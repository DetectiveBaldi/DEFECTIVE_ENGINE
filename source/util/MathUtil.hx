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

    public static function minInt(...integers:Int):Int
    {
        var output:Int = FlxMath.MAX_VALUE_INT;

        for (i in 0 ... integers.length)
        {
            var integer:Int = integers[i];

            if (integer < output)
                output = integer;
        }

        return output;
    }

    public static function maxInt(...integers:Int):Int
    {
        var output:Int = FlxMath.MIN_VALUE_INT;

        for (i in 0 ... integers.length)
        {
            var integer:Int = integers[i];

            if (integer > output)
                output = integer;
        }

        return output;
    }
}