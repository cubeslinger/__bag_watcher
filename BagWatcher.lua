--
-- Addon       BagWatcher.lua
-- Author      marcob@marcob.org
-- StartDate   04/04/2018
-- Version     0.2
--
local addon, bw = ...
--
local function displayresults(t)

   local k, v = nil, nil
   local a, b = nil, nil
   local c, d = nil, nil
   for k, v in pairs (t) do
      print(string.format("main: displayresults (t): msgid [%s]", k))
      for a, b in pairs(v) do
         print(string.format("                              : [%s] [%s]", a, b))
      end
      print(string.format("BagWatcher: %s %s", v.name, v.delta))
   end

   return

end

local function main(h, t)

   bw.player   =  Inspect.Unit.Detail("player")

   local availableid, availablename, weareready =  nil,  nil, false

   for availableid, availablename in pairs(t) do if bw.player.id == availableid then  weareready = true break end end

   if weareready then

--       Command.Event.Detach(Event.Unit.Availability.Full, main, "Stats: get base stats")

      bw.bagwatcher  =  bagwatcher(displayresults)

      -- <handler>.addwatcher( {name="itemname", category="categoryname", itemid="itemid" } )
      --    userinput.name       -> watch for item by name (or substring)
      --    userinput.category   -> watch for category items (or substring)
      --    userinput.itemid     -> watch for item by its itemid
      --
--       local q        =  {}
      local fish     =  bw.bagwatcher.addwatcher({ category =  "fish" })            -- everything in a category with "fish" in it's name
      local burlap   =  bw.bagwatcher.addwatcher({ name     =  "burlap cloth" })    -- look for "burlap cloth" in item name (case INsensitive)

   end

   return

end

Command.Event.Attach(Event.Unit.Availability.Full, main,    "Stats: get base stats")
