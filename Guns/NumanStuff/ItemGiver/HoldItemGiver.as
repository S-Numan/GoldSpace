//hig. upon being held, gives user item. if user already has item in spot, removes that item and makes it into another hig.
//This blob should be created with no init, then the init should be ran after.

#include "WeaponCommon.as";
#include "AllWeapons.as"

void onInit( CBlob@ this )
{
    this.Tag("item_giver");

    if(this.get_string("item_type").size() == 0)//if item_type(equipment) was not set.
    {
        u8 equip_slot;
        string item_type;
        this.set("equipment", @TestWeapon(equip_slot, item_type));
        
        this.set_u8("equip_slot", equip_slot);
        this.set_string("item_type", item_type);
    }
}
       

void onTick( CBlob@ this )
{

}