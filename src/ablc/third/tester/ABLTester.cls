block-level on error undo, throw.
using ablc.third.tester.* from propath.

class ablc.third.tester.ABLTester:
    define public property testName as character get. private set.
    define public property totalRunTime as decimal get. private set.
    
    define private temp-table testResult
        field testSequence as int64
        field testResult as character
        field testStart as datetime
        field testEnd as datetime
        field totalRunTime as decimal.
        
        
    constructor ABLTester(pName as character):
        assign testName = pName.
    end constructor.
end class.

