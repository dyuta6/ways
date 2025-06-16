// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_page.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NodeItemAdapter extends TypeAdapter<NodeItem> {
  @override
  final int typeId = 0;

  @override
  NodeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NodeItem(
      id: fields[0] as String,
      title: fields[1] as String?,
      position: fields[2] as Offset,
      colorValue: fields[3] as int,
    )..connections = (fields[4] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, NodeItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.connections);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
