import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  Uint8List? profileImage;

  User({required this.name, this.profileImage});
}
