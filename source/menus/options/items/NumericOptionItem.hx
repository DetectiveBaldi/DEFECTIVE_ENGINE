package menus.options.items;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.math.FlxMath;

import flixel.text.FlxText;

import flixel.util.FlxColor;

import core.AssetCache;
import core.Paths;

class IntOptionItem extends VariableOptionItem<Int>
{
    override function set_value(_value:Int):Int
    {
        super.set_value(Math.floor(FlxMath.bound(_value, min, max)));

        valueText.text = '<${value}>';

        return value;
    }
    
    public var selectable:Bool;
    
    public var valueText:FlxText;

    public var lButton:FlxSprite;

    public var rButton:FlxSprite;

    public var min:Int;

    public var max:Int;

    public var step:Int;

    public var holdTime:Float;

    public function new(_x:Float = 0.0, _y:Float = 0.0, _title:String, _description:String, _option:String, _min:Int, _max:Int, _step:Int):Void
    {
        super(_x, _y, _title, _description, _option);

        titleText.alignment = LEFT;

        titleText.x = background.x + 50.0;

        selectable = false;

        valueText = new FlxText(0.0, 0.0, background.width, "", 48);

        valueText.antialiasing = true;

        valueText.color = FlxColor.BLACK;

        valueText.font = Paths.font(Paths.ttf("Ubuntu Regular"));

        valueText.alignment = RIGHT;

        valueText.setPosition(background.x - 50.0, background.getMidpoint().y - valueText.height * 0.5);

        add(valueText);

        min = _min;

        max = _max;

        value = value;

        lButton = new FlxSprite();

        lButton.loadGraphic(AssetCache.getGraphic("menus/options/items/NumericOptionItem/lButton"), true, 48, 96);

        lButton.antialiasing = true;

        lButton.animation.add("0", [0], 0.0, true);

        lButton.animation.add("1", [1], 0.0, true);
        
        lButton.animation.play("0");

        lButton.scale.set(1.25, 1.25);

        lButton.updateHitbox();

        lButton.setPosition(background.x - lButton.width - 75.0, background.getMidpoint().y - lButton.height * 0.5 - 40.0);

        add(lButton);

        rButton = new FlxSprite();

        rButton.loadGraphic(AssetCache.getGraphic("menus/options/items/NumericOptionItem/rButton"), true, 48, 96);

        rButton.antialiasing = true;

        rButton.animation.add("0", [0], 0.0, false);

        rButton.animation.add("1", [1], 0.0, false);
        
        rButton.animation.play("0");

        rButton.scale.set(1.25, 1.25);

        rButton.updateHitbox();

        rButton.setPosition(background.x - rButton.width, background.getMidpoint().y - rButton.height * 0.5 - 40.0);

        add(rButton);

        step = _step;

        holdTime = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (selectable)
        {
            if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
            {
                if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
                {
                    value += FlxG.keys.justPressed.LEFT ? -1 : 1;
                    
                    holdTime = 0.0;
                }

                if (FlxG.keys.pressed.LEFT)
                    lButton.animation.play("1");

                if (FlxG.keys.pressed.RIGHT)
                    rButton.animation.play("1");

                var rep:Float = Math.floor(holdTime += elapsed * 1.75) - 0.75;

                if (rep > 0.0)
                {
                    value += FlxG.keys.pressed.LEFT ? -1 : 1;

                    holdTime -= (FlxG.keys.pressed.SHIFT ? 0.01 : 0.1);
                }
            }

            if (FlxG.keys.justReleased.LEFT)
                lButton.animation.play("0");
    
            if (FlxG.keys.justReleased.RIGHT)
                rButton.animation.play("0");
        }
        else
        {
            lButton.animation.play("0");

            rButton.animation.play("0");

            holdTime = 0.0;
        }
    }
}