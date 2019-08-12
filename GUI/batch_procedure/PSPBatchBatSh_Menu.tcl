#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    package require Tk
    switch $tcl_platform(platform) {
	windows {
	    option add *Button.padY 0
	}
	default {
	    option add *Scrollbar.width 10
	    option add *Scrollbar.highlightThickness 0
	    option add *Scrollbar.elementBorderWidth 2
	    option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v8.6.0.5 Project
#




#############################################################################
## vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
#############################################################################
## Procedure:  vTcl:rename

proc ::vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

#############################################################################
## Procedure:  vTcl:image:create_new_image

proc ::vTcl:image:create_new_image {filename {description {no description}} {type {}} {data {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    # Does the image already exist?
    if {[info exists ::vTcl(images,files)]} {
        if {[lsearch -exact $::vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists ::vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            ## will add 'broken image' again when img is fixed, for now create empty
            set object [image create photo -width 1 -height 1]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]
    set ::vTcl(images,$reference,image)       $object
    set ::vTcl(images,$reference,description) $description
    set ::vTcl(images,$reference,type)        $type
    set ::vTcl(images,filename,$object)       $filename

    lappend ::vTcl(images,files) $filename
    lappend ::vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

#############################################################################
## Procedure:  vTcl:image:get_image

proc ::vTcl:image:get_image {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

#############################################################################
## Procedure:  vTcl:image:get_creation_type

proc ::vTcl:image:get_creation_type {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif -
	.png	{return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

foreach img {


            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

}
#############################################################################
## vTcl Code to Load User Images

catch {package require Img}

foreach img {

        {{[file join . GUI Images PSPImgBatchRunOn.gif]} {user image} user {}}
        {{[file join . GUI Images PSPImgBatch.gif]} {user image} user {}}
        {{[file join . GUI Images PSPImgBatchSpeckleOn.gif]} {user image} user {}}
        {{[file join . GUI Images PSPImgBatchReadOn.gif]} {user image} user {}}
        {{[file join . GUI Images PSPImgBatchArrowOn.gif]} {user image} user {}}
        {{[file join . GUI Images PSPImgBatchProcessOn.gif]} {user image} user {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
	show {
	    if {$exists} {
		wm deiconify $newname
	    } elseif {[info procs vTclWindow$name] != ""} {
		eval "vTclWindow$name $newname $rest"
	    }
	    if {[winfo exists $newname] && [wm state $newname] == "normal"} {
		vTcl:FireEvent $newname <<Show>>
	    }
	}
	hide    {
	    if {$exists} {
		wm withdraw $newname
		vTcl:FireEvent $newname <<Hide>>
		return}
	}
	iconify { if $exists {wm iconify $newname; return} }
	destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
	interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
	set widget($top_or_alias,$alias) $target
	if {$cmdalias} {
	    interp alias {} $top_or_alias.$alias {} $widgetProc $target
	}
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
	set tag_events [bind $bindtag]
	set stop_processing 0
	foreach tag_event $tag_events {
	    if {$tag_event == $event} {
		set bind_code [bind $bindtag $tag_event]
		foreach rep "\{%W $target\} $params" {
		    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
		}
		set result [catch {uplevel #0 $bind_code} errortext]
		if {$result == 3} {
		    ## break exception, stop processing
		    set stop_processing 1
		} elseif {$result != 0} {
		    bgerror $errortext
		}
		break
	    }
	}
	if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
	## If no arguments, returns the path the alias points to
	return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top700
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab67 {
        array set save {-activebackground 1 -background 1 -image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd125 {
        array set save {-activebackground 1 -background 1 -command 1 -image 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd128 {
        array set save {-activebackground 1 -background 1 -borderwidth 1 -image 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.but69 {
        array set save {-activebackground 1 -background 1 -command 1 -image 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd129 {
        array set save {-activebackground 1 -background 1 -borderwidth 1 -image 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd127 {
        array set save {-activebackground 1 -background 1 -command 1 -image 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd130 {
        array set save {-activebackground 1 -background 1 -borderwidth 1 -image 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd126 {
        array set save {-activebackground 1 -background 1 -command 1 -image 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.cpd73 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            BatchWidgetShow
            BatchCheckFile
            BatchWriteConfigInit
            BatchWriteConfigDir
            BatchWriteFilter
            BatchWriteProcessC2
            BatchWriteProcessT3
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {}
#############################################################################
## Procedure:  BatchWidgetShow

proc ::BatchWidgetShow {WidgetNum} {
global tcl_platform

set PlatForm $tcl_platform(platform)

set geoscreenwidth [winfo screenwidth .top700]
set geoscreenheight [winfo screenheight .top700]

set tx [winfo rootx .top700]
set ty [winfo rooty .top700]
set x [winfo x .top700]
set y [winfo y .top700]
set geoscreenborderw [expr {$tx-$x}]
set geoscreentitleh [expr {$ty-$y}]
if {$PlatForm == "unix"} {
    set geoscreentitleh [expr {$y-1}]
    set geoscreenborderw [expr 1 + round(($geoscreentitleh * 1.0) / 10.0)]
    }

set FrameGalBd 2; set FrameBd 2; set ButtonBd 3; set BorderHeight 62; ; set ButtonHeight 26
set offsetheight [expr $geoscreentitleh + $geoscreenborderw ] 
set offsetheight [expr $offsetheight + (2 * $FrameGalBd) + (2 * $FrameBd) + (2 * $ButtonBd) + $BorderHeight ] 
set offsetheight [expr $offsetheight + (2 * $FrameGalBd) + (2 * $FrameBd) + (2 * $ButtonBd) + $ButtonHeight ] 

set offsetbottom "0"

#set geoscreenheighttmp [expr $geoscreenheight - $offsetheight - $offsetbottom]
set geoscreenheighttmp [expr $geoscreenheight - $offsetbottom]
set geoscreenwidths2 [expr $geoscreenwidth / 2]
set geoscreenheights2 [expr $geoscreenheighttmp / 2]

set geomenuwidth [winfo width .top700]
set geomenuheight [winfo height .top700]
set geomenuX [winfo x .top700]
set geomenuY [winfo y .top700]

set geowidgetwidth [winfo width $WidgetNum]
set geowidgetheight [winfo height $WidgetNum]
set geowidgetwidths2 [expr $geowidgetwidth / 2]
set geowidgetheights2 [expr $geowidgetheight / 2]

set positionheight $geomenuY
if {$PlatForm == "unix"} {
    set positionheight [expr $geomenuY - ($geoscreentitleh / 2)]
    }

#Positionnement a Droite
set positionwidth [expr $geomenuX + $geomenuwidth]; set positionwidth [expr $positionwidth + (3 * $geoscreenborderw)];
set limitwidth [expr $positionwidth + $geowidgetwidth]
set config "true"
if {$limitwidth > $geoscreenwidth} {set config "false"}

if {$config == "false"} {
    #Positionnement a Gauche
    set positionwidth [expr $geomenuX - $geowidgetwidth]; set positionwidth [expr $positionwidth - (3 * $geoscreenborderw)];
    set limitwidth $positionwidth
    set config "true"
    set limit [expr $geoscreenborderw + $geoscreenborderw]
    if {$limitwidth < $limit} {set config "false"}

    if {$config == "false"} {
        #Positionnement au Centre
        set positionwidth [expr $geoscreenwidths2 - $geowidgetwidths2]
        #set positionheight [expr $geoscreenheights2 - $geowidgetheights2 + $offsetheight]
        set positionheight [expr $geoscreenheights2 - $geowidgetheights2]
        if {$positionheight < $offsetheight} {set positionheight $offsetheight}
        }  
    }  

set geometrie $geowidgetwidth; append geometrie "x"; append geometrie $geowidgetheight; append geometrie "+";
append geometrie $positionwidth; append geometrie "+"; append geometrie $positionheight

wm geometry $WidgetNum $geometrie; update
#catch {wm geometry $WidgetNum {}}
Window show $WidgetNum
}
#############################################################################
## Procedure:  BatchCheckFile

proc ::BatchCheckFile {FileNameInput} {
set FileNameOutput ""
set Lengthtemp [string length $FileNameInput]
for {set i 0} {$i <= $Lengthtemp} {incr i} {
    set lettre [string range $FileNameInput $i $i]
    if {$lettre == "/"} { set lettre "\\" }
    append FileNameOutput $lettre
    }
return $FileNameOutput
}
#############################################################################
## Procedure:  BatchWriteConfigInit

proc ::BatchWriteConfigInit {ffb} {
global tcl_platform env
global PSPDir TMPDir COLORMAPDir
global BatchPSPDir BatchTMPDir BatchCOLORMAPDir

set PlatForm $tcl_platform(platform)

##Windows
if {$PlatForm == "windows"} {
    set BatchPSPDir [BatchCheckFile $PSPDir]
    set BatchTMPDir [BatchCheckFile $TMPDir]
    set BatchCOLORMAPDir [BatchCheckFile $COLORMAPDir]
    puts $ffb " "
    puts $ffb "echo off"
    puts $ffb " "
    puts $ffb "REM ********** Global / Common Variables **********"
    puts $ffb "set PolSARproDirectory=$BatchPSPDir"
    puts $ffb "set TMPDirectory=$BatchTMPDir"
    puts $ffb "set COLORMAPDirectory=$BatchCOLORMAPDir"
    puts $ffb " "
    }        

##Unix - Linux
if {$PlatForm == "unix"} {
    set BatchPSPDir $PSPDir
    set BatchTMPDir $TMPDir
    set BatchCOLORMAPDir $COLORMAPDir
    }
}
#############################################################################
## Procedure:  BatchWriteConfigDir

proc ::BatchWriteConfigDir {ffb ii BatchDataDirInput BatchNlig BatchNcol} {
global tcl_platform

set PlatForm $tcl_platform(platform)

##Windows
if {$PlatForm == "windows"} {
    puts $ffb "echo ********************"
    puts $ffb "echo ***   Image $ii    ***"
    puts $ffb "echo ********************"
    set BatchDataDir [BatchCheckFile $BatchDataDirInput]
    puts $ffb "set InputDirectory=$BatchDataDir"
    puts $ffb "set InitialNrow=$BatchNlig"
    puts $ffb "set InitialNcol=$BatchNcol"
    }        

##Unix - Linux
if {$PlatForm == "unix"} {
    }
    
    
}
#############################################################################
## Procedure:  BatchWriteFilter

proc ::BatchWriteFilter {ffb fff BatchFilter BatchDataDirOutput BatchFormat} {
global tcl_platform BatchPSPDir

set PlatForm $tcl_platform(platform)

if {$BatchFilter == "boxcar" } {
    gets $fff BatchNwinFilterL; gets $fff BatchNwinFilterC; gets $fff BatchNlook
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_box"
    }
if {$BatchFilter == "gauss" } {
    gets $fff BatchNwinFilterL; gets $fff BatchNwinFilterC; gets $fff BatchNlook
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_gauss"
    }
if {$BatchFilter == "idan" } {
    gets $fff BatchNwinFilterL; gets $fff BatchNwinFilterC; gets $fff BatchNlook
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_idan"
    }
if {$BatchFilter == "lee" } {
    gets $fff BatchNwinFilterL; gets $fff BatchNwinFilterC; gets $fff BatchNlook
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_lee"
    }
if {$BatchFilter == "anyang" } {
    gets $fff BatchNlookAnYang; gets $fff BatchNwinLAnYang; gets $fff BatchNwinCAnYang
    gets $fff BatchSwinLAnYang; gets $fff BatchSwinCAnYang; gets $fff BatchKAnYang
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_anyang"
    }
if {$BatchFilter == "lopez" } {
    gets $fff BatchNwinFilterL; gets $fff BatchNwinFilterC; gets $fff BatchNlook
    gets $fff BatchNitFilter; gets $fff BatchImprovedFilter; gets $fff BatchWeightFilter; gets $fff BatchStrgFilter
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_lopez"
    }
if {$BatchFilter == "sigma" } {
    gets $fff BatchNlookSigma; gets $fff BatchSigma; gets $fff BatchNwinFilter; gets $fff BatchNwinTgt
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_sigma"
    }
if {$BatchFilter == "nonlocalmeans" } {
    gets $fff BatchNwinSearch; gets $fff BatchNwinPatch; gets $fff BatchNLFilter
    gets $fff BatchNlookNL; gets $fff BatchCoeffK; gets $fff BatchNwinFilter; gets $fff BatchNwinTgt
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_nonlocalmeans"
    }
if {$BatchFilter == "meanshift" } {
    gets $fff BatchMeanShiftLook; gets $fff BatchMeanShiftNwin; gets $fff BatchMeanShiftNwinPix; gets $fff BatchMeanShiftThreshold
    gets $fff BatchMeanShiftSigma; gets $fff BatchMeanShiftKernelS; gets $fff BatchMeanShiftKernelR
    gets $fff BatchMeanShiftPixel; gets $fff BatchMeanShiftBeta; gets $fff BatchMeanShiftLambdaS; gets $fff BatchMeanShiftLambdaR
    set BatchFilterNameBat $BatchPSPDir; append BatchFilterNameBat "/GUI/batch_procedure/speckle_meanshift"
    }

##Windows
if {$PlatForm == "windows"} {
    puts $ffb " "
    set Tmp [BatchCheckFile $BatchDataDirOutput]
    puts $ffb "set OutputDirectory=$Tmp"
    puts $ffb "set DataFormat=$BatchFormat"
    set Tmp [BatchCheckFile "$BatchFilterNameBat.bat"]
    if {$BatchFilter == "boxcar" } { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchNwinFilterL $BatchNwinFilterC" }
    if {$BatchFilter == "gauss" } { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchNwinFilterL $BatchNwinFilterC" }
    if {$BatchFilter == "idan" } {
        set FilterAmount [expr 1. / $BatchNlook]; if {$FilterAmount > 1.} { set FilterAmount "1." }
        puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchNwinFilterL $BatchNlook $FilterAmount"
        }
    if {$BatchFilter == "lee" } { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchNwinFilterL $BatchNlook" }
    if {$BatchFilter == "anyang" } { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchNwinLAnYang $BatchNwinCAnYang $BatchSwinLAnYang $BatchSwinCAnYang $BatchNlookAnYang $BatchKAnYang" }
    if {$BatchFilter == "lopez" } { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchNwinFilterL $BatchNwinFilterC $BatchNitFilter $BatchImprovedFilter $BatchWeightFilter $BatchStrgFilter" }
    if {$BatchFilter == "sigma" } { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchNwinFilter $BatchNwinTgt $BatchNlookSigma $BatchSigma" }
    if {$BatchFilter == "nonlocalmeans" } { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchNLFilter $BatchNwinFilter $BatchNlookNL $BatchNwinTgt $BatchNwinSearch $BatchNwinPatch $BatchCoeffK" }
    if {$BatchFilter == "meanshift" } { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% $BatchMeanShiftLook $BatchMeanShiftNwin $BatchMeanShiftNwinPix $BatchMeanShiftThreshold $BatchMeanShiftSigma $BatchMeanShiftKernelS $BatchMeanShiftKernelR $BatchMeanShiftPixel $BatchMeanShiftBeta $BatchMeanShiftLambdaS $BatchMeanShiftLambdaR" }
    }        

##Unix - Linux
if {$PlatForm == "unix"} {
    set Tmp "$BatchFilterNameBat.sh"
    }
}
#############################################################################
## Procedure:  BatchWriteProcessC2

proc ::BatchWriteProcessC2 {ffb ffp BatchDataDirOutput} {
global tcl_platform BatchPSPDir

set PlatForm $tcl_platform(platform)

gets $ffp NwinProcessL; gets $ffp NwinProcessC

##Windows
if {$PlatForm == "windows"} {
    puts $ffb " "
    set Tmp [BatchCheckFile $BatchDataDirOutput]
    puts $ffb "set InputDirectory=$Tmp"
    puts $ffb "set OutputDirectory=$Tmp"
    puts $ffb "set DataFormat=$BatchFormat"
    puts $ffb "set NwinProcessRow=$NwinProcessL"
    puts $ffb "set NwinProcessCol=$NwinProcessC"
    }
##Unix - Linux
if {$PlatForm == "unix"} {
    }

gets $ffp BatchMatrix
if {$BatchMatrix != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_matrix"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchProcessNameBat.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchProcessNameBat.sh"}
    gets $ffp MatrixM11mod
    if {$MatrixM11mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 11 mod" }
    gets $ffp MatrixM11db
    if {$MatrixM11db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 11 db" }
    gets $ffp MatrixM12mod
    if {$MatrixM12mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 12 mod" }
    gets $ffp MatrixM12db
    if {$MatrixM12db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 12 db" }
    gets $ffp MatrixM12pha
    if {$MatrixM12pha == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 12 pha" }
    gets $ffp MatrixM22mod
    if {$MatrixM22mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 22 mod" }
    gets $ffp MatrixM22db
    if {$MatrixM22db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 22 db" }
    }

gets $ffp BatchCorr
if {$BatchCorr != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_corr"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchProcessNameBat.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchProcessNameBat.sh"}
    gets $ffp Corr12mod
    if {$Corr12mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 12 mod" }
    gets $ffp Corr12db
    if {$Corr12db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 12 db" }
    gets $ffp Corr12pha
    if {$Corr12pha == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 12 pha" }
    }

gets $ffp BatchFunc
if {$BatchFunc != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_functions"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchProcessNameBat.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchProcessNameBat.sh"}
    gets $ffp SpanLin
    if {$SpanLin == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% spanlin" }
    gets $ffp SpanDB
    if {$SpanDB == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% spandb" }
    gets $ffp PWF
    if {$PWF == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% pwf" }
    gets $ffp PWFdb
    if {$PWFdb == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% pwfdb" }
    gets $ffp DIG
    if {$DIG == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dig" }
    gets $ffp DIIS
    if {$DIIS == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% diis" }
    gets $ffp DII
    if {$DII == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dii" }
    gets $ffp DIP
    if {$DIP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dip" }
    gets $ffp DIR2
    if {$DIR2 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dir2" }
    gets $ffp DIR3
    if {$DIR3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dir3" }
    gets $ffp DIR4
    if {$DIR4 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dir4" }
    gets $ffp DIS
    if {$DIS == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dis" }
    gets $ffp DISH
    if {$DISH == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dish" }
    gets $ffp RR1112
    if {$RR1112 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1112" }
    gets $ffp RR1211
    if {$RR1211 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1211" }
    gets $ffp RR1122
    if {$RR1122 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1122" }
    gets $ffp RR2211
    if {$RR2211 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2211" }
    gets $ffp RR1222
    if {$RR1222 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1222" }
    gets $ffp RR2212
    if {$RR2212 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2212" }
    gets $ffp RR1121
    if {$RR1121 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1121" }
    gets $ffp RR2111
    if {$RR2111 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2111" }
    gets $ffp RR1221
    if {$RR1221 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1221" }
    gets $ffp RR2112
    if {$RR2112 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2112" }
    gets $ffp RR2122
    if {$RR2122 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2122" }
    gets $ffp RR2221
    if {$RR2221 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2221" }
    gets $ffp ZDR1112
    if {$ZDR1112 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1112" }
    gets $ffp ZDR1211
    if {$ZDR1211 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1211" }
    gets $ffp ZDR1122
    if {$ZDR1122 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1122" }
    gets $ffp ZDR2211
    if {$ZDR2211 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2211" }
    gets $ffp ZDR1222
    if {$ZDR1222 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1222" }
    gets $ffp ZDR2212
    if {$ZDR2212 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2212" }
    gets $ffp ZDR1121
    if {$ZDR1121 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1121" }
    gets $ffp ZDR2111
    if {$ZDR2111 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2111" }
    gets $ffp ZDR1221
    if {$ZDR1221 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1221" }
    gets $ffp ZDR2112
    if {$ZDR2112 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2112" }
    gets $ffp ZDR2122
    if {$ZDR2122 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2122" }
    gets $ffp ZDR2221
    if {$ZDR2221 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2221" }
    gets $ffp G0
    if {$G0 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkg0" }
    gets $ffp G0db
    if {$G0db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkg0db" }
    gets $ffp G1
    if {$G1 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkg1" }
    gets $ffp G1db
    if {$G1db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkg1db" }
    gets $ffp G2
    if {$G2 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkg2" }
    gets $ffp G2db
    if {$G2db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkg2db" }
    gets $ffp G3
    if {$G3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkg3" }
    gets $ffp G3db
    if {$G3db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkg3db" }
    gets $ffp PHI
    if {$PHI == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkphi" }
    gets $ffp TAU
    if {$TAU == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stktau" }
    gets $ffp CON
    if {$CON == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkcon" }
    gets $ffp DOP
    if {$DOP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkdop" }
    gets $ffp DOLP
    if {$DOLP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkdolp" }
    gets $ffp DOCP
    if {$DOCP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkdocp" }
    gets $ffp LPR
    if {$LPR == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stklpr" }
    gets $ffp CPR
    if {$CPR == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% stkcpr" }
    gets $ffp prob
    if {$prob == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC2prob" }
    gets $ffp alpdellam
    if {$alpdellam == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC2alpdellam" }
    gets $ffp H
    if {$H == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC2H" }
    gets $ffp SH
    if {$SH == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC2SH" }
    gets $ffp A
    if {$A == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC2A" }
    gets $ffp HA
    if {$HA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC2HA" }
    gets $ffp H1mA
    if {$H1mA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC2H1mA" }
    gets $ffp 1mHA
    if {$1mHA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC21mHA" }
    gets $ffp 1mH1mA
    if {$1mH1mA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpC21mH1mA" }
    }

gets $ffp BatchClass
if {$BatchClass != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_classification"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchProcessNameBat.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchProcessNameBat.sh"}
    gets $ffp NwinClassifL; gets $ffp NwinClassifC
    ##Windows
    if {$PlatForm == "windows"} {
        puts $ffb " "
        puts $ffb "set NwinClassifRow=$NwinClassifL"
        puts $ffb "set NwinClassifCol=$NwinClassifC"
        }
    ##Unix - Linux
    if {$PlatForm == "unix"} {
        }
    gets $ffp Classif1
    if {$Classif1 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif1" }
    gets $ffp Classif2
    if {$Classif2 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif2" }
    gets $ffp Classif3
    if {$Classif3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif3" }
    gets $ffp Classif4
    if {$Classif4 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif4" }
    gets $ffp Classif5
    if {$Classif5 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif5" }
    gets $ffp Classif6
    if {$Classif6 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif6" }
    gets $ffp Classif7
    if {$Classif7 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif7" }
    }
}
#############################################################################
## Procedure:  BatchWriteProcessT3

proc ::BatchWriteProcessT3 {ffb ffp BatchDataDirOutput} {
global tcl_platform BatchPSPDir

set PlatForm $tcl_platform(platform)

gets $ffp NwinProcessL; gets $ffp NwinProcessC

##Windows
if {$PlatForm == "windows"} {
    puts $ffb " "
    set Tmp [BatchCheckFile $BatchDataDirOutput]
    puts $ffb "set InputDirectory=$Tmp"
    puts $ffb "set OutputDirectory=$Tmp"
    puts $ffb "set DataFormat=$BatchFormat"
    puts $ffb "set NwinProcessRow=$NwinProcessL"
    puts $ffb "set NwinProcessCol=$NwinProcessC"
    }
##Unix - Linux
if {$PlatForm == "unix"} {
    }

gets $ffp BatchMatrix
if {$BatchMatrix != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_matrix"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchProcessNameBat.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchProcessNameBat.sh"}
    gets $ffp MatrixM11mod
    if {$MatrixM11mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 11 mod" }
    gets $ffp MatrixM11db
    if {$MatrixM11db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 11 db" }
    gets $ffp MatrixM12mod
    if {$MatrixM12mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 12 mod" }
    gets $ffp MatrixM12db
    if {$MatrixM12db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 12 db" }
    gets $ffp MatrixM12pha
    if {$MatrixM12pha == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 12 pha" }
    gets $ffp MatrixM13mod
    if {$MatrixM13mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 13 mod" }
    gets $ffp MatrixM13db
    if {$MatrixM13db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 13 db" }
    gets $ffp MatrixM13pha
    if {$MatrixM13pha == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 13 pha" }
    gets $ffp MatrixM22mod
    if {$MatrixM22mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 22 mod" }
    gets $ffp MatrixM22db
    if {$MatrixM22db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 22 db" }
    gets $ffp MatrixM23mod
    if {$MatrixM23mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 23 mod" }
    gets $ffp MatrixM23db
    if {$MatrixM23db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 23 db" }
    gets $ffp MatrixM23pha
    if {$MatrixM23pha == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 23 pha" }
    gets $ffp MatrixM33mod
    if {$MatrixM33mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 33 mod" }
    gets $ffp MatrixM33db
    if {$MatrixM33db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% 33 db" }
    }

gets $ffp BatchCorr
if {$BatchCorr != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_corr"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchProcessNameBat.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchProcessNameBat.sh"}
    gets $ffp Corr12mod
    if {$Corr12mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 12 mod" }
    gets $ffp Corr12db
    if {$Corr12db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 12 db" }
    gets $ffp Corr12pha
    if {$Corr12pha == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 12 pha" }
    gets $ffp Corr13mod
    if {$Corr13mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 13 mod" }
    gets $ffp Corr13db
    if {$Corr13db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 13 db" }
    gets $ffp Corr13pha
    if {$Corr13pha == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 13 pha" }
    gets $ffp Corr23mod
    if {$Corr23mod == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 23 mod" }
    gets $ffp Corr23db
    if {$Corr23db == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 23 db" }
    gets $ffp Corr23pha
    if {$Corr23pha == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% 23 pha" }
    }

gets $ffp BatchFunc
if {$BatchFunc != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_functions"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchProcessNameBat.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchProcessNameBat.sh"}
    gets $ffp SpanLin
    if {$SpanLin == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% spanlin" }
    gets $ffp SpanDB
    if {$SpanDB == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% spandb" }
    gets $ffp PWF
    if {$PWF == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% pwf" }
    gets $ffp PWFdb
    if {$PWFdb == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% pwfdb" }
    gets $ffp DIG
    if {$DIG == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dig" }
    gets $ffp DIIS
    if {$DIIS == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% diis" }
    gets $ffp DII
    if {$DII == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dii" }
    gets $ffp DIP
    if {$DIP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dip" }
    gets $ffp DIR2
    if {$DIR2 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dir2" }
    gets $ffp DIR3
    if {$DIR3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dir3" }
    gets $ffp DIR4
    if {$DIR4 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dir4" }
    gets $ffp DIS
    if {$DIS == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dis" }
    gets $ffp DISH
    if {$DISH == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% dish" }
    gets $ffp RR1112
    if {$RR1112 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1112" }
    gets $ffp RR1211
    if {$RR1211 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1211" }
    gets $ffp RR1122
    if {$RR1122 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1122" }
    gets $ffp RR2211
    if {$RR2211 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2211" }
    gets $ffp RR1222
    if {$RR1222 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1222" }
    gets $ffp RR2212
    if {$RR2212 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2212" }
    gets $ffp RR1121
    if {$RR1121 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1121" }
    gets $ffp RR2111
    if {$RR2111 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2111" }
    gets $ffp RR1221
    if {$RR1221 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr1221" }
    gets $ffp RR2112
    if {$RR2112 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2112" }
    gets $ffp RR2122
    if {$RR2122 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2122" }
    gets $ffp RR2221
    if {$RR2221 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% rr2221" }
    gets $ffp ZDR1112
    if {$ZDR1112 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1112" }
    gets $ffp ZDR1211
    if {$ZDR1211 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1211" }
    gets $ffp ZDR1122
    if {$ZDR1122 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1122" }
    gets $ffp ZDR2211
    if {$ZDR2211 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2211" }
    gets $ffp ZDR1222
    if {$ZDR1222 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1222" }
    gets $ffp ZDR2212
    if {$ZDR2212 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2212" }
    gets $ffp ZDR1121
    if {$ZDR1121 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1121" }
    gets $ffp ZDR2111
    if {$ZDR2111 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2111" }
    gets $ffp ZDR1221
    if {$ZDR1221 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr1221" }
    gets $ffp ZDR2112
    if {$ZDR2112 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2112" }
    gets $ffp ZDR2122
    if {$ZDR2122 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2122" }
    gets $ffp ZDR2221
    if {$ZDR2221 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% zdr2221" }
    gets $ffp prob
    if {$prob == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT3prob" }
    gets $ffp alpbetdelgamlam
    if {$alpbetdelgamlam == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpT3alpbetdelgamlam" }
    gets $ffp H
    if {$H == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpT3H" }
    gets $ffp SH
    if {$SH == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT3SH" }
    gets $ffp A
    if {$A == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpT3A" }
    gets $ffp HA
    if {$HA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpT3HA" }
    gets $ffp H1mA
    if {$H1mA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpT3H1mA" }
    gets $ffp 1mHA
    if {$1mHA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpT31mHA" }
    gets $ffp 1mH1mA
    if {$1mH1mA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpT31mH1mA" }
    gets $ffp HP
    if {$HP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HPraks" }
    gets $ffp HAn
    if {$HAn == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAn" }
    gets $ffp HFre
    if {$HFre == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HFreeman" }
    gets $ffp HVZ
    if {$HVZ == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HVanZyl" }
    gets $ffp AlpP
    if {$AlpP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% AlpPraks" }
    gets $ffp AlpAn
    if {$AlpAn == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% AlpAn" }
    gets $ffp A12
    if {$A12 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT31A12" }
    gets $ffp AKoz
    if {$AKoz == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% AKozlov" }
    gets $ffp ALue
    if {$ALue == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT31ALue" }
    gets $ffp PolAss
    if {$PolAss == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT31PolAss" }
    gets $ffp PolFrac
    if {$PolFrac == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT31PolFrac" }
    gets $ffp RVI
    if {$RVI == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT31RVI" }
    gets $ffp ERD
    if {$ERD == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT31ERD" }
    gets $ffp PH
    if {$PH == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% HAAlpEigT31PH" }
    gets $ffp POC
    if {$POC == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% POC" }
    gets $ffp CC
    if {$CC == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% CC" }
    gets $ffp SP
    if {$SP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% SP" }
    gets $ffp SD
    if {$SD == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% SD" }
    gets $ffp DP
    if {$DP == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% DP" }
    gets $ffp DI
    if {$DI == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% DI" }
    gets $ffp PPSD
    if {$PPSD == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% PPSD" }
    gets $ffp RCS
    if {$RCS == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinProcessRow% %NwinProcessCol% RCS" }
    }

gets $ffp BatchClass
if {$BatchClass != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_classification"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchProcessNameBat.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchProcessNameBat.sh"}
    gets $ffp NwinClassifL; gets $ffp NwinClassifC
    ##Windows
    if {$PlatForm == "windows"} {
        puts $ffb " "
        puts $ffb "set NwinClassifRow=$NwinClassifL"
        puts $ffb "set NwinClassifCol=$NwinClassifC"
        }
    ##Unix - Linux
    if {$PlatForm == "unix"} {
        }
    gets $ffp Classif1
    if {$Classif1 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif1" }
    gets $ffp Classif2
    if {$Classif2 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif2" }
    gets $ffp Classif3
    if {$Classif3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif3" }
    gets $ffp Classif4
    if {$Classif4 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif4" }
    gets $ffp Classif5
    if {$Classif5 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif5" }
    gets $ffp Classif6
    if {$Classif6 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif6" }
    gets $ffp Classif7
    if {$Classif7 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinClassifRow% %NwinClassifCol% Classif7" }
    }

gets $ffp BatchDecomp
if {$BatchDecomp != "none"} {
    set BatchProcessNameBat $BatchPSPDir; append BatchProcessNameBat "/GUI/batch_procedure/process_decomposition"
    if {$PlatForm == "windows"} {set Tmp [BatchCheckFile "$BatchFilterName.bat"]}
    if {$PlatForm == "unix"} {set Tmp "$BatchFilterName.sh"}
    gets $ffp NwinDecompL; gets $ffp NwinDecompC
    ##Windows
    if {$PlatForm == "windows"} {
        puts $ffb " "
        puts $ffb "set NwinDecompRow=$NwinDecompL"
        puts $ffb "set NwinDecompCol=$NwinDecompC"
        }
    ##Unix - Linux
    if {$PlatForm == "unix"} {
        }
    gets $ffp RMB1
    if {$RMB1 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% RMB1" }
    gets $ffp RMB2
    if {$RMB2 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% RMB2" }
    gets $ffp WAH1
    if {$WAH1 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% WAH1" }
    gets $ffp WAH2
    if {$WAH2 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% WAH2" }
    gets $ffp JRC
    if {$JRC == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% JRC" }
    gets $ffp UHD
    if {$UHD == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% UHD" }
    gets $ffp HAA
    if {$HAA == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% HAA" }
    gets $ffp SRC
    if {$SRC == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% SRC" }
    gets $ffp AGH
    if {$AGH == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% AGH" }
    gets $ffp KRO
    if {$KRO == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% KRO" }
    gets $ffp TSVM
    if {$TSVM == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% TSVM" }
    gets $ffp FRE2
    if {$FRE2 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% FRE2" }
    gets $ffp NEU
    if {$NEU == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% NEU" }
    gets $ffp AN3
    if {$AN3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% AN3" }
    gets $ffp FRE3
    if {$FRE3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% FRE3" }
    gets $ffp NNED
    if {$NNED == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% NNED" }
    gets $ffp ANNED
    if {$ANNED == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% ANNED" }
    gets $ffp VZ3
    if {$VZ3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% VZ3" }
    gets $ffp YAM3
    if {$YAM3 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% YAM3" }
    gets $ffp AN4
    if {$AN4 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% AN4" }
    gets $ffp BF4
    if {$BF4 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% BF4" }
    gets $ffp G4U
    if {$G4U == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% G4U" }
    gets $ffp YA0
    if {$YA0 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% YA0" }
    gets $ffp YAR
    if {$YAR == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% YAR" }
    gets $ffp S4R
    if {$S4R == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% S4R" }
    gets $ffp MCSM5
    if {$MCSM5 == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% MCSM5" }
    gets $ffp i6SD
    if {$i6SD == 1} { puts $ffb "$Tmp %PolSARproDirectory% %TMPDirectory% %InputDirectory% %OutputDirectory% %DataFormat% %InitialNrow% %InitialNcol% %NwinDecompRow% %NwinDecompCol% I6SD" }
    }
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 200x200+260+260; update
    wm maxsize $top 1924 1061
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top700 {base} {
    if {$base == ""} {
        set base .top700
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
		-background #ffffff 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 120x300+10+110; update
    wm maxsize $top 3844 1065
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Batch : Main Menu"
    vTcl:DefineAlias "$top" "Toplevel700" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    label $top.lab67 \
		-activebackground #ffffff -background #ffffff \
		-image [vTcl:image:get_image [file join . GUI Images PSPImgBatch.gif]] \
		-relief ridge -text label 
    vTcl:DefineAlias "$top.lab67" "Label1" vTcl:WidgetProc "Toplevel700" 1
    button $top.cpd125 \
		-activebackground #ffffff -background #ffffff \
		-command {global DataDir DataDirBatch DataDirInit DataDirBatchActive
global NDataDirBatch NDataDirBatchActive 
global DataDirBatchFormat DataDirBatchFormatActive
global SaveDataDirBatch TestDataDirBatch
global BatchSNAPSensor 
global DataDirBatchNligFullSize DataDirBatchNcolFullSize
global DataDirBatchNligFullSizeActive DataDirBatchNcolFullSizeActive
global DataDirBatchPolarCase DataDirBatchPolarType
global DataDirBatchPolarCaseActive DataDirBatchPolarTypeActive
global DataDirBatchSensor DataDirBatchSensorActive
global DataDirBatchSensorFormat DataDirBatchSensorFormatActive
global DataDirBatchSensorProductFile DataDirBatchSensorConfigFile DataDirBatchSensorExtraFile DataDirBatchSensorSNAP
global DataDirBatchSensorFile1 DataDirBatchSensorFile2 DataDirBatchSensorFile3 DataDirBatchSensorFile4
global DataDirBatchSensorNligInput DataDirBatchSensorNcolInput DataDirBatchSensorNligMLK DataDirBatchSensorNcolMLK

#POLSARPRO-BIO
global Load_PSPBatchBatShRead PSPTopLevelBio

if {$Load_PSPBatchBatShRead == 0} {
    source "GUI/batch_procedure/PSPBatchBatSh_Read.tcl"
    set Load_PSPBatchBatShRead 1
    WmTransient $widget(Toplevel701) $PSPTopLevelBio
    }

set ConfigFile ""
#CheckBinaryData
for {set i 0} {$i <= 100} {incr i} {set DataDirBatch($i) $DataDir}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchFormat($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchNligFullSize($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchNcolFullSize($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchPolarCase($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchPolarType($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensor($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorFormat($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorProductFile($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorConfigFile($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorExtraFile($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorSNAP($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorFile1($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorFile2($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorFile3($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorFile4($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorNligInput($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorNcolInput($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorNligMLK($i) " "}
for {set i 0} {$i <= 100} {incr i} {set DataDirBatchSensorNcolMLK($i) " "}
set DataDirBatchActive $DataDirBatch(1) 
set NDataDirBatch 1
set NDataDirBatchActive 1
set DataDirBatchFormatActive " "
set DataDirBatchNligFullSizeActive " "
set DataDirBatchNcolFullSizeActive " "
set DataDirBatchPolarCaseActive " "
set DataDirBatchPolarTypeActive " "
set DataDirBatchSensorActive " "
set DataDirBatchSensorFormatActive " "

set BatchSNAPSensor " "

set SaveDataDirBatch 0
set TestDataDirBatch "ok"

$widget(Button701_2) configure -state disable
$widget(Button701_3) configure -state disable
$widget(Button701_4) configure -state disable
$widget(Button701_5) configure -state disable
$widget(Button701_6) configure -state disable

$widget(TitleFrame701_1)  configure -state disable
$widget(Radiobutton701_1)  configure -state disable
$widget(Radiobutton701_2)  configure -state disable
$widget(Radiobutton701_3)  configure -state disable
$widget(Radiobutton701_4)  configure -state disable
$widget(Radiobutton701_5)  configure -state disable
$widget(Radiobutton701_6)  configure -state disable
$widget(Radiobutton701_7)  configure -state disable
$widget(Radiobutton701_8)  configure -state disable
$widget(Radiobutton701_9)  configure -state disable
$widget(Radiobutton701_10)  configure -state disable
$widget(Radiobutton701_11)  configure -state disable

BatchWidgetShow $widget(Toplevel701); TextEditorRunTrace "Open Window PolSARpro-Bio Batch : Read Menu" "b"} \
		-image [vTcl:image:get_image [file join . GUI Images PSPImgBatchReadOn.gif]] \
		-pady 0 -relief flat -state disabled -text button 
    vTcl:DefineAlias "$top.cpd125" "Button700_1" vTcl:WidgetProc "Toplevel700" 1
    label $top.cpd128 \
		-activebackground #ffffff -background #ffffff -borderwidth 0 \
		-image [vTcl:image:get_image [file join . GUI Images PSPImgBatchArrowOn.gif]] \
		-state disabled -text label 
    vTcl:DefineAlias "$top.cpd128" "Label700_1" vTcl:WidgetProc "Toplevel700" 1
    button $top.but69 \
		-activebackground #ffffff -background #ffffff \
		-command {global BatchFilterCase BatchNlook BatchNwinFilterL BatchNwinFilterC

#POLSARPRO-BIO
global Load_PSPBatchBatShSpeckleFilter PSPTopLevelBio

set BatchFilterCase "none"
set BatchNlook " "; set BatchNwinFilterL " "; set BatchNwinFilterC " "

if {$Load_PSPBatchBatShSpeckleFilter == 0} {
    source "GUI/batch_procedure/PSPBatchBatSh_SpeckleFilter.tcl"
    set Load_PSPBatchBatShSpeckleFilter 1
    WmTransient $widget(Toplevel702) $PSPTopLevelBio
    }

$widget(TitleFrame702_1_1)  configure -state disable
$widget(Label702_1_1)  configure -state disable
$widget(Label702_1_2)  configure -state disable
$widget(Label702_1_3)  configure -state disable
$widget(Entry702_1_1)  configure -state disable
$widget(Entry702_1_2)  configure -state disable
$widget(Entry702_1_3)  configure -state disable
$widget(Button702_1_1)  configure -state disable

$widget(Button702_1_0)  configure -state normal

BatchWidgetShow $widget(Toplevel702); TextEditorRunTrace "Open Window PolSARpro-Bio Batch : Speckle Filter Menu" "b"} \
		-image [vTcl:image:get_image [file join . GUI Images PSPImgBatchSpeckleOn.gif]] \
		-pady 0 -relief flat -state disabled -text button 
    vTcl:DefineAlias "$top.but69" "Button700_2" vTcl:WidgetProc "Toplevel700" 1
    label $top.cpd129 \
		-activebackground #ffffff -background #ffffff -borderwidth 0 \
		-image [vTcl:image:get_image [file join . GUI Images PSPImgBatchArrowOn.gif]] \
		-state disabled -text label 
    vTcl:DefineAlias "$top.cpd129" "Label700_2" vTcl:WidgetProc "Toplevel700" 1
    button $top.cpd127 \
		-activebackground #ffffff -background #ffffff \
		-command {global BatchProcessC2Matrix BatchProcessC2Corr BatchProcessC2Func BatchProcessC2Class
global BatchProcessT3Matrix BatchProcessT3Corr BatchProcessT3Func BatchProcessT3Class BatchProcessT3Deco
global BatchNwinProcessL BatchNwinProcessC

#POLSARPRO-BIO
global Load_PSPBatchBatShProcess PSPTopLevelBio

if {$Load_PSPBatchBatShProcess == 0} {
    source "GUI/batch_procedure/PSPBatchBatSh_Process.tcl"
    set Load_PSPBatchBatShProcess 1
    WmTransient $widget(Toplevel703) $PSPTopLevelBio
    }

set BatchProcessC2Matrix 0
set BatchProcessC2Corr 0
set BatchProcessC2Func 0
set BatchProcessC2Class 0

set BatchProcessT3Matrix 0
set BatchProcessT3Corr 0
set BatchProcessT3Func 0
set BatchProcessT3Class 0
set BatchProcessT3Deco 0

set BatchNwinProcessL "3"
set BatchNwinProcessC "3"

BatchWidgetShow $widget(Toplevel703); TextEditorRunTrace "Open Window PolSARpro-Bio Batch : Process Menu" "b"} \
		-image [vTcl:image:get_image [file join . GUI Images PSPImgBatchProcessOn.gif]] \
		-pady 0 -relief flat -state disabled -text button 
    vTcl:DefineAlias "$top.cpd127" "Button700_3" vTcl:WidgetProc "Toplevel700" 1
    label $top.cpd130 \
		-activebackground #ffffff -background #ffffff -borderwidth 0 \
		-image [vTcl:image:get_image [file join . GUI Images PSPImgBatchArrowOn.gif]] \
		-state disabled -text label 
    vTcl:DefineAlias "$top.cpd130" "Label700_3" vTcl:WidgetProc "Toplevel700" 1
    button $top.cpd126 \
		-activebackground #ffffff -background #ffffff \
		-command {global TMPDir 
global OpenDirFile VarError ErrorMessage

if {$OpenDirFile == 0} {

set ffb [open "$TMPDir/BatchFile.bat" w]
BatchWriteConfigInit $ffb

set ffr [open "$TMPDir/BatchReadFile.txt" r]
set fff [open "$TMPDir/BatchSpeckleFilterFile.txt" r]
set ffp2 [open "$TMPDir/BatchProcessFileC2.txt" r]
set ffp3 [open "$TMPDir/BatchProcessFileT3.txt" r]

gets $ffr NDataDirBatch
for {set ii 1} {$ii <= $NDataDirBatch} {incr ii} {
    gets $ffr BatchFormat
    if {$BatchFormat != "Sensor"} {
        gets $ffr BatchDataDirInput
        gets $ffr BatchNligFullSize
        gets $ffr BatchNcolFullSize
        gets $ffr BatchPolarCase
        gets $ffr BatchPolarType
        BatchWriteConfigDir $ffb $ii $BatchDataDirInput $BatchNligFullSize $BatchNcolFullSize

        set BatchDataDirOutput $BatchDataDirInput

        gets $fff BatchFilter
        if {$BatchFilter != "none"} {
            if {$BatchFilter == "boxcar" } {
                append BatchDataDirOutput "_GSS"
                }
            if {$BatchFilter == "gauss" } {
                append BatchDataDirOutput "_GSS"
                }
            if {$BatchFilter == "idan" } {
                append BatchDataDirOutput "_IDAN"
                }
            if {$BatchFilter == "lee" } {
                append BatchDataDirOutput "_LEE"
                }
            if {$BatchFilter == "anyang" } {
                append BatchDataDirOutput "_PRE"
                }
            if {$BatchFilter == "lopez" } {
                append BatchDataDirOutput "_LOP"
                }
            if {$BatchFilter == "sigma" } {
                append BatchDataDirOutput "_SIG"
                }
            if {$BatchFilter == "nonlocalmeans" } {
                append BatchDataDirOutput "_NL"
                }
            if {$BatchFilter == "meanshift" } {
                append BatchDataDirOutput "_GMS"
                }
            BatchWriteFilter $ffb $fff $BatchFilter $BatchDataDirOutput $BatchFormat
            }

        set BatchDataDirInput $BatchDataDirOutput

        if {$BatchFormat == "C2"} {
            BatchWriteProcessC2 $ffb $ffp2 $BatchDataDirOutput $BatchFormat
            }
        if {$BatchFormat == "T3"} {
            BatchWriteProcessT3 $ffb $ffp3 $BatchDataDirOutput $BatchFormat
            }
        } else {
        gets $ffr $DataDirBatchSensor($ii)            
        gets $ffr $DataDirBatch($ii)            
        gets $ffr $DataDirBatchSensorFormat($ii)
        }
    }
close $ffb
close $ffr
close $fff
close $ffp2
close $ffp3

##### execution du batch file
#set taskIdBatch [ open "| \x22$TMPDir/BatchFile.bat\x22" r]

}} \
		-image [vTcl:image:get_image [file join . GUI Images PSPImgBatchRunOn.gif]] \
		-pady 0 -relief flat -state disabled -text button 
    vTcl:DefineAlias "$top.cpd126" "Button700_4" vTcl:WidgetProc "Toplevel700" 1
    frame $top.fra71 \
		-borderwidth 2 -background #ffffff -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame1" vTcl:WidgetProc "Toplevel700" 1
    set site_3_0 $top.fra71
    button $site_3_0.cpd73 \
		-background #ffff00 \
		-command {global Load_PSPBatchBatShRead Load_PSPBatchBatShSpeckleFilter Load_PSPBatchBatShProcess

$widget(Label700_1) configure -state disable
$widget(Button700_2) configure -state disable
$widget(Label700_2) configure -state disable
$widget(Button700_3) configure -state disable
$widget(Label700_3) configure -state disable
$widget(Button700_4) configure -state disable

if {$Load_PSPBatchBatShRead == 1} {
    Window hide $widget(Toplevel701); TextEditorRunTrace "Close Window PolSARpro-Bio Batch : Read Menu" "b"
    }
if {$Load_PSPBatchBatShSpeckleFilter == 1} {
    Window hide $widget(Toplevel702); TextEditorRunTrace "Close Window PolSARpro-Bio Batch : Speckle Filter Menu" "b"
    }
if {$Load_PSPBatchBatShProcess == 1} {
    Window hide $widget(Toplevel703); TextEditorRunTrace "Close Window PolSARpro-Bio Batch : Process Menu" "b"
    }} \
		-padx 2 -pady 0 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd73" "Button3" vTcl:WidgetProc "Toplevel700" 1
    button $site_3_0.cpd74 \
		-background #ffff00 \
		-command {Window hide $widget(Toplevel700); TextEditorRunTrace "Close Window PolSARpro-Bio Batch : Main Menu" "b"} \
		-padx 2 -pady 0 -text Exit 
    vTcl:DefineAlias "$site_3_0.cpd74" "Button4" vTcl:WidgetProc "Toplevel700" 1
    pack $site_3_0.cpd73 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab67 \
		-in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.cpd125 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd128 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.but69 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd129 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd127 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd130 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd126 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra71 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}

Window show .
Window show .top700

main $argc $argv
