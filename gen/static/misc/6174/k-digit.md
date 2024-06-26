
[//]: # (gen-title: 6174: k-digit - philthompson.me)

[//]: # (gen-keywords: 6174, Kaprekar, Wolfram, Numberphile)

[//]: # (gen-description: JavaScript app for evaluating the Kaprekar Routine for any k-digit number")

[//]: # (gen-meta-end)

  <h1><i>k</i>-digit Kaprekar Routine</h1>
  <p>See <a target="_blank" href="https://mathworld.wolfram.com/KaprekarRoutine.html">The Kaprekar Routine at Wolfram MathWorld</a>, and <a href="./index.html">the 4-digit 6174 page</a>.</p>
  <p>Also see the <a href="./index.html">4-digit version of this page</a>.</p>
  <p>Enter a <i>k</i>-digit number.</p>
  <table border="0">
    <tr><td style="text-align: right;">num digits <i>k</i>:</td><td><input type="number" min="2" max="16" value="4" id="n" /></td></tr>
    <tr><td style="text-align: right;">input:</td><td><input type="number" id="i" /></td></tr>
  </table>
  <div id="p" style="font-family:monospace; margin-top:1.0rem;"></div>

<script type="text/javascript">

var p = document.getElementById('p');
var nInput = document.getElementById('n');
var i = document.getElementById('i');
var n = 4;
var seen = [];

var next = function(digitStr, iter) {
  if (iter > 100) {
    p.innerHTML += "<br/>stopping after 100 iterations<br/>";
    return;
  } else {
    p.innerHTML += "<span style=\"opacity:0.4;\">" + (iter+1) + "</span><br/>";
  }
  while (digitStr.length < n) {
    digitStr = '0' + digitStr;
  }
  let d = [];
  for (let i = 0; i < n; i++) {
    d[i] = parseInt(digitStr[i]);
  }
  d.sort();
  let rev = parseInt(d.join(""));
  d.reverse();
  let sor = parseInt(d.join(""));
  let dif = sor - rev;
  let wasLoop = (seen.indexOf(dif) != -1);
  seen.unshift(dif);
  p.innerHTML += sor + " <-- sort digits<br/>";
  for (let i = 1; i < n; i++) {
    if (rev < Math.pow(10, i)) {
      for (let j = 0; j < n - i; j++) {
        p.innerHTML += "0";
      }
      break;
    }
  }
  p.innerHTML += rev + " <-- reverse<br/>";
  p.innerHTML += "----<br/>";
  for (let i = 1; i < n; i++) {
    if (dif < Math.pow(10, i)) {
      for (let j = 0; j < n - i; j++) {
        p.innerHTML += "0";
      }
      break;
    }
  }
  p.innerHTML += dif + " <-- subtract <br/>";
	if (n === 4 && dif == 6174) {
    return;
  }
  if (wasLoop) {
    p.innerHTML += "<br/>loop detected!<br/>";
    return;
  }
  if (dif.toString() == digitStr) {
    return;
  }
  p.innerHTML += "<br/>";
  next(dif.toString(), iter + 1);
};

var start = function() {
  seen = [];
  p.innerHTML = "";
  const nString = nInput.value.replace(/[^0-9]*/g, '');
  if (n.length == 0 || n.length > 1) {
    p.innerHTML = "enter a number of digits, 2-16";
    return;
  }
  n = parseInt(nString);
  if (n < 2 || n > 16) {
    p.innerHTML = "enter a number of digits, 2-16";
    return;
  }
  const inputLengthMsg = "enter a 1-" + n + " digit number using at least 2 different digits";
  let s = i.value.replace(/[^0-9]*/g, '');
  
  if (s.length == 0 || s.length > n) {
    p.innerHTML = inputLengthMsg;
    return;
  }
  let allSameDigit = true;
  for (let i = 1; i < n; i++) {
    if (s[i] !== s[0]) {
      allSameDigit = false;
      break;
    }
  }
  if (allSameDigit) {
    p.innerHTML = inputLengthMsg;
    return;
  }
  const input = parseInt(s);
  if (input <= 0) {
    p.innerHTML = inputLengthMsg;
  } else if (input >= 1) {
    while (s.length < n) {
      s = '0' + s;
    }
    p.innerHTML = s + " <-- input<br/><br/>";
	  next(s, 0);
  }
};

nInput.addEventListener("input", start);
i.addEventListener("input", start);
if (i.value.length > 0) {
  start();
}

</script>
