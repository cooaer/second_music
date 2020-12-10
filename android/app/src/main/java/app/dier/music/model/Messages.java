package app.dier.music.model;

import app.dier.music.MusicPlayerMessages;

public class Messages {

    public static String getSongUniqueId(MusicPlayerMessages.SongMessage message) {
        return message.getPlt() + "#" + message.getId();
    }

}
