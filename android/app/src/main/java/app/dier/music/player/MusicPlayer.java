package app.dier.music.player;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Message;

import java.io.IOException;
import java.lang.ref.WeakReference;

import app.dier.music.MusicPlayerMessages;
import app.dier.music.MusicPlayerMessages.DurationMessage;
import app.dier.music.MusicPlayerMessages.SongMessage;
import app.dier.music.MusicPlayerMessages.StateMessage;

public class MusicPlayer implements MusicPlayerMessages.MusicPlayerControllerApi, AudioManager.OnAudioFocusChangeListener {

    public interface MusicPlayerDelegate {

        void resetPlaylist();

        SongMessage currentSong();

        SongMessage nextSong();

        void changeSong(SongMessage song);

    }

    private Context context;
    private MediaPlayer player;
    private AudioManager audioManager;
    private AudioFocusRequest audioFocusRequest;

    private boolean isPlaying = false;
    private boolean isPrepared = false;
    private int shouldSeekTo = -1;

    private DurationHandler durationHandler;
    private MusicPlayerMessages.MusicPlayerCallbackApi callbackApi;
    private MusicPlayerDelegate delegate;

    public MusicPlayer(Context context) {
        this.context = context;
        initMediaPlayer();
    }

    private void initMediaPlayer() {
        player = new MediaPlayer();
        durationHandler = new DurationHandler(this);

        player.setOnPreparedListener(this::onPlayerPrepared);
        player.setOnCompletionListener(this::onPlayerCompletion);
        player.setOnErrorListener(this::onPlayerError);
        player.setOnSeekCompleteListener(this::onPlayerSeekComplete);
    }

    public void setCallbackApi(MusicPlayerMessages.MusicPlayerCallbackApi callbackApi) {
        this.callbackApi = callbackApi;
    }

    public void setDelegate(MusicPlayerDelegate delegate) {
        this.delegate = delegate;
    }

    //=========== Media Player Callback ===========

    private void onPlayerPrepared(MediaPlayer player) {
        isPrepared = true;

        if (shouldSeekTo > 0) {
            player.seekTo(shouldSeekTo);
            shouldSeekTo = -1;
        }

        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("prepared");
            callbackApi.onPlayerStateChanged(stateMessage, reply -> {
            });
        }
    }

    private void onPlayerCompletion(MediaPlayer player) {
        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("completed");
            callbackApi.onPlayerStateChanged(stateMessage, reply -> {
            });
        }
    }

    private void onPlayerSeekComplete(MediaPlayer player) {
        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("seekCompleted");
            callbackApi.onPlayerStateChanged(stateMessage, reply -> {
            });
        }
    }

    private boolean onPlayerError(MediaPlayer player, int what, int extra) {
        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("error");
            callbackApi.onPlayerStateChanged(stateMessage, reply -> {
            });
        }
        return false;
    }

    private void onDurationChanged() {
        if (callbackApi != null) {
            long duration = player.getDuration();
            DurationMessage durationMessage = new DurationMessage();
            durationMessage.setDuration(duration);
            callbackApi.onDurationChanged(durationMessage, reply -> {
            });
        }
    }

    @Override
    public void onAudioFocusChange(int focusChange) {
        if (focusChange == AudioManager.AUDIOFOCUS_GAIN) {
            playInternal();
        }
    }

    //=========== Media Player Callback ===========


    //=========== Media Player Controller ===========

    @Override
    public void playSong(SongMessage arg) {
        if (!delegate.currentSong().equals(arg)) {
            delegate.changeSong(arg);
        }
        if (!isPlaying) {
            play();
        }
    }

    @Override
    public void play() {
        AudioManager audioManager = getAudioManager();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            AudioFocusRequest.Builder builder = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN);
            builder.setAudioAttributes(new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .build())
                    .setOnAudioFocusChangeListener(this);
            this.audioFocusRequest = builder.build();
            audioManager.requestAudioFocus(this.audioFocusRequest);
        } else {
            int result = audioManager.requestAudioFocus(this, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN);
            if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                playInternal();
            }
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
        if (!isPrepared) {
            setSource();
            player.prepareAsync();
        } else {
            player.start();
        }
    }

    private void setSource() {
        SongMessage song = delegate.currentSong();
        try {
            player.setDataSource(context, Uri.parse(song.getStreamUrl()));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void pause() {
        if (isPlaying) {
            isPlaying = false;
            player.pause();
        }
    }

    @Override
    public void stop() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (audioFocusRequest != null) {
                audioManager.abandonAudioFocusRequest(audioFocusRequest);
            }
        } else {
            audioManager.abandonAudioFocus(this);
        }
        player.stop();
        isPlaying = false;
        isPrepared = false;
    }

    @Override
    public void seek(MusicPlayerMessages.PositionMessage arg) {
        if (isPrepared) {
            player.seekTo(arg.getPosition().intValue());
        } else {
            shouldSeekTo = arg.getPosition().intValue();
        }
    }

    //=========== Media Player Controller ===========

    // listen duration change

    private void listenDurationChanged() {
        durationHandler.postDelayed(durationRunnable, 300);
    }

    private void removeDurationListener() {
        durationHandler.removeCallbacks(durationRunnable);
    }

    private final Runnable durationRunnable = new Runnable() {
        @Override
        public void run() {
            onDurationChanged();
            listenDurationChanged();
        }
    };

    private static class DurationHandler extends Handler {

        private final WeakReference<MusicPlayer> ref;

        public DurationHandler(MusicPlayer musicPlayer) {
            this.ref = new WeakReference<>(musicPlayer);
        }

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);

        }
    }

}
