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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}

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
    set base .top509
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd77
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
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
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-_tooltip 1 -image 1 -padx 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.fra88 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra88
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra90 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra90
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad24 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra91 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra91
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad25 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad29 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad26 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad30 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra95 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra95
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad27 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad31 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd66
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad27 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad31 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra96 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra96
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-cursor 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra94 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra94
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
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
            vTclWindow.top509
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
    wm geometry $top 200x200+66+66; update
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

proc vTclWindow.top509 {base} {
    if {$base == ""} {
        set base .top509
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
    wm geometry $top 500x360+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Sinclair Elements"
    vTcl:DefineAlias "$top" "Toplevel509" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame4" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel509" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SlrDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel509" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel509" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel509" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel509" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SlrDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel509" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel509" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd78 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -state disabled -text button 
    bindtags $site_6_0.cpd78 "$site_6_0.cpd78 Button $top all _vTclBalloon"
    bind $site_6_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra88 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra88" "Frame9" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.fra88
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel509" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel509" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel509" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel509" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel509" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel509" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel509" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel509" 1
    pack $site_3_0.lab57 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent58 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab59 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent60 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab61 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent62 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab63 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_3_0.ent64 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra90 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra90" "Frame430" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.fra90
    label $site_3_0.lab47 \
        -padx 1 -text S11 
    vTcl:DefineAlias "$site_3_0.lab47" "Label509_1" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton509_1) configure -state normal} -padx 1 \
        -text A11 -value A -variable SlrtoS11 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton509_1" vTcl:WidgetProc "Toplevel509" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPSlrtoS11 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton509_1" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad24 \
        -command {$widget(Checkbutton509_1) configure -state normal} -padx 1 \
        -text I11 -value I -variable SlrtoS11 
    vTcl:DefineAlias "$site_3_0.rad24" "Radiobutton509_2" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad28 \
        -command {$widget(Checkbutton509_1) configure -state normal} -padx 1 \
        -text {A11 (dB) = I11 (dB)} -value Idb -variable SlrtoS11 
    vTcl:DefineAlias "$site_3_0.rad28" "Radiobutton509_3" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton509_1) configure -state normal} -padx 1 \
        -text Phase -value pha -variable SlrtoS11 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton509_4" vTcl:WidgetProc "Toplevel509" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.rad24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad28 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    frame $top.fra91 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra91" "Frame431" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.fra91
    label $site_3_0.lab47 \
        -padx 1 -text S21 
    vTcl:DefineAlias "$site_3_0.lab47" "Label509_2" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton509_2) configure -state normal} -padx 1 \
        -text A21 -value A -variable SlrtoS21 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton509_5" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad25 \
        -command {$widget(Checkbutton509_2) configure -state normal} -padx 1 \
        -text I21 -value I -variable SlrtoS21 
    vTcl:DefineAlias "$site_3_0.rad25" "Radiobutton509_6" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad29 \
        -command {$widget(Checkbutton509_2) configure -state normal} -padx 1 \
        -text {A21 (dB) = I21 (dB)} -value Idb -variable SlrtoS21 
    vTcl:DefineAlias "$site_3_0.rad29" "Radiobutton509_7" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton509_2) configure -state normal} -padx 1 \
        -text Phase -value pha -variable SlrtoS21 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton509_8" vTcl:WidgetProc "Toplevel509" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPSlrtoS21 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton509_2" vTcl:WidgetProc "Toplevel509" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad29 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra92 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame432" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.fra92
    label $site_3_0.lab47 \
        -text S12 
    vTcl:DefineAlias "$site_3_0.lab47" "Label509_3" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton509_3) configure -state normal} -padx 1 \
        -text A12 -value A -variable SlrtoS12 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton509_9" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad26 \
        -command {$widget(Checkbutton509_3) configure -state normal} -padx 1 \
        -text I12 -value I -variable SlrtoS12 
    vTcl:DefineAlias "$site_3_0.rad26" "Radiobutton509_10" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad30 \
        -command {$widget(Checkbutton509_3) configure -state normal} -padx 1 \
        -text {A12 (dB) = I12 (dB)} -value Idb -variable SlrtoS12 
    vTcl:DefineAlias "$site_3_0.rad30" "Radiobutton509_11" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton509_3) configure -state normal} -padx 1 \
        -text Phase -value pha -variable SlrtoS12 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton509_12" vTcl:WidgetProc "Toplevel509" 1
    checkbutton $site_3_0.che51 \
        -text BMP -variable BMPSlrtoS12 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton509_3" vTcl:WidgetProc "Toplevel509" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad26 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad30 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra95 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra95" "Frame433" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.fra95
    label $site_3_0.lab47 \
        -text S22 
    vTcl:DefineAlias "$site_3_0.lab47" "Label509_4" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton509_4) configure -state normal} -padx 1 \
        -text A22 -value A -variable SlrtoS22 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton509_13" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad27 \
        -command {$widget(Checkbutton509_4) configure -state normal} -padx 1 \
        -text I22 -value I -variable SlrtoS22 
    vTcl:DefineAlias "$site_3_0.rad27" "Radiobutton509_14" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad31 \
        -command {$widget(Checkbutton509_4) configure -state normal} -padx 1 \
        -text {A22 (dB) = I22 (dB)} -value Idb -variable SlrtoS22 
    vTcl:DefineAlias "$site_3_0.rad31" "Radiobutton509_15" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton509_4) configure -state normal} -padx 1 \
        -text Phase -value pha -variable SlrtoS22 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton509_16" vTcl:WidgetProc "Toplevel509" 1
    checkbutton $site_3_0.che51 \
        -text BMP -variable BMPSlrtoS22 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton509_4" vTcl:WidgetProc "Toplevel509" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad31 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd66 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame435" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.cpd66
    label $site_3_0.lab47 \
        -text Pauli 
    vTcl:DefineAlias "$site_3_0.lab47" "Label509_6" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton509_6) configure -state normal} -padx 1 \
        -text Cmplx -value cmplx -variable SlrtoPauli 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton509_19" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad27 \
        -command {$widget(Checkbutton509_6) configure -state normal} -padx 1 \
        -text Mod -value mod -variable SlrtoPauli 
    vTcl:DefineAlias "$site_3_0.rad27" "Radiobutton509_20" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad31 \
        -command {$widget(Checkbutton509_6) configure -state normal} -padx 1 \
        -text {20log10 (Mod) (dB)} -value db -variable SlrtoPauli 
    vTcl:DefineAlias "$site_3_0.rad31" "Radiobutton509_21" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton509_6) configure -state normal} -padx 1 \
        -text Phase -value pha -variable SlrtoPauli 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton509_22" vTcl:WidgetProc "Toplevel509" 1
    checkbutton $site_3_0.che51 \
        -text BMP -variable BMPSlrtoPauli 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton509_6" vTcl:WidgetProc "Toplevel509" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad31 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra96 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra96" "Frame434" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.fra96
    label $site_3_0.lab47 \
        -cursor {} -padx 1 -text Span 
    vTcl:DefineAlias "$site_3_0.lab47" "Label509_5" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton509_5) configure -state normal} -padx 1 \
        -text Linear -value lin -variable SlrtoSpan 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton509_17" vTcl:WidgetProc "Toplevel509" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton509_5) configure -state normal} -padx 1 \
        -text {DeciBel = 10log(Span)} -value db -variable SlrtoSpan 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton509_18" vTcl:WidgetProc "Toplevel509" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPSlrtoSpan 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton509_5" vTcl:WidgetProc "Toplevel509" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 6 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 60 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame1" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.fra66
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {global PolarType

set SlrtoS11 ""; set SlrtoS21 ""
set SlrtoS12 ""; set SlrtoS22 ""
set SlrtoSpan ""; set SlrtoPauli ""
set BMPSlrtoS11 ""; set BMPSlrtoS21 ""
set BMPSlrtoS12 ""; set BMPSlrtoS22 ""
set BMPSlrtoSpan ""; set BMPSlrtoPauli ""
$widget(Checkbutton509_1) configure -state disable
$widget(Checkbutton509_2) configure -state disable
$widget(Checkbutton509_3) configure -state disable
$widget(Checkbutton509_4) configure -state disable
$widget(Checkbutton509_5) configure -state disable
$widget(Checkbutton509_6) configure -state disable

set SlrtoSpan "db"
set BMPSlrtoSpan "1"
$widget(Checkbutton509_5) configure -state normal

if {$PolarType == "full"} {
    set SlrtoS11 "Idb"; set SlrtoS21 "Idb"
    set SlrtoS12 "Idb"; set SlrtoS22 "Idb"
    set SlrtoPauli "db"
    set BMPSlrtoS11 "1"; set BMPSlrtoS21 "1"
    set BMPSlrtoS12 "1"; set BMPSlrtoS22 "1"
    set BMPSlrtoPauli "1"
    $widget(Checkbutton509_1) configure -state normal
    $widget(Checkbutton509_2) configure -state normal
    $widget(Checkbutton509_3) configure -state normal
    $widget(Checkbutton509_4) configure -state normal
    }
if {$PolarType == "pp1"} {
    set SlrtoS11 "Idb"; set SlrtoS21 "Idb"
    set BMPSlrtoS11 "1"; set BMPSlrtoS21 "1"
    $widget(Checkbutton509_1) configure -state normal
    $widget(Checkbutton509_2) configure -state normal
    }
if {$PolarType == "pp2"} {
    set SlrtoS12 "Idb"; set SlrtoS22 "Idb"
    set BMPSlrtoS12 "1"; set BMPSlrtoS22 "1"
    $widget(Checkbutton509_3) configure -state normal
    $widget(Checkbutton509_4) configure -state normal
    } 
if {$PolarType == "pp3"} {
    set SlrtoS11 "Idb"; set SlrtoS22 "Idb"
    set BMPSlrtoS11 "1"; set BMPSlrtoS22 "1"
    $widget(Checkbutton509_1) configure -state normal
    $widget(Checkbutton509_4) configure -state normal
    }} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button5510" vTcl:WidgetProc "Toplevel509" 1
    bindtags $site_3_0.cpd67 "$site_3_0.cpd67 Button $top all _vTclBalloon"
    bind $site_3_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.cpd68 \
        -background #ffff00 \
        -command {set SlrtoS11 ""
set SlrtoS21 ""
set SlrtoS12 ""
set SlrtoS22 ""
set SlrtoSpan ""
set SlrtoPauli ""
set BMPSlrtoS11 ""
set BMPSlrtoS21 ""
set BMPSlrtoS12 ""
set BMPSlrtoS22 ""
set BMPSlrtoSpan ""
set BMPSlrtoPauli ""
$widget(Checkbutton509_1) configure -state disable
$widget(Checkbutton509_2) configure -state disable
$widget(Checkbutton509_3) configure -state disable
$widget(Checkbutton509_4) configure -state disable
$widget(Checkbutton509_5) configure -state disable
$widget(Checkbutton509_6) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd68" "Button5511" vTcl:WidgetProc "Toplevel509" 1
    bindtags $site_3_0.cpd68 "$site_3_0.cpd68 Button $top all _vTclBalloon"
    bind $site_3_0.cpd68 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra94 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra94" "Frame20" vTcl:WidgetProc "Toplevel509" 1
    set site_3_0 $top.fra94
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirMult NDataDirMult 
global SlrDirInput SlrDirOutput OpenDirFile
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {
    
    #####################################################################
    #Create Directory
    set SlrDirOutput [PSPCreateDirectoryMask $SlrDirOutput $SlrDirOutput $SlrDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {

        WidgetShowTop399; TextEditorRunTrace "Open Window Processing" "b"

        for {set ii 1} {$ii <= $NDataDirMult} {incr ii} {
            set SlrDirInput $DataDirMult($ii)
            set SlrDirOutput $DataDirMult($ii)

            #Create Directory
            set SlrDirOutput [PSPCreateDirectoryMaskMult $SlrDirOutput $SlrDirOutput $SlrDirInput]

    if {"$SlrtoS11"!=""} {
        set Fonction "Creation of the Binary Data File :"
        if {"$SlrtoS11"=="A"} {set Fonction2 "$SlrDirOutput/A11.bin"}
        if {"$SlrtoS11"=="Adb"} {set Fonction2 "$SlrDirOutput/A11_db.bin"}
        if {"$SlrtoS11"=="I"} {set Fonction2 "$SlrDirOutput/I11.bin"}
        if {"$SlrtoS11"=="Idb"} {set Fonction2 "$SlrDirOutput/I11_db.bin"}
        if {"$SlrtoS11"=="pha"} {set Fonction2 "$SlrDirOutput/s11_pha.bin"}
        set MaskCmd ""
        set MaskFile "$SlrDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf S2 -elt 11 -fmt $SlrtoS11 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf S2 -elt 11 -fmt $SlrtoS11 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {"$SlrtoS11"=="A"} {EnviWriteConfig "$SlrDirOutput/A11.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS11"=="Adb"} {EnviWriteConfig "$SlrDirOutput/A11_db.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS11"=="I"} {EnviWriteConfig "$SlrDirOutput/I11.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS11"=="Idb"} {EnviWriteConfig "$SlrDirOutput/I11_db.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS11"=="pha"} {EnviWriteConfig "$SlrDirOutput/s11_pha.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPSlrtoS11"=="1"} {
            if {"$SlrtoS11"=="A"} {
                set BMPFileInput "$SlrDirOutput/A11.bin"
                set BMPFileOutput "$SlrDirOutput/A11.bmp"
                }
            if {"$SlrtoS11"=="Adb"} {
                set BMPFileInput "$SlrDirOutput/A11_db.bin"
                set BMPFileOutput "$SlrDirOutput/A11_db.bmp"
                }
            if {"$SlrtoS11"=="I"} {
                set BMPFileInput "$SlrDirOutput/I11.bin"
                set BMPFileOutput "$SlrDirOutput/I11.bmp"
                }
            if {"$SlrtoS11"=="Idb"} {
                set BMPFileInput "$SlrDirOutput/I11_db.bin"
                set BMPFileOutput "$SlrDirOutput/I11_db.bmp"
                }
            if {"$SlrtoS11"=="pha"} {
                set BMPFileInput "$SlrDirOutput/s11_pha.bin"
                set BMPFileOutput "$SlrDirOutput/s11_pha.bmp"
                }
            if {"$SlrtoS11"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }
        
    if {"$SlrtoS21"!=""} {
        set Fonction "Creation of the Binary Data File :"
        if {"$SlrtoS21"=="A"} {set Fonction2 "$SlrDirOutput/A21.bin"}
        if {"$SlrtoS21"=="Adb"} {set Fonction2 "$SlrDirOutput/A21_db.bin"}
        if {"$SlrtoS21"=="I"} {set Fonction2 "$SlrDirOutput/I21.bin"}
        if {"$SlrtoS21"=="Idb"} {set Fonction2 "$SlrDirOutput/I21_db.bin"}
        if {"$SlrtoS21"=="pha"} {set Fonction2 "$SlrDirOutput/s21_pha.bin"}
        set MaskCmd ""
        set MaskFile "$SlrDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf S2 -elt 21 -fmt $SlrtoS21 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf S2 -elt 21 -fmt $SlrtoS21 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {"$SlrtoS21"=="A"} {EnviWriteConfig "$SlrDirOutput/A21.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS21"=="Adb"} {EnviWriteConfig "$SlrDirOutput/A21_db.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS21"=="I"} {EnviWriteConfig "$SlrDirOutput/I21.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS21"=="Idb"} {EnviWriteConfig "$SlrDirOutput/I21_db.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS21"=="pha"} {EnviWriteConfig "$SlrDirOutput/s21_pha.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPSlrtoS21"=="1"} {
            if {"$SlrtoS21"=="A"} {
                set BMPFileInput "$SlrDirOutput/A21.bin"
                set BMPFileOutput "$SlrDirOutput/A21.bmp"
                }
            if {"$SlrtoS21"=="Adb"} {
                set BMPFileInput "$SlrDirOutput/A21_db.bin"
                set BMPFileOutput "$SlrDirOutput/A21_db.bmp"
                }
            if {"$SlrtoS21"=="I"} {
                set BMPFileInput "$SlrDirOutput/I21.bin"
                set BMPFileOutput "$SlrDirOutput/I21.bmp"
                }
            if {"$SlrtoS21"=="Idb"} {
                set BMPFileInput "$SlrDirOutput/I21_db.bin"
                set BMPFileOutput "$SlrDirOutput/I21_db.bmp"
                }
            if {"$SlrtoS21"=="pha"} {
                set BMPFileInput "$SlrDirOutput/s21_pha.bin"
                set BMPFileOutput "$SlrDirOutput/s21_pha.bmp"
                }
            if {"$SlrtoS21"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }
    
    if {"$SlrtoS12"!=""} {
        set Fonction "Creation of the Binary Data File :"
        if {"$SlrtoS12"=="A"} {set Fonction2 "$SlrDirOutput/A12.bin"}
        if {"$SlrtoS12"=="Adb"} {set Fonction2 "$SlrDirOutput/A12_db.bin"}
        if {"$SlrtoS12"=="I"} {set Fonction2 "$SlrDirOutput/I12.bin"}
        if {"$SlrtoS12"=="Idb"} {set Fonction2 "$SlrDirOutput/I12_db.bin"}
        if {"$SlrtoS12"=="pha"} {set Fonction2 "$SlrDirOutput/s12_pha.bin"}
        set MaskCmd ""
        set MaskFile "$SlrDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf S2 -elt 12 -fmt $SlrtoS12 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf S2 -elt 12 -fmt $SlrtoS12 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {"$SlrtoS12"=="A"} {EnviWriteConfig "$SlrDirOutput/A12.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS12"=="Adb"} {EnviWriteConfig "$SlrDirOutput/A12_db.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS12"=="I"} {EnviWriteConfig "$SlrDirOutput/I12.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS12"=="Idb"} {EnviWriteConfig "$SlrDirOutput/I12_db.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS12"=="pha"} {EnviWriteConfig "$SlrDirOutput/s12_pha.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPSlrtoS12"=="1"} {
            if {"$SlrtoS12"=="A"} {
                set BMPFileInput "$SlrDirOutput/A12.bin"
                set BMPFileOutput "$SlrDirOutput/A12.bmp"
                }
            if {"$SlrtoS12"=="Adb"} {
                set BMPFileInput "$SlrDirOutput/A12_db.bin"
                set BMPFileOutput "$SlrDirOutput/A12_db.bmp"
                }
            if {"$SlrtoS12"=="I"} {
                set BMPFileInput "$SlrDirOutput/I12.bin"
                set BMPFileOutput "$SlrDirOutput/I12.bmp"
                }
            if {"$SlrtoS12"=="Idb"} {
                set BMPFileInput "$SlrDirOutput/I12_db.bin"
                set BMPFileOutput "$SlrDirOutput/I12_db.bmp"
                }
            if {"$SlrtoS12"=="pha"} {
                set BMPFileInput "$SlrDirOutput/s12_pha.bin"
                set BMPFileOutput "$SlrDirOutput/s12_pha.bmp"
                }
            if {"$SlrtoS12"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }

    if {"$SlrtoS22"!=""} {
        set Fonction "Creation of the Binary Data File :"
        if {"$SlrtoS22"=="A"} {set Fonction2 "$SlrDirOutput/A22.bin"}
        if {"$SlrtoS22"=="Adb"} {set Fonction2 "$SlrDirOutput/A22_db.bin"}
        if {"$SlrtoS22"=="I"} {set Fonction2 "$SlrDirOutput/I22.bin"}
        if {"$SlrtoS22"=="Idb"} {set Fonction2 "$SlrDirOutput/I22_db.bin"}
        if {"$SlrtoS22"=="pha"} {set Fonction2 "$SlrDirOutput/s22_pha.bin"}
        set MaskCmd ""
        set MaskFile "$SlrDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf S2 -elt 22 -fmt $SlrtoS22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf S2 -elt 22 -fmt $SlrtoS22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {"$SlrtoS22"=="A"} {EnviWriteConfig "$SlrDirOutput/A22.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS22"=="Adb"} {EnviWriteConfig "$SlrDirOutput/A22_db.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS22"=="I"} {EnviWriteConfig "$SlrDirOutput/I22.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS22"=="Idb"} {EnviWriteConfig "$SlrDirOutput/I22_db.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoS22"=="pha"} {EnviWriteConfig "$SlrDirOutput/s22_pha.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPSlrtoS22"=="1"} {
            if {"$SlrtoS22"=="A"} {
                set BMPFileInput "$SlrDirOutput/A22.bin"
                set BMPFileOutput "$SlrDirOutput/A22.bmp"
                }
            if {"$SlrtoS22"=="Adb"} {
                set BMPFileInput "$SlrDirOutput/A22_db.bin"
                set BMPFileOutput "$SlrDirOutput/A22_db.bmp"
                }
            if {"$SlrtoS22"=="I"} {
                set BMPFileInput "$SlrDirOutput/I22.bin"
                set BMPFileOutput "$SlrDirOutput/I22.bmp"
                }
            if {"$SlrtoS22"=="Idb"} {
                set BMPFileInput "$SlrDirOutput/I22_db.bin"
                set BMPFileOutput "$SlrDirOutput/I22_db.bmp"
                }
            if {"$SlrtoS22"=="pha"} {
                set BMPFileInput "$SlrDirOutput/s22_pha.bin"
                set BMPFileOutput "$SlrDirOutput/s22_pha.bmp"
                }
            if {"$SlrtoS22"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }


    if {"$SlrtoPauli"!=""} {
        set Fonction "Creation of the Binary Data File :"
        if {"$SlrtoPauli"=="cmplx"} {set Fonction2 "Pauli Elements (cmplx)"}
        if {"$SlrtoPauli"=="mod"} {set Fonction2 "Pauli Elements (mod)"}
        if {"$SlrtoPauli"=="db"} {set Fonction2 "Pauli Elements (dB)"}
        if {"$SlrtoPauli"=="pha"} {set Fonction2 "Pauli Elements (pha)"}
        set MaskCmd ""
        set MaskFile "$SlrDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_pauli.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -fmt $SlrtoPauli -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_pauli.exe -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -fmt $SlrtoPauli -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        if {"$SlrtoPauli"=="cmplx"} {
            EnviWriteConfig "$SlrDirOutput/s11ps22.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$SlrDirOutput/s11ms22.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$SlrDirOutput/s12ps21.bin" $FinalNlig $FinalNcol 6
            EnviWriteConfig "$SlrDirOutput/s12ms21.bin" $FinalNlig $FinalNcol 6
            }
        if {"$SlrtoPauli"=="mod"} {
            EnviWriteConfig "$SlrDirOutput/s11ps22_mod.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s11ms22_mod.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s12ps21_mod.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s12ms21_mod.bin" $FinalNlig $FinalNcol 4
            }
        if {"$SlrtoPauli"=="db"} {
            EnviWriteConfig "$SlrDirOutput/s11ps22_db.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s11ms22_db.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s12ps21_db.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s12ms21_db.bin" $FinalNlig $FinalNcol 4
            }
        if {"$SlrtoPauli"=="pha"} {
            EnviWriteConfig "$SlrDirOutput/s11ps22_pha.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s11ms22_pha.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s12ps21_pha.bin" $FinalNlig $FinalNcol 4
            EnviWriteConfig "$SlrDirOutput/s12ms21_pha.bin" $FinalNlig $FinalNcol 4
            }

        if {"$BMPSlrtoPauli"=="1"} {
            if {"$SlrtoPauli"=="mod"} {
                set BMPFileInput "$SlrDirOutput/s11ps22_mod.bin"
                set BMPFileOutput "$SlrDirOutput/s11ps22_mod.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                set BMPFileInput "$SlrDirOutput/s11ms22_mod.bin"
                set BMPFileOutput "$SlrDirOutput/s11ms22_mod.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                set BMPFileInput "$SlrDirOutput/s12ps21_mod.bin"
                set BMPFileOutput "$SlrDirOutput/s12ps21_mod.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                set BMPFileInput "$SlrDirOutput/s12ms21_mod.bin"
                set BMPFileOutput "$SlrDirOutput/s12ms21_mod.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }

            if {"$SlrtoPauli"=="db"} {
                set BMPFileInput "$SlrDirOutput/s11ps22_db.bin"
                set BMPFileOutput "$SlrDirOutput/s11ps22_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                set BMPFileInput "$SlrDirOutput/s11ms22_db.bin"
                set BMPFileOutput "$SlrDirOutput/s11ms22_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                set BMPFileInput "$SlrDirOutput/s12ps21_db.bin"
                set BMPFileOutput "$SlrDirOutput/s12ps21_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                set BMPFileInput "$SlrDirOutput/s12ms21_db.bin"
                set BMPFileOutput "$SlrDirOutput/s12ms21_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }

            if {"$SlrtoPauli"=="pha"} {
                set BMPFileInput "$SlrDirOutput/s11ps22_pha.bin"
                set BMPFileOutput "$SlrDirOutput/s11ps22_pha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                set BMPFileInput "$SlrDirOutput/s11ms22_pha.bin"
                set BMPFileOutput "$SlrDirOutput/s11ms22_pha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                set BMPFileInput "$SlrDirOutput/s12ps21_pha.bin"
                set BMPFileOutput "$SlrDirOutput/s12ps21_pha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                set BMPFileInput "$SlrDirOutput/s12ms21_pha.bin"
                set BMPFileOutput "$SlrDirOutput/s12ms21_pha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                }

            }
        }

    if {"$SlrtoSpan"!=""} {
        set Fonction "Creation of the Binary Data File :"
        if {"$SlrtoSpan"=="lin"} {set Fonction2 "$SlrDirOutput/span.bin"}
        if {"$SlrtoSpan"=="db"} {set Fonction2 "$SlrDirOutput/span_db.bin"}
        set MaskCmd ""
        set MaskFile "$SlrDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf $SinclairFonction -fmt $SlrtoSpan -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_span.exe -id \x22$SlrDirInput\x22 -od \x22$SlrDirOutput\x22 -iodf $SinclairFonction -fmt $SlrtoSpan -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {"$SlrtoSpan"=="lin"} {EnviWriteConfig "$SlrDirOutput/span.bin" $FinalNlig $FinalNcol 4}
        if {"$SlrtoSpan"=="db"} {EnviWriteConfig "$SlrDirOutput/span_db.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPSlrtoSpan"=="1"} {
            if {"$SlrtoSpan"=="lin"} {
                set BMPFileInput "$SlrDirOutput/span.bin"
                set BMPFileOutput "$SlrDirOutput/span.bmp"
                }
            if {"$SlrtoSpan"=="db"} {
                set BMPFileInput "$SlrDirOutput/span_db.bin"
                set BMPFileOutput "$SlrDirOutput/span_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }

      }
      #ii

    WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"

    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel509); TextEditorRunTrace "Close Window Sinclair Elements Mult" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel509" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SinclairElementsMult.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel509" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel509); TextEditorRunTrace "Close Window Sinclair Elements Mult" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel509" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra90 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra91 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra92 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra95 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra96 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra94 \
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
Window show .top509

main $argc $argv
