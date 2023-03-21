module texture.texture;

import std.stdio;
import bindbc.opengl;
import color;
import png;

import OpenGlLogger = tools.opengl_error_logger;

import doml.vector_2d;

/**
    Texture works as a singleton container.
    If you add all textures in at the beginning
    of the program, this becomes a cache.
*/

private immutable GLuint invalid = GLuint.max;

// Stores all textures as simple GLuint pointers. Accessed by file location.
private GLuint[string] storage;
// Stores all texture sized as vector2i. Accessed by file location.
private Vector2d[string] sizes;

/// Add a texture into the container.
GLuint addTexture(string fileLocation, bool debugEnabled = false) {

    if (fileLocation in storage) {
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

    // If this gets called, the driver is probably borked
    if (glIsTexture(id) == GL_FALSE) {
        throw new Exception("Texture: OpenGL FAILED to upload " ~ fileLocation ~ " into GPU memory!");
    }

    // Enable texture clamping to edge
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

    // Border color is nothing - This is a GL REQUIRED float
    float[4] borderColor = [0,0,0,0];
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor.ptr);

    // Add in nearest neighbor texture filtering
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST/*_MIPMAP_NEAREST*/);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    // glGenerateMipmap(GL_TEXTURE_2D);

    OpenGlLogger.execute("This error is from the Texture constructor.\n" ~ "Failed to load texture!");

    if (debugEnabled) {
        writeln(fileLocation, " is stored as ID: ", id);
    }

    // Finally cache the GL pointer ID as a GLuint
    storage[fileLocation] = id;

    sizes[fileLocation] = Vector2d(width, height);
    
    // Then return ID to make this even more flexible
    return id;
}

/// Get the OpenGL ID of the texture. Useful for automating things!
GLuint getTexture(string fileLocation) {
    if (fileLocation !in storage) {
        throw new Exception("Texture: Tried to get an invalid texture ID!");
    }
    return storage[fileLocation];
}

/// Get the literal size of the texture in pixels. Useful for creating cool things!
Vector2d getTextureSize(string fileLocation) {
    if (fileLocation !in sizes) {
        throw new Exception("Texture: Tried to get an invalid texture size!");
    }
    return sizes[fileLocation];
}

/// Destroy all textures loaded into OpenGL memory
void cleanUp() {
    foreach (string key, GLuint value; storage) {
        glDeleteTextures(1, &value);

        writeln("TEXTURE ", value, " (" ~ key ~ ") HAS BEEN DELETED");
    }
}