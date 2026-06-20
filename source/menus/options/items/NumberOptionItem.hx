package menus.options.items;

import flixel.FlxG;

import ui.AtlasText;

class IntOptionItem extends VarOptionItem<Int>
{
    public var min:Int;

    public var max:Int;

    public var step:Int;

    public var holdTime:Float;

    public var valueText:AtlasText;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, description:String, option:String,
        min:Int, max:Int, step:Int):Void
    {
        super(x, y, title, description, option);

        this.min = min;

        this.max = max;

        this.step = step;

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

        if (busy)
            return;

        var pressLeft:Bool = FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT;

        var holdLeft:Bool = FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT;

        var pressRight:Bool = FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT;

        var holdRight:Bool = FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT;

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
}

// TODO: Make this work
typedef FloatOptionItem = IntOptionItem