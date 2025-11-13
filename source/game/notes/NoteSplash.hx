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

        frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("game/notes/NoteSplash/default"), Paths.image(Paths.xml
            ("game/notes/NoteSplash/default")));

        for (i in 0 ... Note.DIRECTIONS.length)
        {
            var direction:String = Note.DIRECTIONS[i].toLowerCase();

            for (j in 0 ... 2)
                animation.addByPrefix('${direction}${j}', 'note impact ${j} ${direction}', 24.0, false);
        }

        animation.onFinish.add((_:String) -> kill());

        scale.set(0.7, 0.7);

        updateHitbox();
    }

    public function play(direction:Int, reversed:Bool):Void
    {
        animation.play(Note.DIRECTIONS[direction].toLowerCase() + FlxG.random.int(0, 1), false, reversed);
    }
}