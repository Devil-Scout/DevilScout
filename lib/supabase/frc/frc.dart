import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'value')
enum FrcMatchLevel {
  qualification('qm'),
  elimination('em'),
  quarterfinals('qf'),
  semifinals('sf'),
  finals('f');

  final String value;

  const FrcMatchLevel(this.value);
}

@JsonEnum(valueField: 'value')
enum FrcAlliance {
  blue('blue'),
  red('red');

  final String value;

  const FrcAlliance(this.value);
}
