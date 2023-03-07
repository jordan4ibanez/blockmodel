module gui.ttf;

import std.stdio;
import std.file;
import std.conv;

/// Stores True Type Font data in raw form
private class TTFBuffer {

    ubyte[] data;
    int cursor;
    int size;

    this(ubyte[] p, int size) {
        // bytes 1_073_741_824 aka 1 gb (pretty much)
        assert(size < 0x40000000);
        this.data = p;
        this.size = size;
        this.cursor = 0;
    }
}

/// Stores all True Type Fonts into an easily accessable hashmap
private TTFont[string] buffers;

/// How you create a font
void createFont(string fileLocation, string name = "") {
    // Are we gonna use the name or the file location as the TTF key?
    string key = name == "" ? fileLocation : name;
    
    buffers[key] = new TTFont(fileLocation, name);
}

/// How you get render data from a font
//Todo;


/// A TrueType Font held in memory, this whole thing can't be accessed outside this module,
/// so we don't care about privacy because you can't touch it.
private class TTFont {

    /// This becomes consumed by the load() method
    TTFInfo fontInfo;

    /// Name of the font
    string name;

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

        ubyte[] ttfData = cast(ubyte[])read(fileLocation);

        this.load(ttfData, name, fileLocation);

    }
}



//*========================================= FONT LOADING =====================================================

/// Holds RAW font data inside of a TTFont object
private class TTFInfo {
    ubyte[] userdata;
    string fileLocation; // Location of .ttf file
    string name;         // Name of a font

    int numGlyphs;       // Number of glyphs, needed for range checking

    int loca, head, glyf, hhea, hmtx, kern, gpos; // table locations as offset from start of .ttf
    int index_map;                                // a cmap mapping for our chosen character encoding
    int indexToLocFormat;                         // format needed to map from glyph index to glyph
    
    TTFBuffer cff;                    // cff font data
    TTFBuffer charstrings;            // the charstring index
    TTFBuffer gsubrs;                 // global charstring subroutines index
    TTFBuffer subrs;                  // private charstring subroutines index
    TTFBuffer fontdicts;              // array of font dicts
    TTFBuffer fdselect;               // map from glyph to fontdict
}

//!================================= END FONT LOADING ==========================================

enum {
    MACSTYLE_DONTCARE   = 0,
    MACSTYLE_BOLD       = 1,
    MACSTYLE_ITALIC     = 2,
    MACSTYLE_UNDERSCORE = 4,
    MACSTYLE_NONE       = 8,   // <= not same as 0, this makes us check the bitfield is 0
}
enum { // platformID
    PLATFORM_ID_UNICODE   = 0,
    PLATFORM_ID_MAC       = 1,
    PLATFORM_ID_ISO       = 2,
    PLATFORM_ID_MICROSOFT = 3
}

enum { // encodingID for PLATFORM_ID_UNICODE
    UNICODE_EID_UNICODE_1_0      = 0,
    UNICODE_EID_UNICODE_1_1      = 1,
    UNICODE_EID_ISO_10646        = 2,
    UNICODE_EID_UNICODE_2_0_BMP  = 3,
    UNICODE_EID_UNICODE_2_0_FULL = 4
}

enum { // encodingID for PLATFORM_ID_MICROSOFT
    MS_EID_SYMBOL       = 0,
    MS_EID_UNICODE_BMP  = 1,
    MS_EID_SHIFTJIS     = 2,
    MS_EID_UNICODE_FULL = 10
}

enum { // encodingID for PLATFORM_ID_MAC; same as Script Manager codes
    MAC_EID_ROMAN        = 0,   MAC_EID_ARABIC  = 4,
    MAC_EID_JAPANESE     = 1,   MAC_EID_HEBREW  = 5,
    MAC_EID_CHINESE_TRAD = 2,   MAC_EID_GREEK   = 6,
    MAC_EID_KOREAN       = 3,   MAC_EID_RUSSIAN = 7
}

enum { // languageID for PLATFORM_ID_MICROSOFT; same as LCID...
       // problematic because there are e.g. 16 english LCIDs and 16 arabic LCIDs
    MS_LANG_ENGLISH = 0x0409,   MS_LANG_ITALIAN  = 0x0410,
    MS_LANG_CHINESE = 0x0804,   MS_LANG_JAPANESE = 0x0411,
    MS_LANG_DUTCH   = 0x0413,   MS_LANG_KOREAN   = 0x0412,
    MS_LANG_FRENCH  = 0x040c,   MS_LANG_RUSSIAN  = 0x0419,
    MS_LANG_GERMAN  = 0x0407,   MS_LANG_SPANISH  = 0x0409,
    MS_LANG_HEBREW  = 0x040d,   MS_LANG_SWEDISH  = 0x041D
}

enum { // languageID for PLATFORM_ID_MAC
    MAC_LANG_ENGLISH = 0,    MAC_LANG_JAPANESE           = 11,
    MAC_LANG_ARABIC  = 12,   MAC_LANG_KOREAN             = 23,
    MAC_LANG_DUTCH   = 4,    MAC_LANG_RUSSIAN            = 32,
    MAC_LANG_FRENCH  = 1,    MAC_LANG_SPANISH            = 6,
    MAC_LANG_GERMAN  = 2,    MAC_LANG_SWEDISH            = 5,
    MAC_LANG_HEBREW  = 10,   MAC_LANG_CHINESE_SIMPLIFIED = 33,
    MAC_LANG_ITALIAN = 3,    MAC_LANG_CHINESE_TRAD       = 19
}
