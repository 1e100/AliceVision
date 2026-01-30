if (NOT DEFINED SOURCE_DIR)
    message(FATAL_ERROR "PatchCMakeMinimum.cmake requires SOURCE_DIR")
endif()

set(_cmake_lists_candidates "")
foreach (_pattern
        "${SOURCE_DIR}/CMakeLists.txt"
        "${SOURCE_DIR}/*/CMakeLists.txt"
        "${SOURCE_DIR}/*/*/CMakeLists.txt"
        "${SOURCE_DIR}/*/*/*/CMakeLists.txt"
)
    file(GLOB _found LIST_DIRECTORIES false "${_pattern}")
    list(APPEND _cmake_lists_candidates ${_found})
endforeach()
list(REMOVE_DUPLICATES _cmake_lists_candidates)

if (NOT _cmake_lists_candidates)
    message(STATUS "No CMakeLists.txt found under ${SOURCE_DIR}, skipping patch.")
else()
    foreach (_cmake_lists IN LISTS _cmake_lists_candidates)
        file(READ "${_cmake_lists}" _cmake_contents)
        if (_cmake_contents MATCHES "[Cc][Mm][Aa][Kk][Ee]_[Mm][Ii][Nn][Ii][Mm][Uu][Mm]_[Rr][Ee][Qq][Uu][Ii][Rr][Ee][Dd]\\(VERSION[ \t]+([0-9]+\\.[0-9]+)")
            set(_current_version "${CMAKE_MATCH_1}")
            if (_current_version VERSION_LESS "3.25")
                string(REGEX REPLACE
                    "[Cc][Mm][Aa][Kk][Ee]_[Mm][Ii][Nn][Ii][Mm][Uu][Mm]_[Rr][Ee][Qq][Uu][Ii][Rr][Ee][Dd]\\(VERSION[ \t]+[^\\)]*\\)"
                    "cmake_minimum_required(VERSION 3.25)"
                    _cmake_contents
                    "${_cmake_contents}"
                )
                file(WRITE "${_cmake_lists}" "${_cmake_contents}")
                message(STATUS "Patched ${_cmake_lists} minimum from ${_current_version} to 3.25")
            else()
                message(STATUS "CMake minimum ${_current_version} already >= 3.25 in ${_cmake_lists}")
            endif()
        endif()

        if (_cmake_contents MATCHES "[Cc][Mm][Aa][Kk][Ee]_[Pp][Oo][Ll][Ii][Cc][Yy]\\(VERSION[ \t]+([0-9]+\\.[0-9]+)\\)")
            set(_policy_version "${CMAKE_MATCH_1}")
            if (_policy_version VERSION_LESS "3.25")
                string(REGEX REPLACE
                    "[Cc][Mm][Aa][Kk][Ee]_[Pp][Oo][Ll][Ii][Cc][Yy]\\(VERSION[ \t]+[^\\)]*\\)"
                    "cmake_policy(VERSION 3.25)"
                    _cmake_contents
                    "${_cmake_contents}"
                )
                file(WRITE "${_cmake_lists}" "${_cmake_contents}")
                message(STATUS "Patched ${_cmake_lists} policy version from ${_policy_version} to 3.25")
            endif()
        endif()

        if (_cmake_contents MATCHES "[Cc][Mm][Aa][Kk][Ee]_[Pp][Oo][Ll][Ii][Cc][Yy]\\(SET[ \t]+CMP0048[ \t]+OLD\\)")
            string(REGEX REPLACE
                "[Cc][Mm][Aa][Kk][Ee]_[Pp][Oo][Ll][Ii][Cc][Yy]\\(SET[ \t]+CMP0048[ \t]+OLD\\)"
                "cmake_policy(SET CMP0048 NEW)"
                _cmake_contents
                "${_cmake_contents}"
            )
            file(WRITE "${_cmake_lists}" "${_cmake_contents}")
            message(STATUS "Patched ${_cmake_lists} to set CMP0048 NEW")
        endif()
    endforeach()
endif()

set(_ocio_yaml_install "${SOURCE_DIR}/share/cmake/modules/install/Installyaml-cpp.cmake")
if (EXISTS "${_ocio_yaml_install}")
    file(READ "${_ocio_yaml_install}" _ocio_yaml_contents)
    if (NOT _ocio_yaml_contents MATCHES "CMAKE_POLICY_VERSION_MINIMUM")
        string(REPLACE
            "-DCMAKE_POLICY_DEFAULT_CMP0063=NEW"
            "-DCMAKE_POLICY_DEFAULT_CMP0063=NEW\n            -DCMAKE_POLICY_VERSION_MINIMUM=3.25"
            _ocio_yaml_contents
            "${_ocio_yaml_contents}"
        )
        file(WRITE "${_ocio_yaml_install}" "${_ocio_yaml_contents}")
        message(STATUS "Patched ${_ocio_yaml_install} to set CMAKE_POLICY_VERSION_MINIMUM=3.25")
    else()
        message(STATUS "CMAKE_POLICY_VERSION_MINIMUM already set in ${_ocio_yaml_install}")
    endif()
endif()

set(_openexr_cmake "${SOURCE_DIR}/cmake/CMakeLists.txt")
if (EXISTS "${_openexr_cmake}")
    file(READ "${_openexr_cmake}" _openexr_contents)
    set(_openexr_updated FALSE)
    if (_openexr_contents MATCHES "::Config ALIAS IexConfig")
        string(REPLACE "::Config ALIAS IexConfig" "::IexConfig ALIAS IexConfig" _openexr_contents "${_openexr_contents}")
        set(_openexr_updated TRUE)
    endif()
    if (_openexr_contents MATCHES "::Config ALIAS IlmThreadConfig")
        string(REPLACE "::Config ALIAS IlmThreadConfig" "::IlmThreadConfig ALIAS IlmThreadConfig" _openexr_contents "${_openexr_contents}")
        set(_openexr_updated TRUE)
    endif()
    if (_openexr_updated)
        file(WRITE "${_openexr_cmake}" "${_openexr_contents}")
        message(STATUS "Patched ${_openexr_cmake} to avoid duplicate OpenEXR::Config aliases")
    endif()
endif()
