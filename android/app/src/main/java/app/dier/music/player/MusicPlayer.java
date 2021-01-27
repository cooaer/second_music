package app.dier.music.player;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.lang.ref.WeakReference;

import app.dier.music.MusicMessages;
import app.dier.music.MusicMessages.MusicPlayerCallbackApi;
import app.dier.music.MusicMessages.StateMessage;
import app.dier.music.entity.Song;

public class MusicPlayer implements AudioManager.OnAudioFocusChangeListener {

    public static final String TAG = MusicPlayer.class.getSimpleName();

    public interface MusicPlayerSongDelegate {
        Song currentPlayingSong();

        Song nextPlayingSong();
    }

    private final Context context;
    private MediaPlayer player;
    private AudioManager audioManager;
    private AudioFocusRequest audioFocusRequest;

    private boolean isPlaying = false;
    private boolean isPausedByUser = false;
    private boolean isPrepared = false;
    private boolean isReleased = false;
    private int shouldSeekTo = -1;

    private Handler durationHandler;
    private MusicPlayerCallbackApi callbackApi;
    private MusicPlayerSongDelegate songDelegate;

    private UpdatePositionCallback updatePositionCallback;

    public MusicPlayer(Context context) {
        this.context = context;
        durationHandler = new Handler(Looper.myLooper());
    }

    private MediaPlayer createMediaPlayer() {
        MediaPlayer player = new MediaPlayer();
        player.setOnPreparedListener(this::onPlayerPrepared);
        player.setOnCompletionListener(this::onPlayerCompletion);
        player.setOnErrorListener(this::onPlayerError);
        player.setOnSeekCompleteListener(this::onPlayerSeekComplete);
        return player;
    }

    public void setCallbackApi(MusicPlayerCallbackApi callbackApi) {
        this.callbackApi = callbackApi;
    }

    public void setSongDelegate(MusicPlayerSongDelegate songDelegate) {
        this.songDelegate = songDelegate;
    }

    public boolean isPlaying() {
        return isPlaying;
    }

    //=========== Media Player Callback ===========

    private void onPlayerPrepared(MediaPlayer player) {
        isPrepared = true;

        if (shouldSeekTo > 0) {
            player.seekTo(shouldSeekTo);
            shouldSeekTo = -1;
        }

        onPlayerStateChanged("prepared");

        if (isPlaying) {
            player.start();
            onPlayerStateChanged("playing");
            listenPositionChanged();
        }
    }

    private void onPlayerCompletion(MediaPlayer player) {
        stop();
        onPlayerStateChanged("completed");

        if (songDelegate == null) {
            Log.e(TAG, "onPlayerCompletion, songDelegate is null");
            return;
        }
        Song nextSong = songDelegate.nextPlayingSong();
        if (nextSong == null) {
            Log.w(TAG, "onPlayerCompletion, nextSong is null");
            return;
        }
        onPlayingSongChanged(nextSong);
        play();
    }

    private void onPlayerSeekComplete(MediaPlayer player) {
        onPlayerStateChanged("seekCompleted");
    }

    private boolean onPlayerError(MediaPlayer player, int what, int extra) {
        onPlayerStateChanged("error");
        return false;
    }

    private void onPlayerStateChanged(String state) {
        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState(state);
            callbackApi.onPlayerStateChanged(stateMessage, reply -> {
            });
        }
    }

    private void onPlayingSongChanged(Song song) {
        if (callbackApi != null) {
            callbackApi.onPlayingSongChanged(song.toMessage(), reply -> {
            });
        }
    }

    @Override
    public void onAudioFocusChange(int focusChange) {
        switch (focusChange) {
            case AudioManager.AUDIOFOCUS_GAIN:
            case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT:
                if (!isPausedByUser) {
                    playInternal();
                }
                break;
            case AudioManager.AUDIOFOCUS_LOSS:
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                pauseInternal(false);
                break;
        }
    }
    //=========== Media Player Callback ===========


    //=========== Media Player Controller ===========

    public void play() {
        AudioManager audioManager = getAudioManager();
        int requestFocusResult;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            AudioFocusRequest.Builder builder = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN);
            builder.setAudioAttributes(new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .build())
                    .setOnAudioFocusChangeListener(this);
            this.audioFocusRequest = builder.build();
            //再次注册会覆盖之前注册的音频焦点请求
            requestFocusResult = audioManager.requestAudioFocus(this.audioFocusRequest);
        } else {
            requestFocusResult = audioManager.requestAudioFocus(this, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN);
        }
        if (requestFocusResult == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            playInternal();
        }
    }

    private AudioManager getAudioManager() {
        if (audioManager == null) {
            audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        }
        return audioManager;
    }

    private void playInternal() {
        if (isPlaying) {
            return;
        }
        isPlaying = true;
        isPausedByUser = false;
        if (!isPrepared) {
            if (setSource()) {
                player.prepareAsync();
            }
        } else {
            player.start();
            onPlayerStateChanged("playing");
            listenPositionChanged();
        }
    }

    private boolean setSource() {
        if (songDelegate == null) {
            Log.e(TAG, "setSource, songDelegate is null");
            return false;
        }
        Song song = songDelegate.currentPlayingSong();
        if (song == null) {
            Log.w(TAG, "current song is null");
            return false;
        }
        onPlayingSongChanged(song);
        try {
            this.player = createMediaPlayer();
            this.player.setDataSource(context, Uri.parse(song.streamUrl));
        } catch (IOException e) {
            e.printStackTrace();
        }
        return true;
    }

    public void pause() {
        pauseInternal(true);
    }

    public void pauseInternal(boolean byUser) {
        if (isPlaying) {
            isPlaying = false;
            isPausedByUser = byUser;
            player.pause();
            onPlayerStateChanged("paused");
            removePositionChangedCallback();
        }
    }

    public void stop() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (audioFocusRequest != null) {
                audioManager.abandonAudioFocusRequest(audioFocusRequest);
            }
        } else {
            audioManager.abandonAudioFocus(this);
        }
        if(player != null){
            player.stop();
            player.release();
        }
        onPlayerStateChanged("stopped");
        isPlaying = false;
        isPrepared = false;
        removePositionChangedCallback();
        player = null;
    }

    public void seekTo(int position) {
        if (isPrepared) {
            player.seekTo(position);
        } else {
            shouldSeekTo = position;
        }
    }

    //=========== Media Player Controller ===========

    // listen duration change
    private void listenPositionChanged() {
        updatePositionCallback = new UpdatePositionCallback(this);
        durationHandler.postDelayed(updatePositionCallback, 300);
    }

    private void removePositionChangedCallback() {
        durationHandler.removeCallbacks(updatePositionCallback);
    }

    private void updatePosition() {
        if (callbackApi != null) {
            MusicMessages.PositionMessage message = new MusicMessages.PositionMessage();
            message.setPosition((long) player.getCurrentPosition());
            message.setDuration((long) player.getDuration());
//            Logger.d("%s updatePosition , position : %s, duration %s", TAG, message.getPosition().toString(), message.getDuration().toString());
            callbackApi.onPositionChanged(message, reply -> {
            });
        }
    }

    private static class UpdatePositionCallback implements Runnable {

        private final WeakReference<MusicPlayer> ref;

        public UpdatePositionCallback(MusicPlayer musicPlayer) {
            this.ref = new WeakReference<>(musicPlayer);
        }

        @Override
        public void run() {
            if (ref.get() == null) {
                return;
            }
            ref.get().updatePosition();
            ref.get().durationHandler.postDelayed(this, 300);
        }
    }

}
