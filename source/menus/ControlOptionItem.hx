package menus;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import core.Assets;
import core.Options;
import core.Paths;

using util.ArrayUtil;

class ControlOptionItem extends VariableOptionItem<Int>
{
    override function get_value():Int
    {
        return Options.controls[option];
    }

    override function set_value(_value:Int):Int
    {
        Options.controls[option] = _value;

        return value;
    }

    public var selectable:Bool;

    public var control:FlxSprite;

    public var keyboard:FlxKeyboard;

    public function new(x:Float = 0.0, y:Float = 0.0, name:String, description:String, option:String):Void
    {
        super(x, y, name, description, option);

        nameText.size = 36;

        nameText.setPosition(background.getMidpoint().x - nameText.width * 0.5, background.getMidpoint().y - nameText.height * 0.5);

        selectable = false;

        control = new FlxSprite(0.0, 0.0, Assets.getGraphic(Paths.png("assets/images/menus/ControlOptionItem/control")));

        control.active = false;

        control.antialiasing = true;

        control.setGraphicSize(192.0, 192.0);

        control.updateHitbox();

        control.setPosition(-175.0, background.getMidpoint().y - control.height * 0.5);

        add(control);

        keyboard = new FlxKeyboard();

        keyboard.enabled = false;

        FlxG.inputs.addInput(keyboard);

        nameText.text = '${name}: ${FlxKey.toStringMap[value]}';
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (selectable)
        {
            if (FlxG.keys.enabled)
            {
                if (FlxG.keys.justPressed.ENTER)
                {
                    FlxG.mouse.enabled = false;

                    FlxG.keys.enabled = false;

                    nameText.text = "...";

                    keyboard.enabled = true;

                    keyboard.reset();
                }
            }
            else
            {
                var firstJustPressed:Int = keyboard.firstJustPressed();

                if (firstJustPressed != -1.0)
                {
                    FlxG.mouse.enabled = true;

                    FlxG.keys.enabled = true;

                    FlxG.keys.reset();

                    value = firstJustPressed;

                    nameText.text = '${name}: ${FlxKey.toStringMap[value]}';

                    keyboard.enabled = false;

                    var scroll:FlxSound = FlxG.sound.play(Assets.getSound(Paths.ogg("assets/sounds/menus/OptionsMenu/scroll"), false), 0.35);

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

        FlxG.inputs.remove(keyboard);

        keyboard.enabled = false;

        keyboard.destroy();
    }
}