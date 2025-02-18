block-level on error undo, throw.
using ablc.third.tester.* from propath.
using ablc.third.tester.errors.* from propath.
using progress.json.ObjectModel.* from propath.

class ablc.third.tester.ABLTestCase inherits ABLAsserter abstract:
    define private property currentSequence as int64 initial 1 get. set.
    define private temp-table testResult
        field sequence as int64
        field className as character
        field methodName as character
        field testResult as character
        field testMessage as character
        field lastErrorCode as integer initial 0
        field timestampStart as datetime
        field timestampEnd as datetime
        field totalTime as decimal.
    
    method public abstract void setup().
    method public abstract void teardown().
    
    method public ABLTestCase runTests():
        clearTests().
        setup().
        define variable currentMethod as progress.reflect.method.
        define variable methods as progress.reflect.method extent.
        define variable ix as integer no-undo.
        
        assign methods = this-object:getClass():getMethods().
        do ix = 1 to extent(methods) on error undo:
            assign currentMethod = methods[ix].
            
            if currentMethod:name matches "test*" then do:
                create testResult.
               
                assign
                    testResult.className = currentMethod:originatingClass:typeName
                    testResult.sequence = currentSequence
                    testResult.methodName = currentMethod:name
                    testResult.timestampStart = now
                    currentSequence = currentSequence + 1.
                    
                if currentMethod:numParameters > 0 then do:
                    return error new ABLTestCaseWithParametersError().
                end.
                
                currentMethod:invoke(new progress.lang.parameterList(0)).
                
                assign 
                    testResult.testResult = "success"
                    testResult.testMessage = "ok".
            end.
           
            catch objError as progress.lang.error:
                define variable iy as integer no-undo.
                assign testResult.testResult = "error".
                do iy = 1 to objError:numMessages: 
                    assign
                        testResult.testMessage = testResult.testMessage + ";" + objError:getMessage(iy)
                        testResult.lastErrorCode = objError:getMessageNum(iy).
                end.
            end catch.
            
            finally:
                if currentMethod:name matches "test*" then do:
                    assign
                        testResult.timestampEnd = now
                        testResult.totalTime = testResult.timestampEnd - testResult.timestampStart.
                end.
            end finally.
        end.
        teardown().
        return this-object.
    end method.
    
    method public ABLTestCase clearTests():
        empty temp-table testResult.
        return this-object.
    end method.
    
    method public JsonArray getTestsJsonArray():
        define variable resultJsonArray as JsonArray no-undo.
        assign resultJsonArray = new JsonArray().
        temp-table testResult:write-json("JsonArray", resultJsonArray, true, ?, false, true).
        return resultJsonArray.
    end method.
end class.
