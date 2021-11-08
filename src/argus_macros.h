#ifndef ARGUS_MACROS_H_INC
#define ARGUS_MACROS_H_INC 1

#define ARGUS_ARRAY_COUNT(arr) (sizeof((arr)) / sizeof((arr)[0]))

#define ARGUS_STRING_EQUALS(a, b) (strcmp((a), (b)) == 0)

#ifndef argus_printf
#define argus_printf(str, ...) (printf(str, ##__VA_ARGS__))
#endif  // argus_printf

#ifndef argus_println
#define argus_println(str, ...) (printf(str "\n", ##__VA_ARGS__))
#endif  // argus_println

#endif  // ARGUS_MACROS_H_INC
