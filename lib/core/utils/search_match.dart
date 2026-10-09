bool matchesSearch(String first, String second, String query) {
  final normalized = query.trim().toLowerCase();
  return normalized.isEmpty ||
      first.toLowerCase().contains(normalized) ||
      second.toLowerCase().contains(normalized);
}
