package tools.formats.charts;

import core.AssetMan;

import haxe.Json;

class StandardFormat
{
    public static function build(chartPath:String):StandardSong
    {
        var output:StandardSong = Json.parse(AssetMan.text(chartPath));
        
        return output;
    }
}

typedef StandardSong =
{
    var name:String;

    var tempo:Float;

    var speed:Float;

    var notes:Array<StandardNote>;

    var events:Array<StandardEvent>;

    var timeChanges:Array<StandardTimeChange>;
};

typedef StandardNote =
{
    var time:Float;

    var speed:Float;

    var direction:Int;

    var lane:Int;

    var length:Float;
};

typedef StandardEvent =
{
    var time:Float;

    var name:String;

    var value:Dynamic;
};

typedef StandardTimeChange =
{
    var tempo:Float;
    
    var time:Float;

    var ?step:Float;

    var ?beat:Float;

    var ?section:Float;
};