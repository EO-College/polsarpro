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
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}

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
    set base .top100
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
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
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra102 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra102
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
    namespace eval ::widgets::$base.fra103 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra103
    namespace eval ::widgets::$site_3_0.fra115 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra115
    namespace eval ::widgets::$site_4_0.fra117 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra117
    namespace eval ::widgets::$site_5_0.fra118 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra118
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra120 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra120
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra122 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra122
    namespace eval ::widgets::$site_5_0.fra118 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra118
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra120 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra120
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra123 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra123
    namespace eval ::widgets::$site_5_0.fra118 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra118
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra120 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra120
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra124 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra124
    namespace eval ::widgets::$site_5_0.fra118 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra118
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra120 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra120
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra125 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra125
    namespace eval ::widgets::$site_5_0.fra118 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra118
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra120 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra120
    namespace eval ::widgets::$site_6_0.che106 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra129 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra129
    namespace eval ::widgets::$site_3_0.fra130 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra130
    namespace eval ::widgets::$site_4_0.che127 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra128 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra128
    namespace eval ::widgets::$site_5_0.fra38 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra38
    namespace eval ::widgets::$site_6_0.rad67 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.rad68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra39
    namespace eval ::widgets::$site_6_0.fra42 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra42
    namespace eval ::widgets::$site_7_0.lab47 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab48 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab49 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra43 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra43
    namespace eval ::widgets::$site_7_0.lab52 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab53 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab54 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra133 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra133
    namespace eval ::widgets::$site_4_0.che134 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra135 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra135
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra136 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra136
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m137 {
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
            vTclWindow.top100
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

proc vTclWindow.top100 {base} {
    if {$base == ""} {
        set base .top100
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
    wm geometry $top 500x350+10+110; update
    wm maxsize $top 1284 1008
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Polarisation Synthesis"
    vTcl:DefineAlias "$top" "Toplevel100" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame4" vTcl:WidgetProc "Toplevel100" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel100" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SyntDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel100" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel100" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable SyntOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel100" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel100" 1
    entry $site_6_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SyntOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd72" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd73 \
        \
        -command {global DirName DataDir SyntOutputDir

set SyntDirOutputTmp $SyntOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set SyntOutputDir $DirName
    } else {
    set SyntOutputDir $SyntDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd73" "Button657" vTcl:WidgetProc "Toplevel100" 1
    bindtags $site_6_0.cpd73 "$site_6_0.cpd73 Button $top all _vTclBalloon"
    bind $site_6_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra102 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra102" "Frame9" vTcl:WidgetProc "Toplevel100" 1
    set site_3_0 $top.fra102
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel100" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel100" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel100" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel100" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel100" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel100" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel100" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel100" 1
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
    frame $top.fra103 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra103" "Frame597" vTcl:WidgetProc "Toplevel100" 1
    set site_3_0 $top.fra103
    frame $site_3_0.fra115 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra115" "Frame612" vTcl:WidgetProc "Toplevel100" 1
    set site_4_0 $site_3_0.fra115
    frame $site_4_0.fra117 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra117" "Frame613" vTcl:WidgetProc "Toplevel100" 1
    set site_5_0 $site_4_0.fra117
    frame $site_5_0.fra118 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra118" "Frame614" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra118
    checkbutton $site_6_0.che106 \
        -text 000 -variable Synt000 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton594" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra120 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra120" "Frame616" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra120
    checkbutton $site_6_0.che106 \
        -text 090 -variable Synt090 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton596" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra118 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra120 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra122 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra122" "Frame619" vTcl:WidgetProc "Toplevel100" 1
    set site_5_0 $site_4_0.fra122
    frame $site_5_0.fra118 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra118" "Frame617" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra118
    checkbutton $site_6_0.che106 \
        -text 030 -variable Synt030 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton597" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra120 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra120" "Frame618" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra120
    checkbutton $site_6_0.che106 \
        -text 120 -variable Synt120 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton598" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra118 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra120 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra123 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra123" "Frame622" vTcl:WidgetProc "Toplevel100" 1
    set site_5_0 $site_4_0.fra123
    frame $site_5_0.fra118 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra118" "Frame620" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra118
    checkbutton $site_6_0.che106 \
        -text 045 -variable Synt045 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton599" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra120 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra120" "Frame621" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra120
    checkbutton $site_6_0.che106 \
        -text 135 -variable Synt135 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton600" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra118 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra120 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra124 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra124" "Frame625" vTcl:WidgetProc "Toplevel100" 1
    set site_5_0 $site_4_0.fra124
    frame $site_5_0.fra118 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra118" "Frame623" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra118
    checkbutton $site_6_0.che106 \
        -text 060 -variable Synt060 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton601" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra120 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra120" "Frame624" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra120
    checkbutton $site_6_0.che106 \
        -text 150 -variable Synt150 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton602" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra118 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra120 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra125 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra125" "Frame628" vTcl:WidgetProc "Toplevel100" 1
    set site_5_0 $site_4_0.fra125
    frame $site_5_0.fra118 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra118" "Frame626" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra118
    checkbutton $site_6_0.che106 \
        -text {Left   } -variable SyntLeft 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton603" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra120 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra120" "Frame627" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra120
    checkbutton $site_6_0.che106 \
        -text Right -variable SyntRight 
    vTcl:DefineAlias "$site_6_0.che106" "Checkbutton604" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.che106 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra118 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra120 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra117 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra122 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra123 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra124 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra125 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra115 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra129 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra129" "Frame630" vTcl:WidgetProc "Toplevel100" 1
    set site_3_0 $top.fra129
    frame $site_3_0.fra130 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra130" "Frame636" vTcl:WidgetProc "Toplevel100" 1
    set site_4_0 $site_3_0.fra130
    checkbutton $site_4_0.che127 \
        \
        -command {global SyntRGB

if {$SyntRGB == "1"} {
    $widget(Radiobutton100_1) configure -state normal
    $widget(Radiobutton100_2) configure -state normal
    $widget(Label100_1) configure -state normal
    $widget(Label100_2) configure -state normal
    $widget(Label100_3) configure -state normal
    $widget(Label100_4) configure -state normal
    $widget(Label100_5) configure -state normal
    $widget(Label100_6) configure -state normal
    } else {
    $widget(Radiobutton100_1) configure -state disable
    $widget(Radiobutton100_2) configure -state disable
    $widget(Label100_1) configure -state disable
    $widget(Label100_2) configure -state disable
    $widget(Label100_3) configure -state disable
    $widget(Label100_4) configure -state disable
    $widget(Label100_5) configure -state disable
    $widget(Label100_6) configure -state disable
    }} \
        -text {RGB BMP File} -variable SyntRGB 
    vTcl:DefineAlias "$site_4_0.che127" "Checkbutton606" vTcl:WidgetProc "Toplevel100" 1
    frame $site_4_0.fra128 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra128" "Frame635" vTcl:WidgetProc "Toplevel100" 1
    set site_5_0 $site_4_0.fra128
    frame $site_5_0.fra38 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra38" "Frame631" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra38
    radiobutton $site_6_0.rad67 \
        -padx 1 -text {Pauli Decomposition} -value pauli \
        -variable SyntRGBFormat 
    vTcl:DefineAlias "$site_6_0.rad67" "Radiobutton100_1" vTcl:WidgetProc "Toplevel100" 1
    radiobutton $site_6_0.rad68 \
        -text {Sinclair Decomposition} -value sinclair \
        -variable SyntRGBFormat 
    vTcl:DefineAlias "$site_6_0.rad68" "Radiobutton100_2" vTcl:WidgetProc "Toplevel100" 1
    pack $site_6_0.rad67 \
        -in $site_6_0 -anchor w -expand 0 -fill none -side top 
    pack $site_6_0.rad68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra39" "Frame634" vTcl:WidgetProc "Toplevel100" 1
    set site_6_0 $site_5_0.fra39
    frame $site_6_0.fra42 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra42" "Frame632" vTcl:WidgetProc "Toplevel100" 1
    set site_7_0 $site_6_0.fra42
    label $site_7_0.lab47 \
        -foreground #0000ff -text |S11+S22| 
    vTcl:DefineAlias "$site_7_0.lab47" "Label100_1" vTcl:WidgetProc "Toplevel100" 1
    label $site_7_0.lab48 \
        -foreground #008000 -text |S12+S21| 
    vTcl:DefineAlias "$site_7_0.lab48" "Label100_2" vTcl:WidgetProc "Toplevel100" 1
    label $site_7_0.lab49 \
        -foreground #ff0000 -text |S11-S22| 
    vTcl:DefineAlias "$site_7_0.lab49" "Label100_3" vTcl:WidgetProc "Toplevel100" 1
    pack $site_7_0.lab47 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.lab48 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.lab49 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.fra43 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra43" "Frame633" vTcl:WidgetProc "Toplevel100" 1
    set site_7_0 $site_6_0.fra43
    label $site_7_0.lab52 \
        -foreground #0000ff -text |S11| 
    vTcl:DefineAlias "$site_7_0.lab52" "Label100_4" vTcl:WidgetProc "Toplevel100" 1
    label $site_7_0.lab53 \
        -foreground #008000 -text |(S12+S21)/2| 
    vTcl:DefineAlias "$site_7_0.lab53" "Label100_5" vTcl:WidgetProc "Toplevel100" 1
    label $site_7_0.lab54 \
        -foreground #ff0000 -text |S22| 
    vTcl:DefineAlias "$site_7_0.lab54" "Label100_6" vTcl:WidgetProc "Toplevel100" 1
    pack $site_7_0.lab52 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.lab53 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.lab54 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra42 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.fra43 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra38 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra39 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.che127 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra128 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    frame $site_3_0.fra133 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra133" "Frame637" vTcl:WidgetProc "Toplevel100" 1
    set site_4_0 $site_3_0.fra133
    checkbutton $site_4_0.che134 \
        -text {BMP File for each  |S11|   (dB)} -variable SyntBMP 
    vTcl:DefineAlias "$site_4_0.che134" "Checkbutton607" vTcl:WidgetProc "Toplevel100" 1
    pack $site_4_0.che134 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra130 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra133 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra135 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra135" "Frame47" vTcl:WidgetProc "Toplevel100" 1
    set site_3_0 $top.fra135
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {global Synt000 Synt030 Synt045 Synt060 Synt090 Synt120 Synt135 Synt150
global SyntLeft SyntRight SyntRGB SyntRGBFormat SyntBMP

set Synt000 "0"
set Synt030 "0"
set Synt045 "0"
set Synt060 "0"
set Synt090 "0"
set Synt120 "0"
set Synt135 "0"
set Synt150 "0"
set SyntLeft "0"
set SyntRight "0"
set SyntRGB "0"
set SyntRGBFormat ""
set SyntBMP "0"
$widget(Radiobutton100_1) configure -state disable
$widget(Radiobutton100_2) configure -state disable
$widget(Label100_1) configure -state disable
$widget(Label100_2) configure -state disable
$widget(Label100_3) configure -state disable
$widget(Label100_4) configure -state disable
$widget(Label100_5) configure -state disable
$widget(Label100_6) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel100" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 50 -side left 
    frame $top.fra136 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra136" "Frame20" vTcl:WidgetProc "Toplevel100" 1
    set site_3_0 $top.fra136
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir SyntFonction SyntFunction OpenDirFile
global SyntDirInput SyntDirOutput SyntOutputDir SyntOutputSubDir ConfigFile
global Synt000 Synt030 Synt045 Synt060 Synt090 Synt120 Synt135 Synt150 SyntLeft SyntRight SyntRGB SyntRGBFormat SyntBMP
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine
global TMPSyntBmp TMPSyntBlue TMPSyntGreen TMPSyntRed TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax PSPViewGimpBMP

if {$OpenDirFile == 0} {

set config "false"
if {"$SyntRGB"=="1"} { set config "true" }
if {"$SyntBMP"=="1"} { set config "true" }

if {"$config"=="false"} {
    set VarError ""
    set ErrorMessage "SELECT A BMP REPRESENTATION" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {

set SyntDirOutput $SyntOutputDir
if {$SyntOutputSubDir != ""} {append SyntDirOutput "/$SyntOutputSubDir"}

    #####################################################################
    #Create Directory
    set SyntDirOutput [PSPCreateDirectoryMask $SyntDirOutput $SyntOutputDir $SyntDirInput]
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

        if {"$Synt000"=="1"} {
            set OrientationAngle "0"
            set EllipticityAngle "0"
            set Fonction "Polarisation Synthesis 000"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/synt000_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/synt000_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/synt000_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$Synt030"=="1"} {
            set OrientationAngle "30"
            set EllipticityAngle "0"
            set Fonction "Polarisation Synthesis 030"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/synt030_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/synt030_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/synt030_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$Synt045"=="1"} {
            set OrientationAngle "45"
            set EllipticityAngle "0"
            set Fonction "Polarisation Synthesis 045"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/synt045_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/synt045_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/synt045_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$Synt060"=="1"} {
            set OrientationAngle "60"
            set EllipticityAngle "0"
            set Fonction "Polarisation Synthesis 060"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/synt060_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/synt060_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/synt060_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$Synt090"=="1"} {
            set OrientationAngle "90"
            set EllipticityAngle "0"
            set Fonction "Polarisation Synthesis 090"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/synt090_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/synt090_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/synt090_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$Synt120"=="1"} {
            set OrientationAngle "120"
            set EllipticityAngle "0"
            set Fonction "Polarisation Synthesis 120"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/synt120_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/synt120_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/synt120_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$Synt135"=="1"} {
            set OrientationAngle "135"
            set EllipticityAngle "0"
            set Fonction "Polarisation Synthesis 135"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/synt135_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/synt135_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/synt135_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$Synt150"=="1"} {
            set OrientationAngle "150"
            set EllipticityAngle "0"
            set Fonction "Polarisation Synthesis 150"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/synt150_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/synt150_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/synt150_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$SyntLeft"=="1"} {
            set OrientationAngle "0"
            set EllipticityAngle "45"
            set Fonction "Polarisation Synthesis Left"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/syntleft_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/syntleft_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/syntleft_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        if {"$SyntRight"=="1"} {
            set OrientationAngle "0"
            set EllipticityAngle "-45"
            set Fonction "Polarisation Synthesis Right"
            set Fonction2 "Elliptical Basis Transformation"
            set MaskCmd ""
            set MaskFile "$SyntDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/polar_synt.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"    
            set f [ open "| Soft/bin/data_process_sngl/polar_synt.exe -id \x22$SyntDirInput\x22 -iodf $SyntFonction -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgb $SyntRGB -rgbf $SyntRGBFormat -bmp $SyntBMP -phi $OrientationAngle -tau $EllipticityAngle -bmpf \x22$TMPSyntBmp\x22 -bf \x22$TMPSyntBlue\x22 -gf \x22$TMPSyntGreen\x22 -rf \x22$TMPSyntRed\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]            
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$SyntBMP"=="1"} {
                set BMPFileInput $TMPSyntBmp
                set BMPFileOutput "$SyntDirOutput/syntright_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  0 0 $FinalNlig  $FinalNcol 1 0 0
                }
            if {"$SyntRGB"=="1"} {
                set FileInputBlue $TMPSyntBlue
                set FileInputGreen $TMPSyntGreen
                set FileInputRed $TMPSyntRed
                if {"$SyntRGBFormat"=="pauli"} {set RGBFileOutput "$SyntDirOutput/syntright_pauli.bmp"}
                if {"$SyntRGBFormat"=="sinclair"} {set RGBFileOutput "$SyntDirOutput/syntright_sinclair.bmp"}
                set Fonction "Creation of the RGB File"
                set Fonction2 $RGBFileOutput
                set MaskCmd ""
                set MaskDir [file dirname $FileInputBlue]
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                }
            }
        }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel100); TextEditorRunTrace "Close Window Polarisation Synthesis" "b"}
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel100" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolarisationSynthesis.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel100" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel100); TextEditorRunTrace "Close Window Polarisation Synthesis" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel100" 1
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
    menu $top.m137 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra102 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra103 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra129 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra135 \
        -in $top -anchor center -expand 0 -fill none -pady 3 -side top 
    pack $top.fra136 \
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
Window show .top100

main $argc $argv
