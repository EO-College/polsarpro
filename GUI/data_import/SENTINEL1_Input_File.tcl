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

        {{[file join . GUI Images SENTINEL1.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}

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
    set base .top453
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab66 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd79
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
    namespace eval ::widgets::$site_6_0.cpd114 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra67
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra75
    namespace eval ::widgets::$site_3_0.tit77 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.tit77 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but79 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd83 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd84
    namespace eval ::widgets::$site_4_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd90
    namespace eval ::widgets::$site_4_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd85
    namespace eval ::widgets::$site_4_0.lab79 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd77
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
    namespace eval ::widgets::$site_6_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd116 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra87
    namespace eval ::widgets::$site_3_0.cpd89 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd89
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd85
    namespace eval ::widgets::$site_5_0.lab79 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
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
            vTclWindow.top453
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
    wm geometry $top 200x200+100+100; update
    wm maxsize $top 3356 1024
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

proc vTclWindow.top453 {base} {
    if {$base == ""} {
        set base .top453
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
    wm geometry $top 500x475+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "SENTINEL1 Input Data File"
    vTcl:DefineAlias "$top" "Toplevel453" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
        -image [vTcl:image:get_image [file join . GUI Images SENTINEL1.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel453" 1
    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel453" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel453" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SENTINEL1DirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel453" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel453" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel453" 1
    pack $site_6_0.cpd114 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame453" vTcl:WidgetProc "Toplevel453" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable SENTINEL1DirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry453" vTcl:WidgetProc "Toplevel453" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel453" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global DirName DataDir SENTINEL1DirOutput
global VarWarning WarningMessage WarningMessage2

set SENTINEL1OutputDirTmp $SENTINEL1DirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set SENTINEL1DirOutput $DirName
        } else {
        set SENTINEL1DirOutput $SENTINEL1OutputDirTmp
        }
    } else {
    set SENTINEL1DirOutput $SENTINEL1OutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button453" vTcl:WidgetProc "Toplevel453" 1
    bindtags $site_5_0.cpd119 "$site_5_0.cpd119 Button $top all _vTclBalloon"
    bind $site_5_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.fra66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame2" vTcl:WidgetProc "Toplevel453" 1
    set site_3_0 $top.fra66
    frame $site_3_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra67" "Frame7" vTcl:WidgetProc "Toplevel453" 1
    set site_4_0 $site_3_0.fra67
    frame $site_4_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd68" "Frame8" vTcl:WidgetProc "Toplevel453" 1
    set site_5_0 $site_4_0.cpd68
    label $site_5_0.lab82 \
        -text Mission 
    vTcl:DefineAlias "$site_5_0.lab82" "Label453" vTcl:WidgetProc "Toplevel453" 1
    entry $site_5_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1Mission -width 5 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry454" vTcl:WidgetProc "Toplevel453" 1
    pack $site_5_0.lab82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.ent83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side top 
    frame $site_4_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame9" vTcl:WidgetProc "Toplevel453" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.lab82 \
        -text Acquisition 
    vTcl:DefineAlias "$site_5_0.lab82" "Label454" vTcl:WidgetProc "Toplevel453" 1
    entry $site_5_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1Mode -width 5 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry455" vTcl:WidgetProc "Toplevel453" 1
    pack $site_5_0.lab82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.ent83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side top 
    frame $site_4_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame13" vTcl:WidgetProc "Toplevel453" 1
    set site_5_0 $site_4_0.cpd73
    label $site_5_0.lab82 \
        -text Product 
    vTcl:DefineAlias "$site_5_0.lab82" "Label457" vTcl:WidgetProc "Toplevel453" 1
    entry $site_5_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1Product -width 5 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry458" vTcl:WidgetProc "Toplevel453" 1
    pack $site_5_0.lab82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.ent83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side top 
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame14" vTcl:WidgetProc "Toplevel453" 1
    set site_5_0 $site_4_0.cpd74
    label $site_5_0.lab82 \
        -text Level 
    vTcl:DefineAlias "$site_5_0.lab82" "Label458" vTcl:WidgetProc "Toplevel453" 1
    entry $site_5_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1Level -width 5 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry459" vTcl:WidgetProc "Toplevel453" 1
    pack $site_5_0.lab82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.ent83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side top 
    frame $site_4_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame10" vTcl:WidgetProc "Toplevel453" 1
    set site_5_0 $site_4_0.cpd70
    label $site_5_0.lab82 \
        -text Polarisation 
    vTcl:DefineAlias "$site_5_0.lab82" "Label455" vTcl:WidgetProc "Toplevel453" 1
    entry $site_5_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PolarType -width 5 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry456" vTcl:WidgetProc "Toplevel453" 1
    pack $site_5_0.lab82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.ent83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side top 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra67 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra75" "Frame15" vTcl:WidgetProc "Toplevel453" 1
    set site_3_0 $top.fra75
    TitleFrame $site_3_0.tit77 \
        -text Swath 
    vTcl:DefineAlias "$site_3_0.tit77" "TitleFrame1" vTcl:WidgetProc "Toplevel453" 1
    bind $site_3_0.tit77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit77 getframe]
    entry $site_5_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -justify center -state disabled \
        -textvariable SENTINEL1Swath -width 5 
    vTcl:DefineAlias "$site_5_0.ent78" "Entry1" vTcl:WidgetProc "Toplevel453" 1
    button $site_5_0.cpd80 \
        \
        -command {global SENTINEL1Swath SENTINEL1SwathMax
global SENTINEL1Burst SENTINEL1BurstMax
global SENTINEL1PixAz SENTINEL1PixRg SENTINEL1IncAngle
global SENTINEL1Acq SENTINEL1FUD
global SENTINEL1NligInit SENTINEL1NcolInit SENTINEL1NligFinal SENTINEL1NcolFinal
global FileInput1 FileInput2

set SENTINEL1Burst ""; set SENTINEL1BurstMax ""
set SENTINEL1PixAz ""; set SENTINEL1PixRg ""; set SENTINEL1IncAngle ""
set SENTINEL1NligInit ""; set SENTINEL1NcolInit ""; set SENTINEL1NligFinal ""; set SENTINEL1NcolFinal ""
set FileInput1 ""; set FileInput2 ""
$widget(TitleFrame453_1) configure  -state disable
$widget(Entry453_1) configure -disabledbackground $PSPBackgroundColor; $widget(Button453_1) configure -state disable
$widget(TitleFrame453_2) configure  -state disable
$widget(Entry453_2) configure -disabledbackground $PSPBackgroundColor; $widget(Button453_2) configure -state disable
$widget(Button453_04) configure -state disable
$widget(Entry453_02) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_02) configure -state disable
$widget(Entry453_03) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_03) configure -state disable
$widget(Entry453_04) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_04) configure -state disable
$widget(Entry453_07) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_07) configure -state disable
$widget(Entry453_08) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_08) configure -state disable
set SENTINEL1Acq ""
set SENTINEL1FUD 0
$widget(Button453_6) configure -state disable
        
set SENTINEL1Swath [expr $SENTINEL1Swath + 1]
if {$SENTINEL1Swath > $SENTINEL1SwathMax} { set SENTINEL1Swath 1 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_5_0.cpd80" "Button3" vTcl:WidgetProc "Toplevel453" 1
    button $site_5_0.but79 \
        \
        -command {global SENTINEL1Swath SENTINEL1SwathMax
global SENTINEL1Burst SENTINEL1BurstMax
global SENTINEL1PixAz SENTINEL1PixRg SENTINEL1IncAngle 
global SENTINEL1Acq SENTINEL1FUD
global SENTINEL1NligInit SENTINEL1NcolInit SENTINEL1NligFinal SENTINEL1NcolFinal
global FileInput1 FileInput2

set SENTINEL1Burst ""; set SENTINEL1BurstMax ""
set SENTINEL1PixAz ""; set SENTINEL1PixRg ""; set SENTINEL1IncAngle ""
set SENTINEL1NligInit ""; set SENTINEL1NcolInit ""; set SENTINEL1NligFinal ""; set SENTINEL1NcolFinal ""
set FileInput1 ""; set FileInput2 ""
$widget(TitleFrame453_1) configure  -state disable
$widget(Entry453_1) configure -disabledbackground $PSPBackgroundColor; $widget(Button453_1) configure -state disable
$widget(TitleFrame453_2) configure  -state disable
$widget(Entry453_2) configure -disabledbackground $PSPBackgroundColor; $widget(Button453_2) configure -state disable
$widget(Button453_04) configure -state disable
$widget(Entry453_02) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_02) configure -state disable
$widget(Entry453_03) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_03) configure -state disable
$widget(Entry453_04) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_04) configure -state disable
$widget(Entry453_07) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_07) configure -state disable
$widget(Entry453_08) configure -disabledbackground $PSPBackgroundColor; $widget(Label453_08) configure -state disable
set SENTINEL1Acq ""
set SENTINEL1FUD 0
$widget(Button453_6) configure -state disable

set SENTINEL1Swath [expr $SENTINEL1Swath - 1]
if {$SENTINEL1Swath == 0} { set SENTINEL1Swath $SENTINEL1SwathMax }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but79" "Button2" vTcl:WidgetProc "Toplevel453" 1
    button $site_5_0.cpd81 \
        -background #ffff00 \
        -command {global SENTINEL1DirInput SENTINEL1DirOutput SENTINEL1FileInputFlag
global SENTINEL1DataFormat SENTINEL1ProductFile SENTINEL1Mode SENTINEL1Swath
global SENTINEL1Burst SENTINEL1BurstMax
global SENTINEL1Acq SENTINEL1FUD
global SENTINEL1PixRg SENTINEL1PixAz SENTINEL1IncAngle
global SENTINEL1NcolInit SENTINEL1NligInit
global SENTINEL1LigInit SENTINEL1LigFinal SENTINEL1NligFinal
global SENTINEL1ColInit SENTINEL1ColFinal SENTINEL1NcolFinal
global SENTINEL1Acq SENTINEL1FUD
global FileInput1 FileInput2
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global TMPSentinel1Config TMPGoogle OpenDirFile PolarType
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4

if {$OpenDirFile == 0} {

DeleteFile $TMPSentinel1Config

if {$SENTINEL1Mode == "IW"} {
    set NumSwath "iw"; append NumSwath $SENTINEL1Swath
    for {set i 1} {$i <= 3} {incr i} { 
        if {[string first $NumSwath $SENTINEL1ProductFile($i)] != "-1"} {set SwathNum $i}
        }
    }
if {$SENTINEL1Mode == "EW"} {
    set NumSwath "ew"; append NumSwath $SENTINEL1Swath
    for {set i 1} {$i <= 5} {incr i} { 
        if {[string first $NumSwath $SENTINEL1ProductFile($i)] != "-1"} {set SwathNum $i}
        }
    }
set SENTINEL1FileProduct "$SENTINEL1DirInput/annotation/"
append SENTINEL1FileProduct "$SENTINEL1ProductFile($SwathNum).xml"
if [file exists $SENTINEL1FileProduct] {
    set SENTINEL1File "$SENTINEL1DirInput/product_header.txt"
    set Sensor "sentinel1"
    ReadXML $SENTINEL1FileProduct $SENTINEL1File $TMPSentinel1Config $Sensor
    WaitUntilCreated $TMPSentinel1Config
    if [file exists $TMPSentinel1Config] {
        set f [open $TMPSentinel1Config r]
        gets $f NumLinesImg
        gets $f NumLinesBurst
        close $f
        set SENTINEL1BurstMax [expr $NumLinesImg / $NumLinesBurst]
        set SENTINEL1Burst "ALL"

#####################################################################
#####################################################################

#set SENTINEL1DirOutput $SENTINEL1DirInput
append SENTINEL1DirOutput "/$SENTINEL1Mode"
append SENTINEL1DirOutput "$SENTINEL1Swath"
#append SENTINEL1DirOutput "_$SENTINEL1Burst"

#####################################################################
#Create Directory
set SENTINEL1DirOutput [PSPCreateDirectoryMask $SENTINEL1DirOutput $SENTINEL1DirOutput $SENTINEL1DirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPSentinel1Config
DeleteFile $TMPGoogle

set SENTINEL1File "$SENTINEL1DirInput/product_header.txt"
set SENTINELBurstOut $SENTINEL1Burst
if {$SENTINEL1Burst == "ALL"} { set SENTINELBurstOut 0 }

if [file exists $SENTINEL1File] {
    TextEditorRunTrace "Process The Function Soft/bin/data_import/sentinel1_header.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$SENTINEL1File\x22 -of \x22$TMPSentinel1Config\x22 -bn $SENTINELBurstOut" "k"
    set f [ open "| Soft/bin/data_import/sentinel1_header.exe -if \x22$SENTINEL1File\x22 -of \x22$TMPSentinel1Config\x22 -bn $SENTINELBurstOut" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WaitUntilCreated $TMPSentinel1Config
    if [file exists $TMPSentinel1Config] {
        set f [open $TMPSentinel1Config r]
        gets $f SENTINEL1Acq
        gets $f SENTINEL1PixRg
        gets $f SENTINEL1PixAz
        gets $f SENTINEL1NcolInit
        gets $f SENTINEL1NligInit
        gets $f SENTINEL1IncAngle
        gets $f SENTINEL1LigInit
        gets $f SENTINEL1LigFinal
        gets $f SENTINEL1NligFinal
        gets $f SENTINEL1ColInit
        gets $f SENTINEL1ColFinal
        gets $f SENTINEL1NcolFinal
        close $f
        $widget(Label453_02) configure -state normal; $widget(Entry453_02) configure -disabledbackground #FFFFFF
        $widget(Label453_03) configure -state normal; $widget(Entry453_03) configure -disabledbackground #FFFFFF
        $widget(Label453_04) configure -state normal; $widget(Entry453_04) configure -disabledbackground #FFFFFF
        $widget(Label453_07) configure -state normal; $widget(Entry453_07) configure -disabledbackground #FFFFFF
        $widget(Label453_08) configure -state normal; $widget(Entry453_08) configure -disabledbackground #FFFFFF
        if {$SENTINEL1Acq == "Asc"} {set SENTINEL1FUD 1}
        if {$SENTINEL1Acq == "Asc"} {set SENTINEL1AntennaPass "AR"} else {set SENTINEL1AntennaPass "DR"} 
        set f [open "$SENTINEL1DirOutput/config_acquisition.txt" w]
        puts $f $SENTINEL1AntennaPass
        puts $f $SENTINEL1IncAngle
        puts $f $SENTINEL1PixRg
        puts $f $SENTINEL1PixAz
        close $f

        if {$SENTINEL1Mode == "IW"} {
            set NumSwath "iw"; append NumSwath $SENTINEL1Swath
            for {set i 1} {$i <= 6} {incr i} { 
                if {[string first $NumSwath $SENTINEL1ProductFile($i)] != "-1"} {
                    if {$PolarType == "pp1"} {
                        if {[string first "hh" $SENTINEL1ProductFile($i)] != "-1"} {
                            set FileInput1 "$SENTINEL1DirInput/measurement/"
                            append FileInput1 "$SENTINEL1ProductFile($i).tiff"
                            }
                        if {[string first "hv" $SENTINEL1ProductFile($i)] != "-1"} {
                            set FileInput2 "$SENTINEL1DirInput/measurement/"
                            append FileInput2 "$SENTINEL1ProductFile($i).tiff"
                            }
                        }
                    if {$PolarType == "pp2"} {
                        if {[string first "vv" $SENTINEL1ProductFile($i)] != "-1"} {
                            set FileInput1 "$SENTINEL1DirInput/measurement/"
                            append FileInput1 "$SENTINEL1ProductFile($i).tiff"
                            }
                        if {[string first "vh" $SENTINEL1ProductFile($i)] != "-1"} {
                            set FileInput2 "$SENTINEL1DirInput/measurement/"
                            append FileInput2 "$SENTINEL1ProductFile($i).tiff"
                            }
                        }
                    }
                }
            }
        if {$SENTINEL1Mode == "EW"} {
            set NumSwath "ew"; append NumSwath $SENTINEL1Swath
            for {set i 1} {$i <= 10} {incr i} { 
                if {[string first $NumSwath $SENTINEL1ProductFile($i)] != "-1"} {
                    if {$PolarType == "pp1"} {
                        if {[string first "hh" $SENTINEL1ProductFile($i)] != "-1"} {
                            set FileInput1 "$SENTINEL1DirInput/measurement/"
                            append FileInput1 "$SENTINEL1ProductFile($i).tiff"
                            }
                        if {[string first "hv" $SENTINEL1ProductFile($i)] != "-1"} {
                            set FileInput2 "$SENTINEL1DirInput/measurement/"
                            append FileInput2 "$SENTINEL1ProductFile($i).tiff"
                            }
                        }
                    if {$PolarType == "pp2"} {
                        if {[string first "vv" $SENTINEL1ProductFile($i)] != "-1"} {
                            set FileInput1 "$SENTINEL1DirInput/measurement/"
                            append FileInput1 "$SENTINEL1ProductFile($i).tiff"
                            }
                        if {[string first "vh" $SENTINEL1ProductFile($i)] != "-1"} {
                            set FileInput2 "$SENTINEL1DirInput/measurement/"
                            append FileInput2 "$SENTINEL1ProductFile($i).tiff"
                            }
                        }
                    }
                }
            }
        $widget(TitleFrame453_1) configure  -state normal
        $widget(Entry453_1) configure -disabledbackground #FFFFFF
        $widget(Button453_1) configure -state normal
        $widget(TitleFrame453_2) configure  -state normal
        $widget(Entry453_2) configure -disabledbackground #FFFFFF
        $widget(Button453_2) configure -state normal
        $widget(Button453_6) configure -state normal
        } else {
        set ErrorMessage "ERROR DURING THE CREATION OF THE OUTPUT FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
        #TMPSentinel1Config Exists

    TextEditorRunTrace "Process The Function Soft/bin/data_import/sentinel1_google.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$SENTINEL1File\x22 -of \x22$TMPGoogle\x22 -od \x22$SENTINEL1DirOutput\x22 -bn $SENTINELBurstOut" "k"
    set f [ open "| Soft/bin/data_import/sentinel1_google.exe -if \x22$SENTINEL1File\x22 -of \x22$TMPGoogle\x22 -od \x22$SENTINEL1DirOutput\x22 -bn $SENTINELBurstOut" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
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
        $widget(Button453_04) configure -state normal
        }
        #TMPGoogle Exists
    }
    #ProductFile Exists
  }
  #Warning

#####################################################################
#####################################################################

        } else {
        set ErrorMessage "PRODUCT FILE IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
        #TMPSentinel1Config Exists
    } else {
    set ErrorMessage "ENTER THE XML - PRODUCT FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set SENTINEL1FileInputFlag 0
    }
    #ProductFile Exists
}
#OpenDirFile} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_5_0.cpd81" "Button4" vTcl:WidgetProc "Toplevel453" 1
    pack $site_5_0.ent78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_5_0.but79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    button $site_3_0.cpd83 \
        \
        -command {global FileName VarError ErrorMessage SENTINEL1DirOutput

set SENTINEL1File "$SENTINEL1DirOutput/GEARTH_POLY.kml"
if [file exists $SENTINEL1File] {
    GoogleEarth $SENTINEL1File
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -padx 4 -pady 2 -text Google 
    vTcl:DefineAlias "$site_3_0.cpd83" "Button453_04" vTcl:WidgetProc "Toplevel453" 1
    bindtags $site_3_0.cpd83 "$site_3_0.cpd83 Button $top all _vTclBalloon"
    bind $site_3_0.cpd83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_3_0.tit77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame5" vTcl:WidgetProc "Toplevel453" 1
    set site_3_0 $top.fra76
    frame $site_3_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd84" "Frame6" vTcl:WidgetProc "Toplevel453" 1
    set site_4_0 $site_3_0.cpd84
    label $site_4_0.lab77 \
        -text {Azimut Pixel Spacing} 
    vTcl:DefineAlias "$site_4_0.lab77" "Label453_02" vTcl:WidgetProc "Toplevel453" 1
    entry $site_4_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1PixAz -width 7 
    vTcl:DefineAlias "$site_4_0.ent78" "Entry453_02" vTcl:WidgetProc "Toplevel453" 1
    pack $site_4_0.lab77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    frame $site_3_0.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd90" "Frame30" vTcl:WidgetProc "Toplevel453" 1
    set site_4_0 $site_3_0.cpd90
    label $site_4_0.lab77 \
        -text {Range Pixel Spacing} 
    vTcl:DefineAlias "$site_4_0.lab77" "Label453_03" vTcl:WidgetProc "Toplevel453" 1
    entry $site_4_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1PixRg -width 7 
    vTcl:DefineAlias "$site_4_0.ent78" "Entry453_03" vTcl:WidgetProc "Toplevel453" 1
    pack $site_4_0.lab77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    frame $site_3_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd85" "Frame16" vTcl:WidgetProc "Toplevel453" 1
    set site_4_0 $site_3_0.cpd85
    label $site_4_0.lab79 \
        -text {Incidence Angle} 
    vTcl:DefineAlias "$site_4_0.lab79" "Label453_04" vTcl:WidgetProc "Toplevel453" 1
    entry $site_4_0.ent80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1IncAngle -width 7 
    vTcl:DefineAlias "$site_4_0.ent80" "Entry453_04" vTcl:WidgetProc "Toplevel453" 1
    pack $site_4_0.lab79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd90 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame3" vTcl:WidgetProc "Toplevel453" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File ( Co - Pol )} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame453_1" vTcl:WidgetProc "Toplevel453" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry453_1" vTcl:WidgetProc "Toplevel453" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame25" vTcl:WidgetProc "Toplevel453" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd119 \
        \
        -command {global FileName SENTINEL1DirInput SENTINEL1DataFormat FileInput1

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $SENTINEL1DirInput $types "INPUT FILE ( Co-Pol )"
set FileInput1 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd119" "Button453_1" vTcl:WidgetProc "Toplevel453" 1
    bindtags $site_6_0.cpd119 "$site_6_0.cpd119 Button $top all _vTclBalloon"
    bind $site_6_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd119 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd116 \
        -ipad 0 -text {Input Data File ( X - Pol )} 
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame453_2" vTcl:WidgetProc "Toplevel453" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry453_2" vTcl:WidgetProc "Toplevel453" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame26" vTcl:WidgetProc "Toplevel453" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd120 \
        \
        -command {global FileName SENTINEL1DirInput SENTINEL1DataFormat FileInput2

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $SENTINEL1DirInput $types "INPUT FILE ( X-Pol )"
set FileInput2 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd120" "Button453_2" vTcl:WidgetProc "Toplevel453" 1
    bindtags $site_6_0.cpd120 "$site_6_0.cpd120 Button $top all _vTclBalloon"
    bind $site_6_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd120 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_3_0.cpd116 \
        -in $site_3_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    frame $top.fra87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra87" "Frame4" vTcl:WidgetProc "Toplevel453" 1
    set site_3_0 $top.fra87
    frame $site_3_0.cpd89 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd89" "Frame24" vTcl:WidgetProc "Toplevel453" 1
    set site_4_0 $site_3_0.cpd89
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame27" vTcl:WidgetProc "Toplevel453" 1
    set site_5_0 $site_4_0.cpd84
    label $site_5_0.lab77 \
        -text {Number of Rows} 
    vTcl:DefineAlias "$site_5_0.lab77" "Label453_07" vTcl:WidgetProc "Toplevel453" 1
    entry $site_5_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1NligFinal -width 7 
    vTcl:DefineAlias "$site_5_0.ent78" "Entry453_07" vTcl:WidgetProc "Toplevel453" 1
    pack $site_5_0.lab77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    frame $site_4_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd85" "Frame28" vTcl:WidgetProc "Toplevel453" 1
    set site_5_0 $site_4_0.cpd85
    label $site_5_0.lab79 \
        -text {Number of Cols} 
    vTcl:DefineAlias "$site_5_0.lab79" "Label453_08" vTcl:WidgetProc "Toplevel453" 1
    entry $site_5_0.ent80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SENTINEL1NcolFinal -width 7 
    vTcl:DefineAlias "$site_5_0.ent80" "Entry453_08" vTcl:WidgetProc "Toplevel453" 1
    pack $site_5_0.lab79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd89 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra71 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel453" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global SENTINEL1DirOutput SENTINEL1FileInputFlag SENTINEL1DataFormat
global SENTINEL1Mode SENTINEL1Swath SENTINEL1ModeSwath
global OpenDirFile TMPSentinel1Config
global FileInput1 FileInput2
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput

if {$OpenDirFile == 0} {

set SENTINEL1FileInputFlag 0
if {$SENTINEL1DataFormat == "dual"} {
    set SENTINEL1FileFlag 0
    if {$FileInput1 != ""} {incr SENTINEL1FileFlag}
    if {$FileInput2 != ""} {incr SENTINEL1FileFlag}
    if {$SENTINEL1FileFlag == 2} {set SENTINEL1FileInputFlag 1}
    }
if {$SENTINEL1FileInputFlag == 1} {
    set SENTINEL1ModeSwath $SENTINEL1Mode; append SENTINEL1ModeSwath $SENTINEL1Swath
    set NligFullSize $SENTINEL1NligInit
    set NcolFullSize $SENTINEL1NcolInit
    set NligInit 1
    set NligEnd $NligFullSize
    set NcolInit 1
    set NcolEnd $NcolFullSize
    set NligFullSizeInput $NligFullSize
    set NcolFullSizeInput $NcolFullSize
    set ErrorMessage ""
    set WarningMessage "DON'T FORGET TO EXTRACT DATA"
    set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    Window hide $widget(Toplevel453); TextEditorRunTrace "Close Window SENTINEL1 Input File" "b"
    } else {
    set SENTINEL1FileInputFlag 0
    set ErrorMessage "ENTER THE SENTINEL1 DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button453_6" vTcl:WidgetProc "Toplevel453" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SENTINEL1_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel453" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel453); TextEditorRunTrace "Close Window SENTINEL1 Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel453" 1
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
    pack $top.lab66 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill none -pady 3 -side top 
    pack $top.fra75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra87 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
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
Window show .top453

main $argc $argv
