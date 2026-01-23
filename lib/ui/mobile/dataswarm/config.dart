/// 全局配置类，单例模式
class SwarmProbeConfig {
  // 私有构造函数
  SwarmProbeConfig._internal();

  // 单例实例
  static final SwarmProbeConfig _instance = SwarmProbeConfig._internal();

  // 工厂构造函数，返回单例
  factory SwarmProbeConfig() => _instance;

  // 模式 dev/user
  String get mode => 'dev';

  // 服务器地址
  String get serverUrl => 'http://192.168.2.22:29357/ds';

  // login url
  String get loginUrl => '$serverUrl/auth/login';
}
