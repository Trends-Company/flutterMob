import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/layer.dart';

class BackgroundLayerCustom extends StatefulWidget {
  const BackgroundLayerCustom({
    super.key,
    required this.layerData,
    this.onUpdate,
  });
  final BackgroundLayerData layerData;
  final VoidCallback? onUpdate;

  @override
  State<BackgroundLayerCustom> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<BackgroundLayerCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.layerData.file.width.toDouble(),
      height: widget.layerData.file.height.toDouble(),
      padding: EdgeInsets.zero,
      child: Image.memory(
        widget.layerData.file.image,
        fit: BoxFit.cover,
      ),
    );
  }
}
