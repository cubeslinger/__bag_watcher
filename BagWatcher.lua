--
-- Addon       BagWatcher.lua
-- Author      marcob@marcob.org
-- StartDate   04/04/2018
-- Version     0.6
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

   bw.bagscanner.scanlist( { "inventory", "quest" })
   bw.delta =  bw.bagscanner.base
   bw.base  =  bw.bagscanner.base

--    print(string.format("BagWatcher is ready: %s items indexed.", countarray(bw.base)))

   Command.Console.Display( "general", true, string.format("BagWatcher is ready: %s items indexed.", countarray(bw.base)), true)

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

      local q  =  {  fish     =  bw.bagwatcher.addwatcher({ category =  "fish",                 bag="si" }),   -- everything in a category with "fish" in it's name (in inventory)
                     burlap   =  bw.bagwatcher.addwatcher({ name     =  "burlap cloth",         bag="si" }),   -- look for "burlap cloth" by name (case INsensitive)(in inventory)
                     artifact =  bw.bagwatcher.addwatcher({ category =  "artifact",             bag="si" }),   -- look for "burlap cloth" by name (case INsensitive)(in inventory)
                     sparkles =  bw.bagwatcher.addwatcher({ name     =  "exceptional sparkles", bag="qst"})    -- look for "Exceptional Sparkles" by name (in Quest Log Bag Slots)
                  }

      -- display active Watchers list
      local watcherslist   =  bw.bagwatcher.list()
      -- debug -- begin
      if next(watcherslist)  then

         for queryid, table in pairs(watcherslist) do

            print(string.format("Watchers List, QuerID: [%s]", queryid))

            local k, v  =  nil, nil
            for k, v in pairs(table) do
               --                print(string.format("             : k[%s]=v(%s)", k, v))

               local a, b  =  nil, nil
               for a, b in pairs(v) do
                  print(string.format("             : [%s]=(%s)", a, b))
               end
            end
         end
      end
      -- debug -- end

   end

   return

end

Command.Event.Attach(Event.Unit.Availability.Full, main,    "Stats: get base stats")
