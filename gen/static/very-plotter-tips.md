
[//]: # (gen-title: Very Plotter Tips - philthompson.me)

[//]: # (gen-keywords: very plotter, help, tips, mandelbrot set)

[//]: # (gen-description: Tips for using Very Plotter, especially for the Mandelbrot set viewer)

[//]: # (gen-meta-end)

Tips and FAQs for using <a target="_blank" href="${SITE_ROOT_REL}/very-plotter/">Very Plotter</a>, especially for the Mandelbrot set plot.

# Contents

Mandelbrot set

* [Screen shows black](#mandel-screen-black)
* [Too few colors](#mandel-too-few-colors)
* [Tips](#mandel-tips)

General

* [Saving the image](#save-image)
* [Centering](#centering)
* [Box zoom](#box-zoom)
* [Fast zoom](#fast-zoom)

[Other Questions?](#other)

# Mandelbrot set FAQs

### <a name="mandel-screen-black"></a>Screen shows black, or lots of black is shown in the plot

The "iterations" count needs to be increased.  This will slow down the computation of the plot, but you'll see more detail in computationally-dense regions.  To increase the iterations count:

* hit the **M** key
  * this will add 100 to the iterations count and immediately start re-computing the plot
  * depending on the scale and location, you may have to increase the iterations by a few thousand or more

or

1. click the wrench button to open the controls menu
1. expand the "iterations" section
1. enter a new value
1. hit the "Go" button

### <a name="mandel-too-few-colors"></a>Too few colors are being used

This usually happens because you are "zoomed in" on an area containing similar colors.  The easiest way to display more colors is:

1. click the wrench button
1. expand the "gradient editor" section
1. in the "gradient" text box, add a "-mod100" to the end of the gradient
  * a smaller number shows more colors on the screen, and a larger number shows fewer
  * if a "-mod#" is already there, try a larger or smaller value there
  * expand the "?" section inside the gradient editor for more information on how the "-mod#" works
1. hit the "Go" button

### <a name="mandel-tips"></a>Tips

* use [box zoom](#box-zoom) for better control and faster zooming when exploring the Mandelbrot set
* use multiple workers to vastly speed up Mandelbrot set computation
  * use 1 fewer worker than <a target="_blank" href="https://www.howtogeek.com/762125/how-to-see-how-many-cores-your-processor-has/">the number of cores/threads your CPU has</a>
    * for example, if your computer has 8 cores, you can try using 7 workers
  * as of March 2023, workers (specifically, nested workers) don't work in Safari (iOS and Mac) yet, but it looks like it'll work soon!
* to prevent accidentally changing the Mandelbrot window, use **shift+alt+L** to lock the window
  * or use the "window lock" checkbox in the "window options" section of the controls menu
* while a Mandelbrot set window is rendering, you can experiment with different gradients without restarting the computation
* use the "smooth" setting in the "smooth and slope" section of the controls menu
* the "slope shading" setting can be changed without causing a full re-render
  * this only works after the full render is completed
* once you've found a Mandelbrot set window you'd like to save as an image, render a larger size, then shrink down, to create a higher-quality render:
  1. lock the window (see above)
  1. in the "window options" section of the controls menu, change "render size" to 2x
  1. once the larger render completes, use the "Save Image" button
  1. using a photo editing software, shrink the saved image down to 50% or 25% size
* if you find a location you want to save, just make a note of the page URL!

# General Tips

### <a name="save-image"></a>Saving the Image

* To download the rendered image, use the "Save Image" button in the controls menu
  * before downloading the image, use the **T** key to add a legend to the final image

### <a name="centering"></a>Centering

* Use **Shift+click** to center the view on an exact location

### <a name="box-zoom"></a>Box zoom

* hold the **alt** key (option on Mac) and drag mouse to draw a box to zoom into
* this is the best way to control the zoom for slow-rendering Mandelbrot set locations

### <a name="fast-zoom"></a>Fast zoom

* Use the **E** key to zoom in (increase the scale by 10x) and **Q** to zoom out
  * for fine-grained zoom control, use the **+** and **-** keys

# <a name="other"></a>Other Questions?

For help using Very Plotter, send mail to "phil" at this domain.

For bug reports, create a new issue <a target="_blank" href="https://github.com/philthompson/visualize-primes/issues">at the GitHub repository</a>, or send mail to "phil" at this domain.