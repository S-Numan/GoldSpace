#include "WeaponCommon.as";

it::activatable@ example_thing;

void onInit( CBlob@ this )
{
    print("created TestItem");   
    CShape@ shape = this.getShape();
    @example_thing = @it::activatable();
    example_thing.Init();

    example_thing.addUseListener(@onUse);
    
    example_thing.max_ammo[BaseValue] = 17;
    example_thing.setAmmoLeft(example_thing.max_ammo[CurrentValue]);
    
    example_thing.using_mode[BaseValue] = 1;//Full auto!
    //example_thing.using_mode[BaseValue] = 2;//use on release

    example_thing.use_sfx = "AssaultFire.ogg";

    example_thing.empty_total_sfx = "BulletImpact.ogg";

    example_thing.use_afterdelay[BaseValue] = 4;







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
    example_thing.Tick(@controls);
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