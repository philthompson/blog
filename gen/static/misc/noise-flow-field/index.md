
[//]: # (gen-title: Noise Flow Field - philthompson.me)

[//]: # (gen-keywords: perlin noise, noise, visualization, computer art)

[//]: # (gen-description: Art generated with Perlin Noise using p5.js")

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

let browserWindowScale = 1.0; // shrink browser window to say 50% (0.5) for higher-resolution output
let vectorGridNoiseIncrZ = 0.002 / browserWindowScale;
let vectorNoiseScale = 0.01 * browserWindowScale;
let noiseZ = 0.0;
const killAfterFrameCount = 10000;
let fpsSpan;
let statusSpan;
let fpsMultipleSelect;
let fpsMultiple = 1;
let ttlSelect;
let newParticleTtl = 1000;
let bgSelect;
let bgColor;

const particles = [];

let randomColorH = 0;
let particleSeed;
let usedPaletteNumber;
let palettePreview;

// based on https://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
// yes, p5.js has HSV mode, but i'm more interested in implementing
//   this myself to see how it works
function getNewRandomColor(sat, val) {
	const convertHsvToRgb = function(h, s, v) {
		const hInt = parseInt(h * 6.0);
		const f = (h * 6.0) - parseFloat(hInt);
		const p = v * (1 - s);
		const q = v * (1 - (f * s));
		const t = v * (1 - ((1 - f) * s));
		let r, g, b;
		if        (hInt == 0) {
			r = v; g = t; b = p;
		} else if (hInt == 1) {
			r = q; g = v; b = p;
		} else if (hInt == 2) {
			r = p; g = v; b = t;
		} else if (hInt == 3) {
			r = p; g = q; b = v;
		} else if (hInt == 4) {
			r = t; g = p; b = v;
		} else {
			r = v; g = p; b = q;
		}
		return [parseInt(r * 256), parseInt(g * 256), parseInt(b * 256)];
	};
	const goldenRatioConjugate = 0.618033988749895;
	randomColorH += goldenRatioConjugate;
	randomColorH = randomColorH % 1.0;
	return convertHsvToRgb(randomColorH, sat, val);
}

function resizeAndRepaint() {
	usedPaletteNumber = false;
	const newWidth = windowWidth - 40;
	const newHeight = (newWidth / 4) * 3;
	resizeCanvas(newWidth, newHeight);
	background(bgColor);
}

function setup() {
	bgColor = color(255);
	const controls = select('#controls');
	const controls2 = select('#controls2');
	const controls3 = select('#controls3');
	let c = createCanvas(1200, 800);
	let saveCanvasButton = createButton('Save Image');
	saveCanvasButton.mousePressed(function() {
		const dateStr = (new Date()).toISOString().split('.')[0].replaceAll(':', '') + 'Z';
		const paletteStr = usedPaletteNumber === false ? '' : ('-palette' + usedPaletteNumber);
		saveCanvas('noise-flow' + paletteStr + '-' + dateStr + '.png');
	});
	controls2.child(saveCanvasButton);
	saveCanvasButton.style('float', 'left');
	let addParticlesControlsLabel = createElement('span');
	controls.child(addParticlesControlsLabel);
	addParticlesControlsLabel.html("Add Particles:");
	let addBlackButton = createButton('Black');
	addBlackButton.mousePressed(function() {
		addParticles(100, color(0, 2), newParticleTtl);
	});
	controls.child(addBlackButton);
	let addWhiteButton = createButton('White');
	addWhiteButton.mousePressed(function() {
		addParticles(100, color(255, 2), newParticleTtl);
	});
	controls.child(addWhiteButton);
	let addRedButton = createButton('Red');
	addRedButton.mousePressed(function() {
		addParticles(100, color(255, 0, 0, 2), newParticleTtl);
	});
	controls.child(addRedButton);
	let addBlueButton = createButton('Blue');
	addBlueButton.mousePressed(function() {
		addParticles(100, color(0, 0, 255, 2), newParticleTtl);
	});
	controls.child(addBlueButton);
	let addGreenButton = createButton('Green');
	addGreenButton.mousePressed(function() {
		addParticles(100, color(0, 255, 0, 2), newParticleTtl);
	});
	controls.child(addGreenButton);
	fpsSpan = createElement('span');
	fpsSpan.style('float', 'right');
	controls3.child(fpsSpan);
	statusSpan = createElement('span');
	statusSpan.style('float', 'left');
	controls3.child(statusSpan);
	////-////-////-////-////-////-////-////-////-////-////
	fpsMultipleSelect = createSelect();
	fpsMultipleSelect.option('1x Speed', 1);
	fpsMultipleSelect.option('5x Speed', 5);
	fpsMultipleSelect.option('10x Speed', 10);
	fpsMultipleSelect.option('20x Speed', 20);
	fpsMultipleSelect.option('50x Speed', 50);
	fpsMultipleSelect.option('100x Speed', 100);
	controls2.child(fpsMultipleSelect);
	fpsMultipleSelect.selected(fpsMultiple);
	fpsMultipleSelect.changed(function() {
		fpsMultiple = parseInt(fpsMultipleSelect.value());
	});
	fpsMultipleSelect.style('float', 'left');
	////-////-////-////-////-////-////-////-////-////-////
	let resizeButton = createButton('Resize/Repaint');
	resizeButton.mousePressed(resizeAndRepaint);
	controls2.child(resizeButton);
	resizeButton.style('float', 'right');
	////-////-////-////-////-////-////-////-////-////-////
	scaleSelect = createSelect();
	scaleSelect.option('1000% Scale', 10.0);
	scaleSelect.option('500% Scale', 5.0);
	scaleSelect.option('200% Scale', 2.0);
	scaleSelect.option('100% Scale', 1.0);
	scaleSelect.option('90% Scale', 0.9);
	scaleSelect.option('80% Scale', 0.8);
	scaleSelect.option('67% Scale', 0.67);
	scaleSelect.option('50% Scale', 0.5);
	scaleSelect.option('30% Scale', 0.3);
	scaleSelect.option('10% Scale', 0.1);
	scaleSelect.option('5% Scale', 0.05);
	scaleSelect.option('1% Scale', 0.01);
	controls2.child(scaleSelect);
	scaleSelect.selected(1.0);
	scaleSelect.changed(function() {
		browserWindowScale = parseFloat(scaleSelect.value());
		if (browserWindowScale < 1.0) {
			fpsMultipleSelect.selected(1);
		}
		vectorGridNoiseIncrZ = 0.002 / browserWindowScale;
		vectorNoiseScale = 0.01 * browserWindowScale;
		strokeWeight(2.0 / browserWindowScale);
	});
	scaleSelect.style('float', 'right');
	////-////-////-////-////-////-////-////-////-////-////
	ttlSelect = createSelect();
	ttlSelect.option('TTL = 100', 100);
	ttlSelect.option('TTL = 500', 500);
	ttlSelect.option('TTL = 1000', 1000);
	ttlSelect.option('TTL = 5000', 5000);
	ttlSelect.option('TTL = 10000', 10000);
	ttlSelect.option('TTL = 50000', 50000);
	controls.child(ttlSelect);
	ttlSelect.selected(newParticleTtl);
	ttlSelect.changed(function() {
		newParticleTtl = parseInt(ttlSelect.value());
	});
	let paletteControlsLabel = createElement('span');
	controls2.child(paletteControlsLabel);
	paletteControlsLabel.html("Palette:");
	particleSeed = createInput(22, 'number');
	controls2.child(particleSeed);
	particleSeed.size(100);
	particleSeed.changed(updatePalettePreview);
	particleSeed.input(updatePalettePreview);
	let restartWithNumericSeed = createButton('Restart with Palette');
	restartWithNumericSeed.mousePressed(restart);
	controls2.child(restartWithNumericSeed);
	bgSelect = createSelect();
	bgSelect.option('White Background', 255);
	bgSelect.option('Black Background', 0);
	controls2.child(bgSelect);
	bgSelect.selected(255);
	bgSelect.changed(function() {
		bgColor = color(parseInt(bgSelect.value()));
	});
	palettePreviewLabel = createElement('span');
	controls3.child(palettePreviewLabel);
	palettePreviewLabel.html('Palette Preview:');
	palettePreview = createElement('span');
	controls3.child(palettePreview);
	palettePreview.style('font-size', '1.8rem')
	resizeAndRepaint();
	select('div.wrap').style('max-width', 'inherit');
	strokeWeight(2.0 / browserWindowScale);
	strokeJoin(MITER);
	addParticles(1000, color(0, 0, 0, 2), killAfterFrameCount);
	frameRate(500);
	updatePalettePreview();
}

function updatePalettePreview() {
	palettePreview.style('background-color', 'rgb(' + bgColor + ',' + bgColor + ',' + bgColor + ')');
	palettePreview.html('');
	const colors = generateParticlesAndPaletteFromSeed(true);
	for (const c of colors) {
		palettePreview.html(palettePreview.html() + '<span style="color:rgb(' + c[0] + ',' + c[1] + ',' + c[2] + ');">■&nbsp;</span>');
	}
}

function generateParticlesAndPaletteFromSeed(shouldPreviewOnly) {
	const paletteColors = [];
	const theSeed = parseInt(particleSeed.value());
	randomSeed(theSeed);
	if (!shouldPreviewOnly) {
		usedPaletteNumber = theSeed;
	}
	const darkColors = random(1,3);
	const medColors = random(1,3);
	const lightColors = random(1,3);
	const saturation = random(0.2, 1.0);
	for (let i = 0; i < darkColors; i++) {
		const c = getNewRandomColor(saturation, random(0.1, 0.3));
		paletteColors.push(c);
		addParticles(random(200,1000), color(c[0], c[1], c[2], 2), random(1000,5000), shouldPreviewOnly);
	}
	for (let i = 0; i < medColors; i++) {
		const c = getNewRandomColor(saturation, random(0.4, 0.7));
		paletteColors.push(c);
		addParticles(random(200,1000), color(c[0], c[1], c[2], 2), random(1000,5000), shouldPreviewOnly);
	}
	for (let i = 0; i < lightColors; i++) {
		const c = getNewRandomColor(saturation, random(0.8, 1.0));
		paletteColors.push(c);
		addParticles(random(200,1000), color(c[0], c[1], c[2], 2), random(1000,5000), shouldPreviewOnly);
	}
	return paletteColors;
}

// using an integer seed, generate a palette and some dark, medium, and light colors
// good palettes:
// 11   - pastel
// 17 - earth tones with purple
// 28 - white/purple/coral (good on black)
// 30 - blue/green
// 37 - pale green
// 529 - fairly bright rainbow-ish
// 999 - big palette
// 1100 - earth tones
function restart() {
	randomColorH = 0.0;
	particles.length = 0;
	resizeAndRepaint();
	generateParticlesAndPaletteFromSeed(false);
}

function addParticles(number, color, ttl, shouldPreviewOnly = false) {
	if (shouldPreviewOnly) {
		return;
	}
	for (let i = 0; i < parseInt(number / browserWindowScale); i++) {
		particles.push(new Particle(color, parseInt(ttl / browserWindowScale)));
	}
	if (statusSpan.html().includes("done")) {
		statusSpan.html("<small></small>");
	}
	loop();
}

function draw() {
	for (let i = 0; i < fpsMultiple; i++) {
		let anyAlive = false;
		for (let p of particles) {
			if (p.dead) {
				continue;
			}
			anyAlive = true;
			const angleAtPos = noise(
				p.pos.x * vectorNoiseScale,
				p.pos.y * vectorNoiseScale,
				noiseZ) * TWO_PI;
			p.applyForce(p5.Vector.fromAngle(angleAtPos));
			p.update();
			p.show();
		}
		noiseZ += vectorGridNoiseIncrZ;
		if (!anyAlive) {
			console.log("stopping after frame count [" + frameCount + "]");
			noLoop();
			particles.length = 0; // a way to clear a const array
			statusSpan.html("<small>done</small>");
			fpsSpan.html("<small>- fps</small>");
		}
		if (frameCount % 200 == 0) {
			let ttlMax = 0;
			let particlesCount = 0;
			for (let p of particles) {
				if (p.dead) {
					continue;
				}
				particlesCount++;
				if (p.ttl > ttlMax) {
					ttlMax = p.ttl;
				}
			}
			statusSpan.html("<small>TTL: " + (ttlMax).toLocaleString() + " - particles: " + (particlesCount).toLocaleString() + "</small>");
			fpsSpan.html("<small>" + round(frameRate() * fpsMultiple, 0) + " fps</small>");
		}
	}
}

class Particle {

	constructor(color, ttl) {
		this.color = color;
		this.ttl = ttl;
		this.pos = createVector(random(width), random(height));
		this.vel = createVector(0.0, 0.0);
		this.acc = createVector(0.0, 0.0);
		this.prev = this.pos.copy();
		this.dead = false;
	}

	updatePrev() {
		this.prev.x = this.pos.x;
		this.prev.y = this.pos.y;
	}

	update() {
		this.ttl--;
		this.updatePrev();

		// slow proportionally to speed squared
		// max speed is still slightly too high (gaps in line), so increase from 0.1 to 0.152
		let slow = this.vel.copy();
		slow.mag((slow.mag() * slow.mag()) * 0.1);
		this.vel.sub(slow);
		//this.vel.sub(p5.Vector.mult(this.vel, 0.152));
		this.vel.add(this.acc);
		this.pos.add(this.vel);
		this.acc.mult(0.0);

		if (this.pos.x > width) {
			this.pos.x = 0;
			this.updatePrev();
			if (this.ttl <= 0) {
				this.dead = true;
			}
		} else if (this.pos.x < 0) {
			this.pos.x = width;
			this.updatePrev();
			if (this.ttl <= 0) {
				this.dead = true;
			}
		}
		if (this.pos.y > height) {
			this.pos.y = 0;
			this.updatePrev();
			if (this.ttl <= 0) {
				this.dead = true;
			}
		} else if (this.pos.y < 0) {
			this.pos.y = height;
			this.updatePrev();
			if (this.ttl <= 0) {
				this.dead = true;
			}
		}
	}

	applyForce(forceVec) {
		this.acc.add(forceVec);
	}

	show() {
		stroke(this.color);
		//point(this.pos.x, this.pos.y);
		// overlapping line ends create visible "dots" all along the lines
		//line(this.pos.x, this.pos.y, this.prev.x, this.prev.y);
		// shrink the line a little to avoid the dots -- this has to be fine-tuned
		//   with the force that slows particles down to also eliminate gaps
		//   between these line segments
		const lineBeg = p5.Vector.lerp(this.pos, this.prev, 0.09);
		const lineEnd = p5.Vector.lerp(this.pos, this.prev, 0.91);
		line(lineBeg.x, lineBeg.y, lineEnd.x, lineEnd.y);
	}
}

</script>
<main style="text-align:center;"></main>
<div id="controls" style="text-align:center; font-size:1.1rem; margin-bottom:0.3rem;"></div>
<div id="controls2" style="text-align:center; font-size:1.1rem; margin-bottom:0.3rem;"></div>
<div id="controls3" style="text-align:center; font-size:1.1rem;"></div>
<div style="max-width: 52rem;margin-left: auto;margin-right: auto;">
<p>Particles are pushed around in a slowly changing flow field.  Each leaves a thin
trail of a certain color as it moves.  Once their TTL (time to live) is depleted,
the particles are removed.</p>
<p>The "Add Particles" controls create new small groups of particles with each button click.</p>
<p>The "Palette" controls create a unique set of particles depending on the palette number.</p>
<p>The "Scale" dropdown box allows higher resolution images when the browser window is scaled down.
It also allows other creative opportunities when changed while the image is being drawn.  At smaller
scales more particles are created so faster speeds may make the browser window unresponsive.</p>
<p>This is based on
<a target="_blank" href="https://www.youtube.com/watch?v=BjoM9oKOAKY">a Coding Train video by Daniel Shiffman</a>.</p>
</div>