

local trait = {
    co = {}
}

function trait.co:isempty () return #self.rdyQ == 0 end

local metatable = {
    co = {
        __index = trait.co
    }
}

local concurrent = {

    new = function ()
        local self = {
            rdyQ = {}
        }

        setmetatable (self, metatable.co)

        return self
    end
}


return concurrent