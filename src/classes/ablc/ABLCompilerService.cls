block-level on error undo, throw.
using classes.ablc.* from propath.
using classes.ablc.errors.* from propath.

class classes.ablc.ABLCompilerService:
    define private property compilerObject as ABLCompiler get. set.
    define private property timeInterval as integer get. set.
    
    constructor ABLCompilerService(pCompiler as ABLCompiler):
        assign compilerObject = pCompiler.
    end constructor.
    
    method public ABLCompilerService setInterval(pSeconds as integer):
        if pSeconds <= 0 then do:
            return error new ABLCInvalidInterval().
        end.
        assign timeInterval = pSeconds.
    end method.
    
    method public void startService():
        if timeInterval <= 0 then do:
            return error new ABLCInvalidInterval().
        end.
        repeat:
            compilerObject:compile().
            pause timeInterval.
        end.
    end method.
end class.
