module gui.ttf;

import std.stdio;
import std.file;
import std.conv;


//* ========================== API ===================================

// This is at the top because this file could get huge
/// How you create a font
void createFont(string fileLocation, string name = "") {
    // Are we gonna use the name or the file location as the TTF key?
    string key = name == "" ? fileLocation : name;
    
    // We are assembling this font
    TTFont fontObject = new TTFont(fileLocation, name);


    fonts[key] = fontObject;

}

/// How you get render data from a font
//Todo;

//! ========================= END API ================================


//* ========================= INTERNAL ===============================
/// Stores all True Type Fonts into an easily accessable hashmap
private TTFont[string] fonts;


/// Stores True Type Font data in raw form
private class TTFBuffer {

    ubyte[] data;
    int cursor;
    int size;

    this(ubyte[] p, int size) {
        this.data = p;
        this.size = size;
        this.cursor = 0;
    }
}

/**
    A TrueType Font held in memory, this whole thing can't be accessed outside this module,
    so we don't care about privacy because you can't touch it.
    A font is also it's font info, self containerized.
    Collections are NOT supported. This is a gamedev library not an OS library.
*/
private class TTFont {

    /// Name of the font
    string name;

    /// Customizable user data
    ubyte[] userdata;

    // Location of .ttf file
    string fileLocation;

    ubyte[] rawData;

    // Number of glyphs, needed for range checking
    // int numGlyphs;

    // Table locations as offset from start of .ttf
    // int loca;
    // int head;
    // int glyf;
    // int hhea;
    // int hmtx;
    // int kern;
    // int gpos;


    // A cmap mapping for our chosen character encoding
    // int index_map;
    // Format needed to map from glyph index to glyph
    // int indexToLocFormat;
    
    // Cff font data
    // TTFBuffer cff;
    // // The charstring index
    // TTFBuffer charstrings;
    // // Global charstring subroutines index
    // TTFBuffer gsubrs;
    // // Private charstring subroutines index
    // TTFBuffer subrs;
    // // Array of font dicts
    // TTFBuffer fontdicts;
    // // Map from glyph to fontdict
    // TTFBuffer fdselect;

    /// Loads the font up from a directory with an optional name assignment
    this(string fileLocation, string name = "") {

        if (!exists(fileLocation)) {
            throw new Exception(fileLocation ~ " font does not exist!");
        }

        if (this.name == "") {
            this.name = fileLocation;
        } else {
            this.name = name;
        }

        this.fileLocation = fileLocation;

        // Start the chain of loader functions
        this.load();
    }

    void load() {

        // Assign in the raw binary data from the file
        this.rawData = cast(ubyte[])read(fileLocation);

        // Now process it

    }


    
}

//!========================================== END INTERNAL ============================================







//*========================================= FONT LOADING =====================================================


//!================================= END FONT LOADING ==========================================

enum {
    MACSTYLE_DONTCARE   = 0,
    MACSTYLE_BOLD       = 1,
    MACSTYLE_ITALIC     = 2,
    MACSTYLE_UNDERSCORE = 4,
    MACSTYLE_NONE       = 8,   // <= not same as 0, this makes us check the bitfield is 0
}

// PlatformID
enum {
    PLATFORM_ID_UNICODE   = 0,
    PLATFORM_ID_MAC       = 1,
    PLATFORM_ID_ISO       = 2,
    PLATFORM_ID_MICROSOFT = 3
}

// EncodingID for PLATFORM_ID_UNICODE
enum {
    UNICODE_EID_UNICODE_1_0      = 0,
    UNICODE_EID_UNICODE_1_1      = 1,
    UNICODE_EID_ISO_10646        = 2,
    UNICODE_EID_UNICODE_2_0_BMP  = 3,
    UNICODE_EID_UNICODE_2_0_FULL = 4
}

// EncodingID for PLATFORM_ID_MICROSOFT
enum {
    MS_EID_SYMBOL       = 0,
    MS_EID_UNICODE_BMP  = 1,
    MS_EID_SHIFTJIS     = 2,
    MS_EID_UNICODE_FULL = 10
}

// EncodingID for PLATFORM_ID_MAC; same as Script Manager codes
enum {
    MAC_EID_ROMAN        = 0,   MAC_EID_ARABIC  = 4,
    MAC_EID_JAPANESE     = 1,   MAC_EID_HEBREW  = 5,
    MAC_EID_CHINESE_TRAD = 2,   MAC_EID_GREEK   = 6,
    MAC_EID_KOREAN       = 3,   MAC_EID_RUSSIAN = 7
}


/**
    LanguageID for PLATFORM_ID_MICROSOFT; same as LCID
    Problematic because there are e.g. 16 english LCIDs and 16 arabic LCIDs
*/
enum {
    MS_LANG_ENGLISH = 0x0409,   MS_LANG_ITALIAN  = 0x0410,
    MS_LANG_CHINESE = 0x0804,   MS_LANG_JAPANESE = 0x0411,
    MS_LANG_DUTCH   = 0x0413,   MS_LANG_KOREAN   = 0x0412,
    MS_LANG_FRENCH  = 0x040c,   MS_LANG_RUSSIAN  = 0x0419,
    MS_LANG_GERMAN  = 0x0407,   MS_LANG_SPANISH  = 0x0409,
    MS_LANG_HEBREW  = 0x040d,   MS_LANG_SWEDISH  = 0x041D
}

// LanguageID for PLATFORM_ID_MAC
enum {
    MAC_LANG_ENGLISH = 0,    MAC_LANG_JAPANESE           = 11,
    MAC_LANG_ARABIC  = 12,   MAC_LANG_KOREAN             = 23,
    MAC_LANG_DUTCH   = 4,    MAC_LANG_RUSSIAN            = 32,
    MAC_LANG_FRENCH  = 1,    MAC_LANG_SPANISH            = 6,
    MAC_LANG_GERMAN  = 2,    MAC_LANG_SWEDISH            = 5,
    MAC_LANG_HEBREW  = 10,   MAC_LANG_CHINESE_SIMPLIFIED = 33,
    MAC_LANG_ITALIAN = 3,    MAC_LANG_CHINESE_TRAD       = 19
}
