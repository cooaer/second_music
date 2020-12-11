package app.dier.music.model;

import java.util.Objects;

import app.dier.music.MusicPlayerMessages.SongMessage;

/**
 * Created by xian on 12/11/20.
 */
public class Song {

    public String plt;
    public String id;
    public String name;
    public String subtitle;
    public String cover;
    public String streamUrl;
    public String description;
    public String albumId;
    public String albumName;
    public String albumCover;
    public String singerId;
    public String singerName;
    public String singerCover;

    public static Song fromSongMessage(SongMessage message) {
        Song song = new Song();
        
        return song;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Song song = (Song) o;
        return plt.equals(song.plt) &&
                id.equals(song.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(plt, id);
    }

    @Override
    public String toString() {
        return "Song{" +
                "plt='" + plt + '\'' +
                ", id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", subtitle='" + subtitle + '\'' +
                ", cover='" + cover + '\'' +
                ", streamUrl='" + streamUrl + '\'' +
                ", description='" + description + '\'' +
                ", albumId='" + albumId + '\'' +
                ", albumName='" + albumName + '\'' +
                ", albumCover='" + albumCover + '\'' +
                ", singerId='" + singerId + '\'' +
                ", singerName='" + singerName + '\'' +
                ", singerCover='" + singerCover + '\'' +
                '}';
    }
}
