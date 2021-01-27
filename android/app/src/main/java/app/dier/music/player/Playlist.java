package app.dier.music.player;

import android.util.Pair;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import app.dier.music.MusicMessages;
import app.dier.music.MusicMessages.MusicPlayerCallbackApi;
import app.dier.music.entity.PlayMode;
import app.dier.music.entity.Song;

import static app.dier.music.entity.PlayMode.repeat;

/**
 * Created by xian on 12/11/20.
 * 运行于主线程；
 */
public class Playlist implements MusicPlayer.MusicPlayerSongDelegate {

    public class SongNode {
        public Song song;
        public SongNode prev;
        public SongNode next;

        public SongNode(Song song) {
            this.song = song;
        }
    }

    private PlayMode playMode = repeat;

    //所有的歌曲
    private final List<Song> songs = new ArrayList<>();
    //播放列表的第一个节点、最后一个节点、当前节点
    private SongNode first, last, current;


    private MusicPlayerCallbackApi callback;

    public void setCallbackApi(MusicPlayerCallbackApi callbackApi) {
        this.callback = callbackApi;
    }

    public boolean containsSong(Song song) {
        return !songs.isEmpty() && songs.contains(song);
    }

    public boolean isEmpty() {
        return songs.isEmpty();
    }

    public int size() {
        return songs.size();
    }

    public void setPlayMode(PlayMode playMode) {
        PlayMode mode = PlayMode.valueOf(playMode.getName());
        if (this.playMode != mode) {
            this.playMode = mode;
            resetPlaylistInternal(songs);
        }
    }

    public void replaceAll(List<Song> songs) {
        resetPlaylistInternal(songs);
    }

    public void addToNext(Song song) {
        if (song == null) {
            return;
        }
        Song currentSong = currentPlayingSong();
        SongNode node = new SongNode(song);
        SongNode prev = current;
        SongNode next = current != null ? current.next : null;

        if (prev == null) {
            first = node;
        } else {
            prev.next = node;
            node.prev = prev;
        }

        if (next == null) {
            last = node;
        } else {
            next.prev = node;
            node.next = next;
        }

        int currentIndex;
        if (currentSong != null && (currentIndex = songs.indexOf(currentSong)) != -1) {
            songs.add(currentIndex + 1, song);
        } else {
            songs.add(song);
        }

        onShowingSongListChanged();
        onPlayingSongListChanged();
    }

    public void delete(Song song) {
        if (song == null) return;

        SongNode node = findNode(song);
        if (node == null) {
            return;
        }
        final SongNode prev = node.prev;
        final SongNode next = node.next;

        if (prev == null) {
            first = next;
        } else {
            prev.next = next;
            node.prev = null;
        }
        if (next == null) {
            last = prev;
        } else {
            next.prev = prev;
            node.next = null;
        }

        songs.remove(song);

        onShowingSongListChanged();
        onPlayingSongListChanged();
    }

    public void clear() {
        Song.recycleAll(songs);
        songs.clear();
        first = null;
        last = null;
        current = null;
        onShowingSongListChanged();
        onPlayingSongListChanged();
    }

    private void resetPlaylistInternal(List<Song> songs) {
        SongNode[] result = null;
        switch (playMode) {
            case repeat:
            case repeatOne:
                result = constructPlaylist(songs);
                break;
            case random:
                List<Song> newSongs = new ArrayList<>(songs);
                Collections.shuffle(newSongs);
                result = constructPlaylist(newSongs);
                break;
        }
        this.songs.clear();
        this.songs.addAll(songs);
        this.first = result[0];
        this.last = result[1];
        this.current = result[2];

        onShowingSongListChanged();
        onPlayingSongListChanged();
    }

    private SongNode[] constructPlaylist(List<Song> songs) {
        SongNode[] nodes = new SongNode[3];
        if (songs.isEmpty()) {
            return nodes;
        }

        SongNode head = new SongNode(null);
        SongNode tail = head;
        Song currentSong = currentPlayingSong();
        SongNode newCurrent = null;
        for (Song song : songs) {
            SongNode songNode = new SongNode(song);
            tail.next = songNode;
            songNode.prev = tail;
            tail = songNode;

            if (newCurrent != null) {
                continue;
            }
            if (song.equals(currentSong)) {
                newCurrent = tail;
            }
        }
        head = head.next;
        if (head != null) {
            head.prev = null;
        }
        nodes[0] = head;
        nodes[1] = tail;
        nodes[2] = newCurrent;
        return nodes;
    }

    // ============  Music Player Song Delegate ============

    public Song currentPlayingSong() {
        return current == null ? null : current.song;
    }

    @Override
    public Song nextPlayingSong() {
        if (current == null) {
            current = first;
            return current == null ? null : current.song;
        }
        switch (playMode) {
            case repeat:
            case random:
                current = current.next;
                if (current == null) {
                    current = first;
                    return current == null ? null : current.song;
                }
                return current.song;
            case repeatOne:
                return current.song;
        }
        return null;
    }

    public Song nextSong() {
        if (current == null) {
            current = first;
            return current == null ? null : current.song;
        }
        current = current.next;
        if (current == null) {
            current = first;
            return current == null ? null : current.song;
        }
        return current.song;
    }

    public Song prevSong() {
        if (current == null) {
            current = last;
            return current == null ? null : current.song;
        }
        current = current.prev;
        if (current == null) {
            current = last;
            return current == null ? null : current.song;
        }
        return current.song;
    }

    public void changeSong(Song song) {
        SongNode songNode = findNode(song);
        if (songNode != null) {
            this.current = songNode;
        }
    }

    private SongNode findNode(Song song) {
        if (song == null) return null;
        SongNode current = first;
        while (current != null) {
            if (song.equals(current.song)) {
                return current;
            }
            current = current.next;
        }
        return null;
    }

    //========== Music Player Callback Api ==========

    private void onShowingSongListChanged() {
        if (callback != null) {
            callback.onShowingSongListChanged(makeSongsMessage(songs), reply -> {
            });
        }
    }

    private void onPlayingSongListChanged() {
        if (callback != null) {
            callback.onPlayingSongListChanged(makeSongsMessage(first), reply -> {
            });
        }
    }

    private MusicMessages.SongsMessage makeSongsMessage(List<Song> songs) {
        MusicMessages.SongsMessage message = new MusicMessages.SongsMessage();
        ArrayList<HashMap<String, Object>> songMessages = new ArrayList<>();
        for (Song song : songs) {
            songMessages.add(song.toMap());
        }
        message.setSongs(songMessages);
        return message;
    }

    private MusicMessages.SongsMessage makeSongsMessage(SongNode head) {
        MusicMessages.SongsMessage message = new MusicMessages.SongsMessage();
        ArrayList<HashMap<String, Object>> songMessages = new ArrayList<>();
        while (head != null) {
            songMessages.add(head.song.toMap());
            head = head.next;
        }
        message.setSongs(songMessages);
        return message;
    }

}
