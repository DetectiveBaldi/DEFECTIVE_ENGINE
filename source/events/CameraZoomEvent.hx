package events;

import flixel.FlxCamera;
import flixel.FlxG;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import states.GameState;

class CameraZoomEvent
{
    public static function dispatch(camera:FlxCamera, zoom:Float, duration:Float, ease:EaseFunction):Void
    {
        if (Type.getClass(FlxG.state) != GameState)
            return;

        var game:GameState = cast (FlxG.state, GameState);

        if (duration > 0.0)
            FlxTween.tween(camera, {zoom: zoom}, duration, {ease: ease});
        else
            camera.zoom = zoom;
    }
}