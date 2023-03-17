module tools.log;

import std.stdio;
import std.conv: to;


// Utilizes builder pattern
// Utilizes struct so we don't have to call the "new" keyword

/// This is a wrapper struct to emulate Vulkan style error toolchains
struct OpenGLError {

    private string helperTip = null;
    private string openGlErrorType = null;
    private string openGlErrorMessage = null;


    /// Allows inserting helpful tips into the error message
    OpenGLError attachTip(string helperTip) {
        this.helperTip = helperTip;

        return this;
    }

    /// Attaches the OpenGL error type
    OpenGLError attachType(const(char)* openGlErrorType) {

        this.openGlErrorType = to!string(openGlErrorType);

        return this;
    }

    /// Attaches the OpenGL error message
    OpenGLError attachMessage(const(char)* openGlErrorMessage) {

        this.openGlErrorMessage = to!string(openGlErrorMessage);

        return this;
    }

    /// Put this at the end of the chain or else it does nothing
    void execute() {

        // Accumulate it into a nice error log tailored EXACTLY to D's exception style

        string messageAccumulator = "OpenGL ERROR!\n";

        // writeln("OpenGL: ", , "!\n: ", );

        

    }

}