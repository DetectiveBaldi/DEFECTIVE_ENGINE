package game;

import haxe.Json;

import openfl.utils.Assets;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import flixel.util.FlxDestroyUtil;

import core.AssetCache;
import core.Options;
import core.Paths;

import data.AnimationData;
import data.AxisData;
import data.CharacterData;

import game.notes.Note;
import game.notes.Strumline;

import music.Conductor;

using StringTools;

using util.ArrayUtil;

class Character extends FlxSprite
{
    public static function getConfig(file:String):CharacterData
    {
        return Json.parse(Assets.getText(Paths.data(Paths.json('game/Character/${file}'))));
    }
    
    public var conductor:Conductor;

    public var strumline:Strumline;

    public var lastScale:FlxPoint;
    
    public var config:CharacterData;

    public var danceSteps:Array<String>;

    public var danceEvery:Float;

    public var singDuration:Float;

    public var deadCharacter:String;

    public var danceIndex:Int;

    public var skipDance:Bool;

    public var skipSing:Bool;

    public var holdTimer:Float;

    public function new(beatDispatcher:IBeatDispatcher, x:Float = 0.0, y:Float = 0.0, _config:CharacterData):Void
    {
        super(x, y);

        conductor = beatDispatcher?.conductor;

        conductor?.onBeatHit?.add(beatHit);

        lastScale = FlxPoint.get();
        
        loadConfig(_config);

        danceIndex = 0;

        skipDance = false;

        skipSing = false;

        holdTimer = 0.0;

        dance();

        danceIndex = 0;

        animation.finish();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        calcOffsetsByScale();

        if (conductor == null || strumline == null)
            return;

        if (isSinging())
        {
            holdTimer += elapsed;

            var singTimeSec:Float = singDuration * (conductor.beatLength * 0.25 * 0.001);

            if ((animation.name ?? "").endsWith("MISS"))
                singTimeSec *= 2.0;

            if (holdTimer >= singTimeSec)
            {
                holdTimer = 0.0;
                
                dance(true);
            }
        }
        else
            holdTimer = 0.0;
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        var animData:AnimationData = config.animations.first((anim:AnimationData) -> animation.name ?? "" == anim.name);

        if (animData != null)
            output.add(animData.offset.x, animData.offset.y);

        return output;
    }

    override function destroy():Void
    {
        super.destroy();

        conductor?.onBeatHit?.remove(beatHit);

        lastScale = FlxDestroyUtil.put(lastScale);

        danceSteps = null;
    }

    public function loadConfig(newConfig:CharacterData):CharacterData
    {
        config = newConfig;

        var pngPath:String = 'game/Character/${config.image}';

        var xmlPath:String = Paths.image(Paths.xml('game/Character/${config.image}'));
        
        switch (config.format ?? "".toLowerCase():String)
        {
            case "sparrow": frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic(pngPath), xmlPath);

            case "texturepackerxml": frames = FlxAtlasFrames.fromTexturePackerXml(AssetCache.getGraphic(pngPath), xmlPath);
        }

        antialiasing = config.antialiasing ?? true;

        scale.set(config.scale?.x ?? 1.0, config.scale?.y ?? 1.0);

        lastScale.copyFrom(scale);

        updateHitbox();

        flipX = config.flipX ?? false;

        flipY = config.flipY ?? false;

        for (i in 0 ... config.animations.length)
        {
            var animData:AnimationData = config.animations[i];

            animData.frameRate ??= 24.0;

            animData.looped ??= false;

            animData.flipX ??= false;

            animData.flipY ??= false;

            animData.offset ??= {x: 0.0, y: 0.0}

            if (animData.indices != null)
                animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.frameRate,
                    animData.looped, animData.flipX, animData.flipY);
            else
                animation.addByPrefix(animData.name, animData.prefix, animData.frameRate, animData.looped,
                    animData.flipX, animData.flipY);
        }

        danceSteps = config.danceSteps;

        danceEvery = config.danceEvery ?? 2.0;

        singDuration = config.singDuration ?? 8.0;

        deadCharacter = config.deadCharacter ?? "bf-dead";

        return config;
    }

    public function isSinging():Bool
    {
        return (animation.name ?? "").startsWith("Sing");
    }

    public function calcOffsetsByScale():Void
    {
        if (scale.equals(lastScale))
            return;

        var xRatio:Float = scale.x / lastScale.x;

        var yRatio:Float = scale.y / lastScale.y;

        for (i in 0 ... config.animations.length)
        {
            var animData:AnimationData = config.animations[i];
            
            animData.offset.x *= xRatio;
            
            animData.offset.y *= yRatio;
        }

        lastScale.copyFrom(scale);
    }

    public function beatHit(beat:Int):Void
    {
        if (beat % danceEvery == 0.0)
            dance();
    }

    public function dance(force:Bool = false):Void
    {
        if (skipDance)
            return;

        if (!force)
        {
            if (isSinging())
                return;

            if (danceSteps.length != 1.0)
            {
                if (!animation.finished && danceSteps.contains(animation.name))
                    return;
            }
        }

        danceIndex = FlxMath.wrap(danceIndex + 1, 0, danceSteps.length - 1);

        animation.play(danceSteps[danceIndex], force);
    }
}