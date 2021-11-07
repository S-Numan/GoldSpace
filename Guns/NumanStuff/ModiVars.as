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
    BeforeAdd,//Add to the value before the multiplier takes effect
    AfterAdd,//Add to the value after the multiplier takes effect
    AddMult,//Multiply the value along with other ModiHow's.
}

class ModiHow//For modifying ModiVars
{
    ModiHow(string _name, f32 _by_what, u8 _how)
    {
        name = _name;
        name_hash = _name.getHash();
        by_what = _by_what;
        how = _how;
    }
    string name;//Maybe remove this for performance reasons later?
    int name_hash;//Name of ModiVar to modify
    f32 by_what;
    u8 how;
}

funcdef void BASE_VALUE_CHANGED();

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

enum WhatValue
{
    CurrentValue = 0,
    BaseValue = 1,
    BeforeAddValue = 2,
    MultiplierValue = 3,
    AfterAddValue = 4,
    ValueCount
}

class Modif32 : ModiBase
{
    Modif32(string _name, f32 default_value = 0.0f)
    {
        setName(_name);//Name for this variable


        //Initialization of the variable
        value = array<f32>(5);
        
        value[1] = default_value;//[1] = base value.
        
        value[0] = value[1];//[0] = current value.

        value[3] = 1.0f;//[2] = multiplier value; applied to current value when grabbing the value. For active modifiers

        value[2] = 0.0f;//[3] = before add value; applied before the multipler value of [2] when grabbing the current value

        value[4] = 0.0f;//[4] = after add value; applied after the multiplier value of [2] when grabbing the current value.

    }

    private f32[] value;

    f32 getValue()//Return the current value
    {
        //return the (base value + before add) multiplied by the multiplier value, then the add value afterwards.
        return (value[1] + value[2]) * value[3] + value[4];//Don't do this unless any of the values changed for optimization purposes. TODO numan
    }//If it makes it easier, think of the current value as a temp value, and the base value as the default value.

    void setValue(f32 _value)//Sets the base value only. The current value should only be changed by modifiers. For example, a laserpointer is a modifier that applies itself to accuracy, raising it.
    {
        value[1] = _value;
        
        if(@base_value_changed_func != @null)
        {
            base_value_changed_func();
        }
    }


    f32 get_opIndex(int idx) const
    {
        if(idx == 0)//If the index is the current value
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

}


class Modibool : ModiBase
{
    Modibool(string _name, bool default_value = false)
    {
        setName(_name);//Name for this variable


        //Initialization of the variable
        value = array<bool>(2);
        
        value[1] = default_value;
    }

    private bool[] value;

    bool getValue(bool get_base = false)
    {
        if(get_base)
        {
            return value[1];
        }
        else
        {
            return value[0];
        }
    }

    void setValue(bool _value, bool set_base = true)
    {
        if(set_base)
        {
            value[1] = _value;
            
            if(@base_value_changed_func != @null)
            {
                base_value_changed_func();
            }
        }
        else
        {
            value[0] = _value;
        }
    }
    
}