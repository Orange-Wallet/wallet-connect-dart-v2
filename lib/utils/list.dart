List<T>? listFromJson<T>(
        List<dynamic>? list, T Function(Map<String, dynamic> json) fromJson) =>
    list?.map((e) => fromJson(e)).toList();

List<dynamic>? listToJson<T>(List<dynamic>? list, Object? Function(T) toJson) =>
    list?.map((e) => toJson(e)).toList();
