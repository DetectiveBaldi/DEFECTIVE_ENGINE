package core;

import flixel.util.FlxColor;

@:structInit
class Rating
{
    public var name:String;

    public var color:FlxColor;

    public var timing:Float;

    public var bonus:Float;

    public var score:Int;

    public var hits:Int;

    public static function calculate(ratings:Array<Rating>, timing:Float):Rating
    {
        for (i in 0 ... ratings.length)
        {
            if (timing <= ratings[i].timing)
            {
                return ratings[i];
            }
        }

        return null;
    }
}