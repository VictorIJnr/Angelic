class Player {
    constructor() {
        this.name;
        this.role;
        this.votes = []; //array of votes with each index specifying a game day.
    }
    
    displayRole() {
        return (this.role == "ANGEL") ? "an Angel" : "a Human";
    } 

    setName(name) {
        this.name = name;
    } 

    setRole(role) {
        this.role = role;
    }

    getName() {
        return this.name;
    }

    getRole() {
        return this.role;
    }
}

class Vote {
    constructor() {
        this.voter;
        this.against;
        this.verdict;
    }
}