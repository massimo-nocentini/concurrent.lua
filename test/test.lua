
local unittest = require "unittest"
local concurrent = require "concurrent"

local T = {}

function T:test1 ()
    local C = concurrent.new ()

    unittest.assert.istrue 'The initial queue should be empty' (C:isempty ())
end

local result = unittest.bootstrap.result ()

unittest.bootstrap.suite (T):run (T, result)

print (result)