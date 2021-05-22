Scriptname AGUD_NPCWeaponApplicator extends activemagiceffect  

{All Geared Up - Adds an ability to NPCs that come in contact with the cloak ability that the player has.}

Spell Property kSPELNPCWeapons Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If(akTarget)
		akTarget.AddSpell(kSPELNPCWeapons)
	EndIf
EndEvent