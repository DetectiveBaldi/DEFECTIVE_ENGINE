package data.chart;

import haxe.Json;

import openfl.utils.Assets;

// Allows conversion of custom note types to Defective Engine ones through the use of a .json file.
class NoteTypeSwaps
{
    public static function buildFromFile(path:String):Map<String, String>
    {
        var file:Dynamic = Json.parse(Assets.getText(path));

        var fields:Array<String> = Reflect.fields(file);

        var map:Map<String, String> = new Map<String, String>();

        for (i in 0 ... fields.length)
        {
            var field:String = fields[i];

            var value:Dynamic = Reflect.field(file, field);

            if (!(value is String))
                throw 'Invalid note type swap, all values need to be strings ("${path}")!';

            map[field] = value;
        }

        return map;
    }
}