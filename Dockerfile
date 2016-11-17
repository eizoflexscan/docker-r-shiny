FROM bigboards/java-8-x86_64

MAINTAINER BigBoards <hello@bigboards.io>

# install dependencies
RUN apt-get update && \
	apt-get install -y gdebi-core libapparmor1 wget libcurl4-openssl-dev 

# install latest R Base 
RUN codename=$(lsb_release -c -s) && \
	echo "deb http://freestatistics.org/cran/bin/linux/ubuntu $codename/" | tee -a /etc/apt/sources.list > /dev/null && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
	apt-get update && apt-get install -y r-base r-base-dev

# install R libraries
RUN R -e 'install.packages(c('devtools','shiny',  'rmarkdown', 'SparkR'), repos="http://cran.freestatistics.org/", dependencies=NA,clean=TRUE)'  && \
	R -e 'library("devtools"); install_github("mbojan/alluvial")' && \
	R -e 'update.packages(ask=FALSE,repos="http://cran.freestatistics.org/")'
		
## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen en_US.utf8 && \
	/usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# install shiny proxy with demo shiny application
# from https://github.com/openanalytics/shinyproxy-demo/blob/master/Dockerfile 
COPY shinyproxy_0.0.1.tar.gz /root/
RUN R CMD INSTALL /root/shinyproxy_0.0.1.tar.gz
RUN rm /root/shinyproxy_0.0.1.tar.gz

# Remove the package list to reduce image size. Note: do this as the last thing of the build process as installs can fail due to this!
# Additional cleanup
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set host and port
COPY Rprofile.site /usr/lib/R/etc/

# Expose the Shiny proxy port
EXPOSE 3838

# Start Shiny Server 
CMD ["R", "-e shinyproxy::run_01_hello()"]
