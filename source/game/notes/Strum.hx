package game.notes;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetCache;
import core.Options;
import core.Paths;

import music.Conductor;

using StringTools;

class Strum extends FlxSprite
{
    public var beatDispatcher:IBeatDispatcher;

    public var conductor(get, never):Conductor;

    @:noCompletion
    function get_conductor():Conductor
    {
        return beatDispatcher?.conductor;
    }

    public var strumline:Strumline;

    public var direction:Int;

    public var downscroll:Bool;

    public var holdTimer:Float;

    public function new(x:Float = 0.0, y:Float = 0.0, beatDispatcher:IBeatDispatcher):Void
    {
        super(x, y);

        this.beatDispatcher = beatDispatcher;

        antialiasing = true;

        frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("game/notes/Strum/default", false),
            Paths.image(Paths.xml("game/notes/Strum/default")));
        
        for (i in 0 ... Note.DIRECTIONS.length)
        {
            var direction:String = Note.DIRECTIONS[i].toLowerCase();

            animation.addByPrefix('${direction}Static', '${direction}Static0', 24.0, false);

            animation.addByPrefix('${direction}Press', '${direction}Press0', 24.0, false);
            
            animation.addByPrefix('${direction}Confirm', '${direction}Confirm0', 24.0, false);
        }

        direction = 0;

        downscroll = Options.downscroll;

        holdTimer = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor == null)
            return;

        if ((animation.name ?? "").endsWith("Confirm"))
        {
            holdTimer += elapsed;

            if (holdTimer >= conductor.beatLength * 0.25 * 0.001)
            {
                holdTimer = 0.0;

                if (!strumline.botplay)
                    animation.play('${strumline.keyParams.keys[direction].toLowerCase()}Press');
            }
        }
        else
            holdTimer = 0.0;
    }
}