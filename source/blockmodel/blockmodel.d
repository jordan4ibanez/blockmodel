module blockmodel.blockmodel;

import std.stdio;
import std.algorithm.sorting;
import std.conv;
import tinygltf;
import vector_3d;
import vector_3i;

class BlockModel {

    //! Turn this into an auto iterator distributor
    private immutable int[] indiceOrder = [
        // Front
        0,1,2,2,3,0,
        // Back
        4,5,6,6,7,4,
        // Left
        8,9,10,10,11,8,
        // Right
        12,13,14,14,15,12
    ];

    Vector3d size = Vector3d(1,1,1);

    int count = 0;
    
    float[] vertexPositions;
    int[] indices;

    this(float width, float height, float length) {
        this.size.x = width;
        this.size.y = height;
        this.size.z = length;

        this.constructVertexPositions();
        this.constructIndices();
    }

    void constructVertexPositions() {
        
        // 8 Vertex Positions

        // Wall 1 (FRONT)
        const auto v0 = Vector3d(size.x, size.y, -size.z);
        const auto v1 = Vector3d(size.x, -size.y, -size.z);
        const auto v2 = Vector3d(-size.x, -size.y, -size.z);
        const auto v3 = Vector3d(-size.x, size.y, -size.z);

        // Wall 2 (BACK)
        const auto v4 = Vector3d(-size.x, size.y, size.z);
        const auto v5 = Vector3d(-size.x, -size.y, size.z);
        const auto v6 = Vector3d(size.x, -size.y, size.z);
        const auto v7 = Vector3d(size.x, size.y, size.z);

        // Front face
        assembleQuad(v0,v1,v2,v3);
        //Back face
        assembleQuad(v4,v5,v6,v7);

        //Left face
        assembleQuad(v3,v2,v5,v4);
        //Right face
        assembleQuad(v7,v6,v1,v0);

        
    }

    // Builds a plane of 2 tris out of 4 vertex positions
    void assembleQuad(Vector3d pos1, Vector3d pos2, Vector3d pos3, Vector3d pos4) {
        foreach (thisVertexPos; [pos1, pos2, pos3, pos4]) {
            vertexPositions ~= thisVertexPos.x;
            vertexPositions ~= thisVertexPos.y;
            vertexPositions ~= thisVertexPos.z;
        }
    }

    void constructIndices() {
        const int currentCount = cast(int)indices.length;

        foreach (int key; indiceOrder) {
            indices ~= currentCount + key;
        }

        writeln(this.indices);
    }

    float[] getVertexPositions() {
        return this.vertexPositions;
    }

    int[] getIndices() {
        return this.indices;
    }

    float[] getTextureCoordinates() {
        // These are place holders for future modeling implementation
        const float xMin = 0.0;
        const float xMax = 1.0;
        const float yMin = 0.0;
        const float yMax = 1.0;
        return [
            //* Front face
            // Top left
            xMin,yMin,
            // Bottom left
            xMin,yMax,
            // Top right
            xMax,yMax,
            // Bottom right
            xMax,yMin,

            //* Back face
            // Top left
            xMin,yMin,
            // Bottom left
            xMin,yMax,
            // Top right
            xMax,yMax,
            // Bottom right
            xMax,yMin,

            //* Left face
            // Top left
            xMin,yMin,
            // Bottom left
            xMin,yMax,
            // Top right
            xMax,yMax,
            // Bottom right
            xMax,yMin,

            //* Right face
            // Top left
            xMin,yMin,
            // Bottom left
            xMin,yMax,
            // Top right
            xMax,yMax,
            // Bottom right
            xMax,yMin,
        ];
    }

    int[] getBones() {
        return [0,0,0,0,0,0,0,0];
    }
    
}
