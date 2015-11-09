# :beginner: Love Shader Converter [![Build Status](https://javabilities.com/jenkins/job/Love%20Shader%20Converter/badge/icon)](https://javabilities.com/jenkins/job/Love%20Shader%20Converter/)
This is a pretty straight forrward program that simpily converts the GLSL used in the [Shader Toy](https://www.shadertoy.com/) which is based on ES; to a version of GLSL that can be used by [LÖVE ](https://love2d.org/), which is based on GLSL 1.2 with custom calls for lua.

## Releases
So far we only have builds for Windows (x32 & x64) and Linux, but none for Mac. So if you're on a mac and you want to use this application you will have to compile it yourself unfortunatly. If you are on a Windows or Linux system, you can check out our [releases](https://github.com/tsteinholz/LoveShaderConverter/releases) for the latest binaries.


## Legal
This Program is under the M.I.T License, but all the shaders you convert with this program are entitled to their own licenses with their own terms. Please do your best to not infringe upon any of their terms because you will be held accountable for it.

## Commands and Arguments Usage
To call the program you have to be using a command line (bat or shell script works)

    LoveShaderConverter <FileName>
  
This creates `<FileName>.bak` which contains the original code you copied from [Shader Toy](https://www.shadertoy.com/) and changes to contents of `<FileName>` to have the GLSL that can be easily used by [LÖVE ](https://love2d.org/).

On Windows, run the file `LoveShaderConverter.bat`, this will give you a working interface to the program.

# Quick Guide
Here is a quick guid / demo using the software and how to implent it in love.

### Step 1 : Go Shopping :handbag:
Go to [Shader Toys](https://www.shadertoy.com/) and pick out a shader you would like to implement. For this demo,
I chose [This Shader](https://www.shadertoy.com/view/Mss3WN).

![alt text](https://raw.githubusercontent.com/tsteinholz/LoveShaderConverter/master/docs/imgs/step-1.png "Step 1")

### Step 2 : Copy the Source :clipboard:

Of coure keep in mind licenses and do-not steal code. Only when a license permits you to, copy-and-paste the
entirety of the code.

![alt text](https://raw.githubusercontent.com/tsteinholz/LoveShaderConverter/master/docs/imgs/step-2.png "Step 2")

### Step 3 : Paste :pencil2:
Simply paste your clipboard to a file and save it as something.

![alt text](https://raw.githubusercontent.com/tsteinholz/LoveShaderConverter/master/docs/imgs/step-3.png "Step 3")

## Step 4: Convert :nut_and_bolt:
Here's the fun part. Make sure you have a download of this project somewhere you can use it, in the command line,
in a shell script, in a bat file, somewhere put down this command.

    LoveShaderConverter <FileName>

Of course replace <FileName> with the atcual file name in the correct directory etc. If you mess something up, the
application will notify you.

![alt text](https://raw.githubusercontent.com/tsteinholz/LoveShaderConverter/master/docs/imgs/step-4.png "Step 4")

## Step 5 : Integrate with Love 2D :bulb:
This is where the tutorial stops for you if you plan to implement anything diffrently, for this demo I am making
a window for the sole purpose of rendering this shader and nothing else. So on that note, you need to set up a new
Love2D project, make a `conf.lua` and `main.lua` and give the files the according methods.

![alt text](https://raw.githubusercontent.com/tsteinholz/LoveShaderConverter/master/docs/imgs/step-5.png "Step 5")

Lets start with our local variables. We are loading a shader so lets add
```lua
local shader
```
We are going to render the shader to a canvas
```lua
local canvas
```
The output from the conversion told us we need the time
```lua
local time = 0
```

Now lets implement the load function!
```lua
function love.load(arg)
    -- Load the shader from the file we generated
    shader = love.graphics.newShader('MetaHexaBalls.glsl')
    -- Create a new Canvas to draw to
    canvas = love.graphics.newCanvas(800, 600)
end
```

Next the Update Function
```lua    
function love.update(dt)
    -- increment our pseudo time variable
    time = dt + time;
    -- When converting, the following variables were requested from the shader...
    shader:send('iResolution', { love.window.getWidth(), love.window.getHeight(), 1 })
    shader:send('iGlobalTime', time)
    shader:send('iMouse', {love.mouse.getX(),love.mouse.getY(),love.mouse.getX(),love.mouse.getY()})
end
```

Last and definatly not least, the draw function
```lua
function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.setShader(shader)
    love.graphics.draw(canvas)
    love.graphics.setShader()
    love.graphics.setCanvas()

    love.graphics.draw(canvas,0,0,0,1,1,0,0)
end
```

Full [main.lua](https://github.com/tsteinholz/LoveShaderConverter/blob/master/docs/demo/main.lua) file can be found here.

### Step 6 : Hit that run button :8ball:
The moment you have been waiting for, a beautiful shader rendered by love2d. Have fun ;)

![alt text](https://raw.githubusercontent.com/tsteinholz/LoveShaderConverter/master/docs/imgs/step-6.png "Step 6")

## What is missing? / To do
 * Multi-channel support
 * Remove boost?
 * Official Builds on Mac
 * Add license terms and a modified change list in the header
 * Flags? For example...
 * Generate Love Project that renders shader with [-g:--generate] flag?
