#include "NuLib.as";
#include "ModiVars.as";

enum ModifierTypes
{
    Passive = 1,
    Active,
    PassiveAndActive
}

u16 getModiVarPos(array<IModiVar@>@ modi_array, int name_hash)
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

class DefaultModifier
{    
    void Init()
    {
        modify_how = array<ModiHow@>();
        
    }
    string icon;

    private u8 modifier_type;
    u8 getModifierType()
    {
        return modifier_type;
    }

    array<ModiHow@> modify_how;

    void addModifier(string _name, f32 _by_what, u8 _how)
    {
        modify_how.push_back(@ModiHow(_name, _by_what, _how));
    }

    void ActiveTick(array<IModiVar@>@ modi_array)
    {
        
    }

    void PassiveTick(array<IModiVar@>@ modi_array)
    {
        for(u16 i = 0; i < modify_how.size(); i++)//For each position in the modify_how array
        {
            u16 modi_pos = getModiVarPos(modi_array, modify_how[i].name_hash);//Find the var this modify_how relates to
            if(modi_pos == Nu::u16_max()) { Nu::Error("modify_how[i] did not relate to anything in the modi_pos array."); continue; }

            f32 base_value = modi_array[modi_pos].getValue(true);//Get the base value.

            if(modify_how[i].how == Set)
            {
                modi_array[modi_pos].setValue(modify_how[i].by_what, false);//Set the current value to the modify_how.
            }
            else if(modify_how[i].how == Add)
            {
                modi_array[modi_pos].setValue(base_value + modify_how[i].by_what, false);//Set the current value to the base_value + modify_how.
            }
            else if(modify_how[i].how == Sub)
            {
                modi_array[modi_pos].setValue(base_value - modify_how[i].by_what, false);//Set the current value to the base_value - modify_how.
            }
            else if(modify_how[i].how == Mult)
            {
                modi_array[modi_pos].setValue(base_value * modify_how[i].by_what, false);//Set the current value to the base_value * modify_how.
            }
            else if(modify_how[i].how == AddMult)
            {
                modi_array[modi_pos].addMult(modify_how[i].by_what);
            }
            else if(modify_how[i].how == SubMult)
            {
                modi_array[modi_pos].subMult(modify_how[i].by_what);
            }
            else
            {
                Nu::Error("Problemo. Too lazy to type out why.");
            }
        }
    }
}





class ExampleModifier : DefaultModifier
{
    ExampleModifier()
    {
        Init();
        modifier_type = PassiveAndActive;

        addModifier("morium_cost", 1.0f, Add);//Add 1 to the cost
        addModifier("morium_cost", 1.0f, AddMult);//Add 1.0f to what the end result will be multiplied by.

    }

    void ActiveTick(array<IModiVar@>@ modi_array) override
    {
        ActiveTick(@modi_array);
    
        //Do whatever logic you want to the array here.

        u16 modi_pos = getModiVarPos(modi_array, "morium_cost".getHash());
        
        Random@ rnd = Random(getGameTime());//Random with seed
        float random_number = (rnd.Next() + rnd.NextFloat()) % 2;//Random number between 0 and 2 (float)

        modi_array[modi_pos].subMult(random_number);//Subtract the multiplier by this number
    }
    void PassiveTick(array<IModiVar@>@ modi_array) override
    {
        PassiveTick(@modi_array);
    
        //Do whatever logic you want to the array here.

    }

}

class ExampleModifier2 : DefaultModifier
{
    ExampleModifier2()
    {
        Init();
        modifier_type = Passive;

        addModifier("morium_cost", 1.0f, Add);
    }

    //Nothing more is required.
}