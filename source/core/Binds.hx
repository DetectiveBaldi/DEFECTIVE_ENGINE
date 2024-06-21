package core;

import flixel.FlxG;

import flixel.input.FlxInput.FlxInputState;

import flixel.input.keyboard.FlxKey;

class Binds
{
    public static var list:Map<String, Array<FlxKey>> =
    [
        "NOTE:LEFT" => [FlxKey.Z, FlxKey.LEFT],

        "NOTE:DOWN" => [FlxKey.X, FlxKey.DOWN],

        "NOTE:UP" => [FlxKey.PERIOD, FlxKey.UP],

        "NOTE:RIGHT" => [FlxKey.SLASH, FlxKey.RIGHT],

        "UI:ACCEPT" => [FlxKey.ENTER],

        "UI:CANCEL" => [FlxKey.BACKSPACE],

        "DEBUG:0" => [FlxKey.EIGHT]
    ];

    public static function checkStatus(bind:String, status:FlxInputState):Null<Bool>
    {
        if (!list.exists(bind))
        {
            return null;
        }

        for (i in 0 ... list[bind].length)
        {
            if (FlxG.keys.checkStatus(list[bind][i], status))
            {
                return true;
            }
        }

        return false;
    }

    public static function bindsJustPressed(binds:Array<String>):Null<Bool>
    {
        for (i in 0 ... binds.length)
        {
            if (!list.exists(binds[i]))
            {
                return null;
            }

            if (checkStatus(binds[i], JUST_PRESSED))
            {
                return true;
            }
        }

        return false;
    }

    public static function bindsPressed(binds:Array<String>):Null<Bool>
    {
        for (i in 0 ... binds.length)
        {
            if (!list.exists(binds[i]))
            {
                return null;
            }

            if (checkStatus(binds[i], PRESSED))
            {
                return true;
            }
        }

        return false;
    }

    public static function bindsJustReleased(binds:Array<String>):Null<Bool>
    {
        for (i in 0 ... binds.length)
        {
            if (!list.exists(binds[i]))
            {
                return null;
            }

            if (checkStatus(binds[i], JUST_RELEASED))
            {
                return true;
            }
        }

        return false;
    }

    public static function bindsReleased(binds:Array<String>):Null<Bool>
    {
        for (i in 0 ... binds.length)
        {
            if (!list.exists(binds[i]))
            {
                return null;
            }

            if (checkStatus(binds[i], RELEASED))
            {
                return true;
            }
        }

        return false;
    }
}