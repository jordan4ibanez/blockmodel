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


        // if (true) {
        //     // Now render this font
            
        //     Camera.clearDepthBuffer();

        //     Shader.startProgram("2d");

        //     Font.setCanvasSize(Window.getWidth, Window.getHeight);

        //     Shader.setUniformMatrix4("2d", "cameraMatrix", Camera.updateGuiMatrix());
        //     Shader.setUniformMatrix4("2d", "objectMatrix", Camera.setGuiObjectMatrix(Vector2d(0,0)) );

        //     Font.selectFont("mc");

        //     // Scoped to show individual calls into api
        //     {
        //         Font.renderToCanvas(0,0, 32, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
        //     }
        //     {
        //         int fontSize = 70;
        //         string textString = "I'm on the bottom right!";

        //         Font.RazorTextSize textSize = Font.getTextSize(fontSize, textString);
        //         // Now we're going to move this to the bottom right of the "canvas"
        //         double posX = Window.getWidth - textSize.width;
        //         double posY = Window.getHeight - textSize.height;

        //         Font.renderToCanvas(posX, posY, fontSize, textString);
        //     }
        //     {
        //         int fontSize = 32;
        //         string textString = "The text below is rendered at the window center-point!";

        //         Font.RazorTextSize textSize = Font.getTextSize(fontSize, textString);
        //         // Now we're going to move this to the bottom right of the "canvas"

        //         double posX = (Window.getWidth / 2.0) - (textSize.width / 2.0);
        //         double posY = (Window.getHeight / 2.0) - (textSize.height / 2.0) - 50;

        //         Font.renderToCanvas(posX, posY, fontSize, textString);

        //         Font.render();
        //     }
            
        // }
