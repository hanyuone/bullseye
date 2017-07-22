import "dart:convert";

/// Private methods.

/// Returns a list of numbers from start to end, inclusive
/// of start.
///
///        _range(5, 10)
///     => [5, 6, 7, 8, 9]
List<int> _range(int start, int end) {
  List<int> out = [];

  for (int a = start; a < end; a++) out.add(a);

  return out;
}

/// Checks if a string's parentheses are balanced.
bool _isBalanced(String msg) {
  int counter = 0;

  for (int a = 0; a < msg.length; a++) {
    if (msg[a] == "(")
      counter++;
    else if (msg[a] == ")") counter--;
  }

  return counter == 0;
}

/// Find the first index from start that creates a balanced
/// string.
int _matchParens(String msg, int start) {
  int index = start;
  int counter = 1;

  while (counter != 0) {
    index++;

    if (msg[index] == "(")
      counter++;
    else if (msg[index] == ")") counter--;
  }

  return index;
}

/// Splits a regex into groups.
List<List<int>> _groups(String regex) {
  List<List<int>> group_indices = [];

  int index = 0;

  while (index < regex.length) {
    if (regex[index] == "(") {
      int temp = _matchParens(regex, index);

      group_indices.add([index + 1, temp]);
      index = temp;
    } else {
      index++;
    }
  }

  return group_indices;
}

/// Tokenises a range of characters.
List<String> _tokeniseRange(String range) {
  List<String> tokenised = [];

  for (int index = 0; index < range.length; index++) {
    if (index < range.length - 1 && range[index] == "\\") {
      tokenised.add(range[index + 1]);
      index++;
    } else if (range[index] == "-") {
      tokenised.add("TO");
    } else {
      tokenised.add(range[index]);
    }
  }

  return tokenised;
}

/// Turns a regex range into a list of possible characters.
List<String> _parseRange(String range) {
  List<String> tokenised = _tokeniseRange(range);
  Set<String> chars = new Set();

  for (int a = 0; a < tokenised.length; a++) {
    if (a < tokenised.length - 2 && tokenised[a + 1] == "TO") {
      int start = tokenised[a].codeUnitAt(0);
      int end = tokenised[a + 2].codeUnitAt(0);

      chars.addAll(UTF8.decode(_range(start, end + 1)).split(""));
      a += 2;
    } else {
      chars.add(tokenised[a]);
    }
  }

  return chars.toList();
}

List _flatten(List coll) {
  List final_coll = [];

  for (var e in coll) {
    if (e is List)
      final_coll.addAll(_flatten(e));
    else
      final_coll.add(e);
  }

  return final_coll;
}

/// Public methods.

/// Gets last element of [coll].
dynamic last(List coll) {
  return coll[coll.length - 1];
}

/// Turns a range into something easier to work with.
List tokeniseRegex(String regex) {
  List regex_groups = [];
  Map<String, String> quantifiers = {"*": "STAR", "+": "PLUS", "?": "QMARK"};

  int index = 0;

  while (index < regex.length) {
    List regex_group = [];

    if (regex[index] == "(") {
      int match_index = _matchParens(regex, index);
      String group_string = regex.substring(index + 1, match_index);

      List<String> split = group_string.split("|");

      if (group_string.contains("|") && _isBalanced(split[0])) {
        regex_group.add("OR");
        regex_group.addAll(split.map((s) => ["GROUP", tokeniseRegex(s)]));
      } else {
        regex_group = ["GROUP", tokeniseRegex(group_string)];
      }

      index = match_index + 1;
    } else if (regex[index] == "[") {
      List<String> group_string;
      int group_index = regex.indexOf("]") + 1;

      if (regex[1] == "^") {
        group_string = _parseRange(regex.substring(2, group_index - 1));
        regex_group = ["CHAR", "!!" + group_string.join("")];
      } else {
        group_string = _parseRange(regex.substring(1, group_index - 1));
        regex_group = ["CHAR", group_string.join("")];
      }

      index = group_index;
    } else {
      regex_group = ["CHAR", regex[index]];
      index++;
    }

    if (index < regex.length && quantifiers.containsKey(regex[index])) {
      regex_group = [quantifiers[regex[index]], regex_group];
      index++;
    } else if (index < regex.length - 2 && regex[index] == "{") {
      
    }

    regex_groups.add(regex_group);
  }

  return regex_groups;
}

int lookbehindLength(List lookbehind) {
  List new_list = _flatten(lookbehind);

  if (["PLUS", "STAR", "QMARK"]
      .map((item) => new_list.contains(item))
      .reduce((a, b) => a || b)) {
    throw new ArgumentError("Lookbehind is not of fixed length");
  } else {
    int length = 0;

    for (int a = 0; a < lookbehind.length; a++) {
      if (lookbehind[a][0] == "RANGE" || lookbehind[a][0] == "CHAR") {
        length += 1;
      } else if (lookbehind[a][0] == "GROUP") {
        length += lookbehindLength(lookbehind[a][1]);
      } else if (lookbehind[a][0] == "OR") {
        List<int> lengths = lookbehind[a]
            .sublist(1)
            .map((list) => lookbehindLength([list]))
            .toList();

        if (!lengths.map((a) => a == lengths[0]).reduce((a, b) => a && b)) {
          throw new ArgumentError("Lookbehind is not of fixed length");
        } else {
          length += lengths[0];
        }
      }
    }

    return length;
  }
}

/// Gets a lookbehind string in a regex.
int getLookbehind(String regex) {
  List<List<int>> possible_groups = _groups(regex);

  if (possible_groups.length == 0) return -1;

  List<int> possible = possible_groups[0];
  String possible_lb = regex.substring(possible[0], possible[1]);

  if (possible_lb.startsWith("?<") && possible[0] != 1) {
    throw new ArgumentError("Lookbehind is not at start of string");
  } else {
    if (possible_lb.startsWith("?<")) {
      return possible[1];
    } else {
      return -1;
    }
  }
}

/// Gets a lookahead string in a regex.
int getLookahead(String regex) {
  List<List<int>> possible_groups = _groups(regex);

  if (possible_groups.length == 0) return -1;

  List<int> possible = last(possible_groups);
  String possible_la = regex.substring(possible[0], possible[1]);

  if (possible_la.startsWith("?") && possible[1] != regex.length - 1) {
    throw new ArgumentError("Lookahead is not at end of string");
  } else {
    if (possible_la.startsWith("?")) {
      return possible[0];
    } else {
      return -1;
    }
  }
}

void main() {
  print(lookbehindLength(tokeniseRegex("(ab|cd)ee")));
}
