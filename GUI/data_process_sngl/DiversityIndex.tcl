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
    set base .top444
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd86 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd86
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra36 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra36
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
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
    namespace eval ::widgets::$base.cpd74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd74
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd75
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra48 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra48
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra30 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra30
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd71
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra22 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra22
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra23
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd77
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra55 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra55
    namespace eval ::widgets::$site_3_0.fra24 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra24
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd94 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd94
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m66 {
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
            vTclWindow.top444
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
    wm geometry $top 200x200+25+25; update
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

proc vTclWindow.top444 {base} {
    if {$base == ""} {
        set base .top444
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m66" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x450+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Diversity Index"
    vTcl:DefineAlias "$top" "Toplevel444" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd86 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd86" "Frame4" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.cpd86
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel444" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DiversityDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel444" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel444" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel444" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel444" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable DiversityOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel444" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel444" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd81 \
        -padx 1 -text / 
    vTcl:DefineAlias "$site_6_0.cpd81" "Label14" vTcl:WidgetProc "Toplevel444" 1
    entry $site_6_0.cpd80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DiversityOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd80" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel444" 1
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side left 
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame17" vTcl:WidgetProc "Toplevel444" 1
    set site_6_0 $site_5_0.cpd79
    button $site_6_0.cpd87 \
        \
        -command {global DirName DataDir DiversityOutputDir

set DiversityDirOutputTmp $DiversityOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set DiversityOutputDir $DirName
    } else {
    set DiversityOutputDir $DiversityDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    bindtags $site_6_0.cpd87 "$site_6_0.cpd87 Button $top all _vTclBalloon"
    bind $site_6_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra36 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame9" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.fra36
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel444" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel444" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel444" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel444" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel444" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel444" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel444" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel444" 1
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
    frame $top.cpd74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd74" "Frame40" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.cpd74
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversityShannon"=="1"} {
    $widget(Checkbutton444_1) configure -state normal
    } else { 
    $widget(Checkbutton444_1) configure -state disable
    set BMPshannon "0"
    }} \
        -padx 1 -text {Shannon Index} -variable DiversityShannon 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton20" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPshannon 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_1" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd75 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame41" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.cpd75
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversitySimpson"=="1"} {
    $widget(Checkbutton444_2) configure -state normal 
    } else {
    $widget(Checkbutton444_2) configure -state disable
    set BMPsimpson "0"
    }} \
        -padx 1 -text {Simpson Index} -variable DiversitySimpson 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton21" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPsimpson 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_2" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra48 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra48" "Frame42" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.fra48
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversityInvSimpson"=="1"} {
    $widget(Checkbutton444_3) configure -state normal
    } else {
    $widget(Checkbutton444_3) configure -state disable
    set BMPinvsimpson "0"
    }} \
        -padx 1 -text {Inverse Simpson Index} -variable DiversityInvSimpson 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton27" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPinvsimpson 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_3" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra30 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra30" "Frame269" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.fra30
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversityGini"=="1"} {
    $widget(Checkbutton444_4) configure -state normal
    } else {
    $widget(Checkbutton444_4) configure -state disable
    set BMPgini "0"
    }} \
        -padx 1 -text {Gini Simpson Index} -variable DiversityGini 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton86" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPgini 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_4" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd71 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame43" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.cpd71
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversityReyni2"=="1"} {
    $widget(Checkbutton444_5) configure -state normal
    } else {
    $widget(Checkbutton444_5) configure -state disable
    set BMPreyni2 "0"
    }} \
        -padx 1 -text {Reyni Entropy (order 2)} -variable DiversityReyni2 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton28" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPreyni2 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_5" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra22 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra22" "Frame319" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.fra22
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversityReyni3"=="1"} {
    $widget(Checkbutton444_6) configure -state normal
    } else {
    $widget(Checkbutton444_6) configure -state disable
    set BMPreyni3 "0"
    }} \
        -padx 1 -text {Reyni Entropy (order 3)} -variable DiversityReyni3 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton138" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPreyni3 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_6" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra23 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra23" "Frame320" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.fra23
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversityReyni4"=="1"} {
    $widget(Checkbutton444_7) configure -state normal
    } else {
    $widget(Checkbutton444_7) configure -state disable
    set BMPreyni4 "0"
    }} \
        -padx 1 -text {Reyni Entropy (order 4)} -variable DiversityReyni4 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton444_30" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPreyni4 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_7" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd77 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    set site_3_0 $top.cpd77
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversityIQV"=="1"} {
    $widget(Checkbutton444_14) configure -state normal
    } else {
    $widget(Checkbutton444_14) configure -state disable
    set BMPiqv "0"
    }} \
        -padx 1 -text {Index of Qualitative Inversion ( I.Q.V )} \
        -variable DiversityIQV 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton16" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPiqv 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_14" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd72 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame38" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.cpd72
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$DiversityPerplexity"=="1"} {
    $widget(Checkbutton444_10) configure -state normal
    } else {
    $widget(Checkbutton444_10) configure -state disable
    set BMPperplexity "0"
    }} \
        -padx 1 -text Perplexity -variable DiversityPerplexity 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton18" vTcl:WidgetProc "Toplevel444" 1
    checkbutton $site_3_0.che39 \
        -padx 1 -text BMP -variable BMPperplexity 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton444_10" vTcl:WidgetProc "Toplevel444" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra55 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra55" "Frame47" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.fra55
    frame $site_3_0.fra24 \
        -borderwidth 2 -cursor {} -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame48" vTcl:WidgetProc "Toplevel444" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -padx 1 -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label444" vTcl:WidgetProc "Toplevel444" 1
    entry $site_4_0.ent58 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinDiversityL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry22" vTcl:WidgetProc "Toplevel444" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd94 \
        -borderwidth 2 -cursor {} -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd94" "Frame49" vTcl:WidgetProc "Toplevel444" 1
    set site_4_0 $site_3_0.cpd94
    label $site_4_0.lab57 \
        -padx 1 -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label323" vTcl:WidgetProc "Toplevel444" 1
    entry $site_4_0.ent58 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinDiversityC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry23" vTcl:WidgetProc "Toplevel444" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.cpd68 \
        -background #ffff00 \
        -command {set NwinDiversityL "?"; set NwinDiversityC "?"
set DiversityShannon "1"
set DiversitySimpson "1"
set DiversityInvSimpson "1"
set DiversityGini "1"
set DiversityReyni2 "1"
set DiversityReyni3 "1"
set DiversityReyni4 "1"
set DiversityIQV "1"
set DiversityPerplexity "1"
set BMPshannon "1"
set BMPsimpson "1"
set BMPinvsimpson "1"
set BMPgini "1"
set BMPreyni2 "1"
set BMPreyni3 "1"
set BMPreyni4 "1"
set BMPiqv "1"
set BMPperplexity "1"
$widget(Checkbutton444_1) configure -state normal
$widget(Checkbutton444_2) configure -state normal
$widget(Checkbutton444_3) configure -state normal
$widget(Checkbutton444_4) configure -state normal
$widget(Checkbutton444_5) configure -state normal
$widget(Checkbutton444_6) configure -state normal
$widget(Checkbutton444_7) configure -state normal
$widget(Checkbutton444_10) configure -state normal
$widget(Checkbutton444_14) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd68" "Button104" vTcl:WidgetProc "Toplevel444" 1
    bindtags $site_3_0.cpd68 "$site_3_0.cpd68 Button $top all _vTclBalloon"
    bind $site_3_0.cpd68 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {set NwinDiversityL "?"; set NwinDiversityC "?"
set DiversityShannon "0"
set DiversitySimpson "0"
set DiversityInvSimpson "0"
set DiversityGini "0"
set DiversityReyni2 "0"
set DiversityReyni3 "0"
set DiversityReyni4 "0"
set DiversityIQV "0"
set DiversityPerplexity "0"
set BMPshannon "0"
set BMPsimpson "0"
set BMPinvsimpson "0"
set BMPgini "0"
set BMPreyni2 "0"
set BMPreyni3 "0"
set BMPreyni4 "0"
set BMPiqv "0"
set BMPperplexity "0"
$widget(Checkbutton444_1) configure -state disable
$widget(Checkbutton444_2) configure -state disable
$widget(Checkbutton444_3) configure -state disable
$widget(Checkbutton444_4) configure -state disable
$widget(Checkbutton444_5) configure -state disable
$widget(Checkbutton444_6) configure -state disable
$widget(Checkbutton444_7) configure -state disable
$widget(Checkbutton444_10) configure -state disable
$widget(Checkbutton444_14) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel444" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd94 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 20 -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel444" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir FileName DataFormatActive
global DiversityDirInput DiversityDirOutput DiversityOutputDir DiversityOutputSubDir
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine
global NwinDiversityL NwinDiversityC
global BMPDirInput OpenDirFile PSPMemory TMPMemoryAllocError
global NwinDiversityL NwinDiversityC 
global DiversityShannon DiversitySimpson DiversityInvSimpson 
global DiversityGini DiversityReyni2 DiversityReyni3
global DiversityReyni4 DiversityIQV DiversityPerplexity
global BMPshannon BMPsimpsonBMPinvsimpson
global BMPgini BMPreyni2 BMPreyni3
global BMPreyni4 BMPiqv BMPperplexity 

if {$OpenDirFile == 0} {

set config "false"
if {"$DiversityShannon"=="1"} { set config "true" }
if {"$DiversitySimpson"=="1"} { set config "true" }
if {"$DiversityInvSimpson"=="1"} { set config "true" }
if {"$DiversityGini"=="1"} { set config "true" }
if {"$DiversityReyni2"=="1"} { set config "true" }
if {"$DiversityReyni3"=="1"} { set config "true" }
if {"$DiversityReyni4"=="1"} { set config "true" }
if {"$DiversityIQV"=="1"} { set config "true" }
if {"$DiversityPerplexity"=="1"} { set config "true" }

if {"$config"=="true"} {

    set DiversityDirOutput $DiversityOutputDir
    if {$DiversityOutputSubDir != ""} {append DiversityDirOutput "/$DiversityOutputSubDir"}

    #####################################################################
    #Create Directory
    set DiversityDirOutput [PSPCreateDirectoryMask $DiversityDirOutput $DiversityOutputDir $DiversityDirInput]
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
        set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinDiversityL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinDiversityC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
        TestVar 6
        if {$TestVarError == "ok"} {
            set Fonction "Creation of all the Binary Data Files"
            set Fonction2 "of the Diversity Index"
            set MaskCmd ""
            set MaskFile "$DiversityDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/diversity_index.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DiversityDirInput\x22 -od \x22$DiversityDirOutput\x22 -iodf $DataFormatActive -nwr $NwinDiversityL -nwc $NwinDiversityC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $DiversityShannon -fl2 $DiversitySimpson -fl3 $DiversityInvSimpson -fl4 $DiversityGini -fl5 $DiversityReyni2 -fl6 $DiversityReyni3 -fl7 $DiversityReyni4 -fl8 $DiversityIQV -fl9 $DiversityPerplexity -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/diversity_index.exe -id \x22$DiversityDirInput\x22 -od \x22$DiversityDirOutput\x22 -iodf $DataFormatActive -nwr $NwinDiversityL -nwc $NwinDiversityC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $DiversityShannon -fl2 $DiversitySimpson -fl3 $DiversityInvSimpson -fl4 $DiversityGini -fl5 $DiversityReyni2 -fl6 $DiversityReyni3 -fl7 $DiversityReyni4 -fl8 $DiversityIQV -fl9 $DiversityPerplexity -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            if {"$DiversityShannon"=="1"} {
                if [file exists "$DiversityDirOutput/shannon_index.bin"] {EnviWriteConfig "$DiversityDirOutput/shannon_index.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$DiversitySimpson"=="1"} {
                if [file exists "$DiversityDirOutput/simpson_index.bin"] {EnviWriteConfig "$DiversityDirOutput/simpson_index.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DiversityDirOutput/simpson_index_norm.bin"] {EnviWriteConfig "$DiversityDirOutput/simpson_index_norm.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$DiversityInvSimpson"=="1"} {
                if [file exists "$DiversityDirOutput/inverse_simpson_index.bin"] {EnviWriteConfig "$DiversityDirOutput/inverse_simpson_index.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DiversityDirOutput/inverse_simpson_index_norm.bin"] {EnviWriteConfig "$DiversityDirOutput/inverse_simpson_index_norm.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$DiversityGini"=="1"} {
                if [file exists "$DiversityDirOutput/gini_simpson_index.bin"] {EnviWriteConfig "$DiversityDirOutput/gini_simpson_index.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DiversityDirOutput/gini_simpson_index_norm.bin"] {EnviWriteConfig "$DiversityDirOutput/gini_simpson_index_norm.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$DiversityReyni2"=="1"} {
                if [file exists "$DiversityDirOutput/reyni_entropy2.bin"] {EnviWriteConfig "$DiversityDirOutput/reyni_entropy2.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$DiversityReyni3"=="1"} {
                if [file exists "$DiversityDirOutput/reyni_entropy3.bin"] {EnviWriteConfig "$DiversityDirOutput/reyni_entropy3.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$DiversityReyni4"=="1"} {
                if [file exists "$DiversityDirOutput/reyni_entropy4.bin"] {EnviWriteConfig "$DiversityDirOutput/reyni_entropy4.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$DiversityIQV"=="1"} {
                if [file exists "$DiversityDirOutput/index_qualitative_variation.bin"] {EnviWriteConfig "$DiversityDirOutput/index_qualitative_variation.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$DiversityPerplexity"=="1"} {
                if [file exists "$DiversityDirOutput/perplexity.bin"] {EnviWriteConfig "$DiversityDirOutput/perplexity.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DiversityDirOutput/perplexity_norm.bin"] {EnviWriteConfig "$DiversityDirOutput/perplexity_norm.bin" $FinalNlig $FinalNcol 4}
                }
            #Update the Nlig/Ncol of the new image after processing
            set NligInit 1
            set NcolInit 1
            set NligEnd $FinalNlig
            set NcolEnd $FinalNcol
            
        #####################################################################       

        set Fonction "Creation of the BMP File"

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        if {$DataFormatActive == "S2"} { set Npp 3; set InvNpp 0.333; set Nppm1sNpp 0.666}
        if {$DataFormatActive == "SPP"} { set Npp 2; set InvNpp 0.5; set Nppm1sNpp 0.5}
        if {$DataFormatActive == "C2"} { set Npp 2; set InvNpp 0.5; set Nppm1sNpp 0.5}
        if {$DataFormatActive == "T2"} { set Npp 2; set InvNpp 0.5; set Nppm1sNpp 0.5}
        if {$DataFormatActive == "C3"} { set Npp 3; set InvNpp 0.333; set Nppm1sNpp 0.666}
        if {$DataFormatActive == "T3"} { set Npp 3; set InvNpp 0.333; set Nppm1sNpp 0.666}
        if {$DataFormatActive == "C4"} { set Npp 4; set InvNpp 0.25; set Nppm1sNpp 0.75}
        if {$DataFormatActive == "T4"} { set Npp 4; set InvNpp 0.25; set Nppm1sNpp 0.75}

        if {"$BMPshannon"=="1"} {
            if [file exists "$DiversityDirOutput/shannon_index.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/shannon_index.bin"
                set BMPFileOutput "$DiversityDirOutput/shannon_index.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPsimpson"=="1"} {
            if [file exists "$DiversityDirOutput/simpson_index.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/simpson_index.bin"
                set BMPFileOutput "$DiversityDirOutput/simpson_index.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 $InvNpp 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$DiversityDirOutput/simpson_index_norm.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/simpson_index_norm.bin"
                set BMPFileOutput "$DiversityDirOutput/simpson_index_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPinvsimpson"=="1"} {
            if [file exists "$DiversityDirOutput/inverse_simpson_index.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/inverse_simpson_index.bin"
                set BMPFileOutput "$DiversityDirOutput/inverse_simpson_index.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 1 $Npp
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$DiversityDirOutput/inverse_simpson_index_norm.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/inverse_simpson_index_norm.bin"
                set BMPFileOutput "$DiversityDirOutput/inverse_simpson_index_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPgini"=="1"} {
            if [file exists "$DiversityDirOutput/gini_simpson_index.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/gini_simpson_index.bin"
                set BMPFileOutput "$DiversityDirOutput/gini_simpson_index.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 $Nppm1sNpp
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$DiversityDirOutput/gini_simpson_index_norm.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/gini_simpson_index_norm.bin"
                set BMPFileOutput "$DiversityDirOutput/gini_simpson_index_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPreyni2"=="1"} {
            if [file exists "$DiversityDirOutput/reyni_entropy2.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/reyni_entropy2.bin"
                set BMPFileOutput "$DiversityDirOutput/reyni_entropy2.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPreyni3"=="1"} {
            if [file exists "$DiversityDirOutput/reyni_entropy3.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/reyni_entropy3.bin"
                set BMPFileOutput "$DiversityDirOutput/reyni_entropy3.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPreyni4"=="1"} {
            if [file exists "$DiversityDirOutput/reyni_entropy4.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/reyni_entropy4.bin"
                set BMPFileOutput "$DiversityDirOutput/reyni_entropy4.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPiqv"=="1"} {
            if [file exists "$DiversityDirOutput/index_qualitative_variation.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/index_qualitative_variation.bin"
                set BMPFileOutput "$DiversityDirOutput/index_qualitative_variation.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPperplexity"=="1"} {
            if [file exists "$DiversityDirOutput/perplexity.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/perplexity.bin"
                set BMPFileOutput "$DiversityDirOutput/perplexity.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 1 $Npp
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$DiversityDirOutput/perplexity_norm.bin"] {
                set BMPDirInput $DiversityDirOutput
                set BMPFileInput "$DiversityDirOutput/perplexity_norm.bin"
                set BMPFileOutput "$DiversityDirOutput/perplexity_norm.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel444); TextEditorRunTrace "Close Window Diversity Index" "b"}
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel444" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DiversityIndex.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel444" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel444); TextEditorRunTrace "Close Window Diversity Index" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel444" 1
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
    menu $top.m66 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd86 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra48 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra30 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra22 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra23 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra55 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra59 \
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
Window show .top444

main $argc $argv
