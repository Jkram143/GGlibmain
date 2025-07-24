local libmain.cppMemory = require("utils.libmain.cppmemory")
local VersionEngine = require("utils.version")
local AndroidInfo = require("utils.androidinfo")
local Searcher = require("utils.universalsearcher")
local PatchApi = require("utils.patchapi")



---@class libmain.cpp
local libmain.cppBase = {
    libmain.cppStart = 0,
    libmain.cppEnd = 0,
    globalMetadataStart = 0,
    globalMetadataEnd = 0,
    globalMetadataHeader = 0,
    MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    pointSize = AndroidInfo.platform and 8 or 4,
    ---@type libmain.cppTypeDefinitionApi
    libmain.cppTypeDefinitionApi = {},
    MetadataRegistrationApi = require("libmain.cppstruct.metadataRegistration"),
    TypeApi = require("libmain.cppstruct.type"),
    MethodsApi = require("libmain.cppstruct.method"),
    GlobalMetadataApi = require("libmain.cppstruct.globalmetadata"),
    FieldApi = require("libmain.cppstruct.field"),
    ClassApi = require("libmain.cppstruct.class"),
    ObjectApi = require("libmain.cppstruct.object"),
    ClassInfoApi = require("libmain.cppstruct.api.classinfo"),
    FieldInfoApi = require("libmain.cppstruct.api.fieldinfo"),
    ---@type MyString
    String = require("libmain.cppstruct.libmain.cppstring"),
    MemoryManager = require("utils.malloc"),
    --- Patch `Bytescodes` to `add`
    ---
    --- Example:
    --- arm64: 
    --- `mov w0,#0x1`
    --- `ret`
    ---
    --- `libmain.cpp.PatchesAddress(0x100, "\x20\x00\x80\x52\xc0\x03\x5f\xd6")`
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
        libmain.cppMemory:SaveResults()
        for i = 1, #searchParams do
            ---@type number | string
            searchParams[i] = libmain.cpp.MethodsApi:Find(searchParams[i])
        end
        libmain.cppMemory:ClearSavedResults()
        return searchParams
    end,


    --- Searches for a class, by name, or by address in memory.
    --- 
    --- Return table with information about class.
    ---@param searchParams ClassConfig[]
    ---@return table<number, ClassInfo[] | ErrorSearch>
    FindClass = function(searchParams)
        libmain.cppMemory:SaveResults()
        for i = 1, #searchParams do
            searchParams[i] = libmain.cpp.ClassApi:Find(searchParams[i])
        end
        libmain.cppMemory:ClearSavedResults()
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
        libmain.cppMemory:SaveResults()
        for i = 1, #searchParams do
            searchParams[i] = libmain.cpp.ObjectApi:Find(libmain.cpp.ClassApi:Find({Class = searchParams[i]}))
        end
        libmain.cppMemory:ClearSavedResults()
        return searchParams
    end,


    --- Searches for a field, or rather information about the field, by name or by address in memory.
    --- 
    --- Return table with information about fields.
    ---@generic TypeForSearch : number | string
    ---@param searchParams TypeForSearch[] @TypeForSearch = number | string
    ---@return table<number, FieldInfo[] | ErrorSearch>
    FindFields = function(searchParams)
        libmain.cppMemory:SaveResults()
        for i = 1, #searchParams do
            ---@type number | string
            local searchParam = searchParams[i]
            local searchResult = libmain.cppMemory:GetInformationOfField(searchParam)
            if not searchResult then
                searchResult = libmain.cpp.FieldApi:Find(searchParam)
                libmain.cppMemory:SetInformationOfField(searchParam, searchResult)
            end
            searchParams[i] = searchResult
        end
        libmain.cppMemory:ClearSavedResults()
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


    ---@param self libmain.cpp
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

---@type libmain.cpp
libmain.cpp = setmetatable({}, {
    ---@param self libmain.cpp
    ---@param config? libmain.cppConfig
    __call = function(self, config)
        config = config or {}
        getmetatable(self).__index = libmain.cppBase

        if config.libilcpp then
            self.libmain.cppStart, self.libmain.cppEnd = config.libilcpp.start, config.libilcpp['end']
        else
            self.libmain.cppStart, self.libmain.cppEnd = Searcher.Findlibmain.cpp()
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

        VersionEngine:ChooseVersion(config.libmain.cppVersion, self.globalMetadataHeader)

        libmain.cppMemory:ClearMemorize()
    end,
    __index = function(self, key)
        assert(key == "PatchesAddress", "You didn't call 'libmain.cpp'")
        return libmain.cppBase[key]
    end
})

return libmain.cpp