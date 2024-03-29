import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:mobx/mobx.dart';

import '../../../../generated/l10n.dart';
import '../../../../pokedex_constants/pokedex_constants_colors.dart';
import '../../../../utils/status_bar_extensions.dart';
import '../../constants/pokemon_constants_colors.dart';
import '../../constants/pokemon_constants_images.dart';
import '../../domain/exception/unknown_state_type_exception.dart';
import '../../domain/model/pokemon/pokemon_model.dart';
import '../common/error_pokemon_widget.dart';
import '../common/loading_widget.dart';
import 'pokemon_characteristics_widget.dart';
import 'pokemon_details_state.dart';
import 'pokemon_details_store.dart';
import 'pokemon_stat_list_widget.dart';
import 'pokemon_type_list_widget.dart';
import 'toggle_favorite_pokemon_state.dart';

class PokemonDetailsScreen extends StatefulWidget {
  const PokemonDetailsScreen({
    required this.pokemon,
    required this.backgroundColorCard,
    Key? key,
  }) : super(key: key);
  final PokemonModel pokemon;
  final Color backgroundColorCard;

  @override
  _PokemonDetailsScreenState createState() => _PokemonDetailsScreenState();
}

class _PokemonDetailsScreenState
    extends ModularState<PokemonDetailsScreen, PokemonDetailsStore> {
  late Color _pokemonBackgroundColorScaffoldByFirstType;
  late Color _textsColor;
  late ReactionDisposer _disposer;
  final _focusDetectorKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    controller.startPokemonDetailsScreen(widget.pokemon);
    _pokemonBackgroundColorScaffoldByFirstType = widget.pokemon
        .mapPokemonTypeToColor(widget.pokemon.colorNameByFirstType);
    _textsColor = widget.backgroundColorCard == PokemonConstantsColors.darkGray
        ? Colors.white
        : PokemonConstantsColors.darkGray;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disposer =
        reaction((_) => controller.toggleFavoritePokemonState, (toggleState) {
      if (toggleState is SuccessfullyAddFavoritePokemon) {
        _showSnackBar(S
            .of(context)
            .pokemonDetailsScreenMessageSnackBarSuccessfullyAddPokemon);
      }
      if (toggleState is SuccessfullyRemoveFavoritePokemon) {
        _showSnackBar(S
            .of(context)
            .pokemonDetailsScreenMessageSnackBarSuccessfullyRemovePokemon);
      }
      if (toggleState is FailToggleFavoritePokemon) {
        _showSnackBar(S.of(context).messageGenericStatusCodeError);
      }
    });
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _disposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FocusDetector(
        key: _focusDetectorKey,
        onFocusGained: () {
          _pokemonBackgroundColorScaffoldByFirstType.setStatusBarColor();
        },
        child: Scaffold(
          backgroundColor: _pokemonBackgroundColorScaffoldByFirstType,
          appBar: AppBar(
            backgroundColor: _pokemonBackgroundColorScaffoldByFirstType,
            elevation: 0,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.pokemon.name,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  widget.pokemon.setPokemonId(widget.pokemon.id),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          body: Observer(
            builder: (context) {
              final pokemonDetailsState = controller.pokemonDetailsState;
              if (pokemonDetailsState is LoadingPokemonDetailsState) {
                return const LoadingWidget(
                  colorCircularProgressIndicator: Colors.white,
                );
              } else if (pokemonDetailsState is InitialPokemonDetailsState ||
                  pokemonDetailsState is SuccessPokemonDetailsState) {
                return SizedBox.expand(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                        left: 8,
                        right: 8,
                        bottom: 80,
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 20,
                              ),
                              child: Image.asset(
                                PokemonConstantsImages.pokeball,
                                height: 160,
                                width: 160,
                                color: Colors.white.withOpacity(1),
                                colorBlendMode: BlendMode.modulate,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 120,
                            ),
                            child: Card(
                              elevation: 4,
                              color: widget.backgroundColorCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 32,
                                  right: 32,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            controller.togglePokemonFavorite(
                                                widget.pokemon);
                                          },
                                          child: Observer(builder: (context) {
                                            final isFavoritePokemon =
                                                controller.isPokemonFavorite;
                                            if ((isFavoritePokemon == true &&
                                                    isFavoritePokemon !=
                                                        null) ||
                                                widget.pokemon.isFavorite) {
                                              return const Image(
                                                height: 40,
                                                width: 40,
                                                image: AssetImage(
                                                  PokemonConstantsImages.heart,
                                                ),
                                              );
                                            } else {
                                              return const Image(
                                                height: 40,
                                                width: 40,
                                                image: AssetImage(
                                                  PokemonConstantsImages
                                                      .emptyHeart,
                                                ),
                                              );
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    PokemonTypeListWidget(
                                      pokemonModel: widget.pokemon,
                                    ),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    PokemonCharacteristicsWidget(
                                      pokemonHeight: widget.pokemon.height,
                                      pokemonWeight: widget.pokemon.weight,
                                      pokemonAbilityList:
                                          widget.pokemon.abilityList,
                                      backgroundColorCard:
                                          widget.backgroundColorCard,
                                      textColor: _textsColor,
                                    ),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    Center(
                                      child: Text(
                                        widget.pokemon.description,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14, color: _textsColor),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    Text(
                                      S
                                          .of(context)
                                          .pokemonDetailsScreenBaseStatsText,
                                      style: TextStyle(
                                        color:
                                            _pokemonBackgroundColorScaffoldByFirstType,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    PokemonStatListWidget(
                                      pokemonStatList: widget.pokemon.statList,
                                      pokemonBackgroundColorByFirstType:
                                          _pokemonBackgroundColorScaffoldByFirstType,
                                      textColor: _textsColor,
                                    ),
                                    const SizedBox(
                                      height: 52,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: SvgPicture.network(
                                widget.pokemon.image,
                                placeholderBuilder: (context) =>
                                    const LoadingWidget(
                                        colorCircularProgressIndicator:
                                            PokedexConstantsColors
                                                .primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (pokemonDetailsState is ErrorPokemonDetailsState) {
                return ErrorPokemonWidget(
                    message: S.of(context).messageGenericStatusCodeError,
                    tryAgain: () =>
                        controller.startPokemonDetailsScreen(widget.pokemon));
              } else {
                throw UnknownStateTypeException();
              }
            },
          ),
        ),
      );
}
