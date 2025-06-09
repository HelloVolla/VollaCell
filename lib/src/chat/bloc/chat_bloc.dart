import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaonic/data/models/meah_chat.dart';
import 'package:kaonic/data/models/mesh_address.dart';
import 'package:kaonic/data/models/mesh_message.dart';
import 'package:kaonic/data/models/radio_address.dart';
import 'package:kaonic/service/communication_service.dart';
import 'package:kaonic/src/chat/chat_args.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(
      {required CommunicationService communicationService,
      required ChatArgs args})
      : _communicationService = communicationService,
        _args = args,
        super(ChatState(
          address: MeshAddress.fromRadio(
            RadioAddress.fromHex(args.contact.address),
          ),
        )) {
    on<SendMessage>(_sendMessage);
    on<_UpdatedChats>(_updatedChats);
    on<_IntiChat>(_intiChat);
    on<InitiateCall>(_initiateCall);
    on<FilePicked>(_filePicked);

    add(_IntiChat());
  }

  final CommunicationService _communicationService;
  final ChatArgs _args;
  late final StreamSubscription<Map<String, MeshChat>>? _chatSubscription;

  @override
  Future<void> close() async {
    _chatSubscription?.cancel();
    super.close();
  }

  FutureOr<void> _intiChat(_IntiChat event, Emitter<ChatState> emit) {
    _chatSubscription = _communicationService.chats
        ?.listen((chats) => add(_UpdatedChats(chats: chats)));
  }

  FutureOr<void> _sendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    try {
      _communicationService.sendMessage(state.address, event.message);
    } catch (e) {
      if (kDebugMode) {
        print('\u001b[31mERROR: $e\u001b[0m');
      }
      return;
    }
    emit(state.copyWith(flagScrollToDown: true));
  }

  FutureOr<void> _updatedChats(_UpdatedChats event, Emitter<ChatState> emit) {
    _communicationService.markMessageRead(state.address);

    emit(state.copyWith(
        messages: event.chats[_args.contact.address]?.messages,
        flagScrollToDown: true));
  }

  FutureOr<void> _initiateCall(
      InitiateCall event, Emitter<ChatState> emit) async {
    await _communicationService.initiateCall(state.address);

    emit(NavigateToCall(address: state.address));
  }

  void _filePicked(FilePicked event, Emitter<ChatState> emit) {
    if (event.file.files.isEmpty && event.file.files.first.path != null) return;
    final f = File(event.file.files.first.path!);
    _communicationService.sendFile(state.address, event.file.files.first.name,
        f.readAsBytesSync(), f.path);
  }
}
