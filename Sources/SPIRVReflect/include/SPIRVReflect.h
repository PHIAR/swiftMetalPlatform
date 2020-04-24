#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct spirv_descriptor_set_t {
} spirv_descriptor_set_t;

#ifdef __cplusplus
extern "C" {
#endif

bool
spirvReflectCreateDescriptorSet(uint32_t const *code,
                                size_t length,
                                spirv_descriptor_set_t *descriptor_set);

void
spirvReflectDestroyDescriptorSet(spirv_descriptor_set_t *descriptor_set);

#ifdef __cplusplus
}
#endif
