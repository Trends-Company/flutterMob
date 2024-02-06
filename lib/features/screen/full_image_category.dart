import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/styles.dart';
import '../../common/models/category_model.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../translations/export_lang.dart';
import '../bloc/full_image_cate/full_image_cate_bloc.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
import '../widget/loading_img_full.dart';
import 'step_two_video.dart';

class FullImageCategory extends StatefulWidget {
  const FullImageCategory({super.key, required this.categoryModel});
  final CategoryModel categoryModel;

  @override
  State<FullImageCategory> createState() => _FullImageCategoryState();
}

class _FullImageCategoryState extends State<FullImageCategory> {
  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context
          .read<FullImageCategoryBloc>()
          .add(FullImageCategoryFetched(categoryId: widget.categoryModel.id!));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context, title: widget.categoryModel.name),
      body: Column(
        children: [
          const AdsApplovinBanner(),
          Expanded(
            child: BlocBuilder<FullImageCategoryBloc, FullImageCategoryState>(
                builder: (context, state) {
              switch (state.status) {
                case FullImageCategoryStatus.initial:
                  return const Center(child: CupertinoActivityIndicator());
                case FullImageCategoryStatus.success:
                  final maxCount = state.images.isNotEmpty
                      ? state.images.fold(0,
                          (maxCount, image) => max(maxCount, image.countSwap))
                      : 0;
                  return GridView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, bottom: 24, top: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 3 / 4,
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8),
                    itemCount: state.images.length,
                    itemBuilder: (context, index) {
                      final isMax = maxCount == state.images[index].countSwap &&
                          maxCount != 0;
                      return AnimationClick(
                        function: () {
                          context
                              .read<SetImageSwapCubit>()
                              .setImageSwap(state.images[index]);
                          Navigator.of(context).pushNamed(Routes.step_two_video,
                              arguments: StepTwoVideo(
                                isSwapVideo: false,
                                categoryId: widget.categoryModel.id,
                                nameCate: widget.categoryModel.name,
                              ));
                        },
                        child: Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: LoadingImageFull(
                                    link: state.images[index].image)),
                            AppWidget.iconCount(
                                isMax, state.images[index].countSwap)
                          ],
                        ),
                      );
                    },
                  );
                case FullImageCategoryStatus.failure:
                  return Center(
                      child: Text(LocaleKeys.failedToFetch.tr(),
                          style: subhead(color: grey800)));
              }
            }),
          ),
        ],
      ),
    );
  }
}
