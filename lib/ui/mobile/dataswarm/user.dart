import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户信息模型
class UserInfo {
  final String account;
  final String? avatar;
  final String token;
  final String username;
  final String? joinDate;

  UserInfo({
    required this.account,
    required this.username,
    required this.token,
    this.avatar,
    this.joinDate,
  });

  /// 从 JSON 构造
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      account: json['account'],
      avatar: json['avatar'],
      token: json['token'],
      username: json['username'],
      joinDate: json['joinDate'],
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'avatar': avatar,
      'token': token,
      'username': username,
      'joinDate': joinDate,
    };
  }
}

/// 用户信息管理单例
class UserInfoManager {
  UserInfoManager._privateConstructor();

  static UserInfoManager? _instance;

  static Future<UserInfoManager> get instance async {
    if (_instance == null) {
      _instance = UserInfoManager._privateConstructor();
      await _instance!.loadUserInfo();
    }
    return _instance!;
  }

  UserInfo? _currentUser;

  static const String _keyUserInfo = 'user_info';

  /// 获取当前缓存的用户信息
  UserInfo? get currentUser => _currentUser;

  /// 从 SharedPreferences 加载用户信息 (JSON)
  Future<UserInfo?> loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyUserInfo);
      if (jsonStr == null) return null;

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      _currentUser = UserInfo.fromJson(jsonMap);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  /// 保存用户信息到 SharedPreferences (JSON)
  Future<bool> saveUserInfo(UserInfo userInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(userInfo.toJson());
      await prefs.setString(_keyUserInfo, jsonStr);
      _currentUser = userInfo;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 清除 SharedPreferences 中的用户信息
  Future<bool> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserInfo);
      _currentUser = null;
      return true;
    } catch (e) {
      return false;
    }
  }
}
