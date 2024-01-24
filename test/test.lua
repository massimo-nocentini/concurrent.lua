
local unittest = require "unittest"
local concurrent = require "concurrent"

local T = {}

function T:test1 ()
    local C = concurrent.new ()

    unittest.assert.istrue 'The initial queue should be empty' (C:isempty ())
end

function T:test_yield ()
    local C = concurrent.new ()

    local ok, error_msg = pcall (function () C:yield () end)

    unittest.assert.isfalse 'The initial queue should be empty' (ok)
    unittest.assert.equals 'Expected a deadlock' 'deadlock' (error_msg)
end


function T:rtest_nats_channel ()
    local C = concurrent.new ()

    local channel = C:channel ()

    local function count (i)
        while true do
            channel:send (i)
            i = i + 1
        end
    end

    C:spawn (function () count (0) end)

    local v = channel:recv ()

    unittest.assert.equals 'The first nats should be zero.' (0) (v)

end


function T:rtest_channel ()
    local C = concurrent.new ()

    local channel = C:channel ()

    local ok, error_msg = pcall (function () channel:recv () end)

    unittest.assert.istrue 'Cannot receive' (ok)
    unittest.assert.equals 'Expected a deadlock' 'deadlock' (error_msg)
end

function T:test_callcc_hop ()

    local v = concurrent.callcc (function (hop) return 1 + hop (2) end)

    unittest.assert.equals 'Expected 2' (2) (v)

end

function T:test_callcc_no_hop ()

    local v = concurrent.callcc (function (hop) return 1 + 2 end)

    unittest.assert.equals 'Expected 2' (3) (v)

end


local result = unittest.bootstrap.result ()

unittest.bootstrap.suite (T):run (T, result)

print (result)