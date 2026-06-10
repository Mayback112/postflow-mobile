import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

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

    Navigator.of(context).pushReplacementNamed('/Scheduled');
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

class _CreateAiContent extends StatelessWidget {
  final List<_ChatMessage> messages;
  final _AiContentType? selectedType;
  final bool isThinking;
  final bool isFinishing;
  final bool showPreview;
  final bool canFinish;
  final bool isScheduled;
  final String scheduleLabel;
  final String previewText;
  final TextEditingController promptController;
  final ScrollController scrollController;
  final VoidCallback onMenuTap;
  final VoidCallback onSend;
  final VoidCallback onFinish;
  final VoidCallback onBackToChat;
  final VoidCallback onSchedule;
  final VoidCallback onAddToQueue;
  final ValueChanged<_AiContentType> onTypeSelected;
  final String Function(_AiContentType type) contentTypeLabel;
  final IconData Function(_AiContentType type) contentTypeIcon;

  const _CreateAiContent({
    required this.messages,
    required this.selectedType,
    required this.isThinking,
    required this.isFinishing,
    required this.showPreview,
    required this.canFinish,
    required this.isScheduled,
    required this.scheduleLabel,
    required this.previewText,
    required this.promptController,
    required this.scrollController,
    required this.onMenuTap,
    required this.onSend,
    required this.onFinish,
    required this.onBackToChat,
    required this.onSchedule,
    required this.onAddToQueue,
    required this.onTypeSelected,
    required this.contentTypeLabel,
    required this.contentTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPreview)
          _PreviewTopBar(onBack: onBackToChat, onMenuTap: onMenuTap)
        else
          _CreateAiTopBar(onMenuTap: onMenuTap),
        if (selectedType == null)
          Expanded(
            child: _ChoiceStage(
              onTypeSelected: onTypeSelected,
              contentTypeLabel: contentTypeLabel,
              contentTypeIcon: contentTypeIcon,
            ),
          )
        else if (showPreview)
          Expanded(
            child: _PreviewStage(
              contentType: selectedType!,
              previewText: previewText,
              isScheduled: isScheduled,
              scheduleLabel: scheduleLabel,
              onSchedule: onSchedule,
              onAddToQueue: onAddToQueue,
              contentTypeLabel: contentTypeLabel,
              contentTypeIcon: contentTypeIcon,
            ),
          )
        else ...[
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              itemCount: messages.length + (isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const _ThinkingBubble();
                }
                return _ChatBubble(message: messages[index]);
              },
            ),
          ),
          _PromptComposer(
            controller: promptController,
            selectedLabel: contentTypeLabel(selectedType!),
            canFinish: canFinish,
            isThinking: isThinking,
            isFinishing: isFinishing,
            onSend: onSend,
            onFinish: onFinish,
          ),
        ],
      ],
    );
  }
}

class _CreateAiTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _CreateAiTopBar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
                  'Create with AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kTextBlack,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Chat through your next post',
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

class _PreviewTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMenuTap;

  const _PreviewTopBar({required this.onBack, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                tooltip: 'Back to chat',
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  foregroundColor: kTextBlack,
                ),
              ),
            ),
            const Text(
              'Post Preview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kTextBlack,
                fontFamily: 'Poppins',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: onMenuTap,
                  icon: Image.asset(
                    '$homeIconPath/heroicons-solid_menu-alt-3.png',
                    width: 19,
                    height: 19,
                    fit: BoxFit.contain,
                  ),
                  tooltip: 'Open navigation menu',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    backgroundColor: kPillBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(homeRadiusMd),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceStage extends StatelessWidget {
  final ValueChanged<_AiContentType> onTypeSelected;
  final String Function(_AiContentType type) contentTypeLabel;
  final IconData Function(_AiContentType type) contentTypeIcon;

  const _ChoiceStage({
    required this.onTypeSelected,
    required this.contentTypeLabel,
    required this.contentTypeIcon,
  });

  String _description(_AiContentType type) {
    return switch (type) {
      _AiContentType.caption => 'Write a clean post caption from your idea.',
      _AiContentType.imageCaption =>
        'Describe or attach an image, then caption it.',
      _AiContentType.videoCaption =>
        'Create hooks, captions, CTAs, and hashtags.',
      _AiContentType.motionGraphics =>
        'Plan scenes, motion text, and a matching caption.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AiIntroBubble(),
          const SizedBox(height: 18),
          const Text(
            'Choose what you want AI to create',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kTextBlack,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          ..._AiContentType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChoiceCard(
                icon: contentTypeIcon(type),
                title: contentTypeLabel(type),
                description: _description(type),
                onTap: () => onTypeSelected(type),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiIntroBubble extends StatelessWidget {
  const _AiIntroBubble();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _AiAvatar(),
        SizedBox(width: 8),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: homeSoftShadow,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                'Hi, choose the type of content first. After that, I will chat with you and help create it step by step.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: kTextMuted,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        boxShadow: homeSoftShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(homeRadiusLg),
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: kBorderLight),
              borderRadius: BorderRadius.circular(homeRadiusLg),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kBlueBg,
                    borderRadius: BorderRadius.circular(homeRadiusMd),
                  ),
                  child: Icon(icon, color: kBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kTextBlack,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: kTextGrey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: kTextGrey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) const _AiAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? kBlue : kCardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 18),
                ),
                border: isUser ? null : Border.all(color: kBorderLight),
                boxShadow: isUser ? null : homeSoftShadow,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: isUser ? Colors.white : kTextMuted,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewStage extends StatelessWidget {
  final _AiContentType contentType;
  final String previewText;
  final bool isScheduled;
  final String scheduleLabel;
  final VoidCallback onSchedule;
  final VoidCallback onAddToQueue;
  final String Function(_AiContentType type) contentTypeLabel;
  final IconData Function(_AiContentType type) contentTypeIcon;

  const _PreviewStage({
    required this.contentType,
    required this.previewText,
    required this.isScheduled,
    required this.scheduleLabel,
    required this.onSchedule,
    required this.onAddToQueue,
    required this.contentTypeLabel,
    required this.contentTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PreviewSummary(),
          const SizedBox(height: 14),
          _SocialPostPreview(
            contentType: contentType,
            previewText: previewText,
            contentTypeLabel: contentTypeLabel,
            contentTypeIcon: contentTypeIcon,
          ),
          const SizedBox(height: 12),
          _ScheduleBar(isScheduled: isScheduled, scheduleLabel: scheduleLabel),
          const SizedBox(height: 10),
          const _PostingToCard(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onSchedule,
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
                  child: Text(isScheduled ? 'Update schedule' : 'Schedule'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton(
                  onPressed: isScheduled ? onAddToQueue : onSchedule,
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
                  child: Text(isScheduled ? 'Add to queue' : 'Post now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewSummary extends StatelessWidget {
  const _PreviewSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(homeSpaceLg),
      decoration: BoxDecoration(
        color: kBlueBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: kBlue, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI draft ready for review',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: kBlue,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          _PreviewTag(label: 'Draft', isActive: true),
        ],
      ),
    );
  }
}

class _SocialPostPreview extends StatelessWidget {
  final _AiContentType contentType;
  final String previewText;
  final String Function(_AiContentType type) contentTypeLabel;
  final IconData Function(_AiContentType type) contentTypeIcon;

  const _SocialPostPreview({
    required this.contentType,
    required this.previewText,
    required this.contentTypeLabel,
    required this.contentTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(homeSpaceLg),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusLg),
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
                decoration: BoxDecoration(
                  color: kMintBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: kMint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Postflow AI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kTextBlack,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Generated content preview',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: kTextGrey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz_rounded, size: 22),
                tooltip: 'Preview options',
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  foregroundColor: kTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PreviewMedia(
            contentType: contentType,
            label: contentTypeLabel(contentType),
            icon: contentTypeIcon(contentType),
          ),
          const SizedBox(height: 12),
          Text(
            previewText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: kTextMuted,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '#SummerCollection #NewDrop #Fashion\n#LimitedEdition #ShopNow',
            style: TextStyle(
              fontSize: 11,
              height: 1.45,
              color: kBlue,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.favorite_border_rounded, size: 21, color: kTextBlack),
              SizedBox(width: 12),
              Icon(Icons.chat_bubble_outline_rounded, size: 21),
              SizedBox(width: 12),
              Icon(Icons.send_outlined, size: 21),
              Spacer(),
              Icon(Icons.bookmark_border_rounded, size: 22),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewMedia extends StatelessWidget {
  final _AiContentType contentType;
  final String label;
  final IconData icon;

  const _PreviewMedia({
    required this.contentType,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = contentType == _AiContentType.videoCaption;
    final isMotion = contentType == _AiContentType.motionGraphics;
    final isCaption = contentType == _AiContentType.caption;

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset(
                isCaption
                    ? 'asset/images/background/Onboarding2.png'
                    : 'asset/images/background/Onboarding3.png',
                fit: BoxFit.cover,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.02),
                    Colors.black.withValues(alpha: 0.34),
                  ],
                ),
              ),
            ),
            if (isVideo || isMotion)
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVideo
                        ? Icons.play_arrow_rounded
                        : Icons.auto_awesome_motion_rounded,
                    color: kBlue,
                    size: isVideo ? 36 : 28,
                  ),
                ),
              ),
            if (isCaption)
              Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(homeRadiusMd),
                  ),
                  child: const Text(
                    'Caption preview',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextBlack,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 32,
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.15,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _imageUrl {
    return switch (contentType) {
      _AiContentType.caption =>
        'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=900&q=80',
      _AiContentType.imageCaption =>
        'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=900&q=80',
      _AiContentType.videoCaption =>
        'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=900&q=80',
      _AiContentType.motionGraphics =>
        'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=900&q=80',
    };
  }
}

class _ScheduleBar extends StatelessWidget {
  final bool isScheduled;
  final String scheduleLabel;

  const _ScheduleBar({required this.isScheduled, required this.scheduleLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isScheduled ? kMintBg : kBlueBg,
            borderRadius: BorderRadius.circular(homeRadiusMd),
          ),
          child: Icon(
            isScheduled
                ? Icons.event_available_rounded
                : Icons.schedule_rounded,
            size: 18,
            color: isScheduled ? kMint : kBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isScheduled ? 'Scheduled' : 'Not scheduled',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kTextMuted,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isScheduled ? kMintBg : kPillBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: kBorderLight),
          ),
          child: Text(
            scheduleLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isScheduled ? kMint : kTextGrey,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}

class _PostingToCard extends StatelessWidget {
  const _PostingToCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'POSTING TO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: kTextGrey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kBlueBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: kBlue, size: 12),
                    SizedBox(width: 2),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: kBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PreviewTag(label: 'Instagram'),
              _PreviewTag(label: 'TikTok'),
              _PreviewTag(label: 'YouTube'),
              _PreviewTag(label: 'LinkedIn'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewTag extends StatelessWidget {
  final String label;
  final bool isActive;

  const _PreviewTag({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? kBlue : kPillBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kBorderLight),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isActive ? Colors.white : kTextGrey,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _AiAvatar(),
          SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.all(Radius.circular(18)),
              boxShadow: homeSoftShadow,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                'AI is drafting...',
                style: TextStyle(
                  fontSize: 13,
                  color: kTextGrey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: kMintBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: kMint, size: 18),
    );
  }
}

class _PromptComposer extends StatelessWidget {
  final TextEditingController controller;
  final String selectedLabel;
  final bool canFinish;
  final bool isThinking;
  final bool isFinishing;
  final VoidCallback onSend;
  final VoidCallback onFinish;

  const _PromptComposer({
    required this.controller,
    required this.selectedLabel,
    required this.canFinish,
    required this.isThinking,
    required this.isFinishing,
    required this.onSend,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kBorderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isFinishing) ...[
            const _SubmissionStatus(),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    enabled: !isThinking,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: 'Tell AI about your $selectedLabel...',
                      hintStyle: const TextStyle(
                        color: kTextGrey,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                      filled: true,
                      fillColor: kPillBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(homeRadiusLg),
                        borderSide: const BorderSide(color: kBorderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(homeRadiusLg),
                        borderSide: const BorderSide(color: kBorderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(homeRadiusLg),
                        borderSide: const BorderSide(color: kBlue),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(homeRadiusLg),
                        borderSide: const BorderSide(color: kBorderLight),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: kTextBlack,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: isThinking ? null : onSend,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  tooltip: 'Send prompt',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: isThinking ? kBorderLight : kBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(homeRadiusMd),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: canFinish && !isThinking ? onFinish : null,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Finish and preview'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                backgroundColor: kMint,
                disabledBackgroundColor: kBorderLight,
                foregroundColor: Colors.white,
                disabledForegroundColor: kTextGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmissionStatus extends StatelessWidget {
  const _SubmissionStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kPillBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusLg),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: kBlue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI is thinking and submitting your draft...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextMuted,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}
