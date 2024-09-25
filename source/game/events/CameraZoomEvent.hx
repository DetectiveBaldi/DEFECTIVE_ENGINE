package game.events;

import flixel.FlxCamera;
import flixel.FlxG;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import game.GameState;

class CameraZoomEvent
{
    public static function dispatch(game:GameState, camera:String, zoom:Float, duration:Float, ease:String):Void
    {
        var _camera:FlxCamera = Reflect.getProperty(game, camera);

        var _ease:EaseFunction = Reflect.getProperty(FlxEase, ease);

        if (duration > 0.0)
            FlxTween.tween(camera, {zoom: zoom}, duration, {ease: _ease});
        else
            _camera.zoom = zoom;
    }
}