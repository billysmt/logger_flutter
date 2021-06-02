import 'package:flutter/material.dart';

class AnsiParser {
  static const TEXT = 0, BRACKET = 1, CODE = 2;

  final bool dark;

  AnsiParser(this.dark);

  late Color foreground = Colors.white;
  Color background = Colors.black;
  late List<TextSpan> spans;

  void parse(String s) {
    background = getColor(0);
    foreground = dark ? Colors.white : Colors.black;
    spans = [];
    var state = TEXT;
    late StringBuffer buffer;
    var text = StringBuffer();
    var code = 0;
    late List<int> codes;

    for (var i = 0, n = s.length; i < n; i++) {
      var c = s[i];

      switch (state) {
        case TEXT:
          if (c == '\u001b') {
            state = BRACKET;
            buffer = StringBuffer(c);
            code = 0;
            codes = [];
          } else {
            text.write(c);
          }
          break;

        case BRACKET:
          buffer.write(c);
          if (c == '[') {
            state = CODE;
          } else {
            state = TEXT;
            text.write(buffer);
          }
          break;

        case CODE:
          buffer.write(c);
          var codeUnit = c.codeUnitAt(0);
          if (codeUnit >= 48 && codeUnit <= 57) {
            code = code * 10 + codeUnit - 48;
            continue;
          } else if (c == ';') {
            codes.add(code);
            code = 0;
            continue;
          } else {
            if (text.isNotEmpty) {
              spans.add(createSpan(text.toString()));
              text.clear();
            }
            state = TEXT;
            if (c == 'm') {
              codes.add(code);
              handleCodes(codes);
            } else {
              text.write(buffer);
            }
          }

          break;
      }
    }
    spans.add(createSpan(text.toString()));
  }

  void handleCodes(List<int> codes) {
    if (codes.isEmpty) {
      codes.add(0);
    }

    switch (codes[0]) {
      case 0:
        foreground = getColor(0);
        background = getColor(0);
        break;
      case 38:
        foreground = getColor(codes[2]);
        break;
      case 39:
        foreground = getColor(0);
        break;
      case 48:
        background = getColor(codes[2]);
        break;
      case 49:
        background = getColor(0);
        break;
    }
  }

  Color getColor(int colorCode) {
    switch (colorCode) {
      case 0:
        return dark ? Colors.black : Colors.transparent;
      case 12:
      ///info
        return dark ? Colors.lightBlue : Colors.indigo;
      case 208:
      ///
        return dark ? Colors.orange : Colors.orange;
      case 196:
        return dark ? Colors.red : Colors.red;
      case 199:
        return dark ? Colors.pink : Colors.pink;
      default:
        return dark ? Colors.deepPurpleAccent : Colors.deepPurple;
    }
  }

  TextSpan createSpan(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: foreground,
        backgroundColor: background,
      ),
    );
  }
}
