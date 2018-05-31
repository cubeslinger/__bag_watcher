--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   30/05/2018
--
function menu()
   -- the new instance
   local self =   {
                  menuid      =  1,
                  o           =  {},
                  fontsize    =  12,
                  color       =  { black = {  0,  0,  0,  1} },
                  borders     =  { l=2, r=2, t=2, b=2 },               -- Left, Right, Top, Bottom
                  status      =  {},
                  initialized =  false
                  }

   local function round(num, digits)
      local floor = math.floor
      local mult = 10^(digits or 0)

      return floor(num * mult + .5) / mult
   end

   --
   -- t  =  {  parent=[],                          -- parent menu or nil (need x and y)
   --          voices=< {
   --                      { name="", callback=""},
   --                      { ... },
   --                   },
   --          title=[],                           -- menu title or nil
   --          fontsize=[],                        -- defaults to
   --          fontface=[],                        -- defaults to Rift Font
   --          hide=[],                            -- defaults to start hidden, use :show() to reveal the menu
   --       }
   --
   function self.new(t)

      if not initialized then self = menu() end

      self.menuid       =  (self.menuid + 1)
      self.o.voices     =  {}
      local fs          =  t.fontsize or self.fontsize

      --Global context (parent frame-thing).
      self.o.context = UI.CreateContext("context_menu_" .. self.menuid)

      -- Main Window
      self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid, self.o.context)

      if t.parent ~= nil and next(t,parent) then
         self.o.menu:SetPoint("TOPLEFT", t.parent, "TOPRIGHT")
      else
         if t.x ~= nil and t.y ~= nil then
            -- we have coordinates
            self.o.menu:SetPoint("TOPLEFT", UIParent, "TOPLEFT", t.x, t.y)
         else
            print(string.format("ERROR: __menu.lua: t.parent is %s, and (%s,%s)", t.parent, x, y))
            return {}
         end
      end

      self.o.menu:SetLayer(-1)
--       self.o.menu:SetWidth(mano.gui.win.width)
      self.o.menu:SetBackgroundColor(unpack(self.color.black))

      if t.title ~= nil then
         self.o.menutitleframe =  UI.CreateFrame("Frame", "menu_title_frame_" .. self.menuid, self.o.menu)
         self.o.menutitleframe:SetPoint("TOPLEFT",  self.o.menu, "TOPLEFT",    self.borders.l,   self.borders.t)  -- move up, outside externalframe
         self.o.menutitleframe:SetPoint("TOPRIGHT", self.o.menu, "TOPRIGHT",   -self.borders.r,  self.borders.t)  -- move up, outside externalframe
         self.o.menutitleframe:SetHeight(fs)
         self.o.menutitleframe:SetBackgroundColor(unpack(self.color.black))
         self.o.menutitleframe:SetLayer(1)

         -- Window Title
         self.o.menutitle =  UI.CreateFrame("Text", "menu_title_" .. self.menuid, self.o.menutitleframe)
         self.o.menutitle:SetFontSize(fs)
         self.o.menutitle:SetText(string.format("%s", t.title), true)
         self.o.menutitle:SetLayer(3)
         self.o.menutitle:SetPoint("CENTERLEFT",   self.o.menutitleframe, "CENTERRIGHT")
      end

      if self.o.menutitleframe ~= nil and next(self.o.menutitleframe) then
         self.o.menuvoicesframe  =  UI.CreateFrame("Frame", "menu_voices_frame_" .. self.menuid, self.o.menutitleframe)
         self.o.menuvoicesframe:SetPoint("TOPLEFT",      self.o.menutitleframe,  "TOPLEFT")
         self.o.menuvoicesframe:SetPoint("TOPRIGHT",     self.o.menutitleframe,  "TOPRIGHT")
         self.o.menuvoicesframe:SetPoint("BOTTOMLEFT",   self.o.menu,  "BOTTOMLEFT",  self.borders.l,    -self.borders.b)
         self.o.menuvoicesframe:SetPoint("BOTTOMRIGHT",  self.o.menu,  "BOTTOMRIGHT", -self.borders.r,   -self.borders.b)
      else
         self.o.menuvoicesframe  =  UI.CreateFrame("Frame", "menu_voices_frame_" .. self.menuid, self.o.menu)
         self.o.menuvoicesframe:SetPoint("TOPLEFT",      self.o.menu,  "TOPLEFT",     self.borders.l,    self.borders.t)
         self.o.menuvoicesframe:SetPoint("TOPRIGHT",     self.o.menu,  "TOPRIGHT",    -self.borders.r,   self.borders.t)
         self.o.menuvoicesframe:SetPoint("BOTTOMLEFT",   self.o.menu,  "BOTTOMLEFT",  self.borders.l,    -self.borders.b)
         self.o.menuvoicesframe:SetPoint("BOTTOMRIGHT",  self.o.menu,  "BOTTOMRIGHT", -self.borders.r,   -self.borders.b)
      end

      local voiceid        =  0
      local lastvoiceframe =  {}
      for _, tbl in pairs(t.voices) do

         for var, val in pairs(tbl) do
            print(string.format("__menu: processing voice: %s of menu=%s (%s)", tbl.name, t.title, self.menuid))

            voiceid        =  voiceid + 1
            local v        =  {}
            local parent   =  {}
            if voiceid == 1 then parent = self.o.menuvoicesframe
            else                 parent = lastvoiceframe
            end

            voiceid  =  (voiceid + 1)

            print(string.format("__menus: self.menuid=%s, voiceid=%s, parent=%s", self.menuid, voiceid, parent))
            v  =  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. voiceid, parent)
            v:SetFontSize(round(fs * .75))
            v:SetText(string.format("%s", tbl.title), true)
            v:SetLayer(3)
            if voiceid == 1 then
               v:SetPoint("TOPLEFT",   parent, "TOPLEFT")
               v:SetPoint("TOPRIGHT",  parent, "TOPRIGHT")
            else
               v:SetPoint("TOPLEFT",   parent, "BOTTOMLEFT",   0, self.borders.t)
               v:SetPoint("TOPRIGHT",  parent, "BOTTOMRIGHT",  0, self.borders.t)
            end

            if tbl.callback ~= nil and next(tbl.callback) then
               v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
                                                                  tbl.callback()
                                                               end,
                                                               "__menu: "..self.menuid.."_voice_"..voiceid .."_callback" )
            else
            v:EventAttach( Event.UI.Input.Mouse.Left.Click,    function()
                                                                  self.status[self.menuid][voiceid] = not self.status[self.menuid][voiceid]
                                                               end,
                                                               "__menu: "..self.menuid.."_voice_"..voiceid .."_status" )
            end

            if self.o.voices[self.menuid] == nil then self.o.voices[self.menuid] = {} end

            self.o.voices[self.menuid][voiceid] =  v
            lastvoiceframe                      =  v
         end
      end

      return self
   end


   function self.show() if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(true) end end
   function self.hide() if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(false) end end

   -- return the class instance
   return self
end
