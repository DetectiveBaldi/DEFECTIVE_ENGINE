package menus;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.group.FlxSpriteGroup;

import flixel.text.FlxText;

import flixel.util.FlxColor;

import core.Assets;
import core.Paths;

class BaseOptionItem extends FlxSpriteGroup
{
    public var title(default, set):String;

    @:noCompletion
    function set_title(_title:String):String
    {
        title = _title;

        titleText.text = title;

        return title;
    }

    public var description:String;

    public var background:FlxSprite;

    public var titleText:FlxText;

    public function new(x:Float = 0.0, y:Float = 0.0, _title:String, _description:String):Void
    {
        super(x, y);

        @:bypassAccessor
        title = _title;

        description = _description;

        background = new FlxSprite();

        background.antialiasing = true;

        background.frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png("assets/images/menus/BaseOptionItem/background")), Paths.xml("assets/images/menus/BaseOptionItem/background"));

        background.animation.addByPrefix("background", "background", 12.0);

        background.animation.play("background");

        add(background);

        titleText = new FlxText(0.0, 0.0, background.width, title, 48);

        titleText.antialiasing = true;

        titleText.color = FlxColor.BLACK;

        titleText.font = Paths.ttf("assets/fonts/Ubuntu Regular");

        titleText.alignment = CENTER;

        titleText.setPosition(background.getMidpoint().x - titleText.width * 0.5, background.getMidpoint().y - titleText.height * 0.5);

        add(titleText);
    }
}