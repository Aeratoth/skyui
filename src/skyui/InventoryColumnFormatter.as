﻿import skyui.IColumnFormatter;
import skyui.Defines;
import skyui.Config;

class skyui.InventoryColumnFormatter implements IColumnFormatter
{
	private static var STATES = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];

	private var _maxTextLength:Number;
	
	// icon vars
	private var _bShowStolenIcon:Boolean;

	// color vars
	private var _defaultEnabledColor;
	private var _defaultDisabledColor;
	private var _negativeEnabledColor;
	private var _negativeDisabledColor;
	private var _stolenEnabledColor;
	private var _stolenDisabledColor;

	private var _config:Config;
	
	function InventoryColumnFormatter()
	{
		_maxTextLength = 50;
		_bShowStolenIcon = true;
		_defaultEnabledColor = 0xffffff;
		_defaultDisabledColor = 0x4c4c4c;
		_negativeEnabledColor = 0xff0000;
		_negativeDisabledColor = 0x800000;
		_stolenEnabledColor = 0xff0000;
		_stolenDisabledColor = 0x800000;
		Config.instance.addEventListener("configLoad",this,"onConfigLoad");
	}

	function onConfigLoad(event)
	{
		_config = event.config;
		if (_config.ItemList.entry.icon.stolen != undefined)
			_bShowStolenIcon = _config.ItemList.entry.icon.stolen;
		if (_config.ItemList.entry.color.enabled.textDefault != undefined)
			_defaultEnabledColor = _config.ItemList.entry.color.enabled.textDefault;
		if (_config.ItemList.entry.color.disabled.textDefault != undefined)
			_defaultDisabledColor = _config.ItemList.entry.color.disabled.textDefault;
		if (_config.ItemList.entry.color.enabled.negative != undefined)
			_negativeEnabledColor = _config.ItemList.entry.color.enabled.negative;
		if (_config.ItemList.entry.color.disabled.negative != undefined) 
			_negativeDisabledColor = _config.ItemList.entry.color.disabled.negative;
		if (_config.ItemList.entry.color.enabled.stolen != undefined)
			_stolenEnabledColor = _config.ItemList.entry.color.enabled.stolen;
		if (_config.ItemList.entry.color.disabled.stolen != undefined)
			_stolenDisabledColor = _config.ItemList.entry.color.disabled.stolen;
	}

	function set maxTextLength(a_length:Number)
	{
		if (a_length > 3) {
			_maxTextLength = a_length;
		}
	}

	function get maxTextLength():Number
	{
		return _maxTextLength;
	}

	function formatEquipIcon(a_entryField:Object, a_entryObject:Object)
	{
		if (a_entryObject != undefined && a_entryObject.equipState != undefined) {
			a_entryField.gotoAndStop(STATES[a_entryObject.equipState]);
		} else {
			a_entryField.gotoAndStop("None");
		}
	}

	function formatItemIcon(a_entryField:Object, a_entryObject:Object)
	{
		switch (a_entryObject.infoType) {
			case InventoryDefines.ICT_WEAPON :
				if (a_entryObject.formType == Defines.FORMTYPE_ARROW) {
					a_entryField.gotoAndStop("weapon_arrow");
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_DAGGER) {
					a_entryField.gotoAndStop("weapon_dagger");
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_BOW) {
					a_entryField.gotoAndStop("weapon_bow");
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_GREATSWORD) {
					a_entryField.gotoAndStop("weapon_greatsword");
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_WARAXE) {
					a_entryField.gotoAndStop("weapon_waraxe");
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_MACE) {
					a_entryField.gotoAndStop("weapon_mace");
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_LONGSWORD) {
					a_entryField.gotoAndStop("weapon_sword");
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_HAMMER) {
					a_entryField.gotoAndStop("weapon_hammer");
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_STAFF) {
					a_entryField.gotoAndStop("weapon_staff");
					break;
				}
			
				a_entryField.gotoAndStop("default_weapon");
				break;
			case InventoryDefines.ICT_ARMOR :
				a_entryField.gotoAndStop("default_armor");
				break;
			case InventoryDefines.ICT_POTION :
				a_entryField.gotoAndStop("default_potion");
				break;
			case InventoryDefines.ICT_SPELL :
				a_entryField.gotoAndStop("default_scroll");
				break;
			case InventoryDefines.ICT_FOOD :
				a_entryField.gotoAndStop("default_food");
				break;
			case InventoryDefines.ICT_INGREDIENT :
				a_entryField.gotoAndStop("default_ingredient");
				break;
			case InventoryDefines.ICT_BOOK :
				a_entryField.gotoAndStop("default_book");
				break;
			case InventoryDefines.ICT_KEY :
				a_entryField.gotoAndStop("default_key");
				break;
			case InventoryDefines.ICT_MISC :
			default :
				if (a_entryObject.formType == Defines.FORMTYPE_SOULGEM) {
					a_entryField.gotoAndStop("misc_soulgem");
				} else {
					a_entryField.gotoAndStop("default_misc");
				}
		}
	}

	function formatName(a_entryField:Object, a_entryObject:Object, a_entryClip:MovieClip)
	{
		if (a_entryObject.text != undefined) {

			// Text
			var text = a_entryObject.text;
			
			if (a_entryObject.soulLVL != undefined) {
				text = text + " (" + a_entryObject.soulLVL + ")";
			}

			if (a_entryObject.count > 1) {
				text = text + " (" + a_entryObject.count.toString() + ")";
			}

			if (text.length > _maxTextLength) {
				text = text.substr(0, _maxTextLength - 3) + "...";
			}

			a_entryField.autoSize = "left";
			a_entryField.SetText(text);

			formatColor(a_entryField, a_entryObject);
			
			// BestInClass icon
			var iconPos = a_entryField._x + a_entryField._width + 5;

			// All icons have the same size
			var iconSpace = a_entryClip.bestIcon._width * 1.25;

			if (a_entryObject.bestInClass == true) {
				a_entryClip.bestIcon._x = iconPos;
				iconPos = iconPos + iconSpace;

				a_entryClip.bestIcon.gotoAndStop("show");
			} else {
				a_entryClip.bestIcon.gotoAndStop("hide");
			}

			// Fav icon
			if (a_entryObject.favorite == true) {
				a_entryClip.favoriteIcon._x = iconPos;
				iconPos = iconPos + iconSpace;
				a_entryClip.favoriteIcon.gotoAndStop("show");
			} else {
				a_entryClip.favoriteIcon.gotoAndStop("hide");
			}

			// Poisoned Icon
			if (a_entryObject.infoIsPoisoned == true) {
				a_entryClip.poisonIcon._x = iconPos;
				iconPos = iconPos + iconSpace;
				a_entryClip.poisonIcon.gotoAndStop("show");
			} else {
				a_entryClip.poisonIcon.gotoAndStop("hide");
			}

			// Stolen Icon
			if ((a_entryObject.infoIsStolen == true || a_entryObject.isStealing) && _bShowStolenIcon != false) {
				a_entryClip.stolenIcon._x = iconPos;
				iconPos = iconPos + iconSpace;
				a_entryClip.stolenIcon.gotoAndStop("show");
			} else {
				a_entryClip.stolenIcon.gotoAndStop("hide");
			}

			// Enchanted Icon
			if (a_entryObject.infoIsEnchanted == true) {
				a_entryClip.enchIcon._x = iconPos;
				iconPos = iconPos + iconSpace;
				a_entryClip.enchIcon.gotoAndStop("show");
			} else {
				a_entryClip.enchIcon.gotoAndStop("hide");
			}

		} else {
			a_entryField.SetText(" ");
		}
	}

	function formatColor(a_entryField:Object, a_entryObject:Object)
	{
		// Negative Effect
		if (a_entryObject.negativeEffect == true) {
			a_entryField.textColor = a_entryObject.enabled == false ? _negativeDisabledColor : _negativeEnabledColor;
			
		// Stolen
		} else if (a_entryObject.infoIsStolen == true || a_entryObject.isStealing) {
			a_entryField.textColor = a_entryObject.enabled == false ? _stolenDisabledColor : _stolenEnabledColor;
			
		// Default
		} else {
			a_entryField.textColor = a_entryObject.enabled == false ? _defaultDisabledColor : _defaultEnabledColor;
		}	
	}

	function formatText(a_entryField:Object, a_entryObject:Object)
	{
		formatColor(a_entryField, a_entryObject);
	}
}