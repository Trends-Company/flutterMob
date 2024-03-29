import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class GenerateImageEvent extends Equatable {
  const GenerateImageEvent();
}

class InitialGenerateImage extends GenerateImageEvent {
  const InitialGenerateImage(
      {required this.context,
        required this.srcPath,
        required this.dstPath,
        this.handleToken = true,
        this.isHD = true,
        this.isRmWater = true});
  final BuildContext context;
  final String srcPath;
  final String dstPath;
  final bool handleToken;
  final bool isHD;
  final bool isRmWater;
  @override
  List<Object> get props =>
      [context, srcPath, dstPath, handleToken, isHD, isRmWater];
}

class EditGenerateImage extends GenerateImageEvent {
  const EditGenerateImage(
      {required this.result, required this.url, required this.requestId});
  final Uint8List result;
  final String url;
  final int requestId;
  @override
  List<Object> get props => [result, url, requestId];
}
