module tools.opengl_error_logger;

import std.stdio;
import std.conv: to;

import bindbc.opengl;
import bindbc.opengl.gl;


//! This one is for runtime OpenGL

// Utilizes builder pattern

/// This is a wrapper class to emulate Vulkan style error toolchains
class OpenGLErrorLogger {

    // This is just a fancy uint
    GLenum error;

    private string accumulator = "OpenGL ERROR!\n";

    private string helperTip = null;

    this() {
        this.getAndClearOpenGLErrors();
    }


    //** ----- BEGIN LOGGER TOOLS -----

    /// Allows inserting helpful tips into the error message
    OpenGLErrorLogger attachTip(string helperTip) {
        this.helperTip = helperTip;

        return this;
    }

    private string grabReadableErrorInfo() {
        /**
        This is from: https://learnopengl.com/In-Practice/Debugging

        I Highly recommend visiting this site, it's really good :)
        */
        
        switch (error) {
            case GL_INVALID_ENUM:                  return "INVALID_ENUM";
            case GL_INVALID_VALUE:                 return "INVALID_VALUE";
            case GL_INVALID_OPERATION:             return "INVALID_OPERATION";
            case GL_STACK_OVERFLOW:                return "STACK_OVERFLOW";
            case GL_STACK_UNDERFLOW:               return "STACK_UNDERFLOW";
            case GL_OUT_OF_MEMORY:                 return "OUT_OF_MEMORY";
            case GL_INVALID_FRAMEBUFFER_OPERATION: return "INVALID_FRAMEBUFFER_OPERATION";
            // Just pray you never see an unknown error in debugging I guess
            default:                               return "UNKNOWN";
        }

    }

    // Literally just inserts line seperators into the string accumulator
    private void line() {
        this.accumulator ~= "========================================";
    }


    /**
    Put this at the end of the chain or else it does nothing.
    Having this as a separate function is useful for auto clearing on OpenGL context creation.
    */
    void execute() {

        // Accumulate it into a nice error log tailored EXACTLY to D's exception style

        line();

        accumulator ~= "Direct Error Code: " ~ grabReadableErrorInfo() ~ "\n";

        line();

        if (helperTip !is null) {
            accumulator ~= helperTip ~ "\n";
        }

        // Prints it out as a nice helpful message
        throw new Exception(accumulator);
    }


    //!! ----- END LOGGER TOOLS -----

    //** ----- BEGIN OPENGL INTERFACE -----

    /**
    Automates the capture and reporting of OpenGL errors.
    This is very useful for OpenGL context creation.
    */
    private void getAndClearOpenGLErrors(){

        writeln("getting and clearing");

        this.error = glGetError();

        // Clear OpenGL errors
        while (glGetError() != GL_NO_ERROR) {
            glGetError();
        }
    }

    //!! ----- END OPENGL INTERFACE -----

}

/// This is an implicitly named function to clear out the context of opengl
void clearOpenGLErrors() {
    // You can see this can just be instantiated without anything because it automatically performs it's task
    new OpenGLErrorLogger();
}


//! This one is for the library loader

class OpenGLLoaderErrorLogger {
    
    // This is the actual Exception that will MAYBE be thrown 
    // Starts off as the output in the end of the line in terminal
    private string accumulator = "OpenGL Error!\n";

    private string helperTip;
    private string[] openGlErrorMessageTypes;
    private string[] openGlErrorMessages;

    
    this() {

    }

    /// Allows inserting helpful tips into the error message
    GLFWErrorLogger attachTip(string helperTip) {
        this.helperTip = helperTip;
        return this;
    }

    /// Attaches the GLFW error type
    private void attachType(const(char)* openGlErrorType) {
        this.openGlErrorMessageTypes ~= to!string(openGlErrorType);
    }

    /// Attaches the GLFW error message
    private void attachMessage(const(char)* openGlErrorMessage) {
        this.openGlErrorMessages ~= to!string(openGlErrorMessage);
    }

    // Literally just inserts line seperators into the string accumulator
    private void line() {
        this.accumulator ~= "========================================";
    }

    // Automatically throws exception containing error output
    void execute() {

        // Iterate the errors into a more usable form
        foreach(info; Loader.errors) {
            attachType(info.error);
            attachMessage(info.message);
        }

        line();

        // Now print out how many errors
        accumulator ~= "Error count: " ~ to!string(glfwErrorMessages.length) ~ "\n";

        line();

        // Now dump the actual errors in with nice separators
        foreach (i; 0..glfwErrorMessages.length) {
            accumulator ~= glfwErrorMessageTypes[i] ~ ": " ~ glfwErrorMessages[i];
            line();
        }


        // Ends with helper tip
        if (this.helperTip !is null) {
            accumulator ~= helperTip ~ "\n";
        }

        line();

        // Prints it out as a nice helpful message
        throw new Exception(accumulator);
    }
}