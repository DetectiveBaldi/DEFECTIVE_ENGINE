package game.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;

import core.AssetCache;
import core.Paths;
import data.Chart;
import interfaces.IBeatDispatcher;
import music.Conductor;

using tools.AlignTools;

/**
 * Handles functionality for a basic note.
 * To create a custom note type, look at `game.notes.NoteSpawner` and add your type to `resolveNoteClass` and `noteFactory`.
 */
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

    public var data:NoteData;

    public var time(get, never):Float;

    @:noCompletion
    function get_time():Float
    {
        return data.time;
    }

    public var direction(get, never):Int;

    @:noCompletion
    function get_direction():Int
    {
        return data.direction;
    }

    public var length(get, never):Float;

    @:noCompletion
    function get_length():Float
    {
        return data.length;
    }

    public var lane(get, never):Int;

    @:noCompletion
    function get_lane():Int
    {
        return data.lane;
    }

    public var kind(get, never):NoteKindData;

    @:noCompletion
    function get_kind():NoteKindData
    {
        return data.kind;
    }

    public var isSustain(get, never):Bool;

    @:noCompletion
    function get_isSustain():Bool
    {
        return length != 0.0;
    }

    public var renderTime:Float;

    public var renderLength(default, set):Float;

    @:noCompletion
    function set_renderLength(v:Float):Float
    {
        renderLength = Math.max(0.0, v);

        return renderLength;
    }

    public var status:NoteStatus;

    public var playSplash:Bool;

    public var unholdTime:Float;

    public var hitHealth:Float;

    public var missHealth:Float;

    public var skipHit:Bool;

    public var hitWindow(get, never):Float;

    @:noCompletion
    function get_hitWindow():Float
    {
        return skipHit ? Rating.earliestTiming : Rating.latestTiming;
    }

    public var sustain:Sustain;

    public var trail:SustainTrail;

    public var strumline:Strumline;

    public var strum(get, never):Strum;

    @:noCompletion
    function get_strum():Strum
    {
        return strumline.getStrum(direction);
    }

    public var downscroll(get, never):Bool;

    @:noCompletion
    function get_downscroll():Bool
    {
        return strumline.downscroll;
    }

    public function new(beatDispatcher:IBeatDispatcher, data:NoteData):Void
    {
        super();

        antialiasing = true;

        this.beatDispatcher = beatDispatcher;

        this.data = data;

        frames = getNoteFrames();

        addAnimations();

        renderTime = data.time;

        renderLength = data.length;

        status = IDLE;

        playSplash = false;

        unholdTime = 0.0;

        hitHealth = 2.0;

        missHealth = 5.0;

        skipHit = false;
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
            y += (renderTime - conductor.time) * (downscroll ? -1.0 : 1.0) * strumline.scrollSpeed * 0.45;
    }

    override function revive():Void
    {
        super.revive();

        renderTime = data.time;

        renderLength = data.length;

        status = IDLE;

        playSplash = false;

        unholdTime = 0.0;

        sustain = null;

        trail = null;
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
            
            animation.addByPrefix(direction, shortPrefix ? "0" : '${direction}0', 24.0);
        }
    }

    public function isHittable():Bool
    {
        if (status != IDLE)
            return false;

        if (strumline.botplay)
            return time <= conductor.time;

        return Math.abs(time - conductor.time) <= hitWindow;
    }
}

enum NoteStatus
{
    IDLE;

    HIT;

    MISS;

    FAILING;
}