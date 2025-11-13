package util;

import haxe.ds.ArraySort;

import music.Conductor;

class TimingUtil
{
    public static function sortTimed<T:TimedObject>(v:Array<T>):Void
    {
        ArraySort.sort(v, (a:T, b:T) -> Math.floor(a.time - b.time));
    }
}

typedef TimedObject =
{
    var time:Float;
}