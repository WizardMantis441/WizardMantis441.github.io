import Reflect;
import Std;

public var modchartSprites:Map<String, Dynamic> = [];
public var modchartTweens:Map<String, Dynamic> = [];
public var modchartTimers:Map<String, Dynamic> = [];
public var modchartTexts:Map<String, Dynamic> = [];
public var variables:Map<String, Dynamic> = [];
public var runtimeShaders:Map<String, Dynamic> = [];

function makeLuaSprite(id, ?image=null, ?x, ?y) {
	tag = tag.replace('.', '');
	resetSpriteTag(tag);
	var leSprite:ModchartSprite = new ModchartSprite(x, y);
	if(image != null && image.length > 0)
		leSprite.loadGraphic(Paths.image(image));
	modchartSprites.set(tag, leSprite);
	leSprite.active = true;
}

function makeAnimatedLuaSprite(id, ?image=null, ?x, ?y, ?spriteType:String = "sparrow") {
	tag = tag.replace('.', '');
	resetSpriteTag(tag);
	var leSprite:ModchartSprite = new ModchartSprite(x, y);

	loadFrames(leSprite, image, spriteType);
	modchartSprites.set(tag, leSprite);
}

function addLuaSprite(tag:String, ?front:Bool = false) {
	if(modchartSprites.exists(tag)) {
		var shit:ModchartSprite = modchartSprites.get(tag);
		if(!shit.wasAdded) {
			if(front)
			{
				getInstance().add(shit);
			}
			else
			{
				//if(PlayState.instance.isDead)
				//{
				//    GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), shit);
				//}
				//else
				//{
					var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gf);
					if(PlayState.instance.members.indexOf(PlayState.instance.boyfriend) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.boyfriend);
					} else if(PlayState.instance.members.indexOf(PlayState.instance.dad) < position) {
						position = PlayState.instance.members.indexOf(PlayState.instance.dad);
					}
					PlayState.instance.insert(position, shit);
				//}
			}
			shit.wasAdded = true;
			//trace('added a thing: ' + tag);
		}
	}
}

// utils

function isOfTypes(value:Any, types:Array<Dynamic>)
{
	for (type in types)
	{
		if(Std.isOfType(value, type))
			return true;
	}
	return false;
}

/*
#if hscript
function initHaxeModule()
{
	if(hscript == null)
	{
		trace('initializing haxe interp for: $scriptName');
		hscript = new HScript(); //TO DO: Fix issue with 2 scripts not being able to use the same variable names
	}
}
#end*/

function setVarInArray(instance:Dynamic, variable:String, value:Dynamic):Any
{
	var shit:Array<String> = variable.split('[');
	if(shit.length > 1)
	{
		var blah:Dynamic = null;
		if(variables.exists(shit[0]))
		{
			var retVal:Dynamic = variables.get(shit[0]);
			if(retVal != null)
				blah = retVal;
		}
		else
			blah = Reflect.getProperty(instance, shit[0]);

		for (i in 1...shit.length)
		{
			var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
			if(i >= shit.length-1) //Last array
				blah[leNum] = value;
			else //Anything else
				blah = blah[leNum];
		}
		return blah;
	}

	if(PlayState.instance.variables.exists(variable))
	{
		PlayState.instance.variables.set(variable, value);
		return true;
	}

	Reflect.setProperty(instance, variable, value);
	return true;
}
function getVarInArray(instance:Dynamic, variable:String):Any
{
	var shit:Array<String> = variable.split('[');
	if(shit.length > 1)
	{
		var blah:Dynamic = null;
		if(PlayState.instance.variables.exists(shit[0]))
		{
			var retVal:Dynamic = PlayState.instance.variables.get(shit[0]);
			if(retVal != null)
				blah = retVal;
		}
		else
			blah = Reflect.getProperty(instance, shit[0]);

		for (i in 1...shit.length)
		{
			var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
			blah = blah[leNum];
		}
		return blah;
	}

	if(variables.exists(variable))
	{
		var retVal:Dynamic = variables.get(variable);
		if(retVal != null)
			return retVal;
	}

	return Reflect.getProperty(instance, variable);
}

function getTextObject(name:String):FlxText
{
	return modchartTexts.exists(name) ? modchartTexts.get(name) : Reflect.getProperty(PlayState.instance, name);
}

/*#if (!flash && sys)
function getShader(obj:String):FlxRuntimeShader
{
	var killMe:Array<String> = obj.split('.');
	var leObj:FlxSprite = getObjectDirectly(killMe[0]);
	if(killMe.length > 1) {
		leObj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
	}

	if(leObj != null) {
		//var shader:Dynamic = leObj.shader;
		//var shader:FlxRuntimeShader = shader;
		return leObj.shader;//shader;
	}
	return null;
}
#end

function initLuaShader(name:String, ?glslVersion:Int = 120)
{
	//if(!ClientPrefs.shaders) return false;

	//#if (!flash && sys)
	if(runtimeShaders.exists(name))
	{
		luaTrace('Shader $name was already initialized!');
		return true;
	}

	var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
	if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
		foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

	for(mod in Paths.getGlobalMods())
		foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));

	for (folder in foldersToCheck)
	{
		if(FileSystem.exists(folder))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
	}
	luaTrace('Missing shader $name .frag AND .vert files!', false, false, FlxColor.RED);
	//#else
	//luaTrace('This platform doesn\'t support Runtime Shaders!', false, false, FlxColor.RED);
	//#end
	return false;
}*/

function getGroupStuff(leArray:Dynamic, variable:String) {
	var killMe:Array<String> = variable.split('.');
	if(killMe.length > 1) {
		var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
		for (i in 1...killMe.length-1) {
			coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
		}
		leArray = coverMeInPiss;
		variable = killMe[killMe.length-1];
	}
	// TODO: needs to be remade
	switch(Type.typeof(leArray)){
		case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
			return leArray.get(variable);
		default:
			return Reflect.getProperty(leArray, variable);
	};
}

function loadFrames(spr:FlxSprite, image:String, spriteType:String)
{
	switch(spriteType.toLowerCase().trim())
	{
		/*case "texture" | "textureatlas" | "tex":
			spr.frames = AtlasFrameMaker.construct(image);

		case "texture_noaa" | "textureatlas_noaa" | "tex_noaa":
			spr.frames = AtlasFrameMaker.construct(image, null, true);*/

		case "packer" | "packeratlas" | "pac":
			spr.frames = Paths.getPackerAtlas(image);

		default:
			spr.frames = Paths.getSparrowAtlas(image);
	}
}

function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic) {
	var killMe:Array<String> = variable.split('.');
	if(killMe.length > 1) {
		var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
		for (i in 1...killMe.length-1) {
			coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
		}
		Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
		return;
	}
	Reflect.setProperty(leArray, variable, value);
}

function resetTextTag(tag:String) {
	if(!modchartTexts.exists(tag)) {
		return;
	}

	var pee:ModchartText = modchartTexts.get(tag);
	pee.kill();
	if(pee.wasAdded) {
		PlayState.instance.remove(pee, true);
	}
	pee.destroy();
	modchartTexts.remove(tag);
}

function cancelTween(tag:String) {
	if(modchartTweens.exists(tag)) {
		modchartTweens.get(tag).cancel();
		modchartTweens.get(tag).destroy();
		modchartTweens.remove(tag);
	}
}

function tweenShit(tag:String, vars:String) {
	cancelTween(tag);
	var variables:Array<String> = vars.split('.');
	var sexyProp:Dynamic = getObjectDirectly(variables[0]);
	if(variables.length > 1) {
		sexyProp = getVarInArray(getPropertyLoopThingWhatever(variables), variables[variables.length-1]);
	}
	return sexyProp;
}

function cancelTimer(tag:String) {
	if(modchartTimers.exists(tag)) {
		var theTimer:FlxTimer = modchartTimers.get(tag);
		theTimer.cancel();
		theTimer.destroy();
		modchartTimers.remove(tag);
	}
}

function getFlxEaseByString(?ease:String = '') {
	switch(ease.toLowerCase().trim()) {
		case 'backin': return FlxEase.backIn;
		case 'backinout': return FlxEase.backInOut;
		case 'backout': return FlxEase.backOut;
		case 'bouncein': return FlxEase.bounceIn;
		case 'bounceinout': return FlxEase.bounceInOut;
		case 'bounceout': return FlxEase.bounceOut;
		case 'circin': return FlxEase.circIn;
		case 'circinout': return FlxEase.circInOut;
		case 'circout': return FlxEase.circOut;
		case 'cubein': return FlxEase.cubeIn;
		case 'cubeinout': return FlxEase.cubeInOut;
		case 'cubeout': return FlxEase.cubeOut;
		case 'elasticin': return FlxEase.elasticIn;
		case 'elasticinout': return FlxEase.elasticInOut;
		case 'elasticout': return FlxEase.elasticOut;
		case 'expoin': return FlxEase.expoIn;
		case 'expoinout': return FlxEase.expoInOut;
		case 'expoout': return FlxEase.expoOut;
		case 'quadin': return FlxEase.quadIn;
		case 'quadinout': return FlxEase.quadInOut;
		case 'quadout': return FlxEase.quadOut;
		case 'quartin': return FlxEase.quartIn;
		case 'quartinout': return FlxEase.quartInOut;
		case 'quartout': return FlxEase.quartOut;
		case 'quintin': return FlxEase.quintIn;
		case 'quintinout': return FlxEase.quintInOut;
		case 'quintout': return FlxEase.quintOut;
		case 'sinein': return FlxEase.sineIn;
		case 'sineinout': return FlxEase.sineInOut;
		case 'sineout': return FlxEase.sineOut;
		case 'smoothstepin': return FlxEase.smoothStepIn;
		case 'smoothstepinout': return FlxEase.smoothStepInOut;
		case 'smoothstepout': return FlxEase.smoothStepInOut;
		case 'smootherstepin': return FlxEase.smootherStepIn;
		case 'smootherstepinout': return FlxEase.smootherStepInOut;
		case 'smootherstepout': return FlxEase.smootherStepOut;
	}
	return FlxEase.linear;
}

function blendModeFromString(blend:String):BlendMode {
	switch(blend.toLowerCase().trim()) {
		case 'add': return BlendMode.ADD;
		case 'alpha': return BlendMode.ALPHA;
		case 'darken': return BlendMode.DARKEN;
		case 'difference': return BlendMode.DIFFERENCE;
		case 'erase': return BlendMode.ERASE;
		case 'hardlight': return BlendMode.HARDLIGHT;
		case 'invert': return BlendMode.INVERT;
		case 'layer': return BlendMode.LAYER;
		case 'lighten': return BlendMode.LIGHTEN;
		case 'multiply': return BlendMode.MULTIPLY;
		case 'overlay': return BlendMode.OVERLAY;
		case 'screen': return BlendMode.SCREEN;
		case 'shader': return BlendMode.SHADER;
		case 'subtract': return BlendMode.SUBTRACT;
	}
	return BlendMode.NORMAL;
}

function resetSpriteTag(tag:String) {
	if(!modchartSprites.exists(tag)) {
		return;
	}

	var pee:ModchartSprite = modchartSprites.get(tag);
	pee.kill();
	if(pee.wasAdded) {
		PlayState.instance.remove(pee, true);
	}
	pee.destroy();
	modchartSprites.remove(tag);
}

function cameraFromString(cam:String):FlxCamera {
	switch(cam.toLowerCase()) {
		case 'camhud' | 'hud': return PlayState.instance.camHUD;
		//case 'camother' | 'other': return PlayState.instance.camOther;
	}
	return PlayState.instance.camGame;
}

function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE) {
	#if LUA_ALLOWED
	if(ignoreCheck || getBool('luaDebugMode')) {
		if(deprecated && !getBool('luaDeprecatedWarnings')) {
			return;
		}
		PlayState.instance.addTextToDebug(text, color);
		trace(text);
	}
	#end
	trace(text);
}

function addAnimByIndices(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24, loop:Bool = false)
{
	var strIndices:Array<String> = indices.trim().split(','); // TODO: StringTools
	var die:Array<Int> = [];
	for (i in 0...strIndices.length) {
		die.push(Std.parseInt(strIndices[i]));
	}

	var spr = null;

	if(PlayState.instance.getLuaObject(obj, false) != null)
		spr = PlayState.instance.getLuaObject(obj, false);
	if(spr == null)
		spr = Reflect.getProperty(getInstance(), obj);

	if(spr != null) {
		spr.animation.addByIndices(name, prefix, die, '', framerate, loop);
		if(spr.animation.curAnim == null) {
			spr.animation.play(name, true);
		}
		return true;
	}
	return false;
}

function getPropertyLoopThingWhatever(killMe:Array<String>, ?checkForTextsToo:Bool = true, ?getProperty:Bool=true):Dynamic
{
	var coverMeInPiss:Dynamic = getObjectDirectly(killMe[0], checkForTextsToo);
	var end = killMe.length;
	if(getProperty)end=killMe.length-1;

	for (i in 1...end) {
		coverMeInPiss = getVarInArray(coverMeInPiss, killMe[i]);
	}
	return coverMeInPiss;
}

function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true):Dynamic
{
	var coverMeInPiss:Dynamic = PlayState.instance.getLuaObject(objectName, checkForTextsToo);
	if(coverMeInPiss==null)
		coverMeInPiss = getVarInArray(getInstance(), objectName);

	return coverMeInPiss;
}

function getInstance()
{
	return PlayState.instance;//PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
}

class ModchartSprite extends flixel.FlxSprite
{
	//public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	//public var wasAdded:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);

		wasAdded = false;
		animOffsets = ["cock"=>[0]];
		animOffsets.remove("cock");
		antialiasing = true;
	}
}