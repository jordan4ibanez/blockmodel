module gui.gui;

import bindbc.opengl;

class GUI {

    private Button[string] buttons;
    private Text[string] texts;

}


private class Button {
    private GLuint backgroundTexture;
    private Text text;

    this(string text, GLuint backgroundTexture) {
        this.text = new Text(text);
        this.backgroundTexture = backgroundTexture;
    }
}

private class Text {
    private string data;
    this(string data) {
        this.data = data;
    }
}