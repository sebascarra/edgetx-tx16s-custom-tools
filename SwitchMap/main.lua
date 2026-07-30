-- EdgeTX 3-Switch Interactive Map Widget (Clean Audio Callouts)
-- Save as: /WIDGETS/swmap/main.lua

local function create(zone, options)
  return {
    zone = zone,
    lastSf = nil,
    lastSc = nil,
    lastSd = nil
  }
end

local function update(widget, newOptions)
end

-- Helper function to play single or chained audio tracks
local function playTracks(tracks)
  if type(tracks) == "table" then
    for _, track in ipairs(tracks) do
      playFile(track)
    end
  else
    playFile(tracks)
  end
end

local function refresh(widget)
  local z = widget.zone

  -- Read raw switch positions (-1024 = AWAY/BACK, 0 = MID, 1024 = FRONT)
  local sfVal = getValue("sf")
  local scVal = getValue("sc")
  local sdVal = getValue("sd")

  -- Color Palette
  local dimColor    = lcd.RGB(50, 50, 50) -- Dark charcoal gray for unselected options
  local headerColor = lcd.RGB(50, 50, 50) -- Dark charcoal gray for switch headers
  local greenColor  = lcd.RGB(0, 255, 0)
  local redColor    = lcd.RGB(255, 60, 60)
  local cyanColor   = lcd.RGB(0, 200, 255)
  local amberColor  = lcd.RGB(255, 170, 0)

  -- Evaluate SF (Arm Switch)
  local sfActive = 2 -- Default DISARM (Away/Back)
  if sfVal > 0 then sfActive = 1 end -- Front = ARMED
  local sfOptions = {
    { text = "[ARMED]",  color = redColor,   sounds = "armed.wav" },
    { text = "[DISARM]", color = greenColor, sounds = "disarm.wav" }
  }

  -- Evaluate SC (Surface Rates - using Rate audio tracks)
  local scActive = 3 -- Default 60% (Away/Back)
  if scVal > 300 then scActive = 1        -- Front = 100%
  elseif scVal > -300 then scActive = 2   -- MID = 80%
  end
  local scOptions = {
    { text = "[100%]", color = amberColor, sounds = "rathi.wav" },
    { text = "[75%]",  color = cyanColor,  sounds = "ratmed.wav" },
    { text = "[50%]",  color = cyanColor,  sounds = "ratlow.wav" }
  }

  -- Evaluate SD (Throttle Rates - using High / Medium / Low audio tracks)
  local sdActive = 3 -- Default 50% (Away/Back)
  if sdVal > 300 then sdActive = 1        -- Front = 100%
  elseif sdVal > -300 then sdActive = 2   -- MID = 80%
  end
  local sdOptions = {
    { text = "[100%]", color = amberColor, sounds = "high.wav" },
    { text = "[75%]",  color = cyanColor,  sounds = "medium.wav" },
    { text = "[50%]",  color = cyanColor,  sounds = "low.wav" }
  }

  -- Audio Callouts Logic (Plays sound only on state changes)
  if widget.lastSf ~= nil and widget.lastSf ~= sfActive then
    playTracks(sfOptions[sfActive].sounds)
  end
  widget.lastSf = sfActive

  if widget.lastSc ~= nil and widget.lastSc ~= scActive then
    playTracks(scOptions[scActive].sounds)
  end
  widget.lastSc = scActive

  if widget.lastSd ~= nil and widget.lastSd ~= sdActive then
    playTracks(sdOptions[sdActive].sounds)
  end
  widget.lastSd = sdActive

  -- Master Layout
  local rows = {
    { name = "ARM (SF)",  active = sfActive, opts = sfOptions },
    { name = "SURF (SC)", active = scActive, opts = scOptions },
    { name = "THR (SD)",  active = sdActive, opts = sdOptions }
  }

  local fontFlag = MIDSIZE
  local fontOffset = 10
  local rowHeight = z.h / 3
  local optionGap = 16

  for i, row in ipairs(rows) do
    local yPos = z.y + ((i - 1) * rowHeight) + (rowHeight / 2) - fontOffset

    -- Draw Switch Label Header (Left Aligned)
    lcd.setColor(CUSTOM_COLOR, headerColor)
    lcd.drawText(z.x + 10, yPos, row.name, fontFlag + CUSTOM_COLOR)

    -- Draw Position Map (Right Aligned with proper spacing)
    local currentX = z.x + z.w - 10

    for optIdx = #row.opts, 1, -1 do
      local opt = row.opts[optIdx]
      local isSelected = (optIdx == row.active)

      if isSelected then
        lcd.setColor(CUSTOM_COLOR, opt.color)
      else
        lcd.setColor(CUSTOM_COLOR, dimColor)
      end

      -- Draw option text
      lcd.drawText(currentX, yPos, opt.text, RIGHT + fontFlag + CUSTOM_COLOR)

      -- Calculate actual rendered pixel width dynamically
      local textWidth, _ = lcd.sizeText(opt.text, fontFlag)
      currentX = currentX - textWidth - optionGap
    end
  end
end

return {
  name = "SwitchMap",
  options = {},
  create = create,
  update = update,
  refresh = refresh
}