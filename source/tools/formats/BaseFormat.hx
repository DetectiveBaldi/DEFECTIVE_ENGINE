package tools.formats;

import haxe.Json;

import core.Song.SimpleSong;

class BaseFormat
{
    public static function build(path:String):SimpleSong
    {
        var output:SimpleSong = Json.parse(#if html5 openfl.utils.Assets.getText(path) #else sys.io.File.getContent(path) #end);
        
        return output;
    }
}