module gui.razor_font;

import std.stdio;
import std.conv;
import std.file;
import std.json;
import std.typecons;
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

    // Font base pallet width (in pixels)
    int palletWidth  = 0;
    int palletHeight = 0;

    // Pixel space (literally) between characters in pallet
    int border = 0;

    // Number of characters (horizontal, aka Z)
    int rows    = 0;
    // Number of characters (vertical, aka Y)
    int columns = 0;

    // Character pallet (individual) in pixels
    int characterWidth   = 0;
    int charactertHeight = 0;
    
    // Readonly specifier if kerning was enabled
    bool kerned = false;

    // Readonly specifier if trimming was enabled
    bool trimmedX = false;
    bool trimmedY = false;

    // Character map - stored as a linear associative array for O(1) retrieval
    /**
        Stores as:
        [
            -x -y,
            -x +y, 
            +x +y,
            +x -y
        ]
        or this, if it's easier to understand:
        [
            top    left,
            bottom left,
            bottom right,
            top    right
        ]
        GPU optimized vertex positions!

        Accessed as:
        double[] myCoolBlah = map["whatever letter/unicode thing you're getting"];

        The last 2 values specify width and height
    */
    double[10][string] map;

    // Stores the map raw as a linear array before processed
    string rawMap;
}

/**
    Create a font from your PNG JSON pairing in the directory.

    You do not specify an extension.

    So if you have: cool.png and cool.json
    You would call this as: createFont("fonts/cool")
    
    Name is an optional. You will call into Razor Font by this name.

    If you do not specify a name, you must call into Razor Font by the fileLocation, literal.

    You can trim the height (X) or width (Y) or both if you want.
*/
void createFont(string fileLocation, string name = "", bool kerning = false, bool trimmingX = false, bool trimmingY = false) {

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

    // Now parse the json, and pass it into object
    parseJson(fontObject, jsonLocation);

    // Now encode the linear string as a keymap of raw graphics positions
    encodeGraphics(fontObject, kerning, trimmingX, trimmingY);

    //!Debug
    // writeln(fontObject.map);

}

//* ============================ BEGIN GRAPHICS DISPATCH ===========================

Tuple!(double[], "vertexData", double[], "textureData", int[], "indices") debugRender() {
    double[] blah = [1,2,3];
    double[] moreBlah = [1,1,1];
    int[] evenMoreBlah = [1,2,3,4];
    return tuple!("vertexData", "textureData", "indices")(blah, moreBlah, evenMoreBlah);
}



//! ============================ END GRAPHICS DISPATCH =============================

//* ========================= BEGIN GRAPHICS ENCODING ==============================

void encodeGraphics(ref RazorFont fontObject, bool kerning, bool trimmingX, bool trimmingY) {
    
    // Store all this on the stack

    // Total image size
    const double palletWidth = cast(double)fontObject.palletWidth;
    const double palletHeight = cast(double)fontObject.palletHeight;

    // How many characters (width, then height)
    const int rows = fontObject.rows;
    const int columns = fontObject.columns;

    // How wide and tall are the characters in pixels
    const int characterWidth = fontObject.characterWidth;
    const int characterHeight = fontObject.charactertHeight;

    // The border between the characters in pixels
    const int border = fontObject.border;


    foreach (size_t i, immutable(char) value; fontObject.rawMap) {

        // Turn off annoying casting suggestions
        const int index = cast(int) i;

        // Now get where the typewriter is
        const int currentRow = (index % rows);
        const int currentColum = index / columns;

        // Now get literal pixel position (top left)
        int intPosX = (characterWidth + border) * currentRow;
        int intPosY = (characterHeight + border) * currentColum;

        //! I'm not sure what's going to be the easiest way to go about this
        //! So I'm dividing my dividends
        
        // left  top,
        // left  bottom,
        // right bottom,
        // right top

        // Now shovel it into a raw array so we can easily use it - iPos stands for Integral Positions
        int[] iPos = [
            intPosX,                  intPosY,                   // Top left
            intPosX,                  intPosY + characterHeight, // Bottom left
            intPosX + characterWidth, intPosY + characterHeight, // Bottom right
            intPosX + characterWidth, intPosY,                    // Top right
            
            characterWidth, characterHeight // Width and height
        ];

        // Now calculate limiters
        const int minX = intPosX;
        const int maxX = intPosX + characterWidth;

        const int minY = intPosY;
        const int maxY = intPosY + characterHeight;


        // Now trim it if suggested
        if (trimmingX) {
            writeln("trim trim trim");
            
        }

        // Now calculate REAL graphical texture map
        double[10] glPositions  = [
            iPos[0] / palletWidth, iPos[1] / palletHeight, 
            iPos[2] / palletWidth, iPos[3] / palletHeight,
            iPos[4] / palletWidth, iPos[5] / palletHeight,
            iPos[6] / palletWidth, iPos[7] / palletHeight,

            iPos[8], iPos[9]
        ];
        // writeln("-------------------");
        // writeln(glPositions[0..2]);
        // writeln(glPositions[2..4]);
        // writeln(glPositions[4..6]);
        // writeln(glPositions[6..8]);

        // writeln(glPositions[8..10]);

        // Now dump it into the dictionary
        fontObject.map[to!string(value)] = glPositions;
    }
}





//! ========================= END GRAPICS ENCODING ================================ 


//* ========================== BEGIN JSON DECODING ==================================
// Run through the required data to assemble a font object
void parseJson(ref RazorFont fontObject, const string jsonLocation) {
    void[] rawData = read(jsonLocation);
    string jsonString = cast(string)rawData;
    JSONValue jsonData = parseJSON(jsonString);

    foreach (string key,JSONValue value; jsonData.objectNoRef) {
        switch(key) {
            case "pallet_width": {
                assert(value.type == JSONType.integer);
                fontObject.palletWidth = cast(int)value.integer;
                break;
            }
            case "pallet_height": {
                assert(value.type == JSONType.integer);
                fontObject.palletHeight = cast(int)value.integer;
                break;
            }
            case "border": {
                assert(value.type == JSONType.integer);
                fontObject.border = cast(int)value.integer;
                break;
            }
            case "rows": {
                assert(value.type == JSONType.integer);
                fontObject.rows = cast(int)value.integer;
                break;
            }
            case "columns": {
                assert(value.type == JSONType.integer);
                fontObject.columns = cast(int)value.integer;
                break;
            }
            case "character_width": {
                assert(value.type == JSONType.integer);
                fontObject.characterWidth = cast(int)value.integer;
                break;
            }
            case "charactert_height": {
                assert(value.type == JSONType.integer);
                fontObject.charactertHeight = cast(int)value.integer;
                break;
            }
            case "character_map": {
                assert(value.type == JSONType.string);
                fontObject.rawMap = value.str;
                break;
            }
            default: // Unknown
        }
    }
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

//* ===================== BEGIN ETC FUNCTIONS ===============================


// Makes sure there's data where there should be
private void checkFilesExist(string pngLocation, string jsonLocation) {
    if (!exists(pngLocation)) {
        throw new Exception("Razor Font: " ~ pngLocation ~ " does not exist!");
    }

    if (!exists(jsonLocation)) {
        throw new Exception("Razor Font: " ~ jsonLocation ~ " does not exist!");
    }
}

//! ===================== END ETC FUNCTIONS =====================================