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
        var output:Int = FlxMath.MAX_VALUE_INT;

        for (i in 0 ... numbers.length)
        {
            var number:Int = numbers[i];

            if (number < output)
                output = number;
        }

        return output;
    }

    public static function maxInt(...numbers:Int):Int
    {
        var output:Int = FlxMath.MIN_VALUE_INT;

        for (i in 0 ... numbers.length)
        {
            var number:Int = numbers[i];

            if (number > output)
                output = number;
        }

        return output;
    }
}