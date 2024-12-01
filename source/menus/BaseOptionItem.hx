package menus;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.group.FlxSpriteGroup;

import flixel.text.FlxText;

import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;

import core.AssetMan;
import core.Options;
import core.Paths;

class BaseOptionItem<T> extends FlxSpriteGroup
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

    public var option:String;

    public var value(get, set):T;

    @:noCompletion
    function get_value():T
    {
        return Reflect.getProperty(Options, option);
    }

    @:noCompletion
    function set_value(_value:T):T
    {
        Reflect.setProperty(Options, option, _value);

        return value;
    }

    public var onUpdate:FlxTypedSignal<(value:T)->Void>;

    public var background:FlxSprite;

    public var nameText:FlxText;

    public function new(x:Float = 0.0, y:Float = 0.0, name:String, description:String, option:String):Void
    {
        super(x, y);

        @:bypassAccessor
            this.name = name;

        this.description = description;

        this.option = option;

        onUpdate = new FlxTypedSignal<(value:T)->Void>();

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

        nameText.alignment = LEFT;

        nameText.setPosition(background.x + 48.0, background.getMidpoint().y - nameText.height * 0.5);

        add(nameText);
    }

    public function set(value:T):T
    {
        this.value = value;

        onUpdate.dispatch(value);

        return value;
    }
}