package objects;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxPoint;

import core.Binds;
import core.Conductor;

class Character extends FlxSprite
{
    public var simple(default, null):SimpleCharacter;

    public var role:CharacterRole;

    public var skipDance:Bool;

    public var danceInterval:Float;

    public var singDuration:Float;

    public var singCount:Float;

    public function new(x:Float = 0.0, y:Float = 0.0, path:String, role:CharacterRole = ARTIFICIAL):Void
    {
        super(x, y);
        
        simple = cast Json.parse(#if html5 openfl.utils.Assets.getText(path) #else sys.io.File.getContent(path) #end);

        this.role = role;

        frames = FlxAtlasFrames.fromSparrow(simple.source, simple.xml);

        antialiasing = simple.antialiasing ?? true;

        scale.set(simple.scale?.x ?? 1.0, simple.scale?.y ?? 1.0);

        updateHitbox();

        flipX = simple.flipX ?? false;

        flipY = simple.flipY ?? false;

        for (i in 0 ... simple.animations.length)
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

        danceInterval = simple.danceInterval ?? 2.0;

        singDuration = simple.singDuration;

        dance(true);

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

        Conductor.current.stepHit.remove(stepHit);

        Conductor.current.beatHit.remove(beatHit);

        Conductor.current.sectionHit.remove(sectionHit);
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... simple.animations.length)
        {
            if (simple.animations[i].name == animation.name)
            {
                output.subtract(simple.animations[i].offsets?.x ?? 0.0, simple.animations[i].offsets?.y ?? 0.0);

                break;
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

        animation.play("dance", forceful);
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
    ARTIFICIAL;

    PLAYABLE;
}

typedef SimpleCharacter =
{
    var source:String;

    var xml:String;

    var ?antialiasing:Bool;

    var ?scale:{x:Float, y:Float};

    var ?flipX:Bool;

    var ?flipY:Bool;

    var animations:Array<{?offsets:{?x:Float, ?y:Float}, name:String, prefix:String, ?frameRate:Float, ?looped:Bool, ?flipX:Bool, ?flipY:Bool}>;

    var ?danceInterval:Float;

    var singDuration:Float;
}