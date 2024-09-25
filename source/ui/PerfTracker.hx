package ui;

import haxe.Timer;

import openfl.text.TextField;
import openfl.text.TextFormat;

import flixel.FlxG;

import flixel.math.FlxMath;

import util.MathUtil;

class PerfTracker extends TextField
{
    @:noCompletion
        var times:Array<Float>;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super();

        width = 250;

        height = 100;

        this.x = x;

        this.y = y;

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

        text = 'FPS: ${MathUtil.minInt(FlxG.updateFramerate, times.length)}' #if !html5 + '\nRAM: ${FlxMath.roundDecimal(#if hl openfl.system.System.totalMemory #else cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE) #end / Math.pow(1024, 2), 2)} MB\nVRAM: ${FlxMath.roundDecimal(FlxG.stage.context3D.totalGPUMemory / Math.pow(1024, 2), 2)} MB' #end;
    }
}