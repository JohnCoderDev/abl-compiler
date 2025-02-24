block-level on error undo, throw.
using progress.Json.ObjectModel.* from propath.
using ablc.* from propath.
using ablc.third.json.* from propath.

class ablc.ABLCompiler:
    define public property compilerOptions as JsonObject get. private set.
    
    constructor ABLCompiler():
        assign compilerOptions = new JsonObject().
    end constructor.
    
    method public ABLCompiler parseJsonObject(pJson as JsonObject):
       
       assign compilerOptions = pJson. 
       return this-object.
    end method.
    
    method public ABLCompiler setBaseDirectory(pDirectory as character):
        if not compilerOptions:has('baseDirectory') then compilerOptions:add('baseDirectory', pDirectory).
        else compilerOptions:set('baseDirectory', pDirectory).
        return this-object.
    end method.
    
    method public void validateABLCompilerJsonObject(pJson as JsonObject):
        // do the logic for the validation
    end method.
    
    method public ABLCompiler appendTargetDirectory(pDirectory as character):
        if not compilerOptions:has('targetDirectories') then compilerOptions:add('targetDirectories', new JsonArray()).
        compilerOptions:getJsonArray('targetDirectories'):add(pDirectory).
        return this-object.
    end method.
end class.
