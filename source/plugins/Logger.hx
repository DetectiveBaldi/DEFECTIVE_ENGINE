package plugins;

import flixel.FlxG;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.text.FlxText;

import flixel.util.FlxColor;

import core.Paths;

class Logger extends FlxTypedContainer<FlxText>
{
    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var i:Int = members.length - 1;

        while (i >= 0.0)
        {
            var log:FlxText = members[i];

            if (!log.isOnScreen())
                remove(log, true).destroy();

            i--;
        }
    }

    public function logInfo(prefix:String = "[INFO]", info:String):FlxText
    {
        var output:FlxText = new FlxText(0.0, 0.0, FlxG.width, '${prefix} ${info}', 24);

        output.moves = true;

        output.scrollFactor.set();

        output.velocity.set(-FlxG.random.int(0, 100), -FlxG.random.int(0, 100));

        output.acceleration.set(0.0, 550.0);

        output.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        output.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        add(output);

        return output;
    }

    public function logWarning(warning:String):FlxText
    {
        var output:FlxText = logInfo("[WARNING]", warning);

        output.color = FlxColor.YELLOW;

        return output;
    }

    public function logError(error:String):FlxText
    {
        var output:FlxText = logInfo("[ERROR]", error);

        output.color = FlxColor.RED;

        return output;
    }
}