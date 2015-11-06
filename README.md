# Love Shader Converter
This is a pretty straight forrward program that simpily converts the GLSL used in the [Shader Toy](https://www.shadertoy.com/) which is based on ES; to a version of GLSL that can be used by [LÖVE ](https://love2d.org/), which is based on GLSL 1.2 with custom calls.

## Legal
Please do everyone a favor (including yourself) and look at the licencing of the shader you are trying to use. Please do not steal others work, and then claim it as yours. If you see a licence that is open-source, free to use, go ahead. Just make sure to read the terms the owner put on the file. Only when the author has not added a licence to the header of the document can you assume it is in the Public Domain, and use it for what-ever.

## Commands and Arguments Usage
To call the program you have to be using a command line (bat or shell script works)

    LoveShaderConverter <FileName>
  
This creates `<FileName>.bak` which contains the original code you copied from [Shader Toy](https://www.shadertoy.com/) and changes to contents of `<FileName>` to have the GLSL that can be easily used by [LÖVE ](https://love2d.org/).

## What is missing?
 * Multi-channel support
 * Remove boost?
 * Official Builds (Windows, Mac)
 * Generate Love Project that renders picture optionaly with [-g:--generate] flag?
