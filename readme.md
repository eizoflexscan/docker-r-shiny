# Docker R Shiny open source edition enriched with LDAP authentication and authorization
===========================================================================================

## Overview 

This repository contains the necessary files for setting up a  [R Shiny](http://shiny.rstudio.com/) containerized application up and running on a [Bigboard](www.bigboards.io) with LDAP authentication and authorization. 

Shiny is a web application framework for R to turn your analyses into interactive web applications. Since the open source edition of Shiny Server does not offer security and authentification (only the Pro version does), [ShinyProxy](http://www.shinyproxy.io/) is used on top of the shiny library. This free open-source library, developed by [Open Analytics](https://www.openanalytics.eu/) allows to deploy Shiny apps in an enterprise context. It has built-in functionality for LDAP authentication and authorization, makes securing Shiny traffic (over TLS) a breeze and has no limits on concurrent usage of a Shiny app. All information can be found [here](http://www.shinyproxy.io/). You might also want to contact the package owner [Open Analytics](https://www.openanalytics.eu/). From waht I've heard, they offer great support and services.

This has proven useful 
* if you want to seamlessly deploy Shiny apps that were developed locally using the Shiny R package,
* if you need enterprise features but want to stay with open source,
* if you trust Java on the server side for running your Shiny apps,
* if you want to get all benefits offered by Docker-based technology.


Note that this image can be combined with Hadoop, Spark and Rstudio to get a full R Stack (see [R on Spark on Yarn](http://hive.bigboards.io/#/library/stack/google-oauth2-113490423275171641798/cm-r-stack) for details).  


## Files Description 
ShinyProxy uses one or more Docker images to serve the Shiny apps to end users. If you want to deploy your Shiny apps, you will therefore need to build your own Docker image for the app.

Such a Docker image will typically contain:
* an R installation,
* all R packages the Shiny app depends on ('dependencies'),
* a folder which contains the shiny app files  (ui.R, server.R and others).

We hereby go through all the files. 

### Dockerfile

### Dockerfile

#### Step 1 : Load pre-existing image
Tells Docker which image your image is based on with the "FROM" keyword. In our case, we'll use the Bigboards base image bigboards/java-8-x86_64 as the foundation to build our app. 

```sh
FROM bigboards/java-8-x86_64
```


#### Step 2 : Set environment variables
The ENV command is used to set the environment variables. These variables consist of “key = value” pairs which can be accessed within the container by scripts and applications alike. If you want don't need to control the R version for your application or if you always want to work with the lastest version, you should remove these lines. 

```sh
## General ENV
ENV R_BASE_VERSION 3.3.1
ENV RSTUDIO_SERVER_VERSION 0.99.1251
```

#### Step 3 : Install dependencies
Install dependencies external to R and Rstudio,
```sh
RUN set -e \
  && apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install \
  	gdebi-core \ 
    libapparmor1 \
    wget \
    libcurl4-openssl-dev 
```

#### Step 4: Download and Install R Base
A full description of R installation processes can be found at the following [link](https://cran.rstudio.com/bin/linux/ubuntu/README.html). 

```sh   
RUN set -e \
&& codename=$(lsb_release -c -s) \	
&& echo "deb http://freestatistics.org/cran/bin/linux/ubuntu $codename/" | tee -a /etc/apt/sources.list > /dev/null \
&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
&& apt-get -y update \
&& apt-get install -y r-base r-base-dev
```
*  Obtain the latest R packages (line 1-2). Add an entry with URL of your favorite CRAN mirror (See https://cran.r-project.org/mirrors.html for the list of CRAN mirrors) 
*  Use crypto to validate downloaded packages (line 3). The Ubuntu archives on CRAN are signed with the key of “Michael Rutter marutter@gmail.com” with key ID E084DAB9. 
*  Install the complete R system (line 4-6), including r-base-dev package to allow users to instal additional packages with "install.packages()".


Note that if you do not want to install the lastest version of R, you should remove the first line and replace the second line with `&& echo 'deb https://cloud.r-project.org/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list`
and choose your Ubuntu operating system (Xenial 16.04, Trusty 14.04 or Precise 12.04). 



#### Step 5: Download and install R Packages 

Install as many R packages as you want by completing the list. But if you want to install Shiny Server later on, you must add `shiny` to the list before installing Shiny Server.

```sh
RUN R -e 'install.packages(c('devtools','shiny',  'rmarkdown', 'SparkR'), repos="http://cran.freestatistics.org/")' \
	&& R -e 'library("devtools"); install_github("mbojan/alluvial")' \
    && R -e 'update.packages(ask=FALSE,repos="http://cran.freestatistics.org/")'
```

* Install R packages from a list available on CRAN (line 1),
* Install R packages from a list available on Github (line 2),
* Avoid to ask if packages required to be updated (line 3).


#### Step 6: Configure default locale
It might be interesting to avoid confusion to configure default local, see [comments](https://github.com/rocker-org/rocker/issues/19).

```sh
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen en_US.utf8 && \
	/usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
```

#### Step 7: Install shiny proxy with demo shiny application
from https://github.com/openanalytics/shinyproxy-demo/blob/master/Dockerfile 

```sh
COPY shinyproxy_0.0.1.tar.gz /root/
RUN R CMD INSTALL /root/shinyproxy_0.0.1.tar.gz
RUN rm /root/shinyproxy_0.0.1.tar.gz
```

* Copy the folder including ShinyProxy library (line 1),
* Install ShinyProxy library (line 2),
* Remove the folder containing the library (line 3).


#### Step 8: Reduce image size  
Remove the R package list to reduce image size. This is done as the last thing of the build process, instead within step 4,  as installs can fail due to this!

```
RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
```

#### Step 9: Set host and port
```sh
COPY Rprofile.site /usr/lib/R/etc/
```

#### Step 10:Expose the Shiny proxy port
Associate the 3838 specified port to enable networking between the running process inside the container and the outside world (i.e. the host).
```
EXPOSE 3838
```

####  Step 11: Start Shiny app
The command CMD, similarly to RUN, can be used for executing a specific command. However, unlike RUN it is not executed during build, but when a container is instantiated using the image being built. Therefore, it should be considered as an initial, default command that gets executed (i.e. run) with the creation of containers based on the image to start the Shiny app.
```sh
CMD ["R", "-e shinyproxy::run_01_hello()"]
```


### Configuration file

#### Rprofile.site
Set Host and Port + to be completed...
```
local({
   old <- getOption("defaultPackages")
   options(defaultPackages = c(old, "shinyproxy"), shiny.port = 3838, shiny.host = "0.0.0.0")
})
```


Running ShinyProxy

ShinyProxy can be run using the following command

java -jar shinyproxy-0.7.0.jar  
less than 10 seconds later, you can point your browser to http://localhost:8080 and use your Shiny apps!

More advanced

