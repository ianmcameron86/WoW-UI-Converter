-- WoW UI Converter probe. Read-only: it reports what this client can do and changes nothing.
-- /wucprobe        show the report in a copyable box
-- /wucprobe full   also dump every keybind and the whole layout string

local lines = {}

-- Called with no extra args the format string is used as-is, so layout strings
-- (which are full of % characters) can be added safely.
local function add(fmt, ...)
  if select('#', ...) > 0 then
    lines[#lines + 1] = fmt:format(...)
  else
    lines[#lines + 1] = fmt
  end
end

-- Describes a value without calling it.
local function kind(v)
  local t = type(v)
  if t == 'function' or t == 'table' or t == 'nil' then return t end
  return t .. ' (' .. tostring(v) .. ')'
end

-- issecurevariable takes either a global name or a table plus a key, and errors
-- on some inputs, so guard it both ways.
local function secure(tbl, key)
  local ok, isSecure, taintedBy
  if tbl == nil then
    ok, isSecure, taintedBy = pcall(issecurevariable, key)
  else
    ok, isSecure, taintedBy = pcall(issecurevariable, tbl, key)
  end
  if not ok then return '?' end
  if isSecure then return 'secure' end
  return 'TAINTED by ' .. tostring(taintedBy)
end

-- Some clients expose C_ namespaces as tables that cannot be iterated, so this
-- reports what it can rather than breaking the whole report.
local function sortedKeys(tbl)
  local keys = {}
  local ok = pcall(function()
    for k in pairs(tbl) do keys[#keys + 1] = tostring(k) end
  end)
  if not ok then return { '<not iterable in this client>' } end
  table.sort(keys)
  return keys
end

-- The functions we plan to use, listed so a missing one is obvious even when
-- the namespace itself exists.
local WANTED_EDITMODE = {
  'GetLayouts', 'ConvertLayoutInfoToString', 'ConvertStringToLayoutInfo',
  'SaveLayouts', 'SetActiveLayout', 'GetActiveLayout', 'GetAccountSettings',
  'OnLayoutAdded', 'OnEditModeExit',
}
local WANTED_MANAGER = {
  'GetActiveLayoutInfo', 'GetLayouts', 'SaveLayouts', 'ImportLayout',
  'SelectLayout', 'MakeNewLayout', 'HasActiveChanges',
}
local WANTED_GLOBALS = {
  'GetNumBindings', 'GetBinding', 'SetBinding', 'SaveBindings', 'LoadBindings',
  'GetCurrentBindingSet', 'GetBindingKey', 'GetBindingAction', 'SetBindingSpell',
  'InCombatLockdown', 'C_EditMode', 'C_KeyBindings', 'EditModeManagerFrame',
}

local function buildReport(full)
  wipe(lines)
  add('== WoW UI Converter probe 0.1 ==')

  local version, build, date, toc = GetBuildInfo()
  add('version=%s build=%s date=%s tocversion=%s',
    tostring(version), tostring(build), tostring(date), tostring(toc))
  add('locale=%s', GetLocale())
  add('WOW_PROJECT_ID=%s (MAINLINE=%s CLASSIC=%s CATA=%s MISTS=%s)',
    tostring(WOW_PROJECT_ID), tostring(WOW_PROJECT_MAINLINE), tostring(WOW_PROJECT_CLASSIC),
    tostring(WOW_PROJECT_CATACLYSM_CLASSIC), tostring(WOW_PROJECT_MISTS_CLASSIC))

  add('')
  add('-- globals --')
  for _, name in ipairs(WANTED_GLOBALS) do
    add('%-24s %s', name, kind(_G[name]))
  end

  add('')
  add('-- C_EditMode --')
  if type(C_EditMode) ~= 'table' then
    add('C_EditMode MISSING. No Edit Mode API in this client.')
  else
    for _, name in ipairs(WANTED_EDITMODE) do
      add('%-28s %-8s %s', name, kind(C_EditMode[name]), secure(C_EditMode, name))
    end
    add('all keys present: %s', table.concat(sortedKeys(C_EditMode), ', '))
  end

  add('')
  add('-- EditModeManagerFrame --')
  if type(EditModeManagerFrame) ~= 'table' then
    add('EditModeManagerFrame MISSING')
  else
    for _, name in ipairs(WANTED_MANAGER) do
      add('%-22s %-8s %s', name, kind(EditModeManagerFrame[name]), secure(EditModeManagerFrame, name))
    end
  end

  -- Read path. This only reads, and tells us whether the string format matches
  -- what src/layout.js already parses.
  add('')
  add('-- layout read test --')
  local layoutString
  if type(C_EditMode) == 'table' and type(C_EditMode.GetLayouts) == 'function' then
    local ok, layouts = pcall(C_EditMode.GetLayouts)
    if not ok then
      add('GetLayouts() ERROR: %s', tostring(layouts))
    else
      add('GetLayouts() returned %s', type(layouts))
      local list = type(layouts) == 'table' and (layouts.layouts or layouts) or nil
      if type(list) == 'table' then
        add('layout count=%d activeLayout=%s', #list, tostring(layouts.activeLayout))
        for i, info in ipairs(list) do
          if type(info) == 'table' then
            add('  [%d] name=%s layoutType=%s systems=%s', i, tostring(info.layoutName),
              tostring(info.layoutType), type(info.systems) == 'table' and tostring(#info.systems) or 'nil')
          end
        end
        local first = list[1]
        if type(first) == 'table' and type(C_EditMode.ConvertLayoutInfoToString) == 'function' then
          local ok2, str = pcall(C_EditMode.ConvertLayoutInfoToString, first)
          if ok2 and type(str) == 'string' then
            layoutString = str
            add('ConvertLayoutInfoToString OK, %d chars', #str)
            add('  first 120 chars below')
            add(str:sub(1, 120))
            if type(C_EditMode.ConvertStringToLayoutInfo) == 'function' then
              local ok3, back = pcall(C_EditMode.ConvertStringToLayoutInfo, str)
              add('ConvertStringToLayoutInfo round trip: ok=%s type=%s', tostring(ok3), type(back))
            end
          else
            add('ConvertLayoutInfoToString FAILED: %s', tostring(str))
          end
        end
      else
        add('could not find a layout list in the return value')
      end
    end
  else
    add('skipped, no C_EditMode.GetLayouts')
  end

  add('')
  add('-- layout write path --')
  add('NOTE: this probe never tries to save a layout. The functions above are reported only.')

  add('')
  add('-- keybinds --')
  if type(GetNumBindings) == 'function' then
    local n = GetNumBindings()
    add('GetNumBindings()=%d', n)
    add('GetCurrentBindingSet()=%s',
      type(GetCurrentBindingSet) == 'function' and tostring(GetCurrentBindingSet()) or 'n/a')
    add('SetBinding=%s  SaveBindings=%s', secure(nil, 'SetBinding'), secure(nil, 'SaveBindings'))
    local bound, sample = 0, {}
    for i = 1, n do
      local command, _, key1 = GetBinding(i)
      if key1 then
        bound = bound + 1
        if #sample < 8 then sample[#sample + 1] = tostring(command) .. '=' .. tostring(key1) end
      end
    end
    add('bindings with a key: %d of %d', bound, n)
    add('sample: %s', table.concat(sample, ', '))
  else
    add('GetNumBindings MISSING')
  end

  if full then
    add('')
    add('-- full keybind dump: command|category|key1|key2 --')
    if type(GetNumBindings) == 'function' then
      for i = 1, GetNumBindings() do
        local command, cat, key1, key2 = GetBinding(i)
        add(table.concat({
          tostring(command), tostring(cat), tostring(key1), tostring(key2),
        }, '|'))
      end
    end
    if layoutString then
      add('')
      add('-- full layout string --')
      add(layoutString)
    end
  end

  add('')
  add('== end ==')
  return table.concat(lines, '\n')
end

-- A copyable box. Built defensively so it works on Retail and Classic clients.
local frame
local function showReport(text)
  if not frame then
    frame = CreateFrame('Frame', 'WUCProbeFrame', UIParent,
      BackdropTemplateMixin and 'BackdropTemplate' or nil)
    frame:SetSize(700, 500)
    frame:SetPoint('CENTER')
    frame:SetFrameStrata('DIALOG')
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag('LeftButton')
    frame:SetScript('OnDragStart', frame.StartMoving)
    frame:SetScript('OnDragStop', frame.StopMovingOrSizing)
    if frame.SetBackdrop then
      frame:SetBackdrop({
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
      })
    end

    local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    title:SetPoint('TOP', 0, -16)
    title:SetText('WoW UI Converter probe: click the text, Ctrl+A, Ctrl+C')

    local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
    close:SetPoint('TOPRIGHT', -8, -8)

    local scroll = CreateFrame('ScrollFrame', 'WUCProbeScroll', frame, 'UIPanelScrollFrameTemplate')
    scroll:SetPoint('TOPLEFT', 18, -40)
    scroll:SetPoint('BOTTOMRIGHT', -34, 18)

    local edit = CreateFrame('EditBox', nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject('ChatFontNormal')
    edit:SetWidth(620)
    edit:SetScript('OnEscapePressed', function() frame:Hide() end)
    scroll:SetScrollChild(edit)
    frame.edit = edit
  end
  frame.edit:SetText(text)
  frame:Show()
end

SLASH_WUCPROBE1 = '/wucprobe'
SlashCmdList.WUCPROBE = function(msg)
  local full = (msg or ''):lower():find('full') ~= nil
  local text = buildReport(full)
  local version, build = GetBuildInfo()
  WoWUIConverterProbeDB = WoWUIConverterProbeDB or {}
  WoWUIConverterProbeDB[tostring(version) .. '-' .. tostring(build)] = text
  showReport(text)
  print('|cff00ff00WoW UI Converter probe|r: report shown. It is also saved to SavedVariables on logout.')
end

print('|cff00ff00WoW UI Converter probe|r loaded. Type /wucprobe (or /wucprobe full).')
