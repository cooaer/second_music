package app.dier.music.service;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;

import app.dier.music.Constants;
import app.dier.music.player.MusicPlayerController;


public class PlayMusicService extends Service {

    public static final int NOTIFICATION_ID_MUSIC = 1;

    private MusicPlayerController musicPlayerController;
    private NotificationHelper notificationHelper;

    @Override
    public void onCreate() {
        super.onCreate();
        musicPlayerController = new MusicPlayerController(this);
        notificationHelper = new NotificationHelper(this);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        handleNotificationAction(intent);
        return super.onStartCommand(intent, flags, startId);
    }

    private void handleNotificationAction(Intent intent) {
        String action = intent.getAction();
        if(action == null){
            return;
        }
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

        public MusicPlayerController getMusicPlayerController() {
            return musicPlayerController;
        }

    }


}