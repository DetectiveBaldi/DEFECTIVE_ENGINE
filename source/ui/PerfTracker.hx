package ui;

import haxe.Timer;

import openfl.text.TextField;
import openfl.text.TextFormat;

import flixel.FlxG;

import util.MathUtil;

class PerfTracker extends TextField
{
    public var timestamps:Array<Float>;

    public function new(_x:Float = 0.0, _y:Float = 0.0):Void
    {
        super();

        width = 250;

        height = 100;

        x = _x;

        y = _y;

        selectable = false;

        defaultTextFormat = new TextFormat("Monsterrat", 14, 0xFFFFFFFF, true);

        text = "FPS: 0";

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

        text = 'FPS: ${MathUtil.minInt(FlxG.drawFramerate, timestamps.length)}';

        #if debug
            text += '\nRAM: ${flixel.util.FlxStringUtil.formatBytes(openfl.system.System.totalMemoryNumber)}';

            text += '\nVRAM: ${flixel.util.FlxStringUtil.formatBytes(FlxG.stage.context3D.totalGPUMemory)}';

            text += '\nMax Texture Size: ${FlxG.bitmap.maxTextureSize}^2px';
        #end
    }
}