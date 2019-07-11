**Edukit - Stata Commands for Education Data Analytics**
=====
Logo. Blurb about EduAnalytics.

### **Install and Update**

#### Installing published versions of `edukit`
One day **edukit** may make it to ssc but for now, it is not, so this option does not exist.

#### Installing unpublished branches of this repository
Follow the instructions above if you want the most recent published version of **edukit**.
If you want a yet to be published version of **edukit** then you can use the code below.
The code below installs the version currently in the `master` branch, but replace _master_ in the URL below
with the name of the branch you want to install from. You can also install older version of **edukit**
like this.

```
    net install edukit , from("https://raw.githubusercontent.com/worldbank/eduanalyticstoolkit/master/src") replace
```

### **Content**
**edukit** provides a set of commands that address different aspects of data management and data analysis in relation
to International/National Learning Assessments (ILA/NLA). The list of commands will be extended continuously, and suggestions for
new commands are greatly appreciated.

 - **edukit** returns meta info on the version of _eduanalyticstoolkit_ installed.
 Can be used to ensure that the team uses the same version.
 - **edukit_save** is a modified version of the save command to ensure quality of microdata databases.
 It compress, check _isid_, adds metadata as _char_ and, of course, save.
 
 
