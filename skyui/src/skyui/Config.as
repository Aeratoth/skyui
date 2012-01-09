﻿import gfx.events.EventDispatcher;
import skyui.Util;
import skyui.Defines;

dynamic class skyui.Config
{
	static var COL_TYPE_ITEM_ICON = 0;
	static var COL_TYPE_EQUIP_ICON = 1;
	static var COL_TYPE_TEXT = 2;
	static var COL_TYPE_NAME = 3;
	
	static private var _instance:Config;
	
	static private var _initialized:Boolean = initialize();
	static private var _loaded:Boolean = false;
	
	static private var _constantTable:Object = {
		
		ITEM_ICON: COL_TYPE_ITEM_ICON,
		EQUIP_ICON: COL_TYPE_EQUIP_ICON,
		NAME: COL_TYPE_NAME,
		TEXT: COL_TYPE_TEXT,
		
		ASCENDING: 0,
		DESCENDING: Array.DESCENDING,
		CASEINSENSITIVE: Array.CASEINSENSITIVE,
		NUMERIC: Array.NUMERIC,
		
		CAT_INV_ALL: Defines.FLAG_INV_ALL,
		CAT_INV_FAVORITES: Defines.FLAG_INV_FAVORITES,
		CAT_INV_WEAPONS: Defines.FLAG_INV_WEAPONS,
		CAT_INV_ARMOR: Defines.FLAG_INV_ARMOR,
		CAT_INV_POTIONS: Defines.FLAG_INV_POTIONS,
		CAT_INV_SCROLLS: Defines.FLAG_INV_SCROLLS,
		CAT_INV_FOOD: Defines.FLAG_INV_FOOD,
		CAT_INV_INGREDIENTS: Defines.FLAG_INV_INGREDIENTS,
		CAT_INV_BOOKS: Defines.FLAG_INV_BOOKS,
		CAT_INV_KEYS: Defines.FLAG_INV_KEYS,
		CAT_INV_MISC: Defines.FLAG_INV_MISC,
		
		CAT_CONTAINER_ALL: Defines.FLAG_CONTAINER_ALL,
		CAT_CONTAINER_WEAPONS: Defines.FLAG_CONTAINER_WEAPONS,
		CAT_CONTAINER_ARMOR: Defines.FLAG_CONTAINER_ARMOR,
		CAT_CONTAINER_POTIONS: Defines.FLAG_CONTAINER_POTIONS,
		CAT_CONTAINER_SCROLLS: Defines.FLAG_CONTAINER_SCROLLS,
		CAT_CONTAINER_FOOD: Defines.FLAG_CONTAINER_FOOD,
		CAT_CONTAINER_INGREDIENTS: Defines.FLAG_CONTAINER_INGREDIENTS,
		CAT_CONTAINER_BOOKS: Defines.FLAG_CONTAINER_BOOKS,
		CAT_CONTAINER_KEYS: Defines.FLAG_CONTAINER_KEYS,
		CAT_CONTAINER_MISC: Defines.FLAG_CONTAINER_MISC,
		
		CAT_MAG_ALL: Defines.FLAG_MAGIC_ALL,
		CAT_MAG_FAVORITES: Defines.FLAG_MAGIC_FAVORITES,
		CAT_MAG_ALTERATION: Defines.FLAG_MAGIC_ALTERATION,
		CAT_MAG_ILLUSION: Defines.FLAG_MAGIC_ILLUSION,
		CAT_MAG_DESTRUCTION: Defines.FLAG_MAGIC_DESTRUCTION,
		CAT_MAG_CONJURATION: Defines.FLAG_MAGIC_CONJURATION,
		CAT_MAG_RESTORATION: Defines.FLAG_MAGIC_RESTORATION,
		CAT_MAG_SHOUTS: Defines.FLAG_MAGIC_SHOUTS,
		CAT_MAG_POWERS: Defines.FLAG_MAGIC_POWERS,
		CAT_MAG_EFFECTS: Defines.FLAG_MAGIC_ACTIVE_EFFECT
	};
	
	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;
	
	// Ok, this may not be the best solution but I can't think of anything else right now
	// Just hope that loading is done once you need the values :)
	public static function initialize():Boolean
	{
		if (_initialized) {
			return;
		}
			
		_instance = new Config();
		var lv = new LoadVars();
		lv.onData = parseData;
		lv.load("skyui.cfg");
		
		return true;
	}
	
	static function get instance():Config
	{
		return _instance;
	}

	private function Config()
	{
		EventDispatcher.initialize(this);
	}
	
	function get loaded():Boolean
	{
		return _loaded;
	}

	static function parseData(a_data:Array)
	{
		var lines = a_data.split("\r\n");
		if (lines.length == 1) {
			lines = a_data.split("\n");
		}

		var section = undefined;

		for (var i = 0; i < lines.length; i++) {

			// Comment
			if (lines[i].charAt(0) == ";") {
				continue;
			}

			// Section start
			if (lines[i].charAt(0) == "[") {
				section = lines[i].slice(1, lines[i].lastIndexOf("]"));
//				trace("Section: [" + section + "]");
				
				if (_instance[section] == undefined) {
					_instance[section] = {};
				}
				continue;
			}

			if (lines[i].length < 3 || section == undefined) {
				continue;
			}
			
			// Get raw key string
			var key = Util.clean(lines[i].slice(0, lines[i].indexOf("=")));
			if (key == undefined) {
				continue;
			}
			// Prepare key subsections
			var a = key.split(".");
			var loc = _instance[section];
			for (var j=0; j<a.length-1; j++) {
				if (loc[a[j]] == undefined) {
					loc[a[j]] = {};
				}
				loc = loc[a[j]];
			}

			// Detect value type & extract
			var val = parseValueString(Util.clean(lines[i].slice(lines[i].indexOf("=") + 1)), _constantTable, _instance[section]);
			
			if (val == undefined) {
				continue;
			}
			
//			trace(key + "=" + val + "%");

			// Store val at config.section.a.b.c.d
			loc[a[a.length-1]] = val;
		}
		
		Config._loaded = true;
		_instance.dispatchEvent({type:"configLoad", config:_instance});
	}
	
	static function parseValueString(a_str:String, a_constantTable:Object, a_root:Object):Object
	{
		if (a_str == undefined) {
			return undefined;
		}

		// Number?
		if (!isNaN(a_str)) {
			return Number(a_str);
			
		// Bool true?
		} else if (a_str.toLowerCase() == "true") {
			return true;
			
		// Bool false?
		} else if (a_str.toLowerCase() == "false") {
			return false;
			
		// Explicit String? (enclosed in single quotes)
		} else if (a_str.charAt(0) == "'") {
			a_str = Util.extract(a_str, "'", "'")
			return  Util.unescapeString(a_str, ["'", ";"]);
			
		// Explicit String? (enclosed in double quotes)
		} else if (a_str.charAt(0) == "\"") {
			a_str = Util.extract(a_str, "\"", "\"")
			return  Util.unescapeString(a_str, ["\"", ";"]);
			
		// Entry property? - substituted later
		} else if (a_str.charAt(0) == "@") {
			return a_str;
			
		// List?
		} else if (a_str.charAt(0) == "<") {
			var values = Util.extract(a_str, "<", ">").split(",");
			for (var i=0; i<values.length; i++) {
				values[i] = parseValueString(Util.clean(values[i]), a_constantTable, a_root);
			}
			return values;
			
		// Flags?
		} else if (a_str.charAt(0) == "{") {
			var values = Util.extract(a_str, "{", "}").split("|");
			var flags = 0;
			for (var i=0; i<values.length; i++) {
				var t = parseValueString(Util.clean(values[i]), a_constantTable, a_root);
				if (isNaN(t)) {
					return undefined;
				}
				flags = flags | t;
			}
			return flags;
		
		// Constant?
		} else if (a_constantTable[a_str] != undefined) {
			return a_constantTable[a_str];
			
		// Top-level property?
		} else if (a_root[a_str] != undefined) {
			return a_root[a_str];
		}
		
		// Default String
		return a_str;
	}
}