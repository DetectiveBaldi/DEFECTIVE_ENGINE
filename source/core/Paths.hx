package core;

import openfl.utils.Assets;

class Paths
{
    public static function png(path:String):String
    {
        return '${path}.png';
    }

    public static function ogg(path:String):String
    {
        return '${path}.ogg';
    }

    public static function json(path:String):String
    {
        return '${path}.json';
    }

    public static function txt(path:String):String
    {
        return '${path}.txt';
    }

    public static function xml(path:String):String
    {
        return '${path}.xml';
    }

    public static function ttf(path:String):String
    {
        return '${path}.ttf';
    }

    public static function data(path:String):String
    {
        return 'assets/data/${path}';
    }

    public static function font(path:String):String
    {
        return 'assets/fonts/${path}';
    }

    public static function image(path:String):String
    {
        return 'assets/images/${path}';
    }

    public static function music(path:String):String
    {
        return 'assets/music/${path}';
    }

    public static function sound(path:String):String
    {
        return 'assets/sounds/${path}';
    }

    public static function exists(path:String):Bool
    {
        return Assets.exists(path);
    }
}