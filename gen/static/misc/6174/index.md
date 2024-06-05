
[//]: # (gen-title: 6174 - philthompson.me)

[//]: # (gen-keywords: 6174, Kaprekar, Wolfram, Numberphile)

[//]: # (gen-description: JavaScript app for evaluating the Kaprekar Routine for any 4-digit number")

[//]: # (gen-meta-end)

  <h1>6174 <span style="font-weight: normal; font-size: 1.2rem";>(4-digit Kaprekar Routine)</span></h1>
  <p>See <a target="_blank" href="https://www.youtube.com/watch?v=d8TRcZklX_Q">Numberphile on YouTube</a>, <a target="_blank" href="https://mathworld.wolfram.com/KaprekarRoutine.html">The Kaprekar Routine at Wolfram MathWorld</a>, and <a href="./k-digit.html">the <i>k</i>-digit Kaprekar Routine page</a>.</p>
  <p>Also see the <a href="./k-digit.html">k-digit version of this page</a>.</p>
  <p>Enter a 4-digit number.</p>
  <input type="number" id="i" /><br/>
  <div id="p" style="font-family:monospace; margin-top:1.0rem;"></div>

<script type="text/javascript">

var p = document.getElementById('p');
var i = document.getElementById('i');

var next = function(digitStr, iter) {
  if (iter > 100) {
    p.innerHTML += "<br/>stopping after 100 iterations<br/>";
    return;
  } else {
    p.innerHTML += "<span style=\"opacity:0.4;\">" + (iter+1) + "</span><br/>";
  }
  while (digitStr.length < 4) {
    digitStr = '0' + digitStr;
  }
  let d = [];
  d[0] = parseInt(digitStr[0]);
  d[1] = parseInt(digitStr[1]);
  d[2] = parseInt(digitStr[2]);
  d[3] = parseInt(digitStr[3]);
  d.sort();
  let rev = parseInt(d.join(""));
  d.reverse();
  let sor = parseInt(d.join(""));
  let dif = sor - rev;
  p.innerHTML += sor + " <-- sort digits<br/>";
  if (rev < 10) {
    p.innerHTML += "000";
  } else if (rev < 100) {
    p.innerHTML += "00";
  } else if (rev < 1000) {
    p.innerHTML += "0";
  }
  p.innerHTML += rev + " <-- reverse<br/>";
  p.innerHTML += "----<br/>";
  if (dif < 10) {
    p.innerHTML += "000";
  } else if (dif < 100) {
    p.innerHTML += "00";
  } else if (dif < 1000) {
    p.innerHTML += "0";
  }
  p.innerHTML += dif + " <-- subtract <br/>";
	if (dif == 6174) {
    return;
  }
  p.innerHTML += "<br/>";
  next(dif.toString(), iter + 1);
};

var start = function() {
  p.innerHTML = "";
  let s = i.value.replace(/[^0-9]*/g, '');
  if (s.length == 0 || s.length > 4) {
    p.innerHTML = "enter a number from 1-9998 using at least 2 different digits";
    return;
  }
  if (s.length === 4 && s[0] === s[1] && s[1] === s[2] && s[2] === s[3]) {
    p.innerHTML = "enter a number from 1-9998 using at least 2 different digits";
    return;
  }
  let n = parseInt(s);
  if (n <= 0 || n > 9998) {
    p.innerHTML = "enter a number from 1-9998 using at least 2 different digits";
  } else if (n >= 1 && n <= 9998) {
    while (s.length < 4) {
      s = '0' + s;
    }
    p.innerHTML = s + " <-- input<br/><br/>";
	  next(s, 0);
  }
};

i.addEventListener("input", start);
if (i.value.length > 0) {
  start();
}

</script>
