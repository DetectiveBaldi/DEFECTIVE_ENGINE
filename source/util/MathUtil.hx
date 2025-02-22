package util;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.math.FlxMath;

import flixel.util.FlxAxes;

class MathUtil
{
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

    public static overload inline extern function centerTo(object:FlxObject, base:FlxObject, axes:FlxAxes = XY):FlxObject
    {
        if (axes.x)
            object.x = base.getMidpoint().x - object.width * 0.5;

        if (axes.y)
            object.y = base.getMidpoint().y - object.height * 0.5;

        return object;
    }

    public static overload inline extern function centerTo(object:FlxObject, base:FlxCamera, axes:FlxAxes = XY):FlxObject
    {
        if (axes.x)
            object.x = base.scroll.x + (base.width - object.width) * 0.5;

        if (axes.y)
            object.y = base.scroll.y + (base.height - object.height) * 0.5;

        return object;
    }

    public static overload inline extern function centerTo(object:FlxObject, axes:FlxAxes = XY):FlxObject
    {
        if (axes.x)
            object.x = FlxG.width - object.width * 0.5;

        if (axes.y)
            object.y = FlxG.height - object.height * 0.5;

        return object;
    }
}