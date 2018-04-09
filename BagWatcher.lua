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
      print(string.format("displayresults (t): msgid [%s]", k))
      for a, b in pairs(v) do
         print(string.format("                        : [%s] [%s]", a, b))
      end
   end

   return

end

local function main()
   -- bw.bagmonitor  =  bagmonitor(displayresults)
   bw.bagcacher   =  bagcacher(displayresults)


   -- <handler>.addwatcher( {name="itemname", category="categoryname", itemid="itemid" } )
   --    userinput.name       -> watch for item by name (or substring)
   --    userinput.category   -> watch for category items (or substring)
   --    userinput.itemid     -> watch for item by its itemid
   --
   local queryfish   =  bw.bagcacher.addwatcher({ category="fish" })       -- everything in a category with "fish" in name
   -- print(string.format("agWatcher: queryfish  [%s]", queryfish))

   local queryburlap =  bw.bagcacher.addwatcher({ name="burlap cloth" })   -- look for "burlap cloth" (case INsensitive)
   -- print(string.format("BagWatcher: queryburlap[%s]", queryburlap))
   
end

Command.Event.Attach(Event.Unit.Availability.Full, main,    "Stats: get base stats")
