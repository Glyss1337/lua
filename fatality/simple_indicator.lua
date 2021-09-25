-- libraries

local menu      = fatality.menu;
local config    = fatality.config;
local callbacks = fatality.callbacks;
local render    = fatality.render;
local value     = fatality.value;

-- interfaces

local engine_client = csgo.interface_handler:get_engine_client( )
local entity_list   = csgo.interface_handler:get_entity_list( )
local global_vars   = csgo.interface_handler:get_global_vars( )

-- fonts

local font = render:create_font( "Tahoma", 14, 500, true )

-- colors

local active_color   = csgo.color( 25, 255, 65, 255 )
local disabled_color = csgo.color( 225, 25, 25, 255 )

-- menu references

local ref_hide_shot    = menu:get_reference( "Rage", "Aimbot", "Aimbot", "Hide shot" );
local ref_double_tap   = menu:get_reference( "Rage", "Aimbot", "Aimbot", "Double tap" );
local ref_force_sp 	   = menu:get_reference( "Rage", "Aimbot", "Aimbot", "Force safepoint" );
local ref_hs_only 	   = menu:get_reference( "Rage", "Aimbot", "Aimbot", "Headshot only" );
local ref_freestanding = menu:get_reference( "Rage", "Anti-aim", "General", "Freestand" );
-- [[manual aa]] --
local ref_aa_override  = menu:get_reference( "Rage", "Anti-aim", "General", "Antiaim override" );
local ref_aa_back 	   = menu:get_reference( "Rage", "Anti-aim", "General", "Back" );
local ref_aa_left 	   = menu:get_reference( "Rage", "Anti-aim", "General", "Left" );
local ref_aa_right 	   = menu:get_reference( "Rage", "Anti-aim", "General", "Right" );

local ref_fake_duck    = menu:get_reference( "Misc", "", "Movement", "Fake duck" );
local ref_peek_assist  = menu:get_reference( "Misc", "", "Movement", "Peek Assist" );

-- engine

local indicator_count_frame = 0 -- int
local screen_size = render:screen_size( ) -- vector2

local function render_indicator( element, name, flip_status, ignore_condition, render_default ) -- simple render function
	if ignore_condition then
		if ignore_condition:get_bool( ) then return end
	end
	
	local element_status = element:get_bool( ) -- check if element is active/disabled/doesn't exist
	if not render_default and not element_status then return end
	if flip_status and element_status then element_status = not element_status end
	local element_color = element_status and active_color or not element_status and disabled_color
	render:text( font, screen_size.x / 2 + 5, screen_size.y / 2 + ( 14 * indicator_count_frame ) + 5, name, element_color )
	indicator_count_frame = indicator_count_frame + 1
end

-- render

local function render( ) -- this is where the "magic" happens
	-- reset indicator count
	indicator_count_frame = 0
  -- render all the indicators
	render_indicator( ref_double_tap, "DT", ref_fake_duck:get_bool(), false, not ref_hide_shot:get_bool( ) )
	render_indicator( ref_hide_shot, "ST", ref_fake_duck:get_bool(), ref_double_tap, false )
	render_indicator( ref_fake_duck, "FD", false, false, false )
	render_indicator( ref_force_sp, "SP", false, false, true )
	render_indicator( ref_hs_only, "HS", false, false, false )
	if ref_aa_override:get_bool( ) then -- realized midway that my ignore condition is a bit stupid so i'll have to use this
	render_indicator( ref_aa_back, "BACK", false, false, false )
	render_indicator( ref_aa_left, "LEFT", false, false, false )
	render_indicator( ref_aa_right, "RIGHT", false, false, false )
	end
	render_indicator( ref_freestanding, "FS", false, false, true )
	render_indicator( ref_peek_assist, "PEEK", false, false, false )
end

-- init

local function paint_traverse( )
	if engine_client:is_connected( ) and entity_list:get_localplayer( ):is_alive( ) then
	render( )
	end
end

-- callbacks

callbacks:add( "paint", paint_traverse )
