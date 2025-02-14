block-level on error undo, throw.
using ABLC.*.
using progress.Json.ObjectModel.*.

class ABLC.ABLCompiler:
    define private property compilerOptions as JsonObject get. set. 
    
    constructor ABLCompiler():
        assign compilerOptions = new JsonObject().
    end constructor.
    
    method public ABLCompiler parseJsonFile(pJsonPath as character):
       
       return this-object.
    end method.
    
    method public ABLCompiler setBaseDirectory(pDirectory as character):
        if not compilerOptions:has('baseDirectory') then compilerOptions:add('baseDirectory', pDirectory).
        else compilerOptions:set('baseDirectory', pDirectory).
        return this-object.
    end method.
    
    
    
    method public ABLCompiler appendTargetDirectory(pDirectory as character):
        if not compilerOptions:has('targetDirectories') then compilerOptions:add('targetDirectories', new JsonArray()).
        compilerOptions:getJsonArray('targetDirectories'):add(pDirectory).
        return this-object.
    end method.
end class.
