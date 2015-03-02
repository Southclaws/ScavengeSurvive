#include <YSI\y_hooks>


hook OnGameModeInit()
{
	CreateItem(item_HeartShapedBox, 2912.3301, 2910.2800, 29.7780);
}

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_HeartShapedBox)
	{
		if(GetItemLootIndex(itemid) != -1)
		{
			new containerid = GetItemArrayDataAtCell(itemid, 1);

			if(IsValidContainer(containerid))
			{
				AddItemToContainer(containerid, CreateItem(item_Dildo1));
				AddItemToContainer(containerid, CreateItem(item_Flowers));
				AddItemToContainer(containerid, CreateItem(item_AntiSepBandage));
				AddItemToContainer(containerid, CreateItem(item_ZorroMask));
			}
		}
	}
	#if defined hsb_OnItemCreate
		return hsb_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate hsb_OnItemCreate
#if defined hsb_OnItemCreate
	forward hsb_OnItemCreate(itemid);
#endif

