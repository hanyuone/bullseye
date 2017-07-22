// Copyright (c) 2017, Hanyuan Li. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "Node.dart";
import "NFA.dart";
import "Methods.dart";

String EPSILON = "";

/// A deterministic finite automaton.
/// 
/// A more efficient version of finite automaton, converted
/// from a non-deterministic FA.
class DFA {
  List<Node> nodes;
  int ending_ident;
  List<int> ending_nodes;

  List _movements(List<Node> nodes) {
    List moves = [];

    for (int a = 0; a < nodes.length; a++) {
      List move_paths =
          nodes[a].paths.where((path) => path[0] != EPSILON).toList();

      moves.addAll(move_paths);
    }

    return moves;
  }

  List<int> _epsilonClosure(Node starting_node) {
    Set<int> accessible = new Set();

    for (List path in starting_node.paths) {
      if (path[0] == EPSILON)
        accessible.add(path[1]);
    }

    Set<int> new_elements = new Set();

    for (int a in accessible) {
      new_elements.addAll(this._epsilonClosure(this.nodes[a]));
      new_elements = new_elements.where((n) => !accessible.contains(n)).toSet();
    }

    accessible.addAll(new_elements);
    List<int> accessible_ls = accessible.toList();
    accessible_ls.insert(0, starting_node.ident);

    return accessible_ls;
  }

  void _toDeterministic() {
    List<List<int>> new_nodes = [
      [0]
    ];
    List<List> node_paths = [];
    Set<int> used_nodes = new Set();

    while (used_nodes.length < this.nodes.length ||
        new_nodes.length > node_paths.length) {
      Set<int> connected_nodes = new Set();

      for (int a = node_paths.length; a < new_nodes.length; a++) {
        List<int> starting_node =
            this._epsilonClosure(this.nodes[new_nodes[a][0]]);
        List connections =
            this._movements(starting_node.map((n) => this.nodes[n]).toList());

        new_nodes[a] = starting_node;
        node_paths.add(connections);
        used_nodes.addAll(starting_node);
        connected_nodes.addAll(connections.map((n) => n[1]));
      }

      List<int> first_items = new_nodes.map((ls) => ls[0]).toList();
      connected_nodes =
          connected_nodes.where((n) => !first_items.contains(n)).toSet();

      new_nodes.addAll(connected_nodes.map((n) => [n]));
    }

    List<Node> actual_nodes = [];

    for (int a = 0; a < new_nodes.length; a++) {
      List paths = node_paths[a];
      Node temp_node = new Node(new_nodes[a][0]);

      for (int b = 0; b < paths.length; b++) {
        temp_node.addPath(paths[b][0], this.nodes[paths[b][1]]);
      }

      actual_nodes.add(temp_node);

      if (new_nodes[a].contains(this.ending_ident)) {
        this.ending_nodes.add(new_nodes[a][0]);
      }
    }

    this.nodes = actual_nodes;
  }

  DFA(List tokenised) {
    NFA nfa = new NFA(tokenised);
    this.nodes = nfa.nodes;
    this.ending_ident = nfa.ending_node;

    this.ending_nodes = [];

    this._toDeterministic();
  }
}

void main() {
  DFA test = new DFA(tokeniseRegex("a*"));

  for (int a = 0; a < test.nodes.length; a++)
    print("${test.nodes[a].ident}, ${test.nodes[a].paths}");

  print(test.ending_nodes);
}
