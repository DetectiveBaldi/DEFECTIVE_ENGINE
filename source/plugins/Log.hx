package plugins;

import flixel.FlxG;

import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.text.FlxText;

import flixel.util.FlxColor;

import core.Paths;

class Log extends FlxTypedGroup<FlxText>
{
    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var i:Int = members.length - 1;

        while (i >= 0.0)
        {
            var log:FlxText = members[i];

            log.alpha -= elapsed * 0.25;

            if (log.alpha <= 0.0)
                remove(log, true).destroy();

            i--;
        }
    }

    public function info(prefix:String = "[INFO]", info:String):FlxText
    {
        var output:FlxText = new FlxText(camera.viewMarginLeft, camera.viewMarginTop, FlxG.width, '${prefix} ${info}', 24);

        output.moves = true;

        output.scrollFactor.set();

        output.antialiasing = true;

        output.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        output.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        add(output);

        for (i in 0 ... members.length - 1)
            members[i].y += output.height;

        return output;
    }

    public function warning(warning:String):FlxText
    {
        var output:FlxText = info("[WARNING]", warning);

        output.color = FlxColor.YELLOW;

        return output;
    }

    public function error(error:String):FlxText
    {
        var output:FlxText = info("[ERROR]", error);

        output.color = FlxColor.RED;

        return output;
    }
}