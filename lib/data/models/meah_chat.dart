import 'package:kaonic/data/models/mesh_message.dart';

class MeshChat {
  MeshChat({this.unreadMessagesCount = 0, this.messages = const []});

  int unreadMessagesCount;
  final List<MeshMessage> messages;
}