class Player {
    constructor() {
        this.name;
        this.votes = []; //array of votes with each index specifying a game day.
    }
}

class Vote {
    constructor() {
        this.voter;
        this.against;
        this.verdict;
    }
}