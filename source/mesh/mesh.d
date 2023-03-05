module mesh.mesh;

import std.stdio;
import bindbc.opengl;
import Shader = shader.shader;
import vector_3d;
import vector_4d;
import vector_4i;
import tools.gl_error;

/// An OpenGL mesh. Utilizes builder pattern.
class Mesh {

    private static immutable GLint invalid = GLint.max;

    private static bool debugEnabled = true;

    // Vertex array object - Main object
    private GLuint vao = invalid;

    // Positions vertex buffer object
    //* Layout position 0
    private GLuint pbo = invalid;
    // Texture coordinates vertex buffer object
    //* Layout position 1
    private GLuint tbo = invalid;
    // Bones vertex buffer object
    //* Layout position 2
    private GLuint bbo = invalid;

    // Indices vertex buffer object
    private GLuint ibo = invalid;

    ///This is used for telling glsl how many indices are drawn in the render method.
    private GLuint indexCount = invalid;

    /**
     This is used to tell GL and GLSL which texture we are using.
     It is: (uniform sampler2D textureSampler) in the fragment shader
    */
    private GLuint textureId = invalid;

    /// Draws the mesh as a bunch of lines.
    private bool lineMode = false;

    /// Enforces calling the finalize() method.
    private bool finalized = false;

    /// Creates the OpenGL context for assembling this GL Mesh Object.
    this() {

        // bind the Vertex Array Object.
        glGenVertexArrays(1, &this.vao);
        glBindVertexArray(this.vao);

    }

    /// Adds vertex position data in Vector3 format within a linear float[].
    Mesh addVertices(const float[] vertices) {

        // Don't bother if not divisible by 3 TRI from cube vertex positions
        if (vertices.length % 3 != 0 || vertices.length < 3) {
            throw new Exception("Vertices must contain XYZ components for ALL vertex positions!");
        }

        // Positions VBO
        glGenBuffers(1, &this.pbo);
        glBindBuffer(GL_ARRAY_BUFFER, this.pbo);

        glBufferData(
            GL_ARRAY_BUFFER,                // Target object
            vertices.length * float.sizeof, // How big the object is
            vertices.ptr,                   // The pointer to the data for the object
            GL_STATIC_DRAW                  // Which draw mode OpenGL will use
        );

        glVertexAttribPointer(
            0,           // Attribute 0 (matches the attribute in the glsl shader)
            3,           // Size (literal like 3 points)  
            GL_FLOAT,    // Type
            GL_FALSE,    // Normalized?
            0,           // Stride
            cast(void*)0 // Array buffer offset
        );
        glEnableVertexAttribArray(0);
        
        return this;
    }

    /// Adds texture coordinate data in Vector2 format within a linear float[].
    Mesh addTextureCoordinates(const float[] textureCoordinates) {

        // Don't bother if not divisible by 2 and less than 2, these are raw Vector2 components in a linear array.
        if (textureCoordinates.length % 2 != 0 || textureCoordinates.length < 2) {
            throw new Exception("Vertices must contain XY components for ALL texture coordinates!");
        }

        // Texture coordinates VBO

        glGenBuffers(1, &this.tbo);
        glBindBuffer(GL_ARRAY_BUFFER, this.tbo);

        glBufferData(
            GL_ARRAY_BUFFER,
            textureCoordinates.length * float.sizeof,
            textureCoordinates.ptr,
            GL_STATIC_DRAW
        );

        glVertexAttribPointer(
            1,
            2,
            GL_FLOAT,
            GL_FALSE,
            0,
            cast(const(void)*)0
        );
        glEnableVertexAttribArray(1); 

        return this;
    }

    /// Adds indices data (order of vertex positions) in a linear int[].
    Mesh addIndices(const int[] indices) {

        // Indices VBO

        this.indexCount = cast(GLuint)(indices.length);

        glGenBuffers(1, &this.ibo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this.ibo);

        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,     // Target object
            indices.length * int.sizeof, // size (bytes)
            indices.ptr,                 // the pointer to the data for the object
            GL_STATIC_DRAW               // The draw mode OpenGL will use
        );

        return this;
    }

    /// Adds bone data aligned with the vertex position in a linear int[].
    Mesh addBones(const int[] bones) {

        // Bones VBO

        glGenBuffers(1, &this.bbo);
        glBindBuffer(GL_ARRAY_BUFFER, this.bbo);

        glBufferData(
            GL_ARRAY_BUFFER,            // Target object
            bones.length * int.sizeof,  // How big the object is
            bones.ptr,                  // The pointer to the data for the object
            GL_STATIC_DRAW              // Which draw mode OpenGL will use
        );

        glVertexAttribIPointer(
            2,           // Attribute 0 (matches the attribute in the glsl shader)
            1,           // Size (literal like 3 points)  
            GL_INT,      // Type
            0,           // Stride
            cast(void*)0 // Array buffer offset
        );
        glEnableVertexAttribArray(2);

        return this;
    }

    /// Make this mesh draw as a bunch of lines between indices
    Mesh setLineMode(const bool lineMode) {
        this.lineMode = lineMode;
        return this;
    }

    /// Set the texture ID of the mesh
    Mesh setTexture(const GLuint textureId) {
        this.textureId = textureId;
        return this;
    }

    /// Unbinds the GL Array Buffer and Vertex Array Object in GPU memory
    Mesh finalize() {
        
        finalized = true;
        
        // Unbind buffer pointer
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        // Unbind vao
        glBindVertexArray(0);

        GLenum glErrorInfo = getAndClearGLErrors();
        if (glErrorInfo != GL_NO_ERROR) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH CONSTRUCTOR");
        }

        if (debugEnabled) {
            writeln("Mesh ", this.vao, " has been successfully created");
        }

        return this;
    }

    /**
        Delete the texture from gpu memory.
        deleteTexture specifies if the encapsulated
        texture should be deleted from GPU memory as well.
        Do not delete the texture if it is shared, this will
        cause unexpected behavior.
    */
    void cleanUp() {

        if (!finalized) {
            throw new Exception("You MUST call finalize() for a mesh!");
        }
        
        // Bind to the context of the Vertex Array Object in gpu memory
        glBindVertexArray(this.vao);

        // Delete the positions vbo
        if (this.pbo != invalid) {
            glDisableVertexAttribArray(0);
            glDeleteBuffers(1, &this.pbo);
            assert (glIsBuffer(this.pbo) == GL_FALSE);

            writeln("deleted VERTEX POSITIONS");
        }

        // Delete the texture coordinates vbo
        if (this.tbo != invalid) {
            glDisableVertexAttribArray(1);
            glDeleteBuffers(1, &this.tbo);
            assert (glIsBuffer(this.tbo) == GL_FALSE);
            writeln("deleted TEXTURE COORDINATES");
        }
        // Delete the indices vbo
        if (this.bbo != invalid) {
            glDisableVertexAttribArray(2);
            glDeleteBuffers(1, &this.ibo);
            assert (glIsBuffer(this.ibo) == GL_FALSE);
            writeln("deleted BONES");
        }

        // Unbind the OpenGL object
        glBindVertexArray(0);

        // Now we can delete the OpenGL Vertex Array Object without any issues
        glDeleteVertexArrays(1, &this.vao);
        assert(glIsVertexArray(this.vao) == GL_FALSE);

        

        GLenum glErrorInfo = getAndClearGLErrors();
        if (glErrorInfo != GL_NO_ERROR) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH DESTRUCTOR");
        }

        if (debugEnabled) {
            writeln("Mesh ", this.vao, " has been successfully deleted from gpu memory");
        }
    }

    /// shaderName is the shader you want to render with
    void render(string shaderName) {

        if (!finalized) {
            throw new Exception("You MUST call finalize() for a mesh!");
        }

        if (textureId == invalid) {
            throw new Exception("Attempted to render a mesh with an invalid texture!");
        }

        Shader.setUniformInt(shaderName, "textureSampler", 0);

        glActiveTexture(GL_TEXTURE0);

        //! This needs to use the internal setter pointer (int) and check if it's negative
        glBindTexture(GL_TEXTURE_2D, this.textureId);

        glBindVertexArray(this.vao);

        if (lineMode) {
            glDrawArrays(GL_LINES, 0, this.indexCount);
        } else {
            glDrawElements(GL_TRIANGLES, this.indexCount, GL_UNSIGNED_INT, cast(const(void)*)0);
        }
        
        GLenum glErrorInfo = getAndClearGLErrors();
        if (glErrorInfo != GL_NO_ERROR) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH RENDER");
        }
        if (debugEnabled) {
            writeln("Mesh ", this.vao, " has rendered successfully ");
        }
    }
}