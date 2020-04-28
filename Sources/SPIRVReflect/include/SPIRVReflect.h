#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <vulkan/vulkan.h>

typedef struct spirv_push_constant_descriptor_t {
    size_t offset;
    size_t size;
} spirv_push_constant_descriptor_t;

typedef struct spirv_specialization_constant_t {
    uint32_t id;
    size_t offset;
    size_t size;
} spirv_specialization_constant_t;

typedef struct spirv_descriptor_set_layout_t {
    char const *entry_point;
    VkDescriptorSetLayoutBinding *bindings;
    size_t bindingCount;
    VkPushConstantRange pushConstantRange;
    spirv_push_constant_descriptor_t *pushConstantDescriptors;
    size_t pushConstantDescriptorCount;
    spirv_specialization_constant_t workgroupSize[3];
} spirv_descriptor_set_layout_t;

#ifdef __cplusplus
extern "C" {
#endif

bool
spirvReflectCreateDescriptorSetLayout(char const *entry_point,
                                      uint32_t const *code,
                                      size_t length,
                                      spirv_descriptor_set_layout_t *descriptor_set_layout_result);

void
spirvReflectDestroyDescriptorSetLayout(spirv_descriptor_set_layout_t *descriptor_set_layout);

#ifdef __cplusplus
}
#endif
