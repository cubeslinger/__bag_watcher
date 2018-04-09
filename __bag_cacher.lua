--
-- Addon       __bag_cacher.lua
-- Author      marcob@marcob.org
-- StartDate   09/04/2018
-- Version     0.1
--
local addon, bw = ...
--
function bagcacher(callback_function)
   -- the new instance
   local self =   {
                  -- public fields go in the instance table
                  originalcallback  =  callback_function,
                  cachebase         =  {}
                  bagmonitor        =  bagmonitor(callback_function)
                  }

   --
   -- private fields are implemented using locals
   -- they are faster than table access, and are truly private, so the code that uses your class can't get them
   --
   -- local watchers             =  {}


   --private
   local function cachercallback(t)
      --
      local tt =  t
      --
      self.originalcallback(tt)

      return
   end

   --
   -- private
   -- scan All Inventory Bags
   --
   local function initcache()
      --
      --    Utility.Item.Slot.All
      --    Utility.Item.Slot.Bank
      --    Utility.Item.Slot.Character
      --    Utility.Item.Slot.Guild
      --    Utility.Item.Slot.Inventory
      --    Utility.Item.Slot.Quest
      --    Utility.Item.Slot.Wardrobe
      --
      local allbags  =  Inspect.Item.List(Utility.Item.Slot.All())

      for slotid, itemid in pairs(allbags) do
         if itemid then

            local item  = Inspect.Item.Detail(itemid)

            itemname    = item.name
            itemstack   = item.stack

            if self.cachebase[itemname] then
               self.cachebase[itemname]   =  self.cachebase[itemname] + (item.stack or 1)
            else
               self.cachebase[itemname]   =  (item.stack or 1)
            end
         end
      end

      return
   end

   -- private
   local function addquantitiestoevent(t)
   -- [queryid] = { msgid=msgid, slot=t.slot, itemid=t.itemid, itemname=t.itemname, itemcategory=t.itemcategory, newevent=t.newevent }

      return
   end

   -- PUBLIC
   function addwatcher(t)  return(self.bagmonitor(t))   end

   -- PUBLIC
   function delwatcher(t)  return(self.bagmonitor(t))   end

   --
   -- end module -----------------------------------------
   --
   -- return the instance
   return self

end

