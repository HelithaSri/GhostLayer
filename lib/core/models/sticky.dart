import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'sticky.g.dart';

@HiveType(typeId: 0)
class Sticky extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  double x;

  @HiveField(4)
  double y;

  @HiveField(5)
  double width;

  @HiveField(6)
  double height;

  @HiveField(7)
  double opacity;

  @HiveField(8)
  int colorValue;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  bool isVisible;

  @HiveField(12)
  bool isMinimized;

  Sticky({
    required this.id,
    required this.title,
    required this.content,
    this.x = 100.0,
    this.y = 100.0,
    this.width = 300.0,
    this.height = 200.0,
    this.opacity = 1.0,
    this.colorValue = 0xFFFFF3E0, // Amber 50
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isVisible = true,
    this.isMinimized = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Color get color => Color(colorValue);
  
  set color(Color newColor) {
    colorValue = newColor.value;
  }

  Offset get position => Offset(x, y);
  
  set position(Offset newPosition) {
    x = newPosition.dx;
    y = newPosition.dy;
  }

  Size get size => Size(width, height);
  
  set size(Size newSize) {
    width = newSize.width;
    height = newSize.height;
  }

  void updateContent(String newTitle, String newContent) {
    title = newTitle;
    content = newContent;
    updatedAt = DateTime.now();
    save();
  }

  void updatePosition(Offset newPosition) {
    position = newPosition;
    updatedAt = DateTime.now();
    save();
  }

  void updateSize(Size newSize) {
    size = newSize;
    updatedAt = DateTime.now();
    save();
  }

  void updateOpacity(double newOpacity) {
    opacity = newOpacity.clamp(0.0, 1.0);
    updatedAt = DateTime.now();
    save();
  }

  void toggleVisibility() {
    isVisible = !isVisible;
    updatedAt = DateTime.now();
    save();
  }

  void toggleMinimized() {
    isMinimized = !isMinimized;
    updatedAt = DateTime.now();
    save();
  }

  Sticky copyWith({
    String? id,
    String? title,
    String? content,
    double? x,
    double? y,
    double? width,
    double? height,
    double? opacity,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
    bool? isMinimized,
  }) {
    return Sticky(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      opacity: opacity ?? this.opacity,
      colorValue: color?.value ?? colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVisible: isVisible ?? this.isVisible,
      isMinimized: isMinimized ?? this.isMinimized,
    );
  }

  @override
  String toString() {
    return 'Sticky(id: $id, title: $title, position: ($x, $y), size: (${width}x$height), opacity: $opacity)';
  }
}
