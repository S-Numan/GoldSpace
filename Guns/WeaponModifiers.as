#include "NuLib.as";
#include "ModiVars.as";

enum ModifierTypes
{
    Passive = 1,
    Active,
    PassiveAndActive
}

u16 getModiVarPos(array<ModiBase@>@ modi_array, int name_hash)
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
    
        icon = "";
        name = "";
        name_hash = 0;
        modifier_type = Passive;
    }
    string icon;
    string name;
    int name_hash;

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

    array<ModiHow@> modify_how;

    void addModifier(string _name, f32 _by_what, u8 _how)
    {
        modify_how.push_back(@ModiHow(_name, _by_what, _how));
    }

    void ActiveTick(array<ModiBase@>@ modi_array)//Called every tick
    {
        
    }

    void PassiveTick(array<ModiBase@>@ modi_array)//Called onInit
    {
        ModiHowPassiveTick(modi_array);
    }

    void AntiPassiveTick(array<ModiBase@>@ modi_array)//Called on removal
    {
        ModiHowPassiveTick(modi_array, true);//Invert values
    }

    void ModiHowPassiveTick(array<ModiBase@>@ modi_array, bool invert_values = false)
    {
        for(u16 i = 0; i < modify_how.size(); i++)//For each position in the modify_how array
        {
            u16 modi_pos = getModiVarPos(modi_array, modify_how[i].name_hash);//Find the var this modify_how relates to
            if(modi_pos == Nu::u16_max()) { Nu::Error("modify_how[i] did not relate to anything in the modi_pos array. modify_how name = " + modify_how[i].name); continue; }

            f32 base_value = modi_array[modi_pos].getValue(true);//Get the base value.

            s8 _invert = 1;
            if(invert_values)
            {
                _invert = -1;
            }

            /*if(modify_how[i].how == Set)
            {
                modi_array[modi_pos].setValue(modify_how[i].by_what * _invert, false);//Set the current value to the modify_how.
            }*/
            if(modify_how[i].how == BeforeAdd)
            {
                modi_array[modi_pos].addBeforeAdd(modify_how[i].by_what * _invert);
            }
            else if(modify_how[i].how == BeforeSub)
            {
                modi_array[modi_pos].subBeforeAdd(modify_how[i].by_what * _invert);
            }
            else if(modify_how[i].how == AfterAdd)
            {
                modi_array[modi_pos].addAfterAdd(modify_how[i].by_what * _invert);
            }
            else if(modify_how[i].how == AfterSub)
            {
                modi_array[modi_pos].subAfterAdd(modify_how[i].by_what * _invert);
            }
            /*else if(modify_how[i].how == Mult)
            {

            }*/
            else if(modify_how[i].how == AddMult)
            {
                modi_array[modi_pos].addMult(modify_how[i].by_what * _invert);
            }
            else if(modify_how[i].how == SubMult)
            {
                modi_array[modi_pos].subMult(modify_how[i].by_what * _invert);
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
        
        setName("example");

        addModifier("morium_cost", 1.0f, AfterAdd);//Add 1 to the cost
        addModifier("morium_cost", 1.0f, AddMult);//Add 1.0f to what the end result will be multiplied by.

    }

    void ActiveTick(array<ModiBase@>@ modi_array) override
    {
        DefaultModifier::ActiveTick(@modi_array);
    
        //Do whatever logic you want to the array here.

        u16 modi_pos = getModiVarPos(modi_array, "morium_cost".getHash());
        
        Random@ rnd = Random(getGameTime());//Random with seed
        float random_number = (rnd.Next() + rnd.NextFloat()) % 2;//Random number between 0 and 2 (float)

        modi_array[modi_pos].subMult(random_number);//Subtract the multiplier by this number
    }
    void PassiveTick(array<ModiBase@>@ modi_array) override //Called on creation
    {
        DefaultModifier::PassiveTick(@modi_array);
    
        //Do whatever logic you want to the array here.

    }

    void AntiPassiveTick(array<ModiBase@>@ modi_array) override //Called on removal
    {
        DefaultModifier::AntiPassiveTick(@modi_array);
    
        //Do whatever logic you want to the array here.
    }

}

class ExampleModifier2 : DefaultModifier
{
    ExampleModifier2()
    {
        Init();
        modifier_type = Passive;

        setName("example2");

        addModifier("morium_cost", 1.0f, AfterAdd);
    }

    //Nothing more is required.
}