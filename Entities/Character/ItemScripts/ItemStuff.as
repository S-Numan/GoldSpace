//Todo, make this better. it's bad

#include "WeaponCommon.as";
#include "NuLib.as";


void onInit(CBlob@ this)
{
    array<it::basemodistore@>@ equipment = @array<it::basemodistore@>(11, @null);
    this.set("equipment", @equipment);//Equipment
    
    this.set_u8("current_equip", 0);//Currently equiped thing in equipment array
}

void onReload(CBlob@ this)
{
    onInit(@this);
}

void onTick(CBlob@ this)
{
    array<it::basemodistore@>@ equipment;
    if(!this.get("equipment", @equipment)) { Nu::Error("equipment array was null"); return; }
    
    CControls@ controls = @this.getControls();
    if(controls == @null) { Nu::Error("controls was null"); return; }

    for(u16 i = 0; i < equipment.size(); i++)
    {
        if(equipment[i] == @null) { continue; }
        equipment[i].Tick(@controls);
    }



    //print("charge = " + example_thing.getCurrentCharge());

    Vec2f direction;
    //print("a");
    //this.getAimDirection(direction);
    //direction = this.getAimPos();
    
    this.getAimDirection(direction);
    //for x -1 is left
    //for x 1 is right
    //for y -1 is up
    //for y 1 is down

    Vec2f aimpos = this.getAimPos();//Controller
	Vec2f pos = this.getPosition();//Held thing?
	Vec2f aimVec = aimpos - pos;
    f32 distance1 = aimVec.Normalize();
    f32 distance2 = (aimpos - pos).getLength();
    
    //print("aimangle1 = " + getAimAngle(plob, plob));

    //print("aimangle2 = " + aimVec.getAngleDegrees());
    //print("x = " + distance);
    //print("y = " + aimVec.y);


    //print("x = " + direction.x);
    //print("y = " + direction.y);
}






void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
    if(this.getCarriedBlob() != @attached) { return; }
    //Past this point, we're sure that the attached blob is the carried blob.
    if(attached.hasTag("item_giver"))
    {
        array<it::basemodistore@>@ equipment;
        if(!this.get("equipment", @equipment)) { Nu::Error("equipment array was null"); return; }

        int item_type = attached.get_string("item_type").getHash();
        if(item_type == "basemodistore".getHash())
        {
            
        }
        else if(item_type == "activatable".getHash())
        {

        }
        else if(item_type == "item".getHash())
        {

        }
        else if(item_type == "itemaim".getHash())
        {
            it::basemodistore@ _itemaim;
            attached.get("equipment", @_itemaim);
            addEquipment(@this, @_itemaim, this.get_u8("equip_slot"));
        }
        else if(item_type == "weapon".getHash())
        {
            
        }
        else
        {
            Nu::Error("unknown item type"); return;
        }

        if(isServer())
        {
            attached.server_Die();
        }
    }
}

void addEquipment(CBlob@ this, it::basemodistore@ to_add, u8 equip_slot)
{
    array<it::basemodistore@>@ equipment;
    if(!this.get("equipment", @equipment)) { Nu::Error("equipment array was null"); return; }

    @equipment[equip_slot] = @to_add;//TODO, see if casting works.

    this.set("equipment", @equipment);
}




f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
 	Vec2f aimvector = holder.getAimPos() - this.getInterpolatedPosition();
	return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}