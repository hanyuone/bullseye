// Copyright (c) 2017, Hanyuan Li. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:bullseye/bullseye.dart';
import "dart:convert";

void main() {
  BullseyeRegex test = new BullseyeRegex("(?<=a)b*");

  print(JSON.encode(test.allMatches("aabbaab")));
}
