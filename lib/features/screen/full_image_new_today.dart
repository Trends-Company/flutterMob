import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/widget_support.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../bloc/new_today/new_today_bloc.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
import '../widget/loading_img_full.dart';
import 'step_two_video.dart';

class FullImageNewToday extends StatelessWidget {
  const FullImageNewToday({super.key});

  @override
  Widget build(BuildContext context) {
    final images = context.read<NewTodayBloc>().state.images;
    final maxCount = images.isNotEmpty
        ? images.fold(0, (maxCount, image) => max(maxCount, image.countSwap))
        : 0;
    return Scaffold(
      appBar:
          AppWidget.createSimpleAppBar(context: context, title: 'New Today'),
      body: Column(
        children: [
          const AdsApplovinBanner(),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 32, top: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 3 / 4,
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isMax =
                    maxCount == images[index].countSwap && maxCount != 0;
                return AnimationClick(
                  function: () {
                    context
                        .read<SetImageSwapCubit>()
                        .setImageSwap(images[index]);
                    Navigator.of(context).pushNamed(Routes.step_two_video,
                        arguments: StepTwoVideo(
                          isSwapVideo: false,
                          images: images,
                          nameCate: 'New Today',
                        ));
                  },
                  child: Stack(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: LoadingImageFull(link: images[index].image)),
                      AppWidget.iconCount(isMax, images[index].countSwap)
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
