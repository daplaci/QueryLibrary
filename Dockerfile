# Use the official R image from the Rocker project
FROM ghcr.io/daplaci/ohdsi-achilles:main

USER root

RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    gdebi-core

# Download and install Shiny Server
RUN wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.22.1017-amd64.deb \
    && gdebi -n shiny-server-1.5.22.1017-amd64.deb \
    && rm shiny-server-1.5.22.1017-amd64.deb

# Create a Shiny app directory
RUN mkdir -p /srv/shiny-server/

# Copy the Shiny app source code into the container
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

COPY inst/shinyApps/QueryLibrary /srv/shiny-server/QueryLibrary

# Set the working directory
WORKDIR /srv/shiny-server/QueryLibraryW
RUN chmod -R 777 /srv/shiny-server/QueryLibrary/

# Expose the port on which Shiny Server will run
EXPOSE 3838

RUN R -e 'renv::install("DT")'
RUN mkdir /data

# Command to run Shiny Server
ENTRYPOINT []
CMD ["/usr/bin/shiny-server"]