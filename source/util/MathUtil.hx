package util;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.math.FlxMath;

import flixel.util.FlxAxes;

class MathUtil
{
    @:inheritDoc(Math.abs)
    public static function absInt(val:Float):Int
    {
        return Std.int(Math.abs(val));
    }

    @:inheritDoc(Math.min)
    public static function minInt(...vals:Int):Int
    {
        var output:Int = FlxMath.MAX_VALUE_INT;

        for (i in 0 ... vals.length)
        {
            var val:Int = vals[i];

            if (val < output)
                output = val;
        }

        return output;
    }

    @:inheritDoc(Math.max)
    public static function maxInt(...vals:Int):Int
    {
        var output:Int = FlxMath.MIN_VALUE_INT;

        for (i in 0 ... vals.length)
        {
            var val:Int = vals[i];

            if (val > output)
                output = val;
        }

        return output;
    }

    @:inheritDoc(flixel.math.FlxMath.bound)
    public static function boundInt(val:Float, ?min:Float, ?max:Float):Int
    {
        return Std.int(FlxMath.bound(val, min, max));
    }

    /**
     * Gets the aligned x axis on an object-to-object level.
     * @param object The object to position.
     * @param base The anchor object.
     * @return `Float`
     */
    public static overload inline extern function getCenterX(object:FlxObject, base:FlxObject):Float
    {
        return base.getMidpoint().x - object.width * 0.5;
    }

    /**
     * Gets the aligned x axis on an object-to-camera level.
     * @param object The object to position.
     * @param base The anchor camera.
     * @return `Float`
     */
    public static overload inline extern function getCenterX(object:FlxObject, base:FlxCamera):Float
    {
        return base.scroll.x + (base.width - object.width) * 0.5;
    }

    /**
     * Gets the aligned x axis on an object-to-screen level.
     * @param object The object to position.
     * @return `Float`
     */
    public static overload inline extern function getCenterX(object:FlxObject):Float
    {
        return (FlxG.width - object.width) * 0.5;
    }

    /**
     * Gets the aligned y axis on an object-to-object level.
     * @param object The object to position.
     * @param base The anchor object.
     * @return `Float`
     */
    public static overload inline extern function getCenterY(object:FlxObject, base:FlxObject):Float
    {
        return base.getMidpoint().y - object.height * 0.5;
    }

    /**
     * Gets the aligned y axis on an object-to-camera level.
     * @param object The object to position.
     * @param base The anchor camera.
     * @return `Float`
     */
    public static overload inline extern function getCenterY(object:FlxObject, base:FlxCamera):Float
    {
        return base.scroll.y + (base.height - object.height) * 0.5;
    }

    /**
     * Gets the aligned y axis on an object-to-screen level.
     * @param object The object to position.
     * @return `Float`
     */
    public static overload inline extern function getCenterY(object:FlxObject):Float
    {
        return (FlxG.height - object.height) * 0.5;
    }

    /**
     * Centers an object on an object-to-object level.
     * @param object The object to position.
     * @param base The anchor object.
     * @param axes Do you want to center on the x axis, the y axis, or both?
     * @return `FlxObject`
     */
    public static overload inline extern function centerTo(object:FlxObject, base:FlxObject, axes:FlxAxes = XY):FlxObject
    {
        if (axes.x)
            object.x = getCenterX(object, base);

        if (axes.y)
            object.y = getCenterY(object, base);

        return object;
    }

    /**
     * Centers an object on an object-to-camera level.
     * @param object The object to position.
     * @param base The anchor camera.
     * @param axes Do you want to center on the x axis, the y axis, or both?
     * @return `FlxObject`
     */
    public static overload inline extern function centerTo(object:FlxObject, base:FlxCamera, axes:FlxAxes = XY):FlxObject
    {
        if (axes.x)
            object.x = getCenterX(object, base);

        if (axes.y)
            object.y = getCenterY(object, base);

        return object;
    }

    /**
     * Centers an object on an object-to-screen level.
     * @param object The object to position.
     * @param axes Do you want to center on the x axis, the y axis, or both?
     * @return `FlxObject`
     */
    public static overload inline extern function centerTo(object:FlxObject, axes:FlxAxes = XY):FlxObject
    {
        if (axes.x)
            object.x = getCenterX(object);

        if (axes.y)
            object.y = getCenterY(object);

        return object;
    }
}