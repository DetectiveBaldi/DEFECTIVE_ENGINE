package util;

class ArrayUtil
{
    public static function pushMany<T>(arr:Array<T>, ...v:T):Void
    {
        for (i in 0 ... v.length)
            arr.push(v[i]);
    }

    public static function first<T>(arr:Array<T>, func:(T)->Bool = null):T
    {
        var result:T = null;

        if (arr.length == 0.0)
            return result;

        if (func == null)
            result = arr[0];
        else
        {
            for (i in 0 ... arr.length)
            {
                var value:T = arr[i];

                if (func(value))
                {
                    result = value;

                    break;
                }
            }
        }

        return result;
    }

    public static function last<T>(arr:Array<T>, func:(T)->Bool = null):T
    {
        var result:T = null;

        if (arr.length == 0.0)
            return result;

        if (func == null)
            result = arr[arr.length - 1];
        else
        {
            var i:Int = arr.length - 1;

            while (i >= 0.0)
            {
                var value:T = arr[i];

                if (func(value))
                {
                    result = value;

                    break;
                }

                i--;
            }
        }

        return result;
    }
}