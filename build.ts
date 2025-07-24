import { bundle } from 'luabundle'
import fs from 'fs'
import path from "path"

const bundledLua = bundle('./index.lua', {
    metadata: false,
    rootModuleName: "GGlibmain.cpp"
})

const buildPath = path.normalize("build/libmain.cppApi.lua")

fs.writeFile(buildPath, bundledLua, (err : any) => {
    if (err) throw err
    console.log("libmain.cppApi.lua -> ОК\n")
})