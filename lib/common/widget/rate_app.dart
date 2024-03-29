import 'package:face_swap_flutter/common/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../app/widget_support.dart';
import '../../../common/widget/gradient_text.dart';
import '../../translations/export_lang.dart';
import '../constant/images.dart';
import '../constant/styles.dart';

class RateAppWidget extends StatefulWidget {
  const RateAppWidget({Key? key}) : super(key: key);

  @override
  State<RateAppWidget> createState() => _RateAppWidgetState();
}

class _RateAppWidgetState extends State<RateAppWidget> {
  /* MUST CONFIG */
  Future<void> _rateAndReviewApp() async {
    final _inAppReview = InAppReview.instance;
    _inAppReview.openStoreListing(
      appStoreId: '6471816673',
      microsoftStoreId: 'dev.ditustudio.face_swap_flutter',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: grey200, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(success, width: 120, height: 120),
                DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SpaceGrotesk'),
                  child: GradientText(
                    LocaleKeys.enjoyOurApp.tr(),
                    gradient: Theme.of(context).linearGradientCustome,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    LocaleKeys.itGoodRight.tr(),
                    textAlign: TextAlign.center,
                    style: body(color: Theme.of(context).color12),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppWidget.typeButtonStartAction(
                          context: context,
                          input: LocaleKeys.later.tr(),
                          borderRadius: 12,
                          vertical: 12,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          bgColor: grey100,
                          borderColor: grey100,
                          textColor: grey1100),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppWidget.typeButtonStartAction(
                          context: context,
                          input: LocaleKeys.RateNow.tr(),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _rateAndReviewApp();
                          },
                          bgColor: primary,
                          borderRadius: 12,
                          vertical: 12,
                          borderColor: primary,
                          textColor: grey1100),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
