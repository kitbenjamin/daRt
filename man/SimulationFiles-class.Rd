% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AAA_Classes.R, R/AA_Generics.R
\docType{class}
\name{SimulationFiles-class}
\alias{SimulationFiles-class}
\alias{simdir}
\title{SimulationFiles class}
\usage{
simdir(x)
}
\description{
An S4 class to represent the files within a simulation or simulations.
Created using the \code{\link{getFiles}} method. Specific files within the class are modified
by the object with class \link{SimulationFilter-class}
}
\section{Slots}{

\describe{
\item{\code{simulationFilter}}{contains \link{SimulationFilter-class} object}

\item{\code{files}}{a data.frame, with each row describing the file}

\item{\code{sequenceInfoList}}{a list, with each list element showing the variable permutation(s) within this specific simulation sequence.}
}}

\examples{

}
