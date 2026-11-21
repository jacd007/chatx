import 'package:flutter/material.dart';

import 'ai_features.dart';
import 'appearance_features.dart';
import 'community_features.dart';
import 'content_features.dart';
import 'demo_chat.dart';
import 'media_features.dart';
import 'messaging_features.dart';

/// Every feature of chatx as its own small, working demo.
class FeatureCatalogPage extends StatefulWidget {
  const FeatureCatalogPage({super.key});

  @override
  State<FeatureCatalogPage> createState() => _FeatureCatalogPageState();
}

class _FeatureCatalogPageState extends State<FeatureCatalogPage> {
  final groups = [
    messagingFeatures,
    mediaFeatures,
    contentFeatures,
    aiFeatures,
    communityFeatures,
    appearanceFeatures,
  ];
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    bool matches(FeatureDemo demo) =>
        query.isEmpty ||
        demo.title.toLowerCase().contains(query) ||
        demo.description.toLowerCase().contains(query);
    final total = groups.fold<int>(0, (sum, g) => sum + g.demos.length);

    return Scaffold(
      appBar: AppBar(title: Text('Features ($total)')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              key: const Key('feature_search'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search features',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          for (final group in groups)
            if (group.demos.any(matches)) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  group.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              for (final demo in group.demos.where(matches))
                ListTile(
                  leading: Icon(demo.icon),
                  title: Text(demo.title),
                  subtitle: Text(demo.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: demo.builder),
                  ),
                ),
            ],
        ],
      ),
    );
  }
}
