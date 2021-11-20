//hig. upon being held, gives user item. if user already has item in spot, removes that item and makes it into another hig.
//This blob should be created with no init, then the init should be ran after.

//Todo, wait why do I even need to destroy and make a new one of these when picking up. If it already has a thing, just swap it out? 

#include "WeaponCommon.as";
#include "AllWeapons.as";

void onInit( CBlob@ this )
{
    it::onInitSync(@this);

    this.addCommandID("deserialize_equipment");
    //this.addCommandID("new_hig");
    
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
    if(modi_store == @null)
    {
        warning("pickup_equipment was null in hig. Making debug pickup_equipment");
        u8 equip_slot;
        this.set("pickup_equipment", @CreateWeapon(wep::TestWeapon, @this, equip_slot));
        this.set_u8("equip_slot", equip_slot);

        this.get("pickup_equipment", @modi_store);
        if(modi_store == @null){ Nu::Error("bruh"); return; }
    }

    addEquipment(@this, @attached, @modi_store, this.get_u8("equip_slot"));
}

void addEquipment(CBlob@ this, CBlob@ attached, it::IModiStore@ to_add, u8 equip_slot)
{
    array<it::IModiStore@>@ equipment;
    if(!attached.get("equipment", @equipment)) { Nu::Error("equipment array was null"); return; }

    if(equipment[equip_slot] != @null)//Equipment slot already taken?
    {
        if(attached.isMyPlayer())
        {
            equipment[equip_slot].setOwner(@this);
            CBitStream@ bs = @CBitStream();
            equipment[equip_slot].Serialize(@bs
            , false);//No sfx
            this.SendCommand(this.getCommandID("deserialize_equipment"), bs);
        }
    }
    else if(isServer())//Not swapping out?
    {
        this.server_Die();//Just remove it.
    }

    @equipment[equip_slot] = @to_add;
    equipment[equip_slot].setOwner(@attached);
    equipment[equip_slot].setID(equip_slot);

    //this.set("equipment", @equipment);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if(it::onCommandSync(@this, cmd, @params))
    {
        
    }
    else if(this.getCommandID("deserialize_equipment") == cmd)
	{
        it::IModiStore@ equip;

        this.get("pickup_equipment", @equip);
        if(equip != @null) { Nu::Warning("pickup_equipment was not null on deserialize_equipment"); }

        u8 class_type;
        if(!params.saferead_u8(class_type)) { Nu::Error("failure to read class_type0."); return; }

        u16 initial_item;
        if(!params.saferead_u16(initial_item)) { Nu::Error("failure to read initial_item0."); return; }

        u8 equip_slot;

        @equip = @CreateWeapon(initial_item, @this, equip_slot, 
        true,//SFX
        true,//Functions
        false//Modivars
        );
        equip.Deserialize(@params);

        this.set("pickup_equipment", @equip);
        this.set_u8("equip_slot", equip_slot);
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
    else if(this.getCommandID("syncvf32") == cmd)
    {
        print("wrong");
    }
    else if(this.getCommandID("syncvbool") == cmd)
    {
        print("wrong");
    }
    else if(this.getCommandID("syncf32base") == cmd)
    {
        print("wrong");
    }
    else if(this.getCommandID("syncboolbase") == cmd)
    {
        print("wrong");
    }
}