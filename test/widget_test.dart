import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spull/home_page.dart';
import 'package:spull/models/media_models.dart';
import 'package:spull/services/spull_backend.dart';
import 'package:spull/state/app_controller.dart';
import 'package:spull/widgets/pixel_widgets.dart';

void main() {
  testWidgets('renders the Spull dashboard', (tester) async {
    final controller = SpullController();
    await tester.pumpWidget(SpullApp(controller: controller));

    expect(find.text('Spull'), findsOneWidget);
    expect(find.text('STEP 1'), findsOneWidget);
    expect(find.text('다른 링크 추가'), findsOneWidget);
    expect(find.text('링크 분석'), findsOneWidget);
    expect(find.text('저장 위치'), findsOneWidget);

    controller.dispose();
  });
  testWidgets('expands advanced settings inside its rounded card', (
    tester,
  ) async {
    final controller = SpullController();
    await tester.pumpWidget(SpullApp(controller: controller));

    await tester.ensureVisible(find.text('고급 설정'));
    await tester.tap(find.byType(ExpansionTile));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('yt-dlp 채널'), findsOneWidget);
    controller.dispose();
  });

  test('persists selected audio and video quality', () {
    const settings = AppSettings(
      format: DownloadFormat.mp4,
      audioQuality: '192K',
      videoQuality: '1080p',
    );

    final restored = AppSettings.fromJson(settings.toJson());

    expect(restored.audioQuality, '192K');
    expect(restored.videoQuality, '1080p');
  });

  test('uses safe quality defaults for unknown saved values', () {
    final settings = AppSettings.fromJson({
      'audio_quality': 'invalid',
      'video_quality': 'invalid',
    });

    expect(settings.audioQuality, '320K');
    expect(settings.videoQuality, 'best');
  });
  test('decodes malformed native output without throwing', () {
    final payload = jsonDecode(
      processOutputDecoder.convert(<int>[
        0x7b,
        0x22,
        0x74,
        0x69,
        0x74,
        0x6c,
        0x65,
        0x22,
        0x3a,
        0x22,
        0x53,
        0x70,
        0x75,
        0x6c,
        0x6c,
        0xff,
        0x22,
        0x7d,
      ]),
    ) as Map<String, dynamic>;

    expect(payload['title'], 'Spull\uFFFD');
  });
  test('restores playable URLs from flat playlist entries', () {
    final playlist = PlaylistInfo.fromJson({
      '_type': 'playlist',
      'title': 'My mix',
      'entries': [
        {
          '_type': 'url',
          'id': 'video-one',
          'url': 'video-one',
          'ie_key': 'Youtube',
          'title': 'First video',
        },
        {
          '_type': 'url',
          'id': 'video-two',
          'url': 'video-two',
          'original_url': 'https://www.youtube.com/watch?v=video-two',
          'title': 'Second video',
        },
      ],
    }, sourceUrl: 'https://www.youtube.com/playlist?list=example');

    expect(playlist.entries, hasLength(2));
    expect(
      playlist.entries.first.url,
      'https://www.youtube.com/watch?v=video-one',
    );
    expect(
      playlist.entries.last.url,
      'https://www.youtube.com/watch?v=video-two',
    );
  });

  test('returns to idle when analysis has no playable entries', () async {
    final controller = SpullController(backend: _EmptyBackend());
    controller.urlRows.first.value =
        'https://www.youtube.com/playlist?list=empty';

    await controller.analyze();

    expect(controller.phase, AppPhase.idle);
    expect(controller.errorMessage, '다운로드 가능한 항목을 찾지 못했습니다. 링크를 확인해 주세요.');
    controller.dispose();
  });

  test('cancelling analysis returns the controller to idle', () async {
    final backend = _BlockingBackend();
    final controller = SpullController(backend: backend);
    controller.urlRows.first.value = 'https://example.com/video';

    final analysis = controller.analyze();
    expect(controller.phase, AppPhase.analyzing);
    await controller.cancelAnalyze();
    await analysis;

    expect(backend.analysisCancelled, isTrue);
    expect(controller.phase, AppPhase.idle);
    expect(controller.logs.last, '분석을 취소했습니다.');
    controller.dispose();
  });

  test('cancelling extractor loading clears its loading state', () async {
    final backend = _BlockingBackend();
    final controller = SpullController(backend: backend);

    final loading = controller.toggleSupportPanel();
    await Future<void>.delayed(Duration.zero);
    expect(controller.supportLoading, isTrue);

    await controller.cancelSupportedSites();
    await loading;

    expect(backend.supportSitesCancelled, isTrue);
    expect(controller.supportLoading, isFalse);
    expect(controller.supportError, 'extractor 목록 로딩을 취소했습니다.');
    controller.dispose();
  });

  testWidgets('renders an indeterminate pixel progress bar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PixelProgressBar(value: null))),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}

class _EmptyBackend extends SpullBackend {
  @override
  Future<PlaylistInfo> analyzeUrl({
    required String url,
    required AppSettings settings,
  }) async {
    return PlaylistInfo(
      title: 'Empty',
      entries: <VideoEntry>[],
      isPlaylist: true,
    );
  }
}

class _BlockingBackend extends SpullBackend {
  final Completer<PlaylistInfo> _analysis = Completer<PlaylistInfo>();
  final Completer<SupportedSites> _supportedSites = Completer<SupportedSites>();
  bool analysisCancelled = false;
  bool supportSitesCancelled = false;
  bool analysisStarted = false;
  bool supportSitesStarted = false;

  @override
  Future<PlaylistInfo> analyzeUrl({
    required String url,
    required AppSettings settings,
  }) {
    analysisStarted = true;
    return _analysis.future;
  }

  @override
  Future<void> cancelAnalysis() async {
    analysisCancelled = true;
    if (analysisStarted && !_analysis.isCompleted) {
      _analysis.completeError(const SpullOperationCancelled('링크 분석'));
    }
  }

  @override
  Future<SupportedSites> supportedSites() {
    supportSitesStarted = true;
    return _supportedSites.future;
  }

  @override
  Future<void> cancelSupportedSites() async {
    supportSitesCancelled = true;
    if (supportSitesStarted && !_supportedSites.isCompleted) {
      _supportedSites.completeError(
        const SpullOperationCancelled('extractor 목록 조회'),
      );
    }
  }
}
