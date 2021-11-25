#include "WeaponCommon.as";
#include "ModiVars.as";

/*it::IModiStore@ CreateModiStore(u8 class_type)
{
    if(class_type == it::ClassBaseModiStore)
    {
        return @it::basemodistore();
    }
    else if(class_type == it::ClassActivatable)
    {
        return @it::activatable();
    }
    else if(class_type == it::ClassItem)
    {
        return @it::item();
    }
    else if(class_type == it::ClassItemAim)
    {
        return @it::itemaim();
    }
    else if(class_type == it::ClassWeapon)
    {
        return @it::weapon();
    }

    return @null;
}*/

//TODO, make blob that is using the weapon a parameter in here. maybe ...
void onDebugUse(it::IModiStore@ item)
{
    print("\n\nthis has been used");
    print("f32_array.size() == " + item.getF32Array().size());
    print("bool_array.size() == " + item.getBoolArray().size());
    print("all_modifiers.size() == " + item.getAllModifiers().size());
    //item.DebugModiVars(true);
    item.DebugVars();
}

void onDebugShot(it::IModiStore@ item, f32 shot_angle)
{
    print("\n\nthis has been shot");
    print("f32_array.size() == " + item.getF32Array().size());
    print("bool_array.size() == " + item.getBoolArray().size());
    print("all_modifiers.size() == " + item.getAllModifiers().size());
    //item.DebugModiVars(true);
    item.DebugVars();
}



namespace wep
{
    enum CreatedWeapon
    {
        TestWeapon = 1,
        StandardPistol,

        WeaponCount
    }
}

it::IModiStore@ CreateItem(u16 created_item, CBlob@ owner, bool include_sfx = true, bool include_functions = true, bool include_modivars = true)
{
    it::IModiStore@ item = @null;

    if(created_item < wep::WeaponCount)
    {//Weapons
        switch (created_item)
        {
            case wep::TestWeapon:
                @item = @TestWeapon(created_item, @owner, include_sfx, include_functions, include_modivars);
                break;
            case wep::StandardPistol:
                @item = @StandardPistol(created_item, @owner, include_sfx, include_functions, include_modivars);
                break;
            default:
                Nu::Error("No found item with created_item " + created_item);
                break;
        }
    }
    else
    {//Items
        Nu::Error("No found item with created_item " + created_item);
    }

    
    array<IModiF32@>@ f32_array = @item.getF32Array();

    if(item.hasVF32(it::MagLeft)) { item.setVF32(it::MagLeft, f32_array[item.getModif32Point("mag_size")][CurrentValue], false); }//False means don't sync
    if(item.hasVF32(it::MaxAmmoLeft)) { item.setVF32(it::MaxAmmoLeft, f32_array[item.getModif32Point("max_ammo")][CurrentValue], false); }
    
    return @item;
}

it::weapon@ TestWeapon(u16 created_weapon, CBlob@ owner, bool include_sfx, bool include_functions, bool include_modivars)
{
    print("created TestItem");   

    it::weapon@ example_thing = @it::weapon();
    example_thing.Init(created_weapon);

    example_thing.setEquipSlot(0);//0 is primary, 1 is secondary, 2 is whatever.

    example_thing.setOwner(@owner);
    

    if(include_functions)
    {
        example_thing.addUseListener(@onDebugUse);

        example_thing.addShotListener(@onDebugShot);
    }

    if(include_sfx)
    {
        example_thing.use_sfx = "arrow_hit_ground.ogg";

        example_thing.shot_sfx = "AssaultFire.ogg";

        example_thing.empty_mag_sfx = "BulletImpact.ogg";

        example_thing.empty_mag_ongoing_sfx = "ShellDrop.ogg";

        example_thing.reload_sfx = "Reload.ogg";
    }

    if(include_modivars)
    {
        example_thing.setSyncModivars(false);
        
        example_thing.mag_size[BaseValue] = 17;
        
        example_thing.shots_per_use[BaseValue] = 5;//5 Shots per use

        example_thing.shot_afterdelay[BaseValue] = 15;//Half a second per shot

        example_thing.using_mode[BaseValue] = 1;//Full auto!
        //example_thing.using_mode[BaseValue] = 2;//use on release

        example_thing.use_with_queued_shots[BaseValue] = false;

        example_thing.use_afterdelay[BaseValue] = 4;

        example_thing.no_ammo_no_shots[BaseValue] = false;

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


        example_thing.projectiles_per_shot[BaseValue] = 3;

        example_thing.damage_on_overheat[BaseValue] = 0.1f;


        example_thing.max_ammo[BaseValue] = 7;


        example_thing.reload_time[BaseValue] = 15;

        //example_thing.auto_reload[BaseValue] = true;




        example_thing.setSyncModivars(true);
    }
    

    IModifier@ _modi = CreateModifier(mod::SUPPRESSINGFIRE, @example_thing.getF32Array());
    example_thing.addModifier(@_modi, false);//false means don't sync.


    example_thing.DebugModiVars(true);
    example_thing.DebugVars();

    return @example_thing;
}

it::weapon@ StandardPistol(u16 created_weapon, CBlob@ owner, bool include_sfx, bool include_functions, bool include_modivars)
{
    it::weapon@ weapon = @it::weapon();
    weapon.Init(created_weapon);

    weapon.setEquipSlot(0);

    weapon.setOwner(@owner);

    if(include_functions)
    {
        weapon.addUseListener(@onDebugUse);

        weapon.addShotListener(@onDebugShot);
    }

    if(include_sfx)
    {
        weapon.shot_sfx = "AssaultFire.ogg";

        weapon.empty_mag_sfx = "BulletImpact.ogg";

        weapon.empty_mag_ongoing_sfx = "ShellDrop.ogg";
    }

    if(include_modivars)
    {
        weapon.setSyncModivars(false);

        weapon.mag_size[BaseValue] = 17;
    
        weapon.setSyncModivars(true);
    }

    return @weapon;
}