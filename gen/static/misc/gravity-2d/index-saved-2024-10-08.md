
[//]: # (gen-title: Gravity 2D - Solar System - philthompson.me)

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
let fpsMultiple = 5;

let gConstant = 0.000005;
const particles = [];

let totalReplaced = 0;
let maxX = 0;
let maxY = 0;

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
    particles.push(new Particle(50000000.0, color(252), 1));
    particles[0].pos.x = width / 2;
    particles[0].pos.y = height / 2;
    particles[0].vel.mult(0.0);
    for (let i = 0; i < 5; i++) {
        particles.push(new Particle(1000.0, color(222), 1));
    }
    addParticles(500);
    frameRate(30);
}

function addParticles(n) {
    for (let i = 0; i < n; i++) {
        particles.push(new Particle(0.0000001, color(202), 1));
    }
}

function draw() {
    // translate to keep the big one in the middle
    translate((width/2) - particles[0].pos.x, (height/2) - particles[0].pos.y);
    let iParticle;
    for (let frameMult = 0; frameMult < fpsMultiple; frameMult ++) {
        for (let i = 0; i < particles.length - 1; i++) {
            iParticle = particles[i];
            for (let j = i+1; j < particles.length; j++) {
                applyGravityBetweenParticles(iParticle, particles[j])
            }
        }
    }
    background(51, 50);
    for (let p of particles) {
        p.update();
        p.show();
    }
    if (frameCount % 100 == 0) {
        if (frameCount % 200 == 0) {
            let toReplace = 0;
            const wLimit = width * 100;
            const hLimit = height * 100;
            let p;
            for (let i = particles.length - 1; i >= 0; i--) {
                p = particles[i];
                if (abs(p.pos.x) > maxX) {
                    maxX = abs(p.pos.x);
                }
                if (abs(p.pos.x) > wLimit || abs(p.pos.y) > hLimit) {
                    particles.splice(i, 1);
                    toReplace++;
                }
            }
            addParticles(toReplace);
            totalReplaced += toReplace;
        }
        fpsSpan.html("<small>" + round(frameRate() * fpsMultiple, 0) + " fps - " + (particles.length).toLocaleString() + " particles - " + (totalReplaced).toLocaleString() + " replaced - maxX=" + maxX + "</small>");
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
    let distSq = max(1.0, grav.magSq());
    let mag = gConstant / distSq;
    grav.setMag(mag);
    a.acc.add(p5.Vector.mult(grav, b.mass));
    b.acc.sub(p5.Vector.mult(grav, a.mass));
}

class Particle {

    constructor(mass, color, ttl) {
        this.mass = mass;
        this.strokeWeight = max(1, min(20.0, ((this.mass * this.mass)/300000.0)));
        this.color = color;
        this.ttl = ttl;
        this.pos = createVector(random(width), random(height));
        if (this.pos.x < width / 2) {
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

    // might move this...
    applyGravityFromParticle(other) {
        let grav = p5.Vector.sub(other.pos, this.pos);
        let mag = (gConstant * this.mass * other.mass) / grav.magSq();
        grav.setMag(mag);
        applyForce(grav);
    }

    show() {
//        stroke(this.color);
        strokeWeight(this.strokeWeight);
        point(this.pos.x, this.pos.y);
        // overlapping line ends create visible "dots" all along the lines
        //line(this.pos.x, this.pos.y, this.prev.x, this.prev.y);
        // shrink the line a little to avoid the dots -- this has to be fine-tuned
        //   with the force that slows particles down to also eliminate gaps
        //   between these line segments
//        const lineBeg = p5.Vector.lerp(this.pos, this.prev, 0.09);
//        const lineEnd = p5.Vector.lerp(this.pos, this.prev, 0.91);
//        line(lineBeg.x, lineBeg.y, lineEnd.x, lineEnd.y);
    }
}
</script>
<main style="text-align:center;"></main>
<div id="controls" style="text-align:center; font-size:1.1rem; margin-bottom:0.3rem;"></div>
<div id="controls2" style="text-align:center; font-size:1.1rem; margin-bottom:0.3rem;"></div>
<div id="controls3" style="text-align:center; font-size:1.1rem;"></div>
<div style="max-width: 52rem;margin-left: auto;margin-right: auto;">
    <h3>Gravity 2D: Solar System</h3>
    <p>Each particle interacts gravitationally with all other particles.</p>
    <p>This is based on some Coding Train videos (<a target="_blank" href="https://www.youtube.com/watch?v=OAcXnzRNiCY">here</a> and <a target="_blank" href="https://www.youtube.com/watch?v=EpgB3cNhKPM">here</a> and <a target="_blank" href="https://www.youtube.com/watch?v=GjbKsOkN1Oc">here</a>) by Daniel Shiffman.</p>
    <p>All Gravity 2D apps:
        <ul>
            <li><a href="./single.html">Single</a>: A single particle, customizable "sun" positions, and trail drawing</li>
            <li><a href="./planet.html">Planet</a>: A single "sun," single "planet," and full particle-to-particle gravity simulation</a></li>
            <li><a href="./fixed-suns.html">Fixed Suns</a>: Many particles, customizable "sun" positions, simplified gravity simulation</li>
            <li><a href="./index.html">Solar System</a>: A single "sun," several "planets," and full particle-to-particle gravity simulation</li>
        </ul>
    </p>
</div>