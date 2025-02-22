package game.notes;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxPoint;

import core.Assets;
import core.Paths;

import data.AnimationData;
import data.NotePopSkin;
import data.NotePopSkin.RawNotePopSkin;

using StringTools;

class NotePop extends FlxSprite
{
    public var skin(default, set):RawNotePopSkin;

    @:noCompletion
    function set_skin(_skin:RawNotePopSkin):RawNotePopSkin
    {
        skin = _skin;

        switch (skin.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png(skin.png)), Paths.xml(skin.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(Assets.getGraphic(Paths.png(skin.png)), Paths.xml(skin.xml));
        }

        antialiasing = skin.antialiasing ?? true;

        for (i in 0 ... skin.animations.length)
        {
            var _animation:AnimationData = skin.animations[i];

            _animation.frameRate ??= 24.0;

            _animation.looped ??= false;

            _animation.flipX ??= false;

            _animation.flipY ??= false;

            if (_animation.indices.length > 0.0)
                animation.addByIndices(_animation.name, _animation.prefix, _animation.indices, "", _animation.frameRate, _animation.looped, _animation.flipX, _animation.flipY);
            else
                animation.addByPrefix(_animation.name, _animation.prefix, _animation.frameRate, _animation.looped, _animation.flipX, _animation.flipY);
        }

        return skin;
    }

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        skin = NotePopSkin.get("default");

        animation.onFinish.add((name:String) -> kill());

        scale.set(0.7, 0.7);

        updateHitbox();
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... skin.animations.length)
        {
            var _animation:AnimationData = skin.animations[i];

            if ((animation.name ?? "") == _animation.name)
                output.subtract(_animation.offset?.x ?? 0.0, _animation.offset?.y ?? 0.0);
        }

        return output;
    }

    public function pop(direction:Int, reversed:Bool):Void
    {
        animation.play(Note.DIRECTIONS[direction].toLowerCase() + FlxG.random.int(0, 1), false, reversed);
    }
}