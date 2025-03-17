class classes.ablc.errors.ABLCDirectoryDoesNotExist inherits Progress.Lang.AppError:
    constructor ABLCDirectoryDoesNotExist(pPath as character):
        addMessage('directory `' + pPath + '` was not found', -4500).
    end constructor.
end class.
