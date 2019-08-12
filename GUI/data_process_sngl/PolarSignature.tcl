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
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
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
    set base .top240
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd78
    namespace eval ::widgets::$site_4_0.can73 {
        array set save {-borderwidth 1 -closeenough 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd80 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra84
    namespace eval ::widgets::$site_8_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra85
    namespace eval ::widgets::$site_8_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra84
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd71
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd72
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra84
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd71
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd73
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra84
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra85
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd75
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.tit82 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.tit82 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd83 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd84 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd85 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra84
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.but86 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd87 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra85
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd88 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd89 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra79
    namespace eval ::widgets::$site_5_0.but80 {
        array set save {-command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but83 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.but67 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top240
            PlotPolarSig
            PlotPolarSigThumb
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
## Procedure:  PlotPolarSig

proc ::PlotPolarSig {} {
global BMPPolSigX BMPPolSigY PolSigOutputFormat PolSigOutputUnit PolSigExecFid
global GnuplotPipeFid GnuplotPipeCopol GnuplotPipeXpol
global TMPCopolSigTxt TMPCopolSigBin TMPXpolSigTxt TMPXpolSigBin  
global GnuXview GnuZview  
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPGnuPlotTk1 TMPGnuPlotTk2 TMPGnuPlot1Tk TMPGnuPlot2Tk GnuOutputFormat GnuOutputFile

set TestVarName(0) "Orientation Elevation (°)"; set TestVarType(0) "float"; set TestVarValue(0) $GnuXview; set TestVarMin(0) "0.0"; set TestVarMax(0) "180.0"
set TestVarName(1) "Orientation Azimut (°)"; set TestVarType(1) "float"; set TestVarValue(1) $GnuZview; set TestVarMin(1) "0.0"; set TestVarMax(1) "360.0"
TestVar 2
if {$TestVarError == "ok"} {

set Rb240_1 .top240.fra71.fra72.cpd77.f.cpd75.fra84.rad78
set Rb240_2 .top240.fra71.fra72.cpd77.f.cpd75.cpd71.rad78
set Rb240_3 .top240.fra71.fra72.cpd77.f.cpd75.cpd72.rad78
set Rb240_4 .top240.fra71.fra72.cpd77.f.cpd72.fra84.rad78
set Rb240_5 .top240.fra71.fra72.cpd77.f.cpd72.cpd71.rad78
set Rb240_6 .top240.fra71.fra72.cpd77.f.cpd72.cpd73.rad78
set B240_1 .top240.fra71.fra72.fra79.but81
set B240_2 .top240.fra92.but24
set B240_4 .top240.fra71.fra72.fra79.but83
set B240_5 .top240.fra71.fra72.fra79.but71
set B240_6 .top240.fra71.fra72.fra79.but67


set config "true"
if {$BMPPolSigX == ""} {set config "false"}
if {$BMPPolSigY == ""} {set config "false"}
if {$config == "true"} {
$Rb240_1 configure -state disable
$Rb240_2 configure -state disable
$Rb240_3 configure -state disable
$Rb240_4 configure -state disable
$Rb240_5 configure -state disable
$Rb240_6 configure -state disable
$B240_1 configure -state disable
#$B240_2 configure -state disable
$B240_4 configure -state disable
$B240_5 configure -state disable
$B240_6 configure -state disable

DeleteFile $TMPCopolSigTxt
DeleteFile $TMPCopolSigBin
DeleteFile $TMPXpolSigTxt
DeleteFile $TMPXpolSigBin

set ProgressLine ""
puts $PolSigExecFid "plot\n"
flush $PolSigExecFid
fconfigure $PolSigExecFid -buffering line
while {$ProgressLine != "OKplot"} {
    gets $PolSigExecFid ProgressLine
    update
    }
set ProgressLine ""
puts $PolSigExecFid "$BMPPolSigX\n"
flush $PolSigExecFid
fconfigure $PolSigExecFid -buffering line
while {$ProgressLine != "OKreadcol"} {
    gets $PolSigExecFid ProgressLine
    update
    }
set ProgressLine ""
puts $PolSigExecFid "$BMPPolSigY\n"
flush $PolSigExecFid
fconfigure $PolSigExecFid -buffering line
while {$ProgressLine != "OKreadlig"} {
    gets $PolSigExecFid ProgressLine
    update
    }
set ProgressLine ""
puts $PolSigExecFid "$PolSigOutputUnit\n"
flush $PolSigExecFid
fconfigure $PolSigExecFid -buffering line
while {$ProgressLine != "OKformat"} {
    gets $PolSigExecFid ProgressLine
    update
    }
set ProgressLine ""
while {$ProgressLine != "OKplotOK"} {
    gets $PolSigExecFid ProgressLine
    update
    }
set ProgressLine ""

set xwindow [winfo x .top240]; set ywindow [winfo y .top240]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk

if [file exists $TMPXpolSigTxt] {
    if {$GnuplotPipeXpol == ""} {
	GnuPlotInit 0 0 1 1
    	set GnuplotPipeXpol $GnuplotPipeFid
	}
    #PlotPolarSigThumb 1
    set GnuOutputFile $TMPGnuPlotTk1
    set GnuOutputFormat "gif"
    GnuPlotTerm $GnuplotPipeXpol $GnuOutputFormat
    set Unit ""; if {$PolSigOutputUnit == "dB"} {set Unit "dB"}
    GnuPlot3D $GnuplotPipeXpol $TMPXpolSigTxt $TMPXpolSigBin "Tau (°)" "Phi (°)" $Unit $GnuXview $GnuZview "Normalized Polarimetric Signature : Cross-polarisation channel" 1 $PolSigOutputFormat 3
    
    puts $GnuplotPipeXpol "unset output"; flush $GnuplotPipeXpol 

    set ErrorCatch [catch {puts $GnuplotPipeXpol "quit"}]
    if { $ErrorCatch == "0" } {
        puts $GnuplotPipeXpol "quit"; flush $GnuplotPipeXpol 
        }
    catch "close $GnuplotPipeXpol"
    set GnuplotPipeXpol ""

    WaitUntilCreated $TMPGnuPlotTk1
    Gimp $TMPGnuPlotTk1
    #ViewGnuPlotTKThumb 1 .top240 "X-Pol Signature"
    }

DeleteFile $TMPGnuPlotTk2
DeleteFile $TMPGnuPlot2Tk

if [file exists $TMPCopolSigTxt] {
    if {$GnuplotPipeCopol == ""} {
	GnuPlotInit 0 0 1 1
    	set GnuplotPipeCopol $GnuplotPipeFid
	}
    #PlotPolarSigThumb 2
    set GnuOutputFile $TMPGnuPlotTk2
    set GnuOutputFormat "gif"
    GnuPlotTerm $GnuplotPipeCopol $GnuOutputFormat
    set Unit ""; if {$PolSigOutputUnit == "dB"} {set Unit "dB"}
    GnuPlot3D $GnuplotPipeCopol $TMPCopolSigTxt $TMPCopolSigBin "Tau (°)" "Phi (°)" $Unit $GnuXview $GnuZview "Normalized Polarimetric Signature : Co-polarisation channel" 1 $PolSigOutputFormat 3
    
    puts $GnuplotPipeCopol "unset output"; flush $GnuplotPipeCopol 

    set ErrorCatch [catch {puts $GnuplotPipeCopol "quit"}]
    if { $ErrorCatch == "0" } {
        puts $GnuplotPipeCopol "quit"; flush $GnuplotPipeCopol 
        }
    catch "close $GnuplotPipeCopol"
    set GnuplotPipeCopol ""

    WaitUntilCreated $TMPGnuPlotTk2
    Gimp $TMPGnuPlotTk2
    #ViewGnuPlotTKThumb 2 .top401 "Co-Pol Signature"
    }
        
$Rb240_1 configure -state normal
$Rb240_2 configure -state normal
$Rb240_3 configure -state normal
$Rb240_4 configure -state normal
$Rb240_5 configure -state normal
$Rb240_6 configure -state normal
$B240_1 configure -state normal
#$B240_2 configure -state normal
$B240_4 configure -state normal
$B240_5 configure -state normal
$B240_6 configure -state normal
}
}
}
#############################################################################
## Procedure:  PlotPolarSigThumb

proc ::PlotPolarSigThumb {ThumbNum} {
global BMPPolSigX BMPPolSigY PolSigOutputFormat PolSigOutputUnit PolSigExecFid
global GnuplotPipeFid GnuplotPipeCopol GnuplotPipeXpol
global TMPCopolSigTxt TMPCopolSigBin TMPXpolSigTxt TMPXpolSigBin  
global GnuXview GnuZview  
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPGnuPlotTk1 TMPGnuPlotTk2 TMPGnuPlot1Tk TMPGnuPlot2Tk GnuOutputFormat GnuOutputFile

set xwindow [winfo x .top240]; set ywindow [winfo y .top240]

if {$ThumbNum == 1} {
    DeleteFile $TMPGnuPlot1Tk
    set GnuOutputFile $TMPGnuPlot1Tk
    set GnuOutputFormat "png"
    GnuPlotTerm $GnuplotPipeXpol $GnuOutputFormat
    set Unit ""; if {$PolSigOutputUnit == "dB"} {set Unit "dB"}
    GnuPlot3D $GnuplotPipeXpol $TMPXpolSigTxt $TMPXpolSigBin "Tau (°)" "Phi (°)" $Unit $GnuXview $GnuZview "Normalized Polarimetric Signature : Cross-polarisation channel" 1 $PolSigOutputFormat 3
    
    puts $GnuplotPipeXpol "unset output"; flush $GnuplotPipeXpol 

    WaitUntilCreated $TMPGnuPlot1Tk
    }

if {$ThumbNum == 2} {
    DeleteFile $TMPGnuPlot2Tk
    set GnuOutputFile $TMPGnuPlot2Tk
    set GnuOutputFormat "png"
    GnuPlotTerm $GnuplotPipeCopol $GnuOutputFormat
    set Unit ""; if {$PolSigOutputUnit == "dB"} {set Unit "dB"}
    GnuPlot3D $GnuplotPipeCopol $TMPCopolSigTxt $TMPCopolSigBin "Tau (°)" "Phi (°)" $Unit $GnuXview $GnuZview "Normalized Polarimetric Signature : Co-polarisation channel" 1 $PolSigOutputFormat 3
    
    puts $GnuplotPipeCopol "unset output"; flush $GnuplotPipeCopol 

    WaitUntilCreated $TMPGnuPlot2Tk
    }
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
    wm geometry $top 200x200+175+175; update
    wm maxsize $top 3360 1028
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

proc vTclWindow.top240 {base} {
    if {$base == ""} {
        set base .top240
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
    wm title $top "Polarimetric Signatures"
    vTcl:DefineAlias "$top" "Toplevel240" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel240" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel240" 1
    set site_4_0 $site_3_0.cpd78
    canvas $site_4_0.can73 \
        -borderwidth 2 -closeenough 1.0 -height 200 -relief ridge -width 200 
    vTcl:DefineAlias "$site_4_0.can73" "CANVASLENSPOLSIG" vTcl:WidgetProc "Toplevel240" 1
    bind $site_4_0.can73 <Button-1> {
        MouseButtonDownLens %x %y
    }
    TitleFrame $site_4_0.cpd80 \
        -ipad 2 -text {Mouse Position} 
    vTcl:DefineAlias "$site_4_0.cpd80" "TitleFrame3" vTcl:WidgetProc "Toplevel240" 1
    bind $site_4_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd80 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame29" vTcl:WidgetProc "Toplevel240" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame30" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label27" vTcl:WidgetProc "Toplevel240" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseX -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry52" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame31" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label28" vTcl:WidgetProc "Toplevel240" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseY -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry53" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame32" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab76 \
        -relief groove -text Val -width 4 
    vTcl:DefineAlias "$site_8_0.lab76" "Label29" vTcl:WidgetProc "Toplevel240" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPValue -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry54" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.fra85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.can73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel240" 1
    set site_4_0 $site_3_0.fra72
    TitleFrame $site_4_0.cpd77 \
        -ipad 2 -text Representation 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame6" vTcl:WidgetProc "Toplevel240" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame33" vTcl:WidgetProc "Toplevel240" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame34" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.fra84
    radiobutton $site_8_0.rad78 \
        -command PlotPolarSig -text Mesh -value mesh \
        -variable PolSigOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton240_1" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame35" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.cpd71
    radiobutton $site_8_0.rad78 \
        -command PlotPolarSig -text Contour -value contour \
        -variable PolSigOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton240_2" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd72" "Frame39" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.cpd72
    radiobutton $site_8_0.rad78 \
        -command PlotPolarSig -text Surface -value surface \
        -variable PolSigOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton240" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    frame $site_6_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame36" vTcl:WidgetProc "Toplevel240" 1
    set site_7_0 $site_6_0.cpd72
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame37" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.fra84
    radiobutton $site_8_0.rad78 \
        -command PlotPolarSig -text Mesh-Color -value meshcolor \
        -variable PolSigOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton240_3" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame38" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.cpd71
    radiobutton $site_8_0.rad78 \
        -command PlotPolarSig -text {Mesh & Contour} -value meshcontour \
        -variable PolSigOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton240_4" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd73 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd73" "Frame40" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.cpd73
    radiobutton $site_8_0.rad78 \
        -command PlotPolarSig -text {Mesh & Surface} -value meshsurface \
        -variable PolSigOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton241" vTcl:WidgetProc "Toplevel240" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame7" vTcl:WidgetProc "Toplevel240" 1
    set site_5_0 $site_4_0.cpd75
    TitleFrame $site_5_0.cpd76 \
        -ipad 2 -text {Pixel Values} 
    vTcl:DefineAlias "$site_5_0.cpd76" "TitleFrame7" vTcl:WidgetProc "Toplevel240" 1
    bind $site_5_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame41" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame42" vTcl:WidgetProc "Toplevel240" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label30" vTcl:WidgetProc "Toplevel240" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPPolSigX -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry55" vTcl:WidgetProc "Toplevel240" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame43" vTcl:WidgetProc "Toplevel240" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label31" vTcl:WidgetProc "Toplevel240" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPPolSigY -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry56" vTcl:WidgetProc "Toplevel240" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd75" "Frame44" vTcl:WidgetProc "Toplevel240" 1
    set site_9_0 $site_8_0.cpd75
    label $site_9_0.lab76 \
        -relief groove -text Val -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label32" vTcl:WidgetProc "Toplevel240" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPPolSigValue -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry57" vTcl:WidgetProc "Toplevel240" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.cpd75 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $site_5_0.tit82 \
        -text Format 
    vTcl:DefineAlias "$site_5_0.tit82" "TitleFrame1" vTcl:WidgetProc "Toplevel240" 1
    bind $site_5_0.tit82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit82 getframe]
    radiobutton $site_7_0.cpd83 \
        -command PlotPolarSig -text dB -value dB -variable PolSigOutputUnit 
    vTcl:DefineAlias "$site_7_0.cpd83" "Radiobutton5" vTcl:WidgetProc "Toplevel240" 1
    radiobutton $site_7_0.cpd84 \
        -command PlotPolarSig -text lin -value lin -variable PolSigOutputUnit 
    vTcl:DefineAlias "$site_7_0.cpd84" "Radiobutton6" vTcl:WidgetProc "Toplevel240" 1
    pack $site_7_0.cpd83 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.cpd84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    TitleFrame $site_5_0.cpd85 \
        -ipad 2 -text Orientation 
    vTcl:DefineAlias "$site_5_0.cpd85" "TitleFrame8" vTcl:WidgetProc "Toplevel240" 1
    bind $site_5_0.cpd85 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd85 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame45" vTcl:WidgetProc "Toplevel240" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame46" vTcl:WidgetProc "Toplevel240" 1
    set site_9_0 $site_8_0.fra84
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GnuXview -width 5 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry58" vTcl:WidgetProc "Toplevel240" 1
    button $site_9_0.but86 \
        \
        -command {global GnuXview

set GnuTmp [expr $GnuXview + 5]
if {$GnuTmp > 180} {set GnuTmp [expr $GnuTmp - 180]}
set GnuXview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.but86" "Button2" vTcl:WidgetProc "Toplevel240" 1
    button $site_9_0.cpd87 \
        \
        -command {global GnuXview

set GnuTmp [expr $GnuXview - 5]
if {$GnuTmp < 0} {set GnuTmp [expr $GnuTmp + 180]}
set GnuXview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd87" "Button3" vTcl:WidgetProc "Toplevel240" 1
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_9_0.but86 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd87 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame47" vTcl:WidgetProc "Toplevel240" 1
    set site_9_0 $site_8_0.fra85
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GnuZview -width 5 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry59" vTcl:WidgetProc "Toplevel240" 1
    button $site_9_0.cpd88 \
        \
        -command {global GnuZview

set GnuTmp [expr $GnuZview + 5]
if {$GnuTmp > 360} {set GnuTmp [expr $GnuTmp - 360]}
set GnuZview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.cpd88" "Button4" vTcl:WidgetProc "Toplevel240" 1
    button $site_9_0.cpd89 \
        \
        -command {global GnuZview

set GnuTmp [expr $GnuZview - 5]
if {$GnuTmp < 0} {set GnuTmp [expr $GnuTmp + 360]}
set GnuZview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd89" "Button5" vTcl:WidgetProc "Toplevel240" 1
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_9_0.cpd88 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd89 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.tit82 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    frame $site_4_0.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra79" "Frame5" vTcl:WidgetProc "Toplevel240" 1
    set site_5_0 $site_4_0.fra79
    button $site_5_0.but80 \
        \
        -command {global BMPLens LineXLensInit LineYLensInit LineXLens LineYLens plot2 line_color

if {$line_color == "white"} {
    set line_color "black"
    } else {
    set line_color "white"
    }

set b .top240.fra71.fra72.fra79.but80
$b configure -background $line_color -foreground $line_color

$widget(CANVASLENSPOLSIG) dtag LineXLensInit
$widget(CANVASLENSPOLSIG) dtag LineYLensInit
$widget(CANVASLENSPOLSIG) create image 0 0 -anchor nw -image BMPLens
set LineXLensInit {0 0}
set LineYLensInit {0 0}
set LineXLens [$widget(CANVASLENSPOLSIG) create line 0 0 0 $SizeLens -fill $line_color -width 2]
set LineYLens [$widget(CANVASLENSPOLSIG) create line 0 0 $SizeLens 0 -fill $line_color -width 2]
$widget(CANVASLENSPOLSIG) addtag LineXLensInit withtag $LineXLens
$widget(CANVASLENSPOLSIG) addtag LineYLensInit withtag $LineYLens
set plot2(lastX) 0
set plot2(lastY) 0} \
        -pady 0 -relief ridge -text {   } 
    vTcl:DefineAlias "$site_5_0.but80" "Button1" vTcl:WidgetProc "Toplevel240" 1
    button $site_5_0.but81 \
        -background #ffff00 -command PlotPolarSig -padx 4 -pady 2 -text Plot 
    vTcl:DefineAlias "$site_5_0.but81" "Button240_1" vTcl:WidgetProc "Toplevel240" 1
    button $site_5_0.but83 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput PolSigDirOutput
global GnuplotPipeFid
global SaveDisplayOutputFile1 SaveDisplayOutputFile2

#BMP_PROCESS
global Load_SaveDisplay2 PSPTopLevel

if {$GnuplotPipeFid == ""} {
    set ErrorMessage "GNUPLOT IS NOT RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

    if {$Load_SaveDisplay2 == 0} {
        source "GUI/bmp_process/SaveDisplay2.tcl"
        set Load_SaveDisplay2 1
        WmTransient $widget(Toplevel457) $PSPTopLevel
        }

    set SaveDisplayDirOutput $PolSigDirOutput

    set SaveDisplayOutputFile1 "CopolSignature"
    set SaveDisplayOutputFile2 "XpolSignature"
    
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel240) $widget(Toplevel457); TextEditorRunTrace "Open Window Save Display 2" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but83" "Button240_4" vTcl:WidgetProc "Toplevel240" 1
    bindtags $site_5_0.but83 "$site_5_0.but83 Button $top all _vTclBalloon"
    bind $site_5_0.but83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save}
    }
    button $site_5_0.but67 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1 TMPGnuPlotTk2

Gimp $TMPGnuPlotTk1
Gimp $TMPGnuPlotTk2} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but67" "Button240_6" vTcl:WidgetProc "Toplevel240" 1
    button $site_5_0.but71 \
        -background #ffff00 \
        -command {global GnuplotPipeFid GnuplotPipeCopol GnuplotPipeXpol

if {$GnuplotPipeCopol != ""} {
    catch "close $GnuplotPipeCopol"
    set GnuplotPipeCopol ""
    }
if {$GnuplotPipeXpol != ""} {
    catch "close $GnuplotPipeXpol"
    set GnuplotPipeXpol ""
    }
set GnuplotPipeFid ""
Window hide .top401
Window hide .top402} \
        -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_5_0.but71" "Button240_5" vTcl:WidgetProc "Toplevel240" 1
    pack $site_5_0.but80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra79 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side left 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel240" 1
    set site_3_0 $top.fra92
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolarSignature.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel240" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global PolSigExecFid Load_SaveDisplay2
global GnuplotPipeFid GnuplotPipeCopol GnuplotPipeXpol

if {$Load_SaveDisplay2 == 1} {Window hide $widget(Toplevel457); TextEditorRunTrace "Close Window Save Display 2" "b"}

set ErrorCatch "0"
set ProgressLine ""
set ErrorCatch [catch {puts $PolSigExecFid "exit\n"}]
if { $ErrorCatch == "0" } {
    puts $PolSigExecFid "exit\n"
    flush $PolSigExecFid
    fconfigure $PolSigExecFid -buffering line
    while {$ProgressLine != "OKexit"} {
        gets $PolSigExecFid ProgressLine
        update
        }
    catch "close $PolSigExecFid"
    }
set PolSigExecFid ""
set ProgressLine ""

if {$GnuplotPipeCopol != ""} {
    catch "close $GnuplotPipeCopol"
    set GnuplotPipeCopol ""
    }
if {$GnuplotPipeXpol != ""} {
    catch "close $GnuplotPipeXpol"
    set GnuplotPipeXpol ""
    }
set GnuplotPipeFid ""
Window hide .top401
Window hide .top402    
ClosePSPViewer
Window hide $widget(Toplevel240); TextEditorRunTrace "Close Window Polarimetric Signatures" "b"} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button240_2" vTcl:WidgetProc "Toplevel240" 1
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
Window show .top240

main $argc $argv
