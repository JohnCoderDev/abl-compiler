using progress.lang.AppError.

class ablc.third.json.errors.UnknownTypeInJson inherits AppError:
    constructor UnknownTypeInJson(pName as character):
          addMessage('unknown type with name ' + pName + ' in json object', -3500). 
    end constructor.
    
    constructor UnknownTypeInJson(pIndex as integer):
        addMessage('unknown type in position ' + string(pIndex) + ' in json array', -3501).
    end constructor.
end class.
