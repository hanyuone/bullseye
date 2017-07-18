# bullseye ![](https://travis-ci.org/Qwerp-Derp/bullseye.svg?branch=master)

Bullseye is a new flavour of regex for Dart, because JavaScript's regex flavour sucks quite a lot.

Some things Bullseye has that JS regex doesn't:

- Lookbehinds (positive and negative)
- Variable-length lookaheads

Possible features:

- Named capturing groups
- Backtracking
- Recursion (probably not)

## Usage

A simple usage example:

    import 'package:bullseye/bullseye.dart';

    void main() {
      NewRegex dart = new NewRegex("ab*");

      print(dart.allMatches("ababbaa")); // => ["ab", "abb", "a", "a"]
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/Qwerp-Derp/bullseye
