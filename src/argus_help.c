#include "argus_help.h"

#include <stdio.h>
#include <string.h>

#include "argus_action.h"
#include "argus_macros.h"
#include "argus_option.h"

extern const argus_Action* argus_Actions;
extern unsigned            argus_ActionsCount;

int argus_Help_Zero(int argc, char** argv)
{
    argus_println("no help defined  for '%s'", argus_programName);
    argus_println("received %d args (%s)", argc, argv[0]);
    argus_println("call `%s <action> [options] [arguments]`\n", argus_programName);
    argus_println(
        "\nto get information about a specific action:\n"
        "`%s help <action>` or `%s <action> --help`",
        argus_programName,
        argus_programName);

    return 1;
}


int argus_Help(int argc, char** argv)
{
    char*              helpAction     = NULL;
    const argus_Option help_Options[] = {
        {.description = "action to get help on", &helpAction, argus_setOptionPositionalString},
    };

    argus_parseOptions(help_Options, ARGUS_ARRAY_COUNT(help_Options), argc - 1, argv + 1);

    if (helpAction)
    {
        // get --help menu from action
        static char argv_help[] = {"--help"};

        for (size_t i = 1; i < argus_ActionsCount; ++i)  // skip help
        {
            if (ARGUS_STRING_EQUALS(argus_Actions[i].verb, helpAction))
            {
                return argus_Actions[i].call(2, (char*[]){helpAction, argv_help});
            }
        }
        argus_println("No such action '%s'", helpAction);
        return 0;
    }


    argus_println("%s", argus_programName);
    argus_println("call `%s <action> [options] [arguments]`\n", argus_programName);
    argus_println("<action> be one of the following %llu:", (unsigned long long)argus_ActionsCount);

    for (size_t i = 0; i < argus_ActionsCount; ++i)
    {
        argus_println("\t%-20s\t%s", argus_Actions[i].verb, argus_Actions[i].desc);
    }

    argus_println(
        "\nto get information about a specific action:\n"
        "`%s help <action>` or `%s <action> --help`",
        argus_programName,
        argus_programName);

    return 0;
}
