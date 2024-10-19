package editors;

import haxe.Json;

import openfl.desktop.Clipboard;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;

import flixel.math.FlxMath;

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

import haxe.ui.data.ArrayDataSource;

import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

import haxe.ui.focus.FocusManager;

import core.AssetMan;
import core.Paths;

import game.Character;
import game.GameState;

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

        character = new Character(null, 0.0, 0.0, "assets/data/game/characters/BOYFRIEND", ARTIFICIAL);

        character.screenCenter();

        add(character);

        framesIndex = character.data.frames.indexOf(character.data.frames.getFirst((frames:CharacterFramesData) -> character.animation.name == frames.name));

        ui = ComponentBuilder.fromFile("assets/data/editors/character.xml");

        ui.camera = hudCamera;

        add(ui);

        refreshMainTab();

        ui.findComponent("textfield", TextField).onChange = (ev:UIEvent) -> character.data.name = ui.findComponent("textfield", TextField).text;

        #if html5
            ui.findComponent("button", Button).disabled = true;
        #else
            ui.findComponent("button", Button).onClick = (ev:MouseEvent) ->
            {
                sys.io.File.saveContent(Paths.json('assets/data/game/characters/${character.data.name}'), Json.stringify(character.data));

                OpeningState.logger.logInfo('Character saved to "${Paths.json('assets/data/game/characters/${character.data.name}')}".');
            }
        #end

        ui.findComponent("_button", Button).onClick = (ev:MouseEvent) ->
        {
            if (!Paths.exists(Paths.json('assets/data/game/characters/${ui.findComponent("textfield", TextField).text}')))
            {
                OpeningState.logger.logError("The requested file(s) do not exist!");

                return;
            }

            character.data = Json.parse(AssetMan.text(Paths.json('assets/data/game/characters/${ui.findComponent("textfield", TextField).text}')));

            switch (character.data.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    character.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));

                case "texturepackerxml":
                    character.frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));
            }

            character.antialiasing = character.data.antialiasing ?? true;

            character.scale.set(character.data.scale?.x ?? 1.0, character.data.scale?.y ?? 1.0);

            character.updateHitbox();

            character.screenCenter();

            character.flipX = character.data.flipX ?? false;

            character.flipY = character.data.flipY ?? false;

            for (i in 0 ... character.data.frames.length)
            {
                var frames:CharacterFramesData = character.data.frames[i];
    
                if (character.animation.exists(frames.name))
                    throw "game.Character: Invalid frames name!";
    
                if (frames.indices.length > 0)
                {
                    character.animation.addByIndices
                    (
                        frames.name,
    
                        frames.prefix,
    
                        frames.indices,
    
                        "",
    
                        frames.frameRate ?? 24.0,
    
                        frames.looped ?? false,
    
                        frames.flipX ?? false,
    
                        frames.flipY ?? false
                    );
                }
                else
                {
                    character.animation.addByPrefix
                    (
                        frames.name,
    
                        frames.prefix,
    
                        frames.frameRate ?? 24.0,
    
                        frames.looped ?? false,
    
                        frames.flipX ?? false,
    
                        frames.flipY ?? false
                    );
                }
            }

            character.danceSteps = character.data.danceSteps;

            character.danceStep = 0;

            character.danceInterval = character.data.danceInterval ?? 1.0;

            character.singDuration = character.data.singDuration ?? 8.0;

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
            character.data.antialiasing = ui.findComponent("checkbox", CheckBox).value;

            character.antialiasing = character.data.antialiasing;
        }

        ui.findComponent("number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.data.scale ??= {x: 1.0, y: 1.0};

            character.data.scale.x = ui.findComponent("number-stepper", NumberStepper).value;

            character.scale.x = character.data.scale.x;

            character.updateHitbox();

            character.screenCenter();
        }

        ui.findComponent("_number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.data.scale ??= {x: 1.0, y: 1.0};

            character.data.scale.y = ui.findComponent("_number-stepper", NumberStepper).value;

            character.scale.y = character.data.scale.y;

            character.updateHitbox();

            character.screenCenter();
        }

        ui.findComponent("_checkbox", CheckBox).onChange = (ev:UIEvent) ->
        {
            character.data.flipX = ui.findComponent("_checkbox", CheckBox).value;

            character.flipX = character.data.flipX;
        }

        ui.findComponent("__checkbox", CheckBox).onChange = (ev:UIEvent) ->
        {
            character.data.flipY = ui.findComponent("__checkbox", CheckBox).value;

            character.flipY = character.data.flipY;
        }

        ui.findComponent("_textfield", TextField).onChange = (ev:UIEvent) ->
        {
            if (ui.findComponent("_textfield", TextField).text.length < 1)
                return;
            
            character.data.danceSteps = ui.findComponent("_textfield", TextField).text.split(",");

            character.danceSteps = ui.findComponent("_textfield", TextField).text.split(",");

            character.danceStep = 0;
        };

        ui.findComponent("__number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.data.danceInterval = ui.findComponent("__number-stepper", NumberStepper).value;

            character.danceInterval = character.data.danceInterval;
        }

        ui.findComponent("___number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.data.singDuration = ui.findComponent("___number-stepper", NumberStepper).value;

            character.singDuration = character.data.singDuration;
        }

        refreshAssetsTab();

        ui.findComponent("__button", Button).onClick = (ev:MouseEvent) ->
        {
            if (character.data.format == ui.findComponent("__textfield", TextField).text && character.data.png == ui.findComponent("___textfield", TextField).text && character.data.xml == ui.findComponent("____textfield", TextField).text)
            {
                OpeningState.logger.logError("The requested format and file(s) are in use!");
                
                return;
            }

            if (!Paths.exists(Paths.png(ui.findComponent("___textfield", TextField).text)) || !Paths.exists(Paths.xml(ui.findComponent("____textfield", TextField).text)))
            {
                OpeningState.logger.logError("The requested file(s) do not exist!");

                return;
            }

            character.data.format = ui.findComponent("__textfield", TextField).text;

            character.data.png = ui.findComponent("___textfield", TextField).text;

            character.data.xml = ui.findComponent("____textfield", TextField).text;

            switch (character.data.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    character.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));

                case "texturepackerxml":
                    character.frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));
            }

            character.animation.destroyAnimations();

            character.updateHitbox();

            character.screenCenter();

            ui.findComponent("tabview", TabView).selectedPage = ui.findComponent("__box", Box);

            OpeningState.logger.logWarning("Some frames might be invalidated! Take a look!");
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
                framesIndex = FlxMath.wrap(framesIndex - 1, 0, character.data.frames.length - 1);

            if (FlxG.keys.justPressed.S)
                framesIndex = FlxMath.wrap(framesIndex + 1, 0, character.data.frames.length - 1);

            var frames:CharacterFramesData = character.data.frames[framesIndex];

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

                    Clipboard.generalClipboard.setData(TEXT_FORMAT, Json.stringify(character.data.frames[framesIndex].offset), false);

                    OpeningState.logger.logInfo("Current frames offset copied to clipboard.");
                }

                if (FlxG.keys.justPressed.V)
                {
                    var frames:CharacterFramesData = character.data.frames[framesIndex];

                    var offset:{?x:Null<Float>, ?y:Null<Float>} = Json.parse(Clipboard.generalClipboard.getData(TEXT_FORMAT));

                    setFramesOffset(frames, offset?.x ?? 0.0, offset?.y ?? 0.0);

                    OpeningState.logger.logInfo("Copied offset successfully applied to current frames.");
                }
            }

            if (FlxG.keys.justPressed.ENTER)
                FlxG.switchState(() -> new GameState());
        }
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.mouse.visible = false;

        AssetMan.clearCache();
    }

    public function refreshMainTab():Void
    {
        ui.findComponent("textfield", TextField).text = character.data.name;

        ui.findComponent("checkbox", CheckBox).value = character.data.antialiasing ?? true;

        ui.findComponent("number-stepper", NumberStepper).value = character.data.scale?.x ?? 1.0;

        ui.findComponent("_number-stepper", NumberStepper).value = character.data.scale?.y ?? 1.0;

        ui.findComponent("_checkbox", CheckBox).value = character.data.flipX ?? false;

        ui.findComponent("__checkbox", CheckBox).value = character.data.flipY ?? false;

        ui.findComponent("_textfield", TextField).text = character.data.danceSteps.toString();
        
        #if !html5
           ui.findComponent("_textfield", TextField).text = ui.findComponent("_textfield", TextField).text.substring(1, ui.findComponent("_textfield", TextField).text.length - 1);
        #end

        ui.findComponent("__number-stepper", NumberStepper).value = character.data.danceInterval ?? 1.0;

        ui.findComponent("___number-stepper", NumberStepper).value = character.data.singDuration ?? 8.0;
    }

    public function refreshAssetsTab():Void
    {
        ui.findComponent("__textfield", TextField).text = character.data.format;

        ui.findComponent("___textfield", TextField).text = character.data.png;

        ui.findComponent("____textfield", TextField).text = character.data.xml;
    }

    public function refreshFramesTab():Void
    {
        var frames:CharacterFramesData = character.data.frames[framesIndex];

        ui.findComponent("_____textfield", TextField).text = frames.name;

        ui.findComponent("______textfield", TextField).text = frames.prefix;

        ui.findComponent("textarea", TextArea).text = frames.indices.toString();

        #if !html5
            ui.findComponent("textarea", TextArea).text = ui.findComponent("textarea", TextArea).text.substring(1, ui.findComponent("textarea", TextArea).text.length - 1);
        #end

        ui.findComponent("____number-stepper", NumberStepper).value = frames.frameRate ?? 24.0;

        ui.findComponent("___checkbox", CheckBox).value = frames.looped ?? false;

        ui.findComponent("____checkbox", CheckBox).value = frames.flipX ?? false;

        ui.findComponent("_____checkbox", CheckBox).value = frames.flipY ?? false;

        ui.findComponent("____________label", Label).text = 'Offset: (${frames.offset?.x ?? 0.0}, ${frames.offset?.y ?? 0.0})';
    }

    public function saveFrames():Void
    {
        var frames:Array<FlxFrame> = new Array<FlxFrame>();

        @:privateAccess
            character.animation.findByPrefix(frames, ui.findComponent("______textfield", TextField).text);
        
        if (frames.length <= 0.0)
        {
            OpeningState.logger.logError("Invalid frames detected!");

            return;
        }

        var indices:Array<String> = ui.findComponent("textarea", TextArea).text.split(",");

        var _indices:Array<Int> = new Array<Int>();

        if (ui.findComponent("textarea", TextArea).text.length > 0)
        {
            for (i in 0 ... indices.length)
                _indices.push(Std.parseInt(indices[i]));
        }

        var frames:CharacterFramesData = character.data.frames.getFirst((frames:CharacterFramesData) -> ui.findComponent("_____textfield", TextField).text == frames.name);

        if (frames == null)
        {
            character.data.frames.push
            ({
                name: ui.findComponent("_____textfield", TextField).text,

                prefix: ui.findComponent("______textfield", TextField).text,

                indices: _indices,

                frameRate: ui.findComponent("____number-stepper", NumberStepper).value,

                looped: ui.findComponent("___checkbox", CheckBox).value,

                flipX: ui.findComponent("____checkbox", CheckBox).value,

                flipY: ui.findComponent("_____checkbox", CheckBox).value
            });

            framesIndex = character.data.frames.length - 1;

            frames = character.data.frames[framesIndex];
        }
        else
        {
            frames.prefix = ui.findComponent("______textfield", TextField).text;

            frames.indices = _indices;

            frames.frameRate = ui.findComponent("____number-stepper", NumberStepper).value;

            frames.looped = ui.findComponent("___checkbox", CheckBox).value;

            frames.flipX = ui.findComponent("____checkbox", CheckBox).value;

            frames.flipY = ui.findComponent("_____checkbox", CheckBox).value;
        }
        
        if (_indices.length > 0.0)
            character.animation.addByIndices(frames.name, frames.prefix, frames.indices, "", frames.frameRate, frames.looped, frames.flipX, frames.flipY);
        else
            character.animation.addByPrefix(frames.name, frames.prefix, frames.frameRate, frames.looped, frames.flipX, frames.flipY);

        character.animation.play(frames.name, true);

        refreshFramesTab();

        OpeningState.logger.logInfo('Saved "${frames.name}"!');
    }

    public function deleteFrames():Void
    {
        if (character.data.frames.length == 1.0)
        {
            OpeningState.logger.logError("You must have at least one frames!");

            return;
        }

        var frames:CharacterFramesData = character.data.frames[framesIndex];

        character.data.frames.remove(frames);

        if (character.animation.exists(frames.name))
            character.animation.remove(frames.name);

        framesIndex = 0;

        frames = character.data.frames[framesIndex];

        character.animation.play(frames.name, true);

        refreshFramesTab();

        OpeningState.logger.logInfo('Deleted "${frames.name}"!');
    }

    public function setFramesOffset(frames:CharacterFramesData, x:Float = 0.0, y:Float = 0.0):Void
    {
        frames.offset ??= {x: 0.0, y: 0.0};

        frames.offset.x = x;

        frames.offset.y = y;

        ui.findComponent("____________label", Label).text = 'Offset: (${frames.offset.x ?? 0.0}, ${frames.offset.y ?? 0.0})';
    }

    public function addFramesOffset(frames:CharacterFramesData, x:Float = 0.0, y:Float = 0.0):Void
    {
        frames.offset ??= {x: 0.0, y: 0.0};

        setFramesOffset(frames, frames.offset.x ?? 0.0 + x, frames.offset.y ?? 0.0 + y);
    }
}