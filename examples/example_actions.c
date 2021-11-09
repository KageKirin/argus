// Example for Argus

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_action.h"
#include "argus_macros.h"
#include "argus_option.h"

static int example_Help(int argc, char** argv);
static int example_Hello(int argc, char** argv);

static argus_Action g_Actions[2] = {
    // clang-format off
    { "help",               "prints this message",   &example_Help }, //must be top
    { "hello",              "prints hello world",    &example_Hello },
    // clang-format on
};


int example_Help(int argc, char** argv)
{
    static char argv_help[] = {"--help"};
    if (argc > 1)
    {
        for (size_t i = 1; i < ARGUS_ARRAY_COUNT(g_Actions); ++i)  // skip help
        {
            if (ARGUS_STRING_EQUALS(g_Actions[i].verb, argv[1]))
            {
                return g_Actions[i].call(2, (char*[]){argv[1], argv_help});
            }
        }
        argus_println("No such action '%s'", argv[1]);
    }

    argus_println("%s", argus_programName);
    argus_println("call `%s <action> [options] [arguments]`\n", argus_programName);
    argus_println("<action> be one of the following %llu:", (unsigned long long)ARGUS_ARRAY_COUNT(g_Actions));

    for (size_t i = 0; i < ARGUS_ARRAY_COUNT(g_Actions); ++i)
    {
        argus_println("\t%-20s\t%s", g_Actions[i].verb, g_Actions[i].desc);
    }

    argus_println(
        "\nto get information about a specific action:\n"
        "`%s help <action>` or `%s <action> --help`",
        argus_programName,
        argus_programName);

    return 0;
}


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

int example_Hello(int argc, char** argv)
{
    argus_println("Hello World, %d %s", argc, argv[0]);

    if (argus_parseOptions(g_Options, ARGUS_ARRAY_COUNT(g_Options), argc - 1, argv + 1))
    {
        return 1;
    }
    return 0;
}

argus_ActionFunction* Help = &example_Help;

int main(int argc, char** argv)
{
    if (!argus_parseActions(g_Actions, ARGUS_ARRAY_COUNT(g_Actions), argc, argv))
    {
        return 1;
    }
    return 0;
}
