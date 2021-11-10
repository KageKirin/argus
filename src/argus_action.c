#include "argus_action.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_macros.h"

char* argus_actionName  = "";
char* argus_programName = "";

const argus_Action* argus_Actions      = NULL;
unsigned            argus_ActionsCount = 0;

extern argus_ActionFunction argus_Help;
argus_ActionFunction*       argus_Help_Override = NULL;

int argus_parseActions(const argus_Action* actions, unsigned actions_count, int argc, char** argv)
{
    argus_programName  = argv[0];
    argus_Actions      = actions;
    argus_ActionsCount = actions_count;

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
        argus_Help_Override ? argus_Help_Override(argc, argv) : argus_Help(argc, argv);
        return 1;
    }

    return argus_Help_Override ? argus_Help_Override(argc, argv) : argus_Help(argc, argv);
}
