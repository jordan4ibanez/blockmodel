module blockmodel.blockmodel;

import std.stdio;
import std.algorithm.sorting;
import std.conv;
import tinygltf;
import vector_3d;
import vector_3i;

class BlockModel {

    Vector3d size = Vector3d(1,1,1);
    
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
        // Wall 1 (bottom)
        vertexPositions ~= -size.x;
        vertexPositions ~= -size.y;
        vertexPositions ~= -size.z;

        vertexPositions ~= -size.x;
        vertexPositions ~= -size.y;
        vertexPositions ~= size.z;

        vertexPositions ~= size.x;
        vertexPositions ~= -size.y;
        vertexPositions ~= -size.z;

        vertexPositions ~= size.x;
        vertexPositions ~= -size.y;
        vertexPositions ~= size.z;

        // Wall 2 (top)
        vertexPositions ~= -size.x;
        vertexPositions ~= size.y;
        vertexPositions ~= -size.z;
        
        vertexPositions ~= size.x;
        vertexPositions ~= size.y;
        vertexPositions ~= -size.z;

        vertexPositions ~= -size.x;
        vertexPositions ~= size.y;
        vertexPositions ~= size.z;

        vertexPositions ~= size.x;
        vertexPositions ~= size.y;
        vertexPositions ~= size.z;
    }

    void constructIndices() {
        
    }

    float[] getVertexPositions() {
        return this.vertexPositions;
    }
    
}
