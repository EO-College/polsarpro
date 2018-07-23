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

        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images color-rgb.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images DecrDir.gif]} {user image} user {}}
        {{[file join . GUI Images HomeDir.gif]} {user image} user {}}

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
    set base .top300
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra69
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra81
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd82 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra81
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit95 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit95 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.but69 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit96 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit96 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd97
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd90
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd98
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd90
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd90
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top300
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
    wm geometry $top 200x200+22+22; update
    wm maxsize $top 1284 785
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

proc vTclWindow.top300 {base} {
    if {$base == ""} {
        set base .top300
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
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Environment"
    vTcl:DefineAlias "$top" "Toplevel300" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra69" "Frame1" vTcl:WidgetProc "Toplevel300" 1
    set site_3_0 $top.fra69
    button $site_3_0.cpd71 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/EnvironmentDual.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -padx 1 -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.cpd71" "Button12" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_3_0.cpd71 "$site_3_0.cpd71 Button $top all _vTclBalloon"
    bind $site_3_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.cpd70 \
        -background #ffff00 \
        -command {global ViewerName WidthBMP HeightBMP WidthBMPNew HeightBMPNew OpenDirFile CONFIGDir
global DataDirTmp1 DataDirChannel1 DataDirTmp2 DataDirChannel2

if {$OpenDirFile == 0} {

set HeightWidthBMPChange 0
if {$WidthBMPNew != $WidthBMP } {set HeightWidthBMPChange 1}
if {$HeightBMPNew != $HeightBMP } {set HeightWidthBMPChange 1}
if {$HeightWidthBMPChange == 1 } {
    #####################################################################
    set WarningMessage "DISPLAY SIZE HAS CHANGED"
    set WarningMessage2 "DO YOU WISH TO SAVE ?"
    set VarWarning ""
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set WidthBMP $WidthBMPNew
        set HeightBMP $HeightBMPNew
        set f [open "$CONFIGDir/Viewer.txt" w]
        puts $f $ViewerName
        puts $f "Width"
        puts $f $WidthBMP
        puts $f "Height"
        puts $f $HeightBMP
        close $f
        } else {
        set WidthBMPNew $WidthBMP
        set HeightBMPNew $HeightBMP
        }
    set HeightWidthBMPChange 0
    ##################################################################### 
    }    
if {$DataDirTmp1 != $DataDirChannel1 || $DataDirTmp2 != $DataDirChannel2 } {
    #MenuRAZ
    CloseAllWidget
    }
CheckEnvironnement
set DataDirTmp1 $DataDirChannel1
set DataDirTmp2 $DataDirChannel2
Window hide $widget(Toplevel300); TextEditorRunTrace "Close Window Environment Dual" "b"
}} \
        -padx 4 -pady 2 -text {Save & Exit} 
    bindtags $site_3_0.cpd70 "$site_3_0.cpd70 Button $top all _vTclBalloon"
    bind $site_3_0.cpd70 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save Configuration and Exit the Function}
    }
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit92 \
        -ipad 0 -text {Main Input Master Directory} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame300_1" vTcl:WidgetProc "Toplevel300" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    entry $site_4_0.cpd79 \
        -background #ffffff -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DataDirChannel1 
    vTcl:DefineAlias "$site_4_0.cpd79" "Entry300_1" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Entry $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Main Directory}
    }
    frame $site_4_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra81" "Frame5" vTcl:WidgetProc "Toplevel300" 1
    set site_5_0 $site_4_0.fra81
    button $site_5_0.cpd82 \
        \
        -command {global ActiveProgram ConfigFile PolarType
global DirName DataDirChannel1 BMPDirInput DataDirTmp1

MenuOff
set DataDirTmp1 $DataDirChannel1
set DirName ""
if {$ActiveProgram == "POLINSAR"} {OpenDir "$DataDirChannel1" "DATA INPUT MASTER DIRECTORY"}
if {$ActiveProgram == "DUALFREQ"} {OpenDir "$DataDirChannel1" "DATA INPUT FREQUENCY CHANNEL 1 DIRECTORY"}
if {$DirName != ""} {
    set DataDirChannel1 $DirName
    } else {
    set DataDirChannel1 $DataDirTmp1
    }

set BMPDirInput $DataDirChannel1

CheckEnvBinData} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd82" "Button300_1" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_5_0.cpd82 "$site_5_0.cpd82 Button $top all _vTclBalloon"
    bind $site_5_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Directory}
    }
    button $site_5_0.cpd72 \
        \
        -command {global DataDirChannel1 OpenDirFile DataDirTmp1

if {$OpenDirFile == 0} {
set DataDirTmp1 $DataDirChannel1
MenuOff
set DataDirChannel1 [file dirname $DataDirChannel1]
CheckEnvBinData
}} \
        -image [vTcl:image:get_image [file join . GUI Images DecrDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button300_2" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Parent Directory}
    }
    button $site_5_0.cpd73 \
        \
        -command {global DataDirChannel1 OpenDirFile DataDirTmp1

if {$OpenDirFile == 0} {
set DataDirTmp1 $DataDirChannel1
MenuOff
set DataDirChannel1 $env(HOME)
CheckEnvBinData
}} \
        -image [vTcl:image:get_image [file join . GUI Images HomeDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button300_3" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Home Directory}
    }
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd82 \
        -ipad 0 -text {Main Input Slave Directory} 
    vTcl:DefineAlias "$top.cpd82" "TitleFrame300_2" vTcl:WidgetProc "Toplevel300" 1
    bind $top.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd82 getframe]
    entry $site_4_0.cpd79 \
        -background #ffffff -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DataDirChannel2 
    vTcl:DefineAlias "$site_4_0.cpd79" "Entry300_2" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Entry $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Main Directory}
    }
    frame $site_4_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra81" "Frame8" vTcl:WidgetProc "Toplevel300" 1
    set site_5_0 $site_4_0.fra81
    button $site_5_0.cpd82 \
        \
        -command {global ActiveProgram ConfigFile PolarType
global DirName DataDirChannel2 DataDirTmp2

MenuOff
set DataDirTmp2 $DataDirChannel2
set DirName ""
if {$ActiveProgram == "POLINSAR"} {OpenDir "$DataDirChannel2" "DATA INPUT SLAVE DIRECTORY"}
if {$ActiveProgram == "DUALFREQ"} {OpenDir "$DataDirChannel2" "DATA INPUT FREQUENCY CHANNEL 2 DIRECTORY"}
if {$DirName != ""} {
    set DataDirChannel2 $DirName
    } else {
    set DataDirChannel2 $DataDirTmp2
    }

CheckEnvBinData} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd82" "Button300_4" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_5_0.cpd82 "$site_5_0.cpd82 Button $top all _vTclBalloon"
    bind $site_5_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Directory}
    }
    button $site_5_0.cpd72 \
        \
        -command {global DataDirChannel2 OpenDirFile DataDirTmp2

if {$OpenDirFile == 0} {
set DataDirTmp2 $DataDirChannel2
MenuOff
set DataDirChannel2 [file dirname $DataDirChannel2]
CheckEnvBinData
}} \
        -image [vTcl:image:get_image [file join . GUI Images DecrDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button300_5" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Parent Directory}
    }
    button $site_5_0.cpd73 \
        \
        -command {global DataDirChannel2 OpenDirFile DataDirTmp2

if {$OpenDirFile == 0} {
set DataDirTmp2 $DataDirChannel2
MenuOff
set DataDirChannel2 $env(HOME)
CheckEnvBinData
}} \
        -image [vTcl:image:get_image [file join . GUI Images HomeDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button300_6" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Home Directory}
    }
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.tit95 \
        -text {Display Size} 
    vTcl:DefineAlias "$top.tit95" "TitleFrame2" vTcl:WidgetProc "Toplevel300" 1
    bind $top.tit95 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit95 getframe]
    frame $site_4_0.cpd71 \
        -borderwidth 2 -relief ridge -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame2" vTcl:WidgetProc "Toplevel300" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab73 \
        -relief sunken -text Rows -width 10 
    vTcl:DefineAlias "$site_5_0.lab73" "Label1" vTcl:WidgetProc "Toplevel300" 1
    label $site_5_0.cpd71 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable HeightBMPNew -width 10 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label7" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_5_0.cpd71 "$site_5_0.cpd71 Label $top all _vTclBalloon"
    bind $site_5_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {DIsplay Screen Height Size}
    }
    button $site_5_0.but75 \
        \
        -command {global HeightBMPNew

set HeightTMP [expr $HeightBMPNew +100]
set HeightMax [lindex [wm maxsize $widget(Toplevel300)] 0 ]
if {$HeightTMP < $HeightMax } {
    set HeightBMPNew $HeightTMP
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button5" vTcl:WidgetProc "Toplevel300" 1
    button $site_5_0.but76 \
        \
        -command {global HeightBMPNew

set HeightTMP [expr $HeightBMPNew -100]
if {$HeightTMP > 0 } {
    set HeightBMPNew $HeightTMP
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but76" "Button6" vTcl:WidgetProc "Toplevel300" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd77 \
        -borderwidth 2 -relief ridge -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame4" vTcl:WidgetProc "Toplevel300" 1
    set site_5_0 $site_4_0.cpd77
    label $site_5_0.lab73 \
        -relief sunken -text Columns -width 10 
    vTcl:DefineAlias "$site_5_0.lab73" "Label6" vTcl:WidgetProc "Toplevel300" 1
    label $site_5_0.cpd72 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable WidthBMPNew -width 10 
    vTcl:DefineAlias "$site_5_0.cpd72" "Label8" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Label $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {DIsplay Screen Width Size}
    }
    button $site_5_0.but75 \
        \
        -command {global WidthBMPNew

set WidthTMP [expr $WidthBMPNew +100]
set WidthMax [lindex [wm maxsize $widget(Toplevel300)] 0 ]
if {$WidthTMP < $WidthMax } {
    set WidthBMPNew $WidthTMP
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button7" vTcl:WidgetProc "Toplevel300" 1
    button $site_5_0.but76 \
        \
        -command {global WidthBMPNew

set WidthTMP [expr $WidthBMPNew -100]
if {$WidthTMP > 0 } {
    set WidthBMPNew $WidthTMP
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but76" "Button8" vTcl:WidgetProc "Toplevel300" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    button $site_4_0.but69 \
        -background #ffff00 \
        -command {global ViewerName WidthBMP HeightBMP WidthBMPNew HeightBMPNew OpenDirFile CONFIGDir

if {$OpenDirFile == 0} {
set WidthBMP $WidthBMPNew
set HeightBMP $HeightBMPNew

set f [open "$CONFIGDir/Viewer.txt" w]
puts $f $ViewerName
puts $f "Width"
puts $f $WidthBMP
puts $f "Height"
puts $f $HeightBMP
close $f
}} \
        -padx 4 -pady 2 -text Update 
    vTcl:DefineAlias "$site_4_0.but69" "Button9" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_4_0.but69 "$site_4_0.but69 Button $top all _vTclBalloon"
    bind $site_4_0.but69 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Update the Display Size}
    }
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.but69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit96 \
        -ipad 0 -text {Color Maps} 
    vTcl:DefineAlias "$top.tit96" "TitleFrame3" vTcl:WidgetProc "Toplevel300" 1
    bind $top.tit96 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit96 getframe]
    frame $site_4_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd97" "Frame6" vTcl:WidgetProc "Toplevel300" 1
    set site_5_0 $site_4_0.cpd97
    frame $site_5_0.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd90" "Frame9" vTcl:WidgetProc "Toplevel300" 1
    set site_6_0 $site_5_0.cpd90
    button $site_6_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_6_0.cpd89 {global ColorMapWishart8 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette COLORMAPDir
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMapWishart8 "$COLORMAPDir/Wishart_ColorMap8.pal"
set ColorMapNumber 8
set ColorNumber "256"
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMapWishart8] {
    set f [open $ColorMapWishart8 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMapWishart8
set ColorMapOut $ColorMapWishart8
WidgetShowFromWidget $widget(Toplevel300) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapWishart8 $ColorMapOut
   }}] \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button2" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Colormap}
    }
    label $site_6_0.lab85 \
        -text {Unsupervized ColorMap8} 
    vTcl:DefineAlias "$site_6_0.lab85" "Label3" vTcl:WidgetProc "Toplevel300" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame10" vTcl:WidgetProc "Toplevel300" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_6_0.cpd89 {global ColorMap9 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette COLORMAPDir
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMap9 "$COLORMAPDir/Planes_A1_A2_ColorMap9.pal"
set ColorMapNumber 9
set ColorNumber "256"
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMap9] {
    set f [open $ColorMap9 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMap9
set ColorMapOut $ColorMap9
WidgetShowFromWidget $widget(Toplevel300) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMap9 $ColorMapOut
   }}] \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button3" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Colormap}
    }
    label $site_6_0.lab85 \
        -text {Unsupervized ColorMap9} 
    vTcl:DefineAlias "$site_6_0.lab85" "Label4" vTcl:WidgetProc "Toplevel300" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame12" vTcl:WidgetProc "Toplevel300" 1
    set site_6_0 $site_5_0.cpd75
    button $site_6_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_6_0.cpd89 {global ColorMapWishart16 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette COLORMAPDir
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMapWishart16 "$COLORMAPDir/Wishart_ColorMap16.pal"
set ColorMapNumber 16
set ColorNumber "256"
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMapWishart16] {
    set f [open $ColorMapWishart16 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMapWishart16
set ColorMapOut $ColorMapWishart16
WidgetShowFromWidget $widget(Toplevel300) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapWishart16 $ColorMapOut
   }}] \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button11" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Colormap}
    }
    label $site_6_0.lab85 \
        -text {Unsupervized ColorMap16} 
    vTcl:DefineAlias "$site_6_0.lab85" "Label9" vTcl:WidgetProc "Toplevel300" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    frame $site_4_0.cpd98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd98" "Frame7" vTcl:WidgetProc "Toplevel300" 1
    set site_5_0 $site_4_0.cpd98
    frame $site_5_0.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd90" "Frame11" vTcl:WidgetProc "Toplevel300" 1
    set site_6_0 $site_5_0.cpd90
    button $site_6_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_6_0.cpd89 {global ColorMapPlanes27 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette OpenDirFile COLORMAPDir
#BMP PROCESS
global Load_colormap2 PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap2 == 0} {
    source "GUI/bmp_process/colormap2.tcl"
    set Load_colormap2 1
    WmTransient $widget(Toplevel254) $PSPTopLevel
    }

set ColorMapPlanes27 "$COLORMAPDir/Dbl_Vol_Sgl_ColorMap27.pal"
set ColorMapNumber 27
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMapPlanes27] {
    set f [open $ColorMapPlanes27 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top254.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top254.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top254.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top254.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top254.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top254.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top254.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top254.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top254.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top254.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top254.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top254.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top254.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top254.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top254.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top254.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur
set c17 .top254.cpd73.but36
set couleur [format "#%02x%02x%02x" $RedPalette(17) $GreenPalette(17) $BluePalette(17)]    
$c17 configure -background $couleur
set c18 .top254.cpd73.but37
set couleur [format "#%02x%02x%02x" $RedPalette(18) $GreenPalette(18) $BluePalette(18)]    
$c18 configure -background $couleur
set c19 .top254.cpd73.but38
set couleur [format "#%02x%02x%02x" $RedPalette(19) $GreenPalette(19) $BluePalette(19)]    
$c19 configure -background $couleur
set c20 .top254.cpd73.but39
set couleur [format "#%02x%02x%02x" $RedPalette(20) $GreenPalette(20) $BluePalette(20)]    
$c20 configure -background $couleur
set c21 .top254.cpd73.but40
set couleur [format "#%02x%02x%02x" $RedPalette(21) $GreenPalette(21) $BluePalette(21)]    
$c21 configure -background $couleur
set c22 .top254.cpd73.but41
set couleur [format "#%02x%02x%02x" $RedPalette(22) $GreenPalette(22) $BluePalette(22)]    
$c22 configure -background $couleur
set c23 .top254.cpd73.but42
set couleur [format "#%02x%02x%02x" $RedPalette(23) $GreenPalette(23) $BluePalette(23)]    
$c23 configure -background $couleur
set c24 .top254.cpd73.but43
set couleur [format "#%02x%02x%02x" $RedPalette(24) $GreenPalette(24) $BluePalette(24)]    
$c24 configure -background $couleur
set c25 .top254.cpd73.but44
set couleur [format "#%02x%02x%02x" $RedPalette(25) $GreenPalette(25) $BluePalette(25)]    
$c25 configure -background $couleur
set c26 .top254.cpd73.but45
set couleur [format "#%02x%02x%02x" $RedPalette(26) $GreenPalette(26) $BluePalette(26)]    
$c26 configure -background $couleur
set c27 .top254.cpd73.but46
set couleur [format "#%02x%02x%02x" $RedPalette(27) $GreenPalette(27) $BluePalette(27)]    
$c27 configure -background $couleur
set c28 .top254.cpd73.but47
set couleur [format "#%02x%02x%02x" $RedPalette(28) $GreenPalette(28) $BluePalette(28)]    
$c28 configure -background $couleur
set c29 .top254.cpd73.but48
set couleur [format "#%02x%02x%02x" $RedPalette(29) $GreenPalette(29) $BluePalette(29)]    
$c29 configure -background $couleur
set c30 .top254.cpd73.but49
set couleur [format "#%02x%02x%02x" $RedPalette(30) $GreenPalette(30) $BluePalette(30)]    
$c30 configure -background $couleur
set c31 .top254.cpd73.but50
set couleur [format "#%02x%02x%02x" $RedPalette(31) $GreenPalette(31) $BluePalette(31)]    
$c31 configure -background $couleur
set c32 .top254.cpd73.but51
set couleur [format "#%02x%02x%02x" $RedPalette(32) $GreenPalette(32) $BluePalette(32)]    
$c32 configure -background $couleur

.top254.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMapPlanes27
set ColorMapOut $ColorMapPlanes27
WidgetShowFromWidget $widget(Toplevel300) $widget(Toplevel254); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapPlanes27 $ColorMapOut
   }
}}] \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button4" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Colormap}
    }
    label $site_6_0.lab85 \
        -text { Dbl_Vol_Sgl ColorMap27} 
    vTcl:DefineAlias "$site_6_0.lab85" "Label5" vTcl:WidgetProc "Toplevel300" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame17" vTcl:WidgetProc "Toplevel300" 1
    set site_6_0 $site_5_0.cpd77
    button $site_6_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_6_0.cpd89 {global ColorMap32 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette OpenDirFile COLORMAPDir
#BMP PROCESS
global Load_colormap2 PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap2 == 0} {
    source "GUI/bmp_process/colormap2.tcl"
    set Load_colormap2 1
    WmTransient $widget(Toplevel254) $PSPTopLevel
    }

set ColorMap32 "$COLORMAPDir/Random_ColorMap32.pal"
set ColorMapNumber 32
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMap32] {
    set f [open $ColorMap32 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top254.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top254.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top254.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top254.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top254.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top254.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top254.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top254.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top254.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top254.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top254.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top254.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top254.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top254.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top254.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top254.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur
set c17 .top254.cpd73.but36
set couleur [format "#%02x%02x%02x" $RedPalette(17) $GreenPalette(17) $BluePalette(17)]    
$c17 configure -background $couleur
set c18 .top254.cpd73.but37
set couleur [format "#%02x%02x%02x" $RedPalette(18) $GreenPalette(18) $BluePalette(18)]    
$c18 configure -background $couleur
set c19 .top254.cpd73.but38
set couleur [format "#%02x%02x%02x" $RedPalette(19) $GreenPalette(19) $BluePalette(19)]    
$c19 configure -background $couleur
set c20 .top254.cpd73.but39
set couleur [format "#%02x%02x%02x" $RedPalette(20) $GreenPalette(20) $BluePalette(20)]    
$c20 configure -background $couleur
set c21 .top254.cpd73.but40
set couleur [format "#%02x%02x%02x" $RedPalette(21) $GreenPalette(21) $BluePalette(21)]    
$c21 configure -background $couleur
set c22 .top254.cpd73.but41
set couleur [format "#%02x%02x%02x" $RedPalette(22) $GreenPalette(22) $BluePalette(22)]    
$c22 configure -background $couleur
set c23 .top254.cpd73.but42
set couleur [format "#%02x%02x%02x" $RedPalette(23) $GreenPalette(23) $BluePalette(23)]    
$c23 configure -background $couleur
set c24 .top254.cpd73.but43
set couleur [format "#%02x%02x%02x" $RedPalette(24) $GreenPalette(24) $BluePalette(24)]    
$c24 configure -background $couleur
set c25 .top254.cpd73.but44
set couleur [format "#%02x%02x%02x" $RedPalette(25) $GreenPalette(25) $BluePalette(25)]    
$c25 configure -background $couleur
set c26 .top254.cpd73.but45
set couleur [format "#%02x%02x%02x" $RedPalette(26) $GreenPalette(26) $BluePalette(26)]    
$c26 configure -background $couleur
set c27 .top254.cpd73.but46
set couleur [format "#%02x%02x%02x" $RedPalette(27) $GreenPalette(27) $BluePalette(27)]    
$c27 configure -background $couleur
set c28 .top254.cpd73.but47
set couleur [format "#%02x%02x%02x" $RedPalette(28) $GreenPalette(28) $BluePalette(28)]    
$c28 configure -background $couleur
set c29 .top254.cpd73.but48
set couleur [format "#%02x%02x%02x" $RedPalette(29) $GreenPalette(29) $BluePalette(29)]    
$c29 configure -background $couleur
set c30 .top254.cpd73.but49
set couleur [format "#%02x%02x%02x" $RedPalette(30) $GreenPalette(30) $BluePalette(30)]    
$c30 configure -background $couleur
set c31 .top254.cpd73.but50
set couleur [format "#%02x%02x%02x" $RedPalette(31) $GreenPalette(31) $BluePalette(31)]    
$c31 configure -background $couleur
set c32 .top254.cpd73.but51
set couleur [format "#%02x%02x%02x" $RedPalette(32) $GreenPalette(32) $BluePalette(32)]    
$c32 configure -background $couleur

.top254.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMap32
set ColorMapOut $ColorMap32
WidgetShowFromWidget $widget(Toplevel300) $widget(Toplevel254); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMap32 $ColorMapOut
   }
}}] \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button16" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Colormap}
    }
    label $site_6_0.lab85 \
        -text { Random ColorMap32} 
    vTcl:DefineAlias "$site_6_0.lab85" "Label13" vTcl:WidgetProc "Toplevel300" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    frame $site_4_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame13" vTcl:WidgetProc "Toplevel300" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd90" "Frame14" vTcl:WidgetProc "Toplevel300" 1
    set site_6_0 $site_5_0.cpd90
    button $site_6_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_6_0.cpd89 {global ColorMap9 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette COLORMAPDir
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMap9 "$COLORMAPDir/Sgl_ColorMap9.pal"
set ColorMapNumber 9
set ColorNumber "256"
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMap9] {
    set f [open $ColorMap9 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMap9
set ColorMapOut $ColorMap9
WidgetShowFromWidget $widget(Toplevel300) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMap9 $ColorMapOut
   }}] \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button13" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Colormap}
    }
    label $site_6_0.lab85 \
        -text {Single ColorMap9} 
    vTcl:DefineAlias "$site_6_0.lab85" "Label10" vTcl:WidgetProc "Toplevel300" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame15" vTcl:WidgetProc "Toplevel300" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_6_0.cpd89 {global ColorMap9 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette COLORMAPDir
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMap9 "$COLORMAPDir/Dbl_ColorMap9.pal"
set ColorMapNumber 9
set ColorNumber "256"
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMap9] {
    set f [open $ColorMap9 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMap9
set ColorMapOut $ColorMap9
WidgetShowFromWidget $widget(Toplevel300) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMap9 $ColorMapOut
   }}] \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button14" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Colormap}
    }
    label $site_6_0.lab85 \
        -text {Double ColorMap9} 
    vTcl:DefineAlias "$site_6_0.lab85" "Label11" vTcl:WidgetProc "Toplevel300" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame16" vTcl:WidgetProc "Toplevel300" 1
    set site_6_0 $site_5_0.cpd75
    button $site_6_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_6_0.cpd89 {global ColorMap9 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette COLORMAPDir
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMap9 "$COLORMAPDir/Vol_ColorMap9.pal"
set ColorMapNumber 9
set ColorNumber "256"
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMap9] {
    set f [open $ColorMap9 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMap9
set ColorMapOut $ColorMap9
WidgetShowFromWidget $widget(Toplevel300) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMap9 $ColorMapOut
   }}] \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd89" "Button15" vTcl:WidgetProc "Toplevel300" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Colormap}
    }
    label $site_6_0.lab85 \
        -text {Volume ColorMap9} 
    vTcl:DefineAlias "$site_6_0.lab85" "Label12" vTcl:WidgetProc "Toplevel300" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side right 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra69 \
        -in $top -anchor center -expand 1 -fill x -side bottom 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd82 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit95 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.tit96 \
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
Window show .top300

main $argc $argv
