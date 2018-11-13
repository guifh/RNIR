---
title: "Smoothing"
output: md_document
sidebar: mydoc_sidebar
permalink: Smoothing.html
folder: mydoc
---



<br>

Spectral smoothing aims at reducing high frequency noise (e.g. removing "spikes" in the spectrum). However, when smoothing a spectrum, one should pay attention at not removing high frequency components that represents useful information. A compromise needs to be found by choosing an appropriate smoothing window size. Two main methods for smoothing spectra are presented below: the moving average window and the [Savitzky-Golay algorithm](http://adsabs.harvard.edu/abs/1964AnaCh..36.1627S).   


Moving average window
---------------------

A simple smoothing of a spectrum can be done using a moving average window. For example, for a given point (wavelength) *i > j* in the spectrum, the value of *i* is replaced by the average value of the points in the window ranging from *i-j* to *i+j*. Therefore, the only parameter that needs to be defined is the half window size (*j*). However, with this method, *j* points at both ends of the spectrum remain unchanged (i.e. are not smoothed). Plus, it is fairly slow. To increase computational speed, we propose below an algorithm that uses matrix operations to perform the smoothing of the entire spectral data frame at once:    


{% highlight r %}
#Create smoothing function:
SmoothFast<-function(Spectra,windowsize){                         
  
  #Create smoothing matrix: 
  Mat<-matrix(0,length((windowsize+1):(ncol(Spectra)-windowsize)),2*windowsize+1)
  for(j in 1:nrow(Mat)){Mat[j,]<-seq(j,j+2*windowsize,1)}
  
  #Smoothing spectra using matrix operations:
  newspectra<-matrix(0,nrow(Spectra),
                     length((windowsize+1):(ncol(Spectra)-windowsize)))
  for(i in 1:nrow(Mat)){newspectra[,i]<-apply(Spectra[,Mat[i,]],1,mean)}
  
  #Add front and end tails (not smoothed):
  fronttail<-newspectra[,1]
  endtail<-newspectra[,ncol(newspectra)]
  for(k in 1:(windowsize-1)){fronttail<-data.frame(fronttail,newspectra[,1])
                              endtail<-data.frame(endtail,newspectra[,ncol(newspectra)])}
  newspectra<-data.frame(fronttail,newspectra,endtail)
  
  return(newspectra)}

#Apply smoothing function:
newspectra<-SmoothFast(mydata$NIR,windowsize=3)
mydataSmooth<-data.frame(mydata[,1:6], NIR = I(newspectra))          
rm(newspectra)

#Plot smoothed spectra:
myBasicPlot(mydataSmooth, wavelengths, xlim, ylim)          
{% endhighlight %}

<img src="images/Smooth-1.svg" title="plot of chunk Smooth" alt="plot of chunk Smooth" style="display: block; margin: auto;" />

Note that as the **PHAZIR spectra** are quite short, with only 100 wavelengths. Therefore, the moving average window size has to be small to avoid removing useful information from the signal.



Savitsky-Golay method
---------------------

The [Savitzky-Golay algorithm](http://adsabs.harvard.edu/abs/1964AnaCh..36.1627S) is based on a moving window that fit a polynomial curve of fixed degree to the spectral data. It is assumed that the fitted values are a better estimate than the measured ones and therefore that some noise is being removed in the process [(De Maesschalck et al., 1999)](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.571.732). Two parameters need to be defined: the polynomial order (p) and the filter length (n). The Savitzky-Golay algorithm is available in the [signal](https://cran.r-project.org/web/packages/signal/index.html) package with the *sgolayfilt* function. Note however that this function is designed to process vectors. Therefore, we are using the function *apply* to process each row of our spectral matrix:


{% highlight r %}
library(signal)

#Apply Savitzky-Golay smoothing to all spectra:
newspectra<-apply(mydata$NIR,1, FUN=sgolayfilt, p = 2, n = 3, m = 0, ts = 1)

#Create new data frame:
mydataSmoothSG<-data.frame(mydata[,1:6], NIR = I(t(newspectra)))  
rm(newspectra)

#Plot spectra:
myBasicPlot(mydataSmoothSG, wavelengths, xlim, ylim)   
{% endhighlight %}

<img src="images/SmoothSG-1.svg" title="plot of chunk SmoothSG" alt="plot of chunk SmoothSG" style="display: block; margin: auto;" />
