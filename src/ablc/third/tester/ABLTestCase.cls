block-level on error undo, throw.
using ablc.third.tester.* from propath.
using ablc.third.tester.errors.* from propath.
using progress.json.ObjectModel.* from propath.

class ablc.third.tester.ABLTestCase inherits ABLAsserter abstract:
    define public property totalRunned as int64 get. private set.
    define public property totalSuccess as int64 get. private set.
    define public property totalFailed as int64 get. private set.
    define public property totalErrors as int64 get. private set.
    
    define private temp-table testResult
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
        return runTests("test*").
    end method.
    
    method public ABLTestCase runTests(pPattern as character):
        clearTestsResults().
        define variable currentMethod as progress.reflect.method.
        define variable methods as progress.reflect.method extent.
        define variable ix as integer no-undo.
        
        assign methods = this-object:getClass():getMethods().
        
        do ix = 1 to extent(methods) on error undo:
            setup().
            assign currentMethod = methods[ix].
            
            if currentMethod:name matches pPattern then do:
                create testResult.
               
                assign
                    totalRunned = totalRunned + 1
                    testResult.className = currentMethod:originatingClass:typeName
                    testResult.methodName = currentMethod:name
                    testResult.timestampStart = now.
                    
                if currentMethod:numParameters > 0 then do:
                    return error new ABLTestCaseWithParametersError().
                end.
                
                currentMethod:invoke(this-object, new progress.lang.parameterList(0)).
                
                assign
                    totalSuccess = totalSuccess + 1
                    testResult.testResult = "success"
                    testResult.testMessage = "ok".
            end.
           
            catch objAssertionError as ABLAssertionError:
                assign
                    totalFailed = totalFailed + 1
                    testResult.testResult = "failed"
                    testResult.testMessage = objAssertionError:getMessage(1)
                    testResult.lastErrorCode = objAssertionError:getMessageNum(1).
            end catch.
            
            catch objError as progress.lang.error:
                define variable iy as integer no-undo.
                
                assign testResult.testResult = "error".
                do iy = 1 to objError:numMessages: 
                    assign
                        totalErrors = totalErrors + 1
                        testResult.testMessage = testResult.testMessage + ";" + objError:getMessage(iy)
                        testResult.lastErrorCode = objError:getMessageNum(iy).
                end.
            end catch.
            
            finally:
                if currentMethod:name matches pPattern then do:
                    assign
                        testResult.timestampEnd = now
                        testResult.totalTime = testResult.timestampEnd - testResult.timestampStart.
                end.
                teardown().
            end finally.
        end.
        return this-object.
    end method.
    
    method public ABLTestCase clearTestsResults():
        empty temp-table testResult.
        assign
            totalRunned = 0
            totalSuccess = 0
            totalFailed = 0
            totalErrors = 0.
        return this-object.
    end method.
    
    method public JsonObject getTestsResultsObject():
        define variable resultJsonArray as JsonArray no-undo.
        define variable testsJsonObject as JsonObject no-undo.
        
        assign 
            resultJsonArray = new JsonArray()
            testsJsonObject = new JsonObject().
        
        temp-table testResult:write-json("JsonArray", resultJsonArray, true, ?, false, true).
        
        testsJsonObject:add("meta", new JsonObject()).
        testsJsonObject:add("results", resultJsonArray).
        testsJsonObject:getJsonObject("meta"):add("runned", totalRunned).
        testsJsonObject:getJsonObject("meta"):add("success", totalSuccess).
        testsJsonObject:getJsonObject("meta"):add("failed", totalFailed).
        testsJsonObject:getJsonObject("meta"):add("errors", totalErrors).
        testsJsonObject:getJsonObject("meta"):add("successRating", totalSuccess / totalRunned).
        testsJsonObject:getJsonObject("meta"):add("failedRating", totalFailed / totalRunned).
        testsJsonObject:getJsonObject("meta"):add("errorsRating", totalErrors / totalRunned).
        
        return testsJsonObject.
    end method.
    
    method public handle getTestResultTableHandle():
        return temp-table testResult:handle.
    end method.
    
    method public void showResultsTable():
        for each testResult:
            display 
                testResult
                with scrollable.
        end.
    end method.
end class.
