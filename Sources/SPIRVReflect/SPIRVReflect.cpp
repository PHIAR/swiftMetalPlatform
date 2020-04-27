#include <vector>
#include <spirv_cross/spirv_cross.hpp>

#include "SPIRVReflect.h"

#define SPIRV_REFLECT_ENABLE_LOG false

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
    auto const &pushConstants = shaderResources.push_constant_buffers;
    auto &&shaderStageFlags = VkShaderStageFlags();
    auto const &bindingCount = storageBuffers.size();
    auto const &pushConstantCount = pushConstants.size();
    auto &&bindingSlot = 0;

    descriptor_set_layout->entry_point = strdup(entryPoints[0].name.c_str());
    descriptor_set_layout->bindingCount = bindingCount;
    descriptor_set_layout->bindings = static_cast <VkDescriptorSetLayoutBinding *> (malloc(bindingCount * sizeof(VkDescriptorSetLayoutBinding)));
    descriptor_set_layout->pushConstantCount = pushConstantCount;
    descriptor_set_layout->pushConstants = static_cast <VkPushConstantRange *> (malloc(pushConstantCount * sizeof(VkPushConstantRange)));

#if SPIRV_REFLECT_ENABLE_LOG
    printf("\n");
    printf("entryPoints: %zu\n", entryPoints.size());
#endif

    assert(entryPoints.size() == 1);

    for (auto const &entryPoint: entryPoints) {
    #if SPIRV_REFLECT_ENABLE_LOG
        printf("    entryPoint: %s\n", entryPoint.name.c_str());
        printf("    executionModel: %d\n", entryPoint.execution_model);
    #endif

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

#if SPIRV_REFLECT_ENABLE_LOG
    printf("specializationConstants: %zu\n", specializationConstants.size());
#endif

    for (auto const &specializationConstant: specializationConstants) {
    #if SPIRV_REFLECT_ENABLE_LOG
        printf("    specializationConstant: %s\n", compiler.get_name(specializationConstant.id).c_str());
        printf("        constant id: %d\n", specializationConstant.constant_id);
        printf("        binding: %d\n", compiler.get_decoration(specializationConstant.id,
                                                                spv::DecorationDescriptorSet));
        printf("        location: %d\n", compiler.get_decoration(specializationConstant.id,
                                                                 spv::DecorationLocation));
        printf("        set: %d\n", compiler.get_decoration(specializationConstant.id,
                                                            spv::DecorationBinding));
    #endif
    }

#if SPIRV_REFLECT_ENABLE_LOG
    printf("storageBuffers: %zu\n", storageBuffers.size());
#endif

    for (auto const &storageBuffer: storageBuffers) {
    #if SPIRV_REFLECT_ENABLE_LOG
        printf("    storageBuffer: %s\n", compiler.get_name(storageBuffer.id).c_str());
        printf("        binding: %d\n", compiler.get_decoration(storageBuffer.id,
                                                                spv::DecorationDescriptorSet));
        printf("        location: %d\n", compiler.get_decoration(storageBuffer.id,
                                                                 spv::DecorationLocation));
        printf("        set: %d\n", compiler.get_decoration(storageBuffer.id,
                                                            spv::DecorationBinding));
    #endif

        auto &descriptorSetLayoutBinding = descriptor_set_layout->bindings[bindingSlot];

        descriptorSetLayoutBinding.binding = bindingSlot;
        descriptorSetLayoutBinding.descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
        descriptorSetLayoutBinding.descriptorCount = 1;
        descriptorSetLayoutBinding.stageFlags = shaderStageFlags;
        ++bindingSlot;
    }

#if SPIRV_REFLECT_ENABLE_LOG
    printf("pushConstants: %zu\n", pushConstants.size());
#endif

    for (auto const &pushConstant: pushConstants) {
    #if SPIRV_REFLECT_ENABLE_LOG
        printf("   pushConstants: %s\n", compiler.get_name(pushConstant.id).c_str());
    #endif

        auto const &bufferRanges = compiler.get_active_buffer_ranges(pushConstant.id);

        for (auto const &bufferRange: bufferRanges) {
            auto &_pushConstant = descriptor_set_layout->pushConstants[bufferRange.index];

        #if SPIRV_REFLECT_ENABLE_LOG
            printf("        index: %d\n", bufferRange.index);
            printf("        offset: %zu\n", bufferRange.offset);
            printf("        range: %zu\n", bufferRange.range);
        #endif

            _pushConstant.offset = bufferRange.offset;
            _pushConstant.size = bufferRange.range;
            _pushConstant.stageFlags = shaderStageFlags;
        }
    }

    return true;
}

void
spirvReflectDestroyDescriptorSetLayout(spirv_descriptor_set_layout_t *descriptor_set_layout)
{
    if (descriptor_set_layout->pushConstants) {
        free(descriptor_set_layout->pushConstants);
        descriptor_set_layout->pushConstants = nullptr;
    }

    descriptor_set_layout->pushConstants = 0;

    if (descriptor_set_layout->bindings) {
        free(descriptor_set_layout->bindings);
        descriptor_set_layout->bindings = nullptr;
    }

    descriptor_set_layout->bindingCount = 0;

    if (descriptor_set_layout->entry_point) {
        free(const_cast <char *> (descriptor_set_layout->entry_point));
        descriptor_set_layout->entry_point = nullptr;
    }
}
