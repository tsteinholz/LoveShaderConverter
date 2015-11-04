# Love Shader Converter
This is a pretty straight forrward program that simpily converts the GLSL used in the [Shader Toy](https://www.shadertoy.com/) which is based on ES; to a version of GLSL that can be used by [LÖVE ](https://love2d.org/), which is based on GLSL 1.2 with custom calls.

## Commands and Arguments Usage
To call the program you have to be using a command line (bat or shell script works)

    LoveShaderConverter FILE-TO-CONVERT.glsl
  
This creates `FILE-TO-CONVERT.glsl.bak` which contains the original code you copied from [Shader Toy](https://www.shadertoy.com/) and changes to contents of `FILE-TO-CONVERT.glsl` to have the GLSL that can be easily used by [LÖVE ](https://love2d.org/).
