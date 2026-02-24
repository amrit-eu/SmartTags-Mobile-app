/// String extension to add utility methods for string manipulation.
extension StringExtension on String {
  /// Capitalizes the first letter of the string and makes the rest lowercase.
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
