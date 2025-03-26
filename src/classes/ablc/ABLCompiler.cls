block-level on error undo, throw.
using Progress.Json.ObjectModel.* from propath.
using classes.ablc.* from propath.
using classes.ablc.errors.* from propath.
using classes.PathTester.* from propath.

class classes.ablc.ABLCompiler:
    define private property sourcePathTester as PathTester get. set.
    define private property targetPathTester as PathTester get. set.
    define private property filePathTester as PathTester get. set.
    define private property pathSeparator as character initial "\" get. set.
    define private property compilationErrorsFilePath as character get. set.
    define private property hasSSHTarget as logical get. set.
    define private property sshTempBuildDir as character get. set.
    define public property compilationErrors as JsonArray get. set.
    
    define private temp-table sourceDirectories
        field directoryPath as character
        index idxDirectoryPath as primary unique directoryPath.
    
    define private temp-table targetDirectories
        field directoryPath as character
        field isSSH as logical
        field sshServer as character
        field sshUser as character
        index idxDirectoryPath as primary unique directoryPath isSSH.
        
    define private temp-table compiledFiles
        field pathSourceCode as character
        field lastWriteTime as datetime
        field folderTarget as character
        index idxSourceTarget as primary unique pathSourceCode folderTarget.
    
    define private temp-table filesToCompile
        field pathSourceCode as character
        field folderTarget as character.
        
    define private temp-table OSCommand
        field commandString as character
        field runWhen as character.
        
    constructor ABLCompiler():
        assign 
            sourcePathTester = new PathTester()
            targetPathTester = new PathTester()
            filePathTester = new PathTester()
            sshTempBuildDir = session:temp-directory + "ablc-tmpbuild".
        
        ABLCompilerMessageFormatter:writeMessage(
            "ssh temp directory settled to `" + sshTempBuildDir + "`"
        ).    
        
        if opsys <> "win32" then do:
            assign pathSeparator = "/".
        end.
    end constructor.
    
    method public ABLCompiler addToPropath(pPath as character):
        if not propath matches "*" + pPath + ",*" then do:
            assign propath = pPath + "," + propath.
            ABLCompilerMessageFormatter:writeMessage("added `" + pPath + "` to the propath").
        end.
        return this-object.
    end method.
    
    method public ABLCompiler setPathSeparator(pSeparator as character):
        assign pathSeparator = pSeparator. 
        return this-object.
    end.
    
    method public ABLCompiler addBeforeOSCommand(pCmd as character):
        create OSCommand.
        assign
            OSCommand.commandString = pCmd
            OSCommand.runWhen = "before".
    end method.
    
    method public ABLCompiler addCompilationErrorsFilePath(pPath as character):
        assign compilationErrorsFilePath = pPath.
        return this-object.
    end method.
    
    method public ABLCompiler addAfterOSCommand(pCmd as character):
        create OSCommand.
        assign
            OSCommand.commandString = pCmd
            OSCommand.runWhen = "after".
        return this-object.
    end method.
   
    method public ABLCompiler addSSHTargetDirectory(
        pPath as character,
        pServer as character,
        pUser as character
    ):
        if session:temp-directory = "" then do:
            return error new ABLCNullTempDirectory().
        end.
        assign hasSSHTarget = true.        
        addTargetDirectory(sshTempBuildDir).
        if not can-find(
            first targetDirectories
            where targetDirectories.directoryPath = pPath
                and targetDirectories.isSSH = true
        ) then do:    
            create targetDirectories.
            assign
                targetDirectories.directoryPath = pPath
                targetDirectories.isSSH = true
                targetDirectories.sshServer = pServer
                targetDirectories.sshUser = pUser.
                
             ABLCompilerMessageFormatter:writeMessage(
                "added ssh target directory `" + targetDirectories.directoryPath + "`"
                + " in the server `" + targetDirectories.sshServer + "`"
             ).
        end.
        return this-object.
    end method.
    
    method public ABLCompiler addTargetDirectory(pPath as character):
        if not can-find(
            first targetDirectories
            where targetDirectories.directoryPath = pPath
                and targetDirectories.isSSH = false
        ) then do:
            create targetDirectories.
            assign targetDirectories.directoryPath = pPath.
            
            ABLCompilerMessageFormatter:writeMessage(
                "added target directory `" + targetDirectories.directoryPath + "`"
            ).
        end.
        return this-object.
    end method.
    
    
    method public ABLCompiler addSourceDirectory(pPath as character):
         if not can-find(
            first sourceDirectories
            where targetDirectories.directoryPath = pPath
        ) then do:
            sourcePathTester:setPath(pPath).
            if not sourcePathTester:isDir() or not sourcePathTester:pathExists() then do:
                return error new ABLCDirectoryDoesNotExist(pPath).
            end.
            
            if not propath matches "*" + pPath + "*" then do:
                ABLCompilerMessageFormatter:writeMessage(
                    "adding `" + pPath + "` to the propath"
                ).    
                assign propath = pPath + "," + propath.
            end.
                
            create sourceDirectories.
            assign sourceDirectories.directoryPath = pPath.
            
            ABLCompilerMessageFormatter:writeMessage(
                "added source directory `" + sourceDirectories.directoryPath + "`"
            ).
        end.
        return this-object.
    end method.
    
    method public void compile():
        define variable hasToCompile as logical no-undo.
        resetSSHTempBuildDir().
        verifyCompilationNecessity().
        
        assign hasToCompile = temp-table filesToCompile:has-records.
        
        if hasToCompile then do:
            assign compilationErrors = new JsonArray().
            runCommands("before").
        end.
        
        for each filesToCompile.
            compile value(filesToCompile.pathSourceCode)
                save into value(filesToCompile.folderTarget)
                no-error.
            
            if not compiler:error then do:
                ABLCompilerMessageFormatter:writeMessage(
                    "compiled file from source `" + filesToCompile.pathSourceCode + "`"
                    + " to folder target `" + filesToCompile.folderTarget + "`",
                    "success"
                ).
                delete filesToCompile.
            end.
            else do:
                define variable idx as integer no-undo.
                define variable compilerMessage as JsonObject no-undo.
                do idx = 1 to compiler:num-messages:
                    ABLCompilerMessageFormatter:writeMessage(
                        compiler:get-file-name(idx)
                        + ":" + string(compiler:get-row(idx))
                        + ":" + string(compiler:get-column(idx))
                        + ": " + compiler:get-message(idx)
                        + " (" + string(compiler:get-number(idx)) + ")",
                        if compiler:get-message-type(idx) = 1 then "error"
                        else if compiler:get-message-type(idx) = 2 then "warning"
                        else "preprocessor"
                    ).
                    assign compilerMessage = new JsonObject().
                    compilerMessage:add("timestamp", now).
                    compilerMessage:add("row", compiler:get-row(idx)).
                    compilerMessage:add("column", compiler:get-column(idx)).
                    compilerMessage:add("file", compiler:get-file-name(idx)).
                    compilerMessage:add("message", compiler:get-message(idx)).
                    compilerMessage:add("code", compiler:get-number(idx)).
                    compilerMessage:add("type", compiler:get-message-type(idx)).
                    compilerMessage:add("typeName", 
                        if compiler:get-message-type(idx) = 1 then "error"
                        else if compiler:get-message-type(idx) = 2 then "warning"
                        else "preprocessor"
                    ).
                    compilerMessage:add("errorString",
                        compiler:get-file-name(idx)
                        + ":" + string(compiler:get-row(idx))
                        + ":" + string(compiler:get-column(idx))
                        + ": " + compiler:get-message(idx)
                        + " (" + string(compiler:get-number(idx)) + ")"
                        + " [" + compilerMessage:getCharacter("typeName") + "]"
                    ).    
                    compilationErrors:add(compilerMessage).
                end.
            end.
        end.
        
        if hasToCompile then do:
            runCommands("after").
            if compilationErrorsFilePath <> "" then do:
                compilationErrors:writeFile(compilationErrorsFilePath, true).
                ABLCompilerMessageFormatter:writeMessage(
                    "written the compilation errors file `"
                    + compilationErrorsFilePath + "`"
                ).
            end.
        end.
        copyToSSHTargets().
        
        ABLCompilerMessageFormatter:writeMessage(
            "trying to remove folder `" + sshTempBuildDir + "`"
        ).
        os-delete value(sshTempBuildDir) recursive.
        
        ABLCompilerMessageFormatter:writeMessage(
            "end of the compilation"
        ).    
    end method.
    
    method private void resetSSHTempBuildDir():
        if hasSSHTarget then do:
            ABLCompilerMessageFormatter:writeMessage(
                "deleting the folder `" + sshTempBuildDir + "`"
            ).    
            os-delete value(sshTempBuildDir) recursive.
            ABLCompilerMessageFormatter:writeMessage(
                "creating the folder `" + sshTempBuildDir + "`"
            ).
            os-create-dir value(sshTempBuildDir).
        end. 
    end method.
    
    method private void copyToSSHTargets():
        if hasSSHTarget then do:
            define variable sshCopyCommand as character no-undo.
            define variable replacedCommand as character no-undo.
            
            assign sshCopyCommand = "scp -r &1" + pathSeparator + "* &2@&3:&4".
            
            for each targetDirectories where isSSH = true:
                assign replacedCommand = substitute(
                    sshCopyCommand,
                    sshTempBuildDir,
                    targetDirectories.sshUser,
                    targetDirectories.sshServer,
                    targetDirectories.directoryPath
                ).
                ABLCompilerMessageFormatter:writeMessage(
                    "running the copy command `" + replacedCommand + "`" 
                ).
                
                os-command silent value(replacedCommand).                
            end.
        end.
    end method.
    
    method private void runCommands(pGrouper as character):
        for each OSCommand where OSCommand.runWhen = pGrouper:
            ABLCompilerMessageFormatter:writeMessage(
                "running command `" + OSCommand.commandString + "`"
                + " of the grouper `" + pGrouper + "`"
            ).
            os-command silent value(OSCommand.commandString).    
        end.
    end method.
    
    method private void verifyCompilationNecessity():
        empty temp-table filesToCompile.
        for each sourceDirectories:
            for each targetDirectories where targetDirectories.isSSH = false:
                verifyCompilationNecessity(
                    sourceDirectories.directoryPath,
                    targetDirectories.directoryPath,
                    targetDirectories.directoryPath
                ).
            end.
        end.
    end method.
    
    method private void verifyCompilationNecessity(
        pSourcePath as character, 
        pTargetPath as character,
        pBasePath as character
    ):
        define variable nameOfPath as character no-undo.
        define variable fullSourcePath as character no-undo.
        define variable fullTargetPath as character no-undo.
        
        targetPathTester:setPath(pTargetPath).
        if not targetPathTester:pathExists() then do:
            ABLCompilerMessageFormatter:writeMessage(
                "creating directory `" + pTargetPath + "`"
            ).
            os-create-dir value(pTargetPath).
        end.
        
        input from os-dir(pSourcePath).
            repeat:
                import nameOfPath.
                if nameOfPath = "." or nameOfPath = ".." then next.
                assign fullSourcePath = pSourcePath 
                    + (if pSourcePath matches "*" + pathSeparator then "" else pathSeparator)
                    + nameOfPath.
                
                sourcePathTester:setPath(fullSourcePath).
                if sourcePathTester:isDir() then do:
                    verifyCompilationNecessity(
                        sourcePathTester:getFullPath(),
                        pTargetPath + pathSeparator + nameOfPath,
                        pBasePath
                    ).
                end.
                else if sourcePathTester:isFile() and (
                    nameOfPath matches "*.p"
                    or nameOfPath matches "*.w"
                    or nameOfPath matches "*.cls"
                ) then do:
                    find first compiledFiles
                        where compiledFiles.pathSourceCode = fullSourcePath
                            and compiledFiles.folderTarget = pTargetPath
                        no-error.
                    
                    if not available compiledFiles then do:
                        create filesToCompile.
                        assign 
                            filesToCompile.pathSourceCode = fullSourcePath
                            filesToCompile.folderTarget = if nameOfPath matches "*.cls" then pBasePath else pTargetPath.
                        
                        create compiledFiles.
                        assign 
                            compiledFiles.pathSourceCode = fullSourcePath
                            compiledFiles.folderTarget = if nameOfPath matches "*.cls" then pBasePath else pTargetPath
                            compiledFiles.lastWriteTime = sourcePathTester:getLastWriteDateTime().
                        
                        ABLCompilerMessageFormatter:writeMessage(
                            "source code `" + filesToCompile.pathSourceCode + "`" 
                            + " requires compilation to target `" + filesToCompile.folderTarget + "`"
                        ).    
                    end.
                    else if compiledFiles.lastWriteTime <> sourcePathTester:getLastWriteDateTime() then do:
                        create filesToCompile.
                        assign 
                            filesToCompile.pathSourceCode = fullSourcePath
                            filesToCompile.folderTarget = if nameOfPath matches "*.cls" then pBasePath else pTargetPath.
                        
                        ABLCompilerMessageFormatter:writeMessage(
                            "source code `" + filesToCompile.pathSourceCode + "`" 
                            + " requires recompilation to target `" + filesToCompile.folderTarget + "`"
                        ).
                    end.
                    else do:
                        assign 
                            fullTargetPath = replace(fullSourcePath, ".p", ".r")
                            fullTargetPath = replace(fullTargetPath, ".cls", ".r")
                            fullTargetPath = replace(fullTargetPath, ".w", ".r").
                            
                        targetPathTester:setPath(fullTargetPath).
                        if not targetPathTester:pathExists() then do:
                            create filesToCompile.
                            assign 
                                filesToCompile.pathSourceCode = fullSourcePath
                                filesToCompile.folderTarget = if nameOfPath matches "*.cls" then pBasePath else pTargetPath.
                                
                            ABLCompilerMessageFormatter:writeMessage(
                                "source code `" + filesToCompile.pathSourceCode + "`" 
                                + " requires compilation to target `" + filesToCompile.folderTarget + "`"
                            ).
                        end.
                    end.
                end.
            end.
        input close.
    end method.
    
    method public void clearCompiler():
        empty temp-table sourceDirectories.
        empty temp-table targetDirectories.
        empty temp-table compiledFiles.
        empty temp-table filesToCompile.
        assign 
            compilationErrors = new JsonArray()
            hasSSHTarget = false
            compilationErrorsFilePath = "".
    end method.
end class.
