local Protect = require("utils.protect")

---@class FieldApi
---@field Offset number
---@field Type number
---@field ClassOffset number
---@field Find fun(self : FieldApi, fieldSearchCondition : string | number) : FieldInfo[] | ErrorSearch
local FieldApi = {


    ---@param self FieldApi
    ---@param FieldInfoAddress number
    UnpackFieldInfo = function(self, FieldInfoAddress)
        return {
            { -- Field Name
                address = FieldInfoAddress,
                flags = libmaincpp.MainType
            }, 
            { -- Offset Field
                address = FieldInfoAddress + self.Offset,
                flags = gg.TYPE_WORD
            }, 
            { -- Field type
                address = FieldInfoAddress + self.Type,
                flags = libmaincpp.MainType
            }, 
            { -- Class address
                address = FieldInfoAddress + self.ClassOffset,
                flags = libmaincpp.MainType
            }
        }
    end,


    ---@param self FieldApi
    DecodeFieldsInfo = function(self, FieldsInfo, ClassCharacteristic)
        local index, _FieldsInfo = 0, {}
        local fieldStart = gg.getValues({{
            address = ClassCharacteristic.TypeMetadataHandle + libmaincpp.libmaincppTypeDefinitionApi.fieldStart,
            flags = gg.TYPE_DWORD
        }})[1].value
        for i = 1, #FieldsInfo, 4 do
            index = index + 1
            local TypeInfo = libmaincpp.FixValue(FieldsInfo[i + 2].value)
            local _TypeInfo = gg.getValues({
                { -- attrs
                    address = TypeInfo + self.Type,
                    flags = gg.TYPE_WORD
                }, 
                { -- type index | type
                    address = TypeInfo + libmaincpp.TypeApi.Type,
                    flags = gg.TYPE_BYTE
                }, 
                { -- index | data
                    address = TypeInfo,
                    flags = libmaincpp.MainType
                }
            })
            local attrs = _TypeInfo[1].value
            local IsConst = (attrs & libmaincppFlags.Field.FIELD_ATTRIBUTE_LITERAL) ~= 0
            _FieldsInfo[index] = setmetatable({
                ClassName = ClassCharacteristic.ClassName or libmaincpp.ClassApi:GetClassName(FieldsInfo[i + 3].value),
                ClassAddress = string.format('%X', libmaincpp.FixValue(FieldsInfo[i + 3].value)),
                FieldName = libmaincpp.Utf8ToString(libmaincpp.FixValue(FieldsInfo[i].value)),
                Offset = string.format('%X', FieldsInfo[i + 1].value),
                IsStatic = (not IsConst) and ((attrs & libmaincppFlags.Field.FIELD_ATTRIBUTE_STATIC) ~= 0),
                Type = libmaincpp.TypeApi:GetTypeName(_TypeInfo[2].value, _TypeInfo[3].value),
                IsConst = IsConst,
                Access = libmaincppFlags.Field.Access[attrs & libmaincppFlags.Field.FIELD_ATTRIBUTE_FIELD_ACCESS_MASK] or "",
            }, {
                __index = libmaincpp.FieldInfoApi,
                fieldIndex = fieldStart + index - 1
            })
        end
        return _FieldsInfo
    end,


    ---@param self FieldApi
    ---@param fieldName string
    ---@return FieldInfo[]
    FindFieldWithName = function(self, fieldName)
        local fieldNamePoint = libmaincpp.GlobalMetadataApi.GetPointersToString(fieldName)
        local ResultTable = {}
        for k, v in ipairs(fieldNamePoint) do
            local classAddress = gg.getValues({{
                address = v.address + self.ClassOffset,
                flags = libmaincpp.MainType
            }})[1].value
            if libmaincpp.ClassApi.IsClassInfo(classAddress) then
                local result = self.FindFieldInClass(fieldName, classAddress)
                table.move(result, 1, #result, #ResultTable + 1, ResultTable)
            end
        end
        assert(type(ResultTable) == "table" and #ResultTable > 0, string.format("The '%s' field is not initialized", fieldName))
        return ResultTable
    end,


    ---@param self FieldApi
    FindFieldWithAddress = function(self, fieldAddress)
        local ObjectHead = libmaincpp.ObjectApi.FindHead(fieldAddress)
        local fieldOffset = fieldAddress - ObjectHead.address
        local classAddress = libmaincpp.FixValue(ObjectHead.value)
        local ResultTable = self.FindFieldInClass(fieldOffset, classAddress)
        assert(#ResultTable > 0, string.format("nothing was found for this address 0x%X", fieldAddress))
        return ResultTable
    end,

    FindFieldInClass = function(fieldSearchCondition, classAddress)
        local ResultTable = {}
        local libmaincppClass = libmaincpp.FindClass({
            {
                Class = classAddress, 
                FieldsDump = true
            }
        })[1]
        for i, v in ipairs(libmaincppClass) do
            ResultTable[#ResultTable + 1] = type(fieldSearchCondition) == "number" 
                and v:GetFieldWithOffset(fieldSearchCondition)
                or v:GetFieldWithName(fieldSearchCondition)
        end
        return ResultTable
    end,


    FindTypeCheck = {
        ---@param self FieldApi
        ---@param fieldName string
        ['string'] = function(self, fieldName)
            return Protect:Call(self.FindFieldWithName, self, fieldName)
        end,
        ---@param self FieldApi
        ---@param fieldAddress number
        ['number'] = function(self, fieldAddress)
            return Protect:Call(self.FindFieldWithAddress, self, fieldAddress)
        end,
        ['default'] = function()
            return {
                Error = 'Invalid search criteria'
            }
        end
    },


    ---@param self FieldApi
    ---@param fieldSearchCondition number | string
    ---@return FieldInfo[] | ErrorSearch
    Find = function(self, fieldSearchCondition)
        local FieldsInfo = (self.FindTypeCheck[type(fieldSearchCondition)] or self.FindTypeCheck['default'])(self, fieldSearchCondition)
        return FieldsInfo
    end
}

return FieldApi
