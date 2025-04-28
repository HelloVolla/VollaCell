import 'package:bloc/bloc.dart';
import 'package:kaonic/data/models/settings.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState()) {
    on<UpdateFrequency>(
        (event, emit) => emit((state.copyWith(frequency: event.frequency))));
    on<UpdateChannelSpacing>(
        (event, emit) => emit((state.copyWith(channelSpacing: event.spacing))));
    on<UpdateChannel>(
        (event, emit) => emit((state.copyWith(channel: event.channel))));
    on<UpdateOption>(
        (event, emit) => emit((state.copyWith(option: event.option))));
    on<UpdateRate>((event, emit) => emit((state.copyWith(rate: event.rate))));
    on<SaveSettings>(_saveSettings);
  }

  Future<void> _saveSettings(
      SaveSettings event, Emitter<SettingsState> emit) async {}
}
