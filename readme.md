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

### Dockerfile



