import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

part 'widgets/create_manual_widgets.dart';

enum _PostMediaType { image, video }

class CreateManualScreen extends StatefulWidget {
  const CreateManualScreen({super.key});

  @override
  State<CreateManualScreen> createState() => _CreateManualScreenState();
}

class _CreateManualScreenState extends State<CreateManualScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  final Set<String> _selectedPlatforms = {};
  final List<String> _hashtags = [];

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

    Navigator.of(context).pushNamed('/Scheduled');
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
