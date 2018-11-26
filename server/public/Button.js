class Button {
    constructor(xPos, yPos, width, height, text, action) {
        this.xPos = xPos;
        this.yPos = yPos;
        this.width = width;
        this.height = height;
        this.text = text;

        this.action = action;
    }

    isHovering() {
        return ((mouseX >= this.xPos - this.width / 2 && mouseX <= this.xPos + this.width / 2) && 
            (mouseY >= this.yPos - this.height / 2 && mouseY <= this.yPos + this.height / 2))
    }

    execAction() {
        this.action();
    }

    mouseClick() {
        if (this.isHovering()) this.execAction();
    }

    draw() {
        rectMode(CENTER);
        textAlign(CENTER, CENTER);
        let strokeColour = "#FFEAAF"; 

        fill("#FD79AF");
        stroke(strokeColour);
        strokeWeight(7.5);
        
        //Show the hover fill if needed.
        if (this.isHovering()) {
            strokeColour = "#FFDDB1"; 
            fill("#B04370");
            stroke(strokeColour);
        }

        rect(this.xPos, this.yPos, this.width, this.height);

        noStroke();
        fill(strokeColour);
        text(this.text, this.xPos, this.yPos, this.width, this.height);
    }
}