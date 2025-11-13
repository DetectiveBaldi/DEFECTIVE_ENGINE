package game;

import flixel.FlxG;
import flixel.FlxSubState;

import flixel.sound.FlxSound;

import flixel.util.FlxColor;

import core.AssetCache;
import core.Paths;

import data.CharacterData;

import music.Conductor;

using util.MathUtil;

class GameOverScreen extends FlxSubState implements IBeatDispatcher
{
    public var conductor:Conductor;

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

        conductor = new Conductor();

        conductor.onStepHit.add(stepHit);

        conductor.onBeatHit.add(beatHit);

        conductor.onMeasureHit.add(measureHit);

        conductor.timingPoints.push({time: 0.0, tempo: 100.0, beatsPerMeasure: 4});

        conductor.calibrateTimingPoints();

        conductor.update(-conductor.beatLength * 5.0);

        game.gameCamera.followLerp = 0.0185;

        game.players.visible = false;

        player = new Character(this, 0.0, 0.0, Character.getConfig(game.player.deadCharacter));

        player.skipDance = true;

        player.animation.play("start");

        player.centerTo();

        add(player);

        tune = FlxG.sound.load(AssetCache.getMusic("game/GameOverScreen/tune"), 1.0, true);

        start = FlxG.sound.load(AssetCache.getSound("game/GameOverScreen/start"));

        start.play();

        end = FlxG.sound.load(AssetCache.getSound("game/GameOverScreen/end"));
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var timeToUpdateTo:Float = conductor.time + 1000.0 * elapsed;
        
        conductor.update(timeToUpdateTo);

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

    public function stepHit(step:Int):Void
    {

    }

    public function beatHit(beat:Int):Void
    {
        if (beat == 0.0)
        {
            player.skipDance = false;

            tune.play();
        }
    }

    public function measureHit(measure:Int):Void
    {

    }
}