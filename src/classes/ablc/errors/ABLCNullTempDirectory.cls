class classes.ablc.errors.ABLCNullTempDirectory inherits Progress.Lang.AppError:
    constructor ABLCNullTempDirectory():
        addMessage("the temp directory cannot be null or empty", -4602).
    end constructor.    
end class.
