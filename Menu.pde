class Menu {

    RadioButton<String> myRadio;

    Menu() {
        ArrayList<String> myVals = new ArrayList<String>();

        myVals.add("foo");
        myVals.add("bar");
        myVals.add("loosid");

        myRadio = new RadioButton<String>(myVals, new PVector(width / 2, height / 2));
    }

    void draw() {
        myRadio.draw();
    }

    void mouseClick() {
        myRadio.mouseClicked();
    }
}

class Button<T> {
    static final float BTN_HEIGHT = (isSpectre) ? 96 : 48;    
    static final float BTN_WIDTH = BTN_HEIGHT * 5;  
    static final color TEXT_FILL = #DFE6E9;
    static final color DEFAULT_TEXT_FILL = #FFB142;
    static final color DEFAULT_FILL = #636E72;
    static final color HOVER_FILL = #C7ECEE;
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

class RadioButton<T> extends Button<T> {
    ArrayList<BoolButton<T>> subButtons;
    int subIndex = 0;

    RadioButton(ArrayList<T> values, PVector myPos) {
        super(values, myPos);
        subButtons = setupSubButtons(values);
        subButtons.get(subIndex).flip();
    }

    ArrayList<BoolButton<T>> setupSubButtons(ArrayList<T> values) {
        ArrayList<BoolButton<T>> retValue = new ArrayList<BoolButton<T>>();
        int index = 0;
        
        for (T value : values) {
            retValue.add(new BoolButton(this, index, value, new PVector(myPosition.x,
                myPosition.y + (index++ * BTN_HEIGHT + BTN_HEIGHT / 2))));
        }

        return retValue;
    }

    @Override
    void mouseClicked() {
        int i = 0;

        for (BoolButton<T> subButton : subButtons) {
            if (subButton.clicked()) {
                subButtons.get(subIndex).flip();
                myValue = subButton.getNonNullValue();
                subButton.flip();
                subIndex = i;

                System.out.println(myValue);
        System.out.println("My Value " + this);

                break;
            }
            i++;
        }
    }

    void update() {
       for (BoolButton<T> option : subButtons) {
            color fillColour;
            System.out.println(subIndex);
            if (option.getID() == subIndex) fillColour = SELECTED_FILL;
            else fillColour = DEFAULT_FILL;

            option.draw(fillColour, DEFAULT_TEXT_FILL);
        } 
    }

    void draw() {
        for (BoolButton<T> option : subButtons) {
            color fillColour;

            if (option.getID() == subIndex) fillColour = SELECTED_FILL;
            else fillColour = DEFAULT_FILL;

            option.draw(fillColour, DEFAULT_TEXT_FILL);
        }
    }
}

class BoolButton<T> extends Button<T> {
    ArrayList<T> myVals = new ArrayList<T>();
    Button<T> parent;
    T nonNull;
    int myID;

    BoolButton(Button<T> parent, int id, T value, PVector myPos) {
        this(value, myPos);
        this.parent = parent;
        myID = id;
    }

    BoolButton(T value, PVector myPos) {
        super(value, myPos);
        nonNull = value;
        myValue = null;

        myVals.add(value);
        myVals.add(null);
    }

    void flip() {
        myValue = (myValue == null) ? myVals.get(0) : null;
    }

    T getNonNullValue() {
        return nonNull;
    }

    boolean getBoolValue() {
        return myValue != null;
    }

    int getID() {
        return myID;
    }

    void draw() {

    }

    void draw(color rectFill, color textFill) {
        if (mouseHover()) rectFill = HOVER_FILL;
        
        fill(rectFill);
        rectMode(CENTER);
        rect(myPosition.x, myPosition.y, BTN_WIDTH, BTN_HEIGHT);

        fill(textFill);
        text(nonNull.toString(), myPosition.x, myPosition.y + TEXT_SIZE / 4, BTN_WIDTH, BTN_HEIGHT);
    }

    boolean clicked() {
        if (mouseHover()) {
            myValue = (myValue == null) ? myVals.get(0) : null;
            return true;
        }
        return false;
    }
}