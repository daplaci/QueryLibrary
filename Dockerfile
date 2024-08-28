# Use the official R image from the Rocker project
FROM ohdsi/ohdsi-shiny-modules

RUN R -e "install.packages('duckdb')"
COPY inst/shinyApps/QueryLibrary /srv/shiny-server/QueryLibrary

# Set the working directory
WORKDIR /srv/shiny-server/QueryLibraryW
RUN chmod -R 777 /srv/shiny-server/QueryLibrary/

# Expose the port on which Shiny Server will run
EXPOSE 3838

RUN mkdir /data

# Command to run Shiny Server
ENTRYPOINT []
CMD ["/usr/bin/shiny-server"]