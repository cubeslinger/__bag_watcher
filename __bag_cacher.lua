--
-- Addon       __bag_cacher.lua
-- Author      marcob@marcob.org
-- StartDate   09/04/2018
-- Version     0.2
--
local addon, bw = ...
--
function bagcacher(callback_function)
   -- the new instance
   local self =   {
                  -- public fields go in the instance table
                  originalcallback  =  callback_function,
                  cachebase         =  {},
--                   bagmonitor        =  bagmonitor(cachercallback)
                  }

   --
   -- private fields are implemented using locals
   -- they are faster than table access, and are truly private, so the code that uses your class can't get them
   --
   -- local watchers             =  {}


   --private
   local function cachercallback(table)
      
      --
      local watcherid, t   =  nil, {}
      local tt             =  {}
      --
      for watcherid, t  in pairs (table) do 
         
         if t.stack then
            
--                local a, b = nil, nil
--                for a, b in pairs(t) do 
--                   print(string.format("cachercallback: k(t)=%s, v(t)=%s", a, b))   
--                end
            
            
            tt =  t
            tt.delta =  t.stack - (self.cachebase[t.itemname] or 0)
            print(string.format("delta: %s - (%s or 0)", t.stack, self.cachebase[t.itemname] ))

            
            self.originalcallback( { [watcherid] = tt } )            
            self.cachebase[t.itemname]  =  t.stack
            
         else
            
            print("__bag_cacher: ERROR t.stack is empty, t is:")
            
            local k, v = nil, nil
            local a, b = nil, nil
            for k, v in pairs(t) do 
               print(string.format("            : k(t)=%s, v(t)=%s", k, v))   
               for a, b in pairs(v) do 
                  print(string.format("            : k(v)=%s, v(v)=%s", a, b))   
               end
            end
         end
      end

      return
   end

   --
   -- private
   -- scan All Inventory Bags
   --
   local function initbagcache()
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

            if self.cachebase[item.name] then
               self.cachebase[item.name]   =  self.cachebase[item.name] + (item.stack or 1)
            else
               self.cachebase[item.name]   =  (item.stack or 1)
            end
            
            print(string.format("initbagcache: %s = %s", item.name, self.cachebase[item.name]))
            
         end
      end

      return
   end

   -- PUBLIC
   function self.addwatcher(t)  return(self.bagmonitor.addwatcher(t))   end

   -- PUBLIC
   function self.delwatcher(t)  return(self.bagmonitor.delwatcher(t))   end

   --
   -- init main obj
   -- 
   self.bagmonitor        =  bagmonitor(cachercallback)
   initbagcache()
   --
   -- end module -----------------------------------------
   --
   -- return the instance
   return self
end

--[[
Error: BagWatcher/__bag_cacher.lua:38: table index is nil
    In BagWatcher / bagmonitor_item_slot, event Event.Item.Slot
stack traceback:
	[C]: in function '__newindex'
	BagWatcher/__bag_cacher.lua:38: in function 'callback_function'
	BagWatcher/__bag_watcher.lua:180: in function 'queue_message'
	BagWatcher/__bag_watcher.lua:224: in function <BagWatcher/__bag_watcher.lua:186>
      ]]
   
