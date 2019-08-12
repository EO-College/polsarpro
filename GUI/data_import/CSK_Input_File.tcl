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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}
        {{[file join . GUI Images CSK.gif]} {user image} user {}}

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
    set base .top430
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab49 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra88
    namespace eval ::widgets::$site_3_0.cpd89 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but66 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd66
    namespace eval ::widgets::$site_3_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra91
    namespace eval ::widgets::$site_4_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra93
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd71
    namespace eval ::widgets::$site_4_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra93
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd97
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra93
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.tit68 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.tit68 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd69
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd85
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent67 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra57 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra57
    namespace eval ::widgets::$site_3_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra39
    namespace eval ::widgets::$site_4_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent41 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab42 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent43 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top430
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

proc vTclWindow.top430 {base} {
    if {$base == ""} {
        set base .top430
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
    wm geometry $top 500x500+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "COSMO-SKYMED Input Data File"
    vTcl:DefineAlias "$top" "Toplevel430" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab49 \
        -image [vTcl:image:get_image [file join . GUI Images CSK.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab49" "Label73" vTcl:WidgetProc "Toplevel430" 1
    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame1" vTcl:WidgetProc "Toplevel430" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel430" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CSKDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel430" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel430" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button1" vTcl:WidgetProc "Toplevel430" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame5" vTcl:WidgetProc "Toplevel430" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable CSKDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel430" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame12" vTcl:WidgetProc "Toplevel430" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -command {global DirName DataDir CSKDirOutput
global VarWarning WarningMessage WarningMessage2

set CSKOutputDirTmp $CSKDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set CSKDirOutput $DirName
        } else {
        set CSKDirOutput $CSKOutputDirTmp
        }
    } else {
    set CSKDirOutput $CSKOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button2" vTcl:WidgetProc "Toplevel430" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd72 \
        -ipad 0 -text {SAR Product File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame6" vTcl:WidgetProc "Toplevel430" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CSKFileInput 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel430" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.but71 \
        \
        -command {global FileName CSKDirInput CSKFileInput

set types {
    {{HDF5 Files}        {.h5}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $CSKDirInput $types "SAR PRODUCT FILE"
set CSKFileInput $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but71" "Button3" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra88" "Frame30" vTcl:WidgetProc "Toplevel430" 1
    set site_3_0 $top.fra88
    button $site_3_0.cpd89 \
        -background #ffff00 \
        -command {global CSKFileInput CSKDataFormat CSKDirInput CSKDirOutput
global TMPGoogle TMPCSKTmp TMPCSKConfig
global CSKSatelliteID CSKStationID CSKFrequency CSKIncAngle CSKLookSide CSKOrbit
global CSKSceneStart CSKSceneStop CSKColumn CSKLine CSKPolar1 CSKPolar2 CSKNcol CSKNlig
global FileInput1 FileInput2 FileInput3 FileInput4
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global ErrorMessage VarError PolarType ActiveProgram
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4

if {$OpenDirFile == 0} {

DeleteFile  $TMPGoogle
DeleteFile  $TMPCSKTmp
DeleteFile  $TMPCSKConfig

set config "true"
if {$CSKFileInput != ""} {
    CSKBatchProcess "A" $CSKFileInput
    WaitUntilCreated $TMPCSKTmp
    if [file exists $TMPCSKTmp] {
        DeleteFile  $TMPGoogle
        DeleteFile  $TMPCSKConfig
        TextEditorRunTrace "Process The Function Soft/bin/data_import/csk_config.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPCSKTmp\x22 -od \x22$CSKDirOutput\x22 -ocf \x22$TMPCSKConfig\x22 -ogf \x22$TMPGoogle\x22" "k"
        set f [ open "| Soft/bin/data_import/csk_config.exe -if \x22$TMPCSKTmp\x22 -od \x22$CSKDirOutput\x22 -ocf \x22$TMPCSKConfig\x22 -ogf \x22$TMPGoogle\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WaitUntilCreated $TMPCSKConfig
        if [file exists $TMPCSKConfig] {
            set f [open $TMPCSKConfig r]
            gets $f CSKStationID 
            gets $f CSKLookSide 
            gets $f CSKOrbit
            gets $f CSKFrequency 
            gets $f CSKIncAngle 
            gets $f CSKSatelliteID 
            gets $f CSKSceneStart 
            gets $f CSKSceneStop
            gets $f CSKPolar1 
            gets $f CSKPolar2
            gets $f CSKColumn 
            gets $f CSKLine
            gets $f CSKNlig
            gets $f CSKNcol
            close $f
            set PolarType ""; set CSKPolarType $CSKPolar1; append CSKPolarType $CSKPolar2
            if {$CSKPolarType == "HHHV"} { set PolarType "pp1" }
            if {$CSKPolarType == "HHVH"} { set PolarType "pp1" }
            if {$CSKPolarType == "HHVV"} { set PolarType "pp3" }
            if {$CSKPolarType == "HVHH"} { set PolarType "pp1" }
            if {$CSKPolarType == "HVVV"} { set PolarType "pp2" }
            if {$CSKPolarType == "VHHH"} { set PolarType "pp1" }
            if {$CSKPolarType == "VHVV"} { set PolarType "pp2" }
            if {$CSKPolarType == "VVHV"} { set PolarType "pp2" }
            if {$CSKPolarType == "VVVH"} { set PolarType "pp2" }
            if {$CSKPolarType == "VVHH"} { set PolarType "pp3" }
            $widget(Button430_2) configure -state normal
            }
        WaitUntilCreated $TMPGoogle
        if [file exists $TMPGoogle] {
            set f [open $TMPGoogle r]
            gets $f GoogleLatCenter
            gets $f GoogleLongCenter
            gets $f GoogleLat00
            gets $f GoogleLong00
            gets $f GoogleLat0N
            gets $f GoogleLong0N
            gets $f GoogleLatN0
            gets $f GoogleLongN0
            gets $f GoogleLatNN
            gets $f GoogleLongNN
            close $f
            $widget(Button430_1) configure -state normal
            }
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER THE SAR PRODUCT FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -cursor {} -padx 4 -pady 2 -text {Check Files} 
    vTcl:DefineAlias "$site_3_0.cpd89" "Button219" vTcl:WidgetProc "Toplevel430" 1
    bindtags $site_3_0.cpd89 "$site_3_0.cpd89 Button $top all _vTclBalloon"
    bind $site_3_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but66 \
        \
        -command {global FileName VarError ErrorMessage CSKDirOutput

set CSKFile "$CSKDirOutput/GEARTH_POLY.kml"
if [file exists $CSKFile] {
    GoogleEarth $CSKFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -pady 2 
    vTcl:DefineAlias "$site_3_0.but66" "Button430_1" vTcl:WidgetProc "Toplevel430" 1
    pack $site_3_0.cpd89 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame39" vTcl:WidgetProc "Toplevel430" 1
    set site_3_0 $top.cpd66
    frame $site_3_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra91" "Frame40" vTcl:WidgetProc "Toplevel430" 1
    set site_4_0 $site_3_0.fra91
    frame $site_4_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra93" "Frame41" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.fra93
    label $site_5_0.cpd94 \
        -text {Satellite ID} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label430" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKSatelliteID -width 10 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry430" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_4_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame47" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.cpd67
    label $site_5_0.cpd94 \
        -text {Station ID} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label435" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKStationID -width 22 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry435" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_4_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame44" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.cpd66
    label $site_5_0.cpd94 \
        -text Frequency 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label433" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKFrequency -width 10 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry433" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_4_0.fra93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $site_3_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd71" "Frame50" vTcl:WidgetProc "Toplevel430" 1
    set site_4_0 $site_3_0.cpd71
    frame $site_4_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra93" "Frame51" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.fra93
    label $site_5_0.cpd94 \
        -text {Incidence Angle } 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label438" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKIncAngle -width 10 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry438" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_4_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd97" "Frame52" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.cpd97
    label $site_5_0.cpd94 \
        -text {Orbit Direction} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label439" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKOrbit -width 15 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry439" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_4_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame53" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.cpd67
    label $site_5_0.cpd94 \
        -text {Look Side} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label440" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKLookSide -width 10 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry440" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_4_0.fra93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame54" vTcl:WidgetProc "Toplevel430" 1
    set site_4_0 $site_3_0.cpd66
    frame $site_4_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra93" "Frame55" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.fra93
    label $site_5_0.cpd94 \
        -text {Column Spacing} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label441" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKColumn -width 10 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry441" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_4_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame57" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.cpd67
    label $site_5_0.cpd94 \
        -text {Line Spacing} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label443" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKLine -width 10 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry443" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_4_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd68" "Frame43" vTcl:WidgetProc "Toplevel430" 1
    set site_5_0 $site_4_0.cpd68
    label $site_5_0.cpd94 \
        -text {Polar Type} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label432" vTcl:WidgetProc "Toplevel430" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PolarType -width 5 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry432" vTcl:WidgetProc "Toplevel430" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_4_0.fra93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $site_3_0.tit68 \
        -ipad 0 -text {Scene Sensing} 
    vTcl:DefineAlias "$site_3_0.tit68" "TitleFrame1" vTcl:WidgetProc "Toplevel430" 1
    bind $site_3_0.tit68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit68 getframe]
    frame $site_5_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd69" "Frame48" vTcl:WidgetProc "Toplevel430" 1
    set site_6_0 $site_5_0.cpd69
    label $site_6_0.cpd94 \
        -text Start 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label436" vTcl:WidgetProc "Toplevel430" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKSceneStart -width 30 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry436" vTcl:WidgetProc "Toplevel430" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame49" vTcl:WidgetProc "Toplevel430" 1
    set site_6_0 $site_5_0.cpd70
    label $site_6_0.cpd94 \
        -text Stop 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label437" vTcl:WidgetProc "Toplevel430" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKSceneStop -width 30 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry437" vTcl:WidgetProc "Toplevel430" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.fra91 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.tit68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -pady 2 -side top 
    frame $top.cpd85 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd85" "Frame21" vTcl:WidgetProc "Toplevel430" 1
    set site_3_0 $top.cpd85
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global CSKFileInput CSKDataFormat CSKDirInput CSKDirOutput PolarType 
global TMPCSKTmp TMPCSKBinary1 TMPCSKBinary1
global CSKPolar1 CSKPolar2 CSKNcol CSKNlig CSKMessage CSKFileInputFlag 
global FileInput1 FileInput2 FileInput3 FileInput4
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global ErrorMessage VarError PolarType ActiveProgram
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4

if {$OpenDirFile == 0} {

DeleteFile  $TMPCSKBinary1
DeleteFile  $TMPCSKBinary2

set CSKFileInputFlag 0  
set NligFullSize ""
set NcolFullSize ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set NligFullSizeInput 0
set NcolFullSizeInput 0

set CSKFileSize [expr $CSKNcol * $CSKNlig * 4]

if {$CSKFileInput != ""} {
    set CSKMessage "Dumping Dataset S01-SBI to $CSKPolar1 binary file"
    WidgetShowTop399
    CSKBatchProcess "d1" $CSKFileInput
    set FlagStop 0
    while {$FlagStop == 0} {
       set BinFileSize [file size $TMPCSKBinary1]
       if {$BinFileSize == $CSKFileSize} { set FlagStop 1}
       after 5000
       }
    WidgetHideTop399
    set CSKMessage "Dumping Dataset S02-SBI to $CSKPolar2 binary file"
    WidgetShowTop399
    CSKBatchProcess "d2" $CSKFileInput
    set FlagStop 0
    while {$FlagStop == 0} {
       set BinFileSize [file size $TMPCSKBinary2]
       if {$BinFileSize == $CSKFileSize} { set FlagStop 1}
       after 5000
       }
    WidgetHideTop399
    
    set NligFullSize $CSKNlig
    set NcolFullSize $CSKNcol
    set CSKFileInputFlag 1
    set NligInit 1
    set NligEnd $NligFullSize
    set NcolInit 1
    set NcolEnd $NcolFullSize
    set NligFullSizeInput $NligFullSize
    set NcolFullSizeInput $NcolFullSize

    if {$PolarType == "pp1"} {
        if {$CSKPolar1 == "HH"} {
            set FileInput1 $TMPCSKBinary1
            set FileInput2 $TMPCSKBinary2
            } else {
            set FileInput1 $TMPCSKBinary2
            set FileInput2 $TMPCSKBinary1
            }
        }
    if {$PolarType == "pp2"} {
        if {$CSKPolar1 == "VV"} {
            set FileInput1 $TMPCSKBinary1
            set FileInput2 $TMPCSKBinary2
            } else {
            set FileInput1 $TMPCSKBinary2
            set FileInput2 $TMPCSKBinary1
            }
        }
    if {$PolarType == "pp3"} {
        if {$CSKPolar1 == "HH"} {
            set FileInput1 $TMPCSKBinary1
            set FileInput2 $TMPCSKBinary2
            } else {
            set FileInput1 $TMPCSKBinary2
            set FileInput2 $TMPCSKBinary1
            }
        }
    
    $widget(Button430_3) configure -state normal
    } else {
    set VarError ""
    set ErrorMessage "ENTER THE SAR PRODUCT FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -cursor {} -padx 4 -pady 2 -text {Dump hd5 to bin Files} 
    vTcl:DefineAlias "$site_3_0.but93" "Button430_2" vTcl:WidgetProc "Toplevel430" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Read Header Files}
    }
    entry $site_3_0.ent67 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSKMessage -width 42 
    vTcl:DefineAlias "$site_3_0.ent67" "Entry1" vTcl:WidgetProc "Toplevel430" 1
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.ent67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra57 \
        -borderwidth 2 -relief groove -height 76 -width 200 
    vTcl:DefineAlias "$top.fra57" "Frame" vTcl:WidgetProc "Toplevel430" 1
    set site_3_0 $top.fra57
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame107" vTcl:WidgetProc "Toplevel430" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label430_1" vTcl:WidgetProc "Toplevel430" 1
    entry $site_4_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent41" "Entry430_1" vTcl:WidgetProc "Toplevel430" 1
    label $site_4_0.lab42 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_4_0.lab42" "Label430_2" vTcl:WidgetProc "Toplevel430" 1
    entry $site_4_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent43" "Entry430_2" vTcl:WidgetProc "Toplevel430" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent41 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.lab42 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent43 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.fra39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side bottom 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel430" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile CSKFileInputFlag
global VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError

if {$OpenDirFile == 0} {
    if {$CSKFileInputFlag == 1} {
        set ErrorMessage ""
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel430); TextEditorRunTrace "Close Window COSMO - SKYMED Input File" "b"
        }
    }} \
        -cursor {} -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button430_3" vTcl:WidgetProc "Toplevel430" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CSK_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel430" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel430); TextEditorRunTrace "Close Window COSMO - SKYMED Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel430" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel the Function}
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
    pack $top.lab49 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra88 \
        -in $top -anchor center -expand 0 -fill both -pady 2 -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill none -ipady 4 -side top 
    pack $top.cpd85 \
        -in $top -anchor center -expand 0 -fill x -pady 4 -side top 
    pack $top.fra57 \
        -in $top -anchor center -expand 0 -fill none -side top 
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
Window show .top430

main $argc $argv
