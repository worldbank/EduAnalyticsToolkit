**Edukit - Stata commands for learning assessments**
=====
<img align="left" src="https://user-images.githubusercontent.com/43160181/62169131-58ea6a00-b2f5-11e9-977f-18117cc9e42d.png" width="130">

This toolkit was developed by people that work at or with the **EduAnalytics** team at the World Bank Education Global Practice.

While the commands in this toolkit are developed with best practices for analysis of microdata of learning assessments in mind, some commands may be useful outside that field as well. Some commands are very specific to out own work flow, and might not suit other projects, but we want to share as much as possible for anyone to use if applicable.



### **Install and Update**

###### Installing `edukit`
 **edukit** is currently not published on [SSC](https://www.stata.com/support/ssc-installation/), so it cannot be installed through `ssc install`.

If you want to install the most recent carefully curated version of  **edukit** then you can use the code below:

```
net install edukit, from("https://raw.githubusercontent.com/worldbank/eduanalyticstoolkit/master/src") replace
```

The code above installs the version currently in the `master` branch. We merge **edukit** to the `master` branch after we have carefully added new features and documented them in help files.

If you want to install a version of **edukit** not yet merged to the `master` branch then replace _master_ in the URL above with the name of the branch you want to install from. These versions of **edukit** have not yet been equally carefully tested for bugs, and might have features that are not yet documented in the help files, but you are still free to use them.

Similarly, to get the ancillary file in this package (_edukit_save_dyntext.txt_), you can use the code below.
```
net get edukit, from("https://raw.githubusercontent.com/worldbank/eduanalyticstoolkit/master/src") replace
```

###### Updating `edukit`
To update **edukit** simply repeat the installation process that overwrites the files you currently have installed.

#### Installing `edukit` by cloning this repository
An alternative to those who prefer not to use `net install` in Stata, is to install this package by cloning this repo and checking out the branch you choose to install (_master_ will be checked out by default). To update the package if the branch is updated, you would need to _pull_ the branch. The installation of the package through this method can be automated in your do file through the code below.

```stata
* Specify the location of the clone of EduAnalytics toolkit repo
global edukit_clone  "C:/Users/WB111111/Documents/Github/EduAnalyticsToolkit"

* Load eduanalytics toolkit package
cap net uninstall edukit
net install edukit.pkg, from("${edukit_clone}/src") replace
```

This would be the best method to use if you need to adapt these commands to meet the needs specific to your own project.

### **Content**
**edukit** provides a set of commands that address different aspects of data management and data analysis for
learning assessments microdata. The list of commands will be extended continuously, and suggestions for
new commands are greatly appreciated.

 - **edukit** returns meta info on the version of _edukit_ installed.
 Can be used to ensure that the team uses the same version.
 - **edukit_comparefiles** compares two files and list all the differences.
It is similar to _cf_, but better at handling different number of observations,
the data doesn't need to be sorted, and it can create a markdown file of the differences.
 - **edukit_datalibweb** calls _datalibweb_ repeatedly to prevent breaking a loop if connection is temporarily lost or other issues arise while querying many files. _Datalibweb_ is a currently only available for Stata users within the World Bank, so this command is not intended to be used outside the World Bank.
 - **edukit_dlwcheck** validates file and folders structures in EduAnalytics' network folder.
 - **edukit_rmkdir** conveniently creates folders and sub-folders recursively.
 - **edukit_save** is a modified version of the save command to ensure quality of databases.
Before saving, it compress, check _isid_, and has options to store metadata as _char_
plus flexibility to execute special commands for EduAnalytics.
It comes with a companion _dyntext_ example.
- **edukit_save_dyntext** is a txt to be used with _dyntext_ to automatically generate
documentation for a dataset, based on metadata stored by _edukit_save_. Given that it
is an ancillary file in the package, it must be downloaded through _net get_ instead of _net install_.

### **Contact**
The team can be reached at [eduanalytics@worldbank.org](mailto:eduanalytics@worldbank.org).

### **Authors**
Kristoffer Bjärkefur, Diana Goldemberg
