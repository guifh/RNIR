---
title: "Connection to an SQL database"
output: md_document
sidebar: mydoc_sidebar
permalink: SQLdatabase.html
folder: mydoc
---

<br>

If your data are stored in a database, it is possible to directly access the database through R. This can be done using Open Database Connectivity (ODBC) through the package [RODBC](https://cran.r-project.org/web/packages/RODBC/index.html). Note that before using ODBC, you should make sure it is correctly set up on your computer (under Control Panel/Administrative Tools in Windows). Then, you'll need to install the RODBC package in R:


{% highlight r %}
install.packages("RODBC")
library(RODBC) 
{% endhighlight %}

Finally, you will be able to connect to your database, run SQL queries to download the data in R as data frames, and close the connection as follows:


{% highlight r %}
channel <- odbcConnect("YOUR DATABASE NAME")
mydata <- sqlQuery(channel, "YOUR SQL QUERY")
odbcClose(channel)
{% endhighlight %}

<br>

