
local libconcurrent = require 'libconcurrentlua'

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

local function dequeue (q) return table.remove (q, 1) end

function trait.co:isempty () return #self.rdyQ == 0 end

function trait.co:dispatch () coroutine.resume (dequeue (self.rdyQ)) end

function trait.co:yield ()
    if self:isempty () then
        error ('deadlock', 0)
    end
end

function trait.co:spawn (f)
    local co = coroutine.create (function ()        
        pcall (f)
        self:dispatch ()
    end)
    table.insert (self.rdyQ, co)
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

function trait.channel:recv ()
    if #self.sendQ == 0 then
        local co = coroutine.create (function (v) print ('***', v); self.co:dispatch () end)
        table.insert (self.recvQ, co)
        local flag, v = coroutine.resume (co)
        print ('---', flag, v)
        assert (flag, v)
        return v
    else
        return dequeue (self.sendQ)
    end
end

function trait.channel:send (v)
    if #self.recvQ == 0 then
        table.insert (self.sendQ, v)
    else
        local co = coroutine.create (function ()
            table.insert (self.co.rdyQ, co)
            coroutine.resume (dequeue (self.recvQ), v)
        end)
        coroutine.resume (co)
    end
end

local concurrent = {

    new = function ()
        local self = {
            rdyQ = {}
        }

        setmetatable (self, metatable.co)

        return self
    end,

    callcc = libconcurrent.callcc,
}


return concurrent