﻿import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import skyui.Config;

/* This class is changed only conservatively for now since it's reused by several other menus later. */

class ItemMenu extends MovieClip
{
	private var _bItemCardFadedIn:Boolean;
	
	var InventoryLists_mc:MovieClip;
	var ItemCardFadeHolder_mc:MovieClip;
	var ItemCard_mc:MovieClip;
	var BottomBar_mc:MovieClip;
	var bFadedIn:Boolean;
	var ExitMenuRect:MovieClip;
	var MouseRotationRect:MovieClip;
	var iPlatform:Number;

	var skseWarningMsg:MovieClip;
	
	private var _config;
	static var DEBUG_LEVEL = 1;

	function ItemMenu()
	{
		super();
		InventoryLists_mc = InventoryLists_mc;
		ItemCard_mc = ItemCardFadeHolder_mc.ItemCard_mc;
		BottomBar_mc = BottomBar_mc;
		bFadedIn = true;
		Mouse.addListener(this);
		Config.instance.addEventListener("configLoad",this,"onConfigLoad");
		
		_bItemCardFadedIn = false;
	}

	function InitExtensions(abPlayBladeSound)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu InitExtensions()");
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
		InventoryLists_mc.ShowCategoriesList(abPlayBladeSound);
		ItemCard_mc._visible = false;
		BottomBar_mc.HideButtons();

		ExitMenuRect.onMouseDown = function()
		{
			if (_parent.bFadedIn == true && Mouse.getTopMostEntity() == this)
			{
				_parent.onExitMenuRectClick();
			}
		};
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
		if (scaleMult < 1.0)
		{
			itemCardContainer._width *= scaleMult;
			itemCardContainer._height *= scaleMult;
			itemiconPosition.scale *= scaleMult;
		}

		if (itemcardPosition.align == "left")
		{
			itemCardContainer._x = panelEdge + leftEdge + itemcardPosition.xOffset;
		}
		else if (itemcardPosition.align == "right")
		{
			itemCardContainer._x = rightEdge - itemCardContainer._width + itemcardPosition.xOffset;
		}
		else
		{
			itemCardContainer._x = panelEdge + itemcardPosition.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - panelEdge - itemCardContainer._width) / 2;
		}
		itemCardContainer._y = itemCardContainer._y + itemcardPosition.yOffset;

		MovieClip(ExitMenuRect).Lock("TL");
		ExitMenuRect._x = ExitMenuRect._x - Stage.safeRect.x;
		ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;


		var iconX = GlobalFunc.Lerp(0, 128, Stage.visibleRect.x, (Stage.visibleRect.x + Stage.visibleRect.width), (itemCardContainer._x + (itemCardContainer._width / 2)), 0);
		iconX = -(iconX - 64);
		skse.SetINISetting("fInventory3DItemPosScaleWide:Interface",(itemiconPosition.scale));
		skse.SetINISetting("fInventory3DItemPosXWide:Interface",(iconX + itemiconPosition.xOffset));
		//skse.SetINISetting("fInventory3DItemPosYWide:Interface", -500);
		skse.SetINISetting("fInventory3DItemPosZWide:Interface",(12 + itemiconPosition.yOffset));

		skse.SetINISetting("fInventory3DItemPosScale:Interface",(itemiconPosition.scale));
		skse.SetINISetting("fInventory3DItemPosX:Interface",(iconX + itemiconPosition.xOffset));
		//skse.SetINISetting("fInventory3DItemPosY:Interface", -500);
		skse.SetINISetting("fInventory3DItemPosZ:Interface",(16 + itemiconPosition.yOffset));

		skse.SetINISetting("fMagic3DItemPosScaleWide:Interface",(itemiconPosition.scale));
		skse.SetINISetting("fMagic3DItemPosXWide:Interface",(iconX + itemiconPosition.xOffset));
		//skse.SetINISetting("fMagic3DItemPosYWide:Interface",-500);
		skse.SetINISetting("fMagic3DItemPosZWide:Interface",(12 + itemiconPosition.yOffset));

		skse.SetINISetting("fMagic3DItemPosScale:Interface",(itemiconPosition.scale));
		skse.SetINISetting("fMagic3DItemPosX:Interface",(iconX + itemiconPosition.xOffset));
		//skse.SetINISetting("fMagic3DItemPosY:Interface",-500);
		skse.SetINISetting("fMagic3DItemPosZ:Interface",(16 + itemiconPosition.yOffset));

		if (MouseRotationRect != undefined)
		{
			MovieClip(MouseRotationRect).Lock("T");
			MouseRotationRect._x = ItemCard_mc._parent._x;
			MouseRotationRect._width = ItemCard_mc._parent._width;
			MouseRotationRect._height = 0.550000 * Stage.visibleRect.height;
		}
		
		skseWarningMsg.Lock("TR");
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu SetPlatform()");
		iPlatform = aiPlatform;
		InventoryLists_mc.SetPlatform(aiPlatform,abPS3Switch);
		ItemCard_mc.SetPlatform(aiPlatform,abPS3Switch);
		BottomBar_mc.SetPlatform(aiPlatform,abPS3Switch);
	}

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
		if (bFadedIn)
		{
			if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1)))
			{
				if (GlobalFunc.IsKeyPressed(details) && details.navEquivalent == gfx.ui.NavigationCode.TAB)
				{
					GameDelegate.call("CloseMenu",[]);
				}
			}
		}

		return (true);
	}

	function onMouseWheel(delta)
	{
        if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu onMouseWheel()");
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
		{
			if (e == MouseRotationRect && ShouldProcessItemsListInput(false) || !bFadedIn && delta == -1)
			{
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
        if (DEBUG_LEVEL > 0)
		{
			_global.skse.Log("ItemMenu onItemHighlightChange()");
			for (var key:String in event)
			{
				_global.skse.Log(key + " : " + event[key]);
			}
		}
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

	// Barter menu calls this
	// Might event might still be sent from somewhere else, so keep this for now.
	function onShowItemsList(event)
	{
		if (DEBUG_LEVEL > 0)
		{
			_global.skse.Log("ItemMenu onShowItemsList()");
			for (var key:String in event)
			{
				_global.skse.Log(key + " : " + event[key]);
			}
		}
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
		if (event.entry.enabled)
		{
			if (event.entry.count > InventoryDefines.QUANTITY_MENU_COUNT_LIMIT)
			{
				ItemCard_mc.ShowQuantityMenu(event.entry.count);
			}
			else
			{
				onQuantityMenuSelect({amount:1});
			}
		}
		else
		{
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
		if (event.opening == true)
		{
			InventoryLists_mc.ItemsList.disableSelection = true;
			InventoryLists_mc.ItemsList.disableInput = true;
			InventoryLists_mc.CategoriesList.disableSelection = true;
			InventoryLists_mc.CategoriesList.disableInput = true;
		}
		else if (event.opening == false)
		{
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

		if (process && iPlatform == 0 && abCheckIfOverRect)
		{
			var e = Mouse.getTopMostEntity();
			var found = false;
			while (!found && e && e != undefined)
			{
				if (e == InventoryLists_mc.ItemsList)
				{
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
		if (ShouldProcessItemsListInput(false))
		{
			onItemSelect({entry:InventoryLists_mc.ItemsList.selectedEntry, keyboardOrMouse:0});
		}
	}

	function ToggleMenuFade()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu ToggleMenuFade()");
		if (bFadedIn)
		{
			_parent.gotoAndPlay("fadeOut");
			bFadedIn = false;
			InventoryLists_mc.ItemsList.disableSelection = true;
			InventoryLists_mc.ItemsList.disableInput = true;
			InventoryLists_mc.CategoriesList.disableSelection = true;
			InventoryLists_mc.CategoriesList.disableInput = true;
		}
		else
		{
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
			_global.skse.Log("ItemMenu RestoreIndices()");
		if (DEBUG_LEVEL > 1)
			_global.skse.Log("ItemMenu RestoreIndices() argument[0] = " + arguments[0]);
		if (arguments[0] != undefined && arguments[0] != -1)
		{
			InventoryLists_mc.CategoriesList.restoreSelectedEntry(arguments[0]);
		}
		else
		{
			// ALL
			InventoryLists_mc.CategoriesList.restoreSelectedEntry(1);
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
			if (_global.skse == undefined) {
				skseWarningMsg.gotoAndStop("show");
			}			
		}
		
		
		InventoryLists_mc.CategoriesList.UpdateList();
	}

	function SaveIndices()
	{
		if (DEBUG_LEVEL > 0)
			_global.skse.Log("ItemMenu SaveIndices()");
		var a = new Array();

		a.push(InventoryLists_mc.CategoriesList.selectedIndex);
                _global.skse.Log("saving category entry " + InventoryLists_mc.CategoriesList.selectedIndex);
		for (var i = 0; i < InventoryLists_mc.CategoriesList.entryList.length; i++)
		{
			a.push(InventoryLists_mc.CategoriesList.entryList[i].savedItemIndex);
		}
		
		// Restarted == false
		a.push(1);
		
		GameDelegate.call("SaveIndices",[a]);

		// TODO: Gets called when the menu closes, so I put that icon reset here. Still would be nice to find something more appropriate.

		// Restore to defaults for enchanting etc
		/*skse.SetINISetting("fInventory3DItemPosScaleWide:Interface",1.5000);
		skse.SetINISetting("fInventory3DItemPosXWide:Interface",-22.0000);
		skse.SetINISetting("fInventory3DItemPosZWide:Interface",12.0000);

		skse.SetINISetting("fInventory3DItemPosScale:Interface",1.8700);
		skse.SetINISetting("fInventory3DItemPosX:Interface",-29.0000);
		skse.SetINISetting("fInventory3DItemPosZ:Interface",16.0000);*/
	}
}