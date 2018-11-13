---
title: "Derivatives"
output: md_document
sidebar: mydoc_sidebar
permalink: Derivative.html
folder: mydoc
toc: false
---



<br>

Derivative can be seen as a special form of baseline correction method as it removes constant background signals. One advantage of derivative is that it can be used to enhance the visual resolution, resolve overlapping peaks and highlight detailed structures in spectra. However, this is done at the cost of increasing noise. Each derivative reduces the polynomial order by one. The first derivative removes a constant offset while the second derivative removes the offset plus a linear term (linear tilting of the spectrum), etc. Change in offset and slope of the spectra can be caused by variations in particle size. Therefore, derivative pre-processing is especially recommended in situations where particle size is a confounding variable. Second-order derivatives are most commonly used because they have distinct troughs at the location of the original peaks [De Maesschalck et al. (1999)](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.571.732), which facilitate spectrum interpretation and absorption bands identification. 
 
The most basic method for derivatization would be to calculate the differences between absorbance levels at sequential wavelengths. However, in practice, this should be avoided as it decreases the signal to noise ratio [Rinnan et al. (2009)](https://www.sciencedirect.com/science/article/pii/S0165993609001629). To limit noise inflation, derivative spectra are computed here using the Savitzky-Golay algorithm already used in the [Smoothing](Smoothing.html#savitsky-golay-method) section. First and second-order derivatives spectra are given below. They were both computed using a filter order of 5 and a second-order polynomial.  



{% highlight r %}
#Compute the first derivative for all spectra:
newspectra<-apply(mydata$NIR, 1, FUN=sgolayfilt, p = 2, n = 5, m = 1, ts = 1)
mydataDERIV1<-data.frame(mydata[,1:6], NIR = I(t(newspectra)))                 

#Plot new spectra:
myBasicPlot(mydataDERIV1, wavelengths, xlim, ylim = c(-0.05,0.1)) 
{% endhighlight %}

<img src="images/Deriv1-1.svg" title="plot of chunk Deriv1" alt="plot of chunk Deriv1" style="display: block; margin: auto;" />




{% highlight r %}
#Compute the second derivative for all spectra:
newspectra<-apply(mydata$NIR, 1, FUN=sgolayfilt, p = 2, n = 5, m = 2, ts = 1)  
mydataDERIV2<-data.frame(mydata[,1:6], NIR = I(t(newspectra)))              

#Plot new spectra:
myBasicPlot(mydataDERIV2, wavelengths, xlim, ylim = c(-0.02,0.02)) 
{% endhighlight %}

<img src="images/Deriv2-1.svg" title="plot of chunk Deriv2" alt="plot of chunk Deriv2" style="display: block; margin: auto;" />

