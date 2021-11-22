#include "ModifierCommon.as";

namespace mod
{
    enum CreatedModifiers
    {
        ExampleModifier = 1,
        ExampleModifier2,
        SUPPRESSINGFIRE,

        ModifierCount
    }
}

IModifier@ CreateModifier(u16 created_modifier, array<Modif32@>@ modi_array)
{
    switch (created_modifier)
    {
        case mod::ExampleModifier:
            return @ExampleModifier(@modi_array);
        case mod::ExampleModifier2:
            return @ExampleModifier2(@modi_array);
        case mod::SUPPRESSINGFIRE:
            return @SUPPRESSINGFIRE(@modi_array);
        default:
            Nu::Error("No found modifier with created_modifier " + created_modifier);
            break;
    }

    return @null;
}
//In best practice, buffs are generally additive, debuffs are generally multiplicative.




class ExampleModifier : DefaultModifier
{
    ExampleModifier(array<Modif32@>@ modi_array)
    {
        Init(@modi_array);
        
        initial_modifier = mod::ExampleModifier;
        
        modifier_type = PassiveAndActive;

        addModifier("morium_cost", 1.0f, AfterAdd);//Add 1 to the cost
        addModifier("morium_cost", 1.0f, AddMult);//Add 1.0f to what the end result will be multiplied by.

    }

    void ActiveTick(bool in_use = true) override
    {
        DefaultModifier::ActiveTick(in_use);
    
        //Do whatever logic you want to the array here.

        u16 modi_pos = getModiVarPos(modi_array, "morium_cost".getHash());
        
        Random@ rnd = Random(getGameTime());//Random with seed
        float random_number = Nu::getRandomF32(0, 2);//Random number between 0 and 2 (float)

        //modi_array[modi_pos][AddMult] = modi_array[modi_pos][AddMult] - random_number;//Subtract the multiplier by this number
    }
    void PassiveTick() override //Called on creation
    {
        DefaultModifier::PassiveTick();
    
        //Do whatever logic you want to the array here.

    }

    void AntiPassiveTick() override //Called on removal
    {
        DefaultModifier::AntiPassiveTick();
    
        //Do whatever logic you want to the array here.
    }

}

class ExampleModifier2 : DefaultModifier
{
    ExampleModifier2(array<Modif32@>@ modi_array)
    {
        Init(@modi_array);

        modifier_type = Passive;

        initial_modifier = mod::ExampleModifier2;

        addModifier("morium_cost", 1.0f, AfterAdd);
    }

    //Nothing more is required.
}


class SUPPRESSINGFIRE : DefaultModifier//SUPRESSING FIRE!: Much larger clip size, larger max ammo, longer reload time, cheaper ammo, less heat, more recoil, less projectile damage.
{
    SUPPRESSINGFIRE(array<Modif32@>@ modi_array)
    {
        Init(@modi_array);

        modifier_type = Passive;

        initial_modifier = mod::SUPPRESSINGFIRE;

        addModifier("max_ammo", 0.3f, AddMult);//1.5 as much max ammo
        addModifier("mag_size", 1.0f, AddMult);//Doubled mag size
        addModifier("reload_time", 1.0f, AddMult);//Doubled reload time
        addModifier("spread_gain_per_shot", 1.0f, AddMult);//Double spread
        
        //addModifier("morium_cost", 0.8f, MultMult);//Morium cost for the entire weapon is always the same. It always costs the same amount no matter the max_ammo. More ammo means cheaper ammo in a way.
        addModifier("heat_gain_per_shot", 0.9f, MultMult);//Slightly less heat.
        addModifier("shot_afterdelay", 0.8f, MultMult);//somewhere around 1.2 the firerate
    }
}