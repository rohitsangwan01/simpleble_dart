#pragma once

#include "adapter.h"
#include "peripheral.h"
#include "export.h"

#ifdef __cplusplus
extern "C"
{
#endif

    /**
     * @brief Wrapper around free() to allow memory to be cleared
     *        within the library.
     *
     * @param handle
     */
    SIMPLEBLE_EXPORT void simpleble_free(void *handle);

#ifdef __cplusplus
}
#endif
