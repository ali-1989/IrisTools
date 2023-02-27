import 'dart:convert';
import 'package:dio/dio.dart';

class Http {
	Http._();

	static final BaseOptions _options = BaseOptions(
		connectTimeout: Duration(seconds: 40),
	);

	static Future<Response> sendGet(String url) async { //"http://www.google.com"
		try {
			Dio dio = Dio(_options);

			//(dio.transformer as DefaultTransformer).transformRequest(options);
			return dio.get(url);
		}
		catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response<ResponseBody>> sendGetAsStream(String url) async {
		try {
			 return Dio(_options).get<ResponseBody>(url, options: Options(responseType: ResponseType.stream));
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response<List<int>>> sendGetAsBytes(String url) async {
		try {
			 return Dio(_options).get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
		}
		catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> sendGetByQuery(String url, Map<String, dynamic> queryParams) async {
		try {
			return Dio(_options).get(url, queryParameters: queryParams);
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> sendPost(String url, dynamic data) async {
		try {
			return Dio(_options).post(url, data: data);
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> sendPostByQuery(String url, dynamic data, Map<String, dynamic> queryParams) async {
		try {
			return Dio(_options).post(url, data: data, queryParameters: queryParams);
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> downloadToFile(String url, String savePath, {ProgressCallback? progress}) async {
		try {
			Options op = Options(
				method: 'GET',
				responseType: ResponseType.stream,
			);

			//Uri u = Uri(scheme: 'https', host: 'png.pngtree.com', path: 'thumb_back/fh260/background/20191113/pngtree-abstract-wallpaper-desktop-design-image_321813.jpg');
			if(progress != null) {
			  return Dio(_options).download(url, savePath, options: op, onReceiveProgress: progress);
			} else {
			  return Dio(_options).download(url, savePath, options: op);
			}
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> downloadByQuery(String url, String savePath, Map<String, dynamic> queryParams, {ProgressCallback? progress}) async {
		try {
			if(progress != null) {
			  return Dio(_options).download(url, savePath, queryParameters: queryParams, onReceiveProgress: progress);
			} else {
			  return Dio(_options).download(url, savePath, queryParameters: queryParams);
			}
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> uploadFile(String url, String filePath, String fileName, {Map<String, dynamic>? queryParams, ProgressCallback? progress}) async {
		try {
			var formData = FormData.fromMap({
				'file': await MultipartFile.fromFile(filePath, filename: fileName),}
			);

			if(progress != null) {
			  return Dio(_options).post(url, data: formData, queryParameters: queryParams, onSendProgress: progress);
			} else {
			  return Dio(_options).post(url, data: formData, queryParameters: queryParams,);
			}
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> uploadBytes(String url, List<int> data, {Map<String, dynamic>? queryParams, ProgressCallback? progress}) async {
		try {
			var sendData = Stream.fromIterable(data.map((e) => [e]));
			var op = Options(headers: {
				Headers.contentLengthHeader: data.length,},);

			if(progress != null) {
			  return Dio(_options).post(url, data: sendData, options: op, queryParameters: queryParams, onSendProgress: progress);
			} else {
			  return Dio(_options).post(url, data: sendData, options: op, queryParameters: queryParams);
			}
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> uploadFileByJson(String url, String filePath, String fileName, String jsonParam, {Map<String, dynamic>? queryParams, ProgressCallback? progress}) async {
		try {
			var formData = FormData.fromMap({
				...json.decode(jsonParam),
				'filePart': await MultipartFile.fromFile(filePath, filename: fileName),}
			);

			if(progress != null) {
			  return Dio(_options).post(url, data: formData, queryParameters: queryParams, onSendProgress: progress);
			} else {
			  return Dio(_options).post(url, data: formData, queryParameters: queryParams);
			}
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> uploadFileByMap(String url, String filePath, String fileName, Map map, {Map<String, dynamic>? queryParams, ProgressCallback? progress}) async {
		try {
			var formData = FormData.fromMap({
				...map,
				//"RootJson": '{"key": "value60"}',
				'filePart': await MultipartFile.fromFile(filePath, filename: fileName),}
			);

			if(progress != null) {
			  return Dio(_options).post(url, data: formData, queryParameters: queryParams, onSendProgress: progress);
			} else {
			  return Dio(_options).post(url, data: formData, queryParameters: queryParams);
			}
		} catch (e) {
			return Future.error(e);
		}
	}

	static Future<Response> putDataByMap(String url, dynamic data, {Map<String, dynamic>? queryParams, ProgressCallback? progress}) async {
		try {
			if(progress != null) {
			  return Dio(_options).put(url, data: data, queryParameters: queryParams, onSendProgress: progress);
			} else {
			  return Dio(_options).put(url, data: data, queryParameters: queryParams);
			}
		} catch (e) {
			return Future.error(e);
		}
	}
}