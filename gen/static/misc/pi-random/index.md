
[//]: # (gen-title: Random Point Pi Approximation - philthompson.me)

[//]: # (gen-keywords: pi, random, javascript, coding train, p5.js)

[//]: # (gen-description: JavaScript toy for approximating pi")

[//]: # (gen-meta-end)

<script src="../p5-v1.9.0.min.js"></script>
<script>
// written by Phil Thompson on 2024-02-20
const radius = 400;
const radiusPlusOne = 401;
const radiusSquared = radius * radius;
const padding = 25;
let isRunning = false;
let approxP;
let actualP;
let otherP;
let squarePoints = 0;
let circlePoints = 0;
let periodicCounter = 1000000;
let dotHue = 0.0;
let dotBright = 0.0;

function setup() {
	colorMode(HSB, 100, 100, 100, 1);
	createCanvas((radius*2)+padding+padding, (radius*2)+padding+padding);
	select('div.wrap').style('max-width', 'inherit');
	runButton = createButton('▷');
	runButton.mousePressed(toggleRun);
	runButton.style('font-size', '2.0rem');
	runButton.style('padding', '0.5rem 1.0rem 0.5rem 1.0rem');
	const controls = select('#controls');
	const content = select('#content');
    controls.child(runButton);
	for (const b of selectAll('button')) {
		b.style('margin', '0.4rem');
	}
	content.child(createElement('br'));
	approxP = createElement('pre');
	approxP.style('margin-bottom', '0px');
	approxP.style('padding-bottom', '0px');
	content.child(approxP);
	actualP = createElement('pre', 'actual: 3.141592653589793238462643383279502884197169');
	actualP.style('margin-top', '0px');
	actualP.style('padding-top', '0px');
	content.child(actualP);
	otherP = createElement('p');
	content.child(otherP);
	content.child(createElement('p', 'Approximates pi by placing random points within a circle within a bounding square.  This is based on <a href="https://www.youtube.com/watch?v=5cNnf_7e92Q">this Coding Train YouTube video</a>.'));
	background(0,0,20);
	translate(radius+padding, radius+padding);
	noFill();
	stroke(0,0,100,0.05);
	rectMode(CENTER);
	ellipse(0, 0, radius*2, radius*2);
	rect(0, 0, radius*2, radius*2);
	toggleRun();
}

function draw() {
	translate(radius+padding, radius+padding);

	periodicCounter++;
	if (periodicCounter % 5 == 0) {
		dotBright = (dotBright + 1) % 100;
		stroke(dotHue,100,dotBright,0.05);
		let approx = 4.0 * (circlePoints / squarePoints);
		approxP.html('approx: ' + approx);
	}
	if (periodicCounter >= 25) {
		dotHue = (dotHue + 1) % 100;
		periodicCounter = 0;
		// re-seed the rng with some actual randomness derived some least-significant bits of some things
		const newRandSeed = Date.now() + (11*(window.performance.now()%1000)) + (7*(millis() % 100000)) + (3*(mouseX % 100)) + (mouseY % 100);
		randomSeed(newRandSeed);
		const billionPoints = (squarePoints/1000000000).toFixed(5);
		const pointsPerSecond = parseInt(squarePoints/(millis()/1000.0));
		const fps = frameRate().toFixed(2);
		otherP.html("square points: " + billionPoints + " billion (" + pointsPerSecond + "/sec @" + fps + "fps)<br/>random seed: " + newRandSeed);
		ellipse(0, 0, radius*2, radius*2);
	}
	
	let x = 0.0;
	let y = 0.0;
	let outOfBoundsCount = 0;
	const pointsToCreate = 1430000;
	for (let i = 0; i < pointsToCreate; i++) {
		// gives random floating point value somewhere within the bounding
		//   square, which allows us to test many more points than just
		//   counting pixels
		// since upper bound is exclusive, we need to exceed +radius then check
		//   whether either x or y is beyond the radius
		x = random(-radius, radiusPlusOne);
		y = random(-radius, radiusPlusOne);
		if (x > radius || y > radius) {
			outOfBoundsCount++;
			continue;
		}
		// for speed, only plot every 50th point
		if (i % 50 == 0) {
			point(x,y);
		}
		if ((x*x) + (y*y) <= radiusSquared) {
			circlePoints += 1;
		}
	}
	squarePoints += (pointsToCreate - outOfBoundsCount);
}

function toggleRun() {
	isRunning = !isRunning;
	if (isRunning) {
		runButton.html('□');
		// on my M1 Mac mini, was getting:
		// ~7 million per second at 20 fps ( 350000 per frame)
		// ~7 million per second at ~5 fps (1430000 per frame)
		frameRate(5);
	} else {
		runButton.html('▷');
		frameRate(0);
	}
}
</script>
<main style="text-align:center;"></main>
<div id="controls" style="text-align:center; font-size:1.5rem;"></div>
<div id="content" style="max-width: 52rem;margin-left: auto;margin-right: auto;">
</div>
