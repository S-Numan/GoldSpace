//Variables that can be changed like rpg values with items. Such as an rpg value "strength" that can have an item add 3 to it then %10 to the entire stat.
#include "NuLib.as"

/*interface IModiVar
{
    string getName();

    void setName(string _value);
 
    int getNameHash();


    f32 getValue(bool get_base = false);

    void setValue(f32 _value, bool set_base = true);


    f32 getMult();

    void setMult(f32 _value);

    void addMult(f32 _value);

    void subMult(f32 _value);

    void multMult(f32 _value);
}*/



enum HowToModify
{
    BeforeAdd = 2,//Add to the value before the multiplier takes effect
    AfterAdd = 4,//Add to the value after the multiplier takes effect
    AddMult = 3,//Multiply the value along with other ModiHow's.
}
//These two enums work together just fine.
enum WhatValue
{
    CurrentValue = 0,
    BaseValue = 1,
    BeforeAddValue = 2,
    MultiplierValue = 3,
    MultValue = 3,
    AfterAddValue = 4,
    MaxValue = 5,
    MinValue = 6,
    ValueCount
}

//parameter 1 is name_hash
funcdef void BASE_VALUE_CHANGED(int);

class ModiBase
{
    private string name;
    string getName()
    {
        return name;
    }
    //protected          - why kag, not letting me set this to protected
    void setName(string _value)
    {
        if(_value.size() == 0) { Nu::Error("string was empty"); }
        name = _value;
        name_hash = name.getHash();
    }

    private int name_hash;
    int getNameHash()
    {
        return name_hash;
    }

    private BASE_VALUE_CHANGED@ base_value_changed_func;
    void setBaseValueChangedFunc(BASE_VALUE_CHANGED@ _func)
    {
        @base_value_changed_func = @_func;//Function called when the base value changes
    }
}

class Modif32 : ModiBase
{
    Modif32(string _name)
    {
        setName(_name);
        value = array<f32>(ValueCount);
    }
    Modif32(string _name, f32 default_value)
    {
        setName(_name);//Name for this variable


        //Initialization of the variable
        value = array<f32>(ValueCount);
        
        value[BaseValue] = default_value;//base value.
        
        value[CurrentValue] = value[BaseValue];//current value.

        value[MultValue] = 1.0f;//multiplier value; applied to current value when grabbing the value. For active modifiers

        value[BeforeAdd] = 0.0f;//before add value; applied before the multipler value when grabbing the current value

        value[AfterAdd] = 0.0f;//after add value; applied after the multiplier value when grabbing the current value.

        value[MinValue] = Nu::s32_min();//Min value that CurrentValue can be

        value[MaxValue] = Nu::s32_max();//Max value that CurrentValue can be
    }

    private f32[] value;

    f32 getValue()//Return the current value
    {
        //return the (base value + before add) multiplied by the multiplier value, then the after add value afterwards. Then clamp between min and max values
        //Don't do this unless any of the values changed for optimization purposes. TODO numan
        return Maths::Clamp((value[BaseValue] + value[BeforeAdd]) * value[MultValue] + value[AfterAdd], value[MinValue], value[MaxValue]);
    }//If it makes it easier, think of the current value as a temp value, and the base value as the default value.

    void setValue(f32 _value)//Sets the base value only. The current value should only be changed by modifiers. For example, a laserpointer is a modifier that applies itself to accuracy, raising it.
    {
        value[BaseValue] = _value;
        
        if(@base_value_changed_func != @null)
        {
            base_value_changed_func(name_hash);
        }
    }


    f32 get_opIndex(int idx) const
    {
        if(idx == CurrentValue)//If the index is the current value
        {
            return getValue();//Get the current value
        }
        //Otherwise
        return value[idx];//Return the desired value
    }
    void set_opIndex(int idx, f32 _value) 
    {
        if(idx == CurrentValue)//If the index is the current value
        {
            Nu::Warning("Cannot alter current value");
            return;
        }
        if(idx == BaseValue)//If the index is the base value
        {
            setValue(_value);
            return;
        }
        if(idx > BaseValue)//Index is something else
        {
            Nu::Warning("Cannot simply set the multiplier values or add values");
            return;
        }
        
    }


    bool Serialize(CBitStream@ bs)
    {
        /*for(u16 i = 1; i < value.size(); i++)//For everything that modifies value, skipping current value.
        {
            bs.write_f32(value[i]);
        }*/
        bs.write_f32(value[BaseValue]);//Things that apply modifiers to this should be serialized sepeartely.

        return true;
    }
    bool Deserialize(CBitStream@ bs)
    {
        /*for(u16 i = 1; i < value.size(); i++)//For everything that modifies value, skipping current value.
        {
            if(!bs.saferead_f32(value[i]))
            {
                Nu::Error("Failure to read value. Name = " + getName()); return false;
            }
        }*/
        f32 base_val;//Kag doesn't like putting the array directly into the saferead, it corrupts, so this needs to grab the value to put it into the array.
        if(!bs.saferead_f32(base_val))
        {
            Nu::Error("Failure to read value. Name = " + getName()); return false;
        }
        value[BaseValue] = base_val;

        return true;
    }
}


class Modibool : ModiBase
{
    Modibool(string _name)
    {
        setName(_name);//Name for this variable


        //Initialization of the variable
        value = array<bool>(2);
    }
    Modibool(string _name, bool default_value)
    {
        setName(_name);//Name for this variable


        //Initialization of the variable
        value = array<bool>(2);
        
        value[BaseValue] = default_value;

        value[CurrentValue] = value[BaseValue];
    }

    private bool[] value;

    bool getValue(bool get_base = false)
    {
        if(get_base)
        {
            return value[BaseValue];
        }
        else
        {
            //return value[CurrentValue];
            return value[BaseValue];
        }
    }

    void setValue(bool _value, bool set_base = true)
    {
        if(set_base)
        {
            value[BaseValue] = _value;
            
            if(@base_value_changed_func != @null)
            {
                base_value_changed_func(name_hash);
            }
        }
        else
        {
            value[CurrentValue] = _value;
        }
    }



    bool get_opIndex(int idx) const
    {
        if(idx == CurrentValue)//If the index is the current value
        {
            return getValue();//Get the current value
        }
        //Otherwise
        return value[idx];//Return the desired value
    }
    void set_opIndex(int idx, bool _value) 
    {
        if(idx == CurrentValue)//If the index is the current value
        {
            setValue(_value, false);
            return;
        }
        if(idx == BaseValue)//If the index is the base value
        {
            setValue(_value);
            return;
        }
        if(idx > BaseValue)//Index is something else
        {
            Nu::Warning("Modibool does not have multiplier values or add values");
            return;
        }
        
    }



    bool Serialize(CBitStream@ bs)
    {
        for(u16 i = 0; i < value.size(); i++)
        {
            bs.write_bool(value[i]);
        }

        return true;
    }
    bool Deserialize(CBitStream@ bs)
    {
        for(u16 i = 0; i < value.size(); i++)
        {
            if(!bs.saferead_bool(value[i]))
            {
                Nu::Error("Failure to read value. Name = " + getName()); return false;
            }
        }

        return true;
    }
}