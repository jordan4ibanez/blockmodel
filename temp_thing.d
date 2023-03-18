module temp_thing;

// if (false) {
        //     Camera.clearDepthBuffer();
        //     Camera.setRotation(Vector3d(0,0,0));

        //     // Render sam first

        //     Shader.startProgram("model");

        //     Shader.setUniformMatrix4("model", "boneTRS", model.playAnimation(1), model.total_blocks);
        //     Shader.setUniformMatrix4("model", "cameraMatrix", Camera.updateCameraMatrix());

        //     Shader.setUniformMatrix4("model", "objectMatrix",
        //         Camera.setObjectMatrix(
        //             Vector3d(0,-3,-10), // Translation
        //             Vector3d(0,fancyRotation,0), // Rotation
        //             Vector3d(1), // Scale
        //         )
        //     );

        //     debugMesh.render("model");

        //     // Render the xyz compass on top
        //     Camera.clearDepthBuffer();

        //     Shader.startProgram("regular");

        //     Shader.setUniformMatrix4("regular", "cameraMatrix", Camera.updateCameraMatrix());

        //     Shader.setUniformMatrix4("regular", "objectMatrix",
        //         Camera.setObjectMatrix(
        //             Vector3d(0,-1,-4), // Translation
        //             Vector3d(0,fancyRotation,0), // Rotation
        //             Vector3d(1), // Scale
        //         )
        //     );

        //     xyzCompass.render("regular");


        //     // Now render this debug thing on top of that
        //     Camera.clearDepthBuffer();

        //     Shader.startProgram("2d");

        //     Shader.setUniformMatrix4("2d", "cameraMatrix", Camera.updateGuiMatrix());

        //     Shader.setUniformMatrix4("2d", "objectMatrix",
        //         Camera.setGuiObjectMatrix(
        //             Vector2d(
        //                 (Window.getWidth / 2.0) - debug2d.getWidth,
        //                 (Window.getHeight / 2.0) - debug2d.getHeight
        //             )
        //         )
        //     );

        //     debug2d.render("2d");
        // }