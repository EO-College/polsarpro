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
        {{[file join . GUI Images zoom2.gif]} {user image} user {}}
        {{[file join . GUI Images rectangle.gif]} {user image} user {}}

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
    set base .top202
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.fra46 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra46
    namespace eval ::widgets::$site_4_0.fra22 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra22
    namespace eval ::widgets::$site_5_0.lab24 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent25 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra23
    namespace eval ::widgets::$site_5_0.lab26 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent27 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra48 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra48
    namespace eval ::widgets::$site_3_0.fra24 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra24
    namespace eval ::widgets::$site_4_0.fra22 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra22
    namespace eval ::widgets::$site_5_0.lab24 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent25 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra23
    namespace eval ::widgets::$site_5_0.lab26 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent27 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra28 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra28
    namespace eval ::widgets::$site_4_0.fra22 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra22
    namespace eval ::widgets::$site_5_0.lab24 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent25 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra23
    namespace eval ::widgets::$site_5_0.lab26 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent27 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra70 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra70
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd74
    namespace eval ::widgets::$site_4_0.fra22 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra22
    namespace eval ::widgets::$site_5_0.lab24 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent25 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra23
    namespace eval ::widgets::$site_5_0.lab26 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent27 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra69
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra72
    namespace eval ::widgets::$site_3_0.lab73 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-_tooltip 1 -activebackground 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab75 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-_tooltip 1 -command 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$base.fra49 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra49
    namespace eval ::widgets::$site_3_0.but26 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but27 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but69 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top202
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
global tool; 
global x; 
global y; 

set tool rect
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

proc vTclWindow.top202 {base} {
    if {$base == ""} {
        set base .top202
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
    wm geometry $top 140x250+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "SubArea: Graphic Editor"
    vTcl:DefineAlias "$top" "Toplevel202" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd72 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame169" vTcl:WidgetProc "Toplevel202" 1
    set site_3_0 $top.cpd72
    frame $site_3_0.fra46 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra46" "Frame197" vTcl:WidgetProc "Toplevel202" 1
    set site_4_0 $site_3_0.fra46
    frame $site_4_0.fra22 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra22" "Frame198" vTcl:WidgetProc "Toplevel202" 1
    set site_5_0 $site_4_0.fra22
    label $site_5_0.lab24 \
        -relief sunken -text X -width 2 
    vTcl:DefineAlias "$site_5_0.lab24" "Label201" vTcl:WidgetProc "Toplevel202" 1
    entry $site_5_0.ent25 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable QLBMPMouseX -width 5 
    vTcl:DefineAlias "$site_5_0.ent25" "Entry149" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_5_0.ent25 "$site_5_0.ent25 Entry $top all _vTclBalloon"
    bind $site_5_0.ent25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Current mouse position }
    }
    pack $site_5_0.lab24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent25 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.fra23 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra23" "Frame199" vTcl:WidgetProc "Toplevel202" 1
    set site_5_0 $site_4_0.fra23
    label $site_5_0.lab26 \
        -relief sunken -text Y -width 2 
    vTcl:DefineAlias "$site_5_0.lab26" "Label202" vTcl:WidgetProc "Toplevel202" 1
    entry $site_5_0.ent27 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable QLBMPMouseY -width 5 
    vTcl:DefineAlias "$site_5_0.ent27" "Entry150" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_5_0.ent27 "$site_5_0.ent27 Entry $top all _vTclBalloon"
    bind $site_5_0.ent27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Current mouse position}
    }
    pack $site_5_0.lab26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent27 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra22 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.fra46 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra48 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra48" "Frame167" vTcl:WidgetProc "Toplevel202" 1
    set site_3_0 $top.fra48
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame165" vTcl:WidgetProc "Toplevel202" 1
    set site_4_0 $site_3_0.fra24
    frame $site_4_0.fra22 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra22" "Frame183" vTcl:WidgetProc "Toplevel202" 1
    set site_5_0 $site_4_0.fra22
    label $site_5_0.lab24 \
        -relief sunken -text X1 -width 2 
    vTcl:DefineAlias "$site_5_0.lab24" "Label175" vTcl:WidgetProc "Toplevel202" 1
    entry $site_5_0.ent25 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable QLMouseInitX -width 5 
    vTcl:DefineAlias "$site_5_0.ent25" "Entry128" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_5_0.ent25 "$site_5_0.ent25 Entry $top all _vTclBalloon"
    bind $site_5_0.ent25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Upper-Left coordinates of the selected area}
    }
    pack $site_5_0.lab24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent25 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.fra23 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra23" "Frame184" vTcl:WidgetProc "Toplevel202" 1
    set site_5_0 $site_4_0.fra23
    label $site_5_0.lab26 \
        -relief sunken -text Y1 -width 2 
    vTcl:DefineAlias "$site_5_0.lab26" "Label176" vTcl:WidgetProc "Toplevel202" 1
    entry $site_5_0.ent27 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable QLMouseInitY -width 5 
    vTcl:DefineAlias "$site_5_0.ent27" "Entry129" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_5_0.ent27 "$site_5_0.ent27 Entry $top all _vTclBalloon"
    bind $site_5_0.ent27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Upper-Left coordinates of the selected area}
    }
    pack $site_5_0.lab26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent27 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra22 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $site_3_0.fra28 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra28" "Frame187" vTcl:WidgetProc "Toplevel202" 1
    set site_4_0 $site_3_0.fra28
    frame $site_4_0.fra22 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra22" "Frame185" vTcl:WidgetProc "Toplevel202" 1
    set site_5_0 $site_4_0.fra22
    label $site_5_0.lab24 \
        -relief sunken -text X2 -width 2 
    vTcl:DefineAlias "$site_5_0.lab24" "Label190" vTcl:WidgetProc "Toplevel202" 1
    entry $site_5_0.ent25 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable QLMouseEndX -width 5 
    vTcl:DefineAlias "$site_5_0.ent25" "Entry143" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_5_0.ent25 "$site_5_0.ent25 Entry $top all _vTclBalloon"
    bind $site_5_0.ent25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Lower-Right coordinates of the selected area}
    }
    pack $site_5_0.lab24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent25 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.fra23 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra23" "Frame186" vTcl:WidgetProc "Toplevel202" 1
    set site_5_0 $site_4_0.fra23
    label $site_5_0.lab26 \
        -relief sunken -text Y2 -width 2 
    vTcl:DefineAlias "$site_5_0.lab26" "Label191" vTcl:WidgetProc "Toplevel202" 1
    entry $site_5_0.ent27 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable QLMouseEndY -width 5 
    vTcl:DefineAlias "$site_5_0.ent27" "Entry144" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_5_0.ent27 "$site_5_0.ent27 Entry $top all _vTclBalloon"
    bind $site_5_0.ent27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Lower-Right coordinates of the selected area}
    }
    pack $site_5_0.lab26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent27 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra22 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.fra28 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra70 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra70" "Frame2" vTcl:WidgetProc "Toplevel202" 1
    set site_3_0 $top.fra70
    frame $site_3_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd74" "Frame203" vTcl:WidgetProc "Toplevel202" 1
    set site_4_0 $site_3_0.cpd74
    frame $site_4_0.fra22 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra22" "Frame204" vTcl:WidgetProc "Toplevel202" 1
    set site_5_0 $site_4_0.fra22
    label $site_5_0.lab24 \
        -relief sunken -text C -width 2 
    vTcl:DefineAlias "$site_5_0.lab24" "Label205" vTcl:WidgetProc "Toplevel202" 1
    entry $site_5_0.ent25 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable QLMouseNcol -width 5 
    vTcl:DefineAlias "$site_5_0.ent25" "Entry153" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_5_0.ent25 "$site_5_0.ent25 Entry $top all _vTclBalloon"
    bind $site_5_0.ent25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Columns of the selected area}
    }
    pack $site_5_0.lab24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent25 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.fra23 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra23" "Frame205" vTcl:WidgetProc "Toplevel202" 1
    set site_5_0 $site_4_0.fra23
    label $site_5_0.lab26 \
        -relief sunken -text R -width 2 
    vTcl:DefineAlias "$site_5_0.lab26" "Label206" vTcl:WidgetProc "Toplevel202" 1
    entry $site_5_0.ent27 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable QLMouseNlig -width 5 
    vTcl:DefineAlias "$site_5_0.ent27" "Entry154" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_5_0.ent27 "$site_5_0.ent27 Entry $top all _vTclBalloon"
    bind $site_5_0.ent27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Rows of the selected area}
    }
    pack $site_5_0.lab26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent27 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra22 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra23 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra69" "Frame1" vTcl:WidgetProc "Toplevel202" 1
    set site_3_0 $top.fra69
    button $site_3_0.cpd70 \
        -background #ffff00 \
        -command {global QLBMPMouseX QLBMPMouseY QLMouseInitX QLMouseInitY QLMouseEndX QLMouseEndY QLMouseNlig QLMouseNcol
global widget SourceWidth SourceHeight WidthBMP HeightBMP 
global BMPWidth BMPHeight ZoomBMP ZoomBMPQL QLZoomBMP BMPImage ImageSource BMPCanvas

set QLMouseInitX ""
set QLMouseInitY ""
set QLMouseEndX ""
set QLMouseEndY ""
set QLMouseNlig ""
set QLMouseNcol ""
set QLBMPMouseX ""
set QLBMPMouseY ""

if {$ZoomBMP != "0:0"} {
    set Num1 ""
    set Num2 ""
    set Num1 [string index $ZoomBMP 0]
    set Num2 [string index $ZoomBMP 1]
    if {$Num2 == ":"} {
        set Num $Num1
        set Den1 ""
        set Den2 ""
        set Den1 [string index $ZoomBMP 2]
        set Den2 [string index $ZoomBMP 3]
        if {$Den2 == ""} {
            set Den $Den1
            } else {
            set Den [expr 10*$Den1 + $Den2]
            }
        } else {
        set Num [expr 10*$Num1 + $Num2]
        set Den1 ""
        set Den2 ""
        set Den1 [string index $ZoomBMP 3]
        set Den2 [string index $ZoomBMP 4]
        if {$Den2 == ""} {
            set Den $Den1
            } else {
            set Den [expr 10*$Den1 + $Den2]
            }
        }

    if {$Den >= $Num} {
        set BMPSample $Den
        set Xmax [expr round($BMPWidth * $BMPSample)]
        set Ymax [expr round($BMPHeight * $BMPSample)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -subsample $BMPSample $BMPSample
        $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
        $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
        $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
        }
    }} \
        -padx 4 -pady 2 -text Clear 
    vTcl:DefineAlias "$site_3_0.cpd70" "Button86" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.cpd70 "$site_3_0.cpd70 Button $top all _vTclBalloon"
    bind $site_3_0.cpd70 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Clear the selected area}
    }
    button $site_3_0.cpd73 \
        \
        -command {global rect_color

if {$rect_color == "white"} {
    set rect_color "black"
    } else {
    set rect_color "white"
    }

set b .top202.fra69.cpd73
$b configure -background $rect_color -foreground $rect_color} \
        -padx 3 -pady 2 -relief ridge -text . -width 1 
    vTcl:DefineAlias "$site_3_0.cpd73" "Button142" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.cpd73 "$site_3_0.cpd73 Button $top all _vTclBalloon"
    bind $site_3_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Color change }
    }
    button $site_3_0.cpd71 \
        -background #ffff00 \
        -command {global QLMouseInitX QLMouseInitY QLMouseEndX QLMouseEndY QLMouseNlig QLMouseNcol
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global ZoomBMP ZoomBMPQL QLZoomBMP

set QLMouseInitY [expr $NligInit - 1]
set QLMouseInitX [expr $NcolInit - 1]
set QLMouseEndY [expr $NligEnd - 1]
set QLMouseEndX [expr $NcolEnd - 1]
set QLMouseNlig $NligFullSize
set QLMouseNcol $NcolFullSize

if {$ZoomBMP != "0:0"} {
    set Num1 ""
    set Num2 ""
    set Num1 [string index $ZoomBMP 0]
    set Num2 [string index $ZoomBMP 1]
    if {$Num2 == ":"} {
        set Num $Num1
        set Den1 ""
        set Den2 ""
        set Den1 [string index $ZoomBMP 2]
        set Den2 [string index $ZoomBMP 3]
        if {$Den2 == ""} {
            set Den $Den1
            } else {
            set Den [expr 10*$Den1 + $Den2]
            }
        } else {
        set Num [expr 10*$Num1 + $Num2]
        set Den1 ""
        set Den2 ""
        set Den1 [string index $ZoomBMP 3]
        set Den2 [string index $ZoomBMP 4]
        if {$Den2 == ""} {
            set Den $Den1
            } else {
            set Den [expr 10*$Den1 + $Den2]
            }
        }

    if {$Den >= $Num} {
        set BMPSample $Den
        set sx2 [expr round($SourceWidth / $BMPSample)]
        set sy2 [expr round($SourceHeight / $BMPSample)]
        set Xmax [expr round($BMPWidth * $BMPSample)]
        set Ymax [expr round($BMPHeight * $BMPSample)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -subsample $BMPSample $BMPSample
        $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
        $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set sx2 [expr round($SourceWidth * $BMPZoom)]
        set sy2 [expr round($SourceHeight * $BMPZoom)]
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
        $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
        }

    set obj [$widget($BMPCanvas) create rectangle 0 0 $sx2 $sy2 -outline "red" -width 4]
    }} \
        -padx 4 -pady 2 -text Full 
    vTcl:DefineAlias "$site_3_0.cpd71" "Button87" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.cpd71 "$site_3_0.cpd71 Button $top all _vTclBalloon"
    bind $site_3_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select all the image}
    }
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra72" "Frame4" vTcl:WidgetProc "Toplevel202" 1
    set site_3_0 $top.fra72
    label $site_3_0.lab73 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable QLZoomBMP -width 6 
    vTcl:DefineAlias "$site_3_0.lab73" "Label2" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.lab73 "$site_3_0.lab73 Label $top all _vTclBalloon"
    bind $site_3_0.lab73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Zoom QL}
    }
    label $site_3_0.cpd74 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable ZoomBMP -width 6 
    vTcl:DefineAlias "$site_3_0.cpd74" "Label3" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.cpd74 "$site_3_0.cpd74 Label $top all _vTclBalloon"
    bind $site_3_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Zoom BMP}
    }
    pack $site_3_0.lab73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel202" 1
    set site_3_0 $top.fra71
    button $site_3_0.but72 \
        -activebackground #ffff00 \
        -command {global BMPImageOpen MouseActiveButton OpenDirFile
#BMP PROCESS
global Load_ViewBMPFile PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_ViewBMPFile == 0} {
    source "GUI/bmp_process/ViewBMPFile.tcl"
    set Load_ViewBMPFile 1
    WmTransient .top27 $PSPTopLevel
    }

if {"$BMPImageOpen" == "1"} {
    if {$MouseActiveButton != "Zoom"} {
        MouseActiveFunction "ZoomQL"
        } else {
        MouseActiveFunction ""
        } 
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images zoom2.gif]] \
        -pady 0 -text button -width 20 
    vTcl:DefineAlias "$site_3_0.but72" "Button2" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.but72 "$site_3_0.but72 Button $top all _vTclBalloon"
    bind $site_3_0.but72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Zoom Tool}
    }
    label $site_3_0.lab75 \
        -background #ffffff -foreground #0000ff -relief sunken -text 0:0 \
        -textvariable ZoomBMPQL -width 6 
    vTcl:DefineAlias "$site_3_0.lab75" "Label1" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.lab75 "$site_3_0.lab75 Label $top all _vTclBalloon"
    bind $site_3_0.lab75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Zoom Value}
    }
    button $site_3_0.but74 \
        \
        -command {global TrainingAreaTool OpenDirFile
global BMPImageOpen MouseActiveButton

if {$OpenDirFile == 0} {

if {"$BMPImageOpen" == "1"} {
    if {$MouseActiveButton != "Training"} {
        set TrainingAreaTool "rect"
        MouseActiveFunction "TrainingQL"
        } else {
        if {$TrainingAreaTool == "rect"} {
            MouseActiveFunction ""
            } else {
            set TrainingAreaTool "rect"
            MouseActiveFunction "TrainingQL"
            }
        } 
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images rectangle.gif]] \
        -text button 
    vTcl:DefineAlias "$site_3_0.but74" "Button3" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.but74 "$site_3_0.but74 Button $top all _vTclBalloon"
    bind $site_3_0.but74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select Tool}
    }
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra49 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra49" "Frame168" vTcl:WidgetProc "Toplevel202" 1
    set site_3_0 $top.fra49
    button $site_3_0.but26 \
        -background #ffff00 \
        -command {global ActiveProgram ActiveImportData VarError ErrorMessage OpenDirFile
global MultiLookCol MultiLookRow SubSampCol SubSampRow
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global FileInputASAR AsarDataFormat AsarDirOutput AsarExtractFonction
global EOSIFileInputFlag EOSIDirInput EOSIOutputDir EOSIOutputSubDir EOSIExtractFonction ImageEOSIExtractMenu
global PSPImportFileInputFlag PSPImportInputFormat PSPImportOutputFormat
global PSPImportDirInput PSPImportOutputDir PSPImportOutputSubDir
global PSPSymmetrisation
global ImportDataExtractFonction ImageImportDataExtractMenu
global RawBinaryDirInput RawBinaryDirOutput 
global RawBinaryDataType RawBinaryDataFormat RawBinaryDataFormatPP
global RawBinaryDataInput RawBinaryFileInputFlag
global ALOSDirInput ALOSDirOutput ALOSFileInputFlag ALOSDataFormat
global CSKFileInputFlag CSKDataFormat CSKDirInput CSKDirOutput
global RADARSAT2DirInput RADARSAT2DirOutput RADARSAT2FileInputFlag RADARSAT2DataFormat
global RISATDirInput RISATDirOutput RISATFileInputFlag RISATDataFormat
global SENTINEL1DirInput SENTINEL1DirOutput SENTINEL1FileInputFlag SENTINEL1DataFormat
global SENTINEL1Burst SENTINEL1LigInit SENTINEL1ColInit SENTINEL1LigFinal SENTINEL1ColFinal
global TERRASARXDirInput TERRASARXDirOutput TERRASARXFileInputFlag
global TERRASARXDataFormat TERRASARXDataLevel
global TANDEMXDirInputMaster TANDEMXDirOutputMaster TANDEMXDirInputSlave TANDEMXDirOutputSlave
global SIRCDirInput SIRCDirOutput SIRCFileInputFlag
global AIRSARDirInput AIRSARDirOutput AIRSARFileInputFlag AIRSARProcessor AIRSARDataFormat TOPSAROutputFormat
global FileInputSTK1 FileInputSTK2 FileInputSTK3 FileInputSTK4 FileInputSTK5
global FlagFileInputSTK1 FlagFileInputSTK2 FlagFileInputSTK3 FlagFileInputSTK4 FlagFileInputSTK5
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global CONVAIRDirInput CONVAIRDirOutput CONVAIRFileInputFlag
global EMISARDirInput EMISARDirOutput EMISARFileInputFlag
global ESARDirInput ESARDirOutput ESARFileInputFlag
global FSARDirInput FSARDirOutput FSARFileInputFlag
global PISARDirInput PISARDirOutput PISARFileInputFlag
global SETHIDirInput SETHIDirOutput SETHIFileInputFlag
global UAVSARDirInput UAVSARDirOutput UAVSARFileInputFlag UAVSARDataFormat
global ImageSource BMPImage
global BMPImageOpen BMPSubAreaFlag
global SourceWidth SourceHeight ZoomBMP ZoomBMPQL QLZoomBMP
global QLBMPMouseX QLBMPMouseY QLMouseInitX QLMouseInitY QLMouseEndX QLMouseEndY QLMouseNlig QLMouseNcol
global MouseActiveButton TrainingAreaTool rect_color 
#DATA IMPORT
global Load_ASAR_Extract_Data Load_EOSI_Extract_Data Load_PSP_Extract_Data Load_TOPSAR_Extract_Data Load_EOSI_TDX_Extract_Data 
#BMP PROCESS
global Load_ViewBMPFile Load_ViewBMP1 PSPTopLevel

if {$OpenDirFile == 0} {

set NligFullSize $NligFullSizeInput
set NcolFullSize $NcolFullSizeInput
set NligInit [expr $QLMouseInitY + 1]
set NcolInit [expr $QLMouseInitX + 1]
set NligEnd [expr $QLMouseEndY + 1]
set NcolEnd [expr $QLMouseEndX + 1]

if {$ActiveProgram == "SENTINEL1"} {
    if {$SENTINEL1Burst != "ALL" } {
        set NligInit [expr $QLMouseInitY + 1 + $SENTINEL1LigInit]
        set NligEnd [expr $QLMouseEndY + 1 + $SENTINEL1LigInit]
        set NcolInit [expr $QLMouseInitX + 1 + $SENTINEL1ColInit]
        set NcolEnd [expr $QLMouseEndX + 1 + $SENTINEL1ColInit]
        }
    }
if {$ActiveImportData == "SENTINEL1"} {
    if {$SENTINEL1Burst != "ALL" } {
        set NligInit [expr $QLMouseInitY + 1 + $SENTINEL1LigInit]
        set NligEnd [expr $QLMouseEndY + 1 + $SENTINEL1LigInit]
        set NcolInit [expr $QLMouseInitX + 1 + $SENTINEL1ColInit]
        set NcolEnd [expr $QLMouseEndX + 1 + $SENTINEL1ColInit]
        }
    }

if { $BMPImageOpen == 1 } {
    #Display Window
    if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP); TextEditorRunTrace "Close Window View BMP File" "b"}
    if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1); TextEditorRunTrace "Close Window View BMP1" "b"}
    image delete ImageSource
    image delete BMPImage
    set SourceWidth ""
    set SourceHeight ""
    set QLBMPMouseX ""
    set QLBMPMouseY ""
    set QLMouseInitX ""
    set QLMouseInitY ""
    set QLMouseEndX ""
    set QLMouseEndY ""
    set QLMouseNlig ""
    set QLMouseNcol ""
    set MouseActiveFunction ""
    set TrainingAreaTool ""
    set rect_color ""
    set ZoomBMP "0:0"
    set BMPImageOpen "0"
    set BMPSubAreaFlag 0
    Window hide $widget(Toplevel202); TextEditorRunTrace "Close Window Sub-Area Graphic Editor" "b"
    }
         
set MultiLookCol ""
set MultiLookRow ""
set SubSampCol ""
set SubSampRow ""

if {$ActiveProgram == "POLSARPRO"} {
    set LoadWidget "psp"
    if {$ActiveImportData == "AIRSAR"} {
        if {$AIRSARProcessor == "TOPSAR"} {set LoadWidget "topsar"}
        }
    if {$ActiveImportData == "ASAR"} {set LoadWidget "asar"}
    if {$ActiveImportData == "TANDEMX"} {set LoadWidget "tandemx"}


    if {$LoadWidget == "psp"} {
        if {$Load_PSP_Extract_Data == 0} {
            source "GUI/data_import/PSP_Extract_Data.tcl"
            set Load_PSP_Extract_Data 1
            WmTransient $widget(Toplevel233) $PSPTopLevel
            }
        }
    if {$LoadWidget == "topsar"} {
        if {$Load_TOPSAR_Extract_Data == 0} {
            source "GUI/data_import/TOPSAR_Extract_Data.tcl"
            set Load_TOPSAR_Extract_Data 1
            WmTransient $widget(Toplevel251) $PSPTopLevel
            }
        }
    if {$LoadWidget == "tandemx"} {
        if {$Load_EOSI_TDX_Extract_Data == 0} {
            source "GUI/data_import/EOSI_TDX_Extract_Data.tcl"
            set Load_EOSI_TDX_Extract_Data 1
            WmTransient $widget(Toplevel437) $PSPTopLevel
            }
        }
    if {$LoadWidget == "asar"} {
        if {$Load_ASAR_Extract_Data == 0} {
            source "GUI/data_import/ASAR_Extract_Data.tcl"
            set Load_ASAR_Extract_Data 1
            WmTransient $widget(Toplevel203) $PSPTopLevel
            }
        }

    if {$ActiveImportData == "RAWBINARYDATA"} {set PSPImportDirInput $RawBinaryDirInput; set PSPImportOutputDir $RawBinaryDirOutput }
    if {$ActiveImportData == "ALOS"} {set PSPImportDirInput $ALOSDirInput; set PSPImportOutputDir $ALOSDirOutput }
    if {$ActiveImportData == "ALOS2"} {set PSPImportDirInput $ALOSDirInput; set PSPImportOutputDir $ALOSDirOutput }
    if {$ActiveImportData == "CSK"} {set PSPImportDirInput $CSKDirInput; set PSPImportOutputDir $CSKDirOutput }
    if {$ActiveImportData == "RADARSAT2"} {set PSPImportDirInput $RADARSAT2DirInput; set PSPImportOutputDir $RADARSAT2DirOutput }
    if {$ActiveImportData == "RISAT"} {set PSPImportDirInput $RISATDirInput; set PSPImportOutputDir $RISATDirOutput }
    if {$ActiveImportData == "SENTINEL1"} {set PSPImportDirInput $SENTINEL1DirInput; set PSPImportOutputDir $SENTINEL1DirOutput }
    if {$ActiveImportData == "TERRASARX"} {set PSPImportDirInput $TERRASARXDirInput; set PSPImportOutputDir $TERRASARXDirOutput }
    if {$ActiveImportData == "SIRC"} {set PSPImportDirInput $SIRCDirInput; set PSPImportOutputDir $SIRCDirOutput }
    if {$ActiveImportData == "AIRSAR"} {
        if {$LoadWidget == "topsar"} {  
            set EOSIDirInput $AIRSARDirInput; set EOSIOutputDir $AIRSARDirOutput
            set EOSIFileInputFlag 1; set EOSIOutputSubDir "T3"; set EOSIExtractFonction "Full"
            } else {
            set PSPImportDirInput $AIRSARDirInput; set PSPImportOutputDir $AIRSARDirOutput
            }
        }
    if {$ActiveImportData == "CONVAIR"} {set PSPImportDirInput $CONVAIRDirInput; set PSPImportOutputDir $CONVAIRDirOutput }
    if {$ActiveImportData == "EMISAR"} {set PSPImportDirInput $EMISARDirInput; set PSPImportOutputDir $EMISARDirOutput }
    if {$ActiveImportData == "ESAR"} {set PSPImportDirInput $ESARDirInput; set PSPImportOutputDir $ESARDirOutput }
    if {$ActiveImportData == "FSAR"} {set PSPImportDirInput $FSARDirInput; set PSPImportOutputDir $FSARDirOutput }
    if {$ActiveImportData == "PISAR"} {set PSPImportDirInput $PISARDirInput; set PSPImportOutputDir $PISARDirOutput }
    if {$ActiveImportData == "SETHI"} {set PSPImportDirInput $SETHIDirInput; set PSPImportOutputDir $SETHIDirOutput }
    if {$ActiveImportData == "UAVSAR"} {set PSPImportDirInput $UAVSARDirInput; set PSPImportOutputDir $UAVSARDirOutput }
    set PSPImportExtractFonction ""
    set PSPImportOutputFormat ""
    set PSPImportOutputSubDir ""
    if {$LoadWidget == "psp"} {
        $widget(Label233_1) configure -state disable
        $widget(Label233_2) configure -state disable
        $widget(Label233_3) configure -state disable
        $widget(Label233_4) configure -state disable
        $widget(Entry233_1) configure -state disable
        $widget(Entry233_2) configure -state disable
        $widget(Entry233_3) configure -state disable
        $widget(Entry233_4) configure -state disable
    
        set PSPSymmetrisation 0; $widget(Checkbutton233_1) configure -state disable
    
        $widget(Radiobutton233_1) configure -state disable; $widget(Radiobutton233_2) configure -state disable; $widget(Radiobutton233_3) configure -state disable
        $widget(Radiobutton233_4) configure -state disable; $widget(Radiobutton233_5) configure -state disable
        $widget(Radiobutton233_6) configure -state disable; $widget(Radiobutton233_7) configure -state disable; $widget(Radiobutton233_8) configure -state disable
    
        if {$ActiveImportData == "RAWBINARYDATA"} {
            if {$RawBinaryDataFormat == "S2"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
            if {$RawBinaryDataFormat == "SPP"} { set PSPImportInputFormat "Dual Polarisation Elements" }
            if {$RawBinaryDataFormat == "IPP"} { set PSPImportInputFormat "Intensities Elements" }
            if {$RawBinaryDataFormat == "T3"} { set PSPImportInputFormat "3x3 Complex Coherency Matrix T3" }
            if {$RawBinaryDataFormat == "T4"} { set PSPImportInputFormat "4x4 Complex Coherency Matrix T4" }
            if {$RawBinaryDataFormat == "C3"} { set PSPImportInputFormat "3x3 Complex Covariance Matrix C3" }
            if {$RawBinaryDataFormat == "C4"} { set PSPImportInputFormat "4x4 Complex Covariance Matrix C4" }
            }
        if {$ActiveImportData == "ALOS"} {
            if {$ALOSDataFormat == "quad1.1"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
            if {$ALOSDataFormat == "quad1.5"} { set PSPImportInputFormat "Intensities Elements" }
            if {$ALOSDataFormat == "dual1.1"} { set PSPImportInputFormat "Dual Polarisation Elements" }
            if {$ALOSDataFormat == "dual1.5"} { set PSPImportInputFormat "Dual Intensities Elements" }
            if {$ALOSDataFormat == "dual1.1vex"} { set PSPImportInputFormat "Dual Polarisation Elements" }
            if {$ALOSDataFormat == "quad1.1vex"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
            }
        if {$ActiveImportData == "ALOS2"} {
            if {$ALOSDataFormat == "quad1.1"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
            if {$ALOSDataFormat == "dual1.1"} { set PSPImportInputFormat "Dual Polarisation Elements" }
            }
        if {$ActiveImportData == "CSK"} {
            if {$CSKDataFormat == "dual"} { set PSPImportInputFormat "Dual Polarisation Elements" }
            }
        if {$ActiveImportData == "RADARSAT2"} {
            if {$RADARSAT2DataFormat == "quad"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
            if {$RADARSAT2DataFormat == "dual"} { set PSPImportInputFormat "Dual Polarisation Elements" }
            }
        if {$ActiveImportData == "RISAT"} {
            if {$RISATDataFormat == "quad1.1"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
            if {$RISATDataFormat == "dual1.1"} { set PSPImportInputFormat "Dual Polarisation Elements" }
            }
        if {$ActiveImportData == "SENTINEL1"} {
            if {$SENTINEL1DataFormat == "dual"} { set PSPImportInputFormat "Dual Polarisation Elements" }
            }
        if {$ActiveImportData == "TERRASARX"} {
            if {$TERRASARXDataFormat == "dual"} {
                if {$TERRASARXDataLevel == "SSC"} {
                   set PSPImportInputFormat "Dual Polarisation Elements"
                   } else {
                   set PSPImportInputFormat "Dual Intensities Elements"
                   }
                }
            }
        if {$ActiveImportData == "SIRC"} {
            if {$SIRCDataFormat == "SLCquad"} { set PSPImportInputFormat "SLC Quad-Pol Coded Sinclair Elements" }
            if {$SIRCDataFormat == "MLCquad"} { set PSPImportInputFormat "MLC Quad-Pol Coded Stokes Elements" }
            if {$SIRCDataFormat == "SLCdual"} { set PSPImportInputFormat "SLC Dual-Pol Coded Sinclair Elements" }
            if {$SIRCDataFormat == "MLCdual"} { set PSPImportInputFormat "MLC Dual-Pol Coded Stokes Elements" }
            }
        if {$ActiveImportData == "AIRSAR"} { 
            set PSPImportInputFormat "Coded Stokes Elements"
            if {$AIRSARDataFormat == "SLC"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2"}
            }
        if {$ActiveImportData == "CONVAIR"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
        if {$ActiveImportData == "EMISAR"} {
            if {$EMISARDataFormat == "S2"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
            if {$EMISARDataFormat == "C3"} { set PSPImportInputFormat "3x3 Complex Covariance Matrix C3" }
            }
        if {$ActiveImportData == "ESAR"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
        if {$ActiveImportData == "FSAR"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
        if {$ActiveImportData == "PISAR"} {
    	      if {$PISARDataFormat == "MGPC"} { set PSPImportInputFormat "Coded Stokes Elements" }
    	      if {$PISARDataFormat == "MGPSSC"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
    	      }
        if {$ActiveImportData == "SETHI"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
        if {$ActiveImportData == "UAVSAR"} {
    	      if {$UAVSARDataFormat == "MLC"} { set PSPImportInputFormat "3x3 Complex Covariance Matrix C3" }
    	      if {$UAVSARDataFormat == "GRD"} { set PSPImportInputFormat "3x3 Complex Covariance Matrix C3" }
    	      if {$UAVSARDataFormat == "SLC"} { set PSPImportInputFormat "2x2 Complex Scattering Matrix S2" }
    	      }
    
        package require Img
        image create photo ImagePSPImportExtractMenu
        ImagePSPImportExtractMenu blank
        $widget(CANVASPSPImportEXTRACTMENU) create image 0 0 -anchor nw -image ImagePSPImportExtractMenu
        image delete ImagePSPImportExtractMenu
        if {$ActiveImportData == "RAWBINARYDATA"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/PSPv2RawData.gif"}
        if {$ActiveImportData == "ALOS"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/ALOS.gif"}
        if {$ActiveImportData == "ALOS2"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/ALOS2.gif"}
        if {$ActiveImportData == "CSK"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/CSK.gif"}
        if {$ActiveImportData == "RADARSAT2"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/RADARSAT2.gif"}
        if {$ActiveImportData == "RISAT"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/RISAT.gif"}
        if {$ActiveImportData == "SENTINEL1"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/SENTINEL1.gif"}
        if {$ActiveImportData == "TERRASARX"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/TERRASARX.gif"}
        if {$ActiveImportData == "SIRC"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/SIRC.gif"}
        if {$ActiveImportData == "AIRSAR"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/AIRSAR.gif"}
        if {$ActiveImportData == "CONVAIR"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/CONVAIR.gif"}
        if {$ActiveImportData == "EMISAR"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/EMISAR.gif"}
        if {$ActiveImportData == "ESAR"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/ESAR.gif"}
        if {$ActiveImportData == "FSAR"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/FSAR.gif"}
        if {$ActiveImportData == "PISAR"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/PISAR.gif"}
        if {$ActiveImportData == "SETHI"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/SETHI.gif"} 
        if {$ActiveImportData == "UAVSAR"} {image create photo ImagePSPImportExtractMenu -file "GUI/Images/UAVSAR.gif"} 
        $widget(CANVASPSPImportEXTRACTMENU) create image 0 0 -anchor nw -image ImagePSPImportExtractMenu
        WidgetShow $widget(Toplevel233); TextEditorRunTrace "Open Window Extract Data" "b"
        wm title $widget(Toplevel233) [file tail "$ActiveProgram Extract Data"]
        }
        
    if {$LoadWidget == "asar"} {
        set AsarExtractFonction "Full"
        $widget(Label203_1) configure -state disable; $widget(Label203_2) configure -state disable
        $widget(Label203_3) configure -state disable; $widget(Label203_4) configure -state disable
        $widget(Entry203_1) configure -state disable; $widget(Entry203_2) configure -state disable
        $widget(Entry203_3) configure -state disable; $widget(Entry203_4) configure -state disable
        WidgetShow $widget(Toplevel203); TextEditorRunTrace "Open Window ASAR Extract Data" "b"
        }

    if {$LoadWidget == "topsar"} {
        $widget(Label251_1) configure -state disable; $widget(Label251_2) configure -state disable
        $widget(Label251_3) configure -state disable; $widget(Label251_4) configure -state disable
        $widget(Entry251_1) configure -state disable; $widget(Entry251_2) configure -state disable
        $widget(Entry251_3) configure -state disable; $widget(Entry251_4) configure -state disable
        set FlagFileInputSTK1 "0"; set FlagFileInputSTK2 "0"; set FlagFileInputSTK3 "0"; set FlagFileInputSTK4 "0"; set FlagFileInputSTK5 "0"
        $widget(Checkbutton251_1) configure -state disable; $widget(Checkbutton251_2) configure -state disable; $widget(Checkbutton251_3) configure -state disable
        $widget(Checkbutton251_4) configure -state disable; $widget(Checkbutton251_5) configure -state disable
        $widget(Radiobutton251_1) configure -state normal; $widget(Radiobutton251_2) configure -state normal; set TOPSAROutputFormat "T3"
        if {$FileInputSTK1 != ""} { $widget(Checkbutton251_1) configure -state normal }
        if {$FileInputSTK2 != ""} { $widget(Checkbutton251_2) configure -state normal }
        if {$FileInputSTK3 != ""} { $widget(Checkbutton251_3) configure -state normal }
        if {$FileInputSTK4 != ""} { $widget(Checkbutton251_4) configure -state normal }
        if {$FileInputSTK5 != ""} { $widget(Checkbutton251_5) configure -state normal }
        WidgetShow $widget(Toplevel251); TextEditorRunTrace "Open Window TOPSAR Extract Data" "b"
        }

    if {$LoadWidget == "tandemx"} {
        set EOSIDirInputMaster $TANDEMXDirInputMaster; set EOSIOutputDirMaster $TANDEMXDirOutputMaster
        set EOSIDirInputSlave $TANDEMXDirInputSlave; set EOSIOutputDirSlave $TANDEMXDirOutputSlave
        set EOSIOutputSubDir ""
        set EOSIExtractFonction "Full"
        set TANDEMXBistaticCorrection 0
        $widget(Label437_1) configure -state disable; $widget(Label437_2) configure -state disable
        $widget(Entry437_1) configure -state disable; $widget(Entry437_2) configure -state disable
        WidgetShow $widget(Toplevel437); TextEditorRunTrace "Open Window $ActiveProgram Extract Data" "b"
        wm title $widget(Toplevel437) [file tail "$ActiveProgram Extract Data"]
        }

    } else {
    #End PolSarpro

    set LoadWidget "eosi"
    if {$ActiveProgram == "AIRSAR"} {
        if {$AIRSARProcessor == "TOPSAR"} {set LoadWidget "topsar"}
        }
    if {$ActiveProgram == "ASAR"} {set LoadWidget "asar"}
    if {$ActiveProgram == "TANDEMX"} {set LoadWidget "tandemx"}
    
    if {$LoadWidget == "eosi"} {  
        if {$Load_EOSI_Extract_Data == 0} {
            source "GUI/data_import/EOSI_Extract_Data.tcl"
            set Load_EOSI_Extract_Data 1
            WmTransient $widget(Toplevel229) $PSPTopLevel
            }
        }
    if {$LoadWidget == "topsar"} {  
        if {$Load_TOPSAR_Extract_Data == 0} {
            source "GUI/data_import/TOPSAR_Extract_Data.tcl"
            set Load_TOPSAR_Extract_Data 1
            WmTransient $widget(Toplevel251) $PSPTopLevel
            }
        }
    if {$LoadWidget == "tandemx"} {  
        if {$Load_EOSI_TDX_Extract_Data == 0} {
            source "GUI/data_import/EOSI_TDX_Extract_Data.tcl"
            set Load_EOSI_TDX_Extract_Data 1
            WmTransient $widget(Toplevel437) $PSPTopLevel
            }
        }
    if {$LoadWidget == "asar"} {  
        if {$Load_ASAR_Extract_Data == 0} {
            source "GUI/data_import/ASAR_Extract_Data.tcl"
            set Load_ASAR_Extract_Data 1
            WmTransient $widget(Toplevel203) $PSPTopLevel
            }
        }

    if {$ActiveProgram == "ALOS"} {set EOSIDirInput $ALOSDirInput; set EOSIOutputDir $ALOSDirOutput }
    if {$ActiveProgram == "ALOS2"} {set EOSIDirInput $ALOSDirInput; set EOSIOutputDir $ALOSDirOutput }
    if {$ActiveProgram == "CSK"} {set EOSIDirInput $CSKDirInput; set EOSIOutputDir $CSKDirOutput }
    if {$ActiveProgram == "RADARSAT2"} {set EOSIDirInput $RADARSAT2DirInput; set EOSIOutputDir $RADARSAT2DirOutput }
    if {$ActiveProgram == "RISAT"} {set EOSIDirInput $RISATDirInput; set EOSIOutputDir $RISATDirOutput }
    if {$ActiveProgram == "SENTINEL1"} {set EOSIDirInput $SENTINEL1DirInput; set EOSIOutputDir $SENTINEL1DirOutput }
    if {$ActiveProgram == "TERRASARX"} {set EOSIDirInput $TERRASARXDirInput; set EOSIOutputDir $TERRASARXDirOutput }
    if {$ActiveProgram == "SIRC"} {set EOSIDirInput $SIRCDirInput; set EOSIOutputDir $SIRCDirOutput }
    if {$ActiveProgram == "AIRSAR"} {set EOSIDirInput $AIRSARDirInput; set EOSIOutputDir $AIRSARDirOutput }
    if {$ActiveProgram == "CONVAIR"} {set EOSIDirInput $CONVAIRDirInput; set EOSIOutputDir $CONVAIRDirOutput }
    if {$ActiveProgram == "EMISAR"} {set EOSIDirInput $EMISARDirInput; set EOSIOutputDir $EMISARDirOutput }
    if {$ActiveProgram == "ESAR"} {set EOSIDirInput $ESARDirInput; set EOSIOutputDir $ESARDirOutput }
    if {$ActiveProgram == "FSAR"} {set EOSIDirInput $FSARDirInput; set EOSIOutputDir $FSARDirOutput }
    if {$ActiveProgram == "PISAR"} {set EOSIDirInput $PISARDirInput; set EOSIOutputDir $PISARDirOutput }
    if {$ActiveProgram == "SETHI"} {set EOSIDirInput $SETHIDirInput; set EOSIOutputDir $SETHIDirOutput }
    if {$ActiveProgram == "UAVSAR"} {set EOSIDirInput $UAVSARDirInput; set EOSIOutputDir $UAVSARDirOutput }
    set EOSIOutputSubDir "T3"
    set EOSIExtractFonction "Full"

    if {$ActiveProgram == "ALOS"} {
        if {$ALOSDataFormat == "quad1.1"} { set EOSIOutputSubDir "T3" }
        if {$ALOSDataFormat == "quad1.5"} { set EOSIOutputSubDir "" }
        if {$ALOSDataFormat == "dual1.1"} { set EOSIOutputSubDir "C2" }
        if {$ALOSDataFormat == "dual1.5"} { set EOSIOutputSubDir "" }
        if {$ALOSDataFormat == "dual1.1vex"} { set EOSIOutputSubDir "C2" }
        if {$ALOSDataFormat == "quad1.1vex"} { set EOSIOutputSubDir "T3" }
        }
    if {$ActiveProgram == "ALOS2"} {
        if {$ALOSDataFormat == "quad1.1"} { set EOSIOutputSubDir "T3" }
        if {$ALOSDataFormat == "dual1.1"} { set EOSIOutputSubDir "C2" }
        }
    if {$ActiveProgram == "CSK"} {
        if {$CSKDataFormat == "dual"} { set EOSIOutputSubDir "C2" }
        }
    if {$ActiveProgram == "RADARSAT2"} {
        if {$RADARSAT2DataFormat == "dual"} { set EOSIOutputSubDir "C2" }
        }
    if {$ActiveProgram == "RISAT"} {
        if {$RISATDataFormat == "quad1.1"} { set EOSIOutputSubDir "T3" }
        if {$RISATDataFormat == "dual1.1"} { set EOSIOutputSubDir "C2" }
        }
    if {$ActiveProgram == "SENTINEL1"} {
        if {$SENTINEL1DataFormat == "dual"} { set EOSIOutputSubDir "C2" }
        }
    if {$ActiveProgram == "TERRASARX"} {
        if {$TERRASARXDataFormat == "dual"} {
            if {$TERRASARXDataLevel == "SSC"} {
                set EOSIOutputSubDir "C2"
                } else {
                set EOSIOutputSubDir ""
                }
            }
        }
    if {$ActiveProgram == "SIRC"} {
        if {$SIRCDataFormat == "SLCdual"} { set EOSIOutputSubDir "C2" }
        if {$SIRCDataFormat == "MLCdual"} { set EOSIOutputSubDir "C2" }
        }
    
    if {$LoadWidget == "eosi"} {  
        $widget(Label229_1) configure -state disable; $widget(Label229_2) configure -state disable
        $widget(Label229_3) configure -state disable; $widget(Label229_4) configure -state disable
        $widget(Entry229_1) configure -state disable; $widget(Entry229_2) configure -state disable
        $widget(Entry229_3) configure -state disable; $widget(Entry229_4) configure -state disable
        package require Img
        image create photo ImageEOSIExtractMenu
        ImageEOSIExtractMenu blank
        $widget(CANVASEOSIEXTRACTMENU) create image 0 0 -anchor nw -image ImageEOSIExtractMenu
        image delete ImageEOSIExtractMenu
        if {$ActiveProgram == "ALOS"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/ALOS.gif"}
        if {$ActiveProgram == "ALOS2"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/ALOS2.gif"}
        if {$ActiveProgram == "CSK"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/CSK.gif"}
        if {$ActiveProgram == "RADARSAT2"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/RADARSAT2.gif"}
        if {$ActiveProgram == "RISAT"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/RISAT.gif"}
        if {$ActiveProgram == "SENTINEL1"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/SENTINEL1.gif"}
        if {$ActiveProgram == "TERRASARX"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/TERRASARX.gif"}
        if {$ActiveProgram == "SIRC"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/SIRC.gif"}
        if {$ActiveProgram == "AIRSAR"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/AIRSAR.gif"}
        if {$ActiveProgram == "CONVAIR"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/CONVAIR.gif"}
        if {$ActiveProgram == "EMISAR"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/EMISAR.gif"}
        if {$ActiveProgram == "ESAR"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/ESAR.gif"}
        if {$ActiveProgram == "FSAR"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/FSAR.gif"}
        if {$ActiveProgram == "PISAR"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/PISAR.gif"}
        if {$ActiveProgram == "SETHI"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/SETHI.gif"} 
        if {$ActiveProgram == "UAVSAR"} {image create photo ImageEOSIExtractMenu -file "GUI/Images/UAVSAR.gif"} 
        $widget(CANVASEOSIEXTRACTMENU) create image 0 0 -anchor nw -image ImageEOSIExtractMenu
        WidgetShow $widget(Toplevel229); TextEditorRunTrace "Open Window $ActiveProgram Extract Data" "b"
        wm title $widget(Toplevel229) [file tail "$ActiveProgram Extract Data"]
        }
    if {$LoadWidget == "topsar"} {  
        $widget(Label251_1) configure -state disable; $widget(Label251_2) configure -state disable
        $widget(Label251_3) configure -state disable; $widget(Label251_4) configure -state disable
        $widget(Entry251_1) configure -state disable; $widget(Entry251_2) configure -state disable
        $widget(Entry251_3) configure -state disable; $widget(Entry251_4) configure -state disable
        set FlagFileInputSTK1 "0"; set FlagFileInputSTK2 "0"; set FlagFileInputSTK3 "0"; set FlagFileInputSTK4 "0"; set FlagFileInputSTK5 "0"
        $widget(Checkbutton251_1) configure -state disable; $widget(Checkbutton251_2) configure -state disable; $widget(Checkbutton251_3) configure -state disable
        $widget(Checkbutton251_4) configure -state disable; $widget(Checkbutton251_5) configure -state disable
        if {$FileInputSTK1 != ""} { $widget(Checkbutton251_1) configure -state normal }
        if {$FileInputSTK2 != ""} { $widget(Checkbutton251_2) configure -state normal }
        if {$FileInputSTK3 != ""} { $widget(Checkbutton251_3) configure -state normal }
        if {$FileInputSTK4 != ""} { $widget(Checkbutton251_4) configure -state normal }
        if {$FileInputSTK5 != ""} { $widget(Checkbutton251_5) configure -state normal }
        WidgetShow $widget(Toplevel251); TextEditorRunTrace "Open Window TOPSAR Extract Data" "b"
        }
    if {$LoadWidget == "asar"} {  
        set AsarExtractFonction "Full"
        $widget(Label203_1) configure -state disable; $widget(Label203_2) configure -state disable
        $widget(Label203_3) configure -state disable; $widget(Label203_4) configure -state disable
        $widget(Entry203_1) configure -state disable; $widget(Entry203_2) configure -state disable
        $widget(Entry203_3) configure -state disable; $widget(Entry203_4) configure -state disable
        WidgetShow $widget(Toplevel203); TextEditorRunTrace "Open Window ASAR Extract Data" "b"
        }
    if {$LoadWidget == "tandemx"} {  
        set EOSIDirInputMaster $TANDEMXDirInputMaster; set EOSIOutputDirMaster $TANDEMXDirOutputMaster
        set EOSIDirInputSlave $TANDEMXDirInputSlave; set EOSIOutputDirSlave $TANDEMXDirOutputSlave
        set EOSIOutputSubDir ""
        set EOSIExtractFonction "Full"
        set TANDEMXBistaticCorrection 0
        $widget(Label437_1) configure -state disable; $widget(Label437_2) configure -state disable
        $widget(Entry437_1) configure -state disable; $widget(Entry437_2) configure -state disable
        WidgetShow $widget(Toplevel437); TextEditorRunTrace "Open Window $ActiveProgram Extract Data" "b"
        wm title $widget(Toplevel437) [file tail "$ActiveProgram Extract Data"]
        }
    }
}} \
        -padx 4 -pady 2 -text Extract 
    vTcl:DefineAlias "$site_3_0.but26" "Button88" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.but26 "$site_3_0.but26 Button $top all _vTclBalloon"
    bind $site_3_0.but26 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Extract the selected area}
    }
    button $site_3_0.but27 \
        -background #ffff00 \
        -command {global ImageSource BMPImage OpenDirFile
global BMPImageOpen BMPSubAreaFlag
global SourceWidth SourceHeight ZoomBMP ZoomBMPQL QLZoomBMP
global QLBMPMouseX QLBMPMouseY QLMouseInitX QLMouseInitY QLMouseEndX QLMouseEndY QLMouseNlig QLMouseNcol
global MouseActiveButton TrainingAreaTool rect_color 

#BMP PROCESS
global Load_ViewBMPFile Load_ViewBMP1

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    #Display Window
    if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP); TextEditorRunTrace "Close Window View BMP File" "b"}
    if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1); TextEditorRunTrace "Close Window View BMP1" "b"}
    image delete ImageSource
    image delete BMPImage
    set SourceWidth ""
    set SourceHeight ""
    set QLBMPMouseX ""
    set QLBMPMouseY ""
    set QLMouseInitX ""
    set QLMouseInitY ""
    set QLMouseEndX ""
    set QLMouseEndY ""
    set QLMouseNlig ""
    set QLMouseNcol ""
    set MouseActiveButton ""
    set TrainingAreaTool ""
    set rect_color ""
    set ZoomBMP "0:0"
    set BMPImageOpen "0"
    set BMPSubAreaFlag 0
    Window hide $widget(Toplevel202); TextEditorRunTrace "Close Window Sub-Area Graphic Editor" "b"
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but27" "Button89" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.but27 "$site_3_0.but27 Button $top all _vTclBalloon"
    bind $site_3_0.but27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    button $site_3_0.but69 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SubArea_GraphicEditor.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but69" "Button1" vTcl:WidgetProc "Toplevel202" 1
    bindtags $site_3_0.but69 "$site_3_0.but69 Button $top all _vTclBalloon"
    bind $site_3_0.but69 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help}
    }
    pack $site_3_0.but26 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side right 
    pack $site_3_0.but69 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side top 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd72 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra48 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra70 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra69 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra72 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra49 \
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
Window show .top202

main $argc $argv
