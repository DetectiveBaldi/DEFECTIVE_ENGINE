package core;

class Paths
{
    public static function exists(path:String):Bool
    {
        return #if html5 openfl.utils.Assets.exists #else sys.FileSystem.exists #end (path);
    }

    public static function readDirectory(path:String):Array<String>
    {
        #if html5
            var output:Array<String> = new Array<String>();

            for (i in 0 ... openfl.utils.Assets.list().length)
            {
                var file:String = openfl.utils.Assets.list()[i];

                if (StringTools.startsWith(file, path))
                {
                    file = StringTools.replace(file, StringTools.endsWith(path, "/") ? path : '${path}/', "");

                    if (StringTools.contains(file, "/"))
                        file = StringTools.replace(file, file.substring(file.indexOf("/"), file.length), "");

                    if (!output.contains(file))
                        output.push(file);
                }
            }

            haxe.ds.ArraySort.sort(output, (a:String, b:String) -> 
            {
                a = a.toLowerCase();

                b = b.toLowerCase();
                
                return a > b ? 1 : a < b ? -1 : 0;
            });

            return output;
        #else
            return sys.FileSystem.readDirectory(path);
        #end
    }

    public static function png(path:String):String
    {
        return '${path}.png';
    }

    public static function mp3(path:String):String
    {
        return '${path}.mp3';
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
}