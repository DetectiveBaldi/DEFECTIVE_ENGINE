package menus.options.items;

import flixel.FlxG;
import flixel.math.FlxMath;

import ui.AtlasText;

class IntOptionItem extends VarOptionItem<Int>
{
    public var min:Int;

    public var max:Int;

    public var holdTime:Float;

    public var valueText:AtlasText;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, description:String, option:String,
        min:Int, max:Int):Void
    {
        super(x, y, title, description, option);

        this.min = min;

        this.max = max;

        holdTime = 0.0;

        valueText = new AtlasText(0.0, 0.0, Std.string(value));

        valueText.x = titleText.x + titleText.width + 25.0;

        add(valueText);

        onUpdate.add((newValue:Int) ->
        {
            valueText.text = Std.string(newValue);

            valueText.setText();
        });
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!enabled)
            return;

        var overlap:Bool = FlxG.mouse.overlaps(this, camera);

        var pressLeft:Bool = (FlxG.mouse.justPressed && overlap) || FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT;

        var holdLeft:Bool = (FlxG.mouse.pressed && overlap) || FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT;

        var pressRight:Bool = (FlxG.mouse.justPressedRight && overlap) || FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT;

        var holdRight:Bool = (FlxG.mouse.pressedRight && overlap) || FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT;

        if (holdLeft && holdRight)
            holdTime = 0.0;

        if (holdLeft || holdRight && !(holdLeft && holdRight))
        {
            if (pressLeft || pressRight)
            {
                setValue(value + (holdLeft ? -1 : 1));
                
                holdTime = 0.0;
            }

            holdTime += elapsed * 1.75;

            var repeatRate:Float = Math.floor(holdTime) - 0.75;

            if (repeatRate > 0.0)
            {
                setValue(value + (holdLeft ? -1 : 1));

                holdTime -= (FlxG.keys.pressed.SHIFT ? 0.01 : 0.1);
            }
        }
    }

    override function setValue(value:Int):Void
    {
        value = Math.floor(FlxMath.bound(value, min, max));

        super.setValue(value);
    }
}

// TODO: Make this work
typedef FloatOptionItem = IntOptionItem