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

    public var role(default, null):CharacterRole;

    public var singTimer:Float;

    public function new(x:Float = 0.0, y:Float = 0.0, path:String, role:CharacterRole = ARTIFICIAL):Void
    {
        super(x, y);

        #if html5
            simple = cast Json.parse(openfl.utils.Assets.getText(path));
        #else
            simple = cast Json.parse(sys.io.File.getContent(path));
        #end

        frames = FlxAtlasFrames.fromSparrow('${simple.source}.png', '${simple.source}.xml');

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

        this.role = role;

        dance(true);

        Conductor.current.sectionHit.add(sectionHit);

        Conductor.current.beatHit.add(beatHit);

        Conductor.current.stepHit.add(stepHit);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (Binds.bindsJustPressed(["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"]) && role == PLAYABLE)
        {
            singTimer = 0.0;
        }

        if (StringTools.startsWith(animation.name ?? "", "Sing"))
        {
            singTimer += elapsed;

            var requiredTime:Float = simple.singDuration * ((Conductor.current.crotchet * 0.25) * 0.001);

            if (StringTools.endsWith(animation.name ?? "", "MISS"))
            {
                requiredTime *= FlxG.random.float(1.35, 1.85);
            }

            if (singTimer >= requiredTime && (role == PLAYABLE ? !Binds.bindsPressed(["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"]) : true))
            {
                dance(true);

                singTimer = 0.0;
            }
        }
        else
        {
            singTimer = 0.0;
        }
    }

    override function destroy():Void
    {
        super.destroy();

        Conductor.current.sectionHit.remove(sectionHit);

        Conductor.current.beatHit.remove(beatHit);

        Conductor.current.stepHit.remove(stepHit);
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... simple.animations.length)
        {
            if (simple.animations[i].name == animation.name)
            {
                output.subtract(simple.animations[i].offsets.x, simple.animations[i].offsets.y);

                break;
            }
        }
        
        return output;
    }

    public function dance(forceful:Bool = false):Void
    {
        if (!forceful && StringTools.startsWith(animation.name ?? "", "Sing"))
        {
            return;
        }

        animation.play("dance", forceful);
    }

    public function sectionHit():Void
    {

    }

    public function beatHit():Void
    {
        if (Conductor.current.currentBeat % 2.0 == 0.0)
        {
            dance();
        }
    }

    public function stepHit():Void
    {

    }
}

enum abstract CharacterRole(String)
{
    var ARTIFICIAL:CharacterRole = "ARTIFICIAL";

    var PLAYABLE:CharacterRole = "PLAYABLE";
}

typedef SimpleCharacter =
{
    var source:String;

    var animations:Array<{offsets:{x:Null<Float>, y:Null<Float>}, name:String, prefix:String, ?frameRate:Float, ?looped:Bool, ?flipX:Bool, ?flipY:Bool}>;

    var singDuration:Float;
}