module gui.gui;

import std.stdio;
import bindbc.opengl;
import doml.vector_2d;
import doml.vector_4d;

import Font = razor_font;
import Texture = texture.texture;
import Window = window.window;
import Shader = shader.shader;
import Camera = camera.camera;

import mesh.mesh;


// Allows elements to be bolted to a part of the window
enum WINDOW_POSITION : Vector2d {

    TOP_LEFT      = Vector2d( 0.0, 0.0 ),
    TOP_CENTER    = Vector2d( 0.5, 0.0 ),
    TOP_RIGHT     = Vector2d( 1.0, 0.0 ),

    CENTER_LEFT   = Vector2d( 0.0, 0.5 ),
    CENTER_CENTER = Vector2d( 0.5, 0.5 ),
    CENTER_RIGHT  = Vector2d( 1.0, 0.5 ),

    BOTTOM_LEFT   = Vector2d( 0.0, 1.0 ),
    BOTTOM_CENTER = Vector2d( 0.5, 1.0 ),
    BOTTOM_RIGHT  = Vector2d( 1.0, 1.0 )

}

// Export as public enums so you don't have to type out WINDOW_POSITION every time
enum TOP_LEFT      = WINDOW_POSITION.TOP_LEFT;
enum TOP_CENTER    = WINDOW_POSITION.TOP_CENTER;
enum TOP_RIGHT     = WINDOW_POSITION.TOP_RIGHT;

enum CENTER_LEFT   = WINDOW_POSITION.CENTER_LEFT;
enum CENTER_CENTER = WINDOW_POSITION.CENTER_CENTER;
enum CENTER_RIGHT  = WINDOW_POSITION.CENTER_RIGHT;

enum BOTTOM_LEFT   = WINDOW_POSITION.BOTTOM_LEFT;
enum BOTTOM_CENTER = WINDOW_POSITION.BOTTOM_CENTER;
enum BOTTOM_RIGHT  = WINDOW_POSITION.BOTTOM_RIGHT;

// Default the position to top left
private immutable WINDOW_POSITION DEFAULT = WINDOW_POSITION.TOP_LEFT;

/// This auto converts the enumerator into a direct position on screen
private Vector2d grabWindowPosition(WINDOW_POSITION inputPosition) {
    Vector2d windowSize = Window.getSize();
    
    return Vector2d(
        inputPosition.x * windowSize.x,
        inputPosition.y * windowSize.y
    );
}

// This auto converts the text into position utilizing it's offset size when rendered
private Vector2d grabRealPosition(Text text) {
    Vector2d windowPosition = grabWindowPosition(text.windowPosition);
    Font.RazorTextSize textSize = Font.getTextSize(text.size, text.textData);

    Vector2d outputtingPosition;

    // This automatically centers the text as much as possible.
    // So if you're in the center, you're in the direct center.
    // If you're on the right, you're exactly on the right, etc.

    final switch (cast(int)(text.windowPosition.x * 10)) {
        case (0): {
            outputtingPosition.x = windowPosition.x;
            break;
        }
        case (5): {
            outputtingPosition.x = windowPosition.x - (textSize.width / 2.0);
            break;
        }
        case (10): {
            outputtingPosition.x = windowPosition.x - textSize.width;
            break;
        }
    }

    final switch (cast(int)(text.windowPosition.y * 10)) {
        case (0): {
            outputtingPosition.y = windowPosition.y;
            break;
        }
        case (5): {
            outputtingPosition.y = windowPosition.y - (textSize.height / 2.0);
            break;
        }
        case (10): {
            outputtingPosition.y = windowPosition.y - textSize.height;
            break;
        }
    }

    return outputtingPosition;
}

Vector2d grabFinalPosition(Text text) {
    Vector2d realPosition = grabRealPosition(text);
    realPosition.x += text.position.x;
    realPosition.y += text.position.y;
    return realPosition;
}

Vector2d grabButtonFix(Button button) {

    WINDOW_POSITION windowPosition = button.windowPosition;

    Vector2d outputtingPosition;

    double buttonWidth = button.size.x;
    double buttonHeight = button.size.y;


    final switch (cast(int)(windowPosition.x * 10)) {
        case (0): {
            outputtingPosition.x = buttonWidth;
            break;
        }
        case (5): {
            outputtingPosition.x = -buttonWidth / 2.0;
            break;
        }
        case (10): {
            outputtingPosition.x = -buttonWidth;
            break;
        }
    }

    final switch (cast(int)(windowPosition.y * 10)) {
        case (0): {
            outputtingPosition.y = 0;
            break;
        }
        case (5): {
            outputtingPosition.y = -buttonHeight / 2.0;
            break;
        }
        case (10): {
            outputtingPosition.y = -buttonHeight;
            break;
        }
    }

    return outputtingPosition;
}

class GUI {

    private Button[string] buttonObjects;
    private Text[string] textObjects;

    void addText(string name, Text text) {
        this.textObjects[name] = text;
    }

    void addButton(string name, Button button) {
        this.buttonObjects[name] = button;
    }

    void render() {

        Font.switchColors(1,0,0,1);

        Shader.setUniformMatrix4("2d", "cameraMatrix", Camera.updateGuiMatrix());

        foreach (Button button; buttonObjects) {
            

            Vector2d windowPosition = grabWindowPosition(button.windowPosition);

            windowPosition.x -= Window.getWidth() / 2.0;
            windowPosition.y -= Window.getHeight() / 2.0;

            Vector2d buttonFix = grabButtonFix(button);

            windowPosition.x += buttonFix.x;
            windowPosition.y += buttonFix.y;

            windowPosition.x += button.position.x;
            windowPosition.y -= button.position.y;

            Shader.setUniformMatrix4("2d", "objectMatrix", Camera.setGuiObjectMatrix(Vector2d(0,0)));
            
            Font.renderToCanvas(
                windowPosition.x + (Window.getWidth() / 2.0) + button.padding,
                windowPosition.y + (Window.getHeight() / 2.0) + button.padding,
                button.text.size,
                button.text.textData
            );
            Font.render();

            Shader.setUniformMatrix4("2d", "objectMatrix", Camera.setGuiObjectMatrix(
                    windowPosition
                )
            );

            button.mesh.render("2d");
        }

        Shader.setUniformMatrix4("2d", "objectMatrix", Camera.setGuiObjectMatrix(Vector2d(0,0)));

        foreach (Text text; textObjects) {

            Vector2d finalPosition = grabFinalPosition(text);

            Font.renderToCanvas(finalPosition.x, finalPosition.y, text.size, text.textData);
        }

        Font.render();
    }

    void collisionDetect() {



        if (!Window.mouseButtonClicked()) {
            return;
        }

        Vector2d mousePosition = Window.getMousePosition();
        

        foreach (string name, Button button; buttonObjects) {
            

            // We're getting the top left of the button

            Vector2d windowPosition = grabWindowPosition(button.windowPosition);

            Vector2d buttonFix = grabButtonFix(button);

            windowPosition.x += buttonFix.x;
            windowPosition.y += buttonFix.y;

            windowPosition.x += button.position.x;
            windowPosition.y -= button.position.y;

            // Check if collided
            if (mousePosition.x >= windowPosition.x && mousePosition.x <= windowPosition.x + button.size.x &&
                mousePosition.y >= windowPosition.y && mousePosition.y <= windowPosition.y + button.size.y) {


                if (button.buttonFunction !is null) {
                    button.buttonFunction();
                }
                return;
            }

            
        }

    }

    void destroy() {
        foreach (Button button; buttonObjects) {
            button.mesh.cleanUp();            
        }
    }

}


class Button {

    // Real window position
    WINDOW_POSITION windowPosition = DEFAULT;

    // Offset from real window position in pixels
    Vector2d position;

    Vector2d size;

    double padding = 0.0;
    
    private Text text;

    Mesh mesh;

    // What this button does when pushed
    void delegate() buttonFunction;

    this(Text text) {

        this.text = text;

        
        this.setButtonTexture();
    }

    private void setButtonTexture() {

        // This is hardcoded, for now
        

        Font.RazorTextSize textSize = Font.getTextSize(text.size, text.textData);

        // Pixel padding between the edge of the button texture, and the text texture
        padding = 10;

        // The guide edges for buttons, keeps texture edges from stretching
        // So think of this of like: How many pixels does your button texture use before getting to the text part.
        immutable double pixelEdge = 1.0;
        // Border scalar just makes the button border more pronounced/visible
        immutable double borderScalar = 3.0;

        size = Vector2d(
            textSize.width + (padding * 2),
            textSize.height + (padding * 2)
        );

        Vector2d textureSize = Texture.getTextureSize("textures/button.png");

        // Accumulates the mesh data for the button
        double[] vertices;
        double[] textureCoords;
        int[] indices;

        //! This is written so sloppily because I've never done this before. Need to actually get an implementation before I neaten/optimize it!

        // We're going to use the height to create the consistent layout

        double centerBorder = (size.y / textureSize.y) * pixelEdge * borderScalar;

        // writeln(size.y, " ", textureSize.y, " one pixel: ", onePixel);
        
        vertices ~= [

            // Top left
            0,            0,
            0,            centerBorder,
            centerBorder, centerBorder,
            centerBorder, 0,

            // Top center
            centerBorder,          0,
            centerBorder,          centerBorder,
            size.x - centerBorder, centerBorder,
            size.x - centerBorder, 0,

            // Top right
            size.x - centerBorder, 0,
            size.x - centerBorder, centerBorder,
            size.x,                centerBorder,
            size.x,                0,

            // Center left
            0,            centerBorder,
            0,            size.y - centerBorder,
            centerBorder, size.y - centerBorder,
            centerBorder, centerBorder,

            // Center center
            centerBorder,          centerBorder,
            centerBorder,          size.y - centerBorder,
            size.x - centerBorder, size.y - centerBorder,
            size.x - centerBorder, centerBorder,

            // Center right
            size.x - centerBorder, centerBorder,
            size.x - centerBorder, size.y - centerBorder,
            size.x,                size.y - centerBorder,
            size.x,                centerBorder



        ];

        textureCoords ~= [
            // Top left
            0.0,                       0.0,
            0.0,                       pixelEdge / textureSize.y,
            pixelEdge / textureSize.x, pixelEdge / textureSize.y,
            pixelEdge / textureSize.x, 0.0,

            // Top center
            pixelEdge / textureSize.x,                   0.0,
            pixelEdge / textureSize.x,                   pixelEdge / textureSize.y,
            (textureSize.x - pixelEdge) / textureSize.x, pixelEdge / textureSize.y,
            (textureSize.x - pixelEdge) / textureSize.x, 0.0,

            // Top right
            (textureSize.x - pixelEdge) / textureSize.x, 0.0,
            (textureSize.x - pixelEdge) / textureSize.x, pixelEdge / textureSize.y,
            1.0,                                         pixelEdge / textureSize.y,
            1.0,                                         0.0,

            // Center left
            0.0,                       pixelEdge / textureSize.y,
            0.0,                       (textureSize.y - pixelEdge) / textureSize.y,
            pixelEdge / textureSize.x, (textureSize.y - pixelEdge) / textureSize.y,
            pixelEdge / textureSize.x, pixelEdge / textureSize.y,

            // Center center
            pixelEdge / textureSize.x,                   pixelEdge / textureSize.y,
            pixelEdge / textureSize.x,                   (textureSize.y - pixelEdge) / textureSize.y,
            (textureSize.x - pixelEdge) / textureSize.x, (textureSize.y - pixelEdge) / textureSize.y,
            (textureSize.x - pixelEdge) / textureSize.x, pixelEdge / textureSize.y,

            // Center right
            (textureSize.x - pixelEdge) / textureSize.x, pixelEdge / textureSize.y,
            (textureSize.x - pixelEdge) / textureSize.x, (textureSize.y - pixelEdge) / textureSize.y,
            1.0,                                         (textureSize.y - pixelEdge) / textureSize.y,
            1.0,                                         pixelEdge / textureSize.y,



        ];
        
        indices ~= [
            // Top left
            0,1,2,2,3,0,
            // Top center
            4,5,6,6,7,4,
            // Top right
            8,9,10,10,11,8,
            // Center left
            12,13,14,14,15,12,
            // Center center
            16,17,18,18,19,16,
            // Center right
            20,21,22,22,23,20
        ];

        /**

        Vertices as a whole
        [
            0.0,    0.0,
            0.0,    size.y,
            size.x, size.y,
            size.x, 0.0
        ]

        Texture coordinates a whole
        [
            0.0, 0.0,
            0.0, 1.0,
            1.0, 1.0,
            1.0, 0.0
        ]
        Indices as a whole
        [
            0,1,2,2,3,0
        ]

        */




        this.mesh = new Mesh()
            .addVertices2d(vertices)
            .addTextureCoordinates(textureCoords)
            .addIndices(indices)
            // This is hardcoded for now
            .setTexture(Texture.getTexture("textures/button.png"))
            .finalize();

    }

    Button setPostion(Vector2d position) {
        this.position = position;
        return this;
    }

    Button setWindowPosition(WINDOW_POSITION windowPosition) {
        this.windowPosition = windowPosition;
        return this;
    }

    Button setFunction(void delegate() buttonFunction) {
        this.buttonFunction = buttonFunction;
        return this;
    }
    
}

class Text {

    double size = 0;

    // If the text is within a button, this will be ignored
    WINDOW_POSITION windowPosition = DEFAULT;

    // This is the position relative to the window position
    Vector2d position;

    Vector4d color = Vector4d(0,0,0,1);

    private string textData;

    this(string textData) {
        this.textData = textData;
    }

    /// This is the position relative to the window position
    Text setPosition(Vector2d position) {
        this.position = position;
        return this;
    }

    /// This is the position in the window where the text will be bolted to
    Text setWindowPosition(WINDOW_POSITION windowPosition) {
        this.windowPosition = windowPosition;
        return this;
    }

    Text setSize(double size) {
        this.size = size;
        return this;
    }

    Text setColor(double r, double b, double g, double a) {
        this.color = Vector4d(r,g,b,a);
        return this;
    }
    
}