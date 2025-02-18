import 'package:chronolapse/backend/settings_storage/settings_storage.dart';
import 'package:flutter/material.dart';

class ProjectPrefix {
  final String _prefix;
  String prefix() => _prefix;

  const ProjectPrefix(this._prefix);
  const ProjectPrefix.none() : _prefix = "";
}

abstract class PersistentSetting {
  const PersistentSetting();

  Widget getWidget();
}

class DividerNoSetting extends PersistentSetting {
  const DividerNoSetting();

  @override
  Widget getWidget() {
    return const Divider();
  }
}

class ToggleSetting extends PersistentSetting {
  final String _key;
  final bool _default;

  const ToggleSetting(this._key, this._default);

  bool getValue() {
    return SharedStorage.sp().getBool(_key) ?? _default;
  }

  Future<void> setValue(bool value) async {
    await SharedStorage.sp().setBool(_key, value);
  }

  @override
  Widget getWidget() {
    // TODO: implement getWidget
    throw UnimplementedError();
  }
}