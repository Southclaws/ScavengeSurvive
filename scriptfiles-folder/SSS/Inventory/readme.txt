The files in this folder contain player inventory/bag data

Items are stored as "itemtype-extradata" pairs, like so:

	itemtype1, extradata
	itemtype2, extradata
	itemtype3, extradata
	etc...

The first 8 cells are 4 itemtype-extradata pairs.
Then one cell determines the bag type.
After this there are 9 itemtype-extradata pairs for items within the bag.
