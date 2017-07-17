// Copyright (c) 2017, Hanyuan Li. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:bullseye/bullseye.dart';

main() {
  NewRegex test = new NewRegex("(?<=a)a*(?!a)");

  for (int a = 0; a < test.nodes.length; a++) {
    print("${test.nodes[a].ident}, ${test.nodes[a].paths}");
  }

  print(test.allMatches("aaaaaaaaaaa"));
}
