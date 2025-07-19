class PlayerModel {
  final String player_id;
  final String user_id;
  final String full_name;
  final String gender;
  final String birth_date;
  final String player_address;
  final String jersey_name;
  final double? jersey_number;
  final String position;
  final double? height_in;
  final double? weight_kg;
  final int games_played;
  final int points_scored;
  final int assists;
  final int rebounds;
  final String profile_image_url;
  final DateTime created_at;
  final DateTime updated_at;

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
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      player_id: json['player_id'],
      user_id: json['user_id'],
      full_name: json['full_name'],
      gender: json['gender'],
      birth_date: json['birth_date'],
      player_address: json['player_address'],
      jersey_name: json['jersey_name'],
      jersey_number: (json['jersey_number'] as num?)?.toDouble(),
      position: json['position'],
      height_in: (json['height_in'] as num?)?.toDouble(),
      weight_kg: (json['weight_kg'] as num?)?.toDouble(),
      games_played: json['games_played'],
      points_scored: json['points_scored'],
      assists: json['assists'],
      rebounds: json['rebounds'],
      profile_image_url: json['profile_image_url'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }
}

class PlayerTeamWrapper {
  final String player_team_id;
  final String player_id;
  final String team_id;
  final DateTime created_at;
  final DateTime updated_at;
  final PlayerModel player;

  PlayerTeamWrapper({
    required this.player_team_id,
    required this.player_id,
    required this.team_id,
    required this.created_at,
    required this.updated_at,
    required this.player,
  });

  factory PlayerTeamWrapper.fromJson(Map<String, dynamic> json) {
    return PlayerTeamWrapper(
      player_team_id: json['player_team_id'],
      player_id: json['player_id'],
      team_id: json['team_id'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
      player: PlayerModel.fromJson(json['player']),
    );
  }
}