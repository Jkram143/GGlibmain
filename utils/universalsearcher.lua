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
