import 'arg.dart';

class FullPath extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help =>
      'Generate full path including package prefix (e.g., packages/my_package/lib/assets/image.png). '
      'When enabled, you can use Image.asset(Assets.ASSET_NAME) without the package parameter.';

  @override
  String get name => 'full-path';
}
