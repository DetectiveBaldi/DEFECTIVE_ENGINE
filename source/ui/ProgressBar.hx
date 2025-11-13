package ui;

import openfl.geom.Rectangle;

import flixel.FlxSprite;

import flixel.math.FlxMath;

import flixel.group.FlxSpriteGroup;

import flixel.math.FlxRect;

import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

/**
 * An alternative to `flixel.ui.FlxBar` containing fixed fill directions and a couple optimizations.
 */
class ProgressBar extends FlxSpriteGroup
{
    public var percent(get, set):Float;

    @:noCompletion
    function get_percent():Float
    {
        return ((value - min) / (max - min)) * 100.0;
    }

    @:noCompletion
    function set_percent(_percent:Float):Float
    {
        value = (range / max) * _percent;

        return percent;
    }

    public var value(default, set):Float;

    @:noCompletion
    function set_value(_value:Float):Float
    {
        value = FlxMath.bound(_value, min, max);

        updateClipping();

        if (value == min)
            onEmptied.dispatch();

        if (value == max)
            onFilled.dispatch();
        
        return value;
    }

    public var min:Float;

    public var max:Float;

    public var range(get, never):Float;
    
    @:noCompletion
    function get_range():Float
    {
        return max - min;
    }

    public var onEmptied:FlxSignal;

    public var onFilled:FlxSignal;

    public var fillDirection(default, set):ProgressBarFillDirection;

    @:noCompletion
    function set_fillDirection(_fillDirection:ProgressBarFillDirection):ProgressBarFillDirection
    {
        fillDirection = _fillDirection;

        updateClipping();

        return fillDirection;
    }

    public var emptiedSide:ProgressBarSideSprite;

    public var filledSide:ProgressBarSideSprite;

    public var border:FlxSprite;

    public var borderSize:Int;

    public function new(x:Float = 0.0, y:Float = 0.0, width:Int = 600, height:Int = 25, borderSize:Int = 5,
        fillDirection:ProgressBarFillDirection):Void
    {
        super(x, y);

        min = 0.0;

        max = 100.0;

        onEmptied = new FlxSignal();

        onFilled = new FlxSignal();
        
        emptiedSide = new ProgressBarSideSprite();

        emptiedSide.clipRect = FlxRect.get();

        emptiedSide.color = FlxColor.RED;

        add(emptiedSide);

        filledSide = new ProgressBarSideSprite();

        filledSide.color = 0xFF66FF33;

        filledSide.clipRect = FlxRect.get();

        add(filledSide);

        border = new FlxSprite();
        
        add(border);

        this.width = width;

        this.height = height;

        regenerateSides();

        this.fillDirection = fillDirection;

        value = 50.0;

        this.borderSize = borderSize;

        regenerateBorder();
    }

    override function destroy():Void
    {
        super.destroy();

        onEmptied = cast FlxDestroyUtil.destroy(onEmptied);

        onFilled = cast FlxDestroyUtil.destroy(onFilled);

        emptiedSide.clipRect = FlxDestroyUtil.put(emptiedSide.clipRect);

        filledSide.clipRect = FlxDestroyUtil.put(filledSide.clipRect);
    }

    public function updateClipping():Void
    {
        emptiedSide.clipRect.set();

        filledSide.clipRect.set();

        switch (fillDirection:ProgressBarFillDirection)
        {
            case LEFT_TO_RIGHT:
            {
                emptiedSide.clipRect.width = emptiedSide.width * (1.0 - percent * 0.01);

                emptiedSide.clipRect.height = emptiedSide.height;

                emptiedSide.clipRect.x = emptiedSide.width - emptiedSide.clipRect.width;

                filledSide.clipRect.width = filledSide.width * (percent * 0.01);

                filledSide.clipRect.height = filledSide.height;
            }

            case RIGHT_TO_LEFT:
            {
                emptiedSide.clipRect.width = emptiedSide.width * (1.0 - percent * 0.01);

                emptiedSide.clipRect.height = emptiedSide.height;

                filledSide.clipRect.width = filledSide.width * (percent * 0.01);

                filledSide.clipRect.height = filledSide.height;

                filledSide.clipRect.x = filledSide.width - filledSide.clipRect.width;
            }

            case TOP_TO_BOTTOM:
            {
                emptiedSide.clipRect.width = emptiedSide.width;

                emptiedSide.clipRect.height = emptiedSide.height * (1.0 - percent * 0.01);

                emptiedSide.clipRect.y = emptiedSide.height - emptiedSide.clipRect.height;

                filledSide.clipRect.height = filledSide.height * (percent * 0.01);

                filledSide.clipRect.width = filledSide.width;
            }

            case BOTTOM_TO_TOP:
            {
                emptiedSide.clipRect.width = emptiedSide.width;

                emptiedSide.clipRect.height = emptiedSide.height * (1.0 - percent * 0.01);

                filledSide.clipRect.width = filledSide.width;

                filledSide.clipRect.height = filledSide.height * (percent * 0.01);

                filledSide.clipRect.y = filledSide.height - filledSide.clipRect.height;
            }
        }
    }

    public function regenerateSides():Void
    {
        var iWidth:Int = Math.floor(width);

        var iHeight:Int = Math.floor(height);

        emptiedSide.makeGraphic(iWidth, iHeight, FlxColor.WHITE);

        filledSide.makeGraphic(iWidth, iHeight, FlxColor.WHITE);
    }

    public function regenerateBorder():Void
    {
        border.makeGraphic(Math.floor(width), Math.floor(height), FlxColor.BLACK);

        border.graphic.bitmap.fillRect(new Rectangle(0.0, 0.0, width, height), 0xFF000000);

        border.graphic.bitmap.fillRect(new Rectangle(borderSize, borderSize,
            width - borderSize * 2.0, height - borderSize * 2.0), 0x00000000);
    }

    @:noCompletion
    override function get_width():Float
    {
        return width;
    }

    @:noCompletion
    override function get_height():Float
    {
        return height;
    }

    override function set_width(width:Float):Float
    {
        this.width = Math.floor(width);

        return width;
    }

    override function set_height(height:Float):Float
    {
        this.height = Math.floor(height);

        return height;
    }
}

class ProgressBarSideSprite extends FlxSprite
{
    @:noCompletion
    override function set_clipRect(clipRect:FlxRect):FlxRect
    {
        this.clipRect = clipRect;

        return clipRect;
    }
}

enum ProgressBarFillDirection
{
    LEFT_TO_RIGHT;

    RIGHT_TO_LEFT;

    TOP_TO_BOTTOM;

    BOTTOM_TO_TOP;
}