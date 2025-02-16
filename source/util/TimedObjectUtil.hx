package util;

import haxe.ds.ArraySort;

class TimedObjectUtil
{
    public static function sortRaw<T:RawTimedObject>(arr:Array<T>):Array<T>
    {
        ArraySort.sort(arr, (a:T, b:T) -> Std.int(a.t - b.t));
        
        return arr;
    }

    public static function sort<T:TimedObject>(arr:Array<T>):Array<T>
    {
        ArraySort.sort(arr, (a:T, b:T) -> Std.int(a.time - b.time));

        return arr;
    }
}

typedef RawTimedObject =
{
    var t:Float;
}

typedef TimedObject =
{
    var time:Float;
}