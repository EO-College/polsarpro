# Important Note

This repository is only a mirror of the Linux version of PolSARpro. It does
contain all the files from `PolSARpro_v6.0_Biomass_Edition_Package_Linux.zip`,
which can be found in the zip file [PolSARpro_v6.0_Biomass_Edition_Linux_Installer_20190404.zip](https://www.ietr.fr/polsarpro-bio/Linux/PolSARpro_v6.0_Biomass_Edition_Linux_Installer_20190404.zip).
In other words: PolSARpro minus the files of the PolSARpro installer.

The primary purpose of having these files here is to aid in packaging PolSARpro
for [SARbian](https://github.com/EO-College/sarbian).

--------

The following README has been extracted from
"README_PolSARpro_v6.0_Biomass_Edition_Linux_Installation_Procedure.pdf"
and adjusted for better display.

# POLSARPRO V6.0 (BIOMASS EDITION) - LINUX INSTALLATION PROCEDURE

## INSTALLATION

To install **PolSARpro v6.0 (Biomass Edition) Software**, user has to:

1) Unpack the zip file :  
*PolSARpro_v6.X_BiomassEdition_Linux_Installer_YYYYMMDD.zip*  
into the _**Download**_ Directory.

2) Open an **Xterm** window and type :  
```bash
cd Download/PolSARpro_v6.X_Biomass_Edition_Linux_Installer_YYYYMMDD
wish PolSARpro_v6.X_Biomass_Edition_Linux_Installer.tcl
```
(where v6.X = version and YYYYMMDD = date)

3) Follow the *Automatic Installation procedure for Linux*. User will be ask to
enter the destination directory where **PolSARPro v6.0 (Biomass Edition) Software**
directory will be installed.

## DIRECTORY STRUCTURE
Once installed, the **PolSARpro v6.0 (Biomass Edition) Software** directory
presents the following structure:

- **ColorMap directory** contains user defined or modified POLSARPRO colour-map files
- **Config directory:** contains all the different software configuration files
- **GUI directory** contains all the widget window Tcl-Tk files.
- **Help directory** contains the PolSARpro Help files.
- **License directory** contrains all the PolSARpro licenses files
- **Log directory** will contain all the log files created at each session.
- **Soft directory** contains ready to use executable processing files and libraries.
- **TechDoc directory** contains the technical documentations relative to all the 
  GUI Widgets and C-Routines used in PolSARpro.
- **Tmp directory** is empty after installation and is used by PolSARpro during each session.
- **Tutorial directory** contains PolSARpro Tutorial material in PDF format .

*It is strictly recommended to not change, extract, move or modify any component (tcl-tk
widgets, executable processing files, colormaps, help files, PDF files…) included in the
PolSARpro v6.0 (Biomass Edition) Software directory and / or change its structure.*

## RUNNING POLSARPRO V6.0 (BIOMASS EDITION) SOFTWARE
To run the **PolSARpro v6.0 (Biomass Edition) Software**, start the GUI (Graphical
User Interface) by double clicking the **PolSARpro_v6.X_Biomass_Edition** icon
located on the user desktop, or open an **Xterm** window in the directory where
**PolSARpro v6.0 (Biomass Edition) Software** directory is installed and type :
```bash
wish PolSARpro_v6.X_Biomass_Edition.tcl
```

(where v6.X = version)
