// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/images_url_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:dio/dio.dart';

class PlayerModel {
  late String player_id;
  late String user_id;
  String full_name;
  String gender;
  DateTime birth_date;
  String player_address;
  String jersey_name;
  double jersey_number;
  String position;
  double? height_in;
  double? weight_kg;
  late int games_played;
  late int points_scored;
  late int assists;
  late int rebounds;

  late String profile_image_url;
  late List<ImageModel> document_photos;

  UserModel user;

  late DateTime created_at;
  late DateTime updated_at;
  late MultipartFile profile_image;

  PlayerModel({
    required this.player_id,
    required this.user_id,
    required this.full_name,
    required this.gender,
    required this.birth_date,
    required this.player_address,
    required this.jersey_name,
    required this.jersey_number,
    required this.position,
    required this.height_in,
    required this.weight_kg,
    required this.games_played,
    required this.points_scored,
    required this.assists,
    required this.rebounds,
    required this.profile_image_url,
    required this.created_at,
    required this.updated_at,
    required this.user,
    this.document_photos = const [],
  });

  PlayerModel copyWith({
    String? full_name,
    String? gender,
    DateTime? birth_date,
    String? player_address,
    String? jersey_name,
    double? jersey_number,
    String? position,
    double? height_in,
    double? weight_kg,
  }) {
    return PlayerModel(
      player_id: this.player_id,
      user_id: this.user_id,
      full_name: full_name ?? this.full_name,
      gender: gender ?? this.gender,
      birth_date: birth_date ?? this.birth_date,
      player_address: player_address ?? this.player_address,
      jersey_name: jersey_name ?? this.jersey_name,
      jersey_number: jersey_number ?? this.jersey_number,
      position: position ?? this.position,
      height_in: height_in ?? this.height_in,
      weight_kg: weight_kg ?? this.weight_kg,
      games_played: this.games_played,
      points_scored: this.points_scored,
      assists: this.assists,
      rebounds: this.rebounds,
      profile_image_url: this.profile_image_url,
      user: this.user,
      created_at: this.created_at,
      updated_at: this.updated_at,
    );
  }

  Map<String, dynamic> toJsonForUpdate(PlayerModel original) {
    final Map<String, dynamic> updatedFields = {};

    if (full_name != original.full_name) updatedFields['full_name'] = full_name;
    if (gender != original.gender) updatedFields['gender'] = gender;
    if (birth_date != original.birth_date) {
      updatedFields['birth_date'] = birth_date.toIso8601String();
    }
    if (player_address != original.player_address) {
      updatedFields['player_address'] = player_address;
    }
    if (jersey_name != original.jersey_name) {
      updatedFields['jersey_name'] = jersey_name;
    }
    if (jersey_number != original.jersey_number) {
      updatedFields['jersey_number'] = jersey_number;
    }
    if (position != original.position) {
      updatedFields['position'] = position;
    }
    if (height_in != original.height_in) {
      updatedFields['height_in'] = height_in;
    }
    if (weight_kg != original.weight_kg) {
      updatedFields['weight_kg'] = weight_kg;
    }

    return updatedFields;
  }

  PlayerModel.create({
    required this.full_name,
    required this.gender,
    required this.birth_date,
    required this.player_address,
    required this.jersey_name,
    required this.jersey_number,
    required this.position,
    required this.user,
    required this.profile_image,
  });

  FormData toFormDataForCreation() {
    final userMap = user.toJsonForCreation();
    final formMap = {
      'full_name': full_name,
      'gender': gender,
      'birth_date': birth_date.toIso8601String(),
      'player_address': player_address,
      'jersey_name': jersey_name,
      'jersey_number': jersey_number,
      'position': position,
      'profile_image': profile_image,
    };

    userMap.forEach((key, value) {
      formMap['user[$key]'] = value;
    });

    return FormData.fromMap(formMap);
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      assists: json['assists'],
      birth_date: DateTime.parse(json['birth_date']),
      created_at: DateTime.parse(json['created_at']),
      full_name: json['full_name'],
      games_played: json['games_played'],
      gender: json['gender'],
      height_in: json['height_in'],
      jersey_name: json['jersey_name'],
      jersey_number: json['jersey_number'],
      player_address: json['player_address'],
      player_id: json['player_id'],
      points_scored: json['points_scored'],
      position: json['position'],
      profile_image_url: json['profile_image_url'],
      rebounds: json['rebounds'],
      updated_at: DateTime.parse(json['updated_at']),
      user: UserModel.fromJson(json['user']),
      user_id: json['user_id'],
      weight_kg: json['weight_kg'],
      document_photos: (json['document_photos'] as List)
          .map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': player_id,
      'user_id': user_id,
      'full_name': full_name,
      'gender': gender,
      'birth_date': birth_date,
      'player_address': player_address,
      'jersey_name': jersey_name,
      'jersey_number': jersey_number,
      'position': position,
      'height_in': height_in,
      'weight_kg': weight_kg,
      'games_played': games_played,
      'points_scored': points_scored,
      'assists': assists,
      'rebounds': rebounds,
      'profile_image_url': profile_image_url,
    };
  }
}
