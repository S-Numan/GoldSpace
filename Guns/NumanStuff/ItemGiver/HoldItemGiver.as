//hig. upon being held, gives user item. if user already has item in spot, removes that item and makes it into another hig.
//This blob should be created with no init, then the init should be ran after.

#include "WeaponCommon.as";
#include "AllWeapons.as";

void onInit( CBlob@ this )
{
    it::IModiStore@ equipment = @null;
    this.get("equipment", @equipment);
    
    if(equipment == @null)//equipment not set?
    {
        //Set test item for debug purposes
        u8 equip_slot;
        this.set("equipment", @TestWeapon(equip_slot));
        
        this.set_u8("equip_slot", equip_slot);
    }
    
    this.Tag("equipment_giver");
}
       

void onTick( CBlob@ this )
{

}