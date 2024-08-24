pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--###########################--
--#     global functions    #--
--###########################--


--global init function

function _init()

	--define initial mode
	mode = "menu"
end



--global update function

function _update()

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
	if btnp(❎) then
		mode = "end"
	end
end

function draw_game()
	cls(2)
	print("press ❎ to finish",
	28,60,14)
end



-- "end" state functions

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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
