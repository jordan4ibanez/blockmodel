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

    // This isn't perfect, but it does the job
    Vector3d direction = Vector3d(
        Math.sin(-rotation.y),
        Math.asin(rotation.x),
        Math.cos(rotation.y)
    )
        .normalize()
        .mul(length)
        .add(position);
    

    Camera.setPosition(
        Vector3d(
            direction
        )
    );
    

    Camera.setRotation(Vector3d(rotation.x,rotation.y,0));
}


