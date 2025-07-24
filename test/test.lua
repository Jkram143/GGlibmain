io.open('libmaincppapi.lua',"w+"):write(gg.makeRequest("https://raw.githubusercontent.com/Jkram143/GGlibmain/refs/heads/main/build/libmaincppApi.lua").content):close()
require('libmaincppapi')
os.remove('libmaincppapi.lua')

libmaincpp()

---@type ClassConfig
local TestClassConfig = {}

TestClassConfig.Class = "TestClass"
TestClassConfig.FieldsDump = true

local TestClasses = libmaincpp.FindClass({TestClassConfig})[1]

local ChangeTestClasses = {}

print(TestClasses)

for k,v in ipairs(TestClasses) do
    local TestClassObject = libmaincpp.FindObject({tonumber(v.ClassAddress, 16)})[1]
    if v.Parent and v.Parent.ClassName ~= "ValueType" and #v.ClassNameSpace == 0 then
        for i = 1, #TestClassObject do
            ChangeTestClasses[#ChangeTestClasses + 1] = {
                address = TestClassObject[i].address + tonumber(v:GetFieldWithName("Field1").Offset, 16),
                flags = gg.TYPE_DWORD,
                value = 40
            }
            ChangeTestClasses[#ChangeTestClasses + 1] = {
                address = TestClassObject[i].address + tonumber(v:GetFieldWithName("Field2").Offset, 16),
                flags = gg.TYPE_FLOAT,
                value = 33
            }
        end
    
        ChangeTestClasses[#ChangeTestClasses + 1] = {
            address = v.StaticFieldData + tonumber(v:GetFieldWithName("Field3").Offset, 16),
            flags = gg.TYPE_DWORD,
            value = 12
        }
    end

end

gg.setValues(ChangeTestClasses)

for k,v in ipairs(TestClasses) do
    local Methods = v:GetMethodsWithName("GetField4")
    if #Methods > 0 then
        for i = 1, #Methods do
            libmaincpp.PatchesAddress(tonumber(Methods[i].AddressInMemory, 16), libmaincpp.MainType == gg.TYPE_QWORD and "\x40\x02\x80\x52\xc0\x03\x5f\xd6" or "\x12\x00\xa0\xe3\x1e\xff\x2f\xe1")
        end
    end
end

os.exit()