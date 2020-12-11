package app.dier.music.player;

import android.text.TextUtils;
import android.util.Pair;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import app.dier.music.MusicPlayerMessages;
import app.dier.music.MusicPlayerMessages.PlayModeMessage;
import app.dier.music.MusicPlayerMessages.SongMessage;
import app.dier.music.MusicPlayerMessages.SongsMessage;
import app.dier.music.model.Messages;
import app.dier.music.model.PlayMode;

import static app.dier.music.model.PlayMode.repeat;

/**
 * Created by xian on 12/11/20.
 */
public class Playlist implements MusicPlayerMessages.PlaylistControllerApi, MusicPlayer.MusicPlayerDelegate {

    public class Node {
        public SongMessage song;
        public Node prev;
        public Node next;

        public Node(SongMessage song) {
            this.song = song;
        }
    }

    private PlayMode playMode = repeat;

    //所有的歌曲
    private final List<SongMessage> songs = new ArrayList<>();

    //播放列表
    private Node playlist;
    //当前播放列表
    private Node current;

    @Override
    public void addToPlaylist(SongsMessage arg) {
        List<SongMessage> newSongs = new ArrayList<>(songs);
        newSongs.addAll(arg.getSongs());
        resetPlaylistInternal(newSongs);
    }

    @Override
    public void removeFromPlaylist(SongsMessage arg) {
        List<SongMessage> newSongs = new ArrayList<>(songs);
        newSongs.removeAll(arg.getSongs());
        resetPlaylistInternal(newSongs);
    }

    @Override
    public void replacePlaylist(SongsMessage arg) {
        resetPlaylistInternal(arg.getSongs());
    }

    @Override
    public void setPlayMode(PlayModeMessage arg) {
        PlayMode mode = PlayMode.valueOf(arg.getPlayMode());
        if (this.playMode != mode) {
            this.playMode = mode;
            resetPlaylist();
        }
    }

    private void resetPlaylistInternal(List<SongMessage> songs) {
        Pair<Node, Node> result = null;
        switch (playMode) {
            case repeat:
            case repeatOne:
                result = constructPlaylist(songs);
                break;
            case random:
                List<SongMessage> newSongs = new ArrayList<>(songs);
                Collections.shuffle(newSongs);
                result = constructPlaylist(newSongs);
                break;
        }
        if (result != null) {
            this.playlist = result.first;
            this.current = result.second;
        }
    }

    private Pair<Node, Node> constructPlaylist(List<SongMessage> songs) {
        if (songs.isEmpty()) {
            return new Pair<>(null, null);
        }
        Node head = new Node(null);
        Node tail = head;
        String currentId = Messages.getSongUniqueId(current.song);
        Node newCurrent = null;
        for (SongMessage song : songs) {
            Node node = new Node(song);
            tail.prev = node;
            node.next = tail;
            tail = node;

            if (newCurrent != null) {
                continue;
            }
            String thisId = Messages.getSongUniqueId(song);
            if (currentId.equals(thisId)) {
                newCurrent = tail;
            }
        }
        return new Pair<>(head, newCurrent);
    }

    // ============  Music Player Delegate ============

    @Override
    public void resetPlaylist() {
        resetPlaylistInternal(songs);
    }

    public SongMessage currentSong() {
        return current == null ? null : current.song;
    }

    @Override
    public SongMessage nextSong() {
        if (current == null) {
            current = playlist;
            return current == null ? null : current.song;
        }
        switch (playMode) {
            case repeat:
            case random:
                current = current.next;
                if (current == null) {
                    current = playlist;
                    return current == null ? null : current.song;
                }
                return current.song;
            case repeatOne:
                return current == null ? null : current.song;
        }
        return null;
    }

    @Override
    public void changeSong(SongMessage song) {
        Node node = findNode(song);
        if (node != null) {
            this.current = node;
            return;
        }
        ArrayList newSongs = new ArrayList();
        newSongs.add(song);
        SongsMessage songsMessage = new SongsMessage();
        songsMessage.setSongs(newSongs);
        addToPlaylist(songsMessage);
    }

    private Node findNode(SongMessage song) {
        Node current = playlist;
        String songId = Messages.getSongUniqueId(song);
        while (current != null) {
            String currentSongId = Messages.getSongUniqueId(current.song);
            if (TextUtils.equals(songId, currentSongId)) {
                return current;
            }
            current = current.next;
        }
        return null;
    }

}
