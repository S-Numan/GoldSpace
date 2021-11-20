//hig. upon being held, gives user item. if user already has item in spot, removes that item and makes it into another hig.
//This blob should be created with no init, then the init should be ran after.

//Todo, wait why do I even need to destroy and make a new one of these when picking up. If it already has a thing, just swap it out? 

#include "WeaponCommon.as";
#include "AllWeapons.as";

void onInit( CBlob@ this )
{
    it::onInit(@this);

    //this.addCommandID("new_hig");

    array<it::IModiStore@>@ equipment = @array<it::IModiStore@>(1, @null);
    this.set("equipment", @equipment);//Equipment
    
    this.Tag("equipment_giver");
}
       

void onTick( CBlob@ this )
{

}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
    if(attached.getCarriedBlob() != @this) { return; }
    //Past this point, we're sure that the carried blob is this.
    array<it::IModiStore@>@ equipment;
    if(!this.get("equipment", @equipment)) { Nu::Error("equipment array was null"); return; }

    if(equipment[0] == @null)
    {
        warning("equipment[0] was null in hig. Making debug equipment[0]");

        @equipment[0] = @CreateItem(wep::TestWeapon, @this);

        if(equipment[0] == @null){ Nu::Error("bruh"); return; }
    }

    addEquipment(@this, @attached, @equipment[0], equipment[0].getEquipSlot());
}

void addEquipment(CBlob@ this, CBlob@ attached, it::IModiStore@ to_add, u8 equip_slot)
{
    //Get the equipment of the attached
    array<it::IModiStore@>@ equipment;
    if(!attached.get("equipment", @equipment)) { Nu::Error("equipment array was null"); return; }

    if(equipment[equip_slot] != @null)//Equipment slot of the attached already taken?
    {
        if(attached.isMyPlayer())//If this is being ran over by the player that called this.
        {
            equipment[equip_slot].setOwner(@this);//Set the new owner for the equipment slot
            it::SyncEquipment(@this, it::EquipmentBitStream(@equipment, equip_slot));//Sync to everyone. Including self.
        }
    }
    else if(isServer())//Not swapping out?
    {
        this.server_Die();//Just remove it.
    }

    @equipment[equip_slot] = @to_add;//Add it
    equipment[equip_slot].setOwner(@attached);//Set its new owner
    equipment[equip_slot].setID(equip_slot);//Set its id to the equip slot for conveinceecencien. Yes.

    //this.set("equipment", @equipment);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if(it::onCommand(@this, cmd, @params))
    {
        
    }
    /*else if(this.getCommandID("new_hig") == cmd)
    {
        if(!isServer()) { Nu::Error("Server only command used on client"); return; }
        u8 class_type;
        print("params bit index1 = " + params.getBitIndex());
        if(!params.saferead_u8(class_type)) { Nu::Error("failure to read class_type1."); return; }
        
        it::IModiStore@ equip = @CreateModiStore(class_type);
        equip.Init();
        equip.Deserialize(params);
        
        CBlob@ new_hig = server_CreateBlobNoInit("hig");//Create a new hig
        new_hig.setPosition(this.getPosition());//Set the hig to the position where it was last-ish.
        new_hig.set("pickup_equipment", @equip);//Give the hig the weapon.
        new_hig.Init();

        print("params.size = " + params.Length());
        print("params bit index2 = " + params.getBitIndex());
        params.ResetBitIndex();
        print("params bit index3 = " + params.getBitIndex());
        for(u16 i = 0; i < getPlayerCount(); i++)
        {
            new_hig.server_SendCommandToPlayer(this.getCommandID("deserialize_equipment"), params, @getPlayer(i));
        }
    }*/
}