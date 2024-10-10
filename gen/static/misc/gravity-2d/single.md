
[//]: # (gen-title: Gravity 2D: Single - philthompson.me)

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
const suns = [];
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
    let resetButton = createButton('Reset');
    controls.child(resetButton);
    resetButton.mousePressed(resetSim);
    let saveImageButton = createButton('Save Image');
    controls.child(saveImageButton);
    saveImageButton.mousePressed(saveCanvasImage);
    fpsSpan = createElement('span');
    fpsSpan.style('float', 'right');
    controls2.child(fpsSpan);
    //////////////////////////////////////////
    let sun = new Particle(50000000.0, color(252), 1);
    sun.pos.x = width / 2;
    sun.pos.y = height / 2;
    sun.vel.mult(0.0);
    suns.push(sun);
    addParticles(1);
    frameRate(30);
}

function saveCanvasImage() {
    const dateStr = (new Date()).toISOString().split('.')[0].replaceAll(':', '') + 'Z';
    saveCanvas('gravity-' + dateStr + '.png');
}

function resetSim() {
    particles.length = 0;
    addParticles(1);
    background(51);
    fpsSpan.html("<small>restarted</small>");
    loop();
}

function mousePressed() {
    if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) {
        return;
    }
    let dx, dy;
    for (let i = 0; i < suns.length; i++) {
        dx = suns[i].pos.x - mouseX;
        dy = suns[i].pos.y - mouseY;
        if (dx * dx + dy * dy < 100) {
            stroke(51);
            strokeWeight(suns[i].strokeWeight * 1.2);
            point(suns[i].pos.x, suns[i].pos.y);
            stroke(222);
            suns.splice(i, 1);
            loop();
            return;
        }
    }
    let sun = new Particle(50000000.0, color(252), 1, createVector(width/2, height/2));
    sun.pos.x = mouseX;
    sun.pos.y = mouseY;
    sun.vel.mult(0.0);
    suns.push(sun);
}

function addParticles(n) {
    for (let i = 0; i < n; i++) {
        particles.push(new Particle(0.0000000001, color(202), 1));
    }
}

function draw() {
    let iParticle;
    for (let frameMult = 0; frameMult < fpsMultiple; frameMult ++) {
        for (let p of particles) {
            for (let s of suns) {
                applyGravityBetweenParticles(s, p);
            }
        }
    }
    //background(51, 5);
    if (suns.length > 0) {
        strokeWeight(suns[0].strokeWeight);
    }
    for (let s of suns) {
        //s.update();
        s.show();
    }
    strokeWeight(particles[0].strokeWeight);
    for (let p of particles) {
        p.update();
        p.show();
    }
    if (frameCount % 100 == 0) {
        if (frameCount % 200 == 0) {
            const distLimit = (width * 20) * (width * 20);
            const p = particles[0];
            const dx = p.pos.x - (width / 2);
            const dy = p.pos.y - (height / 2);
            if ((dx * dx + dy * dy) > distLimit) {
                noLoop();
                fpsSpan.html("<small>paused (particle too far away)</small>");
                return;
            }
        }
        fpsSpan.html("<small>" + round(frameRate() * fpsMultiple, 0) + " fps</small>");
    }
}

function applyGravityBetweenParticles(a, b) {
    // where force is divided by mass of the object to apply the force to:
    // F = ma --> a = F/m
    // but the force would be:
    // F = (g * a.mass * b.mass) / distSq
    // we can just omit the multiplication and division by the same mass value
    let grav = p5.Vector.sub(b.pos, a.pos);
    let distSq = max(1.5, grav.magSq());
    let mag = gConstant / distSq;
    grav.setMag(mag);
    //a.acc.add(p5.Vector.mult(grav, b.mass)); // don't actually move the "suns"
    b.acc.sub(p5.Vector.mult(grav, a.mass));
}

class Particle {

    constructor(mass, color, ttl) {
        this.mass = mass;
        //this.strokeWeight = max(1, min(20.0, ((this.mass * this.mass)/300000.0)));
        if (this.mass < 1.0) {
            this.strokeWeight = 1.0;
        } else {
            // from https://www.wolframalpha.com/input?i=exponential+fit+%7B%7B2000000%2C+10%7D%2C+%7B50000000%2C+20%7D%7D
            //this.strokeWeight = 9.71532 * Math.pow(Math.E, 0.0000000144406 * this.mass);
            this.strokeWeight = 5.0 * Math.pow(Math.E, 0.0000000144406 * this.mass);
            this.strokeWeight = max(1, this.strokeWeight);
            this.strokeWeight = min(30, this.strokeWeight);
        }
        this.color = color;
        this.ttl = ttl;
        this.pos = createVector(random(width), random(height));
        if (this.pos.x < width/2) {
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
    <h3>Gravity 2D: Single</h3>
    <p>The small particle only interacts with the large "sun" objects, which
do not move.  Click to place more "sun" objects, or click one to remove it.</p>
    <p>This is based on some Coding Train videos (<a target="_blank" href="https://www.youtube.com/watch?v=OAcXnzRNiCY">here</a> and <a target="_blank" href="https://www.youtube.com/watch?v=EpgB3cNhKPM">here</a> and <a target="_blank" href="https://www.youtube.com/watch?v=GjbKsOkN1Oc">here</a>) by Daniel Shiffman.</p>
    <p>All Gravity 2D apps:
        <ul>
            <li><a href="./single.html">Single</a>: A single particle, customizable "sun" positions, and trail drawing</li>
            <li><a href="./planet.html">Planet</a>: A single "sun," single "planet," and full particle-to-particle gravity simulation</a></li>
            <li><a href="./fixed-suns.html">Fixed Suns</a>: Many particles, customizable "sun" positions, simplified gravity simulation</li>
            <li><a href="./index.html">Solar System</a>: A single "sun," several "planets," and full particle-to-particle gravity simulation</li>
        </ul>
    </p>
<h3>Examples</h3>
<img class="width-100" style="border: 0.7rem solid white" src="${SITE_ROOT_REL}/s/img/2024/gravity-2d-single-example1.png"/><br/>
<img class="width-100" style="border: 0.7rem solid white" src="${SITE_ROOT_REL}/s/img/2024/gravity-2d-single-example2.png"/><br/>
<img class="width-100" style="border: 0.7rem solid white" src="${SITE_ROOT_REL}/s/img/2024/gravity-2d-single-example3.png"/><br/>
<img class="width-100" style="border: 0.7rem solid white" src="${SITE_ROOT_REL}/s/img/2024/gravity-2d-single-example4.png"/><br/>
</div>