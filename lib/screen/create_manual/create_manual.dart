import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

enum _PostMediaType { image, video }

class CreateManualScreen extends StatefulWidget {
  const CreateManualScreen({super.key});

  @override
  State<CreateManualScreen> createState() => _CreateManualScreenState();
}

class _CreateManualScreenState extends State<CreateManualScreen> {
  final TextEditingController _captionController = TextEditingController(
    text: 'New collection this Friday. Save this post and turn on reminders.',
  );
  final TextEditingController _hashtagController = TextEditingController();
  final Set<String> _selectedPlatforms = {'Instagram'};
  final List<String> _hashtags = ['#postflow', '#launch'];

  bool _isSideNavOpen = false;
  DateTime? _scheduledAt;
  PlatformFile? _selectedResource;
  _PostMediaType _selectedType = _PostMediaType.image;

  @override
  void dispose() {
    _captionController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  void _togglePlatform(String platform) {
    setState(() {
      if (_selectedPlatforms.contains(platform)) {
        if (_selectedPlatforms.length == 1) return;
        _selectedPlatforms.remove(platform);
      } else {
        _selectedPlatforms.add(platform);
      }
    });
  }

  void _selectType(_PostMediaType type) {
    setState(() {
      _selectedType = type;
      _selectedResource = null;
    });
  }

  Future<void> _pickResource() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _selectedType == _PostMediaType.image
          ? ['jpg', 'jpeg', 'png', 'webp']
          : ['mp4', 'mov', 'm4v', 'webm'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return;

    setState(() => _selectedResource = file);
  }

  void _addHashtag() {
    final rawValue = _hashtagController.text.trim();
    if (rawValue.isEmpty) return;

    final tag = rawValue.startsWith('#') ? rawValue : '#$rawValue';
    if (_hashtags.contains(tag)) {
      _hashtagController.clear();
      return;
    }

    setState(() {
      _hashtags.add(tag);
      _hashtagController.clear();
    });
  }

  void _removeHashtag(String tag) {
    setState(() => _hashtags.remove(tag));
  }

  void _continueToSchedule() {
    FocusScope.of(context).unfocus();
    _openScheduleSheet();
  }

  void _finishSchedule() {
    if (_scheduledAt == null) {
      _openScheduleSheet();
      return;
    }

    Navigator.of(context).pushReplacementNamed('/Scheduled');
  }

  void _openScheduleSheet() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = _scheduledAt == null
        ? today
        : DateTime(_scheduledAt!.year, _scheduledAt!.month, _scheduledAt!.day);
    final initialTime = _scheduledAt == null
        ? const TimeOfDay(hour: 18, minute: 0)
        : TimeOfDay(hour: _scheduledAt!.hour, minute: _scheduledAt!.minute);

    var selectedDate = initialDate;
    var selectedTime = initialTime;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Schedule post',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kTextBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pick the day and time after your content is ready.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kTextGrey,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: kPillBg,
                        border: Border.all(color: kBorderLight),
                        borderRadius: BorderRadius.circular(homeRadiusLg),
                      ),
                      child: CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 365)),
                        onDateChanged: (date) {
                          setSheetState(() => selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ScheduleTimeButton(
                      label: _formatTime(selectedTime),
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(
                                  context,
                                ).colorScheme.copyWith(primary: kBlue),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime == null) return;
                        setSheetState(() => selectedTime = pickedTime);
                      },
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _scheduledAt = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                        Navigator.of(context).pop();
                      },
                      style: _primaryButtonStyle(),
                      child: const Text('Confirm schedule'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _scheduleLabel() {
    final scheduledAt = _scheduledAt;
    if (scheduledAt == null) return 'Next step: choose date and time';

    final date = _formatDate(scheduledAt);
    final time = _formatTime(
      TimeOfDay(hour: scheduledAt.hour, minute: scheduledAt.minute),
    );
    return '$date at $time';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    if (selected == today) return 'Today';
    if (selected == today.add(const Duration(days: 1))) return 'Tomorrow';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SideNavOverlay(
        isOpen: _isSideNavOpen,
        activeIndex: 4,
        onClose: _closeSideNav,
        onItemSelected: (_) => _closeSideNav(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.orientationOf(context) == Orientation.landscape;
              final isWide = constraints.maxWidth >= 700 || isLandscape;

              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PostContentTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ComposeHeader(
                            scheduleLabel: _scheduleLabel(),
                            isScheduled: _scheduledAt != null,
                          ),
                          const SizedBox(height: 14),
                          _InstagramComposeCard(
                            selectedType: _selectedType,
                            selectedResource: _selectedResource,
                            captionController: _captionController,
                            hashtagController: _hashtagController,
                            hashtags: _hashtags,
                            selectedPlatforms: _selectedPlatforms,
                            onTypeSelected: _selectType,
                            onPickResource: _pickResource,
                            onCaptionChanged: () => setState(() {}),
                            onAddHashtag: _addHashtag,
                            onRemoveHashtag: _removeHashtag,
                            onPlatformToggled: _togglePlatform,
                          ),
                          const SizedBox(height: 14),
                          _PostPreviewCard(
                            resource: _selectedResource,
                            caption: _captionController.text,
                            hashtags: _hashtags,
                            isVideo: _selectedType == _PostMediaType.video,
                            platforms: _selectedPlatforms.toList(),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _continueToSchedule,
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _scheduledAt == null
                                  ? 'Continue to schedule'
                                  : 'Update schedule',
                            ),
                            style: _primaryButtonStyle(),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _finishSchedule,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(48, 52),
                              foregroundColor: kBlue,
                              side: const BorderSide(color: kBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  homeRadiusMd,
                                ),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            child: Text(
                              _scheduledAt == null
                                  ? 'Schedule later'
                                  : 'Add to queue',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              if (isWide) return content;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: homePageMaxWidth),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    minimumSize: const Size(48, 52),
    backgroundColor: kBlue,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(homeRadiusMd),
    ),
    textStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      fontFamily: 'Poppins',
    ),
  );
}

class _PostContentTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _PostContentTopBar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            tooltip: 'Go back',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: kTextMuted,
              backgroundColor: kPillBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post content',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kTextBlack,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Media, caption, hashtags',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextGrey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onMenuTap,
            icon: Image.asset(
              '$homeIconPath/heroicons-solid_menu-alt-3.png',
              width: 19,
              height: 19,
              fit: BoxFit.contain,
            ),
            tooltip: 'Open navigation menu',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: kPillBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposeHeader extends StatelessWidget {
  final String scheduleLabel;
  final bool isScheduled;

  const _ComposeHeader({
    required this.scheduleLabel,
    required this.isScheduled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlueBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(homeRadiusMd),
            ),
            child: Icon(
              isScheduled
                  ? Icons.event_available_rounded
                  : Icons.edit_note_rounded,
              color: kBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create it like an Instagram post',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  scheduleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstagramComposeCard extends StatelessWidget {
  final _PostMediaType selectedType;
  final PlatformFile? selectedResource;
  final TextEditingController captionController;
  final TextEditingController hashtagController;
  final List<String> hashtags;
  final Set<String> selectedPlatforms;
  final ValueChanged<_PostMediaType> onTypeSelected;
  final VoidCallback onPickResource;
  final VoidCallback onCaptionChanged;
  final VoidCallback onAddHashtag;
  final ValueChanged<String> onRemoveHashtag;
  final ValueChanged<String> onPlatformToggled;

  const _InstagramComposeCard({
    required this.selectedType,
    required this.selectedResource,
    required this.captionController,
    required this.hashtagController,
    required this.hashtags,
    required this.selectedPlatforms,
    required this.onTypeSelected,
    required this.onPickResource,
    required this.onCaptionChanged,
    required this.onAddHashtag,
    required this.onRemoveHashtag,
    required this.onPlatformToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusXl),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _MediaTypeButton(
                  label: 'Image',
                  icon: Icons.image_rounded,
                  isActive: selectedType == _PostMediaType.image,
                  onPressed: () => onTypeSelected(_PostMediaType.image),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MediaTypeButton(
                  label: 'Video',
                  icon: Icons.play_circle_fill_rounded,
                  isActive: selectedType == _PostMediaType.video,
                  onPressed: () => onTypeSelected(_PostMediaType.video),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MediaPickerPreview(
            selectedType: selectedType,
            selectedResource: selectedResource,
            onPressed: onPickResource,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: captionController,
            onChanged: (_) => onCaptionChanged(),
            minLines: 4,
            maxLines: 7,
            textInputAction: TextInputAction.newline,
            decoration: _inputDecoration(
              label: 'Caption',
              hint: 'Write the caption for this post',
              icon: Icons.short_text_rounded,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: hashtagController,
                  onSubmitted: (_) => onAddHashtag(),
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration(
                    label: 'Hashtags',
                    hint: '#summerdrop',
                    icon: Icons.tag_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: onAddHashtag,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add hashtag',
                style: IconButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  backgroundColor: kBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(homeRadiusMd),
                  ),
                ),
              ),
            ],
          ),
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hashtags
                  .map(
                    (tag) => InputChip(
                      label: Text(tag),
                      onDeleted: () => onRemoveHashtag(tag),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16),
                      backgroundColor: kBlueBg,
                      side: BorderSide.none,
                      labelStyle: const TextStyle(
                        color: kBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            'Post to',
            style: TextStyle(
              color: kTextBlack,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Instagram', 'TikTok', 'YouTube', 'LinkedIn']
                .map(
                  (platform) => _PlatformChip(
                    label: platform,
                    isActive: selectedPlatforms.contains(platform),
                    onPressed: () => onPlatformToggled(platform),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: kBlue),
      filled: true,
      fillColor: kPillBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(homeRadiusMd),
        borderSide: const BorderSide(color: kBorderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(homeRadiusMd),
        borderSide: const BorderSide(color: kBorderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(homeRadiusMd),
        borderSide: const BorderSide(color: kBlue),
      ),
    );
  }
}

class _MediaTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _MediaTypeButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: isActive ? kBlue : kPillBg,
        foregroundColor: isActive ? Colors.white : kTextMuted,
        side: BorderSide(color: isActive ? kBlue : kBorderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(homeRadiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _MediaPickerPreview extends StatelessWidget {
  final _PostMediaType selectedType;
  final PlatformFile? selectedResource;
  final VoidCallback onPressed;

  const _MediaPickerPreview({
    required this.selectedType,
    required this.selectedResource,
    required this.onPressed,
  });

  bool get _hasImagePreview {
    final extension = selectedResource?.extension?.toLowerCase();
    return selectedResource?.bytes != null &&
        (extension == 'jpg' ||
            extension == 'jpeg' ||
            extension == 'png' ||
            extension == 'webp');
  }

  @override
  Widget build(BuildContext context) {
    final file = selectedResource;
    final isVideo = selectedType == _PostMediaType.video;

    return Material(
      color: kPillBg,
      borderRadius: BorderRadius.circular(homeRadiusLg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 230),
          decoration: BoxDecoration(
            border: Border.all(color: kBorderLight),
            borderRadius: BorderRadius.circular(homeRadiusLg),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(homeRadiusLg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_hasImagePreview)
                    Image.memory(file!.bytes!, fit: BoxFit.cover)
                  else
                    Container(
                      padding: const EdgeInsets.all(18),
                      color: kPillBg,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: homeSoftShadow,
                            ),
                            child: Icon(
                              isVideo
                                  ? Icons.play_circle_fill_rounded
                                  : Icons.add_photo_alternate_rounded,
                              color: kBlue,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            file == null
                                ? 'Add ${isVideo ? 'video' : 'image'}'
                                : file.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kTextBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            file == null
                                ? (isVideo
                                      ? 'MP4, MOV, M4V, WEBM'
                                      : 'JPG, PNG, WEBP')
                                : '${(file.extension ?? 'file').toUpperCase()} - ${_formatBytes(file.size)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kTextGrey,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isVideo)
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: kBlue,
                          size: 36,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: kBlue,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        file == null ? 'Upload' : 'Change',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostPreviewCard extends StatelessWidget {
  final PlatformFile? resource;
  final String caption;
  final List<String> hashtags;
  final bool isVideo;
  final List<String> platforms;

  const _PostPreviewCard({
    required this.resource,
    required this.caption,
    required this.hashtags,
    required this.isVideo,
    required this.platforms,
  });

  bool get _hasImageResource {
    final extension = resource?.extension?.toLowerCase();
    return resource?.bytes != null &&
        (extension == 'jpg' ||
            extension == 'jpeg' ||
            extension == 'png' ||
            extension == 'webp');
  }

  @override
  Widget build(BuildContext context) {
    final file = resource;
    final previewCaption = [
      if (caption.trim().isNotEmpty) caption.trim(),
      if (hashtags.isNotEmpty) hashtags.join(' '),
    ].join('\n\n');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusXl),
        boxShadow: homeCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBlueBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: const Icon(Icons.person_rounded, color: kBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bernard Obeng Akoto',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kTextBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Post preview',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kTextGrey,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                color: kTextMuted,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(homeRadiusLg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_hasImageResource)
                    Image.memory(resource!.bytes!, fit: BoxFit.cover)
                  else
                    Container(
                      color: kPillBg,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isVideo
                                ? Icons.play_circle_fill_rounded
                                : Icons.add_photo_alternate_rounded,
                            color: kBlue,
                            size: 42,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            file == null ? 'Resource preview' : file.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kTextBlack,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isVideo)
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: kBlue,
                          size: 36,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              platforms.join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            previewCaption.isEmpty
                ? 'Caption and hashtags appear here.'
                : previewCaption,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 12,
              height: 1.45,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _PlatformChip({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isActive,
      showCheckmark: false,
      label: Text(label),
      avatar: Icon(
        isActive ? Icons.check_circle_rounded : Icons.circle_outlined,
        size: 18,
        color: isActive ? kBlue : kTextGrey,
      ),
      onSelected: (_) => onPressed(),
      backgroundColor: kPillBg,
      selectedColor: kBlueBg,
      side: BorderSide(color: isActive ? kBlue : kBorderLight),
      labelStyle: TextStyle(
        color: isActive ? kBlue : kTextMuted,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        fontFamily: 'Poppins',
      ),
    );
  }
}

class _ScheduleTimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ScheduleTimeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kPillBg,
      borderRadius: BorderRadius.circular(homeRadiusLg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: kBorderLight),
            borderRadius: BorderRadius.circular(homeRadiusLg),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBlueBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: kBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: kTextBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const Text(
                'Change',
                style: TextStyle(
                  color: kBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '$bytes B';
}
