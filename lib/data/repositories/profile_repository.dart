import 'package:hive_flutter/hive_flutter.dart';

import '../../services/hive_service.dart';
import '../models/profile_model.dart';
import 'dummy_repository.dart';

class ProfileRepository {
  Box get _box => Hive.box(HiveService.profileBox);

  ProfileModel get() {
    final data = _box.get("profile");

    if (data == null) {
      return DummyRepository.profile;
    }

    return ProfileModel.fromMap(Map<dynamic, dynamic>.from(data));
  }

  void update(ProfileModel profile) {
    _box.put("profile", profile.toMap());
  }
}
