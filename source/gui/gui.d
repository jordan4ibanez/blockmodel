module gui.gui;

import std.stdio;
import bindbc.opengl;
import doml.vector_2d;

import Font = razor_font;

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

    private GLuint backgroundTexture;
    private Text text;

    this(string text, GLuint backgroundTexture) {

        this.text = new Text(text);
        this.backgroundTexture = backgroundTexture;

    }
}

class Text {

    double size = 0;

    Vector2d position;

    private string textData;

    this(string textData) {
        this.textData = textData;
    }

    Text setPosition(Vector2d position) {
        this.position = position;
        return this;
    }

    Text setSize(double size) {
        this.size = size;
        return this;
    }
    
}