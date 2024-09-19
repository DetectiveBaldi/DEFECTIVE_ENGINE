package objects;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import core.AssetMan;
import core.Conductor;
import core.Inputs;
import core.Paths;

using StringTools;

class Character extends FlxSprite
{
    /**
     * A structure containing fundamentals about this `Character`, such as name, texture-related information, and more.
     */
    public var data(default, null):CharacterData;

    public var danceSteps:Array<String>;

    public var danceStep:Int;

    public var danceInterval:Float;

    public var singDuration:Float;

    public var skipDance:Bool;

    public var skipSing:Bool;

    public var singCount:Float;

    public var role:CharacterRole;

    public var conductor(default, null):Conductor;

    public function new(x:Float = 0.0, y:Float = 0.0, path:String, role:CharacterRole, conductor:Conductor):Void
    {
        super(x, y);
        
        data = Json.parse(AssetMan.text(path));

        switch (data.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(data.png)), Paths.xml(data.xml));

            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(data.png)), Paths.xml(data.xml));
        }

        antialiasing = data.antialiasing ?? true;

        scale.set(data.scale?.x ?? 1.0, data.scale?.y ?? 1.0);

        updateHitbox();

        flipX = data.flipX ?? false;

        flipY = data.flipY ?? false;

        for (i in 0 ... data.animations.length)
        {
            if (data.animations[i].indices.length > 0)
            {
                animation.addByIndices
                (
                    data.animations[i].name,

                    data.animations[i].prefix,

                    data.animations[i].indices,

                    "",

                    data.animations[i].frameRate ?? 24.0,

                    data.animations[i].looped ?? false,

                    data.animations[i].flipX ?? false,

                    data.animations[i].flipY ?? false
                );
            }
            else
            {
                animation.addByPrefix
                (
                    data.animations[i].name,

                    data.animations[i].prefix,

                    data.animations[i].frameRate ?? 24.0,

                    data.animations[i].looped ?? false,

                    data.animations[i].flipX ?? false,

                    data.animations[i].flipY ?? false
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

        this.conductor = conductor;

        conductor.stepHit.add(stepHit);

        conductor.beatHit.add(beatHit);

        conductor.sectionHit.add(sectionHit);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (Inputs.inputsJustPressed(["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"]) && role == PLAYABLE)
            singCount = 0.0;

        if (animation.name?.startsWith("Sing"))
        {
            singCount += elapsed;

            var requiredTime:Float = singDuration * ((conductor.crotchet * 0.25) * 0.001);

            if (animation.name?.endsWith("MISS"))
                requiredTime *= FlxG.random.float(1.35, 1.85);

            if (singCount >= requiredTime && (role == PLAYABLE ? !Inputs.inputsPressed(["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"]) : true))
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

        conductor.stepHit.remove(stepHit);

        conductor.beatHit.remove(beatHit);

        conductor.sectionHit.remove(sectionHit);
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... data.animations.length)
            if (animation.name ?? "" == data.animations[i].name)
                output.subtract(data.animations[i].offsets?.x ?? 0.0, data.animations[i].offsets?.y ?? 0.0);

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

    public function stepHit(step:Int):Void
    {

    }

    public function beatHit(beat:Int):Void
    {
        if (beat % danceInterval == 0.0)
            dance();
    }

    public function sectionHit(section:Int):Void
    {

    }
}

typedef CharacterData =
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

    var danceSteps:Array<String>;

    var ?danceInterval:Float;

    var ?singDuration:Float;
};

enum CharacterRole
{
    ARTIFICIAL:CharacterRole;

    PLAYABLE:CharacterRole;

    OTHER:CharacterRole;
}