# Argus

Simple and low-overhead program argument parser in C.

## Usage example for simple options

Please refer to the [`examples/example_options.c`](https://github.com/KageKirin/argus/blob/main/examples/example_options.c)
for the full program, but the gist is as follows:

1. Define an array of `argus_Option` like this:

```C
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
```

`argus_Option` is a simple struct defined as follows:

```C
struct argus_Option
{
    const char shortname;     //< single char short option. e.g. '-o'
    const char* longname;     //< multi-char long option. e.g. '--option'
    const char* description;  //< description for help text
    void* const value;        //< pointer to value (for strings, that's a char** to pass)
    argus_OptionFuncPtr consume;    //< callback to consume arguments coming after
};
```

2. call `argus_parseOptions` by passing it the options array, its length (here through some small macro),
   and the arguments to parse, which start **after** the program name (`argv[0]`), i.e. at `argv[1]`.

Note that the argument count has to be decreased accordingly.

```C
int err = argus_parseOptions(g_Options, ARGUS_ARRAY_COUNT(g_Options), argc - 1, argv + 1);
```

This will automatically fill the values pointed to from `argus_Option.value` with their parsed value.

How the value is parsed depends on the `consume` callback (`argus_OptionFuncPtr`).
In the basic case, it's `sscanf` for integers/floats, and just a pointer set for strings (`char*`).

## Usage example for _action verbs_ and their respective options

Many command line programs combine multiple actions in a single tool (e.g. git with verbs being `init` or `add`),
with each action having its own set of options.

Please refer to the [`examples/example_actions.c`](https://github.com/KageKirin/argus/blob/main/examples/example_actions.c)
for the full program, but the gist is as follows:

1. Define an array of `argus_Action` pointing to a function to execute.

`argus_ActionFunction` has the same signature as main,
so that main can directly defer to the said action if needed.


```C
static argus_Action g_Actions[2] = {
    // clang-format off
    { "help",               "prints this message",   &example_Help }, //must be top
    { "hello",              "prints hello world",    &example_Hello },
    // clang-format on
};
```

2. For each `argus_ActionFunction`, define its own set of options, as an array

3. In each `argus_ActionFunction`, parse its `argus_Option` as in the example above.

## Runtime or global variables

The variables to parse can be created as globals or be created inside a specific scope at runtime.

TODO: example

## Combining options

Given the case that several actions share a common set of options,
while extending it with their own further options,
the `argus_Option` array passed to `argus_parseOptions` can be composited at runtime,
through a simple memcpy.

TODO: example
