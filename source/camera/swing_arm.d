module camera.swing_arm;

import std.stdio;

import Camera = camera.camera;
import doml.vector_3d;
import Math = doml.math;


private double length = 3;

private Vector3d rotation;
private Vector3d position;

void setRotation(double pitch, double yaw) {
    rotation = Vector3d(yaw, pitch, 0);
}

void setPosition(double x, double y, double z) {
    position = Vector3d(x,y,z);
}

void setLength(double newLength) {
    length = newLength;
}

void applyToCamera() {


    Vector3d direction = Vector3d(
        Math.cos(rotation.y) * Math.cos(rotation.x),
        Math.sin(rotation.y) * Math.cos(rotation.x),
        Math.sin(rotation.x)
    ).mul(length);
    

    Camera.setPosition(
        direction
    );

    Camera.setRotation(Vector3d(
        -rotation.x,
        -rotation.y,
        0
        )
    );
}


