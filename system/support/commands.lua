local addon, light = ...

light.commands = {
  commands = { }
}

function light.commands.register(command)
  if type(command.command) == 'table' then
    for _, command_key in ipairs(command.command) do
      light.commands.commands[command_key] = command
    end
  else
    light.commands.commands[command.command] = command
  end
end

local function format_help(command)
  local arguments = table.concat(command.arguments, ', ')
  local command_key
  if type(command.command) == 'table' then
    command_key = table.concat(command.command, '||')
  else
    command_key = command.command
  end
  return string.format('|cff%s/dr %s|r |cff%s%s|r %s', light.color2, command_key, light.color3, arguments, command.text)
end

local function handle_command(msg, editbox)
  local _, _, command, _arguments = string.find(msg, "%s?(%w+)%s?(.*)")
  local arguments = { }

  if not _arguments then
    light.log('Build ' .. light.version)
    light.log('Type /dr help for a list of known commands.')
    return
  end

  for argument in string.gmatch(_arguments, "%S+") do
    table.insert(arguments, argument)
  end

  command = light.commands.commands[command]
  if command then
    result = command.callback(unpack(arguments))
    if not result then
      light.log('Command Usage:')
      light.log(format_help(command))
    end
  else
    light.log('Command not found, type /dr help for a list of known commands.')
  end
end

light.on_ready(function()
  light.commands.register({
    command = 'help',
    arguments = { },
    text = 'Display the list of known commands',
    callback = function(rotation_name)
      light.log('Known commands:')
      local printed = { }
      for _, command in pairs(light.commands.commands) do
        if not printed[tostring(command)] then
          light.log(format_help(command))
          printed[tostring(command)] = true
        end
      end
      return true
    end
  })

  light.commands.register({
    command = 'load',
    arguments = {
      'rotation_name'
    },
    text = 'Loads the specified rotation',
    callback = function(rotation_name)
      light.settings.store('netload_rotation_release', nil)
      light.rotation.load(rotation_name)
      return true
    end
  })

  light.commands.register({
    command = 'list',
    arguments = { },
    text = 'List available rotations',
    callback = function()
      light.log('Available Rotations:')
      for name, rotation in pairs(light.rotation.rotation_store) do
        light.log(rotation.label and rotation.name .. ' - ' .. rotation.label or rotation.name)
      end
      return true
    end
  })

  light.commands.register({
    command = 'debug',
    arguments = {
      'debug_level',
    },
    text = 'Enable the debug console at the specified debug level',
    callback = function(debug_level)
      if tonumber(debug_level) then
        light.console.set_level(debug_level)
        if tonumber(debug_level) > 0 then
          light.console.toggle(true)
        else
          light.console.toggle(false)
        end
        return true
      else
        return false
      end
    end
  })

  light.commands.register({
    command = 'toggle',
    arguments = {
      'button_name',
    },
    text = 'Toggles the on/off state for the specified button',
    callback = function(button_name)
      if button_name and light.interface.buttons.buttons[button_name] then
        light.interface.buttons.buttons[button_name]:callback()
        return true
      end
      return false
    end
  })

  light.commands.register({
    command = 'econf',
    arguments = { },
    text = 'Shows the core engine config window.',
    callback = function(button_name)
      if light.econf.parent:IsShown() then
        light.econf.parent:Hide()
      else
        light.econf.parent:Show()
      end
      return true
    end
  })

  -- TODO: remove this?
  light.commands.register({
    command = 'drnum',
    arguments = { },
    text = 'Display your DR#.',
    callback = function(button_name)
      --if light.adv_protected then
      --  light.log("Your DR# is "..string.gsub(ReadMemory(GetModuleAddress()+GetOffset("s_accountName"), "string"), '#',''))
      --elseif light.luabox then
      --  light.log("Your DR# is "..string.gsub(__LB__.GetGameAccountName(),'#',''))
      --else
        light.log("DR# is not supported in this build!")
      --end
      return true
    end
  })
end)

SLASH_DANKROTATIONS1, SLASH_DANKROTATIONS2 = '/light', '/dr'
SlashCmdList["DANKROTATIONS"] = handle_command
