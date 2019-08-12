#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    # Provoke name search
    catch {package require bogus-package-name}
    set packageNames [package names]

    package require BWidget
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *ScrolledWindow.size 14
	}
    }
    
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
# Visual Tcl v1.60 Project
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
        .gif    {return photo}
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

        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images CloseFile.gif]} {user image} user {}}
        {{[file join . GUI Images GIMPshortcut.gif]} {user image} user {}}

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
    set base .top247
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
    namespace eval ::widgets::$site_4_0.fra98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra98
    namespace eval ::widgets::$site_5_0.but101 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.but102 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.but103 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.che104 {
        array set save {-_tooltip 1 -command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra99 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra99
    namespace eval ::widgets::$site_5_0.scr106 {
        array set save {-command 1 -orient 1}
    }
    namespace eval ::widgets::$site_5_0.scr107 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_5_0.tex108 {
        array set save {-background 1 -height 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd78
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra83
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.fra87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra87
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd68
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_7_0.but69 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.fra73 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra73
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-text 1}
    }
    set site_9_0 [$site_7_0.cpd74 getframe]
    namespace eval ::widgets::$site_9_0 {
        array set save {}
    }
    set site_9_0 $site_9_0
    namespace eval ::widgets::$site_9_0.com72 {
        array set save {-editable 1 -entrybg 1 -justify 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-text 1}
    }
    set site_9_0 [$site_7_0.cpd75 getframe]
    namespace eval ::widgets::$site_9_0 {
        array set save {}
    }
    set site_9_0 $site_9_0
    namespace eval ::widgets::$site_9_0.com72 {
        array set save {-editable 1 -entrybg 1 -justify 1 -takefocus 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.fra93 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra93
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-text 1}
    }
    set site_9_0 [$site_7_0.cpd96 getframe]
    namespace eval ::widgets::$site_9_0 {
        array set save {}
    }
    set site_9_0 $site_9_0
    namespace eval ::widgets::$site_9_0.cpd76 {
        array set save {-editable 1 -entrybg 1 -justify 1 -takefocus 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m71 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top247
            ClearStatBmp
            PlotStat1D
            PlotStatInit
            PlotStatClose
            PlotStatRAZ
            PlotStat1DThumb
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

proc ::main {argc argv} {
## This will clean up and call exit properly on Windows.
#vTcl:WindowsCleanup
}
#############################################################################
## Procedure:  ClearStatBmp

proc ::ClearStatBmp {} {
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint
global VarStatSave TMPStatisticsTxt TMPStatisticsBin TMPStatResultsTxt

set VarStatSave "no"
$widget(Button247_1) configure -state disable
$widget(Button247_3) configure -state disable
$widget(Button247_4) configure -state disable
$widget(Button247_5) configure -state disable
$widget(Button247_6) configure -state disable
$widget(Button247_7) configure -state disable
$widget(Checkbutton247_1) configure -state disable
$widget(TitleFrame247_1) configure -state disable
$widget(Combobox247_1) configure -state disabled
$widget(TitleFrame247_2) configure -state disable
$widget(Combobox247_2) configure -state disabled
$widget(TitleFrame247_3) configure -state disable
$widget(Combobox247_3) configure -state disabled

DeleteFile $TMPStatisticsTxt
DeleteFile $TMPStatisticsBin
DeleteFile $TMPStatResultsTxt

for {set i 0} {$i <= 2} {incr i} {
    set NTrainingArea($i) ""
    for {set j 0} {$j <= 2} {incr j} {
        set Argument [expr (100*$i + $j)]
        set AreaPoint($Argument) ""
        for {set k 0} {$k <= 17} {incr k} {
            set Argument [expr (10000*$i + 100*$j + $k)]
            set AreaPointLig($Argument) ""
            set AreaPointCol($Argument) ""
            }
        }
    }           

set AreaClassN 1
set NTrainingAreaClass 1
set AreaN 1
set NTrainingArea(1) 1
}
#############################################################################
## Procedure:  PlotStat1D

proc ::PlotStat1D {} {
global TMPStatHistoTxt
global GnuplotPipeFid GnuplotPipeStat GnuOutputFormat GnuOutputFile
global GnuStatHistoLabel GnuStatHistoId
global GnuStatPdfNum GnuStatPdfLabel GnuStatPdfId GnuStatPdfFlag
global GnuStatHistoIdLabel GnuStatHistoIdData
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top247]; set ywindow [winfo y .top247]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk


if {$GnuplotPipeStat == ""} {
    GnuPlotInit 0 0 1 1
    set GnuplotPipeStat $GnuplotPipeFid
    }
    
#PlotStat1DThumb

set GnuOutputFile $TMPGnuPlotTk1
set GnuOutputFormat "gif"
GnuPlotTerm $GnuplotPipeStat $GnuOutputFormat
    
puts $GnuplotPipeStat "set autoscale"; flush $GnuplotPipeStat
puts $GnuplotPipeStat "set xlabel 'Value'"; flush $GnuplotPipeStat
puts $GnuplotPipeStat "set ylabel 'Nb of Samples'"; flush $GnuplotPipeStat
puts $GnuplotPipeStat "set title '$GnuStatHistoLabel($GnuStatHistoIdLabel)' textcolor lt 3"; flush $GnuplotPipeStat

set xi $GnuStatHistoIdData
set yi [expr $xi + 1]
if {$GnuStatPdfFlag == 0} {
    puts $GnuplotPipeStat "plot '$TMPStatHistoTxt' using $xi:$yi title '$GnuStatHistoLabel($GnuStatHistoIdLabel)' with boxes"; flush $GnuplotPipeStat
    } else {
    if {$GnuStatPdfId != [expr $GnuStatPdfNum - 1] } {
        set yii [expr $xi + $GnuStatPdfId + 2]
        puts $GnuplotPipeStat "plot '$TMPStatHistoTxt' using $xi:$yii title 'Theoretical PDF : $GnuStatPdfLabel($GnuStatPdfId)' with lines, '$TMPStatHistoTxt' using $xi:$yi title '$GnuStatHistoLabel($GnuStatHistoIdLabel)' with boxes"; flush $GnuplotPipeStat
        } else {
        set yii $yi;
        set GnuCommand "plot '$TMPStatHistoTxt' using $xi:$yi title '$GnuStatHistoLabel($GnuStatHistoIdLabel)' with boxes"
        for {set i 0} {$i < [expr $GnuStatPdfNum - 1]} {incr i} {
            incr yii; 
            append GnuCommand ", '$TMPStatHistoTxt' using $xi:$yii title 'Theoretical PDF : $GnuStatPdfLabel($i)' with lines"
            }
        puts $GnuplotPipeStat "$GnuCommand"; flush $GnuplotPipeStat
        }
    }
puts $GnuplotPipeStat "unset output"; flush $GnuplotPipeStat 

set ErrorCatch [catch {puts $GnuplotPipeStat "quit"}]
if { $ErrorCatch == "0" } {
    puts $GnuplotPipeStat "quit"; flush $GnuplotPipeStat 
    }  
catch "close $GnuplotPipeStat"
set GnuplotPipeStat ""

WaitUntilCreated $TMPGnuPlotTk1
Gimp $TMPGnuPlotTk1
#ViewGnuPlotTKThumb 1 .top247 "Statistics"
}
#############################################################################
## Procedure:  PlotStatInit

proc ::PlotStatInit {} {
global TMPStatLabelTxt GnuStatType
global GnuStatHistoNum GnuStatHistoLabel GnuStatHisto GnuStatHistoId
global GnuStatChannelNum GnuStatChannelLabel GnuStatChannel GnuStatChannelId
global GnuStatElementNum GnuStatElementLabel GnuStatElement GnuStatElementId
global GnuStatPdfNum GnuStatPdfLabel GnuStatPdf GnuStatPdfId GnuStatPdfFirstTime

WaitUntilCreated $TMPStatLabelTxt 
if [file exists $TMPStatLabelTxt] {
    set f [open $TMPStatLabelTxt r]
    gets $f GnuStatHistoNum;
    for {set i 0} {$i < $GnuStatHistoNum} {incr i} {gets $f GnuStatHistoLabel($i)}
    close $f
    #Channel
    if {$GnuStatType == "S2"} {
        set GnuStatChannel "4"; 
        set GnuStatChannelLabel(0) "S11"; set GnuStatChannelLabel(1) "S12"
        set GnuStatChannelLabel(2) "S21"; set GnuStatChannelLabel(3) "S22"
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "S11" "S12" "S21" "S22"}    
        }
    if {$GnuStatType == "SPP1"} {
        set GnuStatChannel "2"; 
        set GnuStatChannelLabel(0) "S11"; set GnuStatChannelLabel(1) "S21"
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "S11" "S21"}    
        }
    if {$GnuStatType == "SPP2"} {
        set GnuStatChannel "2"; 
        set GnuStatChannelLabel(0) "S12"; set GnuStatChannelLabel(1) "S22"
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "S12" "S22"}    
        }
    if {$GnuStatType == "SPP3"} {
        set GnuStatChannel "2"; 
        set GnuStatChannelLabel(0) "S11"; set GnuStatChannelLabel(1) "S22"
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "S11" "S22"}    
        }
    if {$GnuStatType == "C2"} {
        set GnuStatChannel "4"; 
        set GnuStatChannelLabel(0) "C11"; set GnuStatChannelLabel(1) "C12"; set GnuStatChannelLabel(2) "C22"
        set GnuStatChannelLabel(3) "rhoC12"; 
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "C11" "C12" "C22" "rhoC12"}    
        }
    if {$GnuStatType == "T3"} {
        set GnuStatChannel "9"; 
        set GnuStatChannelLabel(0) "T11"; set GnuStatChannelLabel(1) "T12"; set GnuStatChannelLabel(2) "T13"
        set GnuStatChannelLabel(3) "T22"; set GnuStatChannelLabel(4) "T23"; set GnuStatChannelLabel(5) "T33"
        set GnuStatChannelLabel(6) "rhoT12"; set GnuStatChannelLabel(7) "rhoT13"; set GnuStatChannelLabel(8) "rhoT23"
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "T11" "T12" "T13" "T22" "T23" "T33" "rhoT12" "rhoT13" "rhoT23"}    
        }
    if {$GnuStatType == "C3"} {
        set GnuStatChannel "9"; 
        set GnuStatChannelLabel(0) "C11"; set GnuStatChannelLabel(1) "C12"; set GnuStatChannelLabel(2) "C13"
        set GnuStatChannelLabel(3) "C22"; set GnuStatChannelLabel(4) "C23"; set GnuStatChannelLabel(5) "C33"
        set GnuStatChannelLabel(6) "rhoC12"; set GnuStatChannelLabel(7) "rhoC13"; set GnuStatChannelLabel(8) "rhoC23"
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "C11" "C12" "C13" "C22" "C23" "C33" "rhoC12" "rhoC13" "rhoC23"}    
        }
    if {$GnuStatType == "T4"} {
        set GnuStatChannel "16"; 
        set GnuStatChannelLabel(0) "T11"; set GnuStatChannelLabel(1) "T12"; set GnuStatChannelLabel(2) "T13"
        set GnuStatChannelLabel(3) "T14"; set GnuStatChannelLabel(4) "T22"; set GnuStatChannelLabel(5) "T23"
        set GnuStatChannelLabel(6) "T24"; set GnuStatChannelLabel(7) "T33"; set GnuStatChannelLabel(8) "T34"
        set GnuStatChannelLabel(9) "T44" 
        set GnuStatChannelLabel(10) "rhoT12"; set GnuStatChannelLabel(11) "rhoT13"; set GnuStatChannelLabel(12) "rhoT14"
        set GnuStatChannelLabel(13) "rhoT23"; set GnuStatChannelLabel(14) "rhoT24"; set GnuStatChannelLabel(15) "rhoT34"
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "T11" "T12" "T13" "T14" "T22" "T23" "T24" "T33" "T34" "T44" "rhoT12" "rhoT13" "rhoT14" "rhoT23" "rhoT24" "rhoT34"}    
        }
    if {$GnuStatType == "C4"} {
        set GnuStatChannel "16"; 
        set GnuStatChannelLabel(0) "C11"; set GnuStatChannelLabel(1) "C12"; set GnuStatChannelLabel(2) "C13"
        set GnuStatChannelLabel(3) "C14"; set GnuStatChannelLabel(4) "C22"; set GnuStatChannelLabel(5) "C23"
        set GnuStatChannelLabel(6) "C24"; set GnuStatChannelLabel(7) "C33"; set GnuStatChannelLabel(8) "C34"
        set GnuStatChannelLabel(9) "C44" 
        set GnuStatChannelLabel(10) "rhoC12"; set GnuStatChannelLabel(11) "rhoC13"; set GnuStatChannelLabel(12) "rhoC14"
        set GnuStatChannelLabel(13) "rhoC23"; set GnuStatChannelLabel(14) "rhoC24"; set GnuStatChannelLabel(15) "rhoC34"
        .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -values { "C11" "C12" "C13" "C14" "C22" "C23" "C24" "C33" "C34" "C44" "rhoC12" "rhoC13" "rhoC14" "rhoC23" "rhoC24" "rhoC34"}    
        }
    set GnuStatChannel $GnuStatChannelLabel(0); set GnuStatChannelId "0"
    #Elements
    set GnuStatElementNum "4"
    set GnuStatElementLabel(0) "Real Part"; set GnuStatElementLabel(1) "Imaginary Part"
    set GnuStatElementLabel(2) "Amplitude"; set GnuStatElementLabel(3) "Phase"
    .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd75.f.com72 configure -values { "Real Part" "Imaginary Part" "Amplitude" "Phase" }    
    set GnuStatElement $GnuStatElementLabel(0); set GnuStatElementId "0"
    #PDF    
    set GnuStatPdfNum "5"; set GnuStatPdf ""; set GnuStatPdfId "0"; set GnuStatPdfFirstTime 0
    set GnuStatPdfLabel(0) "Gaussian"; set GnuStatPdfLabel(1) "Exponential"
    set GnuStatPdfLabel(2) "Rayleigh"; set GnuStatPdfLabel(3) "Uniform"
    set GnuStatPdfLabel(4) "All PDF"
    .top247.fra71.cpd78.cpd72.cpd77.fra93.cpd96.f.cpd76 configure -values { "Gaussian" "Exponential" "Rayleigh" "Uniform" "All PDF"}    
    } else {
    PlotStatClose
    .top247.fra71.cpd78.cpd72.fra87.cpd88 configure -state disable
    .top247.fra71.cpd78.cpd72.fra87.cpd68.cpd80 configure -state disable
    .top247.fra71.cpd78.cpd72.fra87.cpd81 configure -state disable
    .top247.fra71.cpd78.cpd72.fra87.cpd68.but69 configure -state disable
    .top247.fra71.cpd78.cpd72.cpd77.fra93.cpd94 configure -state disable
    .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74 configure -state disable
    .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 configure -state disabled
    .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd75 configure -state disable
    .top247.fra71.cpd78.cpd72.cpd77.fra73.cpd75.f.com72 configure -state disabled
    .top247.fra71.cpd78.cpd72.cpd77.fra93.cpd96 configure -state disable
    .top247.fra71.cpd78.cpd72.cpd77.fra93.cpd96.f.cpd76 configure -state disabled
    }

    
}
#############################################################################
## Procedure:  PlotStatClose

proc ::PlotStatClose {} {
global GnuplotPipeFid GnuplotPipeStat

if {$GnuplotPipeStat != ""} {
    catch "close $GnuplotPipeStat"
    set GnuplotPipeStat ""
    }
set GnuplotPipeFid ""
Window hide .top401; 
}
#############################################################################
## Procedure:  PlotStatRAZ

proc ::PlotStatRAZ {} {
global GnuStatHistoNum GnuStatHistoLabel GnuStatHisto GnuStatHistoId
global GnuStatChannelNum GnuStatChannelLabel GnuStatChannel GnuStatChannelId
global GnuStatElementNum GnuStatElementLabel GnuStatElement GnuStatElementId
global GnuStatPdfNum GnuStatPdfLabel GnuStatPdf GnuStatPdfId
global GnuStatPdfFlag

set GnuStatHistoNum "0"; set GnuStatHisto ""; set GnuStatHistoId "0"; set GnuStatHistoLabel(0) ""
set GnuStatChannelNum "0"; set GnuStatChannel ""; set GnuStatChannelId "0"; set GnuStatChannelLabel(0) ""
set GnuStatElementNum "0"; set GnuStatElement ""; set GnuStatElementId "0"; set GnuStatElementLabel(0) ""
set GnuStatPdfNum "0"; set GnuStatPdf ""; set GnuStatPdfId "0"; set GnuStatPdfLabel(0) ""
set GnuStatPdfFlag "0"
}
#############################################################################
## Procedure:  PlotStat1DThumb

proc ::PlotStat1DThumb {} {
global TMPStatHistoTxt
global GnuplotPipeFid GnuplotPipeStat GnuOutputFormat GnuOutputFile
global GnuStatHistoLabel GnuStatHistoId
global GnuStatPdfNum GnuStatPdfLabel GnuStatPdfId GnuStatPdfFlag
global GnuStatHistoIdLabel GnuStatHistoIdData
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top247]; set ywindow [winfo y .top247]

DeleteFile $TMPGnuPlot1Tk

set GnuOutputFile $TMPGnuPlot1Tk
set GnuOutputFormat "png"
GnuPlotTerm $GnuplotPipeStat $GnuOutputFormat
    
puts $GnuplotPipeStat "set autoscale"; flush $GnuplotPipeStat
puts $GnuplotPipeStat "set xlabel 'Value'"; flush $GnuplotPipeStat
puts $GnuplotPipeStat "set ylabel 'Nb of Samples'"; flush $GnuplotPipeStat
puts $GnuplotPipeStat "set title '$GnuStatHistoLabel($GnuStatHistoIdLabel)' textcolor lt 3"; flush $GnuplotPipeStat

set xi $GnuStatHistoIdData
set yi [expr $xi + 1]
if {$GnuStatPdfFlag == 0} {
    puts $GnuplotPipeStat "plot '$TMPStatHistoTxt' using $xi:$yi title '$GnuStatHistoLabel($GnuStatHistoIdLabel)' with boxes"; flush $GnuplotPipeStat
    } else {
    if {$GnuStatPdfId != [expr $GnuStatPdfNum - 1] } {
        set yii [expr $xi + $GnuStatPdfId + 2]
        puts $GnuplotPipeStat "plot '$TMPStatHistoTxt' using $xi:$yii title 'Theoretical PDF : $GnuStatPdfLabel($GnuStatPdfId)' with lines, '$TMPStatHistoTxt' using $xi:$yi title '$GnuStatHistoLabel($GnuStatHistoIdLabel)' with boxes"; flush $GnuplotPipeStat
        } else {
        set yii $yi;
        set GnuCommand "plot '$TMPStatHistoTxt' using $xi:$yi title '$GnuStatHistoLabel($GnuStatHistoIdLabel)' with boxes"
        for {set i 0} {$i < [expr $GnuStatPdfNum - 1]} {incr i} {
            incr yii; 
            append GnuCommand ", '$TMPStatHistoTxt' using $xi:$yii title 'Theoretical PDF : $GnuStatPdfLabel($i)' with lines"
            }
        puts $GnuplotPipeStat "$GnuCommand"; flush $GnuplotPipeStat
        }
    }
puts $GnuplotPipeStat "unset output"; flush $GnuplotPipeStat 

WaitUntilCreated $TMPGnuPlot1Tk
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {
global tk_strictMotif MouseInitX MouseInitY MouseEndX MouseEndY BMPMouseX BMPMouseY

catch {package require unsafe}
set tk_strictMotif 1
global TrainingAreaTool; 
global x;
global y;

set TrainingAreaTool rect
}

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
    wm geometry $top 200x200+150+150; update
    wm maxsize $top 3364 1032
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top247 {base} {
    if {$base == ""} {
        set base .top247
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m71" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x400+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Analysis : Statistics"
    vTcl:DefineAlias "$top" "Toplevel247" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel247" 1
    set site_3_0 $top.fra71
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel247" 1
    set site_4_0 $site_3_0.fra72
    frame $site_4_0.fra98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra98" "Frame5" vTcl:WidgetProc "Toplevel247" 1
    set site_5_0 $site_4_0.fra98
    button $site_5_0.but101 \
        \
        -command {global TextFile FileName OpenDirFile StatDirInput

if {$OpenDirFile == 0} {

set TextFileTypes {
    {{Text} {.txt}}
    {{Text} {.asc}}
    {{All}  {*}}
    }
set FileName ""
OpenFile $StatDirInput $TextFileTypes "INPUT TXT FILE"
set TextFile $FileName

if {$TextFile != ""} {
    set OpenTextFile [open $TextFile r]
    set ReadTextFile [read $OpenTextFile]
    $widget(TextStat) delete 1.0 end
    $widget(TextStat) insert end $ReadTextFile
    $widget(TextStat) configure -wrap none
    close $OpenTextFile
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but101" "Button1" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_5_0.but101 "$site_5_0.but101 Button $top all _vTclBalloon"
    bind $site_5_0.but101 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Text File}
    }
    button $site_5_0.but102 \
        \
        -command {global TextFile OpenDirFile StatDirInput

if {$OpenDirFile == 0} {

set TextFileTypes {
    {{Text} {.txt}}
    {{Text} {.asc}}
    {{All}  {*}}
    }
set TextFile ""
set TextFile [tk_getSaveFile -initialdir $StatDirInput -filetypes $TextFileTypes -title "TXT OUTPUT FILE" -defaultextension .txt -initialfile "statistics"]
if {$TextFile != ""} {
    set opentext [open $TextFile w]
    set savetext [$widget(TextStat) get 1.0 end]
    puts $opentext $savetext
    close $opentext
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but102" "Button2" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_5_0.but102 "$site_5_0.but102 Button $top all _vTclBalloon"
    bind $site_5_0.but102 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save Text File}
    }
    button $site_5_0.but103 \
        \
        -command {global TextFile OpenDirFile

if {$OpenDirFile == 0} {
    $widget(TextStat) delete 1.0 end
    }} \
        -image [vTcl:image:get_image [file join . GUI Images CloseFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but103" "Button3" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_5_0.but103 "$site_5_0.but103 Button $top all _vTclBalloon"
    bind $site_5_0.but103 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Close Text File}
    }
    checkbutton $site_5_0.che104 \
        \
        -command {if {$WrapVar == 1} {$widget(TextStat) configure -wrap word}
if {$WrapVar == 0} {$widget(TextStat) configure -wrap none}} \
        -text {Wrap Text Mode} -variable WrapVar 
    vTcl:DefineAlias "$site_5_0.che104" "Checkbutton1" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_5_0.che104 "$site_5_0.che104 Checkbutton $top all _vTclBalloon"
    bind $site_5_0.che104 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Wrap Text Mode}
    }
    pack $site_5_0.but101 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but102 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but103 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che104 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra99 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra99" "Frame7" vTcl:WidgetProc "Toplevel247" 1
    set site_5_0 $site_4_0.fra99
    scrollbar $site_5_0.scr106 \
        -command "$site_5_0.tex108 xview" -orient horizontal 
    vTcl:DefineAlias "$site_5_0.scr106" "Scrollbar1" vTcl:WidgetProc "Toplevel247" 1
    scrollbar $site_5_0.scr107 \
        -command "$site_5_0.tex108 yview" 
    vTcl:DefineAlias "$site_5_0.scr107" "Scrollbar2" vTcl:WidgetProc "Toplevel247" 1
    text $site_5_0.tex108 \
        -background white -height 15 -width 50 \
        -xscrollcommand "$site_5_0.scr106 set" \
        -yscrollcommand "$site_5_0.scr107 set" 
    vTcl:DefineAlias "$site_5_0.tex108" "TextStat" vTcl:WidgetProc "Toplevel247" 1
    pack $site_5_0.scr106 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_5_0.scr107 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.tex108 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.fra98 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.fra99 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel247" 1
    set site_4_0 $site_3_0.cpd78
    frame $site_4_0.cpd71 \
        -borderwidth 2 -relief sunken -height 75 -width 120 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame6" vTcl:WidgetProc "Toplevel247" 1
    set site_5_0 $site_4_0.cpd71
    frame $site_5_0.fra83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra83" "Frame2" vTcl:WidgetProc "Toplevel247" 1
    set site_6_0 $site_5_0.fra83
    button $site_6_0.cpd84 \
        -background #ffff00 \
        -command {global TMPStatisticsTxt VarStatSave
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint
global VarStatSave TMPStatisticsTxt TMPStatisticsBin TMPStatResultsTxt

set VarStatSave "no"
$widget(Button247_1) configure -state disable
$widget(Button247_3) configure -state disable
$widget(Button247_4) configure -state disable
$widget(Button247_5) configure -state disable
$widget(Button247_6) configure -state disable
$widget(Button247_7) configure -state disable
$widget(Checkbutton247_1) configure -state disable
$widget(TitleFrame247_1) configure -state disable
$widget(Combobox247_1) configure -state disabled
$widget(TitleFrame247_2) configure -state disable
$widget(Combobox247_2) configure -state disabled
$widget(TitleFrame247_3) configure -state disable
$widget(Combobox247_3) configure -state disabled

DeleteFile $TMPStatisticsTxt
DeleteFile $TMPStatisticsBin
DeleteFile $TMPStatResultsTxt

for {set i 0} {$i <= 2} {incr i} {
    set NTrainingArea($i) ""
    for {set j 0} {$j <= 2} {incr j} {
        set Argument [expr (100*$i + $j)]
        set AreaPoint($Argument) ""
        for {set k 0} {$k <= 17} {incr k} {
            set Argument [expr (10000*$i + 100*$j + $k)]
            set AreaPointLig($Argument) ""
            set AreaPointCol($Argument) ""
            }
        }
    }           

set AreaClassN 1
set NTrainingAreaClass 1
set AreaN 1
set NTrainingArea(1) 1

PlotStatRAZ
PlotStatClose
$widget(TextStat) delete 1.0 end

set VarStatSave "no"
WaitUntilCreated $TMPStatisticsTxt
if [file exists $TMPStatisticsTxt] {
    set VarStatSave "ok"
    $widget(Button247_1) configure -state normal
    $widget(Button247_3) configure -state normal
    $widget(Button247_4) configure -state disable
    $widget(Button247_5) configure -state disable
    $widget(Button247_6) configure -state disable
    $widget(Button247_7) configure -state disable
    $widget(Checkbutton247_1) configure -state disable
    $widget(TitleFrame247_1) configure -state disable
    $widget(TitleFrame247_2) configure -state disable    
    }
tkwait variable VarStatSave} \
        -padx 4 -pady 2 -text Clear 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button247_1" vTcl:WidgetProc "Toplevel247" 1
    button $site_6_0.cpd86 \
        -background #ffff00 \
        -command {global StatDirInput VarStatSave StatExecFid StatFunction
global TMPStatisticsBin TMPStatResultsTxt TMPStatLabelTxt TMPStatHistoTxt TextFile
global VarError ErrorMessage OpenDirFile

if {$OpenDirFile == 0} {

if {$VarStatSave == "ok"} {
    if [file exists $TMPStatisticsTxt] {
        DeleteFile $TMPStatisticsBin
        DeleteFile $TMPStatResultsTxt
        DeleteFile $TMPStatHistoTxt
        DeleteFile $TMPStatLabelTxt
        set ProgressLine ""
        puts $StatExecFid "stat\n"
        flush $StatExecFid
        fconfigure $StatExecFid -buffering line
        while {$ProgressLine != "OKstat"} {
            gets $StatExecFid ProgressLine
            update
            }
        set ProgressLine ""
        if [file exists $TMPStatisticsBin] {
            TextEditorRunTrace "Process The Function $StatFunction" "k"
            TextEditorRunTrace "Arguments: \x22$TMPStatisticsBin\x22 \x22$TMPStatResultsTxt\x22 \x22$TMPStatHistoTxt\x22 \x22$TMPStatLabelTxt\x22" "k"
            set f [ open "| $StatFunction \x22$TMPStatisticsBin\x22 \x22$TMPStatResultsTxt\x22 \x22$TMPStatHistoTxt\x22 \x22$TMPStatLabelTxt\x22" r]
            catch "close $f"
            if [file exists $TMPStatResultsTxt] {
                set TextFile $TMPStatResultsTxt
                set OpenTextFile [open $TextFile r]
                set ReadTextFile [read $OpenTextFile]
                $widget(TextStat) delete 1.0 end
                $widget(TextStat) insert end $ReadTextFile
                $widget(TextStat) configure -wrap word
                close $OpenTextFile
                }
            }
        }
    #MouseActiveFunction ""
    $widget(Button247_3) configure -state disable
    $widget(Button247_4) configure -state normal
    $widget(Button247_6) configure -state normal
    $widget(Checkbutton247_1) configure -state normal
    $widget(TitleFrame247_1) configure -state normal
    $widget(Combobox247_1) configure -state normal
    $widget(TitleFrame247_2) configure -state normal
    $widget(Combobox247_2) configure -state normal
    $widget(TitleFrame247_3) configure -state disable
    $widget(Combobox247_3) configure -state disabled
    PlotStatInit
    } else {
    set ErrorMessage "AREA MUST BE DEFINED AND SAVED FIRST BEFORE RUNNING STATISTICS PROCESS" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button247_3" vTcl:WidgetProc "Toplevel247" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra83 \
        -in $site_5_0 -anchor center -expand 1 -fill y -padx 10 -side left 
    frame $site_4_0.cpd72 \
        -borderwidth 2 -relief sunken -height 75 -width 150 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame10" vTcl:WidgetProc "Toplevel247" 1
    set site_5_0 $site_4_0.cpd72
    frame $site_5_0.fra87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra87" "Frame11" vTcl:WidgetProc "Toplevel247" 1
    set site_6_0 $site_5_0.fra87
    button $site_6_0.cpd88 \
        -background #ffff00 \
        -command {global GnuStatType GnuStatHistoId GnuStatChannelId GnuStatChannelNum 
global GnuStatElementId GnuStatElementNum GnuStatElementLabel GnuStatElement
global GnuStatPdf GnuStatPdfId GnuStatPdfFlag
global GnuStatHistoIdLabel GnuStatHistoIdData

set GnuStatChannelId [.top247.fra71.cpd78.cpd72.cpd77.fra73.cpd74.f.com72 getvalue]
set GnuStatElementId [.top247.fra71.cpd78.cpd72.cpd77.fra73.cpd75.f.com72 getvalue]
if {$GnuStatPdfFlag == 1} {
    set GnuStatPdfId [.top247.fra71.cpd78.cpd72.cpd77.fra93.cpd96.f.cpd76 getvalue]
    } else {
    set GnuStatPdfId "0"
    }

set config "true"
if {$GnuStatChannelId == "-1"} {set config "false"}
if {$GnuStatElementId == "-1"} {set config "false"}

if {$config == "true"} {

set config234 0;
if {$GnuStatType == "S2"} {set config234 2}
if {$GnuStatType == "SPP1"} {set config234 2}
if {$GnuStatType == "SPP2"} {set config234 2}
if {$GnuStatType == "SPP3"} {set config234 2}
if {$GnuStatType == "T3"} {set config234 3}
if {$GnuStatType == "C3"} {set config234 3}
if {$GnuStatType == "T4"} {set config234 4}
if {$GnuStatType == "C4"} {set config234 4}
if {$GnuStatType == "C2"} {set config234 5}

if {$config234 == 2} {
    set GnuStatHistoId [expr $GnuStatChannelId * $GnuStatElementNum + $GnuStatElementId]
    set GnuStatHistoIdLabel [expr 5 * $GnuStatHistoId]
    if {$GnuStatPdfFlag == 1} {
        if {$GnuStatPdfId != [expr $GnuStatPdfNum - 1] } {set GnuStatHistoIdLabel [expr $GnuStatHistoIdLabel + $GnuStatPdfId + 1]} 
        }
    set GnuStatHistoIdData [expr 6 * $GnuStatHistoId + 1]
    }
    
if {$config234 == 3} {
    if {$GnuStatChannelId < 6} {
        if {$GnuStatChannelId == 0} {set GnuStatHistoId 0; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        if {$GnuStatChannelId == 1} {set GnuStatHistoId [expr 1 + $GnuStatElementId]}
        if {$GnuStatChannelId == 2} {set GnuStatHistoId [expr 5 + $GnuStatElementId]}
        if {$GnuStatChannelId == 3} {set GnuStatHistoId 9; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        if {$GnuStatChannelId == 4} {set GnuStatHistoId [expr 10 + $GnuStatElementId]}
        if {$GnuStatChannelId == 5} {set GnuStatHistoId 14; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        set GnuStatHistoIdLabel [expr 5 * $GnuStatHistoId]
        if {$GnuStatPdfFlag == 1} {
            if {$GnuStatPdfId != [expr $GnuStatPdfNum - 1] } {set GnuStatHistoIdLabel [expr $GnuStatHistoIdLabel + $GnuStatPdfId + 1]} 
            }
        set GnuStatHistoIdData [expr 6 * $GnuStatHistoId + 1]
        } else {
        if {$GnuStatChannelId == 6} {set GnuStatHistoId [expr 15 + $GnuStatElementId]}
        if {$GnuStatChannelId == 7} {set GnuStatHistoId [expr 19 + $GnuStatElementId]}
        if {$GnuStatChannelId == 8} {set GnuStatHistoId [expr 23 + $GnuStatElementId]}
        set GnuStatHistoIdLabel [expr 15 * 5 + ($GnuStatHistoId - 15 )]
        set GnuStatHistoIdData [expr 15 * 6 + 2 * ($GnuStatHistoId -  15 ) + 1]
        $widget(TitleFrame247_3) configure -state disable; $widget(Combobox247_3) configure -state disabled
        set GnuStatPdf ""; set GnuStatPdfId "0"; set GnuStatPdfFlag 0
        }
    }

if {$config234 == 4} {
    if {$GnuStatChannelId < 10} {
        if {$GnuStatChannelId == 0} {set GnuStatHistoId 0; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        if {$GnuStatChannelId == 1} {set GnuStatHistoId [expr 1 + $GnuStatElementId]}
        if {$GnuStatChannelId == 2} {set GnuStatHistoId [expr 5 + $GnuStatElementId]}
        if {$GnuStatChannelId == 3} {set GnuStatHistoId [expr 9 + $GnuStatElementId]}
        if {$GnuStatChannelId == 4} {set GnuStatHistoId 13; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        if {$GnuStatChannelId == 5} {set GnuStatHistoId [expr 14 + $GnuStatElementId]}
        if {$GnuStatChannelId == 6} {set GnuStatHistoId [expr 18 + $GnuStatElementId]}
        if {$GnuStatChannelId == 7} {set GnuStatHistoId 22; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        if {$GnuStatChannelId == 8} {set GnuStatHistoId [expr 23 + $GnuStatElementId]}
        if {$GnuStatChannelId == 9} {set GnuStatHistoId 27; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        set GnuStatHistoIdLabel [expr 5 * $GnuStatHistoId]
        if {$GnuStatPdfFlag == 1} {
            if {$GnuStatPdfId != [expr $GnuStatPdfNum - 1] } {set GnuStatHistoIdLabel [expr $GnuStatHistoIdLabel + $GnuStatPdfId + 1]} 
            }
        set GnuStatHistoIdData [expr 6 * $GnuStatHistoId + 1]
        } else {
        if {$GnuStatChannelId == 10} {set GnuStatHistoId [expr 28 + $GnuStatElementId]}
        if {$GnuStatChannelId == 11} {set GnuStatHistoId [expr 32 + $GnuStatElementId]}
        if {$GnuStatChannelId == 12} {set GnuStatHistoId [expr 36 + $GnuStatElementId]}
        if {$GnuStatChannelId == 13} {set GnuStatHistoId [expr 40 + $GnuStatElementId]}
        if {$GnuStatChannelId == 14} {set GnuStatHistoId [expr 44 + $GnuStatElementId]}
        if {$GnuStatChannelId == 15} {set GnuStatHistoId [expr 48 + $GnuStatElementId]}
        set GnuStatHistoIdLabel [expr 28 * 5 + ($GnuStatHistoId - 28 )]
        set GnuStatHistoIdData [expr 28 * 6 + 2 * ($GnuStatHistoId -  28 ) + 1]
        $widget(TitleFrame247_3) configure -state disable; $widget(Combobox247_3) configure -state disabled
        set GnuStatPdf ""; set GnuStatPdfId "0"; set GnuStatPdfFlag 0
        }
    }

if {$config234 == 5} {
    if {$GnuStatChannelId < 3} {
        if {$GnuStatChannelId == 0} {set GnuStatHistoId 0; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        if {$GnuStatChannelId == 1} {set GnuStatHistoId [expr 1 + $GnuStatElementId]}
        if {$GnuStatChannelId == 2} {set GnuStatHistoId 5; set GnuStatElementId 0; set GnuStatElement $GnuStatElementLabel(2)}
        set GnuStatHistoIdLabel [expr 5 * $GnuStatHistoId]
        if {$GnuStatPdfFlag == 1} {
            if {$GnuStatPdfId != [expr $GnuStatPdfNum - 1] } {set GnuStatHistoIdLabel [expr $GnuStatHistoIdLabel + $GnuStatPdfId + 1]} 
            }
        set GnuStatHistoIdData [expr 6 * $GnuStatHistoId + 1]
        } else {
        if {$GnuStatChannelId == 3} {set GnuStatHistoId [expr 6 + $GnuStatElementId]}
        set GnuStatHistoIdLabel [expr 6 * 5 + ($GnuStatHistoId - 6 )]
        set GnuStatHistoIdData [expr 6 * 6 + 2 * ($GnuStatHistoId -  6 ) + 1]
        $widget(TitleFrame247_3) configure -state disable; $widget(Combobox247_3) configure -state disabled
        set GnuStatPdf ""; set GnuStatPdfId "0"; set GnuStatPdfFlag 0
        }
    }

PlotStat1D
$widget(Button247_5) configure -state normal
$widget(Button247_7) configure -state normal

}} \
        -padx 4 -pady 2 -text Histo 
    vTcl:DefineAlias "$site_6_0.cpd88" "Button247_4" vTcl:WidgetProc "Toplevel247" 1
    frame $site_6_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd68" "Frame15" vTcl:WidgetProc "Toplevel247" 1
    set site_7_0 $site_6_0.cpd68
    button $site_7_0.cpd80 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput StatDirOutput
global GnuplotPipeFid
global GnuStatChannel GnuStatElement GnuStatPdf GnuStatPdfFlag
global SaveDisplayOutputFile1

#BMP_PROCESS
global Load_SaveDisplay1 PSPTopLevel

if {$GnuplotPipeFid == ""} {
    set ErrorMessage "GNUPLOT IS NOT RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

    if {$Load_SaveDisplay1 == 0} {
        source "GUI/bmp_process/SaveDisplay1.tcl"
        set Load_SaveDisplay1 1
        WmTransient $widget(Toplevel456) $PSPTopLevel
        }

    set SaveDisplayDirOutput $StatDirOutput

    set SaveDisplayOutputFile1 "Statistics_"
    append SaveDisplayOutputFile1 "$GnuStatChannel"
    append SaveDisplayOutputFile1 "_$GnuStatElement"
    if {$GnuStatPdfFlag == 1} {append SaveDisplayOutputFile1 "_$GnuStatPdf" }
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel247) $widget(Toplevel456); TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_7_0.cpd80" "Button247_5" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_7_0.cpd80 "$site_7_0.cpd80 Button $top all _vTclBalloon"
    bind $site_7_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save}
    }
    button $site_7_0.but69 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1

Gimp $TMPGnuPlotTk1} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but69" "Button247_7" vTcl:WidgetProc "Toplevel247" 1
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 1 -fill none -ipady 1 -side left 
    pack $site_7_0.but69 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    button $site_6_0.cpd81 \
        -background #ffff00 \
        -command {PlotStatClose
$widget(Button247_5) configure -state disable
$widget(Button247_7) configure -state disable} \
        -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_6_0.cpd81" "Button247_6" vTcl:WidgetProc "Toplevel247" 1
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd68 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame1" vTcl:WidgetProc "Toplevel247" 1
    set site_6_0 $site_5_0.cpd77
    frame $site_6_0.fra73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra73" "Frame13" vTcl:WidgetProc "Toplevel247" 1
    set site_7_0 $site_6_0.fra73
    TitleFrame $site_7_0.cpd74 \
        -text Channel 
    vTcl:DefineAlias "$site_7_0.cpd74" "TitleFrame247_1" vTcl:WidgetProc "Toplevel247" 1
    bind $site_7_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_9_0 [$site_7_0.cpd74 getframe]
    ComboBox $site_9_0.com72 \
        -editable 0 -entrybg white -justify center -takefocus 1 \
        -textvariable GnuStatChannel -width 7 
    vTcl:DefineAlias "$site_9_0.com72" "Combobox247_1" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_9_0.com72 "$site_9_0.com72 BwComboBox $top all"
    pack $site_9_0.com72 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_7_0.cpd75 \
        -text Elements 
    vTcl:DefineAlias "$site_7_0.cpd75" "TitleFrame247_2" vTcl:WidgetProc "Toplevel247" 1
    bind $site_7_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_9_0 [$site_7_0.cpd75 getframe]
    ComboBox $site_9_0.com72 \
        -editable 0 -entrybg white -justify center -takefocus 1 \
        -textvariable GnuStatElement 
    vTcl:DefineAlias "$site_9_0.com72" "Combobox247_2" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_9_0.com72 "$site_9_0.com72 BwComboBox $top all"
    pack $site_9_0.com72 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    frame $site_7_0.cpd73 \
        -borderwidth 2 -height 23 -width 6 
    vTcl:DefineAlias "$site_7_0.cpd73" "Frame14" vTcl:WidgetProc "Toplevel247" 1
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side right 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.fra93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra93" "Frame12" vTcl:WidgetProc "Toplevel247" 1
    set site_7_0 $site_6_0.fra93
    checkbutton $site_7_0.cpd94 \
        \
        -command {global GnuStatPdfFlag GnuStatPdfLabel GnuStatPdfNum GnuStatPdf GnuStatPdfId GnuStatPdfFirstTime

if {$GnuStatPdfFlag == 1} {
    $widget(TitleFrame247_3) configure -state normal
    $widget(Combobox247_3) configure -state normal
    if {$GnuStatPdfFirstTime == 0} {
        set GnuStatPdfFirstTime 1
        }    
    set GnuStatPdfId "0"; set GnuStatPdf $GnuStatPdfLabel(0)
    }
if {$GnuStatPdfFlag == 0} {
    $widget(TitleFrame247_3) configure -state disable
    $widget(Combobox247_3) configure -state disabled
    set GnuStatPdf ""; set GnuStatPdfId "0"
    }} \
        -text {Theoretical PDF} -variable GnuStatPdfFlag 
    vTcl:DefineAlias "$site_7_0.cpd94" "Checkbutton247_1" vTcl:WidgetProc "Toplevel247" 1
    TitleFrame $site_7_0.cpd96 \
        -text PDF 
    vTcl:DefineAlias "$site_7_0.cpd96" "TitleFrame247_3" vTcl:WidgetProc "Toplevel247" 1
    bind $site_7_0.cpd96 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_9_0 [$site_7_0.cpd96 getframe]
    ComboBox $site_9_0.cpd76 \
        -editable 0 -entrybg white -justify center -takefocus 1 \
        -textvariable GnuStatPdf 
    vTcl:DefineAlias "$site_9_0.cpd76" "Combobox247_3" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_9_0.cpd76 "$site_9_0.cpd76 BwComboBox $top all"
    pack $site_9_0.cpd76 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.fra73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.fra93 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra87 \
        -in $site_5_0 -anchor center -expand 1 -fill both -padx 5 -side left 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side right 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side right 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side top 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel247" 1
    set site_3_0 $top.fra92
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit "Help/Statistics.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile MapAlgebraConfigFileStatHistoROI
global StatExecFid GnuplotPipeFid GnuplotPipeStat Load_SaveDisplay1

if {$OpenDirFile == 0} {

if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}

PlotStatClose
$widget(Button247_5) configure -state disable
$widget(Button247_7) configure -state disable

set ErrorCatch "0"
set ProgressLine ""
set ErrorCatch [catch {puts $StatExecFid "exit\n"}]
if { $ErrorCatch == "0" } {
    puts $StatExecFid "exit\n"
    flush $StatExecFid
    fconfigure $StatExecFid -buffering line
    while {$ProgressLine != "OKexit"} {
        gets $StatExecFid ProgressLine
        update
        }
    catch "close $StatExecFid"
    }
set StatExecFid ""
set ProgressLine ""

PlotStatRAZ   
if {$MapAlgebraConfigFileStatHistoROI != ""} { set MapAlgebraConfigFileStatHistoROI [MapAlgebra_command $MapAlgebraConfigFileStatHistoROI "quit" ""] }
Window hide $widget(Toplevel247); TextEditorRunTrace "Close Window Statistics" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button247" vTcl:WidgetProc "Toplevel247" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.fra92 \
        -in $top -anchor center -expand 1 -fill x -side top 

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
#############################################################################
## Binding tag:  _vTclBalloon


if {![info exists vTcl(sourcing)]} {
}

Window show .
Window show .top247

main $argc $argv
