import 'arg.dart';
import 'arg_parser.dart';

class Path extends Argument {
  @override
  String get abbr => 'p';

  @override
  dynamic get defaultsTo => '.';

  @override
  String get help => 'Flutter project root path';

  @override
  String get name => 'path';

  @override
  String get value {
    if (argResults.wasParsed(name)) {
      return argResults[name] as String;
    }
    return defaultsTo as String;
  }
}
