package data;

import haxe.Json;

import openfl.utils.Assets;

import core.AssetCache;
import core.Paths;

import data.ChartConverters;

import util.MacroUtil;

using StringTools;

// Difficulties aren't fully supported. They are available for Funkin' charts, though.
class ChartBuilder
{
    public static function buildFromFolder(path:String):Chart
    {
        var metadataFilePath:String = '${path}/metadata.json';

        if (Paths.exists(metadataFilePath))
        {
            var chartFilePath:String = '${path}/chart.json';
            
            return FunkinConverter.buildFromFiles(chartFilePath, metadataFilePath,
                MacroUtil.sanitizeDefine(MacroUtil.getDefine("DIFFICULTY")).toLowerCase());
        }
        else
        {
            var chartFilePath:String = '${path}/chart.json${MacroUtil.sanitizeDefine(MacroUtil.getDefine("DIFFICULTY")).toLowerCase()}';

            var data:Dynamic = Json.parse(Assets.getText(chartFilePath));

            if (Reflect.hasField(data, "song"))
            {
                if (Reflect.hasField(data.song, "song"))
                    return LegacyPsychConverter.buildFromFiles(chartFilePath);
                else
                    return PsychConverter.buildFromFiles(chartFilePath);
            }
            else
                return Chart.build(data);
        }
    }
}