package menus.options.items;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import flixel.math.FlxMath;

import core.Options;
import ui.AtlasText;

class KeybindOptionItem extends VarOptionItem<Array<Int>>
{
    public var selectedIndex:Int;

    public var valueText:AtlasText;

    public var holdTime:Float = 0.0;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, option:String):Void
    {
        super(x, y, title, "", option);

        type = KEYBIND;

        selectedIndex = 0;

        valueText = new AtlasText(0.0, 0.0, "");

        valueText.text = getValueString();

        valueText.x = titleText.x + valueText.fontData.maxWidth * 6.0;

        add(valueText);

        holdTime = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (status == ENABLED)
        {
            if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
            {
                selectedIndex = FlxMath.wrap(selectedIndex + (FlxG.keys.justPressed.LEFT ? -1 : 1), 0, value.length - 1);

                playScrollSound();
            }

            if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
                selectedIndex = 0;

            if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
                valueText.text = getValueString();

            if ((FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera)) || FlxG.keys.justPressed.ENTER)
            {
                FlxG.sound.soundTrayEnabled = false;

                description = "Press a key to update this keybind. Hold BACKSPACE to\nreset, or ESCAPE to delete.";

                status = LOCKED;

                valueText.text = "...";

                playScrollSound();
            }
        }
        else
        {
            if (status == LOCKED)
            {
                var key:Int = FlxG.keys.firstPressed();

                if (key != -1.0)
                    holdTime += elapsed;

                var heldList:Array<FlxInput<FlxKey>> = FlxG.keys.getIsDown();

                if (heldList.length > 1.0)
                {
                    FlxG.sound.soundTrayEnabled = true;

                    status = ENABLED;

                    valueText.text = getValueString();

                    holdTime = 0.0;
                }
                
                if (FlxG.keys.pressed.BACKSPACE || FlxG.keys.pressed.ESCAPE)
                {
                    if (holdTime >= 1.0)
                    {
                        var periods:Int = Math.floor(holdTime * 4000.0 / 1000.0) % 4;

                        var text:String = "";

                        for (i in 0 ... periods)
                            text += ".";

                        valueText.text = text;

                        if (holdTime >= 3.0)
                        {
                            FlxG.sound.soundTrayEnabled = true;

                            status = ENABLED;

                            if (FlxG.keys.pressed.BACKSPACE)
                                value[selectedIndex] = Options.defaultKeybinds[option][selectedIndex];
                            else
                                value[selectedIndex] = -1;

                            setValue(value);

                            valueText.text = getValueString();

                            holdTime = 0.0;

                            playCancelSound();
                        }
                    }
                }

                var key:Int = -1;

                var firstJustPressed:Int = FlxG.keys.firstJustPressed();

                if (firstJustPressed != -1.0 && firstJustPressed != FlxKey.BACKSPACE && firstJustPressed != FlxKey.ESCAPE)
                    key = firstJustPressed;

                var firstJustReleased:Int = FlxG.keys.firstJustReleased();

                if (firstJustReleased != 1.0 && firstJustReleased == FlxKey.BACKSPACE || firstJustReleased == FlxKey.ESCAPE)
                    key = firstJustReleased;

                if (key != -1.0)
                {
                    FlxG.sound.soundTrayEnabled = true;

                    status = ENABLED;

                    description = "";

                    value[selectedIndex] = key;

                    setValue(value);

                    valueText.text = getValueString();

                    holdTime = 0.0;

                    playScrollSound();
                }
            }
        }
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.sound.soundTrayEnabled = true;
    }

    override function getValue():Array<Int>
    {
        return Options.keybinds[option];
    }

    override function setValue(v:Array<Int>):Array<Int>
    {
        value = v;

        Options.keybinds[option] = v;

        Options.keybinds = Options.keybinds;

        onUpdate.dispatch(v);

        return value;
    }

    public function getValueString():String
    {
        var str:String = "";

        for (i in 0 ... value.length)
        {
            var highlight:Bool = selectedIndex == i && value.length != 1.0;

            var key:Int = value[i];

            if (highlight)
                str += "(";

            str += FlxKey.toStringMap[key];

            if (highlight)
                str += ")";

            str += " ";
        }

        return str;
    }
}