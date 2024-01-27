import 'package:string_similarity/string_similarity.dart';

class Autocomplete{
  // Returns a string with only the numeric characters from the input
  static String _numericOnly(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  // Returns true if the input contains only digits and spaces
  static bool _isOnlyDigits(String input) {
    final digitsAndSpacesRegex =
        RegExp(r'^\d*$'); // Matches digits and spaces only
    return digitsAndSpacesRegex.hasMatch(input);
  }

  // Returns a list of entries that contain the input characters in order
  static List<String> _filterEntriesWithoutInput(String input, List<String> entries) {
    return entries.where((entry) {
      return _containsWord(input, entry);
    }).toList();
  }

  // Returns true if the input characters are contained in the entry in order
  static bool _containsWord(String input, String word) {
    int inputIndex = 0;
    for (int i = 0; i < word.length; i++) {
      if (word[i] == input[inputIndex]) {
        inputIndex++;
        // If all input characters have been found, the entry matches
        if (inputIndex == input.length) {
          return true;
        }
      }
    }
    return false;
  }

  ///Filters the options list according to the input and returns it sorted by similarity.
  ///
  /// Filters entries that do not contain the input characters in order.
  /// As an exception, numeral part (for line or station code for example) can appear anywhere.
  static List<String> bestMatches(String input, List<String> options) {
    List<String> filteredList = List.from(options);
    if (_numericOnly(input).isNotEmpty) {
      filteredList
          .retainWhere((option) => _numericOnly(option) == _numericOnly(input));
    }
    if (input.isNotEmpty) {
      filteredList = _filterEntriesWithoutInput(input, filteredList);
    }

    filteredList.sort((a, b) => _moreSimilarToInput(a, b, input));
    return filteredList;
  }

  // Returns a number that represents the similarity of a and b to the input.
  //
  // The smaller the number, the more similar the string a is to the input relative to b.
  static int _moreSimilarToInput(String a, String b, String input) {
    // Determine similarity based on input type and string content
    double similarityA;
    double similarityB;

    if (_isOnlyDigits(input)) {
      // Prioritize numeric similarity if input has numerals only
      similarityA = StringSimilarity.compareTwoStrings(input, _numericOnly(a));
      similarityB = StringSimilarity.compareTwoStrings(input, _numericOnly(b));
    } else {
      // Use general string similarity otherwise
      similarityA = StringSimilarity.compareTwoStrings(input, a);
      similarityB = StringSimilarity.compareTwoStrings(input, b);
    }
    // Sort in descending order
    return -similarityA.compareTo(similarityB);
  }
}