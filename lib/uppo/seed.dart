import 'dart:math' as math;

math.Random Seed(String string) {
  int numericSeed = 0;
  for (var c in string.split("")) {
    numericSeed += c.codeUnitAt(0);
  }
  return math.Random(numericSeed);
}
