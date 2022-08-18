local addon, dank = ...

local ticker

ticker = C_Timer.NewTicker(0.1, function()
  if dank.settings_ready then
    for _, callback in pairs(dank.ready_callbacks) do
      callback()
    end
    ticker:Cancel()
  end
end)