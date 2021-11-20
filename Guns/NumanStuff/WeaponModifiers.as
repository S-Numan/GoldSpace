#include "NuLib.as";
#include "ModiVars.as";

enum ModifierTypes
{
    Passive = 1,
    Active,
    PassiveAndActive
}

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

class ModiHow//For modifying ModiVars
{
    ModiHow()
    {
        
    }
    ModiHow(string _name, f32 _by_what, u8 _how)
    {
        Init(_name, _name.getHash(), _by_what, _how);
    }
    ModiHow(int _name_hash, f32 _by_what, u8 _how)
    {
        Init("" + _name_hash, _name_hash, _by_what, _how);
    }
    private void Init(string _name, int _name_hash, f32 _by_what, u8 _how)
    {
        name = _name;
        name_hash = _name_hash;
        by_what = _by_what;
        how = _how;
    }
    bool Serialize(CBitStream@ bs)
    {
        bs.write_s32(name_hash);
        bs.write_u8(how);
        bs.write_f32(by_what);

        return true;
    }
    bool Deserialize(CBitStream@ bs)
    {
        if(!bs.saferead_s32(name_hash)) { Nu::Error("Failure to read value."); return false; }
        name = "" + name_hash;
        if(!bs.saferead_u8(how)) { Nu::Error("Failure to read value. Name = " + name); return false; }
        if(!bs.saferead_f32(by_what)) { Nu::Error("Failure to read value. Name = " + name); return false; }

        return true;
    }
    
    string name;//Maybe remove this for performance reasons later?
    int name_hash;//Name of ModiVar to modify
    f32 by_what;
    u8 how;
}

u16 getModiVarPos(array<Modif32@>@ modi_array, int name_hash)
{
    for(u16 i = 0; i < modi_array.size(); i++)
    {
        if(modi_array[i].getNameHash() == name_hash)
        {
            return i;
        }
    }
    
    return Nu::u16_max();
}

interface IModifier
{
    void Init(array<Modif32@>@ _modi_array);
    string getName();
    int getNameHash();
    void setName(string _name);
    u8 getModifierType();
    u16 getInitialModifier();
    void addModifier(string _name, f32 _by_what, u8 _how);
    void ActiveTick();
    void PassiveTick();
    void AntiPassiveTick();
    void ModiHowPassiveTick(bool invert_values = false);
}

class DefaultModifier : IModifier
{    
    void Init(array<Modif32@>@ _modi_array)
    {
        @modi_array = @_modi_array;

        initial_modifier = 0;
        
        modify_how = array<ModiHow@>();
    
        icon = "";
        name = "";
        name_hash = 0;
        modifier_type = Passive;
    }
    string icon;
    string name;
    int name_hash;
    string getName()
    {
        return name;
    }
    int getNameHash()
    {
        return name_hash;
    }


    array<Modif32@>@ modi_array;

    void setName(string _name)
    {
        name = _name;
        name_hash = _name.getHash();
    }


    private u8 modifier_type;
    u8 getModifierType()
    {
        return modifier_type;
    }


    private u16 initial_modifier;
    u16 getInitialModifier()
    {
        return initial_modifier;
    }
    

    array<ModiHow@> modify_how;

    void addModifier(string _name, f32 _by_what, u8 _how)
    {
        modify_how.push_back(@ModiHow(_name, _by_what, _how));
    }

    void ActiveTick()//Called every tick
    {
        
    }

    void PassiveTick()//Called onInit
    {
        ModiHowPassiveTick();
    }

    void AntiPassiveTick()//Called on removal
    {
        ModiHowPassiveTick(true);//Invert values
    }

    void ModiHowPassiveTick(bool invert_values = false)
    {
        for(u16 i = 0; i < modify_how.size(); i++)//For each position in the modify_how array
        {
            u16 modi_pos = getModiVarPos(modi_array, modify_how[i].name_hash);//Find the var this modify_how relates to
            if(modi_pos == Nu::u16_max()) { Nu::Error("modify_how[i] did not relate to anything in the modi_pos array. modify_how name = " + modify_how[i].name); continue; }

            //f32 base_value = modi_array[modi_pos][BaseValue];//Get the base value.

            s8 _invert = 1;//Create the value that multiplies the end result
            if(invert_values)//If the goal is to invert the end result
            {
                _invert = -1;//Commit.
            }

            if(modify_how[i].how == BeforeAdd)//If the goal is to add to the BeforeAdd.
            {
                modi_array[modi_pos][BeforeAdd] = modi_array[modi_pos][BeforeAdd] + modify_how[i].by_what * _invert;//Add to it
            }
            else if(modify_how[i].how == AddMult)//If the goal is to add to the AddMult
            {
                modi_array[modi_pos][AddMult] = modi_array[modi_pos][AddMult] + modify_how[i].by_what * _invert;//Add to it
            }
            else if(modify_how[i].how == AfterAdd)//If the goal is to add to the AfterAdd
            {
                modi_array[modi_pos][AfterAdd] = modi_array[modi_pos][AfterAdd] + modify_how[i].by_what * _invert;//Add to it
                //How does this work?
                //modi_array[modi_pos] <- This specific ModiVar in the array. (fancy f32 variable)
                //[AfterAdd] <- The "AfterAdd" within the ModiVar. (value that adds to the fancy f32 variable after the other two above (BeforeAdd & AddMult) have done so)
                //= modi_array[modi_pos][AfterAdd] <- See the two lines above
                //+ modify_how[i].by_what <- for this ModiHow in the array, add it's value to AfterAdd
                //* _invert; <- invert the adding value if desired, this is generally only done when removing the modifier
            }
            else if(modify_how[i].how == MinValue)
            {
                //modi_array[modi_pos][MinValue] = modify_how[i].by_what;//How is this supposed to be inverted?
            }
            else if(modify_how[i].how == MaxValue)
            {
                //modi_array[modi_pos][MaxValue] = modify_how[i].by_what;
            }
            else
            {
                Nu::Error("Problemo. Too lazy to type out why.");
            }
            /*if(modify_how[i].how == Set)
            {
                modi_array[modi_pos].setValue(modify_how[i].by_what * _invert, false);//Set the current value to the modify_how.
            }*/
            /*else if(modify_how[i].how == Mult)
            {

            }*/
        }
    }
}






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

    void ActiveTick() override
    {
        DefaultModifier::ActiveTick();
    
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

        setName("example2");

        addModifier("morium_cost", 1.0f, AfterAdd);
    }

    //Nothing more is required.
}

class SUPPRESSINGFIRE : DefaultModifier//SUPRESSING FIRE!: Much larger clip size, larger max ammo, longer reload time, cheaper ammo, less heat, more recoil.
{
    SUPPRESSINGFIRE(array<Modif32@>@ modi_array)
    {
        Init(@modi_array);

        modifier_type = Passive;

        initial_modifier = mod::SUPPRESSINGFIRE;

        addModifier("max_ammo", 1.0f, AddMult);//Double ammo
        addModifier("shot_afterdelay", -0.5f, AddMult);//Double firerate
        //Clip size
        //Reload time
        //addModifier("morium_cost", -0.5f, AddMult);//Morium cost for the entire weapon is always the same. It always costs the same amount no matter the max_ammo. More ammo means cheaper ammo in a way.
        //Heat
        addModifier("spread_gain_per_shot", 1.0f, AddMult);//Double spread
    }
}