#ifndef ARGUSPP_HPP_INCL
#define ARGUSPP_HPP_INCL

extern "C"
{
    auto argus_setOptionImplicitBool(void* value, int* argc, char*** argv) -> int;
    auto argus_setOptionExplicitStdString(void* value, int* argc, char*** argv) -> int;
    auto argus_setOptionExplicitStdStringView(void* value, int* argc, char*** argv) -> int;
    auto argus_setOptionExplicitStdVectorOfInt(void* value, int* argc, char*** argv) -> int;
    auto argus_setOptionExplicitStdVectorOfStdString(void* value, int* argc, char*** argv) -> int;
    auto argus_setOptionExplicitStdVectorOfStdStringView(void* value, int* argc, char*** argv) -> int;
}

#endif  // ARGUSPP_HPP_INCL
