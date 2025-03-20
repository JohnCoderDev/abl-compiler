block-level on error undo, throw.

using Progress.Json.ObjectModel.* from propath.
using classes.PathTester.* from propath.
using classes.Json.* from propath.
using classes.ablc.* from propath.

define variable CLIParameters as character no-undo.
define variable compilerParameters as character no-undo.
define variable compilerSpecs as character no-undo.
define variable compilationMode as character no-undo.
define variable compilerLogFile as character no-undo.
define variable additionalProcedures as character no-undo.
define variable pathTester as PathTester no-undo.

assign 
    CLIParameters = session:parameter
    pathTester = new PathTester()
    compilerParameters = entry(1, CLIParameters)
    compilationMode = entry(1, compilerParameters, ";")
    compilerSpecs = entry(2, compilerParameters, ";")
    compilerLogFile = entry(3, compilerParameters, ";")
    additionalProcedures = substring(CLIParameters, index(CLIParameters, ",") + 1).

output to value(compilerLogFile).

pathTester:setPath(compilerSpecs).
if not pathTester:pathExists() or not pathTester:isFile() then do:
    ABLCompilerMessageFormatter:writeMessage(
        "compilation specs file `" + pathTester:getFullPath() + "` was not found",
        'error'
    ).
    output close.
    quit.
end.

if additionalProcedures <> "" then do:
    define variable idx as integer no-undo.
    do idx = 1 to num-entries(additionalProcedures):
        pathTester:setPath(entry(idx, additionalProcedures)).
        
        if pathTester:pathExists() and pathTester:isFile() then do:
            ABLCompilerMessageFormatter:writeMessage(
                "running before script `" + pathTester:getFullPath() + "`"
            ).    
            run value(pathTester:getFullPath()).
        end.
        else do:
            ABLCompilerMessageFormatter:writeMessage(
                "procedure `" + entry(idx, additionalProcedures) + "` not found",
                'warning'
            ).
        end.
    end.
end.

do on error undo, leave:
    define variable jsonInput as JsonObject no-undo.
    
    assign jsonInput = new JsonFileReader():readJsonObjectFile(compilerSpecs).
    
    if compilationMode = "c" then do:
        define variable ablc as ABLCompiler no-undo.
        assign ablc = new ABLCompilerParser():parseCompileOnce(jsonInput).
        ABLCompilerMessageFormatter:writeMessage(
            "initializing compiling once mode"
        ).    
        ablc:compile().
    end.
    else if compilationMode = "s" then do:
        define variable abls as ABLCompilerService no-undo.
        assign abls = new ABLCompilerParser():parseCompilationService(jsonInput).
        ABLCompilerMessageFormatter:writeMessage(
            "initializing service mode" 
        ).
        abls:startService().
    end.    
    
    catch objError as Progress.Lang.Error:
        do idx = 1 to objError:numMessages:
            ABLCompilerMessageFormatter:writeMessage(
                objError:getMessage(idx),
                'error'
            ).
        end.
    end catch.
end.

output close.
quit.
