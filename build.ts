import { bundle } from 'luabundle'
import fs from 'fs'
import path from "path"

const bundledLua = bundle('./index.lua', {
    metadata: false,
    rootModuleName: "GGlibmaincpp"
})

const buildPath = path.normalize("build/libmaincppApi.lua")

fs.writeFile(buildPath, bundledLua, (err : any) => {
    if (err) throw err
    console.log("libmaincppApi.lua -> ОК\n")
})