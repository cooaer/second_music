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

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import app.dier.music.MusicMessages;
import app.dier.music.MusicMessages.SongMessage;
import app.dier.music.MusicMessages.StateMessage;
import app.dier.music.MusicMessages.MusicPlayerCallbackApi;
import app.dier.music.MusicMessages.MusicPlayerControllerApi;
import app.dier.music.MusicMessages.MusicPlayerDelegateApi;

public class MusicPlayer implements MusicPlayerControllerApi, AudioManager.OnAudioFocusChangeListener {

    private final Context context;
    private MediaPlayer player;
    private AudioManager audioManager;
    private AudioFocusRequest audioFocusRequest;

    private int currentIndex = -1;
    private List<SongMessage> songs = new ArrayList<>();


    private boolean isPlaying = false;
    private boolean isPrepared = false;
    private int shouldSeekTo = -1;

    private Handler durationHandler;
    private MusicPlayerCallbackApi callbackApi;

    private UpdatePositionCallback updatePositionCallback;

    public MusicPlayer(Context context) {
        this.context = context;
        initMediaPlayer();
    }

    private void initMediaPlayer() {
        player = new MediaPlayer();
        durationHandler = new Handler(Looper.myLooper());

        player.setOnPreparedListener(this::onPlayerPrepared);
        player.setOnCompletionListener(this::onPlayerCompletion);
        player.setOnErrorListener(this::onPlayerError);
        player.setOnSeekCompleteListener(this::onPlayerSeekComplete);
    }

    public void setCallbackApi(MusicPlayerCallbackApi callbackApi) {
        this.callbackApi = callbackApi;
    }

    private SongMessage currentSong() {
        if (songs.isEmpty()) {
            currentIndex = -1;
            return null;
        }
        if (currentIndex < 0 || currentIndex > songs.size()) {
            currentIndex = 0;
        }
        return songs.get(currentIndex);
    }

    private SongMessage nextSong() {
        if (songs.isEmpty()) {
            currentIndex = -1;
            return null;
        }
        currentIndex = (currentIndex + 1) % songs.size();
        return songs.get(currentIndex);
    }

    private void changeSong(SongMessage song) {
        currentIndex = songs.indexOf(song);
    }

    //=========== Media Player Callback ===========

    private void onPlayerPrepared(MediaPlayer player) {
        isPrepared = true;

        if (shouldSeekTo > 0) {
            player.seekTo(shouldSeekTo);
            shouldSeekTo = -1;
        }

        if (isPlaying) {
            player.start();
            listenPositionChanged();
        }

        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("prepared");
            callbackApi.onPlayerStateChanged(stateMessage, reply -> {
            });
        }
    }

    private void onPlayerCompletion(MediaPlayer player) {
        isPlaying = false;
        SongMessage nextSong = nextSong();
        if (nextSong != null) {
            playSong(nextSong);
        }

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

    @Override
    public void onAudioFocusChange(int focusChange) {
        switch (focusChange) {
            case AudioManager.AUDIOFOCUS_GAIN:
            case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT:
                playInternal();
                break;
            case AudioManager.AUDIOFOCUS_LOSS:
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                pause();
                break;
        }
    }

    //=========== Media Player Callback ===========


    //=========== Media Player Controller ===========


    @Override
    public void syncPlaylist(MusicMessages.SongsMessage arg) {
        SongMessage currentSong = currentSong();
        songs.clear();
        if (arg.getSongs() != null) {
            songs.addAll(arg.getSongs());
            if (currentSong != null) {
                currentIndex = songs.indexOf(currentSong);
            }
        }
    }

    @Override
    public void playSong(SongMessage arg) {
        SongMessage currentSong = currentSong();
        if (currentSong == null || !currentSong.equals(arg)) {
            changeSong(arg);
            play();
        } else {
            playInternal();
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
            listenPositionChanged();
        }
    }

    private void setSource() {
        SongMessage song = currentSong();
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
            removePositionChangedCallback();
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
        removePositionChangedCallback();
    }

    @Override
    public void seek(MusicMessages.PositionMessage arg) {
        if (isPrepared) {
            player.seekTo(arg.getPosition().intValue());
        } else {
            shouldSeekTo = arg.getPosition().intValue();
        }
    }

    //=========== Media Player Controller ===========

    // listen duration change
    private void listenPositionChanged() {
        if (updatePositionCallback != null) {
            return;
        }
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
            ref.get().listenPositionChanged();
        }
    }

}
