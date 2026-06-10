
<!-- Copyright 2026 Phil Thompson. All Rights Reserved.  As noted in the License section of this repository's readme.md file, this file and its corresponding public HTML file, and all other articles, article files, and images, are distributed under traditional copyright.  The repository source code and other files are distributed under the MIT license. -->

[//]: # (gen-title: Buenos Aires Constant)

[//]: # (gen-title-url: Buenos-Aires-Constant)

[//]: # (gen-keywords: integers, primes, python, Numberphile, youtube)

[//]: # (gen-description: Discussion on calculating and using the Buenos Aires Constant for generating the sequence of primes.)

[//]: # (gen-meta-end)

<a href="${THIS_ARTICLE}"><img style="float: left" class="width-resp-50-100" src="${SITE_ROOT_REL}/s/img/2026/20260610-Buenos-Aires-Constant.jpg"/></a>

Numberphile videos often ["nerd snipe"](https://xkcd.com/356/) me, and it's happened again.  If I had tagging on my posts I'd be able to provide a link here to all my Numberphile-related posts.  Maybe someday.  I tried to make this Numberphile diversion a super quick one. 

The Numberphile video in question here is a few years old.  It's titled ["2.920050977316"](https://www.youtube.com/watch?v=_gCKX6VMvmU), and it introduces the "Buenos Aires Constant," which is a decimal number that generates the sequence of primes.

This constant was first described by four Numberphile viewers in a (paywalled) [formal paper](https://www.tandfonline.com/doi/abs/10.1080/00029890.2019.1530554).  The paper was "Received Sep 16th 2017, Accepted May 29th 2018, Published online: Jan 30th 2019" and the Numberphile video was released Nov. 26th 2020, so it took quite a while to surface for public discussion.

The video demonstrated using the constant to generate primes, and how to calculate the constant given the primes.  What they didn't discuss, however, is *how many* primes can be generated for some number of decimal places.  I wanted to find that out, and also to calculate the constant for myself, so I fired up the text editor and wrote some Python code.

[more](more://)

## Using the Constant

To use the Buenos Aires Constant to calculate the series of primes:

1. Take the decimal portion of the number, and add 1.0 to it.
2. Take the integer portion of the number, and multiply it by the result from the first step.
3. The integer portion of the result is the next prime.
4. Repeat the steps again to get the next prime after that.

For example, we start the sequence with:

<math display="block" style="font-size:1.5rem">
  <mn>2.92005...</mn>
  <mo>&rarr;</mo>
  <mn>2</mn>
</math>

...and find the next prime with:

<math display="block" style="font-size:1.5rem">
  <mn>2.92005...</mn>
  <mo linebreak="goodbreak">&rarr;</mo>
  <mn>2</mn>
  <mo linebreak="goodbreak">&times;</mo>
  <mrow>
  	<mo>(</mo>
  	<mn>1.0</mn>
  	<mn>&plus;</mn>
  	<mn>0.92005...</mn>
  	<mo>)</mo>
  </mrow>
  <mo linebreak="goodbreak">=</mo>
  <mn>3.8401...</mn>
  <mo linebreak="goodbreak">&rarr;</mo>
  <mn>3</mn>
</math>

...and find the following prime with:

<math display="block" style="font-size:1.5rem">
  <mn>3.8401...</mn>
  <mo linebreak="goodbreak">&rarr;</mo>
  <mn>3</mn>
  <mo linebreak="goodbreak">&times;</mo>
  <mrow>
  	<mo>(</mo>
  	<mn>1.0</mn>
  	<mn>&plus;</mn>
  	<mn>0.8401...</mn>
  	<mo>)</mo>
  </mrow>
  <mo linebreak="goodbreak">=</mo>
  <mn>5.5203...</mn>
  <mo linebreak="goodbreak">&rarr;</mo>
  <mn>5</mn>
</math>

...and so on.

## Calculating the Constant

In the Numberphile video, Dr. Grime demonstrated the method for using the series of primes to calculate a value for this constant.  I instead wanted to use a simple algorithm to find it.  And I wanted to write the initial version myself, without using AI.  (I guess we're now at the point where programming projects might be assumed to involve AI unless the programmer says otherwise.)

For my algorithm, I figured something like a binary search would work, where we repeatedly halve the search space between two decimal values.  Based on how many primes the high, middle, and low values each produce, we can select either the high and middle or the middle and low as our new "high" and "low" values, and repeat this process to add decimal digits of precision and approach the value for the constant.

Python has arbitrary precision integers, which is great, but it does not have arbitrary precision "decimal" numbers (*real numbers* in math lingo).  To solve this, we multiply our decimal values by some large `mult` factor to create integers, perform integer math, and finally divide our calculation results by that factor to end up with a decimal value.  When we calculate the middle values for the binary search, we may require an additional digit of precision, so `mult` can be increased at that point.

I initially was using a lot of extra digits of precision, put Claude Opus 4.8 clarified for me that we only need to add a digit of precision when the "high" and "low" values differ by one.  I eventually figured out why that might make sense: for the binary math behind Python's integers, two odd numbers or two even numbers will result in the least significant bit being 0 when they're added.  When that least significant bit is 0, we can divide the sum by two (shifting right by one bit) without any loss of precision.  We only need to increase the precision when the least significant bit of the sum is 1.  That allows us to perform integer division by two to find the midpoint.

This binary search algorithm is a recursive algorithm, but I knew we'd be invoking the recursion many (millions?) times.  So I structured the script as a simple loop with just a Python list to track the stack state.  When we split the "high" and "low" bounds into two new pairs of bounds, we can append both to the stack, and pop the stack at the top of the loop to continue the algorithm.

For the first version of the script I wrote, I didn't discard any stack frames.  Often, the high, middle, and low points would all calculate the same number of primes, so it's impossible to tell which one (the high-middle or the middle-low) contains the true value of the constant.  I was able to calculate a few digits of the constant with this approach, but obviously the stack got huge and the script never really got anywhere.

After a quick consultation with Claude Opus 4.8, I added two lines to the script.  We can discard a stack frame (the high-middle and/or the middle-low) if both ends of the range find fewer primes than the best known value.  That one change allowed the script to instantly run much much faster.

I've published the script [on GitHub](https://github.com/philthompson/buenos-aires-constant).

## How Many Primes Can be Calculated

I used the Python script to output the constant at a few points.  Notice the final digits in the constant values shown here are incorrect.

The first 5 primes can be calculated with 3 decimal places:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  2.921
</div>

10 primes with 8 decimal places:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  2.92005098
</div>

25 primes with 34 decimal places:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  2.9200509773161347120925629171120195
</div>

50 primes with 89 decimal places:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  2.92005097731613471209256291711201946800272789932142671977268253310773377212776612419017812
</div>

100 primes with 217 decimal places:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  2.9200509773161347120925629171120194680027278993214267197726825331077337721277661241901781123175837422983388595531013766557907893508590053204588790664508021842922524112293144747664327267813594016119309348178711518935253
</div>

...and so on.

## Growth Rate

Let's plot a few things to see how these grow with the number of primes:

* The number of digits of the primes themselves, plus a "separator" character between each prime.
* The number of digits of the *difference* from one prime to the next, plus a separator between each.
* The number of digits of the Buenos Aires Constant.
* The number of digits of the "Prime Constant" (more about that in the next section below).

<p class="wrap-wider-child">
	<a target="_blank" href="${SITE_ROOT_REL}/s/img/2026/20260610-Buenos-Aires-Constant-digit-count.png">
		<img class="width-100 center-block" src="${SITE_ROOT_REL}/s/img/2026/20260610-Buenos-Aires-Constant-digit-count.png"/>
	</a>
</p>

I was interested in whether the Buenos Aires Constant is somehow a more "compressed" representation of the sequence of primes.  For example, we can use "1,2,2,4,2,4,2,4,6" (a list of differences between primes) to recreate the prime sequence "2,3,5,7,11,13,17,19,23,29".  That's 17 characters of information to recreate 25.  Using the constant, these first 10 primes can be computed with only 8 (or 10 depending on what you're counting) digits/characters: 2.92005098.

8 or 10 characters is fewer than 17!  So is the constant really able to generate the sequence of primes using less information than is contained in the primes themselves?  No.  While this is true for the first 10 primes, if we look at longer sequences of primes the constant soon overtakes the differences list in required length.  (The constant does require fewer digits than the primes themselves, however, which is kind of interesting.)

If we look at the plot above, for 89 primes or fewer, they are very close but the Buenos Aires Constant does require fewer digits than the differences list.  So that's pretty cool.  For more than 89 primes however, the constant's digit count grows at a faster rate.  From 500 primes to 750 primes, the constant digit count grows at rate of 3.66 digits/chars per prime, while the "differences list with separator" grows at a rate of 2.37 digits/chars per prime.

## Another Prime Constant 

Yes, we have another *unrelated* Numberphile video, released 4 years later in 2024, called ["The Prime Constant"](https://www.youtube.com/watch?v=c066hLi78B0).

This separate "Prime Constant" is a bit more straightforward.  It's just a base 10 representation of the binary number created by setting the Nth binary digit to 0 if the Nth integer is composite, or to 1 if the Nth integer is prime.

Here are some examples:

Encoding the first 5 primes as 1s, in binary and decimal:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  <small>binary:</small>&nbsp;0.01101010001<br/>
  <small>decimal:</small>&nbsp;0.41455078125
</div>

the first 10 primes:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  <small>binary:</small>&nbsp;0.01101010001010001010001000001<br/>
  <small>decimal:</small>&nbsp;0.41468250937759876251220703125
</div>

the first 25 primes:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  <small>binary:</small>&nbsp;0.0110101000101000101000100000101000001000101000100000100000101000001000101000001000100000100000001<br/>
  <small>decimal:</small>&nbsp;0.4146825098511116602481096221538068702774843473102611636667280681223246574518270790576934814453125
</div>

the first 50 primes:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  <small>binary:</small>&nbsp;0.0110101000101000101000100000101000001000101000100000100000101000001000101000001000100000100000001000101000101000100000000000001000100000101000000000101000001000001000100000100000101000000000101000101000000000001000000000001000101<br/>
  <small>decimal:</small>&nbsp;0.4146825098511116602481096221543077083657742381379169778682454144886408867586941032455953206412813334435613920786009132892075204164678657898137136337065750669122623465274037290047540153131201690062113129897625185549259185791015625
</div>

the first 100 primes:

<div class="width-resp-75-100 center-block" style="font-size:1.5rem; font-family:math, serif; overflow-wrap:break-word; word-break:break-all;">
  <small>binary:</small>&nbsp;0.0110101000101000101000100000101000001000101000100000100000101000001000101000001000100000100000001000101000101000100000000000001000100000101000000000101000001000001000100000100000101000000000101000101000000000001000000000001000101000100000101000000000100000100000100000101000001000101000000000100000000000001000101000100000000000001000001000000000101000100000100000001000001000001000100000100000001000100000001000000000101000000000101000001000100000100000001000101000100000000000100000001000100000001000100000100000000000101000000000000000001<br/>
  <small>decimal:</small>&nbsp;0.4146825098511116602481096221543077083657742381379169778682454144886409606193573341962900484284757779396161593520829859578357499784530220099041208146500339589937019719463698857726550764737491289525402177960448300485649399270144063062027297261269103475675013577533525989869815644172219450364743480757145014608334657315406374702088865951121741894711534352997587978930959288731482506758583471621497599219688305550742466759342907926565768905000834693646843352020276828810097398773655849418912899927898711889551197629089074325747787952423095703125
</div>

As you can see in the above plot, the "compression" rate of this "Prime Constant" number is negative.  It requires more digits than the primes themselves.  From 500 primes to 750 primes, the "Prime Constant" grows at a rate of 8.49 digits per prime.  This is much higher than the Buenos Aires Constant at 3.66 digits per prime, and the "differences list with separator" rate of 2.37 digits/chars per prime.

In fact, the "Prime Constant" uses a number of digits equal to the largest prime represented in the number.  In other words, when recording the primes 2 and 3, it uses 3 digits.  When recording 10 primes, up to and including 29, it requires 29 digits to be written out.  Up to and including the 750th prime, 5693, the Prime Constant requires 5,693 digits, while those primes themselves, including a separator character (such as a comma) require 3,552 digits/characters.

Another strange quirk is that a binary value less than one like "0.0110101000101000101" will always have the same number of digits as the base 10 version!  That binary number is "0.4146823883056640625" in decimal, and is also 19-digits long.

## Use Cases

None.  Just recreational math and programming &mdash; it was fun to figure out an algorithm to calculate the constant.
