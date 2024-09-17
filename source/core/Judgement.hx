package core;

import flixel.util.FlxColor;

@:structInit
class Judgement
{
    public var name:String;

    public var color:FlxColor;

    public var timing:Float;

    public var bonus:Float;

    public var score:Int;

    public var hits:Int;

    public static function guage(judgements:Array<Judgement>, timing:Float):Null<Judgement>
    {
        for (i in 0 ... judgements.length)
        {
            var judgement:Judgement = judgements[i];

            if (timing <= judgement.timing)
                return judgement;
        }

        return null;
    }
}