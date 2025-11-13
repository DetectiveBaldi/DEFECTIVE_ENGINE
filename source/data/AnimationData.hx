package data;

typedef AnimationData =
{
    var name:String;
    
    var prefix:String;
    
    var ?indices:Array<Int>;
    
    var ?frameRate:Float;
    
    var ?looped:Bool;
    
    var ?flipX:Bool;
    
    var ?flipY:Bool;

    var ?offset:AxisData;
}