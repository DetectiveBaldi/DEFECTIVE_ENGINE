package util;

import flixel.math.FlxMath;

class MathUtil
{
    public static function min(...numbers:Float):Float
    {
        var output:Float = FlxMath.MAX_VALUE_FLOAT;

        for (i in 0 ... numbers.length)
        {
            var number:Float = numbers[i];

            if (number < output)
                output = number;
        }

        return output;
    }

    public static function max(...numbers:Float):Float
    {
        var output:Float = FlxMath.MIN_VALUE_FLOAT;

        for (i in 0 ... numbers.length)
        {
            var number:Float = numbers[i];

            if (number > output)
                output = number;
        }

        return output;
    }

    public static function minInt(...numbers:Int):Int
    {
        return Std.int(min(for (i in 0 ... numbers.length) numbers[i]));
    }

    public static function maxInt(...numbers:Int):Int
    {
        return Std.int(max(for (i in 0 ... numbers.length) numbers[i]));
    }
}