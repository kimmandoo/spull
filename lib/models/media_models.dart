import 'dart:convert';

enum DownloadFormat { mp3, wav, m4a, flac, mp4, webm }

const audioQualityOptions = <String>['128K', '192K', '256K', '320K'];
const videoQualityOptions = <String>[
  'best',
  '2160p',
  '1440p',
  '1080p',
  '720p',
  '480p',
  '360p',
];

extension DownloadFormatX on DownloadFormat {
  String get value => name;
  String get label => name.toUpperCase();
  bool get isAudio => const {
    DownloadFormat.mp3,
    DownloadFormat.wav,
    DownloadFormat.m4a,
    DownloadFormat.flac,
  }.contains(this);
  bool get isVideo => !isAudio;
}

DownloadFormat downloadFormatFromValue(String value) {
  return DownloadFormat.values.firstWhere(
    (format) => format.value == value,
    orElse: () => DownloadFormat.mp3,
  );
}

String _qualityOrDefault(
  dynamic rawValue,
  List<String> options,
  String fallback,
) {
  final value = rawValue?.toString();
  return value != null && options.contains(value) ? value : fallback;
}

class UrlRow {
  UrlRow({required this.id, this.value = ''});

  final String id;
  String value;
}

String? _firstNonEmptyString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

String _entryUrl(Map<String, dynamic> json, {String? fallbackUrl}) {
  final webpageUrl = _firstNonEmptyString(json, <String>[
    'webpage_url',
    'original_url',
  ]);
  if (webpageUrl != null) return webpageUrl;

  final url = _firstNonEmptyString(json, <String>['url']);
  if (url == null) return fallbackUrl ?? '';
  final parsed = Uri.tryParse(url);
  if (parsed?.hasScheme == true) return url;

  final extractor =
      (_firstNonEmptyString(json, <String>[
                'ie_key',
                'extractor_key',
                'extractor',
              ]) ??
              '')
          .toLowerCase();
  final id = _firstNonEmptyString(json, <String>['id']) ?? url;
  if (extractor.contains('youtube') &&
      !id.contains('/') &&
      !id.contains('?') &&
      id.isNotEmpty) {
    return 'https://www.youtube.com/watch?v=$id';
  }
  return url;
}

class VideoEntry {
  VideoEntry({
    required this.id,
    required this.title,
    required this.url,
    this.source,
    this.thumbnail,
    this.duration,
    this.durationString,
    this.selected = true,
  });

  final String id;
  final String title;
  final String url;
  final String? source;
  final String? thumbnail;
  final double? duration;
  final String? durationString;
  bool selected;

  String get displayDuration {
    if (durationString?.isNotEmpty == true) return durationString!;
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration!.round() % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory VideoEntry.fromJson(
    Map<String, dynamic> json, {
    String? fallbackUrl,
  }) {
    final rawDuration = json['duration'];
    final duration = rawDuration is num ? rawDuration.toDouble() : null;
    return VideoEntry(
      id: (json['id'] ?? json['url'] ?? DateTime.now().microsecondsSinceEpoch)
          .toString(),
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : '제목 없음',
      url: _entryUrl(json, fallbackUrl: fallbackUrl),
      source: (json['source'] ?? json['extractor_key'] ?? json['extractor'])
          ?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      duration: duration,
      durationString: json['duration_string']?.toString(),
      selected: json['selected'] as bool? ?? true,
    );
  }
}

class PlaylistInfo {
  PlaylistInfo({
    required this.title,
    required this.entries,
    required this.isPlaylist,
  });

  final String title;
  final List<VideoEntry> entries;
  final bool isPlaylist;

  factory PlaylistInfo.fromJson(
    Map<String, dynamic> json, {
    required String sourceUrl,
  }) {
    final isPlaylist = json['_type'] == 'playlist' || json['entries'] is List;
    final rawEntries = (json['entries'] as List<dynamic>?) ?? <dynamic>[json];
    final entries = <VideoEntry>[];
    final fallbackUrl = isPlaylist ? null : sourceUrl;
    for (final raw in rawEntries) {
      if (raw is Map<String, dynamic>) {
        final entry = VideoEntry.fromJson(raw, fallbackUrl: fallbackUrl);
        if (entry.url.isNotEmpty) entries.add(entry);
      } else if (raw is Map) {
        final entry = VideoEntry.fromJson(
          Map<String, dynamic>.from(raw),
          fallbackUrl: fallbackUrl,
        );
        if (entry.url.isNotEmpty) entries.add(entry);
      }
    }
    return PlaylistInfo(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : (isPlaylist ? '플레이리스트' : '영상'),
      entries: entries,
      isPlaylist: isPlaylist,
    );
  }
}

class AppSettings {
  const AppSettings({
    this.downloadDir,
    this.format = DownloadFormat.mp3,
    this.audioQuality = '320K',
    this.videoQuality = 'best',
    this.ytdlpChannel = 'stable',
    this.cookieBrowser = 'none',
    this.cookieFile,
  });

  final String? downloadDir;
  final DownloadFormat format;
  final String audioQuality;
  final String videoQuality;
  final String ytdlpChannel;
  final String cookieBrowser;
  final String? cookieFile;

  AppSettings copyWith({
    String? downloadDir,
    bool clearDownloadDir = false,
    DownloadFormat? format,
    String? audioQuality,
    String? ytdlpChannel,
    String? videoQuality,
    String? cookieBrowser,
    String? cookieFile,
    bool clearCookieFile = false,
  }) {
    return AppSettings(
      downloadDir: clearDownloadDir ? null : (downloadDir ?? this.downloadDir),
      format: format ?? this.format,
      audioQuality: audioQuality ?? this.audioQuality,
      videoQuality: videoQuality ?? this.videoQuality,
      ytdlpChannel: ytdlpChannel ?? this.ytdlpChannel,
      cookieBrowser: cookieBrowser ?? this.cookieBrowser,
      cookieFile: clearCookieFile ? null : (cookieFile ?? this.cookieFile),
    );
  }

  Map<String, dynamic> toJson() => {
    'download_dir': downloadDir,
    'format': format.value,
    'audio_quality': audioQuality,
    'video_quality': videoQuality,
    'ytdlp_channel': ytdlpChannel,
    'ytdlp_cookie_browser': cookieBrowser,
    'ytdlp_cookie_file': cookieFile,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    downloadDir: json['download_dir'] as String?,
    format: downloadFormatFromValue(json['format'] as String? ?? 'mp3'),
    audioQuality: _qualityOrDefault(
      json['audio_quality'],
      audioQualityOptions,
      '320K',
    ),
    videoQuality: _qualityOrDefault(
      json['video_quality'],
      videoQualityOptions,
      'best',
    ),
    ytdlpChannel: json['ytdlp_channel'] as String? ?? 'stable',
    cookieBrowser: json['ytdlp_cookie_browser'] as String? ?? 'none',
    cookieFile: json['ytdlp_cookie_file'] as String?,
  );

  String encode() => jsonEncode(toJson());
}

enum InitKind { starting, checking, ready, failed }

class InitEvent {
  const InitEvent({required this.kind, required this.message, this.percent});

  final InitKind kind;
  final String message;
  final double? percent;
}

class DownloadEvent {
  const DownloadEvent({
    required this.kind,
    required this.current,
    required this.total,
    required this.percent,
    required this.title,
    required this.message,
    this.source,
  });

  final String kind;
  final int current;
  final int total;
  final double percent;
  final String title;
  final String message;
  final String? source;
}

enum SiteStatus { stable, experimental, broken }

class SupportedSite {
  const SupportedSite(this.name, this.status);

  final String name;
  final SiteStatus status;
}

class SupportedSites {
  const SupportedSites({required this.extractors});

  final List<SupportedSite> extractors;
}
