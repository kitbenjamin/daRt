
<!-- README.md is generated from README.Rmd. Please edit that file -->

# daRt

<!-- badges: start -->

<!-- badges: end -->

The daRt package provides a very quick and flexible way to import data
that is produced by the Discrete Anisotropic Radiative Transfer (DART)
model. The data in daRt are formatted in a way that facilitates rapid
data analysis.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("willmorrison1/daRt")
```

## Example

Load the package

``` r
library(daRt)
```

Create and modify the “SimulationFilter” object. This defines what data
you want to extract from a DART output directory structure

``` r
#define SimulationFilter object - define "directions" as the product
sF <- simulationFilter(product = "directions")

#show the SimulationFilter
sF
#> 'SimulationFilter' object for DART product: directions 
#> 
#> bands:          BAND0 
#> variables:      BRF 
#> iterations:     ITER1, ITERX 
#> variablesRB3D:  Intercepted, Scattered, Emitted, Absorbed, +ZFaceExit, +ZFaceEntry 
#> typeNums:        
#> imageType:      ima, camera 
#> imageNo:

#list the 'setters' and 'accessors'
methods(class = "SimulationFilter")
#>  [1] bands           bands<-         getData         getFiles       
#>  [5] imageFiles      imageNo         imageNo<-       imageType      
#>  [9] imageType<-     iters           iters<-         product        
#> [13] product<-       show            simdir          typeNums       
#> [17] typeNums<-      variables       variables<-     variablesRB3D  
#> [21] variablesRB3D<-
#> see '?methods' for accessing help and source code

#e.g. change the 'bands', then the 'iterations'
bands(sF) <- c("BAND0", "BAND1")
iters(sF) <- "ITER1"
```

Now explore the DART output directory structure. First define the
simulation directory. For this example, ‘simulationDir’ is a relative
directory and is one simulation.

``` r
simulationDir <- "man/data/cesbio"
```

If you install the package using devtools::install\_github then these
DART files will not be available automatically. To use these files, get
them from github manually or use your own ‘cesbio’ simulation (is
shipped with the DART model).

The directory should be the base directory of the simulation. E.g.
within ‘simulationDir there should be the simulation ’input’ and
‘output’ directories.

``` r
list.files(simulationDir)
#> [1] "input"  "output"
```

Now we have the simulation diretory clarified, we continue by defining a
simulationFilter and then explore the files

``` r
#define the SimulationFiler as shown above (i.e. 'sF'), but in one line
sF1 <- simulationFilter(product = "directions", 
                       bands = c("BAND0", "BAND1"), 
                       iters = "ITER1")

#get simulation files based on this newly defined filter
simFiles <- daRt::getFiles(x = simulationDir, sF = sF1)
#> Warning: package 'xml2' was built under R version 3.6.1
#> Warning: package 'stringr' was built under R version 3.6.1

#show these files are we happy to continue and load the data, or
#do we want to adjust the SimulationFilter? daRt::getFiles is essentially
#a 'dry-run' of the data extraction
files(simFiles)
#> [1] "man/data/cesbio/output//BAND0/BRF/ITER1/brf"
#> [2] "man/data/cesbio/output//BAND1/BRF/ITER1/brf"
```

Now extract DART output data

``` r
#get simulation data
simData <- daRt::getData(x = simulationDir, sF = sF1)
#> Warning: package 'data.table' was built under R version 3.6.1
```

Documentation needs updating and finishing from here

``` r
#plot using ggplot2
library(ggplot2)
#> Warning: package 'ggplot2' was built under R version 3.6.1
plotOut <- ggplot(simData@data) +
    geom_point(aes(x = zenith, y = value, colour = azimuth)) +
    facet_wrap(~ band) +
    theme(aspect.ratio = 1)
plot(plotOut)
```

<img src="man/figures/README-plot data example-1.png" width="100%" />
Then alter the SimulationFilter to look at images

``` r
product(sF) <- "images"
simData <- daRt::getData(x = simulationDir, sF = sF)
#> Warning: package 'reshape2' was built under R version 3.6.1
ggplot(simData@data) + 
    geom_raster(aes(x = x, y = y, fill = value)) +
    facet_grid(band ~ imageNo) +
    theme(aspect.ratio = 1)
```

<img src="man/figures/README-images example-1.png" width="100%" /> Alter
the SimulationFilter again to look at radiative budget files. This will
not work if you are using the default cesbio simulation shipped from
DART.

``` r
product(sF) <- "rb3D"
simData <- daRt::getData(x = simulationDir, sF = sF)
#> Warning in filesFun(x = x[i], sF = sF): Forcing 'RADIATIVE_BUDGET' variable
#> in 'simulationFilter' variables.
ggplot(simData@data) + 
    geom_raster(aes(x = X, y = Y, fill = value)) +
    facet_grid(band + variablesRB3D~ Z) +
    theme(aspect.ratio = 1)
```

<img src="man/figures/README-RB3D example-1.png" width="100%" /> That’s
a lot of data\! It is important to set the “SimulationFilter” to match
what data you want so that this doesn’t happen. Also, the process can
use a lot of memory when many large files are loaded so try to only load
in the files you need in the first place. The below example uses the
simple “dplyr” approach to work with the data. Here we look at the
lowest horizontal layer of each 3D radiative budget array (i.e. Z = 1)
rather than all layers (above plot) and plot the smaller dataset. This
also won’t work if using the cesbio simulation shipped from DART.

``` r
library(dplyr)
simData_filtered <- simData@data %>%
    dplyr::filter(Z == 1)
#plot again and tweak the plot
ggplot(simData_filtered) + 
    geom_raster(aes(x = X, y = Y, fill = value)) +
    facet_grid(band ~ variablesRB3D) +
    theme(aspect.ratio = 1) +
    theme_bw() +
    theme(panel.spacing = unit(0, "cm"), 
          strip.text = element_text(size = 6, 
                                    margin = margin(0.05, 0.05, 0.05, 0.05, unit = "cm"))) +
    scale_fill_distiller(palette = "Spectral")
```

<img src="man/figures/README-RB3D filter-1.png" width="100%" />
