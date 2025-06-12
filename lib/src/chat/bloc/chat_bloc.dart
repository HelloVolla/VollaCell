import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaonic/data/models/kaonic_new/kaonic_event.dart';
import 'package:kaonic/data/models/mesh_address.dart';
import 'package:kaonic/data/models/radio_address.dart';
import 'package:kaonic/service/new/chat_service.dart';
import 'package:kaonic/src/chat/chat_args.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required ChatService chatService, required String address})
      : _chatService = chatService,
        _address = address,
        super(ChatState(
            address: MeshAddress.fromRadio(RadioAddress.fromHex(address)))) {
    on<SendMessage>(_sendMessage);
    on<_UpdatedChats>(_updatedChats);
    on<_IntiChat>(_intiChat);
    on<InitiateCall>(_initiateCall);
    on<FilePicked>(_filePicked);

    add(_IntiChat());
  }
  late final ChatService _chatService;
  // final CommunicationService _communicationService;
  final String _address;
  late final String _chatId;
  // late final StreamSubscription<Map<String, MeshChat>>? _chatSubscription;
  late final StreamSubscription<List<KaonicEvent<KaonicEventData>>>?
      _chatSubscription;

  @override
  Future<void> close() async {
    _chatSubscription?.cancel();
    super.close();
  }

  FutureOr<void> _intiChat(_IntiChat event, Emitter<ChatState> emit) async {
    _chatId = await _chatService.createChat(_address);
    _chatSubscription =
        _chatService.getChatMessages(_address).listen((messages) {
      add(_UpdatedChats(messages: messages));
    });
  }

  FutureOr<void> _sendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    try {
      _chatService.sendTextMessage(event.message, _address);
    } catch (e) {
      if (kDebugMode) {
        print('\u001b[31mERROR: $e\u001b[0m');
      }
      return;
    }
    emit(state.copyWith(flagScrollToDown: true));
  }

  FutureOr<void> _updatedChats(_UpdatedChats event, Emitter<ChatState> emit) {
    // _communicationService.markMessageRead(state.address);

    emit(state.copyWith(
      // messages: event.chats[_args.contact.address]?.messages,
      messages: event.messages,
      flagScrollToDown: true,
    ));
  }

  FutureOr<void> _initiateCall(
      InitiateCall event, Emitter<ChatState> emit) async {
    // await _communicationService.initiateCall(state.address);

    emit(NavigateToCall(address: state.address));
  }

  void _filePicked(FilePicked event, Emitter<ChatState> emit) {
    if (event.file.files.isEmpty && event.file.files.first.path != null) return;
    final f = File(event.file.files.first.path!);
    _chatService.sendFileMessage(f.path, _address);
  }
}
