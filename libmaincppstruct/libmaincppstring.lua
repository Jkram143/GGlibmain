---@class StringApi
---@field address number
---@field pointToStr number
---@field Fields table<string, number>
---@field ClassAddress number
local StringApi = {

    ---@param self StringApi
    ---@param newStr string
    EditString = function(self, newStr)
        local _stringLength = gg.getValues{{address = self.address + self.Fields._stringLength, flags = gg.TYPE_DWORD}}[1].value
        _stringLength = _stringLength * 2
        local bytes = gg.bytes(newStr, "UTF-16LE")
        if _stringLength == #bytes then
            local strStart = self.address + self.Fields._firstChar
            for i, v in ipairs(bytes) do
                bytes[i] = {
                    address = strStart + (i - 1),
                    flags = gg.TYPE_BYTE,
                    value = v
                }
            end

            gg.setValues(bytes)
        elseif _stringLength > #bytes then
            local strStart = self.address + self.Fields._firstChar
            local _bytes = {}
            for i = 1, _stringLength do
                _bytes[#_bytes + 1] = {
                    address = strStart + (i - 1),
                    flags = gg.TYPE_BYTE,
                    value = bytes[i] or 0
                }
            end

            gg.setValues(_bytes)
        elseif _stringLength < #bytes then
            self.address = libmaincpp.MemoryManager.MAlloc(self.Fields._firstChar + #bytes + 8)
            local length = #bytes % 2 == 1 and #bytes + 1 or #bytes
            local _bytes = {
                { -- Head
                    address = self.address,
                    flags = libmaincpp.MainType,
                    value = self.ClassAddress
                },
                { -- _stringLength
                    address = self.address + self.Fields._stringLength,
                    flags = gg.TYPE_DWORD,
                    value = length / 2
                }
            }
            local strStart = self.address + self.Fields._firstChar
            for i = 1, length do
                _bytes[#_bytes + 1] = {
                    address = strStart + (i - 1),
                    flags = gg.TYPE_BYTE,
                    value = bytes[i] or 0
                }                
            end
            _bytes[#_bytes + 1] = {
                address = self.pointToStr,
                flags = libmaincpp.MainType,
                value = self.address
            }
            gg.setValues(_bytes)
        end
    end,



    ---@param self StringApi
    ---@return string
    ReadString = function(self)
        local _stringLength = gg.getValues{{address = self.address + self.Fields._stringLength, flags = gg.TYPE_DWORD}}[1].value
        local bytes = {}
        if _stringLength > 0 and _stringLength < 200 then
            local strStart = self.address + self.Fields._firstChar
            for i = 0, _stringLength do
                bytes[#bytes + 1] = {
                    address = strStart + (i << 1),
                    flags = gg.TYPE_WORD
                }
            end
            bytes = gg.getValues(bytes)
            local code = {[[return "]]}
            for i, v in ipairs(bytes) do
                code[#code + 1] = string.format([[\u{%x}]], v.value & 0xFFFF)
            end
            code[#code + 1] = '"'
            local read, err = load(table.concat(code))
            if read then
                return read()
            end
        end
        return ""
    end
}

---@class MyString
---@field From fun(address : number) : StringApi | nil
local String = {

    ---@param address number
    ---@return StringApi | nil
    From = function(address)
        local pointToStr = gg.getValues({{address = libmaincpp.FixValue(address), flags = libmaincpp.MainType}})[1]
        local str = setmetatable(
            {
                address = libmaincpp.FixValue(pointToStr.value), 
                Fields = {},
                pointToStr = libmaincpp.FixValue(address)
            }, {__index = StringApi})
        local pointClassAddress = gg.getValues({{address = str.address, flags = libmaincpp.MainType}})[1].value
        local stringInfo = libmaincpp.FindClass({{Class = libmaincpp.FixValue(pointClassAddress), FieldsDump = true}})[1]
        for i, v in ipairs(stringInfo) do
            if v.ClassNameSpace == "System" then
                str.ClassAddress = tonumber(v.ClassAddress, 16)
                for indexField, FieldInfo in ipairs(v.Fields) do
                    str.Fields[FieldInfo.FieldName] = tonumber(FieldInfo.Offset, 16)
                end
                return str
            end
        end
        return nil
    end,
    
}

return String