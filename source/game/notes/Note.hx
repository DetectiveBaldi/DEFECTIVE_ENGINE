package game.notes;

import flixel.FlxSprite;

import data.Chart.NoteKindData;

class Note extends FlxSprite
{
    public static var DIRECTIONS:Array<String> = ["left", "down", "up", "right", "circle"];

    public static var DIRECTIONS_BASE_4:Map<Int, Int> = [0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 2];

    public var time:Float;

    public var direction:Int;

    public var length(default, set):Float;

    @:noCompletion
    function set_length(length:Float):Float
    {
        length = Math.max(0.0, length);

        this.length = length;

        return length;
    }

    public var isSustain(get, never):Bool;

    @:noCompletion
    function get_isSustain():Bool
    {
        return length != 0.0;
    }

    public var lane:Int;

    public var kind:NoteKindData;

    public var status:NoteStatus;

    public var playSplash:Bool;

    public var unholdTime:Float;

    public var sustain:Sustain;

    public var strumline:Strumline;

    public var strum:Strum;

    public var hitHealth:Float;

    public var missHealth:Float;

    public var skipHit:Bool;

    public var hitWindow(get, never):Float;

    @:noCompletion
    function get_hitWindow():Float
    {
        return Rating.list[skipHit ? 1 : 0].timing;
    }

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        antialiasing = true;

        reset(x, y);
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

    override function reset(x:Float, y:Float):Void
    {
        super.reset(x, y);

        time = 0.0;

        direction = 0;

        length = 0.0;

        lane = 0;

        kind = null;

        status = IDLING;

        playSplash = false;

        unholdTime = 0.0;

        sustain = null;

        strumline = null;

        strum = null;

        hitHealth = 1.0;

        missHealth = 5.0;

        skipHit = false;
    }

    public function addAnimations():Void
    {
        for (i in 0 ... DIRECTIONS.length)
            animation.addByPrefix(DIRECTIONS[i].toLowerCase(), DIRECTIONS[i].toLowerCase() + "0", 24.0, false);
    }

    public function isHittable():Bool
    {
        if (status != IDLING)
            return false;

        var botplay:Bool = strumline.botplay;

        if (botplay)
            return time <= strumline.conductor.time;

        return Math.abs(time - strumline.conductor.time) <= hitWindow;
    }
}

enum NoteStatus
{
    IDLING;

    HIT;

    MISSED;

    FAILING;
}