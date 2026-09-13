-- EdgeTX Clean Flight Timer Display Widget
-- Save as: /WIDGETS/flttmr/main.lua

local function create(zone, options)
  return { zone = zone }
end

local function update(widget, newOptions)
end

local function refresh(widget)
  local z = widget.zone

  -- Read native Timer 1 value (returns elapsed seconds)
  local timerVal = model.getTimer(0)
  local totalSecs = timerVal and timerVal.value or 0

  -- Check if motor is armed and running to set display state
  local sfVal = getValue("sf") or 0
  local rawThr = getValue("thr") or -1024
  local isRunning = (sfVal > 0) and (rawThr > -950)

  -- Color Palette
  local headerColor = lcd.RGB(50, 50, 50)
  local activeColor = lcd.RGB(0, 255, 0)
  local idleColor   = lcd.RGB(50, 50, 50)

  -- Format time MM:SS
  local mins = math.floor(totalSecs / 60)
  local secs = totalSecs % 60
  local timeStr = string.format("%02d:%02d", mins, secs)

  -- Layout Parameters
  local fontFlag = MIDSIZE
  local fontOffset = 10
  local yPos = z.y + (z.h / 2) - fontOffset

  -- Draw Header (Left Aligned)
  lcd.setColor(CUSTOM_COLOR, headerColor)
  lcd.drawText(z.x + 8, yPos, "FLT TIME (SH)", fontFlag + CUSTOM_COLOR)

  -- Draw Timer Value (Right Aligned)
  lcd.setColor(CUSTOM_COLOR, isRunning and activeColor or idleColor)
  lcd.drawText(z.x + z.w - 8, yPos, timeStr, RIGHT + fontFlag + CUSTOM_COLOR)
end

return {
  name = "FltTmr",
  options = {},
  create = create,
  update = update,
  refresh = refresh
}