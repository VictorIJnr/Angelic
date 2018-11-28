enum Action {
    START_GAME, END_VOTING;
}

class Button<T> {
    static final float BTN_HEIGHT = (isSpectre) ? 96 : 48;    
    static final float BTN_WIDTH = BTN_HEIGHT * 5;  
    static final color TEXT_FILL = #DFE6E9;
    static final color DEFAULT_TEXT_FILL = #FFEAAF;
    static final color DEFAULT_FILL = #FD79AF;
    static final color HOVER_FILL = #B04370;
    static final color HOVER_TEXT_FILL = #FFDDB1;
    static final color SELECTED_FILL = #0984E3;
    
    T myValue;
    ArrayList<T> values;
    PVector myPosition;

    Button(T value, PVector myPos) {
        myValue = value;
        myPosition = myPos;
    }

    Button(ArrayList<T> values, PVector myPos) {
        this.values = values;
        myPosition = myPos;

        myValue = values.get(0);
    }

    void draw() {
        draw(DEFAULT_FILL, DEFAULT_TEXT_FILL);
    }

    void draw(color rectFill, color textFill) {
        draw(myValue.toString(), rectFill, textFill);
    }

    void draw(String displayText, color rectFill, color textFill) {
        if (mouseHover()) {
            rectFill = HOVER_FILL;
            textFill = HOVER_TEXT_FILL;
        }
        
        stroke(textFill);
        strokeWeight(5);

        fill(rectFill);
        rectMode(CENTER);
        rect(myPosition.x, myPosition.y, BTN_WIDTH, BTN_HEIGHT);

        fill(textFill);
        text(displayText, myPosition.x, myPosition.y + TEXT_SIZE / 4, BTN_WIDTH, BTN_HEIGHT);    
    }

    boolean mouseHover() {
        return mouseX >= myPosition.x - BTN_WIDTH / 2 && mouseX <= myPosition.x + BTN_WIDTH / 2
            && mouseY >= myPosition.y - BTN_HEIGHT / 2&& mouseY <= myPosition.y + BTN_HEIGHT / 2;
    }

    void mouseClicked() {}
    void subClicked(int subID) {}

    T getValue() {
        return myValue;
    }
}

class ActionButton extends Button<Action> {
    Action myAction;

    ActionButton(Action myAction, PVector myPos) {
        super(myAction, myPos);

        this.myAction = myAction;
    }

    @Override
    void draw(color rectFill, color textFill) {
        String buttonText = "";
        switch (myAction) {
            case START_GAME:
                buttonText = "Start the Game";
                break;
            case END_VOTING:
                buttonText = "Close Voting";
                break;
        }
        draw(buttonText, rectFill, textFill);
    }

    @Override
    void mouseClicked() {
        if (mouseHover()) {
            switch (myAction) {
                case START_GAME:
                    myGame.startGame();
                    break; 
                case END_VOTING:
                    myGame.getDay().stopVoting();
                    break;
                default:
                    break;
            }
        }
    }
}