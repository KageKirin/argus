#include "argus_option.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "argus_action.h"
#include "argus_macros.h"

static int showHelp(const argus_Option* options, unsigned options_count)
{
    // header
    argus_println("Help for %s %s", argus_programName, argus_actionName);

    // call help
    argus_println("call:");
    argus_printf("%s %s", argus_programName, argus_actionName);
    for (size_t i = 0; i < options_count; ++i)
    {
        const char* val = options[i].consume == &argus_setOptionImplicit ? "" : " <value>";
        if (options[i].shortname && options[i].longname)
        {
            argus_printf(" [-%c|--%s%s]", options[i].shortname, options[i].longname, val);
        }
        else if (options[i].shortname)
        {
            argus_printf(" [-%c%s]", options[i].shortname, val);
        }
        else if (options[i].longname)
        {
            argus_printf(" [--%s%s]", options[i].longname, val);
        }
        else
        {
            argus_printf(" <%s>", options[i].description);
        }
    }
    argus_printf("\n\n");


    // detail help
    argus_println("details:");
    argus_println("  -%c    --%-26s\t%s", 'h', "help", "show this message");
    int positional_args = 0;
    for (size_t i = 0; i < options_count; ++i)
    {
        if (options[i].shortname && options[i].longname)
        {
            argus_println("  -%c    --%-26s\t%s", options[i].shortname, options[i].longname, options[i].description);
        }
        else if (options[i].shortname)
        {
            argus_println("  -%c      %-26s\t%s", options[i].shortname, "", options[i].description);
        }
        else if (options[i].longname)
        {
            argus_println("        --%-26s\t%s", options[i].longname, options[i].description);
        }
        else
        {
            argus_println("positional %i%-22s\t%s", ++positional_args, "", options[i].description);
        }
    }
    return 0;
}

int argus_parseOptions(const argus_Option* options, unsigned options_count, int argc, char** argv)
{
    if (!argus_validateOptions(options, options_count))
    {
        argus_println("Invalid option setup for %s", argus_actionName);
        return argc;
    }

    // parse actual options (-, --) until '--' encountered or
    while (argc > 0)
    {
        size_t len = strlen(argv[0]);

        // special case for -h/--help
        if ((len == 2 && argv[0][0] == '-' && argv[0][1] == 'h') || (len == 6 && ARGUS_STRING_EQUALS("--help", &argv[0][0])))
        {
            showHelp(options, options_count);
            return argc;

            argc -= 1;
            argv += 1;
            break;
        }
        // single char arg
        else if (len == 2 && argv[0][0] == '-' && argv[0][1] != '-' && isalpha(argv[0][1]))
        {
            char     arg = argv[0][1];
            unsigned i   = 0;
            for (; i < options_count; ++i)
            {
                if (options[i].shortname == arg)
                {
                    options[i].consume(options[i].value, &argc, &argv);
                    break;
                }
            }

            if (i == options_count)
            {
                argus_println("No such short option '%s'", argv[0]);
                showHelp(options, options_count);
                return argc;
            }
        }
        // multi-char arg
        else if (len > 2 && argv[0][0] == '-' && argv[0][1] == '-')
        {
            char*    arg = &argv[0][2];
            unsigned i   = 0;
            for (; i < options_count; ++i)
            {
                if (options[i].longname && ARGUS_STRING_EQUALS(options[i].longname, arg))
                {
                    options[i].consume(options[i].value, &argc, &argv);
                    break;
                }
            }

            if (i == options_count)
            {
                argus_println("No such short option '%s'", argv[0]);
                showHelp(options, options_count);
                return argc;
            }
        }
        // check for 'end of options' -> '--'
        else if (len == 2 && argv[0][0] == '-' && argv[0][1] == '-')
        {
            argc--;
            argv++;
            break;
        }
        // natural 'end of options', i.e. next arg is not prefixed with '-|--
        else
        {
            break;
        }
    }

    // consume remaining arguments
    for (unsigned i = 0; i < options_count; ++i)
    {
        if (argc > 0)
        {
            // skip empty positional arguments
            while (*argv[0] == '\0')
            {
                argc--;
                argv++;
            }

            if (options[i].shortname == 0 && options[i].longname == NULL && options[i].consume)
            {
                options[i].consume(options[i].value, &argc, &argv);
            }
        }
    }

    if (argc > 0)
    {
        argus_println("Too many arguments: %d", argc);
        showHelp(options, options_count);
    }

    return argc;
}

int argus_validateOptions(const argus_Option* options, unsigned options_count)
{
    for (unsigned i = 0; i < options_count; ++i)
    {
        if (options[i].description == NULL)
        {
            argus_println("Option %d has no description", i);
        }

        if (options[i].consume == NULL)
        {
            argus_println("Option %d has no consume function", i);
            return 0;
        }
    }

    return 1;
}


int argus_setOptionImplicit(void* value, int* argc, char*** argv)
{
    if (value)
        *(int*)value = 1;
    *argc -= 1;
    *argv += 1;
    return 1;
}

int argus_setOptionExplicitInt(void* value, int* argc, char*** argv)
{
    if (value)
        *(int*)value = atoi((*argv)[1]);
    *argc -= 2;
    *argv += 2;
    return 2;
}

int argus_setOptionExplicitFloat(void* value, int* argc, char*** argv)
{
    if (value)
        *(float*)value = atof((*argv)[1]);
    *argc -= 2;
    *argv += 2;
    return 2;
}

int argus_setOptionExplicitDouble(void* value, int* argc, char*** argv)
{
    if (value)
        *(double*)value = strtod((*argv)[1], NULL);
    *argc -= 2;
    *argv += 2;
    return 2;
}

int argus_setOptionExplicitString(void* value, int* argc, char*** argv)
{
    if (value)
        *(char**)value = (*argv)[1];
    *argc -= 2;
    *argv += 2;
    return 2;
}

int argus_setOptionPositionalInt(void* value, int* argc, char*** argv)
{
    if (value)
        *(int*)value = atoi((*argv)[0]);
    *argc -= 1;
    *argv += 1;
    return 1;
}

int argus_setOptionPositionalFloat(void* value, int* argc, char*** argv)
{
    if (value)
        *(float*)value = atof((*argv)[0]);
    *argc -= 1;
    *argv += 1;
    return 1;
}

int argus_setOptionPositionalString(void* value, int* argc, char*** argv)
{
    if (value)
        *(char**)value = (*argv)[0];
    *argc -= 1;
    *argv += 1;
    return 1;
}

int argus_setOptionPositionalArguments(void* value, int* argc, char*** argv)
{
    if (value)
    {
        argus_Arguments* args = (argus_Arguments*)value;
        args->argc            = *argc;
        args->argv            = *argv;
    }

    *argv += *argc;
    *argc = 0;
    return 1;
}
