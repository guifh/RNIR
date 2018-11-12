---
title: "Piecewise Direct Standardization (PDS)"
output: md_document
sidebar: mydoc_sidebar
permalink: PDS.html
folder: mydoc
toc: true
---



<br>

Piecewise Direct Standardization (PDS) is a method that was proposed by [Wang et al. (1991)](https://pubs.acs.org/doi/abs/10.1021/ac00023a016) to transfer NIR spectra from one instrument to another. As explained by [Bouveresse & Massart (1996)](https://www.sciencedirect.com/science/article/pii/0169743995000747), several methods and algorithms were subsequently proposed in the literature to improve the transfer procedure. However, this post is limited to the presentation of the original PDS method.


Master and slave data
---------------------

In this example, we will look at transferring the spectra collected with the ASD LabSpec 4 spectrometer (slave instrument) to the PHAZIR handheld spectrometer (master instrument). Refer to the  [Phazir & ASD](PhazirASD.html) section for details. Let's load these data (available from the [RNIR GitHib repository](https://github.com/guillaumehans/RNIR)) and extract their corresponding wavelengths:


{% highlight r %}
load("mydataPHAZIR.RData")
Master<-mydata
rm(mydata)
load("mydataASD.RData")
Slave<-mydata
rm(mydata)

wavelengthsMaster<-as.numeric(substring(colnames(Master$NIR),2,7))
wavelengthsSlave<-as.numeric(colnames(Slave$NIR))
{% endhighlight %}

{% include note.html content="As already pointed out in the [Phazir & ASD](PhazirASD.html) section, the **ASD spectra** were acquired over a wider wavelength range and at a higher resolution than the **PHAZIR spectra**. This actually constitutes an advantage for performing PDS as more sampling points are available in the slave data to predict the master data during the PLS regression step. However, to keep this example simple and generic, we will resample the ASD spectra so they match the PHAZIR spectral resolution and range." %}


Resampling
----------

There are many ways to resample spectral data and a future section of RNIR will be dedicated to this topic. In the meantime, the resampling of the slave data is performed here using a simple linear interpolation with R's *approx* function: 


{% highlight r %}
#Resampling of each row of the Slave spectral matrix: 
SlaveSpectra<-data.frame()
for(i in 1:nrow(Slave)){
  #Linear interpolation:
  temp<-approx(wavelengthsSlave, Slave$NIR[i,], 
               xout = wavelengthsMaster, method = "linear")
  SlaveSpectra<-rbind(SlaveSpectra, temp$y)
  rm(temp)
}
colnames(SlaveSpectra)<-colnames(Master$NIR)
Slave$NIR<-SlaveSpectra
rm(SlaveSpectra)
{% endhighlight %}


Now, let's take a look at the master and slave spectra after performing [SNV](SNV.html) to correct for scattering effects. 




{% highlight r %}
#SNV scatter correction:
Slave$NIR<-SNV(Slave$NIR)
Master$NIR<-SNV(Master$NIR)

library(Hmisc)

#Plot the master and slave spectra:
par(font=2,las=1,mar = c(5,5,4,2) + 0.1)
matplot(wavelengthsMaster,t(Master$NIR),font.axis=2,main="",          
        col="blue",lty=1, xlab="",ylab="",type="l",lwd=3, ylim=c(-1.5,2))
par(new=TRUE)
matplot(wavelengthsMaster,t(Slave$NIR),font.axis=2,main="",          
        col="forestgreen",lty=1, xlab="",ylab="",type="l",lwd=3, ylim=c(-1.5,2))
minor.tick(nx=2, ny=2,tick.ratio=0.75)
par(mar = c(5,4,4,2) + 0.1)
title( xlab="Wavelength (nm)",ylab="Absorbance (Log(1/R))",cex.lab=1,font.lab=2)
legend("topleft",bty="n", legend=c("Master data","Slave data"),
       col=c("blue","forestgreen"),lty=c(1),cex=1,lwd=3)
{% endhighlight %}

<img src="/images/beforePDS-1.svg" title="plot of chunk beforePDS" alt="plot of chunk beforePDS" style="display: block; margin: auto;" />

We see that the master and slave spectra are very similar, which is a good news and will contribute to facilitate the transfer between the two instruments.


The PDS algorithm
-----------------

The PDS method relates the spectral intensities obtained at the wavelength *i* on the master instrument to the wavelengths contained in a moving window (from *i-k* to *i+k*) on the slave instrument. For each wavelength of the master instrument, a Partial Least Squares (PLS) regression model is then built between the spectral intensity of the master and slave instruments. The regression coefficients of the PLS model (with length 2*k*+1) form the *i*<sup>th</sup> column (between rows *i-k* and *i+k*) of a banded diagonal transfer matrix **_P_**. See [Bouveresse & Massart (1996)](https://www.sciencedirect.com/science/article/pii/0169743995000747) or [Wulfert et al. (2000)](https://pubs.acs.org/doi/abs/10.1021/ac9906835) for schematic representations of this process. In R, the PDS algorithm that computes the transfer matrix **_P_** can be written as follows:



{% highlight r %}
#Piecewise Direct Standardization (PDS) algorithm:

#INPUT:   masterSpectra = Spectra acquired with the master instrument (matrix).
#         slaveSpectra = Spectra acquired with the slave instrument (matrix).
#         MWsize = Half size of the moving window (integer).
#         Ncomp = Number of latent variables used in the PLS model (integer).
#         wavelength = wavelength (numeric vector).

#OUTPUT:  P = the PDS transfer matrix.

PDS<-function(masterSpectra, slaveSpectra, MWsize, Ncomp, wavelength){
  
require(pls)

#Loop Initialization:
i<-MWsize
k<-i-1
#Creation of an empty P matrix:
P<-matrix(0,nrow=ncol(masterSpectra),ncol=ncol(masterSpectra)-(2*i)+2)
InterceptReg<-c()

while(i<=(ncol(masterSpectra)-k)){
  
  #PLS regression:
  fit<- plsr(masterSpectra[,i] ~ as.matrix(slaveSpectra[,(i-k):(i+k)]),
             ncomp=Ncomp, scale=F, method="oscorespls")
  
  #Extraction of the regression coefficients:
  coefReg<-as.numeric(coef(fit, ncomp=Ncomp, intercept = TRUE))
  InterceptReg<-c(InterceptReg,coefReg[1])
  coefReg<-coefReg[2:length(coefReg)]
  
  #Add coefficients to the transfer matrix:
  P[(i-k):(i+k),i-k]<-t(coefReg)
  
  rm(coefReg,fit)
  i<-i+1
  
  #Diplay progression:
  cat("\r",paste(round(i/ncol(masterSpectra)*100)," %",sep=""))}

P<-data.frame(matrix(0,nrow=ncol(masterSpectra),ncol=k), P,
              matrix(0,nrow=ncol(masterSpectra),ncol=k))
InterceptReg<-c(rep(0,k),InterceptReg,rep(0,k)) 

Output<-list(P = P , Intercept = InterceptReg)

return(Output)}
{% endhighlight %}


Applying PDS
------------

Let's now use our PDS function to compute the **_P_** matrix that will help us transferring spectra from the slave to the master instrument. We will be using a half moving window size (*MWsize*) of 2, meaning that 3 points will be selected in total (since the full window size is actually equal to 2[*MWsize*-1]+1), and 2 latent variables in the PLS regression.


{% highlight r %}
Ncomp<-2
MWsize<-2 
wavelength<-wavelengthsMaster

#Compute the transfer matrix P:
Pmat<-PDS(Master$NIR, Slave$NIR, MWsize, Ncomp, wavelength)
{% endhighlight %}

Once we have computed the transfer matrix, performing the standardization is straightforward. Note however that, in addition to the transfer matrix **_P_**, the PDS algorithm presented above also computed an intercept term. This is because the data were not mean-centered. If you mean-center the data beforehand, the intercept term will be null. Therefore, in our case, to compute the standardized slave data, we multiply the spectral matrix by **_P_** and add the intercept:



{% highlight r %}
#Standardization of the slave data (using P and the intercept):
SlaveCor<-as.matrix(Slave$NIR)%*%as.matrix(Pmat$P)
SlaveCor<-sweep(SlaveCor, 2, as.numeric(t(Pmat$Intercept)), "+")
SlaveCor<-data.frame(Slave[,1:6], NIR = I(SlaveCor))


#Plot the master and slave spectra:
par(font=2,las=1,mar = c(5,5,4,2) + 0.1)
matplot(wavelengthsMaster,t(Master$NIR),font.axis=2,main="",          
        col="blue",lty=1, xlab="",ylab="",type="l",lwd=3, ylim=c(-1.5,2))
par(new=TRUE)
matplot(wavelengthsMaster,t(Slave$NIR),font.axis=2,main="",          
        col="forestgreen",lty=1, xlab="",ylab="",type="l",lwd=3, ylim=c(-1.5,2))
par(new=TRUE)
matplot(wavelengthsMaster,t(SlaveCor$NIR),font.axis=2,main="",          
        col="red",lty=1, xlab="",ylab="",type="l",lwd=3, ylim=c(-1.5,2))
minor.tick(nx=2, ny=2,tick.ratio=0.75)
par(mar = c(5,4,4,2) + 0.1)
title( xlab="Wavelength (nm)",ylab="Absorbance (Log(1/R))",cex.lab=1,font.lab=2)
legend("topleft",bty="n", legend=c("Master data","Slave data", "Stand. slave data"),
       col=c("blue","forestgreen","red"),lty=c(1),cex=1,lwd=3)
{% endhighlight %}

<img src="/images/PDSafter-1.svg" title="plot of chunk PDSafter" alt="plot of chunk PDSafter" style="display: block; margin: auto;" />


It can be seen that the new standardized spectra match the ones of the master instrument. However, because of the nature of the PDS algorithm that uses a moving window, both ends of the standardized spectra need to be truncated. To improve the visibility, we can also remove the old slave data from our plot:



{% highlight r %}
#Truncation of both ends of teh spectra:

Master$NIR<-Master$NIR[,3:98]
SlaveCor$NIR<-SlaveCor$NIR[,3:98]

#Plot the master and slave spectra:
par(font=2,las=1,mar = c(5,5,4,2) + 0.1)
matplot(wavelengthsMaster[3:98],t(Master$NIR),font.axis=2,main="",          
        col="blue",lty=1, xlab="",ylab="",type="l",lwd=3, ylim=c(-1.5,2))
minor.tick(nx=2, ny=2,tick.ratio=0.75)
par(new=TRUE)
matplot(wavelengthsMaster[3:98],t(SlaveCor$NIR),font.axis=2,main="",          
        col="red",lty=1, xlab="",ylab="",type="l",lwd=3, ylim=c(-1.5,2))
par(mar = c(5,4,4,2) + 0.1)
title( xlab="Wavelength (nm)",ylab="Absorbance (Log(1/R))",cex.lab=1,font.lab=2)
legend("topleft",bty="n", legend=c("Master data", "Stand. slave data"),
       col=c("blue","red"),lty=c(1),cex=1,lwd=3)
{% endhighlight %}

<img src="/images/PDScompar-1.svg" title="plot of chunk PDScompar" alt="plot of chunk PDScompar" style="display: block; margin: auto;" />


Finally, after PDS, it is often necessary to smooth the spectra due to the apparition of artifacts in the signal. This can be done as presented in the [Smoothing](Smoothing.html) section.




