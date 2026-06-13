import 'package:uuid/uuid.dart';

enum SshAuthType { password, key }

class SshProfile {
  final String id;
  final String label;
  final String host;
  final int port;
  final String username;
  final SshAuthType authType;
  final String jumpHost;
  final int jumpPort;
  final String jumpUser;

  SshProfile({
    String? id,
    this.label = '',
    this.host = '',
    this.port = 22,
    this.username = 'root',
    this.authType = SshAuthType.password,
    this.jumpHost = '',
    this.jumpPort = 22,
    this.jumpUser = 'root',
  }) : id = id ?? const Uuid().v4();

  SshProfile copyWith({
    String? label,
    String? host,
    int? port,
    String? username,
    SshAuthType? authType,
    String? jumpHost,
    int? jumpPort,
    String? jumpUser,
  }) {
    return SshProfile(
      id: id,
      label: label ?? this.label,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      jumpHost: jumpHost ?? this.jumpHost,
      jumpPort: jumpPort ?? this.jumpPort,
      jumpUser: jumpUser ?? this.jumpUser,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'host': host,
        'port': port,
        'username': username,
        'authType': authType.name,
        'jumpHost': jumpHost,
        'jumpPort': jumpPort,
        'jumpUser': jumpUser,
      };

  factory SshProfile.fromJson(Map<String, dynamic> json) => SshProfile(
        id: json['id'] as String,
        label: json['label'] as String? ?? '',
        host: json['host'] as String? ?? '',
        port: json['port'] as int? ?? 22,
        username: json['username'] as String? ?? 'root',
        authType: SshAuthType.values.firstWhere(
          (e) => e.name == json['authType'],
          orElse: () => SshAuthType.password,
        ),
        jumpHost: json['jumpHost'] as String? ?? '',
        jumpPort: json['jumpPort'] as int? ?? 22,
        jumpUser: json['jumpUser'] as String? ?? 'root',
      );
}
