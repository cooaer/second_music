package app.dier.music.service;

import android.app.Notification;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.media.session.MediaSession;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;

import app.dier.music.Constants;
import app.dier.music.MusicMessages;
import app.dier.music.R;
import app.dier.music.entity.Song;
import app.dier.music.utils.DisplayUtils;

public class NotificationHelper {

    public static final String CHANNEL_ID_PLAY_MUSIC = "app.dier.music.PLAY";

    private final Context context;

    public NotificationHelper(Context context) {
        this.context = context;
    }

    public Notification createPlayMusicNotification(Song song,
                                                    Bitmap coverBitmap,
                                                    boolean isPlaying,
                                                    MediaSession.Token sessionToken) {
        Notification.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder = new Notification.Builder(context, CHANNEL_ID_PLAY_MUSIC);
        } else {
            builder = new Notification.Builder(context);
        }

        builder.setOnlyAlertOnce(true)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(song.name)
                .setContentText(song.singerName + " - " + song.albumName)
                .addAction(new Notification.Action(android.R.drawable.ic_media_play,
                        context.getString(R.string.notification_action_play),
                        PendingIntent.getService(context,
                                0,
                                new Intent().setAction(Constants.NotificationAction.PLAY),
                                PendingIntent.FLAG_UPDATE_CURRENT)))
                .addAction(new Notification.Action(android.R.drawable.ic_media_pause,
                        context.getString(R.string.notification_action_pause),
                        PendingIntent.getService(context,
                                0,
                                new Intent().setAction(Constants.NotificationAction.PAUSE),
                                PendingIntent.FLAG_UPDATE_CURRENT)))
                .addAction(new Notification.Action(android.R.drawable.ic_media_previous,
                        context.getString(R.string.notification_action_previous),
                        PendingIntent.getService(context,
                                0,
                                new Intent().setAction(Constants.NotificationAction.PREVIOUS),
                                PendingIntent.FLAG_UPDATE_CURRENT)))
                .addAction(new Notification.Action(android.R.drawable.ic_media_next,
                        context.getString(R.string.notification_action_next),
                        PendingIntent.getService(context,
                                0,
                                new Intent().setAction(Constants.NotificationAction.NEXT),
                                PendingIntent.FLAG_UPDATE_CURRENT)));

        Notification.MediaStyle style = new Notification.MediaStyle();
        if (isPlaying) {
            style.setMediaSession(sessionToken);
            style.setShowActionsInCompactView(2, 0, 3);
        } else {
            style.setShowActionsInCompactView(2, 1, 3);
        }
        builder.setStyle(style);

        if (coverBitmap != null) {
            builder.setLargeIcon(coverBitmap);
        }
        return builder.build();
    }

    private void updatePlayMusicNotification(Song song) {
        int dp100 = DisplayUtils.dp2px(100);
        Glide.with(context)
                .asBitmap()
                .load(song.cover)
                .centerCrop()
                .into(new CustomTarget<Bitmap>(dp100, dp100) {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {

                    }

                    @Override
                    public void onLoadCleared(@Nullable Drawable placeholder) {

                    }
                });
    }

}
