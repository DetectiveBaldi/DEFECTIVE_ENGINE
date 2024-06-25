package tools.formats;

import haxe.Json;

import core.Song.SimpleSong;

class BaseFormat
{
    public static function build(path:String):SimpleSong
    {
        #if html5
            var output:SimpleSong = cast Json.parse(openfl.utils.Assets.getText(path));
        #else
            var output:SimpleSong = cast Json.parse(sys.io.File.getContent(path));
        #end

        return output;
    }
}