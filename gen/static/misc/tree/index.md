
[//]: # (gen-title: Fractal Trees - philthompson.me)

[//]: # (gen-keywords: fractals, trees, random, javascript, coding train, p5.js)

[//]: # (gen-description: JavaScript toy for generating fractal trees")

[//]: # (gen-meta-end)

<script src="../p5-v1.9.0.min.js"></script>
<script>
// written by Phil Thompson on 2024-02-07
const canvasW = 1200;
const canvasH = 800;
const progressPerFrame = 0.04;
let lengthFactor = 0.6;
let branchSpreadRads = 1.0;
let initialAngleRads = 1.0;
let initialX;
let initialY;
let initialLength;
let initialStrokeWeight;
let strokeWeightFactor;

let runButton;
let isRunning = false;
let segments = [];

class Segment {
	constructor(startX, startY, length, angle_rads, stroke_weight, rand_func) {
		this.startX = startX;
		this.startY = startY;
		this.length = length;
		this.angle_rads = angle_rads;
		this.stroke_weight = stroke_weight;
		this.rand_func = rand_func;
		this.endX = this.startX + (cos(this.angle_rads) * this.length);
		this.endY = this.startY + (sin(this.angle_rads) * this.length);
		this.midBranchL = 0.0;
		this.midBranchR = 0.0;
		if (this.rand_func() != 1.0) {
			if (abs(this.rand_func() - 1.0) < 0.003) {
				this.midBranchL = 0.5 * this.rand_func();
			}
			if (abs(this.rand_func() - 1.0) < 0.003) {
				this.midBranchR = 0.5 * this.rand_func();
			}
		}
		this.progress = 0.0;
		this.done = false;
		//this.color = color(random(0,256),100,100)
		this.color = color(100,0,100)
	}

	draw() {
		strokeWeight(this.stroke_weight);
		stroke(this.color);
		line(this.startX, this.startY, lerp(this.startX, this.endX, this.progress), lerp(this.startY, this.endY, this.progress));
		if (this.done) {
			return true;
		}
		this.progress += progressPerFrame;
		if (this.progress > 1.0) {
			this.progress = 1.0;
			this.done = true;
			if (this.length <= 1.6 || this.stroke_weight < 0.2) {
				return true;
			}
			if (abs(this.rand_func() - 1.0) < 0.22) {
				segments.push(new Segment(
					this.endX, this.endY,
					this.length * lengthFactor * this.rand_func(),
					((this.angle_rads - branchSpreadRads) * this.rand_func()) % TWO_PI,
					this.stroke_weight * strokeWeightFactor,// * this.rand_func(),
					this.rand_func));
			}
			if (abs(this.rand_func() - 1.0) < 0.22) {
				segments.push(new Segment(
					this.endX, this.endY,
					this.length * lengthFactor * this.rand_func(),
					((this.angle_rads + branchSpreadRads) * this.rand_func()) % TWO_PI,
					this.stroke_weight * strokeWeightFactor,// * this.rand_func(),
					this.rand_func));
			}
			return true;
		} else {
			if (this.midBranchL > 0.0 && this.progress > this.midBranchL) {
				this.midBranchL = -1.0;
				segments.push(new Segment(
					lerp(this.startX, this.endX, this.progress), lerp(this.startY, this.endY, this.progress),
					this.length * lengthFactor * this.rand_func(),
					((this.angle_rads - branchSpreadRads) * this.rand_func()) % TWO_PI,
					this.stroke_weight * strokeWeightFactor * this.rand_func() * 0.2,
					this.rand_func));
			}
			if (this.midBranchR > 0.0 && this.progress > this.midBranchR) {
				this.midBranchR = -1.0;
				segments.push(new Segment(
					lerp(this.startX, this.endX, this.progress), lerp(this.startY, this.endY, this.progress),
					this.length * lengthFactor * this.rand_func(),
					((this.angle_rads + branchSpreadRads) * this.rand_func()) % TWO_PI,
					this.stroke_weight * strokeWeightFactor * this.rand_func() * 0.2,
					this.rand_func));
			}
		}
		return false;
	}
}

function setup() {
	select('div.wrap').style('max-width', 'inherit');
	const controls = select('#controls');
	const content = select('#content');
	colorMode(HSB);
	strokeCap(PROJECT);
	initialAngleRads = -HALF_PI;
	initialX = canvasW / 2;
	initialY = canvasH;
	createCanvas(canvasW, canvasH);
	runButton = createButton('▷');
	runButton.mousePressed(toggleRun);
	runButton.style('font-size', '1.4rem');
	runButton.style('padding', '0.5rem 1.0rem 0.5rem 1.0rem');
	controls.child(runButton);
	controls.child(createElement('br'));
	controls.child(createButton('tree').mousePressed(resetWithTree));
	controls.child(createButton('tree 2').mousePressed(resetWithTree2));
	controls.child(createButton('tree 3').mousePressed(resetWithTree3));
	controls.child(createButton('tree rand').mousePressed(resetWithTreeRand));
	controls.child(createButton('square').mousePressed(resetWithSquare));
	controls.child(createButton('obtuse').mousePressed(resetWithObtuse));
	for (const b of selectAll('button')) {
		b.style('margin', '0.4rem');
	}
	resetWithTreeRand();
}

let randFactor = function() {
	return randomGaussian(1.0, 0.12);
}

let nonRandFactor = function() {
	return 1.0;
}

function resetWithSquare() {
	branchSpreadRads = HALF_PI;
	lengthFactor = 0.7;
	initialLength = canvasH * 0.42;
	initialStrokeWeight = 1.0;
	strokeWeightFactor = 1.0;
	segments = [];
	segments.push(new Segment(initialX, initialY, initialLength, initialAngleRads, initialStrokeWeight, nonRandFactor));
	if (!isRunning) {
		toggleRun();
	}
}

function resetWithTree() {
	branchSpreadRads = HALF_PI * 0.4;
	lengthFactor = 0.55;
	initialLength = canvasH * 0.4;
	initialStrokeWeight = 1.0;
	strokeWeightFactor = 1.0;
	segments = [];
	segments.push(new Segment(initialX, initialY, initialLength, initialAngleRads, initialStrokeWeight, nonRandFactor));
	if (!isRunning) {
		toggleRun();
	}
}

function resetWithTree2() {
	branchSpreadRads = HALF_PI * 0.3;
	lengthFactor = 0.7;
	initialLength = canvasH * 0.25;
	initialStrokeWeight = 5.0;
	strokeWeightFactor = 0.7;
	segments = [];
	segments.push(new Segment(initialX, initialY, initialLength, initialAngleRads, initialStrokeWeight, nonRandFactor));
	if (!isRunning) {
		toggleRun();
	}
}

function resetWithTree3() {
	branchSpreadRads = HALF_PI * 0.22;
	lengthFactor = 0.8;
	initialLength = canvasH * 0.2;
	initialStrokeWeight = 22.0;
	strokeWeightFactor = 0.7;
	segments = [];
	segments.push(new Segment(initialX, initialY, initialLength, initialAngleRads, initialStrokeWeight, nonRandFactor));
	if (!isRunning) {
		toggleRun();
	}
}

function resetWithTreeRand() {
	strokeJoin(BEVEL);
	branchSpreadRads = HALF_PI * 0.22;
	lengthFactor = 0.8;
	initialLength = canvasH * 0.15;
	initialStrokeWeight = 16.0;
	strokeWeightFactor = 0.76;
	segments = [];
	segments.push(new Segment(initialX, initialY, initialLength, initialAngleRads, initialStrokeWeight, randFactor));
	if (!isRunning) {
		toggleRun();
	}
}

function resetWithObtuse() {
	branchSpreadRads = HALF_PI * 1.1;
	lengthFactor = 0.62;
	initialLength = canvasH * 0.45;
	initialStrokeWeight = 1.0;
	strokeWeightFactor = 1.0;
	segments = [];
	segments.push(new Segment(initialX, initialY, initialLength, initialAngleRads, initialStrokeWeight, nonRandFactor));
	if (!isRunning) {
		toggleRun();
	}
}

function draw() {
	background(20);
	let allDone = true;
	for (const segment of segments) {
		if (!segment.draw()) {
			allDone = false;
		}
	}
	if (allDone) {
		toggleRun();
	}
}

function toggleRun() {
	isRunning = !isRunning;
	if (isRunning) {
		runButton.html('□');
		frameRate(60);
	} else {
		runButton.html('▷');
		frameRate(0);
	}
}
</script>
<main style="text-align:center;"></main>
<div id="controls" style="text-align:center; font-size:1.1rem;"></div>
<div id="content" style="max-width: 52rem;margin-left: auto;margin-right: auto; text-align: center;">
	<p>Based on <a target="_blank" href="https://www.youtube.com/watch?v=0jjeOYMjmDU">a Coding Train video</a> by Daniel Shiffman.</p>
</div>
