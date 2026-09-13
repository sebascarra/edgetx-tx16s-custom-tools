-- EdgeTX Clean Switch State Widget
-- Save as: /WIDGETS/swmap/main.lua

local function create(zone, options)
  return { zone = zone }
end

local function update(widget, newOptions)
end

local function refresh(widget)
  local z = widget.zone

  -- Read raw positions (-1024 = UP, 0 = MID, 1024 = DOWN)
  local sfVal = getValue("sf")
  local scVal = getValue("sc")

  -- Color Palette
  local dimColor    = lcd.RGB(50, 50, 50)
  local headerColor = lcd.RGB(50, 50, 50)
  local greenColor  = lcd.RGB(0, 220, 0)
  local redColor    = lcd.RGB(255, 50, 50)
  local amberColor  = lcd.RGB(255, 170, 0)

  -- Evaluate SF (Arm / Throttle Cut)
  local sfActive = (sfVal > 0) and 1 or 2
  local sfOptions = {
    { text = "[ARM]",    color = redColor },
    { text = "[CUT]", color = greenColor }
  }

  -- Evaluate SC (High = down/towards you > 300, Low = mid or pushed back)
  local scActive = (scVal > 300) and 1 or 2
  local scOptions = {
    { text = "[HIGH]", color = amberColor },
    { text = "[LOW]",  color = greenColor }
  }

  local rows = {
    { name = "MOTOR (SF)", active = sfActive, opts = sfOptions },
    { name = "RATES (SC)", active = scActive, opts = scOptions }
  }

  local fontFlag = MIDSIZE
  local fontOffset = 10
  local rowHeight = z.h / #rows
  local optionGap = 14

  for i, row in ipairs(rows) do
    local yPos = z.y + ((i - 1) * rowHeight) + (rowHeight / 2) - fontOffset

    -- Header label
    lcd.setColor(CUSTOM_COLOR, headerColor)
    lcd.drawText(z.x + 8, yPos, row.name, fontFlag + CUSTOM_COLOR)

    -- Option flags
    local currentX = z.x + z.w - 8
    for optIdx = #row.opts, 1, -1 do
      local opt = row.opts[optIdx]
      local isSelected = (optIdx == row.active)

      lcd.setColor(CUSTOM_COLOR, isSelected and opt.color or dimColor)
      lcd.drawText(currentX, yPos, opt.text, RIGHT + fontFlag + CUSTOM_COLOR)

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