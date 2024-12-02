package menus;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

import flixel.math.FlxMath;

import core.AssetMan;
import core.Options;
import core.Paths;

using util.ArrayUtil;

class KeybindOptionItem extends ConfigurableOptionItem<Array<Int>>
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

        enabled = true;

        keyboard = new FlxSprite(0.0, 0.0, AssetMan.graphic(Paths.png("assets/images/menus/KeybindOptionItem/keyboard")));

        keyboard.antialiasing = true;

        keyboard.setGraphicSize(192.0, 192.0);

        keyboard.updateHitbox();

        keyboard.setPosition(-175.0, background.getMidpoint().y - keyboard.height * 0.5);

        add(keyboard);

        _keyboard = new FlxKeyboard();

        _keyboard.enabled = false;

        FlxG.inputs.addInput(_keyboard);

        nameText.text = switch (bindIndex:Int)
        {
            case 1:
                '${name}: ${FlxKey.toStringMap[value[0]]} (${FlxKey.toStringMap[value[1]]})';

            default:
                '${name}: (${FlxKey.toStringMap[value[0]]}) ${FlxKey.toStringMap[value[1]]}';
        }
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
                    FlxG.sound.play(AssetMan.sound(Paths.ogg("assets/sounds/menus/OptionsMenu/scroll"), false), 0.35);

                if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
                {
                    nameText.text = switch (bindIndex:Int)
                    {
                        case 1:
                            '${name}: ${FlxKey.toStringMap[value[0]]} (${FlxKey.toStringMap[value[1]]})';

                        default:
                            '${name}: (${FlxKey.toStringMap[value[0]]}) ${FlxKey.toStringMap[value[1]]}';
                    }
                }

                if (FlxG.keys.justPressed.ENTER)
                {
                    FlxG.keys.enabled = false;

                    nameText.text = "...";

                    _keyboard.enabled = true;

                    _keyboard.reset();
                }
            }
            else
            {
                var firstJustPressed:Int = _keyboard.firstJustPressed();

                if (firstJustPressed != -1)
                {
                    FlxG.keys.enabled = true;

                    FlxG.keys.reset();

                    FlxG.sound.play(AssetMan.sound(Paths.ogg("assets/sounds/menus/OptionsMenu/scroll"), false), 0.35);

                    value[bindIndex] = firstJustPressed;

                    value = value;

                    nameText.text = switch (bindIndex:Int)
                    {
                        case 1:
                            '${name}: ${FlxKey.toStringMap[value[0]]} (${FlxKey.toStringMap[value[1]]})';

                        default:
                            '${name}: (${FlxKey.toStringMap[value[0]]}) ${FlxKey.toStringMap[value[1]]}';
                    }

                    _keyboard.enabled = false;
                }
            }
        }
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.inputs.remove(_keyboard);

        _keyboard.destroy();
    }
}