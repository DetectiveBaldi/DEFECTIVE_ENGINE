package tools.formats.charts;

import haxe.Json;

class ClassicFormat
{
    public static function build(chartPath:String):ClassicSong
    {
        var output:ClassicSong = Json.parse(#if html5 openfl.utils.Assets.getText(chartPath) #else sys.io.File.getContent(chartPath) #end);
        
        return output;
    }
}

typedef ClassicSong =
{
    var name:String;

    var tempo:Float;

    var speed:Float;

    var notes:Array<ClassicNote>;

    var events:Array<ClassicEvent>;

    var timeChanges:Array<ClassicTimeChange>;
};

typedef ClassicNote =
{
    var time:Float;

    var speed:Float;

    var direction:Int;

    var lane:Int;

    var length:Float;
};

typedef ClassicEvent =
{
    var time:Float;

    var name:String;

    var value:Dynamic;
};

typedef ClassicTimeChange =
{
    var tempo:Float;
    
    var time:Float;

    var ?step:Float;

    var ?beat:Float;

    var ?section:Float;
};