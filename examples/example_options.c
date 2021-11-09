// Example for Argus

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_action.h"
#include "argus_macros.h"
#include "argus_option.h"


typedef struct OptionValues_t
{
    int   int_value;
    int   implicit_value;
    float float_value;
    char* string_value;
    int   short_option;
    int   long_option;
    char* argument1;
    char* argument2;
    int   argument3;
    float argument4;
} OptionValues_t;

static OptionValues_t g_OptionValues;

static const argus_Option g_Options[] = {
    {'e', "explicit", "explicitly set int value", &g_OptionValues.int_value, argus_setOptionExplicitInt},
    {'i', "implicit", "implicitly set int value", &g_OptionValues.implicit_value, argus_setOptionImplicit},
    {'f', "float", "explicitely set float value", &g_OptionValues.float_value, argus_setOptionExplicitFloat},
    {'s', "string", "explicitely set string value", &g_OptionValues.string_value, argus_setOptionExplicitString},
    {'x', 0, "short option only int", &g_OptionValues.short_option, argus_setOptionExplicitInt},
    {0, "longopt", "long option only int", &g_OptionValues.long_option, argus_setOptionExplicitInt},
    {.description = "argument value 1 (string)", &g_OptionValues.argument1, argus_setOptionPositionalString},
    {.description = "argument value 2 (string)", &g_OptionValues.argument2, argus_setOptionPositionalString},
    {.description = "argument value 3 (int)", &g_OptionValues.argument3, argus_setOptionPositionalInt},
    {.description = "argument value 4 (float)", &g_OptionValues.argument4, argus_setOptionPositionalFloat},
};

argus_ActionFunction* Help = NULL;

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

    argus_println("passed int_value: %i", g_OptionValues.int_value);
    argus_println("passed implicit_value: %i", g_OptionValues.implicit_value);
    argus_println("passed float_value: %f", g_OptionValues.float_value);
    argus_println("passed string_value: %s", g_OptionValues.string_value);
    argus_println("passed short_option: %d", g_OptionValues.short_option);
    argus_println("passed long_option: %d", g_OptionValues.long_option);
    argus_println("passed argument1: %s", g_OptionValues.argument1);
    argus_println("passed argument2: %s", g_OptionValues.argument2);
    argus_println("passed argument3: %i", g_OptionValues.argument3);
    argus_println("passed argument4: %f", g_OptionValues.argument4);

    return 0;
}
