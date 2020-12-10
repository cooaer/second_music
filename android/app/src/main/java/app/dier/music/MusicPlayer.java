package app.dier.music;

import android.media.MediaPlayer;
import android.os.Handler;
import android.os.Message;

import java.lang.ref.WeakReference;

import app.dier.music.MusicPlayerMessages.StateMessage;
import app.dier.music.MusicPlayerMessages.DurationMessage;
import app.dier.music.model.PlayMode;

public class MusicPlayer implements MusicPlayerMessages.MusicPlayerControllerApi {

    private MediaPlayer player;
    private MusicPlayerMessages.MusicPlayerCallbackApi callbackApi;
    private DurationHandler durationHandler;

    public MusicPlayer() {
        initMediaPlayer();
    }

    private void initMediaPlayer() {
        player = new MediaPlayer();
        durationHandler = new DurationHandler(this);

        player.setOnPreparedListener(this::onPlayerPrepared);
        player.setOnCompletionListener(this::onPlayerCompletion);
        player.setOnErrorListener(this::onPlayerError);
        player.setOnSeekCompleteListener(this::onPlayerSeekComplete);

        //使用Handler嵌套，实现间隔发送音频进度
        player.getCurrentPosition();
    }

    public void setCallbackApi(MusicPlayerMessages.MusicPlayerCallbackApi callbackApi) {
        this.callbackApi = callbackApi;
    }

    //=========== Media Player Callback ===========

    private void onPlayerPrepared(MediaPlayer player) {
        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("prepared");
            callbackApi.onPlayerStateChange(stateMessage, reply -> {
            });
        }
    }

    private void onPlayerCompletion(MediaPlayer player) {
        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("completed");
            callbackApi.onPlayerStateChange(stateMessage, reply -> {
            });
        }
    }

    private void onPlayerSeekComplete(MediaPlayer player) {
        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("seekCompleted");
            callbackApi.onPlayerStateChange(stateMessage, reply -> {
            });
        }
    }

    private boolean onPlayerError(MediaPlayer player, int what, int extra) {
        if (callbackApi != null) {
            StateMessage stateMessage = new StateMessage();
            stateMessage.setState("error");
            callbackApi.onPlayerStateChange(stateMessage, reply -> {
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

    //=========== Media Player Callback ===========


    //=========== Media Player Controller ===========



    @Override
    public void addToPlaylist(MusicPlayerMessages.SongsMessage arg) {

    }

    @Override
    public void removeFromPlaylist(MusicPlayerMessages.SongsMessage arg) {

    }

    @Override
    public void replacePlaylist(MusicPlayerMessages.SongsMessage arg) {

    }

    @Override
    public void setPlayMode(MusicPlayerMessages.PlayModeMessage arg) {
        PlayMode mode = PlayMode.valueOf(arg.getPlayMode());
    }

    @Override
    public void play(MusicPlayerMessages.SongMessage arg) {

    }

    @Override
    public void pause() {

    }

    @Override
    public void resume() {

    }

    @Override
    public void stop() {

    }

    @Override
    public void seek(MusicPlayerMessages.PositionMessage arg) {

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
