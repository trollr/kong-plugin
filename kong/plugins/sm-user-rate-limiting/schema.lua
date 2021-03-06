local Errors = require "kong.dao.errors"
local constants = require "kong.constants"

return {
  fields = {
    second = { type = "number" },
    minute = { type = "number" },
    hour = { type = "number" },
    day = { type = "number" },
    month = { type = "number" },
    year = { type = "number" },
    policy = { type = "string", enum = {"local"}, default = "local" },  -- currently, the only accepted policy is "local", but we can add other back in if needed
    fault_tolerant = { type = "boolean", default = true }
  },
  self_check = function(schema, plugin_t, dao, is_update)
    local ordered_periods = { "second", "minute", "hour", "day", "month", "year"}
    local has_value
    local invalid_order
    local invalid_value

    for i, v in ipairs(ordered_periods) do
      if plugin_t[v] then
        has_value = true
        if plugin_t[v] <=0 then
          invalid_value = "Value for "..v.." must be greater than zero"
        else
          for t = i+1, #ordered_periods do
            if plugin_t[ordered_periods[t]] and plugin_t[ordered_periods[t]] < plugin_t[v] then
              invalid_order = "The limit for "..ordered_periods[t].." cannot be lower than the limit for "..v
            end
          end
        end
      end
    end

    if not has_value then
      return false, Errors.schema("You need to set at least one limit: second, minute, hour, day, month, year", constants.DATABASE_ERROR_TYPES.SCHEMA)
    elseif invalid_value then
      return false, Errors.schema(invalid_value, constants.DATABASE_ERROR_TYPES.SCHEMA)
    elseif invalid_order then
      return false, Errors.schema(invalid_order, constants.DATABASE_ERROR_TYPES.SCHEMA)
    end

    return true
  end
}
