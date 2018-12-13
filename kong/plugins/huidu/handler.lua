-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")


-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

-- load the base plugin object and create a subclass
local plugin = require("kong.plugins.base_plugin"):extend()

-- constructor
function plugin:new()
  plugin.super.new(self, plugin_name)
  
  -- do initialization here, runs in the 'init_by_lua_block', before worker processes are forked

end

---[[ runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)
  plugin.super.access(self)

  -- your custom code here
  local pattern = plugin_conf.pattern
  local token = kong.request.get_header("authorization")
  if token == nil then
    return 
  end
  -- 忽略大小写
  local matched = ngx.re.match(token, pattern, "joi")
  if matched then
    -- 设置upstream
    local ok, err = kong.service.set_upstream(plugin_conf.upstream)
    if not ok then
        kong.log.err(err)
        return
    end
    -- 匹配成功添加特定头部方便监控
    ngx.req.set_header("X-Kong-" .. plugin_name .. "-upstream", plugin_conf.upstream)
    ngx.req.set_header("X-Kong-" .. plugin_name .. "-pattern", plugin_conf.pattern)
  end    
  
end --]]

-- set the plugin priority, which determines plugin execution order
plugin.PRIORITY = 1000

-- return our plugin object
return plugin
