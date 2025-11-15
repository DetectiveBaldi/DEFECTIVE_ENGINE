package menus.options.items;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import core.AssetCache;
import core.Options;
import core.Paths;

using util.ArrayUtil;

class ControlOptionItem extends VariableOptionItem<Array<Int>>
{
    override function get_value():Array<Int>
    {
        return Options.controls[option];
    }

    override function set_value(_value:Array<Int>):Array<Int>
    {
        Options.controls[option] = _value;

        Options.controls = Options.controls;

        return value;
    }

    public var selectable:Bool;

    public var control:FlxSprite;

    public var input:FlxKeyboard;

    public var index:Int;

    public function new(_x:Float = 0.0, _y:Float = 0.0, _title:String, _description:String, _option:String):Void
    {
        super(_x, _y, _title, _description, _option);

        trace("?");

        titleText.size = 36;

        titleText.setPosition(background.getMidpoint().x - titleText.width * 0.5, background.getMidpoint().y - titleText.height * 0.5);

        selectable = false;

        control = new FlxSprite(0.0, 0.0, AssetCache.getGraphic("menus/options/items/ControlOptionItem/control"));

        control.active = false;

        control.antialiasing = true;

        control.setGraphicSize(192.0, 192.0);

        control.updateHitbox();

        control.setPosition(-175.0, background.getMidpoint().y - control.height * 0.5);

        add(control);

        input = new FlxKeyboard();

        input.enabled = false;

        FlxG.inputs.addInput(input);

        index = 0;

        updateTitleText();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (selectable)
        {
            if (FlxG.keys.enabled)
            {
                if (FlxG.keys.justPressed.LEFT)
                    index = FlxMath.wrap(index - 1, 0, 1);

                if (FlxG.keys.justPressed.RIGHT)
                    index = FlxMath.wrap(index + 1, 0, 1);

                if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
                {
                    var scroll:FlxSound = FlxG.sound.play(AssetCache.getSound("menus/options/OptionsMenu/scroll"), 0.35);

                    scroll.onComplete = scroll.kill;

                    updateTitleText();
                }

                if (FlxG.keys.justPressed.ENTER)
                {
                    FlxG.mouse.enabled = false;

                    FlxG.keys.enabled = false;

                    titleText.text = "...";

                    input.enabled = true;

                    input.reset();
                }
            }
            else
            {
                var firstJustPressed:Int = input.firstJustPressed();

                if (firstJustPressed != -1.0)
                {
                    FlxG.mouse.enabled = true;

                    FlxG.keys.enabled = true;

                    FlxG.keys.reset();

                    value[index] = firstJustPressed;

                    updateTitleText();

                    input.enabled = false;

                    var scroll:FlxSound = FlxG.sound.play(AssetCache.getSound("menus/options/OptionsMenu/scroll"), 0.35);

                    scroll.onComplete = scroll.kill;
                }
            }
        }
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.mouse.enabled = true;

        FlxG.keys.enabled = true;

        FlxG.keys.reset();

        FlxG.inputs.remove(input);

        input.enabled = false;

        input.destroy();
    }

    public function updateTitleText():Void
    {
        if (index == 0)
            titleText.text = '${title}: (${FlxKey.toStringMap[value[0]]}) ${FlxKey.toStringMap[value[1]]}';
        else
            titleText.text = '${title}: ${FlxKey.toStringMap[value[0]]} (${FlxKey.toStringMap[value[1]]})';
    }
}