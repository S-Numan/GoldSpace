#include "GenericButtonCommon.as";
#include "NuLib.as";

void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
    if(shape != @null)
    {
        shape.SetStatic(true);
    }
}

void onTick( CBlob@ this )
{

}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    if (!canSeeButtons(this, caller,
    false,//Team only
    16.0f))//Max distance
    {
        return;
    }

    CBitStream params;
	params.write_u16(caller.getNetworkID());

	//Sets up things easily.
    NuMenu::MenuButton@ button = CreateButton(this);

    setText(button, getTranslatedString("Select Maps"));//The text on the button.

    //Icon
    addIcon(button,//Button.
        "GUI/InteractionIcons.png",//Image name
        Vec2f(32, 32),//Icon frame size
        13,//Default frame
        20,//Hover frame 
        20//Pressing frame
    );
    
    button.addReleaseListener(@ButtonFunction);

    addButton(caller, button);
}

void ButtonFunction(CPlayer@ caller, CBitStream@ params, NuMenu::IMenu@ menu, u16 key_code)
{
    CRules@ rules = getRules();
    
    print("button pressed mhm");
    
    //Display map picking menu
    //Does the captain decide? Or do the crew vote.
    //For the moment show a menu that allows you to select several maps. Upon selecting a map, move everyone to the pod area or something. Once everyone is in the pod area, or the captain has been there for 20 seconds. Next map.

    
    rules.set_f32("gravity_mult", 1.0f);
    rules.set_u8("map_type", 1);//0 for space. 1 for underground

    LoadMap("GroundMap1.png");
}