import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/services.dart';
import 'package:iris_tools/api/system.dart';
import 'package:path_provider/path_provider.dart'; // for ios/android document dir
import 'package:path/path.dart' as pat; // work with path address
import 'package:file/file.dart' as fs;
import 'package:file/src/backends/memory.dart';
import 'package:file/local.dart';
import 'package:platform/platform.dart' as pl;

/// /storage/emulated/0/ARE
/// /data/user/0/ir.iris.ARE/files

class StorageHelper {
	StorageHelper._();

	//  /  or  c:\  or  http:://x.com  or  ''
	static String getRootPrefix(String path) {
		return pat.rootPrefix(path);
	}

	static String gstCurrentPath() {
		return pat.current;
	}

	static String getDirSeparator() {
		return pat.separator;
	}

	static Future<double> getFreeDiskSpace() async {
		double? size;

		try {
			size = await DiskSpace.getFreeDiskSpace;
		}
		on PlatformException {
			size = 0;
		}

		return Future<double>.value(size);
	}

	static Future<double> getTotalDiskSpace() async {
		double? size;

		try {
			size = await DiskSpace.getTotalDiskSpace;
		}
		on PlatformException {
			size = 0;
		}

		return Future<double>.value(size);
	}

	static fs.FileSystem getFileSystem() {
		return LocalFileSystem();
	}

	static MemoryFileSystem getMemoryFileSystem() {
		return MemoryFileSystem();
	}

	static final Map<String, String> _osToPathStyle = <String, String>{
		'linux': 'posix',
		'macos': 'posix',
		'android': 'posix',
		'ios': 'posix',
		'fuchsia': 'posix',
		'windows': 'windows',
	};

	static String? getExecutablePath(String command, String? workingDirectory, {
				pl.Platform platform = const pl.LocalPlatform(),
				fs.FileSystem fs = const LocalFileSystem(),
			}) {

		assert(_osToPathStyle[Platform.operatingSystem] == fs.path.style.name);

		workingDirectory ??= fs.currentDirectory.path;
		pat.Context context = pat.Context(style: fs.path.style, current: workingDirectory);

		String pathSeparator = Platform.isWindows ? ';' : ':';

		List<String>? extensions = <String>[];
		List<String> candidates = <String>[];

		if (Platform.isWindows && context.extension(command).isEmpty) {
			extensions = Platform.environment['PATHEXT']?.split(pathSeparator);
		}

		if (command.contains(context.separator)) {
			candidates = _getCandidatePaths(command, <String>[workingDirectory], extensions!, context);
		}
		else {
			List<String>? searchPath = Platform.environment['PATH']?.split(pathSeparator);
			candidates = _getCandidatePaths(command, searchPath!, extensions!, context);
		}

		try {
			return candidates.firstWhere((String path) => fs.file(path).existsSync());
		}
		catch (e){
			return null;
		}
	}

	static List<String> _getCandidatePaths(String command, List<String> searchPaths,
			List<String> extensions, pat.Context context,) {

		List<String> withExtensions = extensions.isNotEmpty
				? extensions.map((String ext) => '$command$ext').toList()
				: <String>[command];

		if (context.isAbsolute(command)) {
		  return withExtensions;
		}

		return searchPaths
				.map((String path) =>
				withExtensions.map((String command) => context.join(path, command)))
				.expand((Iterable<String> e) => e)
				.toList();
				//.cast<String>();
	}
	///--- Web --------------------------------------------------------------------------------------------
	static String getWebExternalStorage() {
		return getMemoryFileSystem().path.current;
	}
	///--- android ----------------------------------------------------------------------------------------
		// /storage/emulated/0
	static Future<String?> getAndroidExternalStorage() async {
		var full = (await getAndroidFilesDir$external())?.path?? '';
		full = full.substring(0, full.indexOf('/Android/data'));
		return full;
	}

	//  /storage/emulated/0/Android/data/ir.iris.appName/files
	static Future<Directory?> getAndroidFilesDir$external() async {
		return await getExternalStorageDirectory();
	}

	// /data/user/0/ir.iris.appName/files   	on iOS:
	static Future<Directory> getAndroidFilesDir$internal() async {
		final directory = await getApplicationSupportDirectory();
		return directory;
	}

	// /storage/emulated/0/Documents
	static Future<String?> getAndroidDocumentsDir() async {
		return await AndroidPathProvider.documentsPath;
	}

	static Future<String?> getAndroidDcimDir() async {
		return await AndroidPathProvider.dcimPath;
	}

	static Future<String?> getAndroidDownloadsDir() async {
		var path = await AndroidPathProvider.downloadsPath;
		return path;
	}

	static Future<String?> getAndroidPicturesDir() async {
		var path = await AndroidPathProvider.picturesPath;
		return path;
	}

	static Future<String?> getAndroidMoviesDir() async {
		var path = await AndroidPathProvider.moviesPath;
		return path;
	}
	///--- IOS ------------------------------------------------------------------------------------------
	static Future<Directory> getIosApplicationSupportDir() async {
		final directory = await getApplicationSupportDirectory();
		return directory;
	}

	static Future<Directory> getIosDocumentsDirectory() async {
		final directory = await getApplicationDocumentsDirectory();
		return directory;
	}
	///-- Shared Dir ------------------------------------------------------------------------------------
		// iOS:  ,   Android: /data/user/0/ir.iris.appName/app_flutter
	static Future<Directory> getAppDirectory$internal() async {
		final directory = await getApplicationDocumentsDirectory();

		return directory;
	}

	//android: /storage/emulated/0/Documents
	static Future<String> getDocumentsDirectory$external() async {
		if(System.isWeb()) {
		  return getWebExternalStorage() + '/Documents';
		} else if(Platform.isAndroid) {
		  return (await getAndroidDocumentsDir())!;
		} else if(Platform.isIOS) {
		  return (await getIosDocumentsDirectory()).path;
		} else {
		  return '';
		}
	}
	///------------------------------------------------------------------------------------------------
}