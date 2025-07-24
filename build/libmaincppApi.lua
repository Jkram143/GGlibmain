local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("GGlibmaincpp", function(require, _LOADED, __bundle_register, __bundle_modules)
require("utils.libmaincppconst")
require("libmaincpp")

---@class ClassInfoRaw
---@field ClassName string | nil
---@field ClassInfoAddress number
---@field ImageName string

---@class ClassInfo
---@field ClassName string
---@field ClassAddress string
---@field Methods MethodInfo[] | nil
---@field Fields FieldInfo[] | nil
---@field Parent ParentClassInfo | nil
---@field ClassNameSpace string
---@field StaticFieldData number | nil
---@field IsEnum boolean
---@field TypeMetadataHandle number
---@field InstanceSize number
---@field Token string
---@field ImageName string
---@field GetFieldWithName fun(self : ClassInfo, name : string) : FieldInfo | nil @Get FieldInfo by Field Name. If Fields weren't dumped, then this function return `nil`. Also, if Field isn't found by name, then function will return `nil`
---@field GetMethodsWithName fun(self : ClassInfo, name : string) : MethodInfo[] | nil @Get MethodInfo[] by MethodName. If Methods weren't dumped, then this function return `nil`. Also, if Method isn't found by name, then function will return `table with zero size`
---@field GetFieldWithOffset fun(self : ClassInfo, fieldOffset : number) : FieldInfo | nil

---@class ParentClassInfo
---@field ClassName string
---@field ClassAddress string

---@class FieldInfoRaw
---@field FieldInfoAddress number
---@field ClassName string | nil


---@class ClassMemory
---@field config ClassConfig
---@field result ClassInfo[] | ErrorSearch
---@field len number
---@field isNew boolean | nil

---@class MethodMemory
---@field len number
---@field result MethodInfo[] | ErrorSearch
---@field isNew boolean | nil

---@class FieldInfo
---@field ClassName string 
---@field ClassAddress string 
---@field FieldName string
---@field Offset string
---@field IsStatic boolean
---@field Type string
---@field IsConst boolean
---@field Access string
---@field GetConstValue fun(self : FieldInfo) : nil | string | number


---@class MethodInfoRaw
---@field MethodName string | nil
---@field Offset number | nil
---@field MethodInfoAddress number
---@field ClassName string | nil
---@field MethodAddress number


---@class ErrorSearch
---@field Error string


---@class MethodInfo
---@field MethodName string
---@field Offset string
---@field AddressInMemory string
---@field MethodInfoAddress number
---@field ClassName string
---@field ClassAddress string
---@field ParamCount number
---@field ReturnType string
---@field IsStatic boolean
---@field IsAbstract boolean
---@field Access string


---@class libmaincppApi
---@field FieldApiOffset number
---@field FieldApiType number
---@field FieldApiClassOffset number
---@field ClassApiNameOffset number
---@field ClassApiMethodsStep number
---@field ClassApiCountMethods number
---@field ClassApiMethodsLink number
---@field ClassApiFieldsLink number
---@field ClassApiFieldsStep number
---@field ClassApiCountFields number
---@field ClassApiParentOffset number
---@field ClassApiNameSpaceOffset number
---@field ClassApiStaticFieldDataOffset number
---@field ClassApiEnumType number
---@field ClassApiEnumRsh number
---@field ClassApiTypeMetadataHandle number
---@field ClassApiInstanceSize number
---@field ClassApiToken number
---@field MethodsApiClassOffset number
---@field MethodsApiNameOffset number
---@field MethodsApiParamCount number
---@field MethodsApiReturnType number
---@field MethodsApiFlags number
---@field typeDefinitionsSize number
---@field typeDefinitionsOffset number
---@field stringOffset number
---@field fieldDefaultValuesOffset number
---@field fieldDefaultValuesSize number
---@field fieldAndParameterDefaultValueDataOffset number
---@field TypeApiType number
---@field libmaincppTypeDefinitionApifieldStart number
---@field MetadataRegistrationApitypes number


---@class ClassConfig
---@field Class number | string @Class Name or Address Class
---@field FieldsDump boolean
---@field MethodsDump boolean


---@class libmaincppConfig
---@field libilcpp table | nil
---@field globalMetadata table | nil
---@field libmaincppVersion number | nil
---@field globalMetadataHeader number | nil
---@field metadataRegistration number | nil


---@class libmaincppTypeDefinitionApi
---@field fieldStart number

---@class MethodFlags
---@field Access string[]
---@field METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK number
---@field METHOD_ATTRIBUTE_STATIC number
---@field METHOD_ATTRIBUTE_ABSTRACT number


---@class FieldFlags
---@field Access string[]
---@field FIELD_ATTRIBUTE_FIELD_ACCESS_MASK number
---@field FIELD_ATTRIBUTE_STATIC number
---@field FIELD_ATTRIBUTE_LITERAL number


return libmaincpp
end)
__bundle_register("libmaincpp", function(require, _LOADED, __bundle_register, __bundle_modules)
local libmaincppMemory = require("utils.libmaincppmemory")
local VersionEngine = require("utils.version")
local AndroidInfo = require("utils.androidinfo")
local Searcher = require("utils.universalsearcher")
local PatchApi = require("utils.patchapi")



---@class libmaincpp
local libmaincppBase = {
    libmaincppStart = 0,
    libmaincppEnd = 0,
    globalMetadataStart = 0,
    globalMetadataEnd = 0,
    globalMetadataHeader = 0,
    MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    pointSize = AndroidInfo.platform and 8 or 4,
    ---@type libmaincppTypeDefinitionApi
    libmaincppTypeDefinitionApi = {},
    MetadataRegistrationApi = require("libmaincppstruct.metadataRegistration"),
    TypeApi = require("libmaincppstruct.type"),
    MethodsApi = require("libmaincppstruct.method"),
    GlobalMetadataApi = require("libmaincppstruct.globalmetadata"),
    FieldApi = require("libmaincppstruct.field"),
    ClassApi = require("libmaincppstruct.class"),
    ObjectApi = require("libmaincppstruct.object"),
    ClassInfoApi = require("libmaincppstruct.api.classinfo"),
    FieldInfoApi = require("libmaincppstruct.api.fieldinfo"),
    ---@type MyString
    String = require("libmaincppstruct.libmaincppstring"),
    MemoryManager = require("utils.malloc"),
    --- Patch `Bytescodes` to `add`
    ---
    --- Example:
    --- arm64: 
    --- `mov w0,#0x1`
    --- `ret`
    ---
    --- `libmaincpp.PatchesAddress(0x100, "\x20\x00\x80\x52\xc0\x03\x5f\xd6")`
    ---@param add number
    ---@param Bytescodes string
    ---@return Patch
    PatchesAddress = function(add, Bytescodes)
        local patchCode = {}
        for code in string.gmatch(Bytescodes, '.') do
            patchCode[#patchCode + 1] = {
                address = add + #patchCode,
                value = string.byte(code),
                flags = gg.TYPE_BYTE
            }
        end
        ---@type Patch
        local patch = PatchApi:Create(patchCode)
        patch:Patch()
        return patch
    end,


    --- Searches for a method, or rather information on the method, by name or by offset, you can also send an address in memory to it.
    --- 
    --- Return table with information about methods.
    ---@generic TypeForSearch : number | string
    ---@param searchParams TypeForSearch[] @TypeForSearch = number | string
    ---@return table<number, MethodInfo[] | ErrorSearch>
    FindMethods = function(searchParams)
        libmaincppMemory:SaveResults()
        for i = 1, #searchParams do
            ---@type number | string
            searchParams[i] = libmaincpp.MethodsApi:Find(searchParams[i])
        end
        libmaincppMemory:ClearSavedResults()
        return searchParams
    end,


    --- Searches for a class, by name, or by address in memory.
    --- 
    --- Return table with information about class.
    ---@param searchParams ClassConfig[]
    ---@return table<number, ClassInfo[] | ErrorSearch>
    FindClass = function(searchParams)
        libmaincppMemory:SaveResults()
        for i = 1, #searchParams do
            searchParams[i] = libmaincpp.ClassApi:Find(searchParams[i])
        end
        libmaincppMemory:ClearSavedResults()
        return searchParams
    end,


    --- Searches for an object by name or by class address, in memory.
    --- 
    --- In some cases, the function may return an incorrect result for certain classes. For example, sometimes the garbage collector may not have time to remove an object from memory and then a `fake object` will appear or for a turnover, the object may still be `not implemented` or `not created`.
    ---
    --- Returns a table of objects.
    ---@param searchParams table
    ---@return table
    FindObject = function(searchParams)
        libmaincppMemory:SaveResults()
        for i = 1, #searchParams do
            searchParams[i] = libmaincpp.ObjectApi:Find(libmaincpp.ClassApi:Find({Class = searchParams[i]}))
        end
        libmaincppMemory:ClearSavedResults()
        return searchParams
    end,


    --- Searches for a field, or rather information about the field, by name or by address in memory.
    --- 
    --- Return table with information about fields.
    ---@generic TypeForSearch : number | string
    ---@param searchParams TypeForSearch[] @TypeForSearch = number | string
    ---@return table<number, FieldInfo[] | ErrorSearch>
    FindFields = function(searchParams)
        libmaincppMemory:SaveResults()
        for i = 1, #searchParams do
            ---@type number | string
            local searchParam = searchParams[i]
            local searchResult = libmaincppMemory:GetInformationOfField(searchParam)
            if not searchResult then
                searchResult = libmaincpp.FieldApi:Find(searchParam)
                libmaincppMemory:SetInformationOfField(searchParam, searchResult)
            end
            searchParams[i] = searchResult
        end
        libmaincppMemory:ClearSavedResults()
        return searchParams
    end,


    ---@param Address number
    ---@param length? number
    ---@return string
    Utf8ToString = function(Address, length)
        local chars, char = {}, {
            address = Address,
            flags = gg.TYPE_BYTE
        }
        if not length then
            repeat
                _char = string.char(gg.getValues({char})[1].value & 0xFF)
                chars[#chars + 1] = _char
                char.address = char.address + 0x1
            until string.find(_char, "[%z%s]")
            return table.concat(chars, "", 1, #chars - 1)
        else
            for i = 1, length do
                local _char = gg.getValues({char})[1].value
                chars[i] = string.char(_char & 0xFF)
                char.address = char.address + 0x1
            end
            return table.concat(chars)
        end
    end,


    ---@param bytes string
    ChangeBytesOrder = function(bytes)
        local newBytes, index, lenBytes = {}, 0, #bytes / 2
        for byte in string.gmatch(bytes, "..") do
            newBytes[lenBytes - index] = byte
            index = index + 1
        end
        return table.concat(newBytes)
    end,


    FixValue = function(val)
        return AndroidInfo.platform and val & 0x00FFFFFFFFFFFFFF or val & 0xFFFFFFFF
    end,


    GetValidAddress = function(Address)
        local lastByte = Address & 0x000000000000000F
        local delta = 0
        local checkTable = {[12] = true, [4] = true, [8] = true, [0] = true}
        while not checkTable[lastByte - delta] do
            delta = delta + 1
        end
        return Address - delta
    end,


    ---@param self libmaincpp
    ---@param address number | string
    SearchPointer = function(self, address)
        address = self.ChangeBytesOrder(type(address) == 'number' and string.format('%X', address) or address)
        gg.searchNumber('h ' .. address)
        gg.refineNumber('h ' .. address:sub(1, 6))
        gg.refineNumber('h ' .. address:sub(1, 2))
        local FindsResult = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        return FindsResult
    end,
}

---@type libmaincpp
libmaincpp = setmetatable({}, {
    ---@param self libmaincpp
    ---@param config? libmaincppConfig
    __call = function(self, config)
        config = config or {}
        getmetatable(self).__index = libmaincppBase

        if config.libilcpp then
            self.libmaincppStart, self.libmaincppEnd = config.libilcpp.start, config.libilcpp['end']
        else
            self.libmaincppStart, self.libmaincppEnd = Searcher.Findlibmaincpp()
        end

        if config.globalMetadata then
            self.globalMetadataStart, self.globalMetadataEnd = config.globalMetadata.start, config.globalMetadata['end']
        else
            self.globalMetadataStart, self.globalMetadataEnd = Searcher:FindGlobalMetaData()
        end

        if config.globalMetadataHeader then
            self.globalMetadataHeader = config.globalMetadataHeader
        else
            self.globalMetadataHeader = self.globalMetadataStart
        end
        
        self.MetadataRegistrationApi.metadataRegistration = config.metadataRegistration

        VersionEngine:ChooseVersion(config.libmaincppVersion, self.globalMetadataHeader)

        libmaincppMemory:ClearMemorize()
    end,
    __index = function(self, key)
        assert(key == "PatchesAddress", "You didn't call 'libmaincpp'")
        return libmaincppBase[key]
    end
})

return libmaincpp
end)
__bundle_register("utils.malloc", function(require, _LOADED, __bundle_register, __bundle_modules)
local MemoryManager = {
    availableMemory = 0,
    lastAddress = 0,

    NewAlloc = function(self)
        self.lastAddress = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE)
        self.availableMemory = 4096
    end,
}

local M = {
    ---@param size number
    MAlloc = function(size)
        local manager = MemoryManager
        if size > manager.availableMemory then
            manager:NewAlloc()
        end
        local address = manager.lastAddress
        manager.availableMemory = manager.availableMemory - size
        manager.lastAddress = manager.lastAddress + size
        return address
    end,
}

return M
end)
__bundle_register("libmaincppstruct.libmaincppstring", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)
__bundle_register("libmaincppstruct.api.fieldinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)
__bundle_register("utils.libmaincppmemory", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Memorizing libmaincpp Search Result
---@class libmaincppMemory
---@field Methods table<number | string, MethodMemory>
---@field Classes table<string | number, ClassMemory>
---@field Fields table<number | string, FieldInfo[] | ErrorSearch>
---@field Results table
---@field Types table<number, string>
---@field DefaultValues table<number, string | number>
---@field GetInformaionOfMethod fun(self : libmaincppMemory, searchParam : number | string) : MethodMemory | nil
---@field SetInformaionOfMethod fun(self : libmaincppMemory, searchParam : string | number, searchResult : MethodMemory) : void
---@field GetInformationOfClass fun(self : libmaincppMemory, searchParam : string | number) : ClassMemory | nil
---@field SetInformationOfClass fun(self : libmaincppMemory, searchParam : string | number, searchResult : ClassMemory) : void
---@field GetInformationOfField fun(self : libmaincppMemory, searchParam : number | string) : FieldInfo[] | nil | ErrorSearch
---@field SetInformationOfField fun(self : libmaincppMemory, searchParam : string | number, searchResult : FieldInfo[] | ErrorSearch) : void
---@field GetInformationOfType fun(self : libmaincppMemory, index : number) : string | nil
---@field SetInformationOfType fun(self : libmaincppMemory, index : number, typeName : string)
---@field SaveResults fun(self : libmaincppMemory) : void
---@field ClearSavedResults fun(self : libmaincppMemory) : void
local libmaincppMemory = {
    Methods = {},
    Classes = {},
    Fields = {},
    DefaultValues = {},
    Results = {},
    Types = {},


    ---@param self libmaincppMemory
    ---@return nil | string
    GetInformationOfType = function(self, index)
        return self.Types[index]
    end,


    ---@param self libmaincppMemory
    SetInformationOfType = function(self, index, typeName)
        self.Types[index] = typeName
    end,

    ---@param self libmaincppMemory
    SaveResults = function(self)
        if gg.getResultsCount() > 0 then
            self.Results = gg.getResults(gg.getResultsCount())
        end
    end,


    ---@param self libmaincppMemory
    ClearSavedResults = function(self)
        self.Results = {}
    end,


    ---@param self libmaincppMemory
    ---@param fieldIndex number
    ---@return string | number | nil
    GetDefaultValue = function(self, fieldIndex)
        return self.DefaultValues[fieldIndex]
    end,


    ---@param self libmaincppMemory
    ---@param fieldIndex number
    ---@param defaultValue number | string | nil
    SetDefaultValue = function(self, fieldIndex, defaultValue)
        self.DefaultValues[fieldIndex] = defaultValue or "nil"
    end,


    ---@param self libmaincppMemory
    ---@param searchParam number | string
    ---@return FieldInfo[] | nil | ErrorSearch
    GetInformationOfField = function(self, searchParam)
        return self.Fields[searchParam]
    end,


    ---@param self libmaincppMemory
    ---@param searchParam number | string
    ---@param searchResult FieldInfo[] | ErrorSearch
    SetInformationOfField = function(self, searchParam, searchResult)
        if not searchResult.Error then
            self.Fields[searchParam] = searchResult
        end
    end,


    GetInformaionOfMethod = function(self, searchParam)
        return self.Methods[searchParam]
    end,


    SetInformaionOfMethod = function(self, searchParam, searchResult)
        if not searchResult.Error then
            self.Methods[searchParam] = searchResult
        end
    end,


    GetInformationOfClass = function(self, searchParam)
        return self.Classes[searchParam]
    end,


    SetInformationOfClass = function(self, searchParam, searchResult)
        self.Classes[searchParam] = searchResult
    end,


    ---@param self libmaincppMemory
    ---@return void
    ClearMemorize = function(self)
        self.Methods = {}
        self.Classes = {}
        self.Fields = {}
        self.DefaultValues = {}
        self.Results = {}
        self.Types = {}
    end
}

return libmaincppMemory

end)
__bundle_register("libmaincppstruct.api.classinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
local ClassInfoApi = {

    
    ---Get FieldInfo by Field Name. If Field isn't found by name, then function will return `nil`
    ---@param self ClassInfo
    ---@param name string
    ---@return FieldInfo | nil
    GetFieldWithName = function(self, name)
        local FieldsInfo = self.Fields
        if FieldsInfo then
            for fieldIndex = 1, #FieldsInfo do
                if FieldsInfo[fieldIndex].FieldName == name then
                    return FieldsInfo[fieldIndex]
                end
            end
        else
            local ClassAddress = tonumber(self.ClassAddress, 16)
            local _ClassInfo = gg.getValues({
                { -- Link as Fields
                    address = ClassAddress + libmaincpp.ClassApi.FieldsLink,
                    flags = libmaincpp.MainType
                },
                { -- Fields Count
                    address = ClassAddress + libmaincpp.ClassApi.CountFields,
                    flags = gg.TYPE_WORD
                }
            })
            self.Fields = libmaincpp.ClassApi:GetClassFields(libmaincpp.FixValue(_ClassInfo[1].value), _ClassInfo[2].value, {
                ClassName = self.ClassName,
                IsEnum = self.IsEnum,
                TypeMetadataHandle = self.TypeMetadataHandle
            })
            return self:GetFieldWithName(name)
        end
        return nil
    end,


    ---Get MethodInfo[] by MethodName. If Method isn't found by name, then function will return `table with zero size`
    ---@param self ClassInfo
    ---@param name string
    ---@return MethodInfo[]
    GetMethodsWithName = function(self, name)
        local MethodsInfo, MethodsInfoResult = self.Methods, {}
        if MethodsInfo then
            for methodIndex = 1, #MethodsInfo do
                if MethodsInfo[methodIndex].MethodName == name then
                    MethodsInfoResult[#MethodsInfoResult + 1] = MethodsInfo[methodIndex]
                end
            end
            return MethodsInfoResult
        else
            local ClassAddress = tonumber(self.ClassAddress, 16)
            local _ClassInfo = gg.getValues({
                { -- Link as Methods
                    address = ClassAddress + libmaincpp.ClassApi.MethodsLink,
                    flags = libmaincpp.MainType
                },
                { -- Methods Count
                    address = ClassAddress + libmaincpp.ClassApi.CountMethods,
                    flags = gg.TYPE_WORD
                }
            })
            self.Methods = libmaincpp.ClassApi:GetClassMethods(libmaincpp.FixValue(_ClassInfo[1].value), _ClassInfo[2].value,
                self.ClassName)
            return self:GetMethodsWithName(name)
        end
    end,


    ---@param self ClassInfo
    ---@param fieldOffset number
    ---@return nil | FieldInfo
    GetFieldWithOffset = function(self, fieldOffset)
        if not self.Fields then
            local ClassAddress = tonumber(self.ClassAddress, 16)
            local _ClassInfo = gg.getValues({
                { -- Link as Fields
                    address = ClassAddress + libmaincpp.ClassApi.FieldsLink,
                    flags = libmaincpp.MainType
                },
                { -- Fields Count
                    address = ClassAddress + libmaincpp.ClassApi.CountFields,
                    flags = gg.TYPE_WORD
                }
            })
            self.Fields = libmaincpp.ClassApi:GetClassFields(libmaincpp.FixValue(_ClassInfo[1].value), _ClassInfo[2].value, {
                ClassName = self.ClassName,
                IsEnum = self.IsEnum,
                TypeMetadataHandle = self.TypeMetadataHandle
            })
        end
        if #self.Fields > 0 then
            local klass = self
            while klass ~= nil do
                if klass.Fields and klass.InstanceSize >= fieldOffset then
                    local lastField
                    for indexField, field in ipairs(klass.Fields) do
                        if not (field.IsStatic or field.IsConst) then
                            local offset = tonumber(field.Offset, 16)
                            if offset > 0 then 
                                local maybeStruct = fieldOffset < offset

                                if indexField == 1 and maybeStruct then
                                    break
                                elseif offset == fieldOffset or indexField == #klass.Fields then
                                    return field
                                elseif maybeStruct then
                                    return lastField
                                else
                                    lastField = field
                                end
                            end
                        end
                    end
                end
                klass = klass.Parent ~= nil 
                    and libmaincpp.FindClass({
                        {
                            Class = tonumber(klass.Parent.ClassAddress, 16), 
                            FieldsDump = true
                        }
                    })[1][1] 
                    or nil
            end
        end
        return nil
    end
}

return ClassInfoApi
end)
__bundle_register("libmaincppstruct.object", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@class ObjectApi
local ObjectApi = {


    ---@param self ObjectApi
    ---@param Objects table
    FilterObjects = function(self, Objects)
        local FilterObjects = {}
        for k, v in ipairs(gg.getValuesRange(Objects)) do
            if v == 'A' then
                FilterObjects[#FilterObjects + 1] = Objects[k]
            end
        end
        Objects = FilterObjects
        gg.loadResults(Objects)
        gg.searchPointer(0)
        if gg.getResultsCount() <= 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            local FixRefToObjects = {}
            for k, v in ipairs(Objects) do
                gg.searchNumber(tostring(v.address | 0xB400000000000000), gg.TYPE_QWORD)
                ---@type tablelib
                local RefToObject = gg.getResults(gg.getResultsCount())
                table.move(RefToObject, 1, #RefToObject, #FixRefToObjects + 1, FixRefToObjects)
                gg.clearResults()
            end
            gg.loadResults(FixRefToObjects)
        end
        local RefToObjects, FilterObjects = gg.getResults(gg.getResultsCount()), {}
        gg.clearResults()
        for k, v in ipairs(gg.getValuesRange(RefToObjects)) do
            if v == 'A' then
                FilterObjects[#FilterObjects + 1] = {
                    address = libmaincpp.FixValue(RefToObjects[k].value),
                    flags = RefToObjects[k].flags
                }
            end
        end
        gg.loadResults(FilterObjects)
        local _FilterObjects = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        return _FilterObjects
    end,


    ---@param self ObjectApi
    ---@param ClassAddress string
    FindObjects = function(self, ClassAddress)
        gg.clearResults()
        gg.setRanges(0)
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_C_ALLOC)
        gg.loadResults({{
            address = tonumber(ClassAddress, 16),
            flags = libmaincpp.MainType
        }})
        gg.searchPointer(0)
        if gg.getResultsCount() <= 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(tonumber(ClassAddress, 16) | 0xB400000000000000), gg.TYPE_QWORD)
        end
        local FindsResult = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        return self:FilterObjects(FindsResult)
    end,

    
    ---@param self ObjectApi
    ---@param ClassesInfo ClassInfo[]
    Find = function(self, ClassesInfo)
        local Objects = {}
        for j = 1, #ClassesInfo do
            local FindResult = self:FindObjects(ClassesInfo[j].ClassAddress)
            table.move(FindResult, 1, #FindResult, #Objects + 1, Objects)
        end
        return Objects
    end,


    FindHead = function(Address)
        local validAddress = libmaincpp.GetValidAddress(Address)
        local mayBeHead = {}
        for i = 1, 1000 do
            mayBeHead[i] = {
                address = validAddress - (4 * (i - 1)),
                flags = libmaincpp.MainType
            } 
        end
        mayBeHead = gg.getValues(mayBeHead)
        for i = 1, #mayBeHead do
            local mayBeClass = libmaincpp.FixValue(mayBeHead[i].value)
            if libmaincpp.ClassApi.IsClassInfo(mayBeClass) then
                return mayBeHead[i]
            end
        end
        return {value = 0, address = 0}
    end,
}

return ObjectApi
end)
__bundle_register("utils.androidinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = {
    platform = gg.getTargetInfo().x64,
    sdk = gg.getTargetInfo().targetSdkVersion
}

return AndroidInfo
end)
__bundle_register("libmaincppstruct.class", function(require, _LOADED, __bundle_register, __bundle_modules)
local Protect = require("utils.protect")
local StringUtils = require("utils.stringutils")
local libmaincppMemory = require("utils.libmaincppmemory")

---@class ClassApi
---@field NameOffset number
---@field MethodsStep number
---@field CountMethods number
---@field MethodsLink number
---@field FieldsLink number
---@field FieldsStep number
---@field CountFields number
---@field ParentOffset number
---@field NameSpaceOffset number
---@field StaticFieldDataOffset number
---@field EnumType number
---@field EnumRsh number
---@field TypeMetadataHandle number
---@field InstanceSize number
---@field Token number
---@field GetClassName fun(self : ClassApi, ClassAddress : number) : string
---@field GetClassMethods fun(self : ClassApi, MethodsLink : number, Count : number, ClassName : string | nil) : MethodInfo[]
local ClassApi = {
    
    
    ---@param self ClassApi
    ---@param ClassAddress number
    GetClassName = function(self, ClassAddress)
        return libmaincpp.Utf8ToString(libmaincpp.FixValue(gg.getValues({{
            address = libmaincpp.FixValue(ClassAddress) + self.NameOffset,
            flags = libmaincpp.MainType
        }})[1].value))
    end,
    
    
    ---@param self ClassApi
    ---@param MethodsLink number
    ---@param Count number
    ---@param ClassName string | nil
    GetClassMethods = function(self, MethodsLink, Count, ClassName)
        local MethodsInfo, _MethodsInfo = {}, {}
        for i = 0, Count - 1 do
            _MethodsInfo[#_MethodsInfo + 1] = {
                address = MethodsLink + (i << self.MethodsStep),
                flags = libmaincpp.MainType
            }
        end
        _MethodsInfo = gg.getValues(_MethodsInfo)
        for i = 1, #_MethodsInfo do
            local MethodInfo
            MethodInfo, _MethodsInfo[i] = libmaincpp.MethodsApi:UnpackMethodInfo({
                MethodInfoAddress = libmaincpp.FixValue(_MethodsInfo[i].value),
                ClassName = ClassName
            })
            table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
        end
        MethodsInfo = gg.getValues(MethodsInfo)
        libmaincpp.MethodsApi:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)
        return _MethodsInfo
    end,


    GetClassFields = function(self, FieldsLink, Count, ClassCharacteristic)
        local FieldsInfo, _FieldsInfo = {}, {}
        for i = 0, Count - 1 do
            _FieldsInfo[#_FieldsInfo + 1] = {
                address = FieldsLink + (i * self.FieldsStep),
                flags = libmaincpp.MainType
            }
        end
        _FieldsInfo = gg.getValues(_FieldsInfo)
        for i = 1, #_FieldsInfo do
            local FieldInfo
            FieldInfo = libmaincpp.FieldApi:UnpackFieldInfo(libmaincpp.FixValue(_FieldsInfo[i].address))
            table.move(FieldInfo, 1, #FieldInfo, #FieldsInfo + 1, FieldsInfo)
        end
        FieldsInfo = gg.getValues(FieldsInfo)
        _FieldsInfo = libmaincpp.FieldApi:DecodeFieldsInfo(FieldsInfo, ClassCharacteristic)
        return _FieldsInfo
    end,


    ---@param self ClassApi
    ---@param ClassInfo ClassInfoRaw
    ---@param Config table
    ---@return ClassInfo
    UnpackClassInfo = function(self, ClassInfo, Config)
        local _ClassInfo = gg.getValues({
            { -- Class Name [1]
                address = ClassInfo.ClassInfoAddress + self.NameOffset,
                flags = libmaincpp.MainType
            },
            { -- Methods Count [2]
                address = ClassInfo.ClassInfoAddress + self.CountMethods,
                flags = gg.TYPE_WORD
            },
            { -- Fields Count [3]
                address = ClassInfo.ClassInfoAddress + self.CountFields,
                flags = gg.TYPE_WORD
            },
            { -- Link as Methods [4]
                address = ClassInfo.ClassInfoAddress + self.MethodsLink,
                flags = libmaincpp.MainType
            },
            { -- Link as Fields [5]
                address = ClassInfo.ClassInfoAddress + self.FieldsLink,
                flags = libmaincpp.MainType
            },
            { -- Link as Parent Class [6]
                address = ClassInfo.ClassInfoAddress + self.ParentOffset,
                flags = libmaincpp.MainType
            },
            { -- Class NameSpace [7]
                address = ClassInfo.ClassInfoAddress + self.NameSpaceOffset,
                flags = libmaincpp.MainType
            },
            { -- Class Static Field Data [8]
                address = ClassInfo.ClassInfoAddress + self.StaticFieldDataOffset,
                flags = libmaincpp.MainType
            },
            { -- EnumType [9]
                address = ClassInfo.ClassInfoAddress + self.EnumType,
                flags = gg.TYPE_BYTE
            },
            { -- TypeMetadataHandle [10]
                address = ClassInfo.ClassInfoAddress + self.TypeMetadataHandle,
                flags = libmaincpp.MainType
            },
            { -- InstanceSize [11]
                address = ClassInfo.ClassInfoAddress + self.InstanceSize,
                flags = gg.TYPE_DWORD
            },
            { -- Token [12]
                address = ClassInfo.ClassInfoAddress + self.Token,
                flags = gg.TYPE_DWORD
            }
        })
        local ClassName = ClassInfo.ClassName or libmaincpp.Utf8ToString(libmaincpp.FixValue(_ClassInfo[1].value))
        local ClassCharacteristic = {
            ClassName = ClassName,
            IsEnum = ((_ClassInfo[9].value >> self.EnumRsh) & 1) == 1,
            TypeMetadataHandle = libmaincpp.FixValue(_ClassInfo[10].value)
        }
        return setmetatable({
            ClassName = ClassName,
            ClassAddress = string.format('%X', libmaincpp.FixValue(ClassInfo.ClassInfoAddress)),
            Methods = (_ClassInfo[2].value > 0 and Config.MethodsDump) and
                self:GetClassMethods(libmaincpp.FixValue(_ClassInfo[4].value), _ClassInfo[2].value, ClassName) or nil,
            Fields = (_ClassInfo[3].value > 0 and Config.FieldsDump) and
                self:GetClassFields(libmaincpp.FixValue(_ClassInfo[5].value), _ClassInfo[3].value, ClassCharacteristic) or
                nil,
            Parent = _ClassInfo[6].value ~= 0 and {
                ClassAddress = string.format('%X', libmaincpp.FixValue(_ClassInfo[6].value)),
                ClassName = self:GetClassName(_ClassInfo[6].value)
            } or nil,
            ClassNameSpace = libmaincpp.Utf8ToString(libmaincpp.FixValue(_ClassInfo[7].value)),
            StaticFieldData = _ClassInfo[8].value ~= 0 and libmaincpp.FixValue(_ClassInfo[8].value) or nil,
            IsEnum = ClassCharacteristic.IsEnum,
            TypeMetadataHandle = ClassCharacteristic.TypeMetadataHandle,
            InstanceSize = _ClassInfo[11].value,
            Token = string.format("0x%X", _ClassInfo[12].value),
            ImageName = ClassInfo.ImageName
        }, {
            __index = libmaincpp.ClassInfoApi,
            __tostring = StringUtils.ClassInfoToDumpCS
        })
    end,

    --- Defines not quite accurately, especially in the 29th version of the backend
    ---@param Address number
    IsClassInfo = function(Address)
        local imageAddress = libmaincpp.FixValue(gg.getValues(
            {
                {
                    address = libmaincpp.FixValue(Address),
                    flags = libmaincpp.MainType
                }
            }
        )[1].value)
        local imageStr = libmaincpp.Utf8ToString(libmaincpp.FixValue(gg.getValues(
            {
                {
                    address = imageAddress,
                    flags = libmaincpp.MainType
                }
            }
        )[1].value))
        local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
        return check and imageStr or nil
    end,


    ---@param self ClassApi
    ---@param ClassName string
    ---@param searchResult ClassMemory
    FindClassWithName = function(self, ClassName, searchResult)
        local ClassNamePoint = libmaincpp.GlobalMetadataApi.GetPointersToString(ClassName)
        local ResultTable = {}
        if #ClassNamePoint > searchResult.len then
            for classPointIndex, classPoint in ipairs(ClassNamePoint) do
                local classAddress = classPoint.address - self.NameOffset
                local imageName = self.IsClassInfo(classAddress)
                if (imageName) then
                    ResultTable[#ResultTable + 1] = {
                        ClassInfoAddress = libmaincpp.FixValue(classAddress),
                        ClassName = ClassName,
                        ImageName = imageName
                    }
                end
            end
            searchResult.len = #ClassNamePoint
        else
            searchResult.isNew = false
        end
        assert(#ResultTable > 0, string.format("The '%s' class is not initialized", ClassName))
        return ResultTable
    end,


    ---@param self ClassApi
    ---@param ClassAddress number
    ---@param searchResult ClassMemory
    ---@return ClassInfoRaw[]
    FindClassWithAddressInMemory = function(self, ClassAddress, searchResult)
        local ResultTable = {}
        if searchResult.len < 1 then
            local imageName = self.IsClassInfo(ClassAddress)
            if imageName then
                ResultTable[#ResultTable + 1] = {
                    ClassInfoAddress = ClassAddress,
                    ImageName = imageName
                }
            end
            searchResult.len = 1
        else
            searchResult.isNew = false
        end
        assert(#ResultTable > 0, string.format("nothing was found for this address 0x%X", ClassAddress))
        return ResultTable
    end,


    FindParamsCheck = {
        ---@param self ClassApi
        ---@param _class number @Class Address In Memory
        ---@param searchResult ClassMemory
        ['number'] = function(self, _class, searchResult)
            return Protect:Call(self.FindClassWithAddressInMemory, self, _class, searchResult)
        end,
        ---@param self ClassApi
        ---@param _class string @Class Name
        ---@param searchResult ClassMemory
        ['string'] = function(self, _class, searchResult)
            return Protect:Call(self.FindClassWithName, self, _class, searchResult)
        end,
        ['default'] = function()
            return {
                Error = 'Invalid search criteria'
            }
        end
    },


    ---@param self ClassApi
    ---@param class ClassConfig
    ---@return ClassInfo[] | ErrorSearch
    Find = function(self, class)
        local searchResult = libmaincppMemory:GetInformationOfClass(class.Class)
        if (not searchResult) 
            or ((class.FieldsDump or class.MethodsDump)
                and (searchResult.config.FieldsDump ~= class.FieldsDump or searchResult.config.MethodsDump ~= class.MethodsDump))  
            then
            searchResult = {len = 0}
        end
        searchResult.isNew = true

        ---@type ClassInfoRaw[] | ErrorSearch
        local ClassInfo =
            (self.FindParamsCheck[type(class.Class)] or self.FindParamsCheck['default'])(self, class.Class, searchResult)
        if searchResult.isNew then
            for k = 1, #ClassInfo do
                ClassInfo[k] = self:UnpackClassInfo(ClassInfo[k], {
                    FieldsDump = class.FieldsDump,
                    MethodsDump = class.MethodsDump
                })
            end
            searchResult.config = {
                Class = class.Class,
                FieldsDump = class.FieldsDump,
                MethodsDump = class.MethodsDump
            }
            searchResult.result = ClassInfo
            libmaincppMemory:SetInformationOfClass(class.Class, searchResult)
        else
            ClassInfo = searchResult.result
        end
        return ClassInfo
    end
}

return ClassApi
end)
__bundle_register("utils.stringutils", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class StringUtils
local StringUtils = {

    ---@param classInfo ClassInfo
    ClassInfoToDumpCS = function(classInfo)
        local dumpClass = {
            "// ", classInfo.ImageName, "\n",
            "// Namespace: ", classInfo.ClassNameSpace, "\n";

            "class ", classInfo.ClassName, classInfo.Parent and " : " .. classInfo.Parent.ClassName or "", "\n", 
            "{\n"
        }

        if classInfo.Fields and #classInfo.Fields > 0 then
            dumpClass[#dumpClass + 1] = "\n\t// Fields\n"
            for i, v in ipairs(classInfo.Fields) do
                local dumpField = {
                    "\t", v.Access, " ", v.IsStatic and "static " or "", v.IsConst and "const " or "", v.Type, " ", v.FieldName, "; // 0x", v.Offset, "\n"
                }
                table.move(dumpField, 1, #dumpField, #dumpClass + 1, dumpClass)
            end
        end

        if classInfo.Methods and #classInfo.Methods > 0 then
            dumpClass[#dumpClass + 1] = "\n\t// Methods\n"
            for i, v in ipairs(classInfo.Methods) do
                local dumpMethod = {
                    i == 1 and "" or "\n",
                    "\t// Offset: 0x", v.Offset, " VA: 0x", v.AddressInMemory, " ParamCount: ", v.ParamCount, "\n",
                    "\t", v.Access, " ",  v.IsStatic and "static " or "", v.IsAbstract and "abstract " or "", v.ReturnType, " ", v.MethodName, "() { } \n"
                }
                table.move(dumpMethod, 1, #dumpMethod, #dumpClass + 1, dumpClass)
            end
        end
        
        table.insert(dumpClass, "\n}\n")
        return table.concat(dumpClass)
    end
}

return StringUtils
end)
__bundle_register("utils.protect", function(require, _LOADED, __bundle_register, __bundle_modules)
local Protect = {
    ErrorHandler = function(err)
        return {Error = err}
    end,
    Call = function(self, fun, ...) 
        return ({xpcall(fun, self.ErrorHandler, ...)})[2]
    end
}

return Protect
end)
__bundle_register("libmaincppstruct.field", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("libmaincppstruct.globalmetadata", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class GlobalMetadataApi
---@field typeDefinitionsSize number
---@field typeDefinitionsOffset number
---@field stringOffset number
---@field fieldDefaultValuesOffset number
---@field fieldDefaultValuesSize number
---@field fieldAndParameterDefaultValueDataOffset number
---@field version number
local GlobalMetadataApi = {


    ---@type table<number, fun(blob : number) : string | number>
    behaviorForTypes = {
        [2] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_BYTE)
        end,
        [3] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_BYTE)
        end,
        [4] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_BYTE)
        end,
        [5] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_BYTE)
        end,
        [6] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_WORD)
        end,
        [7] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_WORD)
        end,
        [8] = function(blob)
            local self = libmaincpp.GlobalMetadataApi
            return self.version < 29 and self.ReadNumberConst(blob, gg.TYPE_DWORD) or self.ReadCompressedInt32(blob)
        end,
        [9] = function(blob)
            local self = libmaincpp.GlobalMetadataApi
            return self.version < 29 and libmaincpp.FixValue(self.ReadNumberConst(blob, gg.TYPE_DWORD)) or self.ReadCompressedUInt32(blob)
        end,
        [10] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_QWORD)
        end,
        [11] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_QWORD)
        end,
        [12] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_FLOAT)
        end,
        [13] = function(blob)
            return libmaincpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_DOUBLE)
        end,
        [14] = function(blob)
            local self = libmaincpp.GlobalMetadataApi
            local length, offset = 0, 0
            if self.version >= 29 then
                length, offset = self.ReadCompressedInt32(blob)
            else
                length = self.ReadNumberConst(blob, gg.TYPE_DWORD) 
                offset = 4
            end

            if length ~= -1 then
                return libmaincpp.Utf8ToString(blob + offset, length)
            end
            return ""
        end
    },


    ---@param self GlobalMetadataApi
    ---@param index number
    GetStringFromIndex = function(self, index)
        local stringDefinitions = libmaincpp.globalMetadataStart + self.stringOffset
        return libmaincpp.Utf8ToString(stringDefinitions + index)
    end,


    ---@param self GlobalMetadataApi
    GetClassNameFromIndex = function(self, index)
        if (self.version < 27) then
            local typeDefinitions = libmaincpp.globalMetadataStart + self.typeDefinitionsOffset
            index = (self.typeDefinitionsSize * index) + typeDefinitions
        else
            index = libmaincpp.FixValue(index)
        end
        local typeDefinition = gg.getValues({{
            address = index,
            flags = gg.TYPE_DWORD
        }})[1].value
        return self:GetStringFromIndex(typeDefinition)
    end,


    ---@param self GlobalMetadataApi
    ---@param dataIndex number
    GetFieldOrParameterDefalutValue = function(self, dataIndex)
        return self.fieldAndParameterDefaultValueDataOffset + libmaincpp.globalMetadataStart + dataIndex
    end,


    ---@param self GlobalMetadataApi
    ---@param index string
    GetlibmaincppFieldDefaultValue = function(self, index)
        gg.clearResults()
        gg.setRanges(0)
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER | gg.REGION_C_ALLOC)
        gg.searchNumber(index, gg.TYPE_DWORD, false, gg.SIGN_EQUAL,
            libmaincpp.globalMetadataStart + self.fieldDefaultValuesOffset,
            libmaincpp.globalMetadataStart + self.fieldDefaultValuesOffset + self.fieldDefaultValuesSize)
        if gg.getResultsCount() > 0 then
            local libmaincppFieldDefaultValue = gg.getResults(1)
            gg.clearResults()
            return libmaincppFieldDefaultValue
        end
        return {}
    end,

    
    ---@param Address number
    ReadCompressedUInt32 = function(Address)
        local val, offset = 0, 0
        local read = gg.getValues({
            { -- [1]
                address = Address, 
                flags = gg.TYPE_BYTE
            },
            { -- [2]
                address = Address + 1, 
                flags = gg.TYPE_BYTE
            },
            { -- [3]
                address = Address + 2, 
                flags = gg.TYPE_BYTE
            },
            { -- [4]
                address = Address + 3, 
                flags = gg.TYPE_BYTE
            }
        })
        local read1 = read[1].value & 0xFF
        offset = 1
        if (read1 & 0x80) == 0 then
            val = read1
        elseif (read1 & 0xC0) == 0x80 then
            val = (read1 & ~0x80) << 8
            val = val | (read[2].value & 0xFF)
            offset = offset + 1
        elseif (read1 & 0xE0) == 0xC0 then
            val = (read1 & ~0xC0) << 24
            val = val | ((read[2].value & 0xFF) << 16)
            val = val | ((read[3].value & 0xFF) << 8)
            val = val | (read[4].value & 0xFF)
            offset = offset + 3
        elseif read1 == 0xF0 then
            val = gg.getValues({{address = Address + 1, flags = gg.TYPE_DWORD}})[1].value
            offset = offset + 4
        elseif read1 == 0xFE then
            val = 0xffffffff - 1
        elseif read1 == 0xFF then
            val = 0xffffffff
        end
        return val, offset
    end,


    ---@param Address number
    ReadCompressedInt32 = function(Address)
        local encoded, offset = libmaincpp.GlobalMetadataApi.ReadCompressedUInt32(Address)

        if encoded == 0xffffffff then
            return -2147483647 - 1
        end

        local isNegative = (encoded & 1) == 1
        encoded = encoded >> 1
        if isNegative then
            return -(encoded + 1)
        end
        return encoded, offset
    end,


    ---@param Address number
    ---@param ggType number @gg.TYPE_
    ReadNumberConst = function(Address, ggType)
        return gg.getValues({{
            address = Address,
            flags = ggType
        }})[1].value
    end,

    
    ---@param self GlobalMetadataApi
    ---@param index number
    ---@return number | string | nil
    GetDefaultFieldValue = function(self, index)
        local libmaincppFieldDefaultValue = self:GetlibmaincppFieldDefaultValue(tostring(index))
        if #libmaincppFieldDefaultValue > 0 then
            local _libmaincppFieldDefaultValue = gg.getValues({
                { -- TypeIndex [1]
                    address = libmaincppFieldDefaultValue[1].address + 4,
                    flags = gg.TYPE_DWORD,
                },
                { -- dataIndex [2]
                    address = libmaincppFieldDefaultValue[1].address + 8,
                    flags = gg.TYPE_DWORD
                }
            })
            local blob = self:GetFieldOrParameterDefalutValue(_libmaincppFieldDefaultValue[2].value)
            local libmaincppType = libmaincpp.MetadataRegistrationApi:GetlibmaincppTypeFromIndex(_libmaincppFieldDefaultValue[1].value)
            local typeEnum = libmaincpp.TypeApi:GetTypeEnum(libmaincppType)
            ---@type string | fun(blob : number) : string | number
            local behavior = self.behaviorForTypes[typeEnum] or "Not support type"
            if type(behavior) == "function" then
                return behavior(blob)
            end
            return behavior
        end
        return nil
    end,


    ---@param name string
    GetPointersToString = function(name)
        local pointers = {}
        gg.clearResults()
        gg.setRanges(0)
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER | gg.REGION_C_ALLOC)
        gg.searchNumber(string.format("Q 00 '%s' 00", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,
            libmaincpp.globalMetadataStart, libmaincpp.globalMetadataEnd)
        gg.searchPointer(0)
        pointers = gg.getResults(gg.getResultsCount())
        assert(type(pointers) == 'table' and #pointers > 0, string.format("this '%s' is not in the global-metadata", name))
        gg.clearResults()
        return pointers
    end
}

return GlobalMetadataApi
end)
__bundle_register("libmaincppstruct.method", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")
local Protect = require("utils.protect")
local libmaincppMemory = require("utils.libmaincppmemory")

---@class MethodsApi
---@field ClassOffset number
---@field NameOffset number
---@field ParamCount number
---@field ReturnType number
---@field Flags number
local MethodsApi = {


    ---@param self MethodsApi
    ---@param MethodName string
    ---@param searchResult MethodMemory
    ---@return MethodInfoRaw[]
    FindMethodWithName = function(self, MethodName, searchResult)
        local FinalMethods = {}
        local MethodNamePointers = libmaincpp.GlobalMetadataApi.GetPointersToString(MethodName)
        if searchResult.len < #MethodNamePointers then
            for methodPointIndex, methodPoint in ipairs(MethodNamePointers) do
                methodPoint.address = methodPoint.address - self.NameOffset
                local MethodAddress = libmaincpp.FixValue(gg.getValues({methodPoint})[1].value)
                if MethodAddress > libmaincpp.libmaincppStart and MethodAddress < libmaincpp.libmaincppEnd then
                    FinalMethods[#FinalMethods + 1] = {
                        MethodName = MethodName,
                        MethodAddress = MethodAddress,
                        MethodInfoAddress = methodPoint.address
                    }
                end
            end
        else
            searchResult.isNew = false
        end
        assert(#FinalMethods > 0, string.format("The '%s' method is not initialized", MethodName))
        return FinalMethods
    end,


    ---@param self MethodsApi
    ---@param MethodOffset number
    ---@param searchResult MethodMemory | nil
    ---@return MethodInfoRaw[]
    FindMethodWithOffset = function(self, MethodOffset, searchResult)
        local MethodsInfo = self:FindMethodWithAddressInMemory(libmaincpp.libmaincppStart + MethodOffset, searchResult, MethodOffset)
        return MethodsInfo
    end,


    ---@param self MethodsApi
    ---@param MethodAddress number
    ---@param searchResult MethodMemory
    ---@param MethodOffset number | nil
    ---@return MethodInfoRaw[]
    FindMethodWithAddressInMemory = function(self, MethodAddress, searchResult, MethodOffset)
        local RawMethodsInfo = {} -- the same as MethodsInfo
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER)
        if gg.BUILD < 16126 then
            gg.searchNumber(string.format("%Xh", MethodAddress), libmaincpp.MainType)
        else
            gg.loadResults({{
                address = MethodAddress,
                flags = libmaincpp.MainType
            }})
            gg.searchPointer(0)
        end
        local r_count = gg.getResultsCount()
        if r_count > searchResult.len then
            local r = gg.getResults(r_count)
            for j = 1, #r do
                RawMethodsInfo[#RawMethodsInfo + 1] = {
                    MethodAddress = MethodAddress,
                    MethodInfoAddress = r[j].address,
                    Offset = MethodOffset
                }
            end
        else
            searchResult.isNew = false
        end 
        gg.clearResults()
        assert(#RawMethodsInfo > 0, string.format("nothing was found for this address 0x%X", MethodAddress))
        return RawMethodsInfo
    end,


    ---@param self MethodsApi
    ---@param _MethodsInfo MethodInfo[]
    DecodeMethodsInfo = function(self, _MethodsInfo, MethodsInfo)
        for i = 1, #_MethodsInfo do
            local index = (i - 1) * 6
            local TypeInfo = libmaincpp.FixValue(MethodsInfo[index + 5].value)
            local _TypeInfo = gg.getValues({{ -- type index
                address = TypeInfo + libmaincpp.TypeApi.Type,
                flags = gg.TYPE_BYTE
            }, { -- index
                address = TypeInfo,
                flags = libmaincpp.MainType
            }})
            local MethodAddress = libmaincpp.FixValue(MethodsInfo[index + 1].value)
            local MethodFlags = MethodsInfo[index + 6].value

            _MethodsInfo[i] = {
                MethodName = _MethodsInfo[i].MethodName or
                    libmaincpp.Utf8ToString(libmaincpp.FixValue(MethodsInfo[index + 2].value)),
                Offset = string.format("%X", _MethodsInfo[i].Offset or (MethodAddress == 0 and MethodAddress or MethodAddress - libmaincpp.libmaincppStart)),
                AddressInMemory = string.format("%X", MethodAddress),
                MethodInfoAddress = _MethodsInfo[i].MethodInfoAddress,
                ClassName = _MethodsInfo[i].ClassName or libmaincpp.ClassApi:GetClassName(MethodsInfo[index + 3].value),
                ClassAddress = string.format('%X', libmaincpp.FixValue(MethodsInfo[index + 3].value)),
                ParamCount = MethodsInfo[index + 4].value,
                ReturnType = libmaincpp.TypeApi:GetTypeName(_TypeInfo[1].value, _TypeInfo[2].value),
                IsStatic = (MethodFlags & libmaincppFlags.Method.METHOD_ATTRIBUTE_STATIC) ~= 0,
                Access = libmaincppFlags.Method.Access[MethodFlags & libmaincppFlags.Method.METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK] or "",
                IsAbstract = (MethodFlags & libmaincppFlags.Method.METHOD_ATTRIBUTE_ABSTRACT) ~= 0,
            }
        end
    end,


    ---@param self MethodsApi
    ---@param MethodInfo MethodInfoRaw
    UnpackMethodInfo = function(self, MethodInfo)
        return {
            { -- [1] Address Method in Memory
                address = MethodInfo.MethodInfoAddress,
                flags = libmaincpp.MainType
            },
            { -- [2] Name Address
                address = MethodInfo.MethodInfoAddress + self.NameOffset,
                flags = libmaincpp.MainType
            },
            { -- [3] Class address
                address = MethodInfo.MethodInfoAddress + self.ClassOffset,
                flags = libmaincpp.MainType
            },
            { -- [4] Param Count
                address = MethodInfo.MethodInfoAddress + self.ParamCount,
                flags = gg.TYPE_BYTE
            },
            { -- [5] Return Type
                address = MethodInfo.MethodInfoAddress + self.ReturnType,
                flags = libmaincpp.MainType
            },
            { -- [6] Flags
                address = MethodInfo.MethodInfoAddress + self.Flags,
                flags = gg.TYPE_WORD
            }
        }, 
        {
            MethodName = MethodInfo.MethodName or nil,
            Offset = MethodInfo.Offset or nil,
            MethodInfoAddress = MethodInfo.MethodInfoAddress,
            ClassName = MethodInfo.ClassName
        }
    end,


    FindParamsCheck = {
        ---@param self MethodsApi
        ---@param method number
        ---@param searchResult MethodMemory
        ['number'] = function(self, method, searchResult)
            if (method > libmaincpp.libmaincppStart and method < libmaincpp.libmaincppEnd) then
                return Protect:Call(self.FindMethodWithAddressInMemory, self, method, searchResult)
            else
                return Protect:Call(self.FindMethodWithOffset, self, method, searchResult)
            end
        end,
        ---@param self MethodsApi
        ---@param method string
        ---@param searchResult MethodMemory
        ['string'] = function(self, method, searchResult)
            return Protect:Call(self.FindMethodWithName, self, method, searchResult)
        end,
        ['default'] = function()
            return {
                Error = 'Invalid search criteria'
            }
        end
    },


    ---@param self MethodsApi
    ---@param method number | string
    ---@return MethodInfo[] | ErrorSearch
    Find = function(self, method)
        local searchResult = libmaincppMemory:GetInformaionOfMethod(method)
        if not searchResult then
            searchResult = {len = 0}
        end
        searchResult.isNew = true

        ---@type MethodInfoRaw[] | ErrorSearch
        local _MethodsInfo = (self.FindParamsCheck[type(method)] or self.FindParamsCheck['default'])(self, method, searchResult)
        if searchResult.isNew then
            local MethodsInfo = {}
            for i = 1, #_MethodsInfo do
                local MethodInfo
                MethodInfo, _MethodsInfo[i] = self:UnpackMethodInfo(_MethodsInfo[i])
                table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
            end
            MethodsInfo = gg.getValues(MethodsInfo)
            self:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)

            -- save result
            searchResult.len = #_MethodsInfo
            searchResult.result = _MethodsInfo
            libmaincppMemory:SetInformaionOfMethod(method, searchResult)
        else
            _MethodsInfo = searchResult.result
        end

        return _MethodsInfo
    end
}

return MethodsApi
end)
__bundle_register("libmaincppstruct.type", function(require, _LOADED, __bundle_register, __bundle_modules)
local libmaincppMemory = require("utils.libmaincppmemory")

---@class TypeApi
---@field Type number
---@field tableTypes table
local TypeApi = {

    
    tableTypes = {
        [1] = "void",
        [2] = "bool",
        [3] = "char",
        [4] = "sbyte",
        [5] = "byte",
        [6] = "short",
        [7] = "ushort",
        [8] = "int",
        [9] = "uint",
        [10] = "long",
        [11] = "ulong",
        [12] = "float",
        [13] = "double",
        [14] = "string",
        [22] = "TypedReference",
        [24] = "IntPtr",
        [25] = "UIntPtr",
        [28] = "object",
        [17] = function(index)
            return libmaincpp.GlobalMetadataApi:GetClassNameFromIndex(index)
        end,
        [18] = function(index)
            return libmaincpp.GlobalMetadataApi:GetClassNameFromIndex(index)
        end,
        [29] = function(index)
            local typeMassiv = gg.getValues({
                {
                    address = libmaincpp.FixValue(index),
                    flags = libmaincpp.MainType
                },
                {
                    address = libmaincpp.FixValue(index) + libmaincpp.TypeApi.Type,
                    flags = gg.TYPE_BYTE
                }
            })
            return libmaincpp.TypeApi:GetTypeName(typeMassiv[2].value, typeMassiv[1].value) .. "[]"
        end,
        [21] = function(index)
            if not (libmaincpp.GlobalMetadataApi.version < 27) then
                index = gg.getValues({{
                    address = libmaincpp.FixValue(index),
                    flags = libmaincpp.MainType
                }})[1].value
            end
            index = gg.getValues({{
                address = libmaincpp.FixValue(index),
                flags = libmaincpp.MainType
            }})[1].value
            return libmaincpp.GlobalMetadataApi:GetClassNameFromIndex(index)
        end
    },


    ---@param self TypeApi
    ---@param typeIndex number @number for tableTypes
    ---@param index number @for an api that is higher than 24, this can be a reference to the index
    ---@return string
    GetTypeName = function(self, typeIndex, index)
        ---@type string | fun(index : number) : string
        local typeName = self.tableTypes[typeIndex] or string.format('(not support type -> 0x%X)', typeIndex)
        if (type(typeName) == 'function') then
            local resultType = libmaincppMemory:GetInformationOfType(index)
            if not resultType then
                resultType = typeName(index)
                libmaincppMemory:SetInformationOfType(index, resultType)
            end
            typeName = resultType
        end
        return typeName
    end,


    ---@param self TypeApi
    ---@param libmaincppType number
    GetTypeEnum = function(self, libmaincppType)
        return gg.getValues({{address = libmaincppType + self.Type, flags = gg.TYPE_BYTE}})[1].value
    end
}

return TypeApi
end)
__bundle_register("libmaincppstruct.metadataRegistration", function(require, _LOADED, __bundle_register, __bundle_modules)
local Searcher = require("utils.universalsearcher")

---@class MetadataRegistrationApi
---@field metadataRegistration number
---@field types number
local MetadataRegistrationApi = {


    ---@param self MetadataRegistrationApi
    ---@return number
    GetlibmaincppTypeFromIndex = function(self, index)
        if not self.metadataRegistration then
            self:FindMetadataRegistration()
        end
        local types = gg.getValues({{address = self.metadataRegistration + self.types, flags = libmaincpp.MainType}})[1].value
        return libmaincpp.FixValue(gg.getValues({{address = types + (libmaincpp.pointSize * index), flags = libmaincpp.MainType}})[1].value)
    end,


    ---@param self MetadataRegistrationApi
    ---@return void
    FindMetadataRegistration = function(self)
        self.metadataRegistration = Searcher.libmaincppMetadataRegistration()
    end
}

return MetadataRegistrationApi
end)
__bundle_register("utils.universalsearcher", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@class Searcher
local Searcher = {
    searchWord = ":EnsureCapacity",

    ---@param self Searcher
    FindGlobalMetaData = function(self)
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER)
        local globalMetadata = gg.getRangesList('global-metadata.dat')
        if not self:IsValidData(globalMetadata) then
            globalMetadata = {}
            gg.clearResults()
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE)
            gg.refineNumber(self.searchWord:sub(1, 2), gg.TYPE_BYTE)
            local EnsureCapacity = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for k, v in ipairs(gg.getRangesList()) do
                if (v.state == 'Ca' or v.state == 'A' or v.state == 'Cd' or v.state == 'Cb' or v.state == 'Ch' or
                    v.state == 'O') then
                    for key, val in ipairs(EnsureCapacity) do
                        globalMetadata[#globalMetadata + 1] =
                            (libmaincpp.FixValue(v.start) <= libmaincpp.FixValue(val.address) and libmaincpp.FixValue(val.address) <
                                libmaincpp.FixValue(v['end'])) and v or nil
                    end
                end
            end
        end
        return globalMetadata[1].start, globalMetadata[#globalMetadata]['end']
    end,

    ---@param self Searcher
    IsValidData = function(self, globalMetadata)
        if #globalMetadata ~= 0 then
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, globalMetadata[1].start,
                globalMetadata[#globalMetadata]['end'])
            if gg.getResultsCount() > 0 then
                gg.clearResults()
                return true
            end
        end
        return false
    end,

    Findlibmaincpp = function()
        local libmaincpp = gg.getRangesList('liblibmaincpp.so')
        if #libmaincpp == 0 then
            libmaincpp = gg.getRangesList('split_config.')
            local _libmaincpp = {}
            gg.setRanges(gg.REGION_CODE_APP)
            for k, v in ipairs(libmaincpp) do
                if (v.state == 'Xa') then
                    gg.searchNumber(':libmaincpp', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, v.start, v['end'])
                    if (gg.getResultsCount() > 0) then
                        _libmaincpp[#_libmaincpp + 1] = v
                        gg.clearResults()
                    end
                end
            end
            libmaincpp = _libmaincpp
        else
            local _libmaincpp = {}
            for k,v in ipairs(libmaincpp) do
                if (string.find(v.type, "..x.") or v.state == "Xa") then
                    _libmaincpp[#_libmaincpp + 1] = v
                end
            end
            libmaincpp = _libmaincpp
        end       
        return libmaincpp[1].start, libmaincpp[#libmaincpp]['end']
    end,

    libmaincppMetadataRegistration = function()
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER)
        gg.loadResults({{
            address = libmaincpp.globalMetadataStart,
            flags = libmaincpp.MainType
        }})
        gg.searchPointer(0)
        if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(libmaincpp.globalMetadataStart | 0xB400000000000000), libmaincpp.MainType)
        end
        if gg.getResultsCount() > 0 then
            local GlobalMetadataPointers, s_GlobalMetadata = gg.getResults(gg.getResultsCount()), 0
            for i = 1, #GlobalMetadataPointers do
                if i ~= 1 then
                    local difference = GlobalMetadataPointers[i].address - GlobalMetadataPointers[i - 1].address
                    if (difference == libmaincpp.pointSize) then
                        s_GlobalMetadata = libmaincpp.FixValue(gg.getValues({{
                            address = GlobalMetadataPointers[i].address - (AndroidInfo.platform and 0x10 or 0x8),
                            flags = libmaincpp.MainType
                        }})[1].value)
                    end
                end
            end
            return s_GlobalMetadata
        end
        return 0
    end
}

return Searcher

end)
__bundle_register("utils.patchapi", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Patch
---@field oldBytes table
---@field newBytes table
---@field Create fun(self : Patch, patchCode : table) : Patch
---@field Patch fun(self : Patch) : void
---@field Undo fun(self : Patch) : void
local PatchApi = {

    ---@param self Patch
    ---@param patchCode table
    Create = function(self, patchCode)
        return setmetatable({
            newBytes = patchCode,
            oldBytes = gg.getValues(patchCode)
        },
        {
            __index = self,
        })
    end,
    
    ---@param self Patch
    Patch = function(self)
        if self.newBytes then
            gg.setValues(self.newBytes)
        end 
    end,

    ---@param self Patch
    Undo = function(self)
        if self.oldBytes then
            gg.setValues(self.oldBytes)
        end
    end,
}

return PatchApi
end)
__bundle_register("utils.version", function(require, _LOADED, __bundle_register, __bundle_modules)
local semver = require("semver.semver")

---@class VersionEngine
local VersionEngine = {
    ConstSemVer = {
        ['2018_3'] = semver(2018, 3),
        ['2019_4_21'] = semver(2019, 4, 21),
        ['2019_4_15'] = semver(2019, 4, 15),
        ['2019_3_7'] = semver(2019, 3, 7),
        ['2020_2_4'] = semver(2020, 2, 4),
        ['2020_2'] = semver(2020, 2),
        ['2020_1_11'] = semver(2020, 1, 11),
        ['2021_2'] = semver(2021, 2)   
    },
    Year = {
        [2017] = function(self, unityVersion)
            return 24
        end,
        ---@param self VersionEngine
        [2018] = function(self, unityVersion)
            return (not (unityVersion < self.ConstSemVer['2018_3'])) and 24.1 or 24
        end,
        ---@param self VersionEngine
        [2019] = function(self, unityVersion)
            local version = 24.2
            if not (unityVersion < self.ConstSemVer['2019_4_21']) then
                version = 24.5
            elseif not (unityVersion < self.ConstSemVer['2019_4_15']) then
                version = 24.4
            elseif not (unityVersion < self.ConstSemVer['2019_3_7']) then
                version = 24.3
            end
            return version
        end,
        ---@param self VersionEngine
        [2020] = function(self, unityVersion)
            local version = 24.3
            if not (unityVersion < self.ConstSemVer['2020_2_4']) then
                version = 27.1
            elseif not (unityVersion < self.ConstSemVer['2020_2']) then
                version = 27
            elseif not (unityVersion < self.ConstSemVer['2020_1_11']) then
                version = 24.4
            end
            return version
        end,
        ---@param self VersionEngine
        [2021] = function(self, unityVersion)
            return (not (unityVersion < self.ConstSemVer['2021_2'])) and 29 or 27.2 
        end,
        [2022] = function(self, unityVersion)
            return 29
        end,
    },
    ---@return number
    GetUnityVersion = function()
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.clearResults()
        gg.searchNumber("00h;32h;30h;0~~0;0~~0;2Eh;0~~0;2Eh::9", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
        local result = gg.getResultsCount() > 0 and gg.getResults(3)[3].address or 0
        gg.clearResults()
        return result
    end,
    ReadUnityVersion = function(versionAddress)
        local verisonName = libmaincpp.Utf8ToString(versionAddress)
        return string.gmatch(verisonName, "(%d+)%p(%d+)%p(%d+)")()
    end,
    ---@param self VersionEngine
    ---@param version? number
    ChooseVersion = function(self, version, globalMetadataHeader)
        if not version then
            local unityVersionAddress = self.GetUnityVersion()
            if unityVersionAddress == 0 then
                version = gg.getValues({{address = globalMetadataHeader + 0x4, flags = gg.TYPE_DWORD}})[1].value
            else
                local p1, p2, p3 = self.ReadUnityVersion(unityVersionAddress)
                local unityVersion = semver(tonumber(p1), tonumber(p2), tonumber(p3))
                ---@type number | fun(self: VersionEngine, unityVersion: table): number
                version = self.Year[unityVersion.major] or 29
                if type(version) == 'function' then
                    version = version(self, unityVersion)
                end
            end
            
        end
        ---@type libmaincppApi
        local api = assert(libmaincppConst[version], 'Not support this libmaincpp version')
        libmaincpp.FieldApi.Offset = api.FieldApiOffset
        libmaincpp.FieldApi.Type = api.FieldApiType
        libmaincpp.FieldApi.ClassOffset = api.FieldApiClassOffset

        libmaincpp.ClassApi.NameOffset = api.ClassApiNameOffset
        libmaincpp.ClassApi.MethodsStep = api.ClassApiMethodsStep
        libmaincpp.ClassApi.CountMethods = api.ClassApiCountMethods
        libmaincpp.ClassApi.MethodsLink = api.ClassApiMethodsLink
        libmaincpp.ClassApi.FieldsLink = api.ClassApiFieldsLink
        libmaincpp.ClassApi.FieldsStep = api.ClassApiFieldsStep
        libmaincpp.ClassApi.CountFields = api.ClassApiCountFields
        libmaincpp.ClassApi.ParentOffset = api.ClassApiParentOffset
        libmaincpp.ClassApi.NameSpaceOffset = api.ClassApiNameSpaceOffset
        libmaincpp.ClassApi.StaticFieldDataOffset = api.ClassApiStaticFieldDataOffset
        libmaincpp.ClassApi.EnumType = api.ClassApiEnumType
        libmaincpp.ClassApi.EnumRsh = api.ClassApiEnumRsh
        libmaincpp.ClassApi.TypeMetadataHandle = api.ClassApiTypeMetadataHandle
        libmaincpp.ClassApi.InstanceSize = api.ClassApiInstanceSize
        libmaincpp.ClassApi.Token = api.ClassApiToken

        libmaincpp.MethodsApi.ClassOffset = api.MethodsApiClassOffset
        libmaincpp.MethodsApi.NameOffset = api.MethodsApiNameOffset
        libmaincpp.MethodsApi.ParamCount = api.MethodsApiParamCount
        libmaincpp.MethodsApi.ReturnType = api.MethodsApiReturnType
        libmaincpp.MethodsApi.Flags = api.MethodsApiFlags

        libmaincpp.GlobalMetadataApi.typeDefinitionsSize = api.typeDefinitionsSize
        libmaincpp.GlobalMetadataApi.version = version

        local consts = gg.getValues({
            { -- [1] 
                address = libmaincpp.globalMetadataHeader + api.typeDefinitionsOffset,
                flags = gg.TYPE_DWORD
            },
            { -- [2]
                address = libmaincpp.globalMetadataHeader + api.stringOffset,
                flags = gg.TYPE_DWORD,
            },
            { -- [3]
                address = libmaincpp.globalMetadataHeader + api.fieldDefaultValuesOffset,
                flags = gg.TYPE_DWORD,
            },
            { -- [4]
                address = libmaincpp.globalMetadataHeader + api.fieldDefaultValuesSize,
                flags = gg.TYPE_DWORD
            },
            { -- [5]
                address = libmaincpp.globalMetadataHeader + api.fieldAndParameterDefaultValueDataOffset,
                flags = gg.TYPE_DWORD
            }
        })
        libmaincpp.GlobalMetadataApi.typeDefinitionsOffset = consts[1].value
        libmaincpp.GlobalMetadataApi.stringOffset = consts[2].value
        libmaincpp.GlobalMetadataApi.fieldDefaultValuesOffset = consts[3].value
        libmaincpp.GlobalMetadataApi.fieldDefaultValuesSize = consts[4].value
        libmaincpp.GlobalMetadataApi.fieldAndParameterDefaultValueDataOffset = consts[5].value

        libmaincpp.TypeApi.Type = api.TypeApiType

        libmaincpp.libmaincppTypeDefinitionApi.fieldStart = api.libmaincppTypeDefinitionApifieldStart

        libmaincpp.MetadataRegistrationApi.types = api.MetadataRegistrationApitypes
    end,
}

return VersionEngine
end)
__bundle_register("semver.semver", function(require, _LOADED, __bundle_register, __bundle_modules)
local semver = {
  _VERSION     = '1.2.1',
  _DESCRIPTION = 'semver for Lua',
  _URL         = 'https://github.com/kikito/semver.lua',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2015 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of tother software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and tother permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local function checkPositiveInteger(number, name)
  assert(number >= 0, name .. ' must be a valid positive number')
  assert(math.floor(number) == number, name .. ' must be an integer')
end

local function present(value)
  return value and value ~= ''
end

-- splitByDot("a.bbc.d") == {"a", "bbc", "d"}
local function splitByDot(str)
  str = str or ""
  local t, count = {}, 0
  str:gsub("([^%.]+)", function(c)
    count = count + 1
    t[count] = c
  end)
  return t
end

local function parsePrereleaseAndBuildWithSign(str)
  local prereleaseWithSign, buildWithSign = str:match("^(-[^+]+)(+.+)$")
  if not (prereleaseWithSign and buildWithSign) then
    prereleaseWithSign = str:match("^(-.+)$")
    buildWithSign      = str:match("^(+.+)$")
  end
  assert(prereleaseWithSign or buildWithSign, ("The parameter %q must begin with + or - to denote a prerelease or a build"):format(str))
  return prereleaseWithSign, buildWithSign
end

local function parsePrerelease(prereleaseWithSign)
  if prereleaseWithSign then
    local prerelease = prereleaseWithSign:match("^-(%w[%.%w-]*)$")
    assert(prerelease, ("The prerelease %q is not a slash followed by alphanumerics, dots and slashes"):format(prereleaseWithSign))
    return prerelease
  end
end

local function parseBuild(buildWithSign)
  if buildWithSign then
    local build = buildWithSign:match("^%+(%w[%.%w-]*)$")
    assert(build, ("The build %q is not a + sign followed by alphanumerics, dots and slashes"):format(buildWithSign))
    return build
  end
end

local function parsePrereleaseAndBuild(str)
  if not present(str) then return nil, nil end

  local prereleaseWithSign, buildWithSign = parsePrereleaseAndBuildWithSign(str)

  local prerelease = parsePrerelease(prereleaseWithSign)
  local build = parseBuild(buildWithSign)

  return prerelease, build
end

local function parseVersion(str)
  local sMajor, sMinor, sPatch, sPrereleaseAndBuild = str:match("^(%d+)%.?(%d*)%.?(%d*)(.-)$")
  assert(type(sMajor) == 'string', ("Could not extract version number(s) from %q"):format(str))
  local major, minor, patch = tonumber(sMajor), tonumber(sMinor), tonumber(sPatch)
  local prerelease, build = parsePrereleaseAndBuild(sPrereleaseAndBuild)
  return major, minor, patch, prerelease, build
end


-- return 0 if a == b, -1 if a < b, and 1 if a > b
local function compare(a,b)
  return a == b and 0 or a < b and -1 or 1
end

local function compareIds(myId, otherId)
  if myId == otherId then return  0
  elseif not myId    then return -1
  elseif not otherId then return  1
  end

  local selfNumber, otherNumber = tonumber(myId), tonumber(otherId)

  if selfNumber and otherNumber then -- numerical comparison
    return compare(selfNumber, otherNumber)
  -- numericals are always smaller than alphanums
  elseif selfNumber then
    return -1
  elseif otherNumber then
    return 1
  else
    return compare(myId, otherId) -- alphanumerical comparison
  end
end

local function smallerIdList(myIds, otherIds)
  local myLength = #myIds
  local comparison

  for i=1, myLength do
    comparison = compareIds(myIds[i], otherIds[i])
    if comparison ~= 0 then
      return comparison == -1
    end
    -- if comparison == 0, continue loop
  end

  return myLength < #otherIds
end

local function smallerPrerelease(mine, other)
  if mine == other or not mine then return false
  elseif not other then return true
  end

  return smallerIdList(splitByDot(mine), splitByDot(other))
end

local methods = {}

function methods:nextMajor()
  return semver(self.major + 1, 0, 0)
end
function methods:nextMinor()
  return semver(self.major, self.minor + 1, 0)
end
function methods:nextPatch()
  return semver(self.major, self.minor, self.patch + 1)
end

local mt = { __index = methods }
function mt:__eq(other)
  return self.major == other.major and
         self.minor == other.minor and
         self.patch == other.patch and
         self.prerelease == other.prerelease
         -- notice that build is ignored for precedence in semver 2.0.0
end
function mt:__lt(other)
  if self.major ~= other.major then return self.major < other.major end
  if self.minor ~= other.minor then return self.minor < other.minor end
  if self.patch ~= other.patch then return self.patch < other.patch end
  return smallerPrerelease(self.prerelease, other.prerelease)
  -- notice that build is ignored for precedence in semver 2.0.0
end
-- This works like the "pessimisstic operator" in Rubygems.
-- if a and b are versions, a ^ b means "b is backwards-compatible with a"
-- in other words, "it's safe to upgrade from a to b"
function mt:__pow(other)
  if self.major == 0 then
    return self == other
  end
  return self.major == other.major and
         self.minor <= other.minor
end
function mt:__tostring()
  local buffer = { ("%d.%d.%d"):format(self.major, self.minor, self.patch) }
  if self.prerelease then table.insert(buffer, "-" .. self.prerelease) end
  if self.build      then table.insert(buffer, "+" .. self.build) end
  return table.concat(buffer)
end

local function new(major, minor, patch, prerelease, build)
  assert(major, "At least one parameter is needed")

  if type(major) == 'string' then
    major,minor,patch,prerelease,build = parseVersion(major)
  end
  patch = patch or 0
  minor = minor or 0

  checkPositiveInteger(major, "major")
  checkPositiveInteger(minor, "minor")
  checkPositiveInteger(patch, "patch")

  local result = {major=major, minor=minor, patch=patch, prerelease=prerelease, build=build}
  return setmetatable(result, mt)
end

setmetatable(semver, { __call = function(_, ...) return new(...) end })
semver._VERSION= semver(semver._VERSION)

return semver

end)
__bundle_register("utils.libmaincppconst", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@type table<number, libmaincppApi>
libmaincppConst = {
    [20] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB0,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x70,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x38,
        MetadataRegistrationApitypes = 0x1C,
    },
    [21] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB0,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x78,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x40,
        MetadataRegistrationApitypes = 0x1C,
    },
    [22] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x94,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0x98,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x4C,
        ClassApiEnumType = 0xA9,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x70,
        ClassApiToken = 0x90,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x78,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x40,
        MetadataRegistrationApitypes = 0x1C,
    },
    [23] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x40,
        ClassApiFieldsLink = 0x34,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB1,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 104,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x30,
        MetadataRegistrationApitypes = 0x1C,
    },
    [24.1] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x110 or 0xA8,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x114 or 0xAC,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x126 or 0xBE,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xEC or 0x84,
        ClassApiToken = AndroidInfo.platform and 0x10c or 0xa4,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 100,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x2C,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x114 or 0xAC,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x28 or 0x18,
        ClassApiCountFields = AndroidInfo.platform and 0x118 or 0xB0,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x129 or 0xC1,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF0 or 0x88,
        ClassApiToken = AndroidInfo.platform and 0x110 or 0xa8,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4E or 0x2E,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x48 or 0x28,
        typeDefinitionsSize = 104,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x30,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.2] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.3] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.4] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.5] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27.1] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27.2] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [29] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiNameOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiParamCount = AndroidInfo.platform and 0x52 or 0x2E,
        MethodsApiReturnType = AndroidInfo.platform and 0x28 or 0x14,
        MethodsApiFlags = AndroidInfo.platform and 0x4C or 0x28,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        libmaincppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    }
}


---@class libmaincppFlags
---@field Method MethodFlags
---@field Field FieldFlags
libmaincppFlags = {
    Method = {
        METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- METHOD_ATTRIBUTE_PRIVATE
            "internal", -- METHOD_ATTRIBUTE_FAM_AND_ASSEM
            "internal", -- METHOD_ATTRIBUTE_ASSEM
            "protected", -- METHOD_ATTRIBUTE_FAMILY
            "protected internal", -- METHOD_ATTRIBUTE_FAM_OR_ASSEM
            "public", -- METHOD_ATTRIBUTE_PUBLIC
        },
        METHOD_ATTRIBUTE_STATIC = 0x0010,
        METHOD_ATTRIBUTE_ABSTRACT = 0x0400,
    },
    Field = {
        FIELD_ATTRIBUTE_FIELD_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- FIELD_ATTRIBUTE_PRIVATE
            "internal", -- FIELD_ATTRIBUTE_FAM_AND_ASSEM
            "internal", -- FIELD_ATTRIBUTE_ASSEMBLY
            "protected", -- FIELD_ATTRIBUTE_FAMILY
            "protected internal", -- FIELD_ATTRIBUTE_FAM_OR_ASSEM
            "public", -- FIELD_ATTRIBUTE_PUBLIC
        },
        FIELD_ATTRIBUTE_STATIC = 0x0010,
        FIELD_ATTRIBUTE_LITERAL = 0x0040,
    }
}
end)
return __bundle_require("GGlibmaincpp")