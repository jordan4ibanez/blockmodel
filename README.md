# blockmodel
 A model format for voxel games.



# Spec:

## Spec notes

This is a rolling spec. I am literally bootstrapping it as I go. This might change until version 1.0.0 is released. Thank you for your understanding.

## Goal

Simple modeling format for voxel games.

## Minimum OpenGL Version

The minimum supported version of OpenGL is 4.1. This can probably be set further back, but it is not guaranteed to work in older versions.

## File Format

1. Blockmodels are ONLY to be stored as JSON encoded files.
2. Block models SHOULD be stored as a ``.bm`` file extension.

## Mesh/Bone

1. Each section of the model is made up of cuboids.
2. Each cuboid is outer facing.
3. Each cuboid is it's own bone
4. A model can have up to 64 cuboids.
5. Each cuboid becomes part of one mesh buffer in OpenGL for ease of use.
6. Each cuboid is represented by a length, width, height variable in it's section of the JSON.
7. There is NO parent child hierachy. Each cuboid exists as itself.
8. ONLY one bone can affect a cuboid.
9. ALL bones are relative to position (0,0,0) of the model.
10. ALL cuboids are to be 0 counted. Index gaps are NOT allowed.
11. ALL bones are REQUIRED to apply 1.0 weight to indices.
12. -Z is facing forward.
13. IF a model utilizes static position for one block, ALL block must utilize static position in the model.

## Animation

1. LINEAR interpolation ONLY.
2. Animation framerate MUST be included in the model.
3. Each keyframe MUST be included as part of the model. This is to avoid desync and implementation guessing. IF there is a 1 second gap between keyframes, model MUST be LINEAR interpolated between these frames on export.
4. If a model utilizes a static position in one block ALL blocks must be static.
5. If a model contains a static position NO animation must be included.



## Texturing

1. Models MUST be texture mapped AS IS to the image texture. No X or Y flipping.
2. Models MUST NOT contain multiple material (texture) buffers. ONLY one.
3. Texture coordinates are integrated as part of JSON object inside cuboid.
4. A model MUST contain texture coordinates.