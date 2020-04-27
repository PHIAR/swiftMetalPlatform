#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <vulkan/vulkan.h>

typedef struct spirv_descriptor_set_layout_t {
    char const *entry_point;
    VkDescriptorSetLayoutBinding *bindings;
    size_t bindingCount;
    VkPushConstantRange *pushConstants;
    size_t pushConstantCount;
} spirv_descriptor_set_layout_t;

#ifdef __cplusplus
extern "C" {
#endif

bool
spirvReflectCreateDescriptorSetLayout(uint32_t const *code,
                                      size_t length,
                                      spirv_descriptor_set_layout_t *descriptor_set_layout);

void
spirvReflectDestroyDescriptorSetLayout(spirv_descriptor_set_layout_t *descriptor_set_layout);

#ifdef __cplusplus
}
#endif
