import '../../../../features/auth/data/models/user_model.dart';

class UserListResponse {
  final List<UserModel> items;
  final int page;
  final int totalPages;
  final int totalItems;
  final Map<String, int>? counts;

  const UserListResponse({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
    this.counts,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    Map<String, int>? parsedCounts;
    if (json['counts'] is Map) {
      final rawCounts = json['counts'] as Map<String, dynamic>;
      parsedCounts = rawCounts.map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    return UserListResponse(
      items: rawItems
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      totalItems: json['totalItems'] as int? ?? rawItems.length,
      counts: parsedCounts,
    );
  }
}
