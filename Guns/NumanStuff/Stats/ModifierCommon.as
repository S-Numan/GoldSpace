#include "NuLib.as";
#include "ModiVars.as";

enum ModifierTypes
{
    Passive = 1,
    Active,
    PassiveAndActive
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

u16 getModiVarPos(array<IModiF32@>@ modi_array, int name_hash)
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

shared interface IModifier
{
    void Init(array<IModiF32@>@ _modi_array);
    string getName();
    int getNameHash();
    void setName(string _name);
    u8 getModifierType();
    u16 getInitialModifier();
    void addModifier(string _name, f32 _by_what, u8 _how);
    void ActiveTick(bool in_use = true);
    void PassiveTick();
    void AntiPassiveTick();
    void ModiHowPassiveTick(bool invert_values = false);
}

class DefaultModifier : IModifier
{    
    void Init(array<IModiF32@>@ _modi_array)
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


    array<IModiF32@>@ modi_array;

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

    void ActiveTick(bool in_use = true)//Called every tick
    {
        //TODO . addModifier that has conditions. Such as "do x when x value is ...". 
        //On second thought, that might be too annoying to implement. Just somehow streamline turning a addModifier on and off.
        //Maybe remove PassiveTick(), and simply modify variables yourself when they're added? No ticking it on. It gets on when you create it. Only thing you have to do it tick it off. I.E AntiPassiveTick(); Maybe rename that to onRemove().
        
        //Maybe store a bool for each setting value to confirm if it was set? then once the condition is false, remove it and set the bool to false? Once condition is true, set bool to true and apply.
        //^ Hyjacking will work. Make an "active" array. Use how as the bool. 0 is false, 1 is true. Eh, good enough.
        //Maybe alter ModiVars.as to somehow store an id for where each modification was done to it? (too bulky. would rather not)

        
        //For example, when MagLeft is equal to or less than 1, increase damage by 50%.
        //It would be preferable to have the damage increase dependent on the mag size. So weapons with only two rounds don't get much of a boost.
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
            else if(modify_how[i].how == MultMult)
            {
                if(invert_values){ Nu::Error("Attempted MultMult with invert_values true. That isn't how MultMult works."); return; }//Stop if somehow got here with inverting values
                    modify_how[i].how = modi_array[modi_pos].addMultMult(modify_how[i].by_what);//Add it, and store the id.
            }
            else
            {
                if(!modi_array[modi_pos].removeMultMult(modify_how[i].how))
                {
                    Nu::Error("Failed to remove MultMult, either the id somehow was wrong or this was a completely different non supported command. modify_how = " + modify_how[i].how + " with name " + modify_how[i].name); return;
                }
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