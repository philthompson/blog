
[//]: # (gen-title: Gravity 2D - philthompson.me)

[//]: # (gen-keywords: gravity simulation, javascript)

[//]: # (gen-description: Simple 2D gravity simulator built using p5.js")

[//]: # (gen-meta-end)

<style>
\#controls > * {
    margin: 0.2rem;
}
\#controls2 > * {
    margin: 0.2rem;
}
\#controls3 > * {
    margin: 0.2rem 0.5rem 0.2rem 0.5rem;
}
</style>
<script src="../p5-v1.9.0.min.js"></script>
<script>

let fpsSpan;
let fpsMultiple = 6;

let gConstant = 0.000001;
let sun;
const particles = [];

let totalReplaced = 0;

function setup() {
    let c = createCanvas(1200, 800);
    background(51);
    select('div.wrap').style('max-width', 'inherit');
    stroke(222);
    strokeWeight(2.0);
    //////////////////////////////////////////
    const controls = select('#controls');
    const controls2 = select('#controls2');
    let pauseButton = createButton('Pause');
    controls.child(pauseButton);
    pauseButton.mousePressed(function() { noLoop(); });
    let playButton = createButton('Play');
    controls.child(playButton);
    playButton.mousePressed(function() { loop(); });
    fpsSpan = createElement('span');
    fpsSpan.style('float', 'right');
    controls2.child(fpsSpan);
    //////////////////////////////////////////
    sun = new Particle(50000000.0, color(252), 1, createVector(width/2, height/2));
    sun.pos.x = width / 2;
    sun.pos.y = height / 2;
    sun.vel.mult(0.0);
    addParticles(2500);
    frameRate(30);
}

function addParticles(n) {
    for (let i = 0; i < n; i++) {
        particles.push(new Particle(0.0000000001, color(202), 1, sun.pos));
    }
}

function draw() {
    // translate to keep the big one in the middle
    translate((width/2) - sun.pos.x, (height/2) - sun.pos.y);
    let iParticle;
    for (let frameMult = 0; frameMult < fpsMultiple; frameMult ++) {
        for (let p of particles) {
            applyGravityBetweenParticles(sun, p)
        }
    }
    background(51, 50);
    strokeWeight(sun.strokeWeight);
    sun.update();
    sun.show();
    strokeWeight(particles[0].strokeWeight);
    for (let p of particles) {
        p.update();
        p.show();
    }
    if (frameCount % 100 == 0) {
        if (frameCount % 200 == 0) {
            let toReplace = 0;
            const distLimit = (width * 20) * (width * 20);
            let p, dx, dy;
            for (let i = particles.length - 1; i >= 0; i--) {
                p = particles[i];
                dx = p.pos.x - sun.pos.x;
                dy = p.pos.y - sun.pos.y;
                if ((dx * dx + dy * dy) > distLimit) {
                    particles.splice(i, 1);
                    toReplace++;
                }
            }
            addParticles(toReplace);
            totalReplaced += toReplace;
        }
        fpsSpan.html("<small>" + round(frameRate() * fpsMultiple, 0) + " fps - " + (particles.length).toLocaleString() + " particles - " + (totalReplaced).toLocaleString() + " replaced - sun (" + round(sun.pos.x) + "," + round(sun.pos.y) + ")</small>");
    }
}

function applyGravityBetweenParticles(a, b) {
//    let grav = p5.Vector.sub(b.pos, a.pos);
//    // constraint dist because if it gets too close gravity will be super strong
//    let distSq = max(20.0, grav.magSq());
//    let mag = (gConstant * a.mass * b.mass) / distSq;
//    grav.setMag(mag);
//    a.acc.add(grav);
//    b.acc.sub(grav);
    ////////////
    // new version where force is divided by mass of the object to apply the force to:
    // F = ma --> a = F/m
    let grav = p5.Vector.sub(b.pos, a.pos);
    let distSq = max(1.5, grav.magSq());
    let mag = gConstant / distSq;
    grav.setMag(mag);
    a.acc.add(p5.Vector.mult(grav, b.mass));
    b.acc.sub(p5.Vector.mult(grav, a.mass));
}

class Particle {

    constructor(mass, color, ttl, sunpos) {
        this.mass = mass;
        //this.strokeWeight = max(1, min(20.0, ((this.mass * this.mass)/300000.0)));
        // from https://www.wolframalpha.com/input?i=exponential+fit+%7B%7B2000000%2C+10%7D%2C+%7B50000000%2C+20%7D%7D
        if (this.mass < 1.0) {
            this.strokeWeight = 1.0;
        } else {
            this.strokeWeight = 9.71532 * Math.pow(Math.E, 0.0000000144406 * this.mass);
            this.strokeWeight = max(1, this.strokeWeight);
            this.strokeWeight = min(30, this.strokeWeight);
        }
        this.color = color;
        this.ttl = ttl;
        this.pos = createVector(sunpos.x + random(-width/2, width/2), sunpos.y + random(-height/2, height/2));
        if (this.pos.x < sunpos.x) {
            this.vel = createVector(random(0.0, 1.0), random(0.0, 1.0));
        } else {
            this.vel = createVector(random(-1.0, 0.0), random(-1.0, 0.0));
        }
        this.acc = createVector(0.0, 0.0);
        this.prev = this.pos.copy();
        this.dead = false;
    }

    updatePrev() {
        this.prev.x = this.pos.x;
        this.prev.y = this.pos.y;
    }

    update() {
        this.vel.add(this.acc);
        this.pos.add(this.vel);
        this.acc.mult(0.0);
    }

    applyForce(forceVec) {
        this.acc.add(forceVec);
    }

    show() {
        point(this.pos.x, this.pos.y);
    }
}
</script>
<main style="text-align:center;"></main>
<div id="controls" style="text-align:center; font-size:1.1rem; margin-bottom:0.3rem;"></div>
<div id="controls2" style="text-align:center; font-size:1.1rem; margin-bottom:0.3rem;"></div>
<div id="controls3" style="text-align:center; font-size:1.1rem;"></div>
<div style="max-width: 52rem;margin-left: auto;margin-right: auto;">
    <p>Each small particle only interacts with the large "sun", rather than
with all the other particles.  This is a less accurate simulation but it allows
many more particles to be simulated.</p>
    <p>This is based on a Coding Train video by Daniel Shiffman.</p>
</div>