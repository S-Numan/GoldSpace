#include "NuLib.as";
#include "ModiVars.as";

enum ModifierTypes
{
    Passive = 1,
    Active,
    PassiveAndActive
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

class DefaultModifier
{    
    void Init(array<Modif32@>@ _modi_array)
    {
        @modi_array = @_modi_array;
        
        modify_how = array<ModiHow@>();
    
        icon = "";
        name = "";
        name_hash = 0;
        modifier_type = Passive;
    }
    string icon;
    string name;
    int name_hash;

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
        modifier_type = PassiveAndActive;
        
        setName("example");

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

        modi_array[modi_pos][AddMult] = modi_array[modi_pos][AddMult] - random_number;//Subtract the multiplier by this number
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

        setName("example2");

        addModifier("morium_cost", 1.0f, AfterAdd);
    }

    //Nothing more is required.
}