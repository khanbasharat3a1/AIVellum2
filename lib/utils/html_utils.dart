class HtmlUtils {
  static String stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return htmlString;
    
    // Remove HTML tags
    String result = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Decode common HTML entities
    result = result
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&apos;', "'");
    
    return result.trim();
  }
}
