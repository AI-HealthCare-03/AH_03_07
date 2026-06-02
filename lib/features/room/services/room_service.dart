import 'package:shared_preferences/shared_preferences.dart';
import '../models/room_models.dart';

class RoomService {
  static const _key = 'room_state_v1';

  Future<RoomState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return RoomState();
    try {
      return RoomState.fromJsonString(json);
    } catch (_) {
      return RoomState();
    }
  }

  Future<void> save(RoomState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.toJsonString());
  }

  Future<bool> buyItem(String itemId, int currentPoints) async {
    final def = allRoomItems.firstWhere((i) => i.id == itemId,
        orElse: () => throw Exception('아이템을 찾을 수 없습니다.'));
    if (currentPoints < def.cost) return false;
    final state = await load();
    if (!state.ownedItemIds.contains(itemId)) {
      state.ownedItemIds.add(itemId);
      await save(state);
    }
    return true;
  }
}
