package objects;

import haxe.Timer;

import openfl.system.System;

import openfl.text.TextField;
import openfl.text.TextFormat;

import flixel.FlxG;

import flixel.math.FlxMath;

class PerformanceStats extends TextField
{
    @:noCompletion
        var times:Array<Float>;

    public function new():Void
    {
        super();

        width = 250;

        height = 100;

        selectable = false;

        defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFFFF, true);

        times = new Array<Float>();
    }

    override function __enterFrame(deltaTime:Int):Void
    {
        super.__enterFrame(deltaTime);

        var now:Float = Timer.stamp();

        times.push(now);

        while (times[0] < now - 1)
            times.shift();

        text = 'FPS: ${Math.min(times.length, FlxG.updateFramerate)}\nMemory: ${FlxMath.roundDecimal(System.totalMemory / Math.pow(1024, 2), 2)} MB';
    }
}