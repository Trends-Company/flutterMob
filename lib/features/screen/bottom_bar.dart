import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/list_requests/list_requests_bloc.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/models/user_model.dart';
import '../../common/preference/shared_preference_builder.dart';
import '../../common/route/routes.dart';
import '../../common/widget/check_in.dart';
import '../../features/screen/step_one.dart';
import '../../features/screen/swap_category.dart';
import '../../translations/export_lang.dart';
import '../bloc/list_categories/list_categories_bloc.dart';
import '../bloc/new_today/new_today_bloc.dart';
import '../bloc/set_index_bottombar/set_index_bottombar_bloc.dart';
import '../bloc/trending/trending_bloc.dart';
import 'price.dart';
import 'profile.dart';
import 'swap_video.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key, this.index = 0});
  final int index;
  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  List<Widget> listWidget = [];

  Future<void> checkShowDaily() async {
    Future.delayed(const Duration(seconds: 2)).whenComplete(() async {
      final UserModel? user = context.read<UserBloc>().userModel;
      if (user != null) {
        final timeNow = await getTime();
        if (canCheckIn(user.dateCheckIn, timeNow)) {
          showDialog(
            context: context,
            builder: (context) {
              return const CheckInWidget();
            },
          );
        }
      }
    });
  }

  Future<void> checkShowPrice() async {
    if (isIOS) {
      final bool showPrice = await getValueBool(input: 'show_price') ?? false;
      if (showPrice) {
        await setSharedBool(false, 'show_price');
        Future.delayed(const Duration(seconds: 2)).whenComplete(() async {
          final res = await Navigator.of(context).pushNamed(Routes.price,
              arguments: PriceScreen(showDaily: true)) as bool;
          if (res) {
            checkShowDaily();
          }
        });
      }
    } else {
      checkShowDaily();
    }
  }

  Future<void> loadData() async {
    Future.delayed(const Duration(seconds: 1)).whenComplete(() {
      getUserInfo(mounted, context);
      getLanguageUser(context);
      context.read<ListCategoriesBloc>().add(ListCategoriesFetched());
      context.read<NewTodayBloc>().add(NewTodayFetched());
      context.read<TrendingBloc>().add(TrendingFetched());
      context
          .read<ListRequestsBloc>()
          .add(ListRequestsFetched(context: context));
      getRecentFace(mounted, context);
    });
    await Purchases.setEmail(firebaseUser.email!);
    listenInAppPurchase(context);
    createNoti();
    checkShowPrice();
  }

  @override
  void initState() {
    super.initState();
    context.read<SetIndexBottomBar>().setIndex(widget.index);
    listWidget = [
      const SwapCategory(),
      const StepOne(),
      SwapVideo(),
      const Profile(),
    ];
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: context.watch<SetIndexBottomBar>().state,
        children: listWidget,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: context.watch<SetIndexBottomBar>().state,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: grey200,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (value) {
          context.read<SetIndexBottomBar>().setIndex(value);
        },
        items: [
          AppWidget.createItemNav(context, house_simple, house_simple_active,
              LocaleKeys.category.tr()),
          AppWidget.createItemNav(
              context, paint_brush, paint_brush_active, LocaleKeys.home.tr()),
          AppWidget.createItemNav(
              context, video_camera, video_camera_active, LocaleKeys.home.tr()),
          BottomNavigationBarItem(
              icon: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child:
                    BlocBuilder<UserBloc, UserState>(builder: (context, state) {
                  if (state is UserLoaded) {
                    return CachedNetworkImage(
                      imageUrl: state.user.avatar,
                      width: 28,
                      height: 28,
                      fadeOutDuration: const Duration(milliseconds: 200),
                      fadeInDuration: const Duration(milliseconds: 200),
                    );
                  }
                  return CachedNetworkImage(
                    imageUrl: defaultAvatar,
                    width: 28,
                    height: 28,
                    fadeOutDuration: const Duration(milliseconds: 200),
                    fadeInDuration: const Duration(milliseconds: 200),
                  );
                }),
              ),
              label: LocaleKeys.profile.tr()),
        ],
      ),
    );
  }
}
