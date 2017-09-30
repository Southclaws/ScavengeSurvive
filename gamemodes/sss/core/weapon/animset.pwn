/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


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
		err("MAX_ANIMSET limit reached.");
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
