# Important Note

This repository is only a mirror of the Linux version of PolSARpro. Its primary
purpose is to aid in packaging PolSARpro for [SARbian](https://github.com/EO-College/sarbian).

The following README has been extracted from "README_PolSARpro_v5.0_Install_Linux.pdf"
and adjusted for better display:

# POLSARPRO V5.0 INSTALLATION PROCEDURE - LINUX VERSION
## INSTALLATION
PolSARpro requires the installation of the software package **ActiveTcl Package**
(if not already installed on the machine). Tcl (Tool Command Language) is used by over half a
million developers worldwide. Tk is a graphical user interface toolkit that now ships with all
distributions of Tcl. Together they enable the creation and execution of powerful GUIs. Tcl
and Tk were created and developed by John Ousterhout. We recommend installing ActiveTcl,
ActiveState's quality-assured distribution of Tcl, available free to the community for Linux,
Solaris and Windows. The package is easy to install and use on all major platforms and
represents the most stable release of Tcl available in binary form. It also includes several of
the most popular extensions, including Jan Nijtmans' IMG package, pre-compiled and ready
to use.

Linux Users have to check first if Tcl-Tk is already provided in the Linux Kernel. If not, it
has to be installed. On the CD-ROM is provided the last Linux version of ActiveTcl, called
*ActiveTcl8.4.13.0.261555-linux-ix86.tar*.

To install **PolSARpro v5.0 Software**, Linux Users have just to unzip and copy the
PolSARpro v5.0 package into the directory of their choice.

## DIRECTORY STRUCTURE
Once installed, the PolSARpro v5.0 Software Directory has the following structure:

- **ColorMap Directory** contains user defined or modified POLSARPRO colour-map files
- **Config Directory:**
    - default PolSARpro colour-map files.
    - config.txt, a default polarimetric data configuration text file.
    - gpl.txt and gplpsp.txt, the GNU GPL License text files.
    - OPCE_areas.txt, a default OPCE training class definition text file.
    - PDFReaderUnix.txt, containing the path to the default software used to view PDF files on a UNIX platform.
    - PDFReaderWindows.txt, containing the path to the default software used to view PDF files on a Windows platform.
    - training_areas.txt, a default training class definition text file.
    - Viewer.txt, a text file containing PolSARpro viewer default image display dimensions in pixels.
- **GUI Directory** contains all the widget window Tcl-Tk files.
- **Help Directory** contains the PolSARpro Help files.
- **Log Directory** is empty after installation and will contain all the log files created at each session.
- **Soft Directory** contains ready to use executable processing files and libraries.
- **TechDoc Directory** contains the technical documentations relative to all the GUI Widgets and C-Routines used in PolSARpro.
- **Tmp Directory** is empty after installation and is used by PolSARpro during each session.
- **Tutorial Directory** contains PolSARpro Tutorial material in PDF format .

**PolSARpro_v5.0.tcl** is the **executable file** that launches the PolSARpro User Interface (GUI).

*It is strictly recommended to not change, extract, move or modify any component (tcl-tk
widgets, executable processing files, colormaps, help files, PDF files…) included in the
PolSARpro v5.0 Software Directory and / or change its structure.*

## RUNNING POLSARPRO
Before running PolSARpro, Linux Users have to **compile** the executable processing files.
For this, is provided a batch file, called **Compil_PolSARpro_v5_Linux.bat** located in the **Soft**
directory.  
Once the executable files compiled, create a **link** between the directory where is installed
PolSARpro software and the sh command to launch PolSARpro, with:
```
ln –s /my_dir/PolSARpro_v5.0/PolSARpro.sh /usr/bin/PolSARpro
```
PolSARpro v5.0 Software is now ready to run. Start the GUI by typing the command batch
file *PolSARpro.sh* in an **Xterm** window. The command batch file *PolSARpro.sh* is given by:
```
#!/bin/sh

cd $(dirname $(readlink -f $0))
./PolSARpro_v5.0.tcl
```
