package core;

#if html5
    import openfl.utils.Assets;

    using StringTools;
#else
    import sys.FileSystem;
#end

class Paths
{
    public static function exists(path:String):Bool
    {
        return #if html5 Assets.exists #else FileSystem.exists #end (path);
    }

    public static function readDirectory(path:String):Array<String>
    {
        #if html5
            var output:Array<String> = new Array<String>();

            for (i in 0 ... Assets.list().length)
            {
                var file:String = Assets.list()[i];

                if (file.startsWith(path))
                {
                    file = file.replace(path.endsWith("/") ? path : '${path}/', "");

                    if (file.contains("/"))
                        file = file.replace(file.substring(file.indexOf("/"), file.length), "");

                    if (!output.contains(file))
                        output.push(file);
                }
            }

            output.sort((a:String, b:String) -> 
            {
                a = a.toLowerCase();

                b = b.toLowerCase();
                
                return (a < b) ? -1 : (a > b) ? 1 : 0;
            });

            return output;
        #else
            return FileSystem.readDirectory(path);
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

    public static function txt(path:String):String
    {
        return '${path}.txt';
    }

    public static function json(path:String):String
    {
        return '${path}.json';
    }

    public static function xml(path:String):String
    {
        return '${path}.xml';
    }
}