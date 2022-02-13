function createFloatExpFromInfNum(infNum){var value=infNum.v.toString();let negative=false;if(infNum.v<0){negative=true;value=value.substring(1)}let bd=value.length;let ad=value.length-1;let finalExponent=parseInt(infNum.e)+ad;let decimal=trimZeroes(value.substring(0,1)+"."+value.substring(1));if(!decimal.includes(".")){decimal=decimal+".0"}if(negative){decimal="-"+decimal}return{v:parseFloat(decimal),e:finalExponent}}function createFloatExpFromString(stringNum){const split=replaceAllEachChar(stringNum,", ","").replaceAll("E","e").split("e");if(split.length>1){let value=split[0];let exponent=0;if(value.includes(".")){let valSplit=value.split(".");exponent-=valSplit[1].length;value=valSplit[0]+valSplit[1]}exponent+=parseInt(split[1]);return floatExpAlign({v:parseFloat(value),e:exponent})}else{return floatExpAlign({v:parseFloat(split[0]),e:0})}}function createFloatExpFromNumber(n){return floatExpAlign({v:n,e:0})}function floatExpAlign(a){if(a.v===0){return{v:0,e:0}}let pwr=Math.floor(Math.log10(Math.abs(a.v)));a.v/=10**pwr;a.e+=pwr;return a}function floatExpMul(a,b){return floatExpAlign({v:a.v*b.v,e:a.e+b.e})}function floatExpDiv(a,b){return floatExpAlign({v:a.v/b.v,e:a.e-b.e})}function floatExpAdd(a,b){if(b.v===0){return a}else if(a.v===0){return b}if(a.e>b.e){let eDiff=a.e-b.e;if(eDiff>307){return a}return floatExpAlign({v:a.v+b.v/10**eDiff,e:a.e})}else{let eDiff=b.e-a.e;if(eDiff>307){return b}return floatExpAlign({v:b.v+a.v/10**eDiff,e:b.e})}}function floatExpSub(a,b){if(b.v===0){return a}else if(a.v===0){return{v:b.v*=-1,e:b.e}}if(a.e>b.e){let eDiff=a.e-b.e;if(eDiff>307){return a}return floatExpAlign({v:a.v-b.v/10**eDiff,e:a.e})}else{let eDiff=b.e-a.e;if(eDiff>307){return b}return floatExpAlign({v:a.v/10**eDiff-b.v,e:b.e})}}function floatExpEq(a,b){if(a.v===0&&b.v===0){return true}if(a.e!==b.e){return false}else{return a.v===b.v}}function floatExpGt(a,b){if(a.v>0){if(b.v<0){return true}else if(a.e>b.e){return true}else if(a.e<b.e){return false}else{return a.v>b.v}}else{if(b.v>0){return false}else if(a.e>b.e){return false}else if(a.e<b.e){return true}else{return a.v>b.v}}}function floatExpGe(a,b){return floatExpEq(a,b)||floatExpGt(a,b)}function floatExpLt(a,b){if(a.v>0){if(b.v<0){return false}else if(a.e>b.e){return false}else if(a.e<b.e){return true}else{return a.v<b.v}}else{if(b.v>0){return true}else if(a.e>b.e){return true}else if(a.e<b.e){return false}else{return a.v<b.v}}}function floatExpLe(a,b){return floatExpEq(a,b)||floatExpLt(a,b)}var sqrt10=10**.5;function floatExpSqrt(a){if(a.v===0){return a}if(a.e%2===0){return floatExpAlign({v:Math.sqrt(a.v),e:a.e/2})}else{return floatExpAlign({v:Math.sqrt(a.v)*sqrt10,e:Math.floor(a.e/2)})}}function floatExpToString(n){return n.v+"e"+n.e}var FLOATEXP_LN10=createFloatExpFromNumber(Math.LN10);function floatExpLn(a){const epsilon=floatExpAlign({v:1,e:-20});let aligned=floatExpAlign(a);aligned.v/=10;aligned.e+=1;const one=createFloatExpFromNumber(1);const two=createFloatExpFromNumber(2);const kLimit=createFloatExpFromNumber(1e3);const aMinusOne=floatExpSub(createFloatExpFromNumber(aligned.v),one);let aMinusOnePower=one;let kthTerm=one;let ln=createFloatExpFromNumber(0);let doAdd=false;for(let k=one;floatExpGt(kthTerm,epsilon)&&floatExpLt(k,kLimit);k=floatExpAdd(k,one)){doAdd=!doAdd;aMinusOnePower=floatExpMul(aMinusOnePower,aMinusOne);let kthTerm=floatExpDiv(aMinusOnePower,k);if(doAdd){ln=floatExpAdd(ln,kthTerm)}else{ln=floatExpSub(ln,kthTerm)}}return floatExpAdd(ln,floatExpMul(createFloatExpFromNumber(aligned.e),FLOATEXP_LN10))}