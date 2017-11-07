
# Overview

The GUI is a web app which uses [Shiny](http://shiny.rstudio.com) by [Rstudio](https://www.rstudio.com). Shiny is designed for building GUIs, it has good documention in the form of tutorials and articles.

Shiny uses a client-server pattern and a reactive programming model. The appearance and interactive behaviour of the app is all controlled on the client side. On the server side control messages are received, ClimPACT2 processing is done and results sent back. All of the client code is within the 'ui/' directory, while the server code can be found in 'server/' and 'Climpact2.R'.

Looking at the files in the 'ui/' directory you can see that they primarily deal with widget configuration and layout. They intentionally don't contain any lower level functionality.

In server/server.R there are a collection of elemnts or 'reactives'. Shiny is designed to automatically trigger execution of these when values in the UI change. For example as soon as a dataset is uploaded the shiny server is able to 'react' and fill in fields with certain defaults based on that dataset. As well as the reactive model the Climpact app is also 'event driven'. Particular events, such as button presses, are what trigger computation. There is good documentation about how this works here:
  - https://shiny.rstudio.com/articles/reactivity-overview.html
  - https://shiny.rstudio.com/reference/shiny/latest/observeEvent.html

# Serving Climpact2 output files

As noted above the GUI uses a client-server model. Theoretically, the client and server could run on different computers. This means that the app needs a way to serve Climpact2 outputs to the user. For this purpose a file server runs on port 4199 of the server. Once Climpact2 outputs are generated they are placed in a directory and linkes are provided to the user via the GUI so that they can view or download these files.

# Install server on Ubuntu (not necessary when running locally)

Follow instructions here: https://www.rstudio.com/products/shiny/download-server/

Then:

```{bash}
sudo su --c "R -e \"install.packages('rmarkdown', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('shinythemes', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('servr', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('dplyr', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('dplyr', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('corrplot', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('ggplot2', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('Rcpp', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('caTools', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('PCICt', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('SPEI', repos='http://cran.rstudio.com/')\""
sudo su --c "R -e \"install.packages('climdex.pcic', repos='http://cran.rstudio.com/')\""
```

Make sure TCP port 3838 is open/accessible then visit: http://ec2-52-65-87-111.ap-southeast-2.compute.amazonaws.com:3838/

# Update app on server (not necessary when running locally)

```{bash}
cd /srv/shiny-server/
sudo git clone https://github.com/nicjhan/climpact2-app.git
```

Edit /etc/shiny-server/shiny-server.conf to look like below, notice that 'site_dir' is commented out.
```
# Define a location at the base URL
location / {

	app_dir /srv/shiny-server/climpact2-app;

    # Host the directory of Shiny Apps stored in this directory
    # site_dir /srv/shiny-server;
...
```

Restart the server:
```{bash}
sudo systemctl restart shiny-server
```

To see the logs:
```{bash}
cat /var/log/shiny-server.log
```
