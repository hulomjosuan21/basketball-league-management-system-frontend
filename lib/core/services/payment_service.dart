import 'package:bogoballers/core/network/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static Future<void> startSubmissionPayment({
    required String submissionType,
    required String submissionId,
    required String leagueId,
    required String categoryId,
    required double amount,
  }) async {
    final dio = DioClient().client;

    final response = await dio.post(
      "/payment/start",
      data: {
        "submission_type": submissionType,
        "submission_id": submissionId,
        "league_id": leagueId,
        "category_id": categoryId,
        "amount": amount,
      },
    );

    final redirectUrl =
        response.data["redirect"] ?? response.data["payload"]?["checkout_url"];

    if (redirectUrl != null) {
      final uri = Uri.parse(redirectUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not open payment URL.";
      }
    } else {
      throw "Invalid response from payment server.";
    }
  }
}
