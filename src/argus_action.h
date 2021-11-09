#ifndef ARGUS_ACTION_H_INC
#define ARGUS_ACTION_H_INC

/// structures for 'action' parsing

//! callback function for action
//! like main()
typedef int(argus_ActionFunction)(int, char**);  // int argc, char** argv

//! structure for action
//! a 'named' callback
typedef struct argus_Action
{
    const char*           verb;  //< verb to call action witrh
    const char*           desc;  //< description for help text
    argus_ActionFunction* call;  //< callback
} argus_Action;

int argus_parseActions(const argus_Action* actions, unsigned actions_count, int argc, char** argv);

extern char*                 argus_actionName;
extern char*                 argus_programName;
extern argus_ActionFunction* Help;

#endif  // ARGUS_ACTION_H_INC
