import 'package:equatable/equatable.dart';

import 'stat_model.dart';

class PokemonModel extends Equatable {
  const PokemonModel({
    required this.abilityList,
    required this.height,
    required this.id,
    required this.name,
    required this.statList,
    required this.typeList,
    required this.weight,
    required this.image,
  });

  final List<String> abilityList;
  final int height;
  final int id;
  final String name;
  final List<StatModel> statList;
  final List<String> typeList;
  final int weight;
  final String image;

  @override
  List<Object?> get props => [
        abilityList,
        height,
        id,
        name,
        statList,
        typeList,
        weight,
        image,
      ];
}
