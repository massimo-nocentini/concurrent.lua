

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>
#include <ctype.h>

#include <lua.h>
#include <lauxlib.h>

int l_lua_newthread(lua_State *L)
{
    lua_State *S = lua_newthread(L);
    return 1;
}

const struct luaL_Reg libconcurrentlua[] = {
    {"lua_newthread", l_lua_newthread},
    {NULL, NULL} /* sentinel */
};

int luaopen_libconcurrentlua(lua_State *L) // the initialization function of the module.
{
    luaL_newlib(L, libconcurrentlua);

    return 1;
}