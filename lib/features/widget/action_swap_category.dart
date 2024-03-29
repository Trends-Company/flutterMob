import 'package:flutter/material.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/images.dart';
import '../../common/models/request_model.dart';
import '../../common/route/routes.dart';
import '../screen/edit_image.dart';
import '../screen/result_edit_image.dart';
import 'list_photo.dart';
import 'remove_bg_image_device.dart';

class ActionSwapCategory extends StatelessWidget {
  const ActionSwapCategory({super.key});

  void showRemoveBg(BuildContext context, String path) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: grey200,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext ctx) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: RemoveBGImageDevice(path: path, ctx: context),
        );
      },
    );
  }

  Future<void> setPhoto(BuildContext context, bool removeBg) async {
    await showModalBottomSheet<Map<String, dynamic>>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: grey200,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: const ListPhoto(
              cropImage: false,
            ));
      },
      context: context,
    ).then((value) async {
      if (value != null) {
        if (removeBg) {
          showRemoveBg(context, value['path']);
        } else {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleImageEditor(image: value['bytes']),
            ),
          );
          if (res != null) {
            final request = res['request'] as RequestModel;
            Navigator.of(context).pushNamed(Routes.result_edit_image,
                arguments: ResultEditImage(
                    imageEdit: request.imageRes, requestId: request.id!));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();

  }
}
