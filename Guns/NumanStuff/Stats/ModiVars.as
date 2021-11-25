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

//I don't know what I'm doing.
int findFirstMissing(array<u16> int_array, int start, int end)//Array must be sorted from least to most
{
    if (start > end)//If the start value is greater than the end value. (no more to look through?)
    {
        return end + 1;//Should this + 1 exist?
    }
    
    //Is this if statement needed?
    if (start != int_array[start])//If the start position is not equal to this position in the array.
    {
        return start;//Found the free position.
    }
    int mid = (start + end) / 2;//Find middle position
    //int mid = start + (end - start) / 2;//alternative?

    //if the mid-index matches with its value, then the mismatch lies on the right half
    if (int_array[mid] == mid)
        return findFirstMissing(int_array, mid+1, end);
    //mismatch of left half
    return findFirstMissing(int_array, start, mid);//mid - 1?
}


enum HowToModify
{
    BeforeAdd = 2,//Add to the value before the multiplier takes effect
    AfterAdd = 4,//Add to the value after the multiplier takes effect
    AddMult = 3,//Additive multiplication to the value along with other ModiHow's.
    MultMult = ValueCount//Multiplicative.
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

/*class ModiBase
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
}*/

shared interface IModiF32
{
    string getName();
    void setName(string _value);
    int getNameHash();

    void setSyncBaseValue(bool value);
    void setBaseValueChangedFunc(BASE_VALUE_CHANGED@ _func);

    f32 get_opIndex(int idx);
    void set_opIndex(int idx, f32 _value);

    u16 addMultMult(f32 _value);
    bool removeMultMult(u16 _id);
    void ResizeMultMult(u16 _value);

    bool Serialize(CBitStream@ bs);
    bool Deserialize(CBitStream@ bs);
}

class Modif32 : IModiF32
{
    //Base
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

    void setSyncBaseValue(bool value)
    {
        sync_base_value = value;
    }
    bool sync_base_value;

    private BASE_VALUE_CHANGED@ base_value_changed_func;
    void setBaseValueChangedFunc(BASE_VALUE_CHANGED@ _func)
    {
        @base_value_changed_func = @_func;//Function called when the base value changes
    }
    //Base

    Modif32(string _name)
    {
        setName(_name);
        value = array<f32>(ValueCount);
    
        sync_base_value = true;
    }
    Modif32(string _name, f32 default_value)
    {
        setName(_name);//Name for this variable

        sync_base_value = true;
        
        //Initialization of the variable
        value = array<f32>(ValueCount);
        
        value[BaseValue] = default_value;//base value.
        
        value[CurrentValue] = value[BaseValue];//current value.

        value[MultValue] = 1.0f;//multiplier value; applied to current value when grabbing the value. For active modifiers

        value[BeforeAdd] = 0.0f;//before add value; applied before the multipler value when grabbing the current value

        value[AfterAdd] = 0.0f;//after add value; applied after the multiplier value when grabbing the current value.

        value[MinValue] = Nu::s32_min();//Min value that CurrentValue can be

        value[MaxValue] = Nu::s32_max();//Max value that CurrentValue can be
    

        multmultid = array<u16>();
        multmultvalue = array<f32>();
    }

    private f32[] value;

    private u16[] multmultid;//Matches up to each multmultvalue.
    private f32[] multmultvalue;//Multiplicative. Each in this array is applied one after another after MultValue.

    f32 getValue()//Return the current value
    {
        //Don't do this unless any of the values changed for optimization purposes. TODO numan
        
        f32 start_value = (value[BaseValue] + value[BeforeAdd]) * value[MultValue];//the (base value + before add) multiplied by the multiplier value.

        for(u16 i = 0; i < multmultvalue.size(); i++)//Then apply each multmult value.
        {
            start_value *= multmultvalue[i];
        }

        return Maths::Clamp(start_value + value[AfterAdd], value[MinValue], value[MaxValue]);//then the after add value afterwards. Then clamp between min and max values
    }//If it makes it easier, think of the current value as a temp value, and the base value as the default value.

    void setValue(f32 _value)//Sets the base value only. The current value should only be changed by modifiers. For example, a laserpointer is a modifier that applies itself to accuracy, raising it.
    {
        value[BaseValue] = _value;
        
        if(@base_value_changed_func != @null && sync_base_value)
        {
            base_value_changed_func(name_hash);
        }
    }


    f32 get_opIndex(int idx)
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
            //Nu::Warning("Cannot simply set the multiplier values or add values");
            value[idx] = _value;
            return;
        }
        
    }

    //returns an id that is uniquely for this added value.
    u16 addMultMult(f32 _value)//Multiplicative.
    {
        multmultvalue.push_back(_value);
        
        array<u16> sorted = multmultid;
        sorted.sortAsc();
        u16 _id = findFirstMissing(sorted, 0, sorted.size() - 1);
        multmultid.push_back(_id);

        return _id;
    }
    bool removeMultMult(u16 _id)
    {
        bool success = false;
        for(u16 i = 0; i < multmultid.size(); i++)
        {
            if(multmultid[i] == _id)
            {
                multmultvalue.removeAt(i);
                multmultid.removeAt(i);
                success = true;
            }
        }
        return success;
    }
    void ResizeMultMult(u16 _value)
    {
        multmultvalue.resize(_value);
        multmultid.resize(_value);
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

shared interface IModiBool
{
    string getName();
    void setName(string _value);
    int getNameHash();

    void setSyncBaseValue(bool value);
    void setBaseValueChangedFunc(BASE_VALUE_CHANGED@ _func);

    bool get_opIndex(int idx);
    void set_opIndex(int idx, bool _value);
    
    bool Serialize(CBitStream@ bs);
    bool Deserialize(CBitStream@ bs);
}

class Modibool : IModiBool
{
    //Base
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

    bool sync_base_value;
    void setSyncBaseValue(bool value)
    {
        sync_base_value = value;
    }

    private BASE_VALUE_CHANGED@ base_value_changed_func;
    void setBaseValueChangedFunc(BASE_VALUE_CHANGED@ _func)
    {
        @base_value_changed_func = @_func;//Function called when the base value changes
    }
    //Base
    
    Modibool(string _name)
    {
        setName(_name);//Name for this variable

        sync_base_value = true;

        //Initialization of the variable
        value = array<bool>(2);
    }
    Modibool(string _name, bool default_value)
    {
        setName(_name);//Name for this variable

        sync_base_value = true;
        
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
            
            if(@base_value_changed_func != @null && sync_base_value)
            {
                base_value_changed_func(name_hash);
            }
        }
        else
        {
            value[CurrentValue] = _value;
        }
    }



    bool get_opIndex(int idx)
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