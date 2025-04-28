// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_bloc.dart';

class SettingsState {
  SettingsState({
    this.frequency = '',
    this.channelSpacing = '',
    this.channel,
    this.option,
    this.rate,
  });
  final String frequency;
  final int? channel;
  final String channelSpacing;
  final OFDMOptions? option;
  final OFDMRate? rate;

  SettingsState copyWith({
    String? frequency,
    int? channel,
    String? channelSpacing,
    OFDMOptions? option,
    OFDMRate? rate,
  }) {
    return SettingsState(
      frequency: frequency ?? this.frequency,
      channel: channel ?? this.channel,
      channelSpacing: channelSpacing ?? this.channelSpacing,
      option: option ?? this.option,
      rate: rate ?? this.rate,
    );
  }
}
