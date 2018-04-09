--
-- Addon       BagWatcher.lua
-- Author      marcob@marcob.org
-- StartDate   04/04/2018
-- Version     0.2
--
local addon, achi = ...
--

-- local bm =  achi.bagmonitor()

-- for var, val in pairs(bm) do
--    print(string.format("var=[%s] val=[%s]", var, val))
-- end

-- bm.addbyname("fish")

-- local queryfish   =  achi.bagmonitor.addbyname("fish")
-- local queryburlap =  achi.bagmonitor.addbyname("burlap cloth")


-- <handler>.addwatcher( {name="itemname", category="categoryname", itemid="itemid", [exact=<true|false>]} )
--    userinput.name       -> watch for item by name (or substring)
--    userinput.category   -> watch for category items (or substring)
--    userinput.itemid     -> watch for item by its itemid
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

achi.bagmonitor=  bagmonitor(displayresults)

local queryfish   =  achi.bagmonitor.addwatcher({ category="fish" })       -- everything in a category with "fish" in name
print(string.format("ACHI: queryfish  [%s]", queryfish))

local queryburlap =  achi.bagmonitor.addwatcher({ name="burlap cloth" })   -- look for "burlap cloth" (case INsensitive)
print(string.format("ACHI: queryburlap[%s]", queryburlap))

