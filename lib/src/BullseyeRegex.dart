// Copyright (c) 2017, Hanyuan Li. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "Methods.dart";
import "Node.dart";
import "DFA.dart";

/// Main class for new regex.
class BullseyeRegex {
  String regex;
  List possible_groups;
  Map regexes = {"behind": [], "main": [], "ahead": []};

  int lookbehind_length = 0;

  List<Node> nodes;
  List<int> ending_nodes;
  Map<int, int> node_indices = {};

  /// Initialises regex for matching.
  void _init() {
    int lookbehind_index = getLookbehind(this.regex);
    int lookahead_index = getLookahead(this.regex);

    if (lookbehind_index != -1) {
      this.regexes["behind"] = [
        this.regex[3] == "=",
        new BullseyeRegex(this.regex.substring(4, lookbehind_index))
      ];
      this.lookbehind_length = lookbehindLength(
          tokeniseRegex(this.regex.substring(4, lookbehind_index)));
      this.regex = this.regex.substring(lookbehind_index + 1);
    }

    if (lookahead_index != -1) {
      this.regexes["ahead"] = [
        this.regex[lookahead_index + 1] == "=",
        new BullseyeRegex(
            this.regex.substring(lookahead_index + 2, this.regex.length - 1))
      ];
      this.regex = this.regex.substring(0, lookahead_index - 1);
    }

    this.regexes["main"] = new DFA(tokeniseRegex(this.regex));
    this.nodes = this.regexes["main"].nodes;
    this.ending_nodes = this.regexes["main"].ending_nodes;

    for (int a = 0; a < this.nodes.length; a++)
      this.node_indices[this.nodes[a].ident] = a;
  }

  BullseyeRegex(String regex) {
    this.regex = regex;

    this._init();
  }

  /// Returns amount of matched chars.
  /// 
  /// Goes through a message, and returns the amount of characters
  /// matched by the regex from the start of the message.
  int _matchChars(String msg) {
    int current_node = 0;
    int matched_chars = 0;

    while (matched_chars < msg.length) {
      int temp = matched_chars;
      List paths = this.nodes[current_node].paths;

      for (int a = 0; a < paths.length; a++) {
        String chars = paths[a][0];
        bool no_match =
            chars.length > 2 && chars.substring(0, 2) == "!!";
        List<String> match_chars;
        int new_node = node_indices[paths[a][1]];

        if (no_match)
          match_chars = chars.split("").sublist(2);
        else
          match_chars = chars.split("");

        if (no_match == match_chars.contains(msg[matched_chars])) continue;

        temp += 1;
        current_node = new_node;
        break;
      }

      if (temp != matched_chars)
        matched_chars += 1;
      else
        break;
    }

    if (ending_nodes.contains(this.nodes[current_node].ident))
      return matched_chars;
    else
      return -1;
  }

  /// Returns a list of all matches.
  /// 
  /// Given a string [msg], this returns a list of strings
  /// inside [msg] that match the regex.
  List<String> allMatches(String msg) {
    List<String> matches = [];

    for (int a = 0; a < msg.length; a++) {
      if (regexes["behind"].length != 0) {
        if (regexes["behind"][0] && a < this.lookbehind_length) continue;

        if (!((a < this.lookbehind_length) || !regexes["behind"][0])) {
          BullseyeRegex temp_lb = regexes["behind"][1];
          List<String> lb_matches =
              temp_lb.allMatches(msg.substring(a - lookbehind_length, a));

          if (regexes["behind"][0] != (lb_matches.length == 1)) continue;
        }
      }

      int match_index = this._matchChars(msg.substring(a));

      if (match_index == -1) continue;

      if (regexes["ahead"].length != 0 &&
          (regexes["ahead"][0] || !(a + match_index == msg.length))) {
        BullseyeRegex temp_la = regexes["ahead"][1];
        List<String> la_matches;
        bool is_match;

        if (a + match_index == msg.length) {
          la_matches = [];
          is_match = false;
        } else {
          la_matches = temp_la.allMatches(msg.substring(a + match_index));
          is_match = msg.substring(a + match_index).startsWith(la_matches[0]);
        }

        while ((match_index > 0) && !is_match) {
          match_index -= 1;
          la_matches = temp_la.allMatches(msg.substring(a + match_index));

          if (la_matches.length == 0) continue;

          is_match = msg.substring(a + match_index).startsWith(la_matches[0]);
        }

        if (regexes["ahead"][0] != is_match) continue;
      }

      matches.add(msg.substring(a, a + match_index));

      if (match_index != 0) a += match_index - 1;
    }

    return matches;
  }
}
