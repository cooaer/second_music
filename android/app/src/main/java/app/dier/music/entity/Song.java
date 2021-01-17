package app.dier.music.entity;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Objects;
import java.util.concurrent.ConcurrentLinkedDeque;

import app.dier.music.MusicMessages.SongMessage;

/**
 * Created by xian on 12/11/20.
 */
public class Song {

    public String plt;
    public String id;
    public String name;
    public String cover;
    public String streamUrl;
    public String albumName;
    public String singerName;

    public static Song fromMessage(SongMessage message) {
        if (message == null) return null;
        return fromMap(message.getSong());
    }

    public static Song fromMap(Map<String, Object> map) {
        Song song = obtain();
        if (map == null) {
            return song;
        }
        HashMap<String, Object> songMap = (HashMap<String, Object>) map;
        for (Map.Entry<String, Object> entry : songMap.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue().toString();
            switch (key) {
                case "plt":
                    song.plt = value;
                    break;
                case "id":
                    song.id = value;
                    break;
                case "name":
                    song.name = value;
                    break;
                case "cover":
                    song.cover = value;
                    break;
                case "streamUrl":
                    song.streamUrl = value;
                    break;
                case "albumName":
                    song.albumName = value;
                    break;
                case "singerName":
                    song.singerName = value;
                    break;
            }
        }
        return song;
    }

    public String getUniqueId() {
        return this.plt + "#" + this.id;
    }

    public SongMessage toMessage() {
        SongMessage message = new SongMessage();
        message.setSong(toMap());
        return message;
    }

    @NotNull
    public HashMap<String, Object> toMap() {
        HashMap<String, Object> song = new HashMap<>();
        song.put("plt", plt);
        song.put("id", id);
        song.put("name", name);
        song.put("cover", cover);
        song.put("streamUrl", streamUrl);
        song.put("albumName", albumName);
        song.put("singerName", singerName);
        return song;
    }


    public Song reset() {
        this.plt = "";
        this.id = "";
        this.name = "";
        this.cover = "";
        this.streamUrl = "";
        this.albumName = "";
        this.singerName = "";
        return this;
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

    @NotNull
    @Override
    public String toString() {
        return "Song{" +
                "plt='" + plt + '\'' +
                ", id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", cover='" + cover + '\'' +
                ", streamUrl='" + streamUrl + '\'' +
                ", albumName='" + albumName + '\'' +
                ", singerName='" + singerName + '\'' +
                '}';
    }

    private static final ConcurrentLinkedDeque<Song> caches = new ConcurrentLinkedDeque<>();

    public static Song obtain() {
        if (caches.isEmpty()) {
            return new Song();
        }
        return caches.removeFirst().reset();
    }

    public static void recycleAll(List<Song> songs) {
        caches.addAll(songs);
    }

    public static void recycle(Song song) {
        caches.addLast(song);
    }

}
