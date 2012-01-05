﻿import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import skyui.Config;
import gfx.ui.NavigationCode;


class ItemMenu extends MovieClip
{
	private var _platform:Number;
	private var _bItemCardFadedIn:Boolean;
	
	private var _3DIconXSettingStr:String;
	private var _3DIconZSettingStr:String;
	private var _3DIconScaleSettingStr:String;
	private var _3DIconWideXSettingStr:String;
	private var _3DIconWideZSettingStr:String;
	private var _3DIconWideScaleSettingStr:String;
	
	private var _3DIconXDefault:Number;
	private var _3DIconZDefault:Number;
	private var _3DIconScaleDefault:Number;
	private var _3DIconWideXDefault:Number;
	private var _3DIconWideZDefault:Number;
	private var _3DIconWideScaleDefault:Number;
	
	private var _config;
	
	var InventoryLists_mc:MovieClip;
	var ItemCardFadeHolder_mc:MovieClip;
	var ItemCard_mc:MovieClip;
	var BottomBar_mc:MovieClip;

	var MouseRotationRect:MovieClip;
	var ExitMenuRect:MovieClip;
	var skseWarningMsg:MovieClip;
	
	// API
	var bFadedIn:Boolean;
	
        static var DEBUG_LEVEL = 1;

	function ItemMenu()
	{
		super();
		
		InventoryLists_mc = InventoryLists_mc;
		ItemCard_mc = ItemCardFadeHolder_mc.ItemCard_mc;
		BottomBar_mc = BottomBar_mc;
		
		Mouse.addListener(this);
		Config.instance.addEventListener("configLoad",this,"onConfigLoad");
		
		bFadedIn = true;
		_bItemCardFadedIn = false;
		
		_3DIconXSettingStr = "fInventory3DItemPosX:Interface";
		_3DIconZSettingStr = "fInventory3DItemPosZ:Interface";
		_3DIconScaleSettingStr = "fInventory3DItemPosScale:Interface";
		_3DIconWideXSettingStr = "fInventory3DItemPosXWide:Interface";
		_3DIconWideZSettingStr = "fInventory3DItemPosZWide:Interface";
		_3DIconWideScaleSettingStr = "fInventory3DItemPosScaleWide:Interface";
	}

	function InitExtensions(a_bPlayBladeSound)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("<========================ITEMMENU INITEXTENSIONS==================================" + "\n");
		GameDelegate.addCallBack("UpdatePlayerInfo",this,"UpdatePlayerInfo");
		GameDelegate.addCallBack("UpdateItemCardInfo",this,"UpdateItemCardInfo");
		GameDelegate.addCallBack("ToggleMenuFade",this,"ToggleMenuFade");
		GameDelegate.addCallBack("RestoreIndices",this,"RestoreIndices");
		
		InventoryLists_mc.addEventListener("categoryChange",this,"onCategoryChange");
		InventoryLists_mc.addEventListener("itemHighlightChange",this,"onItemHighlightChange");
		InventoryLists_mc.addEventListener("showItemsList",this,"onShowItemsList");
		InventoryLists_mc.addEventListener("hideItemsList",this,"onHideItemsList");
		InventoryLists_mc.ItemsList.addEventListener("itemPress",this,"onItemSelect");
		ItemCard_mc.addEventListener("quantitySelect",this,"onQuantityMenuSelect");
		ItemCard_mc.addEventListener("subMenuAction",this,"onItemCardSubMenuAction");

		PositionElements();
		
		InventoryLists_mc.ShowCategoriesList(a_bPlayBladeSound);
		
		ItemCard_mc._visible = false;
		BottomBar_mc.HideButtons();

		ExitMenuRect.onMouseDown = function()
		{
			if (_parent.bFadedIn == true && Mouse.getTopMostEntity() == this) {
				_parent.onExitMenuRectClick();
			}
		};
		_global.skse.Log("========================END ITEMMENU INITEXTENSIONS==================================>" + "\n");
	}

	function onConfigLoad(event)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onConfigLoad()");
		_config = event.config;
	}

	function PositionElements()
	{
		if (DEBUG_LEVEL > 0)
        	_global.skse.Log("ItemMenu PositionElements()");
		GlobalFunc.SetLockFunction();

		InventoryLists_mc.Lock("L");
		InventoryLists_mc._x = InventoryLists_mc._x - 20;

		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

		var a = InventoryLists_mc.getContentBounds();
		// 25 is hardcoded cause thats the final offset after the animation of the panel container is done
		var panelEdge = InventoryLists_mc._x + a[0] + a[2] + 25;

		BottomBar_mc.PositionElements(leftEdge,rightEdge);

		var itemCardContainer = ItemCard_mc._parent;
		var itemcardPosition = _config.ItemInfo.itemcard;
		var itemiconPosition = _config.ItemInfo.itemicon;

		var scaleMult = (rightEdge - panelEdge) / itemCardContainer._width;

		// Scale down if necessary
		if (scaleMult < 1.0) {
			itemCardContainer._width *= scaleMult;
			itemCardContainer._height *= scaleMult;
			itemiconPosition.scale *= scaleMult;
		}

		if (itemcardPosition.align == "left") {
			itemCardContainer._x = panelEdge + leftEdge + itemcardPosition.xOffset;
		} else if (itemcardPosition.align == "right") {
			itemCardContainer._x = rightEdge - itemCardContainer._width + itemcardPosition.xOffset;
		} else {
			itemCardContainer._x = panelEdge + itemcardPosition.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - panelEdge - itemCardContainer._width) / 2;
		}
		itemCardContainer._y = itemCardContainer._y + itemcardPosition.yOffset;

		MovieClip(ExitMenuRect).Lock("TL");
		ExitMenuRect._x = ExitMenuRect._x - Stage.safeRect.x;
		ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;


		var iconX = GlobalFunc.Lerp(0, 128, Stage.visibleRect.x, (Stage.visibleRect.x + Stage.visibleRect.width), (itemCardContainer._x + (itemCardContainer._width / 2)), 0);
		iconX = -(iconX - 64);

		_3DIconWideScaleDefault = skse.GetINISetting(_3DIconWideScaleSettingStr);
		_3DIconWideXDefault = skse.GetINISetting(_3DIconWideXSettingStr);
		_3DIconWideZDefault = skse.GetINISetting(_3DIconWideZSettingStr);
		_3DIconScaleDefault = skse.GetINISetting(_3DIconScaleSettingStr);
		_3DIconXDefault = skse.GetINISetting(_3DIconXSettingStr);
		_3DIconZDefault = skse.GetINISetting(_3DIconZSettingStr);

		skse.SetINISetting(_3DIconWideScaleSettingStr, (itemiconPosition.scale));
		skse.SetINISetting(_3DIconWideXSettingStr, (iconX + itemiconPosition.xOffset));
		skse.SetINISetting(_3DIconWideZSettingStr, (12 + itemiconPosition.yOffset));
		skse.SetINISetting(_3DIconScaleSettingStr, (itemiconPosition.scale));
		skse.SetINISetting(_3DIconXSettingStr, (iconX + itemiconPosition.xOffset));
		skse.SetINISetting(_3DIconZSettingStr, (16 + itemiconPosition.yOffset));

		if (MouseRotationRect != undefined) {
			MovieClip(MouseRotationRect).Lock("T");
			MouseRotationRect._x = ItemCard_mc._parent._x;
			MouseRotationRect._width = ItemCard_mc._parent._width;
			MouseRotationRect._height = 0.55 * Stage.visibleRect.height;
		}
		
		if (skseWarningMsg != undefined) {
		skseWarningMsg.Lock("TR");
	        }
	}

	// Restore to defaults for enchanting etc
	function ResetElements()
	{
		skse.SetINISetting(_3DIconWideScaleSettingStr, _3DIconWideScaleDefault);
		skse.SetINISetting(_3DIconWideXSettingStr, _3DIconWideXDefault);
		skse.SetINISetting(_3DIconWideZSettingStr, _3DIconWideZDefault);
		skse.SetINISetting(_3DIconScaleSettingStr, _3DIconScaleDefault);
		skse.SetINISetting(_3DIconXSettingStr, _3DIconXDefault);
		skse.SetINISetting(_3DIconZSettingStr, _3DIconZDefault);
	}

	function SetPlatform(a_platform, a_bPS3Switch)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu SetPlatform()");
		_platform = a_platform;
		InventoryLists_mc.SetPlatform(a_platform,a_bPS3Switch);
		ItemCard_mc.SetPlatform(a_platform,a_bPS3Switch);
		BottomBar_mc.SetPlatform(a_platform,a_bPS3Switch);
	}
	
	// API
	function GetInventoryItemList()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu GetInventoryItemList()");
		return InventoryLists_mc.ItemsList;
	}

	function handleInput(details, pathToFocus)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu handleInput()");
		if (bFadedIn) {
			if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
				if (GlobalFunc.IsKeyPressed(details) && details.navEquivalent == NavigationCode.TAB) {
					GameDelegate.call("CloseMenu",[]);
				}
			}
		}

		return true;
	}

	function onMouseWheel(delta)
	{
        if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onMouseWheel()");
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent) {
			if (e == MouseRotationRect && ShouldProcessItemsListInput(false) || !bFadedIn && delta == -1) {
				GameDelegate.call("ZoomItemModel",[delta]);
				continue;
			}
		}
	}

	function onExitMenuRectClick()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onExitMenuRectClick()");
		GameDelegate.call("CloseMenu",[]);
	}

	function onCategoryChange(event)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onCategoryChange()");
	}

	function onItemHighlightChange(event)
	{
        if (DEBUG_LEVEL > 0) _global.skse.Log("ItemMenu onItemHighlightChange()");
		if (event.index != -1) {
			
			if (!_bItemCardFadedIn) {
				_bItemCardFadedIn = true;
				ItemCard_mc.FadeInCard();
				BottomBar_mc.ShowButtons();
			}
			
			GameDelegate.call("UpdateItem3D",[true]);
			GameDelegate.call("RequestItemCardInfo",[],this,"UpdateItemCardInfo");
			
		} else if (_bItemCardFadedIn) {
			_bItemCardFadedIn = false;
			onHideItemsList();
		}
	}

	function onShowItemsList(event)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onShowItemsList()");
		onItemHighlightChange(event);
	}

	function onHideItemsList(event)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onHideItemsList()");
		GameDelegate.call("UpdateItem3D",[false]);
		ItemCard_mc.FadeOutCard();
		BottomBar_mc.HideButtons();
	}

	function onItemSelect(event)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onItemSelect()");
		if (event.entry.enabled) {
			if (event.entry.count > InventoryDefines.QUANTITY_MENU_COUNT_LIMIT) {
				ItemCard_mc.ShowQuantityMenu(event.entry.count);
			} else {
				onQuantityMenuSelect({amount:1});
			}
		} else {
			GameDelegate.call("DisabledItemSelect",[]);
		}
	}

	function onQuantityMenuSelect(event)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onQuantityMenuSelect()");
		GameDelegate.call("ItemSelect",[event.amount]);
	}

	function UpdatePlayerInfo(aUpdateObj)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu UpdatePlayerInfo()");
		BottomBar_mc.UpdatePlayerInfo(aUpdateObj,ItemCard_mc.itemInfo);
	}

	function UpdateItemCardInfo(aUpdateObj)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu UpdateItemCardInfo()");
		ItemCard_mc.itemInfo = aUpdateObj;
		BottomBar_mc.UpdatePerItemInfo(aUpdateObj);
	}

	function onItemCardSubMenuAction(event)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onItemCardSubMenuAction()");
		if (event.opening == true) {
			InventoryLists_mc.ItemsList.disableSelection = true;
			InventoryLists_mc.ItemsList.disableInput = true;
			InventoryLists_mc.CategoriesList.disableSelection = true;
			InventoryLists_mc.CategoriesList.disableInput = true;
		} else if (event.opening == false) {
			InventoryLists_mc.ItemsList.disableSelection = false;
			InventoryLists_mc.ItemsList.disableInput = false;
			InventoryLists_mc.CategoriesList.disableSelection = false;
			InventoryLists_mc.CategoriesList.disableInput = false;
		}
	}

	function ShouldProcessItemsListInput(abCheckIfOverRect)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu ShouldProcessItemsListInput()");
		var process = bFadedIn == true && InventoryLists_mc.currentState == InventoryLists.SHOW_PANEL && InventoryLists_mc.ItemsList.numUnfilteredItems > 0 && !InventoryLists_mc.ItemsList.disableSelection && !InventoryLists_mc.ItemsList.disableInput;

		if (process && _platform == 0 && abCheckIfOverRect) {
			var e = Mouse.getTopMostEntity();
			var found = false;
			
			while (!found && e != undefined)
			{
				if (e == InventoryLists_mc.ItemsList) {
					found = true;
				}
				e = e._parent;
			}
			
			process = process && found;
			if (DEBUG_LEVEL > 1)
				_global.skse.Log("ItemMenu ShouldProcessItemsListInput() process =  " + process + ", found = " + found);
		}
		return process;
	}

	// Added to prevent clicks on the scrollbar from equipping/using stuff
	function ConfirmSelectedEntry():Boolean
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu ConfirmSelectedEntry()");
		// only confirm when using mouse
		if (_platform != 0) {
			return true;
		}
		
		for (var e = Mouse.getTopMostEntity(); e && e != undefined; e = e._parent) {
			if (e.itemIndex == InventoryLists_mc.ItemsList.selectedIndex) {
				return true;
			}
		}
		return false;
	}

	function onMouseRotationStart()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onMouseRotationStart()");
		GameDelegate.call("StartMouseRotation",[]);
		InventoryLists_mc.CategoriesList.disableSelection = true;
		InventoryLists_mc.ItemsList.disableSelection = true;
	}

	function onMouseRotationStop()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onMouseRotationStop()");
		GameDelegate.call("StopMouseRotation",[]);
		InventoryLists_mc.CategoriesList.disableSelection = false;
		InventoryLists_mc.ItemsList.disableSelection = false;
	}

	function onMouseRotationFastClick()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onMouseRotationFastClick()");
		if (ShouldProcessItemsListInput(false)) {
			onItemSelect({entry:InventoryLists_mc.ItemsList.selectedEntry, keyboardOrMouse:0});
		}
	}

	function ToggleMenuFade()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu ToggleMenuFade()");
		if (bFadedIn) {
			_parent.gotoAndPlay("fadeOut");
			bFadedIn = false;
			InventoryLists_mc.ItemsList.disableSelection = true;
			InventoryLists_mc.ItemsList.disableInput = true;
			InventoryLists_mc.CategoriesList.disableSelection = true;
			InventoryLists_mc.CategoriesList.disableInput = true;
		} else {
			_parent.gotoAndPlay("fadeIn");
		}
	}

	function SetFadedIn()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu SetFadedIn()");
		bFadedIn = true;
		InventoryLists_mc.ItemsList.disableSelection = false;
		InventoryLists_mc.ItemsList.disableInput = false;
		InventoryLists_mc.CategoriesList.disableSelection = false;
		InventoryLists_mc.CategoriesList.disableInput = false;
	}

	function RestoreIndices()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("<================================ItemMenu RestoreIndices==================================" + "\n");
		if (DEBUG_LEVEL > 1)
			_global.skse.Log("ItemMenu RestoreIndices() argument[0] = " + arguments[0] + " size = " + arguments.length);
		
		if (arguments[0] != undefined && arguments[0] != -1 && arguments.length != 1) {
			InventoryLists_mc.CategoriesList.restoreSelectedEntry(arguments[0]);
			InventoryLists_mc.CategoriesList.UpdateList();
		} else {
			InventoryLists_mc.CategoriesList.restoreSelectedEntry(1); // ALL
		}
		
		var index;
		// Saved category indices
		for (index = 1; index < arguments.length && index < InventoryLists_mc.CategoriesList.entryList.length; index++) {
				InventoryLists_mc.CategoriesList.entryList[index - 1].savedItemIndex = arguments[index];
		}

		// Extra state information. Cleared after game restart.
		var bRestarted = arguments[index] == undefined;
		
		if (bRestarted) {
			// Display SKSE warning if necessary after restart
			if (_global.skse == undefined && skseWarningMsg != undefined) {
				skseWarningMsg.gotoAndStop("show");
			}			
		}
	_global.skse.Log("============================END ItemMenu RestoreIndices==================================>" + "\n");
		
	}

	function SaveIndices()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu SaveIndices()");
		var a = new Array();

		a.push(InventoryLists_mc.CategoriesList.selectedIndex);
                _global.skse.Log("saving category entry " + InventoryLists_mc.CategoriesList.selectedIndex);
		for (var i = 0; i < InventoryLists_mc.CategoriesList.entryList.length; i++) {
			a.push(InventoryLists_mc.CategoriesList.entryList[i].savedItemIndex);
		}
		
		// Restarted == false
		a.push(1);

		GameDelegate.call("SaveIndices",[a]);

		ResetElements();
	}
}