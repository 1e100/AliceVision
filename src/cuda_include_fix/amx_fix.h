#ifndef _CUDA_AMX_FIX_H
#define _CUDA_AMX_FIX_H

// Define dummy versions of AMX builtins for CUDA compilation
#define __builtin_ia32_ldtilecfg(x) (0)
#define __builtin_ia32_sttilecfg(x) (0)

#endif
