#define MAX_ANIMSET			(8)
#define MAX_ANIMS_PER_SET	(8)


static
			anm_Animations[MAX_ANIMSET][MAX_ANIMS_PER_SET],
			anm_TotalAnimations[MAX_ANIMSET],
			anm_TotalAnimSets;


/*==============================================================================

	Core

==============================================================================*/


DefineAnimSet()
{
	if(anm_TotalAnimSets == MAX_ANIMSET)
	{
		print("ERROR: MAX_ANIMSET limit reached.");
		return -1;
	}

	return anm_TotalAnimSets++;
}

AddAnimToSet(animset, idx)
{
	if(!(0 <= animset < anm_TotalAnimSets))
		return -1;

	anm_Animations[animset][anm_TotalAnimations[animset]] = idx;

	return anm_TotalAnimations[animset]++;
}


/*==============================================================================

	Interface Functions

==============================================================================*/


stock GetAnimSetSize(animset)
{
	if(!(0 <= animset < anm_TotalAnimSets))
		return 0;

	return anm_TotalAnimations[animset];
}

stock GetAnimSetAnimations(animset, output[])
{
	if(!(0 <= animset < anm_TotalAnimSets))
		return 0;

	for(new i; i < anm_TotalAnimations[animset]; i++)
	{
		output[i] = anm_Animations[i];
	}

	return anm_TotalAnimations[animset];
}

stock GetAnimSetAnimationIdx(animset, cell)
{
	if(!(0 <= animset < anm_TotalAnimSets))
		return 0;

	return anm_Animations[animset][cell];
}
