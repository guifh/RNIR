#
#KnitPost is a function that convert Rmd files into ready to publish Jekyll website.
#
#Credits for this function goes to chepec (https://chepec.se/2014/07/16/knitr-jekyll.html)
#and Andrew Brooks (http://brooksandrew.github.io/simpleblog/articles/blogging-with-r-markdown-and-jekyll-using-knitr/)
#
#I simply made a few edit and adjustment to suits the needs of the RNIR blog and
#to handle references with .bib files.
#
#
#how to use KnitPost (by Andrew Brooks):
#---------------------------------------
#Configure the directories at the top of KnitPost to match the file system of your blog. 
#I could have included these as parameters, but I figured I wouldn't re-architect my blog 
#very often. so I left them hard-coded.
#Create an R Markdown post and save it as a .Rmd file in rmd.path. Be sure to include 
#the proper YAML front matter for Jekyll. This tripped me up initially. I forgot to change 
#the date from the knitr style date ("Month, day YYYY") that auto-generates when you 
#create a new .Rmd to a Jekyll style date ('YYYY-MM-DD').
#Run KnitPost to publish your R Markdown file.
#
#Arguments:
#---------
#site.path = Path to the folder of your blog (in our case GitHub/RNIR)
#overwriteAll = if former posts need to be overwrite or not (TRUE or FALSE)
#overwriteOne = string input to overwrite any post that partially matches it (when overwriteAll is FALSE)
#biblio = if a bibliography should be generated (TRUE or FALSE)
#

KnitPost <- function(site.path='/pathToYourBlog/', overwriteAll=F, overwriteOne=NULL, biblio = TRUE) {
  if(!'package:knitr' %in% search()) library('knitr')
  
  require(knitr)
  require(knitcitations)
  
  if(biblio){
  cleanbib()
  cite_options(citation_format = "text", cite.style = "numeric", sorting= "none")}
  
  ## Blog-specific directories.  This will depend on how you organize your blog.
  site.path <- site.path # directory of jekyll blog (including trailing slash)
  rmd.path <- paste0(site.path, "_Rmd") # directory where your Rmd-files reside (relative to base)
  fig.dir <- paste0(site.path, "images/") # directory to save figures
  posts.path <- paste0(site.path, "pages/mydoc/") # directory for converted markdown files
  cache.path <- paste0(site.path, "_cache/") # necessary for plots
  
  render_jekyll(highlight = "pygments")
  opts_knit$set(base.url = '/', base.dir = site.path)
  opts_chunk$set(base.dir = site.path, fig.path="images/", fig.width=8.5, fig.height=5.25, dev='png', cache=F, 
                 warning=F, message=F, cache.path=cache.path, tidy=F)   
  
  
  setwd(rmd.path) # setwd to base
  
  # some logic to help us avoid overwriting already existing md files
  files.rmd <- data.frame(rmd = list.files(path = rmd.path,
                                           full.names = T,
                                           pattern = "\\.Rmd$",
                                           ignore.case = T,
                                           recursive = F), stringsAsFactors=F)
  files.rmd$corresponding.md.file <- paste0(posts.path, basename(gsub(pattern = "\\.Rmd$", replacement = ".md", x = files.rmd$rmd)))
  files.rmd$corresponding.md.exists <- file.exists(files.rmd$corresponding.md.file)
  
  ## determining which posts to overwrite from parameters overwriteOne & overwriteAll
  files.rmd$md.overwriteAll <- overwriteAll
  if(is.null(overwriteOne)==F) files.rmd$md.overwriteAll[grep(overwriteOne, files.rmd[,'rmd'], ignore.case=T)] <- T
  files.rmd$md.render <- F
  for (i in 1:dim(files.rmd)[1]) {
    if (files.rmd$corresponding.md.exists[i] == F) {
      files.rmd$md.render[i] <- T
    }
    if ((files.rmd$corresponding.md.exists[i] == T) && (files.rmd$md.overwriteAll[i] == T)) {
      files.rmd$md.render[i] <- T
    }
  }
  
  # For each Rmd file, render markdown (contingent on the flags set above)
  for (i in 1:dim(files.rmd)[1]) {
    if (files.rmd$md.render[i] == T) {
      out.file <- knit(as.character(files.rmd$rmd[i]), 
                       output = as.character(files.rmd$corresponding.md.file[i]),
                       envir = parent.frame(), 
                       encoding = "UTF-8",
                       quiet = T)
      
      if(biblio){
      bibname<-basename(gsub(pattern = "\\.Rmd$", replacement = ".bib", x = files.rmd$rmd))[i]
      write.bibtex(file=paste0(rmd.path,"/",bibname), append=FALSE)}
         
      message(paste0("KnitPost(): ", basename(files.rmd$rmd[i])))
    }     
  }
  
}