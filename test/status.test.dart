import 'dart:convert';

import 'package:test/test.dart';
import 'package:uppo/player_metadata.dart';
import 'package:uppo/uppo/status.dart';

void main() {
  group("StatusMaster", () {
    var players = {
      "cow": PlayerMetadata(name: "Moo", id: "cow"),
      "abc": PlayerMetadata(name: "Abe", id: "abc")
    };
    test('should do what I wanted', () {
      StatusEntry se;

      se = StatusEntry(Status.TURN, "abc", "abc", players);
      expect(se.toStringWithContext(), equals("It's your turn"));

      se = StatusEntry(Status.TURN, "cow", "abc", players);
      expect(se.toStringWithContext(), equals("Moo's turn"));

      se = StatusEntry(Status.MUST_DRAW, "abc", "abc", players, bundle: {"count": 3});
      expect(se.toStringWithContext(),
          equals("You must draw 3 cards"));

      se = StatusEntry(Status.MUST_DRAW, "cow", "abc", players, bundle: {"count": 3});
      expect(se.toStringWithContext(),
          equals("Moo must draw 3 cards"));

      se = StatusEntry(Status.WILD_PICK, "abc", "abc", players);
      expect(se.toStringWithContext(), equals("Pick a color"));

      se = StatusEntry(Status.WILD_PICK, "cow", "abc", players);
      expect(se.toStringWithContext(),
          equals("Moo is picking a color"));
    });
  });
}
