module gui.gui;

import bindbc.opengl;

class GUI {

    private Button[string] buttons;
    private Text[string] texts;

}


private class Button {
    private GLuint backgroundTexture;
}

private class Text {
    private string data;
    this(string data) {
        this.data = data;
    }
}