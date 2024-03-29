import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../common/bloc/user/bloc_user.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/error_code.dart';
import '../../../common/constant/helper.dart';
import '../../../common/constant/styles.dart';
import '../../../common/models/request_model.dart';
import '../../../common/util/upload_image.dart';
import 'bloc_generate_image.dart';

class GenerateImageBloc extends Bloc<GenerateImageEvent, GenerateImageState> {
  GenerateImageBloc() : super(GenerateImageLoading()) {
    on<InitialGenerateImage>(_onInitialGenerateImage);
    on<EditGenerateImage>(_onEditGenerateImage);
  }

  User firebaseUser = FirebaseAuth.instance.currentUser!;
  Uint8List? result;
  String? url;
  int? requestId;

  Future<void> _onInitialGenerateImage(
      InitialGenerateImage event, Emitter<GenerateImageState> emit) async {
    emit(GenerateImageLoading());
    try {
      result = null;
      url = null;
      requestId = null;
      result = await handleImage(event.srcPath, event.dstPath, event.context,
          event.isHD, event.isRmWater);
      if (result != null) {
        final res = await uploadImage(result, event.context);
        if (res != null && res['url'] != null && res['request_id'] != null) {
          url = res['url'];
          requestId = res['request_id'];
          if (event.handleToken) {
            final UserBloc userBloc = event.context.read<UserBloc>();
            int tokensLost = TOKEN_SWAP;
            if (event.isHD) {
              tokensLost += TOKEN_EXPORT_HD;
            }
            if (event.isRmWater) {
              tokensLost += TOKEN_REM_MARK;
            }
            userBloc
                .add(UpdateTokenUser(userBloc.userModel!.token - tokensLost));
          }
          emit(GenerateImageLoaded(
              imageRes: result, url: url, requestId: requestId));
        }
      } else {
        emit(const GenerateImageError(error: SOMETHING_WENT_WRONG));
      }
    } catch (e) {
      emit(GenerateImageError(error: e.toString()));
    }
  }

  Future<void> _onEditGenerateImage(
      EditGenerateImage event, Emitter<GenerateImageState> emit) async {
    emit(GenerateImageLoading());
    try {
      result = event.result;
      url = event.url;
      requestId = event.requestId;
      emit(GenerateImageLoaded(
          imageRes: result, url: url, requestId: requestId));
    } catch (e) {
      emit(GenerateImageError(error: e.toString()));
    }
  }

  void showSnackBar(String input, BuildContext context) {
    BotToast.showText(text: input, textStyle: body(color: grey1100));
  }

  Future<Uint8List?> handleImage(String srcPath, String dstPath,
      BuildContext context, bool isHD, bool isRmWater) async {
    Uint8List? result;
    try {
      final request =
      http.MultipartRequest('POST', Uri.parse('$apiEndpoint/swap_image'));
      request.files.addAll([
        await http.MultipartFile.fromPath('srcPath', srcPath),
        await http.MultipartFile.fromPath('dstPath', dstPath)
      ]);
      request.fields['uuid'] = firebaseUser.uid;
      request.fields['isHD'] = isHD ? '1' : '0';
      request.fields['isRmWater'] = isRmWater ? '1' : '0';
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        result = response.bodyBytes;
      } else {
        showSnackBar(SOMETHING_WENT_WRONG, context);
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return result;
  }

  Future<Map<String, dynamic>?> uploadImage(
      Uint8List? res, BuildContext context) async {
    String? url;
    RequestModel? requestModel;
    final imageFile = await createFileUploadDO(res!);
    url = await uploadFile(imageFile: imageFile);
    if (url != null) {
      requestModel = await insertRequest(url, context);
    }
    return {'url': url, 'request_id': requestModel!.id};
  }
}
