#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_action.h"
#include "argus_macros.h"
#include "argus_option.h"
#include "munit.h"
#include "test_optionfunc.h"
#include "test_parseactions.h"
#include "test_parseoptions.h"

// linker fix
extern argus_ActionFunction argus_Help;
argus_ActionFunction*       Help = &argus_Help;

#pragma clang diagnostic ignored "-Wunused-parameter"

MunitSuite g_suite = {
    .prefix = "Argus/",
    .tests  = NULL,
    .suites =
        (MunitSuite[]){
            {
                .prefix     = "OptionFuncs/",
                .tests      = g_OptionFunctionTests,
                .suites     = NULL,
                .iterations = 1,
                .options    = MUNIT_SUITE_OPTION_NONE,
            },

            /// end of array marker
            {NULL, NULL, NULL, 0, MUNIT_SUITE_OPTION_NONE},
        },
    .iterations = 1,
    .options    = MUNIT_SUITE_OPTION_NONE,
};

int main(int argc, char** argv)
{  //
    return munit_suite_main(&g_suite, NULL, argc, argv);
}
