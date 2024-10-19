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

using StringTools;

class Character extends FlxSprite
{
    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(conductor:Conductor):Conductor
    {
        this.conductor?.beatHit.remove(beatHit);

        conductor?.beatHit.add(beatHit);

        return this.conductor = conductor;
    }

    public var inputs:Array<Input>;
    
    /**
     * A structure containing fundamentals about `this` `Character`, such as name, texture-related information, and more.
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

    public function new(conductor:Conductor, x:Float = 0.0, y:Float = 0.0, character:String, role:CharacterRole):Void
    {
        super(x, y);

        this.conductor = conductor;

        inputs =
        [
            {name: "NOTE:LEFT", keys: [FlxKey.Z, FlxKey.A, FlxKey.LEFT]},

            {name: "NOTE:DOWN", keys: [FlxKey.X, FlxKey.S, FlxKey.DOWN]},

            {name: "NOTE:UP", keys: [FlxKey.PERIOD, FlxKey.W, FlxKey.UP]},

            {name: "NOTE:RIGHT", keys: [FlxKey.SLASH, FlxKey.D, FlxKey.RIGHT]}
        ];
        
        data = Json.parse(AssetMan.text(Paths.json(character)));

        switch (data.format ?? "".toLowerCase():String)
        {
            case "sparrow": frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(data.png), true), Paths.xml(data.xml));

            case "texturepackerxml": frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(data.png), true), Paths.xml(data.xml));
        }

        antialiasing = data.antialiasing ?? true;

        scale.set(data.scale?.x ?? 1.0, data.scale?.y ?? 1.0);

        updateHitbox();

        flipX = data.flipX ?? false;

        flipY = data.flipY ?? false;

        for (i in 0 ... data.frames.length)
        {
            var _frames:CharacterFramesData = data.frames[i];

            if (animation.exists(_frames.name))
                throw "game.Character: Invalid animation name!";

            if (_frames.indices.length > 0)
            {
                animation.addByIndices
                (
                    _frames.name,

                    _frames.prefix,

                    _frames.indices,

                    "",

                    _frames.frameRate ?? 24.0,

                    _frames.looped ?? false,

                    _frames.flipX ?? false,

                    _frames.flipY ?? false
                );
            }
            else
            {
                animation.addByPrefix
                (
                    _frames.name,

                    _frames.prefix,

                    _frames.frameRate ?? 24.0,

                    _frames.looped ?? false,

                    _frames.flipX ?? false,

                    _frames.flipY ?? false
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
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor == null)
            return;

        if (Inputs.inputsJustPressed(inputs) && role == PLAYABLE)
            singCount = 0.0;

        if ((animation.name ?? "").startsWith("Sing"))
        {
            singCount += elapsed;

            var requiredTime:Float = singDuration * ((conductor.crotchet * 0.25) * 0.001);

            if ((animation.name ?? "").endsWith("MISS"))
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

        conductor?.beatHit.remove(beatHit);
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... data.frames.length)
        {
            var _frames:CharacterFramesData = data.frames[i];
            
            if (animation.name ?? "" == _frames.name)
                output.add(_frames.offset?.x ?? 0.0, _frames.offset?.y ?? 0.0);
        }

        return output;
    }

    public function beatHit(beat:Int):Void
    {
        if (beat % danceInterval == 0.0)
            dance();
    }

    public function dance(forceful:Bool = false):Void
    {
        if (skipDance)
            return;
        
        if (!forceful && (animation.name ?? "").startsWith("Sing"))
            return;

        animation.play(danceSteps[danceStep = FlxMath.wrap(danceStep + 1, 0, danceSteps.length - 1)], forceful);
    }
}

typedef CharacterData =
{
    var name:String;
    
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Null<Bool>;

    var ?scale:{?x:Null<Float>, ?y:Null<Float>};

    var ?flipX:Null<Bool>;

    var ?flipY:Null<Bool>;

    var frames:Array<CharacterFramesData>;

    var danceSteps:Array<String>;

    var ?danceInterval:Float;

    var ?singDuration:Null<Float>;
};

typedef CharacterFramesData =
{
    var name:String;
    
    var prefix:String;
    
    var indices:Array<Int>;
    
    var ?frameRate:Null<Float>;
    
    var ?looped:Null<Bool>;
    
    var ?flipX:Null<Bool>;
    
    var ?flipY:Null<Bool>;

    var ?offset:{?x:Null<Float>, ?y:Null<Float>};
};

enum abstract CharacterRole(String) from String to String
{
    var ARTIFICIAL:CharacterRole = "ARTIFICIAL";

    var PLAYABLE:CharacterRole = "PLAYABLE";

    var OTHER:CharacterRole = "OTHER";
}