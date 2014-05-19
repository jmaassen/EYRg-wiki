Howto install CESM 1.04
-----------------------

In our EYRg experiments we will use CESM version 1.04. Although this is not the latest version, we also use 
it in other projects, and therefore we have configuration files and results available. 

We will now give a very short description of how to install CESM on Cartesius or Stampede. For a more detailed 
description on installing CESM have a look at the official documentation:

<http://www.cesm.ucar.edu/models/cesm1.0/cesm/tags/index.html#CESM1_0_4>

Note that this page describes how to perform a standard installation, __without__ support for wide area communication.
More information about installing CESM __with__ support for wide area communication can be found [here](http://)


Retrieve CESM from SVN:
---

First retrieve CESM from SVN at ucar: 

     svn co --username <user> --password <password> https://svn-ccsm-release.cgd.ucar.edu/model_versions/cesm1_0_4 cesm_1_0_4 

To get access to SVN you will need a username and password for which you need to register here:

<http://www.cesm.ucar.edu/models/register/register_cesm.cgi>



