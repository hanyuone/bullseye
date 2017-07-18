// Copyright (c) 2017, Hanyuan Li. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:bullseye/bullseye.dart';

void main() {
  NewRegex test = new NewRegex("ab*");

  print(test.allMatches("aabbaab"));
}
