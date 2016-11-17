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

### Dockerfile


### Configuration file
Running ShinyProxy

ShinyProxy can be run using the following command

java -jar shinyproxy-0.7.0.jar  
less than 10 seconds later, you can point your browser to http://localhost:8080 and use your Shiny apps!

More advanced

