--
--
--    Addon       __timer.lua
--    Author      marcob@marcob.org
--    StartDate   13/04/2018
--    Version     0.1
--
--
--    Main Call:
--
--
--    Public Methods:
--
--    Public Vars:
--

function __timer()
   -- the new instance
   local self =   {
                  -- public fields go in the instance table
                     callback    =  callback,
                     recurring   =  recurring,
                     watchdog    =  false,
                     timerstart  =  nil,
                     time        =  {  hour=0, mins=0, secs=0 }
                  }

   --
   -- private fields are implemented using locals
   -- they are faster than table access, and are truly private, so the code that uses your class can't get them
   --

   --private
   function self.timedeventsmanager()

      local now = Inspect.Time.Frame()

--       print(string.format("__timer: timedeventsmanager(%s) watchdog(%s), timerstart(%s)", now, self.watchdog, self.timerstart))

      --
      -- Section rolling Timers - Begin
      --
      --
      -- first run
      --
      if self.timerstart   == nil then
         self.timerstart   =  now
         lasttotaltime     =  now
      else
         local secs  =  (now - self.timerstart)
         local mins  =  0
         local hour  =  0

         if secs > 1 then
            secs = math.floor(secs)
            while secs  >  60 do
               secs  = secs - 60
               mins = mins + 1
            end
            while mins  >  60 do
               mins  = mins - 60
               hour = hour + 1
            end

            local tsecs       =  0
            tsecs             =  now - lasttotaltime
            lasttotaltime     =  now
            self.time.secs    =  self.time.secs + tsecs

            while self.time.secs   >   60 do
               self.time.secs      =   self.time.secs - 60
               self.time.mins      =   self.time.mins + 1
            end
            while self.time.mins   >   60 do
               self.time.mins      =   self.time.mins - 60
               self.time.hour      =   self.time.hour + 1
            end


            --[[

                things todo each frame

               ]]

         end
      end
      --
      -- Section rolling Timers - End
      --

      if self.watchdog == true then
         --
         -- Section Watchdog - Begin
         --
         -- first run
         if self.timerstart == nil then
            self.timerstart = now
         else

            if (now - self.timerstart) >= self.time2wait then
               --
               -- time is up (time2wait has expired)
               -- we are done, stop timer/flags
               --
               self.timerstart=  nil
               self.watchdog  =  false

               -- remove handler
               Command.Event.Detach(Event.System.Update.Begin, self.timedeventsmanager,  "Event.System.Update.Begin")

               if self.callback  then

                  self.callback()

               end

            end
         end
         --
         -- Section Watchdog - End
         --
      end

      return
   end


   --
   -- PUBLIC
   --
   function self.add(callback, time2wait, recurring)

      if callback and time2wait then
         self.callback  =  callback
         self.time2wait =  time2wait
         self.recurring =  recurring
         self.watchdog  =  true

         Command.Event.Attach(Event.System.Update.Begin, self.timedeventsmanager,  "Event.System.Update.Begin")

      else

         print(string.format("__timer.addtimer ERROR: <callback=[%s]> <time2wait=[%s]> [<recurring=[%s]>]", callback, time2wait, recurring))

      end

      return self
   end

   --
   -- PUBLIC
   --
   function self.del(callback, time2wait, recurring)

      if callback and time2wait then
         self.callback  =  nil
         self.time2wait =  nil
         self.recurring =  nil
         self.watchdog  =  false

         Command.Event.Detach(Event.System.Update.Begin, self.timedeventsmanager,  "Event.System.Update.Begin")

      else

         print(string.format("__timer.deltimer ERROR: <callback=[%s]> <time2wait=[%s]> [<recurring=[%s]>]", callback, time2wait, recurring))

      end

      return self
   end

   return self

end
