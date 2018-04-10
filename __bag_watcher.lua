--
--
--    Addon       __bag_watcher.lua
--    Author      marcob@marcob.org
--    StartDate   05/04/2018
--    Version     0.6
--
--
--    Main Call:
--
--    <handler>   =  bagmonitor([<callback_function>])
--
--       [<callback_function>]   => if present gets called like this: callback_function(<message_tbl>)
--
--       <message_table>   => { [queryid] = { msgid=<msgid>, slot=<slot>, itemid=<itemid>, name=<name>, category=<category>, newevent=<newevent> } }
--
--          <msgid>        =  event arrivalorder, progressive.
--          <slot>         =  bag and slot where the event took place.
--          <itemid>       =  the itemid of the event's object.
--          <name>         =  the item name of the event's object (in current client language).
--          <category>     =  the item category of the event's object (in current client language).
--          <newevent>     =  true if the event is a new one, false it's an update.
--
--    Public Methods:
--
--       <watcherid> =  <handler>.addwatcher({...})
--                      <watcherid> => to be used in getmessages(<watcherid>)
--
--       void        =  <handler>.delwatcher(<watcherid>)
--
--       <msgtable>  =  <handler>.getmessages(<watcherid>)
--                      <msgtable> = { slot=bag_slot, itemid=item_id, name=item_name, category=item_category, newevent=new_event, stack=stack }
--
--    Public Vars:
--
--       <handler>.mailbox   => the table read by getmessages()
--
--
--
--
local addon, bw = ...
--
function bagwatcher(callback_function)
   -- the new instance
   local self =   {
                  mailbox     =  {},
                  cachebase   =  {}
                  -- public fields go in the instance table
                  }

   --
   -- private fields are implemented using locals
   -- they are faster than table access, and are truly private, so the code that uses your class can't get them
   --
   local watchers             =  {}
   local queryid              =  0
   local msgid                =  0
   local lastmsg              =  0

   --private
   local function countarray(array)
      local k, v  =  nil, nil
      local count =  0
      local t     =  array

      if array then
         for k, v in pairs(array) do count = count +1 end
      end

      return count
   end

   -- private
   local function queue_message(t)
      -- t  =  { msgid=msgid, slot=t.slot, itemid=t.itemid, name=t.name, category=t.category, newevent=t.newevent, stack=t.stack, delta=t.delta }

--       for k, v in pairs(t) do
--          print(string.format("queue_message: k=%s, v=%s", k, v))
--       end

      msgid    =  msgid + 1
      lastmsg  =  msgid

      local tt  =   { msgid=msgid, slot=t.slot, itemid=t.itemid, name=t.name, category=t.category, newevent=t.newevent, stack=t.stack, delta=t.delta }

      if not self.mailbox[t.queryid]   then  self.mailbox[t.queryid] =  {} end

      table.insert(self.mailbox[t.queryid], tt )

      -- CallBack Function
      if callback_function then  callback_function( { [queryid] = tt } )   end

      return
   end

   --
   -- private
   -- scan All Inventory Bags
   --
--    local function initbagcache()
--       --
--       --    Utility.Item.Slot.All
--       --    Utility.Item.Slot.Bank
--       --    Utility.Item.Slot.Character
--       --    Utility.Item.Slot.Guild
--       --    Utility.Item.Slot.Inventory
--       --    Utility.Item.Slot.Quest
--       --    Utility.Item.Slot.Wardrobe
--       --
--       local allbags  =  Inspect.Item.List(Utility.Item.Slot.All())
--
--       for slotid, itemid in pairs(allbags) do
--
--          if itemid then
--
--             local item  = Inspect.Item.Detail(itemid)
--
--             if self.cachebase[item.name] then
--                self.cachebase[item.name]   =  self.cachebase[item.name] + (item.stack or 0)
--             else
--                self.cachebase[item.name]   =  (item.stack or 0)
--             end
--
--             print(string.format("initbagcache: %s = %s item.stack=[%s]", item.name, self.cachebase[item.name], item.stack))
--
--          end
--       end
--
--       return
--    end

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
      local slot     =  nil
      slot           =  Utility.Item.Slot.All()
      local allbags  =  Inspect.Item.List(slot)
--       print(string.format("all count: %s [%s]", countarray(allbags), slot))

      for slotid, itemid in pairs(allbags) do

         if itemid then

            local item  = Inspect.Item.Detail(itemid)

            if item.stack then

               if self.cachebase[item.name] then
                  self.cachebase[item.name]   =  self.cachebase[item.name] + (item.stack or 0)
               else
                  self.cachebase[item.name]   =  (item.stack or 0)
               end

               print(string.format("initbagcache: %s = %s item.stack=[%s] slot=[%s]", item.name, self.cachebase[item.name], item.stack, slotid))
            end

         end
      end


      return
   end


   -- private
   local function parseventtable(h, eventtable, new)

      local itemid   =  nil
      local slot     =  nil

      if eventtable ~= nil then

         for slot, itemid in pairs(eventtable) do

            if itemid ~= "nil" and itemid ~= false then

               local item  =  Inspect.Item.Detail(itemid)

               for _, wtable in pairs(watchers)   do

                  local qhits =  0

                  for queryid, qargs in pairs(wtable) do

                     if qargs.itemid   and   qargs.itemid   == item.itemid               then  qhits =  qhits +1 end
                     if qargs.name     and   string.find(item.name, qargs.name)          then  qhits =  qhits +1 end
                     if qargs.category and   string.find(item.category, qargs.category)  then  qhits =  qhits +1 end

                     --
                     -- do we have enough hits?
                     --
                     if qhits == countarray(qargs) then

                        local t        =  {}
                        t.slot         =  slot
                        t.itemid       =  itemid
                        t.name         =  item.name
                        t.category     =  item.category
                        t.queryid      =  queryid
                        t.newevent     =  new
                        t.stack        =  item.stack
                        t.delta        =  t.stack - (self.cachebase[t.name] or 0)

                        print(string.format("Queueing Event: queryid[%s]\n                newevent[%s]\n                slot[%s]\n                itemid[%s]\n                name[%s]\n                category[%s]\n                stack=[%s]\n                delta=[%s]\n                cachebase=[%s]", queryid, new, slot, itemid, item.name, item.category, item.stack,  t.delta, self.cachebase[item.name]))
                        --
                        queue_message(t)
                        --
                        self.cachebase[t.name]  =  t.stack
                        t                       =  {}
                     end

                  end

               end

            end

         end

      else

         print("ERROR in parseventtable, eventable is empty")

      end

      return
   end

   -- private
   local function gotnewevent(h, eventtable)    return parseventtable(h, eventtable, true)   end

   -- private
   local function gotupdateevent(h, eventtable) return parseventtable(h, eventtable, false)  end

   -- private
   local function attach_events()
      Command.Event.Attach(Event.Item.Update,   gotupdateevent,   "bagmonitor_item_update")
      Command.Event.Attach(Event.Item.Slot,     gotnewevent,      "bagmonitor_item_slot")

      return
   end

   -- private
   local function detach_events()
      Command.Event.Detach(Event.Item.Update,   gotupdateevent,   "bagmonitor_item_update")
      Command.Event.Detach(Event.Item.Slot,     gotnewevent,      "bagmonitor_item_slot")
      return
   end

   --
   -- PUBLIC: get all messages in queue
   -- then clean the queue
   --
   function self.getmessages(queryid)

      local t  =  {}

      if queryid  then

         t	=  self.mailbox[queryid]

         local removed  =  table.RemoveByValue( self.mailbox, queryid )
         print(string.format("REMOVED msgs for queryid=%s, {%s}", queryid, removed))

         msgid          =  0
         lastmsg        =  0
      end

      return(t)
   end

   --
   -- PUBLIC
   --
   -- <handler>.addwatcher( { name="name", category="categoryname", itemid="itemid" } )
   --    userinput.name       -> watch for item by name
   --    userinput.category   -> watch for category items
   --    userinput.itemid     -> watch for item by its itemid
   --    userinput.exact      -> strict matching on .name and/or
   --                            .category, matches are always
   --                            exact on itemid, (default=false).
   --
   function self.addwatcher(userinput)

      if userinput   ~= {} then
         --
         -- first item to monitor, so we
         -- need to install Event Monitors.
         --
--          print(string.format("**** countarray(watchers) = %s", countarray(watchers)))
         if countarray(watchers) < 1 then attach_events() end

         queryid           =  queryid + 1
         table.insert(watchers, { [queryid] =  userinput })
      end

      return queryid
   end

   --
   -- PUBLIC: remove a watcher by watcherid
   -- watcherid is returned by .addwatcher(...)
   --
   function self.delwatcher(watcherid)

      if self.watchers[watcherid]   then
         table.remove(self.watchers, watcherid)

         -- if this is the last element watched we need to remove
         -- Event Monitors.
         if countarray(watchers) > 1 then detach_events()   end
      end

      return
   end

   -- initialize bag cache (must be run AFTER: Event.Unit.Availability.Full)
   initbagcache()

   -- return the instance
   return self
end
