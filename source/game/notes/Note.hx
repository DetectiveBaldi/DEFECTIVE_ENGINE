package game.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;

import core.AssetCache;
import core.Paths;
import data.Chart.NoteKindData;
import interfaces.IBeatDispatcher;
import music.Conductor;

using tools.AlignTools;

// TODO: Make this an `flixel.group.FlxSpriteGroup`.
// Handles animations and basic fields for a `Note` object.
// To create a custom note type, look at `game.notes.NoteSpawner.setNoteType`.
class Note extends FlxSprite
{
    public static var DIRECTIONS:Array<String> = ["left", "down", "up", "right", "circle"];

    public static var DIRECTIONS_BASE_4:Map<Int, Int> = [0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 2];

    public var beatDispatcher:IBeatDispatcher;

    public var conductor(get, never):Conductor;

    @:noCompletion
    function get_conductor():Conductor
    {
        return beatDispatcher.conductor;
    }

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
        return sustain != null;
    }

    public var lane:Int;

    public var kind:NoteKindData;

    public var status:NoteStatus;

    public var playSplash:Bool;

    public var unholdTime:Float;

    public var sustain:Sustain;

    public var trail:SustainTrail;

    public var strumline:Strumline;

    public var downscroll(get, never):Bool;

    @:noCompletion
    function get_downscroll():Bool
    {
        return strumline.downscroll;
    }

    public var strum(get, never):Strum;

    @:noCompletion
    function get_strum():Strum
    {
        var safeDir:Int = direction % strumline.keyCount;

        var v:Strum = strumline.getStrum(safeDir);

        if (v == null)
            v = strumline.getStrum(0);

        return v;
    }

    public var hitHealth:Float;

    public var missHealth:Float;

    public var skipHit:Bool;

    public var hitWindow(get, never):Float;

    @:noCompletion
    function get_hitWindow():Float
    {
        return skipHit ? Rating.earliestTiming : Rating.latestTiming;
    }

    public function new(beatDispatcher:IBeatDispatcher):Void
    {
        super();

        antialiasing = true;

        this.beatDispatcher = beatDispatcher;

        reset(0.0, 0.0);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var animToPlay:String = strumline.convertDirectionToAnim(direction).toLowerCase();

        if (animation.name != animToPlay)
            animation.play(animToPlay);

        var strumScale:Float = strumline.keyParams.strumScale;

        scale.x = strumScale;

        scale.y = strumScale;

        var hitboxScale:Float = 160.0 * strumScale;

        setSize(hitboxScale, hitboxScale);

        centerOffsets();

        x = this.getCenterX(strum);

        y = strum.y;

        if (status != HIT || length <= 0.0)
            y += (time - strumline.conductor.time) * (downscroll ? -1.0 : 1.0) * strumline.scrollSpeed * 0.45;
    }

    override function reset(x:Float, y:Float):Void
    {
        super.reset(x, y);

        time = 0.0;

        direction = 0;

        length = 0.0;

        lane = 0;

        kind = null;

        status = IDLE;

        playSplash = false;

        unholdTime = 0.0;

        sustain = null;

        trail = null;

        strumline = null;

        hitHealth = 2.0;

        missHealth = 5.0;

        skipHit = false;
    }

    public function getNoteFrames():FlxAtlasFrames
    {
        var suffix:String = kind.type;

        if (suffix == "")
            suffix = "default";

        var path:String = 'game/notes/Note/${suffix}';

        return FlxAtlasFrames.fromSparrow(AssetCache.getGraphic(path), Paths.image(Paths.xml(path)));
    }

    public function addAnimations():Void
    {
        var frames:Array<FlxFrame> = new Array<FlxFrame>();

        @:privateAccess
        animation.findByPrefix(frames, "left");

        var shortPrefix:Bool = frames.length == 0.0;

        for (i in 0 ... DIRECTIONS.length)
        {
            var direction:String = DIRECTIONS[i].toLowerCase();
            
            animation.addByPrefix(direction, shortPrefix ? "0" : '${direction}0', 24.0, false);
        }
    }

    public function isHittable():Bool
    {
        if (status != IDLE)
            return false;

        var botplay:Bool = strumline.botplay;

        if (botplay)
            return time <= strumline.conductor.time;

        return Math.abs(time - strumline.conductor.time) <= hitWindow;
    }
}

enum NoteStatus
{
    IDLE;

    HIT;

    MISS;

    FAILING;
}