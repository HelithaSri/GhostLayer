import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../../../lib/core/models/sticky.dart';

void main() {
  group('Sticky Model Tests', () {
    late Sticky sticky;

    setUp(() {
      sticky = Sticky(
        id: 'test-id',
        title: 'Test Note',
        content: 'Test content',
        x: 100.0,
        y: 200.0,
        width: 300.0,
        height: 400.0,
      );
    });

    test('should create sticky with default values', () {
      expect(sticky.id, equals('test-id'));
      expect(sticky.title, equals('Test Note'));
      expect(sticky.content, equals('Test content'));
      expect(sticky.x, equals(100.0));
      expect(sticky.y, equals(200.0));
      expect(sticky.width, equals(300.0));
      expect(sticky.height, equals(400.0));
      expect(sticky.opacity, equals(1.0));
      expect(sticky.isVisible, isTrue);
      expect(sticky.isMinimized, isFalse);
    });

    test('should have correct position and size getters', () {
      expect(sticky.position, equals(const Offset(100.0, 200.0)));
      expect(sticky.size, equals(const Size(300.0, 400.0)));
    });

    test('should update position correctly', () {
      const newPosition = Offset(150.0, 250.0);
      sticky.position = newPosition;
      
      expect(sticky.x, equals(150.0));
      expect(sticky.y, equals(250.0));
      expect(sticky.position, equals(newPosition));
    });

    test('should update size correctly', () {
      const newSize = Size(350.0, 450.0);
      sticky.size = newSize;
      
      expect(sticky.width, equals(350.0));
      expect(sticky.height, equals(450.0));
      expect(sticky.size, equals(newSize));
    });

    test('should clamp opacity between 0 and 1', () {
      sticky.updateOpacity(-0.5);
      expect(sticky.opacity, equals(0.0));
      
      sticky.updateOpacity(1.5);
      expect(sticky.opacity, equals(1.0));
      
      sticky.updateOpacity(0.7);
      expect(sticky.opacity, equals(0.7));
    });

    test('should toggle visibility', () {
      expect(sticky.isVisible, isTrue);
      
      sticky.toggleVisibility();
      expect(sticky.isVisible, isFalse);
      
      sticky.toggleVisibility();
      expect(sticky.isVisible, isTrue);
    });

    test('should toggle minimized state', () {
      expect(sticky.isMinimized, isFalse);
      
      sticky.toggleMinimized();
      expect(sticky.isMinimized, isTrue);
      
      sticky.toggleMinimized();
      expect(sticky.isMinimized, isFalse);
    });

    test('should update content and timestamps', () {
      final originalUpdatedAt = sticky.updatedAt;
      
      // Wait a bit to ensure timestamp difference
      Future.delayed(const Duration(milliseconds: 1), () {
        sticky.updateContent('New Title', 'New Content');
        
        expect(sticky.title, equals('New Title'));
        expect(sticky.content, equals('New Content'));
        expect(sticky.updatedAt.isAfter(originalUpdatedAt), isTrue);
      });
    });

    test('should create copy with modified values', () {
      final copy = sticky.copyWith(
        title: 'Modified Title',
        x: 500.0,
        opacity: 0.5,
      );
      
      expect(copy.title, equals('Modified Title'));
      expect(copy.x, equals(500.0));
      expect(copy.opacity, equals(0.5));
      
      // Unchanged values should remain the same
      expect(copy.content, equals(sticky.content));
      expect(copy.y, equals(sticky.y));
      expect(copy.width, equals(sticky.width));
    });

    test('should handle color conversion correctly', () {
      const testColor = Color(0xFFFF5722);
      sticky.color = testColor;
      
      expect(sticky.colorValue, equals(testColor.value));
      expect(sticky.color, equals(testColor));
    });

    test('should have meaningful toString representation', () {
      final stringRepresentation = sticky.toString();
      
      expect(stringRepresentation, contains('test-id'));
      expect(stringRepresentation, contains('Test Note'));
      expect(stringRepresentation, contains('100'));
      expect(stringRepresentation, contains('200'));
    });
  });
}
