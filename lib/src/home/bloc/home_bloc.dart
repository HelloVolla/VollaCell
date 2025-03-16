import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaonic/data/models/meah_chat.dart';
import 'package:kaonic/data/models/mesh_call.dart';
import 'package:kaonic/data/models/mesh_node.dart';
import 'package:kaonic/data/models/user_model.dart';
import 'package:kaonic/service/communication_service.dart';
import 'package:kaonic/service/device_service.dart';
import 'package:kaonic/service/user_service.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required UserService userService,
    required DeviceService deviceService,
    required CommunicationService communicationService,
  })  : _userService = userService,
        _deviceService = deviceService,
        _communicationService = communicationService,
        super(HomeState(user: userService.user)) {
    on<_InitEvent>(_initEvent);
    on<_UpdatedUser>(_updatedUser);
    on<_UpdatedChats>(_updatedChats);
    on<_UpdatedNodes>(_updatedNodes);
    on<_HandleCallStatus>(_handleCallStatus);

    add(_InitEvent());

    if (userService.user != null) {
      _communicationService.initializeCommunicationLayer(userService.user!);
      _nodesSubscription = communicationService.nodes?.listen(
        (event) => add(_UpdatedNodes(nodes: event)),
      );
    }
  }

  final UserService _userService;
  final DeviceService _deviceService;
  final CommunicationService _communicationService;

  late final StreamSubscription<Query<UserModel>>? _userSubscription;
  late final StreamSubscription<Map<String, MeshChat>>? _chatSubscription;
  late final StreamSubscription<Map<String, MeshNode>>? _nodesSubscription;
  late final StreamSubscription<MeshCall>? _callStatusSubscription;

  @override
  close() async {
    _userSubscription?.cancel();
    _chatSubscription?.cancel();
    _communicationService.dispose();
    _nodesSubscription?.cancel();
    _callStatusSubscription?.cancel();
    super.close();
  }

  FutureOr<void> _initEvent(_InitEvent event, Emitter<HomeState> emit) {
    _deviceService.startUser(_userService.user?.key ?? '');
    _userSubscription = _userService.watchCurrentUser()?.listen((user) {
      final newUser = user.findFirst();
      if (newUser == null) return;
      add(_UpdatedUser(user: newUser));
    });
    
    _chatSubscription = _communicationService.chats?.listen(
      (event) {},
    );

    _callStatusSubscription = _communicationService.callStatusStream
        ?.listen((call) => add(_HandleCallStatus(call: call)));
  }

  FutureOr<void> _updatedUser(_UpdatedUser event, Emitter<HomeState> emit) {
    emit(state.copyWith(user: event.user));
  }

  FutureOr<void> _updatedNodes(_UpdatedNodes event, Emitter<HomeState> emit) {
    emit(state.copyWith(nodes: event.nodes));
  }


  FutureOr<void> _handleCallStatus(
      _HandleCallStatus event, Emitter<HomeState> emit) {
    if (event.call.status == MeshCallStatuses.incomingCall) {
      emit(IncomingCall.fromParentState(state));
    }
  }

  FutureOr<void> _updatedChats(_UpdatedChats event, Emitter<HomeState> emit) {
    emit(state.copyWith(
        unreadMessages: event.chats
            .map((key, value) => MapEntry(key, value.unreadMessagesCount))));
  }
}
