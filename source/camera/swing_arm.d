module camera.swing_arm;

import std.stdio;

import Camera = camera.camera;
import doml.vector_3d;
import Math = doml.math;


private double length = 3;

private Vector3d rotation;
private Vector3d position;

void setRotation(double pitch, double yaw) {
    rotation = Vector3d(Math.toRadians(pitch), Math.toRadians(yaw), 0);
}

void setPosition(double x, double y, double z) {
    position = Vector3d(x,y,z);
}

void setLength(double newLength) {
    length = newLength;
}

void applyToCamera() {


    Vector3d direction = Vector3d(
        Math.cos(rotation.y),
        0,
        Math.sin(rotation.y)
    )
    .mul(length)
    .add(position);
    

    Camera.setPosition(
        direction
    );


    writeln(rotation.y);
    Camera.setRotation(Vector3d(
        Math.toDegrees(rotation.x),
        Math.toDegrees(rotation.y) - 90,
        0
        )
    );
}


