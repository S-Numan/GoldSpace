#include "NuLib.as"

funcdef void BASE_VALUE_CHANGED();

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
    Set,//Set the value
    Add,//Add to the value
    Sub,//Subtract the value
    Mult,//Multiply the value
    AddMult,//Multiply the value along with other ModiHow's.
    SubMult//AddMult but subtraction
}

class ModiHow//For modifying ModiVars
{
    ModiHow(string _name, f32 _by_what, u8 _how)
    {
        name_hash = _name.getHash();
        by_what = _by_what;
        how = _how;
    }
    int name_hash;//Name of ModiVar to modify
    f32 by_what;
    u8 how;
}

class Modif32
{
    Modif32(BASE_VALUE_CHANGED@ _func, string _name, f32 default_value = 0.0f)
    {
        @base_value_changed_func = @_func;//Function when the base value changes


        setName(_name);//Name for this variable


        //Initialization of the variable
        value = array<f32>(3);
        
        value[1] = default_value;//[1] = base value.
        
        value[0] = value[1];//[0] = current value.

        value[2] = 1.0f;//[2] = multiplier value; applied to current value when grabbing the value. For active modifiers
    }

    private string name;
    string getName()
    {
        return name;
    }
    private void setName(string _value)
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

    private f32[] value;

    f32 getValue(bool get_base = false)
    {
        if(get_base)//If get_base is true, this will return the base value instead of the current value
        {
            return value[1];
        }
        else//get_base is not true, return the current value * the modifier multiplier. 
        {
            return value[0] * value[2];
        }
    }//If it makes it easier, think of the current value as a temp value, and the base value as the default value.

    void setValue(f32 _value, bool set_base = true)//Sets the base value only. The current value should only be changed by modifiers. For example, a laserpointer is a modifier that applies itself to accuracy, raising it.
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
    
    f32 getMult()
    {
        return value[2];
    }
    void setMult(f32 _value)
    {
        value[2] = _value;
    }
    void addMult(f32 _value)
    {
        setMult(value[2] + _value);
    }
    void subMult(f32 _value)
    {
        addMult(_value);
    }
    void multMult(f32 _value)
    {
        setMult(value[2] * _value);
    }
}


class Modibool
{
    Modibool(BASE_VALUE_CHANGED@ _func, string _name, bool default_value = false)
    {
        @base_value_changed_func = @_func;//Function when the base value changes


        setName(_name);//Name for this variable


        //Initialization of the variable
        value = array<bool>(2);
        
        value[1] = default_value;
    }

    private string name;
    string getName()
    {
        return name;
    }
    private void setName(string _value)
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