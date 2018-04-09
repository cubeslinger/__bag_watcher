--
--
--    Addon       __bag_monitor.lua
--    Author      marcob@marcob.org
--    StartDate   05/04/2018
--    Version     0.5
--
--
--    Main Call:
--
--    <handler>   =  bagmonitor([<callback_function>])
--                   [<callback_function>]   => if present gets called like this:
--
--                                              callback_function(message_tbl)
--
--                            message_table  => { [queryid]    =  { msgid=<msgid>, slot=<slot>, itemid=<itemid>, itemname=<itemname>, itemcategory=<itemcategory>, newevent=<newevent> } }
--
--                                              <msgid>        =  event arrivalorder, progressive.
--                                              <slot>         =  bag and slot where the event took place.
--                                              <itemid>       =  the itemid of the event's object.
--                                              <itemname>     =  the item name of the event's object (in current client language).
--                                              <itemcategory> =  the item category of the event's object (in current client language).
--                                              <newevent>     =  true if the event is a new one, false it's an update.
--
--    Public Methods:
--
--    <queryid>   =  <handler>.addbyname(itemname)
--                   <queryid> => to be used in getmessages(<queryid>)
--    void        =  <handler>.delbyname(itemname)
--    table       =  <handler>.getmessages(<queryid>)
--                => table = { slot=slot, itemid=itemid, itemname=itemname, itemcategory=itemcategory }
--
--    Public Vars:
--
--       <handler>.mailbox   => the table read by getmessages()
--
--
--[[


   Notes on Bags:
   ------
   source: http://wiki.riftui.com/Inspect.Item.List

   Sintax

      items = Inspect.Item.List()		-- table  <- void
      item  = Inspect.Item.List(slot)	-- item   <- slot
      items = Inspect.Item.List(slot)	-- table  <- slot
      items = Inspect.Item.List(slots)	-- table  <- table

   Parameters

      slot:	A single slot specifier.
      slots:	A table of slot specifiers.

   Return Value

      item:	A single item ID. This will be returned only if the input is a single fully-specified slot specifier.
      items:	A lookup table of item IDs. The key is the slot specifier, the value is the item ID.

   Slot Identifiers

   Slot identifiers are strings used to denote the exact location of items, whether in the bank, worn on the character,
   in the wardrobe, or in inventory. Slots are designated by the following code:

   Every slot begins with "s"
   The second, third, and fourth letters indicate the location

         bmn = Main bank slots

         b0x = Bank bag slot, where x is between 1 and 8

         qst = Quest bag

         eqp = Equipped items

         ibg = Inventory bags (the actual bag, not the items in the bag)

         i0x = Inventory bag contents, where x is between 1 and 5

         w0x = Wardrobe slot, where x is between 1 and 4

         g0x = Guild bank, where x indicates the vault number

   A period separates the first four characters from the remaining three characters
   The remaining three characters indicate the position of the item

         0xx = Slot position within bags (or, in the case of the bags themselves, the bag slot)
         rn1 = Ring 1
         rn2 = Ring 2
         blt = Belt
         nck = Neck
         hlm = Helmet
         tkt = Trinket
         chs = Chest
         fcs = Planar Focus
         hof = Off hand
         lgs = Legs
         shl = Shoulders
         syn = Synergy Crystal
         rng = Ranged
         fet = Feet
         hmn = Main hand
         glv = Gloves
         sel = Seal

   Examples
         seqp.nck = Equipped Neck item
         si05.022 = Item number 22 in bag number 5
         sibg.004 = Bag number 4
         sqst.001 = Item number 1 in the quest bag
         sw01.shl = Shoulder item in Wardrobe slot 1


   Utilities
   The API has provided a number of utilities to make it easier to create the slot identifiers
   without necessarily remembering all the above information:

         Utility.Item.Slot.All
         Utility.Item.Slot.Bank
         Utility.Item.Slot.Character
         Utility.Item.Slot.Guild
         Utility.Item.Slot.Inventory
         Utility.Item.Slot.Quest
         Utility.Item.Slot.Wardrobe
         ]]
--
--
local addon, achi = ...
--
function bagmonitor(callback_function)
   -- the new instance
   local self =   {
                  mailbox  =  {},
                  -- public fields go in the instance table
                  }

   --
   -- private fields are implemented using locals
   -- they are faster than table access, and are truly private, so the code that uses your class can't get them
   --
   local watchers             =  {}
   local monitored_itemnames  =  {}
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
   local function iswatchedname(frombag)
      local retval   =  false
      frombag        =  string.lower(frombag)

      for _, tocheck in ipairs(monitored_itemnames) do
         if string.find(frombag, tocheck) then
            retval   =  true
         else
            retval   =  false
         end
      end

      return retval
   end

   -- private
   local function queue_message(t)
      -- t = {slot=slot, itemid=itemid, itemname=itemname, itemcategory=itemcategory)}

--       for k, v in pairs(t) do
--          print(string.format("queue_message: k=%s, v=%s", k, v))
--       end

      msgid    =  msgid + 1
      lastmsg  =  msgid

      local tt  =   { msgid=msgid, slot=t.slot, itemid=t.itemid, itemname=t.itemname, itemcategory=t.itemcategory, newevent=t.newevent }

      if not self.mailbox[t.queryid]   then  self.mailbox[t.queryid] =  {} end

      table.insert(self.mailbox[t.queryid], tt )

      -- CallBack Function
      if callback_function then  callback_function( { [queryid] = tt } )   end

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

--                         print(string.format("Queueing Event: queryid[%s]\n                newevent[%s]\n                slot[%s]\n                itemid[%s]\n                itemname[%s]\n                category[%s]", queryid, new, slot, itemid, item.name, item.category))

                        local t        =  {}
                        t.slot         =  slot
                        t.itemid       =  itemid
                        t.itemname     =  item.name
                        t.itemcategory =  item.category
                        t.queryid      =  queryid
                        t.newevent     =  new
                        queue_message(t)
                        t              =  {}
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
   -- PUBLIC: add an object (by name)
   -- to the monitored list
   --
   function self.addbyname(itemname)

      -- first item to monitor, so we
      -- need to install Event Monitors.
      if countarray(monitored_itemnames) < 1 then attach_events() end

      table.insert(monitored_itemnames, string.lower(itemname))

      return
   end

   --
   -- PUBLIC
   --
   -- <handler>.addwatcher( {name="itemname", category="categoryname", itemid="itemid", [exact=<true|false>]} )
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


   -- PUBLIC: add an object (by name)
   -- to the monitored list
   function self.delbyname(itemname)

      local monitored_itemnames_size = #monitored_itemnames
      local i = 1
      while i <= #monitored_itemnames_size do
         local value = monitored_itemnames[i]
         if value == itemname then
            table.remove(monitored_itemnames, i)
         else
            i = i + 1
         end
      end

      -- if this is the last element watched we need to remove
      -- Event Monitors.
      if next(monitored_itemnames) == nil then
         detach_events()
      end

      return
   end

   -- return the instance
   return self
end
