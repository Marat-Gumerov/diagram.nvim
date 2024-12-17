---@type table<string, string>
local cache = {} -- session cache

---@class AsyncRenderer<MermaidOptions>
local M = {
    id = "mermaid-async",
}

-- fs cache
local tmpdir = vim.fn.resolve(vim.fn.stdpath("cache") .. "/diagram-cache/mermaid-async")
vim.fn.mkdir(tmpdir, "p")

---@param source string
---@param options MermaidOptions
---@param callback fun(path: string|nil)
M.render = function(source, options, callback)
    local hash = vim.fn.sha256(M.id .. ":" .. source)
    if cache[hash] then callback(cache[hash]) end

    local path = vim.fn.resolve(tmpdir .. "/" .. hash .. ".png")
    if vim.fn.filereadable(path) == 1 then callback(path) end

    if not vim.fn.executable("mmdc") then error("diagram/mermaid: mmdc not found in PATH") end

    local tmpsource = vim.fn.tempname()
    vim.fn.writefile(vim.split(source, "\n"), tmpsource)

    local command_parts = {
        "-i",
        tmpsource,
        "-o",
        path,
    }
    if options.background then
        table.insert(command_parts, "-b")
        table.insert(command_parts, options.background)
    end
    if options.theme then
        table.insert(command_parts, "-t")
        table.insert(command_parts, options.theme)
    end
    if options.scale then
        table.insert(command_parts, "-s")
        table.insert(command_parts, options.scale)
    end

    vim.uv.spawn("mmdc", {
        args = command_parts,
        stdio = {nil, nil, nil},
        detached = true,
    }, function(code, signal)
        if code ~= 0 then
            vim.notify("diagram/mermaid: mmdc failed to render diagram", vim.log.levels.ERROR)
            callback(nil)
            return
        end
        cache[hash] = path
        callback(path)
    end)
end
