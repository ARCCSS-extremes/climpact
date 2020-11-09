# <p align="center">Climpact user guide</p>

## Table of contents
<a name="toc"></a>

1. [Known issues](#issues)
1. [Acknowledgements](#acknowledgements)
1. [Background to the Climpact climate extremes indices](#background)



<a name="issues"></a>

## Known issues
1.
1.
1.
1.
1.
1.
1.


<a name="acknowledgements"></a>
## Acknowledgements
[table of contents](#toc)

This document and the body of work it represents was made possible through the efforts of The World Meteorological Organisation (WMO) Commission for Climatology (CCl) Open Panel of CCl Experts on Climate Information for Adaptation and Risk Management (OPACE 4) under the guidance of OPACE-4 co-chairs (Rodney Martinez and Andrew Tait); the CCl OPACE 4 Expert Team on Sector-specific Climate Indices (ET-SCI) members: Lisa Alexander (Chair, Australia), Toshiyuki Nakaegawa (co-Chair, Japan), Fatima Zohra El Guelai (Morocco), Amelia Diaz Pablo (Peru), Adam Kalkstein (USA) and Gé Verver (The Netherlands) and the WMO World Climate Applications and Services Programme (Rupa Kumar Kolli and Anahit Hovsepyan). It draws heavily on the input of the Expert Team on Climate Risk and Sector-specific Climate Indices (ET-CRSCI), the predecessor of the ET-SCI and including additional ET-CRSCI members Elena Akentyeva, Alexis Nimubona, G. Srinivasan, Philip Thornton, and Peiqun Zhang. Significant contributions to the development of the ET-SCI indices, software and technical manual also came from Nicholas Hannah, Enric Aguilar, Andrew King, James Goldie, Brad Rippey, Sarah Perkins, Sergio M. Vicente-Serrano, Juan Jose Nieto, Sandra Schuster and Hongang Yang. We are also grateful to the other experts and sector representatives who have contributed to the development of indices: Manola Brunet, Albert Klein Tank, Christina Koppe, Sari Kovats, Glenn McGregor, Xuebin Zhang, Javier Sigro, Peter Domonkos, Dimitrios Efthymiadis.

Lisa Alexander, Nicholas Herold and Nicholas Hannah contributed significantly to development of this document, the indices and the Climpact software. The majority of indices in Climpact are calculated using code from the climdex.pcic R package which was developed by the Pacific Climate Impacts Consortium (PCIC). Input was also provided by James Hiebert of PCIC during the development of Climpact.

The application of climate indices to the Agriculture sector was undertaken in full cooperation with the WMO Commission for Agricultural Meteorology, through which Brad Rippey and Sergio Vicente Serrano supported the work.

Commission for Climatology experts Glenn McGregor, Christina Koppe and Sari Kovats supported the applications of indices for Climate and Health, in particular for heat waves and health.

This version of Climpact updates the original Climpact which was based on the RClimDEX software developed by the WMO CCl/WCRP/JCOMM Expert Team on Climate Change Detection and Indices (ETCCDI). The CCl Co Chair for the CCl OPACE on Climate Monitoring and Assessment (Manola Brunet), ETCCDI members, Albert Klein Tank and Xuebin Zhang, along with Enric Aguilar, Juan Jose Nieto, Javier Sigro, Peter Domonkos, and Dimitrios Efthymiadis, contributed to development of the indices and software described in the previous version of the technical manual.

Climpact is written in R, a language and environment for statistical computing and graphics and makes use of numerous R packages. R is available as Free Software under the terms of the Free Software Foundation's GNU General Public License in source code form.

This work is also supported by WMO grant SSA 3876-12/REM/CNS and the Australian Research Council grant CE110001028 specifically through funding from the New South Wales Office of the Environment and Heritage. 



<a name="background"></a>
## Background
[table of contents](#toc)

This document was prepared on behalf of the World Meteorological Organization (WMO) Commission for Climatology (CCl) Expert Team on Sector-specific Climate Indices (ET-SCI). It outlines the background and goals of the ET-SCI and describes the indices and software that were developed on their behalf.

The ET-SCI, formerly known as the Expert Team on Climate Risk and Sector-specific Indices (ET-CRSCI) was set up by the Fifteenth session of the WMO Technical Commission for Climatology (CCl-XV, Antalya, Turkey, February 2010), with terms of reference established to support eventual implementation of the Global Framework for Climate Services (GFCS). Following the sixteenth World Meteorological Congress in May 2011 where a decision was made by WMO members to implement the GFCS, the ET-SCI held their first meeting in Tarragona, Spain (13-15 July, 2011).

 

### 1.1 Role of ET-SCI in GFCS

The ET-SCI sits within CCl under the Open Panel of CCl Experts (OPACE) on Climate Information for Adaptation and Risk Management (OPACE-4). The objective of OPACE-4 is to improve decision-making for planning, operations, risk management and for adaptation to both climate change and variability (covering time scales from seasonal to centennial) and will be achieved through a higher level of climate knowledge, as well as by access to and use of actionable information and products, tailored to meet their needs. OPACE-4 activities primarily focus on the development of tailored climate information, products and services for user application in adaptation and risk management, and building interfaces with user groups to facilitate GFCS implementation.


The work of OPACE-4 is multidisciplinary, and requires close collaboration with experts from various socio-economic sectors. In keeping with the priorities agreed for initial implementation of the GFCS, the core priority sectors for consideration by the OPACE in this present intersessional period are agriculture/food security, water and health. This requires close collaboration with relevant experts in these sectors including seeking guidance and aid from the WMO Technical Commissions for Agricultural Meteorology (CAgM) and Hydrology (CHy) and with the World Health Organisation (WHO).


The ET-SCI Terms of Reference (ToR) and expected deliverables are shown in Appendix H. The deliverables include the collection and analysis of existing sector-relevant climate indices in addition to developing the tools required to produce them. At a meeting in Tarragona in 2011, members of the former ET-CRSCI invited sector and Commission representatives to help define a suite of indices that would represent a “core set” that would meet the ToR and deliverables. This manual outlines the rationale behind the creation of those indices and the Climpact software developed for their calculation.

      

### 1.2 The ‘value’ of climate indices

Monthly averages of climate data smooth over a lot of important information that is relevant for sectoral impacts. For this reason indices derived from daily data are an attempt to objectively extract information from daily weather observations to answer questions concerning aspects of the climate system that affect many human and natural systems with particular emphasis on extremes. Such indices might reflect the duration or amplitude of heat waves, extreme rainfall intensity and frequency or measures of extremely wet or dry/hot or cold periods that have socio-economic impacts. Climate indices provide valuable information contained in daily data, without the need to transmit the daily data itself.


Much progress has been made in recent decades through internationally agreed indices derived from daily temperature and precipitation that represent more extreme aspects of the climate, overseen by the CCl/WCRP/JCOMM Expert Team on Climate Change Detection and Indices (ETCCDI). Development and analyses of these indices has made a significant contribution to the Intergovernmental Panel on Climate Change (IPCC) Assessment Reports.

 

### 1.3 Background to ETCCDI, Indices and Software

The ETCCDI started in 1999 and is co-sponsored by the World Climate Research Program (WCRP) and JCOMM. They developed an internationally coordinated set of core climate indices consisting of 27 descriptive indices for moderate extremes (Alexander et al. 2006; Zhang et al. 2011). These indices were developed with the ‘detection and attribution’ research community in mind. In order to detect changes in climate extremes, it was important to develop a set of indices that were statistically robust, covered a wide range of climates, and had a high signal-to-noise ratio. In addition, internationally agreed indices derived from daily temperature and precipitation allowed results to be compared consistently across different countries and also had the advantage of overcoming most of the restrictions on the dissemination of daily data that apply in many countries.


ETCCDI recognized that a two-pronged approach was needed to promote further work on the monitoring and analysis of daily climate records to identify trends in extreme climate events (Peterson and Manton, 2008). In addition to the formulation of indices described above, a second prong was to promote the analysis of extremes around the world, particularly in less developed countries, by organizing regional climate change workshops that provided training for the local experts and conducted data analysis. The goals of these workshops are to: contribute to worldwide indices database; build capacity to analyse observed changes in extremes; improve information services on extremes in the region; and publish peer-reviewed journal articles. Most of these articles were directly a result of the regional workshops and included all of the workshop participants as authors (e.g. Peterson et al. 2002; Vincent et al. 2005; Zhang et al. 2005; Haylock et al. 2006; Klein Tank et al. 2006; New et al. 2006; Aguilar et al, 2006, Aguilar et al. 2009; Caesar et al. 2011; Vincent et al. 2011).


As part of the workshop development, software called RClimDEX was also developed that could be used at the workshops (thus providing consistent definitions from each workshop and region). Environment Canada provides, maintains, and further develops the R-based software used for the workshops (freely available from http://etccdi.pacificclimate.org/software.shtml).

 

### 1.4 Background to Development of ET-SCI Indices

Most ETCCDI indices focus on counts of days crossing a threshold; either absolute/fixed thresholds or percentile/variable thresholds relative to local climate. Others focus on absolute extreme values such as the warmest, coldest or wettest day of the year. The indices are used for both observations and models, globally as well as regionally, and can be coupled with simple trend analysis techniques, and standard detection and attribution methods in addition to complementing the analysis of more rare extremes using Extreme Value Theory (EVT).


One current disadvantage of the ETCCDI indices is that few of them are specifically sector-relevant. While some of these indices may be useful for sector applications (e.g. number of days with frost for agricultural applications, heat waves for health applications) it was realised that it was important to get sectors involved in the development of the ET-SCI indices so that more application-relevant indices could be developed to better support adaptation.


The core set of indices agreed by the ET-SCI (as the ET-CRSCI) at their meeting in Tarragona, Spain in July 2011 were developed in part from the core set of indices that are developed and maintained by ETCCDI. The meeting included technical experts in climate and health and climate and agriculture from CCl and CAgM and it was agreed that the initial effort should consider requirements for climate indices relevant to heat waves and droughts. A core set of 34 indices was agreed at that meeting. In some cases these indices are already part of the core set defined by the ETCCDI. All indices calculated by Climpact are shown in Appendix A and are separated into core and non-core ET-SCI indices. In addition, there is some scope in the Climpact software for the user to create their own index based on absolute thresholds.


It should be noted that indices development is an ongoing activity as additional sector-needs arise and other sectors are considered within the Terms of Reference and deliverables of the ET-SCI. This softwrae and documentation should therefore be seen only as the initial step in the continuing work of the ET-SCI.

 

### 1.5 Requirements for data quality when computing indices

Before indices can be computed, it is important that any daily input data are checked for quality and homogeneity. Homogeneity implies consistency of a series through time and is an obvious requirement for the robust analysis of climate time series. While many of the time series that are used for indices calculations have been adjusted to improve homogeneity, some aspects of these records may remain inhomogeneous, and this should be borne in mind when interpreting changes in indices. For example, most methods for assessing homogeneity do not consider changes in day-to-day variability or changes in how the series has been derived. It is possible for a change of variance to occur without a change in mean temperature. Two examples of ways in which this could occur are where a station moves from an exposed coastal location to a location further inland, increasing maximum temperatures and decreasing minimum temperatures, or where the number of stations contributing to a composite series changes.


Homogeneity adjustment of daily data is difficult because of high variability in the daily data when compared with monthly or annual data, and also because an inhomogeneity due to a change in station location or instrument may alter behaviour differently under different weather conditions. Homogeneity adjustment of daily data is a very active field of research and there are many methods which could be used. Although many different methods exists, the ETCCDI promote the use of the RHTest software because it is free and easy to use, making it ideal for demonstration in regional workshops. The software method is based on the penalized maximal t (PMT) or F test (PMF) and can identify, and adjust for, multiple change points in a time series (see Wang, 2008 and ETCCDI software website for more details). PMT requires the use of reference stations for the homogeneity analysis but PMF can be used as an absolute method (i.e. in isolation or when there are no neighbouring stations to use for comparison)*. In Climact, apart from basic quality control, there is currently no means to homogenise data. We therefore assume that the required level of homogeneity testing and/or adjustment has already been applied. 


*NB Daily adjustments, especially with absolute methods, must be applied with extreme care as – if incorrectly applied – they can damage the statistical distribution of the series. Therefore, data require careful post-workshop analysis in concert with metadata (where available) and as such ET-SCI recommend that any homogeneity software used at regional workshops is for demonstration purposes only.


 

### 1.6 Future prospects for the Indices

At present the core set of indices are defined using only daily maximum temperature (TX), daily minimum temperature (TN) and daily precipitation (PR). It is acknowledged that for sector applications, these variables (and the related indices) are all required, but users have also indicated a need for additional variables including: humidity (important for both agricultural and health indices); wind speed and direction (important for health indices, building design, energy, transportation, etc.); Sea Surface Temperatures (SSTs; useful for marine applications and in relation to the onset and variability of the El Niño-Southern Oscillation (ENSO)); onset and cessation dates for monsoon; rain periods, snow fall, snow depth, snow-water equivalent, days with snowfall and hydrological parameters (particularly important for mid-and high latitude applications). Some of these (e.g. onset dates) may require considerable study and available systematic long-term data. Furthermore, in a subsequent phase of the work of the Team, addition of ‘event statistics’ such as days with thunderstorms, hail, tornados, number of consecutive days with snowfall, etc., for expanded studies of hazards could be considered. The ET-SCI will consider at a later date whether to add these new variables to the dataset as a second level priority.


The ET-SCI also feels that it is important to add several complex indices to this initial effort (for example heat waves), but recognized that more could be demanded by (or may be in current use by) sectors, once they are consulted on the process and through training. The development of indices to assess multi-day temperature extremes (e.g., prolonged heat waves) has been particularly challenging, as the occurrence of such events depends not just on the frequency distribution of daily temperatures, but also on their persistence from day to day. The existing ETCCDI indices measure the maximum number of consecutive days during events with six or more consecutive days above a specified percentile value or anomaly, vary widely in frequency across climates, describe events that occur rarely or not at all in many climates, and are poor discriminators of very extreme events. The ET-SCI are therefore recommending some new heat wave indices (see Appendix D) that have been added as a supplement to the core set in this initial phase of the software. This range of indices is defined for most climates and has a number of other desirable statistical properties, such as being approximately normally distributed in many climates.


Also drought indices have been included following ET-SCI recommendations. Since drought severity is difficult to quantify and is identified by its effects or impacts on different types of systems (e.g. agriculture, water resources, ecology, forestry, economy), different proxies for drought have been developed based on climatic information. These are assumed to adequately quantify the degree of drought hazard exerted on sensitive systems. Recent studies have reviewed the development of drought indices and compared their advantages and disadvantages (Heim, 2002; Mishra and Singh, 2010; Sivakumar et al., 2010). Currently Climpact includes the Standardized Precipitation Index (SPI), proposed by McKee et al. (1993), and accepted by the WMO as the reference drought index for more effective drought monitoring and climate risk management (World Meteorological Organization, 2012), and the Standardized Precipitation Evapotranspiration Index (SPEI), proposed by Vicente-Serrano et al. (2010), which combines the sensitivity to changes in evaporative demand, caused by temperature fluctuations and trends, with the simplicity of calculation and the multi-temporal nature of the SPI.


In a subsequent phase, ET-SCI will investigate additional complex indices combining meteorological variables (e.g. temperature and humidity for physiological comfort), and could consider indices that combine meteorological/hydrological parameters with sector-based information including measures of vulnerability.


Much of the input for additional indices will come from regional workshops with participants from both National Meteorological and Hydrological Services (NMHSs) and sector groups. The ET-SCI will work with sector-based agencies and experts, including those of relevant WMO Technical Commissions, particularly the Commission for Climatology for health, the Commission for Hydrology (CHy) for water and the Commission for Agricultural Meteorology (CAgM) for agriculture and food security, to facilitate the use of climate information in users’ decision-support systems for climate risk management and adaptation strategies. As part of this development, the ET-SCI commissioned the development of Climpact with the aim of producing an easy and consistent way of calculating indices for each user, with regional workshop users particularly in mind. To date workshops have been held in Ecuador, Fiji, Barbados and India. An example of an ET-SCI workshop can be found here.


It is also acknowledged that updating indices is problematic for many regions and some regions would need specific indices to cope with their particular needs to provide climate services. As GFCS stresses the importance of the global, regional and local scales, the ET-SCI acknowledges that support for this could come from Regional Climate Centers (RCCs) or Regional Climate Outlook Forums (RCOFs) etc. In addition, there are constraints on access to daily data. It is a considerable challenge to assemble worldwide datasets which are integrated, quality controlled, and openly and easily accessible. There is tension between traceability (access to the primary sources) and data completeness (use whatever available). Also a problem arises through the use of specified climatological periods which vary from group to group and which are used for base period calculations for percentile-based indices. In the first iteration of the software we use the base period of 1971-2000 but recognise that this will need to be amended for countries that do not have records covering this period. The software has been written in such a way that the user can specify the climatological base period which is most suitable for their data.


Users are invited to view Climpact as ‘living software’ in that it can and will be amended as additional user needs arise.

## Getting and installing Climpact
[table of contents](#toc)

### 2.1 Software requirements
Climpact is an app that runs through your computer's web browser and is compatible with Windows, Linux and MacOS. While interaction with Climpact takes place through a web browser, it does not require an internet connection once it is installed. To run Climpact, the R software package version 3.3.2 or later needs to be installed on your operating system. The steps to install R on Linux and Mac computers will vary according to your set up, please see the R website for instructions. See below for a video tutorial on installing R in Windows 10.

For Linux users, the PROJ4 development files (libproj-dev package on Ubuntu) and udunits development files (libudunits2-dev package on Ubuntu) are required before installing Climpact. Use the package manager in your Linux distribution to install these files.

[![](http://img.youtube.com/vi/a-vnLME6hRQ/0.jpg)](http://www.youtube.com/watch?v=a-vnLME6hRQ "")


