extension StringExtension on String {
  bool get containsImageFormat =>
      endsWith('.jpg') || endsWith('.png') || endsWith('.jpeg');
}
