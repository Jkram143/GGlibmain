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
