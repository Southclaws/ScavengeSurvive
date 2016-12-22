class ItemType:
    def __init__(self, typeid, name, uname, model, size,
                 offsetRotX, offsetRotY, offsetRotZ,
                 zModelOffset, zButtonOffset, attachPosX, attachPosY,
                 attachPosZ, attachRotX, attachRotY, attachRotZ,
                 useCarryAnim, colour, attachBone, longPickup, maxHitPoints):

        self.typeid = typeid
        self.name = name
        self.uname = uname
        self.model = model
        self.size = size
        self.offsetRotX = offsetRotX
        self.offsetRotY = offsetRotY
        self.offsetRotZ = offsetRotZ
        self.zModelOffset = zModelOffset
        self.zButtonOffset = zButtonOffset
        self.attachPosX = attachPosX
        self.attachPosY = attachPosY
        self.attachPosZ = attachPosZ
        self.attachRotX = attachRotX
        self.attachRotY = attachRotY
        self.attachRotZ = attachRotZ
        self.useCarryAnim = useCarryAnim
        self.colour = colour
        self.attachBone = attachBone
        self.longPickup = longPickup
        self.maxHitPoints = maxHitPoints


class Item:
    def __init__(self, typeid, posX, posY, posZ, rotX, rotY, rotZ,
                 world, interior, hitPoints, exData, nameEx, geid, arrayData):
        self.typeid = typeid
        self.posX = posX
        self.posY = posY
        self.posZ = posZ
        self.rotX = rotX
        self.rotY = rotY
        self.rotZ = rotZ
        self.world = world
        self.interior = interior
        self.hitPoints = hitPoints
        self.exData = exData
        self.nameEx = nameEx
        self.geid = geid
        self.arrayData = arrayData

    def __repr__(self):
        return str(self.typeid)
