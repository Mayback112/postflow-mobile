import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

part 'widgets/create_ai_content.dart';

enum _AiContentType { caption, imageCaption, videoCaption, motionGraphics }

class CreateWithAiScreen extends StatefulWidget {
  const CreateWithAiScreen({super.key});

  @override
  State<CreateWithAiScreen> createState() => _CreateWithAiScreenState();
}

class _CreateWithAiScreenState extends State<CreateWithAiScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _isSideNavOpen = false;
  bool _isThinking = false;
  bool _isFinishing = false;
  bool _showPreview = false;
  DateTime? _scheduledAt;
  _AiContentType? _selectedType;

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  void _selectType(_AiContentType type) {
    if (_selectedType == type) return;

    setState(() {
      _selectedType = type;
      _isThinking = false;
      _isFinishing = false;
      _showPreview = false;
      _scheduledAt = null;
      _messages
        ..clear()
        ..add(
          _ChatMessage(
            text:
                'I want to create a ${_contentTypeLabel(type).toLowerCase()}.',
            isUser: true,
          ),
        )
        ..add(_ChatMessage(text: _starterReply(type), isUser: false));
    });
    _scrollToBottom();
  }

  void _sendPrompt() {
    final prompt = _promptController.text.trim();
    final selectedType = _selectedType;
    if (prompt.isEmpty || _isThinking || _isFinishing || selectedType == null) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: prompt, isUser: true));
      _promptController.clear();
      _isThinking = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      setState(() {
        _isThinking = false;
        _messages.add(
          _ChatMessage(
            text: _generatedReply(selectedType, prompt),
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _finishCreation() {
    final selectedType = _selectedType;
    if (selectedType == null || _isThinking || _isFinishing || !_canFinish) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isFinishing = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isFinishing = false;
        _showPreview = true;
      });
    });
  }

  void _backToChat() {
    setState(() => _showPreview = false);
    _scrollToBottom();
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
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Schedule post',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kTextBlack,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose when this draft should go live.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextGrey,
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
                    const Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kTextBlack,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: kPillBg,
                      borderRadius: BorderRadius.circular(homeRadiusLg),
                      child: InkWell(
                        onTap: () async {
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
                        borderRadius: BorderRadius.circular(homeRadiusLg),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 54),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
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
                                  borderRadius: BorderRadius.circular(
                                    homeRadiusMd,
                                  ),
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
                                  _formatTime(selectedTime),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: kTextBlack,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              const Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kBlue,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 52),
                        backgroundColor: kBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(homeRadiusMd),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
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

  void _addToQueue() {
    if (_scheduledAt == null) {
      _openScheduleSheet();
      return;
    }

    Navigator.of(context).pushNamed('/Scheduled');
  }

  String _scheduleLabel() {
    final scheduledAt = _scheduledAt;
    if (scheduledAt == null) return 'Choose date and time';

    final date = _formatDate(scheduledAt);
    final time = _formatTime(
      TimeOfDay(hour: scheduledAt.hour, minute: scheduledAt.minute),
    );
    return '$date, $time';
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

  bool get _canFinish {
    return _messages.where((message) => message.isUser).length > 1;
  }

  String get _latestUserPrompt {
    for (final message in _messages.reversed) {
      if (message.isUser) return message.text;
    }
    return 'Your new post';
  }

  String _previewText(_AiContentType type) {
    final prompt = _latestUserPrompt;

    return switch (type) {
      _AiContentType.caption =>
        'Hook your audience with a clear opening, explain why "$prompt" matters, and close with a simple CTA that invites replies.',
      _AiContentType.imageCaption =>
        'A visual-first caption for "$prompt" that connects the image to the audience, adds context, and ends with a save/share CTA.',
      _AiContentType.videoCaption =>
        'Hook: Stop scrolling if this matters to you.\n\nCaption: $prompt\n\nCTA: Save this for your next content planning session.',
      _AiContentType.motionGraphics =>
        'Scene 1: Bold opener from "$prompt".\nScene 2: Three animated proof points.\nScene 3: Final CTA with brand lockup.',
    };
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _contentTypeLabel(_AiContentType type) {
    return switch (type) {
      _AiContentType.caption => 'Caption',
      _AiContentType.imageCaption => 'Image caption',
      _AiContentType.videoCaption => 'Video caption',
      _AiContentType.motionGraphics => 'Motion graphics',
    };
  }

  IconData _contentTypeIcon(_AiContentType type) {
    return switch (type) {
      _AiContentType.caption => Icons.notes_rounded,
      _AiContentType.imageCaption => Icons.image_rounded,
      _AiContentType.videoCaption => Icons.play_circle_fill_rounded,
      _AiContentType.motionGraphics => Icons.auto_awesome_motion_rounded,
    };
  }

  String _starterReply(_AiContentType type) {
    return switch (type) {
      _AiContentType.caption =>
        'Tell me the topic, platform, audience, and tone. I will turn it into a polished post caption.',
      _AiContentType.imageCaption =>
        'Upload or describe the image, then tell me the platform and message. I will write a caption that matches the visual.',
      _AiContentType.videoCaption =>
        'Share the video idea, length, and audience. I can create a hook, caption, hashtags, and CTA.',
      _AiContentType.motionGraphics =>
        'Describe the motion graphic concept. I can shape the script, scene beats, on-screen text, and caption.',
    };
  }

  String _generatedReply(_AiContentType type, String prompt) {
    final label = _contentTypeLabel(type);
    return switch (type) {
      _AiContentType.caption =>
        '$label draft:\n\n$prompt\n\nHere is a stronger social caption angle: open with a clear hook, add one useful detail, then close with a simple CTA. Want it more formal, playful, or sales-focused?',
      _AiContentType.imageCaption =>
        '$label draft:\n\nA visual-first caption for "$prompt" should describe the moment, connect it to the audience, and end with a direct action. Do you want this optimized for Instagram, LinkedIn, TikTok, or YouTube?',
      _AiContentType.videoCaption =>
        '$label draft:\n\nHook: Stop scrolling if this is your problem.\nCaption: $prompt\nCTA: Save this and share it with someone planning content this week.\n\nShould I also create a short video script?',
      _AiContentType.motionGraphics =>
        '$label idea:\n\nScene 1: Big headline from your prompt.\nScene 2: Three quick animated proof points.\nScene 3: Logo lockup and CTA.\n\nCaption base: $prompt\n\nWant this as a 15-second or 30-second concept?',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SideNavOverlay(
        isOpen: _isSideNavOpen,
        activeIndex: 3,
        onClose: _closeSideNav,
        onItemSelected: (_) => _closeSideNav(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.orientationOf(context) == Orientation.landscape;
              final isWide = constraints.maxWidth >= 700 || isLandscape;
              final content = _CreateAiContent(
                messages: _messages,
                selectedType: _selectedType,
                isThinking: _isThinking,
                isFinishing: _isFinishing,
                showPreview: _showPreview,
                canFinish: _canFinish,
                isScheduled: _scheduledAt != null,
                scheduleLabel: _scheduleLabel(),
                previewText: _selectedType == null
                    ? ''
                    : _previewText(_selectedType!),
                promptController: _promptController,
                scrollController: _scrollController,
                onMenuTap: _openSideNav,
                onSend: _sendPrompt,
                onFinish: _finishCreation,
                onBackToChat: _backToChat,
                onSchedule: _openScheduleSheet,
                onAddToQueue: _addToQueue,
                onTypeSelected: _selectType,
                contentTypeLabel: _contentTypeLabel,
                contentTypeIcon: _contentTypeIcon,
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
