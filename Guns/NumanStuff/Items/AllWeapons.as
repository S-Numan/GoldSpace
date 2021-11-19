#include "WeaponCommon.as";

//TODO, make blob that is using the weapon a parameter in here. maybe ...
void onDebugUse(array<Modif32@>@ f32_array, array<Modibool@>@ bool_array, array<DefaultModifier@>@ all_modifiers)
{
    print("\n\nthis has been used");
    print("f32_array.size() == " + f32_array.size());
    print("bool_array.size() == " + bool_array.size());
    print("all_modifiers.size() == " + all_modifiers.size());
    //example_thing.DebugModiVars(true);
    //example_thing.DebugVars();
}

void onDebugShot(f32 shot_angle, array<Modif32@>@ f32_array, array<Modibool@>@ bool_array, array<DefaultModifier@>@ all_modifiers)
{
    print("\n\nthis has been shot");
    print("f32_array.size() == " + f32_array.size());
    print("bool_array.size() == " + bool_array.size());
    print("all_modifiers.size() == " + all_modifiers.size());
    //example_thing.DebugModiVars(true);
    //example_thing.DebugVars();
}

it::itemaim@ TestWeapon(u8 &out equip_slot)
{
    equip_slot = 0;//0 is primary, 1 is secondary, 2 is whatever.
    

    print("created TestItem");   

    it::itemaim@ example_thing = @it::itemaim();
    example_thing.Init();
    
    example_thing.addUseListener(@onDebugUse);

    example_thing.addShotListener(@onDebugShot);

    example_thing.max_ammo[BaseValue] = 17;
    example_thing.setAmmoLeft(example_thing.max_ammo[CurrentValue]);

    example_thing.shots_per_use[BaseValue] = 5;//3 Shots per use

    example_thing.shot_afterdelay[BaseValue] = 15;//Half a second per shot

    example_thing.using_mode[BaseValue] = 1;//Full auto!
    //example_thing.using_mode[BaseValue] = 2;//use on release

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

    return @example_thing;
}