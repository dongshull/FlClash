import 'package:flutter/material.dart';

@immutable
class FileInfo {
  final String size;
  final DateTime lastModified;

  const FileInfo({
    required this.size,
    required this.lastModified,
  });
}