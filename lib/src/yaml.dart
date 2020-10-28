import 'dart:io';

import 'package:assets_generator/assets_generator.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart';
import 'package:source_span/source_span.dart';
import 'package:yaml/yaml.dart';

import 'arg/type.dart';

const String license = '''

{0}# GENERATED CODE - DO NOT MODIFY MANUALLY
{0}# **************************************************************************
{0}# Auto generated by https://github.com/fluttercandies/assets_generator
{0}# **************************************************************************

''';

//const String assetsStartConst = '# assets start';
//const String assetsEndConst = '# assets end';
const String space = ' ';

class Yaml {
  Yaml(
    this.yamlFile,
    this.assets,
    this.miss,
    this.formatType,
  );
  final File yamlFile;
  final List<String> assets;
  final List<String> miss;
  final FormatType formatType;

  void write() {
    if (formatType == FormatType.directory) {
      final List<String> directories = <String>[];
      for (final String asset in assets) {
        // resolution image assets miss main asset entry
        // It should define as a file
        if (miss.contains(asset)) {
          directories.add(asset);
        } else {
          final String d = '${dirname(asset)}/';
          if (!directories.contains(d)) {
            directories.add(d);
          }
        }
      }
      assets.clear();
      assets.addAll(directories);
    }

    assets.sort((String a, String b) => a.compareTo(b));

    String yamlString = yamlFile.readAsStringSync();

    //make sure that there are no '# assets start' and '# assets end'
    // yamlString = yamlString
    //     .replaceAll(assetsStartConst, '')
    //     .replaceAll(assetsEndConst, '')
    //     .trim();

    final YamlMap yaml = loadYaml(yamlString) as YamlMap;

    final String indent = getIndent(yaml);

    // final String assetsStart = '\n$indent$assetsStartConst\n';
    // final String assetsEnd = '\n$indent$assetsEndConst\n';
    final StringBuffer pubspecSb = StringBuffer();
    if (assets.isNotEmpty) {
      //pubspecSb.write(assetsStart);
      pubspecSb.write(license.replaceAll('{0}', indent));
      for (final String asset in assets) {
        pubspecSb.write('${indent * 2}- $asset\n');
      }
      //pubspecSb.write(assetsEnd);
    }

    final String newAssets = pubspecSb.toString();

    final String assetsNodeS = indent + 'assets:\n' + newAssets;
    if (yaml.containsKey('flutter')) {
      final YamlMap flutter = yaml['flutter'] as YamlMap;
      if (flutter != null) {
        if (flutter.containsKey('assets')) {
          final YamlList assetsNode = flutter['assets'] as YamlList;
          final FileSpan sourceSpan = (flutter.nodes.keys.firstWhere(
                      (dynamic element) =>
                          element is YamlNode && element.span.text == 'assets')
                  as YamlNode)
              ?.span as FileSpan;

          final int start = sourceSpan.start.offset - sourceSpan.start.column;
          if (assetsNode != null) {
            final int end = assetsNode.nodes.last.span.end.offset;
            yamlString = yamlString.replaceRange(
              start,
              end,
              assetsNodeS,
            );
          }
          //Empty assets
          else {
            yamlString = yamlString.replaceRange(
                start, sourceSpan.end.offset, '\n' + assetsNodeS);
          }
        }
        //miss assets:
        else {
          final int end = flutter.span.end.offset;
          yamlString = yamlString.replaceRange(end, end, '\n' + assetsNodeS);
        }
      }
      //Empty flutter
      else {
        final int end = yamlString.lastIndexOf('flutter:') + 'flutter:'.length;
        yamlString = yamlString.replaceRange(end, end, '\n' + assetsNodeS);
      }
    }
    //miss flutter:
    else {
      final int end = yaml.span.end.offset;
      yamlString =
          yamlString.replaceRange(end, end, '\nflutter:\n$assetsNodeS');
    }

    if (assets.isEmpty) {
      //make sure that there are no 'assets:'
      yamlString = yamlString.replaceAll('assets:', '').trim();
    }

    yamlString = yamlString.trim();

    yamlFile.writeAsStringSync(yamlString);
    print(green.wrap('${yamlFile.path} is changed automatically.'));
  }
}

String getIndent(YamlMap yamlMap) {
  if (yamlMap.containsKey('flutter')) {
    final YamlMap flutter = yamlMap['flutter'] as YamlMap;
    if (flutter != null && flutter.nodes.keys.first is YamlNode) {
      final SourceSpan sourceSpan = flutter.nodes.keys.first.span as SourceSpan;
      return space * sourceSpan.start.column;
    }
  }
  return space * 2;
}
