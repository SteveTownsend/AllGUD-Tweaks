Scriptname AGUD_MCM extends SKI_ConfigBase
{All Geared Up - The script that creates the MCM for the mod.}

import Math
import StringUtil

;Reminder: bForceItem is inverted for the gvb because it is used for the >= count condition.
;So If bForceItem, ItemCount >= 0 ;If !bForceItem, ItemCount >= 1

;########################
;Properties and Variables	Grouped by category
;########################
;Constants
	Actor PlayerRef ;Technically sort of a constant
	String sFormatGold = "{0} gold"
	String sFemalePath = "Female/"
	
	;Important Numbers
	Int iSlotCount = 13
	Int iSlotIrrelevant = -1
	Int iSlotStaff = 4
	Int iSlotTwoHMelee = 5
	Int iSlotRange = 6
	Int iSlotLeftStart = 7
	Int iSlotLeftStaff = 11
	Int iSlotShield = 12
	
;Globals
	Int[] iSlotMasks
	Int[] iSlotMaskIndex
	String[] sSlotMasksClearText
	String[] sSlotLabel
	
	String[] sPositionNames
	String[] sUpperBackPositionNames
	String[] sArtPositionUpperBack
	String[] sInstrumentHipPositions
	String[] sArtPositionInstrumentBack
	String[] sArtPosition
	String[] sLuteColor
	
	Int iIndexCoinPurseTiny = 0
	Int iIndexCoinPurseSmall = 1
	Int iIndexCoinPurseMedium = 2
	Int iIndexCoinPurseLarge = 3
	Int iIndexCoinPurseHuge = 4
	Int iIndexCoinPurseGargantuan = 5
	Int iIndexIngredientSatchel = 6
	Int iIndexPotionHealth = 7
	Int iIndexPotionMagicka = 8
	Int iIndexPotionStamina = 9
	Int iIndexScroll = 10
	Int iIndexTorch = 11
	Int iIndexTorchStrap = 12
	Int iIndexLute = 13
	Int iIndexHorn = 14
	Int iIndexFlute = 15
	Int iIndexDrum = 16
	Int iIndexAzurasStar = 17
	Int iIndexElderScroll = 18
	Int iIndexWhitePhial = 19
	Int iIndexWhitePhialStrap = 20
	Int iIndexSkooma = 21
		
;MCM States
	Int iSubMenuLevel = 0
	Bool bConfigOpen = False	;variable is queried when updating models outside of MCM
	Bool bUpdatedPlayerVisuals = False
	Bool bUpdatedNPCVisuals = False
	Bool bUpdatedNPCWeapons = False
	Bool bPageChange = True
	
;Hotkeys - Hotkeys are registered in the System script
	Int iOptionHKeyPlayerWeapon
	Int iOptionHKeyPlayerItem
	Int iOptionHKeyNPCWeapon
	Int iOptionHKeyNPCItem
	
;Player Weapons
	Int iOptionTogglePlayerWeapon
	
	Int[] iOptionSlotMask
	Int[] iOptionSlotLock
	Int[] iOptionSlotHiddenFP
	Int iOptionFirstPersonWeapons
	Int[] iOptionFormID
	Int[] iOptionFormIDState
	Int[] iOptionModelPath
	
	Int iOptionClearSlots
		
	Int iOptionShieldAccommodateCloak
	Int iOptionShieldAccommodateBackpack
	Int iOptionShieldHide
	Int iOptionShieldOnArm
	
	Int iOptionNodeRealignment
	Int iOptionNodeRescale
	
	Int iOptionSaveDefaults
	Int iOptionRestoreDefaults

;Player Items
	Int iOptionTogglePlayerMisc
	Int iOptionToggleItemsRequireArmor
	Int iOptionToggleWeaponsRequireArmor
		
;NPC Weapons
	GlobalVariable Property gvbDisplayNPCWeapons Auto
		Bool bDisplayNPCWeapons = False	;Do not enable on game start, or ulfric will be missing his gag.
		Int iOptionNPCWeaponsToggle
	GlobalVariable Property gvbDisplayNPCShield Auto
		Bool bDisplayNPCShield = True
		Int iOptionNPCShieldToggle
	GlobalVariable Property gvfNPCAttemtInterval Auto
		Float fNPCAttemptInterval = 0.2
		Int iOptionNPCAttemptInterval
	GlobalVariable Property gviNPCAttemptLimit Auto
		Float fNPCAttemptLimit = 10.0
		Int iOptionNPCAttemptLimit
	GlobalVariable Property gvbAutoEquipStaves Auto
		Bool bAutoEquipStaves = False
		Int iOptionNPCEquipStavesToggle
	GlobalVariable Property gvbNPCSleepWeapons Auto
		Bool bNPCSleepWeapons = False
		Int iOptionNPCSleepWeapons
	GlobalVariable Property gvbNPCSleepItems Auto
		Bool bNPCSleepItems = False
		Int iOptionNPCSleepItems
		
	Int iSlotMaskIndexNPCRight = 1
		Int iOptionNPCSlotMaskRight
	Int iSlotMaskIndexNPCLeft = 15
		Int iOptionNPCSlotMaskLeft
	
;NPC Items
	GlobalVariable Property gvbDisplayNPCItems Auto
		Bool bDisplayNPCItems = True
		Int iOptionNPCItemsToggle
	
;Coin Purse
	Int iOptionCoinPursePage
	
	GlobalVariable Property gvbDisplayCoinPurse Auto
		Bool bDisplayCoinPurse = True
		Int iOptionCoinPurseToggle
	
	GlobalVariable Property gviCoinPurseLimit1 Auto
		Float fCoinPurseLimit1 = 1.0
		Int iOptionCoinPurseLimit1
	GlobalVariable Property gviCoinPurseLimit2 Auto
		Float fCoinPurseLimit2 = 50.0
		Int iOptionCoinPurseLimit2
	GlobalVariable Property gviCoinPurseLimit3 Auto
		Float fCoinPurseLimit3 = 100.0
		Int iOptionCoinPurseLimit3
	GlobalVariable Property gviCoinPurseLimit4 Auto
		Float fCoinPurseLimit4 = 150.0
		Int iOptionCoinPurseLimit4
	GlobalVariable Property gviCoinPurseLimit5 Auto
		Float fCoinPurseLimit5 = 200.0
		Int iOptionCoinPurseLimit5
	GlobalVariable Property gviCoinPurseLimit6 Auto
		Float fCoinPurseLimit6 = 250.0
		Int iOptionCoinPurseLimit6
		
	Int iModCoinPurse = 0
		Int iOptionCoinPurseModel
	Int iPosCoinPurse = 5
		Int iOptionCoinPursePosition
	Float fCoinPurseMaxSize = 6.0
		Int iOptionCoinPurseMax
	
	GlobalVariable Property gvbDisplayNPCCoinPurse Auto
		Bool bDisplayNPCCoinPurse = True
		Int iOptionNPCCoinPurseToggle
		
	Int iModNPCCoinPurse = 0
		Int iOptionNPCCoinPurseModel
	Int iPosNPCCoinPurse = 5
		Int iOptionNPCCoinPursePosition
	Float fNPCCoinPurseMaxSize = 6.0
		Int iOptionNPCCoinPurseMax
		
	String[] sModelListCoinPurse
	String[] sPathCoinPurse
;Ingredient Satchel
	GlobalVariable Property gvbDisplayIngredients Auto
		Bool bDisplayIngredients = True
		Int iOptionIngredientSatchelToggle
	GlobalVariable Property gvbForceIngredients Auto
		Bool bForceIngredients = False
		Int iOptionIngredientSatchelForce
		
	Int iModIngredients = 0
		Int iOptionIngredientsModel
	Int iPosIngredients = 4
		Int iOptionIngredientsPosition
	
	GlobalVariable Property gvbDisplayNPCIngredients Auto
		Bool bDisplayNPCIngredients = True
		Int iOptionNPCIngredientsToggle
		
	Int iModNPCIngredients = 0
		Int iOptionNPCIngredientsModel
	Int iPosNPCIngredients = 4
		Int iOptionNPCIngredientsPosition

	String[] sModelListIngredients
	String[] sPathIngredients
;Potions
	GlobalVariable Property gvbDisplayPotions Auto
		Bool bDisplayPotions = True
		Int iOptionPotionsToggle
	GlobalVariable Property gvbForcePotions Auto
		Bool bForcePotions = False
		Int iOptionPotionsForce
	
	Int iModHealthPotion = 0
		Int iOptionHealthPotionModel
	Int iPosHealthPotion = 0
		Int iOptionHealthPotionPosition
	Int iModMagickaPotion = 0
		Int iOptionMagickaPotionModel
	Int iPosMagickaPotion = 0
		Int iOptionMagickaPotionPosition
	Int iModStaminaPotion = 0
		Int iOptionStaminaPotionModel
	Int iPosStaminaPotion = 0
		Int iOptionStaminaPotionPosition
		
	GlobalVariable Property gvbDisplayNPCPotions Auto
		Bool bDisplayNPCPotions = True
		Int iOptionNPCPotionsToggle
	
	Int iModNPCHealthPotion = 0
		Int iOptionNPCHealthPotionModel
	Int iPosNPCHealthPotion = 0
		Int iOptionNPCHealthPotionPosition
	Int iModNPCMagickaPotion = 0
		Int iOptionNPCMagickaPotionModel
	Int iPosNPCMagickaPotion = 0
		Int iOptionNPCMagickaPotionPosition
	Int iModNPCStaminaPotion = 0
		Int iOptionNPCStaminaPotionModel
	Int iPosNPCStaminaPotion = 0
		Int iOptionNPCStaminaPotionPosition
	
	String[] sModelListPotions
	String[] sPathPotions
;Skooma
;/	GlobalVariable Property gvbDisplaySkooma Auto
		Bool bDisplaySkooma = True
		Int iOptionSkoomaToggle
	GlobalVariable Property gvbForceSkooma Auto
		Bool bForceSkooma = False
		Int iOptionSkoomaForce
		
	Int iModSkooma = 0
		Int iOptionSkoomaModel
	Int iPosSkooma = 0
		Int iOptionSkoomaPosition
		
	GlobalVariable Property gvbDisplayNPCSkooma Auto
		Bool bDisplayNPCSkooma = True
		Int iOptionNPCSkoomaToggle
	Int iModNPCSkooma = 0
		Int iOptionNPCSkoomaModel
	Int iPosNPCSkooma = 0
		Int iOptionNPCSkoomaPosition
		
	String[] sModelListSkooma
	String[] sPathSkooma
	/;
;Scroll
	GlobalVariable Property gvbDisplayScroll Auto
		Bool bDisplayScroll = True
		Int iOptionScrollToggle
	GlobalVariable Property gvbForceScroll Auto
		Bool bForceScroll = False
		Int iOptionScrollForce
	
	Int iModScroll = 0
		Int iOptionScrollModel
	Int iPosScroll = 0
		Int iOptionScrollPosition
	
	GlobalVariable Property gvbDisplayNPCScroll Auto
		Bool bDisplayNPCScroll = True
		Int iOptionNPCScrollToggle
	Int iModNPCScroll = 0
		Int iOptionNPCScrollModel
	Int iPosNPCScroll = 0
		Int iOptionNPCScrollPosition
	
	String[] sModelListScrolls
	String[] sPathScrolls
;Torch
	GlobalVariable Property gvbDisplayTorch Auto
		Bool bDisplayTorch = True
		Int iOptionTorchToggle
	GlobalVariable Property gvbForceTorch Auto
		Bool bForceTorch = False
		Int iOptionTorchForce
		
	Int iModTorch = 0
		Int iOptionTorchModel
	Int iPosTorch = 3
		Int iOptionTorchPosition
	
	GlobalVariable Property gvbDisplayNPCTorch Auto
		Bool bDisplayNPCTorch = True
		Int iOptionNPCTorchToggle
	Int iModNPCTorch = 0
		Int iOptionNPCTorchModel
	Int iPosNPCTorch = 3
		Int iOptionNPCTorchPosition
	
	String[] sModelListTorches
	String[] sPathTorches
;Instruments
	GlobalVariable Property gvbDisplayLute Auto
		Bool bDisplayLute = True
		Int iOptionLuteToggle
	GlobalVariable Property gvbForceLute Auto
		Bool bForceLute = False
		Int iOptionLuteForce
	Int iModLute = 0
		Int iOptionLuteModel
	Int iPosLute = 0
		Int iOptionLutePosition
		
	GlobalVariable Property gvbDisplayHorn Auto
		Bool bDisplayHorn = True
		Int iOptionHornToggle
	GlobalVariable Property gvbForceHorn Auto
		Bool bForceHorn = False
		Int iOptionHornForce
	Int iModHorn = 0
		Int iOptionHornModel
	Int iPosHorn = 1
		Int iOptionHornPosition
		
	GlobalVariable Property gvbDisplayFlute Auto
		Bool bDisplayFlute = False
		Int iOptionFluteToggle
	GlobalVariable Property gvbForceFlute Auto
		Bool bForceFlute = False
		Int iOptionFluteForce
	Int iModFlute = 0
		Int iOptionFluteModel
	Int iPosFlute = 1
		Int iOptionFlutePosition
		
	GlobalVariable Property gvbDisplayDrum Auto
		Bool bDisplayDrum = False
		Int iOptionDrumToggle
	GlobalVariable Property gvbForceDrum Auto
		Bool bForceDrum = False
		Int iOptionDrumForce
	Int iModDrum = 0
		Int iOptionDrumModel
	Int iPosDrum = 1
		Int iOptionDrumPosition
	
	GlobalVariable Property gvbDisplayNPCLute Auto
		Bool bDisplayNPCLute = True
		Int iOptionNPCLuteToggle
	Int iModNPCLute = 0
		Int iOptionNPCLuteModel
	Int iPosNPCLute = 0
		Int iOptionNPCLutePosition
		
	GlobalVariable Property gvbDisplayNPCHorn Auto
		Bool bDisplayNPCHorn = True
		Int iOptionNPCHornToggle
	Int iModNPCHorn = 0
		Int iOptionNPCHornModel
	Int iPosNPCHorn = 1
		Int iOptionNPCHornPosition
		
	GlobalVariable Property gvbDisplayNPCFlute Auto
		Bool bDisplayNPCFlute = True
		Int iOptionNPCFluteToggle
	Int iModNPCFlute = 0
		Int iOptionNPCFluteModel
	Int iPosNPCFlute = 1
		Int iOptionNPCFlutePosition
		
	GlobalVariable Property gvbDisplayNPCDrum Auto
		Bool bDisplayNPCDrum = True
		Int iOptionNPCDrumToggle
	Int iModNPCDrum = 0
		Int iOptionNPCDrumModel
	Int iPosNPCDrum = 1
		Int iOptionNPCDrumPosition
		
	String[] sModelListLute
	String[] sPathLute
	String[] sModelListHorn
	String[] sPathHorn
	String[] sModelListFlute
	String[] sPathFlute
	String[] sModelListDrum
	String[] sPathDrum
;Quest Items
	GlobalVariable Property gvbDisplayElderScroll Auto
		Bool bDisplayElderScroll = True
		Int iOptionElderScrollToggle
	Int iPosElderScroll = 0
		Int iOptionElderScrollPosition
		
	GlobalVariable Property gvbDisplayWhitePhial Auto
		Bool bDisplayWhitePhial = True
		Int iOptionWhitePhialToggle
	Int iModWhitePhial = 0
		Int iOptionWhitePhialModel
	Int iPosWhitePhial = 1
		Int iOptionWhitePhialPosition
	
	String[] sModelListWhitePhial
	String[] sPathWhitePhial
	
	GlobalVariable Property gvbDisplayAzurasStar Auto
		Bool bDisplayAzurasStar = True
		Int iOptionAzurasStarToggle
	Int iModAzurasStar = 0
		Int iOptionAzurasStarModel
	Int iPosAzurasStar = 1
		Int iOptionAzurasStarPosition
	
	String[] sModelListAzurasStar
	String[] sPathAzurasStar
		
;Spells
	Spell Property kSPELPlayerItems Auto
	Spell Property kSPELNPCItemsM Auto
	Spell Property kSPELNPCItemsF Auto
	
	AGUD_System Property AGUDSystem Auto ;For Builds
;	Quest Property AGUDSystem Auto ;For CK
;/ /;
;######
;Events
;######
	Int Function GetVersion()
		Return 7 ;Updated the sSlotLabel array
	;	Return 6 ;Added Azura's Star, updated Ingredient Models, updated Potion Models
					;Added AutoEquipStaves Option, no need to reset config
					;Added Skooma & Torso Armor Requirement option
	;	Return 5 ;Added Current Player Equipment Page
	;	Return 4 ;Added More Misc Item Options
	;	Return 3 ;Added Hotkeys page
	EndFunction
	
	Event OnVersionUpdate(Int aiNewVersion)
		If (CurrentVersion < 7)
			If (CurrentVersion < 6)
				;Removed iIndexPotionStraps, advance things down, Added Azura's Star at 17
				iIndexPotionHealth = 7
				iIndexPotionMagicka = 8
				iIndexPotionStamina = 9
				iIndexScroll = 10
				iIndexTorch = 11
				iIndexTorchStrap = 12
				iIndexLute = 13
				iIndexHorn = 14
				iIndexFlute = 15
				iIndexDrum = 16
				iIndexAzurasStar = 17
				iIndexElderScroll = 18
				iIndexWhitePhial = 19
				iIndexWhitePhialStrap = 20
				
				If (CurrentVersion < 4)
				;New Defaults for positions
					iPosCoinPurse = 5
					iPosIngredients = 4
					;Pos for potions got reset in version 6
					iPosScroll = 0
					iPosTorch = 3
					iPosLute = 1
					iPosHorn = 1
					iPosFlute = 1
					iPosDrum = 1
					iPosWhitePhial = 1
					iPosElderScroll = 2
					
					iPosNPCCoinPurse = 5
					iPosNPCIngredients = 4
					;Pos for potions got reset in version 6
					iPosNPCScroll = 0
					iPosNPCTorch = 3
					iPosNPCLute = 1
					iPosNPCHorn = 1
					iPosNPCFlute = 1
					iPosNPCDrum = 1
					
					gvbDisplayNPCItems.SetValue(bDisplayNPCItems as Int)
					AGUDSystem.EnsureSpellStateCorrect()
				EndIf
			EndIf
				
			OnConfigInit()
			
			;Debug.Notification("AllGUD MCM Updated to version " + aiNewVersion)
			Debug.Trace(self + ": Updated script to version " + aiNewVersion)
		EndIf
	EndEvent
	
	Event OnConfigInit()
		ModName = "$AGUName"
		Pages = New String[5]
		Pages[0] = "$Weapons - Player"
		Pages[1] = "$Misc - Player"
		Pages[2] = "$NPC"
		Pages[3] = "$Hotkeys"
		Pages[4] = "$Current Body Slot Info"
		
		iOptionSlotMask = New Int[13]
		iOptionSlotLock = New Int[13]
		iOptionSlotHiddenFP = New Int[13]
		iOptionFormID = New Int[16]
		iOptionModelPath = New Int[16]
		iOptionFormIDState = New Int[16]
		iSlotMaskIndex = New int[13]
		
		iSlotMasks = New Int[16]
		iSlotMasks[0] = 0x00000000 ;-1		The "DISABLED" Slot
		iSlotMasks[1] = 0x00004000 ;44	RH Sword
		iSlotMasks[2] = 0x00008000 ;45	RH Dagger
		iSlotMasks[3] = 0x00010000 ;46		CLOAKS
		iSlotMasks[4] = 0x00020000 ;47		BACKPACKS
		iSlotMasks[5] = 0x00040000 ;48		BACK-LEFT-HIP (Bandolier, Equippable Tomes, Warmonger Armory, etc)
		iSlotMasks[6] = 0x00080000 ;49	RH Mace/Axe
		;50 & 51 Decapitation-related		LEFT HAND RINGS MODIFIED
		iSlotMasks[7] = 0x00400000 ;52	RH Staff				LEFT-SIDE-HIP (Bandolier)
		iSlotMasks[8] = 0x00800000 ;53		TORSO (Bandolier)
		iSlotMasks[9] = 0x01000000 ;54	2H Melee
		iSlotMasks[10] = 0x02000000 ;55		BACK-RIGHT-HIP
		iSlotMasks[11] = 0x04000000 ;56 LH Sword/Dagger/Mace/Axe
		iSlotMasks[12] = 0x08000000 ;57		FRONT-RIGHT-HIP
		iSlotMasks[13] = 0x10000000 ;58		FRONT-LEFT-HIP
		iSlotMasks[14] = 0x20000000 ;59	LH Staff/2H Range		RIGHT-SIDE-HIP (Bandolier)
		iSlotMasks[15] = 0x40000000 ;60 Shield
		
		sSlotMasksClearText = New String[16]
		sSlotMasksClearText[0] = "$Disabled"
		sSlotMasksClearText[1] = "44"
		sSlotMasksClearText[2] = "45"
		sSlotMasksClearText[3] = "46"
		sSlotMasksClearText[4] = "47"
		sSlotMasksClearText[5] = "48"
		sSlotMasksClearText[6] = "49"
		sSlotMasksClearText[7] = "52"
		sSlotMasksClearText[8] = "53"
		sSlotMasksClearText[9] = "54"
		sSlotMasksClearText[10] = "55"
		sSlotMasksClearText[11] = "56"
		sSlotMasksClearText[12] = "57"
		sSlotMasksClearText[13] = "58"
		sSlotMasksClearText[14] = "59"
		sSlotMasksClearText[15] = "60"
		
		sSlotLabel = New String[13]
		sSlotLabel[0] = "$Sword"
		sSlotLabel[1] = "$Dagger"
		sSlotLabel[2] = "$War Axe"
		sSlotLabel[3] = "$Mace"
		sSlotLabel[4] = "$Staff"
		sSlotLabel[5] = "$Two-Hander"
		sSlotLabel[6] = "$Bow"
		sSlotLabel[7] = "$LHSword"
		sSlotLabel[8] = "$LHDagger"
		sSlotLabel[9] = "$LHAxe"
		sSlotLabel[10] = "$LHMace"
		sSlotLabel[11] = "$LHStaff"
		sSlotLabel[12] = "$Shield"

		sPositionNames = New String[7]
		sPositionNames[0] = "$Front-Left"
		sPositionNames[1] = "$Front-Right"
		sPositionNames[2] = "$Back-Left"
		sPositionNames[3] = "$Back-Center-Left"
		sPositionNames[4] = "$Back-Center"
		sPositionNames[5] = "$Back-Center-Right"
		sPositionNames[6] = "$Back-Right"
		
		sArtPosition = New String[7]
		sArtPosition[0] = "FL"
		sArtPosition[1] = "FR"
		sArtPosition[2] = "BL"
		sArtPosition[3] = "BCL"
		sArtPosition[4] = "BC"
		sArtPosition[5] = "BCR"
		sArtPosition[6] = "BR"
		
		sUpperBackPositionNames = New String[4]
		sUpperBackPositionNames[0] = "$Left"
		sUpperBackPositionNames[1] = "$Right"
		sUpperBackPositionNames[2] = "$Lower Left"
		sUpperBackPositionNames[3] = "$Lower Right"
		
		sArtPositionUpperBack = New String[4]
		sArtPositionUpperBack[0] = "UL"
		sArtPositionUpperBack[1] = "UR"
		sArtPositionUpperBack[2] = "LL"
		sArtPositionUpperBack[3] = "LR"
		
		sInstrumentHipPositions = New String[3]
		sInstrumentHipPositions[0] = "$Back-Center-Left"
		sInstrumentHipPositions[1] = "$Back-Center"
		sInstrumentHipPositions[2] = "$Back-Center-Right"
		
	;The non-center ones just don't look good at all
		sArtPositionInstrumentBack = New String[3]
		sArtPositionInstrumentBack[0] = "BCL"
		sArtPositionInstrumentBack[1] = "BC"
		sArtPositionInstrumentBack[2] = "BCR"

		sModelListCoinPurse = New String[3]
		sModelListCoinPurse[0] = "$Small"
		sModelListCoinPurse[1] = "$Medium"
		sModelListCoinPurse[2] = "$Large"
		
		sPathCoinPurse = New String[3]
		sPathCoinPurse[0] = "Small/"
		sPathCoinPurse[1] = "Medium/"
		sPathCoinPurse[2] = "Large/"
		
		sModelListIngredients = New String[3]
		sModelListIngredients[0] = "$Satchel"
		sModelListIngredients[1] = "$Cask"
		sModelListIngredients[2] = "$Mead Flask"
		
		sPathIngredients = New String[3]
		sPathIngredients[0] = "Satchel/"
		sPathIngredients[1] = "Cask/"
		sPathIngredients[2] = "Flask/"
		
		sModelListPotions = New String[4]
		sModelListPotions[0] = "$Lesser"
		sModelListPotions[1] = "$Greater"
		sModelListPotions[2] = "$Plentiful"
		sModelListPotions[3] = "$Ultimate"
	;Transparency causing lighting errors, need to split the models up first	
	;	sModelListPotions[4] = "$Lesser - Pretty Potions"
	;	sModelListPotions[5] = "$Greater - Pretty Potions"
	;	sModelListPotions[6] = "$Plentiful - Pretty Potions"
	;	sModelListPotions[7] = "$Ultimate - Pretty Potions"
	;	sModelListPotions[8] = "$Lesser - Pretty Potions Thick"
	;	sModelListPotions[9] = "$Greater - Pretty Potions Thick"
	;	sModelListPotions[10] = "$Plentiful - Pretty Potions Thick"
	;	sModelListPotions[11] = "$Ultimate - Pretty Potions Thick"
		
		
		sPathPotions = New String[4]
		sPathPotions[0] = "Vanilla/Lesser"
		sPathPotions[1] = "Vanilla/Great"
		sPathPotions[2] = "Vanilla/Extra"
		sPathPotions[3] = "Vanilla/Extreme"
		
	;	sPathPotions[4] = "Pretty Potions/Lesser"
	;	sPathPotions[5] = "Pretty Potions/Great"
	;	sPathPotions[6] = "Pretty Potions/Extra"
	;	sPathPotions[7] = "Pretty Potions/Extreme"
	;	sPathPotions[8] = "Pretty Potions Thick/Lesser"
	;	sPathPotions[9] = "Pretty Potions Thick/Great"
	;	sPathPotions[10] = "Pretty Potions Thick/Extra"
	;	sPathPotions[11] = "Pretty Potions Thick/Extreme"
	
	;	sModelListSkooma = New String[2]
	;	sModelListSkooma[0] = "$Normal"
	;	sModelListSkooma[1] = "$Redwater"
	;	
	;	sPathSkooma = New String[2]
	;	sPathSkooma[0] = ""
	;	sPathSkooma[1] = "RedWater"
		
		sModelListScrolls = New String[6]
		sModelListScrolls[0] = "$Basic"
		sModelListScrolls[1] = "$Sealed"
		sModelListScrolls[2] = "$Bound"
		sModelListScrolls[3] = "$Bound with String"
		sModelListScrolls[4] = "$Umbilicus"
		sModelListScrolls[5] = "$Umbilici"
		
		sPathScrolls = New String[6]
		sPathScrolls[0] = "Model1/"
		sPathScrolls[1] = "Model2/"
		sPathScrolls[2] = "Model3/"
		sPathScrolls[3] = "Model4/"
		sPathScrolls[4] = "Model5/"
		sPathScrolls[5] = "Model6/"
		
		sModelListTorches = New String[1]
		sModelListTorches[0] = "$Vanilla"
	;Need to figure out how to reposition the handle first
	;	sModelListTorches[1] = "$Lantern"
	;	sModelListTorches[2] = "$Lantern-SMIM"
	;	sModelListTorches[3] = "$Lantern-MassiveMaster's"
		
		sPathTorches = New String[1]
		sPathTorches[0] = "Vanilla/"
	;	sPathTorches[1] = "Lantern/"
	;	sPathTorches[2] = "Lantern SMIM/"
	;	sPathTorches[3] = "Lantern MM/"
		
		sModelListLute = New String[1]
		sModelListLute[0] = "$Vanilla"
	;Disabling until permission received
	;	sModelListLute[1] = "$Gold-Accents"
	;	sModelListLute[2] = "$Elegant"
	;	sModelListLute[3] = "$Dark"
	;	sModelListLute[4] = "$Pale"
	;	sModelListLute[5] = "$Faded"
	
		sPathLute = New String[1]
		sPathLute[0] = "Vanilla"
	
		sModelListHorn = New String[2]
		sModelListHorn[0] = "$Vanilla-Right"
		sModelListHorn[1] = "$Vanilla-Left"
	
		sPathHorn = New String[2]
		sPathHorn[0] = "Right"
		sPathHorn[1] = "Left"
		
		sModelListFlute = New String[2]
		sModelListFlute[0] = "$Vanilla-Right"
		sModelListFlute[1] = "$Vanilla-Left"
		
		sPathFlute = New String[2]
		sPathFlute[0] = "Right"
		sPathFlute[1] = "Left"
		
		sModelListDrum = New String[2]
		sModelListDrum[0] = "$Vanilla-Right"
		sModelListDrum[1] = "$Vanilla-Left"
		
		sPathDrum = New String[2]
		sPathDrum[0] = "Right"
		sPathDrum[1] = "Left"
		
		sModelListWhitePhial = New String[3]
		sModelListWhitePhial[0] = "$Vanilla"
		sModelListWhitePhial[1] = "$Saerileth's Replacer"
		sModelListWhitePhial[2] = "$Saerileth's Replacer DG"
		
		sPathWhitePhial = New String[3]
		sPathWhitePhial[0] = "Vanilla/"
		sPathWhitePhial[1] = "Saerileth's Replacer/"
		sPathWhitePhial[2] = "Saerileth's Replacer DG/"
		
		sModelListAzurasStar = New String[3]
		sModelListAzurasStar[0] = "$Broken Star"
		sModelListAzurasStar[1] = "$Azura's Star"
		sModelListAzurasStar[2] = "$Black Star"
		
		sPathAzurasStar = New String[3]
		sPathAzurasStar[0] = "Vanilla/Broken"
		sPathAzurasStar[1] = "Vanilla/Azura"
		sPathAzurasStar[2] = "Vanilla/Black"

		PlayerRef = Game.GetPlayer()
				
		UpdateModelCoins(kSPELPlayerItems)
		UpdateModelCoins(kSPELNPCItemsM)
		UpdateModelIngredients(kSPELPlayerItems)
		UpdateModelIngredients(kSPELNPCItemsM)
		UpdateModelPotions(kSPELPlayerItems)
		UpdateModelPotions(kSPELNPCItemsM)
		UpdateModelScroll(kSPELPlayerItems)
		UpdateModelScroll(kSPELNPCItemsM)
		UpdateModelTorch(kSPELPlayerItems)
		UpdateModelTorch(kSPELNPCItemsM)
		UpdateModelInstruments(kSPELPlayerItems)
		UpdateModelInstruments(kSPELNPCItemsM)
		UpdateModelPlayerOnly()
	EndEvent
	
	Event OnConfigOpen()
		PlayerRef = Game.GetPlayer()
		iSubMenuLevel = 0
		bConfigOpen = True
	EndEvent
	
	Event OnConfigClose()
		bConfigOpen = False
		AGUDSystem.UnregisterToggleKeys(True)	;Reregister hotkeys
	;	RegisterForModEvent("AllGUDMCM_Closed", "OnAllGUDConfigClose")
		If(bUpdatedPlayerVisuals || bUpdatedNPCVisuals || bUpdatedNPCWeapons)
			;DON'T WAIT/UPDATE THEM HERE DELAYS THE MCM
			int handle = ModEvent.Create("AllGUDMCM_Closed")
			if(handle)
				ModEvent.PushBool(handle, bUpdatedPlayerVisuals)
				ModEvent.PushBool(handle, bUpdatedNPCVisuals)
				ModEvent.PushBool(handle, bUpdatedNPCWeapons)
				ModEvent.Send(handle)
			EndIf
			bUpdatedPlayerVisuals = False
			bUpdatedNPCVisuals = False
			bUpdatedNPCWeapons = False
		EndIf
	EndEvent
	
	Event OnAllGUDConfigClose(Bool abUpdatePlayerVisuals, Bool abUpdateNPCVisuals, Bool abUpdateNPCWeapons)
		;Okay to wait on an unrelated thread?
		Utility.Wait(1.0)	;waitmenumode doesn't work.
		If(abUpdatePlayerVisuals)
			RefreshPlayerItems()
		EndIf
		If(abUpdateNPCVisuals)
			RefreshNPCItems()
		EndIf
		If(abUpdateNPCWeapons)
			RefreshNPCWeapons()
		EndIf
	EndEvent

	Event OnPageReset(String asPage)
		SetCursorFillMode(TOP_TO_BOTTOM)
		If(asPage == "")
			LoadCustomContent("AllGUD/Logo.dds", 30.0, 128.0)
			Return
		Else
			UnloadCustomContent()
			
			SetCursorPosition(0)
			If bPageChange
				iSubMenuLevel = 0
			Else
				bPageChange = True
			EndIf
			
			If(asPage == Pages[0])
				If(iSubMenuLevel == 0)
					;Update variables
					Int iLoopIndex = 0
					While(iLoopIndex < iSlotCount)
						iSlotMaskIndex[iLoopIndex] = AGUDSystem.GetiSlotMaskIndex(iLoopIndex)
						iLoopIndex += 1
					EndWhile
				;LEFT
					;Draw the menu
					;SetCursorPosition(0)
					AddHeaderOption("$Weapon Slots")
					;Slot Column
					AddHeaderOption("$Right Hand")
					iLoopIndex = 0
					While(iLoopIndex < iSlotLeftStart)
						iOptionSlotMask[iLoopIndex] = AddMenuOption(sSlotLabel[iLoopIndex], sSlotMasksClearText[iSlotMaskIndex[iLoopIndex]])
						iLoopIndex += 1
					EndWhile

					AddHeaderOption("$Left Hand")
					While(iLoopIndex < iSlotCount)
						iOptionSlotMask[iLoopIndex] = AddMenuOption(sSlotLabel[iLoopIndex], sSlotMasksClearText[iSlotMaskIndex[iLoopIndex]])
						iLoopIndex += 1
					EndWhile
					
					AddHeaderOption("$Display Options")
					iOptionShieldAccommodateCloak = AddToggleOption("$ShieldAccommodateCloak", AGUDSystem.bShieldAccommodateCloak)
					iOptionShieldAccommodateBackpack = AddToggleOption("$ShieldAccommodateBackpack", AGUDSystem.bShieldAccommodateBackpack)
					iOptionShieldHide = AddToggleOption("$ShieldHide", AGUDSystem.bShieldHide)
					iOptionShieldOnArm = AddToggleOption("$ShieldOnArm", AGUDSystem.bShieldOnArm)
					iOptionToggleWeaponsRequireArmor = AddToggleOption("$Armor Auto-Toggles", AGUDSystem.bRemoveWeaponsWithoutArmor)
					iOptionFirstPersonWeapons = AddTextOption("","$SlotsToBeHiddenInFP")

				;RIGHT	
					;Lock-in Column
					SetCursorPosition(1)
					iOptionTogglePlayerWeapon = AddToggleOption("$Enable Weapons",AGUDSystem.bDisplayPWeapon)
					AddHeaderOption("$Lock-In Slot")
					String sItemName = ""
					iLoopIndex = 0
					While(iLoopIndex < iSlotCount)
						If(iLoopIndex == 7)
							AddEmptyOption()	;The left-hand header blank space.
						EndIf
						If(AGUDSystem.GetbSlotLocked(iLoopIndex)) ;For Locked-in Slots, grab their locked items, not the hand item.
							iOptionSlotLock[iLoopIndex] = AddToggleOption(AGUDSystem.GetkSlotLockedItemName(iLoopIndex), AGUDSystem.GetbSlotLocked(iLoopIndex))
						Else
							;Check every other slot and disable this one if necessary, but still list the weapon in the slot.
							;Can't SetOptionFlags on page reset.
							;Really wish I could push these damn things into an array
							Bool bConflictWithLocked = False
							Int iLoopTwoIndex = 0
							While(iLoopTwoIndex < iSlotCount)
								;Found a Different slot with same slotmask is Locked-in and has a weapon saved.
								If((iLoopTwoIndex != iLoopIndex) && (iSlotMaskIndex[iLoopIndex] == iSlotMaskIndex[iLoopTwoIndex]) && (AGUDSystem.GetbSlotLocked(iLoopTwoIndex)) && (AGUDSystem.GetkSlotLockedItem(iLoopTwoIndex) != None))
									iLoopTwoIndex = iSlotCount
									bConflictWithLocked = True
								EndIf
								iLoopTwoIndex += 1
							EndWhile
							Int iAltSlot = -1
							If(iLoopIndex <= iSlotStaff)
								iAltSlot = iLoopIndex + iSlotLeftStart
							ElseIf(iLoopIndex >= iSlotLeftStart && iLoopIndex <= iSlotLeftStaff)
								iAltSlot = iLoopIndex - iSlotLeftStart
							EndIf
							
							;Check if alt slot slot is locked-in same weapon with only 1 copy.
							If(iAltSlot > iSlotIrrelevant)
								If(AGUDSystem.GetbSlotLocked(iAltSlot) && (AGUDSystem.GetkSlotLockedItem(iAltSlot) == AGUDSystem.GetkSlotItem(iLoopIndex)))
									If(PlayerRef.GetItemCount(AGUDSystem.GetkSlotItem(iLoopIndex)) == 1)
										bConflictWithLocked = True
									EndIf								
								EndIf
							EndIf
							
							;Can't set disabledflag during a pagereset, have to set on creation.
							If(bConflictWithLocked)
								iOptionSlotLock[iLoopIndex] = AddToggleOption(AGUDSystem.GetkSlotItemName(iLoopIndex), AGUDSystem.GetbSlotLocked(iLoopIndex), OPTION_FLAG_DISABLED)
							Else
								iOptionSlotLock[iLoopIndex] = AddToggleOption(AGUDSystem.GetkSlotItemName(iLoopIndex), AGUDSystem.GetbSlotLocked(iLoopIndex))
							EndIf
						EndIf
						iLoopIndex += 1
					EndWhile
					
					AddHeaderOption("$Default Body Slots")
					iOptionSaveDefaults = AddTextOption("", "$Save Default Slots")
					iOptionRestoreDefaults = AddTextOption("", "$Restore Defaults")
					
					AddHeaderOption("$Misc")
					iOptionClearSlots = AddTextOption("","$Reset Slots")
					
					AddHeaderOption("$NiNode Options")
					iOptionNodeRealignment = AddToggleOption("$ReAlignNodes",AGUDSystem.bReAlignNodes)
					iOptionNodeRescale = AddToggleOption("$ReScaleNodes",AGUDSystem.bReScaleNodes)
				ElseIf(iSubMenuLevel == 1)
					;SetCursorPosition(0)
					AddTextOptionST("stBackButton", "$Back", "")
					If(iSubMenuLevel == 1)
						SetTitleText("$HiddenInFirstPerson")
						
						Int iLoopIndex = 0
						While(iLoopIndex < iSlotCount)
							AddTextOption(sSlotLabel[iLoopIndex], "", OPTION_FLAG_DISABLED)
							iLoopIndex += 1
						EndWhile
						
						SetCursorPosition(3)
						iLoopIndex = 0
						While(iLoopIndex < iSlotCount)
							iOptionSlotHiddenFP[iLoopIndex] = AddToggleOption("$Hidden", AGUDSystem.GetbSlotFPHidden(iLoopIndex))
							iLoopIndex += 1
						EndWhile
					EndIf
				EndIf
			ElseIf(asPage == Pages[1])
				If(iSubMenuLevel == 0)
				;SetCursorPosition(0)
					AddHeaderOption("$Display Items")
					iOptionToggleItemsRequireArmor = AddToggleOption("$Require Torso Armor", AGUDSystem.bRemoveMiscItemsWithoutArmor)

					AddHeaderOption("$Coin Purse")
					iOptionCoinPurseToggle = AddToggleOption("$Enable", bDisplayCoinPurse)
					iOptionCoinPurseModel = AddMenuOption("$Model", sModelListCoinPurse[iModCoinPurse])
					
					AddHeaderOption("$Ingredient Satchel")
					iOptionIngredientSatchelToggle = AddToggleOption("$Enable", bDisplayIngredients)
					iOptionIngredientsModel = AddMenuOption("$Model", sModelListIngredients[iModIngredients])
					
					AddHeaderOption("$Potions")
					iOptionPotionsToggle = AddToggleOption("$Enable", bDisplayPotions)
					iOptionHealthPotionModel = AddMenuOption("$Health Model", sModelListPotions[iModHealthPotion])
					iOptionMagickaPotionModel = AddMenuOption("$Magicka Model", sModelListPotions[iModMagickaPotion])
					iOptionStaminaPotionModel = AddMenuOption("$Stamina Model", sModelListPotions[iModStaminaPotion])
					
					AddHeaderOption("$Scroll")
					iOptionScrollToggle = AddToggleOption("$Enable", bDisplayScroll)
					iOptionScrollModel = AddMenuOption("$Model", sModelListScrolls[iModScroll])
					
					AddHeaderOption("$Torch")
					iOptionTorchToggle = AddToggleOption("$Enable", bDisplayTorch)
					iOptionTorchModel = AddMenuOption("$Model", sModelListTorches[iModTorch])
					
					AddEmptyOption()
					AddHeaderOption("$Instruments")
					
					AddHeaderOption("$Lute")
					iOptionLuteToggle = AddToggleOption("$Enable", bDisplayLute)
					iOptionLuteModel = AddMenuOption("$Model", sModelListLute[iModLute])
					
					AddHeaderOption("$Horn")
					iOptionHornToggle = AddToggleOption("$Enable", bDisplayHorn)
					iOptionHornModel = AddMenuOption("$Model", sModelListHorn[iModHorn])
					
					AddHeaderOption("$Flute")
					iOptionFluteToggle = AddToggleOption("$Enable", bDisplayFlute)
					iOptionFluteModel = AddMenuOption("$Model", sModelListFlute[iModFlute])
					
					AddHeaderOption("$Drum")
					iOptionDrumToggle = AddToggleOption("$Enable", bDisplayDrum)
					iOptionDrumModel = AddMenuOption("$Model", sModelListDrum[iModDrum])

					AddEmptyOption()
					AddHeaderOption("$Quest Items")
					AddHeaderOption("$Elder Scroll")
					iOptionElderScrollToggle = AddToggleOption("$Enable", bDisplayElderScroll)
					
					AddHeaderOption("$White Phial")
					iOptionWhitePhialToggle = AddToggleOption("$Enable", bDisplayWhitePhial)
					iOptionWhitePhialModel = AddMenuOption("$Model", sModelListWhitePhial[iModWhitePhial])
					
					AddHeaderOption("$Azura's Star")
					iOptionAzurasStarToggle = AddToggleOption("$Enable", bDisplayAzurasStar)
					iOptionAzurasStarModel = AddMenuOption("$Model", sModelListAzurasStar[iModAzurasStar]) ;42
					;22 Spaces left
					
				SetCursorPosition(1)
					iOptionTogglePlayerMisc = AddToggleOption("$Enable Misc Item Display", AGUDSystem.bDisplayPMisc)
					AddEmptyOption()

					iOptionCoinPursePage = AddTextOption("", "$CoinPurseSize")
					iOptionCoinPurseMax = AddSliderOption("$Max Size", fCoinPurseMaxSize)
					iOptionCoinPursePosition = AddMenuOption("$Position", sPositionNames[iPosCoinPurse])
					
					AddEmptyOption()
					iOptionIngredientSatchelForce = AddToggleOption("$Always Show", bForceIngredients)
					iOptionIngredientsPosition = AddMenuOption("$Position", sPositionNames[iPosIngredients])
					
					AddEmptyOption()
					iOptionPotionsForce = AddToggleOption("$Always Show", bForcePotions)
					iOptionHealthPotionPosition = AddMenuOption("$Position", sPositionNames[iPosHealthPotion])
					iOptionMagickaPotionPosition = AddMenuOption("$Position", sPositionNames[iPosMagickaPotion])
					iOptionStaminaPotionPosition = AddMenuOption("$Position", sPositionNames[iPosStaminaPotion])
					
					AddEmptyOption()
					iOptionScrollForce = AddToggleOption("$Always Show", bForceScroll)
					iOptionScrollPosition = AddMenuOption("$Position", sPositionNames[iPosScroll])
					
					AddEmptyOption()
					iOptionTorchForce = AddToggleOption("$Always Show", bForceTorch)
					iOptionTorchPosition = AddMenuOption("$Position", sPositionNames[iPosTorch])
					
					AddEmptyOption()
					AddEmptyOption()	;Instruments
					
					AddEmptyOption()
					iOptionLuteForce = AddToggleOption("$Always Show", bForceLute)
					iOptionLutePosition = AddMenuOption("$Position", sUpperBackPositionNames[iPosLute])
					
					AddEmptyOption()
					iOptionHornForce = AddToggleOption("$Always Show", bForceHorn)
					AddEmptyOption();iOptionHornPosition = AddMenuOption("$Position", sInstrumentHipPositions[iPosHorn])
					
					AddEmptyOption()
					iOptionFluteForce = AddToggleOption("$Always Show", bForceFlute)
					AddEmptyOption();iOptionFlutePosition = AddMenuOption("$Position", sInstrumentHipPositions[iPosFlute])
					
					AddEmptyOption()
					iOptionDrumForce = AddToggleOption("$Always Show", bForceDrum)
					AddEmptyOption();iOptionDrumPosition = AddMenuOption("$Position", sInstrumentHipPositions[iPosDrum])
					
					AddEmptyOption()
					AddEmptyOption();Quest Items
					AddEmptyOption()	;Elder Scroll, Cannot be forced
					iOptionElderScrollPosition = AddMenuOption("$Position", sUpperBackPositionNames[iPosElderScroll])
					
					AddEmptyOption()	;White Phial
					AddEmptyOption()	;White Phial cannot be forced
					iOptionWhitePhialPosition = AddMenuOption("$Position", sPositionNames[iPosWhitePhial])
					
					AddEmptyOption()	;Azura's Star
					AddEmptyOption()	;Azura's Star cannot be forced
					iOptionAzurasStarPosition = AddMenuOption("$Position", sPositionNames[iPosAzurasStar])
					
				ElseIf(iSubMenuLevel == 1)
					;SetCursorPosition(0)
					AddTextOptionST("stBackButton", "$Back", "")
					If(iSubMenuLevel == 1) ;Coin purse
						SetTitleText("$Coin Purse")
						iOptionCoinPurseLimit1 = AddSliderOption("$Stage 1", fCoinPurseLimit1, sFormatGold)
						iOptionCoinPurseLimit2 = AddSliderOption("$Stage 2", fCoinPurseLimit2, sFormatGold)
						iOptionCoinPurseLimit3 = AddSliderOption("$Stage 3", fCoinPurseLimit3, sFormatGold)
						iOptionCoinPurseLimit4 = AddSliderOption("$Stage 4", fCoinPurseLimit4, sFormatGold)
						iOptionCoinPurseLimit5 = AddSliderOption("$Stage 5", fCoinPurseLimit5, sFormatGold)
						iOptionCoinPurseLimit6 = AddSliderOption("$Stage 6", fCoinPurseLimit6, sFormatGold)
					EndIf
				EndIf
			ElseIf(asPage == Pages[2])
				;Draw the menu
				;SetCursorPosition(0)
				AddHeaderOption("$Display Weapons")
				iOptionNPCSlotMaskRight = AddMenuOption("$NPC Right SlotMask", sSlotMasksClearText[iSlotMaskIndexNPCRight])
				iOptionNPCSlotMaskLeft = AddMenuOption("$NPC Left SlotMask", sSlotMasksClearText[iSlotMaskIndexNPCLeft])
				iOptionNPCShieldToggle = AddToggleOption("$NPC ShieldonBack", bDisplayNPCShield)
				iOptionNPCEquipStavesToggle = AddToggleOption("$NPC AutoEquipStaves", bAutoEquipStaves)
				
				SetCursorPosition(1)
				iOptionNPCWeaponsToggle = AddToggleOption("$Enable Weapons", bDisplayNPCWeapons)
				iOptionNPCSleepWeapons = AddToggleOption("$SleepEnable", bNPCSleepWeapons)
				AddHeaderOption("$NPC Script Options")
				iOptionNPCAttemptInterval = AddSliderOption("$NPCScriptAttemptInterval", fNPCAttemptInterval, "{2}")
				iOptionNPCAttemptLimit = AddSliderOption("$NPCScriptAttemptLimit", fNPCAttemptLimit, "{0}")
				
			SetCursorPosition(12)
				AddHeaderOption("$Display Items")
				AddHeaderOption("$Coin Purse")
				iOptionNPCCoinPurseToggle = AddToggleOption("$Enable", bDisplayNPCCoinPurse)
				iOptionNPCCoinPurseModel = AddMenuOption("$Model", sModelListCoinPurse[iModNPCCoinPurse])
				
				AddHeaderOption("$Ingredient Satchel")
				iOptionNPCIngredientsToggle = AddToggleOption("$Enable", bDisplayNPCIngredients)
				iOptionNPCIngredientsModel = AddMenuOption("$Model", sModelListIngredients[iModNPCIngredients])
				
				AddHeaderOption("$Potions")
				iOptionNPCPotionsToggle = AddToggleOption("$Enable", bDisplayNPCPotions)
				iOptionNPCHealthPotionModel = AddMenuOption("$Health Model", sModelListPotions[iModNPCHealthPotion])
				iOptionNPCMagickaPotionModel = AddMenuOption("$Magicka Model", sModelListPotions[iModNPCMagickaPotion])
				iOptionNPCStaminaPotionModel = AddMenuOption("$Stamina Model", sModelListPotions[iModNPCStaminaPotion])
				
				AddHeaderOption("$Scroll")
				iOptionNPCScrollToggle = AddToggleOption("$Enable", bDisplayNPCScroll)
				iOptionNPCScrollModel = AddMenuOption("$Model", sModelListScrolls[iModNPCScroll])
				
				AddHeaderOption("$Torch")
				iOptionNPCTorchToggle = AddToggleOption("$Enable", bDisplayNPCTorch)
				iOptionNPCTorchModel = AddMenuOption("$Model", sModelListTorches[iModNPCTorch])
				
					AddEmptyOption()
				AddHeaderOption("$Instruments")
				AddHeaderOption("$Lute")
				iOptionNPCLuteToggle = AddToggleOption("$Enable", bDisplayNPCLute)
				iOptionNPCLuteModel = AddMenuOption("$Model", sModelListLute[iModNPCLute])
				AddHeaderOption("$Horn")
				iOptionNPCHornToggle = AddToggleOption("$Enable", bDisplayNPCHorn)
				iOptionNPCHornModel = AddMenuOption("$Model", sModelListHorn[iModNPCHorn])
				AddHeaderOption("$Flute")
				iOptionNPCFluteToggle = AddToggleOption("$Enable", bDisplayNPCFlute)
				iOptionNPCFluteModel = AddMenuOption("$Model", sModelListFlute[iModNPCFlute])
				AddHeaderOption("$Drum")
				iOptionNPCDrumToggle = AddToggleOption("$Enable", bDisplayNPCDrum)
				iOptionNPCDrumModel = AddMenuOption("$Model", sModelListDrum[iModNPCDrum])

			SetCursorPosition(13)
				iOptionNPCItemsToggle = AddToggleOption("$Enable Misc Item Display", bDisplayNPCItems)
				iOptionNPCSleepItems = AddToggleOption("$SleepEnable", bNPCSleepItems)
				AddEmptyOption()
				iOptionNPCCoinPurseMax = AddSliderOption("$Max Size", fNPCCoinPurseMaxSize)
				iOptionNPCCoinPursePosition = AddMenuOption("$Position", sPositionNames[iPosNPCCoinPurse])
				
				AddEmptyOption()
				AddEmptyOption()
				iOptionNPCIngredientsPosition = AddMenuOption("$Position", sPositionNames[iPosNPCIngredients])
				
				AddEmptyOption()
				AddEmptyOption()
				iOptionNPCHealthPotionPosition = AddMenuOption("$Position", sPositionNames[iPosNPCHealthPotion])
				iOptionNPCMagickaPotionPosition = AddMenuOption("$Position", sPositionNames[iPosNPCMagickaPotion])
				iOptionNPCStaminaPotionPosition = AddMenuOption("$Position", sPositionNames[iPosNPCStaminaPotion])
				
				AddEmptyOption()
				AddEmptyOption()
				iOptionNPCScrollPosition = AddMenuOption("$Position", sPositionNames[iPosNPCScroll])
				
				AddEmptyOption()
				AddEmptyOption()
				iOptionNPCTorchPosition = AddMenuOption("$Position", sPositionNames[iPosNPCTorch])
				
				AddEmptyOption()
				AddEmptyOption()	;Instruments
				AddEmptyOption()	;Lute
				AddEmptyOption()
				iOptionNPCLutePosition = AddMenuOption("$Position", sUpperBackPositionNames[iPosNPCLute])
				AddEmptyOption()	;Horn
				AddEmptyOption()
				AddEmptyOption();iOptionNPCHornPosition = AddMenuOption("$Position", sInstrumentHipPositions[iPosNPCHorn])
				AddEmptyOption()	;Flute
				AddEmptyOption()
				AddEmptyOption();iOptionNPCFlutePosition = AddMenuOption("$Position", sInstrumentHipPositions[iPosFlute])
				AddEmptyOption()	;Drum
				AddEmptyOption()
				AddEmptyOption();iOptionNPCDrumPosition = AddMenuOption("$Position", sInstrumentHipPositions[iPosDrum])
				
			ElseIf(asPage == Pages[3])
				;SetCursorPosition(0)
				AddHeaderOption("$Hotkeys")
				iOptionHKeyPlayerWeapon = AddKeyMapOption("$Toggle Player Weapons", AGUDSystem.iHKeyPWeapon)
				iOptionHKeyPlayerItem = AddKeyMapOption("$Toggle Player Misc Items", AGUDSystem.iHKeyPItem)
				SetCursorPosition(3)
				iOptionHKeyNPCWeapon = AddKeyMapOption("$Toggle NPC Weapons", AGUDSystem.iHKeyNPCWeapon)
				iOptionHKeyNPCItem = AddKeyMapOption("$Toggle NPC Misc Items", AGUDSystem.iHKeyNPCItem)
			ElseIf(asPage == Pages[4])
				;SetCursorPosition(0)
				AddHeaderOption("$Body Slot Occupation")
				Int iLoopIndex = 1
				While (iLoopIndex < 16)
					Form kEquippedForm = PlayerRef.GetWornForm(iSlotMasks[iLoopIndex])
					If kEquippedForm
						iOptionFormID[iLoopIndex] = AddTextOption(sSlotMasksClearText[iLoopIndex], d2h(kEquippedForm.GetFormID()))
					Else
						iOptionFormID[iLoopIndex] = AddTextOption(sSlotMasksClearText[iLoopIndex],"",OPTION_FLAG_DISABLED)
					EndIf
					iLoopIndex += 1
				EndWhile
				
				SetCursorPosition(1)
				AddHeaderOption("$Name and Model Path")
				iLoopIndex = 1
				While (iLoopIndex < 16)
					Form kEquippedForm = PlayerRef.GetWornForm(iSlotMasks[iLoopIndex])
					If kEquippedForm
						iOptionModelPath[iLoopIndex] = AddTextOption("", kEquippedForm.GetName())
					Else
						AddEmptyOption()
					EndIf
					iLoopIndex += 1
				EndWhile
			EndIf
		EndIf
	EndEvent

;##############
;Option actions
;##############
	State stBackButton
		Event OnSelectST()
			If(iSubMenuLevel != 0)
				iSubMenuLevel = 0
			EndIf
			ForcePageReset()
		EndEvent
	EndState

	Event OnOptionKeyMapChange(int aiOption, int keyCode, string conflictControl, string conflictName)
		Bool continue = true
		
		if (conflictControl != "" && conflictName != "agud_MCM" )
			string msg
			if (conflictName != "")
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf

		if (continue)
			If(aiOption == iOptionHKeyPlayerWeapon)
				AGUDSystem.iHKeyPWeapon = keyCode
			ElseIf(aiOption == iOptionHKeyPlayerItem)
				AGUDSystem.iHKeyPItem = keyCode
			ElseIf(aiOption == iOptionHKeyNPCWeapon)
				AGUDSystem.iHKeyNPCWeapon = keyCode
			ElseIf(aiOption == iOptionHKeyNPCItem)
				AGUDSystem.iHKeyNPCItem = keyCode
			EndIf
			SetKeymapOptionValue(aiOption, keyCode)
		endIf
	EndEvent
	
	Event OnOptionDefault(int aiOption)	;Set KeyMap defaults to -1
		Bool continue = false
		If(aiOption == iOptionHKeyPlayerWeapon)
			AGUDSystem.iHKeyPWeapon = -1
			continue = true
		ElseIf(aiOption == iOptionHKeyPlayerItem)
			AGUDSystem.iHKeyPItem = -1
			continue = true
		ElseIf(aiOption == iOptionHKeyNPCWeapon)
			AGUDSystem.iHKeyNPCWeapon = -1
			continue = true
		ElseIf(aiOption == iOptionHKeyNPCItem)
			AGUDSystem.iHKeyNPCItem = -1
			continue = true
		EndIf
		If continue
			SetKeymapOptionValue(aiOption, -1)
		EndIf
	EndEvent
	
	Event OnOptionSliderOpen(Int aiOption)
		If(aiOption == iOptionCoinPurseLimit1)
			SetSliderDialogStartValue(fCoinPurseLimit1)
			SetSliderDialogDefaultValue(1.0)
			SetSliderDialogRange(0.0, 10000.0)
			SetSliderDialogInterval(1.0)
		ElseIf(aiOption == iOptionCoinPurseLimit2)
			SetSliderDialogStartValue(fCoinPurseLimit2)
			SetSliderDialogDefaultValue(50.0)
			SetSliderDialogRange(0.0, 10000.0)
			SetSliderDialogInterval(1.0)
		ElseIf(aiOption == iOptionCoinPurseLimit3)
			SetSliderDialogStartValue(fCoinPurseLimit3)
			SetSliderDialogDefaultValue(100.0)
			SetSliderDialogRange(0.0, 10000.0)
			SetSliderDialogInterval(1.0)
		ElseIf(aiOption == iOptionCoinPurseLimit4)
			SetSliderDialogStartValue(fCoinPurseLimit4)
			SetSliderDialogDefaultValue(150.0)
			SetSliderDialogRange(0.0, 10000.0)
			SetSliderDialogInterval(1.0)
		ElseIf(aiOption == iOptionCoinPurseLimit5)
			SetSliderDialogStartValue(fCoinPurseLimit5)
			SetSliderDialogDefaultValue(200.0)
			SetSliderDialogRange(0.0, 10000.0)
			SetSliderDialogInterval(1.0)
		ElseIf(aiOption == iOptionCoinPurseLimit6)
			SetSliderDialogStartValue(fCoinPurseLimit6)
			SetSliderDialogDefaultValue(250.0)
			SetSliderDialogRange(0.0, 10000.0)
			SetSliderDialogInterval(1.0)
		ElseIf(aiOption == iOptionNPCAttemptInterval)
			SetSliderDialogStartValue(fNPCAttemptInterval)
			SetSliderDialogDefaultValue(0.2)
			SetSliderDialogRange(0.1, 1.0)
			SetSliderDialogInterval(0.01)
		ElseIf(aiOption == iOptionNPCAttemptLimit)
			SetSliderDialogStartValue(fNPCAttemptLimit)
			SetSliderDialogDefaultValue(10.0)
			SetSliderDialogRange(3.0, 20.0)
			SetSliderDialogInterval(1.0)
		ElseIf(aiOption == iOptionCoinPurseMax)
			SetSliderDialogStartValue(fCoinPurseMaxSize)
			SetSliderDialogDefaultValue(6.0)
			SetSliderDialogRange(1.0, 6.0)
			SetSliderDialogInterval(1.0)
		ElseIf(aiOption == iOptionNPCCoinPurseMax)
			SetSliderDialogStartValue(fNPCCoinPurseMaxSize)
			SetSliderDialogDefaultValue(6.0)
			SetSliderDialogRange(1.0, 6.0)
			SetSliderDialogInterval(1.0)
		EndIf
	EndEvent

	Event OnOptionSliderAccept(Int aiOption, Float afValue)
		If(aiOption == iOptionCoinPurseLimit1)
			fCoinPurseLimit1 = afValue
			gviCoinPurseLimit1.SetValue(afValue)
			SetSliderOptionValue(aiOption, afValue, sFormatGold)
			AdjustCoinNeighbors(iOptionCoinPurseLimit2, True, afValue)
		ElseIf(aiOption == iOptionCoinPurseLimit2)
			fCoinPurseLimit2 = afValue
			gviCoinPurseLimit2.SetValue(afValue)
			SetSliderOptionValue(aiOption, afValue, sFormatGold)
			AdjustCoinNeighbors(iOptionCoinPurseLimit1, False, afValue)
			AdjustCoinNeighbors(iOptionCoinPurseLimit3, True, afValue)
		ElseIf(aiOption == iOptionCoinPurseLimit3)
			fCoinPurseLimit3 = afValue
			gviCoinPurseLimit3.SetValue(afValue)
			SetSliderOptionValue(aiOption, afValue, sFormatGold)
			AdjustCoinNeighbors(iOptionCoinPurseLimit2, False, afValue)
			AdjustCoinNeighbors(iOptionCoinPurseLimit4, True, afValue)
		ElseIf(aiOption == iOptionCoinPurseLimit4)
			fCoinPurseLimit4 = afValue
			gviCoinPurseLimit4.SetValue(afValue)
			SetSliderOptionValue(aiOption, afValue, sFormatGold)
			AdjustCoinNeighbors(iOptionCoinPurseLimit3, False, afValue)
			AdjustCoinNeighbors(iOptionCoinPurseLimit5, True, afValue)
		ElseIf(aiOption == iOptionCoinPurseLimit5)
			fCoinPurseLimit5 = afValue
			gviCoinPurseLimit5.SetValue(afValue)
			SetSliderOptionValue(aiOption, afValue, sFormatGold)
			AdjustCoinNeighbors(iOptionCoinPurseLimit4, False, afValue)
			AdjustCoinNeighbors(iOptionCoinPurseLimit6, True, afValue)
		ElseIf(aiOption == iOptionCoinPurseLimit6)
			fCoinPurseLimit6 = afValue
			gviCoinPurseLimit6.SetValue(afValue)
			SetSliderOptionValue(aiOption, afValue, sFormatGold)
			AdjustCoinNeighbors(iOptionCoinPurseLimit5, False, afValue)
			
		ElseIf(aiOption == iOptionNPCAttemptInterval)
			fNPCAttemptInterval = afValue
			gvfNPCAttemtInterval.SetValue(fNPCAttemptInterval)
			SetSliderOptionValue(aiOption, fNPCAttemptInterval, "{2}")
		ElseIf(aiOption == iOptionNPCAttemptLimit)
			fNPCAttemptLimit = afValue
			gviNPCAttemptLimit.SetValue(fNPCAttemptLimit)
			SetSliderOptionValue(aiOption, fNPCAttemptLimit, "{0}")
			
		ElseIf(aiOption == iOptionCoinPurseMax)
			fCoinPurseMaxSize = afValue
			SetSliderOptionValue(aiOption, fCoinPurseMaxSize, "{0}")
			UpdateModelCoins(kSPELPlayerItems, True)
		ElseIf(aiOption == iOptionNPCCoinPurseMax)
			fNPCCoinPurseMaxSize = afValue
			SetSliderOptionValue(aiOption, fNPCCoinPurseMaxSize, "{0}")
			UpdateModelCoins(kSPELNPCItemsM, True)
			
		EndIf
	EndEvent
	
	 Function AdjustCoinNeighbors(Int aiOption, Bool abForward, Float afNewValue)
		;If limit is lower than the previous size, reduce that size to match.
		;If limit is higher than the next size, raise those to match.
		Bool LimitAdjusted
		Float afOldValue
		If(aiOption == iOptionCoinPurseLimit1)
			afOldValue = fCoinPurseLimit1
		ElseIf(aiOption == iOptionCoinPurseLimit2)
			afOldValue = fCoinPurseLimit2
		ElseIf(aiOption == iOptionCoinPurseLimit3)
			afOldValue = fCoinPurseLimit3
		ElseIf(aiOption == iOptionCoinPurseLimit4)
			afOldValue = fCoinPurseLimit4
		ElseIf(aiOption == iOptionCoinPurseLimit5)
			afOldValue = fCoinPurseLimit5
		ElseIf(aiOption == iOptionCoinPurseLimit6)
			afOldValue = fCoinPurseLimit6
		EndIf
			
		If abForward
			If(afNewValue > afOldValue)
				LimitAdjusted = True
			EndIf
		Else
			If(afNewValue < afOldValue)
				LimitAdjusted = True
			EndIf
		EndIf
		
		If(LimitAdjusted)
			
			If(aiOption == iOptionCoinPurseLimit1)
				fCoinPurseLimit1 = afNewValue
				gviCoinPurseLimit1.SetValue(fCoinPurseLimit1)
			ElseIf(aiOption == iOptionCoinPurseLimit2)
				fCoinPurseLimit2 = afNewValue
				gviCoinPurseLimit2.SetValue(fCoinPurseLimit2)
				If(abForward)
					AdjustCoinNeighbors(iOptionCoinPurseLimit3, abForward, afNewValue)
				Else
					AdjustCoinNeighbors(iOptionCoinPurseLimit1, abForward, afNewValue)
				EndIf
			ElseIf(aiOption == iOptionCoinPurseLimit3)
				fCoinPurseLimit3 = afNewValue
				gviCoinPurseLimit3.SetValue(fCoinPurseLimit3)
				If(abForward)
					AdjustCoinNeighbors(iOptionCoinPurseLimit4, abForward, afNewValue)
				Else
					AdjustCoinNeighbors(iOptionCoinPurseLimit2, abForward, afNewValue)
				EndIf
			ElseIf(aiOption == iOptionCoinPurseLimit4)
				fCoinPurseLimit4 = afNewValue
				gviCoinPurseLimit4.SetValue(fCoinPurseLimit4)
				If(abForward)
					AdjustCoinNeighbors(iOptionCoinPurseLimit5, abForward, afNewValue)
				Else
					AdjustCoinNeighbors(iOptionCoinPurseLimit3, abForward, afNewValue)
				EndIf
			ElseIf(aiOption == iOptionCoinPurseLimit5)
				fCoinPurseLimit5 = afNewValue
				gviCoinPurseLimit5.SetValue(fCoinPurseLimit5)
				If(abForward)
					AdjustCoinNeighbors(iOptionCoinPurseLimit6, abForward, afNewValue)
				Else
					AdjustCoinNeighbors(iOptionCoinPurseLimit4, abForward, afNewValue)
				EndIf
			ElseIf(aiOption == iOptionCoinPurseLimit6)
				fCoinPurseLimit6 = afNewValue
				gviCoinPurseLimit6.SetValue(fCoinPurseLimit6)
			EndIf
			
		SetSliderOptionValue(aiOption, afNewValue, sFormatGold)
		EndIf
	EndFunction

	Event OnOptionMenuOpen(Int aiOption)
	;Player Slots
		If((iOptionSlotMask.Find(aiOption) >= 0))
			SetMenuDialogStartIndex(iSlotMaskIndex[iOptionSlotMask.Find(aiOption)])
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sSlotMasksClearText)
	;NPC Slots
		ElseIf(aiOption == iOptionNPCSlotMaskRight)
			SetMenuDialogStartIndex(iSlotMaskIndexNPCRight)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sSlotMasksClearText)
		ElseIf(aiOption == iOptionNPCSlotMaskLeft)
			SetMenuDialogStartIndex(iSlotMaskIndexNPCLeft)
			SetMenuDialogDefaultIndex(15)
			SetMenuDialogOptions(sSlotMasksClearText)
;Player Items
	;Coin Purse
		ElseIf(aiOption == iOptionCoinPurseModel)
			SetMenuDialogStartIndex(iModCoinPurse)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListCoinPurse)
		ElseIf(aiOption == iOptionCoinPursePosition)
			SetMenuDialogStartIndex(iPosCoinPurse)
			SetMenuDialogDefaultIndex(5)
			SetMenuDialogOptions(sPositionNames)
	;Ingredients
		ElseIf(aiOption == iOptionIngredientsModel)
			SetMenuDialogStartIndex(iModIngredients)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListIngredients)
		ElseIf(aiOption == iOptionIngredientsPosition)
			SetMenuDialogStartIndex(iPosIngredients)
			SetMenuDialogDefaultIndex(4)
			SetMenuDialogOptions(sPositionNames)
	;Potions
		ElseIf(aiOption == iOptionHealthPotionModel)
			SetMenuDialogStartIndex(iModHealthPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListPotions)
		ElseIf(aiOption == iOptionHealthPotionPosition)
			SetMenuDialogStartIndex(iPosHealthPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sPositionNames)
			
		ElseIf(aiOption == iOptionMagickaPotionModel)
			SetMenuDialogStartIndex(iModMagickaPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListPotions)
		ElseIf(aiOption == iOptionMagickaPotionPosition)
			SetMenuDialogStartIndex(iPosMagickaPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sPositionNames)
			
		ElseIf(aiOption == iOptionStaminaPotionModel)
			SetMenuDialogStartIndex(iModStaminaPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListPotions)
		ElseIf(aiOption == iOptionStaminaPotionPosition)
			SetMenuDialogStartIndex(iPosStaminaPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sPositionNames)
	;Scroll
		ElseIf(aiOption == iOptionScrollModel)
			SetMenuDialogStartIndex(iModScroll)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListScrolls)
		ElseIf(aiOption == iOptionScrollPosition)
			SetMenuDialogStartIndex(iPosScroll)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sPositionNames)
	;Torch
		ElseIf(aiOption == iOptionTorchModel)
			SetMenuDialogStartIndex(iModTorch)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListTorches)
		ElseIf(aiOption == iOptionTorchPosition)
			SetMenuDialogStartIndex(iPosTorch)
			SetMenuDialogDefaultIndex(3)
			SetMenuDialogOptions(sPositionNames)
	;Instruments
		ElseIf(aiOption == iOptionLuteModel)
			SetMenuDialogStartIndex(iModLute)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListLute)
		ElseIf(aiOption == iOptionLutePosition)
			SetMenuDialogStartIndex(iPosLute)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sUpperBackPositionNames)
			
		ElseIf(aiOption == iOptionHornModel)
			SetMenuDialogStartIndex(iModHorn)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListHorn)
		ElseIf(aiOption == iOptionHornPosition)
			SetMenuDialogStartIndex(iPosHorn)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sInstrumentHipPositions)
			
		ElseIf(aiOption == iOptionFluteModel)
			SetMenuDialogStartIndex(iModFlute)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListFlute)
		ElseIf(aiOption == iOptionFlutePosition)
			SetMenuDialogStartIndex(iPosFlute)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sInstrumentHipPositions)
			
		ElseIf(aiOption == iOptionDrumModel)
			SetMenuDialogStartIndex(iModDrum)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListDrum)
		ElseIf(aiOption == iOptionDrumPosition)
			SetMenuDialogStartIndex(iPosDrum)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sInstrumentHipPositions)
	;Elder Scroll
		ElseIf(aiOption == iOptionElderScrollPosition)
			SetMenuDialogStartIndex(iPosElderScroll)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sUpperBackPositionNames)
	;White Phial
		ElseIf(aiOption == iOptionWhitePhialModel)
			SetMenuDialogStartIndex(iModWhitePhial)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListWhitePhial)
		ElseIf(aiOption == iOptionWhitePhialPosition)
			SetMenuDialogStartIndex(iPosWhitePhial)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sPositionNames)
	;Azuras Star
		ElseIf(aiOption == iOptionAzurasStarModel)
			SetMenuDialogStartIndex(iModAzurasStar)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListAzurasStar)
		ElseIf(aiOption == iOptionAzurasStarPosition)
			SetMenuDialogStartIndex(iPosAzurasStar)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sPositionNames)
;NPC Items
	;Coin Purse
		ElseIf(aiOption == iOptionNPCCoinPurseModel)
			SetMenuDialogStartIndex(iModNPCCoinPurse)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListCoinPurse)
		ElseIf(aiOption == iOptionNPCCoinPursePosition)
			SetMenuDialogStartIndex(iPosNPCCoinPurse)
			SetMenuDialogDefaultIndex(5)
			SetMenuDialogOptions(sPositionNames)
	;Ingredients
		ElseIf(aiOption == iOptionNPCIngredientsModel)
			SetMenuDialogStartIndex(iModNPCIngredients)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListIngredients)
		ElseIf(aiOption == iOptionNPCIngredientsPosition)
			SetMenuDialogStartIndex(iPosNPCIngredients)
			SetMenuDialogDefaultIndex(4)
			SetMenuDialogOptions(sPositionNames)
	;Potions
		ElseIf(aiOption == iOptionNPCHealthPotionModel)
			SetMenuDialogStartIndex(iModNPCHealthPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListPotions)
		ElseIf(aiOption == iOptionNPCHealthPotionPosition)
			SetMenuDialogStartIndex(iPosNPCHealthPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sPositionNames)
			
		ElseIf(aiOption == iOptionNPCMagickaPotionModel)
			SetMenuDialogStartIndex(iModNPCMagickaPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListPotions)
		ElseIf(aiOption == iOptionNPCMagickaPotionPosition)
			SetMenuDialogStartIndex(iPosNPCMagickaPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sPositionNames)
			
		ElseIf(aiOption == iOptionNPCStaminaPotionModel)
			SetMenuDialogStartIndex(iModNPCStaminaPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListPotions)
		ElseIf(aiOption == iOptionNPCStaminaPotionPosition)
			SetMenuDialogStartIndex(iPosNPCStaminaPotion)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sPositionNames)
	;Scroll
		ElseIf(aiOption == iOptionNPCScrollModel)
			SetMenuDialogStartIndex(iModNPCScroll)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListScrolls)
		ElseIf(aiOption == iOptionNPCScrollPosition)
			SetMenuDialogStartIndex(iPosNPCScroll)
			SetMenuDialogDefaultIndex(4)
			SetMenuDialogOptions(sPositionNames)
	;Torch
		ElseIf(aiOption == iOptionNPCTorchModel)
			SetMenuDialogStartIndex(iModNPCTorch)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListTorches)
		ElseIf(aiOption == iOptionNPCTorchPosition)
			SetMenuDialogStartIndex(iPosNPCTorch)
			SetMenuDialogDefaultIndex(3)
			SetMenuDialogOptions(sPositionNames)
	;Instruments
		ElseIf(aiOption == iOptionNPCLuteModel)
			SetMenuDialogStartIndex(iModNPCLute)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListLute)
		ElseIf(aiOption == iOptionNPCLutePosition)
			SetMenuDialogStartIndex(iPosNPCLute)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sUpperBackPositionNames)
			
		ElseIf(aiOption == iOptionNPCHornModel)
			SetMenuDialogStartIndex(iModNPCHorn)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListHorn)
		ElseIf(aiOption == iOptionNPCHornPosition)
			SetMenuDialogStartIndex(iPosNPCHorn)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sInstrumentHipPositions)
			
		ElseIf(aiOption == iOptionNPCFluteModel)
			SetMenuDialogStartIndex(iModNPCFlute)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListFlute)
		ElseIf(aiOption == iOptionNPCFlutePosition)
			SetMenuDialogStartIndex(iPosNPCFlute)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sInstrumentHipPositions)
			
		ElseIf(aiOption == iOptionNPCDrumModel)
			SetMenuDialogStartIndex(iModNPCDrum)
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(sModelListDrum)
		ElseIf(aiOption == iOptionNPCDrumPosition)
			SetMenuDialogStartIndex(iPosNPCDrum)
			SetMenuDialogDefaultIndex(1)
			SetMenuDialogOptions(sInstrumentHipPositions)
		EndIf
	EndEvent
	
	Event OnOptionMenuAccept(Int aiOption, Int aiIndex)
	;Player Slot Masks
		If((iOptionSlotMask.Find(aiOption) >= 0))
			Int iSlot = iOptionSlotMask.Find(aiOption)
			AGUDSystem.SetSlotMaskForSlot(iSlot, aiIndex)
			iSlotMaskIndex[iSlot] = aiIndex
			SetMenuOptionValue(aiOption, sSlotMasksClearText[aiIndex])
			AGUDSystem.ClearCompetition(iSlot)
			AGUDSystem.UpdateSlots()
			ForcePageReset();Buys time for the update
	;NPC Slot MAsk
		ElseIf(aiOption == iOptionNPCSlotMaskRight)
			iSlotMaskIndexNPCRight = aiIndex
			AGUDSystem.SetSlotMaskForNPCSlot(True, aiIndex)
			bUpdatedNPCWeapons = True
			SetMenuOptionValue(aiOption, sSlotMasksClearText[aiIndex])
			ForcePageReset();Buys time for the update
		ElseIf(aiOption == iOptionNPCSlotMaskLeft)
			iSlotMaskIndexNPCLeft = aiIndex
			AGUDSystem.SetSlotMaskForNPCSlot(False, aiIndex)
			bUpdatedNPCWeapons = True
			SetMenuOptionValue(aiOption, sSlotMasksClearText[aiIndex])
			ForcePageReset();Buys time for the update
;Player Items
	;Coin Purse
		ElseIf(aiOption == iOptionCoinPurseModel)
			iModCoinPurse = aiIndex
			UpdateModelCoins(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListCoinPurse[aiIndex])
		ElseIf(aiOption == iOptionCoinPursePosition)
			iPosCoinPurse = aiIndex
			UpdateModelCoins(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Ingredients
		ElseIf(aiOption == iOptionIngredientsModel)
			iModIngredients = aiIndex
			UpdateModelIngredients(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListIngredients[aiIndex])
		ElseIf(aiOption == iOptionIngredientsPosition)
			iPosIngredients = aiIndex
			UpdateModelIngredients(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Potions
		ElseIf(aiOption == iOptionHealthPotionModel)
			iModHealthPotion = aiIndex
			UpdateModelPotions(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListPotions[aiIndex])
		ElseIf(aiOption == iOptionHealthPotionPosition)
			iPosHealthPotion = aiIndex
			UpdateModelPotions(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
			
		ElseIf(aiOption == iOptionMagickaPotionModel)
			iModMagickaPotion = aiIndex
			UpdateModelPotions(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListPotions[aiIndex])
		ElseIf(aiOption == iOptionMagickaPotionPosition)
			iPosMagickaPotion = aiIndex
			UpdateModelPotions(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
			
		ElseIf(aiOption == iOptionStaminaPotionModel)
			iModStaminaPotion = aiIndex
			UpdateModelPotions(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListPotions[aiIndex])
		ElseIf(aiOption == iOptionStaminaPotionPosition)
			iPosStaminaPotion = aiIndex
			UpdateModelPotions(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Scroll
		ElseIf(aiOption == iOptionScrollModel)
			iModScroll = aiIndex
			UpdateModelScroll(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListScrolls[aiIndex])
		ElseIf(aiOption == iOptionScrollPosition)
			iPosScroll = aiIndex
			UpdateModelScroll(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Torch
		ElseIf(aiOption == iOptionTorchModel)
			iModTorch = aiIndex
			UpdateModelTorch(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListTorches[aiIndex])
		ElseIf(aiOption == iOptionTorchPosition)
			iPosTorch = aiIndex
			UpdateModelTorch(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Instruments
		ElseIf(aiOption == iOptionLuteModel)
			iModLute = aiIndex
			UpdateModelInstruments(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListLute[aiIndex])
		ElseIf(aiOption == iOptionLutePosition)
			iPosLute = aiIndex
			UpdateModelInstruments(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sUpperBackPositionNames[aiIndex])
			
		ElseIf(aiOption == iOptionHornModel)
			iModHorn = aiIndex
			UpdateModelInstruments(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListHorn[aiIndex])
		ElseIf(aiOption == iOptionHornPosition)
			iPosHorn = aiIndex
			UpdateModelInstruments(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sInstrumentHipPositions[aiIndex])
			
		ElseIf(aiOption == iOptionFluteModel)
			iModFlute = aiIndex
			UpdateModelInstruments(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListFlute[aiIndex])
		ElseIf(aiOption == iOptionFlutePosition)
			iPosFlute = aiIndex
			UpdateModelInstruments(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sInstrumentHipPositions[aiIndex])
			
		ElseIf(aiOption == iOptionDrumModel)
			iModDrum = aiIndex
			UpdateModelInstruments(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sModelListDrum[aiIndex])
		ElseIf(aiOption == iOptionDrumPosition)
			iPosDrum = aiIndex
			UpdateModelInstruments(kSPELPlayerItems)
			SetMenuOptionValue(aiOption, sInstrumentHipPositions[aiIndex])
	;Elder Scroll
		ElseIf(aiOption == iOptionElderScrollPosition)
			iPosElderScroll = aiIndex
			UpdateModelPlayerOnly()
			SetMenuOptionValue(aiOption, sUpperBackPositionNames[aiIndex])
	;White Phial
		ElseIf(aiOption == iOptionWhitePhialModel)
			iModWhitePhial = aiIndex
			UpdateModelPlayerOnly()
			SetMenuOptionValue(aiOption, sModelListWhitePhial[aiIndex])
		ElseIf(aiOption == iOptionWhitePhialPosition)
			iPosWhitePhial = aiIndex
			UpdateModelPlayerOnly()
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Azuras Star
		ElseIf(aiOption == iOptionAzurasStarModel)
			iModAzurasStar = aiIndex
			UpdateModelPlayerOnly()
			SetMenuOptionValue(aiOption, sModelListAzurasStar[aiIndex])
		ElseIf(aiOption == iOptionAzurasStarPosition)
			iPosAzurasStar = aiIndex
			UpdateModelPlayerOnly()
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
;NPC Items
	;Coin Purse
		ElseIf(aiOption == iOptionNPCCoinPurseModel)
			iModNPCCoinPurse = aiIndex
			UpdateModelCoins(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListCoinPurse[aiIndex])
		ElseIf(aiOption == iOptionNPCCoinPursePosition)
			iPosNPCCoinPurse = aiIndex
			UpdateModelCoins(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Ingredients
		ElseIf(aiOption == iOptionNPCIngredientsModel)
			iModNPCIngredients = aiIndex
			UpdateModelIngredients(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListIngredients[aiIndex])
		ElseIf(aiOption == iOptionNPCIngredientsPosition)
			iPosNPCIngredients = aiIndex
			UpdateModelIngredients(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Potions
		ElseIf(aiOption == iOptionNPCHealthPotionModel)
			iModNPCHealthPotion = aiIndex
			UpdateModelPotions(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListPotions[aiIndex])
		ElseIf(aiOption == iOptionNPCHealthPotionPosition)
			iPosNPCHealthPotion = aiIndex
			UpdateModelPotions(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
			
		ElseIf(aiOption == iOptionNPCMagickaPotionModel)
			iModNPCMagickaPotion = aiIndex
			UpdateModelPotions(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListPotions[aiIndex])
		ElseIf(aiOption == iOptionNPCMagickaPotionPosition)
			iPosNPCMagickaPotion = aiIndex
			UpdateModelPotions(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
			
		ElseIf(aiOption == iOptionNPCStaminaPotionModel)
			iModNPCStaminaPotion = aiIndex
			UpdateModelPotions(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListPotions[aiIndex])
		ElseIf(aiOption == iOptionNPCStaminaPotionPosition)
			iPosNPCStaminaPotion = aiIndex
			UpdateModelPotions(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Scroll
		ElseIf(aiOption == iOptionNPCScrollModel)
			iModNPCScroll = aiIndex
			UpdateModelScroll(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListScrolls[aiIndex])
		ElseIf(aiOption == iOptionNPCScrollPosition)
			iPosNPCScroll = aiIndex
			UpdateModelScroll(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Torch
		ElseIf(aiOption == iOptionNPCTorchModel)
			iModNPCTorch = aiIndex
			UpdateModelTorch(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListTorches[aiIndex])
		ElseIf(aiOption == iOptionNPCTorchPosition)
			iPosNPCTorch = aiIndex
			UpdateModelTorch(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sPositionNames[aiIndex])
	;Instruments
		ElseIf(aiOption == iOptionNPCLuteModel)
			iModNPCLute = aiIndex
			UpdateModelInstruments(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListLute[aiIndex])
		ElseIf(aiOption == iOptionNPCLutePosition)
			iPosNPCLute = aiIndex
			UpdateModelInstruments(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sUpperBackPositionNames[aiIndex])
			
		ElseIf(aiOption == iOptionNPCHornModel)
			iModNPCHorn = aiIndex
			UpdateModelInstruments(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListHorn[aiIndex])
		ElseIf(aiOption == iOptionNPCHornPosition)
			iPosNPCHorn = aiIndex
			UpdateModelInstruments(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sInstrumentHipPositions[aiIndex])
			
		ElseIf(aiOption == iOptionNPCFluteModel)
			iModNPCFlute = aiIndex
			UpdateModelInstruments(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListFlute[aiIndex])
		ElseIf(aiOption == iOptionNPCFlutePosition)
			iPosNPCFlute = aiIndex
			UpdateModelInstruments(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sInstrumentHipPositions[aiIndex])
			
		ElseIf(aiOption == iOptionNPCDrumModel)
			iModNPCDrum = aiIndex
			UpdateModelInstruments(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sModelListDrum[aiIndex])
		ElseIf(aiOption == iOptionNPCDrumPosition)
			iPosNPCDrum = aiIndex
			UpdateModelInstruments(kSPELNPCItemsM)
			SetMenuOptionValue(aiOption, sInstrumentHipPositions[aiIndex])
			
		EndIf
	EndEvent

	Event OnOptionHighlight(Int aiOption)
		If(iSubMenuLevel == 0)
			If(aiOption == iOptionShieldAccommodateCloak || aiOption == iOptionShieldAccommodateBackpack)
				SetInfoText("$HoverTextAccommodateShield")
			ElseIf(aiOption == iOptionShieldHide)
				SetInfoText("$HoverTextHideShield")
			ElseIf(aiOption == iOptionNodeRealignment)
				SetInfoText("$HoverTextNodes")
			ElseIf(aiOption == iOptionNPCAttemptInterval)
				SetInfoText("$HoverTextAttemptInterval")
			ElseIf(aiOption == iOptionNPCAttemptLimit)
				SetInfoText("$HoverTextAttemptLimit")
			ElseIf(aiOption == iOptionCoinPurseToggle)
				SetInfoText("$HoverTextCoinPurse")
			ElseIf(aiOption == iOptionTorchToggle)
				SetInfoText("$HoverTextTorch")
			ElseIf(aiOption == iOptionNPCWeaponsToggle)
				SetInfoText("$HoverTextNPCWeapons")
			ElseIf(aiOption == iOptionWhitePhialModel)
				SetInfoText("$HoverTextWhitePhialModel")
			ElseIf(aiOption == iOptionNPCEquipStavesToggle)
				SetInfoText("$HoverTextNPCStaves")
			ElseIf(aiOption == iOptionLuteModel || aiOption == iOptionNPCLuteModel)
				SetInfoText("$HoverTextLuteColor")
			ElseIf(iOptionSlotLock.Find(aiOption) >= 0)
				SetInfoText("$HoverTextLockIn")
			ElseIf(aiOption == iOptionSaveDefaults || aiOption == iOptionRestoreDefaults)
				SetInfoText("$HoverTextDefaultSlots")
			ElseIf(aiOption == iOptionHKeyPlayerWeapon) || (aiOption == iOptionHKeyPlayerItem) || (aiOption == iOptionHKeyNPCItem) || (aiOption == iOptionHKeyNPCWeapon)
				SetInfoText("$HoverTextHotkey")
			ElseIf(iOptionFormID.Find(aiOption) >= 0)
				If(PlayerRef.GetWornForm(iSlotMasks[iOptionFormID.Find(aiOption)]) as Armor)
					SetInfoText(GetModFromFormID(PlayerRef.GetWornForm(iSlotMasks[iOptionFormID.Find(aiOption)]).GetFormID()))
				Else
					SetInfoText("")
				EndIf
			ElseIf(iOptionModelPath.Find(aiOption) >= 0)
				If(PlayerRef.GetWornForm(iSlotMasks[iOptionModelPath.Find(aiOption)]) as Armor)
					SetInfoText((PlayerRef.GetWornForm(iSlotMasks[iOptionModelPath.Find(aiOption)]) as Armor).GetNthArmorAddon(0).GetModelPath(False, False))
				Else
					SetInfoText("")
				EndIf
			Else
				SetInfoText("")
			EndIf
		ElseIf(iSubMenuLevel == 1 && CurrentPage == "$Misc - Player")
			SetInfoText("$HoverTextCoinSize")
		EndIf
	EndEvent

	Event OnOptionSelect(Int aiOption)
		If(iSubMenuLevel == 0)
		;PAGE 0 - PLAYER WEAPONS
			If(aiOption == iOptionTogglePlayerWeapon)
				AGUDSystem.TogglePlayerWeaponDisplay()
				SetToggleOptionValue(aiOption, AGUDSystem.bDisplayPWeapon)
			ElseIf(aiOption == iOptionToggleWeaponsRequireArmor)
				AGUDSystem.ToggleWeaponsRequireTorsoArmor()
				SetToggleOptionValue(aiOption, AGUDSystem.bRemoveWeaponsWithoutArmor)
		;SHIELD
			ElseIf(aiOption == iOptionShieldAccommodateCloak)
				AGUDSystem.bShieldAccommodateCloak = !AGUDSystem.bShieldAccommodateCloak
				AGUDSystem.UpdateShieldSlot()
				SetToggleOptionValue(aiOption, AGUDSystem.bShieldAccommodateCloak)
			ElseIf(aiOption == iOptionShieldAccommodateBackpack)
				AGUDSystem.bShieldAccommodateBackpack = !AGUDSystem.bShieldAccommodateBackpack
				AGUDSystem.UpdateShieldSlot()
				SetToggleOptionValue(aiOption, AGUDSystem.bShieldAccommodateBackpack)
			ElseIf(aiOption == iOptionShieldHide)
				AGUDSystem.bShieldHide = !AGUDSystem.bShieldHide
				AGUDSystem.UpdateShieldSlot()
				SetToggleOptionValue(aiOption, AGUDSystem.bShieldHide)
			ElseIf(aiOption == iOptionShieldOnArm)
				AGUDSystem.bShieldOnArm = !AGUDSystem.bShieldOnArm
				AGUDSystem.UpdateShieldSlot()
				SetToggleOptionValue(aiOption, AGUDSystem.bShieldOnArm)
		;SLOT MANAGEMENT
			ElseIf(aiOption == iOptionClearSlots)
				SetOptionFlags(iOptionClearSlots, OPTION_FLAG_HIDDEN)
				AGUDSystem.ClearSlots()
				ForcePageReset()
			ElseIf(aiOption == iOptionNodeRealignment)
				AGUDSystem.bReAlignNodes = !AGUDSystem.bReAlignNodes
				SetToggleOptionValue(aiOption, AGUDSystem.bReAlignNodes)
				AGUDSystem.ReWeighNodes(True)
			ElseIf(aiOption == iOptionNodeRescale)
				AGUDSystem.bReScaleNodes = !AGUDSystem.bReScaleNodes
				SetToggleOptionValue(aiOption, AGUDSystem.bReScaleNodes)
				AGUDSystem.ReScaleNodes()
			ElseIf(iOptionSlotLock.Find(aiOption) >= 0)
				Int iSlot = iOptionSlotLock.Find(aiOption)
				AGUDSystem.TogglebSlotLocked(iSlot)
				SetToggleOptionValue(aiOption, AGUDSystem.GetbSlotLocked(iSlot))
				ForcePageReset()
		;DEFAULT SLOTS
			ElseIf(aiOption == iOptionSaveDefaults)
				SetOptionFlags(iOptionSaveDefaults, OPTION_FLAG_HIDDEN)
				AGUDSystem.SaveSlotMaskDefaults()
				ForcePageReset()
			ElseIf(aiOption == iOptionRestoreDefaults )
				SetOptionFlags(iOptionRestoreDefaults, OPTION_FLAG_HIDDEN)
				AGUDSystem.ResetSlotMaskIndexes()
				ForcePageReset()
				
		;PAGE 1 - PLAYER ITEMS
			ElseIf(aiOption == iOptionTogglePlayerMisc)
				AGUDSystem.TogglePlayerMisc()
				SetToggleOptionValue(aiOption, AGUDSystem.bDisplayPMisc)
			ElseIf(aiOption == iOptionToggleItemsRequireArmor)
				AGUDSystem.ToggleItemsRequireTorsoArmor()
				SetToggleOptionValue(aiOption, AGUDSystem.bRemoveMiscItemsWithoutArmor)
				
		;COIN PURSE
			ElseIf(aiOption == iOptionCoinPurseToggle)
				bDisplayCoinPurse = !bDisplayCoinPurse
				gvbDisplayCoinPurse.SetValue(bDisplayCoinPurse as Int)
				SetToggleOptionValue(aiOption, bDisplayCoinPurse)
				
		;INGREDIENTS
			ElseIf(aiOption == iOptionIngredientSatchelToggle)
				bDisplayIngredients = !bDisplayIngredients
				gvbDisplayIngredients.SetValue(bDisplayIngredients as Int)
				SetToggleOptionValue(aiOption, bDisplayIngredients)
			ElseIf(aiOption == iOptionIngredientSatchelForce)
				bForceIngredients = !bForceIngredients
				gvbForceIngredients.SetValue((!bForceIngredients) as Int)
				SetToggleOptionValue(aiOption, bForceIngredients)

		;POTIONS
			ElseIf(aiOption == iOptionPotionsToggle)
				bDisplayPotions = !bDisplayPotions
				gvbDisplayPotions.SetValue(bDisplayPotions as Int)
				SetToggleOptionValue(aiOption, bDisplayPotions)
			ElseIf(aiOption == iOptionPotionsForce)
				bForcePotions = !bForcePotions
				gvbForcePotions.SetValue((!bForcePotions) as Int)
				SetToggleOptionValue(aiOption, bForcePotions)			
				
		;SCROLL
			ElseIf(aiOption == iOptionScrollToggle)
				bDisplayScroll = !bDisplayScroll
				gvbDisplayScroll.SetValue(bDisplayScroll as Int)
				SetToggleOptionValue(aiOption, bDisplayScroll)
			ElseIf(aiOption == iOptionScrollForce)
				bForceScroll = !bForceScroll
				gvbForceScroll.SetValue((!bForceScroll) as Int)
				SetToggleOptionValue(aiOption, bForceScroll)
				
		;TORCH
			ElseIf(aiOption == iOptionTorchToggle)
				bDisplayTorch = !bDisplayTorch
				gvbDisplayTorch.SetValue(bDisplayTorch as Int)
				SetToggleOptionValue(aiOption, bDisplayTorch)
			ElseIf(aiOption == iOptionTorchForce)
				bForceTorch = !bForceTorch
				gvbForceTorch.SetValue((!bForceTorch) as Int)
				SetToggleOptionValue(aiOption, bForceTorch)
				
		;INSTRUMENTS
			;Lute
			ElseIf(aiOption == iOptionLuteToggle)
				bDisplayLute = !bDisplayLute
				gvbDisplayLute.SetValue(bDisplayLute as Int)
				SetToggleOptionValue(aiOption, bDisplayLute)
			ElseIf(aiOption == iOptionLuteForce)
				bForceLute = !bForceLute
				gvbForceLute.SetValue((!bForceLute) as Int)
				SetToggleOptionValue(aiOption, bForceLute)
			;Horn
			ElseIf(aiOption == iOptionHornToggle)
				bDisplayHorn = !bDisplayHorn
				gvbDisplayHorn.SetValue(bDisplayHorn as Int)
				SetToggleOptionValue(aiOption, bDisplayHorn)
			ElseIf(aiOption == iOptionHornForce)
				bForceHorn = !bForceHorn
				gvbForceHorn.SetValue((!bForceHorn) as Int)
				SetToggleOptionValue(aiOption, bForceHorn)
			;Flute
			ElseIf(aiOption == iOptionFluteToggle)
				bDisplayFlute = !bDisplayFlute
				gvbDisplayFlute.SetValue(bDisplayFlute as Int)
				SetToggleOptionValue(aiOption, bDisplayFlute)
			ElseIf(aiOption == iOptionFluteForce)
				bForceFlute = !bForceFlute
				gvbForceFlute.SetValue((!bForceFlute) as Int)
				SetToggleOptionValue(aiOption, bForceFlute)
			;Drum
			ElseIf(aiOption == iOptionDrumToggle)
				bDisplayDrum = !bDisplayDrum
				gvbDisplayDrum.SetValue(bDisplayDrum as Int)
				SetToggleOptionValue(aiOption, bDisplayDrum)
			ElseIf(aiOption == iOptionDrumForce)
				bForceDrum = !bForceDrum
				gvbForceDrum.SetValue((!bForceDrum) as Int)
				SetToggleOptionValue(aiOption, bForceDrum)
			
		;PLAYER ONLY ITEMS
			ElseIf(aiOption == iOptionElderScrollToggle)
				bDisplayElderScroll = !bDisplayElderScroll
				gvbDisplayElderScroll.SetValue(bDisplayElderScroll as Int)
				SetToggleOptionValue(aiOption, bDisplayElderScroll)
			ElseIf(aiOption == iOptionWhitePhialToggle)
				bDisplayWhitePhial = !bDisplayWhitePhial
				gvbDisplayWhitePhial.SetValue(bDisplayWhitePhial as Int)
				SetToggleOptionValue(aiOption, bDisplayWhitePhial)
			ElseIf(aiOption == iOptionAzurasStarToggle)
				bDisplayAzurasStar = !bDisplayAzurasStar
				gvbDisplayAzurasStar.SetValue(bDisplayAzurasStar as Int)
				SetToggleOptionValue(aiOption, bDisplayAzurasStar)
			
		;PAGE 2 - NPC
		;NPC WEAPONS
			ElseIf(aiOption == iOptionNPCWeaponsToggle)
				If(!AGUDSystem.bAllGUDMaintenance)
					ToggleNPCWeapons()
					SetToggleOptionValue(aiOption, bDisplayNPCWeapons)
				EndIf
			ElseIf(aiOption == iOptionNPCShieldToggle)
				bDisplayNPCShield = !bDisplayNPCShield
				gvbDisplayNPCShield.SetValue(bDisplayNPCShield as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCShield)
			ElseIf(aiOption == iOptionNPCEquipStavesToggle)
				bAutoEquipStaves = !bAutoEquipStaves
				gvbAutoEquipStaves.SetValue(bAutoEquipStaves as Int)
				SetToggleOptionValue(aiOption, bAutoEquipStaves)
			ElseIf(aiOption == iOptionNPCSleepWeapons)
				bNPCSleepWeapons = !bNPCSleepWeapons
				gvbNPCSleepWeapons.SetValue(bNPCSleepWeapons as Int * 5)
				SetToggleOptionValue(aiOption, bNPCSleepWeapons)
		;NPC ITEMS
			ElseIf(aiOption == iOptionNPCItemsToggle)
				ToggleNPCItems()
				SetToggleOptionValue(aiOption, bDisplayNPCItems)
			ElseIf(aiOption == iOptionNPCSleepItems)
				bNPCSleepItems = !bNPCSleepItems
				gvbNPCSleepItems.SetValue(bNPCSleepItems as Int * 5)
				SetToggleOptionValue(aiOption, bNPCSleepItems)
				
		;COIN PURSE
			ElseIf(aiOption == iOptionNPCCoinPurseToggle)
				bDisplayNPCCoinPurse = !bDisplayNPCCoinPurse
				gvbDisplayNPCCoinPurse.SetValue(bDisplayNPCCoinPurse as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCCoinPurse)
				
		;INGREDIENTS
			ElseIf(aiOption == iOptionNPCIngredientsToggle)
				bDisplayNPCIngredients = !bDisplayNPCIngredients
				gvbDisplayNPCIngredients.SetValue(bDisplayNPCIngredients as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCIngredients)
				
		;POTIONS	
			ElseIf(aiOption == iOptionNPCPotionsToggle)
				bDisplayNPCPotions = !bDisplayNPCPotions
				gvbDisplayNPCPotions.SetValue(bDisplayNPCPotions as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCPotions)
				
		;SCROLL	
			ElseIf(aiOption == iOptionNPCScrollToggle)
				bDisplayNPCScroll = !bDisplayNPCScroll
				gvbDisplayNPCScroll.SetValue(bDisplayNPCScroll as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCScroll)
				
		;TORCH	
			ElseIf(aiOption == iOptionNPCTorchToggle)
				bDisplayNPCTorch = !bDisplayNPCTorch
				gvbDisplayNPCTorch.SetValue(bDisplayNPCTorch as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCTorch)
				
		;INSTRUMENTS
			ElseIf(aiOption == iOptionNPCLuteToggle)
				bDisplayNPCLute = !bDisplayNPCLute
				gvbDisplayNPCLute.SetValue(bDisplayNPCLute as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCLute)
				
			ElseIf(aiOption == iOptionNPCHornToggle)
				bDisplayNPCHorn = !bDisplayNPCHorn
				gvbDisplayNPCHorn.SetValue(bDisplayNPCHorn as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCHorn)
				
			ElseIf(aiOption == iOptionNPCFluteToggle)
				bDisplayNPCFlute = !bDisplayNPCFlute
				gvbDisplayNPCFlute.SetValue(bDisplayNPCFlute as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCFlute)
				
			ElseIf(aiOption == iOptionNPCDrumToggle)
				bDisplayNPCDrum = !bDisplayNPCDrum
				gvbDisplayNPCDrum.SetValue(bDisplayNPCDrum as Int)
				SetToggleOptionValue(aiOption, bDisplayNPCDrum)
				
			;SUBMENU 
		;NAVIGATION
			ElseIf(aiOption == iOptionCoinPursePage || aiOption == iOptionFirstPersonWeapons)
				iSubMenuLevel = 1
				bPageChange = False
				ForcePageReset()
			EndIf
		ElseIf(iSubMenuLevel == 1)
			If(iOptionSlotHiddenFP.Find(aiOption) >= 0)
				Int iSlot = iOptionSlotHiddenFP.Find(aiOption)
				AGUDSystem.TogglebSlotHiddenFP(iSlot)
				SetToggleOptionValue(aiOption, AGUDSystem.GetbSlotFPHidden(iSlot))
			EndIf
		EndIf
	EndEvent

;#######################
;Visualization Functions
;#######################
	Function ReloadItemVisualization()
		RefreshNPCWeapons()
		UpdateModelCoins(kSPELPlayerItems)
		UpdateModelIngredients(kSPELPlayerItems)
		UpdateModelPotions(kSPELPlayerItems)
		UpdateModelScroll(kSPELPlayerItems)
		UpdateModelTorch(kSPELPlayerItems)
		UpdateModelInstruments(kSPELPlayerItems)
		UpdateModelPlayerOnly()
		
		UpdateModelCoins(kSPELNPCItemsM)
		UpdateModelIngredients(kSPELNPCItemsM)
		UpdateModelPotions(kSPELNPCItemsM)
		UpdateModelScroll(kSPELNPCItemsM)
		UpdateModelTorch(kSPELNPCItemsM)
		UpdateModelInstruments(kSPELNPCItemsM)
		
		Utility.Wait(1.0)
		If(bUpdatedPlayerVisuals)
			RefreshPlayerItems()
		EndIf
		If(bUpdatedNPCVisuals)
			RefreshNPCItems()
		EndIf
	EndFunction
	
	Function ReloadPlayerItemModels()
		UpdateModelCoins(kSPELPlayerItems)
		UpdateModelIngredients(kSPELPlayerItems)
		UpdateModelPotions(kSPELPlayerItems)
		UpdateModelScroll(kSPELPlayerItems)
		UpdateModelTorch(kSPELPlayerItems)
		UpdateModelInstruments(kSPELPlayerItems)
		UpdateModelPlayerOnly()
		
		Utility.Wait(1.0)
		If(bUpdatedPlayerVisuals)
			RefreshPlayerItems()
		EndIf
	EndFunction
		
	Function RefreshPlayerItems()
		gvbDisplayCoinPurse.SetValue(bDisplayCoinPurse as Int)
		gvbDisplayIngredients.SetValue(bDisplayIngredients as Int)
		gvbDisplayPotions.SetValue(bDisplayPotions as Int)
		gvbDisplayScroll.SetValue(bDisplayScroll as Int)
		gvbDisplayTorch.SetValue(bDisplayTorch as Int)
		gvbDisplayLute.SetValue(bDisplayLute as Int)
		gvbDisplayHorn.SetValue(bDisplayHorn as Int)
		gvbDisplayFlute.SetValue(bDisplayFlute as Int)
		gvbDisplayDrum.SetValue(bDisplayDrum as Int)
		
		gvbDisplayElderScroll.SetValue(bDisplayElderScroll as Int)
		gvbDisplayWhitePhial.SetValue(bDisplayWhitePhial as Int)
		gvbDisplayAzurasStar.SetValue(bDisplayAzurasStar as Int)
	EndFunction
	
	Function ReloadNPCItemModels()
		UpdateModelCoins(kSPELNPCItemsM)
		UpdateModelIngredients(kSPELNPCItemsM)
		UpdateModelPotions(kSPELNPCItemsM)
		UpdateModelScroll(kSPELNPCItemsM)
		UpdateModelTorch(kSPELNPCItemsM)
		UpdateModelInstruments(kSPELNPCItemsM)
		
		Utility.Wait(1.0)
		If(bUpdatedNPCVisuals)
			RefreshNPCItems()
		EndIf
	EndFunction
	
	Function RefreshNPCItems()
		gvbDisplayNPCCoinPurse.SetValue(bDisplayNPCCoinPurse as Int)
		gvbDisplayNPCIngredients.SetValue(bDisplayNPCIngredients as Int)
		gvbDisplayNPCPotions.SetValue(bDisplayNPCPotions as Int)
		gvbDisplayNPCScroll.SetValue(bDisplayNPCScroll as Int)
		gvbDisplayNPCTorch.SetValue(bDisplayNPCTorch as Int)
		gvbDisplayNPCLute.SetValue(bDisplayNPCLute as Int)
		gvbDisplayNPCHorn.SetValue(bDisplayNPCHorn as Int)
		gvbDisplayNPCFlute.SetValue(bDisplayNPCFlute as Int)
		gvbDisplayNPCDrum.SetValue(bDisplayNPCDrum as Int)
	EndFunction
	
	Function RefreshNPCWeapons()
		gvbDisplayNPCWeapons.SetValue(bDisplayNPCWeapons as Int)
		AGUDSystem.EnsureSpellStateCorrect()
	EndFunction
	
	Function ToggleNPCItems()
		bDisplayNPCItems = !bDisplayNPCItems
		gvbDisplayNPCItems.SetValue(bDisplayNPCItems as Int)
		AGUDSystem.EnsureSpellStateCorrect()
	EndFunction
	
	Function ToggleNPCWeapons()
		JDB.setObj("AllGUD", 0) ;Remove JDB saved data.
		bDisplayNPCWeapons = !bDisplayNPCWeapons
		If(!AGUDSystem.bAllGUDMaintenance)
			gvbDisplayNPCWeapons.SetValue(bDisplayNPCWeapons as Int)
			AGUDSystem.EnsureSpellStateCorrect()
		EndIf
	EndFunction
	
;#############################
;Positioning & Model Functions
;#############################
	String Function AppendModelPath(String asTarget, String asSuffix)
		String sBase = StringUtil.Substring(asTarget, 0, (StringUtil.GetLength(asTarget) - 4))
		sBase = sBase + asSuffix + ".nif"
		Return sBase
	EndFunction
		
	;Could have a combination of all these, but they are split so the update after MCM change is as fast as possible
	Function UpdateModelCoins(Spell kVisualization, Bool abSizeChange = False)
		;Unknown if repackaging assets is allowed... preferred paths
		String sArtPath = "AllGUD/Coin Purse/.nif"
		String sArtModel
		String sArtPos
		String[] sCoinSize = New String[6]
		sCoinSize[0] = "50"
		sCoinSize[1] = "60"
		sCoinSize[2] = "70"
		sCoinSize[3] = "80"
		sCoinSize[4] = "90"
		sCoinSize[5] = "100"
		
		If(kVisualization == kSPELPlayerItems)
			sArtModel = sPathCoinPurse[iModCoinPurse]
			sArtPos = sArtPosition[iPosCoinPurse]
			If(PlayerRef.GetActorBase().GetSex())
				sArtPath = AppendModelPath(sArtPath, sFemalePath)
			EndIf
			If(fCoinPurseMaxSize < 6)
				Int iIndex = (fCoinPurseMaxSize as Int)
				iIndex -= 1
				Int i = 5
				While i > iIndex 
					sCoinSize[i] = sCoinSize[iIndex]
					i -= 1
				EndWhile
			EndIf
		ElseIf(kVisualization == kSPELNPCItemsM)
			sArtModel = sPathCoinPurse[iModNPCCoinPurse]
			sArtPos = sArtPosition[iPosNPCCoinPurse]
			If(fNPCCoinPurseMaxSize < 6)
				Int iIndex = (fNPCCoinPurseMaxSize as Int)
				iIndex -= 1
				Int i = 5
				While i > iIndex 
					sCoinSize[i] = sCoinSize[iIndex]
					i -= 1
				EndWhile
			EndIf
		EndIf
		
			;Append each path with the size
		If(kVisualization.GetNthEffectMagicEffect(iIndexCoinPurseTiny).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sArtModel+sCoinSize[0]+sArtPos)) || abSizeChange
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayCoinPurse.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				bUpdatedNPCVisuals = True
				gvbDisplayNPCCoinPurse.SetValue(0)
				
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexCoinPurseTiny).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sArtModel+sCoinSize[0]+sArtPos))
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexCoinPurseSmall).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sArtModel+sCoinSize[1]+sArtPos))
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexCoinPurseMedium).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sArtModel+sCoinSize[2]+sArtPos))
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexCoinPurseLarge).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sArtModel+sCoinSize[3]+sArtPos))
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexCoinPurseHuge).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sArtModel+sCoinSize[4]+sArtPos))
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexCoinPurseGargantuan).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sArtModel+sCoinSize[5]+sArtPos))
			EndIf
			kVisualization.GetNthEffectMagicEffect(iIndexCoinPurseTiny).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sCoinSize[0]+sArtPos))
			kVisualization.GetNthEffectMagicEffect(iIndexCoinPurseSmall).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sCoinSize[1]+sArtPos))
			kVisualization.GetNthEffectMagicEffect(iIndexCoinPurseMedium).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sCoinSize[2]+sArtPos))
			kVisualization.GetNthEffectMagicEffect(iIndexCoinPurseLarge).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sCoinSize[3]+sArtPos))
			kVisualization.GetNthEffectMagicEffect(iIndexCoinPurseHuge).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sCoinSize[4]+sArtPos))
			kVisualization.GetNthEffectMagicEffect(iIndexCoinPurseGargantuan).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sCoinSize[5]+sArtPos))
		EndIf
		
	EndFunction
	
	Function UpdateModelIngredients(Spell kVisualization)
		String sArtPath = "AllGUD/Ingredients/.nif"
		String sArtModel
		String sArtPos
		
		If(kVisualization == kSPELPlayerItems)
			sArtPos = sArtPosition[iPosIngredients]
			sArtModel = sPathIngredients[iModIngredients]
			If(PlayerRef.GetActorBase().GetSex())
				sArtPath = AppendModelPath(sArtPath, sFemalePath)
			EndIf
		ElseIf(kVisualization == kSPELNPCItemsM)
			sArtPos = sArtPosition[iPosNPCIngredients]
			sArtModel = sPathIngredients[iModNPCIngredients]
		EndIf

		If(kVisualization.GetNthEffectMagicEffect(iIndexIngredientSatchel).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sArtModel+sArtPos))
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayIngredients.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				bUpdatedNPCVisuals = True
				gvbDisplayNPCIngredients.SetValue(0)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexIngredientSatchel).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sArtModel+sArtPos))
			EndIf
			kVisualization.GetNthEffectMagicEffect(iIndexIngredientSatchel).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sArtPos))
		EndIf
	EndFunction

	Function UpdateModelPotions(Spell kVisualization)
		String sArtPath = "AllGUD/Potions/.nif"
		String sHealthPath = "Health/"
		String sMagickaPath = "Magicka/"
		String sStaminaPath = "Stamina/"
		String sHealthModel
		String sMagickaModel
		String sStaminaModel
		String sHealthPos
		String sMagickaPos
		String sStaminaPos
		
		If(kVisualization == kSPELPlayerItems)
			sHealthModel = sPathPotions[iModHealthPotion]
			sHealthPos = sArtPosition[iPosHealthPotion]
			sMagickaModel = sPathPotions[iModMagickaPotion]
			sMagickaPos = sArtPosition[iPosMagickaPotion]
			sStaminaModel = sPathPotions[iModStaminaPotion]
			sStaminaPos = sArtPosition[iPosStaminaPotion]
			If(PlayerRef.GetActorBase().GetSex())
				sArtPath = AppendModelPath(sArtPath, sFemalePath)
			EndIf
		ElseIf(kVisualization == kSPELNPCItemsM)
			sHealthModel = sPathPotions[iModNPCHealthPotion]
			sHealthPos = sArtPosition[iPosNPCHealthPotion]
			sMagickaModel = sPathPotions[iModNPCMagickaPotion]
			sMagickaPos = sArtPosition[iPosNPCMagickaPotion]
			sStaminaModel = sPathPotions[iModNPCStaminaPotion]
			sStaminaPos = sArtPosition[iPosNPCStaminaPotion]
		EndIf
				
		If(kVisualization.GetNthEffectMagicEffect(iIndexPotionHealth).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sHealthPath + sHealthModel + sHealthPos))
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayPotions.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				bUpdatedNPCVisuals = True
				gvbDisplayNPCPotions.SetValue(0)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexPotionHealth).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sHealthPath + sHealthModel+sHealthPos))
			EndIf
			kVisualization.GetNthEffectMagicEffect(iIndexPotionHealth).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sHealthPath + sHealthModel+sHealthPos))
		EndIf
		
		If(kVisualization.GetNthEffectMagicEffect(iIndexPotionMagicka).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sMagickaPath + sMagickaModel+sMagickaPos))
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayPotions.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				bUpdatedNPCVisuals = True
				gvbDisplayNPCPotions.SetValue(0)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexPotionMagicka).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sMagickaPath + sMagickaModel+sMagickaPos))
			EndIf
			kVisualization.GetNthEffectMagicEffect(iIndexPotionMagicka).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sMagickaPath + sMagickaModel+sMagickaPos))
		EndIf
		
		If(kVisualization.GetNthEffectMagicEffect(iIndexPotionStamina).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sStaminaPath + sStaminaModel+sStaminaPos))
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayPotions.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				bUpdatedNPCVisuals = True
				gvbDisplayNPCPotions.SetValue(0)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexPotionStamina).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sStaminaPath + sStaminaModel+sStaminaPos))
			EndIf
			kVisualization.GetNthEffectMagicEffect(iIndexPotionStamina).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sStaminaPath + sStaminaModel+sStaminaPos))
		EndIf
	EndFunction
	
	Function UpdateModelScroll(Spell kVisualization)
		String sArtPath = "AllGUD/Scrolls/.nif"
		String sArtModel
		String sArtPos
		
		If(kVisualization == kSPELPlayerItems)
			sArtModel = sPathScrolls[iModScroll]
			sArtPos = sArtPosition[iPosScroll]
			If(PlayerRef.GetActorBase().GetSex())
				sArtPath = AppendModelPath(sArtPath, sFemalePath)
			EndIf
		ElseIf(kVisualization == kSPELNPCItemsM)
			sArtModel = sPathScrolls[iModNPCScroll]
			sArtPos = sArtPosition[iPosNPCScroll]
		EndIf
		
		If(kVisualization.GetNthEffectMagicEffect(iIndexScroll).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sArtModel+sArtPos))
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayScroll.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				bUpdatedNPCVisuals = True
				gvbDisplayNPCScroll.SetValue(0)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexScroll).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sArtModel+sArtPos))
			EndIf
			kVisualization.GetNthEffectMagicEffect(iIndexScroll).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sArtPos))
		EndIf
	EndFunction	

	Function UpdateModelTorch(Spell kVisualization)
		String sArtPath = "AllGUD/Torches/.nif"
		String sStrapPath = "Strap/"
		String sArtModel
		String sArtPos
		
		If(kVisualization == kSPELPlayerItems)
			sArtModel = sPathTorches[iModTorch]
			sArtPos = sArtPosition[iPosTorch]
			If(PlayerRef.GetActorBase().GetSex())
				sArtPath = AppendModelPath(sArtPath, sFemalePath)
			EndIf
		ElseIf(kVisualization == kSPELNPCItemsM)
			sArtModel = sPathTorches[iModNPCTorch]
			sArtPos = sArtPosition[iPosNPCTorch]
		EndIf
		
		If(kVisualization.GetNthEffectMagicEffect(iIndexTorch).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sArtModel+sArtPos))
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayTorch.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				bUpdatedNPCVisuals = True
				gvbDisplayNPCTorch.SetValue(0)
				If sArtModel == sPathTorches[0]
					kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexTorchStrap).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath + sStrapPath + sArtPos))
				Else
					kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexTorchStrap).GetHitEffectArt().SetModelPath("")
				EndIf
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexTorch).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath + sArtModel+sArtPos))
			EndIf
			If sArtModel == sPathTorches[0]
				kVisualization.GetNthEffectMagicEffect(iIndexTorchStrap).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sStrapPath + sArtPos))
			Else
				kVisualization.GetNthEffectMagicEffect(iIndexTorchStrap).GetHitEffectArt().SetModelPath("")
			EndIf
			kVisualization.GetNthEffectMagicEffect(iIndexTorch).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sArtPos)) ;Lanterns will give torch strap a path to a model that doesn't exist
		EndIf
	EndFunction
	
	Function UpdateModelInstruments(Spell kVisualization)
		String sLutePath = "AllGUD/Instruments/Lute/.nif"
		String sLuteModel
		String sLutePos
		
		String sArtPath = "AllGUD/Instruments/.nif"
		
		String sHornPath = "Horn/NordWar"
		String sHornModel
		String sHornPos
		
		String sFlutePath = "Flute/"
		String sFluteModel
		String sFlutePos
		
		String sDrumPath = "Drum/"
		String sDrumModel
		String sDrumPos
		
		If(kVisualization == kSPELPlayerItems)
			sLuteModel = sPathLute[iModLute]
			sLutePos = sArtPositionUpperBack[iPosLute]
			
			sHornModel = sPathHorn[iModHorn]
			sHornPos = sArtPositionInstrumentBack[iPosHorn]
			
			sFluteModel = sPathFlute[iModFlute]
			sFlutePos = sArtPositionInstrumentBack[iPosFlute]
			
			sDrumModel = sPathDrum[iModDrum]
			sDrumPos = sArtPositionInstrumentBack[iPosDrum]
			
			If(PlayerRef.GetActorBase().GetSex())
				sArtPath = AppendModelPath(sArtPath, sFemalePath)
			EndIf

		ElseIf(kVisualization == kSPELNPCItemsM)
			sLuteModel = sPathLute[iModNPCLute]
			sLutePos = sArtPositionUpperBack[iPosNPCLute]
			
			sHornModel = sPathHorn[iModNPCHorn]
			sHornPos = sArtPositionInstrumentBack[iPosNPCHorn]
			
			sFluteModel = sPathFlute[iModNPCFlute]
			sFlutePos = sArtPositionInstrumentBack[iPosNPCFlute]
			
			sDrumModel = sPathDrum[iModNPCDrum]
			sDrumPos = sArtPositionInstrumentBack[iPosNPCDrum]
		EndIf
			
		String sCurrentPath = AppendModelPath(sLutePath, sLuteModel+sLutePos)
		If(kVisualization.GetNthEffectMagicEffect(iIndexLute).GetHitEffectArt().GetModelPath() != sCurrentPath)
			kVisualization.GetNthEffectMagicEffect(iIndexLute).GetHitEffectArt().SetModelPath(sCurrentPath)
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayLute.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexLute).GetHitEffectArt().SetModelPath(sCurrentPath);NO FEMALE-LUTE MODEL NEEDED
				bUpdatedNPCVisuals = True
				gvbDisplayNPCLute.SetValue(0)
			EndIf
		EndIf
		
		sCurrentPath = AppendModelPath(sArtPath, sHornPath+sHornModel+sHornPos)
		If(kVisualization.GetNthEffectMagicEffect(iIndexHorn).GetHitEffectArt().GetModelPath() != sCurrentPath)
			kVisualization.GetNthEffectMagicEffect(iIndexHorn).GetHitEffectArt().SetModelPath(sCurrentPath)
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayHorn.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexHorn).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sHornPath+sHornModel+sHornPos))
				bUpdatedNPCVisuals = True
				gvbDisplayNPCHorn.SetValue(0)
			EndIf
		EndIf
		
		sCurrentPath = AppendModelPath(sArtPath, sFlutePath+sFluteModel+sFlutePos)
		If(kVisualization.GetNthEffectMagicEffect(iIndexFlute).GetHitEffectArt().GetModelPath() != sCurrentPath)
			kVisualization.GetNthEffectMagicEffect(iIndexFlute).GetHitEffectArt().SetModelPath(sCurrentPath)
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayFlute.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexFlute).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sFlutePath+sFluteModel+sFlutePos))
				bUpdatedNPCVisuals = True
				gvbDisplayNPCFlute.SetValue(0)
			EndIf
		EndIf
		
		sCurrentPath = AppendModelPath(sArtPath, sDrumPath+sDrumModel+sDrumPos)
		If(kVisualization.GetNthEffectMagicEffect(iIndexDrum).GetHitEffectArt().GetModelPath() != sCurrentPath)
			kVisualization.GetNthEffectMagicEffect(iIndexDrum).GetHitEffectArt().SetModelPath(sCurrentPath)
			If(kVisualization == kSPELPlayerItems)
				bUpdatedPlayerVisuals = True
				gvbDisplayDrum.SetValue(0)
			ElseIf(kVisualization == kSPELNPCItemsM)
				kSPELNPCItemsF.GetNthEffectMagicEffect(iIndexDrum).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sFemalePath+sDrumPath+sDrumModel+sDrumPos))
				bUpdatedNPCVisuals = True
				gvbDisplayNPCDrum.SetValue(0)
			EndIf
		EndIf
	EndFunction
	
	Function UpdateModelPlayerOnly()
		String sArtPath = "AllGUD/Potions/.nif"
		String sStrapPath = "Strap/"
		String sArtModel = sPathWhitePhial[iModWhitePhial]
		String sArtPos = sArtPosition[iPosWhitePhial]

		If(PlayerRef.GetActorBase().GetSex())
			sArtPath = AppendModelPath(sArtPath, sFemalePath)
		EndIf
		sArtPath = AppendModelPath(sArtPath, "White Phial/")
		
		If(kSPELPlayerItems.GetNthEffectMagicEffect(iIndexWhitePhial).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sArtModel+sArtPos))
			bUpdatedPlayerVisuals = True
			gvbDisplayWhitePhial.SetValue(0)
			kSPELPlayerItems.GetNthEffectMagicEffect(iIndexWhitePhial).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sArtPos))
		EndIf
		
		If(kSPELPlayerItems.GetNthEffectMagicEffect(iIndexWhitePhialStrap).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sStrapPath + sArtPos))
			bUpdatedPlayerVisuals = True
			gvbDisplayWhitePhial.SetValue(0)
			kSPELPlayerItems.GetNthEffectMagicEffect(iIndexWhitePhialStrap).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sStrapPath + sArtPos))
		EndIf
		
		
		sArtPath = "AllGUD/Scrolls/.nif"
		sArtModel = ""
		;sArtModel = sPathElder[iModElderScroll]
		sArtPos = sArtPositionUpperBack[iPosElderScroll]
		
		If(PlayerRef.GetActorBase().GetSex())
			sArtPath = AppendModelPath(sArtPath, sFemalePath)
		EndIf
		sArtPath = AppendModelPath(sArtPath, "Elder/")
	
		If(kSPELPlayerItems.GetNthEffectMagicEffect(iIndexElderScroll).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sArtModel+sArtPos))
			bUpdatedPlayerVisuals = True
			gvbDisplayElderScroll.SetValue(0)
			kSPELPlayerItems.GetNthEffectMagicEffect(iIndexElderScroll).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sArtPos))
		EndIf
		
		sArtPath = "AllGUD/Soul Gems/.nif"
		sArtModel = sPathAzurasStar[iModAzurasStar]
		sArtPos = sArtPosition[iPosAzurasStar]
		
		If(PlayerRef.GetActorBase().GetSex())
			sArtPath = AppendModelPath(sArtPath, sFemalePath)
		EndIf
		sArtPath = AppendModelPath(sArtPath, "Azura Star/")
		
		If(kSPELPlayerItems.GetNthEffectMagicEffect(iIndexAzurasStar).GetHitEffectArt().GetModelPath() != AppendModelPath(sArtPath, sArtModel+sArtPos))
			bUpdatedPlayerVisuals = True
			gvbDisplayAzurasStar.SetValue(0)
			kSPELPlayerItems.GetNthEffectMagicEffect(iIndexAzurasStar).GetHitEffectArt().SetModelPath(AppendModelPath(sArtPath, sArtModel+sArtPos))
		EndIf
		
	EndFunction
	
;Misc Functions
	string function d2h(int d, bool bWith0x = false)
		;Function taken from Nexus Forums, a post by 'mlheur', July 28th 2016.
		string digits = "0123456789ABCDEF"
		string hex
		int shifted = 0
		while shifted < 32
			hex = GetNthChar(digits, LogicalAnd(0xF, d)) + hex
			d = RightShift(d, 4)
			shifted += 4
		endwhile
		if bWith0x
			hex = "0x" + hex
		endif
		return hex
	endfunction
	
	string function GetModFromFormID(int d)
		Return Game.GetModName(RightShift(d, 24))
	endfunction
