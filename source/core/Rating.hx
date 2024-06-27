package core;

import flixel.util.FlxColor;

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

    public function new(name:String, color:FlxColor, timing:Float, bonus:Float, score:Int, hits:Int):Void
    {
        this.name = name;

        this.color = color;

        this.timing = timing;

        this.bonus = bonus;

        this.score = score;

        this.hits = hits;
    }
}