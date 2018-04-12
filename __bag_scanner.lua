--
--
--    Addon       __bag_scanner.lua
--    Author      marcob@marcob.org
--    StartDate   12/04/2018
--    Version     0.1
--
--
--    Main Call:
--
--    <handler>   =  bagscanner([<callback_function>])
--
--
--    Public Methods:
--
--
--    Public Vars:
--
--
--
function bagscanner()
   -- the new instance
   local self =   {
                  base  =  {},
      -- public fields go in the instance table
   }

   --
   -- private fields are implemented using locals
   -- they are faster than table access, and are truly private, so the code that uses your class can't get them
   --
--    local watchers             =  {}
--    local queryid              =  0
--    local msgid                =  0
--    local lastmsg              =  0


   -- private
   local function originalone()

      local data        =  {}
      local bagnumber   =  0
      local bagslot     =  0

      for bagnumber=1,9 do

         for bagslot=1,40 do

            local itemslot = "si"..string.format("%2.2d",bagnumber).."."..string.format("%3.3d",bagslot)

            local itemid   =  Inspect.Item.List(itemslot)

            print(string.format("originalone: itemslot(%s) itemid(%s)", itemslot, itemid))

            if itemid   then

               local d        =  Inspect.Item.Detail(itemid)

               print(string.format("originalone: itemslot(%s) item(%s)", itemslot, d))

               if d then

                  if d.name and d.stack then
                     table.insert(data, { [d.name] = d.stack })
                     for a,b in pairs(d) do print(string.format("originalone: a=[%s] b=[%s]", a, b)) end
                     end

                  end

               end

            end

         end

      return data

   end

   -- private
   local function mkbagcache()

      local base   =  {}

      for bagnumber=1,10 do

         for bagslot=1,50 do

            itemslot = "si"..string.format("%2.2d",bagnumber).."."..string.format("%3.3d",bagslot)

            item  =  Inspect.Item.Detail(itemslot)


            if item and item.stack then

               if base[item.name] then
                  base[item.name]   =  base[item.name] + (item.stack or 0)
               else
                  base[item.name]   =  (item.stack or 0)
               end

               print(string.format("makebagcache:\tname=%s\tbase=%s\tstack=%s\tslot=%s", item.name, base[item.name], item.stack, slotid))

            end

         end

      end

      return base

   end

   -- private
   local function makeinvbagcache()

      local base     =  {}
      local baglist  =  {}
      local bagslot  =  nil
      local bagid    =  nil
      local invbags  =  Inspect.Item.List(Utility.Item.Slot.Inventory("bag"))

      for bagslot, bagid in pairs(invbags) do

         if bagslot  and   bagid then

            local baginfo  =  Inspect.Item.Detail(bagid)

            print(string.format("makeinvbagcache: bagslot=%s bagid=%s, name=%s", bagslot, bagid, baginfo.name ))

            local lbl, bagnumber =  unpack(string.split(bagslot, "."))
            bagnumber            =  tonumber(bagnumber)

            print(string.format("makeinvbagcache: lbl=%s bagnumber=%s", lbl, bagnumber))
            baglist[tonumber(bagnumber)]    =  Inspect.Item.Detail(bagid).slots

         end

      end

      -- scan all slots of all bags that compose inventory
      local bagnumber   =  0

      for bagnumber, bagslots in pairs(baglist) do

         local bagslot  =  nil
         local itemslot =  nil

         print(string.format("makeinvbagcache: bagnumber=%s bagslots=%s", bagnumber, bagslots ))

         for bagslot=1, bagslots do

--             itemslot = "si"..string.format("%2.2d", bagnumber).."."..string.format("%3.3d", bagslot)

            print(string.format("makeinvbagcache: bagnumber=%s bagslot=%s", bagnumber, bagslot))

            itemslot = "si"
            itemslot =  itemslot..string.format("%2.2d", bagnumber)
            itemslot =  itemslot.."."
            itemslot =  itemslot..string.format("%3.3d", bagslot)

            local item  =  Inspect.Item.Detail(itemslot)

            print(string.format("itemslot: %s item: %s", itemslot, item))

            if item and item.stack then

               print("...adding...")

               if base[item.name] then
                  base[item.name]   =  base[item.name] + (item.stack or 0)
               else
                  base[item.name]   =  (item.stack or 0)
               end

               print(string.format("makebagcache:\tname=%s\tbase=%s\tstack=%s\tslot=%s", item.name, base[item.name], item.stack, slotid))

            else

               print(string.format("adding failed: item=%s", item))

            end

         end

      end


      print("++++++++++++++++++++++++++")
      for k, v in pairs(base) do print(string.format("\tbase: k=%s, v=%s", k, v))   end
      print("++++++++++++++++++++++++++")

      return base
   end
--[[
   self.base =  makeinvbagcache()

--    self.base =  mkbagcache()

   print("==========================")
   for k, v in pairs(self.base) do print(string.format("\tself.base: k=%s, v=%s", k, v))   end
   print("==========================")
]]


   --
   -- PUBLIC: initialize bag cache
   --
   function self.inventory()

--       self.base   =  makeinvbagcache()
--       self.base   =  mkbagcache()
      self.base   =  originalone()
      print("--------------------------")
      for k, v in pairs(self.base) do print(string.format("\tself.inventory(): k=%s, v=%s", k, v))   end
      print("--------------------------")


      return
   end


   -- return the instance
   return self
end
