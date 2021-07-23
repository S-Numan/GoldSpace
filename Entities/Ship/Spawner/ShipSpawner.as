
void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
    if(shape != @null)
    {
        shape.SetStatic(true);
    }

    CMap@ map = getMap();

    if(map != @null)
    {
        map.AddMarker(this.getPosition(), "blue main spawn");
    }
    
}

void onTick( CBlob@ this )
{

}


void onDie( CBlob@ this )
{
    array<Vec2f> marker_poses;
    CMap@ map = getMap();

    if(map != @null)
    {
        if(map.getMarkers("blue main spawn", marker_poses))
        {
            for(u16 i = 0; i < marker_poses.size(); i++)
            {
                if(marker_poses[i] == this.getPosition())
                {
                    map.RemoveMarker("blue main spawn", i);   
                    break;
                }
            }
        }
    }

}