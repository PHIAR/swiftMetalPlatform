#include <cassert>
#include <vector>
#include <spirv_cross/spirv_cross.hpp>

#include "SPIRVReflect.h"

#define SPIRV_REFLECT_ENABLE_LOG false

bool
spirvReflectCreateDescriptorSetLayout(char const *entry_point,
                                      uint32_t const *code,
                                      size_t length,
                                      spirv_descriptor_set_layout_t *descriptor_set_layout_result)
{
    auto const &spirv = std::vector <uint32_t> (code, code + length);
    auto &descriptor_set_layout = *descriptor_set_layout_result;
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

    for (auto &&i = size_t(0); i < entryPoints.size(); ++i) {
        auto const &entryPoint = entryPoints[i];
        auto const &entryPointName = entryPoint.name;
        auto const &executionModel = entryPoint.execution_model;

    #if SPIRV_REFLECT_ENABLE_LOG
        printf("\n");
        printf("    entryPoint: %s\n", entryPointName.c_str());
        printf("    executionModel: %d\n", executionModel);
    #endif

        if (((entryPoints.size() == 1) &&
             (entryPointName == "main")) ||
            (entryPointName == entry_point)) {
            descriptor_set_layout.entry_point = strdup(entryPointName.c_str());
            compiler.set_entry_point(entryPointName,
                                     executionModel);

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

            break;
        }
    }

    descriptor_set_layout.bindingCount = bindingCount;
    descriptor_set_layout.bindings = static_cast <VkDescriptorSetLayoutBinding *> (calloc(bindingCount, sizeof(VkDescriptorSetLayoutBinding)));

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

        auto &descriptorSetLayoutBinding = descriptor_set_layout.bindings[bindingSlot];

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

        if (!bufferRanges.empty()) {
            auto const &bufferRange = bufferRanges[0];

        #if SPIRV_REFLECT_ENABLE_LOG
            printf("        index: %d\n", bufferRange.index);
            printf("        offset: %zu\n", bufferRange.offset);
            printf("        range: %zu\n", bufferRange.range);
        #endif

            descriptor_set_layout.pushConstantRange.offset = bufferRange.offset;
            descriptor_set_layout.pushConstantRange.size = bufferRange.range;
            descriptor_set_layout.pushConstantRange.stageFlags = shaderStageFlags;

            auto const &podStructType = compiler.get_type(pushConstant.base_type_id);
            auto const &podStructMemberCount = podStructType.member_types.size();

            assert(podStructMemberCount == 1);

        #if SPIRV_REFLECT_ENABLE_LOG
            printf("   podStruct: %s\n", compiler.get_name(pushConstant.id).c_str());
        #endif

            auto const &_podStructType = compiler.get_type(podStructType.member_types[0]);
            auto const &_podStructMemberCount = _podStructType.member_types.size();

            descriptor_set_layout.pushConstantDescriptors = static_cast <spirv_push_constant_descriptor_t *> (calloc(_podStructMemberCount, sizeof(spirv_push_constant_descriptor_t)));
            descriptor_set_layout.pushConstantDescriptorCount = _podStructMemberCount;

            for (auto &&j = size_t(0); j < _podStructMemberCount; ++j) {
                descriptor_set_layout.pushConstantDescriptors[j].offset = compiler.type_struct_member_offset(_podStructType, j);
                descriptor_set_layout.pushConstantDescriptors[j].size = compiler.get_declared_struct_member_size(_podStructType, j);

            #if SPIRV_REFLECT_ENABLE_LOG
                auto const &name = compiler.get_member_name(_podStructType.self, j);

                printf("        name: %s\n", name.c_str());
                printf("        index: %lu\n", j);
                printf("        size: %zu\n", descriptor_set_layout.pushConstantDescriptors[j].size);
                printf("        offset: %zu\n", descriptor_set_layout.pushConstantDescriptors[j].offset);
            #endif
            }
        }
    }

    return true;
}

void
spirvReflectDestroyDescriptorSetLayout(spirv_descriptor_set_layout_t *descriptor_set_layout)
{
    if (descriptor_set_layout->pushConstantDescriptors) {
        free(descriptor_set_layout->pushConstantDescriptors);
        descriptor_set_layout->pushConstantDescriptors = nullptr;
    }

    descriptor_set_layout->pushConstantDescriptorCount = 0;

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
