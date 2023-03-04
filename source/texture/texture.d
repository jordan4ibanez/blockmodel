module texture.texture;

import std.stdio;
import bindbc.opengl;
import color;
import png;
import tools.gl_error;

/// Texture works as a singleton container.
class Texture {
    
    private static Texture instance;

    static Texture getInstance() {
        if (instance is null){
            instance = new Texture();
        }
        return instance;
    }
}

/// TextureObject creates OpenGL data and stores the information for future utilization.
private class TextureObject {

    private static const bool debugEnabled = true;

    private GLuint id = 0;
    private GLuint width = 0;
    private GLuint height = 0;

    private string name;

    this(string textureLocation) {

        this.name = textureLocation;

        TrueColorImage tempImageObject = readPng(textureLocation).getAsTrueColorImage();

        this.width = tempImageObject.width();
        this.height = tempImageObject.height();

        ubyte[] tempData = tempImageObject.imageData.bytes;

        glGenTextures(1, &this.id);
        glBindTexture(GL_TEXTURE_2D, this.id);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, this.width, this.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, tempData.ptr);

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
    }

    GLuint getId() {
        return this.id;
    }

    string getName() {
        return this.name;
    }

    void cleanUp() {
        glDeleteTextures(1, &this.id);
        if (debugEnabled) {
            writeln("TEXTURE ", this.id, " (" ~ this.name ~ ") HAS BEEN DELETED");
        }
    }
}