// as of 2021-11-09, minify with https://codebeautify.org/minify-js
"function"==typeof importScripts&&importScripts("infnum.js");const plots=[{name:"Mandelbrot-set",calcFrom:"window",desc:"The Mandelbrot set is the set of complex numbers, that when repeatedly plugged into the following simple function, does <i>not</i> run away to infinity.  The function is z<sub>n+1</sub> = z<sub>n</sub><sup>2</sup> + c.<br/>For each plotted point <code>c</code>, we repeat the above function many times.<br/>If the value jumps off toward infinity after say 10 iterations, we display a color at the pixel for point <code>c</code>.<br/>If the value doesn't go off toward infinity until say 50 iterations, we pick a quite different color for that point.<br/>If, after our alloted number of iterations has been computed, the value still hasn't gone off to infinity, we color that pixel the backgrond color (defaulting to black).<br/><br/>Wikipedia has a terrific <a target='_blank' href='https://en.wikipedia.org/wiki/Mandelbrot_set'>article with pictures</a>.<br/><br/>My favorite explanation I've found so far is <a target='_blank' href='https://www.youtube.com/watch?v=FFftmWSzgmk'>this Numberphile video on YouTube</a>.<br/><br/><b>Tips for using this Mandelbrot set viewer</b>:<br/>- When not zoomed in very far, keep the <code>n</code> (iterations) parameter low for faster calculation (use N and M keys to decrease/increase the <code>n</code> value).<br/>- To see more detail when zoomed in, increase the <code>n</code> (iterations) parameter with the M key.  Calculations will be slower.",computeBoundPointColor:function(e,n,t,r,o){const i=e,a=infNum(4n,0n);if(t){let e=parseFloat(infNumExpStringTruncToLen(r,15)),n=parseFloat(infNumExpStringTruncToLen(o,15)),t=0,a=0,s=0,u=0,c=0,m=0;for(;m<i&&(s=t*t,u=a*a,!(s+u>4));)c=e+(s-u),a=n+2*t*a,t=c,m++;return m==i?-1:m/i}const s=infNum(2n,0n);var u=infNum(0n,0n),c=infNum(0n,0n),m=infNum(0n,0n),f=infNum(0n,0n),d=infNum(0n,0n),l=0;try{for(;l<i&&(m=infNumMul(u,u),f=infNumMul(c,c),!infNumGt(infNumAdd(m,f),a));)d=infNumAdd(r,infNumSub(m,f)),c=infNumAdd(o,infNumMul(s,infNumMul(u,c))),u=d,u=infNumTruncateToLen(u,n),c=infNumTruncateToLen(c,n),l++;return l==i?-1:l/i}catch(e){return console.log("ERROR CAUGHT when processing point (x, y, iter, maxIter): ["+infNumToString(r)+", "+infNumToString(o)+", "+l+", "+i+"]:"),console.log(e.name+": "+e.message+":\n"+e.stack.split("\n").slice(0,5).join("\n")),windowCalcIgnorePointColor}},computeBoundPointColorNew:function(e,n,t){const r=historyParams.n;var o=infNum(0n,0n),i=infNum(0n,0n),a=null,s=null,u=null,c=null,m=null,f=null,d=null,l=0;try{for(;l<r&&(a=infNumMul(o,o),s=infNumMul(i,i),u=infNumMul(o,i),f=copyInfNum(n),d=copyInfNum(t),c=normInPlaceInfNum(e.boundsRadiusSquared,a,s,f,d,u),!infNumGtNorm(infNumAddNorm(a,s),c));)m=infNumAddNorm(f,infNumSubNorm(a,s)),i=infNumAddNorm(d,infNumMul(e.two,u)),o=infNumTruncate(m),i=infNumTruncate(i),l++;return l==r?-1:e.applyColorCurve(l/r)}catch(e){return console.log("ERROR CAUGHT when processing point (x, y, iter, maxIter): ["+infNumToString(n)+", "+infNumToString(t)+", "+l+", "+r+"]:"),console.log(e.name+": "+e.message+":\n"+e.stack.split("\n").slice(0,5).join("\n")),windowCalcIgnorePointColor}},forcedDefaults:{n:40,scale:infNum(400n,0n),centerX:createInfNum("-0.65"),centerY:infNum(0n,0n)},privContext:{usesImaginaryCoordinates:!0,two:infNum(2n,0n),boundsRadiusSquared:infNum(4n,0n),colors:{},applyColorCurve:function(e){return e<0?0:e>1?1:e},circles:[{centerX:createInfNum("-0.29"),centerY:infNum(0n,0n),radSq:createInfNum("0.18")},{centerX:createInfNum("-0.06"),centerY:createInfNum("0.22"),radSq:createInfNum("0.13")},{centerX:createInfNum("-0.06"),centerY:createInfNum("-0.22"),radSq:createInfNum("0.13")},{centerX:createInfNum("-1.0"),centerY:createInfNum("0.0"),radSq:createInfNum("0.04")}],adjustPrecision:function(e){const n=infNumTruncateToLen(e,8);infNumLt(n,createInfNum("1000"))||infNumLt(n,createInfNum("2,000,000".replaceAll(",","")))?(mandelbrotFloat=!0,precision=12):infNumLt(n,createInfNum("30,000,000,000,000".replaceAll(",","")))?(mandelbrotFloat=!0,precision=20):(mandelbrotFloat=!1,precision=24)},minScale:createInfNum("20")}},{name:"Primes-1-Step-90-turn",calcFrom:"sequence",desc:"Move 1 step forward per integer, but for primes, turn 90 degrees clockwise before moving.",computePointsAndLength:function(e){var n=[],t=0;historyParams.n>5e6&&(historyParams.n=5e6);const r=historyParams;var o=getPoint(0,0);e.direction=0;for(var i=1;i<r.n;i+=1)isPrime(i)&&(n.push(o),e.direction=e.changeDirection(e.direction)),o=e.computeNextPoint(e.direction,i,o.x,o.y),t+=1;return n.push(o),{points:n,length:t}},forcedDefaults:{n:6e4,scale:createInfNum("1.2"),centerX:createInfNum("-240"),centerY:createInfNum("288")},privContext:{direction:0,changeDirection:function(e){return changeDirectionDegrees(e,90)},computeNextPoint:function(e,n,t,r){return computeNextPointDegrees(e,1,t,r)}}},{name:"Primes-1-Step-45-turn",calcFrom:"sequence",desc:"Move 1 step forward per integer, but for primes, turn 45 degrees clockwise before moving.  When moving diagonally, we move 1 step on both the x and y axes, so we're actually moving ~1.414 steps diagonally.",computePointsAndLength:function(e){var n=[],t=0;historyParams.n>5e6&&(historyParams.n=5e6);const r=historyParams;var o=getPoint(0,0);e.direction=315;for(var i=1;i<r.n;i+=1)isPrime(i)&&(n.push(o),e.direction=e.changeDirection(e.direction)),o=e.computeNextPoint(e.direction,i,o.x,o.y),t+=1;return n.push(o),{points:n,length:t}},forcedDefaults:{n:6e4,scale:createInfNum("0.85"),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},privContext:{direction:0,changeDirection:function(e){return changeDirectionDegrees(e,45)},computeNextPoint:function(e,n,t,r){return computeNextPointDegrees(e,1,t,r)}}},{name:"Squares-1-Step-90-turn",calcFrom:"sequence",desc:"Move 1 step forward per integer, but for perfect squares, turn 90 degrees clockwise before moving.",computePointsAndLength:function(e){var n=[],t=0;historyParams.n>1e6&&(historyParams.n=1e6);const r=historyParams;var o=getPoint(0,0);e.direction=270;for(var i=1;i<r.n;i+=1)e.isSquare(i)&&(n.push(o),e.direction=e.changeDirection(e.direction)),o=e.computeNextPoint(e.direction,i,o.x,o.y),t+=1;return n.push(o),{points:n,length:t}},forcedDefaults:{n:5e3,scale:createInfNum("6.5"),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},privContext:{direction:0,changeDirection:function(e){return changeDirectionDegrees(e,90)},computeNextPoint:function(e,n,t,r){return computeNextPointDegrees(e,1,t,r)},isSquare:function(e){const n=Math.sqrt(e);return n==Math.trunc(n)}}},{name:"Squares-1-Step-45-turn",calcFrom:"sequence",desc:"Move 1 step forward per integer, but for perfect squares, turn 45 degrees clockwise before moving.  When moving diagonally, we move 1 step on both the x and y axes, so we're actually moving ~1.414 steps diagonally.",computePointsAndLength:function(e){var n=[],t=0;const r=Math.sqrt(2);historyParams.n>1e6&&(historyParams.n=1e6);const o=historyParams;var i=getPoint(0,0);e.direction=270;for(var a=1;a<o.n;a+=1)e.isSquare(a)&&(n.push(i),e.direction=e.changeDirection(e.direction)),i=e.computeNextPoint(e.direction,a,i.x,i.y),t+=e.direction%90==0?1:r;return n.push(i),{points:n,length:t}},forcedDefaults:{n:5e3,scale:createInfNum("2.3"),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},privContext:{direction:0,changeDirection:function(e){return changeDirectionDegrees(e,45)},computeNextPoint:function(e,n,t,r){return computeNextPointDegrees(e,1,t,r)},isSquare:function(e){const n=Math.sqrt(e);return n==Math.trunc(n)}}},{name:"Primes-X-Y-neg-mod-3",calcFrom:"sequence",desc:"Where each plotted point <code>(x,y)</code> consists of the primes, in order.  Those points are (2,3), (5,7), (11,13), and so on.<br/><br/>Then we take the sum of the digits of both the <code>x</code> and <code>y</code> of each point.<br/>If that sum, mod 3, is 1, the <code>x</code> is negated.<br/>If that sum, mod 3, is 2, the <code>y</code> is negated.<br/><br/>After applying the negation rule, the first three plotted points become:<br/><code>(2,3)&nbsp;&nbsp;→ sum digits = 5&nbsp;&nbsp;mod 3 = 2 → -y → (2,-3)</code><br/><code>(5,7)&nbsp;&nbsp;→ sum digits = 12 mod 3 = 0 →&nbsp;&nbsp;&nbsp;&nbsp;→ (5,7)</code><br/><code>(11,13)→ sum digits = 6&nbsp;&nbsp;mod 3 = 0 →&nbsp;&nbsp;&nbsp;&nbsp;→ (11,13)</code>",computePointsAndLength:function(e){var n=[],t=0;historyParams.n>1e6&&(historyParams.n=1e6);const r=historyParams;var o=-1,i=getPoint(0,0);n.push(i);for(var a=1;a<r.n;a+=1)if(isPrime(a))if(-1==o)o=a;else{var s=a;const e=(o.toString()+s.toString()).split("");for(var u=0,c=0;c<e.length;c++)u+=e[c];const r=u%3;1==r?o*=-1:2==r&&(s*=-1);const m=getPoint(parseFloat(o),parseFloat(s));t+=Math.hypot(m.x-i.x,m.y-i.y),n.push(m),o=-1,i=m}return{points:n,length:t}},forcedDefaults:{n:5e3,scale:createInfNum("0.08"),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},privContext:{}},{name:"Trapped-Knight",calcFrom:"sequence",desc:"On a chessboard, where the squares are numbered in a spiral, find the squares a knight can jump to in sequence where the smallest-numbered square must always be taken.  Previously-visited squares cannot be returned to again.  After more than 2,000 jumps the knight has no valid squares to jump to, so the sequence ends.<br/><br/>Credit to The Online Encyclopedia of Integer Sequences:<br/><a target='_blank' href='https://oeis.org/A316667'>https://oeis.org/A316667</a><br/>and to Numberphile:<br/><a target='_blank' href='https://www.youtube.com/watch?v=RGQe8waGJ4w'>https://www.youtube.com/watch?v=RGQe8waGJ4w</a>",computePointsAndLength:function(e){var n=[],t=0;e.visitedSquares={};const r=historyParams;var o=getPoint(0,0);if(!e.isNumberedSquare(e,o)){let n=o;e.trackNumberedSquare(e,0,o);let t=0,r=90;for(let i=1;i<3562;i+=1)t=e.changeDirection(r),n=e.computeNextPoint(t,1,o.x,o.y),e.isNumberedSquare(e,n)?o=e.computeNextPoint(r,1,o.x,o.y):(r=t,o=n),e.trackNumberedSquare(e,i,o)}var i=getPoint(0,0);n.push(i),e.visitSquare(e,0,i);var a=[],s=-1,u=null;for(let o=0;o<r.n;o+=1){a=e.reachableSquares(i);for(let n=0;n<a.length;n++)(-1==s||e.getSquareNumber(e,a[n])<s)&&(e.isVisited(e,a[n])||(u=a[n],s=e.getSquareNumber(e,u)));if(-1==s)break;t+=Math.hypot(u.x-i.x,u.y-i.y),i=u,n.push(getPoint(i.x,-1*i.y)),e.visitSquare(e,s,i),s=-1}return{points:n,length:t}},forcedDefaults:{n:2016,scale:infNum(15n,0n),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},privContext:{boardPoints:{},visitedSquares:{},trackNumberedSquare:function(e,n,t){e.boardPoints[t.x+"-"+t.y]=n},isNumberedSquare:function(e,n){return n.x+"-"+n.y in e.boardPoints},getSquareNumber:function(e,n){const t=n.x+"-"+n.y;return!t in e.boardPoints&&console.log("MISSING SQUARE - "+t),e.boardPoints[t]},visitSquare:function(e,n,t){e.visitedSquares[t.x+"-"+t.y]=n},isVisited:function(e,n){return n.x+"-"+n.y in e.visitedSquares},changeDirection:function(e){return changeDirectionDegrees(e,-90)},computeNextPoint:function(e,n,t,r){return computeNextPointDegrees(e,n,t,r)},reachableSquares:function(e){return[getPoint(e.x+1,e.y-2),getPoint(e.x+2,e.y-1),getPoint(e.x+2,e.y+1),getPoint(e.x+1,e.y+2),getPoint(e.x-1,e.y-2),getPoint(e.x-2,e.y-1),getPoint(e.x-2,e.y+1),getPoint(e.x-1,e.y+2)]},isSquare:function(e){const n=Math.sqrt(e);return n==Math.trunc(n)}}}];