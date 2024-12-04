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

class KeybindOptionItem extends VariableOptionItem<Array<Int>>
{
    override function get_value():Array<Int>
    {
        return Options.keybinds[option];
    }

    override function set_value(_value:Array<Int>):Array<Int>
    {
        Options.keybinds[option] = _value;

        return value;
    }

    public var enabled:Bool;

    public var keyboard:FlxSprite;

    public var _keyboard:FlxKeyboard;

    public var bindIndex:Int;

    public function new(x:Float = 0.0, y:Float = 0.0, name:String, description:String, option:String):Void
    {
        super(x, y, name, description, option);

        nameText.size = 36;

        nameText.setPosition(background.getMidpoint().x - nameText.width * 0.5, background.getMidpoint().y - nameText.height * 0.5);

        enabled = false;

        keyboard = new FlxSprite(0.0, 0.0, Assets.graphic(Paths.png("assets/images/menus/KeybindOptionItem/keyboard")));

        keyboard.active = false;

        keyboard.antialiasing = true;

        keyboard.setGraphicSize(192.0, 192.0);

        keyboard.updateHitbox();

        keyboard.setPosition(-175.0, background.getMidpoint().y - keyboard.height * 0.5);

        add(keyboard);

        _keyboard = new FlxKeyboard();

        _keyboard.enabled = false;

        FlxG.inputs.addInput(_keyboard);

        bindIndex = 0;

        nameText.text = bindIndex == 0 ? '${name}: (${FlxKey.toStringMap[value[0]]}) ${FlxKey.toStringMap[value[1]]}' : '${name}: ${FlxKey.toStringMap[value[0]]} (${FlxKey.toStringMap[value[1]]})';
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (enabled)
        {
            if (FlxG.keys.enabled)
            {
                if (FlxG.keys.justPressed.LEFT)
                    bindIndex = FlxMath.wrap(bindIndex - 1, 0, 1);

                if (FlxG.keys.justPressed.RIGHT)
                    bindIndex = FlxMath.wrap(bindIndex + 1, 0, 1);

                if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
                {
                    nameText.text = bindIndex == 0 ? '${name}: (${FlxKey.toStringMap[value[0]]}) ${FlxKey.toStringMap[value[1]]}' : '${name}: ${FlxKey.toStringMap[value[0]]} (${FlxKey.toStringMap[value[1]]})';

                    var scroll:FlxSound = FlxG.sound.play(Assets.sound(Paths.ogg("assets/sounds/menus/OptionsMenu/scroll"), false), 0.35);

                    scroll.onComplete = scroll.kill;
                }

                if (FlxG.keys.justPressed.ENTER)
                {
                    FlxG.mouse.enabled = false;

                    FlxG.keys.enabled = false;

                    nameText.text = "...";

                    _keyboard.enabled = true;

                    _keyboard.reset();
                }
            }
            else
            {
                var firstJustPressed:Int = _keyboard.firstJustPressed();

                if (firstJustPressed != -1.0)
                {
                    FlxG.mouse.enabled = true;

                    FlxG.keys.enabled = true;

                    FlxG.keys.reset();

                    value[bindIndex] = firstJustPressed;

                    value = value;

                    nameText.text = bindIndex == 0 ? '${name}: (${FlxKey.toStringMap[value[0]]}) ${FlxKey.toStringMap[value[1]]}' : '${name}: ${FlxKey.toStringMap[value[0]]} (${FlxKey.toStringMap[value[1]]})';

                    _keyboard.enabled = false;

                    var scroll:FlxSound = FlxG.sound.play(Assets.sound(Paths.ogg("assets/sounds/menus/OptionsMenu/scroll"), false), 0.35);

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

        FlxG.inputs.remove(_keyboard);

        _keyboard.enabled = false;

        _keyboard.destroy();
    }
}