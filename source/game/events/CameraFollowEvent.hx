package game.events;

import flixel.math.FlxPoint;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import game.GameState;

class CameraFollowEvent
{
    public static function spawn(game:GameState, x:Float, y:Float, characterMap:String, character:String, duration:Float, ease:String):Void
    {
        switch (characterMap:String)
        {
            case "spectatorMap":
            {
                x = game.spectatorMap[character].getMidpoint().x;

                y = game.spectatorMap[character].getMidpoint().y;
            }

            case "opponentMap":
            {
                x = game.opponentMap[character].getMidpoint().x;

                y = game.opponentMap[character].getMidpoint().y;
            }

            case "playerMap":
            {
                x = game.playerMap[character].getMidpoint().x;

                y = game.playerMap[character].getMidpoint().y;
            }
        }

        if (duration > 0.0)
        {
            game.gameCamera.target = null;

            game.gameCameraTarget.setPosition(x, y);

            FlxTween.tween(game.gameCamera.scroll, {x: game.gameCameraTarget.x - game.gameCamera.width * 0.5, y: game.gameCameraTarget.y - game.gameCamera.height * 0.5}, duration,
            {
                ease: Reflect.getProperty(FlxEase, ease),

                onComplete: (tween:FlxTween) -> game.gameCamera.follow(game.gameCameraTarget, LOCKON, 0.05)
            });
        }
        else
            game.gameCameraTarget.setPosition(x, y);
    }
}