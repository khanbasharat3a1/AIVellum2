class TextUtils {
  /// Strips markdown/markup formatting from text and returns plain text
  static String stripMarkup(String text) {
    if (text.isEmpty) return text;
    
    String result = text;
    
    // Remove bold markers (**text** or __text__)
    result = result.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1');
    result = result.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    
    // Remove italic markers (*text* or _text_)
    result = result.replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1');
    result = result.replaceAll(RegExp(r'_([^_]+)_'), r'$1');
    
    // Remove strikethrough (~~text~~)
    result = result.replaceAll(RegExp(r'~~([^~]+)~~'), r'$1');
    
    // Remove inline code (`code`)
    result = result.replaceAll(RegExp(r'`([^`]+)`'), r'$1');
    
    // Remove code blocks (```code```)
    result = result.replaceAll(RegExp(r'```[^\n]*\n(.*?)```', dotAll: true), r'$1');
    
    // Remove links [text](url) - keep only text
    result = result.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    
    // Remove images ![alt](url)
    result = result.replaceAll(RegExp(r'!\[([^\]]*)\]\([^\)]+\)'), r'$1');
    
    // Remove headers (# ## ### etc)
    result = result.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Remove horizontal rules (---, ***, ___)
    result = result.replaceAll(RegExp(r'^[\-\*_]{3,}$', multiLine: true), '');
    
    // Remove blockquotes (> text)
    result = result.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    
    // Remove HTML tags
    result = result.replaceAll(RegExp(r'<[^>]+>'), '');
    
    // Clean up multiple newlines
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Trim whitespace
    result = result.trim();
    
    return result;
  }
  
  /// Checks if text contains markdown/markup formatting
  static bool hasMarkup(String text) {
    if (text.isEmpty) return false;
    
    // Check for common markdown patterns
    final markupPatterns = [
      RegExp(r'\*\*[^\*]+\*\*'),  // Bold
      RegExp(r'__[^_]+__'),        // Bold
      RegExp(r'\*[^\*]+\*'),       // Italic
      RegExp(r'_[^_]+_'),          // Italic
      RegExp(r'~~[^~]+~~'),        // Strikethrough
      RegExp(r'`[^`]+`'),          // Inline code
      RegExp(r'```'),              // Code block
      RegExp(r'\[[^\]]+\]\([^\)]+\)'), // Links
      RegExp(r'!\[[^\]]*\]\([^\)]+\)'), // Images
      RegExp(r'^#{1,6}\s+', multiLine: true), // Headers
      RegExp(r'<[^>]+>'),          // HTML tags
    ];
    
    for (final pattern in markupPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    
    return false;
  }
}
