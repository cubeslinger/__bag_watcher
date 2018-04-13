--
-- Addon       BagWatcher.lua
-- Author      marcob@marcob.org
-- StartDate   04/04/2018
-- Version     0.3
--
local addon, bw = ...
--
local function displayresults(t)

   local k, v = nil, nil
   local a, b = nil, nil

   for k, v in pairs (t) do
--       print(string.format("main: displayresults (t): msgid [%s]", k))
--       for a, b in pairs(v) do
--          print(string.format("                              : [%s] [%s]", a, b))
--       end

      if bw.bagscanner.base  then
         print(string.format("BagWatcher: \"%s\" %s", v.name, (v.stack - bw.bagscanner.base[v.name])))
      end
   end

   return

end

local function  doinventoryscan()

   bw.bagscanner.inventory()

--    local k, v  =  nil, nil
--    local count =  0
--    for k, v in pairs(bw.bagscanner.base) do
--       print(string.format("doinventoryscan(bw.base): (%02s) [%30s] [%02s]", count, k, v))
--       count =  count + 1
--    end


   return

end

local function main(h, t)

   bw.player   =  Inspect.Unit.Detail("player")

   local availableid, availablename, weareready =  nil,  nil, false

   for availableid, availablename in pairs(t) do if bw.player.id == availableid then  weareready = true break end end

   if weareready then

      Command.Event.Detach(Event.Unit.Availability.Full, main, "Stats: get base stats")

      bw.bagwatcher  =  bagwatcher(displayresults)
      bw.bagscanner  =  bagscanner()

      bw.timer       =  __timer()
      bw.timer.add(doinventoryscan, 5)

      local q  =  {  fish     =  bw.bagwatcher.addwatcher({ category =  "fish" }),           -- everything in a category with "fish" in it's name
                     burlap   =  bw.bagwatcher.addwatcher({ name     =  "burlap cloth" })    -- look for "burlap cloth" in item name (case INsensitive)
                  }
--       local fish     =  bw.bagwatcher.addwatcher({ category =  "fish" })            -- everything in a category with "fish" in it's name
--       local burlap   =  bw.bagwatcher.addwatcher({ name     =  "burlap cloth" })    -- look for "burlap cloth" in item name (case INsensitive)

   end

   return

end

Command.Event.Attach(Event.Unit.Availability.Full, main,    "Stats: get base stats")
