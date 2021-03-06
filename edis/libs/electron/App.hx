package edis.libs.electron;

import haxe.extern.EitherType;
import haxe.Constraints.Function;

import electron.NativeImage;

import tannus.sys.*;

typedef App = ExtApp;

#if main_process
@:jsRequire('electron', 'app')
#elseif renderer_process
@:jsRequire('electron', 'remote.app')
#end
extern class ExtApp {
	public static function on(event:String, f:Function):Void;
	public static function quit():Void;
	public static function exit(?code : Int):Void;
	public static function relaunch(?options : ExtAppRelaunchOptions):Void;
	public static function isReady():Bool;
	public static function isUnityRunning():Bool;
	public static function focus():Void;
	@:native('getAppPath')
	public static function _getAppPath():String;
	@:native('getPath')
	public static function _getPath(name : ExtAppNamedPath):String;
	public static function getVersion():String;
	public static function getName():String;
	public static function makeSingleInstance(f : Array<String>->String->Void):Bool;
	public static function releaseSingleInstance():Void;
	public static function getAppMemoryInfo():Array<{pid:Int,memory:MemoryInfo}>;
	public static function getAppMetrics():Array<ProcessMetric>;

	@:overload(function(path:String,o:{size:String},cb:Null<Dynamic>->NativeImage->Void):Void {})
	public static function getFileIcon(path:String, callback:Null<Dynamic>->NativeImage->Void):Void;

	inline public static function getAppPath():Path return new Path(_getAppPath());
	inline public static function getPath(name : ExtAppNamedPath):Path return new Path(_getPath(name));

	inline public static function onReady(f : Void->Void):Void {
	    on('ready', f);
	}
	inline public static function onAllClosed(f : Void->Void):Void {
	    on('window-all-closed', f);
	}
}

typedef MemoryInfo = {
    pid: Int,
    workingSetSize: Int,
    peakWorkingSetSize: Int,
    privateBytes: Int,
    sharedBytes: Int
};

typedef CPUUsage = {
    percentCPUUsage: Float,
    idleWakeupsPerSecond: Float
};

typedef ProcessMetric = {
    pid: Int,
    type: String,
    memory: MemoryInfo,
    cpu: CPUUsage
};

typedef ExtAppRelaunchOptions = {
	?args:Array<String>,
	?execPath:String
};

@:enum
abstract ExtAppNamedPath (String) from String to String {
	var Home = 'home';
	var AppData = 'appData';
	var UserData = 'userData';
	var Temp = 'temp';
	var Exe = 'exe';
	var Module = 'module';
	var Desktop = 'desktop';
	var Documents = 'documents';
	var Downloads = 'downloads';
	var Pictures = 'pictures';
	var Videos = 'videos';
}
