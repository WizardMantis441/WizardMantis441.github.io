export class Conductor {
    crochet; stepCrochet; changes = [];

    loadBpmChanges(changes) {
        this.crochet = 60 / changes[0].bpm * 1000;
        this.stepCrochet = this.crochet / 4;
        this.changes = [];

        let prevTime = 0;
        let prevSteps = 0;

        for (let i = 0; i < changes.length; i++) {
            let curChange = changes[i];
            let newSteps = prevSteps + (curChange.t - prevTime) / ((60 / (i == 0 ? curChange.bpm : changes[i - 1].bpm) * 1000) / 4); // KILLING MYSELF HOLY FUCK
            this.changes.push({time: curChange.t, bpm: curChange.bpm, step: newSteps});
            prevTime = curChange.t;
            prevSteps = newSteps;   
        }

        // console.log(`loaded ${this.changes.length} bpm changes`);
        // for (const change of this.changes)
        //     console.log(`${change.time} ${change.bpm} ${change.step}`);
    }

    time; curBPM; curStep; curBeat; curMeasure;
    updateTime(time) {
        if (time == 0) {
            this.curBPM = this.changes[0].bpm;
            this.curStep = this.curBeat = this.curMeasure = 0;
        }

        let lastChangeTime = 0;
        this.time = time;
        this.curStep = 0;
        this.changes.forEach(change => {
            if (this.time > change.time) {
                this.curStep = change.step;
                this.curBPM = change.bpm;
                lastChangeTime = change.time;
            }
        })

        this.curStep += (this.time - lastChangeTime) / (60 / this.curBPM) / 1000 * 4;
        this.curBeat = this.curStep / 4; // until i get time signatures working
        this.curMeasure = this.curBeat / 4; // until i get timYOU GET IT >:(
    }

    getYForNote(note, gridSize) {
        let y = 0;

        let step = 0;
        let remainingTime = 0;
        let lastBPM = 0;
        this.changes.forEach(change => {
            if (note.time > change.time) {
                step = change.step;
                remainingTime = note.time - change.time;
                lastBPM = change.bpm;
            }
        });

        step += remainingTime / (60 / lastBPM) / 1000 * 4;
        y = step * gridSize;

        return y;
    }

    getTimeForStep(step) {
        let time = 0;
        let lastChange = this.changes[0];
        for (let i = 1; i < this.changes.length; i++) {
            if (step < this.changes[i].step) break;
            lastChange = this.changes[i];
        }
        let stepOffset = step - lastChange.step;
        let msPerStep = (60 / lastChange.bpm) * 1000 / 4;
        time = lastChange.time + stepOffset * msPerStep;
        return time;
    }
}

export default Conductor;