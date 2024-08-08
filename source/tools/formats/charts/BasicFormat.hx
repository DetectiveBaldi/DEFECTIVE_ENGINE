package tools.formats.charts;

import haxe.Json;

class BasicFormat
{
    public static function build(chartPath:String):BasicSong
    {
        var output:BasicSong = Json.parse(#if html5 openfl.utils.Assets.getText(chartPath) #else sys.io.File.getContent(chartPath) #end);
        
        return output;
    }
}

typedef BasicSong =
{
    var name:String;

    var tempo:Float;

    var speed:Float;

    var notes:Array<BasicNote>;

    var events:Array<BasicEvent>;

    var timeChanges:Array<BasicTimeChange>;
};

typedef BasicNote =
{
    var time:Float;

    var speed:Float;

    var direction:Int;

    var lane:Int;

    var length:Float;
};

typedef BasicEvent =
{
    var time:Float;

    var name:String;

    var value:Dynamic;
};

typedef BasicTimeChange =
{
    var tempo:Float;
    
    var time:Float;

    var ?step:Float;

    var ?beat:Float;

    var ?section:Float;
};