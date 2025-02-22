package game;

import flixel.FlxG;

import flixel.sound.FlxSound;

import flixel.util.FlxColor;

import core.Assets;
import core.Paths;

import data.CharacterData;

import music.MusicSubState;

class GameOverScreen extends MusicSubState
{
    public var game:PlayState;

    public var player:Character;

    public var tune:FlxSound;

    public var start:FlxSound;

    public var end:FlxSound;

    public function new(_game:PlayState):Void
    {
        super();

        game = _game;
    }

    override function create():Void
    {
        super.create();

        conductor.tempo = 100.0;

        conductor.time = -conductor.beatLength * 5.0;

        game.gameCamera.followLerp = 0.0185;

        game.players.visible = false;

        var _player:Character = game.player;

        player = new Character(conductor, 0.0, 0.0, CharacterData.get("BOYFRIEND_GAMEOVER"));

        player.strumline = game.playField.playerStrumline;

        player.skipDance = true;

        player.animation.play("start");

        player.setPosition(_player.x, _player.y);

        add(player);

        game.gameCameraTarget.setPosition(player.getMidpoint().x, player.getMidpoint().y);

        tune = FlxG.sound.load(Assets.getSound(Paths.ogg("assets/music/game/GameOverScreen/tune")), 1.0, true);

        start = FlxG.sound.load(Assets.getSound(Paths.ogg("assets/sounds/game/GameOverScreen/start"), false));

        start.play();

        end = FlxG.sound.load(Assets.getSound(Paths.ogg("assets/sounds/game/GameOverScreen/end"), false));
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (player.config.danceSteps.contains(player.animation.name))
        {
            if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
            {
                FlxG.camera.fade(FlxColor.BLACK, conductor.beatLength * 0.001 * 7.5, false, () -> FlxG.resetState());

                player.skipDance = true;

                player.animation.play("end");

                tune.stop();

                end.play();
            }
        }
    }

    override function beatHit(beat:Int):Void
    {
        super.beatHit(beat);

        if (beat == 0.0)
        {
            player.skipDance = false;

            tune.play();
        }
    }
}