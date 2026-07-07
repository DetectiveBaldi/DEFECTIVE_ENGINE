package game;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

import core.AssetCache;
import core.Paths;
import data.CharacterData;
import data.Chart;

import interfaces.IBeatDispatcher;
import interfaces.ISequenceHandler;
import music.Conductor;

using tools.ObjectHelpers;

class GameOverScreen extends FlxSubState implements ISequenceHandler implements IBeatDispatcher
{
    public var tweens:FlxTweenManager;

    public var timers:FlxTimerManager;

    public var conductor:Conductor;

    public var game:PlayState;

    public var gameCamera(get, never):FlxCamera;

    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return game.gameCamera;
    }

    public var cameraPoint(get, never):FlxObject;

    @:noCompletion
    function get_cameraPoint():FlxObject
    {
        return game.cameraPoint;
    }

    public var player(get, never):Character;

    @:noCompletion
    function get_player():Character
    {
        return game.player;
    }

    public var deadCharacter:Character;

    public var tune:FlxSound;

    public var start:FlxSound;

    public var end:FlxSound;

    public function new(game:PlayState):Void
    {
        super();

        this.game = game;
    }

    override function create():Void
    {
        super.create();

        conductor = new Conductor();

        conductor.addListeners(this);

        var timingPoints:Array<TimingPointData> = new Array<TimingPointData>();

        timingPoints.push({time: 0.0, tempo: 100.0, beatsPerMeasure: 4});

        conductor.setTimingPoints(timingPoints);

        conductor.time = -conductor.measureLength * 1.25;

        conductor.updateSteps();

        add(conductor);

        gameCamera.followLerp = 0.02;

        cameraPoint.centerTo(player);

        deadCharacter = new Character(this, 0.0, 0.0, Character.getConfig(player.deadCharacter));

        deadCharacter.skipDance = true;

        deadCharacter.animation.play("start");

        deadCharacter.centerTo(player);

        add(deadCharacter);

        tune = FlxG.sound.load(AssetCache.getMusic("game/GameOverScreen/tune"), 1.0, true);

        start = FlxG.sound.load(AssetCache.getSound("game/GameOverScreen/start"));

        start.play();

        end = FlxG.sound.load(AssetCache.getSound("game/GameOverScreen/end"));
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        conductor.updateSteps();

        if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && deadCharacter.animation.name != "end")
            pressEnter();
    }

    public function stepHit(step:Int):Void
    {

    }

    public function beatHit(beat:Int):Void
    {
        if (beat == 0.0)
        {
            deadCharacter.skipDance = false;

            tune.play();
        }
    }

    public function measureHit(measure:Int):Void
    {

    }

    public function pressEnter():Void
    {
        gameCamera.fade(FlxColor.BLACK, conductor.beatLength * 0.001 * 6.0, false, FlxG.resetState);

        conductor.removeListeners(this);

        deadCharacter.skipDance = true;

        deadCharacter.animation.play("end");

        tune.stop();

        end.play();
    }
}