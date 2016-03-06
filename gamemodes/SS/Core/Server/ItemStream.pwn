/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

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


/*
	WORK IN PROGRESS!
*/

stock GetItemStream(items[], output[], count)
{
	new idx;

	for(new i; i < count; i++)
	{
		if(!IsValidItem(items[i]))
			continue;

		output[idx++] = GetItemType(items[i]);
		output[idx++] = 1;
		output[idx++] = GetItemExtraData(items[i]);
	}
}

stock GetItemStreamFromContainer(containerid, output[])
{
	if(!IsValidContainer(containerid))
		return 0;

	new
		itemid,
		idx;

	for(new i; i < GetContainerSize(containerid); i++)
	{
		itemid = GetContainerSlotItem(containerid, i)

		output[idx++] = GetItemType(itemid);
		output[idx++] = 1;
		output[idx++] = GetItemExtraData(itemid);
	}

	return 1;
}

stock CreateItemsFromItemStream(stream[], size, output[], count)
{
	for(new i; i < size; i++)
	{

	}
}
