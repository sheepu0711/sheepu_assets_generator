import 'dart:io';

import 'package:assets_generator/assets_generator.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

const String license = '''// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/assets_generator
// **************************************************************************
// ignore_for_file: constant_identifier_names

''';

String get classDeclare => 'class {0} {\n const {0}._();';
String get classDeclareFooter => '}\n';
String get constsArray => '''
final List<String> {0} = <String>[
{1}
];
''';

const String previewTemplate1 = '''/// {@template assets_generator.{0}.preview}
/// ![]({1})
/// {@endtemplate}

''';

const String previewTemplate = '''/// {@macro assets_generator.{0}.preview}
''';

const String mockClass = '''
// ignore_for_file: camel_case_types, unused_element
class _ {}''';

class Template {
  Template(
    this.assets,
    this.packageGraph,
    this.rule,
    this.class1,
    this.constIgnore,
    this.constArray,
    this.package,
    this.classPrefix,
  );
  final PackageNode? packageGraph;
  final List<String> assets;
  final Rule? rule;
  final Class? class1;
  final RegExp? constIgnore;
  final bool? constArray;
  final bool package;
  final bool classPrefix;

  Future<String> generateFile(
    Map<String, String> miss,
    File previewFile,
  ) async {
    final StringBuffer sb = StringBuffer();
    sb.write(license);

    final StringBuffer arraySb = StringBuffer();

    final String className =
        class1!.go('ucc', classPrefix ? packageGraph!.name : '')!;

    sb.write(classDeclare.replaceAll(
      '{0}',
      className,
    ));
    if (!packageGraph!.isRoot || package) {
      sb.write(
          '''\nstatic const String package = '${packageGraph!.name}';\n''');
    }
    final StringBuffer previewImageSb = StringBuffer();

    for (final String asset in assets) {
      if (constIgnore != null && constIgnore!.hasMatch(asset)) {
        continue;
      }
      final String filedName = _formatFiledName(asset);
      String filePath = asset;
      if (miss.containsKey(asset)) {
        filePath = miss[asset]!;
      }

      final String? mimeType = lookupMimeType(asset);
      final bool isImage = mimeType != null && mimeType.startsWith('image/');
      if (isImage) {
        previewImageSb.write(previewTemplate1
            .replaceAll('{0}', filedName)
            .replaceAll('{1}', join(packageGraph!.path, filePath)));
      }

      final String comment =
          isImage ? previewTemplate.replaceAll('{0}', filedName) : '';

      sb.write('\n$comment${formatFiled(asset)}');
      if (constArray!) {
        arraySb.write('$comment$className.$filedName,\n');
      }
    }

    sb.write(classDeclareFooter);

    if (arraySb.isNotEmpty) {
      sb.write(constsArray
          .replaceAll(
            '{0}',
            '${class1!.go('lcc', classPrefix ? packageGraph!.name : '')!}Array',
          )
          .replaceAll('{1}', arraySb.toString()));
    }

    if (previewImageSb.isNotEmpty) {
      final String content = license + previewImageSb.toString() + mockClass;
      previewFile.createSync(recursive: true);
      previewFile.writeAsStringSync(content);
    }

    return sb.toString();
  }

  String formatFiled(String path) {
    return '''static const String ${_formatFiledName(path)} = '$path';\n''';
  }

  String _formatFiledName(String path) {
    path = path
        .replaceAll('/', '_')
        .replaceAll('.', '_')
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll('@', '_AT_');
    return rule!.go(path);
  }
}
