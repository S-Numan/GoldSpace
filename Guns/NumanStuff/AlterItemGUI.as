#include "WeaponCommon.as";
#include "NuMenuCommon.as";
#include "Modivars.as";

namespace AlterItem
{
    //array<NuMenu::MenuSlider@> sliders;
    array<Modif32@>@ f32_array;

    
    void CreateAlterMenu(array<Modif32@>@ _f32_array)
    {
        NuHub@ hub;
        if(!getHub(@hub)) { return; }

        hub.removeMenuFromList("AlterItem");
        
        
        if(_f32_array == @null) { Nu::Error("f32_array was null"); return; }
        @f32_array = @_f32_array;

        //sliders = array<NuMenu::MenuSlider@>(f32_size);


        print("AlterItem Creation");

        Vec2f size = Vec2f(400, 400);

        Vec2f pos = Vec2f(getScreenWidth() - size.x, 0);

        NuMenu::GridMenu@ grid_menu = NuMenu::GridMenu(//This menu is a GridMenu. The GridMenu inherits from BaseMenu, and is designed to hold other menus in an array in a grid fashion.
            "AlterItem");//Name of the menu which you can get later.

        grid_menu.setPos(pos);
        grid_menu.setSize(size);
        //grid_menu.setUpperLeft(Vec2f(0,0));
        //grid_menu.setLowerRight(Vec2f(0,0));
        

        grid_menu.clearBackgrounds();

        Nu::NuStateImage@ grid_image = Nu::NuStateImage(Nu::POSPositionsCount);//Here we create a state image with POSPositionCount states (for color and frames and stuff) 

        grid_image.CreateImage("grid_menu_image", "RenderExample.png");//Creates an image from a png

        grid_image.setFrameSize(Vec2f(32, 32));//Here we set the frame size of the image.

        grid_image.setDefaultFrame(2);
        

        grid_menu.addBackground(grid_image);//And here we add the grid_image as the background. The background image streches to meet the upper left and lower right.


        //How would you assign a grid of buttons to the menu?

        grid_menu.top_left_buffer = Vec2f(8.0f, 8.0f);//This allows you to change the distance of all the buttons from the top left of the menu

        grid_menu.setBuffer(Vec2f(32.0f, 32.0f));//This sets the buffer between buttons on the menu

        //for(u16 x = 0; x < 1; x++)//Grid width
        //{
        for(u16 y = 0; y < f32_array.size(); y++)//Grid height
        {            
            NuMenu::MenuSlider@ slider_menu = @NuMenu::MenuSlider("" + y);

            slider_menu.setSize(Vec2f(grid_menu.getSize().x - grid_menu.top_left_buffer.x * 2, 30));

            //slider_menu.setPos(Vec2f(300, 200));

            slider_menu.setIncrementValue(20.0f);

            slider_menu.setMaxValue(100.0f);

            slider_menu.setMinValue(0.0f);


            slider_menu.addSliderMovedListener(@SliderChangeFunction);

            slider_menu.setCurrentValue(f32_array[y][CurrentValue]);

            SliderChangeFunction(@slider_menu, slider_menu.getCurrentValue());

            grid_menu.setMenu(0,//Set the position on the width of the grid
                y,//The position on the height of the grid
                @slider_menu);//And add the button

            //sliders[y] = @slider_menu;
        }
        //}



        hub.addMenuToList(@grid_menu);
    }


    void SliderChangeFunction(NuMenu::IMenu@ menu, f32 current_value)
    {
        string menu_id = menu.getName()[0];
        int id = parseInt(menu_id);

        print("id = " + id + " current_value = " + current_value + " name = " + f32_array[id].getName());
    
        //f32_array[id][BaseValue] = current_value;
    }
}