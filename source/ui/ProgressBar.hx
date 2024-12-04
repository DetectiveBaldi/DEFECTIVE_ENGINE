package ui;

import openfl.geom.Rectangle;

import flixel.FlxSprite;

import flixel.math.FlxMath;

import flixel.group.FlxSpriteGroup;

import flixel.math.FlxRect;

import flixel.util.FlxColor;
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

    public var barWidth:Int;

    public var barHeight:Int;

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

    public var borderSize(default, set):Int;

    @:noCompletion
        function set_borderSize(_borderSize:Int):Int
        {
            borderSize = _borderSize;

            border.graphic.bitmap.fillRect(new Rectangle(0.0, 0.0, barWidth, barHeight), FlxColor.BLACK);

            border.graphic.bitmap.fillRect(new Rectangle(borderSize, borderSize, barWidth - borderSize * 2.0, barHeight - borderSize * 2.0), FlxColor.TRANSPARENT);

            return borderSize;
        }

    public function new(x:Float = 0.0, y:Float = 0.0, barWidth:Int = 600, barHeight:Int = 25, fillDirection:ProgressBarFillDirection):Void
    {
        super(x, y);
        
        @:bypassAccessor
            value = 50.0;

        min = 0.0;

        max = 100.0;

        onEmptied = new FlxSignal();

        onFilled = new FlxSignal();

        this.barWidth = barWidth;

        this.barHeight = barHeight;

        @:bypassAccessor
            this.fillDirection = fillDirection;
        
        emptiedSide = new ProgressBarSideSprite();

        emptiedSide.makeGraphic(barWidth, barHeight, FlxColor.WHITE);

        emptiedSide.color = FlxColor.RED;

        emptiedSide.clipRect = FlxRect.get();

        add(emptiedSide);

        filledSide = new ProgressBarSideSprite();

        filledSide.makeGraphic(barWidth, barHeight, FlxColor.WHITE);

        filledSide.color = FlxColor.LIME;

        filledSide.clipRect = FlxRect.get();

        add(filledSide);

        updateClipping();

        border = new FlxSprite();

        border.makeGraphic(barWidth, barHeight, FlxColor.BLACK);
        
        add(border);

        borderSize = 0;
    }

    override function destroy():Void
    {
        super.destroy();

        onEmptied.destroy();

        onEmptied = null;

        onFilled.destroy();

        onFilled = null;

        emptiedSide.clipRect.put();

        filledSide.clipRect.put();
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

                emptiedSide.clipRect = emptiedSide.clipRect;

                filledSide.clipRect.width = filledSide.width * (percent * 0.01);

                filledSide.clipRect.height = filledSide.height;

                filledSide.clipRect = filledSide.clipRect;
            }

            case RIGHT_TO_LEFT:
            {
                emptiedSide.clipRect.width = emptiedSide.width * (1.0 - percent * 0.01);

                emptiedSide.clipRect.height = emptiedSide.height;

                emptiedSide.clipRect = emptiedSide.clipRect;

                filledSide.clipRect.width = filledSide.width * (percent * 0.01);

                filledSide.clipRect.height = filledSide.height;

                filledSide.clipRect.x = filledSide.width - filledSide.clipRect.width;

                filledSide.clipRect = filledSide.clipRect;
            }

            case TOP_TO_BOTTOM:
            {
                emptiedSide.clipRect.width = emptiedSide.width;

                emptiedSide.clipRect.height = emptiedSide.height * (1.0 - percent * 0.01);

                emptiedSide.clipRect.y = emptiedSide.height - emptiedSide.clipRect.height;

                emptiedSide.clipRect = emptiedSide.clipRect;

                filledSide.clipRect.height = filledSide.height * (percent * 0.01);

                filledSide.clipRect.width = filledSide.width;

                filledSide.clipRect = filledSide.clipRect;
            }

            case BOTTOM_TO_TOP:
            {
                emptiedSide.clipRect.width = emptiedSide.width;

                emptiedSide.clipRect.height = emptiedSide.height * (1.0 - percent * 0.01);

                emptiedSide.clipRect = emptiedSide.clipRect;

                filledSide.clipRect.width = filledSide.width;

                filledSide.clipRect.height = filledSide.height * (percent * 0.01);

                filledSide.clipRect.y = filledSide.height - filledSide.clipRect.height;

                filledSide.clipRect = filledSide.clipRect;
            }
        }
    }
}

class ProgressBarSideSprite extends FlxSprite
{
    @:noCompletion
        override function set_clipRect(_clipRect:FlxRect):FlxRect
        {
            clipRect = _clipRect;

            frame = frames?.frames[animation.frameIndex];

            return clipRect;
        }
}

enum abstract ProgressBarFillDirection(String) from String to String
{
    var LEFT_TO_RIGHT:ProgressBarFillDirection;

    var RIGHT_TO_LEFT:ProgressBarFillDirection;

    var TOP_TO_BOTTOM:ProgressBarFillDirection;

    var BOTTOM_TO_TOP:ProgressBarFillDirection;
}