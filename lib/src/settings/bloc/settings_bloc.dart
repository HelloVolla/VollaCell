import 'package:bloc/bloc.dart';
import 'package:kaonic/data/models/settings.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState()) {
    on<SettingsEvent>((event, emit) {
    });
  }
}
