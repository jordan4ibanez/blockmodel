module gui.razor_font;

import std.stdio;
import std.file;
import color;
import png;

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
private void delegate(string) renderTargetAPICallString = null;

// Allows DIRECT automatic upload into whatever render target (OpenGL, Vulkan, Metal, DX) as RAW data
private void delegate(ubyte[], int, int) renderTargetAPICallRAW = null;


/**
    Allows automatic render target (OpenGL, Vulkan, Metal, DX) passthrough instantiation.
    This can basically pass a file location off to your rendering engine and auto load it into memory.
*/
void setRenderTargetAPICallString(void delegate(string) apiStringFunction) {
    if (renderTargetAPICallRAW !is null) {
        throw new Exception("Razor Font: You already set the RAW api integration function!");
    }
    renderTargetAPICallString = apiStringFunction;
}


/**
    Allows automatic render target (OpenGL, Vulkan, Metal, DX) DIRECT instantiation.
    This allows the render engine to AUTOMATICALLY upload the image as RAW data.
    ubyte[] = raw data. int = width. int = height.
*/
void setRenderTargetAPICallRAW(void delegate(ubyte[], int, int) apiRAWFunction) {
    if (renderTargetAPICallString !is null) {
        throw new Exception("Razor Font: You already set the STRING api integration function!");
    }
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
    const string key = name == "" ? fileLocation : name;

    const string pngLocation = fileLocation ~ ".png";
    const string jsonLocation = fileLocation ~ ".json";

    // Make sure the files exist
    checkFilesExist(pngLocation, jsonLocation);

    // Automate existing engine integration
    tryCallingRAWApi(pngLocation);
    tryCallingStringApi(pngLocation);

    // Create the Font object
    RazorFont fontObject = new RazorFont();

    // Now parse the json
    

}


// Makes sure there's data where there should be
private void checkFilesExist(string pngLocation, string jsonLocation) {
    if (!exists(pngLocation)) {
        throw new Exception("Razor Font: " ~ pngLocation ~ " does not exist!");
    }

    if (!exists(jsonLocation)) {
        throw new Exception("Razor Font: " ~ jsonLocation ~ " does not exist!");
    }
}

//* ========================== BEGIN JSON DECODING ==================================
// Run through the required data to assemble a font object
void parseJson(ref RazorFont fontObject, const string jsonLocation) {
    
}


//!============================ END JSON DECODING ==================================

//* ========================== BEGIN API AGNOSTIC CALLS ============================
// Attempts to automate the api RAW call
private void tryCallingRAWApi(string fileLocation) {
    if (renderTargetAPICallRAW is null) {
        return;
    }

    // Use ADR's awesome framework library to convert the png into a raw data stream.
    TrueColorImage tempImageObject = readPng(fileLocation).getAsTrueColorImage();

    const int width = tempImageObject.width();
    const int height = tempImageObject.height();

    renderTargetAPICallRAW(tempImageObject.imageData.bytes, width, height);
}

// Attemps to automate the api String call
private void tryCallingStringApi(string fileLocation) {
    if (renderTargetAPICallString is null) {
        return;
    }
    
    renderTargetAPICallString(fileLocation);
}

//! ======================= END API AGNOSTIC CALLS ================================