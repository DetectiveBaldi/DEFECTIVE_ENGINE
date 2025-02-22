package game;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import core.Assets;
import core.Options;
import core.Paths;

import data.AnimationData;
import data.CharacterData.RawCharacterData;

import game.notes.Strumline;

import music.Conductor;

using StringTools;

class Character extends FlxSprite
{
    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(_conductor:Conductor):Conductor
    {
        var __conductor:Conductor = conductor;

        conductor = _conductor;

        conductor?.onBeatHit?.add(beatHit);

        __conductor?.onBeatHit?.remove(beatHit);

        return conductor;
    }

    public var strumline:Strumline;

    public var keys:Array<Int>;
    
    public var config(default, set):RawCharacterData;

    @:noCompletion
    function set_config(_config:RawCharacterData):RawCharacterData
    {
        config = _config;

        switch (config.format ?? "".toLowerCase():String)
        {
            case "sparrow": frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png(config.png)), Paths.xml(config.xml));

            case "texturepackerxml": frames = FlxAtlasFrames.fromTexturePackerXml(Assets.getGraphic(Paths.png(config.png)), Paths.xml(config.xml));
        }

        antialiasing = config.antialiasing ?? true;

        scale.set(config.scale?.x ?? 1.0, config.scale?.y ?? 1.0);

        updateHitbox();

        flipX = config.flipX ?? false;

        flipY = config.flipY ?? false;

        for (i in 0 ... config.animations.length)
        {
            var _animation:AnimationData = config.animations[i];

            _animation.frameRate ??= 24.0;

            _animation.looped ??= false;

            _animation.flipX ??= false;

            _animation.flipY ??= false;

            if (animation.exists(_animation.name))
                throw "Invalid animation name!";

            if (_animation.indices.length > 0)
                animation.addByIndices(_animation.name, _animation.prefix, _animation.indices, "", _animation.frameRate, _animation.looped, _animation.flipX, _animation.flipY);
            else
                animation.addByPrefix(_animation.name, _animation.prefix, _animation.frameRate, _animation.looped, _animation.flipX, _animation.flipY);
        }

        danceSteps = config.danceSteps;

        danceStep = 0;

        danceInterval = config.danceInterval ?? 2.0;

        singDuration = config.singDuration ?? 8.0;

        singTimer = 0.0;

        return config;
    }

    public var danceSteps:Array<String>;

    public var danceStep:Int;

    public var danceInterval:Float;

    public var singDuration:Float;

    public var skipDance:Bool;

    public var skipSing:Bool;

    public var singTimer:Float;

    public function new(_conductor:Conductor, x:Float = 0.0, y:Float = 0.0, _config:RawCharacterData):Void
    {
        super(x, y);

        conductor = _conductor;

        keys = [Options.controls["NOTE:LEFT"], Options.controls["NOTE:DOWN"], Options.controls["NOTE:UP"], Options.controls["NOTE:RIGHT"]];
        
        config = _config;

        skipDance = false;

        skipSing = false;

        dance();

        animation.finish();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor != null && strumline != null)
        {
            if (FlxG.keys.anyJustPressed(keys) && !strumline.automated)
                singTimer = 0.0;

            if ((animation.name ?? "").startsWith("Sing"))
            {
                singTimer += elapsed;

                var requiredTime:Float = singDuration * (conductor.beatLength * 0.25 * 0.001);

                if ((animation.name ?? "").endsWith("MISS"))
                    requiredTime *= FlxG.random.float(1.35, 1.85);

                if (singTimer >= requiredTime && (!FlxG.keys.anyPressed(keys) || strumline.automated))
                {
                    singTimer = 0.0;
                    
                    dance(true);
                }
            }
            else
                singTimer = 0.0;
        }
    }

    override function destroy():Void
    {
        super.destroy();

        conductor?.onBeatHit?.remove(beatHit);

        keys = null;

        danceSteps = null;
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... config.animations.length)
        {
            var _animation:AnimationData = config.animations[i];
            
            if (animation.name ?? "" == _animation.name)
                output.add(_animation.offset?.x ?? 0.0, _animation.offset?.y ?? 0.0);
        }

        return output;
    }

    public function beatHit(beat:Int):Void
    {
        if (beat % danceInterval == 0.0)
            dance();
    }

    public function dance(force:Bool = false):Void
    {
        if (skipDance)
            return;
        
        if (!force && (animation.name ?? "").startsWith("Sing"))
            return;

        var i:Int = danceSteps.indexOf(animation.name);

        i = FlxMath.wrap(i + 1, 0, danceSteps.length - 1);

        animation.play(danceSteps[i], force);
    }
}