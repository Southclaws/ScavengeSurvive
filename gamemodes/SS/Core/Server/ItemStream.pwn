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
