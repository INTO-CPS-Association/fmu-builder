cmake_minimum_required (VERSION 2.6)

project (bouncingBall)
add_definitions( -DDISABLE_PREFIX )
add_library(bouncingBall SHARED sources/bouncingBall.c)

target_include_directories(bouncingBall PUBLIC fmi sources)

# Link the math library (m)
target_link_libraries(bouncingBall m)

set_target_properties(bouncingBall  PROPERTIES position_independent_code on, prefix "")

# Remove lib prefix from generated binary
SET_TARGET_PROPERTIES(bouncingBall PROPERTIES PREFIX "")

#fmi/fmi2FunctionTypes.h
#fmi/fmi2Functions.h
#fmi/fmi2TypesPlatform.h
#sources/all_CS.c
#sources/fmuTemplate_updated.h
#sources/fmuTemplate_updated.c
#sources/fmu_bBRef.c
