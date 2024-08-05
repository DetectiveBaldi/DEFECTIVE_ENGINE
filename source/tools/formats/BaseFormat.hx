package tools.formats;

import haxe.Json;

import core.Song.SimpleSong;

class BaseFormat
{
    public static function build(chartPath:String):SimpleSong
    {
        var output:SimpleSong = Json.parse(#if html5 openfl.utils.Assets.getText(chartPath) #else sys.io.File.getContent(chartPath) #end);
        
        return output;
    }
}