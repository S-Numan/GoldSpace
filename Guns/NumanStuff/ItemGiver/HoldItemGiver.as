//hig. upon being held, gives user item. if user already has item in spot, removes that item and makes it into another hig.
//This blob should be created with no init, then the init should be ran after.

#include "WeaponCommon.as";
#include "AllWeapons.as";

void onInit( CBlob@ this )
{
    this.addCommandID("sync_equipment");

    it::IModiStore@ equipment = @null;
    this.get("pickup_equipment", @equipment);
    
    if(equipment == @null)//equipment not set?
    {
        //Set test item for debug purposes
        u8 equip_slot;
        this.set("pickup_equipment", @TestWeapon(equip_slot));
        
        this.set_u8("equip_slot", equip_slot);
    }
    
    this.Tag("equipment_giver");
}
       

void onTick( CBlob@ this )
{

}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
    if(attached.getCarriedBlob() != @this) { return; }
    //Past this point, we're sure that the carried blob is this.
    it::IModiStore@ modi_store;
    this.get("pickup_equipment", @modi_store);
    if(modi_store == @null) { Nu::Error("pickup_equipment was null."); return;}

    addEquipment(@this, @attached, @modi_store, this.get_u8("equip_slot"));
}

void addEquipment(CBlob@ this, CBlob@ attached, it::IModiStore@ to_add, u8 equip_slot)
{
    array<it::IModiStore@>@ equipment;
    if(!attached.get("equipment", @equipment)) { Nu::Error("equipment array was null"); return; }

    if(equipment[equip_slot] != @null)//Equipment slot already taken?
    {
        if(isServer())
        {
            CBlob@ hig = server_CreateBlobNoInit("hig");//Create a new hig
            hig.setPosition(this.getPosition());//Set the hig to the position where it was last-ish.
            hig.set("pickup_equipment", @equipment[equip_slot]);//Give the hig the weapon.
            
            CBitStream params;
            //params.write_u8(i);
            //this.SendCommand(this.getCommandID("sync_equipment"), params);
        }
    }

    @equipment[equip_slot] = @to_add;

    //this.set("equipment", @equipment);

    if(isServer())
    {
        this.server_Die();
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if(this.getCommandID("sync_equipment") == cmd)
	{

	}
}