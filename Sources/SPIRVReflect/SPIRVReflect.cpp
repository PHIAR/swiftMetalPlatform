#include <vector>
#include <spirv_cross/spirv_cross.hpp>

#include "SPIRVReflect.h"

bool
spirvReflectCreateDescriptorSet(uint32_t const *code,
                                size_t length,
                                spirv_descriptor_set_t *descriptor_set)
{
    auto const &spirv = std::vector <uint32_t> (code, code + length);
    auto const &compiler = spirv_cross::Compiler(spirv);

    return true;
}

void
spirvReflectDestroyDescriptorSet(spirv_descriptor_set_t *descriptor_set)
{
}

