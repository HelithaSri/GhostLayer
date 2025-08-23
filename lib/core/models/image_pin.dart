import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'image_pin.g.dart';

@HiveType(typeId: 1)
class ImagePin extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String imagePath;

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
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool isVisible;

  @HiveField(11)
  bool maintainAspectRatio;

  @HiveField(12)
  double rotation; // in radians

  ImagePin({
    required this.id,
    required this.title,
    required this.imagePath,
    this.x = 100.0,
    this.y = 100.0,
    this.width = 200.0,
    this.height = 200.0,
    this.opacity = 1.0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isVisible = true,
    this.maintainAspectRatio = true,
    this.rotation = 0.0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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

  void updateTitle(String newTitle) {
    title = newTitle;
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

  void updateRotation(double newRotation) {
    rotation = newRotation;
    updatedAt = DateTime.now();
    save();
  }

  void toggleVisibility() {
    isVisible = !isVisible;
    updatedAt = DateTime.now();
    save();
  }

  void toggleAspectRatio() {
    maintainAspectRatio = !maintainAspectRatio;
    updatedAt = DateTime.now();
    save();
  }

  ImagePin copyWith({
    String? id,
    String? title,
    String? imagePath,
    double? x,
    double? y,
    double? width,
    double? height,
    double? opacity,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
    bool? maintainAspectRatio,
    double? rotation,
  }) {
    return ImagePin(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      opacity: opacity ?? this.opacity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVisible: isVisible ?? this.isVisible,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  String toString() {
    return 'ImagePin(id: $id, title: $title, imagePath: $imagePath, position: ($x, $y), size: (${width}x$height), opacity: $opacity)';
  }
}
