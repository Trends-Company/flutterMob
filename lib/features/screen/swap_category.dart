import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/models/category_model.dart';
import '../../common/models/image_category_model.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_native_applovin_medium.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../translations/export_lang.dart';
import '../bloc/full_image_cate/full_image_cate_bloc.dart';
import '../bloc/list_categories/list_categories_bloc.dart';
import '../bloc/new_today/new_today_bloc.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
import '../bloc/trending/trending_bloc.dart';
import '../widget/action_swap_category.dart';
import '../widget/gift_widget.dart';
import '../widget/loading_img_category.dart';
import '../widget/token_widget.dart';
import 'full_image_category.dart';
import 'step_two_video.dart';

class SwapCategory extends StatefulWidget {
  const SwapCategory({super.key});

  @override
  State<SwapCategory> createState() => _SwapCategoryState();
}

class _SwapCategoryState extends State<SwapCategory>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context.read<ListCategoriesBloc>().add(ListCategoriesFetched());
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

  Widget category(
      int indexCategory, double height, CategoryModel categoryModel) {
    final maxCount = categoryModel.images.isNotEmpty
        ? categoryModel.images
            .fold(0, (maxCount, image) => max(maxCount, image.countSwap))
        : 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(categoryModel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: title4(color: grey700))),
              AnimationClick(
                function: () {
                  context
                      .read<FullImageCategoryBloc>()
                      .add(ResetFullImageCategory());
                  context.read<FullImageCategoryBloc>().add(
                      FullImageCategoryFetched(categoryId: categoryModel.id!));
                  Navigator.of(context).pushNamed(Routes.full_image_category,
                      arguments:
                          FullImageCategory(categoryModel: categoryModel));
                },
                child: Text(LocaleKeys.seeAll.tr(),
                    style: headline(color: grey700)),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 240,
            child: categoryModel.images.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemBuilder: (context, index) {
                      final isMax =
                          maxCount == categoryModel.images[index].countSwap &&
                              maxCount != 0;
                      return AnimationClick(
                        function: () {
                          context
                              .read<FullImageCategoryBloc>()
                              .add(ResetFullImageCategory());
                          context.read<FullImageCategoryBloc>().add(
                              FullImageCategoryFetched(
                                  categoryId: categoryModel.id!));
                          context
                              .read<SetImageSwapCubit>()
                              .setImageSwap(categoryModel.images[index]);
                          Navigator.of(context).pushNamed(Routes.step_two_video,
                              arguments: StepTwoVideo(
                                isSwapVideo: false,
                                categoryId: categoryModel.id,
                                nameCate: categoryModel.name,
                              ));
                        },
                        child: Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: LoadingImageCategory(
                                    link: categoryModel.images[index].image)),
                            AppWidget.iconCount(
                                isMax, categoryModel.images[index].countSwap)
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemCount: categoryModel.images.length)
                : Center(
                    child: Text(
                      LocaleKeys.weWillUpdate.tr(),
                      style: subhead(color: grey800),
                    ),
                  ),
          ),
        )
      ],
    );
  }

  Widget newToday(
      double height, bool isNewToday, List<ImageCategoryModel> images) {
    final maxCount = images.isNotEmpty
        ? images.fold(0, (maxCount, image) => max(maxCount, image.countSwap))
        : 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(isNewToday ? 'New Today' : 'Trending',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: title4(color: grey700))),
              AnimationClick(
                function: () {
                  Navigator.of(context).pushNamed(isNewToday
                      ? Routes.full_image_new_today
                      : Routes.full_image_trending);
                },
                child: Text(LocaleKeys.seeAll.tr(),
                    style: headline(color: grey700)),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 240,
            child: images.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                nameCate: isNewToday ? 'New Today' : 'Trending',
                              ));
                        },
                        child: Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: LoadingImageCategory(
                                    link: images[index].image)),
                            AppWidget.iconCount(isMax, images[index].countSwap)
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemCount: images.length > IMAGE_SHOW_LIMIT
                        ? IMAGE_SHOW_LIMIT
                        : images.length)
                : Center(
                    child: Text(
                      LocaleKeys.weWillUpdate.tr(),
                      style: subhead(color: grey800),
                    ),
                  ),
          ),
        )
      ],
    );
  }

  Widget listCategory(double height) {
    return BlocBuilder<ListCategoriesBloc, ListCategoriesState>(
      builder: (context, state) {
        switch (state.status) {
          case ListCategoriesStatus.failure:
            return Center(
                child: Text(LocaleKeys.failedToFetch.tr(),
                    style: subhead(color: grey800)));
          case ListCategoriesStatus.success:
            if (state.categories.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(LocaleKeys.noCategoriesFound.tr(),
                      style: subhead(color: grey800)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: AdsNativeApplovinMedium(),
                  )
                ],
              ));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return index >= state.categories.length
                    ? const Center(child: CupertinoActivityIndicator())
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: category(index, height, state.categories[index]),
                      );
              },
              itemCount: state.hasReachedMax
                  ? state.categories.length
                  : state.categories.length + 1,
            );
          case ListCategoriesStatus.initial:
            return const Center(child: CupertinoActivityIndicator());
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //checkHasAds();
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
    super.build(context);
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(
              height: height / 2,
              decoration:
                  BoxDecoration(gradient: Theme.of(context).colorLinearBottom4),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBarCpn(
                  left: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: AnimationClick(
                      function: () {
                        Navigator.of(context).pushNamed(Routes.menu);
                      },
                      child: Image.asset(
                        circles_four,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  right: const TokenWidget(),
                ),
                floatingActionButton: const GiftWidget(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniEndFloat,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ActionSwapCategory(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => Future.sync(
                          () {
                            context
                                .read<ListCategoriesBloc>()
                                .add(ResetListCategories());
                            context.read<NewTodayBloc>().add(ResetNewToday());
                            context.read<TrendingBloc>().add(ResetTrending());
                            context
                                .read<ListCategoriesBloc>()
                                .add(ListCategoriesFetched());
                            context.read<NewTodayBloc>().add(NewTodayFetched());
                            context.read<TrendingBloc>().add(TrendingFetched());
                          },
                        ),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              BlocBuilder<NewTodayBloc, NewTodayState>(
                                  builder: (context, state) {
                                switch (state.status) {
                                  case NewTodayStatus.success:
                                    return newToday(height, true, state.images);
                                  default:
                                    return const SizedBox();
                                }
                              }),
                              const SizedBox(height: 16),
                              BlocBuilder<TrendingBloc, TrendingState>(
                                  builder: (context, state) {
                                switch (state.status) {
                                  case TrendingStatus.success:
                                    return newToday(
                                        height, false, state.images);
                                  default:
                                    return const SizedBox();
                                }
                              }),
                              const SizedBox(height: 16),
                              listCategory(height),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
