block-level on error undo, throw.
using Progress.Json.ObjectModel.* from propath.
using classes.ablc.errors.* from propath.
using classes.ablc.rules.* from propath.

class classes.ablc.rules.ABLCompilerServiceRules:
    method public void applyInputRules(pJson as JsonObject):
        define variable idx as integer no-undo.
        define variable auxArray as JsonArray no-undo.
        define variable auxObject as JsonObject no-undo.
        define variable auxChar as character no-undo.
        
        
        if not pJson:has("service") then do:
            return error new ABLCInputRuleError(
                "input to service must have json object `service`"
            ).    
        end.
        
        if not pJson:getJsonObject("service"):has("interval") then do:
            define variable intervalValue as integer.
            assign intervalValue = pJson:getJsonObject("service"):getInteger("interval").
            return error new ABLCInputRuleError(
                "`service` json object must have an integer `interval`"
            ).
        end.
        
        new ABLCompileOnceRules():applyInputRules(pJson).
    end method.
end class.
