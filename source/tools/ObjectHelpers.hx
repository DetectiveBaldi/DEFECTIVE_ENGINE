package tools;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class ObjectHelpers
{
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