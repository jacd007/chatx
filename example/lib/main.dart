import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/ai_streaming_page.dart';
import 'pages/basic_chat_page.dart';
import 'pages/bubble_styles_page.dart';
import 'pages/community_page.dart';
import 'pages/custom_look_page.dart';
import 'pages/media_page.dart';
import 'pages/pagination_page.dart';
import 'pages/support_bot_page.dart';

void main() => runApp(const ChatxExampleApp());

class ChatxExampleApp extends StatelessWidget {
  const ChatxExampleApp({super.key});

  static const _seed = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chatx',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: _seed),
      darkTheme: ThemeData(colorSchemeSeed: _seed, brightness: Brightness.dark),
      // Dates and times inside chatx follow MaterialLocalizations.
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en'), Locale('es')],
      home: const DemoListPage(),
    );
  }
}

class DemoListPage extends StatelessWidget {
  const DemoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <(String, String, IconData, WidgetBuilder)>[
      (
        'Basic chat',
        'Swipe to reply, reactions, popup menu, edit',
        Icons.forum_outlined,
        (_) => const BasicChatPage(),
      ),
      (
        'Media & files',
        'Images, files, voice notes, links, spoilers',
        Icons.perm_media_outlined,
        (_) => const MediaPage(),
      ),
      (
        'Community',
        'Survey, poll, thread, seen by, mentions, search',
        Icons.groups_outlined,
        (_) => const CommunityPage(),
      ),
      (
        'Support bot',
        'Buttons, quick replies, disappearing code',
        Icons.support_agent_outlined,
        (_) => const SupportBotPage(),
      ),
      (
        'AI streaming',
        'Token-by-token answers with markdown',
        Icons.auto_awesome_outlined,
        (_) => const AiStreamingPage(),
      ),
      (
        'Bubble styles',
        'Tail, radius, shadow and outline',
        Icons.chat_bubble_outline,
        (_) => const BubbleStylesPage(),
      ),
      (
        'Custom look',
        'Theme, builders, custom messages, actions',
        Icons.palette_outlined,
        (_) => const CustomLookPage(),
      ),
      (
        'Infinite history',
        'Load older messages while scrolling',
        Icons.history,
        (_) => const PaginationPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('chatx demos')),
      body: ListView(
        children: [
          for (final (title, subtitle, icon, builder) in demos)
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: builder),
              ),
            ),
        ],
      ),
    );
  }
}
