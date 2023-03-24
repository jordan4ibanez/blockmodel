module camera.swing_arm;

import std.stdio;

import Camera = camera.camera;
import doml.vector_3d;
import Math = doml.math;


private double length = 3;

private Vector3d rotation;
private Vector3d position;

void setRotation(double pitch, double yaw) {
    rotation = Vector3d(pitch, yaw, 0);
}

void setPosition(double x, double y, double z) {
    position = Vector3d(x,y,z);
}

void setLength(double newLength) {
    length = newLength;
}

void applyToCamera() {


    float xzLen = Math.cos(rotation.x + Math.PI);

    Vector3d rotationVector = Vector3d (
        xzLen * Math.sin(-rotation.y),
        Math.sin(rotation.x + Math.PI),
        xzLen * Math.cos(rotation.y)
    ).mul(-length);
    

    Camera.setPosition(
        rotationVector
    );
    

    Camera.setRotation(Vector3d(rotation.x,rotation.y,0));
}


