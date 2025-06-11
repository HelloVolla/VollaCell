import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'kaonic_event.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class KaonicEvent<T extends KaonicEventData> {
  final String type;
  final T? data;

  KaonicEvent({required this.type, this.data});

  factory KaonicEvent.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$KaonicEventFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$KaonicEventToJson(this, toJsonT);
}

abstract class KaonicEventData {
  final String address;
  final int timestamp;

  KaonicEventData({required this.address, required this.timestamp});
}

abstract class MessageEvent extends KaonicEventData {
  final String id;
  @JsonKey(name: 'chat_id')
  final String chatId;

  MessageEvent({
    required super.address,
    required super.timestamp,
    required this.id,
    required this.chatId,
  });

  MessageEvent.empty()
      : id = '',
        chatId = '',
        super(address: '', timestamp: 0);
}

@JsonSerializable()
class MessageTextEvent extends MessageEvent {
  final String? text;

  MessageTextEvent({
    required super.address,
    required super.timestamp,
    required super.id,
    required super.chatId,
    this.text,
  });

  MessageTextEvent.withUuid({
    required String address,
    required int timestamp,
    required String chatId,
    String? text,
  }) : this(
          address: address,
          timestamp: timestamp,
          id: const Uuid().v4(),
          chatId: chatId,
          text: text,
        );

  factory MessageTextEvent.fromJson(Map<String, dynamic> json) =>
      _$MessageTextEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MessageTextEventToJson(this);
}
