package game.notes;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxPoint;

import core.AssetCache;
import core.Paths;

import data.AnimationData;

using StringTools;

class NoteSplash extends FlxSprite
{
    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        antialiasing = true;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (animation.finished)
            kill();
    }

    public function getSplashFrames():FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("game/notes/NoteSplash/default"), Paths.image(Paths.xml("game/notes/NoteSplash/default")));
    }

    public function addAnimations():Void
    {
        for (i in 0 ... Note.DIRECTIONS.length)
        {
            var direction:String = Note.DIRECTIONS[i].toLowerCase();

            animation.addByPrefix('${direction} 0', 'note impact 0 ${direction}', 24.0, false);

            animation.addByPrefix('${direction} 1', 'note impact 1 ${direction}', 24.0, false);
        }
    }

    public function play(direction:Int, reversed:Bool):Void
    {
        var directionString:String = Note.DIRECTIONS[direction].toLowerCase();

        var index:Int = FlxG.random.int(0, 1);

        animation.play('${directionString} ${index}', false, reversed);
    }
}