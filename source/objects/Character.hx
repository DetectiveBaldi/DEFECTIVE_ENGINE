package objects;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxPoint;

import core.Binds;
import core.Conductor;
import core.Paths;

class Character extends FlxSprite
{
    public var simple(default, null):SimpleCharacter;

    public var danceInterval:Float;

    public var singDuration:Float;

    public var danceSteps:Array<String>;

    public var danceStep:Int;

    public var skipDance:Bool;

    public var skipSing:Bool;

    public var singCount:Float;

    public var role:CharacterRole;

    public function new(x:Float = 0.0, y:Float = 0.0, path:String, role:CharacterRole):Void
    {
        super(x, y);
        
        simple = Json.parse(#if html5 openfl.utils.Assets.getText(path) #else sys.io.File.getContent(path) #end);

        switch (simple.format ?? "".toLowerCase():String)
        {
            case "sparrow":
            {
                frames = FlxAtlasFrames.fromSparrow(Paths.png(simple.png), Paths.xml(simple.xml));
            }

            case "texturepackerxml":
            {
                frames = FlxAtlasFrames.fromTexturePackerXml(Paths.png(simple.png), Paths.xml(simple.xml));
            }
        }

        antialiasing = simple.antialiasing ?? true;

        scale.set(simple.scale?.x ?? 1.0, simple.scale?.y ?? 1.0);

        updateHitbox();

        flipX = simple.flipX ?? false;

        flipY = simple.flipY ?? false;

        for (i in 0 ... simple.animations.length)
        {
            if (simple.animations[i].indices.length > 0)
            {
                animation.addByIndices
                (
                    simple.animations[i].name,

                    simple.animations[i].prefix,

                    simple.animations[i].indices,

                    "",

                    simple.animations[i].frameRate ?? 24.0,

                    simple.animations[i].looped ?? false,

                    simple.animations[i].flipX ?? false,

                    simple.animations[i].flipY ?? false
                );
            }
            else
            {
                animation.addByPrefix
                (
                    simple.animations[i].name,

                    simple.animations[i].prefix,

                    simple.animations[i].frameRate ?? 24.0,

                    simple.animations[i].looped ?? false,

                    simple.animations[i].flipX ?? false,

                    simple.animations[i].flipY ?? false
                );
            }
        }

        danceInterval = simple.danceInterval ?? 1.0;

        singDuration = simple.singDuration ?? 8.0;

        danceSteps = simple.danceSteps ?? ["dance"];

        danceStep = 0;

        skipDance = false;

        skipSing = false;

        singCount = 0.0;

        this.role = role;

        dance();

        Conductor.current.stepHit.add(stepHit);

        Conductor.current.beatHit.add(beatHit);

        Conductor.current.sectionHit.add(sectionHit);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (Binds.bindsJustPressed(["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"]) && role == PLAYABLE)
        {
            singCount = 0.0;
        }

        if (StringTools.startsWith(animation.name ?? "", "Sing"))
        {
            singCount += elapsed;

            var requiredTime:Float = singDuration * ((Conductor.current.crotchet * 0.25) * 0.001);

            if (StringTools.endsWith(animation.name ?? "", "MISS"))
            {
                requiredTime *= FlxG.random.float(1.35, 1.85);
            }

            if (singCount >= requiredTime && (role == PLAYABLE ? !Binds.bindsPressed(["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"]) : true))
            {
                singCount = 0.0;
                
                dance(true);
            }
        }
        else
        {
            singCount = 0.0;
        }
    }

    override function destroy():Void
    {
        super.destroy();

        simple = null;

        danceInterval = 1.0;

        singDuration = 8.0;

        danceSteps = null;

        danceStep = 0;

        skipDance = false;

        skipSing = false;

        singCount = 0.0;

        role = OTHER;

        Conductor.current.stepHit.remove(stepHit);

        Conductor.current.beatHit.remove(beatHit);

        Conductor.current.sectionHit.remove(sectionHit);
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... simple.animations.length)
        {
            if (animation.name ?? "" == simple.animations[i].name)
            {
                output.subtract(simple.animations[i].offsets?.x ?? 0.0, simple.animations[i].offsets?.y ?? 0.0);
            }
        }
        
        return output;
    }

    public function dance(forceful:Bool = false):Void
    {
        if (skipDance)
        {
            return;
        }
        
        if (!forceful && StringTools.startsWith(animation.name ?? "", "Sing"))
        {
            return;
        }

        danceStep++;

        if (danceStep > danceSteps.length - 1.0)
        {
            danceStep = 0;
        }

        animation.play(danceSteps[danceStep], forceful);
    }

    public function stepHit():Void
    {

    }

    public function beatHit():Void
    {
        if (Conductor.current.beat % danceInterval == 0.0)
        {
            dance();
        }
    }

    public function sectionHit():Void
    {

    }
}

enum CharacterRole
{
    ARTIFICIAL:CharacterRole;

    PLAYABLE:CharacterRole;

    OTHER:CharacterRole;
}

typedef SimpleCharacter =
{
    var name:String;
    
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;

    var ?scale:{?x:Float, ?y:Float};

    var ?flipX:Bool;

    var ?flipY:Bool;

    var animations:Array<{?offsets:{?x:Float, ?y:Float}, name:String, prefix:String, indices:Array<Int>, ?frameRate:Float, ?looped:Bool, ?flipX:Bool, ?flipY:Bool}>;

    var ?danceSteps:Array<String>;

    var ?danceInterval:Float;

    var ?singDuration:Float;
}