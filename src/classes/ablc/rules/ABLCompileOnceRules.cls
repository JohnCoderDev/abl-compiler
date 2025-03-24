block-level on error undo, throw.
using Progress.Json.ObjectModel.* from propath.
using classes.ablc.errors.* from propath.

class classes.ablc.rules.ABLCompileOnceRules:
    method public void applyInputRules(pJson as JsonObject):
        define variable idx as integer no-undo.
        define variable auxArray as JsonArray no-undo.
        define variable auxObject as JsonObject no-undo.
        define variable auxChar as character no-undo.
        
        if not pJson:has("sources") then do:
            return error new ABLCInputRuleError(
                "input to compiler must have `sources` json array"
            ).    
        end.
        
        if not pJson:has("targets") then do:
            return error new ABLCInputRuleError(
                "input to compiler must have `targets` json array"
            ).    
        end.
        
        define variable folderPath as character no-undo.
        
        assign auxArray = pJson:getJsonArray("sources").
        if auxArray:length = 0 then do:
            return error new ABLCInputRuleError(
                "`sources` array must have at least one json object"
            ).   
        end.
        
        do idx = 1 to auxArray:length:
            assign auxObject = auxArray:getJsonObject(idx).
            if not auxObject:has("folder") then do:
                return error new ABLCInputRuleError(
                    "a source in `sources` object must have a `folder` path"
                ).
            end.
            
            assign folderPath = auxObject:getCharacter("folder").
        end.
        
        assign auxArray = pJson:getJsonArray("targets").
        
        if auxArray:length = 0 then do:
            return error new ABLCInputRuleError(
                "`targets` array must have at least one json object"
            ).   
        end.
        
        do idx = 1 to auxArray:length:
            assign auxObject = auxArray:getJsonObject(idx).
            if not auxObject:has("folder") then do:
                return error new ABLCInputRuleError(
                    "a target in `targets` object must have a `folder` path"
                ).
            end. 
            assign folderPath = auxObject:getCharacter("folder").
            
            if auxObject:has("server") then do:
                assign auxChar = auxObject:getCharacter("server").
                if not auxObject:has("user") or not auxObject:has("password") then do:
                    return error new ABLCInputRuleError(
                        "when specifying a server, it requires a ssh `user` and `password` strings"
                    ).    
                end.
            end.
        end.
        
        if pJson:has("compilationErrors") then do:
            define variable compilationErrorsPath as character no-undo.
            assign compilationErrorsPath = pJson:getCharacter("compilationErrors").
        end.
        
        if pJson:has("beforeCommands") then do:
            assign auxArray = pJson:getJsonArray("beforeCommands").
            do idx = 1 to auxArray:length:
                assign auxChar = auxArray:getCharacter(idx).
            end.
        end.
        
        if pJson:has("afterCommands") then do:
            assign auxArray = pJson:getJsonArray("afterCommands").
            do idx = 1 to auxArray:length:
                assign auxChar = auxArray:getCharacter(idx).
            end.
        end.
        
        if pJson:has("propath") then do:
            assign auxArray = pJson:getJsonArray("propath").
            do idx = 1 to auxArray:length:
                assign auxChar = auxArray:getCharacter(idx).
            end.
        end.
    end method.
end class.
