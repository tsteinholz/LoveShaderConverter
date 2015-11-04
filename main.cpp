/*/-----------------------------------------------------------------------------------------------------------------/*/
/*/                                                                                                                 /*/
/*/                                 ______________________________________                                          /*/
/*/                        ________|                                      |_______                                  /*/
/*/                        \       |     This file is a part of the       |      /                                  /*/
/*/                         \      |  Shadertoy to Love2D GLSL Converter  |     /                                   /*/
/*/                         /      |______________________________________|     \                                   /*/
/*/                        /__________)                                (_________\                                  /*/
/*/                                                                                                                 /*/
/*/                                    Copyright Last Stand Studio 2015                                             /*/
/*/                                                                                                                 /*/
/*/                                          The MIT License (MIT)                                                  /*/
/*/                                                                                                                 /*/
/*/                   Permission is hereby granted, free of charge, to any person obtaining a copy                  /*/
/*/                   of this software and associated documentation files (the "Software"), to deal                 /*/
/*/                   in the Software without restriction, including without limitation the rights                  /*/
/*/                   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell                     /*/
/*/                   copies of the Software, and to permit persons to whom the Software is                         /*/
/*/                   furnished to do so, subject to the following conditions:                                      /*/
/*/                                                                                                                 /*/
/*/                   The above copyright notice and this permission notice shall be included in                    /*/
/*/                   all copies or substantial portions of the Software.                                           /*/
/*/                                                                                                                 /*/
/*/                   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                    /*/
/*/                   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                      /*/
/*/                   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                   /*/
/*/                   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                        /*/
/*/                   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,                 /*/
/*/                   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN                     /*/
/*/                   THE SOFTWARE.                                                                                 /*/
/*/                                                                                                                 /*/
/*/                                                                                                                 /*/
/*/-----------------------------------------------------------------------------------------------------------------/*/

#include <boost/algorithm/string/replace.hpp>

#include <iostream>
#include <sstream>
#include <fstream>

using namespace std;

bool file_exist(const char *file)
{
    ifstream input(file);
    return input.good();
}

string load_file(const char *file)
{
    ifstream input(file);
    stringstream ss;

    while(input >> ss.rdbuf());

    return ss.str();
}

int main(int argc, char* argv[])
{
    char *file_name = argv[1];
    if (file_name != NULL)
    {
        string file_contents = load_file(file_name);
        if (file_exist(file_name) && file_contents != "")
        {
            cout << "Starting conversion!" << endl;
            string head = "",
                   tail = "vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){\n"
                           "    vec2 fragCoord = texture_coords * iResolution.xy;\n"
                           "    mainImage( color, fragCoord );\n"
                           "    return color;\n"
                           "}";

            cout << "Backing up original file to '" << file_name << ".bak'..." << endl;
            stringstream ss;
            ss << file_name << ".bak";
            ofstream output_bak(ss.str());
            output_bak << file_contents;

            cout << "Converting file to LOVE's format..." << endl;
            boost::replace_all(file_contents, "float", "number");
            boost::replace_all(file_contents, "samplerXX", "Image");
            boost::replace_all(file_contents, "texture2D", "Texel");

            cout << "You will need to send these variables to the shader:" << endl;
            if (file_contents.find("iResolution") != string::npos)
            {
                head += "extern vec3 iResolution;\n";
                cout << "\t- vec3    iResolution [viewport resolution (in pixels)]" << endl;
            }
            if (file_contents.find("iGlobalTime") != string::npos)
            {
                head += "extern number iGlobalTime;\n";
                cout << "\t- number  iGlobalTime [shader playback time (in seconds)]" << endl;
            }
            if (file_contents.find("iMouse") != string::npos)
            {
                head += "extern vec4 iMouse;\n";
                cout << "\t- vec4    iMouse [mouse pixel coords. xy: current (if MLB down), zw: click]" << endl;
            }
            if (file_contents.find("iChannel") != string::npos)
            {
                head += "extern Image iChannel\n";
                cout << "\t- Image   iChannel [input channel]" << endl;
            }

            ofstream output(file_name);
            output << head << "\n\n\n" << file_contents << "\n\n\n" << tail;
        }
        else cerr << "ERROR: File '" << file_name << "' does not exsit!" << endl;
    }
    else cerr << "ERROR: Usage is 'LoveShaderConverter <FileName>'" << endl;
    return 0;
}