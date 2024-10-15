package game;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.input.keyboard.FlxKey;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import core.AssetMan;
import core.Conductor;
import core.Inputs;
import core.Paths;

import game.notes.Note;

using StringTools;

class Character extends FlxSprite
{
    /**
     * A structure containing fundamentals about this `Character`, such as name, texture-related information, and more.
     */
    public var data:CharacterData;

    public var danceSteps:Array<String>;

    public var danceStep:Int;

    public var danceInterval:Float;

    public var singDuration:Float;

    public var skipDance:Bool;

    public var skipSing:Bool;

    public var singCount:Float;

    public var role:CharacterRole;

    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(conductor:Conductor):Conductor
    {
        if (this.conductor != null)
            this.conductor.beatHit.remove(beatHit);

        if (conductor != null)
            conductor.beatHit.add(beatHit);

        return this.conductor = conductor;
    }

    public var inputs:Array<Input>;

    public function new(x:Float = 0.0, y:Float = 0.0, path:String, role:CharacterRole, conductor:Conductor):Void
    {
        super(x, y);
        
        data = Json.parse(AssetMan.text(Paths.json(path)));

        switch (data.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(data.png), true), Paths.xml(data.xml));

            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(data.png), true), Paths.xml(data.xml));
        }

        antialiasing = data.antialiasing ?? true;

        scale.set(data.scale?.x ?? 1.0, data.scale?.y ?? 1.0);

        updateHitbox();

        flipX = data.flipX ?? false;

        flipY = data.flipY ?? false;

        for (i in 0 ... data.animations.length)
        {
            var _animation:CharacterFrameSet = data.animations[i];

            if (animation.exists(_animation.name))
                throw "game.Character: Invalid animation name!";

            if (_animation.indices.length > 0)
            {
                animation.addByIndices
                (
                    _animation.name,

                    _animation.prefix,

                    _animation.indices,

                    "",

                    _animation.frameRate ?? 24.0,

                    _animation.looped ?? false,

                    _animation.flipX ?? false,

                    _animation.flipY ?? false
                );
            }
            else
            {
                animation.addByPrefix
                (
                    _animation.name,

                    _animation.prefix,

                    _animation.frameRate ?? 24.0,

                    _animation.looped ?? false,

                    _animation.flipX ?? false,

                    _animation.flipY ?? false
                );
            }
        }

        danceSteps = data.danceSteps;

        danceStep = 0;

        danceInterval = data.danceInterval ?? 1.0;

        singDuration = data.singDuration ?? 8.0;

        skipDance = false;

        skipSing = false;

        singCount = 0.0;

        this.role = role;

        dance();

        animation.finish();

        this.conductor = conductor;

        inputs =
        [
            {name: "NOTE:LEFT", keys: [FlxKey.Z, FlxKey.A, FlxKey.LEFT]},

            {name: "NOTE:DOWN", keys: [FlxKey.X, FlxKey.S, FlxKey.DOWN]},

            {name: "NOTE:UP", keys: [FlxKey.PERIOD, FlxKey.W, FlxKey.UP]},

            {name: "NOTE:RIGHT", keys: [FlxKey.SLASH, FlxKey.D, FlxKey.RIGHT]}
        ];
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor == null)
            return;

        if (Inputs.inputsJustPressed(inputs) && role == PLAYABLE)
            singCount = 0.0;

        if (animation.name?.startsWith("Sing"))
        {
            singCount += elapsed;

            var requiredTime:Float = singDuration * ((conductor.crotchet * 0.25) * 0.001);

            if (animation.name?.endsWith("MISS"))
                requiredTime *= FlxG.random.float(1.35, 1.85);

            if (singCount >= requiredTime && (role == PLAYABLE ? !Inputs.inputsPressed(inputs) : true))
            {
                singCount = 0.0;
                
                dance(true);
            }
        }
        else
            singCount = 0.0;
    }

    override function destroy():Void
    {
        super.destroy();

        conductor = null;
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... data.animations.length)
        {
            var _animation:CharacterFrameSet = data.animations[i];
            
            if (animation.name ?? "" == _animation.name)
                output.add(_animation.offset?.x ?? 0.0, _animation.offset?.y ?? 0.0);
        }

        return output;
    }

    public function dance(forceful:Bool = false):Void
    {
        if (skipDance)
            return;
        
        if (!forceful && animation.name?.startsWith("Sing"))
            return;

        animation.play(danceSteps[danceStep = FlxMath.wrap(danceStep + 1, 0, danceSteps.length - 1)], forceful);
    }

    public function beatHit(beat:Int):Void
    {
        if (beat % danceInterval == 0.0)
            dance();
    }
}

typedef CharacterData =
{
    var name:String;
    
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Null<Bool>;

    var ?scale:Null<{?x:Null<Float>, ?y:Null<Float>}>;

    var ?flipX:Null<Bool>;

    var ?flipY:Null<Bool>;

    var animations:Array<CharacterFrameSet>;

    var danceSteps:Array<String>;

    var ?danceInterval:Float;

    var ?singDuration:Null<Float>;
};

typedef CharacterFrameSet =
{
    var name:String;
    
    var prefix:String;
    
    var indices:Array<Int>;
    
    var ?frameRate:Null<Float>;
    
    var ?looped:Null<Bool>;
    
    var ?flipX:Null<Bool>;
    
    var ?flipY:Null<Bool>;

    var ?offset:Null<{?x:Null<Float>, ?y:Null<Float>}>;
};

enum abstract CharacterRole(String) from String to String
{
    var ARTIFICIAL:CharacterRole = "ARTIFICIAL";

    var PLAYABLE:CharacterRole = "PLAYABLE";

    var OTHER:CharacterRole = "OTHER";
}