---
title: "Standard Normal Variate (SNV)"
output: md_document
sidebar: mydoc_sidebar
permalink: SNV.html
folder: mydoc
---



<br>


The so-called Standard Normal Variate (SNV) method performs a normalization of the spectra that consists in subtracting each spectrum by its own mean and dividing it by its own standard deviation. After SNV, each spectrum will have a mean of 0 and a standard deviation of 1. 

SNV attempts at making all spectra comparable in terms of intensities (or absorbance level). It can be useful to correct spectra for changes in optical path length and light scattering (it is assumed that the standard deviation of the spectra represents well these changes). SNV is, for example, frequently used to compensate for changes in surface roughness of the material [(Sandak et al., 2016)](https://journals.sagepub.com/doi/abs/10.1255/jnirs.1255). 

Mathematically, SNV is identical to a scaling of the rows instead of the columns of the matrix [(Huang et al., 2010)](https://www.americanpharmaceuticalreview.com/Featured-Articles/116330-Practical-Considerations-in-Data-Pre-treatment-for-NIR-and-Raman-Spectroscopy/) and can therefore be easily performed in R using the *scale* function provided beforehand that the spectral matrix is transposed (so that each column represents a spectrum). To perform this, we create a small *SNV* function:  



{% highlight r %}
#Create SNV function:
SNV<-function(spectra){                                             
  spectra<-as.matrix(spectra)
  spectrat<-t(spectra)
  spectrat_snv<-scale(spectrat,center=TRUE,scale=TRUE)
  spectra_snv<-t(spectrat_snv)
  return(spectra_snv)}

#Perform SNV:
newspectra<-SNV(mydata$NIR)                       
mydataSNV<-data.frame(mydata[,1:6], NIR = I(newspectra))

#Plot new spectra:
myBasicPlot(mydataSNV, wavelengths, xlim, ylim = c(-2,3))   
{% endhighlight %}

<img src="/images/SNV-1.svg" title="plot of chunk SNV" alt="plot of chunk SNV" style="display: block; margin: auto;" />
