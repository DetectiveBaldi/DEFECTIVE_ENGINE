package game.events;

import flixel.tweens.FlxEase;

import game.PlayState;

class CameraZoomEvent
{
    public static function dispatch(game:PlayState, zoom:Float, duration:Float, ease:String = "linear"):Void
    {
        if (duration > 0.0)
            game.tweens.tween(game, {gameCameraZoom: zoom}, duration, {ease: Reflect.getProperty(FlxEase, ease)});
        else
            game.gameCameraZoom = zoom;
    }
}