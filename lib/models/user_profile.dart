class UserProfile {
  String? uid;
  String? email;
  bool access;
  String? pfpURL;
  String? name;

  UserProfile({
    this.uid,
    this.email,
    this.access = false,
    this.pfpURL,
    this.name,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      access: json['access'] as bool? ?? false,
      pfpURL: json['pfpURL'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'access': access,
      'pfpURL': pfpURL,
      'name': name,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    bool? access,
    String? pfpURL,
    String? name,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      access: access ?? this.access,
      pfpURL: pfpURL ?? this.pfpURL,
      name: name ?? this.name,
    );
  }
}
