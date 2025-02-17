package editors;

import haxe.Json;

import sys.FileSystem;
import sys.io.File;

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

import core.Assets;
import core.Paths;

import data.AnimData;
import data.CharacterData;

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

    public var animationIndex:Int;

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

        character = new Character(null, 0.0, 0.0, CharacterData.get("assets/data/game/Character/BOYFRIEND"));

        character.screenCenter();

        add(character);

        animationIndex = character.config.animations.indexOf(character.config.animations.oldest((animation:AnimData) -> character.animation.name == animation.name));

        ui = ComponentBuilder.fromFile("assets/data/editors/CharacterEditorState/ui.xml");

        ui.camera = hudCamera;

        add(ui);

        refreshMainTab();

        ui.findComponent("textfield", TextField).onChange = (ev:UIEvent) -> character.config.name = ui.findComponent("textfield", TextField).text;

        ui.findComponent("button", Button).onClick = (ev:MouseEvent) ->
        {
            var path:String = Paths.json('assets/data/game/Character/${character.config.name}');

            File.saveContent(path, Json.stringify(character.config));

            InitState.log.info("[INFO]", 'Character saved to "${path}".');
        }

        ui.findComponent("_button", Button).onClick = (ev:MouseEvent) ->
        {
            if (!FileSystem.exists(Paths.json('assets/data/game/Character/${ui.findComponent("textfield", TextField).text}')))
            {
                InitState.log.error("The requested file(s) do not exist!");

                return;
            }

            character.config = CharacterData.get('assets/data/game/Character/${ui.findComponent("textfield", TextField).text}');

            character.screenCenter();

            character.dance();

            refreshMainTab();

            refreshAssetsTab();

            refreshAnimationsTab();
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
                InitState.log.error("The requested format and file(s) are in use!");
                
                return;
            }

            if (!FileSystem.exists(Paths.png(ui.findComponent("___textfield", TextField).text)) || !FileSystem.exists(Paths.xml(ui.findComponent("____textfield", TextField).text)))
            {
                InitState.log.error("The requested file(s) do not exist!");

                return;
            }

            character.config.format = ui.findComponent("__textfield", TextField).text;

            character.config.png = ui.findComponent("___textfield", TextField).text;

            character.config.xml = ui.findComponent("____textfield", TextField).text;

            switch (character.config.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    character.frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png(character.config.png), true), Paths.xml(character.config.xml));

                case "texturepackerxml":
                    character.frames = FlxAtlasFrames.fromTexturePackerXml(Assets.getGraphic(Paths.png(character.config.png), true), Paths.xml(character.config.xml));
            }

            character.updateHitbox();

            character.screenCenter();

            ui.findComponent("tabview", TabView).selectedPage = ui.findComponent("__box", Box);

            InitState.log.warning("Some animations might be invalidated! Take a look!");
        }

        refreshAnimationsTab();

        ui.findComponent("___button", Button).onClick = (ev:MouseEvent) -> saveAnimation();

        ui.findComponent("____button", Button).onClick = (ev:MouseEvent) -> deleteAnimation();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FocusManager.instance.focus == null)
        {
            if (FlxG.keys.justPressed.W)
                animationIndex = FlxMath.wrap(animationIndex - 1, 0, character.config.animations.length - 1);

            if (FlxG.keys.justPressed.S)
                animationIndex = FlxMath.wrap(animationIndex + 1, 0, character.config.animations.length - 1);

            var animation:AnimData = character.config.animations[animationIndex];

            if (FlxG.keys.justPressed.UP)
                addAnimationOffset(animation, 0.0, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0);

            if (FlxG.keys.justPressed.LEFT)
                addAnimationOffset(animation, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0, 0.0);

            if (FlxG.keys.justPressed.DOWN)
                addAnimationOffset(animation, 0.0, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0);

            if (FlxG.keys.justPressed.RIGHT)
                addAnimationOffset(animation, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0, 0.0);

            if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || FlxG.keys.justPressed.SPACE)
            {
                character.animation.play(animation.name, true);

                refreshAnimationsTab();
            }

            if (FlxG.keys.pressed.CONTROL)
            {
                if (FlxG.keys.justPressed.C)
                {
                    Clipboard.generalClipboard.clear();

                    Clipboard.generalClipboard.setData(TEXT_FORMAT, Json.stringify(character.config.animations[animationIndex].offset), false);

                    InitState.log.info("[INFO]", "Current animation offset copied to clipboard.");
                }

                if (FlxG.keys.justPressed.V)
                {
                    var animation:AnimData = character.config.animations[animationIndex];

                    var offset:{?x:Float, ?y:Float} = Json.parse(Clipboard.generalClipboard.getData(TEXT_FORMAT));

                    setAnimationOffset(animation, offset?.x ?? 0.0, offset?.y ?? 0.0);

                    InitState.log.info("[INFO]", "Copied offset successfully applied to current animation.");
                }
            }

            if (FlxG.keys.justPressed.ESCAPE)
                FlxG.switchState(() -> new Level1());
        }
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.mouse.visible = false;
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

    public function refreshAnimationsTab():Void
    {
        var animation:AnimData = character.config.animations[animationIndex];

        ui.findComponent("_____textfield", TextField).text = animation.name;

        ui.findComponent("______textfield", TextField).text = animation.prefix;

        ui.findComponent("textarea", TextArea).text = animation.indices.toString();

        ui.findComponent("textarea", TextArea).text = ui.findComponent("textarea", TextArea).text.substring(1, ui.findComponent("textarea", TextArea).text.length - 1);

        ui.findComponent("____number-stepper", NumberStepper).value = animation.frameRate ?? 24.0;

        ui.findComponent("___checkbox", CheckBox).value = animation.looped ?? false;

        ui.findComponent("____checkbox", CheckBox).value = animation.flipX ?? false;

        ui.findComponent("_____checkbox", CheckBox).value = animation.flipY ?? false;

        ui.findComponent("_____________label", Label).text = 'Offset: (${animation.offset?.x ?? 0.0}, ${animation.offset?.y ?? 0.0})';
    }

    public function saveAnimation():Void
    {
        var frames:Array<FlxFrame> = new Array<FlxFrame>();

        @:privateAccess
        character.animation.findByPrefix(frames, ui.findComponent("______textfield", TextField).text);
        
        if (frames.length <= 0.0)
        {
            InitState.log.error("Invalid frames detected!");

            return;
        }

        var indices:Array<Int> = FlxStringUtil.toIntArray(ui.findComponent("textarea", TextArea).text) ?? new Array<Int>();

        var animation:AnimData = character.config.animations.oldest((animation:AnimData) -> ui.findComponent("_____textfield", TextField).text == animation.name);

        if (animation == null)
        {
            character.config.animations.push
            ({
                name: ui.findComponent("_____textfield", TextField).text,

                prefix: ui.findComponent("______textfield", TextField).text,

                indices: indices,

                frameRate: ui.findComponent("____number-stepper", NumberStepper).value,

                looped: ui.findComponent("___checkbox", CheckBox).value,

                flipX: ui.findComponent("____checkbox", CheckBox).value,

                flipY: ui.findComponent("_____checkbox", CheckBox).value
            });

            animationIndex = character.config.animations.length - 1;

            animation = character.config.animations[animationIndex];
        }
        else
        {
            animation.prefix = ui.findComponent("______textfield", TextField).text;

            animation.indices = indices;

            animation.frameRate = ui.findComponent("____number-stepper", NumberStepper).value;

            animation.looped = ui.findComponent("___checkbox", CheckBox).value;

            animation.flipX = ui.findComponent("____checkbox", CheckBox).value;

            animation.flipY = ui.findComponent("_____checkbox", CheckBox).value;
        }
        
        if (animation.indices.length > 0.0)
            character.animation.addByIndices(animation.name, animation.prefix, animation.indices, "", animation.frameRate, animation.looped, animation.flipX, animation.flipY);
        else
            character.animation.addByPrefix(animation.name, animation.prefix, animation.frameRate, animation.looped, animation.flipX, animation.flipY);

        character.animation.play(animation.name, true);

        refreshAnimationsTab();

        InitState.log.info("[INFO]", 'Saved "${animation.name}"!');
    }

    public function deleteAnimation():Void
    {
        if (character.config.animations.length == 1.0)
        {
            InitState.log.error("You must have at least one animation!");

            return;
        }

        var animation:AnimData = character.config.animations[animationIndex];

        character.config.animations.remove(animation);

        if (character.animation.exists(animation.name))
            character.animation.remove(animation.name);

        animationIndex = 0;

        animation = character.config.animations[animationIndex];

        character.animation.play(animation.name, true);

        refreshAnimationsTab();

        InitState.log.info("[INFO]", 'Deleted "${animation.name}"!');
    }

    public function setAnimationOffset(animation:AnimData, x:Float = 0.0, y:Float = 0.0):Void
    {
        animation.offset ??= {x: 0.0, y: 0.0};

        animation.offset.x = x;

        animation.offset.y = y;

        ui.findComponent("_____________label", Label).text = 'Offset: (${animation.offset.x ?? 0.0}, ${animation.offset.y ?? 0.0})';
    }

    public function addAnimationOffset(animation:AnimData, x:Float = 0.0, y:Float = 0.0):Void
    {
        animation.offset ??= {x: 0.0, y: 0.0};

        setAnimationOffset(animation, (animation.offset.x ?? 0.0) + x, (animation.offset.y ?? 0.0) + y);
    }
}