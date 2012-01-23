﻿import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;

import Shared.GlobalFunc;

import skyui.CategoryList;
import skyui.FormattedItemList;
import skyui.ItemTypeFilter;
import skyui.ItemNameFilter;
import skyui.ItemSortingFilter;
import skyui.SortedListHeader;
import skyui.SearchWidget;
import skyui.TabBar;
import skyui.Config;
import skyui.Util;


class InventoryLists extends MovieClip
{
	static var HIDE_PANEL = 0;
	static var SHOW_PANEL = 1;
	static var TRANSITIONING_TO_HIDE_PANEL = 2;
	static var TRANSITIONING_TO_SHOW_PANEL = 3;

	private var _config:Config;

	private var _CategoriesList:CategoryList;
	private var _CategoryLabel:MovieClip;
	private var _ItemsList:FormattedItemList;
	private var _SearchWidget:SearchWidget;
	private var _TabBar:TabBar;

	private var _platform:Number;
	private var _currentState:Number;

	private var _typeFilter:ItemTypeFilter;
	private var _nameFilter:ItemNameFilter;
	private var _sortFilter:ItemSortingFilter;

	private var _currCategoryIndex:Number;

	private var _searchKey:Number;
	private var _tabToggleKey:Number;
	private var _allString:String;

	// Children
	var panelContainer:MovieClip;

	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;


	function InventoryLists()
	{
		super();

		Util.addArrayFunctions();

		_CategoriesList = panelContainer.categoriesList;
		_CategoryLabel = panelContainer.CategoryLabel;
		_ItemsList = panelContainer.itemsList;
		_SearchWidget = panelContainer.searchWidget;
		_TabBar = panelContainer.tabBar;

		EventDispatcher.initialize(this);

		gotoAndStop("NoPanels");

		GameDelegate.addCallBack("SetCategoriesList",this,"SetCategoriesList");
		GameDelegate.addCallBack("InvalidateListData",this,"InvalidateListData");

		_typeFilter = new ItemTypeFilter();
		_nameFilter = new ItemNameFilter();
		_sortFilter = new ItemSortingFilter();

		_searchKey = undefined;
		_tabToggleKey = undefined;

		Config.instance.addEventListener("configLoad",this,"onConfigLoad");
	}

	function onLoad()
	{
		_ItemsList.addFilter(_typeFilter);
		_ItemsList.addFilter(_nameFilter);
		_ItemsList.addFilter(_sortFilter);

		_typeFilter.addEventListener("filterChange",_ItemsList,"onFilterChange");
		_nameFilter.addEventListener("filterChange",_ItemsList,"onFilterChange");
		_sortFilter.addEventListener("filterChange",_ItemsList,"onFilterChange");

		_CategoriesList.addEventListener("itemPress",this,"onCategoriesItemPress");
		_CategoriesList.addEventListener("listPress",this,"onCategoriesListPress");
		_CategoriesList.addEventListener("listMovedUp",this,"onCategoriesListMoveUp");
		_CategoriesList.addEventListener("listMovedDown",this,"onCategoriesListMoveDown");
		_CategoriesList.addEventListener("selectionChange",this,"onCategoriesListMouseSelectionChange");

		_ItemsList.disableInput = false;

		_ItemsList.addEventListener("listMovedUp",this,"onItemsListMoveUp");
		_ItemsList.addEventListener("listMovedDown",this,"onItemsListMoveDown");
		_ItemsList.addEventListener("selectionChange",this,"onItemsListMouseSelectionChange");
		_ItemsList.addEventListener("sortChange",this,"onSortChange");

		_SearchWidget.addEventListener("inputStart",this,"onSearchInputStart");
		_SearchWidget.addEventListener("inputEnd",this,"onSearchInputEnd");
		_SearchWidget.addEventListener("inputChange",this,"onSearchInputChange");
		
		if (_TabBar != undefined) {
			_TabBar.addEventListener("tabPress",this,"onTabPress");
		}
	}

	function onConfigLoad(event)
	{
		_config = event.config;
		_searchKey = _config.Input.hotkey.search;
		_tabToggleKey = _config.Input.hotkey.tabToggle;
	}

	function SetPlatform(a_platform:Number, a_bPS3Switch:Boolean)
	{
		_platform = a_platform;

		_CategoriesList.setPlatform(a_platform,a_bPS3Switch);
		_ItemsList.setPlatform(a_platform,a_bPS3Switch);
	}

	function handleInput(details, pathToFocus)
	{
		var bCaught = false;

		if (_currentState == SHOW_PANEL) {
			if (GlobalFunc.IsKeyPressed(details)) {
				
				if (details.navEquivalent == NavigationCode.LEFT) {
					_CategoriesList.moveSelectionLeft();
					bCaught = true;

				} else if (details.navEquivalent == NavigationCode.RIGHT) {
					_CategoriesList.moveSelectionRight();
					bCaught = true;

				// Search hotkey (default space)
				} else if (details.code == _searchKey) {
					bCaught = true;
					_SearchWidget.startInput();
					
				// Toggle tab (default ALT)
				} else if (_TabBar != undefined && (details.code == _tabToggleKey || (details.navEquivalent == NavigationCode.GAMEPAD_BACK && details.code != 8))) {
					
					bCaught = true;
					_TabBar.tabToggle();
				}
			}
			if (!bCaught) {
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
			}
		}
		return bCaught;
	}

	function getContentBounds():Array
	{
		var lb = panelContainer.ListBackground;
		return [lb._x, lb._y, lb._width, lb._height];
	}

	function get CategoriesList()
	{
		return _CategoriesList;
	}

	function get ItemsList()
	{
		return _ItemsList;
	}
	
	function get TabBar()
	{
		return _TabBar;
	}

	function get currentState()
	{
		return _currentState;
	}

	function set currentState(a_newState)
	{
		if (a_newState == SHOW_PANEL) {
			FocusHandler.instance.setFocus(_ItemsList,0);
		}

		_currentState = a_newState;
	}

	function RestoreCategoryIndex()
	{
		_CategoriesList.selectedIndex = _currCategoryIndex;
	}

	function ShowCategoriesList(a_bPlayBladeSound:Boolean)
	{
		_currentState = TRANSITIONING_TO_SHOW_PANEL;
		gotoAndPlay("PanelShow");

		dispatchEvent({type:"categoryChange", index:_CategoriesList.selectedIndex});

		if (a_bPlayBladeSound != false) {
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		}
	}

	function HideCategoriesList()
	{
		_currentState = TRANSITIONING_TO_HIDE_PANEL;
		gotoAndPlay("PanelHide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}

	function showItemsList()
	{
		_currCategoryIndex = _CategoriesList.selectedIndex;
		// set category label
		_CategoryLabel.textField.SetText(_CategoriesList.selectedEntry.text);
		
		if (_CategoriesList.selectedEntry != undefined) {
			_typeFilter.changeFilterFlag(_CategoriesList.selectedEntry.flag, true);
			_ItemsList.savedScrollPosition = _CategoriesList.selectedEntry.savedScrollPosition;
			_ItemsList.changeFilterFlag(_CategoriesList.selectedEntry.flag);
			if (_CategoriesList.selectedEntry.savedItemIndex != -1)
				_ItemsList.doSetSelectedIndex(_CategoriesList.selectedEntry.savedItemIndex);
		}
		dispatchEvent({type:"itemHighlightChange", index:_ItemsList.selectedIndex});
		
		_ItemsList.disableInput = false;
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	// Not needed anymore, items list always visible
	function hideItemsList()
	{
		/*
		_currentState = TRANSITIONING_TO_ONE_PANEL;
		dispatchEvent({type:"hideItemsList", index:_ItemsList.selectedIndex});
		_ItemsList.selectedIndex = -1;
		gotoAndPlay("Panel2Hide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
		_ItemsList.disableInput = true;
		*/
	}

	function onCategoriesItemPress()
	{
		showItemsList();
	}

	function onCategoriesListPress()
	{
	}

	function onTabPress(event)
	{
		if (_CategoriesList.disableSelection || _CategoriesList.disableInput || _ItemsList.disableSelection || _ItemsList.disableInput) {
			return;
		}
		
		if (event.index == TabBar.LEFT_TAB) {
			_TabBar.activeTab = TabBar.LEFT_TAB;
			_CategoriesList.activeSegment = CategoryList.LEFT_SEGMENT;
		} else if (event.index == TabBar.RIGHT_TAB) {
			_TabBar.activeTab = TabBar.RIGHT_TAB;
			_CategoriesList.activeSegment = CategoryList.RIGHT_SEGMENT;
		}
		
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		showItemsList();
	}

	function onCategoriesListMoveUp(event)
	{
		doCategorySelectionChange(event);
	}

	function onCategoriesListMoveDown(event)
	{
		doCategorySelectionChange(event);
	}

	function onCategoriesListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0) {
			doCategorySelectionChange(event);
		}
	}

	function onItemsListMoveUp(event)
	{
		this.doItemsSelectionChange(event);
	}

	function onItemsListMoveDown(event)
	{
		this.doItemsSelectionChange(event);
	}

	function onItemsListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0) {
			doItemsSelectionChange(event);
		}
	}

	function doCategorySelectionChange(event)
	{
		// save current category info before changing
		if (_CategoriesList.entryList[_currCategoryIndex] != undefined) {
			if (_ItemsList.scrollPosition != undefined)
				_CategoriesList.entryList[_currCategoryIndex].savedScrollPosition = _ItemsList.scrollPosition;
			_CategoriesList.entryList[_currCategoryIndex].savedItemIndex = _ItemsList.selectedIndex;
		}		

		dispatchEvent({type:"categoryChange", index:event.index});
	}

	function doItemsSelectionChange(event)
	{
		dispatchEvent({type:"itemHighlightChange", index:event.index});

		if (event.index != -1) {
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
		}
	}

	function onSortChange(event)
	{
		if (event.pressed) {
			_ItemsList.savedScrollPosition = 0;
			_ItemsList.scrollPosition = 0;
			// reset category saved scroll positions
			for (var i = 0; i < _CategoriesList.entryList.length; i++) {
				_CategoriesList.entryList[i].savedScrollPosition = 0;
			}
		}
		// reset scroll position to top when sorting and unselect item
		if (_ItemsList.selectedIndex != -1)
		{
			_ItemsList.selectedEntry = undefined;
			_ItemsList.selectedIndex = -1;
			dispatchEvent({type:"itemHighlightChange", index:-1});
		}
		_sortFilter.setSortBy(event.attributes, event.options);
	}

	function onSearchInputStart(event)
	{
		_CategoriesList.disableSelection = true;
		_ItemsList.disableInput = true;
		_nameFilter.filterText = "";
	}

	function onSearchInputChange(event)
	{
		_nameFilter.filterText = event.data;
	}

	function onSearchInputEnd(event)
	{
		_CategoriesList.disableSelection = false;
		_ItemsList.disableInput = false;
		_nameFilter.filterText = event.data;
	}

	// API - Called to initially set the category list
	function SetCategoriesList()
	{
		var textOffset = 0;
		var flagOffset = 1;
		var bDontHideOffset = 2;
		var len = 3;

		_CategoriesList.clearList();

		for (var i = 0, index = 0; i < arguments.length; i = i + len, index++) {
			var entry = {text:arguments[i + textOffset], flag:arguments[i + flagOffset], bDontHide:arguments[i + bDontHideOffset], savedItemIndex:-1, savedScrollPosition:0, filterFlag:arguments[i + bDontHideOffset] == true ? (1) : (0)};
			_CategoriesList.entryList.push(entry);

			if (entry.flag == 0) {
				_CategoriesList.dividerIndex = index;
			}
		}
		
		// Initialize tabbar labels and replace text of segment heads (name -> ALL)
		if (_TabBar != undefined) {
			if (_CategoriesList.dividerIndex != -1) {
				_TabBar.setLabelText(_CategoriesList.entryList[0].text, _CategoriesList.entryList[_CategoriesList.dividerIndex + 1].text);
				_CategoriesList.entryList[0].text = _CategoriesList.entryList[_CategoriesList.dividerIndex + 1].text = "$ALL";
			}
			
			// Restore 0 as default index for tabbed lists
			_CategoriesList.selectedIndex = 0;
		}

		_CategoriesList.InvalidateData();
	}

	// API - Called whenever the underlying entryList data is updated (using an item, equipping etc.)
	function InvalidateListData()
	{
		var flag = _CategoriesList.selectedEntry.flag;

		for (var i = 0; i < _CategoriesList.entryList.length; i++) {
			_CategoriesList.entryList[i].filterFlag = _CategoriesList.entryList[i].bDontHide ? 1 : 0;
		}

		// Set filter flag = 1 for non-empty categories with bDontHideOffset=false
		_ItemsList.InvalidateData();
		for (var i = 0; i < _ItemsList.entryList.length; i++) {
			for (var j = 0; j < _CategoriesList.entryList.length; ++j) {
				if (_CategoriesList.entryList[j].filterFlag != 0) {
					continue;
				}

				if (_ItemsList.entryList[i].filterFlag & _CategoriesList.entryList[j].flag) {
					_CategoriesList.entryList[j].filterFlag = 1;
				}
			}
		}

		_CategoriesList.UpdateList();

		if (flag != _CategoriesList.selectedEntry.flag) {
			// Triggers an update if filter flag changed
			_typeFilter.itemFilter = _CategoriesList.selectedEntry.flag;
			dispatchEvent({type:"categoryChange", index:_CategoriesList.selectedIndex});
		}
		
		// This is called when an ItemCard list closes(ex. ShowSoulGemList) to refresh ItemCard data    
		if (_ItemsList.selectedIndex == -1) {
			dispatchEvent({type:"showItemsList", index: -1});
		} else {
			dispatchEvent({type:"itemHighlightChange", index:_ItemsList.selectedIndex});
		}
	}
}