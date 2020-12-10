// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class SongListTableCompanion extends UpdateCompanion<SongList> {
  final Value<int> id;
  final Value<String> plt;
  final Value<String> pltId;
  final Value<String> title;
  final Value<String> cover;
  final Value<String> description;
  final Value<int> playCount;
  final Value<int> favorCount;
  final Value<String> userPlt;
  final Value<String> userId;
  final Value<String> userName;
  final Value<String> userAvatar;
  final Value<SongListType> type;
  final Value<DateTime> createdTime;
  final Value<int> songTotal;
  const SongListTableCompanion({
    this.id = const Value.absent(),
    this.plt = const Value.absent(),
    this.pltId = const Value.absent(),
    this.title = const Value.absent(),
    this.cover = const Value.absent(),
    this.description = const Value.absent(),
    this.playCount = const Value.absent(),
    this.favorCount = const Value.absent(),
    this.userPlt = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.userAvatar = const Value.absent(),
    this.type = const Value.absent(),
    this.createdTime = const Value.absent(),
    this.songTotal = const Value.absent(),
  });
  SongListTableCompanion.insert({
    this.id = const Value.absent(),
    required String plt,
    required String pltId,
    required String title,
    required String cover,
    required String description,
    required int playCount,
    required int favorCount,
    required String userPlt,
    required String userId,
    required String userName,
    required String userAvatar,
    required SongListType type,
    this.createdTime = const Value.absent(),
    required int songTotal,
  })  : plt = Value(plt),
        pltId = Value(pltId),
        title = Value(title),
        cover = Value(cover),
        description = Value(description),
        playCount = Value(playCount),
        favorCount = Value(favorCount),
        userPlt = Value(userPlt),
        userId = Value(userId),
        userName = Value(userName),
        userAvatar = Value(userAvatar),
        type = Value(type),
        songTotal = Value(songTotal);
  static Insertable<SongList> custom({
    Expression<int>? id,
    Expression<String>? plt,
    Expression<String>? pltId,
    Expression<String>? title,
    Expression<String>? cover,
    Expression<String>? description,
    Expression<int>? playCount,
    Expression<int>? favorCount,
    Expression<String>? userPlt,
    Expression<String>? userId,
    Expression<String>? userName,
    Expression<String>? userAvatar,
    Expression<SongListType>? type,
    Expression<DateTime>? createdTime,
    Expression<int>? songTotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plt != null) 'plt': plt,
      if (pltId != null) 'plt_id': pltId,
      if (title != null) 'title': title,
      if (cover != null) 'cover': cover,
      if (description != null) 'description': description,
      if (playCount != null) 'play_count': playCount,
      if (favorCount != null) 'favor_count': favorCount,
      if (userPlt != null) 'user_plt': userPlt,
      if (userId != null) 'user_id': userId,
      if (userName != null) 'user_name': userName,
      if (userAvatar != null) 'user_avatar': userAvatar,
      if (type != null) 'type': type,
      if (createdTime != null) 'created_time': createdTime,
      if (songTotal != null) 'song_total': songTotal,
    });
  }

  SongListTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? plt,
      Value<String>? pltId,
      Value<String>? title,
      Value<String>? cover,
      Value<String>? description,
      Value<int>? playCount,
      Value<int>? favorCount,
      Value<String>? userPlt,
      Value<String>? userId,
      Value<String>? userName,
      Value<String>? userAvatar,
      Value<SongListType>? type,
      Value<DateTime>? createdTime,
      Value<int>? songTotal}) {
    return SongListTableCompanion(
      id: id ?? this.id,
      plt: plt ?? this.plt,
      pltId: pltId ?? this.pltId,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      description: description ?? this.description,
      playCount: playCount ?? this.playCount,
      favorCount: favorCount ?? this.favorCount,
      userPlt: userPlt ?? this.userPlt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      type: type ?? this.type,
      createdTime: createdTime ?? this.createdTime,
      songTotal: songTotal ?? this.songTotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plt.present) {
      map['plt'] = Variable<String>(plt.value);
    }
    if (pltId.present) {
      map['plt_id'] = Variable<String>(pltId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (favorCount.present) {
      map['favor_count'] = Variable<int>(favorCount.value);
    }
    if (userPlt.present) {
      map['user_plt'] = Variable<String>(userPlt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (userAvatar.present) {
      map['user_avatar'] = Variable<String>(userAvatar.value);
    }
    if (type.present) {
      final converter = $SongListTableTable.$converter0;
      map['type'] = Variable<int>(converter.mapToSql(type.value)!);
    }
    if (createdTime.present) {
      map['created_time'] = Variable<DateTime>(createdTime.value);
    }
    if (songTotal.present) {
      map['song_total'] = Variable<int>(songTotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongListTableCompanion(')
          ..write('id: $id, ')
          ..write('plt: $plt, ')
          ..write('pltId: $pltId, ')
          ..write('title: $title, ')
          ..write('cover: $cover, ')
          ..write('description: $description, ')
          ..write('playCount: $playCount, ')
          ..write('favorCount: $favorCount, ')
          ..write('userPlt: $userPlt, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('userAvatar: $userAvatar, ')
          ..write('type: $type, ')
          ..write('createdTime: $createdTime, ')
          ..write('songTotal: $songTotal')
          ..write(')'))
        .toString();
  }
}

class $SongListTableTable extends SongListTable
    with TableInfo<$SongListTableTable, SongList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongListTableTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _pltMeta = const VerificationMeta('plt');
  @override
  late final GeneratedColumn<String?> plt = GeneratedColumn<String?>(
      'plt', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _pltIdMeta = const VerificationMeta('pltId');
  @override
  late final GeneratedColumn<String?> pltId = GeneratedColumn<String?>(
      'plt_id', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String?> title = GeneratedColumn<String?>(
      'title', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String?> cover = GeneratedColumn<String?>(
      'cover', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _playCountMeta = const VerificationMeta('playCount');
  @override
  late final GeneratedColumn<int?> playCount = GeneratedColumn<int?>(
      'play_count', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _favorCountMeta = const VerificationMeta('favorCount');
  @override
  late final GeneratedColumn<int?> favorCount = GeneratedColumn<int?>(
      'favor_count', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _userPltMeta = const VerificationMeta('userPlt');
  @override
  late final GeneratedColumn<String?> userPlt = GeneratedColumn<String?>(
      'user_plt', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String?> userId = GeneratedColumn<String?>(
      'user_id', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _userNameMeta = const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String?> userName = GeneratedColumn<String?>(
      'user_name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _userAvatarMeta = const VerificationMeta('userAvatar');
  @override
  late final GeneratedColumn<String?> userAvatar = GeneratedColumn<String?>(
      'user_avatar', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<SongListType, int?> type =
      GeneratedColumn<int?>('type', aliasedName, false,
              type: const IntType(), requiredDuringInsert: true)
          .withConverter<SongListType>($SongListTableTable.$converter0);
  final VerificationMeta _createdTimeMeta =
      const VerificationMeta('createdTime');
  @override
  late final GeneratedColumn<DateTime?> createdTime =
      GeneratedColumn<DateTime?>('created_time', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  final VerificationMeta _songTotalMeta = const VerificationMeta('songTotal');
  @override
  late final GeneratedColumn<int?> songTotal = GeneratedColumn<int?>(
      'song_total', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        plt,
        pltId,
        title,
        cover,
        description,
        playCount,
        favorCount,
        userPlt,
        userId,
        userName,
        userAvatar,
        type,
        createdTime,
        songTotal
      ];
  @override
  String get aliasedName => _alias ?? 'song_list';
  @override
  String get actualTableName => 'song_list';
  @override
  VerificationContext validateIntegrity(Insertable<SongList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plt')) {
      context.handle(
          _pltMeta, plt.isAcceptableOrUnknown(data['plt']!, _pltMeta));
    } else if (isInserting) {
      context.missing(_pltMeta);
    }
    if (data.containsKey('plt_id')) {
      context.handle(
          _pltIdMeta, pltId.isAcceptableOrUnknown(data['plt_id']!, _pltIdMeta));
    } else if (isInserting) {
      context.missing(_pltIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    } else if (isInserting) {
      context.missing(_coverMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('play_count')) {
      context.handle(_playCountMeta,
          playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta));
    } else if (isInserting) {
      context.missing(_playCountMeta);
    }
    if (data.containsKey('favor_count')) {
      context.handle(
          _favorCountMeta,
          favorCount.isAcceptableOrUnknown(
              data['favor_count']!, _favorCountMeta));
    } else if (isInserting) {
      context.missing(_favorCountMeta);
    }
    if (data.containsKey('user_plt')) {
      context.handle(_userPltMeta,
          userPlt.isAcceptableOrUnknown(data['user_plt']!, _userPltMeta));
    } else if (isInserting) {
      context.missing(_userPltMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('user_avatar')) {
      context.handle(
          _userAvatarMeta,
          userAvatar.isAcceptableOrUnknown(
              data['user_avatar']!, _userAvatarMeta));
    } else if (isInserting) {
      context.missing(_userAvatarMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('created_time')) {
      context.handle(
          _createdTimeMeta,
          createdTime.isAcceptableOrUnknown(
              data['created_time']!, _createdTimeMeta));
    }
    if (data.containsKey('song_total')) {
      context.handle(_songTotalMeta,
          songTotal.isAcceptableOrUnknown(data['song_total']!, _songTotalMeta));
    } else if (isInserting) {
      context.missing(_songTotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {plt, pltId, type},
      ];
  @override
  SongList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongList.fromDb(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      plt: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}plt'])!,
      pltId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}plt_id'])!,
      title: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}title'])!,
      cover: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}cover'])!,
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description'])!,
      playCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}play_count'])!,
      favorCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}favor_count'])!,
      userPlt: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}user_plt'])!,
      userId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}user_id'])!,
      userName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}user_name'])!,
      userAvatar: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}user_avatar'])!,
      type: $SongListTableTable.$converter0.mapToDart(const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}type']))!,
      songTotal: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}song_total'])!,
      createdTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}created_time'])!,
    );
  }

  @override
  $SongListTableTable createAlias(String alias) {
    return $SongListTableTable(attachedDatabase, alias);
  }

  static TypeConverter<SongListType, int> $converter0 =
      const EnumIndexConverter<SongListType>(SongListType.values);
}

class SongTableCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<String> plt;
  final Value<String> pltId;
  final Value<String> name;
  final Value<String> subtitle;
  final Value<String> cover;
  final Value<String> streamUrl;
  final Value<String> description;
  final Value<String> singerId;
  final Value<String> singerName;
  final Value<String> singerAvatar;
  final Value<String> albumId;
  final Value<String> albumName;
  final Value<String> albumCover;
  final Value<DateTime?> playedTime;
  const SongTableCompanion({
    this.id = const Value.absent(),
    this.plt = const Value.absent(),
    this.pltId = const Value.absent(),
    this.name = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.cover = const Value.absent(),
    this.streamUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.singerId = const Value.absent(),
    this.singerName = const Value.absent(),
    this.singerAvatar = const Value.absent(),
    this.albumId = const Value.absent(),
    this.albumName = const Value.absent(),
    this.albumCover = const Value.absent(),
    this.playedTime = const Value.absent(),
  });
  SongTableCompanion.insert({
    this.id = const Value.absent(),
    required String plt,
    required String pltId,
    required String name,
    required String subtitle,
    required String cover,
    required String streamUrl,
    required String description,
    required String singerId,
    required String singerName,
    required String singerAvatar,
    required String albumId,
    required String albumName,
    required String albumCover,
    this.playedTime = const Value.absent(),
  })  : plt = Value(plt),
        pltId = Value(pltId),
        name = Value(name),
        subtitle = Value(subtitle),
        cover = Value(cover),
        streamUrl = Value(streamUrl),
        description = Value(description),
        singerId = Value(singerId),
        singerName = Value(singerName),
        singerAvatar = Value(singerAvatar),
        albumId = Value(albumId),
        albumName = Value(albumName),
        albumCover = Value(albumCover);
  static Insertable<Song> custom({
    Expression<int>? id,
    Expression<String>? plt,
    Expression<String>? pltId,
    Expression<String>? name,
    Expression<String>? subtitle,
    Expression<String>? cover,
    Expression<String>? streamUrl,
    Expression<String>? description,
    Expression<String>? singerId,
    Expression<String>? singerName,
    Expression<String>? singerAvatar,
    Expression<String>? albumId,
    Expression<String>? albumName,
    Expression<String>? albumCover,
    Expression<DateTime?>? playedTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plt != null) 'plt': plt,
      if (pltId != null) 'plt_id': pltId,
      if (name != null) 'name': name,
      if (subtitle != null) 'subtitle': subtitle,
      if (cover != null) 'cover': cover,
      if (streamUrl != null) 'stream_url': streamUrl,
      if (description != null) 'description': description,
      if (singerId != null) 'singer_id': singerId,
      if (singerName != null) 'singer_name': singerName,
      if (singerAvatar != null) 'singer_avatar': singerAvatar,
      if (albumId != null) 'album_id': albumId,
      if (albumName != null) 'album_name': albumName,
      if (albumCover != null) 'album_cover': albumCover,
      if (playedTime != null) 'played_time': playedTime,
    });
  }

  SongTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? plt,
      Value<String>? pltId,
      Value<String>? name,
      Value<String>? subtitle,
      Value<String>? cover,
      Value<String>? streamUrl,
      Value<String>? description,
      Value<String>? singerId,
      Value<String>? singerName,
      Value<String>? singerAvatar,
      Value<String>? albumId,
      Value<String>? albumName,
      Value<String>? albumCover,
      Value<DateTime?>? playedTime}) {
    return SongTableCompanion(
      id: id ?? this.id,
      plt: plt ?? this.plt,
      pltId: pltId ?? this.pltId,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      cover: cover ?? this.cover,
      streamUrl: streamUrl ?? this.streamUrl,
      description: description ?? this.description,
      singerId: singerId ?? this.singerId,
      singerName: singerName ?? this.singerName,
      singerAvatar: singerAvatar ?? this.singerAvatar,
      albumId: albumId ?? this.albumId,
      albumName: albumName ?? this.albumName,
      albumCover: albumCover ?? this.albumCover,
      playedTime: playedTime ?? this.playedTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plt.present) {
      map['plt'] = Variable<String>(plt.value);
    }
    if (pltId.present) {
      map['plt_id'] = Variable<String>(pltId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (streamUrl.present) {
      map['stream_url'] = Variable<String>(streamUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (singerId.present) {
      map['singer_id'] = Variable<String>(singerId.value);
    }
    if (singerName.present) {
      map['singer_name'] = Variable<String>(singerName.value);
    }
    if (singerAvatar.present) {
      map['singer_avatar'] = Variable<String>(singerAvatar.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (albumName.present) {
      map['album_name'] = Variable<String>(albumName.value);
    }
    if (albumCover.present) {
      map['album_cover'] = Variable<String>(albumCover.value);
    }
    if (playedTime.present) {
      map['played_time'] = Variable<DateTime?>(playedTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongTableCompanion(')
          ..write('id: $id, ')
          ..write('plt: $plt, ')
          ..write('pltId: $pltId, ')
          ..write('name: $name, ')
          ..write('subtitle: $subtitle, ')
          ..write('cover: $cover, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('description: $description, ')
          ..write('singerId: $singerId, ')
          ..write('singerName: $singerName, ')
          ..write('singerAvatar: $singerAvatar, ')
          ..write('albumId: $albumId, ')
          ..write('albumName: $albumName, ')
          ..write('albumCover: $albumCover, ')
          ..write('playedTime: $playedTime')
          ..write(')'))
        .toString();
  }
}

class $SongTableTable extends SongTable with TableInfo<$SongTableTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongTableTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _pltMeta = const VerificationMeta('plt');
  @override
  late final GeneratedColumn<String?> plt = GeneratedColumn<String?>(
      'plt', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _pltIdMeta = const VerificationMeta('pltId');
  @override
  late final GeneratedColumn<String?> pltId = GeneratedColumn<String?>(
      'plt_id', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _subtitleMeta = const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String?> subtitle = GeneratedColumn<String?>(
      'subtitle', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String?> cover = GeneratedColumn<String?>(
      'cover', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _streamUrlMeta = const VerificationMeta('streamUrl');
  @override
  late final GeneratedColumn<String?> streamUrl = GeneratedColumn<String?>(
      'stream_url', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _singerIdMeta = const VerificationMeta('singerId');
  @override
  late final GeneratedColumn<String?> singerId = GeneratedColumn<String?>(
      'singer_id', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _singerNameMeta = const VerificationMeta('singerName');
  @override
  late final GeneratedColumn<String?> singerName = GeneratedColumn<String?>(
      'singer_name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _singerAvatarMeta =
      const VerificationMeta('singerAvatar');
  @override
  late final GeneratedColumn<String?> singerAvatar = GeneratedColumn<String?>(
      'singer_avatar', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _albumIdMeta = const VerificationMeta('albumId');
  @override
  late final GeneratedColumn<String?> albumId = GeneratedColumn<String?>(
      'album_id', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _albumNameMeta = const VerificationMeta('albumName');
  @override
  late final GeneratedColumn<String?> albumName = GeneratedColumn<String?>(
      'album_name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _albumCoverMeta = const VerificationMeta('albumCover');
  @override
  late final GeneratedColumn<String?> albumCover = GeneratedColumn<String?>(
      'album_cover', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _playedTimeMeta = const VerificationMeta('playedTime');
  @override
  late final GeneratedColumn<DateTime?> playedTime = GeneratedColumn<DateTime?>(
      'played_time', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        plt,
        pltId,
        name,
        subtitle,
        cover,
        streamUrl,
        description,
        singerId,
        singerName,
        singerAvatar,
        albumId,
        albumName,
        albumCover,
        playedTime
      ];
  @override
  String get aliasedName => _alias ?? 'song';
  @override
  String get actualTableName => 'song';
  @override
  VerificationContext validateIntegrity(Insertable<Song> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plt')) {
      context.handle(
          _pltMeta, plt.isAcceptableOrUnknown(data['plt']!, _pltMeta));
    } else if (isInserting) {
      context.missing(_pltMeta);
    }
    if (data.containsKey('plt_id')) {
      context.handle(
          _pltIdMeta, pltId.isAcceptableOrUnknown(data['plt_id']!, _pltIdMeta));
    } else if (isInserting) {
      context.missing(_pltIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    } else if (isInserting) {
      context.missing(_coverMeta);
    }
    if (data.containsKey('stream_url')) {
      context.handle(_streamUrlMeta,
          streamUrl.isAcceptableOrUnknown(data['stream_url']!, _streamUrlMeta));
    } else if (isInserting) {
      context.missing(_streamUrlMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('singer_id')) {
      context.handle(_singerIdMeta,
          singerId.isAcceptableOrUnknown(data['singer_id']!, _singerIdMeta));
    } else if (isInserting) {
      context.missing(_singerIdMeta);
    }
    if (data.containsKey('singer_name')) {
      context.handle(
          _singerNameMeta,
          singerName.isAcceptableOrUnknown(
              data['singer_name']!, _singerNameMeta));
    } else if (isInserting) {
      context.missing(_singerNameMeta);
    }
    if (data.containsKey('singer_avatar')) {
      context.handle(
          _singerAvatarMeta,
          singerAvatar.isAcceptableOrUnknown(
              data['singer_avatar']!, _singerAvatarMeta));
    } else if (isInserting) {
      context.missing(_singerAvatarMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('album_name')) {
      context.handle(_albumNameMeta,
          albumName.isAcceptableOrUnknown(data['album_name']!, _albumNameMeta));
    } else if (isInserting) {
      context.missing(_albumNameMeta);
    }
    if (data.containsKey('album_cover')) {
      context.handle(
          _albumCoverMeta,
          albumCover.isAcceptableOrUnknown(
              data['album_cover']!, _albumCoverMeta));
    } else if (isInserting) {
      context.missing(_albumCoverMeta);
    }
    if (data.containsKey('played_time')) {
      context.handle(
          _playedTimeMeta,
          playedTime.isAcceptableOrUnknown(
              data['played_time']!, _playedTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {plt, pltId},
      ];
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song.fromDb(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      plt: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}plt'])!,
      pltId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}plt_id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      subtitle: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}subtitle'])!,
      cover: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}cover'])!,
      streamUrl: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}stream_url'])!,
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description'])!,
      singerId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}singer_id'])!,
      singerName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}singer_name'])!,
      singerAvatar: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}singer_avatar'])!,
      albumId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}album_id'])!,
      albumName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}album_name'])!,
      albumCover: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}album_cover'])!,
      playedTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}played_time']),
    );
  }

  @override
  $SongTableTable createAlias(String alias) {
    return $SongTableTable(attachedDatabase, alias);
  }
}

class SongListJoinSongTableCompanion extends UpdateCompanion<SongListJoinSong> {
  final Value<int> songListId;
  final Value<int> songId;
  final Value<DateTime> addedTime;
  const SongListJoinSongTableCompanion({
    this.songListId = const Value.absent(),
    this.songId = const Value.absent(),
    this.addedTime = const Value.absent(),
  });
  SongListJoinSongTableCompanion.insert({
    required int songListId,
    required int songId,
    this.addedTime = const Value.absent(),
  })  : songListId = Value(songListId),
        songId = Value(songId);
  static Insertable<SongListJoinSong> custom({
    Expression<int>? songListId,
    Expression<int>? songId,
    Expression<DateTime>? addedTime,
  }) {
    return RawValuesInsertable({
      if (songListId != null) 'song_list_id': songListId,
      if (songId != null) 'song_id': songId,
      if (addedTime != null) 'added_time': addedTime,
    });
  }

  SongListJoinSongTableCompanion copyWith(
      {Value<int>? songListId,
      Value<int>? songId,
      Value<DateTime>? addedTime}) {
    return SongListJoinSongTableCompanion(
      songListId: songListId ?? this.songListId,
      songId: songId ?? this.songId,
      addedTime: addedTime ?? this.addedTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songListId.present) {
      map['song_list_id'] = Variable<int>(songListId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (addedTime.present) {
      map['added_time'] = Variable<DateTime>(addedTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongListJoinSongTableCompanion(')
          ..write('songListId: $songListId, ')
          ..write('songId: $songId, ')
          ..write('addedTime: $addedTime')
          ..write(')'))
        .toString();
  }
}

class $SongListJoinSongTableTable extends SongListJoinSongTable
    with TableInfo<$SongListJoinSongTableTable, SongListJoinSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongListJoinSongTableTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _songListIdMeta = const VerificationMeta('songListId');
  @override
  late final GeneratedColumn<int?> songListId = GeneratedColumn<int?>(
      'song_list_id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int?> songId = GeneratedColumn<int?>(
      'song_id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _addedTimeMeta = const VerificationMeta('addedTime');
  @override
  late final GeneratedColumn<DateTime?> addedTime = GeneratedColumn<DateTime?>(
      'added_time', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [songListId, songId, addedTime];
  @override
  String get aliasedName => _alias ?? 'songlist_song';
  @override
  String get actualTableName => 'songlist_song';
  @override
  VerificationContext validateIntegrity(Insertable<SongListJoinSong> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_list_id')) {
      context.handle(
          _songListIdMeta,
          songListId.isAcceptableOrUnknown(
              data['song_list_id']!, _songListIdMeta));
    } else if (isInserting) {
      context.missing(_songListIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('added_time')) {
      context.handle(_addedTimeMeta,
          addedTime.isAcceptableOrUnknown(data['added_time']!, _addedTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songListId, songId};
  @override
  SongListJoinSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongListJoinSong.fromDb(
      const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}song_list_id'])!,
      const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}song_id'])!,
      const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}added_time'])!,
    );
  }

  @override
  $SongListJoinSongTableTable createAlias(String alias) {
    return $SongListJoinSongTableTable(attachedDatabase, alias);
  }
}

abstract class _$SongDatabase extends GeneratedDatabase {
  _$SongDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $SongListTableTable songListTable = $SongListTableTable(this);
  late final $SongTableTable songTable = $SongTableTable(this);
  late final $SongListJoinSongTableTable songListJoinSongTable =
      $SongListJoinSongTableTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [songListTable, songTable, songListJoinSongTable];
}
