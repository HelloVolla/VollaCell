import 'dart:async';

import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaonic/data/models/mesh_address.dart';
import 'package:kaonic/data/models/mesh_call.dart';
import 'package:kaonic/service/communication_service.dart';
import 'package:kaonic/service/new/call_service.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc({
    required CommunicationService communicationService,
    required CallService callService,
    required CallScreenState callState,
  })  : _communicationService = communicationService,
        _callService = callService,
        super(CallState(
            callState: callState,
            call: communicationService.callStatusValue,
            usernameAddressHex:
                communicationService.callStatusValue?.address?.toHex())) {
    on<_InitCall>(_initCall);
    on<_CallUpdated>(_callUpdated);
    on<EndCall>(_endCall);
    on<AcceptCall>(_acceptCall);
    on<UpdateCallState>(_onUpdateCallState);

    add(_InitCall());
  }

  late final StreamSubscription<MeshCall>? _callSubscription;
  late final StreamSubscription<CallScreenState>? _callStateSubscription;
  final CommunicationService _communicationService;
  late final CallService _callService;

  @override
  close() async {
    _callSubscription?.cancel();
    _callStateSubscription?.cancel();
    super.close();
  }

  FutureOr<void> _initCall(_InitCall event, Emitter<CallState> emit) {
    // _callSubscription = _communicationService.callStatusStream
    //     ?.listen((call) => add(_CallUpdated(call: call)));

    _callStateSubscription = _callService.callState.listen((callState) {
      add(UpdateCallState(callState));
    });
  }

  void _onUpdateCallState(UpdateCallState event, Emitter<CallState> emit) {
    emit(state.copyWith(callState: event.callSate));
  }

  FutureOr<void> _callUpdated(
      _CallUpdated event, Emitter<CallState> emit) async {
    emit(state.copyWith(
        call: event.call, usernameAddressHex: event.call.address?.toHex()));

    if (event.call.status == MeshCallStatuses.ended) {
      _callSubscription?.cancel();
      await Future.delayed(const Duration(seconds: 2));

      await _communicationService.stopAudio();

      emit(EndCallState());
    }
    if (event.call.status == MeshCallStatuses.inCall) {
      if (event.call.address != null) {
        _communicationService
            .startSendAudio(MeshAddress.fromRadio(event.call.address!));
      }
    }
  }

  FutureOr<void> _endCall(EndCall event, Emitter<CallState> emit) {
    return _communicationService.stopCall();
  }

  FutureOr<void> _acceptCall(AcceptCall event, Emitter<CallState> emit) {
    if (state.call?.address == null) return null;
    _communicationService
        .acceptCall(MeshAddress.fromRadio(state.call!.address!));
  }
}
