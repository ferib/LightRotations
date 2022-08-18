local addon, dank = ...

dank.commands = {
  commands = { }
}

function dank.commands.register(command)
  if type(command.command) == 'table' then
    for _, command_key in ipairs(command.command) do
      dank.commands.commands[command_key] = command
    end
  else
    dank.commands.commands[command.command] = command
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
  return string.format('|cff%s/dr %s|r |cff%s%s|r %s', dank.color2, command_key, dank.color3, arguments, command.text)
end

local function handle_command(msg, editbox)
  local _, _, command, _arguments = string.find(msg, "%s?(%w+)%s?(.*)")
  local arguments = { }

  if not _arguments then
    dank.log('Build ' .. dank.version)
    dank.log('Type /dr help for a list of known commands.')
    return
  end

  for argument in string.gmatch(_arguments, "%S+") do
    table.insert(arguments, argument)
  end

  command = dank.commands.commands[command]
  if command then
    result = command.callback(unpack(arguments))
    if not result then
      dank.log('Command Usage:')
      dank.log(format_help(command))
    end
  else
    dank.log('Command not found, type /dr help for a list of known commands.')
  end
end

dank.on_ready(function()
  dank.commands.register({
    command = 'help',
    arguments = { },
    text = 'Display the list of known commands',
    callback = function(rotation_name)
      dank.log('Known commands:')
      local printed = { }
      for _, command in pairs(dank.commands.commands) do
        if not printed[tostring(command)] then
          dank.log(format_help(command))
          printed[tostring(command)] = true
        end
      end
      return true
    end
  })

  dank.commands.register({
    command = 'load',
    arguments = {
      'rotation_name'
    },
    text = 'Loads the specified rotation',
    callback = function(rotation_name)
      dank.settings.store('netload_rotation_release', nil)
      dank.rotation.load(rotation_name)
      return true
    end
  })

  dank.commands.register({
    command = 'list',
    arguments = { },
    text = 'List available rotations',
    callback = function()
      dank.log('Available Rotations:')
      for name, rotation in pairs(dank.rotation.rotation_store) do
        dank.log(rotation.label and rotation.name .. ' - ' .. rotation.label or rotation.name)
      end
      return true
    end
  })

  dank.commands.register({
    command = 'debug',
    arguments = {
      'debug_level',
    },
    text = 'Enable the debug console at the specified debug level',
    callback = function(debug_level)
      if tonumber(debug_level) then
        dank.console.set_level(debug_level)
        if tonumber(debug_level) > 0 then
          dank.console.toggle(true)
        else
          dank.console.toggle(false)
        end
        return true
      else
        return false
      end
    end
  })

  dank.commands.register({
    command = 'toggle',
    arguments = {
      'button_name',
    },
    text = 'Toggles the on/off state for the specified button',
    callback = function(button_name)
      if button_name and dank.interface.buttons.buttons[button_name] then
        dank.interface.buttons.buttons[button_name]:callback()
        return true
      end
      return false
    end
  })

  dank.commands.register({
    command = 'econf',
    arguments = { },
    text = 'Shows the core engine config window.',
    callback = function(button_name)
      if dank.econf.parent:IsShown() then
        dank.econf.parent:Hide()
      else
        dank.econf.parent:Show()
      end
      return true
    end
  })

  -- TODO: remove this?
  dank.commands.register({
    command = 'drnum',
    arguments = { },
    text = 'Display your DR#.',
    callback = function(button_name)
      --if dank.adv_protected then
      --  dank.log("Your DR# is "..string.gsub(ReadMemory(GetModuleAddress()+GetOffset("s_accountName"), "string"), '#',''))
      --elseif dank.luabox then
      --  dank.log("Your DR# is "..string.gsub(__LB__.GetGameAccountName(),'#',''))
      --else
        dank.log("DR# is not supported in this build!")
      --end
      return true
    end
  })
end)

SLASH_DANKROTATIONS1, SLASH_DANKROTATIONS2 = '/dank', '/dr'
SlashCmdList["DANKROTATIONS"] = handle_command
