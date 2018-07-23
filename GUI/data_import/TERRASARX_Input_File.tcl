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

        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images TERRASARX.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}
        {{[file join . GUI Images tools.gif]} {user image} user {}}

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
    set base .top221
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
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.fra82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra82
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra85
    namespace eval ::widgets::$site_4_0.fra86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra86
    namespace eval ::widgets::$site_5_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra90
    namespace eval ::widgets::$site_6_0.cpd92 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra91
    namespace eval ::widgets::$site_6_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.fra87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra87
    namespace eval ::widgets::$site_5_0.ent95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd98
    namespace eval ::widgets::$site_5_0.ent95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd94
    namespace eval ::widgets::$site_5_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra90
    namespace eval ::widgets::$site_6_0.cpd92 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra91
    namespace eval ::widgets::$site_6_0.cpd93 {
        array set save {-text 1}
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
    namespace eval ::widgets::$site_3_0.cpd117 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd122 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab79 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent80 {
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
    namespace eval ::widgets::$site_3_0.but67 {
        array set save {-command 1 -image 1 -pady 1}
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
            vTclWindow.top221
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

proc vTclWindow.top221 {base} {
    if {$base == ""} {
        set base .top221
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
    wm geometry $top 500x570+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "TerraSAR-X Input Data File"
    vTcl:DefineAlias "$top" "Toplevel221" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
        -image [vTcl:image:get_image [file join . GUI Images TERRASARX.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel221" 1
    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel221" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel221" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TERRASARXDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel221" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel221" 1
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
    vTcl:DefineAlias "$top.cpd71" "TitleFrame221" vTcl:WidgetProc "Toplevel221" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable TERRASARXDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry221" vTcl:WidgetProc "Toplevel221" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel221" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global DirName DataDir TERRASARXDirOutput
global VarWarning WarningMessage WarningMessage2

set TERRASARXOutputDirTmp $TERRASARXDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set TERRASARXDirOutput $DirName
        } else {
        set TERRASARXDirOutput $TERRASARXOutputDirTmp
        }
    } else {
    set TERRASARXDirOutput $TERRASARXOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button221" vTcl:WidgetProc "Toplevel221" 1
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
    TitleFrame $top.cpd72 \
        -ipad 0 -text {SAR Product File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame220" vTcl:WidgetProc "Toplevel221" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TERRASARXProductFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry220" vTcl:WidgetProc "Toplevel221" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame30" vTcl:WidgetProc "Toplevel221" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName TERRASARXDirInput TERRASARXProductFile

set types {
    {{XML Files}        {.xml}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $TERRASARXDirInput $types "SAR PRODUCT FILE"
set TERRASARXProductFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button220" vTcl:WidgetProc "Toplevel221" 1
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
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame4" vTcl:WidgetProc "Toplevel221" 1
    set site_3_0 $top.fra73
    frame $site_3_0.fra82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra82" "Frame2" vTcl:WidgetProc "Toplevel221" 1
    set site_4_0 $site_3_0.fra82
    button $site_4_0.cpd83 \
        -background #ffff00 \
        -command {global TERRASARXDirInput TERRASARXDirOutput TERRASARXFileInputFlag
global TERRASARXDataFormat TERRASARXDataLevel TERRASARXProductFile
global TSXProduct TSXResolution TSXImaging TSXPolar
global FileInput1 FileInput2 FileInput3 FileInput4
global QLFileInput1 QLFileInput2 QLFileInput3 QLFileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPTerrasarxConfig TMPGoogle OpenDirFile PolarType
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set NligFullSize ""
set NcolFullSize ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set NligFullSizeInput 0
set NcolFullSizeInput 0

set config "true"
if {$TERRASARXProductFile == ""} { set config "false" }
if {$config == "true"} {

    set ProductFile [file tail $TERRASARXProductFile]
    set TSXAA [string range $ProductFile 10 12]
    set TSXBB [string range $ProductFile 14 17]
    set TSXCC [string range $ProductFile 19 20]
    set TSXDD [string range $ProductFile 22 22]

    if {$TSXAA == "SSC"} { set TSXProduct "Single Look Slant Range - Complex" }
    if {$TSXAA == "MGD"} { set TSXProduct "Multi Look Ground Range - Detected" }
    if {$TSXAA == "GEC"} { set TSXProduct "Geocoded Ellipsoid Corrected - Detected" }
    if {$TSXAA == "EEC"} { set TSXProduct "Enhanced Ellipsoid Corrected - Detected" }

    if {$TSXBB == "SE__"} { set TSXResolution "Spacially Enhanced (High Resolution)" }
    if {$TSXBB == "RE__"} { set TSXResolution "Radiometrically Enhanced (High Radiometry)" }
    if {$TSXBB == "____"} { set TSXResolution "  n/a " }

    if {$TSXCC == "SM"} { set TSXImaging "StripMap" }
    if {$TSXCC == "SC"} { set TSXImaging "ScanSar" }
    if {$TSXCC == "SL"} { set TSXImaging "SpotLight" }
    if {$TSXCC == "HS"} { set TSXImaging "HR SpotLight" }

    if {$TSXDD == "S"} { set TSXPolar "Single Pol"; set TSXDD "sngl" }
    if {$TSXDD == "D"} { set TSXPolar "Dual Pol"; set TSXDD "dual" }
    if {$TSXDD == "T"} { set TSXPolar "Twin Pol"; set TSXDD "twin" }
    if {$TSXDD == "Q"} { set TSXPolar "Quad Pol"; set TSXDD "quad" }

    set ModeTSX "false"
    if {$TSXDD == $TERRASARXDataFormat} { if {$TSXAA == $TERRASARXDataLevel} { set ModeTSX "true" } }
    if {$ModeTSX == "false"} {
        set ErrorMessage "ERROR IN THE TERRASAR-X DATA MODE and/or LEVEL"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        MenuRAZ
        ClosePSPViewer
        CloseAllWidget
        set WindowShow "false"
        if {$ActiveProgram == "TERRASARX"} {
            if {$TERRASARXDataFormat == "dual"} { TextEditorRunTrace "Close EO-SI Dual Pol" "b" }
            if {$TERRASARXDataFormat == "twin"} { }
            if {$TERRASARXDataFormat == "quad"} { TextEditorRunTrace "Close EO-SI Quad Pol" "b" }
            if {$TSXDD == "dual"} { TextEditorRunTrace "Open EO-SI Dual Pol" "b" }
            if {$TSXDD == "twin"} { }
            if {$TSXDD == "quad"} { TextEditorRunTrace "Open EO-SI Quad Pol" "b" }
            set TERRASARXDataFormat $TSXDD
            set TERRASARXDataLevel $TSXAA
            $widget(MenubuttonTSX) configure -background #FFFF00
            MenuEnvImp
            InitDataDir
            CheckEnvironnement
            }
        Window hide $widget(Toplevel221); TextEditorRunTrace "Close Window TERRASARX Input File" "b"
        } else {

set datalevelerror 0

#####################################################################
#Create Directory
set TERRASARXDirOutput [PSPCreateDirectoryMask $TERRASARXDirOutput $TERRASARXDirOutput $TERRASARXDirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPTerrasarxConfig
DeleteFile $TMPGoogle

if [file exists $TERRASARXProductFile] {
    set TERRASARXFile "$TERRASARXDirOutput/product_header.txt"
    set Sensor "terrasar"
    ReadXML $TERRASARXProductFile $TERRASARXFile $TMPTerrasarxConfig $Sensor
    WaitUntilCreated $TMPTerrasarxConfig
    if [file exists $TMPTerrasarxConfig] {
        set f [open $TMPTerrasarxConfig r]
        gets $f TSXDataFormat
        gets $f TSXDataLevel
        close $f

        if {$TSXDataFormat == $TERRASARXDataFormat } {
            if {$TSXDataLevel == $TERRASARXDataLevel } {
                set f [open $TMPTerrasarxConfig r]
                gets $f TSXtmp; gets $f TSXtmp;

                gets $f NligFullSize
                gets $f NcolFullSize
                $widget(Entry221_5) configure -disabledbackground #FFFFFF; $widget(Label221_1) configure -state normal
                $widget(Entry221_6) configure -disabledbackground #FFFFFF; $widget(Label221_2) configure -state normal
                set NligInit 1; set NligEnd $NligFullSize
                set NcolInit 1; set NcolEnd $NcolFullSize
                set NligFullSizeInput $NligFullSize
                set NcolFullSizeInput $NcolFullSize

                gets $f PolarType 
                if {$TSXDataFormat == "dual"} {
                    set FileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append FileInput $TSXtmp
                    set QLFileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append QLFileInput $TSXtmp
                    if [file exists $FileInput] {
                        set FileInput1 $FileInput; set QLFileInput1 $QLFileInput
                        } else {
                        set FileInput1 ""; set QLFileInput1 ""
                        }
                    gets $f TSXtmp;
                    set FileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append FileInput $TSXtmp
                    set QLFileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append QLFileInput $TSXtmp
                    if [file exists $FileInput] {
                        set FileInput2 $FileInput; set QLFileInput2 $QLFileInput
                        } else {
                        set FileInput2 ""; set QLFileInput2 ""
                        }
                    gets $f TSXtmp;
                    
                    if {$PolarType == "pp1"} { set Channel1 "s11"; set Channel2 "s12" } 
                    if {$PolarType == "pp2"} { set Channel1 "s22"; set Channel2 "s21" } 
                    if {$PolarType == "pp3"} { set Channel1 "s11"; set Channel2 "s22" }
                    if {$PolarType == "pp0"} { set Channel1 "s12"; set Channel2 "s21" } 
                    $widget(Entry221_1) configure -disabledbackground #FFFFFF; $widget(Button221_1) configure -state normal
                    $widget(TitleFrame221_1) configure -text "Input Data File ($Channel1)"
                    $widget(Entry221_2) configure -disabledbackground #FFFFFF; $widget(Button221_2) configure -state normal
                    $widget(TitleFrame221_2) configure -text "Input Data File ($Channel2)"
                    $widget(Entry221_3) configure -disabledbackground $PSPBackgroundColor; $widget(Button221_3) configure -state disable
                    $widget(TitleFrame221_3) configure -text ""
                    $widget(Entry221_4) configure -disabledbackground $PSPBackgroundColor; $widget(Button221_4) configure -state disable
                    }
                if {$TSXDataFormat == "quad"} {
                    set FileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append FileInput $TSXtmp
                    set QLFileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append QLFileInput $TSXtmp
                    if [file exists $FileInput] {
                        set FileInput1 $FileInput; set QLFileInput1 $QLFileInput
                        } else {
                        set FileInput1 ""; set QLFileInput1 ""
                        }
                    gets $f TSXtmp;
                    set FileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append FileInput $TSXtmp
                    set QLFileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append QLFileInput $TSXtmp
                    if [file exists $FileInput] {
                        set FileInput2 $FileInput; set QLFileInput2 $QLFileInput
                        } else {
                        set FileInput2 ""; set QLFileInput2 ""
                        }
                    gets $f TSXtmp;
                    set FileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append FileInput $TSXtmp
                    set QLFileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append QLFileInput $TSXtmp
                    if [file exists $FileInput] {
                        set FileInput3 $FileInput; set QLFileInput3 $QLFileInput
                        } else {
                        set FileInput3 ""; set QLFileInput3 ""
                        }
                    gets $f TSXtmp;
                    set FileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append FileInput $TSXtmp
                    set QLFileInput "$TERRASARXDirInput/"; gets $f TSXtmp; append QLFileInput $TSXtmp
                    if [file exists $FileInput] {
                        set FileInput4 $FileInput; set QLFileInput4 $QLFileInput
                        } else {
                        set FileInput4 ""; set QLFileInput4 ""
                        }
                    gets $f TSXtmp;
                    $widget(Entry221_1) configure -disabledbackground #FFFFFF; $widget(Button221_1) configure -state normal
                    $widget(TitleFrame221_1) configure -text "Input Data File (s11)"
                    $widget(Entry221_2) configure -disabledbackground #FFFFFF; $widget(Button221_2) configure -state normal
                    $widget(TitleFrame221_2) configure -text "Input Data File (s12)"
                    $widget(Entry221_3) configure -disabledbackground #FFFFFF; $widget(Button221_3) configure -state normal
                    $widget(TitleFrame221_3) configure -text "Input Data File (s21)"
                    $widget(Entry221_4) configure -disabledbackground #FFFFFF; $widget(Button221_4) configure -state normal
                    $widget(TitleFrame221_4) configure -text "Input Data File (s22)"
                    }
                close $f
                $widget(Button221_5) configure -state normal; $widget(Button221_6) configure -state normal; 
                TextEditorRunTrace "Process The Function Soft/data_import/terrasarx_google.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$TERRASARXDirOutput\x22 -of \x22$TMPGoogle\x22" "k"
                set f [ open "| Soft/data_import/terrasarx_google.exe -id \x22$TERRASARXDirOutput\x22 -of \x22$TMPGoogle\x22" r]
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
                    }
                $widget(Button221_7) configure -state normal
            } else {
            set ErrorMessage "ERROR IN THE TERRASAR-X DATA LEVEL (SSC - MGD - GEC - EEC)"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set TERRASARXDataFormat ""; set TERRASARXDataLevel ""
            set TERRASARXProductFile ""; set TERRASARXFileInputFlag 0
            set datalevelerror 1
            }
        } else {
        set ErrorMessage "ERROR IN THE TERRASAR-X DATA FORMAT (DUAL - QUAD)"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set TERRASARXDataFormat ""; set TERRASARXDataLevel ""
        set TERRASARXProductFile ""; set TERRASARXFileInputFlag 0
        set datalevelerror 1
        }
    } else {
    set ErrorMessage "PRODUCT FILE IS NOT AN XML FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set TERRASARXDataFormat ""; set TERRASARXDataLevel ""
    set TERRASARXProductFile ""; set TERRASARXFileInputFlag 0
    set datalevelerror 1
    }
    #TMPTERRASARXConfig Exists
} else {
set ErrorMessage "ENTER THE XML - PRODUCT FILE NAME"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
set TERRASARXDataFormat ""; set TERRASARXDataLevel ""
set TERRASARXProductFile ""; set TERRASARXFileInputFlag 0
set datalevelerror 1
}
#ProductFile Exists

if {$datalevelerror == 1 } {
    MenuRAZ
    ClosePSPViewer
    CloseAllWidget
    if {$ActiveProgram == "TERRASARX"} {
        if {$TERRASARXDataFormat == "dual"} { TextEditorRunTrace "Close EO-SI Dual Pol" "b" }
        if {$TERRASARXDataFormat == "quad"} { TextEditorRunTrace "Close EO-SI Quad Pol" "b" }
        if {$TERRASARXDataFormat == "twin"} { }
        set ActiveProgram ""
        set TERRASARXDataFormat ""
        set TERRASARXDataLevel ""
        $widget(MenubuttonTSX) configure -background $couleur_fond
        MenuEnvImp
        }
    Window hide $widget(Toplevel221); TextEditorRunTrace "Close Window TERRASARX Input File" "b"
    }
}
#VarWarning
}
#ModeTSX
}
#ProductFile
} else {
set VarError ""
set ErrorMessage "ENTER THE XML - PRODUCT FILE NAME"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}
#OpenDirFile} \
        -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_4_0.cpd83" "Button1" vTcl:WidgetProc "Toplevel221" 1
    button $site_4_0.cpd84 \
        -background #ffff00 \
        -command {global FileName VarError ErrorMessage TERRASARXDirOutput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set TERRASARXFile "$TERRASARXDirOutput/product_header.txt"
if [file exists $TERRASARXFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top221 $TERRASARXFile
    }} \
        -padx 4 -pady 2 -text {Edit Header} 
    vTcl:DefineAlias "$site_4_0.cpd84" "Button221_5" vTcl:WidgetProc "Toplevel221" 1
    button $site_4_0.cpd73 \
        \
        -command {global FileName VarError ErrorMessage TERRASARXDirInput

set TERRASARXFile "$TERRASARXDirInput/GEARTH_POLY.kml"
if [file exists $TERRASARXFile] {
    GoogleEarth $TERRASARXFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -padx 4 -pady 2 -relief raised -text Google 
    vTcl:DefineAlias "$site_4_0.cpd73" "Button221_7" vTcl:WidgetProc "Toplevel221" 1
    bindtags $site_4_0.cpd73 "$site_4_0.cpd73 Button $top all _vTclBalloon"
    bind $site_4_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.fra85 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_3_0.fra85" "Frame7" vTcl:WidgetProc "Toplevel221" 1
    set site_4_0 $site_3_0.fra85
    frame $site_4_0.fra86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra86" "Frame6" vTcl:WidgetProc "Toplevel221" 1
    set site_5_0 $site_4_0.fra86
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame9" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.fra90
    label $site_6_0.cpd92 \
        -text Product 
    vTcl:DefineAlias "$site_6_0.cpd92" "Label1" vTcl:WidgetProc "Toplevel221" 1
    pack $site_6_0.cpd92 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra91" "Frame10" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.fra91
    label $site_6_0.cpd93 \
        -text Resolution 
    vTcl:DefineAlias "$site_6_0.cpd93" "Label2" vTcl:WidgetProc "Toplevel221" 1
    pack $site_6_0.cpd93 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra90 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra91 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    frame $site_4_0.fra87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra87" "Frame8" vTcl:WidgetProc "Toplevel221" 1
    set site_5_0 $site_4_0.fra87
    entry $site_5_0.ent95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TSXProduct 
    vTcl:DefineAlias "$site_5_0.ent95" "Entry1" vTcl:WidgetProc "Toplevel221" 1
    entry $site_5_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TSXResolution 
    vTcl:DefineAlias "$site_5_0.cpd97" "Entry2" vTcl:WidgetProc "Toplevel221" 1
    pack $site_5_0.ent95 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    frame $site_4_0.cpd98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd98" "Frame15" vTcl:WidgetProc "Toplevel221" 1
    set site_5_0 $site_4_0.cpd98
    entry $site_5_0.ent95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable TSXImaging -width 10 
    vTcl:DefineAlias "$site_5_0.ent95" "Entry3" vTcl:WidgetProc "Toplevel221" 1
    entry $site_5_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable TSXPolar -width 10 
    vTcl:DefineAlias "$site_5_0.cpd97" "Entry4" vTcl:WidgetProc "Toplevel221" 1
    pack $site_5_0.ent95 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    frame $site_4_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd94" "Frame12" vTcl:WidgetProc "Toplevel221" 1
    set site_5_0 $site_4_0.cpd94
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame13" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.fra90
    label $site_6_0.cpd92 \
        -text {Imaging Mode} 
    vTcl:DefineAlias "$site_6_0.cpd92" "Label3" vTcl:WidgetProc "Toplevel221" 1
    pack $site_6_0.cpd92 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra91" "Frame14" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.fra91
    label $site_6_0.cpd93 \
        -text {Polarization Mode} 
    vTcl:DefineAlias "$site_6_0.cpd93" "Label4" vTcl:WidgetProc "Toplevel221" 1
    pack $site_6_0.cpd93 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra90 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra91 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra86 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side left 
    pack $site_4_0.fra87 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill y -padx 5 -side right 
    pack $site_4_0.cpd94 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side right 
    pack $site_3_0.fra82 \
        -in $site_3_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_3_0.fra85 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame3" vTcl:WidgetProc "Toplevel221" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File ( s11 )} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame221_1" vTcl:WidgetProc "Toplevel221" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry221_1" vTcl:WidgetProc "Toplevel221" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame25" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd119 \
        \
        -command {global FileName TERRASARXDirInput TERRASARXDataFormat FileInput1

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TERRASARXDirInput/IMAGEDATA"] {
    set TSXDirTmp "$TERRASARXDirInput/IMAGEDATA"
    } else {
    set TSXDirTmp $TERRASARXDirInput
    }
if {$TERRASARXDataFormat == "quad"} {OpenFile $TSXDirTmp $types "HH INPUT FILE (s11)"}
if {$TERRASARXDataFormat == "dual"} {OpenFile $TSXDirTmp $types "INPUT FILE (Channel 1)"}
if {$FileName == "" } { set FileName $FileInput1 }
set FileInput1 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd119" "Button221_1" vTcl:WidgetProc "Toplevel221" 1
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
        -ipad 0 -text {Input Data File ( s12 )} 
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame221_2" vTcl:WidgetProc "Toplevel221" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry221_2" vTcl:WidgetProc "Toplevel221" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame26" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd120 \
        \
        -command {global FileName TERRASARXDirInput TERRASARXDataFormat FileInput2

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TERRASARXDirInput/IMAGEDATA"] {
    set TSXDirTmp "$TERRASARXDirInput/IMAGEDATA"
    } else {
    set TSXDirTmp $TERRASARXDirInput
    }
if {$TERRASARXDataFormat == "quad"} {OpenFile $TSXDirTmp $types "HV INPUT FILE (s12)"}
if {$TERRASARXDataFormat == "dual"} {OpenFile $TSXDirTmp $types "INPUT FILE (Channel 2)"}
if {$FileName == "" } { set FileName $FileInput2 }
set FileInput2 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd120" "Button221_2" vTcl:WidgetProc "Toplevel221" 1
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
    TitleFrame $site_3_0.cpd117 \
        -ipad 0 -text {Input Data File ( s21 )} 
    vTcl:DefineAlias "$site_3_0.cpd117" "TitleFrame221_3" vTcl:WidgetProc "Toplevel221" 1
    bind $site_3_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry221_3" vTcl:WidgetProc "Toplevel221" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd121 \
        \
        -command {global FileName TERRASARXDirInput TERRASARXDataFormat FileInput3

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TERRASARXDirInput/IMAGEDATA"] {
    set TSXDirTmp "$TERRASARXDirInput/IMAGEDATA"
    } else {
    set TSXDirTmp $TERRASARXDirInput
    }
if {$TERRASARXDataFormat == "quad"} {OpenFile $TSXDirTmp $types "VH INPUT FILE (s21)"}
if {$FileName == "" } { set FileName $FileInput3 }
set FileInput3 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd121" "Button221_3" vTcl:WidgetProc "Toplevel221" 1
    bindtags $site_6_0.cpd121 "$site_6_0.cpd121 Button $top all _vTclBalloon"
    bind $site_6_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd121 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd118 \
        -ipad 0 -text {Input Data File ( s22 )} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame221_4" vTcl:WidgetProc "Toplevel221" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry221_4" vTcl:WidgetProc "Toplevel221" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame28" vTcl:WidgetProc "Toplevel221" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd122 \
        \
        -command {global FileName TERRASARXDirInput TERRASARXDataFormat FileInput4

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TERRASARXDirInput/IMAGEDATA"] {
    set TSXDirTmp "$TERRASARXDirInput/IMAGEDATA"
    } else {
    set TSXDirTmp $TERRASARXDirInput
    }
if {$TERRASARXDataFormat == "quad"} {OpenFile $TSXDirTmp $types "VV INPUT FILE (s22)"}
if {$FileName == "" } { set FileName $FileInput4 }
set FileInput4 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd122" "Button221_4" vTcl:WidgetProc "Toplevel221" 1
    bindtags $site_6_0.cpd122 "$site_6_0.cpd122 Button $top all _vTclBalloon"
    bind $site_6_0.cpd122 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd122 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd116 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd117 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra76 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame5" vTcl:WidgetProc "Toplevel221" 1
    set site_3_0 $top.fra76
    label $site_3_0.lab77 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_3_0.lab77" "Label221_1" vTcl:WidgetProc "Toplevel221" 1
    entry $site_3_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_3_0.ent78" "Entry221_5" vTcl:WidgetProc "Toplevel221" 1
    label $site_3_0.lab79 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_3_0.lab79" "Label221_2" vTcl:WidgetProc "Toplevel221" 1
    entry $site_3_0.ent80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_3_0.ent80" "Entry221_6" vTcl:WidgetProc "Toplevel221" 1
    pack $site_3_0.lab77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.lab79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $top.fra71 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel221" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global TERRASARXDirOutput TERRASARXFileInputFlag OpenDirFile TMPTerrasarxConfig
global QLFileInput1 QLFileInput2 QLFileInput3 QLFileInput4
global IEEEFormat FileInput1 FileInput2 FileInput3 FileInput4
global fonction fonction2 ErrorMessage VarError Load_CheckSizeBinaryDataFile
global VarWarning VarAdvice WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput

if {$OpenDirFile == 0} {

set TERRASARXFileInputFlag 0
if {$TERRASARXDataFormat == "quad"} {
    set TERRASARXFileFlag 0
    if {$FileInput1 != ""} {incr TERRASARXFileFlag}
    if {$FileInput2 != ""} {incr TERRASARXFileFlag}
    if {$FileInput3 != ""} {incr TERRASARXFileFlag}
    if {$FileInput4 != ""} {incr TERRASARXFileFlag}
    if {$TERRASARXFileFlag == 4} {set TERRASARXFileInputFlag 1}
    }
if {$TERRASARXDataFormat == "dual"} {
    set TERRASARXFileFlag 0
    if {$FileInput1 != ""} {incr TERRASARXFileFlag}
    if {$FileInput2 != ""} {incr TERRASARXFileFlag}
    if {$TERRASARXFileFlag == 2} {set TERRASARXFileInputFlag 1}
    }

if {$TERRASARXFileInputFlag == 1} {
    if {$TERRASARXDataFormat == "dual"} {
        if [file exists $QLFileInput1] {
            set FileBMP "$TERRASARXDirOutput/";
            append FileBMP [file rootname [file tail $QLFileInput1]]
            append FileBMP ".bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/tiff_2_bmp.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$QLFileInput1\x22 -of \x22$FileBMP\x22" "k"
            set f [ open "| Soft/bmp_process/tiff_2_bmp.exe -if \x22$QLFileInput1\x22 -of \x22$FileBMP\x22" r]
            }
        if [file exists $QLFileInput2] {
            set FileBMP "$TERRASARXDirOutput/";
            append FileBMP [file rootname [file tail $QLFileInput2]]
            append FileBMP ".bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/tiff_2_bmp.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$QLFileInput2\x22 -of \x22$FileBMP\x22" "k"
            set f [ open "| Soft/bmp_process/tiff_2_bmp.exe -if \x22$QLFileInput2\x22 -of \x22$FileBMP\x22" r]
            }
        }
    if {$TERRASARXDataFormat == "quad"} {
        if [file exists $QLFileInput1] {
            set FileBMP "$TERRASARXDirOutput/";
            append FileBMP [file rootname [file tail $QLFileInput1]]
            append FileBMP ".bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/tiff_2_bmp.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$QLFileInput1\x22 -of \x22$FileBMP\x22" "k"
            set f [ open "| Soft/bmp_process/tiff_2_bmp.exe -if \x22$QLFileInput1\x22 -of \x22$FileBMP\x22" r]
            }
        if [file exists $QLFileInput2] {
            set FileBMP "$TERRASARXDirOutput/";
            append FileBMP [file rootname [file tail $QLFileInput2]]
            append FileBMP ".bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/tiff_2_bmp.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$QLFileInput2\x22 -of \x22$FileBMP\x22" "k"
            set f [ open "| Soft/bmp_process/tiff_2_bmp.exe -if \x22$QLFileInput2\x22 -of \x22$FileBMP\x22" r]
            }
        if [file exists $QLFileInput3] {
            set FileBMP "$TERRASARXDirOutput/";
            append FileBMP [file rootname [file tail $QLFileInput3]]
            append FileBMP ".bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/tiff_2_bmp.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$QLFileInput3\x22 -of \x22$FileBMP\x22" "k"
            set f [ open "| Soft/bmp_process/tiff_2_bmp.exe -if \x22$QLFileInput3\x22 -of \x22$FileBMP\x22" r]
            }
        if [file exists $QLFileInput4] {
            set FileBMP "$TERRASARXDirOutput/";
            append FileBMP [file rootname [file tail $QLFileInput4]]
            append FileBMP ".bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/tiff_2_bmp.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$QLFileInput4\x22 -of \x22$FileBMP\x22" "k"
            set f [ open "| Soft/bmp_process/tiff_2_bmp.exe -if \x22$QLFileInput4\x22 -of \x22$FileBMP\x22" r]
            }
        }

    set WarningMessage "DON'T FORGET TO EXTRACT DATA"
    set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    Window hide $widget(Toplevel221); TextEditorRunTrace "Close Window TERRASARX Input File" "b"
    } else {
    set TERRASARXFileInputFlag 0
    set ErrorMessage "ENTER THE TERRASARX DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
if {$Load_CheckSizeBinaryDataFile == 1} { Window hide $widget(Toplevel438); TextEditorRunTrace "Close Window Check Binary Data Files" "b" }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button221_6" vTcl:WidgetProc "Toplevel221" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/TERRASARX_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel221" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but67 \
        \
        -command {global TERRASARXDataLevel TERRASARXDataFormat
global Load_CheckSizeBinaryDataFile PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_CheckSizeBinaryDataFile == 0} {
    source "GUI/tools/CheckSizeBinaryDataFile.tcl"
    set Load_CheckSizeBinaryDataFile 1
    WmTransient $widget(Toplevel438) $PSPTopLevel
    }

WidgetShowFromWidget $widget(Toplevel221) $widget(Toplevel438); TextEditorRunTrace "Open Window Check Binary Data Files" "b"
CheckBinRAZ
if {$TERRASARXDataLevel == "SSC"} {
    if {$TERRASARXDataFormat == "dual"} { CheckTerrasarDualSSC }
    if {$TERRASARXDataFormat == "quad"} { CheckTerrasarQuadSSC }
    } else {
    CheckTerrasarDualnoSSC
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images tools.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_3_0.but67" "Button2" vTcl:WidgetProc "Toplevel221" 1
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile Load_CheckSizeBinaryDataFile

if {$OpenDirFile == 0} {

if {$Load_CheckSizeBinaryDataFile == 1} { Window hide $widget(Toplevel438); TextEditorRunTrace "Close Window Check Binary Data Files" "b" }
Window hide $widget(Toplevel221); TextEditorRunTrace "Close Window TERRASARX Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel221" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but67 \
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
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
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
Window show .top221

main $argc $argv
