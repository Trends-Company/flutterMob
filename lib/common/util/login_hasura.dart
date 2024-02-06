import 'package:dio/dio.dart';

Future<void> signInSocials(String _token) async {
  try {
    final response =
        await Dio().get<dynamic>('https://nodejs-ai-graphy.vercel.app/webhook',
            options: Options(headers: <String, dynamic>{
              'Authorization': '$_token',
              'content-type': 'application/json',
            }));
    print(response);
  } catch (e) {
    print(e);
  }
}
