
import '../models/user_model.dart';

class UserService {
  // محاكاة قاعدة بيانات
  static final List<UserModel> _users = [
    UserModel(
      id: 1,
      name: 'أحمد محمد',
      email: 'ahmed@example.com',
      phone: '+966501234567',
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    ),
    UserModel(
      id: 2,
      name: 'فاطمة علي',
      email: 'fatima@example.com',
      phone: '+966507654321',
      createdAt: DateTime.now().subtract(Duration(days: 15)),
    ),
    UserModel(
      id: 3,
      name: 'محمد عبدالله',
      email: 'mohammed@example.com',
      phone: '+966509876543',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  Future<List<UserModel>> getUsers() async {
    // محاكاة تأخير الشبكة
    await Future.delayed(Duration(seconds: 1));
    return List.from(_users);
  }

  Future<UserModel?> getUserById(int id) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> getCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 500));
    // محاكاة المستخدم الحالي
    return _users.first;
  }

  Future<UserModel> createUser(UserModel user) async {
    await Future.delayed(Duration(milliseconds: 800));
    final newUser = user.copyWith(
      id: _users.length + 1,
      createdAt: DateTime.now(),
    );
    _users.add(newUser);
    return newUser;
  }

  Future<UserModel> updateUser(UserModel user) async {
    await Future.delayed(Duration(milliseconds: 800));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      return user;
    }
    throw Exception('المستخدم غير موجود');
  }

  Future<bool> deleteUser(int id) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _users.indexWhere((user) => user.id == id);
    if (index != -1) {
      _users.removeAt(index);
      return true;
    }
    return false;
  }

  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _users
        .where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
