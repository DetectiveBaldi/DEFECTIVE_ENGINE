package editors;

import haxe.Json;

import sys.FileSystem;

import openfl.desktop.Clipboard;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;

import flixel.math.FlxMath;

import flixel.util.FlxStringUtil;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import haxe.ui.ComponentBuilder;

import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Label;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;

import haxe.ui.containers.Box;
import haxe.ui.containers.TabView;

import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

import haxe.ui.focus.FocusManager;

import core.AssetMan;
import core.Paths;

import game.Character;

import game.levels.Level1;

using StringTools;

using util.ArrayUtil;

class CharacterEditorState extends FlxState
{
    public var gameCamera(get, never):FlxCamera;
    
    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var hudCamera:FlxCamera;

    public var character:Character;

    public var framesIndex:Int;

    public var ui:Box;

    override function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

        gameCamera.zoom = 0.75;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        var background:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(32, 32, 64, 64, true, 0xFFE7E6E6, 0xFFD9D5D5));

        add(background);

        character = new Character(null, 0.0, 0.0, Character.findConfig("assets/data/game/Character/BOYFRIEND"), OTHER);

        character.screenCenter();

        add(character);

        framesIndex = character.config.frames.indexOf(character.config.frames.newest((frames:CharacterFramesConfig) -> character.animation.name == frames.name));

        ui = ComponentBuilder.fromFile("assets/data/editors/CharacterEditorState/ui.xml");

        ui.camera = hudCamera;

        add(ui);

        refreshMainTab();

        ui.findComponent("textfield", TextField).onChange = (ev:UIEvent) -> character.config.name = ui.findComponent("textfield", TextField).text;

        ui.findComponent("button", Button).onClick = (ev:MouseEvent) ->
        {
            var path:String = Paths.json('assets/data/game/Character/${character.config.name}');

            sys.io.File.saveContent(path, Json.stringify(character.config));

            InitState.logger.logInfo("[INFO]", 'Character saved to "${path}".');
        }

        ui.findComponent("_button", Button).onClick = (ev:MouseEvent) ->
        {
            if (!FileSystem.exists(Paths.json('assets/data/game/Character/${ui.findComponent("textfield", TextField).text}')))
            {
                InitState.logger.logError("The requested file(s) do not exist!");

                return;
            }

            character.config = Character.findConfig('assets/data/game/Character/${ui.findComponent("textfield", TextField).text}');

            switch (character.config.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    character.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(character.config.png)), Paths.xml(character.config.xml));

                case "texturepackerxml":
                    character.frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(character.config.png)), Paths.xml(character.config.xml));
            }

            character.antialiasing = character.config.antialiasing ?? true;

            character.scale.set(character.config.scale?.x ?? 1.0, character.config.scale?.y ?? 1.0);

            character.updateHitbox();

            character.screenCenter();

            character.flipX = character.config.flipX ?? false;

            character.flipY = character.config.flipY ?? false;

            for (i in 0 ... character.config.frames.length)
            {
                var frames:CharacterFramesConfig = character.config.frames[i];

                frames.frameRate ??= 24.0;

                frames.looped ??= false;

                frames.flipX ??= false;

                frames.flipY ??= false;
    
                if (character.animation.exists(frames.name))
                    throw "editors.CharacterEditorState: Invalid frames name!";
    
                if (frames.indices.length > 0)
                    character.animation.addByIndices(frames.name, frames.prefix, frames.indices, "", frames.frameRate, frames.looped, frames.flipX, frames.flipY);
                else
                    character.animation.addByPrefix(frames.name, frames.prefix, frames.frameRate, frames.looped, frames.flipX, frames.flipY);
            }

            character.danceSteps = character.config.danceSteps;

            character.danceStep = 0;

            character.danceInterval = character.config.danceInterval ?? 1.0;

            character.singDuration = character.config.singDuration ?? 8.0;

            character.skipDance = false;

            character.skipSing = false;

            character.singCount = 0.0;

            character.dance();

            refreshMainTab();

            refreshAssetsTab();

            refreshFramesTab();
        }

        ui.findComponent("checkbox", CheckBox).onChange = (ev:UIEvent) ->
        {
            character.config.antialiasing = ui.findComponent("checkbox", CheckBox).value;

            character.antialiasing = character.config.antialiasing;
        }

        ui.findComponent("number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.config.scale ??= {x: 1.0, y: 1.0};

            character.config.scale.x = ui.findComponent("number-stepper", NumberStepper).value;

            character.scale.x = character.config.scale.x;

            character.updateHitbox();

            character.screenCenter();
        }

        ui.findComponent("_number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.config.scale ??= {x: 1.0, y: 1.0};

            character.config.scale.y = ui.findComponent("_number-stepper", NumberStepper).value;

            character.scale.y = character.config.scale.y;

            character.updateHitbox();

            character.screenCenter();
        }

        ui.findComponent("_checkbox", CheckBox).onChange = (ev:UIEvent) ->
        {
            character.config.flipX = ui.findComponent("_checkbox", CheckBox).value;

            character.flipX = character.config.flipX;
        }

        ui.findComponent("__checkbox", CheckBox).onChange = (ev:UIEvent) ->
        {
            character.config.flipY = ui.findComponent("__checkbox", CheckBox).value;

            character.flipY = character.config.flipY;
        }

        ui.findComponent("_textfield", TextField).onChange = (ev:UIEvent) ->
        {
            if (ui.findComponent("_textfield", TextField).text.length < 1)
                return;
            
            character.config.danceSteps = ui.findComponent("_textfield", TextField).text.split(",");

            character.danceSteps = ui.findComponent("_textfield", TextField).text.split(",");

            character.danceStep = 0;
        };

        ui.findComponent("__number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.config.danceInterval = ui.findComponent("__number-stepper", NumberStepper).value;

            character.danceInterval = character.config.danceInterval;
        }

        ui.findComponent("___number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.config.singDuration = ui.findComponent("___number-stepper", NumberStepper).value;

            character.singDuration = character.config.singDuration;
        }

        refreshAssetsTab();

        ui.findComponent("__button", Button).onClick = (ev:MouseEvent) ->
        {
            if (character.config.format == ui.findComponent("__textfield", TextField).text && character.config.png == ui.findComponent("___textfield", TextField).text && character.config.xml == ui.findComponent("____textfield", TextField).text)
            {
                InitState.logger.logError("The requested format and file(s) are in use!");
                
                return;
            }

            if (!FileSystem.exists(Paths.png(ui.findComponent("___textfield", TextField).text)) || !FileSystem.exists(Paths.xml(ui.findComponent("____textfield", TextField).text)))
            {
                InitState.logger.logError("The requested file(s) do not exist!");

                return;
            }

            character.config.format = ui.findComponent("__textfield", TextField).text;

            character.config.png = ui.findComponent("___textfield", TextField).text;

            character.config.xml = ui.findComponent("____textfield", TextField).text;

            switch (character.config.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    character.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(character.config.png), true), Paths.xml(character.config.xml));

                case "texturepackerxml":
                    character.frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(character.config.png), true), Paths.xml(character.config.xml));
            }

            character.animation.destroyAnimations();

            character.updateHitbox();

            character.screenCenter();

            ui.findComponent("tabview", TabView).selectedPage = ui.findComponent("__box", Box);

            InitState.logger.logWarning("Some frames might be invalidated! Take a look!");
        }

        refreshFramesTab();

        ui.findComponent("___button", Button).onClick = (ev:MouseEvent) -> saveFrames();

        ui.findComponent("____button", Button).onClick = (ev:MouseEvent) -> deleteFrames();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FocusManager.instance.focus == null)
        {
            if (FlxG.keys.justPressed.W)
                framesIndex = FlxMath.wrap(framesIndex - 1, 0, character.config.frames.length - 1);

            if (FlxG.keys.justPressed.S)
                framesIndex = FlxMath.wrap(framesIndex + 1, 0, character.config.frames.length - 1);

            var frames:CharacterFramesConfig = character.config.frames[framesIndex];

            if (FlxG.keys.justPressed.UP)
                addFramesOffset(frames, 0.0, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0);

            if (FlxG.keys.justPressed.LEFT)
                addFramesOffset(frames, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0, 0.0);

            if (FlxG.keys.justPressed.DOWN)
                addFramesOffset(frames, 0.0, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0);

            if (FlxG.keys.justPressed.RIGHT)
                addFramesOffset(frames, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0, 0.0);

            if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || FlxG.keys.justPressed.SPACE)
            {
                character.animation.play(frames.name, true);

                refreshFramesTab();
            }

            if (FlxG.keys.pressed.CONTROL)
            {
                if (FlxG.keys.justPressed.C)
                {
                    Clipboard.generalClipboard.clear();

                    Clipboard.generalClipboard.setData(TEXT_FORMAT, Json.stringify(character.config.frames[framesIndex].offset), false);

                    InitState.logger.logInfo("[INFO]", "Current frames offset copied to clipboard.");
                }

                if (FlxG.keys.justPressed.V)
                {
                    var frames:CharacterFramesConfig = character.config.frames[framesIndex];

                    var offset:{?x:Float, ?y:Float} = Json.parse(Clipboard.generalClipboard.getData(TEXT_FORMAT));

                    setFramesOffset(frames, offset?.x ?? 0.0, offset?.y ?? 0.0);

                    InitState.logger.logInfo("[INFO]", "Copied offset successfully applied to current frames.");
                }
            }

            if (FlxG.keys.justPressed.ENTER)
                FlxG.switchState(() -> new Level1());
        }
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.mouse.visible = false;

        AssetMan.clearCaches();
    }

    public function refreshMainTab():Void
    {
        ui.findComponent("textfield", TextField).text = character.config.name;

        ui.findComponent("checkbox", CheckBox).value = character.config.antialiasing ?? true;

        ui.findComponent("number-stepper", NumberStepper).value = character.config.scale?.x ?? 1.0;

        ui.findComponent("_number-stepper", NumberStepper).value = character.config.scale?.y ?? 1.0;

        ui.findComponent("_checkbox", CheckBox).value = character.config.flipX ?? false;

        ui.findComponent("__checkbox", CheckBox).value = character.config.flipY ?? false;

        ui.findComponent("_textfield", TextField).text = character.config.danceSteps.toString();

        ui.findComponent("_textfield", TextField).text = ui.findComponent("_textfield", TextField).text.substring(1, ui.findComponent("_textfield", TextField).text.length - 1);

        ui.findComponent("__number-stepper", NumberStepper).value = character.config.danceInterval ?? 1.0;

        ui.findComponent("___number-stepper", NumberStepper).value = character.config.singDuration ?? 8.0;
    }

    public function refreshAssetsTab():Void
    {
        ui.findComponent("__textfield", TextField).text = character.config.format;

        ui.findComponent("___textfield", TextField).text = character.config.png;

        ui.findComponent("____textfield", TextField).text = character.config.xml;
    }

    public function refreshFramesTab():Void
    {
        var frames:CharacterFramesConfig = character.config.frames[framesIndex];

        ui.findComponent("_____textfield", TextField).text = frames.name;

        ui.findComponent("______textfield", TextField).text = frames.prefix;

        ui.findComponent("textarea", TextArea).text = frames.indices.toString();

        ui.findComponent("textarea", TextArea).text = ui.findComponent("textarea", TextArea).text.substring(1, ui.findComponent("textarea", TextArea).text.length - 1);

        ui.findComponent("____number-stepper", NumberStepper).value = frames.frameRate ?? 24.0;

        ui.findComponent("___checkbox", CheckBox).value = frames.looped ?? false;

        ui.findComponent("____checkbox", CheckBox).value = frames.flipX ?? false;

        ui.findComponent("_____checkbox", CheckBox).value = frames.flipY ?? false;

        ui.findComponent("_____________label", Label).text = 'Offset: (${frames.offset?.x ?? 0.0}, ${frames.offset?.y ?? 0.0})';
    }

    public function saveFrames():Void
    {
        var frames:Array<FlxFrame> = new Array<FlxFrame>();

        @:privateAccess
            character.animation.findByPrefix(frames, ui.findComponent("______textfield", TextField).text);
        
        if (frames.length <= 0.0)
        {
            InitState.logger.logError("Invalid frames detected!");

            return;
        }

        var indices:Array<Int> = FlxStringUtil.toIntArray(ui.findComponent("textarea", TextArea).text) ?? new Array<Int>();

        var frames:CharacterFramesConfig = character.config.frames.newest((frames:CharacterFramesConfig) -> ui.findComponent("_____textfield", TextField).text == frames.name);

        if (frames == null)
        {
            character.config.frames.push
            ({
                name: ui.findComponent("_____textfield", TextField).text,

                prefix: ui.findComponent("______textfield", TextField).text,

                indices: indices,

                frameRate: ui.findComponent("____number-stepper", NumberStepper).value,

                looped: ui.findComponent("___checkbox", CheckBox).value,

                flipX: ui.findComponent("____checkbox", CheckBox).value,

                flipY: ui.findComponent("_____checkbox", CheckBox).value
            });

            framesIndex = character.config.frames.length - 1;

            frames = character.config.frames[framesIndex];
        }
        else
        {
            frames.prefix = ui.findComponent("______textfield", TextField).text;

            frames.indices = indices;

            frames.frameRate = ui.findComponent("____number-stepper", NumberStepper).value;

            frames.looped = ui.findComponent("___checkbox", CheckBox).value;

            frames.flipX = ui.findComponent("____checkbox", CheckBox).value;

            frames.flipY = ui.findComponent("_____checkbox", CheckBox).value;
        }
        
        if (frames.indices.length > 0.0)
            character.animation.addByIndices(frames.name, frames.prefix, frames.indices, "", frames.frameRate, frames.looped, frames.flipX, frames.flipY);
        else
            character.animation.addByPrefix(frames.name, frames.prefix, frames.frameRate, frames.looped, frames.flipX, frames.flipY);

        character.animation.play(frames.name, true);

        refreshFramesTab();

        InitState.logger.logInfo("[INFO]", 'Saved "${frames.name}"!');
    }

    public function deleteFrames():Void
    {
        if (character.config.frames.length == 1.0)
        {
            InitState.logger.logError("You must have at least one frames!");

            return;
        }

        var frames:CharacterFramesConfig = character.config.frames[framesIndex];

        character.config.frames.remove(frames);

        if (character.animation.exists(frames.name))
            character.animation.remove(frames.name);

        framesIndex = 0;

        frames = character.config.frames[framesIndex];

        character.animation.play(frames.name, true);

        refreshFramesTab();

        InitState.logger.logInfo("[INFO]", 'Deleted "${frames.name}"!');
    }

    public function setFramesOffset(frames:CharacterFramesConfig, x:Float = 0.0, y:Float = 0.0):Void
    {
        frames.offset ??= {x: 0.0, y: 0.0};

        frames.offset.x = x;

        frames.offset.y = y;

        ui.findComponent("_____________label", Label).text = 'Offset: (${frames.offset.x ?? 0.0}, ${frames.offset.y ?? 0.0})';
    }

    public function addFramesOffset(frames:CharacterFramesConfig, x:Float = 0.0, y:Float = 0.0):Void
    {
        frames.offset ??= {x: 0.0, y: 0.0};

        setFramesOffset(frames, (frames.offset.x ?? 0.0) + x, (frames.offset.y ?? 0.0) + y);
    }
}