local M = {}
M.setup = function(renderer, timeout)
  local debounce_timer = nil
  return {
    render = function(source, options, callback)
      if debounce_timer then
        debounce_timer:stop()
        debounce_timer:close()
      end
      debounce_timer = vim.uv.new_timer()
      debounce_timer:start(timeout, 0, function()
        debounce_timer:stop()
        debounce_timer:close()
        debounce_timer = nil
        renderer.render(source, options, callback)
      end)
    end
  }
end
return M
