import 'package:flutter/material.dart';
import 'package:smart_tags/widgets/common/container.dart';

/// A collapsed-by-default section for secondary/optional form fields,
/// styled to match [SectionContainer]'s bordered container look.
class CollapsibleSection extends StatelessWidget {
  /// Creates a [CollapsibleSection].
  const CollapsibleSection({required this.title, required this.children, super.key});

  /// The section's header text.
  final String title;

  /// The fields shown when the section is expanded.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [Column(spacing: 16, children: children)],
      ),
    );
  }
}
