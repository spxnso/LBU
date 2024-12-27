local fs = {
    Files = {},
    WMapping = {"w", "w+", "a", "a+", "wb", "wb+", "ab", "ab+"}
}

function fs:openFile(path, mode)
    if self.Files[path] then return nil, "File is already opened" end

    local f, err = io.open(path, mode)
    if not f then return nil, err end

    self.Files[path] = {Instance = f, Mode = mode}
    return self.Files[path], f
end

function fs:closeFile(path)
    if type(path) == "string" then
        if not self.Files[path] then
            return nil, "No file instance is opened for this path"
        end

        local success, err = self.Files[path].Instance:close()
        if not success then return nil, err end

        self.Files[path] = nil
        return true
    else
        if not path.Instance then
            return nil, "The input is not a valid file instance"
        end

        local success, err = path.Instance:close()
        if not success then return nil, err end

        for k, v in pairs(self.Files) do if v == path then v = nil end end
        return true
    end
end

function fs:readFile(path)
    if type(path) == "string" then
        if not self.Files[path] then
            return nil, "No file instance is opened for this path"
        end

        local content, err = self.Files[path].Instance:read("*a")
        if not content then return nil, err end
        return content, self.Files[path].Instance
    else
        if not path.Instance then
            return nil, "The input is not a valid file instance"
        end

        local content, err = path.Instance:read("*a")
        if not content then return nil, err end
        return content, path.Instance
    end
end

function fs:writeToFile(path, content)
    if type(path) == "string" then
        if not self.Files[path] then
            return nil, "No file instance is opened for this path"
        end

        if not self:isWritableMode(self.Files[path].Mode) then
            return nil, "The file is not opened in a writable mode"
        end

        local success, err = self.Files[path].Instance:write(content)
        if not success then return nil, err end
        return true
    else
        if not path.Instance then
            return nil, "The input is not a valid file instance"
        end

        if not self:isWritableMode(path.Mode) then
            return nil, "The file is not opened in a writable mode"
        end

        local success, err = path.Instance:write(content)
        if not success then return nil, err end
        return true
    end
end

function fs:isWritableMode(mode)
    for _, wMode in ipairs(self.WMapping) do
        if mode == wMode then return true end
    end
    return false
end

return fs
