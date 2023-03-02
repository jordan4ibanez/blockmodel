module blockmodel.blockmodel;

import std.stdio;
import std.algorithm.sorting;
import std.conv;
import tinygltf;
import vector_3d;
import vector_3i;

class BlockModel {

    private immutable int[] indiceOrder = [
        // Front
        0,1,2,2,3,0,
        // Back
        4,5,6,6,7,4,
        // Left
        3,2,5,5,4,3,
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
            xMax,yMin,
            // Bottom left
            xMax,yMax,
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
