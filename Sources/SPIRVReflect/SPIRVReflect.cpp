#include <vector>
#include <spirv_cross/spirv_cross.hpp>

#include "SPIRVReflect.h"

bool
spirvReflectCreateDescriptorSetLayout(uint32_t const *code,
                                      size_t length,
                                      spirv_descriptor_set_layout_t *descriptor_set_layout)
{
    auto const &spirv = std::vector <uint32_t> (code, code + length);
    auto &&compiler = spirv_cross::Compiler(spirv);
    auto &&activeInterfaceVariables = compiler.get_active_interface_variables();
    auto const &shaderResources = compiler.get_shader_resources();

    compiler.set_enabled_interface_variables(move(activeInterfaceVariables));

    auto const &entryPoints = compiler.get_entry_points_and_stages();
    auto const &specializationConstants = compiler.get_specialization_constants();
    auto const &storageBuffers = shaderResources.storage_buffers;

    printf("entryPoints: %zu\n", entryPoints.size());

    for (auto const &entryPoint: entryPoints) {
        printf("entryPoint: %s\n", entryPoint.name.c_str());
        printf("executionModel: %d\n", entryPoint.execution_model);
    }

    printf("specializationConstants: %zu\n", specializationConstants.size());

    for (auto const &specializationConstant: specializationConstants) {
        printf("specializationConstant: %s\n", compiler.get_name(specializationConstant.id).c_str());
        printf("constant id: %d\n", specializationConstant.constant_id);
        printf("binding: %d\n", compiler.get_decoration(specializationConstant.id,
                                                        spv::DecorationDescriptorSet));
        printf("location: %d\n", compiler.get_decoration(specializationConstant.id,
                                                         spv::DecorationLocation));
        printf("set: %d\n", compiler.get_decoration(specializationConstant.id,
                                                    spv::DecorationBinding));
    }

    printf("storageBuffers: %zu\n", storageBuffers.size());

    for (auto const &storageBuffer: storageBuffers) {
        printf("storageBuffers: %s\n", compiler.get_name(storageBuffer.id).c_str());
        printf("binding: %d\n", compiler.get_decoration(storageBuffer.id,
                                                        spv::DecorationDescriptorSet));
        printf("location: %d\n", compiler.get_decoration(storageBuffer.id,
                                                         spv::DecorationLocation));
        printf("set: %d\n", compiler.get_decoration(storageBuffer.id,
                                                    spv::DecorationBinding));
    }

    return true;
}

void
spirvReflectDestroyDescriptorSetLayout(spirv_descriptor_set_layout_t *descriptor_set_layout)
{
}

