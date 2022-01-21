#ifndef ARGUS_OPTION_H_INC
#define ARGUS_OPTION_H_INC

/// structures for 'option' parsing

//! callback function for option
//! 'consumes' following arguments
//! modifies values pointed to by argc, argv passed into it
//! returns number of arguments consumed
typedef int (*argus_OptionFuncPtr)(void* value, int*, char***);  // int* argc, char*** argv

int argus_setOptionImplicit(void* value, int* argc, char*** argv);
int argus_setOptionExplicitInt(void* value, int* argc, char*** argv);
int argus_setOptionExplicitFloat(void* value, int* argc, char*** argv);
int argus_setOptionExplicitDouble(void* value, int* argc, char*** argv);
int argus_setOptionExplicitString(void* value, int* argc, char*** argv);
int argus_setOptionPositionalInt(void* value, int* argc, char*** argv);
int argus_setOptionPositionalFloat(void* value, int* argc, char*** argv);
int argus_setOptionPositionalDouble(void* value, int* argc, char*** argv);
int argus_setOptionPositionalString(void* value, int* argc, char*** argv);
int argus_setOptionPositionalArguments(void* value, int* argc, char*** argv);

//! structure for option
//! a 'named' callback
typedef struct argus_Option
{
    const char          shortname;    //< single char short option. e.g. '-o'
    const char*         longname;     //< multi-char long option. e.g. '--option'
    const char*         description;  //< description for help text
    void* const         value;        //< pointer to value
    argus_OptionFuncPtr consume;      //< callback to consume arguments coming after
} argus_Option;

//! structure for positional strings
typedef struct argus_Arguments
{
    int    argc;  //< argument count
    char** argv;  //< point to arguments
} argus_Arguments;

int argus_parseOptions(const argus_Option* options, unsigned options_count, int argc, char** argv);
int argus_validateOptions(const argus_Option* options, unsigned options_count);

#endif  // ARGUS_OPTION_H_INC
