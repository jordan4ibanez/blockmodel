module tools.opengl_error_logger;

import std.stdio;
import std.conv: to;

import bindbc.opengl;
import bindbc.opengl.gl;


// Utilizes builder pattern

/// This is a wrapper class to emulate Vulkan style error toolchains
class OpenGLErrorLogger {

    GLenum error;

    private string helperTip = null;
    

    this() {
        
    }


    //** ----- BEGIN LOGGER TOOLS -----

    /// Allows inserting helpful tips into the error message
    OpenGLErrorLogger attachTip(string helperTip) {
        this.helperTip = helperTip;

        return this;
    }

    /**
    Put this at the end of the chain or else it does nothing.
    Having this as a separate function is useful for auto clearing on OpenGL context creation.
    */
    void execute() {

        // Accumulate it into a nice error log tailored EXACTLY to D's exception style

        string messageAccumulator = "OpenGL ERROR!\n";

        // writeln("OpenGL: ", , "!\n: ", );

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

/// This is an implicitly named variable to clear out the context of opengl
void clearOpenGLErrors() {
    // You can see this can just be instantiated without anything because it automatically performs it's task
    new OpenGLErrorLogger();
}