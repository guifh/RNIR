---
title: "Multiplicative Scatter Correction (MSC)"
output: md_document
sidebar: mydoc_sidebar
permalink: MSC.html
folder: mydoc
---



<br>

Multiplicative Scatter Correction [(Geladi et al., 1985)](https://www.osapublishing.org/as/abstract.cfm?uri=as-39-3-491), as its name indicates, is typically used to compensate for light scattering effects and changes in path length. Indeed, light scattering from solid samples and emulsions can result in multiplicative deviations that are dependent on the wavelength [(Heise & Winzen, 1985)](http://onlinelibrary.wiley.com/doi/10.1002/9783527612666.ch07/summary). MSC minimizes these deviations by fitting a linear model between a reference spectrum and other spectra of the dataset using the linear least squares method. The reference spectrum is often chosen as the average of all spectra in the dataset. The model coefficients are used to compute the ideal (i.e. msc corrected) spectra. Following application of MSC, all spectra appear to have the same absorbance level. MSC and [SNV](SNV.html) usually lead to similar results. However, as mentioned, MSC requires the use of a reference spectrum while SNV does not. 

MSC can be performed using the *msc* function in the [pls](https://cran.r-project.org/web/packages/pls/index.html) package:   


{% highlight r %}
library(pls)

#Perform MSC correction:
newspectra<-msc(as.matrix(mydata$NIR))            
mydataMSC<-data.frame(mydata[,1:6], NIR = I(newspectra))             

#Plot new spectra:
myBasicPlot(mydataMSC, wavelengths, xlim, ylim = c(0,0.8))  
{% endhighlight %}

<img src="images/MSC-1.svg" title="plot of chunk MSC" alt="plot of chunk MSC" style="display: block; margin: auto;" />

