package core;

import haxe.Timer;

import openfl.system.System;

import openfl.text.TextField;
import openfl.text.TextFormat;

import flixel.FlxG;

import flixel.math.FlxMath;

class Statistics extends TextField
{
    public var current(default, null):Map<String, Int>;

    @:noCompletion
        var times:Array<Float>;

    public function new():Void
    {
        super();

        width = 250;

        height = 100;

        selectable = false;

        defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFFFF, true);

        current = new Map<String, Int>();

        current["*"] = 0;

        current["-"] = 0;

        current["+"] = 0;

        times = new Array<Float>();
    }

    #if !flash override #end function __enterFrame(deltaTime:Int):Void
    {
        #if !flash
            super.__enterFrame(deltaTime);
        #end

        var now:Float = Timer.stamp();

        times.push(now);

        while (times[0] < now - 1)
        {
            times.shift();
        }

        current["*"] = times.length;

        current["-"] = System.totalMemory;

        if (current["-"] > current["+"])
        {
            current["+"] = current["-"];
        }

        text = 'FPS: ${Math.min(current["*"], FlxG.updateFramerate)}\nMemory: ${FlxMath.roundDecimal(current["-"] / Math.pow(1024, 2), 2)} MB (${FlxMath.roundDecimal(current["+"] / Math.pow(1024, 2), 2)} MB)';
    }
}