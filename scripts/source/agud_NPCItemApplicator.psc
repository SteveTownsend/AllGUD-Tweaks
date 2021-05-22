Scriptname AGUD_NPCItemApplicator extends activemagiceffect  

{All Geared Up - Adds an ability to NPCs that come in contact with the cloak ability that the player has.}

Spell Property kSPELNPCItemsM Auto
Spell Property kSPELNPCItemsF Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If(akTarget)
		If(akTarget.GetActorBase().GetSex())
			akTarget.AddSpell(kSPELNPCItemsF)
		Else
			akTarget.AddSpell(kSPELNPCItemsM)
		EndIf
	EndIf
EndEvent