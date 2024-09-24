package game.events;

import flixel.FlxCamera;
import flixel.FlxG;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import game.GameState;

class CameraZoomEvent
{
    public static function dispatch(camera:String, zoom:Float, duration:Float, ease:String):Void
    {
        if (Type.getClass(FlxG.state) != GameState)
            return;

        var game:GameState = cast (FlxG.state, GameState);

        var _camera:FlxCamera = Reflect.getProperty(game, camera);

        var _ease:EaseFunction = Reflect.getProperty(FlxEase, ease);

        if (duration > 0.0)
            FlxTween.tween(camera, {zoom: zoom}, duration, {ease: _ease});
        else
            _camera.zoom = zoom;
    }
}