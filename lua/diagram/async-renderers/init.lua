local debounce = require('diagram/renderers/debounce-renderer')
local mermaid = require("diagram/renderers/mermaid")
-- local plantuml = require("diagram/renderers/plantuml")
-- local d2 = require("diagram/renderers/d2")

return {
  mermaid = debounce.setup(mermaid, 1000),
  --  plantuml = plantuml,
  -- d2 = d2,
}
