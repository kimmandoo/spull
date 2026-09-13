import 'package:flutter/material.dart';

import 'models/media_models.dart';
import 'state/app_controller.dart';
import 'widgets/pixel_widgets.dart';

class SpullApp extends StatefulWidget {
  const SpullApp({super.key, this.controller});

  final SpullController? controller;

  @override
  State<SpullApp> createState() => _SpullAppState();
}

class _SpullAppState extends State<SpullApp> {
  late final SpullController controller =
      widget.controller ?? SpullController();

  @override
  void initState() {
    super.initState();
    controller.boot();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spull',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: PixelColors.background,
        colorScheme: const ColorScheme.light(
          primary: PixelColors.orange,
          secondary: PixelColors.mint,
          surface: PixelColors.panel,
          onSurface: PixelColors.text,
          error: PixelColors.pink,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: PixelColors.panelLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PixelColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PixelColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PixelColors.orange, width: 1.5),
          ),
          hintStyle: const TextStyle(color: PixelColors.muted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? PixelColors.orange
                : PixelColors.panel,
          ),
          checkColor: WidgetStateProperty.all(PixelColors.ink),
          side: const BorderSide(color: PixelColors.outline, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: PixelColors.muted,
          collapsedIconColor: PixelColors.muted,
          textColor: PixelColors.text,
          collapsedTextColor: PixelColors.text,
        ),
      ),
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _SpullDashboard(controller: controller),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }
}

class _SpullDashboard extends StatefulWidget {
  const _SpullDashboard({required this.controller});

  final SpullController controller;

  @override
  State<_SpullDashboard> createState() => _SpullDashboardState();
}

class _SpullDashboardState extends State<_SpullDashboard> {
  final Map<String, TextEditingController> _urlControllers =
      <String, TextEditingController>{};
  final TextEditingController _supportSearchController =
      TextEditingController();

  SpullController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    _syncUrlControllers();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 980;
            final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 28.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                36,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildHeader(),
                      const SizedBox(height: 28),
                      if (controller.errorMessage.isNotEmpty) ...<Widget>[
                        _buildErrorBanner(),
                        const SizedBox(height: 18),
                      ],
                      if (compact)
                        _buildCompactContent()
                      else
                        _buildWideContent(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWideContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _buildMainColumn()),
        const SizedBox(width: 22),
        SizedBox(width: 326, child: _buildSettingsColumn()),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildMainColumn(),
        const SizedBox(height: 20),
        _buildSettingsColumn(),
      ],
    );
  }

  Widget _buildMainColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildUrlPanel(),
        const SizedBox(height: 18),
        _buildQueuePanel(),
        const SizedBox(height: 18),
        _buildProgressPanel(),
      ],
    );
  }

  Widget _buildSettingsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('저장 설정'),
        const SizedBox(height: 9),
        _buildFolderPanel(),
        const SizedBox(height: 14),
        _buildOutputPanel(),
        const SizedBox(height: 14),
        _buildAdvancedPanel(),
        const SizedBox(height: 14),
        _buildSupportButton(),
        if (controller.supportPanelOpen) ...<Widget>[
          const SizedBox(height: 12),
          _buildSupportPanel(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const PixelLogo(size: 48),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Spull',
                style: TextStyle(
                  color: PixelColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '링크를 넣고, 필요한 파일만 저장하세요.',
                style: TextStyle(color: PixelColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        _buildStatusPill(),
      ],
    );
  }

  Widget _buildStatusPill() {
    final active = controller.phase == AppPhase.downloading;
    final color = controller.phase == AppPhase.booting
        ? PixelColors.yellow
        : active
        ? PixelColors.orange
        : PixelColors.mint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            _phaseShortLabel(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlPanel() {
    final canEdit = controller.isReadyForInput && !controller.isBusy;
    final isAnalyzing = controller.phase == AppPhase.analyzing;
    final hasUrl = controller.urlRows.any((row) => row.value.trim().isNotEmpty);
    return PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _PanelTitle(
            kicker: 'STEP 1',
            title: '링크 추가',
            subtitle: '영상 또는 재생목록 링크를 붙여넣으세요.',
          ),
          const SizedBox(height: 18),
          ...controller.urlRows.asMap().entries.map(
            (entry) => _buildUrlRow(entry.key, entry.value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              PixelButton(
                label: '다른 링크 추가',
                icon: Icons.add,
                onPressed: canEdit ? controller.addUrlRow : null,
              ),
              PixelButton(
                label: isAnalyzing ? '분석 취소' : '링크 분석',
                icon: isAnalyzing ? Icons.close : Icons.arrow_forward_rounded,
                tone: isAnalyzing
                    ? PixelButtonTone.danger
                    : PixelButtonTone.primary,
                onPressed: isAnalyzing
                    ? controller.cancelAnalyze
                    : canEdit
                    ? controller.analyze
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                hasUrl ? Icons.info_outline : Icons.lightbulb_outline,
                size: 15,
                color: PixelColors.muted,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  hasUrl
                      ? '재생목록은 분석 후 원하는 항목만 선택할 수 있어요.'
                      : '여러 링크를 한 번에 추가할 수도 있어요.',
                  style: const TextStyle(
                    color: PixelColors.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrlRow(int index, UrlRow row) {
    final textController = _urlControllers[row.id]!;
    final canEdit = controller.isReadyForInput && !controller.isBusy;
    return Padding(
      padding: EdgeInsets.only(
        bottom: index == controller.urlRows.length - 1 ? 0 : 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 34,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: PixelColors.cream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: const TextStyle(
                color: PixelColors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: textController,
              enabled: canEdit,
              onChanged: (value) => controller.updateUrl(row.id, value),
              onSubmitted: (_) => controller.analyze(),
              style: const TextStyle(color: PixelColors.text, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'https://www.youtube.com/watch?v=...',
                prefixIcon: Icon(
                  Icons.link_rounded,
                  color: PixelColors.muted,
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: '링크 삭제',
            onPressed: controller.urlRows.length == 1 || !canEdit
                ? null
                : () => _removeUrlController(row.id),
            icon: const Icon(Icons.close_rounded, size: 19),
            color: PixelColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePanel() {
    final playlist = controller.playlist;
    final canSelect = controller.isReadyForInput && !controller.isBusy;
    if (playlist == null) {
      return PixelPanel(
        color: PixelColors.panelLight,
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: PixelColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.playlist_play_rounded,
                color: PixelColors.orange,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '다운로드 목록',
                    style: TextStyle(
                      color: PixelColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '링크를 분석하면 파일 목록이 여기에 나타나요.',
                    style: TextStyle(color: PixelColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _PanelTitle(
                  kicker: playlist.isPlaylist ? 'STEP 2 · 재생목록' : 'STEP 2',
                  title: playlist.title,
                  subtitle: '저장할 항목을 선택하세요.',
                ),
              ),
              const SizedBox(width: 12),
              PixelTag(
                label: '${controller.selectedCount}/${controller.totalCount}',
                color: PixelColors.mint,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: <Widget>[
              TextButton(
                onPressed: canSelect ? () => controller.toggleAll(true) : null,
                child: const Text('모두 선택'),
              ),
              TextButton(
                onPressed: canSelect ? () => controller.toggleAll(false) : null,
                child: const Text('모두 해제'),
              ),
            ],
          ),
          if (controller.selectedCount == 0)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                '다운로드할 항목을 하나 이상 선택하세요.',
                style: TextStyle(
                  color: PixelColors.yellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 5),
          ...playlist.entries.asMap().entries.map(
            (entry) => _buildVideoRow(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoRow(int index, VideoEntry entry) {
    final canSelect = controller.isReadyForInput && !controller.isBusy;
    final borderColor = entry.selected
        ? PixelColors.orange.withValues(alpha: 0.45)
        : PixelColors.outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PixelColors.panelLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: canSelect
              ? () => controller.toggleEntry(entry.id, !entry.selected)
              : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: entry.selected,
                  onChanged: canSelect
                      ? (value) =>
                            controller.toggleEntry(entry.id, value ?? false)
                      : null,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    width: 76,
                    height: 50,
                    color: PixelColors.outline,
                    alignment: Alignment.center,
                    child: entry.thumbnail == null
                        ? Text(
                            '${index + 1}'.padLeft(2, '0'),
                            style: const TextStyle(
                              color: PixelColors.muted,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : Image.network(
                            entry.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Text(
                              '${index + 1}'.padLeft(2, '0'),
                              style: const TextStyle(color: PixelColors.muted),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: PixelColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 5,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.schedule_rounded,
                                color: PixelColors.muted,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                entry.displayDuration,
                                style: const TextStyle(
                                  color: PixelColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          if (entry.source != null)
                            PixelTag(
                              label: entry.source!,
                              color: PixelColors.sky,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressPanel() {
    final isDownloading = controller.phase == AppPhase.downloading;
    final isFinished = controller.phase == AppPhase.finished;
    final heading = isDownloading
        ? '다운로드 중'
        : isFinished
        ? '다운로드 완료'
        : '다운로드 준비';
    final hasSelection = controller.hasDownloadableSelection;
    return PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _PanelTitle(
                  kicker: 'STEP 3',
                  title: heading,
                  subtitle: isDownloading
                      ? controller.downloadTitle
                      : controller.downloadMessage,
                ),
              ),
              PixelTag(
                label: '${controller.downloadPercent.round()}%',
                color: isDownloading ? PixelColors.orange : PixelColors.mint,
              ),
            ],
          ),
          const SizedBox(height: 18),
          PixelProgressBar(value: controller.downloadPercent / 100),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text(
                isDownloading
                    ? '${controller.downloadCurrent}/${controller.downloadTotal}'
                    : isFinished
                    ? '완료'
                    : '대기 중',
                style: const TextStyle(
                  color: PixelColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.downloadMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PixelColors.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              Text(
                '경과 ${controller.elapsedLabel}',
                style: const TextStyle(color: PixelColors.muted, fontSize: 11),
              ),
              const Spacer(),
              Text(
                '예상 ${controller.etaLabel}',
                style: const TextStyle(color: PixelColors.muted, fontSize: 11),
              ),
            ],
          ),
          if (controller.logs.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              height: 70,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PixelColors.panelLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                reverse: true,
                itemCount: controller.logs.length,
                itemBuilder: (_, index) {
                  final log =
                      controller.logs[controller.logs.length - index - 1];
                  return Text(
                    log,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PixelColors.muted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: isDownloading
                ? PixelButton(
                    label: '다운로드 취소',
                    icon: Icons.stop_rounded,
                    tone: PixelButtonTone.danger,
                    onPressed: controller.stopDownload,
                  )
                : PixelButton(
                    label: hasSelection
                        ? '${controller.selectedCount}개 다운로드'
                        : '먼저 링크를 분석하세요',
                    icon: Icons.download_rounded,
                    tone: PixelButtonTone.primary,
                    onPressed: controller.readyToDownload && hasSelection
                        ? controller.startDownload
                        : null,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderPanel() {
    final path = controller.settings.downloadDir;
    final configured = path?.isNotEmpty == true;
    final canEdit = controller.isReadyForInput && !controller.isBusy;
    return PixelPanel(
      padding: const EdgeInsets.all(16),
      color: PixelColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _CardHeading(
            icon: Icons.folder_rounded,
            title: '저장 위치',
            subtitle: '다운로드 파일이 저장될 폴더',
            color: PixelColors.sky,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: PixelColors.panelLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.folder_open_rounded,
                  color: PixelColors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    configured ? path! : '기본 Downloads 폴더를 준비 중입니다.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PixelColors.text,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: PixelButton(
                  label: '변경',
                  icon: Icons.drive_file_move_outline,
                  onPressed: canEdit ? controller.chooseFolder : null,
                  expand: true,
                ),
              ),
              if (configured) ...<Widget>[
                const SizedBox(width: 8),
                PixelButton(
                  label: '열기',
                  icon: Icons.open_in_new_rounded,
                  onPressed: controller.openFolder,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputPanel() {
    final canEdit = controller.isReadyForInput && !controller.isBusy;
    final format = controller.settings.format;
    final supportsAudioBitrate =
        format == DownloadFormat.mp3 || format == DownloadFormat.m4a;
    return PixelPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _CardHeading(
            icon: Icons.tune_rounded,
            title: '출력 형식',
            subtitle: '원하는 파일 형식과 품질',
            color: PixelColors.mint,
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: DownloadFormat.values.map((item) {
              final selected = format == item;
              return InkWell(
                onTap: canEdit ? () => controller.setFormat(item) : null,
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? PixelColors.orange
                        : PixelColors.panelLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? PixelColors.orange
                          : PixelColors.outline,
                    ),
                  ),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? PixelColors.ink : PixelColors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 13),
          if (format.isAudio) ...<Widget>[
            if (supportsAudioBitrate)
              _buildSelectField(
                label: '오디오 품질',
                value: controller.settings.audioQuality,
                items: audioQualityOptions,
                onChanged: canEdit
                    ? (value) {
                        if (value != null) controller.setAudioQuality(value);
                      }
                    : null,
              )
            else
              const Text(
                'WAV / FLAC은 무손실 포맷이라 음질 선택이 필요하지 않습니다.',
                style: TextStyle(
                  color: PixelColors.muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
          ],
          if (format.isVideo)
            _buildSelectField(
              label: '비디오 해상도',
              value: controller.settings.videoQuality,
              items: videoQualityOptions,
              onChanged: canEdit
                  ? (value) {
                      if (value != null) controller.setVideoQuality(value);
                    }
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedPanel() {
    final canEdit = controller.isReadyForInput && !controller.isBusy;
    return PixelPanel(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: const Text(
              '고급 설정',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${controller.settings.ytdlpChannel.toUpperCase()} · ${controller.settings.cookieBrowser == 'none' ? '쿠키 없음' : controller.settings.cookieBrowser.toUpperCase()}',
              style: const TextStyle(color: PixelColors.muted, fontSize: 11),
            ),
            children: <Widget>[
              _buildSelectField(
                label: 'yt-dlp 채널',
                value: controller.settings.ytdlpChannel,
                items: const <String>['stable', 'nightly', 'master'],
                onChanged: canEdit
                    ? (value) {
                        if (value != null) controller.setChannel(value);
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              _buildSelectField(
                label: '브라우저 쿠키',
                value: controller.settings.cookieBrowser,
                items: const <String>[
                  'none',
                  'chrome',
                  'edge',
                  'firefox',
                  'brave',
                  'chromium',
                  'opera',
                  'vivaldi',
                  'safari',
                  'whale',
                ],
                onChanged: canEdit
                    ? (value) {
                        if (value != null) controller.setCookieBrowser(value);
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              _buildCookieFileCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: PixelColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: PixelColors.panelLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PixelColors.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              dropdownColor: PixelColors.panel,
              borderRadius: BorderRadius.circular(10),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: PixelColors.muted,
              ),
              style: const TextStyle(
                color: PixelColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCookieFileCard() {
    final cookieFile = controller.settings.cookieFile;
    final canEdit = controller.isReadyForInput && !controller.isBusy;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PixelColors.panelLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'cookies.txt 파일',
            style: TextStyle(
              color: PixelColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cookieFile ?? '선택하지 않음',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: PixelColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Expanded(
                child: PixelButton(
                  label: '파일 선택',
                  icon: Icons.attach_file_rounded,
                  onPressed: canEdit ? controller.chooseCookieFile : null,
                  expand: true,
                ),
              ),
              const SizedBox(width: 7),
              PixelButton(
                label: '삭제',
                onPressed: canEdit && cookieFile != null
                    ? controller.clearCookieFile
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportButton() {
    return PixelButton(
      label: controller.supportPanelOpen ? '지원 사이트 닫기' : '지원 사이트 보기',
      icon: controller.supportPanelOpen
          ? Icons.expand_less_rounded
          : Icons.public_rounded,
      onPressed: controller.toggleSupportPanel,
      expand: true,
    );
  }

  Widget _buildSupportPanel() {
    if (controller.supportLoading) {
      return PixelPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              '지원 사이트 목록을 불러오는 중...',
              style: TextStyle(color: PixelColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            PixelButton(
              label: '불러오기 취소',
              icon: Icons.stop_rounded,
              tone: PixelButtonTone.danger,
              onPressed: controller.cancelSupportedSites,
              expand: true,
            ),
          ],
        ),
      );
    }
    if (controller.supportError.isNotEmpty) {
      return PixelPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              controller.supportError,
              style: const TextStyle(
                color: PixelColors.text,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            PixelButton(
              label: '다시 시도',
              icon: Icons.refresh_rounded,
              onPressed: controller.retrySupportedSites,
              expand: true,
            ),
          ],
        ),
      );
    }
    final sites = controller.sites;
    if (sites == null) return const SizedBox.shrink();
    final visible = controller.filteredExtractors;
    return PixelPanel(
      padding: const EdgeInsets.all(14),
      color: PixelColors.panelLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '지원 사이트',
                  style: TextStyle(
                    color: PixelColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PixelTag(
                label: '${visible.length}/${sites.extractors.length}',
                color: PixelColors.sky,
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _supportSearchController,
            onChanged: controller.updateSupportQuery,
            style: const TextStyle(fontSize: 12, color: PixelColors.text),
            decoration: const InputDecoration(
              hintText: '사이트 검색',
              prefixIcon: Icon(Icons.search_rounded, size: 18),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 280,
            child: visible.isEmpty
                ? const Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(color: PixelColors.muted, fontSize: 11),
                    ),
                  )
                : Scrollbar(
                    child: ListView.separated(
                      itemCount: visible.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 5),
                      itemBuilder: (_, index) {
                        final site = visible[index];
                        final broken = site.status == SiteStatus.broken;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: PixelColors.panel,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  site.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: PixelColors.text,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PixelTag(
                                label: broken ? '사용 불가' : '지원',
                                color: _siteColor(site.status),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: PixelColors.pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PixelColors.pink.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: PixelColors.pink,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              controller.errorMessage,
              style: const TextStyle(
                color: PixelColors.text,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
          IconButton(
            tooltip: '오류 닫기',
            onPressed: controller.clearError,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: PixelColors.muted,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  void _syncUrlControllers() {
    final ids = controller.urlRows.map((row) => row.id).toSet();
    for (final id in _urlControllers.keys.toList()) {
      if (!ids.contains(id)) _urlControllers.remove(id)?.dispose();
    }
    for (final row in controller.urlRows) {
      _urlControllers.putIfAbsent(
        row.id,
        () => TextEditingController(text: row.value),
      );
    }
  }

  void _removeUrlController(String id) {
    _urlControllers.remove(id)?.dispose();
    controller.removeUrlRow(id);
  }

  String _phaseShortLabel() {
    return switch (controller.phase) {
      AppPhase.booting => '준비 중',
      AppPhase.idle => '대기 중',
      AppPhase.analyzing => '분석 중',
      AppPhase.ready => '선택 가능',
      AppPhase.downloading => '다운로드 중',
      AppPhase.finished => '완료',
    };
  }

  Color _siteColor(SiteStatus status) {
    return switch (status) {
      SiteStatus.stable => PixelColors.mint,
      SiteStatus.experimental => PixelColors.yellow,
      SiteStatus.broken => PixelColors.pink,
    };
  }

  @override
  void dispose() {
    for (final controller in _urlControllers.values) {
      controller.dispose();
    }
    _supportSearchController.dispose();
    super.dispose();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: PixelColors.muted,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.kicker, required this.title, this.subtitle});

  final String kicker;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          kicker,
          style: const TextStyle(
            color: PixelColors.orange,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: PixelColors.text,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: PixelColors.muted, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: PixelColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: PixelColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
