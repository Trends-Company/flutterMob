import 'dart:async';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/recent_face/bloc_recent_face.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/models/recent_face_model.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/animation_long_press.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../common/widget/open_slot.dart';
import '../../translations/export_lang.dart';
import '../bloc/generate_image/bloc_generate_image.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
import '../widget/gift_widget.dart';
import '../widget/loading_face.dart';
import '../widget/not_enough_token.dart';
import '../widget/recent_face_video.dart';
import '../widget/token_remain.dart';
import '../widget/token_widget.dart';
import 'step_three.dart';

class StepTwo extends StatefulWidget {
  const StepTwo({super.key, required this.bytes, required this.pathSource});
  final Uint8List bytes;
  final String pathSource;
  @override
  State<StepTwo> createState() => _StepTwoVideoState();
}

class _StepTwoVideoState extends State<StepTwo> {
  Uint8List? yourFace;
  String? pathLocal;
  String? pathPublic;
  bool handlingFace = false;
  bool showDelete = false;
  bool isHD = true;
  bool isRmWater = true;
  late int tokensLost;

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

  Future<void> handleSwapImage() async {
    if (pathLocal != null) {
      uploadFace(context, yourFace!);
      context.read<GenerateImageBloc>().add(InitialGenerateImage(
          context: context,
          srcPath: widget.pathSource,
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
              srcImage: widget.bytes,
              dstImage: yourFace!,
              dstPath: pathLocal!,
              srcPath: widget.pathSource));
    } else {
      final res = await getImage(pathPublic!);
      final file = await createFileUploadDO(res);
      context.read<GenerateImageBloc>().add(InitialGenerateImage(
          context: context,
          srcPath: widget.pathSource,
          dstPath: file.path,
          handleToken: true,
          isHD: isHD,
          isRmWater: isRmWater));
      context
          .read<RemoveBGImageBloc>()
          .add(const ResetRemoveBGImage(hasLoaded: true));
      Navigator.of(context).pushNamed(Routes.step_three,
          arguments: StepThree(
              srcImage: widget.bytes,
              dstImage: res,
              dstPath: file.path,
              srcPath: widget.pathSource));
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
            margin: const EdgeInsets.only(bottom: 8),
            child: LoadingFace(
              link: recentFaceModel.face,
              radius: 3,
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
                        borderRadius: BorderRadius.circular(3),
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
                            borderRadius: BorderRadius.circular(3)),
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
                              borderRadius: BorderRadius.circular(3)),
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
    tokensLost = TOKEN_SWAP + TOKEN_EXPORT_HD + TOKEN_REM_MARK;
    //AdLovinUtils().initializeInterstitialAds(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        right: const TokenWidget(),
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
                    borderRadius: BorderRadius.circular(0), // For square corners
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF02FEE2), // Corrected color value
                         Color(0xFF6661FB), // Corrected color value, assuming missing digit corrected
                        Color(0xFFB956FA), // Corrected color value
                      ],
                    ),
                  ),
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
                      border: Border.all(color: grey1100, width: 2)),
                  child: LoadingFace(
                    link: pathPublic!,
                    radius: 3,
                  ),
                ),
              if (pathLocal != null)
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: grey1100, width: 2)),
                  child: ClipRRect(
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
                            tokensLost += TOKEN_EXPORT_HD;
                          } else {
                            tokensLost -= TOKEN_EXPORT_HD;
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
                            tokensLost += TOKEN_REM_MARK;
                          } else {
                            tokensLost -= TOKEN_REM_MARK;
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
                input: '${LocaleKeys.generate.tr()} -$tokensLost',
                bgColor: check ? primary : grey300,
                textColor: check ? grey1100 : grey600,
                borderColor: check ? primary : grey300,
                icon: token2,
                colorAsset: check ? null : grey600,
                borderRadius: 12,
                onPressed: check
                    ? () async {
                        final userModel = context.read<UserBloc>().userModel!;
                        if (userModel.token >= tokensLost) {
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
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                child: Image.memory(
                  widget.bytes,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
