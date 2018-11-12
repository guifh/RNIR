---
title: "Baseline removal (or de-trending)"
output: md_document
sidebar: mydoc_sidebar
permalink: Baseline.html
folder: mydoc
---



<br>


NIR spectra often exhibit baseline offset and curvilinear trend caused, for example, by changes in illumination angle or optical path length. Baseline removal aims at resetting all spectra on a common baseline. Baseline correction methods are generally simple and often preserve the main spectral shape. However, this is not always the case with more advanced baseline removal methods. In some cases, baseline removal techniques can distorts the real proportions between absorbance peaks and therefore, caution should be used when interpreting the results ([Sandak et al., 2016](https://journals.sagepub.com/doi/abs/10.1255/jnirs.1255)). 

There are plenty of ways to compute the baseline of a spectrum, the most simple using a linear fitting. In this tutorial, we propose using the polynomial fitting method implemented in the [hyperSpec](http://hyperspec.r-forge.r-project.org/) package. The function *spc.fit.poly.below* performs a least squares fitting of a polynomial curve to the base of the spectrum. The curve is then removed from the original spectrum to obtain the baseline corrected spectrum. The baselines of our spectra can be calculated and plotted as follows:


{% highlight r %}
library(hyperSpec)

#Convert mydata to an hyperSpec S4 object:
mydataHS<-new("hyperSpec", spc = as.matrix(mydata$NIR), wavelength = wavelengths)

#Compute baselines using order 2 polynomials:
baseline<-spc.fit.poly.below(fit.to = mydataHS, poly.order = 2)
mybaseline<-data.frame(mydata[,1:6], NIR = I(baseline@data$spc))   

#Plot baseline:  
myBasicPlot(mybaseline, wavelengths, xlim, ylim = c(0,0.8)) 
{% endhighlight %}

<img src="/images/Baseline-1.svg" title="plot of chunk Baseline" alt="plot of chunk Baseline" style="display: block; margin: auto;" />

The baselines can then be removed from the original spectra as follows:


{% highlight r %}
#Baseline removal:
newspectra<-mydataHS@data$spc-baseline@data$spc                     
mydataBSL<-data.frame(mydata[,1:6], NIR = I(newspectra))            

#Plot new spectra:
myBasicPlot(mydataBSL, wavelengths, xlim, ylim = c(0,0.5))  
{% endhighlight %}

<img src="/images/BaselineRm-1.svg" title="plot of chunk BaselineRm" alt="plot of chunk BaselineRm" style="display: block; margin: auto;" />
