import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/user/user_bloc.dart';
import '../../common/bloc/user/user_event.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/error_code.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/preference/shared_preference_builder.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/gradient_text.dart';
import '../../common/widget/lottie_widget.dart';
import '../../translations/export_lang.dart';
import '../bloc/show_gift/show_gift.dart';
import '../widget/item_price.dart';
import '../widget/web_view_privacy.dart';

final List<String> _kProductIds = <String>[
  tokenIdentifier1,
  tokenIdentifier2,
  tokenIdentifier4
];

class PriceFirstTime extends PageRouteBuilder {
  PriceFirstTime({this.currentIndex})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                PriceFirstTimeToken(currentIndex: currentIndex));
  final int? currentIndex;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(.0, .0))
              .animate(controller!),
      child: PriceFirstTimeToken(currentIndex: currentIndex),
    );
  }
}

class PriceFirstTimeToken extends StatefulWidget {
  const PriceFirstTimeToken({super.key, this.currentIndex});
  final int? currentIndex;

  @override
  State<PriceFirstTimeToken> createState() => _PriceFirstTimeState();
}

class _PriceFirstTimeState extends State<PriceFirstTimeToken>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool isChecked = true;
  int _currentIndex = 1;
  int _tokens = 1950;
  String identifier = tokenIdentifier2;
  List<StoreProduct> products = [];
  List<Map<String, dynamic>> tokens = [];
  List<String> bgPriceFirstTimes = [bg_1, bg_2, bg_3, bg_4, bg_5];

  Future<void> updateTokenUser(int reward) async {
    final UserBloc userBloc = context.read<UserBloc>();
    userBloc.add(UpdateTokenUser(userBloc.userModel!.token + reward));
  }

  Future<void> getInappPurchase() async {
    try {
      products = await Purchases.getProducts(
        _kProductIds,
        productCategory: ProductCategory.nonSubscription,
      );
    } on PlatformException catch (_) {
      BotToast.showText(text: SOMETHING_WENT_WRONG);
    }
  }

  Future<void> makeAPurchase(StoreProduct storeProduct) async {
    if (storeProduct.identifier == _kProductIds[_currentIndex]) {
      try {
        EasyLoading.show();
        await Purchases.purchaseStoreProduct(storeProduct);
        await setRewardTokenIAP(_tokens * 2);
        await Purchases.syncPurchases();
        EasyLoading.dismiss();
        context.read<ShowGift>().reset();
        Navigator.of(context).pop();
      } on PlatformException catch (e) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          BotToast.showText(text: LocaleKeys.thePurchaseHasBeenCancelled.tr());
        } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
          BotToast.showText(text: LocaleKeys.thePurchaseIsStill.tr());
          await setRewardTokenIAP(_tokens);
        }
        EasyLoading.dismiss();
      }
    } else {
      BotToast.showText(text: SOMETHING_WENT_WRONG);
    }
  }

  @override
  void initState() {
    getInappPurchase();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVisible = true;
        _animationController.forward();
      });
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    if (widget.currentIndex != null) {
      _currentIndex = 2;
      _tokens = 10000;
      identifier = tokenIdentifier4;
    } else {
      _currentIndex = 1;
      _tokens = 1950;
      identifier = tokenIdentifier2;
    }

    tokens = [
      {
        'token': 500,
        'bonus': 0,
        'money': 0.99,
        'selected': false,
        'total': 500,
        'identifier': tokenIdentifier1
      },
      {
        'token': 1500,
        'bonus': 450,
        'money': 2.99,
        'selected': widget.currentIndex == null,
        'total': 1950,
        'useful': '${LocaleKeys.save.tr()} 30%',
        'identifier': tokenIdentifier2
      },
      {
        'token': 5000,
        'money': 9.99,
        'selected': widget.currentIndex != null,
        'total': 10000,
        'bonus': 5000,
        'useful': 'x2',
        'identifier': tokenIdentifier4
      }
    ];
    // AppLovinMAX.loadRewardedAd(AdLovinUtils().rewardAdUnitIdApplovin);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = AppWidget.getWidthScreen(context);
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  activeColor: primary,
                  value: isChecked,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = !isChecked;
                    });
                  },
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${LocaleKeys.youAgreeWithOur.tr()} ',
                    style: body(color: grey1100),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Term & Policy',
                        style: headline(color: grey1100),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushNamed(Routes.term,
                                arguments: const WebViewPrivacy());
                          },
                      )
                    ],
                  ),
                ),
              ],
            ),
            AppWidget.typeButtonStartAction2(
                context: context,
                input:
                    '${LocaleKeys.buyNow.tr()} + ${formatToken(context).format(_tokens * 2)} ${LocaleKeys.tokens.tr()}',
                bgColor: isChecked ? primary : grey600,
                textColor: grey1100,
                borderColor: isChecked ? primary : grey600,
                borderRadius: 12,
                onPressed: isChecked
                    ? () async {
                        if (products.isNotEmpty) {
                          await makeAPurchase(products
                              .firstWhere((e) => e.identifier == identifier));
                        } else {
                          BotToast.showText(
                              text: SOMETHING_WENT_WRONG,
                              textStyle: body(color: grey1100));
                        }
                      }
                    : () {}),
            const SizedBox(height: 8),
            Text(version, style: subhead(color: grey800, fontWeight: '400'))
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  CarouselSlider.builder(
                      itemCount: bgPriceFirstTimes.length,
                      itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) =>
                          Image.asset(
                            bgPriceFirstTimes[itemIndex],
                            width: width,
                            height: height / 1.3,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                      options: CarouselOptions(
                        enableInfiniteScroll: true,
                        height: height / 1.3,
                        viewportFraction: 1,
                        aspectRatio: 2,
                        disableCenter: true,
                        autoPlay: true,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        scrollDirection: Axis.horizontal,
                      )),
                  Positioned(
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: height / 1.5,
                        width: width,
                        decoration: BoxDecoration(
                            gradient: Theme.of(context).colorLinearBottom3),
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox())
            ],
          ),
          Positioned(
              left: 24,
              top: 64,
              child: AnimationClick(
                function: _isVisible
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : () {},
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: grey1100.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(48)),
                      child: Image.asset(
                        icClose,
                        width: 20,
                        height: 20,
                        color: grey1100,
                      ),
                    ),
                  ),
                ),
              )),
          Positioned(
              right: 24,
              top: 64,
              child: AnimationClick(
                function: () {
                  // showRewardApplovin(context, updateTokenUser,
                  //     reward: TOKEN_REWARD);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: Theme.of(context).linearGradientCustome,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        video_ads,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '+$TOKEN_REWARD ${LocaleKeys.tokens.tr()}',
                        style: body(color: grey100, fontWeight: '600'),
                      ),
                    ],
                  ),
                ),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          gradient: Theme.of(context).linearGradientCustome,
                          borderRadius: BorderRadius.circular(48)),
                      child: const LottieWidget(lottie: gift, height: 64),
                    ),
                  ),
                  const SizedBox(height: 16),
                  IgnorePointer(
                    child: GradientText(
                      'First Time Purchase',
                      style: const TextStyle(
                          fontSize: 36,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SpaceGrotesk'),
                      gradient: Theme.of(context).linearGradientCustome,
                    ),
                  ),
                  IgnorePointer(
                      child: Text('X2 Tokens', style: title1(color: corn1))),
                  const SizedBox(height: 8),
                  ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemBuilder: (context, index) {
                        return AnimationClick(
                          function: () {
                            for (dynamic r in tokens) {
                              r['selected'] = false;
                            }
                            tokens[index]['selected'] = true;
                            setState(() {
                              _currentIndex = index;
                              identifier = tokens[index]['identifier'];
                              _tokens = tokens[index]['token'] +
                                  tokens[index]['bonus'];
                            });
                          },
                          child: ItemPrice(
                            point: tokens[index],
                            index: index,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemCount: tokens.length),
                ],
              ))
        ],
      ),
    );
  }
}
