#include "test_optionfunc.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_action.h"
#include "argus_macros.h"
#include "argus_option.h"
#include "munit.h"

static MunitResult test_argus_setOptionImplicit(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    const char *param = munit_parameters_get(params, "param");

    int   argc   = 1;
    char *argv[] = {
        (char *)param,
    };
    char **argv2  = argv;
    int    parsed = 0;

    argus_setOptionImplicit(&parsed, &argc, &argv2);

    munit_assert_int(parsed, ==, 1);

    return MUNIT_OK;
}

static MunitResult test_argus_setOptionExplicitInt(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    const char *param = munit_parameters_get(params, "param");
    const char *value = munit_parameters_get(params, "value");
    const int   val   = atoi(value);

    int   argc   = 2;
    char *argv[] = {
        (char *)param,
        (char *)value,
    };
    char **argv2  = argv;
    int    parsed = -1;

    argus_setOptionExplicitInt(&parsed, &argc, &argv2);

    munit_assert_int(parsed, ==, val);

    return MUNIT_OK;
}

static MunitResult test_argus_setOptionExplicitFloat(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    const char *param = munit_parameters_get(params, "param");
    const char *value = munit_parameters_get(params, "value");
    const float val   = atof(value);

    int   argc   = 2;
    char *argv[] = {
        (char *)param,
        (char *)value,
    };
    char **argv2  = argv;
    float  parsed = 0.1f;

    argus_setOptionExplicitFloat(&parsed, &argc, &argv2);

    munit_assert_float(parsed, ==, val);

    return MUNIT_OK;
}

static MunitResult test_argus_setOptionExplicitString(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    const char *param = munit_parameters_get(params, "param");
    const char *value = munit_parameters_get(params, "value");

    int   argc   = 2;
    char *argv[] = {
        (char *)param,
        (char *)value,
    };
    char **argv2  = argv;
    char * parsed = NULL;

    argus_setOptionExplicitString(&parsed, &argc, &argv2);

    munit_assert_not_null(parsed);
    munit_assert_string_equal(parsed, value);

    return MUNIT_OK;
}

//---

static MunitResult test_argus_setOptionPositionalInt(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    const char *value = munit_parameters_get(params, "value");
    const int   val   = atoi(value);

    int   argc   = 1;
    char *argv[] = {
        (char *)value,
    };
    char **argv2  = argv;
    int    parsed = -1;

    argus_setOptionPositionalInt(&parsed, &argc, &argv2);

    munit_assert_int(parsed, ==, val);

    return MUNIT_OK;
}

static MunitResult test_argus_setOptionPositionalFloat(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    const char *value = munit_parameters_get(params, "value");
    const int   val   = atoi(value);

    int   argc   = 1;
    char *argv[] = {
        (char *)value,
    };
    char **argv2  = argv;
    float  parsed = 0.0f;

    argus_setOptionPositionalFloat(&parsed, &argc, &argv2);

    munit_assert_float(parsed, ==, val);

    return MUNIT_OK;
}

static MunitResult test_argus_setOptionPositionalString(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    const char *value = munit_parameters_get(params, "value");

    int   argc   = 1;
    char *argv[] = {
        (char *)value,
    };
    char **argv2  = argv;
    char * parsed = NULL;

    argus_setOptionPositionalString(&parsed, &argc, &argv2);

    munit_assert_ptr_not_null(parsed);
    munit_assert_string_equal(parsed, value);

    return MUNIT_OK;
}

//---

MunitTest g_OptionFunctionTests[] = {
    {
        .name      = "/option/implicit",
        .test      = test_argus_setOptionImplicit,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"param", .values = (char *[]){"-f", "--foo", NULL}},
                {NULL, NULL},
            },
    },

    {
        .name      = "/option/explicit/int",
        .test      = test_argus_setOptionExplicitInt,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"param", .values = (char **)(const char *[]){"-f", "--foo", NULL}},
                {.name = (char *)"value", .values = (char **)(const char *[]){"0", "1", "42", "-1", NULL}},
                {NULL, NULL},
            },
    },

    {
        .name      = "/option/explicit/float",
        .test      = test_argus_setOptionExplicitFloat,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"param", .values = (char **)(const char *[]){"-f", "--foo", NULL}},
                {.name = (char *)"value", .values = (char **)(const char *[]){"0.0", "1.0", "42.0", "-1.0", NULL}},
                {NULL, NULL},
            },
    },

    {
        .name      = "/option/explicit/string",
        .test      = test_argus_setOptionExplicitString,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"param", .values = (char **)(const char *[]){"-f", "--foo", NULL}},
                {.name = (char *)"value", .values = (char **)(const char *[]){"abc", "DEF", "42.0", "-1", "", " ", NULL}},
                {NULL, NULL},
            },
    },

    {
        .name      = "/option/positional/int",
        .test      = test_argus_setOptionPositionalInt,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"value", .values = (char **)(const char *[]){"0", "1", "42", "-1", NULL}},
                {NULL, NULL},
            },
    },

    {
        .name      = "/option/positional/float",
        .test      = test_argus_setOptionPositionalFloat,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"value", .values = (char **)(const char *[]){"0.0", "1.0", "42.0", "-1.0", NULL}},
                {NULL, NULL},
            },
    },

    {
        .name      = "/option/positional/string",
        .test      = test_argus_setOptionPositionalString,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"value", .values = (char **)(const char *[]){"abc", "DEF", "42.0", "-1", " ", NULL}},
                {NULL, NULL},
            },
    },

    /// end of array marker
    {NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL},
};
