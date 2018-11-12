---
title: "Loading CSV files"
output: md_document
sidebar: mydoc_sidebar
permalink: CSVfiles.html
folder: mydoc
toc: false
---

<br>

Loading a CSV file (e.g. comma or tab. separated) into R is straightforward. We can load the [**reference data**](https://github.com/guillaumehans/RNIR) and the [**PHAZIR data**](https://github.com/guillaumehans/RNIR) as follows:




{% highlight r %}
setwd("../_Rdata")    #Replace this by the directory where you stored the files
refData<-read.csv("refData.csv", sep=",", dec=".", header=TRUE)    #Load CSV file containing reference data
spectra<-read.csv("PHAZIRspectra.csv",sep=",",dec=".",header=TRUE)  #Load CSV file containing PHAZIR spectra
{% endhighlight %}

<br>

The **reference data** are composed of 7 columns containing the parameters measured in the laboratory for each sample:

* Step = Sample drying step number
* SpeciesID = wood (tree) species identification (**A** for Aspen and **P** for Poplar)
* sampleID (self explanatory)
* MC = Moisture content of each sample
* ASDref = Reference number for spectra acquired with the ASD
* PHAZIRref = Reference number for spectra acquired with the PHAZIR


{% highlight r %}
head(refData)
{% endhighlight %}



{% highlight text %}
##   Step SpeciesID SampleID ASDref PHAZIRref   MC
## 1    1         A       55    392         1 79.0
## 2    1         A       53    212         2 44.9
## 3    1         A        2    206         3 65.5
## 4    1         A       37    542         4 55.2
## 5    1         A       84    512         5 74.8
## 6    1         A       21    410         6 43.6
{% endhighlight %}

<br>

The first column of the **PHAZIR data** frame contains the reference numbers of the spectra acquired with the PHAZIR. The rest of the data frame is the spectral matrix. Each row represents a spectrum and each column represents a wavelength (from 939.5 nm to 1796.6 nm by increment of ~ 9 nm). The values represent the absorbance (measured as log(1/R)) of the NIR "light" at each wavelength.


{% highlight r %}
spectra[1:5,1:5]
{% endhighlight %}



{% highlight text %}
##   PHAZIRref    X939.5    X948.6    X957.7    X966.9
## 1         1 0.2319877 0.2435677 0.2610752 0.2734112
## 2         2 0.2026727 0.2104515 0.2232337 0.2318915
## 3         3 0.1863593 0.1965210 0.2110100 0.2222735
## 4         4 0.2181995 0.2296227 0.2465842 0.2590197
## 5         5 0.2778210 0.2916717 0.3109255 0.3257660
{% endhighlight %}

<br>

The **reference data** can be matched with the PHAZIR spectra based on spectra reference numbers (column "PHAZIRref" common to the two data sets). One way to do this:


{% highlight r %}
#Sort the reference data by increasing order of reference number:
refData<-refData[with(refData, order(PHAZIRref)),] 

#Verify that the reference number of refData and spectra are identical:
all(refData$PHAZIRref == spectra$PHAZIRref)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}



{% highlight r %}
#Combine the two in a new data frame:
mydata<-data.frame(refData, NIR = I(spectra[2:ncol(spectra)]))

#Save the data in a Rdata file:
save(mydata, file = "mydataPHAZIR.Rdata")
{% endhighlight %}

<br>

The new data frame is saved under the name [mydataPHAZIR.Rdata](https://github.com/guillaumehans/RNIR).



