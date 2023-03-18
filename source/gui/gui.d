module gui.gui;

import std.stdio;
import bindbc.opengl;
import doml.vector_2d;
import doml.vector_4d;

import Font = razor_font;
import Texture = texture.texture;
import Window = window.window;


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
    BOTTOM_RIGH   = Vector2d( 1.0, 1.0 )

}

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

    final switch (cast(int)text.windowPosition.x * 10) {
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

    final switch (cast(int)text.windowPosition.y * 10) {
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

class GUI {

    private Button[string] buttonObjects;
    private Text[string] textObjects;

    void addText(string name, Text text) {
        this.textObjects[name] = text;
    }

    void render() {

        Font.switchColors(1,0,0,1);

        foreach (Text text; textObjects) {

            writeln(text.position, " ", text.size, " ", text.textData);
            Font.renderToCanvas(text.position.x, text.position.y, text.size, text.textData);
        }

        Font.render();
    }

}


class Button {

    WINDOW_POSITION windowPosition = DEFAULT;

    private GLuint backgroundTexture;
    private Text text;

    this(string text, GLuint backgroundTexture) {

        this.text = new Text(text);
        this.backgroundTexture = backgroundTexture;

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