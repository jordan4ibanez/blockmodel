module texture.texture_container;

import std.stdio;
import bindbc.opengl;
import color;
import png;
import tools.gl_error;

/**
    Texture works as a singleton container.
    If you add all textures in at the beginning
    of the program, this becomes a cache.
*/
class TextureContainer {

    private static immutable GLuint invalid = GLuint.max;
    
    // The only instance of Texture container.
    private static TextureContainer instance;

    // Stores all textures as simple GLuint pointers. Accessed by file location.
    private GLuint[string] storage;
    
    //! Note: see about making a new texture object that has a protected flag?
    
    private this() {}

    /// Initialize the instance of the TextureContainer class.
    static void initialize() {
        if (instance is null){
            instance = new TextureContainer();
        }
    }
    
    /// Add a texture into the container.
    static GLuint addTexture(string fileLocation, bool debugEnabled = false) {

        checkInstance();

        if (fileLocation in instance.storage) {
            throw new Exception("Attempted to create a texture twice! Must be deleted first!");
        }

        // Use ADR's awesome framework library to convert the png into a raw data stream.
        TrueColorImage tempImageObject = readPng(fileLocation).getAsTrueColorImage();

        const int width = tempImageObject.width();
        const int height = tempImageObject.height();

        ubyte[] tempData = tempImageObject.imageData.bytes;

        // Now use the OpenGL framework to upload it.
        GLuint id;

        glGenTextures(1, &id);
        glBindTexture(GL_TEXTURE_2D, id);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, tempData.ptr);

        // Enable texture clamping to edge
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

        // Border color is nothing
        float[4] borderColor = [0,0,0,0];
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor.ptr);

        // Add in nearest neighbor texture filtering
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST/*_MIPMAP_NEAREST*/);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // glGenerateMipmap(GL_TEXTURE_2D);

        GLenum glErrorInfo = getAndClearGLErrors();
        if (glErrorInfo != GL_NO_ERROR) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN TEXTURE");

            throw new Exception("Failed to load texture!");
        }

        if (debugEnabled) {
            writeln(fileLocation, " is stored as ID: ", id);
        }

        // Finally cache the GL pointer ID as a GLuint
        instance.storage[fileLocation] = id;
        
        // Then return ID to make this even more flexible
        return id;
    }

    static GLuint getTexture(string fileLocation) {
        checkInstance();

        if (fileLocation !in instance.storage) {
            return invalid;
        }
        return instance.storage[fileLocation];
    }

    static void cleanUp() {
        checkInstance();

        foreach (string key, GLuint value; instance.storage) {
            glDeleteTextures(1, &value);

            writeln("TEXTURE ", value, " (" ~ key ~ ") HAS BEEN DELETED");
        }
    }

    private static void checkInstance() {
        if(instance is null) {
            throw new Exception("Texture was never initialized!");
        }
    }

}
