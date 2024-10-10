package plugins;

import flixel.FlxG;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.text.FlxText;

import flixel.util.FlxColor;

class Logger extends FlxTypedContainer<FlxText>
{
    public static function logInfo(info:String):FlxText
    {
        var logger:Logger = FlxG.plugins.get(Logger);

        if (logger == null)
            throw "`plugins.Logger`: There is no available `plugins.Logger`! Use `flixel.FlxG.plugins.addPlugin` to register one.";

        var output:FlxText = new FlxText(0.0, 0.0, FlxG.width, info, 24);

        output.setBorderStyle(SHADOW, FlxColor.BLACK, 3.5);

        output.moves = true;

        output.acceleration.set(0.0, 550.0);

        output.velocity.set(-FlxG.random.int(0, 100), -FlxG.random.int(0, 100));

        logger.add(output);

        return output;
    }

    public static function logWarning(warning:String):FlxText
    {
        var output:FlxText = logInfo(warning);

        output.color = FlxColor.YELLOW;

        return output;
    }

    public static function logError(error:String):FlxText
    {
        var output:FlxText = logInfo(error);

        output.color = FlxColor.RED;

        return output;
    }

    public function new():Void
    {
        super();
    }

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
}