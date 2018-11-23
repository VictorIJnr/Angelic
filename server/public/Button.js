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
        return ((mouseX >= this.xPos && mouseX <= this.xPos + this.width) && 
            (mouseY >= this.yPos && mouseY <= this.yPos + this.height))
    }

    execAction() {
        this.action();
    }

    draw() {
        fill("fd79af");
        stroke("#ffeaaf");
        rect(this.xPos, this.yPos, this.width, this.height);

        rectMode(CENTER);
        fill(51);
        text(this.text, this.xPos, this.yPos, this.width, this.height);
    }
}