package app.dier.music.utils;

import android.util.DisplayMetrics;

import app.dier.music.App;

public class DisplayUtils {

    public static int dp2px(int dp) {
        DisplayMetrics metrics = new DisplayMetrics();
        App.get().getDisplay().getRealMetrics(metrics);
        return Math.round(metrics.density * dp);
    }

}
