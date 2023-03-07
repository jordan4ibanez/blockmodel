module gui.razor_font;

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

// A simple font container
private class RazorFont {

    // Font base pallet width
    int palletWidth  = 0;
    int palletHeight = 0;

    // Pixel space (literally) between characters in pallet
    int border = 0;

    // Number of characters
    int characterWidth  = 0;
    int characterHeight = 0;

    // Character pallet (individual) in pixels
    int characterPalletWidth  = 0;
    int characterPalletHeight = 0;
    
    // Readonly specifier if kerning was enabled
    bool kerned = false;

    // Readonly specifier if trimming was enabled
    bool trimmed = false;
}

/**
    Create a font from your PNG JSON pairing in the directory.

    You do not specify an extension.

    So if you have: cool.png and cool.json
    You would call this as createFont("fonts/cool")
    
    Name is an optional. You will call into Razor Font by this name.

    If you do not specify a name, you must call into RazorFont by the fileLocation, literal.
*/
void createFont(string fileLocation, string name = "") {

}