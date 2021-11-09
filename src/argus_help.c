#include "argus_help.h"

#include <stdio.h>

#include "argus_action.h"
#include "argus_macros.h"

int argus_Help(int argc, char** argv)
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
