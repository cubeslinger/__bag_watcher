--
-- Addon       BagWatcher.lua
-- Author      marcob@marcob.org
-- StartDate   04/04/2018
-- Version     0.4
--
local addon, bw = ...
--
local function countarray(array)
   local k, v  =  nil, nil
   local count =  0
   local t     =  array

   if array then
      for k, v in pairs(array) do count = count +1 end
   end

   return count
end
      
local function displayresults(t)

   local k, v = nil, nil
   local a, b = nil, nil

   for k, v in pairs (t) do

--       print(string.format("main: displayresults (t): msgid [%s]", k))
--       for a, b in pairs(v) do
--          print(string.format("    : %s=%s", a, b))
--       end


      if bw.base  then
         --
         -- is it a REAL event or we did just got a 
         -- refresh from server, like when we use a 
         -- porticulum?
         --
         if (v.stack ~= (bw.delta[v.name] or 0)) then
--             print(string.format("BagWatcher: base/delta/stack=%s/%s/%s", (bw.base[v.name] or nil), (bw.delta[v.name] or nil), v.stack))
--             print(string.format("BagWatcher: %s %s (base/delta/stack=%s/%s/%s)", v.name, 
--                                                             (v.stack - (bw.delta[v.name] or 0)), 
--                                                             (bw.base[v.name] or nil), 
--                                                             (bw.delta[v.name] or nil), 
--                                                             v.stack
--                               )
--                )
               
            Command.Console.Display(   "general", 
                                       true, 
                                       string.format("BagWatcher: %s %s (base/delta/stack=%s/%s/%s)", v.name, 
                                                            (v.stack - (bw.delta[v.name] or 0)), 
                                                            (bw.base[v.name] or nil), 
                                                            (bw.delta[v.name] or nil), 
                                                            v.stack
                                                   ),
                                       true)                              
         end
         
         bw.delta[v.name] =  v.stack
         if not bw.base[v.name] then bw.base[v.name] = v.stack end
      end
   end

   return

end

local function  doinventoryscan()

   bw.bagscanner.inventory()
   bw.delta =  bw.bagscanner.base
   bw.base  =  bw.bagscanner.base

--    local k, v  =  nil, nil
--    local count =  0
--    for k, v in pairs(bw.bagscanner.base) do
--       print(string.format("doinventoryscan(bw.base): (%02s) [%30s] [%02s]", count, k, v))
--       count =  count + 1
--    end

   print(string.format("BagWatcher is ready: %s items indexed.", countarray(bw.base)))

   return

end

local function main(h, t)

   bw.player   =  Inspect.Unit.Detail("player")
   bw.base     =  {}
   bw.delta    =  {}

   local availableid, availablename, weareready =  nil,  nil, false

   for availableid, availablename in pairs(t) do if bw.player.id == availableid then  weareready = true break end end

   if weareready then

      Command.Event.Detach(Event.Unit.Availability.Full, main, "Stats: get base stats")

      bw.bagwatcher  =  bagwatcher(displayresults)
      bw.bagscanner  =  bagscanner()

      bw.timer       =  __timer()
      bw.timer.add(doinventoryscan, 5)

      local q  =  {  fish     =  bw.bagwatcher.addwatcher({ category =  "fish",           bag="si" }),   -- everything in a category with "fish" in it's name (in inventory)
                     burlap   =  bw.bagwatcher.addwatcher({ name     =  "burlap cloth",   bag="si" }),   -- look for "burlap cloth" in item name (case INsensitive)(in inv.)
                     artifact =  bw.bagwatcher.addwatcher({ category =  "artifact",       bag="si" })    -- look for "burlap cloth" in item name (case INsensitive)(in inv.)
                  }
--       local fish     =  bw.bagwatcher.addwatcher({ category =  "fish" })            -- everything in a category with "fish" in it's name
--       local burlap   =  bw.bagwatcher.addwatcher({ name     =  "burlap cloth" })    -- look for "burlap cloth" in item name (case INsensitive)

   end

   return

end

Command.Event.Attach(Event.Unit.Availability.Full, main,    "Stats: get base stats")

--[[
    Error: BagWatcher/BagWatcher.lua:21: attempt to index global 'item' (a nil value)
    In BagWatcher / bagmonitor_item_slot, event Event.Item.Slot
stack traceback:
	[C]: in function '__index'
	BagWatcher/BagWatcher.lua:21: in function 'callback_function'
	BagWatcher/__bag_watcher.lua:86: in function 'queue_message'
	BagWatcher/__bag_watcher.lua:137: in function <BagWatcher/__bag_watcher.lua:92>
   ]]
