package game.events;

import flixel.FlxCamera;

import flixel.tweens.FlxEase;

import game.PlayState;

class SetCamZoomEvent
{
    public static function dispatch(game:PlayState, zoom:Float, duration:Float, mode:String, ease:String):Void
    {
        if (mode != "direct")
            zoom *= game.stage.zoom;

        game.tweens.cancelTweensOf(game, ["gameCameraZoom"]);

        if (duration > 0.0)
        {
            var easeRef:(Float)->Float = Reflect.getProperty(FlxEase, ease);

            game.tweens.tween(game, {gameCameraZoom: zoom}, game.conductor.stepLength * duration * 0.001, {ease: easeRef});
        }
        else
        {
            game.gameCamera.zoom = zoom;

            game.gameCameraZoom = zoom;
        }
    }
}