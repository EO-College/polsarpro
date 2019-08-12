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

        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
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
    set base .top260a
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit85 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit85 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra178 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra178
    namespace eval ::widgets::$site_3_0.tit179 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.tit179 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.ent180 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd181 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd181 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.ent180 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.tit97 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit97 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra77
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.cpd102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd102
    namespace eval ::widgets::$site_6_0.lab32 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent33 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent35 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-_tooltip 1 -background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.fra75 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra75
    namespace eval ::widgets::$site_4_0.but80 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.but81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra76
    namespace eval ::widgets::$site_4_0.but82 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra182 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra182
    namespace eval ::widgets::$site_5_0.rad183 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd184 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.but83 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-background 1 -command 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.but84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra38 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra38
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top260a
            DualClearHistoBMP
            DualPlotHistoRAZ
            DualPlotHistoClose
            DualPlotHistoSave
            DualPlotHisto1D
            DualPlotHisto1DThumb
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
## Procedure:  DualClearHistoBMP

proc ::DualClearHistoBMP {} {
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint
global VarHistoSave TMPStatisticsTxt TMPStatisticsBin TMPStatResultsTxt

set VarHistoSave "no"
$widget(Button260a_2) configure -state normal
$widget(Button260a_3) configure -state disable
$widget(Button260a_4) configure -state disable
$widget(Button260a_5) configure -state disable
$widget(Button260a_6) configure -state disable
$widget(Radiobutton260a_1) configure -state disable
$widget(Radiobutton260a_2) configure -state disable
$widget(TitleFrame260a_1) configure -state disable
$widget(Checkbutton260a_1) configure -state disable
$widget(Label260a_1) configure -state disable
$widget(Entry260a_1) configure -state disable
$widget(Label260a_2) configure -state disable
$widget(Entry260a_2) configure -state disable
$widget(Button260a_1) configure -state disable

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
## Procedure:  DualPlotHistoRAZ

proc ::DualPlotHistoRAZ {} {
global GnuOutputFormat
global GnuHistoFile GnuHistoTitle GnuHistoLabel
global GnuHistoSaveFile GnuHistoStyle

set GnuOutputFormat ""
set GnuHistoTitle "HISTOGRAM"
set GnuHistoFile ""
set GnuHistoLabel "Label"
set GnuHistoSaveFile ""
set GnuHistoStyle "lines"
}
#############################################################################
## Procedure:  DualPlotHistoClose

proc ::DualPlotHistoClose {} {
global GnuplotPipeFid GnuplotPipeHisto

if {$GnuplotPipeHisto != ""} {
    catch "close $GnuplotPipeHisto"
    set GnuplotPipeHisto ""
    }
set GnuplotPipeFid ""
Window hide .top401
}
#############################################################################
## Procedure:  DualPlotHistoSave

proc ::DualPlotHistoSave {} {
global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput HistoDirOutput
global GnuplotPipeFid
global SaveDisplayOutputFile1

if {$GnuplotPipeFid == ""} {
    set ErrorMessage "GNUPLOT IS NOT RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set SaveDisplayDirOutput $HistoDirOutput
    set VarSaveGnuPlotFile ""
    set SaveDisplayOutputFile1 "Histogram"  
    WidgetShowFromWidget .top260a .top456; TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }
}
#############################################################################
## Procedure:  DualPlotHisto1D

proc ::DualPlotHisto1D {} {
global GnuplotPipeFid GnuplotPipeHisto GnuOutputFormat GnuOutputFile
global GnuHistoFile GnuHistoTitle GnuHistoLabel GnuHistoStyle GnuHistoMax
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top260a]; set ywindow [winfo y .top260a]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk
    
if {$GnuplotPipeHisto == ""} {
    GnuPlotInit 0 0 1 1
    set GnuplotPipeHisto $GnuplotPipeFid
    }
    
#DualPlotHisto1DThumb

set GnuOutputFile $TMPGnuPlotTk1
set GnuOutputFormat "gif"
GnuPlotTerm $GnuplotPipeHisto $GnuOutputFormat

puts $GnuplotPipeHisto "set autoscale"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set xlabel 'Value'"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set ylabel 'Nb of Samples (Max = $GnuHistoMax)'"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set title '$GnuHistoTitle' textcolor lt 3"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "plot '$GnuHistoFile' using 1:2 title '$GnuHistoLabel' with $GnuHistoStyle"; flush $GnuplotPipeHisto

puts $GnuplotPipeHisto "unset output"; flush $GnuplotPipeHisto 

set ErrorCatch [catch {puts $GnuplotPipeHisto "quit"}]
if { $ErrorCatch == "0" } {
    puts $GnuplotPipeHisto "quit"; flush $GnuplotPipeHisto 
    }
catch "close $GnuplotPipeHisto"
set GnuplotPipeHisto ""

WaitUntilCreated $TMPGnuPlotTk1
Gimp $TMPGnuPlotTk1

#ViewGnuPlotTKThumb 1 .top260a "Histogram"
}
#############################################################################
## Procedure:  DualPlotHisto1DThumb

proc ::DualPlotHisto1DThumb {} {
global GnuplotPipeFid GnuplotPipeHisto GnuOutputFormat GnuOutputFile
global GnuHistoFile GnuHistoTitle GnuHistoLabel GnuHistoStyle GnuHistoMax
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top260a]; set ywindow [winfo y .top260a]

DeleteFile $TMPGnuPlot1Tk

set GnuOutputFile $TMPGnuPlot1Tk
set GnuOutputFormat "png"
GnuPlotTerm $GnuplotPipeHisto $GnuOutputFormat

puts $GnuplotPipeHisto "set autoscale"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set xlabel 'Value'"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set ylabel 'Nb of Samples (Max = $GnuHistoMax)'"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set title '$GnuHistoTitle' textcolor lt 3"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "plot '$GnuHistoFile' using 1:2 title '$GnuHistoLabel' with $GnuHistoStyle"; flush $GnuplotPipeHisto

puts $GnuplotPipeHisto "unset output"; flush $GnuplotPipeHisto 

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
    wm geometry $top 200x200+66+66; update
    wm maxsize $top 3604 1065
    wm minsize $top 104 1
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

proc vTclWindow.top260a {base} {
    if {$base == ""} {
        set base .top260a
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x300+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Analysis : Statistics - Histogram"
    vTcl:DefineAlias "$top" "Toplevel260a" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel260a" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel260a" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HistoFileInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel260a" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel260a" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName HistoDirInput HistoFileInput
global HistoExecFid HistoFileOpen
global HistoInputFormat HistoOutputFormat
global MinMaxAutoHisto MinHisto MaxHisto
global ConfigFile NligInit VarError ErrorMessage

if {$HistoFileOpen == 1 } {
    set ProgressLine ""
    puts $HistoExecFid "closefile\n"
    flush $HistoExecFid
    fconfigure $HistoExecFid -buffering line
    while {$ProgressLine != "OKclosefile"} {
        gets $HistoExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $HistoExecFid "$HistoInputFormat\n"
    flush $HistoExecFid
    fconfigure $HistoExecFid -buffering line
    while {$ProgressLine != "OKreadformat"} {
        gets $HistoExecFid ProgressLine
        update
        }
    set ProgressLine ""
    while {$ProgressLine != "OKfinclosefile"} {
        gets $HistoExecFid ProgressLine
        update
        }
    set HistoFileOpen 0
    set ProgressLine ""
    }

set HistoFileInput ""
set NligInit ""
set NligEnd ""
set NcolInit ""
set NcolEnd ""
set NcolFullSize ""
set HistoInputFormat "float"
$widget(Radiobutton260a_3) configure -state disable
$widget(Radiobutton260a_4) configure -state disable
set HistoOutputFormat "real"
set MinMaxAutoHisto 1
set MinHisto "Auto"; set MaxHisto "Auto"
$widget(Button260a_3) configure -state disable
$widget(Button260a_4) configure -state disable
$widget(Button260a_5) configure -state disable
$widget(Button260a_6) configure -state disable
$widget(Radiobutton260a_1) configure -state disable
$widget(Radiobutton260a_2) configure -state disable
$widget(TitleFrame260a_1) configure -state disable
$widget(Checkbutton260a_1) configure -state disable
$widget(Label260a_1) configure -state disable
$widget(Entry260a_1) configure -state disable
$widget(Label260a_2) configure -state disable
$widget(Entry260a_2) configure -state disable
$widget(Button260a_1) configure -state disable
    
set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $HistoDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; gets $f tmp
            gets $f tmp; gets $f tmp
            gets $f tmp; gets $f tmp
            if {$tmp == "data type = 2"} {set HistoInputFormat "int"; set HistoOutputFormat "real"}
            if {$tmp == "data type = 4"} {set HistoInputFormat "float"; set HistoOutputFormat "real"}
            if {$tmp == "data type = 6"} {set HistoInputFormat "cmplx"; set HistoOutputFormat "mod"}
            set HistoDirInput [file dirname $FileName]
            set ConfigFile "$HistoDirInput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                set HistoFileInput $FileName
                } else {
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                if {$VarError == "cancel"} {Window hide $widget(Toplevel260a); TextEditorRunTrace "Close Window Statistic Histograms" "b"}
                }    
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            if {$VarError == "cancel"} {Window hide $widget(Toplevel260a); TextEditorRunTrace "Close Window Statistic Histograms" "b"}
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel260a); TextEditorRunTrace "Close Window Statistic Histograms" "b"}
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit81 \
        -ipad 0 -text {Input Data Format} 
    vTcl:DefineAlias "$top.tit81" "TitleFrame1" vTcl:WidgetProc "Toplevel260a" 1
    bind $top.tit81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit81 getframe]
    radiobutton $site_4_0.cpd82 \
        \
        -command {$widget(Radiobutton260a_3) configure -state normal
$widget(Radiobutton260a_4) configure -state normal} \
        -padx 1 -text Complex -value cmplx -variable HistoInputFormat 
    radiobutton $site_4_0.cpd83 \
        \
        -command {$widget(Radiobutton260a_3) configure -state disable
$widget(Radiobutton260a_4) configure -state disable} \
        -padx 1 -text Float -value float -variable HistoInputFormat 
    radiobutton $site_4_0.cpd84 \
        \
        -command {$widget(Radiobutton260a_3) configure -state disable
$widget(Radiobutton260a_4) configure -state disable} \
        -padx 1 -text Integer -value int -variable HistoInputFormat 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit85 \
        -ipad 0 -text Show 
    vTcl:DefineAlias "$top.tit85" "TitleFrame2" vTcl:WidgetProc "Toplevel260a" 1
    bind $top.tit85 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit85 getframe]
    radiobutton $site_4_0.cpd86 \
        -padx 1 -text Modulus -value mod -variable HistoOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd86" "Radiobutton35" vTcl:WidgetProc "Toplevel260a" 1
    radiobutton $site_4_0.cpd71 \
        -padx 1 -text 10log(Mod) -value db10 -variable HistoOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd71" "Radiobutton43" vTcl:WidgetProc "Toplevel260a" 1
    radiobutton $site_4_0.cpd87 \
        -padx 1 -text 20log(Mod) -value db20 -variable HistoOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd87" "Radiobutton36" vTcl:WidgetProc "Toplevel260a" 1
    radiobutton $site_4_0.cpd89 \
        -padx 1 -text Phase -value pha -variable HistoOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd89" "Radiobutton260a_3" vTcl:WidgetProc "Toplevel260a" 1
    radiobutton $site_4_0.cpd90 \
        -padx 1 -text Real -value real -variable HistoOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd90" "Radiobutton38" vTcl:WidgetProc "Toplevel260a" 1
    radiobutton $site_4_0.cpd92 \
        -padx 1 -text Imag -value imag -variable HistoOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd92" "Radiobutton260a_4" vTcl:WidgetProc "Toplevel260a" 1
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra178 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra178" "Frame7" vTcl:WidgetProc "Toplevel260a" 1
    set site_3_0 $top.fra178
    TitleFrame $site_3_0.tit179 \
        -ipad 2 -text {Histogram Title} 
    vTcl:DefineAlias "$site_3_0.tit179" "TitleFrame3" vTcl:WidgetProc "Toplevel260a" 1
    bind $site_3_0.tit179 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit179 getframe]
    entry $site_5_0.ent180 \
        -background white -foreground #ff0000 -justify center \
        -textvariable GnuHistoTitle -width 40 
    vTcl:DefineAlias "$site_5_0.ent180" "Entry1" vTcl:WidgetProc "Toplevel260a" 1
    pack $site_5_0.ent180 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side top 
    TitleFrame $site_3_0.cpd181 \
        -ipad 2 -text {Histogram Label} 
    vTcl:DefineAlias "$site_3_0.cpd181" "TitleFrame4" vTcl:WidgetProc "Toplevel260a" 1
    bind $site_3_0.cpd181 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd181 getframe]
    entry $site_5_0.ent180 \
        -background white -foreground #ff0000 -justify center \
        -textvariable GnuHistoLabel 
    vTcl:DefineAlias "$site_5_0.ent180" "Entry2" vTcl:WidgetProc "Toplevel260a" 1
    pack $site_5_0.ent180 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side top 
    pack $site_3_0.tit179 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd181 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit97 \
        -ipad 0 -text {Minimum / Maximum Values ( x-axis )} 
    vTcl:DefineAlias "$top.tit97" "TitleFrame260a_1" vTcl:WidgetProc "Toplevel260a" 1
    bind $top.tit97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit97 getframe]
    frame $site_4_0.cpd72
    set site_5_0 $site_4_0.cpd72
    frame $site_5_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra77" "Frame3" vTcl:WidgetProc "Toplevel260a" 1
    set site_6_0 $site_5_0.fra77
    checkbutton $site_6_0.cpd78 \
        \
        -command {global MinMaxAutoHisto MinHisto MaxHisto
if {"$MinMaxAutoHisto" == "1"} {
    $widget(Label260a_1) configure -state disable
    $widget(Entry260a_1) configure -state disable
    $widget(Label260a_2) configure -state disable
    $widget(Entry260a_2) configure -state disable
    $widget(Button260a_1) configure -state disable
    set MinHisto "Auto"
    set MaxHisto "Auto"
    } else {
    $widget(Label260a_1) configure -state normal
    $widget(Entry260a_1) configure -state normal
    $widget(Label260a_2) configure -state normal
    $widget(Entry260a_2) configure -state normal
    $widget(Button260a_1) configure -state normal
    set MinHisto "?"
    set MaxHisto "?"
    }} \
        -padx 1 -text Automatic -variable MinMaxAutoHisto 
    vTcl:DefineAlias "$site_6_0.cpd78" "Checkbutton260a_1" vTcl:WidgetProc "Toplevel260a" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra77 \
        -in $site_5_0 -anchor w -expand 1 -fill none -side top 
    frame $site_4_0.cpd73
    set site_5_0 $site_4_0.cpd73
    frame $site_5_0.cpd102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd102" "Frame69" vTcl:WidgetProc "Toplevel260a" 1
    set site_6_0 $site_5_0.cpd102
    label $site_6_0.lab32 \
        -padx 1 -text Min 
    vTcl:DefineAlias "$site_6_0.lab32" "Label260a_1" vTcl:WidgetProc "Toplevel260a" 1
    entry $site_6_0.ent33 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MinHisto -width 12 
    vTcl:DefineAlias "$site_6_0.ent33" "Entry260a_1" vTcl:WidgetProc "Toplevel260a" 1
    label $site_6_0.lab34 \
        -padx 1 -text Max 
    vTcl:DefineAlias "$site_6_0.lab34" "Label260a_2" vTcl:WidgetProc "Toplevel260a" 1
    entry $site_6_0.ent35 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MaxHisto -width 12 
    vTcl:DefineAlias "$site_6_0.ent35" "Entry260a_2" vTcl:WidgetProc "Toplevel260a" 1
    button $site_6_0.cpd75 \
        -background #ffff00 \
        -command {global TMPStatisticsBin TMPStatResultsTxt
global HistoInputFormat HistoOutputFormat 
global MinMaxAutoHisto MinHisto MaxHisto
global VarError ErrorMessage OpenDirFile
global TMPMinMaxBmp 

if {$OpenDirFile == 0} {

WaitUntilCreated $TMPStatResultsTxt 
if [file exists $TMPStatResultsTxt] {
    set f [open $TMPStatResultsTxt r]
    gets $f Npts
    close $f
    DeleteFile $TMPMinMaxBmp
    set Fonction "Min / Max Values Determination of the Bin File :"
    set Fonction2 "$TMPStatisticsBin"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/MinMaxBMP.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$TMPStatisticsBin\x22 -ift $HistoInputFormat -oft $HistoOutputFormat -nc 1 -ofr 0 -ofc 0 -fnr $Npts -fnc 1 -of \x22$TMPMinMaxBmp\x22" "k"
    set f [ open "| Soft/bin/bmp_process/MinMaxBMP.exe -if \x22$TMPStatisticsBin\x22 -ift $HistoInputFormat -oft $HistoOutputFormat -nc 1 -ofr 0 -ofc 0 -fnr $Npts -fnc 1 -of \x22$TMPMinMaxBmp\x22" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    set ProgressLine ""
        
    WaitUntilCreated $TMPMinMaxBmp 
    if [file exists $TMPMinMaxBmp] {
        set f [open $TMPMinMaxBmp r]
        gets $f MaxHisto
        gets $f MinHisto
        close $f
        }
    } else {
    set ErrorMessage "PROBLEM DURING DATA EXTRACTION" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -pady 2 -text MinMax 
    vTcl:DefineAlias "$site_6_0.cpd75" "Button260a_1" vTcl:WidgetProc "Toplevel260a" 1
    bindtags $site_6_0.cpd75 "$site_6_0.cpd75 Button $top all _vTclBalloon"
    bind $site_6_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Find the Min Max values}
    }
    pack $site_6_0.lab32 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_6_0.ent33 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.lab34 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_6_0.ent35 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd102 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame1" vTcl:WidgetProc "Toplevel260a" 1
    set site_3_0 $top.fra73
    frame $site_3_0.fra75 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra75" "Frame5" vTcl:WidgetProc "Toplevel260a" 1
    set site_4_0 $site_3_0.fra75
    button $site_4_0.but80 \
        -background #ffff00 \
        -command {global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint
global VarHistoSave TMPStatisticsTxt TMPStatisticsBin TMPStatResultsTxt

set VarHistoSave "no"
$widget(Button260a_2) configure -state disable
$widget(Button260a_7) configure -state disable
$widget(Button260a_3) configure -state disable
$widget(Button260a_4) configure -state disable
$widget(Button260a_5) configure -state disable
$widget(Button260a_6) configure -state disable
$widget(Radiobutton260a_1) configure -state disable
$widget(Radiobutton260a_2) configure -state disable
$widget(TitleFrame260a_1) configure -state disable
$widget(Checkbutton260a_1) configure -state disable
$widget(Label260a_1) configure -state disable
$widget(Entry260a_1) configure -state disable
$widget(Label260a_2) configure -state disable
$widget(Entry260a_2) configure -state disable
$widget(Button260a_1) configure -state disable

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

DualPlotHistoRAZ
DualPlotHistoClose

set VarHistoSave "no"
WaitUntilCreated $TMPStatisticsTxt
if [file exists $TMPStatisticsTxt] {
    set VarHistoSave "ok"
    $widget(Button260a_2) configure -state normal
    $widget(Button260a_7) configure -state normal
    }
tkwait variable VarHistoSave} \
        -padx 4 -pady 2 -text Clear 
    vTcl:DefineAlias "$site_4_0.but80" "Button260a_7" vTcl:WidgetProc "Toplevel260a" 1
    button $site_4_0.but81 \
        -background #ffff00 \
        -command {global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint  
global TMPStatisticsTxt TMPStatisticsBin TMPStatResultsTxt
global VarHistoSave OpenDirFile HistoExecFid HistoFileOpen
global HistoDirInput HistoFileInput HistoInputFormat
global MinMaxAutoHisto MinHisto MaxHisto


if {$OpenDirFile == 0} {

if {$HistoFileInput != ""} {

DeleteFile $TMPStatisticsBin
DeleteFile $TMPStatResultsTxt

if [file exists $TMPStatisticsTxt] {
    #Data Extract
    if {$HistoFileOpen == 0} {
        set ProgressLine ""
        puts $HistoExecFid "openfile\n"
        flush $HistoExecFid
        fconfigure $HistoExecFid -buffering line
        while {$ProgressLine != "OKopenfile"} {
            gets $HistoExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $HistoExecFid "$HistoDirInput\n"
        flush $HistoExecFid
        fconfigure $HistoExecFid -buffering line
        while {$ProgressLine != "OKreaddir"} {
            gets $HistoExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $HistoExecFid "$HistoFileInput\n"
        flush $HistoExecFid
        fconfigure $HistoExecFid -buffering line
        while {$ProgressLine != "OKreadfile"} {
            gets $HistoExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $HistoExecFid "$HistoInputFormat\n"
        flush $HistoExecFid
        fconfigure $HistoExecFid -buffering line
        while {$ProgressLine != "OKreadformat"} {
            gets $HistoExecFid ProgressLine
            update
            }
        set ProgressLine ""
        while {$ProgressLine != "OKfinopenfile"} {
            gets $HistoExecFid ProgressLine
            update
            }
        set HistoFileOpen 1
        set ProgressLine ""
        }
        
    set ProgressLine ""
    puts $HistoExecFid "histo\n"
    flush $HistoExecFid
    fconfigure $HistoExecFid -buffering line
    while {$ProgressLine != "OKhisto"} {
        gets $HistoExecFid ProgressLine
        update
        }
    set ProgressLine ""

    if [file exists $TMPStatisticsBin] {
        set VarHistoSave "ok"
        $widget(Button260a_3) configure -state normal
        $widget(Button260a_4) configure -state disable
        $widget(Button260a_5) configure -state disable
        $widget(Button260a_6) configure -state disable
        $widget(Radiobutton260a_1) configure -state disable
        $widget(Radiobutton260a_2) configure -state disable
        $widget(TitleFrame260a_1) configure -state normal
        $widget(Checkbutton260a_1) configure -state normal
        if {$MinMaxAutoHisto == 1} {
            $widget(Label260a_1) configure -state disable
            $widget(Entry260a_1) configure -state disable
            $widget(Label260a_2) configure -state disable
            $widget(Entry260a_2) configure -state disable
            $widget(Button260a_1) configure -state disable
            set MinHisto "Auto"; set MaxHisto "Auto"
            } else {
            $widget(Label260a_1) configure -state normal
            $widget(Entry260a_1) configure -state normal
            $widget(Label260a_2) configure -state normal
            $widget(Entry260a_2) configure -state normal
            $widget(Button260a_1) configure -state normal
            }
        } else {
        $widget(Button260a_3) configure -state disable
        $widget(Button260a_4) configure -state disable
        $widget(Button260a_5) configure -state disable
        $widget(Button260a_6) configure -state disable
        $widget(Radiobutton260a_1) configure -state disable
        $widget(Radiobutton260a_2) configure -state disable
        $widget(TitleFrame260a_1) configure -state disable
        $widget(Checkbutton260a_1) configure -state disable
        $widget(Label260a_1) configure -state disable
        $widget(Entry260a_1) configure -state disable
        $widget(Label260a_2) configure -state disable
        $widget(Entry260a_2) configure -state disable
        $widget(Button260a_1) configure -state disable
        set VarError ""
        set ErrorMessage "PROBLEM DURING DATA EXTRACTION" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }
} else {
set ErrorMessage "THE INPUT DATA FILE IS NOT DEFINED" 
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}

}} \
        -padx 4 -pady 2 -text "Extract & Process" 
    vTcl:DefineAlias "$site_4_0.but81" "Button260a_2" vTcl:WidgetProc "Toplevel260a" 1
    pack $site_4_0.but80 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -pady 5 \
        -side left 
    pack $site_4_0.but81 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -pady 5 \
        -side left 
    frame $site_3_0.fra76 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra76" "Frame6" vTcl:WidgetProc "Toplevel260a" 1
    set site_4_0 $site_3_0.fra76
    button $site_4_0.but82 \
        -background #ffff00 \
        -command {global OpenDirFile VarHistoSave 
global TMPStatisticsBin TMPStatResultsTxt TMPStatHistoTxt
global HistoInputFormat HistoOutputFormat 
global MinMaxAutoHisto MinHisto MaxHisto GnuHistoMax
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global VarError ErrorMessage 

if {$OpenDirFile == 0} {

if {$VarHistoSave == "ok"} {
    if [file exists $TMPStatisticsBin] {
        DualPlotHistoClose
        DeleteFile $TMPStatHistoTxt
        set Nbins 200
        if {$MinMaxAutoHisto == 1} {
            set RunMin "-9999"
            set RunMax "+9999"
            } else {
            set RunMin $MinHisto
            set RunMax $MaxHisto
            }
        set TestVarName(0) "Min Value"; set TestVarType(0) "float"; set TestVarValue(0) $RunMin; set TestVarMin(0) "-10000.00"; set TestVarMax(0) "10000.00"
        set TestVarName(1) "Max Value"; set TestVarType(1) "float"; set TestVarValue(1) $RunMax; set TestVarMin(1) "-10000.00"; set TestVarMax(1) "10000.00"
        TestVar 2
        if {$TestVarError == "ok"} {
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/statistics_histogram.exe" "k"
            TextEditorRunTrace "Arguments: \x22$TMPStatisticsBin\x22 \x22$TMPStatHistoTxt\x22 \x22$TMPStatResultsTxt\x22 $HistoInputFormat $HistoOutputFormat $Nbins $MinMaxAutoHisto $RunMin $RunMax" "k"
            set f [ open "| Soft/bin/data_process_sngl/statistics_histogram.exe \x22$TMPStatisticsBin\x22 \x22$TMPStatHistoTxt\x22 \x22$TMPStatResultsTxt\x22 $HistoInputFormat $HistoOutputFormat $Nbins $MinMaxAutoHisto $RunMin $RunMax" r]
            catch "close $f"
            }
        }            
    if [file exists $TMPStatHistoTxt] {
        #MouseActiveFunction ""
        $widget(Button260a_4) configure -state normal
        $widget(Button260a_5) configure -state normal
        $widget(Button260a_6) configure -state normal
        $widget(Radiobutton260a_1) configure -state normal
        $widget(Radiobutton260a_2) configure -state normal
        set GnuHistoFile "$TMPStatHistoTxt"
        set f [open $TMPStatResultsTxt r]
        gets $f GnuHistoMax
        close $f
        DualPlotHisto1D
        } else {
        set VarError ""
        set ErrorMessage "PROBLEM DURING HISTOGRAM GENERATION" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "AREA MUST BE DEFINED AND SAVED FIRST BEFORE RUNNING HISTOGRAM PROCESS" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Plot 
    vTcl:DefineAlias "$site_4_0.but82" "Button260a_3" vTcl:WidgetProc "Toplevel260a" 1
    frame $site_4_0.fra182 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra182" "Frame8" vTcl:WidgetProc "Toplevel260a" 1
    set site_5_0 $site_4_0.fra182
    radiobutton $site_5_0.rad183 \
        -borderwidth 0 -command DualPlotHisto1D -text line -value lines \
        -variable GnuHistoStyle 
    vTcl:DefineAlias "$site_5_0.rad183" "Radiobutton260a_1" vTcl:WidgetProc "Toplevel260a" 1
    radiobutton $site_5_0.cpd184 \
        -borderwidth 0 -command DualPlotHisto1D -text box -value boxes \
        -variable GnuHistoStyle 
    vTcl:DefineAlias "$site_5_0.cpd184" "Radiobutton260a_2" vTcl:WidgetProc "Toplevel260a" 1
    pack $site_5_0.rad183 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd184 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    button $site_4_0.but83 \
        -background #ffff00 \
        -command {global OpenDirFile
#BMP_PROCESS
global Load_SaveDisplay1 PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_SaveDisplay1 == 0} {
    source "GUI/bmp_process/SaveDisplay1.tcl"
    set Load_SaveDisplay1 1
    WmTransient $widget(Toplevel456) $PSPTopLevel
    }

DualPlotHistoSave
}} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.but83" "Button260a_4" vTcl:WidgetProc "Toplevel260a" 1
    bindtags $site_4_0.but83 "$site_4_0.but83 Button $top all _vTclBalloon"
    bind $site_4_0.but83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save}
    }
    button $site_4_0.cpd66 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1

Gimp $TMPGnuPlotTk1} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -text { } 
    vTcl:DefineAlias "$site_4_0.cpd66" "Button260a_6" vTcl:WidgetProc "Toplevel260a" 1
    button $site_4_0.but84 \
        -background #ffff00 \
        -command {DualPlotHistoClose
$widget(Button260a_4) configure -state disable} \
        -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_4_0.but84" "Button260a_5" vTcl:WidgetProc "Toplevel260a" 1
    pack $site_4_0.but82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -pady 5 \
        -side left 
    pack $site_4_0.fra182 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side left 
    pack $site_4_0.but83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -pady 5 \
        -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.but84 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -pady 5 \
        -side left 
    pack $site_3_0.fra75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra38 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel260a" 1
    set site_3_0 $top.fra38
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit "Help/Histograms.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel260a" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile MapAlgebraConfigFileStatHistoROI
global HistoExecFid GnuplotPipeFid GnuplotPipeHisto Load_SaveDisplay1

if {$OpenDirFile == 0} {

if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}

set ErrorCatch "0"
set ProgressLine ""
set ErrorCatch [catch {puts $HistoExecFid "exit\n"}]
if { $ErrorCatch == "0" } {
    puts $HistoExecFid "exit\n"
    flush $HistoExecFid
    fconfigure $HistoExecFid -buffering line
    while {$ProgressLine != "OKexit"} {
        gets $HistoExecFid ProgressLine
        update
        }
    catch "close $HistoExecFid"
    }
set HistoExecFid ""
set ProgressLine ""

DualPlotHistoRAZ   
DualPlotHistoClose 
if {$MapAlgebraConfigFileStatHistoROI != ""} { set MapAlgebraConfigFileStatHistoROI [MapAlgebra_command $MapAlgebraConfigFileStatHistoROI "quit" ""] }
Window hide $widget(Toplevel260a); TextEditorRunTrace "Close Window Histograms" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel260a" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit85 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra178 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.tit97 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra38 \
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
Window show .top260a

main $argc $argv
