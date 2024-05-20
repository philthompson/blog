
[//]: # (gen-title: Click Counter - philthompson.me)

[//]: # (gen-keywords: counter, image, numbering, counting)

[//]: # (gen-description: JavaScript app for counting things in images")

[//]: # (gen-meta-end)

<script src="../p5-v1.9.0.min.js"></script>
<script>

let canvasElement;
let loadedImage = null;
let imageScale = 1.0;
let offsetX = 0;
let offsetY = 0;
let debugParagraph;
let countParagraph;
let frameRateReduceTimer = null;
let resetCountBtn;
let undoBtn;
let points = [];
let mousePressedX;
let mousePressedY;
let opacitySlider;
let opacitySliderLabel;
let sizeSlider;
let sizeSliderLabel;
let labelOpacity = 100;
let helpBtn;
let helpActive = true;
let pointDiameter = 32;

function windowResized() {
	const newWidth = windowWidth - 40;
	const newHeight = (newWidth / 4) * 3;
	resizeCanvas(newWidth, newHeight);
}

// when images are dragged and dropped, load only the first one
function setFile(files) {
	if (files.length == 0) {
		return;
	}
	for (let i = 0; i < files.length; i++) {
		const file = files[i];
		if (!file.type.startsWith('image/')) {
			continue;
		}
		const reader = new FileReader();
		reader.addEventListener("load", () => {
			// load with p5.js
			loadImage(reader.result, handleLoadedImage);
		}, false);
		reader.readAsDataURL(file);
		return;
	}
}

function handleLoadedImage(img) {
	loadedImage = img;
	imageScale = min(1.0, width / loadedImage.width);
	offsetX = (width - (loadedImage.width * imageScale)) / 2;
	offsetY = (height - (loadedImage.height * imageScale)) / 2;
	helpActive = false;
	increaseFrameRateTemporarily();
}

function setup() {
	let c = createCanvas(1200, 800);
	background(0);
	windowResized();
	stroke(255, 255, 255, labelOpacity);
	textAlign(CENTER, CENTER);
	textStyle(BOLD);
	canvasElement = c.elt; // underlying js element
	canvasElement.addEventListener("dragenter", function(e) {
		e.stopPropagation();
		e.preventDefault();
	}, false);
	canvasElement.addEventListener("dragover", function(e) {
		e.stopPropagation();
		e.preventDefault();
	}, false);
	canvasElement.addEventListener("drop", function(e) {
		e.stopPropagation();
		e.preventDefault();
		setFile(e.dataTransfer.files);
	}, false);
	const controls = select('div.controls');
	countParagraph = createElement('span');
	countParagraph.style('margin', '0 0.3rem');
	controls.child(countParagraph);
	resetCountBtn = createButton("Reset");
	resetCountBtn.mousePressed(resetCount);
	resetCountBtn.style('float', 'left');
	controls.child(resetCountBtn);
	undoBtn = createButton("Undo");
	undoBtn.mousePressed(undo);
	controls.child(undoBtn);
	helpBtn = createButton("?");
	helpBtn.mousePressed(toggleHelp);
	controls.child(helpBtn);
	opacitySlider = createSlider(0, 255, labelOpacity);
	opacitySlider.size(80);
	opacitySlider.changed(changeOpacity);
	opacitySlider.style('vertical-align', 'middle');
	opacitySlider.style('margin', '0 0.6rem');
	controls.child(opacitySlider);
	opacitySliderLabel = createElement('span');
	controls.child(opacitySliderLabel);
	sizeSlider = createSlider(10, 60, pointDiameter);
	sizeSlider.size(80);
	sizeSlider.changed(changeSize);
	sizeSlider.style('vertical-align', 'middle');
	sizeSlider.style('margin', '0 0.6rem 0 1.2rem');
	controls.child(sizeSlider);
	sizeSliderLabel = createElement('span');
	controls.child(sizeSliderLabel);
	debugParagraph = createElement('span');
	debugParagraph.style('float', 'right');
	controls.child(debugParagraph);
	for (const b of selectAll('button')) {
		b.style('margin', '0.4rem');
		b.style('font-size', '1.2rem');
		b.style('padding', '0.5rem 1.0rem 0.5rem 1.0rem');
	}
	changeOpacity();
	changeSize();
	displayCount();
	select('div.wrap').style('max-width', 'inherit');
	noLoop();
}

function keyPressed() {
	if (loadedImage === null) {
		return;
	}
	if (key === 'ArrowDown') {
		offsetY -= 50;
		increaseFrameRateTemporarily();
	} else if (key === 'ArrowUp') {
		offsetY += 50;
		increaseFrameRateTemporarily();
	} else if (key === 'ArrowRight') {
		offsetX -= 50;
		increaseFrameRateTemporarily();
	} else if (key === 'ArrowLeft') {
		offsetX += 50;
		increaseFrameRateTemporarily();
	} else if (key === '-') {
		imageScale -= 0.1;
		imageScale = max(0.1, imageScale);
		increaseFrameRateTemporarily();
	} else if (key === '+' || key === '=') {
		imageScale += 0.1;
		imageScale = min(5.0, imageScale);
		increaseFrameRateTemporarily();
	} else if (key === ' ') {
		addPoint(mouseX, mouseY);
	} else if (key === 'u' || key === 'U') {
		undo();
	} else {
		// for non-handled keys, don't prevent default browser action
		return;  // return true here?  or just return?
	}
	// for handled keys, prevent browser action
	return false;
}

function toggleHelp() {
	helpActive = !helpActive;
	draw();
}

function displayCount() {
	countParagraph.html("count: " + points.length.toLocaleString());
}

function resetCount() {
	points = [];
	displayCount();
	increaseFrameRateTemporarily();
}

function undo() {
	if (points.length > 0) {
		points.pop();
	}
	displayCount();
	increaseFrameRateTemporarily();
}

function changeOpacity() {
	labelOpacity = opacitySlider.value();
	stroke(255, 255, 255, labelOpacity);
	opacitySliderLabel.html("<small>opacity " + round(labelOpacity * 100 / 255) + "%</small>");
	increaseFrameRateTemporarily();
}

function changeSize() {
	pointDiameter = sizeSlider.value();
	sizeSliderLabel.html("<small>size " + round(pointDiameter) + "</small>");
	textSize(15 * (pointDiameter/32.0));
	increaseFrameRateTemporarily();
}

function mousePressed(event) {
	if (event.originalTarget != canvas || event.offsetX < 0 || event.offsetX > width || event.offsetY < 0 || event.offsetY > height) {
		return;
	}
	mousePressedX = event.offsetX;
	mousePressedY = event.offsetY;
}

function mouseReleased(event) {
	if (loadedImage === null || event.originalTarget != canvas || event.offsetX < 0 || event.offsetX > width || event.offsetY < 0 || event.offsetY > height) {
		return;
	}
	if (abs(event.offsetX - mousePressedX) > 5 || abs(event.offsetY - mousePressedY) > 5) {
		return;
	}
	if (keyIsDown(SHIFT)) {
		const maxDistSq = pointDiameter * pointDiameter;
		for (let i = 0; i < points.length; i++) {
			const dx = event.offsetX - ((points[i].x * imageScale) + offsetX);
			const dy = event.offsetY - ((points[i].y * imageScale) + offsetY);
			if (dx * dx + dy * dy < maxDistSq) {
				points.splice(i, 1);
				displayCount();
				increaseFrameRateTemporarily();
				break;
			}
		}
	} else {
		addPoint(event.offsetX, event.offsetY);
	}
}

function addPoint(x, y) {
	const mouseXPct = (x - offsetX) / (loadedImage.width * imageScale);
	const mouseYPct = (y - offsetY) / (loadedImage.height * imageScale);
	points.push({x: mouseXPct * loadedImage.width, y: mouseYPct * loadedImage.height});
	displayCount();
	increaseFrameRateTemporarily();
}

function draw() {
	background(0);
	if (loadedImage === null) {
		if (helpActive) {
			drawHelp();
		}
		return;
	}
	// draw the image
	image(loadedImage,
		offsetX,
		offsetY,
		loadedImage.width * imageScale,
		loadedImage.height * imageScale);
	// draw the points
	let i = 0;
	for (const p of points) {
		i++;
		const px = (p.x * imageScale) + offsetX;
		const py = (p.y * imageScale) + offsetY;
		strokeWeight(2.0 * (pointDiameter/32.0));
		fill(0, 0, 0, labelOpacity);
		circle(px, py, pointDiameter);
		strokeWeight(0);
		fill(255, 255, 255, labelOpacity);
		text(i, px, py);
	}
	//if (random(1, 10) < 2) {
	//	debugParagraph.html("<small>" + round(frameRate(), 0) + " fps</small>");
	//}
	if (helpActive) {
		drawHelp();
	}
}

function drawHelp() {
	textStyle(NORMAL);
	textSize(22);
	fill(255, 255, 255, 198);
	text(
		"Count things in images!  Drag and drop an image here to start.\n" +
		"\n" +
		"• drag to pan\n" +
		"• scroll to zoom\n" +
		"• click (or spacebar) to add a point\n" +
		"• shift+click to remove a point\n" +
		"• use U key to remove the last point\n" +
		"• right-click and \"Save Image As\" to save the annotated image",
		width/2, height/2);
	textStyle(BOLD);
	textSize(pointDiameter/3);
}

function mouseWheel(event) {
	if (loadedImage === null || event.originalTarget != canvas) {
		return;
	}
	// save initial mouse position relative to the image
	const initialMouseXPct = (event.offsetX - offsetX) / (loadedImage.width * imageScale);
	const initialMouseYPct = (event.offsetY - offsetY) / (loadedImage.height * imageScale);
	// change scale linearly for now
	if (event.delta > 0) {
		imageScale -= 0.1;
	} else {
		imageScale += 0.1;
	}
	// clamp the scale
	imageScale = min(5.0, imageScale);
	imageScale = max(0.1, imageScale);
	const scaledWidth = loadedImage.width * imageScale;
	const scaledHeight = loadedImage.height * imageScale;
	// change offset so final mouse position doesn't change after scale change
	const newMouseXPct = (event.offsetX - offsetX) / scaledWidth;
	const newMouseYPct = (event.offsetY - offsetY) / scaledHeight;
	offsetX -= (initialMouseXPct - newMouseXPct) * scaledWidth;
	offsetY -= (initialMouseYPct - newMouseYPct) * scaledHeight;
	// prevent any default scrolling behavior
	increaseFrameRateTemporarily();
	return false;
}

function mouseDragged(event) {
	if (loadedImage === null || event.originalTarget != canvas) {
		return;
	}
	if (event.movementX != 0) {
		offsetX += event.movementX;
	}
	if (event.movementY != 0) {
		offsetY += event.movementY;
	}
	increaseFrameRateTemporarily();
}

function increaseFrameRateTemporarily() {
	if (frameRateReduceTimer !== null) {
		clearTimeout(frameRateReduceTimer);
	}
	loop();
	frameRate(60);
	// (new Date()).getTime()
	frameRateReduceTimer = setTimeout(function() {
		//frameRate(1);
		noLoop();
		frameRateReduceTimer = null;
	}, 5000);
}
</script>
<main style="text-align:center;"></main>
<div class="controls" style="text-align:center; font-size:1.5rem;"></div>
