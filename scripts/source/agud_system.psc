Scriptname AGUD_System extends ReferenceAlias
{All Geared Up Derivative - Adds support for displaying unequipped favorited and/or equipped items.}
;AGUv2.1.1 was refactored into AllGUD by Brian David

;############
;Known Issues
;############
;/	Bug: Equipping a favorited one-hand weapon in the left hand with 2 or more copies will attach a RH model to the Left-Hand object.
	Replicate: Obtain 2 copies of a 1H Weapon that has a sheathe in the vanilla game(aka not-staff), favorite it, equip in the LH
		Equipping without favoriting will not cause the RH model to appear.
	Cause:	Unknown, bug is present in original mod as well.
	...Dual-wield sheathes were not meant to be. The gates to Oblivion have been opened. The end of Tamriel is upon us.
	Notes:	Is triggered on equipping the slot tied to the weapon. BUT is unrelated to the model that slot is using. assigning a null string to the modelpath still resulted in the 1stPerson model appearing.
	Fix:	1. Reloading
	That's it, avoid dual-wielding an object you have multiple copies of.
/;

;############
;Fixed Issues
;############
;/	Bug:	RH weapons using the wrong models (using the armor model instead of the hand item model)
	Cause: Skyrim native equip function is my best guess
		The weapon model uses whatever slot is occupying the corresponding skeleton node first, rather than the weapon slot
		What this means is, if you have a weapon model in an armor slot, let's say WeaponBack for a 2h weapon
		Then the handmodel will use the ARMOR slot, not the WEAPON.
		Therefore, when the ARMOR slot is unequipped, the model in the hand will disappear (become invisible)
		while the WEAPON model will remain sheathed
		This will be fixed on a reload, but more immersive solutions are available
		PlayerRef.QueueNiNodeUpdate() DOES NOT WORK. It doesn't list Weapon in the documentation as something that gets refreshed.
	Proposed Fixes:
		Method Not-Really-A-Solution-But-Doesn't-Involve-More-Work)	Don't unequip the armor at all, results in duplicate weapon when weapon is drawn, but no other problems
		Method A)	Unequip the relevent armor before the weapon is equipped
			Utilize a different set of hotkeys that allow time to unequip the armor slot BEFORE the weapon ever enters the hand.
				Hotkeys have a number of features iLoopIndex would have to replicate
				And integrating SkyUI's hotkeys wouldn't work with Categorized Favorites Menu, which iLoopIndex prefer over SkyUI's favorites menu
		Method B)	Use a different skeleton node
			1. Add a new skeleton node with a label specifically for weapon models as armors
			2. Duplicate weapon nifs(and append their name in a pattern, such as TestGreatSwordArmor.nif) and assign them to use the new skeleton node
			3. assign the model paths in THIS function to use the nifs that have the renamed style
			Cons: new mesh for every weapon? Talos save me...
/;

;/
	Bug:	RH Scabbards remain on actors after unequipping the armor slot
	Cause: Native skyrim function
	Fix: rename the "Scb" Block of meshes to anything other than "Scb"
/;
;/	Bug:	Ranged weapons crash to desktop when assigned as armor
	Cause: Skinned armor doesn't work
/;
;####################################################################################################################################################
;Imported classes
;####################################################################################################################################################
	Import Debug
	
;####################################################################################################################################################
;Properties
;####################################################################################################################################################
	;MCM-Controls
	Bool Property bAllGUDMaintenance = True Auto
	
	;MCM-Configurable Hotkeys
	Int Property iHKeyPWeapon = -1 Auto
	Int Property iHKeyPItem = -1 Auto
	Int Property iHKeyNPCItem = -1 Auto
	Int Property iHKeyNPCWeapon = -1 Auto
	
	;Display Settings
	Bool Property bDisplayPWeapon = True Auto
	Bool Property bReAlignNodes = True Auto
	Bool Property bReScaleNodes = True Auto
	Bool Property bDisplayPMisc = True Auto
	Bool Property bRemoveMiscItemsWithoutArmor = False Auto
	Bool Property bRemoveWeaponsWithoutArmor = False Auto
	;Shield Display Options
	Bool Property bShieldAccommodateBackpack = True Auto
	Bool Property bShieldAccommodateCloak = True Auto
	Bool Property bShieldHide = False Auto	;Betcha 0% of users use this option
	Bool Property bShieldOnArm = False Auto
	
	Keyword Property kKYWDDisplayArmor Auto
	FormList Property kFLSTBannedWeapons Auto
	Formlist Property kFLSTBannedKeywords Auto
	;Visualized inventory
	;List of items that will trigger the display model
	FormList Property kFLSTBackpacks Auto
	FormList Property kFLSTCoins Auto
	FormList Property kFLSTIngredients Auto
	FormList Property kFLSTPotionsHealth Auto
	FormList Property kFLSTPotionsMagicka Auto
	FormList Property kFLSTPotionsStamina Auto
	FormList Property kFLSTScrolls Auto
	FormList Property kFLSTTorches Auto
	FormList Property kFLSTLutes Auto
	FormList Property kFLSTFlutes Auto
	FormList Property kFLSTElderScrolls Auto
	FormList Property kFLSTWhitePhials Auto

	;List of relevant potion effects!
	FormList Property kFLSTRestoreHealth Auto
	FormList Property kFLSTRestoreMagicka Auto
	FormList Property kFLSTRestoreStamina Auto
	
	;Spells for applying magic effects that display the art objects with the models for the misc objects.
	Spell Property kSPELPlayerItems Auto
	
	;NPC-visualization-related properties
	GlobalVariable Property gvbDisplayNPCWeapons Auto
	GlobalVariable Property gvbDisplayNPCItems Auto
	
	Spell Property kSPELAllGUDCloak Auto
	Armor Property kAllGUDNPCWeaponRight Auto
	Armor Property kAllGUDNPCWeaponLeft Auto
	Armor Property kAllGUDNPCShield Auto
	
;	Quest Property AGUDMCM  Auto		;Use this line when opening Property list in CK, and comment out MCM functions before compiling.
	AGUD_MCM Property AGUDMCM  Auto	;Use this line for actual builds
	
;####################################################################################################################################################
;Variables
;####################################################################################################################################################
	Float fVersion
	
	;Slot arrays
	Armor[] Property kSlotVisual Auto ;Armors used to display items on the player character, defined in the .esp
	Armor[] kSlotVisualDisabled ;Time-out for visual slots
	Form[] kSlotItem ;Forms of items displayed in the different slots
	Form[] kSlotItemLocked ;Forms of items locked through the MCM
	String[] sSlotModel ;Model path for restoring from a session
	String[] sSlotLockedModel ;Model of locked-items
	;Bool[] bSlotAlternateTextures ;NOPE, setting this up would be impossible. Any alt texture weapons/shields are getting a seperate plugin patch.
	Bool[] bSlotEquipped ;If the slot should be in an equipped or unequipped state on update
	Bool[] bSlotUpdateFlagged ;If the slot was recently equipped or unequipped, set after bSlotEquipped
	Bool[] bSlotLocked ;Restores sSlotLockedModel on unequip, set in the MCM menu
	Bool[] bSlotHiddenInFirstPerson

	Int[] iSlotMasks ;The slotmask each item type is assigned
	Int[] iSlotMaskIndex ;List of SlotMasks that aren't claimed by vanilla equipment. Popular slots for other mods have been noted
	Int[] iSlotMaskIndexDefaults ;Defaults for the above, can be changed via json file.
	
	;Player-related
	Actor PlayerRef
	Race kPlayerRace
	Bool bPlayerFemale
	
	;Int iSlotMaskTail = 0x00000400	;Adjust shield position if wornForm in tail-slot matches wornForm in cloak-slot
	Int iSlotMaskCloak = 0x00010000	;Adjust shield position if wornForm in tail-slot matches wornForm in cloak-slot
	Bool bWearingCloak = False
	Int iSlotMaskBackpack = 0x00020000
	Bool bWearingBackpack = False
	Bool bWearingBackItem = False
	Int iSlotMaskTorso = 0x00000004
	
	;XPMSE Restyle variables
	Bool bTwoHMeleeIsGreatsword
	Bool bTwoHRangeIsBow
	Bool bXPMSEInstalled
	Bool bECEInstalled
	String[] sWeaponTargetNodes
	String[] sWeaponDefaultTargetNodes
	String[] sWeaponDefaultNodes
	Float[] fWeaponNodeScale
	Int[] iXPMSEWeaponTypes
	String[] sXPMSEStyleKeys
	String[] sXPMSEDagger
	String[] sXPMSESword
	String[] sXPMSEAxe
	String[] sXPMSEMace
	String[] sXPMSEGreatsword
	String[] sXPMSEPolearm
	String[] sXPMSEBow
	String[] sXPMSECrossBow
	
	;Other Compatibility
	
	;Hotkeys
	Int iHotkeyFavorites ;for registering in inventory

	;States
	Bool bInventoryProcessed = False ;For installing mid-playthrough
	Bool bWeaponDrawn = False ;Whether or not weapons are drawn
	Bool bUpdateFavoritesList = False ;True when the player has (un)favorited one or more items

	Bool bProcessingUpdate = False ;True while UpdateSlots() is running
	Bool bUpdateQueued = False ;True when items are equipped/unequipped/unfavorited/removed
	Bool bProcessingHandUpdate = False
	Bool bHandUpdateQueued = False

	;Items in slots and items currently equipped in the player's hands
	Form kLeftHand ;Form of item currently equipped in the player's Left hand
	Int iSlotLeftHand = -1
	String sLeftHandDrawn = ""
	String sLeftHandSheathed = ""
	Int iSlotMaskLeftHand = 0x00000200
	
	Form kRightHand ;Form of item currently equipped in the player's Right hand
	Int iSlotRightHand = -1

	;Races to check for
	Race kRaceWerebeast
	Race kRaceVampireLord
	Bool bWasNonHuman = False
	
	;Misc
	SoundDescriptor kSNDRUnequipArmor
	Float fAttenuation
	Int iVariance
	Keyword kKWDAPotion

	;Important Numbers
	Int iSlotCount = 13
	Int iSlotIrrelevant = -1
	Int iSlotStaff = 4
	Int iSlot2HMelee = 5
	Int iSlotRange = 6
	Int iSlotLeftStart = 7
	Int iSlotLeftStaff = 11
	Int iSlotShield = 12
	
	Int iSlotMaskIndexNPCLeft
	Int iSlotMaskIndexNPCRight
	
	;Indexes for sWeaponDefaultNodes
	Int iNodeSword = 0
	Int iNodeDagger = 1
	Int iNodeAxe = 2
	Int iNodeMace = 3
	Int iNodeTwoHMelee = 4
	Int iNodeRange = 5
	Int iNodePolearm = 6
	Int iNodeCrossBow = 7
	
	;JContainers
	String jAllGUDFileExtension = "AllGUD/PersistantVariables.json"
	String jAllGUDDefaultSlots = "AllGUD/DefaultSlots.json"
	String jbForceReEquip = "bForceReEquip"	;Current Triggers: Player Death.
	
;#####################
;MCM Related Functions	There were some issues when trying to make these arrays properties for the MCM. Whatever, it's not broken, would be more work to enter them into the .esp
;#####################
	Int Function GetiSlotMaskIndex(Int aiSlot)
		Return iSlotMaskIndex[aiSlot]
	EndFunction
	
	Form Function GetkSlotItem(Int aiSlot)
		Return kSlotItem[aiSlot]
	EndFunction

	String Function GetkSlotItemName(Int aiSlot)
		If(kSlotItem[aiSlot] != None)
			Return kSlotItem[aiSlot].GetName()
		EndIf
		Return ""
	EndFunction
	
	Form Function GetkSlotLockedItem(Int aiSlot)
		Return kSlotItemLocked[aiSlot]
	EndFunction
	
	String Function GetkSlotLockedItemName(Int aiSlot)
		If(kSlotItemLocked[aiSlot] != None)
			Return kSlotItemLocked[aiSlot].GetName()
		EndIf
		Return ""
	EndFunction
	
	Bool Function GetbSlotLocked(Int aiSlot)
		Return bSlotLocked[aiSlot]
	EndFunction
	
	Bool Function GetbSlotFPHidden(Int aiSlot)
		Return bSlotHiddenInFirstPerson[aiSlot]
	EndFunction
	
	Function SaveSlotMaskDefaults()
		Int jAllGUD = JArray.objectWithInts(iSlotMaskIndex)
		JValue.writeToFile(jAllGUD, JContainers.userDirectory() + jAllGUDDefaultSlots)
		Int iLoopIndex
		While(iLoopIndex < iSlotCount)
			iSlotMaskIndexDefaults[iLoopIndex] = iSlotMaskIndex[iLoopIndex]
			iLoopIndex += 1
		EndWhile
	EndFunction
	
	Function TogglebSlotHiddenFP(Int aiSlot)
		bSlotHiddenInFirstPerson[aiSlot] = !bSlotHiddenInFirstPerson[aiSlot]
		If(bCameraFirstPerson)
			If(bSlotHiddenInFirstPerson[aiSlot])
				UnequipSlot(aiSlot)
			Else
				EquipSlot(aiSlot)
			EndIf
		EndIf
	EndFunction
	
	Function TogglebSlotLocked(Int aiSlot)
		bSlotLocked[aiSlot] = !bSlotLocked[aiSlot]
		If(bSlotLocked[aiSlot])
			kSlotItemLocked[aiSlot] = kSlotItem[aiSlot]
			If(bWeaponDrawn && (aiSlot >= iSlotLeftStart) && (aiSlot == iSlotLeftHand))
				sSlotLockedModel[aiSlot] = sLeftHandSheathed
			Else
				sSlotLockedModel[aiSlot] = sSlotModel[aiSlot]
			EndIf
			;Competition is cleared on UpdateHandObjects, so it shouldn't be necessary here.
		;	ClearCompetition(aiSlot)
		Else
			kSlotItemLocked[aiSlot] = None
			sSlotLockedModel[aiSlot] = None
		EndIf
	EndFunction
	
	Function TogglePlayerWeaponDisplay()
		bDisplayPWeapon = !bDisplayPWeapon
		;Trace("Displaying Weapons? " + bDisplayPWeapon)
		If(bDisplayPWeapon)
			EquipSlots()
		Else
			UnequipSlots()
		EndIf
	EndFunction
	
	Function TogglePlayerMisc()
		bDisplayPMisc = !bDisplayPMisc
		;Trace("Displaying Misc? " + bDisplayPMisc)
		If(bDisplayPMisc)
			VisualizePlayer()
		Else
			RemovePlayerVisuals()
		EndIf
	EndFunction
	
	Function ToggleWeaponsRequireTorsoArmor()
		bRemoveWeaponsWithoutArmor = !bRemoveWeaponsWithoutArmor
		If(bRemoveWeaponsWithoutArmor)
			If!PlayerRef.GetWornForm(iSlotMaskTorso) && bDisplayPWeapon
				TogglePlayerWeaponDisplay()
			EndIf
		EndIf
	EndFunction
	
	Function ToggleItemsRequireTorsoArmor()
		bRemoveMiscItemsWithoutArmor = !bRemoveMiscItemsWithoutArmor
		If!PlayerRef.GetWornForm(iSlotMaskTorso)
			If(!bRemoveMiscItemsWithoutArmor)
				VisualizePlayer()
			Else
				RemovePlayerVisuals()
			EndIf
		EndIf
	EndFunction
	
	Function SetSlotMaskForNPCSlot(Bool abRightGear, Int aiSlotMaskIndex)
		If(aiSlotMaskIndex >= 0)
			Int iOldSlotMask 
			If abRightGear
				iOldSlotMask = iSlotMasks[iSlotMaskIndexNPCRight]
			Else
				iOldSlotMask = iSlotMasks[iSlotMaskIndexNPCLeft]
			EndIf
			Int iNewSlotMask = iSlotMasks[aiSlotMaskIndex]
			
			If(iOldSlotMask != iNewSlotMask)
				gvbDisplayNPCWeapons.SetValue(0)
				EnsureSpellStateCorrect()
				If abRightGear
					iSlotMaskIndexNPCRight = aiSlotMaskIndex
					kAllGUDNPCWeaponRight.SetSlotMask(iNewSlotMask)
					kAllGUDNPCWeaponRight.GetNthArmorAddon(0).SetSlotMask(iNewSlotMask)
				Else
					iSlotMaskIndexNPCLeft = aiSlotMaskIndex
					kAllGUDNPCWeaponLeft.SetSlotMask(iNewSlotMask)
					kAllGUDNPCWeaponLeft.GetNthArmorAddon(0).SetSlotMask(iNewSlotMask)
					kAllGUDNPCShield.SetSlotMask(iNewSlotMask)
					kAllGUDNPCShield.GetNthArmorAddon(0).SetSlotMask(iNewSlotMask)
					If(iNewSlotMask != 0x000000000)
						kAllGUDNPCShield.AddSlotToMask(iSlotMaskLeftHand) ;Removes NPC Shield because AA slotmask doesn't have priority.
					EndIf
				EndIf
			EndIf
		EndIf
	EndFunction
	
	Function RegisterCompetitiveSlots(Int aiSlot)
		;Used JContainers for this because other stuff required it, but could be replaced with SKSE's Utility.CreateIntArray if necessary
		;Utility.CreateIntArray would be slightly slower here since you'd still have to store the competition somewhere while counting them to find array size.
		;	Storing them would be ugly. They would be faster, since no middle man, so probably look into it later. #TODO
		Int jaCompetitiveSlots = JArray.object()
		Int iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			If(aiSlot != iLoopIndex && iSlotMaskIndex[aiSlot] == iSlotMaskIndex[iLoopIndex])
				JArray.addInt(jaCompetitiveSlots, iLoopIndex)
			EndIf
			iLoopIndex += 1
		EndWhile
		JValue.writeToFile(jaCompetitiveSlots, JContainers.userDirectory() + "AllGUD/Competing Slots/Slot"+aiSlot+".json")
	EndFunction
	
;##############################
;Initialization and maintenance
;##############################
	Event OnInit()
		;Trace("AllGUD-OnInit Event")
		PlayerRef = Game.GetPlayer()
		RegisterForSingleUpdate(2.0)
	EndEvent

	Event OnPlayerLoadGame()
		;Trace("AllGUD-Load Game Event")
		;Model path and form slots are not saved between game sessions.
		;All armor slots must be unequipped before models will appear. (even if they weren't equipped? shrug)
		
		Maintenance() ;Visuals first
		
		CompatibilityMaitenance() ;Compatibility Second
		
	EndEvent

	Event OnUpdate()
		;Trace("AllGUD-Updating")
		bAllGUDMaintenance = True
		fVersion = 1.55
		
		;Someone had a problem with not having display at start so...
		bDisplayPWeapon = True
		bDisplayPMisc = True
		
		kSlotItem = New Form[13]
		kSlotItemLocked = New Form[13]
		kSlotVisualDisabled = New Armor[13]
		
		;All the free slots
		iSlotMasks = New Int[16]
		iSlotMasks[0] = 0x00000000 ;-1		The "DISABLED" Slot
		iSlotMasks[1] = 0x00004000 ;44	RH Sword
		iSlotMasks[2] = 0x00008000 ;45	RH Dagger
		iSlotMasks[3] = 0x00010000 ;46		CLOAKS
		iSlotMasks[4] = 0x00020000 ;47		BACKPACKS
		iSlotMasks[5] = 0x00040000 ;48		BACK-LEFT-HIP (Bandolier, Equippable Tomes, Warmonger Armory, etc)
		iSlotMasks[6] = 0x00080000 ;49	RH Mace/Axe
		;50 Decapitation-related			Left-Hand Rings (Have not tested if using these for the player would cause problems)
		;51 Decapitation-related			Left-Hand Rings (Have not tested if using these for the player would cause problems)
		iSlotMasks[7] = 0x00400000 ;52	RH Staff				LEFT-SIDE-HIP (Bandolier)
		iSlotMasks[8] = 0x00800000 ;53		TORSO (Bandolier)
		iSlotMasks[9] = 0x01000000 ;54	2H Melee
		iSlotMasks[10] = 0x02000000 ;55		BACK-RIGHT-HIP
		iSlotMasks[11] = 0x04000000 ;56 LH Sword/Dagger/Mace/Axe
		iSlotMasks[12] = 0x08000000 ;57		FRONT-RIGHT-HIP
		iSlotMasks[13] = 0x10000000 ;58		FRONT-LEFT-HIP
		iSlotMasks[14] = 0x20000000 ;59	LH Staff/2H Range		RIGHT-SIDE-HIP (Bandolier)
		iSlotMasks[15] = 0x40000000 ;60 Shield
		
		bSlotEquipped = New Bool[13]
		bSlotUpdateFlagged = New Bool[13]
		bSlotLocked = New Bool[13]
		sSlotModel = New String[13]
		sSlotLockedModel = New String[13]
		bSlotHiddenInFirstPerson = New Bool[13]
		
		iSlotMaskIndexDefaults = New Int[13]
					; -1 = -1	Irrelevant
		iSlotMaskIndexDefaults[0] = 1	;RH Sword
		iSlotMaskIndexDefaults[1] = 2	;RH Dagger
		iSlotMaskIndexDefaults[2] = 6	;RH War Axe
		iSlotMaskIndexDefaults[3] = 6	;RH Mace
		iSlotMaskIndexDefaults[4] = 7	;RH Staff	iSlotStaff
		iSlotMaskIndexDefaults[5] = 9	;2H Melee
		iSlotMaskIndexDefaults[6] = 14	;2H Range
		iSlotMaskIndexDefaults[7] = 11	;LH Sword	iSlotLeftStart
		iSlotMaskIndexDefaults[8] = 11	;LH Dagger
		iSlotMaskIndexDefaults[9] = 11	;LH War Axe
		iSlotMaskIndexDefaults[10] = 11	;LH Mace
		iSlotMaskIndexDefaults[11] = 14	;LH Staff	iSlotLeftStaff
		iSlotMaskIndexDefaults[12] = 15	;Shield		iSlotShield

		;Load user-defined defaults
		If(JContainers.fileExistsAtPath(JContainers.userDirectory() + jAllGUDDefaultSlots))
			Int jAllGUD = JValue.readFromFile(JContainers.userDirectory() + jAllGUDDefaultSlots)
			iLoopIndex = 0
			While iLoopIndex < JArray.count(jAllGUD)
				iSlotMaskIndexDefaults[iLoopIndex] = JArray.getInt(jAllGUD, iLoopIndex)
				iLoopIndex += 1
			EndWhile
		EndIf
		
		iSlotMaskIndex = New Int[13]
		Int iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			iSlotMaskIndex[iLoopIndex] = iSlotMaskIndexDefaults[iLoopIndex]
			iLoopIndex += 1
		EndWhile
	
		iSlotMaskIndexNPCLeft = 1
		iSlotMaskIndexNPCRight = 15
		
		;Only kSNDRUnequipArmor can prevent unequip noise spam
		If(kSNDRUnequipArmor == None)
			kSNDRUnequipArmor = Game.GetFormFromFile(0x0003E60B, "Skyrim.esm") as SoundDescriptor
		EndIf		
		;Get Werebeast Race
		If(kRaceWerebeast == None)
			kRaceWerebeast = Game.GetFormFromFile(0x000CDD84, "Skyrim.esm") as Race
		EndIf
		If(kKWDAPotion == None)
			kKWDAPotion = Game.GetFormFromFile(0x0008cdec, "Skyrim.esm") as Keyword
		EndIf
		kPlayerRace = PlayerRef.GetRace()
		bPlayerFemale = PlayerRef.GetActorBase().GetSex()
		bWearingCloak = NonAllGUDInSlot(iSlotMaskCloak)
		bWearingBackpack = NonAllGUDInSlot(iSlotMaskBackpack)
		If(bWearingCloak || bWearingBackpack)
			bWearingBackItem = True
		EndIf
		InitializeXPMSERestyleData()
		CompatibilityMaitenance()
		Maintenance()
		VisualizePlayer()
		
;		AddTestArmory() ;One of these days I'll leave this thing uncommented when compiling
	EndEvent

	Function Maintenance()
		;Trace("AllGUD-Performing Maintenance")
		Trace("AllGUD is currently running version "+ fVersion)
		bAllGUDMaintenance = True	;Protect gvbDisplayNPCWeapons from change by player
		bPlayerFemale = PlayerRef.GetActorBase().GetSex()
		
		;Remove NPC Models since they'll incorrectly load up with whatever the last model was.
		gvbDisplayNPCWeapons.SetValue(0)
		EnsureSpellStateCorrect()
		
		Int iLoopIndex = 0
		
		;Mute unequip noises for slotmask and model update
		
		fAttenuation = kSNDRUnequipArmor.GetDecibelAttenuation()
		iVariance = kSNDRUnequipArmor.GetDecibelVariance()
		
	;	kSNDRUnequipArmor.SetDecibelAttenuation(100.0)
	;	kSNDRUnequipArmor.SetDecibelVariance(0)
		
		;Quick, check for death
		Int jAllGUD
		If(JContainers.fileExistsAtPath(JContainers.userDirectory() + jAllGUDFileExtension))
			jAllGUD = JValue.readFromFile(JContainers.userDirectory() + jAllGUDFileExtension)
			If(JMap.getInt(jAllGUD, jbForceReEquip))
				;Trace("AllGUD  Forcing a ReEquip")
				JMap.SetInt(jAllGUD, jbForceReEquip, 0)
				JValue.writeToFile(jAllGUD, JContainers.userDirectory() + jAllGUDFileExtension)

				While(iLoopIndex < iSlotCount)
					UnequipSlot(iLoopIndex)
					bSlotUpdateFlagged[iLoopIndex] = True
					iLoopIndex += 1
				EndWhile			
			EndIf
		EndIf
		
		;Version Updates since 1.0
		If(fVersion < 1.55)
			bSlotHiddenInFirstPerson = New Bool[13]
		
			If(kKWDAPotion == None)
				kKWDAPotion = Game.GetFormFromFile(0x0008cdec, "Skyrim.esm") as Keyword
			EndIf
			kFLSTPotionsHealth.Revert()
			kFLSTPotionsMagicka.Revert()
			kFLSTPotionsStamina.Revert()
			bInventoryProcessed = False
			
			If(fVersion < 1.51)
				iSlotMaskCloak = 0x00010000
				
				If(fVersion < 1.5)
					If iSlotLeftHand < iSlotLeftStart
						iSlotLeftHand = iSlotIrrelevant
					EndIf
					;1.4 was an MCM Update for the most part.
					If(fVersion < 1.3)
						;Refresh cloak to get the new spells
						PlayerRef.RemoveSpell(kSPELAllGUDCloak)
						Utility.Wait(0.2)
						PlayerRef.AddSpell(kSPELAllGUDCloak, False)
						iSlotMaskIndexNPCLeft = 1
						iSlotMaskIndexNPCRight = 15
					
						;Fix incorrect equation from previous versions
						Bool bDisplayNPCItems = gvbDisplayNPCItems.GetValueInt() as Bool
						gvbDisplayNPCItems.SetValue(bDisplayNPCItems as Int)
						EnsureSpellStateCorrect()
						
						If(fVersion < 1.21)
							InitializeXPMSERestyleData()
							If(fVersion < 1.1)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			fVersion = 1.55
			Trace("AllGUD updated to version " + fVersion)
		EndIf
		
		;Reregister for player-race
		UnregisterForAllMenus()
		UnregisterForAnimations()
		UnregisterForCameraState()
		UnregisterForAllKeys()
		
		If(kPlayerRace != kRaceWerebeast && kPlayerRace != kRaceVampireLord)
			RegisterForMenus()
			RegisterForAnimations()
			RegisterForCameraState()
			RegisterToggleKeys()
		EndIf
		
		RemovePlayerVisuals()
			
		;Ensure the player has the armors used for displaying the weapons
		;Unequip every armor slot and reset path and slotmasks to saved data
		;Don't flag as not-equipped, so they can be requipped just by flagging them for an update
		iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			;Add missing slots
			If(kSlotVisual[iLoopIndex])
				Int iCount = PlayerRef.GetItemCount(kSlotVisual[iLoopIndex])
				If(iCount == 0)
					PlayerRef.AddItem(kSlotVisual[iLoopIndex], 1, True)
				ElseIf(iCount > 1)
					PlayerRef.RemoveItem(kSlotVisual[iLoopIndex], (iCount - 1), True)
				EndIf
			EndIf
			
			;Compare SlotMask
			Int iAssignedSlotMask = iSlotMasks[iSlotMaskIndex[iLoopIndex]] ;Legibility
			;Trace("AllGUD  Assigning " + iAssignedSlotMask + " to "+ iLoopIndex)
			If(iAssignedSlotMask == 0x00000000)
				DisableSlot(iLoopIndex)
			Else
				If(kSlotVisual[iLoopIndex].GetSlotMask() != iAssignedSlotMask)
					If(iLoopIndex == iSlotShield)
						Int iBaseSlotMask = kSlotVisual[iLoopIndex].RemoveSlotFromMask(iSlotLeftHand)
						If(iBaseSlotMask != iAssignedSlotMask)
							UnequipSlot(iLoopIndex)
							bSlotUpdateFlagged[iLoopIndex] = True
							kSlotVisual[iLoopIndex].SetSlotMask(iAssignedSlotMask)
							kSlotVisual[iLoopIndex].GetNthArmorAddon(0).SetSlotMask(iAssignedSlotMask)
						EndIf
					Else
						UnequipSlot(iLoopIndex)
						bSlotUpdateFlagged[iLoopIndex] = True
						kSlotVisual[iLoopIndex].SetSlotMask(iAssignedSlotMask)
						kSlotVisual[iLoopIndex].GetNthArmorAddon(0).SetSlotMask(iAssignedSlotMask)
					EndIf
				EndIf
			EndIf
			
			;Compare Model
			If(kSlotVisual[iLoopIndex])
				If(sSlotModel[iLoopIndex] != kSlotVisual[iLoopIndex].GetNthArmorAddon(0).GetModelPath(False, False))
					UnequipSlot(iLoopIndex)
					kSlotVisual[iLoopIndex].GetNthArmorAddon(0).SetModelPath(sSlotModel[iLoopIndex], False, False)
					bSlotUpdateFlagged[iLoopIndex] = True
				EndIf
			EndIf
			
			RegisterCompetitiveSlots(iLoopIndex)
			
			iLoopIndex += 1
		EndWhile
		
		If(iSlotLeftHand == iSlotShield) ;;;
			;If iSlotLeftHand == iSlotShield
				AddShieldLeftHandSlotMask() ;Block the Shield on arm if not drawn
			;EndIf
			If(bWeaponDrawn)
				UnequipSlot(iSlotShield)
				bSlotEquipped[iSlotShield] = False
				bSlotUpdateFlagged[iSlotShield] = True
			EndIf
		EndIf
		
		;Realign new skeleton nodes with the default positions
		ReWeighNodes(True)
		ReScaleNodes()
		
	;	kSNDRUnequipArmor.SetDecibelVariance(iVariance)
	;	kSNDRUnequipArmor.SetDecibelAttenuation(fAttenuation)
		
		;Get relevant States	;Shouldn't these be saved anyways?
		bWeaponDrawn = PlayerRef.IsWeaponDrawn()
		bCameraFirstPerson = (Game.GetCameraState() == 0)
		
		UpdateHandObjects()
		UpdateSlots()
				
		;Load default slot masks from user-defined file.
		;Don't save them to current slot masks, player can reset them from the MCM.
		If(JContainers.fileExistsAtPath(JContainers.userDirectory() + jAllGUDDefaultSlots))
			jAllGUD = JValue.readFromFile(JContainers.userDirectory() + jAllGUDDefaultSlots)
			iLoopIndex = 0
			While iLoopIndex < JArray.count(jAllGUD)
				iSlotMaskIndexDefaults[iLoopIndex] = JArray.getInt(jAllGUD, iLoopIndex)
				iLoopIndex += 1
			EndWhile
		Else ;If user has deleted the file, reset to the normal defaults		
			iSlotMaskIndexDefaults[0] = 1	;RH Sword
			iSlotMaskIndexDefaults[1] = 2	;RH Dagger
			iSlotMaskIndexDefaults[2] = 6	;RH War Axe
			iSlotMaskIndexDefaults[3] = 6	;RH Mace
			iSlotMaskIndexDefaults[4] = 7	;RH Staff	iSlotStaff
			iSlotMaskIndexDefaults[5] = 9	;2H Melee
			iSlotMaskIndexDefaults[6] = 14	;2H Range
			iSlotMaskIndexDefaults[7] = 11	;LH Sword	iSlotLeftStart
			iSlotMaskIndexDefaults[8] = 11	;LH Dagger
			iSlotMaskIndexDefaults[9] = 11	;LH War Axe
			iSlotMaskIndexDefaults[10] = 11	;LH Mace
			iSlotMaskIndexDefaults[11] = 14	;LH Staff	iSlotLeftStaff
			iSlotMaskIndexDefaults[12] = 15	;Shield		iSlotShield
		EndIf
		
		
		;Reset Slot Masks for NPC Slots
		;RightHand
		Int iAssignedSlotMask = iSlotMasks[iSlotMaskIndexNPCRight]
		Int iCurrentSlotMask = kAllGUDNPCWeaponRight.GetSlotMask()
		If(iCurrentSlotMask != iAssignedSlotMask)
			kAllGUDNPCWeaponRight.SetSlotMask(iAssignedSlotMask)
			kAllGUDNPCWeaponRight.GetNthArmorAddon(0).SetSlotMask(iAssignedSlotMask)
		EndIf
		;LeftHand
		iAssignedSlotMask = iSlotMasks[iSlotMaskIndexNPCLeft]
		iCurrentSlotMask = kAllGUDNPCShield.RemoveSlotFromMask(iSlotMaskLeftHand)
		If(iCurrentSlotMask != iAssignedSlotMask)
			kAllGUDNPCWeaponLeft.SetSlotMask(iAssignedSlotMask)
			kAllGUDNPCWeaponLeft.GetNthArmorAddon(0).SetSlotMask(iAssignedSlotMask)
			kAllGUDNPCShield.SetSlotMask(iAssignedSlotMask)
			kAllGUDNPCShield.GetNthArmorAddon(0).SetSlotMask(iAssignedSlotMask)
		EndIf
		If(iAssignedSlotMask != 0x000000000)
			kAllGUDNPCShield.AddSlotToMask(iSlotMaskLeftHand) ;Removes NPC Shield because AA slotmask doesn't have priority.
		EndIf
		bAllGUDMaintenance = False	;All done
		
		;Safe for NPCs to have their gear show up again.
		AGUDMCM.ReloadItemVisualization()
		VisualizePlayer()
	EndFunction
	
	Function CompatibilityMaitenance()
		;Trace("AllGUD-Performing Compatibility & Variable Maintenance")
		RegisterForModEvent("AllGUDMCM_Closed", "OnAllGUDConfigClose")
		
		;When installing mid-playthrough, add any modded scrolls, ingredients, & restorative potions
		If(!bInventoryProcessed)
			Int iLoopIndex = 0
			Int iSize = PlayerRef.GetNumItems()
			While(iLoopIndex < iSize)
				Form kForm = PlayerRef.GetNthForm(iLoopIndex)
				If(kForm as Potion)
					If kForm.HasKeyword(kKWDAPotion)
						MagicEffect kMGEF = (kForm as Potion).GetNthEffectMagicEffect(0)
						If(kFLSTRestoreHealth.Find(kMGEF) >= 0)
							kFLSTPotionsHealth.AddForm(kForm)
						ElseIf(kFLSTRestoreMagicka.Find(kMGEF) >= 0)
							kFLSTPotionsMagicka.AddForm(kForm)
						ElseIf(kFLSTRestoreStamina.Find(kMGEF) >= 0)
							kFLSTPotionsStamina.AddForm(kForm)
						EndIf
					EndIf
				ElseIf(kForm as Scroll)
					kFLSTScrolls.AddForm(kForm)
				ElseIf(kForm as Ingredient)
					kFLSTIngredients.AddForm(kForm)
				EndIf
				iLoopIndex += 1
			EndWhile
			bInventoryProcessed = True
		EndIf

		If(Game.GetModByName("Dawnguard.esm") != 255)
			;Get Elderscrolls, if only it was this easy, disabling questitem display
			kFLSTElderScrolls.AddForm(Game.GetFormFromFile(0x020118F9, "Dawnguard.esm") as Book)
			kFLSTElderScrolls.AddForm(Game.GetFormFromFile(0x02011A13, "Dawnguard.esm") as Book)
			
			;Get Vampire Lord Race
			If(kRaceVampireLord == None)
				kRaceVampireLord = Game.GetFormFromFile(0x0200283A, "Dawnguard.esm") as Race
			EndIf
			
			;Fill out the ingredient list
			kFLSTIngredients.AddForm(Game.GetFormFromFile(0x000059ba, "Dawnguard.esm") as Ingredient)
			kFLSTIngredients.AddForm(Game.GetFormFromFile(0x000183b7, "Dawnguard.esm") as Ingredient)
			kFLSTIngredients.AddForm(Game.GetFormFromFile(0x0000b097, "Dawnguard.esm") as Ingredient)
			kFLSTIngredients.AddForm(Game.GetFormFromFile(0x000185fb, "Dawnguard.esm") as Ingredient)
			kFLSTIngredients.AddForm(Game.GetFormFromFile(0x00002a78, "Dawnguard.esm") as Ingredient)
		EndIf
		
		If(Game.GetModByName("HearthFires.esm") != 255)
			;More ingredients
			kFLSTIngredients.AddForm(Game.GetFormFromFile(0x0000f1cc, "HearthFires.esm") as Ingredient)
			kFLSTIngredients.AddForm(Game.GetFormFromFile(0x00003545, "HearthFires.esm") as Ingredient)
		EndIf

		If(Game.GetModByName("Dragonborn.esm") != 255)
			kFLSTBannedWeapons.AddForm(Game.GetFormFromFile(0x0001ce02, "Dragonborn.esm") as Weapon)
			kFLSTBannedWeapons.AddForm(Game.GetFormFromFile(0x0001ce03, "Dragonborn.esm") as Weapon)
			kFLSTBannedWeapons.AddForm(Game.GetFormFromFile(0x00023f6c, "Dragonborn.esm") as Weapon)
		EndIf
		
		;Campfire Compatibility
		;Also when will that one guy release Campfire Additional Backpack? q.q
		If(Game.GetModByName("Campfire.esm") != 255)
			FormList kFLSTCampfireBackpacks = Game.GetFormFromFile(0x0202C274, "Campfire.esm") as FormList
			Int iLoopIndex = 0
			While(iLoopIndex < kFLSTCampfireBackpacks.GetSize())
				kFLSTBackpacks.AddForm(kFLSTCampfireBackpacks.GetAt(iLoopIndex))
				iLoopIndex += 1
			EndWhile
		EndIf
		
		;BardsLute Compatibility
		If(Game.GetModByName("DDD-BardsLute.esp") != 255)
			kFLSTLutes.AddForm(Game.GetFormFromFile(0x00000d62, "DDD-BardsLute.esp"))
		EndIf

		;Coin Replacer Redux Compatibility
		If(Game.GetModByName("SkyrimCoinReplacerRedux.esp") != 255)
			kFLSTCoins.AddForm(Game.GetFormFromFile(0x00001000, "SkyrimCoinReplacerRedux.esp"))
			kFLSTCoins.AddForm(Game.GetFormFromFile(0x00001001, "SkyrimCoinReplacerRedux.esp"))
			kFLSTCoins.AddForm(Game.GetFormFromFile(0x00005109, "SkyrimCoinReplacerRedux.esp"))
		EndIf

		;XPMSE Compatibility, event registeration, probably won't be needed if it ever gets these nodes
		If(Game.GetModByName("XPMSE.esp") != 255)
			RegisterForModEvent("XPMSE_ReStyleComplete", "OnXPMSERestyle")
			RegisterForModEvent("XPMSE_MCMClose", "OnXPMSEMCMClose")
			RegisterForModEvent("XPMSE_WeaponUpdate", "OnRacemenuWeaponUpdate")
			bXPMSEInstalled = True
		Else
			bXPMSEInstalled = False
			UnregisterForModEvent("XPMSE_ReStyleComplete")
			UnregisterForModEvent("XPMSE_MCMClose")
			UnregisterForModEvent("XPMSE_WeaponUpdate")
		EndIf
		
		;ECE Compatibility
		If(Game.GetModByName("EnhancedCharacterEdit.esp") != 255)
			bECEInstalled = True;
		Else
			bECEInstalled = False;
		EndIf
		
		If(Game.GetModByName("Bound Armory Extravaganza.esp") != 255)
			kFLSTBannedKeywords.AddForm(Game.GetFormFromFile(0x00028a42, "Skyrim.esm") as Keyword)
			kFLSTBannedKeywords.AddForm(Game.GetFormFromFile(0x000510be, "Skyrim.esm") as Keyword)
			kFLSTBannedKeywords.AddForm(Game.GetFormFromFile(0x00084d1d, "Skyrim.esm") as Keyword)
		Else
			kFLSTBannedKeywords.RemoveAddedForm(Game.GetFormFromFile(0x00028a42, "Skyrim.esm") as Keyword)
			kFLSTBannedKeywords.RemoveAddedForm(Game.GetFormFromFile(0x000510be, "Skyrim.esm") as Keyword)
			kFLSTBannedKeywords.RemoveAddedForm(Game.GetFormFromFile(0x00084d1d, "Skyrim.esm") as Keyword)
		EndIf
	EndFunction
	
	Function InitializeXPMSERestyleData()  ;Last updated for XPMSE 4.51
		;Initialize the XPMSE-restyle-related arrays
		;TODO use XPMSE Properties instead of these constants. But muh arrays! Cuts down on runtime checks, which happen quite a bit.
		
		sWeaponDefaultNodes = New String[8] ;Constant, names of the vanilla skeleton nodes.
		sWeaponDefaultNodes[iNodeSword] = "WeaponSword"
		sWeaponDefaultNodes[iNodeDagger] = "WeaponDagger"
		sWeaponDefaultNodes[iNodeAxe] = "WeaponAxe"
		sWeaponDefaultNodes[iNodeMace] = "WeaponMace"
		sWeaponDefaultNodes[iNodeTwoHMelee] = "WeaponBack"
		sWeaponDefaultNodes[iNodeRange] = "WeaponBow"
		sWeaponDefaultNodes[iNodePolearm] = "WeaponBack"
		sWeaponDefaultNodes[iNodeCrossBow] = "WeaponCrossBow"
		
		sWeaponTargetNodes = New String[8]	;Used to track what skeleton ninode the armor should have as a destination.
		sWeaponTargetNodes[iNodeSword] = "MOV WeaponSwordDefault"
		sWeaponTargetNodes[iNodeDagger] = "MOV WeaponDaggerDefault"
		sWeaponTargetNodes[iNodeAxe] = "MOV WeaponAxeDefault"
		sWeaponTargetNodes[iNodeMace] = "MOV WeaponMaceDefault"
		sWeaponTargetNodes[iNodeTwoHMelee] = "MOV WeaponBackDefault"
		sWeaponTargetNodes[iNodeRange] = "MOV WeaponBowDefault"
		sWeaponTargetNodes[iNodePolearm] = "MOV WeaponBackAxeMaceDefault"
		sWeaponTargetNodes[iNodeCrossBow] = "MOV WeaponCrossBowDefault"
		
		sWeaponDefaultTargetNodes = New String[8]	;Default XPMSE Skeleton nodes
		sWeaponDefaultTargetNodes[iNodeSword] = "MOV WeaponSwordDefault"
		sWeaponDefaultTargetNodes[iNodeDagger] = "MOV WeaponDaggerDefault"
		sWeaponDefaultTargetNodes[iNodeAxe] = "MOV WeaponAxeDefault"
		sWeaponDefaultTargetNodes[iNodeMace] = "MOV WeaponMaceDefault"
		sWeaponDefaultTargetNodes[iNodeTwoHMelee] = "MOV WeaponBackDefault"
		sWeaponDefaultTargetNodes[iNodeRange] = "MOV WeaponBowDefault"
		sWeaponDefaultTargetNodes[iNodePolearm] = "MOV WeaponBackAxeMaceDefault"
		sWeaponDefaultTargetNodes[iNodeCrossBow] = "MOV WeaponCrossBowDefault"
		
		fWeaponNodeScale = New Float[8] ;Used to trace the scale the skeleton node should have as a destination.
		Int iLoopIndex = 0
		While(iLoopIndex < fWeaponNodeScale.Length)
			fWeaponNodeScale[iLoopIndex] = 1.0
			iLoopIndex += 1
		EndWhile
		
		iXPMSEWeaponTypes = New Int [8] ;When XPMSE calls its restyle event, it pushes the XPMSEWeaponType. Use this to compare and find what node we're working with.
		iXPMSEWeaponTypes[iNodeDagger] = 2
		iXPMSEWeaponTypes[iNodeSword] = 1
		iXPMSEWeaponTypes[iNodeAxe] = 3
		iXPMSEWeaponTypes[iNodeMace] = 4
		iXPMSEWeaponTypes[iNodeTwoHMelee] = 5
		iXPMSEWeaponTypes[iNodeRange] = 7
		iXPMSEWeaponTypes[iNodePolearm] = 6
		iXPMSEWeaponTypes[iNodeCrossBow] = 12
		
		sXPMSEStyleKeys = New String[17] ;no Left-hand keys, Unsupported style keys are commented out.
	;	sXPMSEStyleKeys[0] = ""
		sXPMSEStyleKeys[1] = "RMWSword"
		sXPMSEStyleKeys[2] = "RMWDagger"
		sXPMSEStyleKeys[3] = "RMWAxe"
		sXPMSEStyleKeys[4] = "RMWMace"
		sXPMSEStyleKeys[5] = "RMWTwohandedSword"
		sXPMSEStyleKeys[6] = "RMWTwohandedAxe"
		sXPMSEStyleKeys[7] = "RMWBow"
	;	sXPMSEStyleKeys[8] = "RMWStaff"
	;	sXPMSEStyleKeys[9] = "RMFMagic"
	;	sXPMSEStyleKeys[10] = "RMWShield"
	;	sXPMSEStyleKeys[11] = ""
		sXPMSEStyleKeys[12] = "RMWCrossbow"
	;	sXPMSEStyleKeys[13] = "RMFShout"
	;	sXPMSEStyleKeys[14] = "RMWQuiver"
	;	sXPMSEStyleKeys[15] = "RMWBolt"
	;	sXPMSEStyleKeys[16] = ""
		
		sXPMSEDagger = New String[3]
		sXPMSEDagger[0] = "MOV WeaponDaggerDefault"
		sXPMSEDagger[1] = "MOV WeaponDaggerBackHip"
		sXPMSEDagger[2] = "MOV WeaponDaggerAnkle"
		
		sXPMSESword = New String[6]
		sXPMSESword[0] = "MOV WeaponSwordDefault"
		sXPMSESword[1] = "MOV WeaponSwordOnBack"
		sXPMSESword[2] = "MOV WeaponSwordSWP"
		sXPMSESword[3] = "MOV WeaponSwordFSM"
		sXPMSESword[4] = "MOV WeaponSwordLeftHip"
		sXPMSESword[5] = "MOV WeaponSwordNMD"
		
		sXPMSEAxe = New String[3]
		sXPMSEAxe[0] = "MOV WeaponAxeDefault"
		sXPMSEAxe[1] = "MOV WeaponAxeReverse"
		sXPMSEAxe[2] = "MOV WeaponAxeOnBack"
		
		sXPMSEMace = New String[1]
		sXPMSEMace[0] = "MOV WeaponMaceDefault"
		
		sXPMSEGreatsword = New String[3]
		sXPMSEGreatsword[0] = "MOV WeaponBackDefault"
		sXPMSEGreatsword[1] = "MOV WeaponBackSWP"
		sXPMSEGreatsword[2] = "MOV WeaponBackFSM"
		
		sXPMSEPolearm = New String[3]
		sXPMSEPolearm[0] = "MOV WeaponBackAxeMaceDefault"
		sXPMSEPolearm[1] = "MOV WeaponBackAxeMaceSWP"
		sXPMSEPolearm[2] = "MOV WeaponBackAxeMaceFSM"
		
		sXPMSEBow = New String[4]
		sXPMSEBow[0] = "MOV WeaponBowDefault"
		sXPMSEBow[1] = "MOV WeaponBowChesko"
		sXPMSEBow[2] = "MOV WeaponBowBetter"
		sXPMSEBow[3] = "MOV WeaponBowFSM"
		
		sXPMSECrossBow = New String[2]
		sXPMSECrossBow[0] = "MOV WeaponCrossBowDefault"
		sXPMSECrossBow[1] = "MOV WeaponCrossBowChesko"
	EndFunction
	
	Event OnDeath(Actor akKiller)
		;Trace("AllGUD Player has died")
		;When player dies, all the geared up weapons fall off.
		;When the game is reloaded, the geared up weapons retain the position they had on death.
		;Player must be forced to unequip them using a method that persists through loadgame.
		;Solution: Use JContainers to write a Bool to a file that can be read onloadgame.
		;	Alternatives
		;		Unequip geared up armors. Looked incredibly silly as the weapons vanished from the world.
		;		Find what mesh flag allows the NordHero Bow I was testing with to NOT become physics enabled, and apply it to the other meshes. Rejected, cause I found the scattering weapons to be hilarious.
		;		Keep a record in the plugin and store information to it using a variable that doesn't reset on loadgame, like modelpath. Has potential? I think I saw another mod doing this.
		Int jAllGUD = JMap.object()
		JMap.SetInt(jAllGUD, jbForceReEquip, 1)
		JValue.writeToFile(jAllGUD, JContainers.userDirectory() + jAllGUDFileExtension)
	EndEvent
	
;###############################
;Equipping and unequipping items
;###############################
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		;Trace("AllGUD Object equipped: " + akBaseObject.GetName())
		Int iSlot = GetAllGUDItemSlot(akBaseObject)
		If(iSlot > iSlotIrrelevant)
			UpdateHandObjects()
		ElseIf(akBaseObject as Armor)
			Armor akABaseObject = akBaseObject as Armor
			If!akABaseObject.HasKeyword(kKYWDDisplayArmor)
				If bWasNonHuman
					bWasNonHuman = False
					EquipSlots()
					VisualizePlayer()
				EndIf
				If(Math.LogicalAnd(akABaseObject.GetSlotMask(),iSlotMaskTorso) == iSlotMaskTorso)
					ReWeighNodes(False)
					If PlayerRef.GetWornForm(iSlotMaskTorso)
						If bRemoveMiscItemsWithoutArmor
							If!(PlayerRef.HasSpell(kSPELPlayerItems))
								VisualizePlayer()
							EndIf
						EndIf
						If bRemoveWeaponsWithoutArmor && !bDisplayPWeapon
							TogglePlayerWeaponDisplay()
						EndIf
					EndIf
				ElseIf(Math.LogicalAnd(akABaseObject.GetSlotMask(),iSlotMaskCloak) == iSlotMaskCloak)
					If(!bWearingCloak)
						bWearingCloak = NonAllGUDInSlot(iSlotMaskCloak)
						If(bWearingCloak)
							If(!bWearingBackItem)
								bWearingBackItem = True
								UpdateShieldSlot()
							EndIf
						EndIf
					EndIf
				ElseIf(Math.LogicalAnd(akABaseObject.GetSlotMask(),iSlotMaskBackpack) == iSlotMaskBackpack)
					If(!bWearingBackpack)
						bWearingBackpack = NonAllGUDInSlot(iSlotMaskBackpack)
						If(bWearingBackpack)
							If(!bWearingBackItem)
								bWearingBackItem = True
								UpdateShieldSlot()
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndEvent

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		;Keeps the most recent Unequipped favorited item on your person.
		;Trace("AllGUD Object unequipped: " + akBaseObject.GetName())
		Int iSlot = GetAllGUDItemSlot(akBaseObject)
		If(iSlot > iSlotIrrelevant) ;Do i need a better way to prevent the geared up weapons from triggering this?
			UpdateHandObjects()
		ElseIf(akBaseObject as Armor)
			;Main Body Slot
			If(Math.LogicalAnd((akBaseObject as Armor).GetSlotMask(),iSlotMaskTorso) == iSlotMaskTorso)
				ReWeighNodes(False)
				If !PlayerRef.GetWornForm(iSlotMaskTorso)
					If bRemoveMiscItemsWithoutArmor
						RemovePlayerVisuals()
					EndIf
					If bRemoveWeaponsWithoutArmor && bDisplayPWeapon
						TogglePlayerWeaponDisplay()
					EndIf
				EndIf
			ElseIf(Math.LogicalAnd((akBaseObject as Armor).GetSlotMask(),iSlotMaskCloak) == iSlotMaskCloak)
				If(bWearingCloak)
					bWearingCloak = NonAllGUDInSlot(iSlotMaskCloak)
					If(!bWearingCloak)
						If(!bWearingBackpack)
							bWearingBackItem = False
							UpdateShieldSlot()
						EndIf
					EndIf
				EndIf
			ElseIf(Math.LogicalAnd((akBaseObject as Armor).GetSlotMask(),iSlotMaskBackpack) == iSlotMaskBackpack)
				If(bWearingBackpack)
					bWearingBackpack = NonAllGUDInSlot(iSlotMaskBackpack)
					If(!bWearingBackpack)
						If(!bWearingCloak)
							bWearingBackItem = False
							UpdateShieldSlot()
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndEvent	
	
	Function UpdateHandObjects(Bool bForceUpdate = False)
		If(bProcessingHandUpdate)
			bHandUpdateQueued = True
			;Trace("AllGUD  Hand Update in process, update is queued")
		Else
			bProcessingHandUpdate = True

		;	kSNDRUnequipArmor.SetDecibelAttenuation(100.0)
		;	kSNDRUnequipArmor.SetDecibelVariance(0)

			Bool bEquipmentChange = bForceUpdate
			Int iLoopIndex
			;Trace("AllGUD Updating Hand Objects")
			
			Form kCurrentHand = PlayerRef.GetEquippedObject(1)	;Check Right Hand
			If(kRightHand != kCurrentHand)	;Compare to saved hand
				bEquipmentChange = True
			
				If(kRightHand != None)	;Remove previous hand object if it exists
					RemoveHandObject(iSlotRightHand, kRightHand)
					iSlotRightHand = iSlotIrrelevant
				EndIf
				kRightHand = kCurrentHand
				iSlotRightHand = GetAllGUDItemSlot(kRightHand) ;Get the item slot for model and storage
				If(iSlotRightHand > iSlotIrrelevant && kSlotVisual[iSlotRightHand]) ;Filter out fists or none, and disabled
					kSlotItem[iSlotRightHand] = kRightHand
					sSlotModel[iSlotRightHand] = FillSpecificPath(iSlotRightHand, kRightHand, False)
					kSlotVisual[iSlotRightHand].GetNthArmorAddon(0).SetModelPath(sSlotModel[iSlotRightHand], False, False)
					
					
					If(iSlotRightHand == iSlotStaff && !bWeaponDrawn) ;Only display slot immediately if a sheathed staff
						bSlotEquipped[iSlotRightHand] = True
						EquipSlot(iSlotRightHand) ;v2.0
					Else ;Otherwise, unequip slot
						bSlotEquipped[iSlotRightHand] = False
						UnequipSlot(iSlotRightHand) ;v2.0
					EndIf
					bSlotUpdateFlagged[iSlotRightHand] = True
					
					;Clear alt slot if 1-hand
					If((PlayerRef.GetItemCount(kRightHand) == 1) && (iSlotRightHand <= iSlotStaff))
						Int iAltSlot = iSlotRightHand + iSlotLeftStart
						If(kRightHand == kSlotItem[iAltSlot])
							ClearSlot(iAltSlot)
						EndIf
					EndIf
					
					;Clear Slots that share the same SlotMask, for consistent displays between saving and loading.
					ClearCompetition(iSlotRightHand)
					
				EndIf
			EndIf
			
			kCurrentHand = PlayerRef.GetEquippedObject(0) ;Check Left Hand
			If(kLeftHand != kCurrentHand) ;Compare to saved hand
				bEquipmentChange = True
				
				If(kLeftHand != None) ;Remove previous hand object if it exists
					RemoveHandObject(iSlotLeftHand, kLeftHand)
					iSlotLeftHand = iSlotIrrelevant
				EndIf
				kLeftHand = kCurrentHand
				iSlotLeftHand = GetAllGUDItemSlot(kLeftHand) ;Get item slot for model and storage
				If(iSlotLeftHand > iSlotIrrelevant && iSlotLeftHand <= iSlotStaff)
					iSlotLeftHand += iSlotLeftStart ;adjust slot number for one-handers
				EndIf
				If(iSlotLeftHand >= iSlotLeftStart && kSlotVisual[iSlotLeftHand]) ;Filter out fists, none, or 2h
				
					kSlotItem[iSlotLeftHand] = kLeftHand
					sLeftHandSheathed = FillSpecificPath(iSlotLeftHand, kLeftHand, True)
					sLeftHandDrawn = FillSpecificPath(iSlotLeftHand, kLeftHand, False)
					
					If(iSlotLeftHand == iSlotShield)
						AddShieldLeftHandSlotMask()
					EndIf
					If(bWeaponDrawn)
						sSlotModel[iSlotLeftHand] = sLeftHandDrawn
						If(iSlotLeftHand == iSlotShield) ;;; ;Unequip slot if it's a readied shield ?or staff?
							bSlotEquipped[iSlotLeftHand] = False
							UnequipSlot(iSlotLeftHand) ;v2.0
						Else ;Display for all other left hands
							bSlotEquipped[iSlotLeftHand] = True
							EquipSlot(iSlotLeftHand) ;v2.0
						EndIf
					Else ;Display if sheathed
						sSlotModel[iSlotLeftHand] = sLeftHandSheathed
						bSlotEquipped[iSlotLeftHand] = True
						EquipSlot(iSlotLeftHand) ;v2.0
					EndIf
					kSlotVisual[iSlotLeftHand].GetNthArmorAddon(0).SetModelPath(sSlotModel[iSlotLeftHand], False, False)
					bSlotUpdateFlagged[iSlotLeftHand] = True
					
					;Clear alt slot if 1-hand
					If((PlayerRef.GetItemCount(kLeftHand) == 1) && (iSlotLeftHand <= iSlotLeftStaff))
						Int iAltSlot = iSlotLeftHand - iSlotLeftStart
						If(kLeftHand == kSlotItem[iAltSlot])
							ClearSlot(iAltSlot)
						EndIf
					EndIf
					
					;Clear Slots that share the same SlotMask
					ClearCompetition(iSlotLeftHand)
					
				Else
					iSlotLeftHand = iSlotIrrelevant
				EndIf
			EndIf
			
		;	kSNDRUnequipArmor.SetDecibelAttenuation(fAttenuation)
		;	kSNDRUnequipArmor.SetDecibelVariance(iVariance)
			
			;Trace("AllGUD   Right hand contains " + kRightHand +" in slot: " + iSlotRightHand)
			;Trace("AllGUD   Left hand contains " + kLeftHand +" in slot: " + iSlotLeftHand)
			bProcessingHandUpdate = False
			If(bHandUpdateQueued)
				;Utility.WaitMenuMode(0.1)
				bHandUpdateQueued = False
				UpdateHandObjects(bEquipmentChange)
			ElseIf(bEquipmentChange)
				UpdateSlots()
			EndIf
		EndIf
	EndFunction
	
	Function RemoveHandObject(Int aiSlot, Form akBaseObject)
		If(aiSlot > iSlotIrrelevant && akBaseObject != None)
			;Trace("AllGUD  Removing "+ akBaseObject.GetName() +" from 'Currently Equipped' status in slot: "+ aiSlot)
			Int iItemCount = PlayerRef.GetItemCount(akBaseObject)
			If(aiSlot == iSlotShield)
				RemoveShieldLeftHandSlotMask()
			EndIf
			Int iAltSlot = aiSlot ;This is fine since bSlotLocked[aiSlot] is checked before iAltSlot, and therefore won't matter for non 1h's (And won't produce out of bounds error in the log)
			If(aiSlot <= iSlotStaff)
				iAltSlot = aiSlot + iSlotLeftStart
			ElseIf((aiSlot >= iSlotLeftStart) && (aiSlot <= iSlotLeftStaff))
				iAltSlot = aiSlot - iSlotLeftStart
			EndIf
			
			If(bSlotLocked[aiSlot]) ;RESET Slot to the Locked-in weapon
				;Trace("AllGUD   User has Locked-in slot " + aiSlot)
				If((iAltSlot != aiSlot) && (iItemCount == 1) && (kSlotItem[iAltSlot] == kSlotItemLocked[aiSlot]))
					;Weapon is being used in the other hand.
					ClearSlot(aiSlot);
				Else
					;Restore the locked-in item
					If(kSlotItemLocked[aiSlot] == None)
						ClearSlot(aiSlot)
					Else
						kSlotItem[aiSlot] = kSlotItemLocked[aiSlot]
						sSlotModel[aiSlot] = sSlotLockedModel[aiSlot]
						kSlotVisual[aiSlot].GetNthArmorAddon(0).SetModelPath(sSlotModel[aiSlot], False, False)
						bSlotEquipped[aiSlot] = True
						bSlotUpdateFlagged[aiSlot] = True
						;Don't think it needs to clear competition since it shouldn't get set?
					;	ClearCompetition(aiSlot)
					EndIf
				EndIf
		;Alt Slot is locked-in to the same weapon, with only 1 copy
			ElseIf(bSlotLocked[iAltSlot] && (kSlotItemLocked[iAltSlot] == akBaseObject) && (iItemCount == 1))
				;Clear this slot
				ClearSlot(aiSlot)
				
				;Equip other slot
				kSlotItem[iAltSlot] = kSlotItemLocked[iAltSlot]
				sSlotModel[iAltSlot] = sSlotLockedModel[iAltSlot]
				kSlotVisual[iAltSlot].GetNthArmorAddon(0).SetModelPath(sSlotModel[iAltSlot], False, False)
				bSlotEquipped[iAltSlot] = True
				bSlotUpdateFlagged[iAltSlot] = True
					
			ElseIf(Game.IsObjectFavorited(akBaseObject)) ;DISPLAY this weapon, unless it's competing with a Locked-in slot
				Bool bNotInOtherHand = True
				;Because of the order of UpdateHandObjects, check for opposite hand if itemcount is one (mainly because left-hand. TODO: change the order of operations to make this check unnecessary?).
				If(iItemCount == 1)
					If(aiSlot <= iSlotStaff)
						If(akBaseObject == kLeftHand)
							bNotInOtherHand = False
						EndIf
					ElseIf(aiSlot >= iSlotLeftStart && aiSlot <= iSlotLeftStaff)
						If(akBaseObject == kRightHand)
							bNotInOtherHand = False
						EndIf
					EndIf
				EndIf
				
				If(bNotInOtherHand)
					;Trace("AllGUD   " + akBaseObject.GetName() + " was a favorited weapon in slot " + aiSlot)
					If(aiSlot >= iSlotLeftStart && kSlotVisual[aiSlot]) ;Set model to sheathed in case it was currently the drawn model
						sSlotModel[aiSlot] = sLeftHandSheathed
						kSlotVisual[aiSlot].GetNthArmorAddon(0).SetModelPath(sSlotModel[aiSlot], False, False)
					EndIf
					;EquipSlot(aiSlot) ;Do Not do this. Keep it to UpdateSlots in case of competition
					bSlotEquipped[aiSlot] = True
					bSlotUpdateFlagged[aiSlot] = True
				
					;Attempt to fix dual-wielding staves producing artifact model of RH when sheathing.
				;	If(aiSlot == iSlotStaff)
				;		If(iSlotLeftHand == iSlotLeftStaff)
				;			UnequipSlot(iSlotLeftHand)
				;			bSlotUpdateFlagged[iSlotLeftHand] = True
				;		EndIf
				;	EndIf
					;Did not work.
				
					;This ClearCompetition is special, If it finds a locked-in slot, clear current slot and equip that one
					
					If(!JContainers.fileExistsAtPath(JContainers.userDirectory() + "AllGUD/Competing Slots/Slot"+aiSlot+".json"))
						RegisterCompetitiveSlots(aiSlot)
					EndIf
					Int jaCompetitiveSlots = JValue.readFromFile(JContainers.userDirectory() + "AllGUD/Competing Slots/Slot"+aiSlot+".json")
					
					Int iLoopIndex = 0
					While(iLoopIndex < JArray.Count(jaCompetitiveSlots))
						Int iCompetitionSlot = JArray.getInt(jaCompetitiveSlots, iLoopIndex)
						
						If(bSlotLocked[iCompetitionSlot]) ;Competing Slot is Locked-in
							;Trace(iCompetitionSlot + " is Locked-in")
							ClearSlot(aiSlot) ;Clear the current slot instead
							
							;Equip the Locked-in Slot.
							bSlotEquipped[iCompetitionSlot] = True
							bSlotUpdateFlagged[iCompetitionSlot] = True
							
							iLoopIndex = iSlotCount ;Stop the Loop
						ElseIf(iCompetitionSlot < iSlotLeftStart) ;Clear the competing slots.
							If(kSlotItem[iCompetitionSlot] != kRightHand)
								ClearSlot(iCompetitionSlot)
							EndIf
						ElseIf(kSlotItem[iCompetitionSlot] != kLeftHand)
							ClearSlot(iCompetitionSlot)
						EndIf
						
						iLoopIndex += 1
					EndWhile
					
					;/ PRE DYNAMIC ARRAY
					Int iLoopIndex = 0
					While(iLoopIndex < iSlotCount)
						If((iSlotMaskIndex[aiSlot] == iSlotMaskIndex[iLoopIndex]) && (aiSlot != iLoopIndex))
							;Trace("AllGUD    -RemoveHandObject SlotMaskIndex match found between slots " + aiSlot + " and " + iLoopIndex)
							If(bSlotLocked[iLoopIndex]) ;Competing Slot is Locked-in
								;Trace(iLoopIndex + " is Locked-in")
								ClearSlot(aiSlot) ;Clear the current slot instead
								
								;Equip the Locked-in Slot.
								bSlotEquipped[iLoopIndex] = True
					;			EquipSlot(iLoopIndex) ;v2.0
								bSlotUpdateFlagged[iLoopIndex] = True
								
								iLoopIndex = iSlotCount ;Stop the Loop
							ElseIf(iLoopIndex < iSlotLeftStart) ;Clear the competing slots.
								If(kSlotItem[iLoopIndex] != kRightHand)
									ClearSlot(iLoopIndex)
								EndIf
							ElseIf(kSlotItem[iLoopIndex] != kLeftHand)
								ClearSlot(iLoopIndex)
							EndIf
						EndIf
						iLoopIndex += 1
					EndWhile
					/;
				
				EndIf
			Else
				;Trace("AllGUD   " + akBaseObject.GetName() + " was not a favorite. Clearing slot " + aiSlot)
				ClearSlot(aiSlot)
				
				;RESTORE Locked-in Slot.	Only restores if Locked-in and not the most recently unequipped favorited weapon because I imagine it'll be easier for the user to customize their loadout?
				If(!JContainers.fileExistsAtPath(JContainers.userDirectory() + "AllGUD/Competing Slots/Slot"+aiSlot+".json"))
					RegisterCompetitiveSlots(aiSlot)
				EndIf
				Int jaCompetitiveSlots = JValue.readFromFile(JContainers.userDirectory() + "AllGUD/Competing Slots/Slot"+aiSlot+".json")
				
				Int iLoopIndex = 0
				While(iLoopIndex < JArray.Count(jaCompetitiveSlots))
					Int iCompetitionSlot = JArray.getInt(jaCompetitiveSlots, iLoopIndex)
					
					If(bSlotLocked[iCompetitionSlot]) ;Competing Slot is Locked-in
						;Trace(iCompetitionSlot + " is Locked-in")
						ClearSlot(aiSlot) ;Clear the current slot instead
						
						;Equip the Locked-in Slot.
						bSlotEquipped[iCompetitionSlot] = True
						bSlotUpdateFlagged[iCompetitionSlot] = True
						
						iLoopIndex = iSlotCount ;Stop the Loop
					EndIf
					
					iLoopIndex += 1
				EndWhile
					
				;/	PRE DYNAMIC ARRAY
				Int iLoopIndex = 0
				While(iLoopIndex < iSlotCount)
					If((iSlotMaskIndex[aiSlot] == iSlotMaskIndex[iLoopIndex]) && (aiSlot != iLoopIndex))
						;Trace("AllGUD    -RemoveHandObject SlotMaskIndex match found between slots " + aiSlot + " and " + iLoopIndex)
						If(bSlotLocked[iLoopIndex]) ;Competing Slot is Locked-in
							If((iSlotMaskIndex[iLoopIndex] != iSlotMaskIndex[iSlotRightHand]) && (iSlotMaskIndex[iLoopIndex] != iSlotMaskIndex[iSlotLeftHand]))
								bSlotEquipped[iLoopIndex] = True
						;		EquipSlot(iLoopIndex) ;v2.0
								bSlotUpdateFlagged[iLoopIndex] = True
							EndIf ;Equip the other Slot
							iLoopIndex = iSlotCount ;Stop the Loop
						EndIf
					EndIf
					iLoopIndex += 1
				EndWhile
				/;
				
			EndIf
		EndIf
	EndFunction

	Bool Function NonAllGUDInSlot(Int aiSlotMask)
		If(PlayerRef.GetWornForm(aiSlotMask))
			Return !PlayerRef.GetWornForm(aiSlotMask).HasKeyword(kKYWDDisplayArmor)
		EndIf
		Return False
	EndFunction
	
;####################################################################################################################################################
;Sheathing and drawing weapons
;####################################################################################################################################################
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		Bool bNewDrawState = (PlayerRef.IsWeaponDrawn() || (asEventName == "BeginWeaponDraw")) ;"WeaponDraw" is needed because Left-Hand only weapons don't trigger "BeginWeaponDraw"
;		Trace("  AllGUD Animation Event " + asEventName + " " + bWeaponDrawn + " " + bNewDrawState)
		If(bWeaponDrawn != bNewDrawState)
			bWeaponDrawn = bNewDrawState
			
		;	kSNDRUnequipArmor.SetDecibelAttenuation(100.0)
		;	kSNDRUnequipArmor.SetDecibelVariance(0)
						
			UpdateHandObjects() ;Easier to fix any issues by drawing/sheathing than equipping/unequipping
			If(iSlotRightHand == iSlotStaff && kSlotVisual[iSlotRightHand]) ;Only RH that needs to change is Staff
				;Model was already set when it was equipped
				If(bWeaponDrawn)
					bSlotEquipped[iSlotRightHand] = False
					UnequipSlot(iSlotRightHand) ;v2.0
				Else
					bSlotEquipped[iSlotRightHand] = True
					EquipSlot(iSlotRightHand) ;v2.0
				EndIf
				bSlotUpdateFlagged[iSlotRightHand] = True
			EndIf
			If(iSLotLeftHand > iSlotIrrelevant && kSlotVisual[iSlotLeftHand]) ;All LH slots need to change something.
				If(bWeaponDrawn)
					If(iSlotLeftHand == iSlotShield) ;;;
						bSlotEquipped[iSlotLeftHand] = False
						UnequipSlot(iSlotLeftHand) ;v2.0
					Else
						sSlotModel[iSlotLeftHand] = sLeftHandDrawn
						bSlotEquipped[iSlotLeftHand] = True
						EquipSlot(iSlotLeftHand) ;v2.0
					EndIf
				Else
					If(iSlotLeftHand != iSlotShield)
						sSlotModel[iSlotLeftHand] = sLeftHandSheathed
					EndIf
					bSlotEquipped[iSlotLeftHand] = True
					EquipSlot(iSlotLeftHand) ;v2.0
				EndIf
				kSlotVisual[iSlotLeftHand].GetNthArmorAddon(0).SetModelPath(sSlotModel[iSlotLeftHand], False, False)
				bSlotUpdateFlagged[iSlotLeftHand] = True
			EndIf
			
		;	kSNDRUnequipArmor.SetDecibelAttenuation(fAttenuation)
		;	kSNDRUnequipArmor.SetDecibelVariance(iVariance)
		EndIf
		UpdateSlots() ;Keeping it here slows things down generally, but speeds up accuracte gearups
	EndEvent
	
	Function RegisterForAnimations()
		RegisterForAnimationEvent(PlayerRef, "BeginWeaponDraw")
		RegisterForAnimationEvent(PlayerRef, "WeaponDraw")
		RegisterForAnimationEvent(PlayerRef, "WeaponSheathe")
	EndFunction

	Function UnregisterForAnimations()
		UnregisterForAnimationEvent(PlayerRef, "BeginWeaponDraw")
		UnregisterForAnimationEvent(PlayerRef, "WeaponDraw")
		UnregisterForAnimationEvent(PlayerRef, "WeaponSheathe")
	EndFunction

;####################################################################################################################################################
;Race switching
;####################################################################################################################################################
	Event OnRaceSwitchComplete()
		;Trace("AllGUD Race switch completed")
		Race kNewPlayerRace = PlayerRef.GetRace()
		;Trace("New race: " + kNewPlayerRace.GetName())

	;	If((kNewPlayerRace == kRaceWerebeast) || (kNewPlayerRace == kRaceVampireLord))
	;		ClearSlots()	;Clearing someone's saved preferences would be rude.
	;	EndIf
		
		UnregisterForAllMenus()
		UnregisterForAnimations()
		UnregisterForCameraState()
		UnregisterToggleKeys(False)
		If(kPlayerRace != kRaceVampireLord)
			UnequipSlots()
			RemovePlayerVisuals()
		EndIf
		
		If((kNewPlayerRace != kRaceWerebeast) && (kNewPlayerRace != kRaceVampireLord))
			;Trace("AllGUD   Player Turned into one of the default races")
			bPlayerFemale = PlayerRef.GetActorBase().GetSex()
			RegisterForMenus()
			RegisterForAnimations()
			RegisterForCameraState()
			RegisterToggleKeys()
			bCameraFirstPerson = (Game.GetCameraState() == 0)
			ReWeighNodes(True)
			ReScaleNodes()
			ReloadSlotMasks()
			
			If(kPlayerRace != kRaceWerebeast)
				EquipSlots()	;Slots won't be equipped right away after werewolf
				AGUDMCM.ReloadPlayerItemModels()
				VisualizePlayer()
			Else
				bWasNonHuman = True	;Slots will be equipped after entering the inventory/container menu.
			EndIf
		EndIf
		kPlayerRace = kNewPlayerRace
	EndEvent

;#############
;Menu and Keys
;#############
	Event OnMenuOpen(string asMenuName)
		UnregisterToggleKeys(False)
		If(asMenuName == "RaceSex Menu")
		;	UnequipSlots()	;Testing leaving weapons on
		;	RemovePlayerVisuals()
		Else
			If(Game.UsingGamepad())
				iHotkeyFavorites = Input.GetMappedKey("Jump")
			Else
				iHotkeyFavorites = Input.GetMappedKey("Toggle POV")
			EndIf
			RegisterForKey(iHotkeyFavorites)
		EndIf
	EndEvent
	
	Event OnMenuClose(string asMenuName)
		RegisterToggleKeys()
		If(asMenuName == "RaceSex Menu")
			If(kPlayerRace == PlayerRef.GetRace()) ;Race did not change, therefore raceswitch did not trigger
				;If player race or sex was changed in the racemenu, then changed back, visualization spell and equipslots would have to be reequipped
				UnregisterForAnimations()
				UnregisterForCameraState()
				
				bPlayerFemale = PlayerRef.GetActorBase().GetSex()
				bCameraFirstPerson = (Game.GetCameraState() == 0)
				bWeaponDrawn = PlayerRef.IsWeaponDrawn()

				RegisterForAnimations()
				RegisterForCameraState()
				
				ReWeighNodes(True)
				ReScaleNodes()
				ReloadSlotMasks()
				
				EquipSlots()

				AGUDMCM.ReloadPlayerItemModels()
				RemovePlayerVisuals()
				VisualizePlayer()
			EndIf
		Else
			If(bUpdateFavoritesList)
				ClearUnfavorites()
			EndIf
			UnregisterForKey(iHotkeyFavorites)
			If bWasNonHuman ;Keep it in OnMenuClose because equipping looks better when time isn't paused.
				bWasNonHuman = False
				EquipSlots()
				VisualizePlayer()
			EndIf
		EndIf
	EndEvent
	
	Event OnAllGUDConfigClose(Bool abUpdatePlayerVisuals, Bool abUpdateNPCVisuals, Bool abUpdateNPCWeapons)
		;DON'T WAIT/UPDATE THEM IN THE MCM, SLOWS DOWN MCM PAGE SWAPS
		Utility.Wait(1.0)	;waitmenumode doesn't work?
		If(abUpdatePlayerVisuals)
			AGUDMCM.RefreshPlayerItems()
		EndIf
		If(abUpdateNPCVisuals)
			AGUDMCM.RefreshNPCItems()
		EndIf
		If(abUpdateNPCWeapons)
			AGUDMCM.RefreshNPCWeapons()
		EndIf
	EndEvent
	
	Event OnKeyDown(int aiKey)
		If(!UI.IsTextInputEnabled())
			If(aiKey == iHotkeyFavorites)
				bUpdateFavoritesList = True
				UnregisterForKey(iHotkeyFavorites)
			EndIf
			If(aiKey == iHKeyPWeapon)
				TogglePlayerWeaponDisplay()
			EndIf
			If(aiKey == iHKeyPItem)
				TogglePlayerMisc()
			EndIf
			If(aiKey == iHKeyNPCItem)
				AGUDMCM.ToggleNPCItems()
			EndIf
			If(aiKey == iHKeyNPCWeapon)
				AGUDMCM.ToggleNPCWeapons()
			EndIf
		EndIf
	EndEvent

	Function UnregisterToggleKeys(Bool abReRegister)
		UnregisterForAllKeys()
		If(abReRegister)
			RegisterToggleKeys()
		EndIf
	EndFunction
	
	Function RegisterToggleKeys()
		RegisterForKey(iHKeyPWeapon)
		RegisterForKey(iHKeyPItem)
		RegisterForKey(iHKeyNPCItem)
		RegisterForKey(iHKeyNPCWeapon)
	EndFunction
	
	Function ClearUnfavorites()
		bUpdateFavoritesList = False
		Int iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			If(kSlotItem[iLoopIndex])
				If(!Game.IsObjectFavorited(kSlotItem[iLoopIndex]))
					If(iLoopIndex < iSlotLeftStart)
						If(kSlotItem[iLoopIndex] != kRightHand) ;Not the handobject
							ClearSlot(iLoopIndex)
							;Trace("AllGUD   Slot " + iLoopIndex + " will be unequipped, because it is no longer favorited")
						EndIf
					Else
						If(kSlotItem[iLoopIndex] != kLeftHand) ;Not the handobject
							ClearSlot(iLoopIndex)
							;Trace("AllGUD   Slot " + iLoopIndex + " will be unequipped, because it is no longer favorited")
						EndIf
					EndIf
				EndIf
			EndIf
			If(kSlotItemLocked[iLoopIndex])
				If(!Game.IsObjectFavorited(kSlotItemLocked[iLoopIndex]))
					bSlotLocked[iLoopIndex] = False
					kSlotItemLocked[iLoopIndex] = None
					sSlotLockedModel[iLoopIndex] = None
				EndIf
			EndIf
			iLoopIndex += 1
		EndWhile
		UpdateSlots()
	EndFunction

	Function RegisterForMenus()
		RegisterForMenu("InventoryMenu")
		RegisterForMenu("ContainerMenu")
		RegisterForMenu("RaceSex Menu")
	EndFunction
	
;###################
;Inventory Functions ;Don't think i can use an inventory filter? Unless I had a formlist of every friggin weapon, shield, potion, scroll, ingredient etc added by any mod ever?
;###################
	Event OnItemAdded(Form akBaseObject, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
		;Trace("AllGUD  Item added: " + akBaseObject.GetName() + " (" + aiItemCount + ")")

		;Add forms for item visualization so as to support and new items added by mods
		If(kFLSTCoins.HasForm(akBaseObject))
		ElseIf(akBaseObject as Ingredient)
			kFLSTIngredients.AddForm(akBaseObject)
		ElseIf(akBaseObject as Potion)
			If(akBaseObject.HasKeyword(kKWDAPotion))
				MagicEffect kMGEF = (akBaseObject as Potion).GetNthEffectMagicEffect(0)
				If(kFLSTWhitePhials.HasForm(akBaseObject))
					kFLSTPotionsHealth.RemoveAddedForm(akBaseObject)
					kFLSTPotionsMagicka.RemoveAddedForm(akBaseObject)
					kFLSTPotionsStamina.RemoveAddedForm(akBaseObject)
				ElseIf(kFLSTRestoreHealth.HasForm(kMGEF))
					kFLSTPotionsHealth.AddForm(akBaseObject)
				ElseIf(kFLSTRestoreMagicka.HasForm(kMGEF))
					kFLSTPotionsMagicka.AddForm(akBaseObject)
				ElseIf(kFLSTRestoreStamina.HasForm(kMGEF))
					kFLSTPotionsStamina.AddForm(akBaseObject)
				EndIf
			EndIf
		ElseIf(akBaseObject as Scroll)
			kFLSTScrolls.AddForm(akBaseObject)
		EndIf
		;Do these formlists grow too large as play continues? Should the list be popped at some point?
	EndEvent

	Event OnItemRemoved(Form akBaseObject, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
		;Trace("AllGUD  Item removed: " + akBaseObject.GetName() + " (" + aiItemCount + ")")
		Int iSlot = GetAllGUDItemSlot(akBaseObject)
		Int iRemainingCount = PlayerRef.GetItemCount(akBaseObject)
		If(iSlot > iSlotIrrelevant) ;Is it a weapon/shield
			If(iRemainingCount == 0) ;If all items were removed
				If(kSlotItemLocked[iSlot] == akBaseObject)
					bSlotLocked[iSlot] = False
					kSlotItemLocked[iSlot] = None
					sSlotLockedModel[iSlot] = None
				EndIf
			
				If(kSlotItem[iSlot] == akBaseObject) ;Is in RH
					ClearSlot(iSlot)
					;Trace("AllGUD   Slot " + iSlot + " will be unequipped, because there are no remaining copies")
				EndIf
				
				If(iSlot <= iSlotStaff) ;If it's a 1h, need to check LH as well
					iSlot += iSlotLeftStart
					If(kSlotItem[iSlot] == akBaseObject) ;Is in LH
						ClearSlot(iSlot)
						;Trace("AllGUD   Slot " + iSlot + " will be unequipped, because there are no remaining copies")
					EndIf
				EndIf
			ElseIf(iRemainingCount == 1) ;Exactly one left
				If(iSlot <= iSlotStaff) ;and it's a 1h weapon
					Int iAltSlot = iSlot
					iAltSlot = iSlot + iSlotLeftStart
					If((kSlotItem[iSlot] == akBaseObject) && (kSlotItem[iAltSlot] == akBaseObject)) ;and is in both LH and RH slots
						If(kLeftHand == akBaseObject) ;If it's currently in the LH, remove from RH
							ClearSlot(iSlot)
							;Trace("AllGUD   Slot " + iSlot + " will be unequipped, because there is only one copy and it is in the left hand")
						Else ;Remove from Left otherwise
							ClearSlot(iAltSlot)
							;Trace("AllGUD   Slot " + iAltSlot + " will be unequipped, because there is only one copy and the right slot takes priority")
						EndIf
					EndIf
					
					If((kSlotItemLocked[iSlot] == akBaseObject) && (kSlotItemLocked[iAltSlot] == akBaseObject)) ;and is in both LH and RH slots
						If(kLeftHand == akBaseObject) ;If it's currently in the LH, remove from RH
							bSlotLocked[iSlot] = False
							kSlotItemLocked[iSlot] = None
							sSlotLockedModel[iSlot] = None
						Else ;Remove from Left otherwise
							bSlotLocked[iAltSlot] = False
							kSlotItemLocked[iAltSlot] = None
							sSlotLockedModel[iAltSlot] = None
						EndIf
					EndIf
					
				EndIf
			EndIf
			UpdateSlots()
			
		;Add the display armor back if it was somehow removed ;Moved this check to just prior to un/equip in updateslots
;		ElseIf(akBaseObject as Armor)
;			If((kSlotVisual.Find(akBaseObject as Armor) >= 0))
;				If(PlayerRef.GetItemCount(akBaseObject) == 0)
;					PlayerRef.AddItem(akBaseObject)
;				EndIf
;			EndIf
		EndIf
	EndEvent

	Function AddTestArmory()
		;Gives a full set of weapons for testing
		Notification("Adding the complimentary test armory")
		Int OnlyOne = 1
		Int DualWeapon = 2
		Int Arrows = 10
		
		Form TestDagger = Game.GetForm(0x0001397e)
		Form TestSword = Game.GetForm(0x00012eb7)
		Form TestWarAxe = Game.GetForm(0x00013790)
		Form TestMace = Game.GetForm(0x00013982)
		Form TestStaff = Game.GetForm(0x000be121)
		
		Form TestGreatSword = Game.GetForm(0x0001359d)
		Form TestBattleAxe = Game.GetForm(0x00013980)

		Form TestArrow = Game.GetForm(0x0001397d)
		Form TestBow = Game.GetForm(0x00013985)


		Form TestShield = Game.GetForm(0x00012eb6)		
		Form MatchingArmor = Game.GetForm(0x00012e49)
		Form MatchingBoots = Game.GetForm(0x00012e4b)
		Form MatchingGloves = Game.GetForm(0x00012e46)
		Form MatchingHelmet = Game.GetForm(0x00012e4d)

		If(Game.GetModByName("Dawnguard.esm") != 255)
			Form TestCrossbow = Game.GetFormFromFile(0x02000801, "Dawnguard.esm")
			Form SteelBolts = Game.GetFormFromFile(0x02000bb3, "Dawnguard.esm")
			If(PlayerRef.GetItemCount(SteelBolts) < Arrows)
				PlayerRef.AddItem(SteelBolts, Arrows, true)
			EndIf
			If(PlayerRef.GetItemCount(TestCrossbow) < OnlyOne)
				PlayerRef.AddItem(TestCrossbow, OnlyOne, true)
			EndIf
		EndIf
		
		If(Game.GetModByName("Campfire.esm") != 255)
			Form RandoBackpack = Game.GetFormFromFile(0x0202c260, "Campfire.esm")
			If(PlayerRef.GetItemCount(RandoBackpack) < OnlyOne)
				PlayerRef.AddItem(RandoBackpack, OnlyOne, true)
			EndIf
			Form RandoCloak = Game.GetFormFromFile(0x0203fa9c, "Campfire.esm")
			If(PlayerRef.GetItemCount(RandoCloak) < OnlyOne)
				PlayerRef.AddItem(RandoCloak, OnlyOne, true)
			EndIf
		EndIf
		
		If(PlayerRef.GetItemCount(TestDagger) < DualWeapon)
			PlayerRef.AddItem(TestDagger, DualWeapon, true)
		EndIf
		If(PlayerRef.GetItemCount(TestSword) < DualWeapon)
			PlayerRef.AddItem(TestSword, DualWeapon, true)
		EndIf
		If(PlayerRef.GetItemCount(TestWarAxe) < DualWeapon)
			PlayerRef.AddItem(TestWarAxe, DualWeapon, true)
		EndIf
		If(PlayerRef.GetItemCount(TestMace) < DualWeapon)
			PlayerRef.AddItem(TestMace, DualWeapon, true)
		EndIf
		If(PlayerRef.GetItemCount(TestStaff) < DualWeapon)
			PlayerRef.AddItem(TestStaff, DualWeapon, true)
		EndIf

		If(PlayerRef.GetItemCount(TestGreatSword) < OnlyOne)
			PlayerRef.AddItem(TestGreatSword, OnlyOne, true)
		EndIf
		If(PlayerRef.GetItemCount(TestBattleAxe) < OnlyOne)
			PlayerRef.AddItem(TestBattleAxe, OnlyOne, true)
		EndIf

		If(PlayerRef.GetItemCount(TestBow) < OnlyOne)
			PlayerRef.AddItem(TestBow, OnlyOne, true)
		EndIf
		If(PlayerRef.GetItemCount(TestArrow) < Arrows)
			PlayerRef.AddItem(TestArrow, Arrows, true)
		EndIf
		
		If(PlayerRef.GetItemCount(TestShield) < OnlyOne)
			PlayerRef.AddItem(TestShield, OnlyOne, true)
		EndIf
		If(PlayerRef.GetItemCount(MatchingArmor) < OnlyOne)
			PlayerRef.AddItem(MatchingArmor, OnlyOne, true)
		EndIf
		If(PlayerRef.GetItemCount(MatchingHelmet) < OnlyOne)
			PlayerRef.AddItem(MatchingHelmet, OnlyOne, true)
		EndIf
		If(PlayerRef.GetItemCount(MatchingBoots) < OnlyOne)
			PlayerRef.AddItem(MatchingBoots, OnlyOne, true)
		EndIf
		If(PlayerRef.GetItemCount(MatchingGloves) < OnlyOne)
			PlayerRef.AddItem(MatchingGloves, OnlyOne, true)
		EndIf
		
		;Misc Items
		Form Torch = Game.GetForm(0x0001d4ec)
		If(PlayerRef.GetItemCount(Torch) < OnlyOne)
			PlayerRef.AddItem(Torch, OnlyOne, true)
		EndIf
		Form HealthPot = Game.GetForm(0x00039be5)
		If(PlayerRef.GetItemCount(HealthPot) < OnlyOne)
			PlayerRef.AddItem(HealthPot, OnlyOne, true)
		EndIf
		Form MagickPot = Game.GetForm(0x00039be7)
		If(PlayerRef.GetItemCount(MagickPot) < OnlyOne)
			PlayerRef.AddItem(MagickPot, OnlyOne, true)
		EndIf
		Form StaminaPot = Game.GetForm(0x00039cf3)
		If(PlayerRef.GetItemCount(StaminaPot) < OnlyOne)
			PlayerRef.AddItem(StaminaPot, OnlyOne, true)
		EndIf
		Form RandomScroll = Game.GetForm(0x000a44aa)
		If(PlayerRef.GetItemCount(RandomScroll) < OnlyOne)
			PlayerRef.AddItem(RandomScroll, OnlyOne, true)
		EndIf
		Form Nirnroot = Game.GetForm(0x000b701a)
		If(PlayerRef.GetItemCount(Nirnroot) < OnlyOne)
			PlayerRef.AddItem(Nirnroot, OnlyOne, true)
		EndIf
		Form DaedraHeart = Game.GetForm(0x0003ad5b)
		If(PlayerRef.GetItemCount(DaedraHeart) < OnlyOne)
			PlayerRef.AddItem(DaedraHeart, OnlyOne, true)
		EndIf
		Form Gold = Game.GetForm(0x0000000f)
		If(PlayerRef.GetItemCount(Gold) < 100)
			PlayerRef.AddItem(Gold, 100, true)
		EndIf
		
		Form Lute = Game.GetForm(0x000dabab)
		If(PlayerRef.GetItemCount(Lute) < OnlyOne)
			PlayerRef.AddItem(Lute, OnlyOne, true)
		EndIf
		Form Flute = Game.GetForm(0x000daba7)
		If(PlayerRef.GetItemCount(Flute) < OnlyOne)
			PlayerRef.AddItem(Flute, OnlyOne, true)
		EndIf
		
		;Quest Items
		Form WhitePhial = Game.GetForm(0x0010201e)
		If(PlayerRef.GetItemCount(WhitePhial) < OnlyOne)
			PlayerRef.AddItem(WhitePhial, OnlyOne, true)
		EndIf
		Form ElderScroll = Game.GetForm(0x0002d513)
		If(PlayerRef.GetItemCount(ElderScroll) < OnlyOne)
			PlayerRef.AddItem(ElderScroll, OnlyOne, true)
		EndIf
		Form AzurasStar = Game.GetForm(0x00063b27)
		If(PlayerRef.GetItemCount(AzurasStar) < OnlyOne)
			PlayerRef.AddItem(AzurasStar, OnlyOne, true)
		EndIf
		;Trace("AllGUD- Test Armory added")
	EndFunction

;##############
;Slot Functions
;##############
	Int Function GetAllGUDItemSlot(Form akBaseObject)
		;	Default		Step1	Step2	Step3	Step4	Step 5	AfterFunctionReturns	FINAL
		;-1 N/A			Fist									Irrelevant				Irrelevant
		;0 	Fist		Sword															RH Sword
		;1	Sword		Dagger															RH Dagger
		;2 	Dagger		WarAxe															RH WarAxe
		;3 	WarAxe		Mace															RH Mace
		;4 	Mace		GSword	null	Staff											RH Staff
		;5 	GSword		BA & WH	2HMelee													2H Melee
		;6 	BAxe&WHam	Bow						2HRange									2H Range
		;7 	Bow			Staff			Null					LH Sword				LH Sword
		;8 	Staff		XBow					Null			LH Dagger				LH Dagger
		;9 	XBow												LH WarAxe				LH WarAxe
		;10 													LH Mace					LH Mace
		;11														LH Staff				LH Staff
		;12												Shield							Shield

		Int iSlotMisplacedStaff = 7
		
		If(akBaseObject)
			;Bound Weapon? No ty
			If(kFLSTBannedWeapons.HasForm(akBaseObject))
				Return iSlotIrrelevant
			EndIf
			
			Int iLoopIndex = 0
			While(iLoopIndex < kFLSTBannedKeywords.GetSize())
				If(akBaseObject.HasKeyword(kFLSTBannedKeywords.GetAt(iLoopIndex) as Keyword))
					Return iSlotIrrelevant
				EndIf
				iLoopIndex += 1
			EndWhile
			
			Weapon kWeapon = akBaseObject as Weapon
			If(kWeapon)		
				int iSlot = kWeapon.GetWeaponType()
				iSlot -= 1 ;Remove Fists
				If(iSlot == iSlotStaff) ;Adjust greatsword to 2h Slot
				 iSlot += 1
				ElseIf(iSlot == iSlotMisplacedStaff)
					iSlot = iSlotStaff ;Set Staff to 4
				ElseIf(iSlot > iSlot2HMelee)
					iSlot = iSlotRange ;Any Remaining Weapons are Bows/Crossbows
				EndIf
				;Trace("AllGUD   " + akBaseObject.GetName() + " is assigned to slot " + iSlot)
				Return iSlot
			Else
				Armor kArmor = akBaseObject as Armor
				If(kArmor)
					If(kArmor.IsShield())
						Return iSlotShield
					EndIf
				EndIf
			EndIf
		EndIf
		Return iSlotIrrelevant
	EndFunction

	Function UpdateSlots()
		;Trace("AllGUD  Update Slots Called")
		If(bProcessingUpdate)
			;Trace("AllGUD  Update already running, new update queued")
			bUpdateQueued = True
		Else
			bProcessingUpdate = True
			Int iLoopIndex = 0
			
			;Mute both equip & unequip noises for the duration
		;	Float fAttenuation = kSNDRUnequipArmor.GetDecibelAttenuation()
		;	Int iVariance = kSNDRUnequipArmor.GetDecibelVariance()
		;	kSNDRUnequipArmor.SetDecibelAttenuation(100.0)
		;	kSNDRUnequipArmor.SetDecibelVariance(0)
			While(iLoopIndex < iSlotCount)				
				If(bSlotUpdateFlagged[iLoopIndex] && kSlotVisual[iLoopIndex])
					;Does having the armor count check here add too much delay to change?
					If(bSlotEquipped[iLoopIndex]) ;Equip it
						EquipSlot(iLoopIndex)
						
						;XPMSE-restyle Distinct Weapon-type positions
						if(bReAlignNodes && bXPMSEInstalled) ;Displayed weapon may differ last restyled weapon.
							;Only necessary for WeaponBack and WeaponBow(2HMelee and 2HRange)
							If(iLoopIndex == iSlot2HMelee || iLoopIndex == iSlotRange)
								Weapon kWeapon = kSlotItem[iLoopIndex] as Weapon
								If(iLoopIndex == iSlot2HMelee) ;GreatSword/Polearms
									If(bTwoHMeleeIsGreatsword)
										If(kWeapon.GetWeaponType() == 6) ;Polearm WeaponType
											bTwoHMeleeIsGreatsword = False
											UpdateNiNode(iNodeTwoHMelee)
										EndIf
									ElseIf(kWeapon.GetWeaponType() == 5) ;Greatsword WeaponType
										bTwoHMeleeIsGreatsword = True
										UpdateNiNode(iNodeTwoHMelee)
									EndIf
								ElseIf(iLoopIndex == iSlotRange) ;Bows/Crossbows
									If(bTwoHRangeIsBow)
										If(kWeapon.GetWeaponType() == 9) ;XBow WeaponType
											bTwoHRangeIsBow = False
											UpdateNiNode(iNodeRange)
										EndIf
									ElseIf(kWeapon.GetWeaponType() == 7) ;Bow WeaponType
										bTwoHRangeIsBow = True
										UpdateNiNode(iNodeRange)
									EndIf
								EndIf
							EndIf
						EndIf
					Else ;Unequip it
						UnequipSlot(iLoopIndex)
					EndIf
					bSlotUpdateFlagged[iLoopIndex] = False
				EndIf
				iLoopIndex += 1
			EndWhile
		;	kSNDRUnequipArmor.SetDecibelVariance(iVariance)
		;	kSNDRUnequipArmor.SetDecibelAttenuation(fAttenuation)
			
			bProcessingUpdate = False
			;Recursion if a new update was queued
			If(bUpdateQueued)
				;Allow time for slot changes to happen
				Utility.WaitMenuMode(0.1)
				bUpdateQueued = False
				UpdateSlots()
			EndIf
		EndIf
	EndFunction

	Function EquipSlot(Int aiSlot)
		;If(!bRemoveWeaponsWithoutArmor || PlayerRef.GetWornForm(iSlotMaskTorso)) ;This is a lot of checks.. Maybe use a state for this
		If((aiSlot > iSlotIrrelevant) && (bDisplayPWeapon))
			
			If(PlayerRef.GetItemCount(kSlotVisual[aiSlot]) == 0)
				PlayerRef.AddItem(kSlotVisual[aiSlot], 1, true)
			EndIf
					
			;Trace("AllGUD   Equipping slot at index " + aiSlot)
			If(aiSlot == iSlotShield)
				If((bShieldHide && bWearingBackItem) || (bShieldOnArm && (iSlotLeftHand == iSlotShield)))
					;Trace("AllGUD   Actually, nevermind, not equipping shield due to back problems or personal preference") ;Don't think i need this section?
						kSNDRUnequipArmor.SetDecibelAttenuation(100.0)
						kSNDRUnequipArmor.SetDecibelVariance(0)
					PlayerRef.UnequipItemEx(kSlotVisual[aiSlot]) ;Unequip here in case this was called as a result of UpdateShieldSlot()
						kSNDRUnequipArmor.SetDecibelVariance(iVariance)
						kSNDRUnequipArmor.SetDecibelAttenuation(fAttenuation)
				Else
					PlayerRef.EquipItemEx(kSlotVisual[aiSlot])
				EndIf
			ElseIf(kSlotVisual[aiSlot]) ;Volume control used to be here, but was moved upstream to updateslots()
				;Attempting different equipitem commands to avoid the RH model on LH Weapon bug
				;Notes, do not pass True for any "prevent unequip" argument as it interferes with updating the model on draw/sheathe
				PlayerRef.EquipItemEx(kSlotVisual[aiSlot]) ;#0: Displays RH mesh
				;Soo no difference between any of them with regards to the RH model on LH DW bug.
			EndIf
		EndIf
	EndFunction

	Function UnequipSlot(Int aiSlot)
		If(aiSlot > iSlotIrrelevant)
			If(kSlotVisual[aiSlot])
					kSNDRUnequipArmor.SetDecibelAttenuation(100.0)
					kSNDRUnequipArmor.SetDecibelVariance(0)
				;Muting sound fx used to be here, but was moved to updateslots()
				;not muting the sound fx also allows changing the slotmask through mcm to audibly indicate that something has changed
				;Trace("AllGUD   Unequipping " + kSlotVisual[aiSlot].GetName())
				PlayerRef.UnequipItemEx(kSlotVisual[aiSlot]) ;Works best? No visuals seem out of place			
			;	PlayerRef.UnequipItemSlot(iSlotMasks[iSlotMaskIndex[aiSlot]]) ;This method does not work well at all
			;	PlayerRef.UnequipItemEx(kSlotVisual[aiSlot])
					kSNDRUnequipArmor.SetDecibelVariance(iVariance)
					kSNDRUnequipArmor.SetDecibelAttenuation(fAttenuation)
			EndIf
		EndIf
	EndFunction
	
	Function EquipSlots()
		;Trace("AllGUD  Equipping slots")
		Int iLoopIndex=0
		While(iLoopIndex < iSlotCount)
			If(kSlotItem[iLoopIndex])
				bSlotEquipped[iLoopIndex] = True
				;Trace("AllGUD    Slot " + iLoopIndex + " will be equipped, because all slots with objects are being equipped")
				bSlotUpdateFlagged[iLoopIndex] = True
			EndIf
			iLoopIndex += 1
		EndWhile
		UpdateSlots()
	EndFunction

	Function UnequipSlots()
		;Trace("AllGUD  Unequipping slots")
	;	Float fAttenuation = kSNDRUnequipArmor.GetDecibelAttenuation()
	;	Int iVariance = kSNDRUnequipArmor.GetDecibelVariance()
		Int iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			;DO NOT flag or update slots here, to preserve the current display for when EquipSlots is called.
			;Trace("AllGUD    Slot " + iLoopIndex + " will be unequipped, because all slots are being unequipped")
			UnequipSlot(iLoopIndex)
			iLoopIndex += 1
		EndWhile
	EndFunction

	Function DisableSlot(Int aiSlot)
		If(aiSlot > iSlotIrrelevant)
			If(kSlotVisual[aiSlot])
				ClearSlot(aiSlot)
				kSlotVisualDisabled[aiSlot] = kSlotVisual[aiSlot]
				kSlotVisual[aiSlot] = None
				;Trace("AllGUD  Disabled Slot " + aiSlot)
			EndIf
		EndIf
	EndFunction

	Function EnableSlot(Int aiSlot)
		If(aiSlot > iSlotIrrelevant)
			If(kSlotVisualDisabled[aiSlot])			
				kSlotVisual[aiSlot] = kSlotVisualDisabled[aiSlot]
				kSlotVisualDisabled[aiSlot] = None
				;Trace("AllGUD  Enabled Slot "+ aiSlot)
				ClearSlot(aiSlot)
			EndIf
		EndIf
	EndFunction

	Function ClearSlot(Int aiSlot)
		;Removes the currently saved weapon from kSlotItem
		;Trace("AllGUD  Clearing Slot "+ aiSlot)
		If(aiSlot > iSlotIrrelevant) ;valid slot
			sSlotModel[aiSlot] = ""
			bSlotEquipped[aiSlot] = False
			bSlotUpdateFlagged[aiSlot] = True
			If(kSlotItem[aiSlot] && kSlotVisual[aiSlot]) ;Object exists
			;Trace("AllGUD   " + kSlotItem[aiSlot].GetName() + " was kept in slot "+ aiSlot)
				;Used to check if slot was hand object or not, but that has been moved upstream prior to the ClearSlot call
				kSlotItem[aiSlot] = None
				kSlotVisual[aiSlot].GetNthArmorAddon(0).SetModelPath("", False, False)
			EndIf
		EndIf
	EndFunction
	
	Function ClearSlots()
		;Trace("AllGUD Clearing All Slots")
		Int iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			If(iLoopIndex<iSlotLeftStart)
				If(kRightHand != kSlotItem[iLoopIndex] || kRightHand == None)
					ClearSlot(iLoopIndex)
				EndIf
			Else
				If(kLeftHand != kSlotItem[iLoopIndex] || kLeftHand == None)
					ClearSlot(iLoopIndex)
				EndIf
			EndIf
			bSlotLocked[iLoopIndex] = False
			kSlotItemLocked[iLoopIndex] = None
			sSlotLockedModel[iLoopIndex] = ""
			
			iLoopIndex += 1			
		EndWhile
		UpdateSlots()
	EndFunction

	Function ClearCompetition(Int aiSlot)
		;Trace("AllGUD  Clearing slots that share a slot mask with " + aiSlot)
		
		If(!JContainers.fileExistsAtPath(JContainers.userDirectory() + "AllGUD/Competing Slots/Slot"+aiSlot+".json"))
			RegisterCompetitiveSlots(aiSlot)
		EndIf
		Int jaCompetitiveSlots = JValue.readFromFile(JContainers.userDirectory() + "AllGUD/Competing Slots/Slot"+aiSlot+".json")
		
		Int iLoopIndex = 0
		While(iLoopIndex < JArray.Count(jaCompetitiveSlots))
			Int iCompetitionSlot = JArray.getInt(jaCompetitiveSlots, iLoopIndex)
			
			If(iCompetitionSlot < iSlotLeftStart)
				If(kSlotItem[iCompetitionSlot] != kRightHand)
					If(bSlotLocked[iCompetitionSlot])
						UnequipSlot(iCompetitionSlot) ;If UpdateSlots is always called at some point after ClearCompetition, remove this line.
						bSlotEquipped[iCompetitionSlot] = False
						bSlotUpdateFlagged[iCompetitionSlot] = True
					Else
						ClearSlot(iCompetitionSlot)
					EndIf
				EndIf
			ElseIf(kSlotItem[iCompetitionSlot] != kLeftHand)
				If(bSlotLocked[iCompetitionSlot])
					UnequipSlot(iCompetitionSlot) ;If UpdateSlots is always called at some point after ClearCompetition, remove this line.
					bSlotEquipped[iCompetitionSlot] = False
					bSlotUpdateFlagged[iCompetitionSlot] = True
				Else
					ClearSlot(iCompetitionSlot)
				EndIf
			EndIf
			
			iLoopIndex += 1
		EndWhile

		;/ PRE DYNAMIC ARRAY
		Int iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			If(aiSlot != iLoopIndex && iSlotMaskIndex[aiSlot] == iSlotMaskIndex[iLoopIndex])
				If(iLoopIndex < iSlotLeftStart)
					If(kSlotItem[iLoopIndex] != kRightHand)
						If(bSlotLocked[iLoopIndex])
							UnequipSlot(iLoopIndex) ;If UpdateSlots is always called at some point after ClearCompetition, remove this line.
							bSlotEquipped[iLoopIndex] = False
							bSlotUpdateFlagged[iLoopIndex] = True
						Else
							ClearSlot(iLoopIndex)
						EndIf
					EndIf
				ElseIf(kSlotItem[iLoopIndex] != kLeftHand)
					If(bSlotLocked[iLoopIndex])
						UnequipSlot(iLoopIndex) ;If UpdateSlots is always called at some point after ClearCompetition, remove this line.
						bSlotEquipped[iLoopIndex] = False
						bSlotUpdateFlagged[iLoopIndex] = True
					Else
						ClearSlot(iLoopIndex)
					EndIf
				EndIf
			EndIf
			iLoopIndex += 1
		EndWhile
		/;
	EndFunction

;###################
;Slot Mask Functions
;###################
	Function SetSlotMaskForSlot(Int aiSlot, Int aiSlotMaskIndex)
		If((aiSlot > iSlotIrrelevant) && (aiSlotMaskIndex >= 0))
			JContainers.removeFileAtPath(JContainers.userDirectory() + "AllGUD/Competing Slots/Slot"+aiSlot+".json")
			Int iOldSlotMask = iSlotMasks[iSlotMaskIndex[aiSlot]]
			Int iNewSlotMask = iSlotMasks[aiSlotMaskIndex]
			If(iOldSlotMask != iNewSlotMask)
				iSlotMaskIndex[aiSlot] = aiSlotMaskIndex
				;Trace("AllGUD  Slot "+aiSlot+"'s slot mask changed, unequipping slot")
				UnequipSlot(aiSlot) ;Doesn't flag it unequipped because updateslots will reequip it
				If(iOldSlotMask == 0x00000000) ;Enabling
					EnableSlot(aiSlot)
				EndIf
				If(kSlotVisual[aiSlot])
					If(iOldSlotMask != 0x00000000)
						kSlotVisual[aiSlot].RemoveSlotFromMask(iOldSlotMask)
						kSlotVisual[aiSlot].GetNthArmorAddon(0).RemoveSlotFromMask(iOldSlotMask)
					EndIf
					If(iNewSlotMask != 0x00000000)
						kSlotVisual[aiSlot].AddSlotToMask(iNewSlotMask)
						kSlotVisual[aiSlot].GetNthArmorAddon(0).AddSlotToMask(iNewSlotMask)
					EndIf
				EndIf
				If(iNewSlotMask == 0x00000000) ;Disabling
					DisableSlot(aiSlot)
				EndIf
				bSlotUpdateFlagged[aiSlot] = True
			EndIf
		EndIf
	EndFunction

	Function ReloadSlotMasks()
		;Trace("AllGUD Reload All Slot Masks")
		Int iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			Int iAssignedSlotMask = iSlotMasks[iSlotMaskIndex[iLoopIndex]] ;Legibility
			;Trace("AllGUD  Assigning " + iAssignedSlotMask + " to "+ iLoopIndex)
			If(iAssignedSlotMask == 0x00000000)
				DisableSlot(iLoopIndex)
			Else;Obviously kSlotVisual exists here if it hasn't been disabled
				If(kSlotVisual[iLoopIndex].GetSlotMask() != iAssignedSlotMask)
					UnequipSlot(iLoopIndex)
					bSlotUpdateFlagged[iLoopIndex] = True
				EndIf
				kSlotVisual[iLoopIndex].SetSlotMask(iAssignedSlotMask)
				kSlotVisual[iLoopIndex].GetNthArmorAddon(0).SetSlotMask(iAssignedSlotMask)
			EndIf
			iLoopIndex += 1
		EndWhile
		If(iSlotLeftHand == iSlotShield && !bWeaponDrawn)
			AddShieldLeftHandSlotMask()
		EndIf
	EndFunction
	
	Function ResetSlotMaskIndexes()
		Int iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			SetSlotMaskForSlot(iLoopIndex, iSlotMaskIndexDefaults[iLoopIndex])
			iLoopIndex += 1
		EndWhile
		iLoopIndex = 0
		While(iLoopIndex < iSlotCount)
			ClearCompetition(iLoopIndex)
			iLoopIndex += 1
		EndWhile
	EndFunction

	;Shield slot ArmorAddon uses iSlotMaskLeftHand to block the shield from appearing on the arm.
	Function AddShieldLeftHandSlotMask()
		If(kSlotVisual[iSlotShield])
			kSlotVisual[iSlotShield].GetNthArmorAddon(0).AddSlotToMask(iSlotMaskLeftHand)
		ElseIf(kSlotVisualDisabled[iSlotShield])
			kSlotVisualDisabled[iSlotShield].GetNthArmorAddon(0).AddSlotToMask(iSlotMaskLeftHand)
		EndIf
	EndFunction
	
	Function RemoveShieldLeftHandSlotMask()
		If(kSlotVisual[iSlotShield])
			kSlotVisual[iSlotShield].GetNthArmorAddon(0).RemoveSlotFromMask(iSlotMaskLeftHand)
		ElseIf(kSlotVisualDisabled[iSlotShield])
			kSlotVisualDisabled[iSlotShield].GetNthArmorAddon(0).RemoveSlotFromMask(iSlotMaskLeftHand)
		EndIf
	EndFunction

;###############
;Model Functions
;###############
	String Function AppendModelPath(String asTarget, String asSuffix)
		;"OnBack" Regular shield
		;"OnBackClk" Shield, when cloak is equipped
		;"Left" Weapon
		;"Sheath" Weapon
		;"Right" Staff specific
		String sBase = StringUtil.Substring(asTarget, 0, (StringUtil.GetLength(asTarget) - 4))
		sBase = sBase + asSuffix + ".nif"
		Return sBase
	EndFunction

	String Function FillSpecificPath(Int aiSlot, Form akBaseObject, Bool bSheathed)
		String sPath = ""
		If(aiSlot > iSlotIrrelevant)
			If(aiSlot == iSlotShield) ;Shield uses DSR Models
				sPath = (akBaseObject as Armor).GetNthArmorAddon(0).GetModelPath(False, False)
				If(bWearingBackItem)
					;If(bShieldHide) ;Hiding shield logic handled elsewhere
					;	sPath = ""
					;ElseIf(bShieldAccommodate)
					If(bShieldAccommodateBackpack && bWearingBackpack)
						sPath = AppendModelPath(sPath, "OnBackClk")
					ElseIf(bShieldAccommodateCloak && bWearingCloak)
						sPath = AppendModelPath(sPath, "OnBackClk")
					Else
						sPath = AppendModelPath(sPath, "OnBack")
					EndIf
				Else
				sPath = AppendModelPath(sPath, "OnBack")
				EndIf
			Else
				sPath = (akBaseObject as Weapon).GetModelPath()
				If(aiSlot >= iSlotLeftStart) ;Left-Handed weapons Use DSR Models
					If(bSheathed)
						sPath = AppendModelPath(sPath, "Left")
					Else
						sPath = AppendModelPath(sPath, "Sheath")
					EndIf
				ElseIf(aiSlot == iSlotStaff) ;RH Staff gets a DSR model
					sPath = AppendModelPath(sPath, "Right")
				ElseIf(aiSlot < iSlotLeftStart) ;New model path to avoid duplicate/invisible weapon & scabbard artifacts
					sPath = AppendModelPath(sPath, "Armor")
				EndIf
			EndIf
		EndIf
		;Trace("AllGUD   Final model path is: " + sPath)
		Return sPath
	EndFunction
	
;################
;Shield Functions
;################
	Function UpdateShieldSlot()
		;Trace("AllGUD   Shield Display Conditions changed, updating model")
		If(iSlotLeftHand == iSlotShield)
			sLeftHandSheathed = FillSpecificPath(iSlotShield, kLeftHand, False)
			sSlotModel[iSlotShield]=sLeftHandSheathed
		ElseIf(kSlotItem[iSlotShield])
			sSlotModel[iSlotShield]=FillSpecificPath(iSlotShield, kSlotItem[iSlotShield], False)
		EndIf
		kSlotVisual[iSlotShield].GetNthArmorAddon(0).SetModelPath(sSlotModel[iSlotShield], False, False)
		If(bSlotEquipped[iSlotShield])
			bSlotUpdateFlagged[iSlotShield] = True
			UpdateSlots()
		EndIf
	EndFunction

	;/
	Function SetBoolSetting(String asParam, Bool abValue)
		If(asParam == "ShieldAccommodate")
			If(bShieldAccommodate != abValue)
				bShieldAccommodate = abValue
				UpdateShieldSlot()
			EndIf
		ElseIf(asParam == "ShieldHide")
			If(bShieldHide != abValue)
				bShieldHide = abValue
				If(bShieldHide)
					bSlotEquipped[iSlotShield] = False
					;Trace("AllGUD   " + iSlotShield + " will be unequipped, because ShieldHide was enabled")
				Else
					bSlotEquipped[iSlotShield] = True
					;Trace("AllGUD   " + iSlotShield + " will be equipped, because ShieldHide was disabled")
				EndIf
				bSlotUpdateFlagged[iSlotShield] = True
				UpdateSlots()
			EndIf
		EndIf
	EndFunction
	/;

;###############
;Spell Functions
;###############
	Bool bCameraFirstPerson = True
	
	Event OnPlayerCameraState(int iOldState, int iNewState)
		If(iNewState == 0)
			bCameraFirstPerson = True
			RemovePlayerVisuals()
				
				kSNDRUnequipArmor.SetDecibelAttenuation(100.0)
				kSNDRUnequipArmor.SetDecibelVariance(0)
				
			Int iLoopIndex = 0
			While(iLoopIndex < iSlotCount)
				If(bSlotHiddenInFirstPerson[iLoopIndex] && bSlotEquipped[iLoopIndex] && kSlotVisual[iLoopIndex])
					PlayerRef.UnequipItemEx(kSlotVisual[iLoopIndex])
				EndIf
				iLoopIndex += 1
			EndWhile
			
				kSNDRUnequipArmor.SetDecibelVariance(iVariance)
				kSNDRUnequipArmor.SetDecibelAttenuation(fAttenuation)
		EndIf
		If(iOldState == 0)
			bCameraFirstPerson = False
			;Trace("AllGUD- Camera was in first person and must now refresh hiteffect visuals to properly reflect current light and shadows")
			;Is there a way to do this per hit effect without having to reapply it?
				;Firstly, what's the issue with them?
				;the first few are fine, the ones after those all act like they have different... normals?
				;Don't see anything in MagicEffect script
			VisualizePlayer()
			
			Int iLoopIndex = 0
			While iLoopIndex < iSlotCount
				If(bSlotHiddenInFirstPerson[iLoopIndex] && bSlotEquipped[iLoopIndex] && kSlotVisual[iLoopIndex])
					PlayerRef.EquipItemEx(kSlotVisual[iLoopIndex])
				EndIf
				iLoopIndex += 1
			EndWhile
		EndIf
	EndEvent
	
	Function EnsureSpellStateCorrect()
		bool hasSpell = PlayerRef.HasSpell(kSPELAllGUDCloak)
		bool needsSpell = (gvbDisplayNPCWeapons.GetValue() != 0.0) || (gvbDisplayNPCItems.GetValue() != 0.0)
		if needsSpell && !hasSpell
			PlayerRef.AddSpell(kSPELAllGUDCloak, False) ;Reapply the cloak in case it was ever removed. Just in case.
		elseif !needsSpell && hasSpell
			PlayerRef.RemoveSpell(kSPELAllGUDCloak) 	;Remove the cloak if no NPC effects configured
		endif
	EndFunction

	Function VisualizePlayer() ;Does not refresh, using this assumes SPELs have been removed already
		EnsureSpellStateCorrect()
		If(!bCameraFirstPerson && bDisplayPMisc)
			If(!bRemoveMiscItemsWithoutArmor || PlayerRef.GetWornForm(iSlotMaskTorso))
				PlayerRef.AddSpell(kSPELPlayerItems, False)
			EndIf
		EndIf
	EndFunction
	
	Function RemovePlayerVisuals()
		PlayerRef.RemoveSpell(kSPELPlayerItems)
	EndFunction

;################
;NiNode Functions
;################
	Function UpdateNiNode(Int aiNode)
		Bool bNodeUpdateRequired = False
		String sWeaponArmorNode
		String sScaleKey = "AllGUD"
		
		;For weapon nodes that support multiple styles for specific weapon types
		;Keep track of which of the specific weapon type is equipped, and update the node to that style.
		If((aiNode == iNodePolearm) || (aiNode == iNodeTwoHMelee))
			sWeaponArmorNode = sWeaponDefaultNodes[iNodeTwoHMelee]+"Armor"
			If(bTwoHMeleeIsGreatsword || !bXPMSEInstalled)
				aiNode = iNodeTwoHMelee
			Else
				aiNode = iNodePolearm
			EndIf
		ElseIf((aiNode == iNodeCrossBow) || (aiNode == iNodeRange))
			sWeaponArmorNode = sWeaponDefaultNodes[iNodeRange]+"Armor"
			If(bTwoHRangeIsBow || !bXPMSEInstalled)
				aiNode = iNodeRange
			Else
				aiNode = iNodeCrossBow
			EndIf
		Else
			sWeaponArmorNode = sWeaponDefaultNodes[aiNode]+"Armor"
		EndIf
		
		If(bReScaleNodes && (bXPMSEInstalled || bECEInstalled)) ;No other rescale supported at this time.
			If bECEInstalled
				NetImmerse.SetNodeScale(PlayerRef, sWeaponArmorNode, fWeaponNodeScale[aiNode], False)
				NetImmerse.SetNodeScale(PlayerRef, sWeaponArmorNode, fWeaponNodeScale[aiNode], True)
			;Check the Scale
			ElseIf(NiOverride.GetNodeTransformScale(PlayerRef, False, bPlayerFemale, sWeaponArmorNode, sScaleKey) != fWeaponNodeScale[aiNode])
				NiOverride.AddNodeTransformScale(PlayerRef, False, bPlayerFemale, sWeaponArmorNode, sScaleKey, fWeaponNodeScale[aiNode])
				NiOverride.AddNodeTransformScale(PlayerRef, True, bPlayerFemale, sWeaponArmorNode, sScaleKey, fWeaponNodeScale[aiNode])
				bNodeUpdateRequired = True
			EndIf
		Else
			If(NiOverride.HasNodeTransformScale(PlayerRef, False, bPlayerFemale, sWeaponArmorNode, sScaleKey))
				NiOverride.RemoveNodeTransformScale(PlayerRef, False, bPlayerFemale, sWeaponArmorNode, sScaleKey)
				NiOverride.RemoveNodeTransformScale(PlayerRef, True, bPlayerFemale, sWeaponArmorNode, sScaleKey)
				fWeaponNodeScale[aiNode] = 1
				bNodeUpdateRequired = True
			EndIf
		EndIf
	
		If(bReAlignNodes && bXPMSEInstalled) ;No other restyle supported at this time
			;Check the Style
			If(NiOverride.GetNodeDestination(PlayerRef, False, bPlayerFemale, sWeaponArmorNode) != sWeaponTargetNodes[aiNode])
				If(NetImmerse.HasNode(PlayerRef, sWeaponTargetNodes[aiNode], False)) ;Skeleton has the node
					NiOverride.SetNodeDestination(PlayerRef, False, bPlayerFemale, sWeaponArmorNode, sWeaponTargetNodes[aiNode])
					NiOverride.SetNodeDestination(PlayerRef, True, bPlayerFemale, sWeaponArmorNode, sWeaponTargetNodes[aiNode])
				Else
					NiOverride.RemoveNodeDestination(PlayerRef, False, bPlayerFemale, sWeaponArmorNode)
					NiOverride.RemoveNodeDestination(PlayerRef, True, bPlayerFemale, sWeaponArmorNode)
				EndIf
				bNodeUpdateRequired = True
			EndIf
		Else ;Remove XPMSE transformations
			If(NiOverride.GetNodeDestination(PlayerRef, False, bPlayerFemale, sWeaponArmorNode) != sWeaponDefaultTargetNodes[aiNode])
				If(NetImmerse.HasNode(PlayerRef, sWeaponDefaultTargetNodes[aiNode], False)) ;Skeleton has the node
					NiOverride.SetNodeDestination(PlayerRef, False, bPlayerFemale, sWeaponArmorNode, sWeaponDefaultTargetNodes[aiNode])
					NiOverride.SetNodeDestination(PlayerRef, True, bPlayerFemale, sWeaponArmorNode, sWeaponDefaultTargetNodes[aiNode])
				Else
					NiOverride.RemoveNodeDestination(PlayerRef, False, bPlayerFemale, sWeaponArmorNode)
					NiOverride.RemoveNodeDestination(PlayerRef, True, bPlayerFemale, sWeaponArmorNode)
				EndIf
				bNodeUpdateRequired = True
			EndIf
		EndIf
		
		;Get proper position and current positions.
		Float[] fNewTransformPosition = new Float[3]
		Float[] fOldTransformPosition = new Float[3]
		
		;Update Position & Scale
		If(bNodeUpdateRequired)
			NiOverride.UpdateNodeTransform(PlayerRef, False, bPlayerFemale, sWeaponArmorNode)
			NiOverride.UpdateNodeTransform(PlayerRef, True, bPlayerFemale, sWeaponArmorNode)
			
			;Attempts at setting an [x,y,z] transformation did not pan out, so set the new local position manually.
			If(bReAlignNodes)
				NetImmerse.GetNodeLocalPosition(PlayerRef, sWeaponDefaultNodes[aiNode], fNewTransformPosition, False)
				NetImmerse.GetNodeLocalPosition(PlayerRef, sWeaponArmorNode, fOldTransformPosition, False)
				NetImmerse.SetNodeLocalPosition(PlayerRef, sWeaponArmorNode, fNewTransformPosition, False)
				
				NetImmerse.GetNodeLocalPosition(PlayerRef, sWeaponDefaultNodes[aiNode], fNewTransformPosition, True)
				NetImmerse.GetNodeLocalPosition(PlayerRef, sWeaponArmorNode, fOldTransformPosition, True)
				NetImmerse.SetNodeLocalPosition(PlayerRef, sWeaponArmorNode, fNewTransformPosition, True)
			EndIf
		ElseIf(bReAlignNodes)
			;Update for armor un/equip or character weight change.
			
			;Third Person
			NetImmerse.GetNodeLocalPosition(PlayerRef, sWeaponDefaultNodes[aiNode], fNewTransformPosition, False)
			NetImmerse.GetNodeLocalPosition(PlayerRef, sWeaponArmorNode, fOldTransformPosition, False)
			If(fNewTransformPosition != fOldTransformPosition)
				NetImmerse.SetNodeLocalPosition(PlayerRef, sWeaponArmorNode, fNewTransformPosition, False)
			EndIf
			;First Person
			NetImmerse.GetNodeLocalPosition(PlayerRef, sWeaponDefaultNodes[aiNode], fNewTransformPosition, True)
			NetImmerse.GetNodeLocalPosition(PlayerRef, sWeaponArmorNode, fOldTransformPosition, True)
			If(fNewTransformPosition != fOldTransformPosition)
				NetImmerse.SetNodeLocalPosition(PlayerRef, sWeaponArmorNode, fNewTransformPosition, True)
			EndIf
		EndIf
		
		;Any reason to move first-person models?
		;	NiOverride.SetNodeDestination(PlayerRef, True, bPlayerFemale, sWeaponArmorNode, sWeaponTargetNodes[aiNode])
		;	NiOverride.UpdateNodeTransform(PlayerRef, True, bPlayerFemale, sWeaponArmorNode)
	EndFunction
	
	Function ReWeighNodes(Bool bXPMSEUpdate)
		;Skeleton nifs, how do they even. Am I right?
		Int iLoopIndex = 0
		Int iLoopTotal = sWeaponDefaultNodes.Length
		If !bXPMSEInstalled
			iLoopTotal = iNodePolearm ;The start of distinct weapon styles.
		EndIf
		While(iLoopIndex < iLoopTotal)
			If(bReAlignNodes && bXPMSEUpdate && bXPMSEInstalled)
				CheckXPMSEStyle(iXPMSEWeaponTypes[iLoopIndex])
			EndIf
			UpdateNiNode(iLoopIndex) ;Style may not change, but position may change in racemenu or due to armor
			iLoopIndex += 1
		EndWhile
	EndFunction
	
	Function ReScaleNodes()
		Int iLoopIndex = 0
		While iLoopIndex < sWeaponDefaultNodes.Length
			CheckWeaponScale(iLoopIndex)
			iLoopIndex += 1
		EndWhile
	EndFunction
	
	Function CheckXPMSEStyle(Int aiWeaponType)
		If(sXPMSEStyleKeys[aiWeaponType] != "")
			Int iTargetStyle = -1
			Int iWeaponNodeIndex
			String sNewWeaponStyle
			
			;XPMSE properties are a mess. Decided to maintain Style arrays instead.
			
			iTargetStyle = NiOverride.GetBodyMorph(PlayerRef, sXPMSEStyleKeys[aiWeaponType], "XPMSE") as Int
			If iTargetStyle>0
				iTargetStyle -= 1
			EndIf
			
		;Daggers
			If(aiWeaponType == iXPMSEWeaponTypes[iNodeDagger])
				iWeaponNodeIndex = iNodeDagger
				sNewWeaponStyle = sXPMSEDagger[iTargetStyle]
				
		;Swords
			ElseIf(aiWeaponType == iXPMSEWeaponTypes[iNodeSword])
				iWeaponNodeIndex = iNodeSword
				sNewWeaponStyle = sXPMSESword[iTargetStyle]
				
		;Axes
			ElseIf(aiWeaponType == iXPMSEWeaponTypes[iNodeAxe])
				iWeaponNodeIndex = iNodeAxe
				sNewWeaponStyle = sXPMSEAxe[iTargetStyle]
				
		;Maces
			ElseIf(aiWeaponType == iXPMSEWeaponTypes[iNodeMace])
				iWeaponNodeIndex = iNodeMace
				sNewWeaponStyle = sXPMSEMace[iTargetStyle]
				
		;2h Swords
			ElseIf(aiWeaponType == iXPMSEWeaponTypes[iNodeTwoHMelee])
				iWeaponNodeIndex = iNodeTwoHMelee
				sNewWeaponStyle = sXPMSEGreatsword[iTargetStyle]

		;2h BAxe&WHam
			ElseIf(aiWeaponType == iXPMSEWeaponTypes[iNodePolearm])
				iWeaponNodeIndex = iNodePolearm
				sNewWeaponStyle = sXPMSEPolearm[iTargetStyle]
				
		;Bow
			ElseIf(aiWeaponType == iXPMSEWeaponTypes[iNodeRange])
				iWeaponNodeIndex = iNodeRange
				sNewWeaponStyle = sXPMSEBow[iTargetStyle]
				
		;Crossbow
			ElseIf(aiWeaponType == iXPMSEWeaponTypes[iNodeCrossBow])
				iWeaponNodeIndex = iNodeCrossBow
				sNewWeaponStyle = sXPMSECrossBow[iTargetStyle]
			EndIf
			
			If(sWeaponTargetNodes[iWeaponNodeIndex] != sNewWeaponStyle)
				sWeaponTargetNodes[iWeaponNodeIndex] = sNewWeaponStyle
				UpdateNiNode(iWeaponNodeIndex)
			EndIf
		EndIf
	EndFunction

	Function CheckWeaponScale(Int aiNode)
	;Calculate the Scale
	;Unlike Styles, which can be set from the MCM, Scales can only change from racemenu.
	;Therefore, it doesn't get checked On[Journal]MenuClose
		Float fNodeScale
		String NiNodeRightHand = "NPC R Hand [RHnd]"
		String NiNodeLeftHand = "NPC L Hand [LHnd]"
	
		Int iNodeScaleSource = aiNode
		If(bReScaleNodes)
			If(aiNode == iNodePolearm)
				iNodeScaleSource = iNodeTwoHMelee
			ElseIf(aiNode == iNodeCrossBow)
				iNodeScaleSource = iNodeRange 	
			EndIf
			If bECEInstalled
				fNodeScale = NetImmerse.GetNodeScale(PlayerRef, sWeaponDefaultNodes[iNodeScaleSource], False)
			Else
				If(NiOverride.HasNodeTransformScale(PlayerRef, False, bPlayerFemale, sWeaponDefaultNodes[iNodeScaleSource], "RMWPlugin"))
					fNodeScale = NiOverride.GetNodeTransformScale(PlayerRef, False, bPlayerFemale, sWeaponDefaultNodes[iNodeScaleSource],"RMWPlugin")
					If(NiOverride.HasNodeTransformScale(PlayerRef, False, bPlayerFemale, sWeaponDefaultNodes[iNodeScaleSource], "RSMPlugin"))
						fNodeScale *= NiOverride.GetNodeTransformScale(PlayerRef, False, bPlayerFemale, sWeaponDefaultNodes[iNodeScaleSource],"RSMPlugin")
					EndIf
				Else
					fNodeScale = 1.0
				EndIf
			EndIf
		Else
			fNodeScale = 1.0
		EndIf
		If(fWeaponNodeScale[aiNode] != fNodeScale)
			fWeaponNodeScale[aiNode] = fNodeScale
			UpdateNiNode(aiNode)
		EndIf
	EndFunction
	
	Event OnXPMSERestyle(Int aiWeaponType)
		;Trace("AllGUD Detected XPMSE Restyle")
		CheckXPMSEStyle(aiWeaponType)
	EndEvent
	
	Event OnRacemenuWeaponUpdate()
		;...It doesn't include what weapon was changed..........................................whyyyyyyy?
		ReWeighNodes(True)
		ReScaleNodes()
	EndEvent
	
	Event OnXPMSEMCMClose(int aiWhatEvenIsThisFor)
		Int iLoopIndex = 0
		While iLoopIndex < iXPMSEWeaponTypes.Length
			CheckXPMSEStyle(iXPMSEWeaponTypes[iLoopIndex])
			iLoopIndex += 1
		EndWhile
	EndEvent
