import 'package:uuid/uuid.dart';

enum SshAuthType { password, key }

class SshProfile {
  final String id;
  String label;
  String host;
  int port;
  String username;
  SshAuthType authType;
  String password;
  String privateKey;
  String passphrase;
  String jumpHost;
  int jumpPort;
  String jumpUser;
  String jumpPassword;

  SshProfile({
    String? id,
    this.label = '',
    this.host = '',
    this.port = 22,
    this.username = 'root',
    this.authType = SshAuthType.password,
    this.password = '',
    this.privateKey = '',
    this.passphrase = '',
    this.jumpHost = '',
    this.jumpPort = 22,
    this.jumpUser = 'root',
    this.jumpPassword = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'host': host,
        'port': port,
        'username': username,
        'authType': authType.name,
        'password': password,
        'privateKey': privateKey,
        'passphrase': passphrase,
        'jumpHost': jumpHost,
        'jumpPort': jumpPort,
        'jumpUser': jumpUser,
        'jumpPassword': jumpPassword,
      };

  factory SshProfile.fromJson(Map<String, dynamic> json) => SshProfile(
        id: json['id'] as String,
        label: json['label'] as String,
        host: json['host'] as String,
        port: json['port'] as int,
        username: json['username'] as String,
        authType: SshAuthType.values.firstWhere(
          (e) => e.name == json['authType'],
          orElse: () => SshAuthType.password,
        ),
        password: json['password'] as String? ?? '',
        privateKey: json['privateKey'] as String? ?? '',
        passphrase: json['passphrase'] as String? ?? '',
        jumpHost: json['jumpHost'] as String? ?? '',
        jumpPort: json['jumpPort'] as int? ?? 22,
        jumpUser: json['jumpUser'] as String? ?? 'root',
        jumpPassword: json['jumpPassword'] as String? ?? '',
      );
}
