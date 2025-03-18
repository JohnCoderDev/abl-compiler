block-level on error undo, throw.

using Progress.Json.ObjectModel.* from propath.
using classes.PathTester.* from propath.
using classes.Json.* from propath.
using classes.ablc.* from propath.

define variable CLIParameters as character no-undo.
define variable compilerSpecs as character no-undo.
define variable compilationMode as character no-undo.
define variable additionalProcedures as character no-undo.
define variable pathTester as PathTester no-undo.

assign 
    CLIParameters = session:parameter
    pathTester = new PathTester()
    compilerSpecs = substring(CLIParameters, 1, index(CLIParameters, ",") - 1)
    compilationMode = entry(1, compilerSpecs, ";")
    compilerSpecs = entry(2, compilerSpecs, ";")
    additionalProcedures = substring(CLIParameters, index(CLIParameters, ",") + 1).

pathTester:setPath(compilerSpecs).
if not pathTester:pathExists() or not pathTester:isFile() then do:
    message
        "compilation specs file `"
        + pathTester:getFullPath() 
        + "` was not found"
        view-as alert-box
        error
        buttons ok.
    quit.
end.
    
if additionalProcedures <> "" then do:
    define variable idx as integer no-undo.
    do idx = 1 to num-entries(additionalProcedures):
        pathTester:setPath(entry(idx, additionalProcedures)).
        
        if pathTester:pathExists() and pathTester:isFile() then do:
            run value(pathTester:getFullPath()).
        end.
    end.
end.

do on error undo, leave:
    define variable jsonInput as JsonObject no-undo.
    
    assign jsonInput = new JsonFileReader():readJsonObjectFile(compilerSpecs).
    
    if compilationMode = "c" then do:
        define variable ablc as ABLCompiler no-undo.
        assign ablc = new ABLCompilerParser():parseCompileOnce(jsonInput).
        ablc:compile().
    end.
    else if compilationMode = "s" then do:
        define variable abls as ABLCompilerService no-undo.
        assign abls = new ABLCompilerParser():parseCompilationService(jsonInput).
        abls:startService().
    end.    
    
    catch objError as Progress.Lang.Error:
        message
            objError:getMessage(1)
            view-as alert-box
            error
            buttons ok.
    end catch.
end.    
quit.
