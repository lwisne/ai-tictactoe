import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/extensions/game_mode_ui_extensions.dart';

void main() {
  group('GameModeUI Extension', () {
    group('displayName', () {
      test('should return "Play vs AI" for vsAi mode', () {
        expect(GameMode.vsAi.displayName, 'Play vs AI');
      });

      test('should return "Two Player" for twoPlayer mode', () {
        expect(GameMode.twoPlayer.displayName, 'Two Player');
      });
    });

    group('subtitle', () {
      test('should return "Challenge the AI" for vsAi mode', () {
        expect(GameMode.vsAi.subtitle, 'Challenge the AI');
      });

      test('should return "Pass & Play on this device" for twoPlayer mode', () {
        expect(GameMode.twoPlayer.subtitle, 'Pass & Play on this device');
      });
    });

    group('icon', () {
      test('should return Icons.smart_toy for vsAi mode', () {
        expect(GameMode.vsAi.icon, Icons.smart_toy);
      });

      test('should return Icons.people for twoPlayer mode', () {
        expect(GameMode.twoPlayer.icon, Icons.people);
      });
    });

    group('all modes', () {
      test('should provide UI properties for all GameMode values', () {
        for (final mode in GameMode.values) {
          // Should not throw and should return non-empty strings
          expect(mode.displayName, isNotEmpty);
          expect(mode.subtitle, isNotEmpty);
          expect(mode.icon, isA<IconData>());
        }
      });
    });
  });
}
