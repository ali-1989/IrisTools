import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

typedef CheckLocaleSupported = bool Function(Locale locale);
///=========================================================================================
class IrisLocalizations {
	Map<String, dynamic>? _keyValues;
	Map<String, dynamic>? _fallback;
	Locale? _currentLocale;

	IrisLocalizations();

	Locale? get currentLocale => _currentLocale;

	/// find ancestor
	static IrisLocalizations? of(BuildContext context) {
		return Localizations.of<IrisLocalizations>(context, IrisLocalizations);
	}

	static String? translateBy(BuildContext context, String key) {
		return Localizations.of<IrisLocalizations>(context, IrisLocalizations)?.translate(key);
	}

	Future<String> _loadAssetsFile(String path) async {
		return await rootBundle.loadString(path);
	}

	Future<Map<String, dynamic>> _loadAssetFor(Locale locale, {String? assetsPath}) async {
		String? strJson;
		assetsPath ??= 'assets/locales';

		if(locale.countryCode != null && locale.countryCode!.isNotEmpty) {
			strJson = await _loadAssetsFile('$assetsPath/${locale.languageCode}_${locale.countryCode}.json');
		}

		strJson ??= await _loadAssetsFile('$assetsPath/${locale.languageCode}.json');
		return jsonDecode(strJson);
	}

	Future<bool> loadByAssets(Locale locale, {String? assetsPath}) async {
		_currentLocale = locale;
		_keyValues = await _loadAssetFor(locale, assetsPath: assetsPath);

		return true;
	}

	Future<bool> loadByMap(Map<String, String> kv) async {
		_keyValues = kv;
		return true;
	}

	Future<void> setFallbackByLocale(Locale locale, {String? assetsPath}) async {
		_fallback = await _loadAssetFor(locale, assetsPath: assetsPath);
	}

	void setFallbackByMap(Map<String, String> kv) async {
		_fallback = kv;
	}

	bool isSetFallback() {
		return _fallback != null;
	}

	String? translate(String key) {
		var res = _keyValues?[key];

		if(res == null && _fallback != null) {
			res = _fallback![key];
		}

		return res;
	}

	String? translateCapitalize(String key) {
		final res = translate(key);
		return res == null ? null: ('${res[0].toUpperCase()}${res.substring(1)}');
	}

	Map<String, dynamic>? translateAsMap(String key) {
		var res = _keyValues![key];

		if(res == null && _fallback != null) {
			res = _fallback![key];
		}

		return res;
	}

	static Widget getCustomLocalization(BuildContext context, Locale locale, Widget child) {
		return Localizations.override(context: context, locale: locale, child: child);
	}

	static Locale? getLocalOf(BuildContext context) {
		return Localizations.maybeLocaleOf(context);
	}
}
///=========================================================================================
class IrisLocaleDelegate extends LocalizationsDelegate<IrisLocalizations> {
	late final IrisLocalizations _localization;
	late final CheckLocaleSupported _localeSupportChecker;
	String? _assetsFoldr;

	IrisLocaleDelegate(CheckLocaleSupported checkLocaleSupported, {String? customAssetsPath}){
		_localization = IrisLocalizations();
		_localeSupportChecker = checkLocaleSupported;
		_assetsFoldr = customAssetsPath;
	}

	@override
	Future<IrisLocalizations> load(Locale locale) async {
		await _localization.loadByAssets(locale, assetsPath: _assetsFoldr);

		return SynchronousFuture<IrisLocalizations>(_localization);
		//return Future.value(localData);
	}

	@override
	bool isSupported(Locale locale) {
		return _localeSupportChecker(locale);
	}

	@override
	bool shouldReload(IrisLocaleDelegate old) => false;

	IrisLocalizations getLocalization() => _localization;
}





/*static Map<String, Map<String, String>> _data = {
		'en': {
			'title': 'App title',
			'googleLogin': 'Login with Google'
		},
		'fa': {
			'title': '',
			'googleLogin': ''
		},
	};

	String get title =>  _data[locale.languageCode]['title'];
	*/
