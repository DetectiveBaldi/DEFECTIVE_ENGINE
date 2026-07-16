package menus.options.items;

import flixel.FlxG;
import flixel.math.FlxMath;

import ui.AtlasText;

class FloatOptionItem extends VarOptionItem<Float>
{
    public var valueText:AtlasText;

    public var emptyTextStr:String;

    public var fullTextStr:String;

    public var min:Float;

    public var max:Float;

    public var step:Float;

    public var displayType:NumOptionDisplayType;

    public var holdTime:Float;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, description:String, option:String, min:Float, max:Float, step:Float, emptyTextStr:String, fullTextStr:String,
        displayType:NumOptionDisplayType):Void
    {
        super(x, y, '${title}:', description, option);

        type = INT;

        valueText = new AtlasText(0.0, 0.0, "");

        valueText.x = titleText.x + titleText.width + 25.0;

        add(valueText);

        this.emptyTextStr = emptyTextStr;

        this.fullTextStr = fullTextStr;

        this.min = min;

        this.max = max;

        this.step = step;

        this.displayType = displayType;

        valueText.text = getValueString();

        holdTime = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (status == ENABLED)
        {
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
                    setValue(value + (holdLeft ? -step : step));
                    
                    holdTime = 0.0;
                }

                holdTime += elapsed * 1.75;

                var repeatRate:Float = Math.floor(holdTime) - 0.75;

                if (repeatRate > 0.0)
                {
                    setValue(value + (holdLeft ? -step : step));

                    holdTime -= (FlxG.keys.pressed.SHIFT ? 0.01 : 0.1);
                }
            }
        }
    }
    
    override function setValue(v:Float):Float
    {
        v = FlxMath.bound(v, min, max);

        v = Math.round(v / step) * step;

        super.setValue(v);

        valueText.text = getValueString();

        return v;
    }

    public function setDisplayType(v:NumOptionDisplayType):NumOptionDisplayType
    {
        displayType = v;

        valueText.text = getValueString();

        return v;
    }

    public function getValueString():String
    {
        if (value == min && emptyTextStr != "")
            return emptyTextStr;

        if (value == max && fullTextStr != "")
            return fullTextStr;

        if (displayType == DEFAULT)
            return Std.string(value);

        return '${Math.round((value / max) * 100.0)}%';
    }
}

class IntOptionItem extends VarOptionItem<Int>
{
    public var valueText:AtlasText;

    public var emptyTextStr:String;

    public var fullTextStr:String;

    public var min:Int;

    public var max:Int;

    public var step:Int;

    public var displayType:NumOptionDisplayType;

    public var holdTime:Float;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, description:String, option:String, min:Int, max:Int, step:Int, emptyTextStr:String, fullTextStr:String,
        displayType:NumOptionDisplayType):Void
    {
        super(x, y, '${title}:', description, option);

        type = INT;

        valueText = new AtlasText(0.0, 0.0, "");

        valueText.x = titleText.x + titleText.width + 25.0;

        add(valueText);

        this.emptyTextStr = emptyTextStr;

        this.fullTextStr = fullTextStr;

        this.min = min;

        this.max = max;

        this.step = step;

        this.displayType = displayType;

        valueText.text = getValueString();

        holdTime = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (status == ENABLED)
        {
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
                    setValue(value + (holdLeft ? -step : step));
                    
                    holdTime = 0.0;
                }

                holdTime += elapsed * 1.75;

                var repeatRate:Float = Math.floor(holdTime) - 0.75;

                if (repeatRate > 0.0)
                {
                    setValue(value + (holdLeft ? -step : step));

                    holdTime -= (FlxG.keys.pressed.SHIFT ? 0.01 : 0.1);
                }
            }
        }
    }
    
    override function setValue(v:Int):Int
    {
        v = Math.floor(FlxMath.bound(v, min, max));

        v = Math.round(v / step) * step;

        super.setValue(v);

        valueText.text = getValueString();

        return v;
    }

    public function setDisplayType(v:NumOptionDisplayType):NumOptionDisplayType
    {
        displayType = v;

        valueText.text = getValueString();

        return v;
    }

    public function getValueString():String
    {
        if (value == min && emptyTextStr != "")
            return emptyTextStr;

        if (value == max && fullTextStr != "")
            return fullTextStr;
        
        if (displayType == DEFAULT)
            return Std.string(value);

        return '${Math.round((value / max) * 100.0)}%';
    }
}

enum NumOptionDisplayType
{
    DEFAULT;

    PERCENT;
}