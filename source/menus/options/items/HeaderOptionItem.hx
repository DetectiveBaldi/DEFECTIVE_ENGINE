package menus.options.items;

import haxe.ui.containers.Header;

class HeaderOptionItem extends BaseOptionItem
{
    public function new(x:Float = 0.0, y:Float = 0.0, title:String):Void
    {
        super(x, y, title, "");

        type = HEADER;

        titleText.font = BOLD;
    }
}