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
    auto &&shaderStageFlags = VkShaderStageFlags();
    auto const &bindingCount = storageBuffers.size();
    auto &&bindingSlot = 0;

    descriptor_set_layout->bindingCount = bindingCount;
    descriptor_set_layout->bindings = static_cast <VkDescriptorSetLayoutBinding *> (malloc(bindingCount * sizeof(VkDescriptorSetLayoutBinding)));

    printf("entryPoints: %zu\n", entryPoints.size());

    for (auto const &entryPoint: entryPoints) {
        printf("entryPoint: %s\n", entryPoint.name.c_str());
        printf("executionModel: %d\n", entryPoint.execution_model);

        switch (entryPoint.execution_model) {
        case spv::ExecutionModel::ExecutionModelFragment:
            shaderStageFlags |= VK_SHADER_STAGE_FRAGMENT_BIT;
            break;

        case spv::ExecutionModel::ExecutionModelGLCompute:
            shaderStageFlags |= VK_SHADER_STAGE_COMPUTE_BIT;
            break;

        case spv::ExecutionModel::ExecutionModelVertex:
            shaderStageFlags |= VK_SHADER_STAGE_VERTEX_BIT;
            break;

        default:
            assert(false);
        }
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

        auto &descriptorSetLayoutBinding = descriptor_set_layout->bindings[bindingSlot];

        descriptorSetLayoutBinding.binding = bindingSlot;
        descriptorSetLayoutBinding.descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
        descriptorSetLayoutBinding.descriptorCount = 1;
        descriptorSetLayoutBinding.stageFlags = shaderStageFlags;
        ++bindingSlot;
    }

    return true;
}

void
spirvReflectDestroyDescriptorSetLayout(spirv_descriptor_set_layout_t *descriptor_set_layout)
{
    if (descriptor_set_layout->bindings) {
        free(descriptor_set_layout->bindings);
        descriptor_set_layout->bindings = nullptr;
    }

    descriptor_set_layout->bindingCount = 0;
}
