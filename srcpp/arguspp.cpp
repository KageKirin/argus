#include "arguspp.hpp"

#include <argus_option.h>

#include <string>
#include <vector>

auto argus_setOptionImplicitBool(void* value, int* argc, char*** argv) -> int
{
    if (value)
        *(bool*)value = 1;
    *argc -= 1;
    *argv += 1;
    return 1;
}

auto argus_setOptionExplicitStdString(void* value, int* argc, char*** argv) -> int
{
    if (value != nullptr)
    {
        std::string& str = *(static_cast<std::string*>(value));
        str              = (*argv)[1];
    }

    *argc -= 2;
    *argv += 2;
    return 2;
}

auto argus_setOptionExplicitStdStringView(void* value, int* argc, char*** argv) -> int
{
    if (value != nullptr)
    {
        std::string_view& str = *(static_cast<std::string_view*>(value));
        str                   = (*argv)[1];
    }

    *argc -= 2;
    *argv += 2;
    return 2;
}

auto argus_setOptionExplicitStdVectorOfInt(void* value, int* argc, char*** argv) -> int
{
    int count = 1;
    if (value != nullptr)
    {
        std::vector<uint8_t>& v = *(std::vector<uint8_t>*)(value);

        while (--(*argc) > 0 && (*(++(*argv)))[0] != '-')
        {
            v.push_back(std::atoi((*argv)[0]));
            count++;
        }
    }
    return count;
}

auto argus_setOptionExplicitStdVectorOfStdString(void* value, int* argc, char*** argv) -> int
{
    int count = 1;
    if (value != nullptr)
    {
        std::vector<std::string>& v = *(std::vector<std::string>*)value;
        while (--(*argc) > 0 && *(++(*argv))[0] != '-')
        {
            v.emplace_back((*argv)[0]);
            count++;
        }
    }

    return count;
}

auto argus_setOptionExplicitStdVectorOfStdStringView(void* value, int* argc, char*** argv) -> int
{
    int count = 1;
    if (value != nullptr)
    {
        std::vector<std::string_view>& v = *(std::vector<std::string_view>*)value;
        while (--(*argc) > 0 && *(++(*argv))[0] != '-')
        {
            v.emplace_back((*argv)[0]);
            count++;
        }
    }

    return count;
}
