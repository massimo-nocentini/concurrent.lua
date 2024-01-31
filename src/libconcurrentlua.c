

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>
#include <ctype.h>

#include <lua.h>
#include <lauxlib.h>

int l_lua_yield(lua_State *L)
{
    lua_State *S = lua_tothread(L, 1);

    int n = lua_gettop(L) - 1; /* number of values to yield */
    lua_xmove(L, S, n);        /* move values to the destination thread */

    return lua_yield(S, n);
}

int k(lua_State *L, int status, lua_KContext ctx)
{
    printf("k\n");
    return lua_gettop(L);
}

int callcc_closure(lua_State *L)
{
    luaL_checktype(L, lua_upvalueindex(1), LUA_TTHREAD);
    luaL_checktype(L, lua_upvalueindex(2), LUA_TFUNCTION);

    lua_yield(L, 0);

    return 0;

    lua_State *co = lua_tothread(L, lua_upvalueindex(1));
    lua_pushvalue(L, lua_upvalueindex(2));

    // Move the function and its arguments to the new coroutine
    lua_xmove(L, co, lua_gettop(L) - 1);

    // Resume the coroutine immediately
    int nres;
    int status = lua_resume(co, L, 1, &nres);

    lua_xmove(co, L, nres);

    // lua_resetthread(co);

    if (status == LUA_YIELD)
    {
        // If the coroutine yielded, return its result
        return nres;
    }
    else if (status == LUA_OK)
    {
        // If the coroutine finished, return its result
        return nres;
    }
    else
    {
        // If there was an error, throw it
        return luaL_error(L, "error running coroutine: %s", lua_tostring(co, -1));
    }

    luaL_checktype(L, lua_upvalueindex(1), LUA_TFUNCTION); // the receiver function.
    return lua_yield(L, lua_gettop(L));
}

int __l_callcc(lua_State *L)
{
    lua_pushvalue(L, 1);
    lua_pushcclosure(L, &callcc_closure, 1);

    lua_callk(L, 1, LUA_MULTRET, 0, k);

    return LUA_MULTRET;
}

int l_callcc(lua_State *L)
{
    // Check that the first argument is a function
    luaL_checktype(L, 1, LUA_TFUNCTION);
    luaL_checktype(L, 2, LUA_TFUNCTION); // the receiver function.

    // Create a new coroutine with the function as its body
    lua_State *co = lua_newthread(L);
    lua_pushvalue(L, 2);

    lua_pushcclosure(L, callcc_closure, 2); // both the thread and the receiver function are upvalues.
    lua_remove(L, 2);

    assert(lua_gettop(L) == 2);

    lua_call(L, 1, LUA_MULTRET);

    return lua_gettop(L);
}

const struct luaL_Reg libconcurrentlua[] = {
    {"yield", l_lua_yield},
    {"callcc", l_callcc},
    {NULL, NULL} /* sentinel */
};

int luaopen_libconcurrentlua(lua_State *L) // the initialization function of the module.
{
    luaL_newlib(L, libconcurrentlua);

    return 1;
}