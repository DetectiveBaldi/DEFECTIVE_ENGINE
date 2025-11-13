package game.notes;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetCache;
import core.Paths;

import data.Chart.NoteKindData;

using util.ArrayUtil;

class Note extends FlxSprite
{
    public static final DIRECTIONS:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var time:Float;

    public var direction:Int;

    public var length(default, set):Float;

    @:noCompletion
    function set_length(_length:Float):Float
    {
        length = Math.max(_length, 0.0);

        return length;
    }

    public var lane:Int;

    public var kind:NoteKindData;

    public var status:NoteStatus;

    public var playSplash:Bool;

    public var unholdTime:Float;

    public var latestTiming:Float;

    public var sustain:Sustain;

    public var strumline:Strumline;

    public var strum:Strum;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        antialiasing = true;

        frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("game/notes/Note/default"),
            Paths.image(Paths.xml("game/notes/Note/default")));

        for (i in 0 ... DIRECTIONS.length)
            animation.addByPrefix(DIRECTIONS[i].toLowerCase(), DIRECTIONS[i].toLowerCase() + "0", 24.0, false);

        time = 0.0;

        direction = 0;

        length = 0.0;

        lane = 0;

        kind = {type: "", altAnimation: false, noAnimation: false, specSing: false, charIds: null}

        status = IDLING;

        playSplash = false;

        unholdTime = 0.0;

        latestTiming = Rating.list.last().timing;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        x = strum.getMidpoint().x - width * 0.5;

        y = strum.y;

        if (status != HIT || length <= 0.0)
            y += (time - strumline.conductor.time) * (strum.downscroll ? -1 : 1) * strumline.scrollSpeed * 0.45;

        alpha = strum.alpha;
    }

    override function kill():Void
    {
        super.kill();

        sustain?.kill();

        sustain?.trail.kill();
    }

    public function isHittable():Bool
    {
        if (status != IDLING)
            return false;

        var botplay:Bool = strumline.botplay;

        if (botplay)
            return time <= strumline.conductor.time;

        return Math.abs(time - strumline.conductor.time) <= latestTiming;
    }
}

enum NoteStatus
{
    IDLING;

    HIT;

    MISSED;

    FAILING;
}