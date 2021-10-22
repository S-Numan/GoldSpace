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
    BeforeSet,//Set the value before the multiplier takes effect
    BeforeAdd,//Add to the value before the multiplier takes effect
    AfterSet,//Set the value after the multiplier takes effect
    AfterAdd,//Add to the value after the multiplier takes effect
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

class ModiBase
{
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
    void setBaseValueChangedFunc(BASE_VALUE_CHANGED@ _func)
    {
        @base_value_changed_func = @_func;//Function called when the base value changes
    }
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

    f32 getValue(bool get_base = false)
    {
        if(get_base)//If get_base is true, this will return the base value instead of the current value
        {
            return value[1];
        }
        else//get_base is not true, return the (current value + before add) multiplied by the multiplier value, then the add value afterwards.
        {
            return (value[0] + value[2]) * value[3] + value[4];
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
        return value[3];
    }
    void setMult(f32 _value)
    {
        value[3] = _value;
    }
    void addMult(f32 _value)
    {
        setMult(getMult() + _value);
    }
    void subMult(f32 _value)
    {
        setMult(getMult() - _value);
    }
    /*void multMult(f32 _value)
    {
        setMult(getMult() * _value);
    }*/
    
    f32 getBeforeAdd()
    {
        return value[2];
    }
    void setBeforeAdd(f32 _value)
    {
        value[2] = _value;
    }
    void addBeforeAdd(f32 _value)
    {
        setBeforeAdd(getBeforeAdd() + _value);
    }
    void subBeforeAdd(f32 _value)
    {
        setBeforeAdd(getBeforeAdd() - _value);
    }
    
    f32 getAfterAdd()
    {
        return value[4];
    }
    void setAfterAdd(f32 _value)
    {
        value[4] = _value;
    }
    void addAfterAdd(f32 _value)
    {
        setAfterAdd(getAfterAdd() + _value);
    }
    void subBeforeAdd(f32 _value)
    {
        setAfterAdd(getAfterAdd() - _value);
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