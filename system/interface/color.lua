-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
-- https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
local addon, dank = ...

dank.interface.color = {
  red = '#c62828',
  dark_red = '#b71c1c',
  pink = '#F58CBA',
  dark_pink = '#880e4f',
  purple = '#6a1b9a',
  dark_purple = '#4a148c',
  indigo = '#283593',
  dark_indigo = '#1a237e',
  blue = '#1565c0',
  dark_blue = '#0d47a1',
  cyan = '#00838f',
  dark_cyan = '#006064',
  teal = '#00695c',
  dark_teal = '#004d40',
  green = '#2e7d32',
  dark_green = '#1b5e20',
  lime = '#9e9d24',
  dark_lime = '#827717',
  yellow = '#fdd835',
  dark_yellow = '#fbc02d',
  amber = '#ff8f00',
  dark_amber = '#ff6f00',
  orange = '#ef6c00',
  dark_orange = '#e65100',
  brown = '#4e342e',
  dark_brown = '#3e2723',
  grey = '#424242',
  dark_grey = '#212121',
  warrior_brown = '#C79C6E'
}

dank.interface.color_string = {
  red = '|cfff44336%s|r',
  purple = '|cff9c27b0%s|r',
  indigo = '|cff5c6bc0%s|r',
  blue = '|cff42a5f5%s|r',
  teal = '|cff26a69a%s|r',
  green = '|cff66bb6a%s|r',
  yellow = '|cffffee58%s|r',
  orange = '|cffffa726%s|r',
  engine = '|cff' .. dank.color .. '%s|r'
}

function dank.interface.colorize(color, str)
  if dank.interface.color_string[color] ~= nil then
    return string.format(dank.interface.color_string[color], str)
  else
    return string.format(dank.interface.color_string['engine'], str)
  end
end

function dank.interface.color.ratio(color, ratio)
  local r, g, b = dank.interface.color.hexToRgb(color)
  local h, s, l, a = dank.interface.color.rgbToHsl(r, g, b, 1)
  r, g, b = dank.interface.color.hslToRgb(h, s, l * ratio, 1)
  return dank.interface.color.rgbToHex({r  * 255, g * 255, b * 255})
end

function dank.interface.color.hexToRgb(hex)
    hex = hex:gsub('#','')
    return tonumber('0x'..hex:sub(1,2)) / 255,
           tonumber('0x'..hex:sub(3,4)) / 255,
           tonumber('0x'..hex:sub(5,6)) / 255
end

function dank.interface.color.rgbToHex(rgb)
  local hexadecimal = '#'
  for key = 1, #rgb do
    local value = rgb[key]
    local hex = ''
    while(value > 0)do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub('0123456789ABCDEF', index, index) .. hex
    end
    if(string.len(hex) == 0)then
      hex = '00'
    elseif(string.len(hex) == 1)then
      hex = '0' .. hex
    end
    hexadecimal = hexadecimal .. hex
  end
  return hexadecimal
end

function dank.interface.color.rgbToHsl(r, g, b, a)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l, a or 1
end

function dank.interface.color.hue2rgb(p, q, t)
  if t < 0   then t = t + 1 end
  if t > 1   then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

function dank.interface.color.hslToRgb(h, s, l, a)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = dank.interface.color.hue2rgb(p, q, h + 1/3)
    g = dank.interface.color.hue2rgb(p, q, h)
    b = dank.interface.color.hue2rgb(p, q, h - 1/3)
  end

  return r, g, b, a
end

function dank.interface.color.rgbToHsv(r, g, b, a)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, v, a
end

function dank.interface.color.hsvToRgb(h, s, v, a)
  local r, g, b

  local i = Math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r, g, b, a
end
