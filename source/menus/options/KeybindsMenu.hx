package menus.options;

import flixel.FlxSubState;
import flixel.util.FlxColor;

class KeybindsMenu extends FlxSubState
{
    public function new():Void
    {
        super(FlxColor.BLACK);

        _bgSprite.alpha = 0.5;
    }
}