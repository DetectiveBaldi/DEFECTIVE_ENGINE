package util;

import flixel.math.FlxMath;

class MathUtil
{
    public static function min(...floats:Float):Float
    {
        var output:Float = FlxMath.MAX_VALUE_FLOAT;

        for (i in 0 ... floats.length)
        {
            var float:Float = floats[i];

            if (float < output)
                output = float;
        }

        return output;
    }

    public static function max(...floats:Float):Float
    {
        var output:Float = FlxMath.MIN_VALUE_FLOAT;

        for (i in 0 ... floats.length)
        {
            var float:Float = floats[i];

            if (float > output)
                output = float;
        }

        return output;
    }

    public static function minInt(...ints:Int):Int
    {
        var output:Int = FlxMath.MAX_VALUE_INT;

        for (i in 0 ... ints.length)
        {
            var int:Int = ints[i];

            if (int < output)
                output = int;
        }

        return output;
    }

    public static function maxInt(...ints:Int):Int
    {
        var output:Int = FlxMath.MIN_VALUE_INT;

        for (i in 0 ... ints.length)
        {
            var int:Int = ints[i];

            if (int > output)
                output = int;
        }

        return output;
    }
}