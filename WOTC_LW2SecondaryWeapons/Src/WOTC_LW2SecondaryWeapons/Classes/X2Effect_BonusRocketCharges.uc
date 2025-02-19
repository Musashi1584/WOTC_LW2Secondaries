//---------------------------------------------------------------------------------------
//  FILE:    X2Effect_BonusRocketCharges
//  AUTHOR:  Amineri (Pavonis Interactive)
//  PURPOSE: General effect for granting extra uses of rocket-type items -- technical class only
//--------------------------------------------------------------------------------------- 

class X2Effect_BonusRocketCharges extends X2Effect_Persistent;

var int BonusUses;
var EInventorySlot SlotType;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		UnitState; 
	local XComGameState_Item		ItemState, UpdatedItemState;
	local X2MultiWeaponTemplate		WeaponTemplate;
	local int						Idx, BonusAmmo;

	// Skip initial mission setup effects if initiating a later stage of a multi-part mission
	if (class'X2Condition_TacticalToTacticalTransfer'.static.SkipSetupForMultiPartMission(ApplyEffectParameters))
		return;

	History = `XCOMHISTORY;

	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState == none)
		return;

	for (Idx = 0; Idx < UnitState.InventoryItems.Length; ++Idx)
	{
		ItemState = XComGameState_Item(History.GetGameStateForObjectID(UnitState.InventoryItems[Idx].ObjectID));
		if (ItemState != none && !ItemState.bMergedOut)
		{
			//only works for the technical multiweapon
			WeaponTemplate = X2MultiWeaponTemplate(ItemState.GetMyTemplate());
			if(WeaponTemplate != none)
			{
				BonusAmmo = 0;
				if (WeaponTemplate != none && WeaponTemplate.bMergeAmmo)
				{
					if (ItemState.InventorySlot == SlotType)
						BonusAmmo += BonusUses;
				}
				if(BonusAmmo > 0)
				{
					UpdatedItemState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', ItemState.ObjectID));
					UpdatedItemState.Ammo += BonusAmmo;
					NewGameState.AddStateObject(UpdatedItemState);
				}
			}
		}
	}

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

defaultProperties
{
	DuplicateResponse=eDupe_Allow
	bInfiniteDuration = true;
}