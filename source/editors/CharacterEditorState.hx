package editors;

import haxe.Json;

import openfl.desktop.Clipboard;

import openfl.net.FileReference;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.animation.FlxAnimation;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.typeLimit.NextState;

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

import core.AssetCache;
import core.Paths;

import data.AnimationData;
import data.AxisData;
import data.CharacterData;

import game.Character;
import game.HealthIcon;
import game.PlayState;

import ui.ProgressBar;

using StringTools;

using util.ArrayUtil;
using util.MathUtil;

class CharacterEditorState extends FlxState
{
    public var nextState:NextState;

    public var configName:String;

    public var gameCamera(get, never):FlxCamera;
    
    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var hudCamera:FlxCamera;

    public var ghost:FlxSprite;

    public var character:Character;

    public var animationIndex:Int;

    public var cameraPointPointer:FlxSprite;

    public var progBar:ProgressBar;

    public var healthIcon:HealthIcon;

    public var ui:Box;

    public function new(nextState:NextState, configName:String = "bf"):Void
    {
        super();

        this.nextState = nextState;

        this.configName = configName;
    }

    override function create():Void
    {
        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        super.create();

        FlxG.mouse.visible = true;

        gameCamera.zoom = 0.75;

        var background:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(32, 32, 64, 64, true, 0xFFE7E6E6, 0xFFD9D5D5));

        add(background);

        ghost = new FlxSprite();

        ghost.alpha = 0.65;

        add(ghost);

        character = new Character(null, 0.0, 0.0, Character.getConfig(configName));

        character.screenCenter();

        add(character);

        updateGhostFrame();

        updateGhostScale();

        updateGhostFlip();

        animationIndex = character.config.animations.indexOf(character.config.animations.first((animation:AnimationData) -> character.animation.name == animation.name));

        cameraPointPointer = new FlxSprite(0.0, 0.0, AssetCache.getGraphic("editors/CharacterEditorState/cursor-cross"));

        cameraPointPointer.scale.set(3.0, 3.0);

        cameraPointPointer.updateHitbox();

        add(cameraPointPointer);

        resetCameraPoint();

        ui = ComponentBuilder.fromFile("assets/data/editors/CharacterEditorState/ui.xml");

        ui.camera = hudCamera;

        add(ui);

        progBar = new ProgressBar(0.0, 0.0, 600, 25, 5, RIGHT_TO_LEFT);

        progBar.camera = hudCamera;

        progBar.setPosition(50.0, FlxG.height - progBar.height - 50.0);

        add(progBar);

        progBar.emptiedSide.color = progBar.filledSide.color = FlxColor.fromString(character.config.healthColor);

        healthIcon = new HealthIcon(character.config.healthIcon);

        healthIcon.camera = hudCamera;

        healthIcon.setPosition(15.0, progBar.getMidpoint().y - healthIcon.height * 0.5);

        add(healthIcon);

        updateMainTab();

        ui.findComponent("textfield", TextField).onChange = (ev:UIEvent) -> character.config.name = ui.findComponent("textfield", TextField).text;

        ui.findComponent("button", Button).onClick = (ev:MouseEvent) ->
        {
            var path:String = "";

            #if sys
            path += Sys.getCwd().replace("/", "\\");

            path += Paths.data(Paths.json('game\\Character\\${character.config.name}')).replace("/", "\\");
            #end

            var fileRef:FileReference = new FileReference();

            fileRef.save(Json.stringify(character.config), path);
        }

        ui.findComponent("_button", Button).onClick = (ev:MouseEvent) ->
        {
            character.loadConfig(Character.getConfig('${ui.findComponent("textfield", TextField).text}'));

            character.screenCenter();

            character.dance();

            resetCameraPoint();

            updateGhostFrame();

            updateGhostScale();

            updateGhostFlip();

            progBar.emptiedSide.color = progBar.filledSide.color = FlxColor.fromString(character.config.healthColor);

            healthIcon.updateGraphic(character.config.healthIcon);

            animationIndex = 0;

            updateMainTab();

            updateAssetsTab();

            updateAnimationsTab();
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

            updateGhostScale();

            updateOffsetLabel();
        }

        ui.findComponent("_number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.config.scale ??= {x: 1.0, y: 1.0};

            character.config.scale.y = ui.findComponent("_number-stepper", NumberStepper).value;

            character.scale.y = character.config.scale.y;

            character.updateHitbox();

            character.screenCenter();

            updateGhostScale();

            updateOffsetLabel();
        }

        ui.findComponent("_checkbox", CheckBox).onChange = (ev:UIEvent) ->
        {
            character.config.flipX = ui.findComponent("_checkbox", CheckBox).value;

            character.flipX = character.config.flipX;

            updateGhostFlip();
        }

        ui.findComponent("__checkbox", CheckBox).onChange = (ev:UIEvent) ->
        {
            character.config.flipY = ui.findComponent("__checkbox", CheckBox).value;

            character.flipY = character.config.flipY;

            updateGhostFlip();
        }

        ui.findComponent("_textfield", TextField).onChange = (ev:UIEvent) ->
        {
            if (ui.findComponent("_textfield", TextField).text.length < 1)
                return;
            
            character.config.danceSteps = ui.findComponent("_textfield", TextField).text.split(",");

            character.danceSteps = ui.findComponent("_textfield", TextField).text.split(",");

            character.danceIndex = 0;
        };

        ui.findComponent("__number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.config.danceEvery = ui.findComponent("__number-stepper", NumberStepper).value;

            character.danceEvery = character.config.danceEvery;
        }

        ui.findComponent("___number-stepper", NumberStepper).onChange = (ev:UIEvent) ->
        {
            character.config.singDuration = ui.findComponent("___number-stepper", NumberStepper).value;

            character.singDuration = character.config.singDuration;
        }

        updateAssetsTab();

        ui.findComponent("__button", Button).onClick = (ev:MouseEvent) ->
        {
            character.config.format = ui.findComponent("__textfield", TextField).text;

            character.config.image = ui.findComponent("___textfield", TextField).text;

            var pngPath:String = 'game/Character/${character.config.image}';

            var xmlPath:String = Paths.image(Paths.xml('game/Character/${character.config.image}'));

            switch (character.config.format ?? "".toLowerCase():String)
            {
                case "sparrow": character.frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic(pngPath), xmlPath);

                case "texturepackerxml": character.frames = FlxAtlasFrames.fromTexturePackerXml(AssetCache.getGraphic(pngPath), xmlPath);
            }

            character.updateHitbox();

            character.screenCenter();

            updateGhostFrame();

            updateGhostScale();
        }

        ui.findComponent("___button", Button).onClick = (ev:MouseEvent) ->
        {
            character.config.healthIcon = ui.findComponent("____textfield", TextField).text;

            healthIcon.updateGraphic(character.config.healthIcon);

            character.config.healthColor = ui.findComponent("_____textfield", TextField).text;

            progBar.emptiedSide.color = progBar.filledSide.color = FlxColor.fromString(character.config.healthColor);
        }

        ui.findComponent("____button").onClick = (ev:MouseEvent) ->
        {
            character.config.deadCharacter = ui.findComponent("______textfield", TextField).text;

            character.deadCharacter = character.config.deadCharacter;
        }

        updateAnimationsTab();

        ui.findComponent("_____button", Button).onClick = (ev:MouseEvent) -> saveAnimation();

        ui.findComponent("______button", Button).onClick = (ev:MouseEvent) -> deleteAnimation();
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

            if (FlxG.keys.justPressed.UP)
                addAnimationOffset(0.0, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0);

            if (FlxG.keys.justPressed.LEFT)
                addAnimationOffset(FlxG.keys.pressed.SHIFT ? -10.0 : -1.0, 0.0);

            if (FlxG.keys.justPressed.DOWN)
                addAnimationOffset(0.0, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0);

            if (FlxG.keys.justPressed.RIGHT)
                addAnimationOffset(FlxG.keys.pressed.SHIFT ? 10.0 : 1.0, 0.0);

            var animData:AnimationData = getCurrentAnimation();

            if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || FlxG.keys.justPressed.SPACE)
            {
                character.animation.play(animData.name, true);

                updateAnimationsTab();
            }

            if (FlxG.keys.justPressed.I)
                updateCameraPoint(0.0, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0);

            if (FlxG.keys.justPressed.J)
                updateCameraPoint(FlxG.keys.pressed.SHIFT ? -10.0 : -1.0, 0.0);

            if (FlxG.keys.justPressed.K)
                updateCameraPoint(0.0, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0);

            if (FlxG.keys.justPressed.L)
                updateCameraPoint(FlxG.keys.pressed.SHIFT ? 10.0 : 1.0, 0.0);

            if (FlxG.keys.pressed.CONTROL)
            {
                if (FlxG.keys.justPressed.C)
                {
                    Clipboard.generalClipboard.clear();

                    Clipboard.generalClipboard.setData(TEXT_FORMAT, Json.stringify(animData.offset), false);
                }

                if (FlxG.keys.justPressed.V)
                {
                    var offset:AxisData = Json.parse(Clipboard.generalClipboard.getData(TEXT_FORMAT));

                    setAnimationOffset(offset.x, offset.y);
                }
            }

            if (FlxG.keys.justPressed.ESCAPE)
                FlxG.switchState(nextState);
        }
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.mouse.visible = false;
    }

    public function updateMainTab():Void
    {
        ui.findComponent("textfield", TextField).text = character.config.name;

        ui.findComponent("checkbox", CheckBox).value = character.config.antialiasing ?? true;

        ui.findComponent("number-stepper", NumberStepper).value = character.config.scale?.x ?? 1.0;

        ui.findComponent("_number-stepper", NumberStepper).value = character.config.scale?.y ?? 1.0;

        ui.findComponent("_checkbox", CheckBox).value = character.config.flipX ?? false;

        ui.findComponent("__checkbox", CheckBox).value = character.config.flipY ?? false;

        ui.findComponent("_textfield", TextField).text = character.config.danceSteps.toString();

        ui.findComponent("_textfield", TextField).text = ui.findComponent("_textfield", TextField).text.substring(1, ui.findComponent("_textfield", TextField).text.length - 1);

        ui.findComponent("__number-stepper", NumberStepper).value = character.config.danceEvery ?? 1.0;

        ui.findComponent("___number-stepper", NumberStepper).value = character.config.singDuration ?? 8.0;
    }

    public function updateAssetsTab():Void
    {
        ui.findComponent("__textfield", TextField).text = character.config.format;

        ui.findComponent("___textfield", TextField).text = character.config.image;

        ui.findComponent("____textfield", TextField).text = character.config.healthIcon;

        ui.findComponent("_____textfield", TextField).text = character.config.healthColor;

        ui.findComponent("______textfield", TextField).text = character.deadCharacter;
    }

    public function updateAnimationsTab():Void
    {
        var animation:AnimationData = getCurrentAnimation();

        ui.findComponent("_______textfield", TextField).text = animation.name;

        ui.findComponent("________textfield", TextField).text = animation.prefix;

        var indicesText:String = animation.indices?.toString() ?? "";

        ui.findComponent("textarea", TextArea).text = indicesText;

        if (indicesText != "")
        {
            ui.findComponent("textarea", TextArea).text = ui.findComponent("textarea", TextArea).text.substring(1,
                ui.findComponent("textarea", TextArea).text.length - 1);
        }

        ui.findComponent("____number-stepper", NumberStepper).value = animation.frameRate ?? 24.0;

        ui.findComponent("___checkbox", CheckBox).value = animation.looped ?? false;

        ui.findComponent("____checkbox", CheckBox).value = animation.flipX ?? false;

        ui.findComponent("_____checkbox", CheckBox).value = animation.flipY ?? false;

        updateOffsetLabel();
    }

    public function saveAnimation():Void
    {
        var frames:Array<FlxFrame> = new Array<FlxFrame>();

        @:privateAccess
        character.animation.findByPrefix(frames, ui.findComponent("________textfield", TextField).text);
        
        if (frames.length == 0.0)
            return;

        var indices:Array<Int> = FlxStringUtil.toIntArray(ui.findComponent("textarea", TextArea).text);

        var animation:AnimationData = character.config.animations.first((animation:AnimationData) -> ui.findComponent("_______textfield", TextField).text == animation.name);

        if (animation == null)
        {
            character.config.animations.push
            ({
                name: ui.findComponent("_______textfield", TextField).text,

                prefix: ui.findComponent("________textfield", TextField).text,

                indices: indices,

                frameRate: ui.findComponent("____number-stepper", NumberStepper).value,

                looped: ui.findComponent("___checkbox", CheckBox).value,

                flipX: ui.findComponent("____checkbox", CheckBox).value,

                flipY: ui.findComponent("_____checkbox", CheckBox).value,

                offset: {x: 0.0, y: 0.0}
            });

            animation = setAnimationIndex(character.config.animations.length - 1);
        }
        else
        {
            animation.prefix = ui.findComponent("________textfield", TextField).text;

            animation.indices = indices;

            animation.frameRate = ui.findComponent("____number-stepper", NumberStepper).value;

            animation.looped = ui.findComponent("___checkbox", CheckBox).value;

            animation.flipX = ui.findComponent("____checkbox", CheckBox).value;

            animation.flipY = ui.findComponent("_____checkbox", CheckBox).value;
        }
        
        if (animation.indices != null)
            character.animation.addByIndices(animation.name, animation.prefix, animation.indices, "", animation.frameRate,
                animation.looped, animation.flipX, animation.flipY);
        else
            character.animation.addByPrefix(animation.name, animation.prefix, animation.frameRate, animation.looped,
                animation.flipX, animation.flipY);

        updateGhostFrame();

        character.animation.play(animation.name, true);

        updateAnimationsTab();
    }

    public function deleteAnimation():Void
    {
        var animation:AnimationData = getCurrentAnimation();

        character.config.animations.remove(animation);

        if (character.animation.exists(animation.name))
            character.animation.remove(animation.name);

        animation = setAnimationIndex(0);

        character.animation.play(animation.name, true);

        updateAnimationsTab();
    }

    public function getCurrentAnimation():AnimationData
    {
        return character.config.animations[animationIndex];
    }

    public function setAnimationIndex(newIndex:Int):AnimationData
    {
        animationIndex = newIndex;

        return getCurrentAnimation();
    }

    public function getCurrentAnimationOffset():AxisData
    {
        return getCurrentAnimation().offset;
    }

    public function updateOffsetLabel():Void
    {
        var newOffset:AxisData = getCurrentAnimationOffset();

        ui.findComponent("_______________label", Label).text = 'Offset: (${newOffset.x}, ${newOffset.y})';
    }

    public function setAnimationOffset(x:Float = 0.0, y:Float = 0.0):Void
    {
        var offsets:AxisData = getCurrentAnimationOffset();

        offsets.x = x;

        offsets.y = y;

        var animation:AnimationData = getCurrentAnimation();

        updateOffsetLabel();
    }

    public function addAnimationOffset(x:Float = 0.0, y:Float = 0.0):Void
    {
        var data:AxisData = getCurrentAnimationOffset();

        setAnimationOffset(data.x + x, data.y + y);
    }

    public function updateCameraPoint(x:Float = 0.0, y:Float = 0.0):Void
    {
        cameraPointPointer.x += x;

        cameraPointPointer.y += y;

        updateCameraPos();

        character.config.cameraPoint.x += x;

        character.config.cameraPoint.y += y;
    }

    public function resetCameraPoint():Void
    {
        var point:AxisData = character.config.cameraPoint;

        var middle:FlxPoint = character.getMidpoint();

        cameraPointPointer.setPosition(middle.x + point.x, middle.y + point.y);

        middle.put();

        updateCameraPos();
    }

    public function updateCameraPos():Void
    {
        FlxG.camera.scroll.x = cameraPointPointer.x - FlxG.camera.width * 0.5;

        FlxG.camera.scroll.y = cameraPointPointer.y - FlxG.camera.height * 0.5;
    }

    public function updateGhostFrame():Void
    {
        var allAnimations:Array<FlxAnimation> = character.animation.getAnimationList();

        var animationToUse:FlxAnimation = allAnimations.last((anim:FlxAnimation) -> anim.name.contains("idle") ||
            anim.name.contains("dance"));

        if (animationToUse == null)
        {
            ghost.kill();

            return;
        }

        var frameToLoad:FlxFrame = character.frames.frames[animationToUse.frames.last()];

        ghost.loadGraphic(FlxGraphic.fromFrame(frameToLoad));

        ghost.revive();
    }

    public function updateGhostScale():Void
    {
        ghost.scale.set(character.scale.x, character.scale.y);

        ghost.updateHitbox();

        ghost.centerTo();
    }

    public function updateGhostFlip():Void
    {
        ghost.flipX = character.flipX;

        ghost.flipY = character.flipY;
    }
}