class Chat {

    final float HEIGHT = height * 0.4;
    final float WIDTH = width / 4; 

    boolean hasFocus = false;
    boolean isHost;
    PVector myPosition;

    Chat() {    
        myPosition = new PVector(0, height - HEIGHT);
    }

    void draw() {
        
        fill(0);
        rect(myPosition.x, myPosition.y, WIDTH, HEIGHT);

    }

    void postMessage(Player sender, String message) {

    }

}