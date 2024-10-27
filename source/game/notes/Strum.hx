package game.notes;

import haxe.Json;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetMan;
import core.Conductor;
import core.Paths;

using StringTools;

class Strum extends FlxSprite
{
    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var conductor:Conductor;

    public var parent:StrumLine;

    /**
     * A structure containing texture-related information about `this` `Strum`, such as .png and .xml locations.
     */
    public var textureData(default, set):StrumTextureData;

    @:noCompletion
    function set_textureData(textureData:StrumTextureData):StrumTextureData
    {
        switch (textureData.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(textureData.png)), Paths.xml(textureData.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(textureData.png)), Paths.xml(textureData.xml));
        }

        for (i in 0 ... Strum.directions.length)
        {
            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Static", Strum.directions[i].toLowerCase() + "Static0", 24.0, false);

            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Press", Strum.directions[i].toLowerCase() + "Press0", 24.0, false);
            
            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Confirm", Strum.directions[i].toLowerCase() + "Confirm0", 24.0, false);
        }

        antialiasing = textureData.antialiasing ?? true;

        return this.textureData = textureData;
    }

    public var direction:Int;

    public var confirmCount:Float;

    public function new(conductor:Conductor, x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        this.conductor = conductor;
        
        textureData = Json.parse(AssetMan.text(Paths.json("assets/data/game/notes/Strum/classic")));

        direction = -1;

        confirmCount = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor == null)
            return;

        if ((animation.name ?? "").endsWith("Confirm"))
        {
            confirmCount += elapsed;

            if (confirmCount >= (conductor.crotchet * 0.25) * 0.001)
            {
                confirmCount = 0.0;

                animation.play(directions[direction].toLowerCase() + (parent.artificial ? "Static" : "Press"));
            }
        }
        else
            confirmCount = 0.0;
    }
}

typedef StrumTextureData =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;
};