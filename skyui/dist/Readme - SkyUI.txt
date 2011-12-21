########################################################################################################################################
	_______ _     _ __   __ _     _ _____
	|______ |____/    \_/   |     |   |  
	______| |    \_    |    |_____| __|__
			
########################################################################################################################################

Team:			snakster, T3T, Kratos

Contributors:	ianpatt, gibbed, Gopher, Mardoxx, GreatClone

Version:		1.1

Download:		http://www.skyrimnexus.com/downloads/file.php?id=3863

########################################################################################################################################

The following mods/utilities are required for SkyUI:

* The Skyrim Script Extender (SKSE)
	http://skse.silverlock.org/

* The Nexus Mod Manager (NMM) is recommended for properly installing and setting up SkyUI.
	http://skyrimnexus.com/content/modmanager/
	
########################################################################################################################################


	1. Introduction

	2. Changelog

	3. Installation

	4. Troubleshooting

	5. Credits & Acknowledgements
	
	6. Contact
	
	7. Permissions
	

########################################################################################################################################



========================================================================================================================================
 1. Introduction
========================================================================================================================================

SkyUI is mod that aims to improve Skyrim's User Interface by making it easier to use with mouse and keyboard,
less wasteful of available screen space and nicer to look at.

We do all that while keeping true to the style of the original UI, so new and old components are integrated seamlessly.
It is not our goal to re-create the complete interface from scratch.
Instead we try to identify and change areas that need improvement, while leaving the things that are already good alone.

Further general objectives and design concepts are:

* Finding a good balance between 'dumbed down' and 'information overkill'.

* Easy installation and setup by providing a user-friendly installer through the Nexus Mod Manager.

* Great customization support by using a seperate configuration file.

* Blending features in as good as possible - players shouldn't feel reminded that they're using a mod.


Since improving the whole UI is a big undertaking, we release one menu at a time as we make progress.
The first menu we address is the Inventory. For a more detailed description, please see our mod description on SkyrimNexus.


========================================================================================================================================
 2. Changelog
========================================================================================================================================

------------------------------------------------------------
1.0:

[InventoryMenu]
- Initial release


========================================================================================================================================
 3. Installation
========================================================================================================================================

We recommend using the Nexus Mod Manager to install SkyUI. It easily lets you install and remove the mods, and you may even select the
icon theme in the installer.

Basically, there are three ways to install SkyUI:
- Let NMM download and install the archive for you (recommended).
- Download the archive manually and install it with NMM.
- Download and install the archive manually.

Pick one of them.

------------------------------------------------------------
 a) Automatic Download with NMM
------------------------------------------------------------

1.	Click the 'Download with manager' button on top of the file.

2.	SkyUI will appear in in NMM's Mods list once it's downloaded. Double-click the SkyUI entry to activate it.

3.	In the installer window, select a custom icon theme if you want to, then click Install.
	If you are prompted to overwrite anything, click Yes to All.

4.	Done!

OR

------------------------------------------------------------
 b) Manual Download with NMM
------------------------------------------------------------

1.	Start NMM and click on 'Mods'.

2.	In the left icon bar, click on 'Add Mod From File' and select the downloaded archive file.

3.	SkyUI will now appear in the list. Double-click to activate it.

4.	In the installer window, select a custom icon theme if you want to, then click Install.
	If you are prompted to overwrite anything, click 'Yes to All'.

5.	Done!

OR

------------------------------------------------------------
 c) Manual Installation without NMM
------------------------------------------------------------

1.	Locate the Data/ folder in your Skyrim installation directory.
	Typically it's found at Program Files/Steam/steamapps/common/skyrim/Data/.

2.	Extract the contents of the downloaded archive file to your Data/ folder.
	If you are prompted to overwrite anything, click Yes to All.

In case you want to use a custom icon theme:
3.	Locate the Data/SkyUI Extras/ folder. In there, pick a theme subfolder and copy
	'skyui_icons_cat.swf' and 'skyui_icons_inv.swf' to Data/Interface.

4.	Done!


========================================================================================================================================
 4. Troubleshooting
========================================================================================================================================

------------------------------------------------------------
Problem: There's a message on my screen, telling me that I'm missing the Skyrim Script Extender (SKSE). What do I have to do?

Solution: There are two things that can cause this:
	1)	You didn't install the Skyrim Script Extender (or you installed it incorrectly).
		Get it from http://skse.silverlock.org/ and follow the instructions there.
		
	2)	Everything was fine before, then Skyrim was patched to a new version and the message started appearing.
		This is because each new patch also requires an update of SKSE. So just you'll just have to wait until that is released, then
		get the new version and everything should be back to normal.

------------------------------------------------------------
Problem: There are dollar signs ($) in front of all words in the main menu (and in lots of other places, too)!

Solution: This happens if you accidently removed Data/Interface/Translate_ENGLISH.txt. The downloaded SkyUI archive contains an
	original version of that file in SkyUI Extras/. So just copy it from there back to Data/Interface/.
		
------------------------------------------------------------
Problem: I changed something in skyui.cfg, now it's not working anymore.

Solution: If you made a mistake in the config, SkyUI may stop working. In this case, just revert back to the original config from the
	downloaded SkyUI archive.

------------------------------------------------------------	
Problem: The Nexus Mod Manager crashes when trying to install SkyUI.

Solution: This seems to be a common issue with NMM at the moment. Restart NMM and try again, it should work then.


========================================================================================================================================
 5. Credits & Acknowledgements
========================================================================================================================================

Besides the SkyUI team itself, there are other people as well who helped significantly to make this mod a reality.
In the following they are listed by name, including a list of their contributions.

ianpatt:
	Added lots of new functions to the Skyrim Script Extender, that greatly helped us during development and enabled new features that
	would otherwise be impossible.

Gibbed:
	Created the 'gibbed interface extensions' SKSE plugin, which makes more game data available for display in the inventory.

Mardoxx:
	Did a lot of groundwork by reconstructing the decompiled interface files, so we can customize them later.

GreatClone:
	Created an amazing set of alternative category icons.
	
Ismelda:
	Provided configs for very high resolutions used with multi-monitor setups.


Thanks to all the testers, who helped a great deal with improving the overall quality of this mod:
	ToJKa, HellKnight, xporc, MadCat221, Ismelda, Gribbles, freesta, Cartrodus, TheCastle (in random order)

Last but not least, thanks to the whole SKSE team, because without their Script Extender creating this mod wouldn't have been possible.


========================================================================================================================================
 6. Contact
========================================================================================================================================

For direct contact, send a PM to schlangster at

	http://www.skyrimnexus.com/
		or
	http://forums.bethsoft.com/

If you need help, please leave a comment on our Nexus page instead of contacting me directly.

	
========================================================================================================================================
 7. Permissions
========================================================================================================================================	

Some assets in SkyUI belong to other authors.
You will need to seek permission from these authors before you can use their assets.

You are not allowed to upload this file to other sites unless given permission by me to do so.
You are not allowed to convert this file to work on other games.
 
You must get permission from me before you are allowed to modify my files for bug fixes and improvements.
You must get permission from me before you are allowed to use any of the assets in this file.
