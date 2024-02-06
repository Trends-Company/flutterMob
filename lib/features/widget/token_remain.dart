import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../translations/export_lang.dart';
import '../screen/price.dart';

class TokenRemain extends StatelessWidget {
  const TokenRemain({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            '${formatToken(context).format(context.watch<UserBloc>().userModel!.token)} ${LocaleKeys.tokensRemaining.tr()} ',
        style: subhead(color: grey1100),
        children: <TextSpan>[
          TextSpan(
            text: LocaleKeys.buyMore.tr(),
            style: subhead(color: corn2),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context)
                    .pushNamed(Routes.price, arguments: PriceScreen());
              },
          )
        ],
      ),
    );
  }
}
