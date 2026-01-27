import 'package:flutter/material.dart';

/// A stateless widget that wraps a child widget in a styled container with optional dimensions.
class SectionContainer extends StatelessWidget {
  /// Creates a [SectionContainer].
  const SectionContainer({required this.child, this.height, this.width, super.key});

  /// The child widget to display inside the container.
  final Widget child;
  /// Optional height of the container.
  final double? height;
  /// Optional width of the container.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      padding: height == null ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// A stateless widget that displays a label-value pair in a column layout.
class ContainerRow extends StatelessWidget {
  /// Creates a [ContainerRow].
  const ContainerRow({
    required this.label,
    required this.value,
    this.valueColor,
    super.key,
  });

  /// The label text to display.
  final String label;
  /// The value text to display.
  final String value;
  /// Optional color for the value text.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
