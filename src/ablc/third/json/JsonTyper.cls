block-level on error undo, throw.
using progress.Json.ObjectModel.* from propath.
using ablc.third.json.errors.* from propath.

class ablc.third.json.JsonTyper:
    method public static logical isOfType(
        pJson as JsonObject,
        pName as character,
        pExpectedType as character
    ):
        return getRealType(pJson, pName) = pExpectedType.
    end method.
    
    method public static logical isOfType(
        pJson as JsonArray,
        pIndex as integer,
        pExpectedType as character
    ):
        return getRealType(pJson, pIndex) = pExpectedType.
    end method.
    
    method public static character getRealType(pJson as JsonArray, pIndex as integer):
        do on error undo:
            pJson:getCharacter(pIndex).
            return 'character'.
            catch obj as progress.lang.error: end catch.
        end.
        
        do on error undo:
            define variable v as decimal.
            assign v = pJson:getDecimal(pIndex).
            if v <> int(v) then return 'decimal'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getInt64(pIndex).
            return 'integer'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getDate(pIndex).
            return 'date'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getDatetime(pIndex).
            return 'datetime'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getJsonObject(pIndex).
            return 'JsonObject'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getJsonArray(pIndex).
            return 'JsonArray'.
            catch e as progress.lang.error: end catch.
        end.
        
        return error new UnknownTypeInJson(pIndex).
    end method.
    
    method public static character getRealType(pJson as JsonObject, pName as character):
        do on error undo:
            pJson:getCharacter(pName).
            return 'character'.
            catch obj as progress.lang.error: end catch.
        end.
        
        do on error undo:
            define variable v as decimal.
            assign v = pJson:getDecimal(pName).
            if v <> int(v) then return 'decimal'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getInt64(pName).
            return 'integer'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getDate(pName).
            return 'date'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getDatetime(pName).
            return 'datetime'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getJsonObject(pName).
            return 'JsonObject'.
            catch e as progress.lang.error: end catch.
        end.
        
        do on error undo:
            pJson:getJsonArray(pName).
            return 'JsonArray'.
            catch e as progress.lang.error: end catch.
        end.
        
        return error new UnknownTypeInJson(pName).
    end method.
end class.
