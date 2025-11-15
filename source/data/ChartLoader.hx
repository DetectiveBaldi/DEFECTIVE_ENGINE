package data;

import haxe.Json;

import openfl.utils.Assets;

import core.AssetCache;
import core.Paths;

import data.ChartConverters;

using StringTools;

using util.ArrayUtil;

class ChartLoader
{
    public static function readPath(path:String):Chart
    {
        var metadataFilePath:String = '${path}/metadata.json';

        if (Paths.exists(metadataFilePath))
        {
            var chartFilePath:String = Assets.list().first((p:String) -> p.startsWith('${path}/chart'));

            var difficulty:String = chartFilePath.split("-").last().replace(".json", "");
            
            return FunkinConverter.run(chartFilePath, metadataFilePath, difficulty);
        }
        else
        {
            var chartFilePath:String = '${path}/chart.json';

            var chart:Dynamic = Json.parse(Assets.getText(chartFilePath));

            if (Reflect.hasField(chart, "song"))
                return PsychConverter.run(chartFilePath);
            else
                return chart;
        }
    }
}