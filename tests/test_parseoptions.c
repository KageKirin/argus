#include "test_parseoptions.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_action.h"
#include "argus_macros.h"
#include "argus_option.h"
#include "munit.h"


static MunitResult test_argus_parseOptions_Implicit(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    int                parsed    = 0;
    const argus_Option options[] = {
        {'f', "foo", "implicitly set int value", &parsed, argus_setOptionImplicit},
    };

    const char *param = munit_parameters_get(params, "param");

    int   argc   = 1;
    char *argv[] = {
        (char *)param,
    };

    const int ret = argus_parseOptions(options, ARGUS_ARRAY_COUNT(options), argc, argv);

    munit_assert_int(ret, ==, 0);
    munit_assert_int(parsed, ==, 1);

    return MUNIT_OK;
}

static MunitResult test_argus_parseOptions_ExplicitInt(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    int                parsed    = -1;
    const argus_Option options[] = {
        {'f', "foo", "explicitly set int value", &parsed, argus_setOptionExplicitInt},
    };

    const char *param = munit_parameters_get(params, "param");
    const char *value = munit_parameters_get(params, "value");
    const int   val   = atoi(value);

    int   argc   = 2;
    char *argv[] = {
        (char *)param,
        (char *)value,
    };

    const int ret = argus_parseOptions(options, ARGUS_ARRAY_COUNT(options), argc, argv);

    munit_assert_int(ret, ==, 0);
    munit_assert_int(parsed, ==, val);

    return MUNIT_OK;
}

static MunitResult test_argus_parseOptions_ExplicitFloat(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    float              parsed    = 0.1f;
    const argus_Option options[] = {
        {'f', "foo", "explicitly set float value", &parsed, argus_setOptionExplicitFloat},
    };

    const char *param = munit_parameters_get(params, "param");
    const char *value = munit_parameters_get(params, "value");
    const float val   = atof(value);

    int   argc   = 2;
    char *argv[] = {
        (char *)param,
        (char *)value,
    };

    const int ret = argus_parseOptions(options, ARGUS_ARRAY_COUNT(options), argc, argv);

    munit_assert_int(ret, ==, 0);
    munit_assert_float(parsed, ==, val);

    return MUNIT_OK;
}

static MunitResult test_argus_parseOptions_ExplicitString(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    char *             parsed    = NULL;
    const argus_Option options[] = {
        {'f', "foo", "explicitly set string value", &parsed, argus_setOptionExplicitString},
    };

    const char *param = munit_parameters_get(params, "param");
    const char *value = munit_parameters_get(params, "value");

    int   argc   = 2;
    char *argv[] = {
        (char *)param,
        (char *)value,
    };

    const int ret = argus_parseOptions(options, ARGUS_ARRAY_COUNT(options), argc, argv);

    munit_assert_int(ret, ==, 0);
    munit_assert_not_null(parsed);
    munit_assert_string_equal(parsed, value);

    return MUNIT_OK;
}

//---

static MunitResult test_argus_parseOptions_PositionalInt(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    int                parsed    = -1;
    const argus_Option options[] = {
        {.description = "positional int value", &parsed, argus_setOptionPositionalInt},
    };

    const char *separator = munit_parameters_get(params, "separator");
    const char *value     = munit_parameters_get(params, "value");
    const int   val       = atoi(value);

    int   argc   = 2;
    char *argv[] = {
        (char *)separator,
        (char *)value,
    };

    const int ret = argus_parseOptions(options, ARGUS_ARRAY_COUNT(options), argc, argv);

    munit_assert_int(ret, ==, 0);
    munit_assert_int(parsed, ==, val);

    return MUNIT_OK;
}

static MunitResult test_argus_parseOptions_PositionalFloat(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    float              parsed    = 0.1f;
    const argus_Option options[] = {
        {.description = "positional float value", &parsed, argus_setOptionPositionalFloat},
    };

    const char *separator = munit_parameters_get(params, "separator");
    const char *value     = munit_parameters_get(params, "value");
    const float val       = atof(value);

    int   argc   = 2;
    char *argv[] = {
        (char *)separator,
        (char *)value,
    };

    const int ret = argus_parseOptions(options, ARGUS_ARRAY_COUNT(options), argc, argv);

    munit_assert_int(ret, ==, 0);
    munit_assert_float(parsed, ==, val);

    return MUNIT_OK;
}

static MunitResult test_argus_parseOptions_PositionalString(const MunitParameter params[], void *fixture)
{
    (void)fixture;

    char *             parsed    = NULL;
    const argus_Option options[] = {
        {.description = "positional string value", &parsed, argus_setOptionPositionalString},
    };

    const char *separator = munit_parameters_get(params, "separator");
    const char *value     = munit_parameters_get(params, "value");

    int   argc   = 2;
    char *argv[] = {
        (char *)separator,
        (char *)value,
    };

    const int ret = argus_parseOptions(options, ARGUS_ARRAY_COUNT(options), argc, argv);

    munit_assert_int(ret, ==, 0);
    munit_assert_not_null(parsed);
    munit_assert_string_equal(parsed, value);

    return MUNIT_OK;
}

//---

MunitTest g_ParseOptionTests[] = {
    {
        .name      = "/option/implicit",
        .test      = test_argus_parseOptions_Implicit,
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
        .test      = test_argus_parseOptions_ExplicitInt,
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
        .test      = test_argus_parseOptions_ExplicitFloat,
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
        .test      = test_argus_parseOptions_ExplicitString,
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
        .test      = test_argus_parseOptions_PositionalInt,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"separator", .values = (char **)(const char *[]){"", "--", NULL}},
                {.name = (char *)"value", .values = (char **)(const char *[]){"0", "1", "42", "-1", NULL}},
                {NULL, NULL},
            },
    },

    {
        .name      = "/option/positional/float",
        .test      = test_argus_parseOptions_PositionalFloat,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"separator", .values = (char **)(const char *[]){"", "--", NULL}},
                {.name = (char *)"value", .values = (char **)(const char *[]){"0.0", "1.0", "42.0", "-1.0", NULL}},
                {NULL, NULL},
            },
    },

    {
        .name      = "/option/positional/string",
        .test      = test_argus_parseOptions_PositionalString,
        .setup     = NULL,
        .tear_down = NULL,
        .options   = MUNIT_TEST_OPTION_NONE,
        .parameters =
            (MunitParameterEnum[]){
                {.name = (char *)"separator", .values = (char **)(const char *[]){"", "--", NULL}},
                {.name = (char *)"value", .values = (char **)(const char *[]){"abc", "DEF", "42.0", "-1", " ", NULL}},
                {NULL, NULL},
            },
    },

    /// end of array marker
    {NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL},
};
