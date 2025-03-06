import 'package:objectbox/objectbox.dart';

import '../../objectbox.g.dart';

@Entity()
class ContactModel {
  ContactModel({this.id = 0, required this.address});

  @Id()
  int id;
  final String address;
}
