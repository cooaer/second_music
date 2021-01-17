package app.dier.music.player;

import android.content.Context;

import com.orhanobut.logger.Logger;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import app.dier.music.MusicMessages;
import app.dier.music.MusicMessages.*;
import app.dier.music.entity.PlayMode;
import app.dier.music.entity.Song;

public class MusicPlayerController implements MusicPlayerControllerApi {

    public static final String TAG = MusicPlayerController.class.getSimpleName();

    private final MusicPlayer musicPlayer;
    private final Playlist playlist;
    private MusicPlayerCallbackApi callback;

    public MusicPlayerController(Context context) {
        this.musicPlayer = new MusicPlayer(context);
        this.playlist = new Playlist();
    }

    public void setCallbackApi(MusicPlayerCallbackApi callbackApi) {
        this.callback = callbackApi;
        this.musicPlayer.setCallbackApi(callbackApi);
        this.playlist.setCallbackApi(callbackApi);
        this.musicPlayer.setSongDelegate(this.playlist);
    }

    @Override
    public void initialize(InitializeMessage message) {

    }

    @Override
    public void setPlayMode(PlayModeMessage message) {
        playlist.setPlayMode(PlayMode.valueOf(message.getPlayMode()));
    }

    @Override
    public void playSong(SongMessage message) {
        Logger.d("%s playSong : " + message.getSong(), TAG);
        Song song = Song.fromMessage(message);
        if (playlist.containsSong(song)) {
            if (song.equals(playlist.currentPlayingSong())) {
                if (!musicPlayer.isPlaying()) {
                    musicPlayer.play();
                }
            } else {
                playlist.changeSong(song);
                musicPlayer.play();
            }
        } else {
            playlist.addToNext(song);
            playlist.nextSong();
            musicPlayer.play();
        }
    }

    @Override
    public void playSongList(SongsMessage message) {
        Logger.d("%s playSongList : " + message.getSongs(), TAG);
        Song currentSong = playlist.currentPlayingSong();
        List<Song> songs = new ArrayList<>();
        if (message.getSongs() != null) {
            for (Object obj : message.getSongs()) {
                if (obj instanceof Map) {
                    songs.add(Song.fromMap((Map) obj));
                }
            }
        }
        playlist.replaceAll(songs);
        if (musicPlayer.isPlaying() && (currentSong == null || !songs.contains(currentSong))) {
            musicPlayer.stop();
        }
        musicPlayer.play();
    }

    @Override
    public void playPrev() {
        Logger.d("%s playPrev", TAG);
        int playlistSize = playlist.size();
        if (playlistSize == 0 || playlistSize == 1) {
            return;
        }
        if (playlist.prevSong() == null) {
            return;
        }
        musicPlayer.stop();
        musicPlayer.play();
    }

    @Override
    public void playNext() {
        Logger.d("%s playNext", TAG);
        int playlistSize = playlist.size();
        if (playlistSize == 0 || playlistSize == 1) {
            return;
        }
        if (playlist.nextPlayingSong() == null) {
            return;
        }
        musicPlayer.stop();
        musicPlayer.play();
    }

    @Override
    public void play() {
        Logger.d("%s play", TAG);
        musicPlayer.play();
    }

    @Override
    public void pause() {
        Logger.d("%s pause", TAG);
        musicPlayer.pause();
    }

    @Override
    public void seekTo(MusicMessages.PositionMessage message) {
        Logger.d("%s seekTo : " + message.getPosition(), TAG);
        musicPlayer.seekTo(message.getPosition().intValue());
    }

    @Override
    public void addSongToPlaylistNext(SongMessage message) {
        Logger.d("%s addSongToPlaylistNext : " + message.getSong(), TAG);
        playlist.addToNext(Song.fromMessage(message));
    }

    @Override
    public void deleteSongFromPlaylist(SongMessage message) {
        Logger.d("%s deleteSongFromPlaylist : " + message.getSong(), TAG);
        Song song = Song.fromMessage(message);
        boolean isPlaying = musicPlayer.isPlaying();
        boolean isCurrentSong = song.equals(playlist.currentPlayingSong());

        playlist.delete(song);
        if (isCurrentSong) {
            musicPlayer.stop();
            if (isPlaying) {
                if (!playlist.isEmpty()) {
                    musicPlayer.play();
                }
            }
        }
    }

    @Override
    public void clearPlaylist() {
        Logger.d("%s clearPlayList", TAG);
        if (musicPlayer.isPlaying()) {
            musicPlayer.stop();
        }
        playlist.clear();
    }
}
