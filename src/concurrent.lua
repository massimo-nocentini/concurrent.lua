
local libconcurrent = require 'libconcurrentlua'

local concurrent = {
    
    callcc = libconcurrent.callcc,
}

local trait = {
    co = {},
    channel = {},
}

local metatable = {
    co = {
        __index = trait.co
    },
    channel = {
        __index = trait.channel
    }
}

function concurrent.new ()
    local self = {
        rdyQ = {}
    }

    setmetatable (self, metatable.co)

    return self
end


local function dequeue (q) return table.remove (q, 1) end

function trait.co:isempty () return #self.rdyQ == 0 end

function trait.co:dispatch () return dequeue (self.rdyQ) () end

function trait.co:yield ()
    if self:isempty () then
        error ('deadlock', 0)
    end
end

function trait.co:spawn (f)
    local thread = concurrent.callcc (function (k1) 
        concurrent.callcc (function (k2) return k1 (k2) end)
        pcall (f)
        self:dispatch ()
    end)

    table.insert (self.rdyQ, thread)
end

function trait.co:channel ()
    local channel = {
        co = self,
        sendQ = {},
        recvQ = {},
    }
    setmetatable (channel, metatable.channel)
    return channel
end

function trait.channel:send (v)
    if #self.recvQ == 0 then table.insert (self.sendQ, v)
    else
        concurrent.callcc (function (k)
            table.insert (self.co.rdyQ, k)
            dequeue (self.recvQ) (v)
        end)
    end
end

function trait.channel:recv ()
    if #self.sendQ == 0 then
        return concurrent.callcc (function (k)
            table.insert (self.recvQ, k)
            self.co:dispatch ()
        end)
    else
        return dequeue (self.sendQ)
    end
end

return concurrent