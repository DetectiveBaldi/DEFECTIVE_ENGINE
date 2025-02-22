package game.notes;

import haxe.Json;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.Assets;
import core.Paths;

import data.StrumSkin;
import data.StrumSkin.RawStrumSkin;

import music.Conductor;

using StringTools;

class Strum extends FlxSprite
{
    public var conductor:Conductor;

    public var strumline:Strumline;
    
    public var skin(default, set):RawStrumSkin;

    @:noCompletion
    function set_skin(_skin:RawStrumSkin):RawStrumSkin
    {
        skin = _skin;

        switch (skin.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png(skin.png)), Paths.xml(skin.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(Assets.getGraphic(Paths.png(skin.png)), Paths.xml(skin.xml));
        }

        for (i in 0 ... Note.DIRECTIONS.length)
        {
            animation.addByPrefix(Note.DIRECTIONS[i].toLowerCase() + "Static", Note.DIRECTIONS[i].toLowerCase() + "Static0", 24.0, false);

            animation.addByPrefix(Note.DIRECTIONS[i].toLowerCase() + "Press", Note.DIRECTIONS[i].toLowerCase() + "Press0", 24.0, false);
            
            animation.addByPrefix(Note.DIRECTIONS[i].toLowerCase() + "Confirm", Note.DIRECTIONS[i].toLowerCase() + "Confirm0", 24.0, false);
        }

        antialiasing = skin.antialiasing ?? true;

        return skin;
    }

    public var direction:Int;

    public var confirmTimer:Float;

    public function new(_conductor:Conductor, x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        conductor = _conductor;
        
        skin = StrumSkin.get("default");

        direction = 0;

        confirmTimer = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor == null)
            return;

        if ((animation.name ?? "").endsWith("Confirm"))
        {
            confirmTimer += elapsed;

            if (confirmTimer >= conductor.stepLength * 0.001)
            {
                confirmTimer = 0.0;

                animation.play(Note.DIRECTIONS[direction].toLowerCase() + (strumline.automated ? "Static" : "Press"));
            }
        }
        else
            confirmTimer = 0.0;
    }
}