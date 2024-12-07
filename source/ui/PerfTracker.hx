package ui;

import haxe.Timer;

import openfl.text.TextField;
import openfl.text.TextFormat;

import flixel.FlxG;

import util.MathUtil;

class PerfTracker extends TextField
{
    @:noCompletion
    var timestamps:Array<Float>;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super();

        width = 250;

        height = 100;

        this.x = x;

        this.y = y;

        selectable = false;

        defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFFFF, true);

        timestamps = new Array<Float>();
    }

    @:noCompletion
    override function __enterFrame(deltaTime:Int):Void
    {
        super.__enterFrame(deltaTime);

        var now:Float = Timer.stamp();

        timestamps.push(now);

        while (timestamps[0] < now - 1.0)
            timestamps.shift();

        text = 'FPS: ${MathUtil.minInt(FlxG.drawFramerate, timestamps.length)}\nRAM: ${flixel.math.FlxMath.roundDecimal(openfl.system.System.totalMemoryNumber / Math.pow(1024, 2), 2)} MB\nVRAM: ${flixel.math.FlxMath.roundDecimal(FlxG.stage.context3D.totalGPUMemory / Math.pow(1024, 2), 2)} MB';
    }
}