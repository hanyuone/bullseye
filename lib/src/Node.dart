/// A node - required for the NFA and DFA.
class Node {
  int ident;
  List paths;

  Node(int ident) {
    this.ident = ident;
    this.paths = [];
  }

  void addPath(String char, Node node) {
    this.paths.add([char, node.ident]);
  }

  void removePath(int node_ident) {
    for (int a = 0; a < this.paths.length; a++) {
      int destination = this.paths[a][1];

      if (node_ident == destination) {
        this.paths.removeAt(a);
        return;
      }
    }
  }
}
