pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
//core functions
function _init()
	create_good_guys()
	create_bad_guys()
	create_text()
	create_text_controller()
	create_selector()
	create_achievements()
	game_over = false
	fight = false
	the_end = false
end

function _update()
 if the_end then
  text_controller.update()
  return
 end
 good_guys.update()
 bad_guys.update()
 text_controller.update()
 selector.update()
end

function _draw()
 cls()
 if the_end then
  text_controller.draw()
  achievements.draw()
  return
 end
 good_guys.draw()
 bad_guys.draw()
 selector.draw()
 achievements.draw()
 text_controller.draw()
 --debug()
end
-->8
//controllers
function create_good_guys()
 good_guys = {}
 good_guys.number = rand_int(4, 20)
 good_guys.kind = 'good'
 good_guys.nums = {}
 good_guys.positions = generate_position_array(64, 0, 128, 128, good_guys.number)
 good_guys.guys = {}
 populate_guys(good_guys)
 good_guys.draw = function ()
 	draw_guys(good_guys.guys)
 end
 good_guys.update = function()
  if fight then
   if rand_int(0, #bad_guys.guys) <= 1 and #good_guys.guys >= 1 and #bad_guys.guys >= 1 then
    kill_guy(good_guys, pick(good_guys.guys).num)
   end
   if #bad_guys.guys ==0 or #good_guys.guys == 0 then
   fight = false
   game_over = true
   resolve_game()
  end
  end
 end
end

function create_bad_guys()
 bad_guys = {}
 bad_guys.number = rand_int(4, 20)
 bad_guys.kind = 'bad'
 bad_guys.guys = {}
 bad_guys.nums = {}
 bad_guys.positions = generate_position_array(0, 0, 64, 128, bad_guys.number)
 bad_guys.guys = {}
 populate_guys(bad_guys)
 bad_guys.draw = function ()
 	draw_guys(bad_guys.guys)
 end
 bad_guys.update = function()
  if fight then
   if rand_int(2, #bad_guys.guys) <= 2 and #bad_guys.guys > 1 and #good_guys.guys >1 then
    kill_guy(bad_guys, pick(bad_guys.guys).num)
   end
  end
 end
end

function create_text_controller()
 text_controller = {}
 acheive = {}
 text_controller.current_num = 1
 if not achievements then
  text_controller.text_array = text.intro
 elseif #achievements <= 3 then
  text_controller.text_array = text.intro2 
 else
  text_controller.text_array = text.intro3
 end
 text_controller.current_text = ''
 text_controller.get_current_text = function()
  text_controller.current_text = text_controller.text_array[text_controller.current_num]
 end
 text_controller.get_current_text()
 
 text_controller.draw = function()
  if text_controller.current_text then
   draw_text(text_controller.current_text)
  end
 end
 text_controller.end_game = function(text_array)
  extra_array = text.normal_ending
  if game_won then
   extra_array = text.you_win
   the_end = true 
  end
  text_controller.text_array = text_array
  for element in all(extra_array) do
   add(text_controller.text_array, element)
  end
  text_controller.current_num = 1
  text_controller.get_current_text()
 end
 text_controller.update = function()
  if btnp (5) then
   if text_controller.current_num < #text_controller.text_array then
    text_controller.current_num+=1
    text_controller.get_current_text()    
   elseif game_over == true and the_end == false then
    _init()
   end
  end
 end
end

function create_selector()
 kill = false
 selector = {}
 selector.num_good_guys_start = #good_guys.guys
 selector.num_bad_guys_start = #bad_guys.guys
 selector.num = 1
 selector.group = bad_guys
 selector.toggle_group = function()
  if selector.group == bad_guys then
   selector.group = good_guys
  else
   selector.group = bad_guys
  end
 end
 selector.get_loc = function()
  selector.num = max(1, selector.num)
  selector.num = min(selector.num, selector.group.number)
  selector.loc = selector.group.positions[selector.num]
 end
 selector.get_loc()
 selector.draw = function()
  rect(selector.loc[1], selector.loc[2], selector.loc[1]+8, selector.loc[2]+8, 12)
 end
 selector.update = function()
  if not (text_controller.current_text == '') then
   return
  end
  if btnp(0) then
   check_switch('right')
   selector.num -=1
  elseif btnp(1) then
   check_switch('left')
   selector.num +=1 
  elseif btnp(2) then
   selector.num -= 5
  elseif btnp(3) then
   selector.num += 5
  elseif btnp(4) then
   selector.num_good_guys_end = #good_guys.guys
   selector.num_bad_guys_end = #bad_guys.guys
   fight = true
  elseif btnp(5) then
   if kill == true then
    kill_guy(selector.group, selector.num)
   end
   kill=true
  end
  selector.get_loc()
 end
end

function create_achievements()
 if not achievements then
 	  achievements = {}
 end
 achievements.draw = function()
  if #achievements == 0 then
   return
  end
  for i=1, #achievements do
   print(achievements[i], 0, 128-(8*i))
  end
  if #achievements >= 4 then
   print(#achievements..'/7', 0, 128-(8*(#achievements+1)))
  end
 end
end


-->8
//characters and objects
function populate_guys(group)
 for i=1, group.number do
  make_guy(group.kind, group)
 end
end

function make_guy(kind, group)
 guy = {}
 if kind == 'good' then
  guy.sprite = 1
 elseif kind == 'bad' then
  guy.sprite = 2
 else 
  guy.sprite = 2
 end
 guy.num = generate_unused_num(group.nums)
 guy.position = group.positions[guy.num]
 add(group.guys, guy)
 add(group.nums, guy.num)
end

function draw_guys(guys)
 for guy in all(guys) do
  spr(guy.sprite, guy.position[1], guy.position[2])
 end
end

function kill_guy(group, num)
 guy = nil
 for dude in all(group.guys) do
  if dude.num == num then
   guy = dude
  end
 end
 del(group.guys, guy)
end

function check_switch(direction)
 check = -1
 if direction == 'right' and selector.group == good_guys then
 check = 1
 elseif direction == 'left' and selector.group == bad_guys then
  check = 5
 end
 if mod(selector.num, 5) == check then
  selector.toggle_group()
  if selector.group == good_guys then
   selector.num -= 5
  elseif selector.group == bad_guys then
   selector.num += 5
  end
 end
end

function achieve(text)
 add_flag = true
 for element in all(achievements) do
  if element == text then
   add_flag = false
  end
 end
 if add_flag then
  add(achievements, text)
  if #achievements >= 7 then
   game_won = true
  end
 end
end
-->8
//helpers
//game specific helpers
function draw(object)
 for element in all(object.draw) do
  element()
 end
end

function update(object)
 for element in all(object.update) do
  element() 
 end
end

function generate_position_array(x1, y1, x2, y2, num)
 x2 -= 8
 y2 -= 8
 distance = 12
 array = {}
 for i=y1, y2, distance do
  for j=x1, x2, distance do
   add(array, {j, i})
  end
 end
 return array
end

//generic helpers
function pick(list)
 return list[rand_int(1, #list)]
end

function rand_int(lo, hi)
 return flr(rnd(hi-lo+1))+lo
end
 
function mod(x, y)
 while x > y do
  x -= y
 end
 return x
end

function generate_unused_num(list)
 for i = 1, #list do
 return_val = i
  for element in all(list) do
   if i == elemnt then
    return_val = -1
   end
  end 
  if not return_val == -1 then
   return return_val
  end
 end
 return #list+1
end
-->8
//debug
function debug()
 print(you_win, 0,0,7)
 print(test2, 0, 10, 7)
end
-->8
//lib??

function draw_text(text)
 if text == '' or text == nil then
  return
 end
 local text_copy = text
 line_beginning_x = 16
 line_beginning_y = 24
 line_height = 8
 line_length = 24
 char_count = #text
 line_count = ceil(char_count/line_length)
 local pointer_x = 0
 local new_pointer = 0
 local line_pointer = 0
 local new_line_pointer = 0
 draw_box(line_beginning_x-2, line_beginning_y-2, (line_length*4), ((1+line_count)*line_height))
 for i=0, 1000 do
  word = get_next_word(text_copy)
  new_pointer = pointer_x + #word
  if new_pointer > line_length then
   pointer_x = 0
   new_pointer = pointer_x + #word
   new_line_pointer = line_pointer+1
   line_pointer = new_line_pointer
  end
  print(word ,line_beginning_x+pointer_x*4, line_beginning_y+line_height*line_pointer)
  pointer_x = new_pointer
  line_pointer = new_line_pointer
  text_copy = sub(text_copy, #word+1)
 end
end

function draw_box(x, y, w, h)
 rectfill(x-2, y-2, x+w+6, y+h+4, 0)
 rect(x, y, x+w, y+h, 1)
 rect(x-1, y-1, x+w+1, y+h+1, 1)
 print('',0,0,7)
end

function get_next_word(text)
 for i=0, #text do
  if sub(text, i, i+0) == " " then
   return sub(text, 0, i)
  end
 end
 return text
end
-->8
//game end

function resolve_game()
 gge = selector.num_good_guys_end
 ggs = selector.num_good_guys_start
 bge = selector.num_bad_guys_end
 bgs = selector.num_bad_guys_start
 if gge == ggs and bge == 0 then
  achieve('murder rampage')
  text_controller.end_game(text.domination)
 elseif gge == ggs and bge == bgs then
  achieve('monster')
  text_controller.end_game(text.mercy)
 elseif gge == ggs and bge < bgs/2 then
  achieve('weak')
  text_controller.end_game(text.little_mercy)
 elseif gge == ggs and bge < bgs then
  achieve('trust betrayed')
  text_controller.end_game(text.partial_mercy)
 elseif gge == 0 and bge == 0 then
  achieve('1000 baths')
  text_controller.end_game(text.destruction)
 elseif gge == 0 and bge > 0 then
  achieve('heart of darkness')
  text_controller.end_game(text.wicked)
 elseif gge < ggs and bge > 0 then
  achieve('reckless psycho')
  text_controller.end_game(text.thanos)
 end
end
-->8
//text
function create_text()
 text = {}
 text.intro = {}
 add(text.intro,'welcome to coup (press "x" to advance)')
 add(text.intro,'coup is a citizen murder simulator')
 add(text.intro,'evil men are trying to overthrow your kind regime')
 add(text.intro,'with your great power, you can kill them using "x" before the rebillion even begins')
 add(text.intro,'press "x" to kill a rebel or a citizen, and press "c" when you think you have done enough to quell the rebellion, to see what happens')
 add(text.intro,'taking a life is never easy, but if rebellion does come, many of your citizens may lose their lives')
 add(text.intro,'how many of them must you kill to secure peace and safety for your loyal subjects?')
 add(text.intro,'')
 text.intro2 = {}
 add(text.intro2,'welcome to coup (press "x" to advance)')
 add(text.intro2,'coup is a citizen murder simulator')
 add(text.intro2,'but you already know that')
 add(text.intro2,"looks like you've been simulating plenty of murders")
 add(text.intro2,'this time actually try')
 add(text.intro2,'try to keep your citizens alive without taking too many lives')
 add(text.intro2,'and remember that one day the kingdom may depend on your success in this simulation')
 add(text.intro2,'')
 text.intro3 = {}
 add(text.intro3,'welcome to--')
 add(text.intro3,'good gosh you have simulated soo much murder')
 add(text.intro3,"i mean, this is just a game, but aren't you enjoying it a bit too much?")
 add(text.intro3,'honestly, i can smell the blood on your hands')
 add(text.intro3,"i can only hope that this time you won't get everybody killed")
 add(text.intro3,'')
 text.domination = {}
 add(text.domination, 'hands covered in blood, you rise from the corpses of your "enemies"')
 add(text.domination, "your enemies are dead, but somehow, your citizens don't feel safe")
 add(text.domination, "they live in endless hiding, unsure when you will go on your next murder rampage")
 text.mercy = {}
 add(text.mercy, 'in your great wisdom, it seems you have chosen to spare the lives of your enemies')
 add(text.mercy, 'all your people are dead')
 add(text.mercy, 'congratulations....')
 add(text.mercy, ' ')
 add(text.mercy, 'maybe')
 add(text.mercy, 'maybe this is what you wanted all along')
 add(text.mercy, 'monster')
 add(text.mercy, ' ')
 text.partial_mercy = {}
 add(text.partial_mercy, 'it seems you are not serious enough about the lives of your citizens')
 add(text.partial_mercy, 'as difficult as it is to come down hard on your enemies preemptively...')
 add(text.partial_mercy, 'try to remember that every one of those orange faces that dissapears means')
 add(text.partial_mercy, 'that another man, woman, or child is dead.')
 add(text.partial_mercy, 'a man, woman, or child that trusted you')
 add(text.partial_mercy, 'up until the moment that their body was peirced by the blade of evil men')
 add(text.partial_mercy, 'maybe next time you will have the strength to do what is necessary')
 text.little_mercy = {}
 add(text.little_mercy, 'the day is grim')
 add(text.little_mercy, 'you came close to squashing the rebellion')
 add(text.little_mercy, 'but, in the end, your efforts were not enough')
 add(text.little_mercy, 'as you look out among the waylaid landscape')
 add(text.little_mercy, 'and the wasted bodies of your slain citizenry')
 add(text.little_mercy, 'you can only hope that heaven will forgive you your weakness')
 text.destruction = {}
 add(text.destruction, 'why!  blood everywhere, sire, why!')
 add(text.destruction, 'you had everyone murdered, you insane creature')
 add(text.destruction, 'the thick smell of iron from the blood makes it hard to breathe')
 add(text.destruction, 'a thousand baths cannot wash you of this stench')
 add(text.destruction, ' ')
 add(text.destruction, 'what darkness have you wraught')
 text.wicked = {}
 add(text.wicked, '.')
 add(text.wicked, '..')
 add(text.wicked, '...')
 add(text.wicked, 'you wicked wicked human')
 add(text.wicked, "i don't even want to look at you")
 add(text.wicked, 'you had every loyal subject slaughtered')
 add(text.wicked, 'they would have followed you into the very heart of darkness')
 add(text.wicked, 'and you slaughtered them all before the revolt even began')
 add(text.wicked, 'it seems the heart of darkness lies within you')
 text.thanos = {}
 add(text.thanos, 'i umm')
 add(text.thanos, 'i know this is a difficult situation, but i do not think that murdering your own people is going to help')
 add(text.thanos, 'maybe you missed the point of this murder simulation')
 add(text.thanos, 'you want to keep the orange ones alive')
 add(text.thanos, 'because without them you have no kingdom')
 add(text.thanos, 'instead you killed some of them')
 add(text.thanos, "good thing you aren't really king")
 add(text.thanos, ' ')
 add(text.thanos, 'you reckless psycho')
 text.normal_ending = {}
 add(text.normal_ending, " ")
 add(text.normal_ending, "press 'x' to try again")
 text.you_win = {}
 add(text.you_win, ' ')
 add(text.you_win, "press 'x' to --")
 add(text.you_win, "no, actually i don't suppose you need to try again")
 add(text.you_win, "i'm not sure how, but you actually simulated all possible murders")
 add(text.you_win, "i'm afraid there is nothing more i can do for you")
 add(text.you_win, ' ')
 add(text.you_win, 'except pray for your sick sick soul')
 add(text.you_win, ' ')
 add(text.you_win, 'so consider this a success')
 add(text.you_win, 'if you really enjoy murdering this much')
 add(text.you_win, ' ')
 add(text.you_win, ' ')
 add(text.you_win, 'oh! and')
 add(text.you_win, 'thanks for playing')
end
__gfx__
00000000999999995111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995151115100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007009d99d9995151115100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000999999995111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000999999995111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700999999d95155155100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000099999dd95111511100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
