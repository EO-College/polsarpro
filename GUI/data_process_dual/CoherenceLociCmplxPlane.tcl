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
    set base .top332
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd77 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra78 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra78
    namespace eval ::widgets::$site_4_0.fra79 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra79
    namespace eval ::widgets::$site_5_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.com83 {
        array set save {-entrybg 1 -justify 1 -postcommand 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.but81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd85
    namespace eval ::widgets::$site_5_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.com83 {
        array set save {-entrybg 1 -justify 1 -postcommand 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd72 getframe]
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
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd85
    namespace eval ::widgets::$site_7_0.cpd87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd87
    namespace eval ::widgets::$site_8_0.che88 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd74
    namespace eval ::widgets::$site_8_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra77
    namespace eval ::widgets::$site_9_0.lab78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent79 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra73
    namespace eval ::widgets::$site_9_0.rad74 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.rad75 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd71
    namespace eval ::widgets::$site_8_0.che88 {
        array set save {-command 1 -text 1 -variable 1}
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
    namespace eval ::widgets::$base.fra92 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd76
    namespace eval ::widgets::$site_4_0.but80 {
        array set save {-command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.but81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.but83 {
        array set save {-background 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_4_0.but68 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.but71 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
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
            vTclWindow.top332
            LociCmplxPlaneCloseFiles
            LociCmplxPlaneOpenFiles
            LociCmplxPlaneExtract
            LociCmplxPlaneExtractPlot
            LociCmplxPlaneUpdate
            LociCmplxPlaneGammaFiles
            LociCmplxPlaneExtractPlotThumb
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
## Procedure:  LociCmplxPlaneCloseFiles

proc ::LociCmplxPlaneCloseFiles {} {
global LociCmplxPlaneExecFid LociCmplxPlaneFileOpen

if {$LociCmplxPlaneFileOpen == 1 } {
    if {$LociCmplxPlaneExecFid != "" } {
        set ProgressLine ""
        puts $LociCmplxPlaneExecFid "closefile\n"
        flush $LociCmplxPlaneExecFid
        fconfigure $LociCmplxPlaneExecFid -buffering line
        while {$ProgressLine != "OKclosefile"} {
            gets $LociCmplxPlaneExecFid ProgressLine
            update
            }
        set ProgressLine ""
        while {$ProgressLine != "OKfinclosefile"} {
            gets $LociCmplxPlaneExecFid ProgressLine
            update
            }
        set LociCmplxPlaneFileOpen "0"
        }        
    }
}
#############################################################################
## Procedure:  LociCmplxPlaneOpenFiles

proc ::LociCmplxPlaneOpenFiles {} {
global LociCmplxPlaneExecFid LociCmplxPlaneDirInput LociCmplxPlaneFileOpen
global LociCmplxPlaneTopoFile GammaHighFile GammaLowFile 

if {$LociCmplxPlaneFileOpen == 0} {
    if {$LociCmplxPlaneExecFid != ""} {
        set ProgressLine ""
        puts $LociCmplxPlaneExecFid "openfile\n"
        flush $LociCmplxPlaneExecFid
        fconfigure $LociCmplxPlaneExecFid -buffering line
        while {$ProgressLine != "OKopenfile"} {
            gets $LociCmplxPlaneExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $LociCmplxPlaneExecFid "$GammaHighFile\n"
        flush $LociCmplxPlaneExecFid
        fconfigure $LociCmplxPlaneExecFid -buffering line
        while {$ProgressLine != "OKreadgammahigh"} {
            gets $LociCmplxPlaneExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $LociCmplxPlaneExecFid "$GammaLowFile\n"
        flush $LociCmplxPlaneExecFid
        fconfigure $LociCmplxPlaneExecFid -buffering line
        while {$ProgressLine != "OKreadgammalow"} {
            gets $LociCmplxPlaneExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $LociCmplxPlaneExecFid "$LociCmplxPlaneTopoFile\n"
        flush $LociCmplxPlaneExecFid
        fconfigure $LociCmplxPlaneExecFid -buffering line
        while {$ProgressLine != "OKreadtopo"} {
            gets $LociCmplxPlaneExecFid ProgressLine
            update
            }
        set ProgressLine ""
        while {$ProgressLine != "OKfinopenfile"} {
            gets $LociCmplxPlaneExecFid ProgressLine
            update
            }
        }    
    }
    
}
#############################################################################
## Procedure:  LociCmplxPlaneExtract

proc ::LociCmplxPlaneExtract {} {
global LociCmplxPlaneExecFid LociCmplxPlaneExtractVar
global LociCmplxPlaneLoci LociCmplxPlaneLength
global TMPLociCmplxPlaneTxt TMPLociCmplxPlaneLineTxt TMPLociCmplxPlaneLociTxt TMPLociCmplxPlaneTripletTxt
global BMPLociCmplxPlaneX BMPLociCmplxPlaneY

DeleteFile $TMPLociCmplxPlaneTxt
DeleteFile $TMPLociCmplxPlaneLineTxt
DeleteFile $TMPLociCmplxPlaneLociTxt
DeleteFile $TMPLociCmplxPlaneTripletTxt

if {$LociCmplxPlaneExecFid != ""} {
    set ProgressLine ""
    puts $LociCmplxPlaneExecFid "extract\n"
    flush $LociCmplxPlaneExecFid
    fconfigure $LociCmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKextract"} {
        gets $LociCmplxPlaneExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $LociCmplxPlaneExecFid "$BMPLociCmplxPlaneX\n"
    flush $LociCmplxPlaneExecFid
    fconfigure $LociCmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadcol"} {
        gets $LociCmplxPlaneExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $LociCmplxPlaneExecFid "$BMPLociCmplxPlaneY\n"
    flush $LociCmplxPlaneExecFid
    fconfigure $LociCmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadlig"} {
        gets $LociCmplxPlaneExecFid ProgressLine
        update
        }
    set ProgressLine ""
    if {$LociCmplxPlaneLoci == 1} {
        puts $LociCmplxPlaneExecFid "$LociCmplxPlaneLength\n"
        } else {
        puts $LociCmplxPlaneExecFid "11\n"
        }
    flush $LociCmplxPlaneExecFid
    fconfigure $LociCmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadlength"} {
        gets $LociCmplxPlaneExecFid ProgressLine
        update
        }
    set ProgressLine ""
    while {$ProgressLine != "OKfinextract"} {
        gets $LociCmplxPlaneExecFid ProgressLine
        update
        }
    set LociCmplxPlaneExtractVar "true"    
    #ExecFid        
    }        
}
#############################################################################
## Procedure:  LociCmplxPlaneExtractPlot

proc ::LociCmplxPlaneExtractPlot {} {
global LociCmplxPlaneExecFid GnuplotPipeFid
global GnuOutputFormat GnuOutputFile GnuplotPipeLociCmplxPlane
global LociCmplxPlaneLoci LociCmplxPlaneTriplet
global LociCmplxPlaneTitle LociCmplxPlaneLabel
global LociCmplxPlaneExtractVar CohPlot CONFIGDir
global TMPLociCmplxPlaneTxt TMPLociCmplxPlaneLineTxt TMPLociCmplxPlaneLociTxt TMPLociCmplxPlaneTripletTxt
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set LociCmplxPlaneExtractVar "false"
if {$LociCmplxPlaneExecFid != ""} { LociCmplxPlaneExtract }

if {$LociCmplxPlaneExtractVar == "true"} {
    set xwindow [winfo x .top332]; set ywindow [winfo y .top332]

    DeleteFile $TMPGnuPlotTk1
    DeleteFile $TMPGnuPlot1Tk

    if {$GnuplotPipeLociCmplxPlane == ""} {
        GnuPlotInit 0 0 1 1
        set GnuplotPipeLociCmplxPlane $GnuplotPipeFid
        }
    #LociCmplxPlaneExtractPlotThumb        
    set GnuOutputFile $TMPGnuPlotTk1
    set GnuOutputFormat "gif"
    GnuPlotTerm $GnuplotPipeLociCmplxPlane $GnuOutputFormat
  
    puts $GnuplotPipeLociCmplxPlane "load '$CONFIGDir/GnuplotCmplxPlane.txt'"; flush $GnuplotPipeLociCmplxPlane

    set PlotCommand "plot "
    append PlotCommand "'$TMPLociCmplxPlaneTxt' using 1:2 with points pt 2 ps 3 title 'LPC', "
    append PlotCommand "'$TMPLociCmplxPlaneTxt' using 3:4 with points pt 1 ps 3 title 'HPC', "
    append PlotCommand "'$TMPLociCmplxPlaneTxt' using 5:6 with points pt 6 ps 3 title 'ETP', "
    append PlotCommand "'$TMPLociCmplxPlaneLineTxt' using 1:2 with lines notitle"
    
    if {$LociCmplxPlaneLoci == 1} {
        append PlotCommand ", "
        if {$CohPlot == "true"} {
            append PlotCommand "'$TMPLociCmplxPlaneLociTxt' using 1:2 with lines lw 2 title 'TC'"
            }
        if {$CohPlot == "reduced"} {
            append PlotCommand "'$TMPLociCmplxPlaneLociTxt' using 3:4 with lines lw 2 title 'RC'"
            }
        }
    if {$LociCmplxPlaneTriplet == 1} {
        append PlotCommand ", "
        append PlotCommand "'$TMPLociCmplxPlaneTripletTxt' using 1:2 with points pt 2 ps 3 title 'Opt1', "
        append PlotCommand "'$TMPLociCmplxPlaneTripletTxt' using 3:4 with points pt 1 ps 3 title 'Opt2', "
        append PlotCommand "'$TMPLociCmplxPlaneTripletTxt' using 5:6 with points pt 6 ps 3 title 'Opt3'"
        }
    
    puts $GnuplotPipeLociCmplxPlane "$PlotCommand"; flush $GnuplotPipeLociCmplxPlane

    puts $GnuplotPipeLociCmplxPlane "unset output"; flush $GnuplotPipeLociCmplxPlane 

    set ErrorCatch [catch {puts $GnuplotPipeLociCmplxPlane "quit"}]
    if { $ErrorCatch == "0" } {
        puts $GnuplotPipeLociCmplxPlane "quit"; flush $GnuplotPipeLociCmplxPlane 
        }
    catch "close $GnuplotPipeLociCmplxPlane"
    set GnuplotPipeLociCmplxPlane ""

    .top332.fra92.cpd76.but81 configure -state normal
    .top332.fra92.cpd76.but83 configure -state normal
    .top332.fra92.cpd76.but71 configure -state normal
    .top332.fra92.cpd76.but68 configure -state normal

    WaitUntilCreated $TMPGnuPlotTk1
    Gimp $TMPGnuPlotTk1
    #ViewGnuPlotTKThumb 1 .top332 "Complex Plane"
    }
    
}
#############################################################################
## Procedure:  LociCmplxPlaneUpdate

proc ::LociCmplxPlaneUpdate {} {
global PhaseTopChannel PhaseGroundChannel
global LociCmplxPlaneDirInput LociCmplxPlaneList LociCmplxPlaneString
global VarError ErrorMessage

set LociCmplxPlaneList(0) ""
for {set i 1} {$i < 100} {incr i } { set LociCmplxPlaneList($i) "" }

set NumList 1
set LociCmplxPlaneList(1) ""

if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_HH.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HH"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_HH.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HH (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_HV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HV"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_HV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HV (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_VV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "VV"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_VV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "VV (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_HHpVV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HH + VV"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHpVV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HH + VV (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_HHmVV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HH - VV"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHmVV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HH - VV (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_HVpVH.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HV + VH"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_HVpVH.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HV + VH (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_LL.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "LL"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_LL.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "LL (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_LR.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "LR"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_LR.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "LR (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_RR.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "RR"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_RR.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "RR (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_Opt1.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "OPT 1"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt1.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "OPT 1 (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_Opt2.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "OPT 2"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt2.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "OPT 2 (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_Opt3.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "OPT 3"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt3.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "OPT 3 (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR1.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "NR 1"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR1.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "NR 1 (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR2.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "NR 2"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR2.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "NR 2 (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR3.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "NR 3"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR3.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "NR 3 (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_PDHigh.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "PD H"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_PDHigh.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "PD H (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_PDLow.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "PD L"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_PDLow.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "PD L (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_MaxMag.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Max Mag"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_MaxMag.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Max Mag (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_MinMag.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Min Mag"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_MinMag.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Min Mag (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_MaxPha.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Max Pha"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_MaxPha.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Max Pha (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_MinPha.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Min Pha"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_MinPha.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Min Pha (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_MagHigh.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Mag High"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_MagHigh.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Mag High (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_MagLow.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Mag Low"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_MagLow.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Mag Low (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_PhaHigh.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Pha High"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_PhaHigh.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Pha High (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_PhaLow.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Pha Low"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_PhaLow.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "Pha Low (avg)"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_HHVV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HHVV*"
    }
if [file exists "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHVV.bin"] {
    incr NumList
    set LociCmplxPlaneList($NumList) "HHVV* (avg)"
    }

if {$NumList == 1} {              
    set VarError ""
    set ErrorMessage "COMPLEX COHERENCE FILES MUST BE CREATED FIRST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set LociCmplxPlaneString ""
    for {set i 1} {$i <= $NumList} {incr i } { lappend LociCmplxPlaneString $LociCmplxPlaneList($i) }
    .top332.fra76.fra78.fra79.com83 configure -values $LociCmplxPlaneString
    .top332.fra76.fra78.cpd85.com83 configure -values $LociCmplxPlaneString
    set PhaseTopChannel $LociCmplxPlaneList(1)
    set PhaseGroundChannel $LociCmplxPlaneList(1)
    }
}
#############################################################################
## Procedure:  LociCmplxPlaneGammaFiles

proc ::LociCmplxPlaneGammaFiles {} {
global LociCmplxPlaneDirInput
global GammaHighFile GammaLowFile 
global PhaseTopChannel PhaseGroundChannel

set GammaHighFile ""
if {$PhaseTopChannel == "HH" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_HH.bin" }
if {$PhaseTopChannel == "HH (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HH.bin" }
if {$PhaseTopChannel == "HV" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_HV.bin" }
if {$PhaseTopChannel == "HV (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HV.bin" }
if {$PhaseTopChannel == "VV" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_VV.bin" }
if {$PhaseTopChannel == "VV (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_VV.bin" }
if {$PhaseTopChannel == "LL" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_LL.bin" }
if {$PhaseTopChannel == "LL (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_LL.bin" }
if {$PhaseTopChannel == "LR" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_LR.bin" }
if {$PhaseTopChannel == "LR (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_LR.bin" }
if {$PhaseTopChannel == "RR" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_RR.bin" }
if {$PhaseTopChannel == "RR (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_RR.bin" }
if {$PhaseTopChannel == "HH + VV" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_HHpVV.bin" }
if {$PhaseTopChannel == "HH + VV (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHpVV.bin" }
if {$PhaseTopChannel == "HV + VH" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_HVpVH.bin" }
if {$PhaseTopChannel == "HV + VH (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HVpVH.bin" }
if {$PhaseTopChannel == "HH - VV" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_HHmVV.bin" }
if {$PhaseTopChannel == "HH - VV (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHmVV.bin" }
if {$PhaseTopChannel == "OPT 1" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt1.bin" }
if {$PhaseTopChannel == "OPT 1 (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt1.bin" }
if {$PhaseTopChannel == "OPT 2" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt2.bin" }
if {$PhaseTopChannel == "OPT 2 (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt2.bin" }
if {$PhaseTopChannel == "OPT 3" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt3.bin" }
if {$PhaseTopChannel == "OPT 3 (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt3.bin" }
if {$PhaseTopChannel == "NR 1" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR1.bin" }
if {$PhaseTopChannel == "NR 1 (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR1.bin" }
if {$PhaseTopChannel == "NR 2" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR2.bin" }
if {$PhaseTopChannel == "NR 2 (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR2.bin" }
if {$PhaseTopChannel == "NR 3" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR3.bin" }
if {$PhaseTopChannel == "NR 3 (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR3.bin" }
if {$PhaseTopChannel == "PD High" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_PDHigh.bin" }
if {$PhaseTopChannel == "PD High (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_PDHigh.bin" }
if {$PhaseTopChannel == "PD Low" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_PDLow.bin" }
if {$PhaseTopChannel == "PD Low (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_PDLow.bin" }
if {$PhaseTopChannel == "Max Mag" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_MaxMag.bin" }
if {$PhaseTopChannel == "Max Mag (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_MaxMag.bin" }
if {$PhaseTopChannel == "Min Mag" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_MinMag.bin" }
if {$PhaseTopChannel == "Min Mag (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_MinMag.bin" }
if {$PhaseTopChannel == "Max Pha" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_MaxPha.bin" }
if {$PhaseTopChannel == "Max Pha (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_MaxPha.bin" }
if {$PhaseTopChannel == "Min Pha" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_MinPha.bin" }
if {$PhaseTopChannel == "Min Pha (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_MinPha.bin" }
if {$PhaseTopChannel == "Mag High" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_MagHigh.bin" }
if {$PhaseTopChannel == "Mag High (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_MagHigh.bin" }
if {$PhaseTopChannel == "Mag Low" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_MagLow.bin" }
if {$PhaseTopChannel == "Mag Low (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_MagLow.bin" }
if {$PhaseTopChannel == "Pha High" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_PhaHigh.bin" }
if {$PhaseTopChannel == "Pha High (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_PhaHigh.bin" }
if {$PhaseTopChannel == "Pha Low" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_PhaLow.bin" }
if {$PhaseTopChannel == "Pha Low (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_PhaLow.bin" }
if {$PhaseTopChannel == "HHVV*" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_HHVV.bin" }
if {$PhaseTopChannel == "HHVV* (avg)" } { set GammaHighFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHVV.bin" }

set GammaLowFile ""
if {$PhaseGroundChannel == "HH" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_HH.bin" }
if {$PhaseGroundChannel == "HH (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HH.bin" }
if {$PhaseGroundChannel == "HV" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_HV.bin" }
if {$PhaseGroundChannel == "HV (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HV.bin" }
if {$PhaseGroundChannel == "VV" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_VV.bin" }
if {$PhaseGroundChannel == "VV (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_VV.bin" }
if {$PhaseGroundChannel == "LL" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_LL.bin" }
if {$PhaseGroundChannel == "LL (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_LL.bin" }
if {$PhaseGroundChannel == "LR" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_LR.bin" }
if {$PhaseGroundChannel == "LR (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_LR.bin" }
if {$PhaseGroundChannel == "RR" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_RR.bin" }
if {$PhaseGroundChannel == "RR (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_RR.bin" }
if {$PhaseGroundChannel == "HH + VV" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_HHpVV.bin" }
if {$PhaseGroundChannel == "HH + VV (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHpVV.bin" }
if {$PhaseGroundChannel == "HV + VH" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_HVpVH.bin" }
if {$PhaseGroundChannel == "HV + VH (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HVpVH.bin" }
if {$PhaseGroundChannel == "HH - VV" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_HHmVV.bin" }
if {$PhaseGroundChannel == "HH - VV (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHmVV.bin" }
if {$PhaseGroundChannel == "OPT 1" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt1.bin" }
if {$PhaseGroundChannel == "OPT 1 (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt1.bin" }
if {$PhaseGroundChannel == "OPT 2" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt2.bin" }
if {$PhaseGroundChannel == "OPT 2 (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt2.bin" }
if {$PhaseGroundChannel == "OPT 3" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt3.bin" }
if {$PhaseGroundChannel == "OPT 3 (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt3.bin" }
if {$PhaseGroundChannel == "NR 1" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR1.bin" }
if {$PhaseGroundChannel == "NR 1 (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR1.bin" }
if {$PhaseGroundChannel == "NR 2" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR2.bin" }
if {$PhaseGroundChannel == "NR 2 (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR2.bin" }
if {$PhaseGroundChannel == "NR 3" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_Opt_NR3.bin" }
if {$PhaseGroundChannel == "NR 3 (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_Opt_NR3.bin" }
if {$PhaseGroundChannel == "PD High" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_PDHigh.bin" }
if {$PhaseGroundChannel == "PD High (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_PDHigh.bin" }
if {$PhaseGroundChannel == "PD Low" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_PDLow.bin" }
if {$PhaseGroundChannel == "PD Low (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_PDLow.bin" }
if {$PhaseGroundChannel == "Max Mag" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_MaxMag.bin" }
if {$PhaseGroundChannel == "Max Mag (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_MaxMag.bin" }
if {$PhaseGroundChannel == "Min Mag" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_MinMag.bin" }
if {$PhaseGroundChannel == "Min Mag (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_MinMag.bin" }
if {$PhaseGroundChannel == "Max Pha" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_MaxPha.bin" }
if {$PhaseGroundChannel == "Max Pha (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_MaxPha.bin" }
if {$PhaseGroundChannel == "Min Pha" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_MinPha.bin" }
if {$PhaseGroundChannel == "Min Pha (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_MinPha.bin" }
if {$PhaseGroundChannel == "Mag High" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_MagHigh.bin" }
if {$PhaseGroundChannel == "Mag High (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_MagHigh.bin" }
if {$PhaseGroundChannel == "Mag Low" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_MagLow.bin" }
if {$PhaseGroundChannel == "Mag Low (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_MagLow.bin" }
if {$PhaseGroundChannel == "Pha High" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_PhaHigh.bin" }
if {$PhaseGroundChannel == "Pha High (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_PhaHigh.bin" }
if {$PhaseGroundChannel == "Pha Low" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_maxdiff_PhaLow.bin" }
if {$PhaseGroundChannel == "Pha Low (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_maxdiff_PhaLow.bin" }
if {$PhaseGroundChannel == "HHVV*" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_HHVV.bin" }
if {$PhaseGroundChannel == "HHVV* (avg)" } { set GammaLowFile "$LociCmplxPlaneDirInput/cmplx_coh_avg_HHVV.bin" }
}
#############################################################################
## Procedure:  LociCmplxPlaneExtractPlotThumb

proc ::LociCmplxPlaneExtractPlotThumb {} {
global LociCmplxPlaneExecFid GnuplotPipeFid
global GnuOutputFormat GnuOutputFile GnuplotPipeLociCmplxPlane
global LociCmplxPlaneLoci LociCmplxPlaneTriplet
global LociCmplxPlaneTitle LociCmplxPlaneLabel
global LociCmplxPlaneExtractVar CohPlot CONFIGDir
global TMPLociCmplxPlaneTxt TMPLociCmplxPlaneLineTxt TMPLociCmplxPlaneLociTxt TMPLociCmplxPlaneTripletTxt
global TMPGnuPlotTk1 TMPGnuPlot1Tk

    set xwindow [winfo x .top332]; set ywindow [winfo y .top332]

    DeleteFile $TMPGnuPlot1Tk
    set GnuOutputFile $TMPGnuPlot1Tk
    set GnuOutputFormat "png"
    GnuPlotTerm $GnuplotPipeLociCmplxPlane $GnuOutputFormat
  
    puts $GnuplotPipeLociCmplxPlane "load '$CONFIGDir/GnuplotCmplxPlane.txt'"; flush $GnuplotPipeLociCmplxPlane

    set PlotCommand "plot "
    append PlotCommand "'$TMPLociCmplxPlaneTxt' using 1:2 with points pt 2 ps 3 title 'LPC', "
    append PlotCommand "'$TMPLociCmplxPlaneTxt' using 3:4 with points pt 1 ps 3 title 'HPC', "
    append PlotCommand "'$TMPLociCmplxPlaneTxt' using 5:6 with points pt 6 ps 3 title 'ETP', "
    append PlotCommand "'$TMPLociCmplxPlaneLineTxt' using 1:2 with lines notitle"
    
    if {$LociCmplxPlaneLoci == 1} {
        append PlotCommand ", "
        if {$CohPlot == "true"} {
            append PlotCommand "'$TMPLociCmplxPlaneLociTxt' using 1:2 with lines lw 2 title 'TC'"
            }
        if {$CohPlot == "reduced"} {
            append PlotCommand "'$TMPLociCmplxPlaneLociTxt' using 3:4 with lines lw 2 title 'RC'"
            }
        }
    if {$LociCmplxPlaneTriplet == 1} {
        append PlotCommand ", "
        append PlotCommand "'$TMPLociCmplxPlaneTripletTxt' using 1:2 with points pt 2 ps 3 title 'Opt1', "
        append PlotCommand "'$TMPLociCmplxPlaneTripletTxt' using 3:4 with points pt 1 ps 3 title 'Opt2', "
        append PlotCommand "'$TMPLociCmplxPlaneTripletTxt' using 5:6 with points pt 6 ps 3 title 'Opt3'"
        }
    
    puts $GnuplotPipeLociCmplxPlane "$PlotCommand"; flush $GnuplotPipeLociCmplxPlane

    puts $GnuplotPipeLociCmplxPlane "unset output"; flush $GnuplotPipeLociCmplxPlane 

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
    wm geometry $top 200x200+250+250; update
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

proc vTclWindow.top332 {base} {
    if {$base == ""} {
        set base .top332
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
    wm geometry $top 500x380+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Coherences Loci - Complex Plane"
    vTcl:DefineAlias "$top" "Toplevel332" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame13" vTcl:WidgetProc "Toplevel332" 1
    set site_3_0 $top.fra76
    TitleFrame $site_3_0.cpd77 \
        -text {Topographic Phase File} 
    vTcl:DefineAlias "$site_3_0.cpd77" "TitleFrame332_1" vTcl:WidgetProc "Toplevel332" 1
    bind $site_3_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd77 getframe]
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable LociCmplxPlaneTopoFile 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry332_2" vTcl:WidgetProc "Toplevel332" 1
    button $site_5_0.but76 \
        \
        -command {global FileName LociCmplxPlaneDirInput LociCmplxPlaneTopoFile
global WarningMessage WarningMessage2 VarAdvice
global GammaHighFile GammaLowFile LociCmplxPlaneList
global PhaseTopChannel PhaseGroundChannel

LociCmplxPlaneCloseFiles
MouseActiveFunction "LensLOCICMPLXPLANEoff"
$widget(Button332_5) configure -state normal
set GammaHighFile ""
set GammaLowFile ""
set PhaseTopChannel $LociCmplxPlaneList(1)
set PhaseGroundChannel $LociCmplxPlaneList(1)

set WarningMessage "THE TOPOGRAPHIC PHASE FILE MUST HAVE THE SAME"
set WarningMessage2 "DATA SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Topo File}        {.dat}        }
{{Topo File}        {.bin}        }
}
set FileName ""
OpenFile "$LociCmplxPlaneDirInput" $types "TOPOGRAPHIC PHASE FILE"
if {$FileName != ""} {
    set LociCmplxPlaneTopoFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but76" "Button332_4" vTcl:WidgetProc "Toplevel332" 1
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.but76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_3_0.fra78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra78" "Frame14" vTcl:WidgetProc "Toplevel332" 1
    set site_4_0 $site_3_0.fra78
    frame $site_4_0.fra79 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra79" "Frame15" vTcl:WidgetProc "Toplevel332" 1
    set site_5_0 $site_4_0.fra79
    label $site_5_0.lab82 \
        -text {Top Phase Centre} 
    vTcl:DefineAlias "$site_5_0.lab82" "Label332_2" vTcl:WidgetProc "Toplevel332" 1
    ComboBox $site_5_0.com83 \
        -entrybg white -justify center \
        -postcommand {global GammaHighFile GammaLowFile LociCmplxPlaneList

LociCmplxPlaneCloseFiles
MouseActiveFunction "LensLOCICMPLXPLANEoff"
$widget(Button332_5) configure -state normal
set GammaHighFile ""
set GammaLowFile ""} \
        -takefocus 1 -textvariable PhaseTopChannel -width 12 
    vTcl:DefineAlias "$site_5_0.com83" "ComboBox332_2" vTcl:WidgetProc "Toplevel332" 1
    bindtags $site_5_0.com83 "$site_5_0.com83 BwComboBox $top all"
    pack $site_5_0.lab82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.com83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    button $site_4_0.but81 \
        -background #ffff00 \
        -command {global LociCmplxPlaneTopoFile PhaseTopChannel PhaseGroundChannel
global OpenDirFile LociCmplxPlaneFileOpen LociCmplxPlaneList 

if {$OpenDirFile == 0} {

set config ""
if {$PhaseTopChannel != ""} {
    append config "high"
    } else {
    set VarError ""
    set ErrorMessage "SELECT THE TOP PHASE CENTRE CHANNEL"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$PhaseGroundChannel != ""} {
    append config "low"
    } else {
    set VarError ""
    set ErrorMessage "SELECT THE GROUND PHASE CENTRE CHANNEL"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$LociCmplxPlaneTopoFile != ""} {
    append config "topo"
    } else {
    set VarError ""
    set ErrorMessage "SELECT THE TOPOGRAPHIC PHASE FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$config == "highlowtopo"} {
    LociCmplxPlaneGammaFiles
    LociCmplxPlaneOpenFiles
    MouseActiveFunction "LensLOCICMPLXPLANEon"
    $widget(Button332_5) configure -state disable
    $widget(Checkbutton332_1) configure -state normal
    $widget(Checkbutton332_2) configure -state normal
    set LociCmplxPlaneFileOpen 1
    #config
    }
#OpenDir
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_4_0.but81" "Button332_5" vTcl:WidgetProc "Toplevel332" 1
    frame $site_4_0.cpd85 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd85" "Frame16" vTcl:WidgetProc "Toplevel332" 1
    set site_5_0 $site_4_0.cpd85
    label $site_5_0.lab82 \
        -text {Ground Phase Centre} 
    vTcl:DefineAlias "$site_5_0.lab82" "Label332_3" vTcl:WidgetProc "Toplevel332" 1
    ComboBox $site_5_0.com83 \
        -entrybg white -justify center \
        -postcommand {global GammaHighFile GammaLowFile LociCmplxPlaneList
global PhaseTopChannel PhaseGroundChannel

LociCmplxPlaneCloseFiles
MouseActiveFunction "LensLOCICMPLXPLANEoff"
$widget(Button332_5) configure -state normal
set GammaHighFile ""
set GammaLowFile ""} \
        -takefocus 1 -textvariable PhaseGroundChannel -width 12 
    vTcl:DefineAlias "$site_5_0.com83" "ComboBox332_3" vTcl:WidgetProc "Toplevel332" 1
    bindtags $site_5_0.com83 "$site_5_0.com83 BwComboBox $top all"
    pack $site_5_0.lab82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.com83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_4_0.fra79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -ipady 2 -side left 
    pack $site_4_0.but81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill none -ipady 2 -side left 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra78 \
        -in $site_3_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame5" vTcl:WidgetProc "Toplevel332" 1
    set site_3_0 $top.fra73
    button $site_3_0.but75 \
        -background #ffff00 -command LociCmplxPlaneUpdate -padx 4 -pady 2 \
        -text {Update list} 
    vTcl:DefineAlias "$site_3_0.but75" "Button4" vTcl:WidgetProc "Toplevel332" 1
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel332" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel332" 1
    set site_4_0 $site_3_0.cpd78
    canvas $site_4_0.can73 \
        -borderwidth 2 -closeenough 1.0 -height 200 -relief ridge -width 200 
    vTcl:DefineAlias "$site_4_0.can73" "CANVASLENSLOCICMPLXPLANE" vTcl:WidgetProc "Toplevel332" 1
    bind $site_4_0.can73 <Button-1> {
        MouseButtonDownLens %x %y
    }
    pack $site_4_0.can73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel332" 1
    set site_4_0 $site_3_0.fra72
    TitleFrame $site_4_0.cpd72 \
        -ipad 2 -text {Mouse Position} 
    vTcl:DefineAlias "$site_4_0.cpd72" "TitleFrame4" vTcl:WidgetProc "Toplevel332" 1
    bind $site_4_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd72 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame33" vTcl:WidgetProc "Toplevel332" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame34" vTcl:WidgetProc "Toplevel332" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_8_0.lab76" "Label33" vTcl:WidgetProc "Toplevel332" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseX -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry58" vTcl:WidgetProc "Toplevel332" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame35" vTcl:WidgetProc "Toplevel332" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_8_0.lab76" "Label34" vTcl:WidgetProc "Toplevel332" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseY -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry59" vTcl:WidgetProc "Toplevel332" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame36" vTcl:WidgetProc "Toplevel332" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab76 \
        -relief groove -text Val -width 4 
    vTcl:DefineAlias "$site_8_0.lab76" "Label35" vTcl:WidgetProc "Toplevel332" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPValue -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry60" vTcl:WidgetProc "Toplevel332" 1
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
    TitleFrame $site_4_0.cpd77 \
        -ipad 1 -text Representation 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame6" vTcl:WidgetProc "Toplevel332" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    frame $site_6_0.cpd85 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd85" "Frame1" vTcl:WidgetProc "Toplevel332" 1
    set site_7_0 $site_6_0.cpd85
    frame $site_7_0.cpd87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd87" "Frame2" vTcl:WidgetProc "Toplevel332" 1
    set site_8_0 $site_7_0.cpd87
    checkbutton $site_8_0.che88 \
        \
        -command {global LociCmplxPlaneLoci LociCmplxPlaneLength CohPlot

if {$LociCmplxPlaneLoci == 1 } {
    $widget(Label332_1) configure -state normal
    $widget(Entry332_1) configure -state normal
    $widget(Radiobutton332_1) configure -state normal
    $widget(Radiobutton332_2) configure -state normal
    set LociCmplxPlaneLength 11; set CohPlot "true"
    } else {
    $widget(Label332_1) configure -state disable
    $widget(Entry332_1) configure -state disable
    $widget(Radiobutton332_1) configure -state disable
    $widget(Radiobutton332_2) configure -state disable
    set LociCmplxPlaneLength ""; set CohPlot " "
    }} \
        -text {Estimated Standard Coherence Region} \
        -variable LociCmplxPlaneLoci 
    vTcl:DefineAlias "$site_8_0.che88" "Checkbutton332_1" vTcl:WidgetProc "Toplevel332" 1
    pack $site_8_0.che88 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd74 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd74" "Frame6" vTcl:WidgetProc "Toplevel332" 1
    set site_8_0 $site_7_0.cpd74
    frame $site_8_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra77" "Frame9" vTcl:WidgetProc "Toplevel332" 1
    set site_9_0 $site_8_0.fra77
    label $site_9_0.lab78 \
        -text {Area Size (pix)} 
    vTcl:DefineAlias "$site_9_0.lab78" "Label332_1" vTcl:WidgetProc "Toplevel332" 1
    entry $site_9_0.ent79 \
        -background white -disabledforeground SystemDisabledText \
        -foreground #ff0000 -justify center -state disabled \
        -textvariable LociCmplxPlaneLength -width 5 
    vTcl:DefineAlias "$site_9_0.ent79" "Entry332_1" vTcl:WidgetProc "Toplevel332" 1
    pack $site_9_0.lab78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent79 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $site_8_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra73" "Frame11" vTcl:WidgetProc "Toplevel332" 1
    set site_9_0 $site_8_0.fra73
    radiobutton $site_9_0.rad74 \
        -text {True Coherence       } -value true -variable CohPlot 
    vTcl:DefineAlias "$site_9_0.rad74" "Radiobutton332_1" vTcl:WidgetProc "Toplevel332" 1
    radiobutton $site_9_0.rad75 \
        -text {Reduced Coherence} -value reduced -variable CohPlot 
    vTcl:DefineAlias "$site_9_0.rad75" "Radiobutton332_2" vTcl:WidgetProc "Toplevel332" 1
    pack $site_9_0.rad74 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    pack $site_9_0.rad75 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    pack $site_8_0.fra77 \
        -in $site_8_0 -anchor center -expand 0 -fill x -side left 
    pack $site_8_0.fra73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side top 
    frame $site_7_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame10" vTcl:WidgetProc "Toplevel332" 1
    set site_8_0 $site_7_0.cpd71
    checkbutton $site_8_0.che88 \
        -command {} -text {Estimated Optimum Coherence Triplet} \
        -variable LociCmplxPlaneTriplet 
    vTcl:DefineAlias "$site_8_0.che88" "Checkbutton332_2" vTcl:WidgetProc "Toplevel332" 1
    pack $site_8_0.che88 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd87 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 5 -side top 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side top 
    frame $site_4_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame7" vTcl:WidgetProc "Toplevel332" 1
    set site_5_0 $site_4_0.cpd75
    TitleFrame $site_5_0.cpd76 \
        -ipad 2 -text {Pixel Values} 
    vTcl:DefineAlias "$site_5_0.cpd76" "TitleFrame7" vTcl:WidgetProc "Toplevel332" 1
    bind $site_5_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame41" vTcl:WidgetProc "Toplevel332" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame42" vTcl:WidgetProc "Toplevel332" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label30" vTcl:WidgetProc "Toplevel332" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPLociCmplxPlaneX -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry55" vTcl:WidgetProc "Toplevel332" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame43" vTcl:WidgetProc "Toplevel332" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label31" vTcl:WidgetProc "Toplevel332" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPLociCmplxPlaneY -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry56" vTcl:WidgetProc "Toplevel332" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd75" "Frame44" vTcl:WidgetProc "Toplevel332" 1
    set site_9_0 $site_8_0.cpd75
    label $site_9_0.lab76 \
        -relief groove -text Val -width 4 
    vTcl:DefineAlias "$site_9_0.lab76" "Label32" vTcl:WidgetProc "Toplevel332" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPLociCmplxPlaneValue -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry57" vTcl:WidgetProc "Toplevel332" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.cpd75 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side left 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel332" 1
    set site_3_0 $top.fra92
    frame $site_3_0.cpd76 \
        -borderwidth 2 -relief sunken -height 75 -width 100 
    vTcl:DefineAlias "$site_3_0.cpd76" "Frame12" vTcl:WidgetProc "Toplevel332" 1
    set site_4_0 $site_3_0.cpd76
    button $site_4_0.but80 \
        \
        -command {global BMPLens LineXLensInit LineYLensInit LineXLens LineYLens plot2 line_color

if {$line_color == "white"} {
    set line_color "black"
    } else {
    set line_color "white"
    }

set b .top332.fra92.cpd76.but80
$b configure -background $line_color -foreground $line_color

$widget(CANVASLENSLOCICMPLXPLANE) dtag LineXLensInit
$widget(CANVASLENSLOCICMPLXPLANE) dtag LineYLensInit
$widget(CANVASLENSLOCICMPLXPLANE) create image 0 0 -anchor nw -image BMPLens
set LineXLensInit {0 0}
set LineYLensInit {0 0}
set LineXLens [$widget(CANVASLENSLOCICMPLXPLANE) create line 0 0 0 $SizeLens -fill $line_color -width 2]
set LineYLens [$widget(CANVASLENSLOCICMPLXPLANE) create line 0 0 $SizeLens 0 -fill $line_color -width 2]
$widget(CANVASLENSLOCICMPLXPLANE) addtag LineXLensInit withtag $LineXLens
$widget(CANVASLENSLOCICMPLXPLANE) addtag LineYLensInit withtag $LineYLens
set plot2(lastX) 0
set plot2(lastY) 0} \
        -pady 0 -relief ridge -text {   } 
    vTcl:DefineAlias "$site_4_0.but80" "Button3" vTcl:WidgetProc "Toplevel332" 1
    button $site_4_0.but81 \
        -background #ffff00 \
        -command {global GnuplotPipeLociCmplxPlane GnuOutputFormat CONFIGDir

if {$GnuplotPipeLociCmplxPlane != ""} {
    if {$GnuOutputFormat == "SCREEN"} {
        puts $GnuplotPipeLociCmplxPlane "clear"; flush $GnuplotPipeLociCmplxPlane
        puts $GnuplotPipeLociCmplxPlane "reset"; flush $GnuplotPipeLociCmplxPlane
        }
    puts $GnuplotPipeLociCmplxPlane "load '$CONFIGDir/GnuplotCmplxPlane.txt'"; flush $GnuplotPipeLociCmplxPlane
    }} \
        -padx 4 -pady 2 -text Clear 
    vTcl:DefineAlias "$site_4_0.but81" "Button332_1" vTcl:WidgetProc "Toplevel332" 1
    button $site_4_0.but83 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput LociCmplxPlaneDirOutput
global GnuplotPipeFid
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

    set SaveDisplayDirOutput $LociCmplxPlaneDirOutput
    set SaveDisplay1OutputFile1 "Coherence_Loci_Complex_Plane"
    
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel332) $widget(Toplevel456); TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_4_0.but83" "Button332_2" vTcl:WidgetProc "Toplevel332" 1
    button $site_4_0.but68 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1

Gimp $TMPGnuPlotTk1} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text { } 
    vTcl:DefineAlias "$site_4_0.but68" "Button332_6" vTcl:WidgetProc "Toplevel332" 1
    button $site_4_0.but71 \
        -background #ffff00 \
        -command {global GnuplotPipeFid GnuplotPipeLociCmplxPlane

if {$GnuplotPipeLociCmplxPlane != ""} {
    catch "close $GnuplotPipeLociCmplxPlane"
    set GnuplotPipeLociCmplxPlane ""
    }
set GnuplotPipeFid ""
Window hide .top401
.top332.fra92.cpd76.but81 configure -state disable
.top332.fra92.cpd76.but83 configure -state disable
.top332.fra92.cpd76.but71 configure -state disable} \
        -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_4_0.but71" "Button332_3" vTcl:WidgetProc "Toplevel332" 1
    pack $site_4_0.but80 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.but81 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.but83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.but68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.but71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CoherenceLociCmplxPlane.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel332" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global LociCmplxPlaneExecFid GnuplotPipeFid GnuplotPipeLociCmplxPlane Load_SaveDisplay1

if {$OpenDirFile == 0} {

if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}

set ErrorCatch "0"
set ProgressLine ""
set ErrorCatch [catch {puts $LociCmplxPlaneExecFid "exit\n"}]
if { $ErrorCatch == "0" } {
    puts $LociCmplxPlaneExecFid "exit\n"
    flush $LociCmplxPlaneExecFid
    fconfigure $LociCmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKexit"} {
        gets $LociCmplxPlaneExecFid ProgressLine
        update
        }
    catch "close $LociCmplxPlaneExecFid"
    }
set LociCmplxPlaneExecFid ""

if {$GnuplotPipeLociCmplxPlane != ""} {
    catch "close $GnuplotPipeLociCmplxPlane"
    set GnuplotPipeLociCmplxPlane ""
    }
set GnuplotPipeFid ""
Window hide .top401
ClosePSPViewer
Window hide $widget(Toplevel332); TextEditorRunTrace "Close Window Coherences - Complex Plane" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button332_0" vTcl:WidgetProc "Toplevel332" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.cpd76 \
        -in $site_3_0 -anchor center -expand 0 -fill none -ipadx 25 -ipady 3 \
        -padx 5 -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra76 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra92 \
        -in $top -anchor center -expand 0 -fill x -side top 

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
Window show .top332

main $argc $argv
