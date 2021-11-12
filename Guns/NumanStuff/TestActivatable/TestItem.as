#include "WeaponCommon.as";

it::item@ example_thing;

void onInit( CBlob@ this )
{
    print("created TestItem");   
    CShape@ shape = this.getShape();
    @example_thing = @it::item();

    example_thing.addUseListener(@onUse);
    
    example_thing.max_ammo_count[BaseValue] = 17;//20 max shots
    example_thing.ammo_count_left = example_thing.max_ammo_count[CurrentValue];//20 shots in ammo at this moment

    example_thing.shots_per_use[BaseValue] = 5;//3 Shots per use

    example_thing.shot_afterdelay[BaseValue] = 15;//Half a second per shot

    example_thing.using_mode[BaseValue] = 1;//Full auto!

    example_thing.use_with_queued_shots[BaseValue] = false;

    example_thing.shot_sfx = "AssaultFire.ogg";

    example_thing.empty_total_sfx = "BulletImpact.ogg";

    example_thing.empty_total_ongoing_sfx = "ShellDrop.ogg";

    example_thing.use_afterdelay[BaseValue] = 4;

    example_thing.no_ammo_no_shots[BaseValue] = false;

    example_thing.use_with_shot_afterdelay[BaseValue] = false;

    example_thing.reset_charge_on_use[BaseValue] = true;

    example_thing.charge_up_time[BaseValue] = 10;








    example_thing.DebugModiVars(true);
    example_thing.DebugVars();
}

void onTick( CBlob@ this )
{
    if(!this.isAttached()){//Not attached?
        return;//Stop
    }
    if(getLocalPlayerBlob() == @null){//Player blob doesn't exist?
        return;//Stop
    }
    if(!this.isAttachedTo(getLocalPlayerBlob())){//Not attached to the local player?
        return;//Stop
    }
    CControls@ controls = getControls();
    if(controls == @null){//Controls doesn't exist/
        return;//Stop
    }
    example_thing.Tick(controls);
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