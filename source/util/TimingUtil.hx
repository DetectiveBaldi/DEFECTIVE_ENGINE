package util;

import haxe.ds.ArraySort;

class TimingUtil
{
    public static function sortSimple<T:SimpleTimedObject>(arr:Array<T>):Array<T>
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

typedef SimpleTimedObject =
{
    var t:Float;
}

typedef TimedObject =
{
    var time:Float;
}