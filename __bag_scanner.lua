--
--
--    Addon       __bag_scanner.lua
--    Author      marcob@marcob.org
--    StartDate   12/04/2018
--    Version     0.2
--
--
--    Main Call:
--
--    <handler>   =  bagscanner([<callback_function>])
--
--
--    Public Methods:
--
--       <void>   =  bagscanner.scanlist( { "inventory", "quest" } )
--
--    Public Vars:
--
--       self.base=  {} hash containing scan results
--
--
function bagscanner()
   -- the new instance
   -- public fields go in the instance table
   local self =   {
                  base     =  {},
                  }

   --
   -- private fields are implemented using locals
   -- they are faster than table access, and are truly private, so the code that uses your class can't get them
   --
   -- local watchers =  {}
   -- local queryid  =  0
   -- local msgid    =  0
   -- local lastmsg  =  0


   -- split a string
   function string:split(delimiter)

      local result = { }

      local from  = 1

      local delim_from, delim_to = string.find( self, delimiter, from  )

      while delim_from do
         table.insert( result, string.sub( self, from , delim_from-1 ) )
         from  = delim_to + 1
         delim_from, delim_to = string.find( self, delimiter, from  )
      end

      table.insert( result, string.sub( self, from  ) )

      return result
   end


   -- private
   local function makeinvbagcache()

      local baglist  =  {}
      local bagslot  =  nil
      local bagid    =  nil
      local invbags  =  Inspect.Item.List(Utility.Item.Slot.Inventory("bag"))

      --
      -- Count bags forming inventory
      -- then count how many slots each bag has
      --
      for bagslot, bagid in pairs(invbags) do

         if bagslot  and   bagid then

            local baginfo  =  Inspect.Item.Detail(bagid)

--             print(string.format("makeinvbagcache: bagslot=%s bagid=%s, name=%s", bagslot, bagid, baginfo.name ))

            local lbl, bagnumber =  unpack(bagslot:split("%."))
            bagnumber            =  tonumber(bagnumber)

--             print(string.format("makeinvbagcache: lbl=%s bagnumber=%s", lbl, bagnumber))
            baglist[tonumber(bagnumber)]    =  Inspect.Item.Detail(bagid).slots

         end

      end

      --
      -- scan all slots of all bags that compose inventory
      --
      local bagnumber   =  0

      for bagnumber, bagslots in pairs(baglist) do

         local bagslot  =  nil
         local itemslot =  nil

--          print(string.format("makeinvbagcache: bagnumber=%s bagslots=%s", bagnumber, bagslots ))

         for bagslot=1, bagslots do

--             print(string.format("makeinvbagcache: bagnumber=%s bagslot=%s", bagnumber, bagslot))

            itemslot = "si"
            itemslot =  itemslot..string.format("%2.2d", bagnumber)
            itemslot =  itemslot.."."
            itemslot =  itemslot..string.format("%3.3d", bagslot)

            local item  =  Inspect.Item.Detail(itemslot)

--             print(string.format("itemslot: %s item: %s", itemslot, item))

            if item and item.stack then

--                print("...adding...")

               if self.base[item.name] then
                  self.base[item.name]   =  self.base[item.name] + (item.stack or 0)
               else
                  self.base[item.name]   =  (item.stack or 0)
               end

--                print(string.format("makeinvbagcache:\tname=%s\tbase=%s\tstack=%s\tslot=%s", item.name, self.base[item.name], item.stack, itemslot))

            else

--                print(string.format("adding failed: item=%s", item))

            end

         end

      end

--       print("++++++++++++++++++++++++++")
--       local count =  0
--       for k, v in pairs(self.base) do print(string.format("\tbase: (%2d) k=%s, v=%s", count, k, v))   count = count +1 end
--       print("++++++++++++++++++++++++++")

      return self.base
   end

   local function makeqstbagcache()

      local bagslots =  40
      local bagslot  =  nil
      local itemslot =  nil

--       print(string.format("makeqstbagcache: bagnumber=%s bagslots=%s", bagnumber, bagslots ))

      for bagslot=1, bagslots do

--          print(string.format("makeqstbagcache: bagnumber=%s bagslot=%s", bagnumber, bagslot))

         itemslot = "sqst"
         itemslot =  itemslot.."."
         itemslot =  itemslot..string.format("%3.3d", bagslot)

         local item  =  Inspect.Item.Detail(itemslot)

         if item and item.stack then

--             print(string.format("itemslot: %s item: %s", itemslot, item.name))

            --                print("...adding...")

            if self.base[item.name] then
               self.base[item.name]   =  self.base[item.name] + (item.stack or 0)
            else
               self.base[item.name]   =  (item.stack or 0)
            end

--             print(string.format("makeqstbagcache:\tname=%s\tbase=%s\tstack=%s\tslot=%s", item.name, self.base[item.name], item.stack, itemslot))

--          else
--
--             print(string.format("adding failed: item=%s", item))

         end

      end

      return
   end

   --
   -- PUBLIC: scan all bags listed in {t}
   -- atm only:   "inventory" => (all inventory bags) e
   --             "quest"     => (all quest log bag slots)
   --             are allowed
   --
   function self.scanlist(t)
   -- self.scanlist( { "inventory", "quest" } )

      if t  then
         local bag      =  nil
         for _, bag in ipairs(t) do
            if bag   == "inventory" then  makeinvbagcache()    end   -- all inventory bags
            if bag   == "quest"     then  makeqstbagcache()    end   -- all questlog bag slots
            --             if bag   == "bank"      then  end   -- all bank + vaults slots
            --             if bag   == "guild"     then  end   -- all guildbank + vaults slots
         end
      end

      return
   end


   -- return the instance
   return self
end

