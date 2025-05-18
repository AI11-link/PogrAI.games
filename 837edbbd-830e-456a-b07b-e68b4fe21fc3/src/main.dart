import 'package:game/RouterManager.dart';
import 'package:field_game_level_1/src/level.dart' as lvl1;

var rt = getRouterManager();

void startLevel(int level) {
  print("START LEVEL: " + level.toString());
  // TODO implement showing levels 2 and 3
  rt.showWindow("gameplay", {'content': 'world_main.game_level_1'});
  lvl1.level(level);
}
