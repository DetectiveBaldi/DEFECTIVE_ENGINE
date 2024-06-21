package tools.formats;

import haxe.Json;

import core.Song.SimpleSong;

class BaseFormat
{
    public static function build(path:String):SimpleSong
    {
        #if sys
            var output:SimpleSong = cast Json.parse(sys.io.File.getContent(path));
        #else
            var output:SimpleSong = cast Json.parse(openfl.utils.Assets.getText(path));
        #end

        return output;
    }
}