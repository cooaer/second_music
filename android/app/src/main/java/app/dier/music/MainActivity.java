package app.dier.music;

import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;

import androidx.annotation.NonNull;

import app.dier.music.service.PlayMusicService;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;

public class MainActivity extends FlutterActivity {

    private PlayMusicServiceConnection playServConn;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        playServConn = new PlayMusicServiceConnection();
        startPlayMusicService();
        bindPlayMusicService();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unbindPlayMusicService();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
    }

    private void startPlayMusicService() {
        Intent intent = new Intent(this, PlayMusicService.class);
        startService(intent);
    }

    private void bindPlayMusicService() {
        Intent intent = new Intent(this, PlayMusicService.class);
        bindService(intent, playServConn, BIND_AUTO_CREATE);
    }

    private void unbindPlayMusicService() {
        unbindService(playServConn);
    }

    private class PlayMusicServiceConnection implements ServiceConnection {

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            PlayMusicService.PlayMusicBinder binder = (PlayMusicService.PlayMusicBinder) service;
            BinaryMessenger binaryMessenger = getFlutterEngine().getDartExecutor();
            binder.getMusicPlayer().setCallbackApi(
                    new MusicMessages.MusicPlayerCallbackApi(binaryMessenger));
            MusicMessages.MusicPlayerControllerApi.setup(
                    binaryMessenger,
                    binder.getMusicPlayer());
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            
        }
    }

}
