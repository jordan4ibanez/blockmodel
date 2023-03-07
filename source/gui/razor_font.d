module gui.razor_font;

import std.stdio;

//  ____________________________
// |         RAZOR FONT         |
// |____________________________|
//  \            /\            /
//  /            \/            \
// | The Sharpest Font Library  |
// |   For D Game Development   |
// |____________________________|


/**
Spec:

File format:
1. PNG with accompanying JSON in same directory. If these requirements are not met, it will throw an exception.

*/

private RazorFont[string] razorFonts;

// Allows an automatic upload into whatever render target (OpenGL, Vulkan, Metal, DX) as a string file location
private void delegate(string) renderTargetAPICallString;

// Allows DIRECT automatic upload into whatever render target (OpenGL, Vulkan, Metal, DX) as RAW data
private void delegate(ubyte[]) renderTargetAPICallRAW;


/**
    Allows automatic render target (OpenGL, Vulkan, Metal, DX) instantiation.
    This can basically pass a file location off to your rendering engine and auto load it into memory.
*/
void setRenderTargetAPICallString(void delegate(string) apiStringFunction) {
    renderTargetAPICallString = apiStringFunction;
}

void setRenderTargetAPICallRAW(void delegate(ubyte[]) apiRAWFunction) {
    renderTargetAPICallRAW = apiRAWFunction;
}




// A simple font container
private class RazorFont {

    // Font base pallet width
    int palletWidth  = 0;
    int palletHeight = 0;

    // Pixel space (literally) between characters in pallet
    int border = 0;

    // Number of characters (horizontal, aka Z)
    int rows    = 0;
    // Number of characters (vertical, aka Y)
    int columns = 0;

    // Character pallet (individual) in pixels
    int characterWidth  = 0;
    int charactertHeight = 0;
    
    // Readonly specifier if kerning was enabled
    bool kerned = false;

    // Readonly specifier if trimming was enabled
    bool trimmed = false;
}

/**
    Create a font from your PNG JSON pairing in the directory.

    You do not specify an extension.

    So if you have: cool.png and cool.json
    You would call this as: createFont("fonts/cool")
    
    Name is an optional. You will call into Razor Font by this name.

    If you do not specify a name, you must call into Razor Font by the fileLocation, literal.
*/
void createFont(string fileLocation, string name = "") {

    // Are we using the fileLocation as the key, or did they specify a name?
    string key = name == "" ? fileLocation : name;



}