block-level on error undo, throw.
using Progress.Json.ObjectModel.* from propath.
using classes.ablc.* from propath.
using classes.ablc.rules.* from propath.

class classes.ablc.ABLCompilerParser:
    method public ABLCompiler parseCompileOnce(pCompilerSpecs as JsonObject):
        new ABLCompileOnceRules():applyInputRules(pCompilerSpecs).
        return buildCompilerObject(pCompilerSpecs).
    end method.
    
    method public ABLCompilerService parseCompilationService(pCompilerSpecs as JsonObject):
        new ABLCompilerServiceRules():applyInputRules(pCompilerSpecs).
        define variable ablc as ABLCompiler no-undo.
        define variable abls as ABLCompilerService no-undo.
        assign 
            ablc = buildCompilerObject(pCompilerSpecs)
            abls = new ABLCompilerService(ablc).
        abls:setInterval(pCompilerSpecs:getJsonObject("service"):getInteger("interval")).
        return abls.
    end method.
    
    method private ABLCompiler buildCompilerObject(pCompilerSpecs as JsonObject):
        define variable ablc as ABLCompiler no-undo.
        define variable auxArray as JsonArray no-undo.
        define variable auxObject as JsonObject no-undo.
        define variable mantainStructure as logical no-undo.
        define variable idx as integer no-undo.
        
        assign 
            ablc = new ABLCompiler()
            auxArray = pCompilerSpecs:getJsonArray("sources").
        
        do idx = 1 to auxArray:length:
            assign 
                auxObject = auxArray:getJsonObject(idx).
            ablc:addSourceDirectory(auxObject:getCharacter("folder")).
        end.
        
        assign auxArray = pCompilerSpecs:getJsonArray("targets").
        do idx = 1 to auxArray:length:
            assign auxObject = auxArray:getJsonObject(idx).
            if auxObject:has("server") then do:
                ablc:addSSHTargetDirectory(
                    auxObject:getCharacter("folder"),
                    auxObject:getCharacter("server"),
                    if auxObject:has("user") 
                        then auxObject:getCharacter("user") 
                        else "root"
                ).    
            end.
            else do:
                ablc:addTargetDirectory(
                    auxObject:getCharacter("folder")
                ).
            end.
        end.
        
        if pCompilerSpecs:has("compilationErrors") then do:
            ablc:addCompilationErrorsFilePath(
                pCompilerSpecs:getCharacter("compilationErrors")
            ).    
        end.
        
        if pCompilerSpecs:has("beforeCommands") then do:
            assign auxArray = pCompilerSpecs:getJsonArray("beforeCommands").
            
            do idx = 1 to auxArray:length:
                ablc:addBeforeOSCommand(
                    auxArray:getCharacter(idx)
                ).    
            end.
        end.
        
        if pCompilerSpecs:has("afterCommands") then do:
            assign auxArray = pCompilerSpecs:getJsonArray("afterCommands").
            
            do idx = 1 to auxArray:length:
                ablc:addAfterOSCommand(
                    auxArray:getCharacter(idx)
                ).    
            end.
        end.
        
        if pCompilerSpecs:has("propath") then do:
            assign auxArray = pCompilerSpecs:getJsonArray("propath").
            
            do idx = auxArray:length to 1 by -1:
                ablc:addToPropath(auxArray:getCharacter(idx)).
            end.
        end.
        return ablc.
    end method.
end class.
