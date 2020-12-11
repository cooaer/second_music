package app.dier.music.model;

import app.dier.music.MusicPlayerMessages;

public class Messages {

    public static boolean isEquals(MusicPlayerMessages.SongMessage message1, MusicPlayerMessages.SongMessage message2) {
        if (message1 == null && message2 == null) {
            return true;
        } else if (message1 == null || message2 == null) {
            return false;
        }
        return getSongUniqueId(message1).equals(getSongUniqueId(message2));
    }

    public static String getSongUniqueId(MusicPlayerMessages.SongMessage message) {
        return message.getPlt() + "#" + message.getId();
    }

}
