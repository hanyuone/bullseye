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
    NewRegex quant_test;

    setUp(() {
      quant_test = new NewRegex("ab*");
    });

    test("Positive", () {
      assert(listEquals(quant_test.allMatches("abbbbbb"), ["abbbbbb"]));
      assert(listEquals(quant_test.allMatches("aabbaab"), ["a", "abb", "a", "ab"]));
      assert(listEquals(quant_test.allMatches("cabbeeg"), ["abb"]));
    });

    test("Negative", () {
      assert(listEquals(quant_test.allMatches("ccccdde"), []));
    });
  });

  group("Group tests", () {
    NewRegex group_test;

    setUp(() {

    });

    test("Positive", () {

    });
  });
}
