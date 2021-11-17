#include "WeaponCommon.as";

it::itemaim@ example_thing;

void onInit( CBlob@ this )
{
    print("created TestItem");   
    CShape@ shape = this.getShape();
    @example_thing = @it::itemaim();
    example_thing.Init();

    //example_thing.addUseListener(@onUse);

    //example_thing.addShotListener(@onShot);
    
    example_thing.max_ammo[BaseValue] = 17;
    example_thing.setAmmoLeft(example_thing.max_ammo[CurrentValue]);

    example_thing.shots_per_use[BaseValue] = 5;//3 Shots per use

    example_thing.shot_afterdelay[BaseValue] = 15;//Half a second per shot

    //example_thing.using_mode[BaseValue] = 1;//Full auto!
    example_thing.using_mode[BaseValue] = 2;//use on release

    example_thing.use_with_queued_shots[BaseValue] = false;

    example_thing.use_sfx = "arrow_hit_ground.ogg";

    example_thing.shot_sfx = "AssaultFire.ogg";

    example_thing.empty_total_sfx = "BulletImpact.ogg";

    example_thing.empty_total_ongoing_sfx = "ShellDrop.ogg";

    example_thing.use_afterdelay[BaseValue] = 4;

    example_thing.no_ammo_no_shots[BaseValue] = true;

    example_thing.use_with_shot_afterdelay[BaseValue] = false;

    example_thing.charge_down_per_use[BaseValue] = 0.0f;

    example_thing.charge_up_time[BaseValue] = 10;

    example_thing.charge_down_per_tick[BaseValue] = 0.2f;

    example_thing.allow_non_charged_shots[BaseValue] = true;

    example_thing.charge_during_use[BaseValue] = true;



    example_thing.random_shot_spread[BaseValue] = 5.0f;

    example_thing.min_shot_spread[BaseValue] = 2.0f;
    example_thing.max_shot_spread[BaseValue] = 9999.0f;

    example_thing.spread_gain_per_shot[BaseValue] = 30.0f;

    example_thing.spread_loss_per_tick[BaseValue] = 1.0f;





    example_thing.DebugModiVars(true);
    example_thing.DebugVars();
}

void onTick( CBlob@ this )
{/*
    if(!this.isAttached()){//Not attached?
        return;//Stop
    }
    CBlob@ plob = @getLocalPlayerBlob();
    if(plob == @null){//Player blob doesn't exist?
        return;//Stop
    }
    if(!this.isAttachedTo(@plob)){//Not attached to the local player?
        return;//Stop
    }
    CControls@ controls = getControls();
    if(controls == @null){//Controls doesn't exist/
        return;//Stop
    }
    example_thing.Tick(@controls);
    //print("charge = " + example_thing.getCurrentCharge());

    Vec2f direction;
    //print("a");
    //this.getAimDirection(direction);
    //direction = this.getAimPos();
    
    plob.getAimDirection(direction);
    //for x -1 is left
    //for x 1 is right
    //for y -1 is up
    //for y 1 is down

    Vec2f aimpos = plob.getAimPos();//Controller
	Vec2f pos = plob.getPosition();//Held thing?
	Vec2f aimVec = aimpos - pos;
    f32 distance1 = aimVec.Normalize();
    f32 distance2 = (aimpos - pos).getLength();
    
    //print("aimangle1 = " + getAimAngle(plob, plob));

    //print("aimangle2 = " + aimVec.getAngleDegrees());
    //print("x = " + distance);
    //print("y = " + aimVec.y);


    //print("x = " + direction.x);
    //print("y = " + direction.y);*/
}


f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
 	Vec2f aimvector = holder.getAimPos() - this.getInterpolatedPosition();
	return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}



void onUse(array<Modif32@>@ f32_array, array<Modibool@>@ bool_array, array<DefaultModifier@>@ all_modifiers)
{
    print("\n\nthis has been used");
    print("f32_array.size() == " + f32_array.size());
    print("bool_array.size() == " + bool_array.size());
    print("all_modifiers.size() == " + all_modifiers.size());
    //example_thing.DebugModiVars(true);
    example_thing.DebugVars();
}

void onShot(f32 shot_angle, array<Modif32@>@ f32_array, array<Modibool@>@ bool_array, array<DefaultModifier@>@ all_modifiers)
{
    print("\n\nthis has been shot");
    print("f32_array.size() == " + f32_array.size());
    print("bool_array.size() == " + bool_array.size());
    print("all_modifiers.size() == " + all_modifiers.size());
    //example_thing.DebugModiVars(true);
    example_thing.DebugVars();
}