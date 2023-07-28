#ifndef Simulator_H
#define Simulator_H

#include <lua.hpp>
#include <LuaBridge/LuaBridge.h>

namespace Ficsit_Networks::Simulator::Lua
{
    class Simulator { };

    extern "C" __declspec(dllexport) int luaopen_Ficsit_Networks_Simulator(lua_State *L)
    {
        printf("called luaopen\n");

        luabridge::getGlobalNamespace(L)
            .beginNamespace("Simulator")
                .addProperty("Test", "Hi Lol")
            .endNamespace();

        printf("exiting luaopen\n");

        return 0;
    }
}

#endif