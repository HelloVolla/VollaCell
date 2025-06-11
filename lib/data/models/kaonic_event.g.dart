// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kaonic_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KaonicEvent<T> _$KaonicEventFromJson<T extends KaonicEventData>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    KaonicEvent<T>(
      type: json['type'] as String,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$KaonicEventToJson<T extends KaonicEventData>(
  KaonicEvent<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'type': instance.type,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

MessageTextEvent _$MessageTextEventFromJson(Map<String, dynamic> json) =>
    MessageTextEvent(
      address: json['address'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      text: json['text'] as String?,
    );

Map<String, dynamic> _$MessageTextEventToJson(MessageTextEvent instance) =>
    <String, dynamic>{
      'address': instance.address,
      'timestamp': instance.timestamp,
      'id': instance.id,
      'chat_id': instance.chatId,
      'text': instance.text,
    };
