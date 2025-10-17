// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceModelAdapter extends TypeAdapter<PriceModel> {
  @override
  final int typeId = 0;

  @override
  PriceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceModel(
      bifPerKg: fields[0] as double,
      usdPerLb: fields[1] as double,
      change24h: fields[2] as double,
      change7d: fields[3] as double,
      trend: fields[4] as String,
      lastUpdated: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PriceModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bifPerKg)
      ..writeByte(1)
      ..write(obj.usdPerLb)
      ..writeByte(2)
      ..write(obj.change24h)
      ..writeByte(3)
      ..write(obj.change7d)
      ..writeByte(4)
      ..write(obj.trend)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AIPredictionModelAdapter extends TypeAdapter<AIPredictionModel> {
  @override
  final int typeId = 1;

  @override
  AIPredictionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIPredictionModel(
      prediction: fields[0] as String,
      confidence: fields[1] as String,
      recommendation: fields[2] as String,
      predictedChange: fields[3] as double,
      reasoning: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AIPredictionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.prediction)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.recommendation)
      ..writeByte(3)
      ..write(obj.predictedChange)
      ..writeByte(4)
      ..write(obj.reasoning);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIPredictionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RegionModelAdapter extends TypeAdapter<RegionModel> {
  @override
  final int typeId = 2;

  @override
  RegionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RegionModel(
      id: fields[0] as int,
      name: fields[1] as String,
      farmers: fields[2] as int,
      priceBif: fields[3] as double,
      alertLevel: fields[4] as String,
      temp: fields[5] as double,
      conditions: fields[6] as String,
      coordinates: (fields[7] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, RegionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.farmers)
      ..writeByte(3)
      ..write(obj.priceBif)
      ..writeByte(4)
      ..write(obj.alertLevel)
      ..writeByte(5)
      ..write(obj.temp)
      ..writeByte(6)
      ..write(obj.conditions)
      ..writeByte(7)
      ..write(obj.coordinates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DashboardModelAdapter extends TypeAdapter<DashboardModel> {
  @override
  final int typeId = 3;

  @override
  DashboardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardModel(
      price: fields[0] as PriceModel,
      aiPrediction: fields[1] as AIPredictionModel,
      weather: (fields[2] as Map).cast<String, dynamic>(),
      recentEvents: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      alerts: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      timestamp: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DashboardModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.price)
      ..writeByte(1)
      ..write(obj.aiPrediction)
      ..writeByte(2)
      ..write(obj.weather)
      ..writeByte(3)
      ..write(obj.recentEvents)
      ..writeByte(4)
      ..write(obj.alerts)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
