from .item import Item


GEID_LEN = 16


class ItemSequence:
    def __init__(self, source):
        if isinstance(source, list):
            self.items = self.from_array(source)
        else:
            raise ValueError

    def __repr__(self):
        return str(self.items)

    def from_array(self, array):
        result = []
        expected_item_count = array[1]

        itm_arr_Size = 2
        itm_list_Count = 0

        itm_list_ArraySize = None
        itm_list_Item = None
        itm_list_WorldX = None
        itm_list_WorldY = None
        itm_list_WorldZ = None
        itm_list_RotationX = None
        itm_list_RotationY = None
        itm_list_RotationZ = None
        itm_list_VirtualWorld = None
        itm_list_Interior = None
        itm_list_Hitpoints = None
        itm_list_GEID = None
        itm_list_Array = None

        if len(array) != array[0]:
            print("size in first cell (%d) does not match size passed in (%d)",
                  array[0], len(array))

        while(itm_list_Count < expected_item_count):
            itm_list_ArraySize = (
                array[itm_arr_Size] - (11 + GEID_LEN))
            itm_arr_Size += 1

            itm_list_Item = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_WorldX = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_WorldY = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_WorldZ = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_RotationX = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_RotationY = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_RotationZ = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_VirtualWorld = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_Interior = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_Hitpoints = array[itm_arr_Size]
            itm_arr_Size += 1

            itm_list_GEID = array[itm_arr_Size]
            itm_arr_Size += GEID_LEN

            if itm_list_ArraySize > 0:
                itm_list_Array = array[itm_arr_Size]
                itm_arr_Size += itm_list_ArraySize

            itm_list_Count += 1

            result.append(Item(
                itm_list_Item,
                itm_list_WorldX,
                itm_list_WorldY,
                itm_list_WorldZ,
                itm_list_RotationX,
                itm_list_RotationY,
                itm_list_RotationZ,
                itm_list_VirtualWorld,
                itm_list_Interior,
                itm_list_Hitpoints,
                0,
                "",
                itm_list_GEID,
                itm_list_Array))

        if itm_arr_Size != array[0]:
            print("itm_arr_Size != array[0] (%d != %d)",
                  itm_arr_Size, array[0])

        return result
