local Errors = require "kong.dao.errors"

return {
  no_consumer = false, -- this plugin is available on APIs as well as on Consumers,
  fields = {
    -- Describe your plugin's configuration's schema here.
    pattern = {type = "string", required = true},
    upstream = {type = "string", required = true}
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    -- perform any custom verification
    local pattern = plugin_t.pattern
    if #pattern == 0 then
      return false, Errors.schema("pattern must not be null")
    end

    if pattern:sub(1, 1) ~= '^' then
      return false, Errors.schema("pattern must start with ^")
    end

    local upstream = plugin_t.upstream
    if #upstream == 0 then
      return false, Errors.schema("upstream must not be null")
    end

    return true
  end,
}
