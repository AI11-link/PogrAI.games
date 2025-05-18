// import 'package:game/SaveManager.dart'; 
// import 'package:game/ScriptManager.dart'; 
// import 'package:game/test2.dart'; 

// var sv = getSaveManager(); 
// var scr = getScriptManager(); 

// void myFunc(int count, String str) { 
// 	print("TEST MANAGERS: " + count.toString() + "; " + str); 
	
// 	// Test saveManager
// 	final score = sv.getValue("score"); 
// 	print(score);
// 	sv.setValue("score", 18, isSave: true); 
// 	final newScore = sv.getValue("score"); 
// 	print(newScore);
// 	final currentTheme = sv.getSettingsValue("currentTheme"); 
// 	print(currentTheme);
// 	sv.setSettingsValue("currentTheme", "space");
// 	final newCurrentTheme = sv.getSettingsValue("currentTheme"); 
// 	print(newCurrentTheme);
// 	sv.clearData();
// 	final zeroScore = sv.getValue("score"); 
// 	print(zeroScore);
	
// 	// Test local functions
// 	print(myLocalFunc(count, str));
// 	print(myAnotherLocalFunc(count, str));
// }

// int myLocalFunc(int count, String str) {
// 	print("LOCAL FUNCTION: " + count.toString() + "; " + str); 
// 	return 5;
// }