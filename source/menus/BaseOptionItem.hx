package menus;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.group.FlxSpriteGroup;

import flixel.text.FlxText;

import flixel.util.FlxColor;

import core.AssetMan;
import core.Paths;

class BaseOptionItem extends FlxSpriteGroup
{
    public var name(default, set):String;

    @:noCompletion
    function set_name(_name:String):String
    {
        name = _name;

        nameText.text = name;

        return name;
    }

    public var description:String;

    public var background:FlxSprite;

    public var nameText:FlxText;

    public function new(x:Float = 0.0, y:Float = 0.0, name:String, description:String):Void
    {
        super(x, y);

        @:bypassAccessor
            this.name = name;

        this.description = description;

        background = new FlxSprite();

        background.antialiasing = true;

        background.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png("assets/images/menus/BaseOptionItem/background")), Paths.xml("assets/images/menus/BaseOptionItem/background"));

        background.animation.addByPrefix("background", "background", 12.0);

        background.animation.play("background");

        add(background);

        nameText = new FlxText(0.0, 0.0, background.width, name, 48);

        nameText.antialiasing = true;

        nameText.color = FlxColor.BLACK;

        nameText.font = Paths.ttf("assets/fonts/Ubuntu Regular");

        nameText.alignment = CENTER;

        nameText.setPosition(background.getMidpoint().x - nameText.width * 0.5, background.getMidpoint().y - nameText.height * 0.5);

        add(nameText);
    }
}