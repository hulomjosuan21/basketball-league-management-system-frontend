class ImageModel {
  String id;
  String entity_id;
  String image_url;
  String? tag;
  DateTime uploaded_at;

  ImageModel({
    required this.id,
    required this.entity_id,
    required this.image_url,
    required this.tag,
    required this.uploaded_at,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      entity_id: json['entity_id'],
      image_url: json['image_url'],
      tag: json['tag'],
      uploaded_at: DateTime.parse(json['uploaded_at']),
    );
  }
}
