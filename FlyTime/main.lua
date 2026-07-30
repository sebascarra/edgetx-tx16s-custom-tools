-- EdgeTX Active Throttle Flight Timer Widget
-- Save as: /WIDGETS/flttmr/main.lua

local function create(zone, options)
  return {
    zone = zone,
    activeSeconds = 0,
    lastTime = getTime(),
    shPressed = false
  }
end

local function update(widget, newOptions)
end

local function refresh(widget)
  local z = widget.zone
  local now = getTime() -- Returns time in 10ms ticks (100 ticks = 1 second)
  local dt = (now - widget.lastTime) / 100
  widget.lastTime = now

  -- Read inputs
  local sfVal = getValue("sf") or getValue("SF") or 0 -- > 0 when ARMED (Front)
  local shVal = getValue("sh") or getValue("SH") or 0 -- > 0 when pulled towards you

  -- Read throttle position across stick name variations and channels
  local rawThr = getValue("thr") or getValue("Thr") or getValue("THR") or getValue("ch3") or getValue("ch1") or -1024

  -- 1. Reset logic via SH (Momentary Pull)
  if shVal > 0 then
    if not widget.shPressed then
      widget.activeSeconds = 0
      widget.shPressed = true
    end
  else
    widget.shPressed = false
  end

  -- 2. Accumulate time only when ARMED AND Throttle is above minimum
  local isArmed = (sfVal > 0)
  local isThrottleActive = (rawThr > -950) -- Any stick movement above bottom deadband

  if isArmed and isThrottleActive then
    widget.activeSeconds = widget.activeSeconds + dt
  end

  -- Color Palette
  local headerColor = lcd.RGB(50, 50, 50)     -- Charcoal gray header
  local activeColor = lcd.RGB(0, 255, 0)      -- Green when active/running
  local idleColor   = lcd.RGB(50, 50, 50)

  -- Format time MM:SS
  local totalSecs = math.floor(widget.activeSeconds)
  local mins = math.floor(totalSecs / 60)
  local secs = totalSecs % 60
  local timeStr = string.format("%02d:%02d", mins, secs)

  -- Layout Parameters (Matching SwMap MIDSIZE styling)
  local fontFlag = MIDSIZE
  local fontOffset = 10
  local yPos = z.y + (z.h / 2) - fontOffset

  -- Draw Header Label (Left Aligned)
  lcd.setColor(CUSTOM_COLOR, headerColor)
  lcd.drawText(z.x + 10, yPos, "FLT TIME", fontFlag + CUSTOM_COLOR)

  -- Draw Timer Value (Right Aligned)
  if isArmed and isThrottleActive then
    lcd.setColor(CUSTOM_COLOR, activeColor)
  else
    lcd.setColor(CUSTOM_COLOR, idleColor)
  end

  lcd.drawText(z.x + z.w - 10, yPos, timeStr, RIGHT + fontFlag + CUSTOM_COLOR)
end

return {
  name = "FltTmr",
  options = {},
  create = create,
  update = update,
  refresh = refresh
}