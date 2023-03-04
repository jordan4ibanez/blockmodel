module mesh.mesh;

import std.stdio;
import bindbc.opengl;
import shader.shader;
import texture.texture;
import vector_3d;
import vector_4d;
import vector_4i;
import tools.gl_error;

class Mesh {

    private static bool debugEnabled = true;

    private bool exists = false;

    // Vertex array object - Main object
    GLuint vao = 0;
    // Positions vertex buffer object
    GLuint pbo = 0;
    // Texture positions vertex buffer object
    GLuint tbo = 0;
    // Indices vertex buffer object
    GLuint ibo = 0;
    // Bones vertex buffer object
    GLuint bbo = 0;

    // Indices count, not sure why this is stored in this class?
    // Todo: Figure out why this is.
    GLuint indexCount = 0;

    bool lineMode = true;
    
    
    private Texture texture = null;


    this(const float[] vertices, 
        const int[] indices, 
        const float[] textureCoordinates, 
        const int[] bones,
        const string textureLocation,
        const bool lineMode = false) {

        this.lineMode = lineMode;

        this.texture = new Texture(textureLocation);

        // Existence lock
        this.exists = true;

        // Don't bother if not divisible by 3 TRI from cube vertex positions
        assert(vertices.length % 3 == 0 && vertices.length >= 3);
        this.indexCount = cast(GLuint)(indices.length);

        // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
        glGenVertexArrays(1, &this.vao);
        glBindVertexArray(this.vao);
    

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


        // Indices VBO

        glGenBuffers(1, &this.ibo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this.ibo);

        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,     // Target object
            indices.length * int.sizeof, // size (bytes)
            indices.ptr,                 // the pointer to the data for the object
            GL_STATIC_DRAW               // The draw mode OpenGL will use
        );


        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        // Unbind vao just in case
        glBindVertexArray(0);

        GLenum glErrorInfo = getAndClearGLErrors();
        if (glErrorInfo != GL_NO_ERROR) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH CONSTRUCTOR");
        }

        if (debugEnabled) {
            writeln("Mesh ", this.vao, " has been successfully created");
        }
    }

    /**
        Delete the texture from gpu memory.
        deleteTexture specifies if the encapsulated
        texture should be deleted from GPU memory as well.
        Do not delete the texture if it is shared, this will
        cause unexpected behavior.
    */
    void cleanUp(bool deleteTexture = true) {

        // Don't bother the gpu with garbage data
        if (!this.exists) {
            if (debugEnabled) {
                writeln("sorry, I cannot clear gpu memory, I don't exist in gpu memory");
            }
            return;
        }

        // This is done like this because it works around driver issues
        
        // When you bind to the array, the buffers are automatically unbound
        glBindVertexArray(this.vao);

        // Disable all attributes of this "object"
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
        glDisableVertexAttribArray(2);

        // Delete the positions vbo
        glDeleteBuffers(1, &this.pbo);
        assert (glIsBuffer(this.pbo) == GL_FALSE);
    
        // Delete the texture coordinates vbo
        glDeleteBuffers(1, &this.tbo);
        assert (glIsBuffer(this.tbo) == GL_FALSE);

        // Delete the colors vbo
        // glDeleteBuffers(1, &this.cbo);
        // assert (glIsBuffer(this.cbo) == GL_FALSE);

        // Delete the indices vbo
        glDeleteBuffers(1, &this.ibo);
        assert (glIsBuffer(this.ibo) == GL_FALSE);

        // Unbind the "object"
        glBindVertexArray(0);
        // Now we can delete it without any issues
        glDeleteVertexArrays(1, &this.vao);
        assert(glIsVertexArray(this.vao) == GL_FALSE);

        

        GLenum glErrorInfo = getAndClearGLErrors();
        if (glErrorInfo != GL_NO_ERROR) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH DESTRUCTOR");
        }

        if (deleteTexture) {
            this.texture.cleanUp();
        }

        if (debugEnabled) {
            writeln("Mesh ", this.vao, " has been successfully deleted from gpu memory");
        }
    }

    void render(Shader shader) {

        // Don't bother the gpu with garbage data
        if (!this.exists) {
            if (debugEnabled) {
                writeln("sorry, I cannot render, I don't exist in gpu memory");
            }
            return;
        }

        shader.setUniformInt("textureSampler", 0);

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, this.texture.getId);

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

    // void batchRender(Vector3d offset, Vector3d rotation, Vector3d scale, bool culling, Vector3d min, Vector3d max) {

    //     // Don't bother the gpu with garbage data
    //     if (!this.exists) {
    //         if (debugEnabled) {
    //             writeln("sorry, I cannot render, I don't exist in gpu memory");
    //         }
    //         return;
    //     }

    //     shader.setUniformI("textureSampler", 0);
    //     // getShader("main").setUniformF("light", light);

    //     glActiveTexture(GL_TEXTURE0);
    //     glBindTexture(GL_TEXTURE_2D, this.texture.getId);

    //     //! Camera.setObjectMatrix(offset, rotation, scale);

    //     if (culling) {
    //         // Let's get some weird behavior to show it
    //         bool inside = true;//!Re-enable this insideFrustumAABB(min, max);
    //         // bool inside = insideFrustumSphere(10);
    //         if (!inside) {
    //             return;
    //         }
    //     }

    //     glBindVertexArray(this.vao);
    //     // glDrawArrays(GL_TRIANGLES, 0, this.indexCount);
    //     glDrawElements(GL_TRIANGLES, this.indexCount, GL_UNSIGNED_INT, cast(const(void)*)0);
        
    //     GLenum glErrorInfo = window.getAndClearGLErrors();
    //     if (glErrorInfo != GL_NO_ERROR) {
    //         writeln("GL ERROR: ", glErrorInfo);
    //         writeln("ERROR IN A MESH RENDER");
    //     }
    //     if (debugEnabled) {
    //         writeln("Mesh ", this.vao, " has rendered successfully ");
    //     }
    // }

    
}