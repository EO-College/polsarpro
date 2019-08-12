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

        {{[file join . GUI Images UAVSAR.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}

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
    set base .top386
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
    namespace eval ::widgets::$base.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd69 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd77 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd85
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
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
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd80 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd82 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd83 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd83 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd84 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top386
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

proc vTclWindow.top386 {base} {
    if {$base == ""} {
        set base .top386
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
    wm geometry $top 500x650+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "UAVSAR Input Data File"
    vTcl:DefineAlias "$top" "Toplevel386" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab49 \
        -image [vTcl:image:get_image [file join . GUI Images UAVSAR.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab49" "Label73" vTcl:WidgetProc "Toplevel386" 1
    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame1" vTcl:WidgetProc "Toplevel386" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel386" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable UAVSARDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel386" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel386" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button1" vTcl:WidgetProc "Toplevel386" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd69 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame5" vTcl:WidgetProc "Toplevel386" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable UAVSARDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel386" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame12" vTcl:WidgetProc "Toplevel386" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.but71 \
        \
        -command {global DirName DataDir UAVSARDirOutput
global VarWarning WarningMessage WarningMessage2

set UAVSAROutputDirTmp $UAVSARDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set UAVSARDirOutput $DirName
        } else {
        set UAVSARDirOutput $UAVSAROutputDirTmp
        }
    } else {
    set UAVSARDirOutput $UAVSAROutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but71" "Button2" vTcl:WidgetProc "Toplevel386" 1
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {UAVSAR Annotation File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame386" vTcl:WidgetProc "Toplevel386" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable UAVSARAnnotationFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry386" vTcl:WidgetProc "Toplevel386" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel386" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd91 \
        \
        -command {global FileName UAVSARDirInput UAVSARAnnotationFile

set types {
    {{ANN Files}        {.ann}   }
    {{TXT Files}        {.txt}   }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $UAVSARDirInput $types "ANNOTATION FILE"
set UAVSARAnnotationFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd91" "Button386" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_5_0.cpd91 "$site_5_0.cpd91 Button $top all _vTclBalloon"
    bind $site_5_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd77 \
        -ipad 0 -text {UAVSAR Data Format} 
    vTcl:DefineAlias "$top.cpd77" "TitleFrame386_2" vTcl:WidgetProc "Toplevel386" 1
    bind $top.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd77 getframe]
    radiobutton $site_4_0.cpd67 \
        \
        -command {global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global NligFullSize NcolFullSize

set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""; set FileInput5 ""; set FileInput6 ""
set NligFullSize ""
set NcolFullSize ""

$widget(TitleFrame386_3) configure -state disable
$widget(TitleFrame386_3) configure -text ""
$widget(Entry386_3) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_3) configure -state disable 
$widget(TitleFrame386_4) configure -state disable
$widget(TitleFrame386_4) configure -text ""
$widget(Entry386_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_4) configure -state disable 
$widget(TitleFrame386_5) configure -state disable
$widget(TitleFrame386_5) configure -text ""
$widget(Entry386_5) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_5) configure -state disable 
$widget(TitleFrame386_6) configure -state disable
$widget(TitleFrame386_6) configure -text ""
$widget(Entry386_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_6) configure -state disable 
$widget(TitleFrame386_7) configure -state disable
$widget(TitleFrame386_7) configure -text ""
$widget(Entry386_7) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_7) configure -state disable 
$widget(TitleFrame386_8) configure -state disable
$widget(TitleFrame386_8) configure -text ""
$widget(Entry386_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_8) configure -state disable 

$widget(Button386_1) configure -state disable 
$widget(Button386_2) configure -state disable 
$widget(Button386_10) configure -state disable} \
        -text {Single Look Complex ( SLC )} -value SLC \
        -variable UAVSARDataFormat 
    vTcl:DefineAlias "$site_4_0.cpd67" "Radiobutton387" vTcl:WidgetProc "Toplevel386" 1
    radiobutton $site_4_0.cpd66 \
        \
        -command {global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global NligFullSize NcolFullSize

set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""; set FileInput5 ""; set FileInput6 ""
set NligFullSize ""
set NcolFullSize ""

$widget(TitleFrame386_3) configure -state disable
$widget(TitleFrame386_3) configure -text ""
$widget(Entry386_3) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_3) configure -state disable 
$widget(TitleFrame386_4) configure -state disable
$widget(TitleFrame386_4) configure -text ""
$widget(Entry386_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_4) configure -state disable 
$widget(TitleFrame386_5) configure -state disable
$widget(TitleFrame386_5) configure -text ""
$widget(Entry386_5) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_5) configure -state disable 
$widget(TitleFrame386_6) configure -state disable
$widget(TitleFrame386_6) configure -text ""
$widget(Entry386_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_6) configure -state disable 
$widget(TitleFrame386_7) configure -state disable
$widget(TitleFrame386_7) configure -text ""
$widget(Entry386_7) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_7) configure -state disable 
$widget(TitleFrame386_8) configure -state disable
$widget(TitleFrame386_8) configure -text ""
$widget(Entry386_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_8) configure -state disable 

$widget(Button386_1) configure -state disable 
$widget(Button386_2) configure -state disable 
$widget(Button386_10) configure -state disable} \
        -text {Multi Look Complex ( MLC )} -value MLC \
        -variable UAVSARDataFormat 
    vTcl:DefineAlias "$site_4_0.cpd66" "Radiobutton386" vTcl:WidgetProc "Toplevel386" 1
    radiobutton $site_4_0.cpd68 \
        \
        -command {global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global NligFullSize NcolFullSize

set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""; set FileInput5 ""; set FileInput6 ""
set NligFullSize ""
set NcolFullSize ""

$widget(TitleFrame386_3) configure -state disable
$widget(TitleFrame386_3) configure -text ""
$widget(Entry386_3) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_3) configure -state disable 
$widget(TitleFrame386_4) configure -state disable
$widget(TitleFrame386_4) configure -text ""
$widget(Entry386_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_4) configure -state disable 
$widget(TitleFrame386_5) configure -state disable
$widget(TitleFrame386_5) configure -text ""
$widget(Entry386_5) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_5) configure -state disable 
$widget(TitleFrame386_6) configure -state disable
$widget(TitleFrame386_6) configure -text ""
$widget(Entry386_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_6) configure -state disable 
$widget(TitleFrame386_7) configure -state disable
$widget(TitleFrame386_7) configure -text ""
$widget(Entry386_7) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_7) configure -state disable 
$widget(TitleFrame386_8) configure -state disable
$widget(TitleFrame386_8) configure -text ""
$widget(Entry386_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button386_8) configure -state disable 

$widget(Button386_1) configure -state disable 
$widget(Button386_2) configure -state disable 
$widget(Button386_10) configure -state disable} \
        -text {Multi Look Ground ( GRD )} -value GRD \
        -variable UAVSARDataFormat 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton388" vTcl:WidgetProc "Toplevel386" 1
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd85 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd85" "Frame21" vTcl:WidgetProc "Toplevel386" 1
    set site_3_0 $top.cpd85
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global UAVSARDirInput UAVSARDirOutput 
global UAVSARDataFormat UAVSARAnnotationFile UAVSARFileInputFlag
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPUavsarConfig OpenDirFile
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global UAVSARMapInfoMapInfo UAVSARMapInfoLat UAVSARMapInfoLon UAVSARMapInfoLatDeg UAVSARMapInfoLonDeg UAVSARFileDEM 
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set datalevelerror 0
#####################################################################
#Create Directory
set UAVSARDirOutput [PSPCreateDirectoryMask $UAVSARDirOutput $UAVSARDirOutput $UAVSARDirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPUavsarConfig

set config "true"
if {$UAVSARDataFormat == ""} {
    set ErrorMessage "ENTER THE UAVSAR INPUT DATA FORMAT"
    set VarError ""
    Window show $widget(Toplevel44)
    set config "false"
    }
if {$UAVSARAnnotationFile == ""} {
    set ErrorMessage "ENTER THE UAVSAR ANNOTATION FILE"
    set VarError ""
    Window show $widget(Toplevel44)
    set config "false"
    }
 
if {$config == "true"} {  

set UAVSARFileInputFlag 0
if [file exists $UAVSARAnnotationFile] {
    TextEditorRunTrace "Process The Function Soft/bin/data_import/uavsar_header.exe" "k"
    if {$UAVSARDataFormat == "SLC"} { set UAVSARDF "slc"}
    if {$UAVSARDataFormat == "MLC"} { set UAVSARDF "mlc"}
    if {$UAVSARDataFormat == "GRD"} { set UAVSARDF "grd"}
    TextEditorRunTrace "Arguments: -hf \x22$UAVSARAnnotationFile\x22 -id \x22$UAVSARDirInput\x22 -od \x22$UAVSARDirOutput\x22 -df $UAVSARDF -tf \x22$TMPUavsarConfig\x22" "k"
    set f [ open "| Soft/bin/data_import/uavsar_header.exe -hf \x22$UAVSARAnnotationFile\x22 -id \x22$UAVSARDirInput\x22 -od \x22$UAVSARDirOutput\x22 -df $UAVSARDF -tf \x22$TMPUavsarConfig\x22" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    
    set NligFullSize ""
    set NcolFullSize ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NligFullSizeInput 0
    set NcolFullSizeInput 0
    set ErrorMessage ""
    set UAVSARMapInfoMapInfo ""
    set UAVSARMapInfoLat ""
    set UAVSARMapInfoLon ""
    set UAVSARMapInfoLatDeg ""
    set UAVSARMapInfoLonDeg ""
    set UAVSARFileDEM ""
    WaitUntilCreated $TMPUavsarConfig
    if [file exists $TMPUavsarConfig] {
        set f [open $TMPUavsarConfig r]
        gets $f Tmp
        if {$Tmp == "HEADER OK"} {
            gets $f NligFullSize
            gets $f NcolFullSize
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
            gets $f FileIn; set FileInput1 "$UAVSARDirInput/$FileIn"
            gets $f FileIn; set FileInput2 "$UAVSARDirInput/$FileIn"
            gets $f FileIn; set FileInput3 "$UAVSARDirInput/$FileIn"
            gets $f FileIn; set FileInput4 "$UAVSARDirInput/$FileIn"
            if {$UAVSARDataFormat != "SLC"} {
                gets $f FileIn; set FileInput5 "$UAVSARDirInput/$FileIn"
                gets $f FileIn; set FileInput6 "$UAVSARDirInput/$FileIn"
                }
            gets $f UAVSARMapInfoMapInfo
            gets $f UAVSARMapInfoLat
            gets $f UAVSARMapInfoLon
            gets $f UAVSARMapInfoLatDeg
            gets $f UAVSARMapInfoLonDeg
            if {$UAVSARDataFormat == "GRD"} {
                gets $f FileIn;
                if {$FileIn != "No DEM"} {set UAVSARFileDEM "$UAVSARDirInput/$FileIn"}
                }
            close $f

            set UAVSARFileInputFlag 1
            set NligInit 1
            set NligEnd $NligFullSize
            set NcolInit 1
            set NcolEnd $NcolFullSize
            set NligFullSizeInput $NligFullSize
            set NcolFullSizeInput $NcolFullSize
            $widget(Button386_1) configure -state normal
            $widget(Button386_2) configure -state normal
            $widget(Button386_10) configure -state normal
            if {$UAVSARDataFormat == "SLC"} {
                $widget(TitleFrame386_3) configure -state normal
                $widget(TitleFrame386_3) configure -text "UAVSAR Input Data File : s11"
                $widget(Entry386_3) configure -disabledbackground #FFFFFF
                $widget(Button386_3) configure -state normal
                $widget(TitleFrame386_4) configure -state normal
                $widget(TitleFrame386_4) configure -text "UAVSAR Input Data File : s12"
                $widget(Entry386_4) configure -disabledbackground #FFFFFF
                $widget(Button386_4) configure -state normal
                $widget(TitleFrame386_5) configure -state normal
                $widget(TitleFrame386_5) configure -text "UAVSAR Input Data File : s21"
                $widget(Entry386_5) configure -disabledbackground #FFFFFF
                $widget(Button386_5) configure -state normal
                $widget(TitleFrame386_6) configure -state normal
                $widget(TitleFrame386_6) configure -text "UAVSAR Input Data File : s22"
                $widget(Entry386_6) configure -disabledbackground #FFFFFF
                $widget(Button386_6) configure -state normal
                } else {
                $widget(TitleFrame386_3) configure -state normal
                $widget(TitleFrame386_3) configure -text "UAVSAR Input Data File : Chhhh"
                $widget(Entry386_3) configure -disabledbackground #FFFFFF
                $widget(Button386_3) configure -state normal
                $widget(TitleFrame386_4) configure -state normal
                $widget(TitleFrame386_4) configure -text "UAVSAR Input Data File : Chhhv"
                $widget(Entry386_4) configure -disabledbackground #FFFFFF
                $widget(Button386_4) configure -state normal
                $widget(TitleFrame386_5) configure -state normal
                $widget(TitleFrame386_5) configure -text "UAVSAR Input Data File : Chhvv"
                $widget(Entry386_5) configure -disabledbackground #FFFFFF
                $widget(Button386_5) configure -state normal
                $widget(TitleFrame386_6) configure -state normal
                $widget(TitleFrame386_6) configure -text "UAVSAR Input Data File : Chvhv"
                $widget(Entry386_6) configure -disabledbackground #FFFFFF
                $widget(Button386_6) configure -state normal
                $widget(TitleFrame386_7) configure -state normal
                $widget(TitleFrame386_7) configure -text "UAVSAR Input Data File : Chvvv"
                $widget(Entry386_7) configure -disabledbackground #FFFFFF
                $widget(Button386_7) configure -state normal
                $widget(TitleFrame386_8) configure -state normal
                $widget(TitleFrame386_8) configure -text "UAVSAR Input Data File : Cvvvv"
                $widget(Entry386_8) configure -disabledbackground #FFFFFF
                $widget(Button386_8) configure -state normal
                }
            } else {
            close $f
            set ErrorMessage "ERROR IN THE UAVSAR DATA FORMAT"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set UAVSARAnnotationFile ""; set UAVSARDataFormat ""; set UAVSARFileInputFlag 0
            }
            #TMPUavsarConfig Exists
        } else {
        set ErrorMessage "A PROBLEM OCCURED DURING THE HEADER EXTRACTION"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set UAVSARAnnotationFile ""; set UAVSARDataFormat ""; set UAVSARFileInputFlag 0
        }
        #TMPUavsarConfig Exists
    } else {
    set ErrorMessage "ENTER THE UAVSAR ANNOTATION FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    #ProductFile Exists
}
#Config
}
#VarWarning
}
#OpenDirFile} \
        -cursor {} -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_3_0.but93" "Button386_9" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but70 \
        \
        -command {global FileName VarError ErrorMessage UAVSARDirOutput

set UAVSARFile "$UAVSARDirOutput/GEARTH_POLY.kml"
if [file exists $UAVSARFile] {
    GoogleEarth $UAVSARFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but70" "Button386_1" vTcl:WidgetProc "Toplevel386" 1
    button $site_3_0.but71 \
        -background #ffff00 \
        -command {global FileName VarError ErrorMessage UAVSARDirOutput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set UAVSARFile "$UAVSARDirOutput/annotation_file.txt"
if [file exists $UAVSARFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top386 $UAVSARFile
    }} \
        -padx 4 -pady 2 -text {Edit Header} 
    vTcl:DefineAlias "$site_3_0.but71" "Button386_2" vTcl:WidgetProc "Toplevel386" 1
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame2" vTcl:WidgetProc "Toplevel386" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {UAVSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame386_3" vTcl:WidgetProc "Toplevel386" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry386_3" vTcl:WidgetProc "Toplevel386" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel386" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName UAVSARDirInput FileInput1
global UAVSARDataFormat

if {$UAVSARDataFormat == "SLC"} {
    set types {
        {{SLC Files}        {.slc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "s11 : SLC INPUT FILE"
    set FileInput1 $FileName
    }
if {$UAVSARDataFormat == "MLC"} {
    set types {
        {{MLC Files}        {.mlc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chhhh : MLC INPUT FILE"
    set FileInput1 $FileName
    }
if {$UAVSARDataFormat == "GRD"} {
    set types {
        {{GRD Files}        {.grd}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chhhh : GRD INPUT FILE"
    set FileInput1 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button386_3" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_6_0.cpd91 "$site_6_0.cpd91 Button $top all _vTclBalloon"
    bind $site_6_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd80 \
        -ipad 0 -text {UAVSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd80" "TitleFrame386_4" vTcl:WidgetProc "Toplevel386" 1
    bind $site_3_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry386_4" vTcl:WidgetProc "Toplevel386" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame15" vTcl:WidgetProc "Toplevel386" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName UAVSARDirInput FileInput2
global UAVSARDataFormat

if {$UAVSARDataFormat == "SLC"} {
    set types {
        {{SLC Files}        {.slc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "s12 : SLC INPUT FILE"
    set FileInput2 $FileName
    }
if {$UAVSARDataFormat == "MLC"} {
    set types {
        {{MLC Files}        {.mlc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chhhv : MLC INPUT FILE"
    set FileInput2 $FileName
    }
if {$UAVSARDataFormat == "GRD"} {
    set types {
        {{GRD Files}        {.grd}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chhhv : GRD INPUT FILE"
    set FileInput2 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button386_4" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_6_0.cpd91 "$site_6_0.cpd91 Button $top all _vTclBalloon"
    bind $site_6_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd81 \
        -ipad 0 -text {UAVSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd81" "TitleFrame386_5" vTcl:WidgetProc "Toplevel386" 1
    bind $site_3_0.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry386_5" vTcl:WidgetProc "Toplevel386" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel386" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName UAVSARDirInput FileInput3
global UAVSARDataFormat

if {$UAVSARDataFormat == "SLC"} {
    set types {
        {{SLC Files}        {.slc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "s21 : SLC INPUT FILE"
    set FileInput3 $FileName
    }
if {$UAVSARDataFormat == "MLC"} {
    set types {
        {{MLC Files}        {.mlc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chhvv : MLC INPUT FILE"
    set FileInput3 $FileName
    }
if {$UAVSARDataFormat == "GRD"} {
    set types {
        {{GRD Files}        {.grd}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chhvv : GRD INPUT FILE"
    set FileInput3 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button386_5" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_6_0.cpd91 "$site_6_0.cpd91 Button $top all _vTclBalloon"
    bind $site_6_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd82 \
        -ipad 0 -text {UAVSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd82" "TitleFrame386_6" vTcl:WidgetProc "Toplevel386" 1
    bind $site_3_0.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd82 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry386_6" vTcl:WidgetProc "Toplevel386" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel386" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName UAVSARDirInput FileInput4
global UAVSARDataFormat

if {$UAVSARDataFormat == "SLC"} {
    set types {
        {{SLC Files}        {.slc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "s22 : SLC INPUT FILE"
    set FileInput4 $FileName
    }
if {$UAVSARDataFormat == "MLC"} {
    set types {
        {{MLC Files}        {.mlc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chvhv : MLC INPUT FILE"
    set FileInput4 $FileName
    }
if {$UAVSARDataFormat == "GRD"} {
    set types {
        {{GRD Files}        {.grd}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chvhv : GRD INPUT FILE"
    set FileInput4 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button386_6" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_6_0.cpd91 "$site_6_0.cpd91 Button $top all _vTclBalloon"
    bind $site_6_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd83 \
        -ipad 0 -text {UAVSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd83" "TitleFrame386_7" vTcl:WidgetProc "Toplevel386" 1
    bind $site_3_0.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd83 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput5 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry386_7" vTcl:WidgetProc "Toplevel386" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel386" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName UAVSARDirInput FileInput5
global UAVSARDataFormat

if {$UAVSARDataFormat == "MLC"} {
    set types {
        {{MLC Files}        {.mlc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chvvv : MLC INPUT FILE"
    set FileInput5 $FileName
    }
if {$UAVSARDataFormat == "GRD"} {
    set types {
        {{GRD Files}        {.grd}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Chvvv : GRD INPUT FILE"
    set FileInput5 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button386_7" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_6_0.cpd91 "$site_6_0.cpd91 Button $top all _vTclBalloon"
    bind $site_6_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd84 \
        -ipad 0 -text {UAVSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd84" "TitleFrame386_8" vTcl:WidgetProc "Toplevel386" 1
    bind $site_3_0.cpd84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd84 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput6 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry386_8" vTcl:WidgetProc "Toplevel386" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel386" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName UAVSARDirInput FileInput6
global UAVSARDataFormat

if {$UAVSARDataFormat == "MLC"} {
    set types {
        {{MLC Files}        {.mlc}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Cvvvv : MLC INPUT FILE"
    set FileInput6 $FileName
    }
if {$UAVSARDataFormat == "GRD"} {
    set types {
        {{GRD Files}        {.grd}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $UAVSARDirInput $types "Cvvvv : GRD INPUT FILE"
    set FileInput6 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button386_8" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_6_0.cpd91 "$site_6_0.cpd91 Button $top all _vTclBalloon"
    bind $site_6_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd80 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd82 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd83 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra57 \
        -borderwidth 2 -relief groove -height 76 -width 200 
    vTcl:DefineAlias "$top.fra57" "Frame" vTcl:WidgetProc "Toplevel386" 1
    set site_3_0 $top.fra57
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame107" vTcl:WidgetProc "Toplevel386" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label386_1" vTcl:WidgetProc "Toplevel386" 1
    entry $site_4_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent41" "Entry386_1" vTcl:WidgetProc "Toplevel386" 1
    label $site_4_0.lab42 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_4_0.lab42" "Label386_2" vTcl:WidgetProc "Toplevel386" 1
    entry $site_4_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent43" "Entry386_2" vTcl:WidgetProc "Toplevel386" 1
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
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel386" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile
global VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError

if {$OpenDirFile == 0} {
    set WarningMessage "DON'T FORGET TO EXTRACT DATA"
    set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    Window hide $widget(Toplevel386); TextEditorRunTrace "Close Window UAVSAR Input File" "b"
}} \
        -cursor {} -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button386_10" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/UAVSAR_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel386" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel386); TextEditorRunTrace "Close Window UAVSAR Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel386" 1
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
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab49 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd85 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra57 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
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
Window show .top386

main $argc $argv
