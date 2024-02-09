import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//import 'package:video_player/video_player.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/recent_face/bloc_recent_face.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/models/image_category_model.dart';
import '../../common/models/recent_face_model.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/animation_long_press.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../common/widget/open_slot.dart';
import '../../translations/export_lang.dart';
import '../bloc/full_image_cate/full_image_cate_bloc.dart';
import '../bloc/generate_image/bloc_generate_image.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
//import '../bloc/swap_video/bloc_swap_video.dart';
import '../widget/gift_widget.dart';
import '../widget/loading_face.dart';
import '../widget/loading_image.dart';
import '../widget/not_enough_token.dart';
import '../widget/recent_face_video.dart';
import '../widget/token_remain.dart';
import 'step_three.dart';
//import 'step_three_video.dart';

class StepTwoVideo extends StatefulWidget {
  const StepTwoVideo(
      {super.key,
      this.isSwapVideo = true,
      this.pathSource,
      this.nameCate,
      this.categoryId,
      this.images});
  final String? pathSource;
  final bool isSwapVideo;
  final int? categoryId;
  final String? nameCate;
  final List<ImageCategoryModel>? images;
  @override
  State<StepTwoVideo> createState() => _StepTwoVideoState();
}

class _StepTwoVideoState extends State<StepTwoVideo> {
  Uint8List? yourFace;
  String? pathLocal;
  String? pathPublic;
  bool handlingFace = false;
  bool showDelete = false;
  bool isHD = true;
  bool isRmWater = true;
  //VideoPlayerController? videoCtl;
  PageController? pageCtl;
  late int tokensLostVideo;
  late int tokensLostImage;

  void _onScroll() {
    if (_isBottom) {
      context
          .read<FullImageCategoryBloc>()
          .add(FullImageCategoryFetched(categoryId: widget.categoryId!));
    }
  }

  bool get _isBottom {
    if (!pageCtl!.hasClients) {
      return false;
    }
    final maxScroll = pageCtl!.position.maxScrollExtent;
    final currentScroll = pageCtl!.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> updateTokenUser(int reward) async {
    final UserBloc userBloc = context.read<UserBloc>();
    userBloc.add(UpdateTokenUser(userBloc.userModel!.token + reward));
  }

  Future<void> setPhoto() async {
    await showModalBottomSheet<Map<String, dynamic>>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: grey100,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const RecentFaceVideo(cropImage: true);
      },
      context: context,
    ).then((dynamic value) async {
      if (value != null) {
        setState(() {
          yourFace = value['bytes'];
          pathLocal = value['path'];
          pathPublic = null;
        });
      }
    });
  }

  // Future<void> handleSwapVideo() async {
  //   context.read<SwapVideoBloc>().add(const ResetSwapVideo());
  //   if (pathLocal != null) {
  //     uploadFace(context, yourFace!);
  //     context.read<SwapVideoBloc>().add(InitialSwapVideo(
  //         context: context,
  //         srcPath: widget.pathSource!,
  //         dstPath: pathLocal!,
  //         handleToken: true,
  //         isHD: isHD,
  //         isRmWater: isRmWater));
  //     Navigator.of(context).pushNamed(Routes.step_three_video,
  //         arguments:
  //             StepThreeVideo(dstPath: pathLocal!, srcPath: widget.pathSource!));
  //   } else {
  //     final res = await getImage(pathPublic!);
  //     final file = await createFileUploadDO(res);
  //     context.read<SwapVideoBloc>().add(InitialSwapVideo(
  //         context: context,
  //         srcPath: widget.pathSource!,
  //         dstPath: file.path,
  //         handleToken: true,
  //         isHD: isHD,
  //         isRmWater: isRmWater));
  //     Navigator.of(context).pushNamed(Routes.step_three_video,
  //         arguments:
  //             StepThreeVideo(dstPath: file.path, srcPath: widget.pathSource!));
  //   }
  // }

  Future<void> handleSwapImage() async {
    final imageSwapTmp =
        await getImage(context.read<SetImageSwapCubit>().state!.image);
    final tempDirImageSwap = await Directory.systemTemp.createTemp();
    final tempFileImageSwap = File(
        '${tempDirImageSwap.path}/${DateTime.now().toIso8601String()}.jpg');
    await tempFileImageSwap.writeAsBytes(imageSwapTmp);

    if (pathLocal != null) {
      uploadFace(context, yourFace!);
      context.read<GenerateImageBloc>().add(InitialGenerateImage(
          context: context,
          srcPath: tempFileImageSwap.path,
          dstPath: pathLocal!,
          handleToken: true,
          isHD: isHD,
          isRmWater: isRmWater));
      context.read<SetImageSwapCubit>().reset();
      context
          .read<RemoveBGImageBloc>()
          .add(const ResetRemoveBGImage(hasLoaded: true));
      Navigator.of(context).pushNamed(Routes.step_three,
          arguments: StepThree(
              srcImage: imageSwapTmp,
              dstImage: yourFace!,
              dstPath: pathLocal!,
              srcPath: tempFileImageSwap.path));
    } else {
      final res = await getImage(pathPublic!);
      final file = await createFileUploadDO(res);
      context.read<GenerateImageBloc>().add(InitialGenerateImage(
          context: context,
          srcPath: tempFileImageSwap.path,
          dstPath: file.path,
          handleToken: true,
          isHD: isHD,
          isRmWater: isRmWater));
      context
          .read<RemoveBGImageBloc>()
          .add(const ResetRemoveBGImage(hasLoaded: true));
      Navigator.of(context).pushNamed(Routes.step_three,
          arguments: StepThree(
              srcImage: imageSwapTmp,
              dstImage: res,
              dstPath: file.path,
              srcPath: tempFileImageSwap.path));
    }
  }

  Widget itemRecent(int index, RecentFaceModel recentFaceModel) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        AnimationLongPress(
          function: () {
            setState(() {
              showDelete = !showDelete;
            });
          },
          onTap: () async {
            setState(() {
              pathPublic = recentFaceModel.face;
              pathLocal = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
            margin: const EdgeInsets.only(bottom: 8),
            child: LoadingFace(
              link: recentFaceModel.face,
              radius: 32,
            ),
          ),
        ),
        showDelete
            ? Positioned(
                right: -8,
                top: 6,
                child: AnimationClick(
                  function: () {
                    context.read<RecentFaceBloc>().add(
                        DeleteFace(recentFaceModel.id!, recentFaceModel.face));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: grey300),
                    child: Image.asset(
                      icClose,
                      width: 16,
                      height: 16,
                      color: grey1100,
                    ),
                  ),
                ))
            : const SizedBox()
      ],
    );
  }

  Widget recentWidget() {
    final recentsCount =
        context.watch<UserBloc>().userModel?.slotRecentFace ?? DEFAULT_SLOT;
    return TapRegion(
      onTapOutside: (tap) {
        setState(() {
          showDelete = false;
        });
      },
      child: BlocBuilder<RecentFaceBloc, RecentFaceState>(
          builder: (context, state) {
        if (state is RecentFaceLoaded) {
          final List<RecentFaceModel> recentFaces = state.recentFaces;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.only(right: 24),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: recentFaces.length >= recentsCount
                ? recentsCount + 1
                : recentsCount,
            itemBuilder: (context, index) {
              return index >= recentsCount
                  ? AnimationClick(
                      function: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const OpenSlot();
                          },
                        );
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: grey200,
                            border: Border.all(color: grey600),
                            borderRadius: BorderRadius.circular(32)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Image.asset(
                          lock,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : index > recentFaces.length - 1
                      ? Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          decoration: BoxDecoration(
                              color: grey200,
                              border: Border.all(color: grey600),
                              borderRadius: BorderRadius.circular(32)),
                        )
                      : itemRecent(index, recentFaces[index]);
            },
          );
        }
        return const Center(child: CupertinoActivityIndicator());
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    if (context.read<RecentFaceBloc>().recentFaces.isNotEmpty) {
      pathPublic = context.read<RecentFaceBloc>().recentFaces[0].face;
    }

   // if (widget.isSwapVideo) {
      // AdLovinUtils().initializeInterstitialAds2(() {});
      // tokensLostVideo = TOKEN_SWAP_VIDEO + TOKEN_EXPORT_HD + TOKEN_REM_MARK;
      // videoCtl = VideoPlayerController.file(File(widget.pathSource!))
      //   ..initialize().then((value) {
      //     setState(() {});
      //   })
      //   ..play();
   // } else {
    //  checkHasAds();
      tokensLostImage = TOKEN_SWAP + TOKEN_EXPORT_HD + TOKEN_REM_MARK;
      if (widget.images != null) {
        final int page =
            widget.images!.indexOf(context.read<SetImageSwapCubit>().state!);
        pageCtl = PageController(viewportFraction: 0.9, initialPage: page);
      }
   // }
  }

  @override
  void dispose() {
   // videoCtl?.dispose();
    if (!widget.isSwapVideo && widget.images == null)
      pageCtl!
        ..removeListener(_onScroll)
        ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    final check = pathPublic != null || pathLocal != null;
    return Scaffold(
      appBar: AppBarCpn(
        left: AnimationClick(
          function: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Image.asset(
              icArrowLeft,
              width: 24,
              height: 24,
              color: grey1100,
            ),
          ),
        ),
        center: widget.isSwapVideo
            ? const SizedBox()
            : Text(widget.nameCate!, style: headline(color: grey1100)),
      ),
      floatingActionButton: const GiftWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              AnimationClick(
                function: setPhoto,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48), color: grey300),
                  padding: const EdgeInsets.all(19),
                  margin: const EdgeInsets.only(left: 24, right: 16),
                  child: const Icon(
                    Icons.add,
                    size: 28,
                    color: grey1100,
                  ),
                ),
              ),
              if (pathPublic != null)
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: grey1100, width: 2)),
                  child: LoadingFace(
                    link: pathPublic!,
                    radius: 32,
                  ),
                ),
              if (pathLocal != null)
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: grey1100, width: 2)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.memory(
                      yourFace!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              pathPublic != null || pathLocal != null
                  ? Container(
                      width: 1,
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: grey300))
                  : const SizedBox(),
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: recentWidget(),
                ),
              ),
            ],
          ),
          /*Padding(
            padding: const EdgeInsets.only(left: 12, right: 24, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        checkColor: grey100.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusColor: corn1,
                        activeColor: corn1,
                        value: isHD,
                        onChanged: (bool? value) {
                          isHD = !isHD;
                          if (isHD) {
                            if (widget.isSwapVideo)
                              tokensLostVideo += TOKEN_EXPORT_HD;
                            else
                              tokensLostImage += TOKEN_EXPORT_HD;
                          } else {
                            if (widget.isSwapVideo)
                              tokensLostVideo -= TOKEN_EXPORT_HD;
                            else
                              tokensLostImage -= TOKEN_EXPORT_HD;
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    Text(LocaleKeys.hdExport.tr(),
                        style: body(color: grey1100)),
                  ],
                ),
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        checkColor: grey100.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusColor: corn1,
                        activeColor: corn1,
                        value: isRmWater,
                        onChanged: (bool? value) {
                          isRmWater = !isRmWater;
                          if (isRmWater) {
                            if (widget.isSwapVideo)
                              tokensLostVideo += TOKEN_REM_MARK;
                            else
                              tokensLostImage += TOKEN_REM_MARK;
                          } else {
                            if (widget.isSwapVideo)
                              tokensLostVideo -= TOKEN_REM_MARK;
                            else
                              tokensLostImage -= TOKEN_REM_MARK;
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    Text(LocaleKeys.removeWater.tr(),
                        style: body(color: grey1100)),
                  ],
                )
              ],
            ),
          ),*/
          Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
            child: AppWidget.typeButtonStartAction(
                context: context,
                input: widget.isSwapVideo
                    ? '${LocaleKeys.makeVideoNow.tr()} -$tokensLostVideo'
                    : '${LocaleKeys.generate.tr()} -$tokensLostImage',
                bgColor: check ? primary : grey300,
                textColor: check ? grey1100 : grey600,
                borderColor: check ? primary : grey300,
                icon: token2,
                colorAsset: check ? null : grey600,
                borderRadius: 12,
                onPressed: check
                    ? () async {
                        final userModel = context.read<UserBloc>().userModel!;
                        // if (widget.isSwapVideo) {
                        //   if (userModel.token >= tokensLostVideo) {
                        //     showInterApplovin(context, () {}, seconds: 5);
                        //     EasyLoading.show();
                        //     await handleSwapVideo();
                        //     EasyLoading.dismiss();
                        //   } else {
                        //     showDialog<void>(
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return const NotEnoughToken();
                        //       },
                        //     );
                        //   }
                        // } else {
                          if (userModel.token >= tokensLostImage) {
                            //showInterApplovin(context, () {}, seconds: 5);
                            EasyLoading.show();
                            await handleSwapImage();
                            EasyLoading.dismiss();
                          } else {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return const NotEnoughToken();
                              },
                            );
                          }
                        //}
                      }
                    : () {
                        BotToast.showText(
                            text: LocaleKeys.youNeedChooseYourFace.tr(),
                            textStyle: body(color: grey1100));
                      }),
          ),
          const TokenRemain(),
          const SizedBox(height: 16),
          const AdsApplovinBanner(),
          const SizedBox(height: 16),
        ],
      ),
      body: Center(
        child:
        // widget.isSwapVideo
        //     ? Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 24),
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(16),
        //           child: ConstrainedBox(
        //             constraints: BoxConstraints(
        //               minHeight: 200,
        //               maxHeight: height / 2,
        //             ),
        //             child: AspectRatio(
        //               aspectRatio: videoCtl!.value.aspectRatio,
        //               child: ClipRRect(
        //                   borderRadius: BorderRadius.circular(16),
        //                   child: VideoPlayer(videoCtl!)),
        //             ),
        //           ),
        //         ),
        //       )
            widget.images == null
                ? BlocBuilder<FullImageCategoryBloc, FullImageCategoryState>(
                    builder: (context, state) {
                    switch (state.status) {
                      case FullImageCategoryStatus.initial:
                        return const Center(
                            child: CupertinoActivityIndicator());
                      case FullImageCategoryStatus.success:
                        final int page = state.images
                            .indexOf(context.read<SetImageSwapCubit>().state!);
                        pageCtl = PageController(
                            viewportFraction: 0.9, initialPage: page);
                        pageCtl!.addListener(_onScroll);
                        return PageView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: pageCtl,
                          onPageChanged: (value) {
                            if (value == state.images.length) {
                              return;
                            }
                            context
                                .read<SetImageSwapCubit>()
                                .setImageSwap(state.images[value]);
                          },
                          itemBuilder: (context, index) {
                            return index == state.images.length
                                ? const Center(
                                    child: CupertinoActivityIndicator())
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: LoadingImage(
                                        link: state.images[index].image),
                                  );
                          },
                          itemCount: state.hasReachedMax
                              ? state.images.length
                              : state.images.length + 1,
                        );
                      case FullImageCategoryStatus.failure:
                        return Center(
                            child: Text(LocaleKeys.failedToFetch.tr(),
                                style: subhead(color: grey800)));
                    }
                  })
                : PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: pageCtl,
                    onPageChanged: (value) {
                      context
                          .read<SetImageSwapCubit>()
                          .setImageSwap(widget.images![value]);
                    },
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: LoadingImage(link: widget.images![index].image),
                    ),
                    itemCount: widget.images!.length,
                  ),
      ),
    );
  }
}
