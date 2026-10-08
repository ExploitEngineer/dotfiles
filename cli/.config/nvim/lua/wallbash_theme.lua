-- Recolors core highlight groups from HyDE's active wallbash palette
-- (~/.cache/hyde/wall.dcol), the same source kitty/cava/waybar read, so
-- nvim's theme always matches whichever HyDE theme is active.
local M = {}

local function read_dcol(path)
  local colors = {}
  local f = io.open(path, "r")
  if not f then
    return colors
  end
  for line in f:lines() do
    local key, val = line:match [[^(dcol_%w+)="(%x%x%x%x%x%x)"$]]
    if key and val then
      colors[key] = "#" .. val
    end
  end
  f:close()
  return colors
end

function M.apply()
  local cache = os.getenv "HYDE_CACHE_HOME" or (os.getenv "HOME" .. "/.cache/hyde")
  local c = read_dcol(cache .. "/wall.dcol")
  if not c.dcol_pry1 then
    return
  end

  local bg = c.dcol_pry1
  local fg = c.dcol_txt1
  local bg2 = c.dcol_2xa2 or bg
  local subtle = c.dcol_1xa3 or bg2
  local muted = c.dcol_1xa5 or fg
  local accent1 = c.dcol_pry2 or fg
  local accent2 = c.dcol_pry3 or fg
  local accent3 = c.dcol_pry4 or fg

  local set = vim.api.nvim_set_hl
  set(0, "Normal", { fg = fg, bg = bg })
  set(0, "NormalFloat", { fg = fg, bg = bg2 })
  set(0, "NormalNC", { fg = fg, bg = bg })
  set(0, "Comment", { fg = muted, italic = true })
  set(0, "String", { fg = accent2 })
  set(0, "Number", { fg = accent3 })
  set(0, "Constant", { fg = accent3 })
  set(0, "Function", { fg = accent1, bold = true })
  set(0, "Identifier", { fg = fg })
  set(0, "Keyword", { fg = accent1, bold = true })
  set(0, "Statement", { fg = accent1 })
  set(0, "PreProc", { fg = accent2 })
  set(0, "Type", { fg = accent2 })
  set(0, "Special", { fg = accent3 })
  set(0, "Title", { fg = accent1, bold = true })
  set(0, "CursorLine", { bg = subtle })
  set(0, "CursorLineNr", { fg = accent1, bold = true })
  set(0, "LineNr", { fg = muted })
  set(0, "Visual", { bg = subtle })
  set(0, "Pmenu", { fg = fg, bg = bg2 })
  set(0, "PmenuSel", { fg = bg, bg = accent1 })
  set(0, "StatusLine", { fg = fg, bg = bg2 })
  set(0, "WinSeparator", { fg = subtle, bg = bg })
  set(0, "MatchParen", { fg = bg, bg = accent1, bold = true })
  set(0, "NonText", { fg = subtle })
  set(0, "EndOfBuffer", { fg = bg })
end

return M
