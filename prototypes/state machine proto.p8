pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--###########################--
--#     global functions    #--
--###########################--


--global init function

function _init()
	--♥ variables
	heart_x, heart_y =60,5
	heart_dx,heart_dy=0.7,1
	
	--current state
	mode="menu"
end



--global update function

function _update60()
	--update ♥ pos independently
	update_heart()
	
	--go to:update "menu"
	if mode=="menu" then
		update_menu()
	
	--go to:update "game"
	elseif mode=="game" then
		update_game()
	 
	--go to:update "end"
	elseif mode=="end" then
		update_end()
	end
end



--global draw function

function _draw()

	--go to:draw "menu"
	if mode=="menu" then
		draw_menu()
	
	--go to:draw "game"
	elseif mode=="game" then
		draw_game()
	
	--go to:draw "end"
	elseif mode=="end" then
		draw_end()
	end
	
	--draw ♥ independently
	draw_heart()
end



--###########################--
--#      state functions    #--
--###########################--


--"menu" state functions

function update_menu()
	if btnp(🅾️) then
		mode = "game"
	end
end


function draw_menu()
	cls(1)
	print("press 🅾️ to start",
	30,60,13)
end



--"game" state functions

function update_game()
	if btnp(🅾️) then
		mode = "end"
	end
end


function draw_game()
	cls(2)
	print("press 🅾️ to finish",
	28,60,14)
end



--"end" state functions

function update_end()
	if btnp(🅾️) then
		mode = "menu"
	end
end


function draw_end()
	cls(3)
	print("press 🅾️ to restart",
	29,60,15)
end



--###########################--
--#        functions        #--
--###########################--


--update heart

function update_heart()
	
	--mouvement
	heart_x+=heart_dx
	heart_y+=heart_dy
	
	-- boundaries
	if heart_x<0 or
	heart_x>122 then
		heart_dx=-heart_dx
	end
	
	if heart_y<0 or
	heart_y>122 then
		heart_dy=-heart_dy
	end 
end



--draw heart

function draw_heart()

	local color
	
	if mode=="menu" then
		color=8
		
	elseif mode=="game" then
		color=9
		
	elseif mode=="end" then
		color=10
		
	end
	
	print("♥",heart_x,heart_y,
	color)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
