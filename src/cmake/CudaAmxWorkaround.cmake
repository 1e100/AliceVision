# Centralized AMX workaround flags for CUDA builds.

function(av_get_cuda_amx_workaround_flags out_var)
    set(_flags "")
    set(_amx_fix_header "${CMAKE_SOURCE_DIR}/src/cuda_include_fix/amx_fix.h")
    if(EXISTS "${_amx_fix_header}")
        list(APPEND _flags
            "-Xcompiler=-mno-amx-tile"
            "-Xcompiler=-mno-amx-int8"
            "-Xcompiler=-mno-amx-bf16"
            "-Xcompiler=-include${_amx_fix_header}"
            "-Xcompiler=-Wno-unused-value"
        )
    endif()
    set(${out_var} "${_flags}" PARENT_SCOPE)
endfunction()
