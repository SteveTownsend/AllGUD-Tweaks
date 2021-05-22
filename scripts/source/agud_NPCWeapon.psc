Scriptname AGUD_NPCWeapon extends ActiveMagicEffect
{All Geared Up Derivative - Adds support for displaying unequipped favorited and/or equipped items.}

;GlobalVariable Property bShieldAccommodate Auto
FormList Property kFLSTBackpacks Auto
FormList Property kFLSTBannedWeapons Auto
FormList Property kFLSTBannedKeywords Auto
FormList Property kFLSTTorches Auto
GlobalVariable Property gvbDisplayNPCWeapons Auto
GlobalVariable Property gvbAutoEquipStaves Auto
GlobalVariable Property gvbShieldOnBack Auto
GlobalVariable Property gvfAttemtInterval Auto
GlobalVariable Property gviAttemptLimit Auto
Armor Property kAllGUDNPCWeaponRight Auto
Armor Property kAllGUDNPCWeaponLeft Auto
Armor Property kAllGUDNPCShield Auto ;Decided to separate weapon and shield because I was unsure about how the effects of changing the slotmask while equipped. Better safe than sorry.
Spell Property kSPELNPCWeapon Auto ;Plan to use this to remove spell when no objects equipped while dead.
Keyword Property kKYWDCreature Auto
Keyword Property kKYWDDisplayArmor Auto

;Int iSlotMaskTail = 0x00000400
Int iSlotMaskCloak = 0x00010000
Int iSlotMaskBackpack = 0x00020000
Int iSlotMaskLeftHand = 0x00000200
Int iSlotMaskTorso = 0x00000004
Int iSlotLeftHand = 39

Int iSlotIrrelevant = -1
Int iSlotStaff = 4
Int iSlotLeftStart = 7
Int iSlotLeftStaff = 11
Int iSlotShield = 12

Bool bXPMSEInstalled
String[] sWeaponDefaultNodes
Int iNodeSword = 0
Int iNodeDagger = 1
Int iNodeAxe = 2
Int iNodeMace = 3
Int iNodeTwoHMelee = 4
Int iNodeRange = 5
Int iNodePolearm = 6
Int iNodeCrossBow = 7

Actor kActor
Actor PlayerRef
Bool bWeaponDrawn
Bool bWearingBackItem

Bool TheRightHand = True
Bool TheLeftHand = False

Form kRightHand
Form kRightHandDisplay
Int iTypeRightHand
Int iTypeRightHandDisplay = -1
Bool bRightEquipped
Bool bRightUpdateModel = False
String sRightModel

Form kLeftHand
Form kLeftHandDisplay
Int iTypeLeftHand
Int iTypeLeftHandDisplay = -1
Bool bLeftEquipped
Bool bLeftUpdateModel = False
String sLeftModel
String sLeftModelAlternate

Bool bProcessingHandObjects
Bool bUpdateHandObjectQueued

String AllGUDNPCActorList = ".AllGUDNPC.Actors"
String AllGUDNPCAttemptTracker = ".AllGUDNPC.Attempts"


;EFFECT MANAGEMENT
	Event OnUpdate()
		;Need a way to wait for the next frame update so multiple npcs aren't trying to gear up with the same model.
		Int jActors
		Int jAttempts
		
	;GET ARRAY OF ACTORS
		If JDB.hasPath(AllGUDNPCActorList)
			jActors = JDB.solveObj(AllGUDNPCActorList)
		Else
			jActors = JArray.object()
			JDB.solveObjSetter(AllGUDNPCActorList, jActors, True) ;Save jActors ;Can this cause infinite loop? Maybe if fAttemptInterval is way too low.
		EndIf
		Int iActorIndex = JArray.findForm(jActors, kActor)
		;Trace(kActor + " Is trying to gear up, current queue is: " + iActorIndex)
		
	;ACTOR GEARS UP
		If(iActorIndex == 0) ;Actor is first in array
			;JDB.writeToFile(JContainers.userDirectory() + "JDB_PreGearedUp.json")	;Debug Dump
			JDB.solveObjSetter(AllGUDNPCAttemptTracker, 0)
			If(bRightUpdateModel)	;Equip right
				bRightUpdateModel = False ;False it first in case it needs to reequip
				EquipAGUDArmor(True)
			EndIf
			If(bLeftUpdateModel) ;Equip left
				bLeftUpdateModel = False
				EquipAGUDArmor(False)
			EndIf
			
			JArray.eraseIndex(jActors, 0) ;Pop front
			;JDB.writeToFile(JContainers.userDirectory() + "JDB_PostGearedUp.json")	;Debug Dump
			
	;ADD NEW ACTOR TO LIST
		ElseIf(iActorIndex < 0) ;Actor is not in array
			JArray.addForm(jActors, kActor) ;Push to end
	;;;;;;	JArray.addForm(jActors, kActor) ;Used to test the purge
			RegisterForSingleUpdate(gvfAttemtInterval.GetValue())
			
	;ADVANCE ATTEMPT TRACKER FOR ACTOR (Attempts are tracked using a JFormMap, key of kActor and value of iNumAttempts)
		Else
			If JDB.hasPath(AllGUDNPCAttemptTracker)	;Load previous attempts
				jAttempts = JDB.solveObj(AllGUDNPCAttemptTracker)
				If(JValue.Empty(jAttempts)) ;Reset?
					jAttempts = JFormMap.object()
					JDB.solveObjSetter(AllGUDNPCAttemptTracker, jAttempts, True)
					JFormMap.setInt(jAttempts, kActor, 0)
				EndIf
			Else ;Start a new JFormMap
				jAttempts = JFormMap.object()
				JDB.solveObjSetter(AllGUDNPCAttemptTracker, jAttempts, True)
				JFormMap.setInt(jAttempts, kActor, 0)
			EndIf
			
			If(JFormMap.hasKey(jAttempts, kActor)) ;HAS PREVIOUS ATTEMPTS
				Int iCurrentAttempts = 0
				iCurrentAttempts = JFormMap.getInt(jAttempts, kActor)
				If iCurrentAttempts > (gviAttemptLimit.GetValueInt() * iActorIndex) ;PREVIOUS ATTEMPTS SURPASS LIMIT BASED ON THEIR INDEX
					Int iIndexPredActor = iActorIndex - 1
					;JDB.writeToFile(JContainers.userDirectory() + "JDB_PreClear.json")	;Debug Dump
					JArray.eraseRange(jActors, 0, iIndexPredActor) ;Clear all actors higher in the list;
					JDB.solveObjSetter(AllGUDNPCAttemptTracker, 0)
					;JDB.writeToFile(JContainers.userDirectory() + "JDB_PostClear.json")	;Debug Dump
				Else
					JFormMap.setInt(jAttempts, kActor, JFormMap.getInt(jAttempts, kActor) + 1);Store previous attempts +1
					;JDB.writeToFile(JContainers.userDirectory() + "JDB_Increment.json")	;Debug Dump
				EndIf
			Else ;YOU'RE NOT ON LIST
				JFormMap.setInt(jAttempts, kActor, 0)
			EndIf
			RegisterForSingleUpdate(gvfAttemtInterval.GetValue()) ;ARBITRARY NUMBER UNTIL NEXT ATTEMPT ;Don't want too much spam, but also don't want to delay it too much
		EndIf
	EndEvent

	Event OnEffectStart(Actor akTarget, Actor akCaster)
		kActor = akTarget
		PlayerRef = Game.GetPlayer()
		If(kActor.IsDead() || kActor.HasKeyword(kKYWDCreature)) ;Clear spell from the dead and if something switched into a creature
			RemoveAllGUDNPCWeapons()
		Else
			;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] AllGUD NPC Weapons Effect Started. Old RH Display: "+kRightHandDisplay + " Old LH Display: " + kLeftHandDisplay)
			GoToState("")
			RegisterForAnimations()
			bWeaponDrawn = kActor.IsWeaponDrawn()
			If(kActor.GetItemCount(kAllGUDNPCWeaponRight) < 1)
				kActor.AddItem(kAllGUDNPCWeaponRight, 1, True)
			EndIf
			If(kActor.GetItemCount(kAllGUDNPCWeaponLeft) < 1)
				kActor.AddItem(kAllGUDNPCWeaponLeft, 1, True)
			EndIf
			If(kActor.GetItemCount(kAllGUDNPCShield) < 1)
				kActor.AddItem(kAllGUDNPCShield, 1, True)
			EndIf
			InitializeVariables()
			UpdateNPCHandObjects()
		EndIf
	EndEvent
	
	Function InitializeVariables()
		CheckBackItem()
		
		If(Game.GetModByName("XPMSE.esp") != 255)
			bXPMSEInstalled = True
		Else
			bXPMSEInstalled = False
		EndIf
		
		sWeaponDefaultNodes = New String[8] ;Constant, names of the vanilla skeleton nodes.
		sWeaponDefaultNodes[iNodeSword] = "WeaponSword"
		sWeaponDefaultNodes[iNodeDagger] = "WeaponDagger"
		sWeaponDefaultNodes[iNodeAxe] = "WeaponAxe"
		sWeaponDefaultNodes[iNodeMace] = "WeaponMace"
		sWeaponDefaultNodes[iNodeTwoHMelee] = "WeaponBack"
		sWeaponDefaultNodes[iNodeRange] = "WeaponBow"
		sWeaponDefaultNodes[iNodePolearm] = "WeaponBack"
		sWeaponDefaultNodes[iNodeCrossBow] = "WeaponCrossBow"
	EndFunction

	Event OnEffectFinish(Actor akTarget, Actor akCaster)
		;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] AllGUD NPC Weapons Effect Ended. Reasons: Dead?"+kActor.IsDead()+" 3dLoaded?"+kActor.Is3dLoaded()+ " AllGUDEnabled?"+gvbDisplayNPCWeapons.GetValue() as Bool)
		UnequipAGUDArmors()
	EndEvent
	
State Disabled
	Event OnUpdate()
	EndEvent
	
	Event OnBeginState()
		UnregisterForAnimations()
		UnregisterForUpdate()
	EndEvent
	
	Event OnEffectFinish(Actor akTarget, Actor akCaster)
		kActor.RemoveSpell(kSPELNPCWeapon)
	EndEvent
	
	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		UnregisterForAnimations()
	EndEvent
	
	Event OnItemRemoved(Form akBaseObject, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
		;This won't be triggered while effect is off.
		Int iRemainingCount = kActor.GetItemCount(akBaseObject)
		;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Removed item: " + akBaseObject.GetName() + " Remaining: " + iRemainingCount)
		If akBaseObject == kRightHandDisplay
			;Debug.Trace("    "+akBaseObject.GetName()+" was the RH Display")
			If(iRemainingCount == 0)
				UnequipAGUDArmor(TheRightHand)
				ClearAGUDArmor(TheRightHand)
			ElseIf(iRemainingCount == 1)
				If(kRightHandDisplay == kLeftHandDisplay)
					UnequipAGUDArmor(TheLeftHand)
					ClearAGUDArmor(TheLeftHand)
				ElseIf(kRightHandDisplay == kLeftHand)
					UnequipAGUDArmor(TheRightHand)
					ClearAGUDArmor(TheRightHand)
				EndIf
			EndIf
		EndIf
		If akBaseObject == kLeftHandDisplay
			;Debug.Trace("    "+akBaseObject.GetName()+" was the LH Display")
			If(iRemainingCount == 0)
				UnequipAGUDArmor(TheLeftHand)
				ClearAGUDArmor(TheLeftHand)
			EndIf
		EndIf
		If!(bRightEquipped || bLeftEquipped)
			RemoveAllGUDNPCWeapons()
		EndIf
	EndEvent

EndState

	Event OnDying(Actor akKiller)
		If(bRightEquipped || bLeftEquipped)
			GoToState("Disabled")
		Else
			RemoveAllGUDNPCWeapons()
		EndIf
	EndEvent
	
	Event OnRaceSwitchComplete()
		ClearAGUDArmor(TheRightHand)
		ClearAGUDArmor(TheLeftHand)
		UnequipAGUDArmors()
		If kActor.HasKeyword(kKYWDCreature)
			RemoveAllGUDNPCWeapons()
		EndIf
	EndEvent
	
	Function RemoveAllGUDNPCWeapons()
		If(kActor.GetItemCount(kAllGUDNPCWeaponRight)> 0)
			kActor.RemoveItem(kAllGUDNPCWeaponRight, kActor.GetItemCount(kAllGUDNPCWeaponRight))
		EndIf
		If(kActor.GetItemCount(kAllGUDNPCWeaponLeft)> 0)
			kActor.RemoveItem(kAllGUDNPCWeaponLeft, kActor.GetItemCount(kAllGUDNPCWeaponLeft))
		EndIf
		If(kActor.GetItemCount(kAllGUDNPCShield)> 0)
			kActor.RemoveItem(kAllGUDNPCShield, kActor.GetItemCount(kAllGUDNPCShield))
		EndIf
		
		Dispel()
		kActor.RemoveSpell(kSPELNPCWeapon)

	EndFunction
;ITEM FUNCTIONS
	String Function AppendModelPath(String asTarget, String asSuffix)
		;"Armor" Right-hand Non-Staff
		;"OnBack" Regular shield
		;"OnBackClk" Shield, when cloak is equipped
		;"Left" Left-Hand 1h Weapon
		;"Sheath" Left-Hand 1h Model when Weapons are Drawn
		;"Right" Staff specific
		String sBase = StringUtil.Substring(asTarget, 0, (StringUtil.GetLength(asTarget) - 4))
		sBase = sBase + asSuffix + ".nif"
		Return sBase
	EndFunction

	Int Function GetAllGUDItemSlot(Form akBaseObject)
		Int iSlotMisplacedStaff = 7
		Int iSlot2HMelee = 5
		Int iSlotRange = 6
		
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
	
;ANIMATION
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		Bool bNewDrawState = (kActor.IsWeaponDrawn() || (asEventName == "BeginWeaponDraw"))
		If(bWeaponDrawn != bNewDrawState)
			bWeaponDrawn = bNewDrawState
			If(bWeaponDrawn)
				;Right staff unequip
				If(iTypeRightHandDisplay == iSlotStaff || !bRightEquipped)
					UnequipAGUDArmor(TheRightHand)	;Backup removal check
				EndIf
				;Left weapon changes model
				If(iTypeLeftHandDisplay >= iSlotLeftStart)
					If(!bLeftEquipped || iTypeLeftHandDisplay == iSlotLeftStaff)
						UnequipAGUDArmor(TheLeftHand)	;Backup removal check
					ElseIf(iTypeLeftHandDisplay != iSlotShield)
						;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Animation: Drawing Left-Hand Weapon from Sheath")
						bLeftEquipped = True
						UpdateAGUDModel(TheLeftHand)
						RegisterForSingleUpdate(0) ;Second overrides first, updating sooner
					Else ;Left Shield unequips from back supposed to be equipped in hand.
						If(kActor.GetEquippedObject(0) == None)	;NPC drew weapons outside of combat, as entering combat would equip their BIS gear first.
							;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Animation: Drawing Shield from back out of combat")
							UnequipAGUDArmor(TheLeftHand)
					;/	ElseIf(kActor.GetEquippedObject(0) == kLeftHandDisplay)	;UNCOMMENT IF NOT ASSIGNING SLOTMASK
							;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Animation: Drawing Shield from back in combat")
							UnequipAGUDArmor(TheLeftHand)
					/;
						EndIf
					EndIf
				EndIf
			Else
				If(iTypeRightHandDisplay == iSlotStaff)
					bRightUpdateModel = True
					bRightEquipped = True
				ElseIf!bRightEquipped
					UnequipAGUDArmor(TheRightHand)	;Backup removal check
				EndIf
				
				If(iTypeLeftHand >= iSlotLeftStart)
					bLeftUpdateModel = True
					bLeftEquipped = True
				ElseIf!bLeftEquipped
					UnequipAGUDArmor(TheLeftHand)	;Backup removal check
				EndIf
				;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Animation: Sheathing. Updating RH:"+bRightUpdateModel + " Updating LH:"+bLeftUpdateModel)
				If(bRightUpdateModel || bLeftUpdateModel)
					RegisterForSingleUpdate(0)
				EndIf
			EndIf
		EndIf
	EndEvent
	
	Function RegisterForAnimations()
		If(!RegisterForAnimationEvent(kActor, "BeginWeaponDraw"))
			Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Failed to register for BeginWeaponDraw")
		EndIf
		If(!RegisterForAnimationEvent(kActor, "WeaponDraw"))
			Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Failed to register for WeaponDraw")
		EndIf
		If(!RegisterForAnimationEvent(kActor, "WeaponSheathe"))
			Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Failed to register for WeaponSheathe")
		EndIf
	EndFunction

	Function UnregisterForAnimations()
		UnregisterForAnimationEvent(kActor, "BeginWeaponDraw")
		UnregisterForAnimationEvent(kActor, "WeaponDraw")
		UnregisterForAnimationEvent(kActor, "WeaponSheathe")
	EndFunction

;ARMOR MANAGEMENT
	Function UpdateAGUDModel(Bool abRightSlot)
		If abRightSlot
			If(kRightHandDisplay)
				bRightUpdateModel = True
				RegisterForSingleUpdate(gvfAttemtInterval.GetValue())
			EndIf
		Else
			If(kLeftHandDisplay)
				bLeftUpdateModel = True
				RegisterForSingleUpdate(gvfAttemtInterval.GetValue())
			EndIf
		EndIf
	EndFunction

	Function EquipAGUDArmor(Bool abRightSlot)
		;Notes on detecting a wrong model equip
		;	1.5 Introduced waiting a full interval before reseting the model path	
		;	!kActor.IsEquipped(Armor) NO WRONG DISPLAYS YET, seems to be giving off a lot of false posiitives though
		;	Armor.GetNthArmorAddon(0).GetModelPath(False,False) != sFinalModel) Had too many false positives, looping false positives.
		;NEW PLAN
		;	Just wait, no check. Will test a bit to see how it goes.
		
		If(abRightSlot)
			If(iTypeRightHandDisplay > iSlotIrrelevant)
				If(bWeaponDrawn && iTypeRightHandDisplay == iSlotStaff)
					UnequipAGUDArmor(TheRightHand) ;Staff should be drawn, not on back
				ElseIf(sRightModel != "" && kActor.GetItemCount(kRightHandDisplay) > 0)
					;Assign Model	
					kAllGUDNPCWeaponRight.GetNthArmorAddon(0).SetModelPath(sRightModel, False, False)
					kActor.EquipItemEx(kAllGUDNPCWeaponRight)
					Utility.Wait(gvfAttemtInterval.GetValue())
				;CHECK FOR MULTITHREADING CONFLICT
					;If((kAllGUDNPCWeaponRight.GetNthArmorAddon(0).GetModelPath(False,False) != sRightModel) || !kActor.IsEquipped(kAllGUDNPCWeaponRight))
				;	If(!kActor.IsEquipped(kAllGUDNPCWeaponRight))
				;		Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] RightDisplay was incorrect model")
				;		kActor.UnequipItemEx(kAllGUDNPCWeaponRight, 0, true)
				;		UpdateAGUDModel(TheRightHand)
				;	Else
						kAllGUDNPCWeaponRight.GetNthArmorAddon(0).SetModelPath("", False, False)
				;	EndIf
				EndIf
			EndIf
		ElseIf(iTypeLeftHandDisplay >= iSlotLeftStart) ;Left Hand
			If(kActor.GetItemCount(kLeftHandDisplay) > 0)
				String sFinalModel
				If(iTypeLeftHandDisplay != iSlotShield)
					;sLeftModel = AppendModelPath((kLeftHandDisplay as Weapon).GetModelPath(), "Left")
					;sLeftModelAlternate = AppendModelPath((kLeftHandDisplay as Weapon).GetModelPath(), "Sheath")
					If(bWeaponDrawn)
						sFinalModel = sLeftModelAlternate
					Else
						sFinalModel = sLeftModel
					EndIf
					If(sFinalModel != "")
						kAllGUDNPCWeaponLeft.GetNthArmorAddon(0).SetModelPath(sFinalModel, False, False)
						kActor.EquipItemEx(kAllGUDNPCWeaponLeft)
						Utility.Wait(gvfAttemtInterval.GetValue())
					;CHECK FOR MULTITHREADING CONFLICT
						;If(kAllGUDNPCWeaponLeft.GetNthArmorAddon(0).GetModelPath(False,False) != sFinalModel) || !kActor.IsEquipped(kAllGUDNPCWeaponLeft)
					;	If(!kActor.IsEquipped(kAllGUDNPCWeaponLeft))
					;		Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] LeftDisplay was incorrect model")
					;		kActor.UnequipItemEx(kAllGUDNPCWeaponLeft, 0, true)
					;		UpdateAGUDModel(TheLeftHand)
					;	Else
							kAllGUDNPCWeaponLeft.GetNthArmorAddon(0).SetModelPath("", False, False)
					;	EndIf
					EndIf
				ElseIf(gvbShieldOnBack.GetValueInt() as Bool)
					If(bWeaponDrawn && (kActor.GetEquippedObject(0) == kLeftHandDisplay)) ;Oops, this should not be on the back after all
						UnequipAGUDArmor(TheLeftHand)
					Else
						;sLeftModel = AppendModelPath((kLeftHandDisplay as Armor).GetNthArmorAddon(0).GetModelPath(False, False), "OnBack")
						;sLeftModelAlternate = AppendModelPath((kLeftHandDisplay as Armor).GetNthArmorAddon(0).GetModelPath(False, False), "OnBackClk")
						If(bWearingBackItem)
							sFinalModel = sLeftModelAlternate
						Else
							sFinalModel = sLeftModel
						EndIf
						If(sFinalModel != "")
							If(kFLSTTorches.HasForm(kLeftHand))
								kAllGUDNPCShield.RemoveSlotFromMask(iSlotMaskLeftHand)
							Else
								kAllGUDNPCShield.AddSlotToMask(iSlotMaskLeftHand)
							EndIf
							
							kAllGUDNPCShield.GetNthArmorAddon(0).SetModelPath(sFinalModel, False, False)
						;	kActor.UnequipItemSlot(iSlotLeftHand) ;UNCOMMENT IF NOT ASSIGNING SLOTMASK
							kActor.EquipItemEx(kAllGUDNPCShield)
							Utility.Wait(gvfAttemtInterval.GetValue())
						;CHECK FOR MULTITHREADING CONFLICT
							;(kAllGUDNPCShield
					;		If(!kActor.IsEquipped(kAllGUDNPCShield))
					;			Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] ShieldDisplay was incorrect model")
					;			kActor.UnequipItemEx(kAllGUDNPCShield, 0, true)
					;			UpdateAGUDModel(TheLeftHand)
					;		Else
								kAllGUDNPCShield.GetNthArmorAddon(0).SetModelPath("", False, False)
					;		EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndFunction

	Function UnequipAGUDArmor(Bool bRightHand)
		If(bRightHand)
			kActor.UnequipItemEx(kAllGUDNPCWeaponRight, 0, true)
			bRightEquipped = False
		Else
			;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] iTypeLeftHandDisplay:" + iTypeLeftHandDisplay + " CurretLeft:"+kActor.GetEquippedObject(0)+ " EquippedLeft?"+bLeftEquipped)
			If(iTypeLeftHandDisplay == iSlotShield)
				;If((kActor.GetEquippedObject(0) == None) || (kActor.GetEquippedObject(0) as Armor == kAllGUDNPCShield)) && bLeftEquipped ;Tried making kAllGUDNPCShield into a Shield equipment type. AI gave it priority over Lydia's default shield. Will look into whether there's a flag/keyword to stop this
				If((kActor.GetEquippedObject(0) == None) && bLeftEquipped) ;Tried making kAllGUDNPCShield into a Shield equipment type. AI gave it priority over Lydia's default shield. Will look into whether there's a flag/keyword to stop this later.
				;	kActor.UnequipItemEx(kAllGUDNPCShield, 0, true) ;UNCOMMENT IF NOT ASSIGNING SLOTMASK
					kActor.EquipItemEx(kLeftHandDisplay as Armor) ;RESTORE THE SHIELD THAT WAS UNEQUIPPED, very important.
				Else ;Juuust in case
					kActor.UnequipItemEx(kAllGUDNPCShield, 0, true) ;UNCOMMENT IF NOT ASSIGNING SLOTMASK
					kActor.UnequipItemEx(kAllGUDNPCWeaponLeft, 0, true) ;Juuuust in case
				EndIf
				bLeftEquipped = False
			Else
				kActor.UnequipItemEx(kAllGUDNPCWeaponLeft, 0, true)
				kActor.UnequipItemEx(kAllGUDNPCShield, 0, true) ;Juuuust in case
				bLeftEquipped = False
			EndIf
		EndIf
	EndFunction

	Function UnequipAGUDArmors()
		UnequipAGUDArmor(TheRightHand)
		UnequipAGUDArmor(TheLeftHand)
	EndFunction
	
	Function ClearAGUDArmor(Bool bRightHand)
		If(bRightHand)
			kRightHandDisplay = None
			iTypeRightHandDisplay = iSlotIrrelevant
			sRightModel = ""
			bRightEquipped = False
			bRightUpdateModel = False
		Else
			kLeftHandDisplay = None
			iTypeLeftHandDisplay = iSlotIrrelevant
			sLeftModel = ""
			sLeftModelAlternate = ""
			bLeftEquipped = False
			bLeftUpdateModel = False
		EndIf
	EndFunction

;EQUIPMENT CHANGES
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		Armor akABaseObject = akBaseObject as Armor
		If!akABaseObject
			UpdateNPCHandObjects()
		Else
			If akABaseObject.HasKeyword(kKYWDDisplayArmor)
				If(akABaseObject == kAllGUDNPCWeaponRight)
					If(!bRightEquipped);Bad NPC! Take that off!
						UnequipAGUDArmor(TheRightHand)
					EndIf
				Else
					If(!bLeftEquipped);Bad NPC! Take that off!
						UnequipAGUDArmor(TheLeftHand)
					EndIf
				EndIf
			Else
				CheckBackItem()
				If(Math.LogicalAnd(akABaseObject.GetSlotMask(), iSlotMaskLeftHand) == iSlotMaskLeftHand)
					;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Equipped: "+akBaseObject.GetName())
					UpdateNPCHandObjects()
				EndIf
				If(Math.LogicalAnd(akABaseObject.GetSlotMask(),iSlotMaskTorso) == iSlotMaskTorso)
					ReWeighNodes()
				EndIf
			EndIf
		EndIf
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		Armor akABaseObject = akBaseObject as Armor
		If(akABaseObject)
			CheckBackItem()
			If(Math.LogicalAnd(akABaseObject.GetSlotMask(),iSlotMaskTorso) == iSlotMaskTorso)
				ReWeighNodes()
			EndIf
		EndIf
	EndEvent
	
	Function CheckBackItem()
		Bool bCurrentStatus = (NonAllGUDInSlot(iSlotMaskCloak) || NonAllGUDInSlot(iSlotMaskBackpack))
		If bWearingBackItem != bCurrentStatus
			bWearingBackItem = bCurrentStatus
			If bLeftEquipped && (iTypeLeftHandDisplay == iSlotShield)
				;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Cloak or Backpack equipped/removed, updating Shield position")
				UpdateAGUDModel(TheLeftHand)
			EndIf
		EndIf
	EndFunction

	Bool Function NonAllGUDInSlot(Int aiSlotMask)
		If(kActor.GetWornForm(aiSlotMask))
			Return !kActor.GetWornForm(aiSlotMask).HasKeyword(kKYWDDisplayArmor)
		EndIf
		Return False
	EndFunction

	Function UpdateNPCHandObjects()
		If bProcessingHandObjects
			bUpdateHandObjectQueued = True
		Else
			bProcessingHandObjects = True
			;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Current Equipment: Right Hand:"+kActor.GetEquippedObject(1) + " Left Hand:"+kActor.GetEquippedObject(0))
			;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Old Equipment: Right Hand:"+kRightHand + " Left Hand:"+kLeftHand)
			;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Old Display: Right Hand:"+kRightHandDisplay + " Left Hand:"+kLeftHandDisplay)
		;Right Hand
			Form kCurrentHand = kActor.GetEquippedObject(1)
			If(kCurrentHand != kRightHand) ;Right hand change
				If(kRightHand)
					If(iTypeRightHand > iSlotIrrelevant && kRightHand != kRightHandDisplay && kActor.GetItemCount(kRightHand) > 0) ;New valid weapon unequipped
						;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Is Replacing "+ kRightHandDisplay +" with "+ kRightHand)
						kRightHandDisplay = kRightHand
						iTypeRightHandDisplay = iTypeRightHand
						ReWeighNodes()
					EndIf
				EndIf
				kRightHand = kCurrentHand
				iTypeRightHand = GetAllGUDItemSlot(kRightHand)
				
				If(iTypeRightHand == iSlotStaff) ;Staff equipped! Priority Status!
					;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] New Right-hand Staff")
					kRightHandDisplay = kRightHand
					iTypeRightHandDisplay = iTypeRightHand
					ReWeighNodes()
					sRightModel = AppendModelPath((kRightHandDisplay as Weapon).GetModelPath(), "Right")
					If(!bWeaponDrawn) ;Drawn staff does not need to display asap.
						bRightEquipped = True
						bRightUpdateModel = True
					;Else ;Might actually be good to unequip the previous now, for consistency
					EndIf
				ElseIf(kRightHandDisplay)
					If iTypeRightHandDisplay == iTypeRightHand
						;Unequip display if same type as current hand.
						UnequipAGUDArmor(TheRightHand)
						ClearAGUDArmor(TheRightHand)
					ElseIf((iTypeRightHandDisplay > iSlotIrrelevant) && (kActor.GetItemCount(kRightHandDisplay) > 0))
						;Valid weapon, not same type as hand object, still present in inventory.
						;EQUIP THE RH WEAPON DISPLAY
						If(iTypeRightHandDisplay == iSlotStaff)
							sRightModel = AppendModelPath((kRightHandDisplay as Weapon).GetModelPath(), "Right")
						Else
							sRightModel = AppendModelPath((kRightHandDisplay as Weapon).GetModelPath(), "Armor")
						EndIf
						;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] New RH Display: " + sRightModel)
						bRightEquipped = True
						UpdateAGUDModel(TheRightHand)
						;RH should be cleared if it one copy and in the left-hand.
					Else ;Item removed from inventory
						UnequipAGUDArmor(TheRightHand)
						ClearAGUDArmor(TheRightHand)
					EndIf
				Else ;Item is none
					UnequipAGUDArmor(TheRightHand)
					ClearAGUDArmor(TheRightHand)
				EndIf
				
			;If only copy is equipped in RH, remove from LH display
				If(kRightHand)
					If((kActor.GetItemCount(kRightHand) == 1) && (kLeftHandDisplay == kRightHand))
						UnequipAGUDArmor(TheLeftHand)
						ClearAGUDArmor(TheLeftHand)
					EndIf
				EndIf
			ElseIf(kCurrentHand == kRightHandDisplay)
				If((iTypeRightHandDisplay != iSlotStaff) || bWeaponDrawn)
					UnequipAGUDArmor(TheRightHand)
				EndIf
			EndIf
			
		;Left Hand
			kCurrentHand = kActor.GetEquippedObject(0)
			If(kCurrentHand != kLeftHand);LH Hasn't been checked before
				kLeftHand = kCurrentHand
				iTypeLeftHand = GetAllGUDItemSlot(kLeftHand)
				If(iTypeLeftHand > iSlotIrrelevant && iTypeLeftHand <= iSlotStaff)
					iTypeLeftHand += iSlotLeftStart ;adjust slot number for one-handers
				EndIf
				If((kLeftHand != kLeftHandDisplay) && kLeftHand) ;LH in hand does not match the display
					If(iTypeLeftHand >= iSlotLeftStart && (kActor.GetItemCount(kLeftHand) > 0 )) ;Left-hand is a 1hMelee, Staff, or Shield.
						iTypeLeftHandDisplay = iTypeLeftHand
						kLeftHandDisplay = kLeftHand
						If(iTypeLeftHandDisplay == iSlotShield) ;SHIELD
							sLeftModel = AppendModelPath((kLeftHandDisplay as Armor).GetNthArmorAddon(0).GetModelPath(False, False), "OnBack")
							sLeftModelAlternate = AppendModelPath((kLeftHandDisplay as Armor).GetNthArmorAddon(0).GetModelPath(False, False), "OnBackClk")
							If(!bWeaponDrawn)
								bLeftEquipped = True
								UpdateAGUDModel(TheLeftHand)
								;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] New Shield: Putting on Back")
							Else ;Shield being used for combat, don't equip on back.
								UnequipAGUDArmor(TheLeftHand)
								;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] New Shield: Keeping on Arm")
							EndIf
						Else ;Melee or Staff
							sLeftModel = AppendModelPath((kLeftHandDisplay as Weapon).GetModelPath(), "Left")
							sLeftModelAlternate = AppendModelPath((kLeftHandDisplay as Weapon).GetModelPath(), "Sheath")
							bLeftEquipped = True
							UpdateAGUDModel(TheLeftHand)
							;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] New Left-Hand Display")
							
							If((kActor.GetItemCount(kLeftHandDisplay) == 1) && (kLeftHandDisplay == kRightHandDisplay)) ;Only 1 copy and is also displayed for RH.
								UnequipAGUDArmor(TheRightHand)
								ClearAGUDArmor(TheRightHand)
							EndIf
						EndIf
					ElseIf(kLeftHandDisplay)
						If(kActor.GetItemCount(kLeftHandDisplay) > 0)
							If((kActor.GetItemCount(kLeftHandDisplay) == 1) && ((kLeftHandDisplay == kRightHandDisplay) || (kLeftHandDisplay == kRightHand)))
								;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Left-hand Display in other hand, Unequipping")
								;Only 1 copy, equipped to the other side
								UnequipAGUDArmor(TheLeftHand)
								ClearAGUDArmor(TheLeftHand)
							Else
								bLeftEquipped = True
								UpdateAGUDModel(TheLeftHand)
								;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] New Left-Hand Object, Not Supported. Previous Left-hand of type: "+ iTypeLeftHandDisplay +" will be displayed")
							EndIf
						EndIf
					EndIf
				ElseIf(iTypeLeftHandDisplay == iSlotShield) ;Shields are special because the script unequips them!
					If(bWeaponDrawn) ;Shield equipped while weapons drawn, remove from back
						bLeftEquipped = False ;Set to False so it doesn't reequip shield
						UnequipAGUDArmor(TheLeftHand)
				;/	Else ;UNCOMMENT IF NOT ASSIGNING SLOTMASK
						bLeftEquipped = True
						UpdateAGUDModel(TheLeftHand)
						Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Shield Reequipped, moving to the back")
				/;
					EndIf
				EndIf
			ElseIf(kCurrentHand == kLeftHandDisplay) && bLeftEquipped
				If(iTypeLeftHandDisplay == iSlotShield)
					If!kActor.IsEquipped(kAllGUDNPCShield)
						UpdateAGUDModel(TheLeftHand)
						;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Left Shield Display Missing, Reequipping")
					EndIf
				Else
					If!kActor.IsEquipped(kAllGUDNPCWeaponLeft)
						UpdateAGUDModel(TheLeftHand)
						;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] LeftWeaponDisplay Missing, Reequipping")
					EndIf
				EndIf
			EndIf
			
			bProcessingHandObjects = False
			If bUpdateHandObjectQueued
				bUpdateHandObjectQueued = False
				UpdateNPCHandObjects()
			EndIf
		EndIf
	EndFunction

	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
		;Idea by CaptainGabi. Thanks for all the assistance!
		If(gvbAutoEquipStaves.GetValueInt() as Bool) && (akSourceContainer == PlayerRef)
			Int iNativeStaffType = 8
			Weapon akWeapon = akBaseItem as Weapon
			if(akWeapon)
				If(akWeapon.GetWeaponType() == iNativeStaffType)
					If(!kActor.GetEquippedObject(0))
						kActor.EquipItemEx(akWeapon, 2)
					ElseIf(!kActor.GetEquippedObject(1))
						kActor.EquipItemEx(akWeapon, 1)
					EndIf
				EndIf
			EndIf
		EndIf
	EndEvent
	
	Event OnItemRemoved(Form akBaseObject, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
		;This won't be triggered while effect is off.
		Int iRemainingCount = kActor.GetItemCount(akBaseObject)
		;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Removed item: " + akBaseObject.GetName() + " Remaining: " + iRemainingCount)
		If akBaseObject == kRightHand
			;Debug.Trace("    "+akBaseObject.GetName()+" was in RH")
			If(iRemainingCount == 0)
				kRightHand = None
				iTypeRightHand = iSlotIrrelevant
			ElseIf(iRemainingCount == 1)
				If(kRightHand == kLeftHandDisplay)
					UnequipAGUDArmor(TheLeftHand)
					ClearAGUDArmor(TheLeftHand)
				ElseIf(kRightHand == kLeftHand)
					kLeftHand = None
					iTypeLeftHand = iSlotIrrelevant
				EndIf
			EndIf
		EndIf
		If akBaseObject == kRightHandDisplay
			;Debug.Trace("    "+akBaseObject.GetName()+" was the RH Display")
			If(iRemainingCount == 0)
				UnequipAGUDArmor(TheRightHand)
				ClearAGUDArmor(TheRightHand)
			ElseIf(iRemainingCount == 1)
				If(kRightHandDisplay == kLeftHandDisplay)
					UnequipAGUDArmor(TheLeftHand)
					ClearAGUDArmor(TheLeftHand)
				ElseIf(kRightHandDisplay == kLeftHand)
					UnequipAGUDArmor(TheRightHand)
					ClearAGUDArmor(TheRightHand)
				EndIf
			EndIf
		EndIf
		If akBaseObject == kLeftHand
			;Debug.Trace("    "+akBaseObject.GetName()+" was in the LH")
			If(iRemainingCount == 0)
				kLeftHand = None
				iTypeLeftHand = iSlotIrrelevant
			EndIf
		EndIf
		If akBaseObject == kLeftHandDisplay
			;Debug.Trace("    "+akBaseObject.GetName()+" was the LH Display")
			If(iRemainingCount == 0)
				UnequipAGUDArmor(TheLeftHand)
				ClearAGUDArmor(TheLeftHand)
			EndIf
		EndIf
	EndEvent
	
;NODE POSITIONS
	Function UpdateNiNode(Int aiNode)
		String sWeaponArmorNode
		
		If(aiNode == iNodeTwoHMelee)
			sWeaponArmorNode = sWeaponDefaultNodes[iNodeTwoHMelee]+"Armor"
			Weapon kWeapon = kRightHandDisplay as Weapon
			If((kWeapon.GetWeaponType() == 5) || !bXPMSEInstalled)
				aiNode = iNodeTwoHMelee
			Else
				aiNode = iNodePolearm
			EndIf
		ElseIf(aiNode == iNodeRange)
			sWeaponArmorNode = sWeaponDefaultNodes[iNodeRange]+"Armor"
			Weapon kWeapon = kRightHandDisplay as Weapon
			If((kWeapon.GetWeaponType() == 7) || !bXPMSEInstalled)
				aiNode = iNodeRange
			Else
				aiNode = iNodeCrossBow
			EndIf
		Else
			sWeaponArmorNode = sWeaponDefaultNodes[aiNode]+"Armor"
		EndIf
		
	;ReStyle
		;I'll fix this when Groovtama fixes his shield sheath style for NPCs
	
	;REALIGNMENT
		;Debug.Trace(kActor.GetActorBase().GetName() + "["+d2h(kActor.GetFormID())+"] Reweighing:"+sWeaponArmorNode+" to:"+sWeaponDefaultNodes[aiNode])
		;Get proper position and current positions.
		Float[] fNewTransformPosition = new Float[3]
		Float[] fOldTransformPosition = new Float[3]
		;Third Person
		NetImmerse.GetNodeLocalPosition(kActor, sWeaponDefaultNodes[aiNode], fNewTransformPosition, False)
		NetImmerse.GetNodeLocalPosition(kActor, sWeaponArmorNode, fOldTransformPosition, False)
		If(fNewTransformPosition != fOldTransformPosition)
			NetImmerse.SetNodeLocalPosition(kActor, sWeaponArmorNode, fNewTransformPosition, False)
		EndIf
		;First Person
		NetImmerse.GetNodeLocalPosition(kActor, sWeaponDefaultNodes[aiNode], fNewTransformPosition, True)
		NetImmerse.GetNodeLocalPosition(kActor, sWeaponArmorNode, fOldTransformPosition, True)
		If(fNewTransformPosition != fOldTransformPosition)
			NetImmerse.SetNodeLocalPosition(kActor, sWeaponArmorNode, fNewTransformPosition, True)
		EndIf
	EndFunction
	
	Function ReWeighNodes()
		;Unlike player, only needs the RH
		If iTypeRightHandDisplay > iSlotIrrelevant
			If iTypeRightHandDisplay < iSlotStaff
				UpdateNiNode(iTypeRightHandDisplay)
			Else
				Int iNode = iTypeRightHandDisplay - 1
				UpdateNiNode(iNode)
			EndIf
		EndIf
	EndFunction

;MISC
	string function d2h(int d, bool bWith0x = false)
		;Function taken from Nexus Forums, a post by 'mlheur', July 28th 2016.
		string digits = "0123456789ABCDEF"
		string hex
		int shifted = 0
		while shifted < 32
			hex = StringUtil.GetNthChar(digits, Math.LogicalAnd(0xF, d)) + hex
			d = Math.RightShift(d, 4)
			shifted += 4
		endwhile
		if bWith0x
			hex = "0x" + hex
		endif
		return hex
	endfunction
