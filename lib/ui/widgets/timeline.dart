import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TimelineEntry {
  const TimelineEntry({required this.title, required this.description, this.caption});

  final String title;
  final String description;
  final String? caption;
}

/// Linha do tempo vertical com marcadores verdes (.timeline).
class Timeline extends StatelessWidget {
  const Timeline({super.key, required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < entries.length; i++)
            _TimelineTile(entry: entries[i], isLast: i == entries.length - 1),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry, required this.isLast});

  final TimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 6),
          padding: EdgeInsets.only(left: 22, bottom: isLast ? 0 : 22),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: isLast ? Colors.transparent : const Color(0xFFDCE8E1)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
              const SizedBox(height: 5),
              Text(
                entry.description,
                style: const TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF788A81)),
              ),
              if (entry.caption != null) ...[
                const SizedBox(height: 5),
                Text(entry.caption!, style: const TextStyle(fontSize: 10, color: Color(0xFFA0ACA6))),
              ],
            ],
          ),
        ),
        Positioned(
          left: 1,
          top: 0,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: const Color(0xFF66BD98),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6F5ED), width: 3),
            ),
          ),
        ),
      ],
    );
  }
}
