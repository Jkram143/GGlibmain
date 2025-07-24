local libmaincppMemory = require("utils.libmaincppmemory")

---@type FieldInfo
local FieldInfoApi = {


    ---@param self FieldInfo
    ---@return nil | string | number
    GetConstValue = function(self)
        if self.IsConst then
            local fieldIndex = getmetatable(self).fieldIndex
            local defaultValue = libmaincppMemory:GetDefaultValue(fieldIndex)
            if not defaultValue then
                defaultValue = libmaincpp.GlobalMetadataApi:GetDefaultFieldValue(fieldIndex)
                libmaincppMemory:SetDefaultValue(fieldIndex, defaultValue)
            elseif defaultValue == "nil" then
                return nil
            end
            return defaultValue
        end
        return nil
    end
}

return FieldInfoApi