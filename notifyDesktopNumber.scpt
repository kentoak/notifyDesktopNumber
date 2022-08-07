var sys = Application("System Events");
sys.includeStandardAdditions = true;
function file_exists(path){
	let fileManager = $.NSFileManager.defaultManager;
	return fileManager.fileExistsAtPath($(path));
}
let user="kt"//ここはあなたの$Userの名前
let fileManager = $.NSFileManager.defaultManager;
let currentUserPath = ""; 
if(user === ""){currentUserPath = fileManager.homeDirectoryForCurrentUser.fileSystemRepresentation;}
else{currentUserPath = "/Users/" + user;}
var currentSpaceNumber = -100
DELAY_SECONDS = 0.5;
function idle(){
    ObjC.bindFunction('SLSMainConnectionID', ['int', []])
    ObjC.bindFunction('SLSCopyManagedDisplaySpaces', ['id', ['int']])
    let spaces = ObjC.deepUnwrap($.SLSCopyManagedDisplaySpaces($.SLSMainConnectionID()))
    let output = {};
	let dict = $.NSMutableDictionary.alloc.initWithContentsOfFile(currentUserPath + "/Library/Preferences/com.apple.spaces.plist");
    let contents = ObjC.deepUnwrap(dict);
	let monitors = contents['SpacesDisplayConfiguration']['Management Data']['Monitors'];
    if (!file_exists(currentUserPath + "/Library/Preferences/com.apple.spaces.plist")) {
        sys.displayDialog(JSON.stringify({"Spaces_Check": "Required File(s) Not Found"}));
    }
	var activeSpaceID = -1
    activeSpaceID = spaces[0]['Current Space'].ManagedSpaceID; 
    if (activeSpaceID == -1){
        sys.displayDialog("Can't find current space")
    }
    for(let i = 0; i < monitors.length; i++){
        if(monitors[i]['Display Identifier'] == "Main"){
            const currentSpaceID = spaces[0]['Current Space'].ManagedSpaceID;
            let currentSpacePlace = 0;
            let totalSpaces = monitors[i]['Spaces'].length;
            for(let j = 0; j < monitors[i]['Spaces'].length; j++){
                if(currentSpaceID == monitors[i]['Spaces'][j]['ManagedSpaceID']){
                    currentSpacePlace = j + 1;
                }
            }
            output['Main Desktop'] = {};
            output['Main Desktop']['Current Space'] = currentSpacePlace;
            output['Main Desktop']['Total Spaces'] = totalSpaces;
        }
    }
    var app = Application.currentApplication()
    app.includeStandardAdditions = true
    if (currentSpaceNumber>0){
        if (currentSpaceNumber!==output['Main Desktop']['Current Space']){
            app.displayNotification("現在のデスクトップ："+String(JSON.stringify(output['Main Desktop']['Current Space'], null, 1))+" / "+String(JSON.stringify(output['Main Desktop']['Total Spaces'], null, 1)), {
            })
        }
    }
	currentSpaceNumber = output['Main Desktop']['Current Space']
    return DELAY_SECONDS;
}
