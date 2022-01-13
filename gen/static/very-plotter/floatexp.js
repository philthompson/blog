// as of 2021-11-09, minify with https://codebeautify.org/minify-js
function createFloatExpFromInfNum(e){var t=e.v.toString();let n=!1;e.v<0&&(n=!0,t=t.substring(1));t.length;let r=t.length-1,l=parseInt(e.e)+r,v=trimZeroes(t.substring(0,1)+"."+t.substring(1));return v.includes(".")||(v+=".0"),n&&(v="-"+v),{v:parseFloat(v),e:l}}function createFloatExpFromString(e){const t=replaceAllEachChar(e,", ","").replaceAll("E","e").split("e");if(t.length>1){let e=t[0],n=0;if(e.includes(".")){let t=e.split(".");n-=t[1].length,e=t[0]+t[1]}return n+=parseInt(t[1]),floatExpAlign({v:parseFloat(e),e:n})}return floatExpAlign({v:parseFloat(t[0]),e:0})}function createFloatExpFromNumber(e){return floatExpAlign({v:e,e:0})}function floatExpAlign(e){if(0===e.v)return{v:0,e:0};let t=Math.floor(Math.log10(Math.abs(e.v)));return e.v/=10**t,e.e+=t,e}function floatExpMul(e,t){return floatExpAlign({v:e.v*t.v,e:e.e+t.e})}function floatExpDiv(e,t){return floatExpAlign({v:e.v/t.v,e:e.e-t.e})}function floatExpAdd(e,t){if(0===t.v)return e;if(0===e.v)return t;if(e.e>t.e){let n=e.e-t.e;return n>307?e:floatExpAlign({v:e.v+t.v/10**n,e:e.e})}{let n=t.e-e.e;return n>307?t:floatExpAlign({v:t.v+e.v/10**n,e:t.e})}}function floatExpSub(e,t){if(0===t.v)return e;if(0===e.v)return{v:t.v*=-1,e:t.e};if(e.e>t.e){let n=e.e-t.e;return n>307?e:floatExpAlign({v:e.v-t.v/10**n,e:e.e})}{let n=t.e-e.e;return n>307?t:floatExpAlign({v:e.v/10**n-t.v,e:t.e})}}function floatExpEq(e,t){return 0===e.v&&0===t.v||e.e===t.e&&e.v===t.v}function floatExpGt(e,t){return e.v>0?t.v<0||(e.e>t.e||!(e.e<t.e)&&e.v>t.v):!(t.v>0)&&(!(e.e>t.e)&&(e.e<t.e||e.v>t.v))}function floatExpGe(e,t){return floatExpEq(e,t)||floatExpGt(e,t)}function floatExpLt(e,t){return e.v>0?!(t.v<0)&&(!(e.e>t.e)&&(e.e<t.e||e.v<t.v)):t.v>0||(e.e>t.e||!(e.e<t.e)&&e.v<t.v)}function floatExpLe(e,t){return floatExpEq(e,t)||floatExpLt(e,t)}var sqrt10=10**.5;function floatExpSqrt(e){return 0===e.v?e:e.e%2==0?floatExpAlign({v:Math.sqrt(e.v),e:e.e/2}):floatExpAlign({v:Math.sqrt(e.v)*sqrt10,e:Math.floor(e.e/2)})}function floatExpToString(e){return e.v+"e"+e.e}