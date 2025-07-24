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