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
     * Gets a centered object x position.
     * @param object The object to position.
     * @param base The object to position to.
     * @return `Float`
     */
    public static overload inline extern function getCenterX(object:FlxObject, base:FlxObject):Float
    {
        return base.getMidpoint().x - object.width * 0.5;
    }

    /**
     * Gets a centered camera x position.
     * @param object The object to position.
     * @param base The camera to position to.
     * @return `Float`
     */
    public static overload inline extern function getCenterX(object:FlxObject, base:FlxCamera):Float
    {
        return base.scroll.x + (base.width - object.width) * 0.5;
    }

    /**
     * Gets the centered screen x position.
     * @param object The object to position.
     * @return `Float`
     */
    public static overload inline extern function getCenterX(object:FlxObject):Float
    {
        return (FlxG.width - object.width) * 0.5;
    }

    /**
     * Gets a centered object y position.
     * @param object The object to position.
     * @param base The object to position to.
     * @return `Float`
     */
    public static overload inline extern function getCenterY(object:FlxObject, base:FlxObject):Float
    {
        return base.getMidpoint().y - object.height * 0.5;
    }

    /**
     * Gets a centered camera y position.
     * @param object The object to position.
     * @param base The camera to position to.
     * @return `Float`
     */
    public static overload inline extern function getCenterY(object:FlxObject, base:FlxCamera):Float
    {
        return base.scroll.y + (base.height - object.height) * 0.5;
    }

    /**
     * Gets the centered screen y position.
     * @param object The object to position.
     * @return `Float`
     */
    public static overload inline extern function getCenterY(object:FlxObject):Float
    {
        return (FlxG.height - object.height) * 0.5;
    }

    /**
     * Centers an object on another object.
     * @param object The object to position.
     * @param base The object to position to.
     * @param axes On what axes to center the object.
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
     * Centers an object on a camera.
     * @param object The object to position.
     * @param base The camera to position to.
     * @param axes On what axes to center the object.
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
     * Centers an object on the screen.
     * @param object The object to position.
     * @param axes On what axes to center the object.
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