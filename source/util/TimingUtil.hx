package util;

import haxe.ds.ArraySort;

import flixel.util.FlxSort;

class TimingUtil
{
    public static function sortTimed<T:TimedObject>(v:Array<T>):Void
    {
        ArraySort.sort(v, (a:T, b:T) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
    }
}

typedef TimedObject =
{
    var time:Float;
}