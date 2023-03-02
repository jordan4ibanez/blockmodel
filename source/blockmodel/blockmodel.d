module blockmodel.blockmodel;

import std.stdio;
import std.algorithm.sorting;
import std.conv;
import tinygltf;
import vector_3d;
import vector_3i;

class BlockModel {

    private immutable int[] indiceOrder = [
        0,1,3,3,1,2
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
    }

    void constructVertexPositions() {
        
        // 8 Vertex Positions - written extremely verbosely
        // Wall 1 (FRONT)
        vertexPositions ~= -size.x;
        vertexPositions ~= -size.y;
        vertexPositions ~= size.z;

        vertexPositions ~= -size.x;
        vertexPositions ~= size.y;
        vertexPositions ~= size.z;

        vertexPositions ~= size.x;
        vertexPositions ~= -size.y;
        vertexPositions ~= size.z;

        vertexPositions ~= size.x;
        vertexPositions ~= size.y;
        vertexPositions ~= size.z;

        // Wall 2 (BACK)
        vertexPositions ~= -size.x;
        vertexPositions ~= -size.y;
        vertexPositions ~= -size.z;
        
        vertexPositions ~= -size.x;
        vertexPositions ~= size.y;
        vertexPositions ~= -size.z;

        vertexPositions ~= size.x;
        vertexPositions ~= -size.y;
        vertexPositions ~= -size.z;

        vertexPositions ~= size.x;
        vertexPositions ~= size.y;
        vertexPositions ~= -size.z;
    }

    void constructIndices() {
        const currentCount = indices.length;
        foreach (int key; indiceOrder) {
            indices ~= currentCount + key;
        }
    }

    float[] getVertexPositions() {
        return this.vertexPositions;
    }
    
}
