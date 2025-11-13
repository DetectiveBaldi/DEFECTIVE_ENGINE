package data;

import data.AxisData;

typedef CharacterData =
{
    var name:String;
    
    var format:String;

    var image:String;

    var ?antialiasing:Bool;

    var ?scale:AxisData;

    var ?flipX:Bool;

    var ?flipY:Bool;

    var animations:Array<AnimationData>;

    var danceSteps:Array<String>;

    var ?danceEvery:Float;

    var ?singDuration:Float;

    var cameraPoint:AxisData;

    var healthIcon:String;

    var ?healthColor:String;

    var ?deadCharacter:String;
}