﻿import gfx.io.GameDelegate;

import skyui.InventoryColumnFormatter;
import skyui.InventoryDataFetcher;
import skyui.Translator;


class ContainerMenu extends ItemMenu
{
    static var DEBUG_LEVEL:Number = 1;
	static var NULL_HAND: Number = -1;
	static var RIGHT_HAND: Number = 0;
	static var LEFT_HAND: Number = 1;

	private var _bShowEquipButtonHelp:Boolean;
	private var _equipHand:Number;
	private var _equipHelpArt:Object;
	private var _defaultEquipArt:Object;
	
	var ContainerButtonArt:Object;
	var InventoryButtonArt:Object;
	var CategoryListIconArt:Array;
	
	var ColumnFormatter:InventoryColumnFormatter;
	var DataFetcher:InventoryDataFetcher;

	// ?
	var bPCControlsReady:Boolean = true;

	// API
	var bNPCMode:Boolean;


	function ContainerMenu()
	{
		super();
		ContainerButtonArt = [{PCArt:"E", XBoxArt:"360_A", PS3Art:"PS3_A"}, {PCArt:"R", XBoxArt:"360_X", PS3Art:"PS3_X"}, {PCArt:"F", XBoxArt:"360_Y", PS3Art:"PS3_Y"}, {PCArt:"Tab", XBoxArt:"360_B", PS3Art:"PS3_B"}];
		
		_defaultEquipArt = {PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A"};
		_equipHelpArt = {PCArt:"M1M2",XBoxArt:"360_LTRT",PS3Art:"PS3_LBRB"};
		
		bNPCMode = false;
		_bShowEquipButtonHelp = true;
		_equipHand = undefined;

		CategoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
		
		ColumnFormatter = new InventoryColumnFormatter();
		ColumnFormatter.maxTextLength = 80;
		
		DataFetcher = new InventoryDataFetcher();
	}

	function InitExtensions()
	{
		if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu InitExtensions()");
		super.InitExtensions(false);
		
		InventoryLists_mc.CategoriesList.setIconArt(CategoryListIconArt);
		
		InventoryLists_mc.ItemsList.entryClassName = "ItemsListEntryInv";
		InventoryLists_mc.ItemsList.columnFormatter = ColumnFormatter;
		InventoryLists_mc.ItemsList.dataFetcher = DataFetcher;
		InventoryLists_mc.ItemsList.setConfigSection("ItemList");
		
		GameDelegate.addCallBack("AttemptEquip",this,"AttemptEquip");
		GameDelegate.addCallBack("XButtonPress",this,"onXButtonPress");
        ItemCardFadeHolder_mc.StealTextInstance._visible = false;
		updateButtons();
        // Hide buttons that are not needed when initially opening menu.
		BottomBar_mc.SetButtonText("",0);
		BottomBar_mc.SetButtonText("",2);	

		InventoryLists_mc.TabBar.setIcons("take","give");
	}

	function ShowItemsList()
	{
		// Not necessary anymore. Now handled in onShowItemsList for consistency reasons.
		//InventoryLists_mc.showItemsList();
	}

	function handleInput(details, pathToFocus)
	{
		if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu handleInput() " + details.value);
		super.handleInput(details, pathToFocus);

		if (ShouldProcessItemsListInput(false)) {
			if (_platform == 0 && details.code == 16 && InventoryLists_mc.ItemsList.selectedIndex != -1) {
				_bShowEquipButtonHelp = details.value != "keyUp";
				updateButtons();
			}
		}

		return true;
	}

	// called when dropping items
	function onXButtonPress()
	{
        if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu onXButtonPress()");
		if (isViewingContainer() && ! bNPCMode) {
			GameDelegate.call("TakeAllItems",[]);
			return;
		}

		if (isViewingContainer()) {
			return;
		}

  			StartItemTransfer();
	}

	function UpdateItemCardInfo(a_updateObj:Object)
	{
        if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu UpdateItemCardInfo()");
		super.UpdateItemCardInfo(a_updateObj);

		updateButtons();

		if (a_updateObj.pickpocketChance != undefined) {
			ItemCardFadeHolder_mc.StealTextInstance._visible = true;
			ItemCardFadeHolder_mc.StealTextInstance.PercentTextInstance.html = true;
			ItemCardFadeHolder_mc.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + a_updateObj.pickpocketChance + "%</font>" + (isViewingContainer() ? Translator.translate("$ TO STEAL") : Translator.translate("$ TO PLACE"));
		} else {
		ItemCardFadeHolder_mc.StealTextInstance._visible = false;
	        }
	}

	function onItemHighlightChange(event)
	{
                if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu onItemHighlightChange()");
        	updateButtons();
		
		if (event.index == -1) {
			if (!isViewingContainer()) {
				BottomBar_mc.SetButtonText("",1);
			}
			BottomBar_mc.SetButtonText("",0);
			BottomBar_mc.SetButtonText("",2);		
		}

		super.onItemHighlightChange(event);
	}

	function onShowItemsList(event)
	{
                 if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu onShowItemsList()");
		         _global.skse.Log("selectedIndex = " + InventoryLists_mc.ItemsList._selectedIndex);
	         InventoryLists_mc.showItemsList();
	}

	// called when switching categories
	function onHideItemsList(event)
	{
		super.onHideItemsList(event);
		if (DEBUG_LEVEL > 0) _global.skse.Log("ContainerMenu onHideItemsList()");
		updateButtons();
		
		// Hide buttons that are not needed while items are not selected.
		if (!isViewingContainer())
			BottomBar_mc.SetButtonText("",1);
			
		BottomBar_mc.SetButtonText("",0);
		BottomBar_mc.SetButtonText("",2);	
		BottomBar_mc.UpdatePerItemInfo({type:InventoryDefines.ICT_NONE});
	}
	
	function hideButtons()
	{
		BottomBar_mc.SetButtonText("",0);
		BottomBar_mc.SetButtonText("",1);
		BottomBar_mc.SetButtonText("",2);
		BottomBar_mc.SetButtonText("",3);
	}

	function updateButtons()
	{
        if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu updateButtons()");
		
		BottomBar_mc.SetButtonsArt(ContainerButtonArt);
		
		if (InventoryLists_mc.currentState != InventoryLists.TRANSITIONING_TO_SHOW_PANEL && InventoryLists_mc.currentState != InventoryLists.SHOW_PANEL) {
			hideButtons();
			return;
		}
		/*
		  bShowEquipButtonHelp is only meant for PC
		  It's primary purpose is to inform players that M1/M2 can equip left and right weapons
		  
		  If Shift is pressed, show equip help art(M1M2) for Button 0
		*/
		BottomBar_mc.SetButtonArt(_bShowEquipButtonHelp ? _equipHelpArt : _defaultEquipArt,0);

		if (isViewingContainer()) {
			// Button 0
			BottomBar_mc.SetButtonText("$Take",0);
			// Button 1
			BottomBar_mc.SetButtonText(bNPCMode ? "" : "$Take All",1);
			// Button 2
			BottomBar_mc.SetButtonText("$Exit",3);
			
		} else {
			// Button 0
			BottomBar_mc.SetButtonText(InventoryDefines.GetEquipText(ItemCard_mc.itemInfo.type),0);
			// Button 1
			BottomBar_mc.SetButtonText(bNPCMode ? "$Give" : "$Store",1);
			// Button 2
			BottomBar_mc.SetButtonText(ItemCard_mc.itemInfo.favorite ? "$Unfavorite":"$Favorite",2);
			// Button 3
			BottomBar_mc.SetButtonText("$Exit",3);
		}	
	}

	function onMouseRotationFastClick(a_mouseButton:Number)
	{
        if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu onMouseRotationFastClick()");
		GameDelegate.call("CheckForMouseEquip",[a_mouseButton],this,"AttemptEquip");
	}

	function isViewingContainer()
	{
                if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu isViewingContainer()");
		return (InventoryLists_mc.CategoriesList.activeSegment == 0);
	}

	function onQuantityMenuSelect(event)
	{
        if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu onQuantityMenuSelect()");
		if (_equipHand != undefined) {
			GameDelegate.call("EquipItem",[_equipHand,event.amount]);
			_equipHand = undefined;
			return;
		}
			GameDelegate.call("ItemTransfer",[event.amount,isViewingContainer()]);
	}

	function AttemptEquip(a_slot:Number, a_bCheckOverList:Boolean)
	{
        if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu AttemptEquip()");
		var bCheckOverList = a_bCheckOverList == undefined ? true : a_bCheckOverList;

		if (ShouldProcessItemsListInput(bCheckOverList) && ConfirmSelectedEntry()) {
			if (_platform == 0) {
				if (!isViewingContainer() || _bShowEquipButtonHelp) {
					StartItemEquip(a_slot);
				} else {
					StartItemTransfer();
				}
			} else {
			StartItemEquip(a_slot);
		        }
	        }
	}

	function onItemSelect(event)
	{
        if (DEBUG_LEVEL > 0) skse.Log("ContainerMenu onItemSelect()");
		if (event.keyboardOrMouse != 0) {
			if (! isViewingContainer()) {
				StartItemEquip(ContainerMenu.NULL_HAND);
			} else {
			StartItemTransfer();
		        }
	        }
	}

	function StartItemTransfer()
	{
                if (DEBUG_LEVEL > 0) _global.skse.Log("ContainerMenu StartItemTransfer()");
		if (InventoryLists_mc.ItemsList.selectedEntry.enabled) {
		if (ItemCard_mc.itemInfo.weight == 0 && isViewingContainer()) {
			onQuantityMenuSelect({amount:InventoryLists_mc.ItemsList.selectedEntry.count});
			return;
		}

		if (InventoryLists_mc.ItemsList.selectedEntry.count <= InventoryDefines.QUANTITY_MENU_COUNT_LIMIT) {
			onQuantityMenuSelect({amount:1});
			return;
		}

			ItemCard_mc.ShowQuantityMenu(InventoryLists_mc.ItemsList.selectedEntry.count);
		}
		GameDelegate.call("DisabledItemSelect",[]);
	}

	function StartItemEquip(a_equipHand)
	{
        if (DEBUG_LEVEL > 0) _global.skse.Log("ContainerMenu StartItemEquip()");
		if (isViewingContainer()) {
			_equipHand = a_equipHand;
			StartItemTransfer();
			return;
		}

		GameDelegate.call("EquipItem",[a_equipHand]);
	}

	function onItemCardSubMenuAction(event)
	{
        if (DEBUG_LEVEL > 0) _global.skse.Log("ContainerMenu onItemCardSubMenuAction()");
		super.onItemCardSubMenuAction(event);
		
		if (event.menu == "quantity") {
				GameDelegate.call("QuantitySliderOpen",[event.opening]);
		}
	}

	function SetPlatform(a_platform:Number, a_bPS3Switch:Boolean)
	{
		super.SetPlatform(a_platform,a_bPS3Switch);
		if (DEBUG_LEVEL > 0) _global.skse.Log("ContainerMenu SetPlatform()");
		_platform = a_platform;
		_bShowEquipButtonHelp = a_platform != 0;
	}

}
