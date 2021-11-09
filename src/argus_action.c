#include "argus_action.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_macros.h"

char* argus_actionName  = "";
char* argus_programName = "";

extern argus_ActionFunction* Help;
extern argus_ActionFunction  argus_Help;

int argus_parseActions(const argus_Action* actions, unsigned actions_count, int argc, char** argv)
{
    argus_programName = argv[0];

    if (argc > 1)
    {
        for (size_t i = 0; i < actions_count; ++i)
        {
            if (ARGUS_STRING_EQUALS(actions[i].verb, argv[1]))
            {
                // set action name
                argus_actionName = argv[1];

                return actions[i].call(argc - 1, argv + 1);
            }
        }

        argus_println("No such action '%s'", argv[1]);
        Help ? Help(argc, argv) : argus_Help(argc, argv);
        return 1;
    }

    return Help ? Help(argc, argv) : argus_Help(argc, argv);
}
