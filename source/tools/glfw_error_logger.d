module tools.glfw_error_logger;

import std.stdio;
import std.conv: to;

import bindbc.opengl;

// Shared library loader is acting as a static class
import Loader = bindbc.loader.sharedlib;
import bindbc.glfw.types;

class GLFWErrorLogger {

    GLFWSupport acquiredSupport;
    
    // This is the actual Exception that will MAYBE be thrown 
    // Starts off as the output in the end of the line in terminal
    string accumulator = "GLFW Error!\n";

    private string helperTip;
    private string[] glfwErrorMessageTypes;
    private string[] glfwErrorMessages;

    
    this() {

    }

    /// Allows inserting helpful tips into the error message
    GLFWErrorLogger attachTip(string helperTip) {
        this.helperTip = helperTip;
        return this;
    }

    /// Attaches the GLFW error type
    private void attachType(const(char)* openGlErrorType) {
        this.glfwErrorMessageTypes ~= to!string(openGlErrorType);
    }

    /// Attaches the GLFW error message
    private void attachMessage(const(char)* openGlErrorMessage) {
        this.glfwErrorMessages ~= to!string(openGlErrorMessage);
    }

    // Literally just inserts line seperators into the string accumulator
    private void line() {
        this.accumulator ~= "========================================";
    }

    // Automatically throws exception containing error output
    private void execute() {

        // This is a static field in the glfw module
        // If we have support, yay. We can just pretend this didn't happen
        if (acquiredSupport == glfwSupport) {
            return;
        }

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