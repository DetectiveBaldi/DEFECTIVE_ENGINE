package ui;

import openfl.geom.Rectangle;

import flixel.FlxSprite;

import flixel.math.FlxMath;

import flixel.group.FlxSpriteContainer;

import flixel.math.FlxRect;

import flixel.util.FlxColor;
import flixel.util.FlxSignal;

import flixel.ui.FlxBar;

/**
 * An alternative to `flixel.ui.FlxBar` containing fixed fill directions and a couple optimizations.
 */
class ProgressBar extends FlxSpriteContainer
{
    public var percent(get, set):Float;

    @:noCompletion
    function get_percent():Float
    {
        return ((value - min) / (max - min)) * 100.0;
    }

    @:noCompletion
    function set_percent(percent:Float):Float
    {
        value = (range / max) * percent;

        return percent;
    }

    public var value(default, set):Float;

    @:noCompletion
    function set_value(value:Float):Float
    {
        value = FlxMath.bound(value, min, max);

        this.value = value;

        updateClipping();

        if (value == min)
            onEmpty.dispatch();

        if (value == max)
            onFill.dispatch();
        
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

    public var onEmpty:FlxSignal;

    public var onFill:FlxSignal;

    public var barWidth:Int;

    public var barHeight:Int;

    public var fillDirection(default, set):ProgressBarFillDirection;

    @:noCompletion
    function set_fillDirection(fillDirection:ProgressBarFillDirection):ProgressBarFillDirection
    {
        this.fillDirection = fillDirection;

        updateClipping();

        return fillDirection;
    }

    public var emptySide:ProgressBarSideSprite;

    public var fillSide:ProgressBarSideSprite;

    public var border:FlxSprite;

    public var borderSize(default, set):Int;

    @:noCompletion
    function set_borderSize(borderSize:Int):Int
    {
        this.borderSize = borderSize;

        border.graphic.bitmap.fillRect(new Rectangle(0.0, 0.0, barWidth, barHeight), FlxColor.BLACK);

        border.graphic.bitmap.fillRect(new Rectangle(borderSize, borderSize, barWidth - borderSize * 2.0, barHeight - borderSize * 2.0), FlxColor.TRANSPARENT);

        return borderSize;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, barWidth:Int = 600, barHeight:Int = 25, fillDirection:ProgressBarFillDirection):Void
    {
        super();

        setPosition(x, y);

        @:bypassAccessor
            value = 50.0;

        min = 0.0;

        max = 100.0;

        onEmpty = new FlxSignal();

        onFill = new FlxSignal();

        @:bypassAccessor
            this.barWidth = barWidth;

        @:bypassAccessor
            this.barHeight = barHeight;

        @:bypassAccessor
            this.fillDirection = fillDirection;
        
        emptySide = new ProgressBarSideSprite();

        emptySide.makeGraphic(barWidth, barHeight, FlxColor.WHITE);

        emptySide.color = FlxColor.RED;

        emptySide.clipRect = FlxRect.get();

        add(emptySide);

        fillSide = new ProgressBarSideSprite();

        fillSide.makeGraphic(barWidth, barHeight, FlxColor.WHITE);

        fillSide.color = FlxColor.LIME;

        fillSide.clipRect = FlxRect.get();

        add(fillSide);

        updateClipping();

        border = new FlxSprite();

        border.makeGraphic(barWidth, barHeight, FlxColor.BLACK);
        
        add(border);

        borderSize = 0;
    }

    override function destroy():Void
    {
        super.destroy();

        onEmpty.destroy();

        onFill.destroy();

        emptySide.clipRect.put();

        fillSide.clipRect.put();
    }

    public function updateClipping():Void
    {
        switch (fillDirection:ProgressBarFillDirection)
        {
            case LEFT_TO_RIGHT:
            {
                emptySide.clipRect.width = emptySide.width * (1.0 - percent * 0.01);

                emptySide.clipRect.height = emptySide.height;

                emptySide.clipRect.x = emptySide.width - emptySide.clipRect.width;

                emptySide.clipRect = emptySide.clipRect;

                fillSide.clipRect.width = fillSide.width * (percent * 0.01);

                fillSide.clipRect.height = fillSide.height;

                fillSide.clipRect.x = 0.0;

                fillSide.clipRect = fillSide.clipRect;
            }

            case RIGHT_TO_LEFT:
            {
                emptySide.clipRect.width = emptySide.width * (1.0 - percent * 0.01);

                emptySide.clipRect.height = emptySide.height;

                emptySide.clipRect.x = 0.0;

                emptySide.clipRect = emptySide.clipRect;

                fillSide.clipRect.width = fillSide.width * (percent * 0.01);

                fillSide.clipRect.height = fillSide.height;

                fillSide.clipRect.x = fillSide.width - fillSide.clipRect.width;

                fillSide.clipRect = fillSide.clipRect;
            }
        }
    }
}

enum abstract ProgressBarFillDirection(String) from String to String
{
    var LEFT_TO_RIGHT;

    var RIGHT_TO_LEFT;
}

class ProgressBarSideSprite extends FlxSprite
{
    @:noCompletion
    override function set_clipRect(clipRect:FlxRect):FlxRect
    {
        this.clipRect = clipRect;

		frame = frames?.frames[animation.frameIndex];

        return clipRect;
    }
}