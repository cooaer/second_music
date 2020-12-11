package app.dier.music.service;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;

import app.dier.music.Constants;
import app.dier.music.player.MusicPlayer;
import app.dier.music.player.Playlist;


public class PlayMusicService extends Service {

    public static final int NOTIFICATION_ID_MUSIC = 1;

    private MusicPlayer musicPlayer;
    private Playlist playlist;
    private NotificationHelper notificationHelper;

    @Override
    public void onCreate() {
        super.onCreate();
        musicPlayer = new MusicPlayer(this);
        playlist = new Playlist();
        musicPlayer.setDelegate(playlist);
        notificationHelper = new NotificationHelper(this);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        handleNotificationAction(intent);
        return super.onStartCommand(intent, flags, startId);
    }

    private void handleNotificationAction(Intent intent) {
        String action = intent.getAction();
        switch (action) {
            case Constants.NotificationAction.PLAY:

                break;
            case Constants.NotificationAction.PAUSE:

                break;
            case Constants.NotificationAction.PREVIOUS:

                break;
            case Constants.NotificationAction.NEXT:

                break;
        }
    }

    private void showNotification() {

//        startForeground(NOTIFICATION_ID_MUSIC, notificationHelper.create);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return new PlayMusicBinder();
    }

    public class PlayMusicBinder extends Binder {

        public MusicPlayer getMusicPlayer() {
            return musicPlayer;
        }

        public Playlist getPlaylist() {
            return playlist;
        }

    }


}