// Copyright (c) 2017, Hanyuan Li. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:bullseye/bullseye.dart';
import 'package:test/test.dart';

bool listEquals(List a, List b) {
  if (a.length != b.length)
    return false;

  for (int c = 0; c < a.length; c++) {
    if (a[c] != b[c])
      return false;
  }

  return true;
}

void main() {
  group("Quantifier tests", () {
    BullseyeRegex quant_test;

    setUp(() {
      quant_test = new BullseyeRegex("ab*");
    });

    test("Positive", () {
      assert(listEquals(quant_test.allMatches("abbbbbb"), ["abbbbbb"]));
      assert(listEquals(quant_test.allMatches("aabbaab"), ["a", "abb", "a", "ab"]));
      assert(listEquals(quant_test.allMatches("cabbeeg"), ["abb"]));
    });

    test("Negative", () {
      assert(listEquals(quant_test.allMatches("ccccdde"), []));
      assert(listEquals(quant_test.allMatches("bbbbbbb"), []));
    });
  });

  group("Group tests", () {
    BullseyeRegex group_test;

    setUp(() {
      group_test = new BullseyeRegex("(ab)+c");
    });

    test("Positive", () {
      assert(listEquals(group_test.allMatches("ababababc"), ["ababababc"]));
      assert(listEquals(group_test.allMatches("dddabacababc"), ["ababc"]));
      assert(listEquals(group_test.allMatches("bbababcabccab"), ["ababc", "abc"]));
    });

    test("Negative", () {
      assert(listEquals(group_test.allMatches("cccccbabbdddqqabbc"), []));
      assert(listEquals(group_test.allMatches("bbbbc"), []));
    });
  });

  group("Range tests", () {
    BullseyeRegex range_test;

    setUp(() {
      range_test = new BullseyeRegex("[a-g]+h");
    });

    test("Positive", () {
      assert(listEquals(range_test.allMatches("aaaaaagbbdh"), ["aaaaaagbbdh"]));
      assert(listEquals(range_test.allMatches("ahqqqqcndaabeh"), ["ah", "daabeh"]));
    });
  });
}
