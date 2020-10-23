import 'package:assets_generator/assets_generator.dart';
import 'package:build_runner_core/build_runner_core.dart';

const String license = '''// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/assets_generator
// **************************************************************************
''';

String get classDeclare => 'class {0} {\n {0}._();';
String get classDeclareFooter => '}\n';

class Template {
  Template(
    this.assets,
    this.packageGraph,
    this.rule,
    this.class1,
  );
  final PackageNode packageGraph;
  final List<String> assets;
  final Rule rule;
  final Class class1;

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    sb.write(license);
    sb.write(classDeclare.replaceAll(
      '{0}',
      class1.go('ucc'),
    ));
    if (!packageGraph.isRoot) {
      sb.write('''static const String package = '${packageGraph.name}';\n''');
    }
    for (final String asset in assets) {
      sb.write(formatFiled(asset));
    }

    sb.write(classDeclareFooter);

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
    return rule.go(path);
  }
}
