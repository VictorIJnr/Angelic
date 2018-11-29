class Player {
    constructor() {
        this.name;
        this.role;
        this.isAlive = true;
        this.isKiller = false; //Determines if the current angel is selected as the killer
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

    setAlive(isAlive) {
        this.isAlive = isAlive;
    }

    setKiller(isKiller) {
        this.isKiller = isKiller;
    }

    getName() {
        return this.name;
    }

    getRole() {
        return this.role;
    }

    isAlive() {
        return this.isAlive;
    }
}

class Vote {
    constructor() {
        this.voter;
        this.against;
        this.verdict;
    }
}