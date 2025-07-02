import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class PlayerServices {
  Future<ApiResponse> createNewPlayer(PlayerModel player) async {
    final api = DioClient().client;
    Response response = await api.post(
      '/entity/create-new/player',
      data: player.toFormDataForCreation(),
    );
    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);
    return apiResponse;
  }

  static Future<ApiResponse> updatePlayer({
    required String player_id,
    required Map<String, dynamic> json,
  }) async {
    final api = DioClient().client;
    Response response = await api.put(
      '/player/update/profile/${player_id}',
      data: json,
    );
    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);
    return apiResponse;
  }
}
