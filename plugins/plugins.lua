do


local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  -- If not found
  return false
end

local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

local function list_all_plugins(only_enabled)
  local text = ''
  local nsum = 0
  for k, v in pairs( plugins_names( )) do
    local status = '🔘'
    nsum = nsum+1
    nact = 0
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '☑️' 
      end
      nact = nact+1
    end
    if not only_enabled or status == 'âœ”' then

      v = string.match (v, "(.*)%.lua")
      text = text..nsum..'. '..v..'  '..status..'\n'
    end
  end
  local text = text..'\nاین '..nsum..' نصب شده است.\n'..nact..' پلاگین های فعال و '..nsum-nact..' غیر فعال'
  return text
end

local function list_plugins(only_enabled)
  local text = ''
  local nsum = 0
  for k, v in pairs( plugins_names( )) do
    --  ☑️ enabled, 🔘 disabled
    local status = '🔘'
    nsum = nsum+1
    nact = 0
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '☑️' 
      end
      nact = nact+1
    end
    if not only_enabled or status == '☑️' then

      v = string.match (v, "(.*)%.lua")
      text = text..v..'  '..status..'\n'
    end
  end
  local text = text..'\n'..nact..' پلاگین های فعال '..nsum..' پلاگین ها نصب شده است.'
  return text
end

local function reload_plugins( )
  plugins = {}
  load_plugins()
  return list_plugins(true)
end


local function enable_plugin( plugin_name )
  print('checking if '..plugin_name..' exists')

  if plugin_enabled(plugin_name) then
    return 'Plugin '..plugin_name..' is enabled'
  end

  if plugin_exists(plugin_name) then

    table.insert(_config.enabled_plugins, plugin_name)
    print(plugin_name..' added to _config table')
    save_config()

    return reload_plugins( )
  else
    return 'پلاگین '..plugin_name..'وجود ندارد'
  end
end

local function disable_plugin( name, chat )

  if not plugin_exists(name) then
    return 'پلاگین '..name..' وجود ندارد'
  end
  local k = plugin_enabled(name)

  if not k then
    return 'پلاگین '..name..' فعال نیست'
  end

  table.remove(_config.enabled_plugins, k)
  save_config( )
  return reload_plugins(true)    
end

local function disable_plugin_on_chat(receiver, plugin)
  if not plugin_exists(plugin) then
    return "پلاگین فعال نیست"
  end

  if not _config.disabled_plugin_on_chat then
    _config.disabled_plugin_on_chat = {}
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    _config.disabled_plugin_on_chat[receiver] = {}
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = true

  save_config()
  return 'تمام!'
end

local function reenable_plugin_on_chat(receiver, plugin)
  if not _config.disabled_plugin_on_chat then
    return 'هیچ پلاگین غیر فعالی وجود ندارد'
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    return 'هیچ پلاگینی برای این گروه غیر فعال نیست'
  end

  if not _config.disabled_plugin_on_chat[receiver][plugin] then
    return 'این پلاگین غیر فعال نیست'
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = false
  save_config()
  return 'پلاگین '..plugin..' دوباره فعال شد'
end

local function run(msg, matches)

  if matches[1] == 'pl' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    return list_all_plugins()
  end


  if matches[1] == '+' and matches[3] == 'chat' and is_owner(msg) then
    local receiver = get_receiver(msg)
    local plugin = matches[2]
    print("enable "..plugin..' on this chat')
    return reenable_plugin_on_chat(receiver, plugin)
  end


  if matches[1] == '+' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    local plugin_name = matches[2]
    print("enable: "..matches[2])
    return enable_plugin(plugin_name)
  end


  if matches[1] == '--' and matches[3] == 'chat' and is_owner(msg) then
    local plugin = matches[2]
    local receiver = get_receiver(msg)
    print("disable "..plugin..' on this chat')
    return disable_plugin_on_chat(receiver, plugin)
  end

  if matches[1] == '-' and is_sudo(msg) then
    if matches[2] == 'plugins' then
     return 'این امکان وجود ندارد'
    end
    print("disable: "..matches[2])
    return disable_plugin(matches[2])
  end


  if matches[1] == '*' and is_sudo(msg) then
    return reload_plugins(true)
  end
end

return {
  description = "Plugin to manage other plugins. Enable, disable or reload.", 
  usage = {
      moderator = {
          "pl - [plugin] chat : disable plugin only this chat.",
          "pl + [plugin] chat : enable plugin only this chat.",
          },
      sudo = {
          "pl : list all plugins.",
          "pl + [plugin] : enable plugin.",
          "pl - [plugin] : disable plugin.",
          "pl reload : reloads all plugins." },
          },
  patterns = {
    "^پلاگین$",
    "^(پلاگین) (+) ([%w_%.%-]+)$",
    "^(پلاگین) (+) ([%w_%.%-]+) (فقط این گروه)",
    "^(پلاگین) (-) ([%w_%.%-]+)$",
    "^(پلاگین) (-) ([%w_%.%-]+) (فقط این گرو)",
    "^(پلاگین) (*)$" },
  run = run,
  moderated = true, 

}

end
