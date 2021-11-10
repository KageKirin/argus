// Example for Argus

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_action.h"
#include "argus_macros.h"
#include "argus_option.h"


typedef struct OptionValues_t
{
    int             int_value;
    int             implicit_value;
    float           float_value;
    char*           string_value;
    int             short_option;
    int             long_option;
    char*           argument;
    argus_Arguments tail;
} OptionValues_t;

static OptionValues_t g_OptionValues;

static const argus_Option g_Options[] = {
    {'e', "explicit", "explicitly set int value", &g_OptionValues.int_value, argus_setOptionExplicitInt},
    {'i', "implicit", "implicitly set int value", &g_OptionValues.implicit_value, argus_setOptionImplicit},
    {'f', "float", "explicitely set float value", &g_OptionValues.float_value, argus_setOptionExplicitFloat},
    {'s', "string", "explicitely set string value", &g_OptionValues.string_value, argus_setOptionExplicitString},
    {'x', 0, "short option only int", &g_OptionValues.short_option, argus_setOptionExplicitInt},
    {0, "longopt", "long option only int", &g_OptionValues.long_option, argus_setOptionExplicitInt},
    {.description = "argument value (string)", &g_OptionValues.argument, argus_setOptionPositionalString},
    {.description = "argument values (remaining strings)",
     &g_OptionValues.tail,
     argus_setOptionPositionalArguments},  //< consumes remaining args, so must come last
};


int main(int argc, char** argv)
{
    if (argus_parseOptions(g_Options, ARGUS_ARRAY_COUNT(g_Options), argc - 1, argv + 1))
    {
        /// error handling here.
        /// for simplicity, emulate call with "--help" argument
        argus_parseOptions(g_Options,
                           ARGUS_ARRAY_COUNT(g_Options),
                           1,
                           (char*[]){
                               "--help",
                           });
    }

    for (int i = 0; i < g_OptionValues.tail.argc; i++)
    {
        argus_println("args[%i]:\t '%s'", i, g_OptionValues.tail.argv[i]);
    }

    return 0;
}
