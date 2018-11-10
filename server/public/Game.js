class Game {
    constructor() {
        this.room = window.location.pathname.substring(1);
        httpGet(`http://localhost:20793/${this.room}/player`, "json", (data) => {
            console.log(data);
        }, (err) => console.log(err));
    }

    update() {
    }
}
