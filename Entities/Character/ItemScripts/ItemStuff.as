//Todo, make this better. it's bad

#include "WeaponCommon.as";
#include "NuLib.as";


void onInit(CBlob@ this)
{
    it::onInitSync(@this);

    //Can't cast properly in kag angelscript, so I literally don't know how to do this in a better way.
    array<it::IModiStore@>@ equipment = @array<it::IModiStore@>(11, @null);


    this.set("equipment", @equipment);//Equipment
    
    this.set_u8("current_equip", 0);//Currently equiped thing in equipment array
}

void onReload(CBlob@ this)
{
    onInit(@this);
}

void onTick(CBlob@ this)
{
    if(!this.isMyPlayer()) { return; }

    CControls@ controls = @getControls();
    if(controls == @null) { Nu::Error("controls was null"); return; }

    array<it::IModiStore@>@ equipment;
    if(!this.get("equipment", @equipment)) { Nu::Error("equipment array was null"); return; }

    u16 i;

    for(i = 0; i < equipment.size(); i++)
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
    
}



f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
 	Vec2f aimvector = holder.getAimPos() - this.getInterpolatedPosition();
	return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}


void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if(it::onCommandSync(@this, cmd, @params))
    {
        
    }
    else
    {

    }
}

class handlee
{
    handlee()
    {

    }
    handlee(handlee@ hand)
    {

    }
}