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

        {{[file join . GUI Images AIRSAR.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}

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
    set base .top223
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
    namespace eval ::widgets::$base.tit71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd77 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra73
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
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
    namespace eval ::widgets::$base.cpd85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd85
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.men90 {
        array set save {-background 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.men90.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab42 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent43 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.che71 {
        array set save {-text 1 -variable 1}
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
            vTclWindow.top223
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
    wm geometry $top 200x200+256+256; update
    wm maxsize $top 1924 1055
    wm minsize $top 148 1
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

proc vTclWindow.top223 {base} {
    if {$base == ""} {
        set base .top223
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
    wm geometry $top 500x610+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 148 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "AIRSAR Input Data File"
    vTcl:DefineAlias "$top" "Toplevel223" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab49 \
        -image [vTcl:image:get_image [file join . GUI Images AIRSAR.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab49" "Label73" vTcl:WidgetProc "Toplevel223" 1
    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame1" vTcl:WidgetProc "Toplevel223" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel223" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable AIRSARDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel223" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel223" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button1" vTcl:WidgetProc "Toplevel223" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit71 \
        -ipad 0 -text {AIRSAR Processor} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame223_1" vTcl:WidgetProc "Toplevel223" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    radiobutton $site_4_0.cpd87 \
        \
        -command {global AIRSARDataFormat IEEEFormat
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3 FileInputSTK4 FileInputSTK5

set FileInputSTK1 ""; set FileInputSTK2 ""; set FileInputSTK3 ""; set FileInputSTK4 ""; set FileInputSTK5 ""; set FileInputSTK ""

$widget(TitleFrame223_2) configure -state normal
$widget(Radiobutton223_1) configure -state normal
$widget(Radiobutton223_2) configure -state normal

$widget(TitleFrame223_3) configure -state disable
$widget(TitleFrame223_3) configure -text ""
$widget(Entry223_3) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_3) configure -state disable 
$widget(TitleFrame223_4) configure -state disable
$widget(TitleFrame223_4) configure -text ""
$widget(Entry223_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_4) configure -state disable 
$widget(TitleFrame223_5) configure -state disable
$widget(TitleFrame223_5) configure -text ""
$widget(Entry223_5) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_5) configure -state disable 
$widget(TitleFrame223_6) configure -state disable
$widget(TitleFrame223_6) configure -text ""
$widget(Entry223_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_6) configure -state disable 
$widget(TitleFrame223_7) configure -state disable
$widget(TitleFrame223_7) configure -text ""
$widget(Entry223_7) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_7) configure -state disable 
$widget(TitleFrame223_8) configure -state disable
$widget(TitleFrame223_8) configure -text ""
$widget(Entry223_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_8) configure -state disable 

$widget(Button223_9) configure -state disable 
$widget(Menubutton223_1) configure -state disable 
$widget(Label223_1) configure -state disable; $widget(Entry223_1) configure -state disable  
$widget(Label223_2) configure -state disable; $widget(Entry223_2) configure -state disable  
$widget(Checkbutton223_1) configure -state disable; set IEEEFormat 0 

if {$AIRSARDataFormat != ""} {
    $widget(TitleFrame223_3) configure -state normal
    $widget(TitleFrame223_3) configure -text "AIRSAR STK or CM####_c / l / p.dat Input Data File"
    $widget(Entry223_3) configure -disabledbackground #FFFFFF
    $widget(Button223_3) configure -state normal
    }} \
        -text {v3.56 ( prior to 1993 )} -value old -variable AIRSARProcessor 
    vTcl:DefineAlias "$site_4_0.cpd87" "Radiobutton5" vTcl:WidgetProc "Toplevel223" 1
    radiobutton $site_4_0.cpd88 \
        \
        -command {global AIRSARDataFormat IEEEFormat
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3 FileInputSTK4 FileInputSTK5

set FileInputSTK1 ""; set FileInputSTK2 ""; set FileInputSTK3 ""; set FileInputSTK4 ""; set FileInputSTK5 ""; set FileInputSTK ""

$widget(TitleFrame223_2) configure -state normal
$widget(Radiobutton223_1) configure -state normal
$widget(Radiobutton223_2) configure -state normal

$widget(TitleFrame223_3) configure -state disable
$widget(TitleFrame223_3) configure -text ""
$widget(Entry223_3) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_3) configure -state disable 
$widget(TitleFrame223_4) configure -state disable
$widget(TitleFrame223_4) configure -text ""
$widget(Entry223_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_4) configure -state disable 
$widget(TitleFrame223_5) configure -state disable
$widget(TitleFrame223_5) configure -text ""
$widget(Entry223_5) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_5) configure -state disable 
$widget(TitleFrame223_6) configure -state disable
$widget(TitleFrame223_6) configure -text ""
$widget(Entry223_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_6) configure -state disable 
$widget(TitleFrame223_7) configure -state disable
$widget(TitleFrame223_7) configure -text ""
$widget(Entry223_7) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_7) configure -state disable 
$widget(TitleFrame223_8) configure -state disable
$widget(TitleFrame223_8) configure -text ""
$widget(Entry223_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_8) configure -state disable 

$widget(Button223_9) configure -state disable 
$widget(Menubutton223_1) configure -state disable 
$widget(Label223_1) configure -state disable; $widget(Entry223_1) configure -state disable  
$widget(Label223_2) configure -state disable; $widget(Entry223_2) configure -state disable  
$widget(Checkbutton223_1) configure -state disable; set IEEEFormat 0 

if {$AIRSARDataFormat == "MLC"} {
    $widget(TitleFrame223_3) configure -state normal
    $widget(TitleFrame223_3) configure -text "AIRSAR Input Data File : CM####_c / l / p.dat "
    $widget(Entry223_3) configure -disabledbackground #FFFFFF
    $widget(Button223_3) configure -state normal
    }
if {$AIRSARDataFormat == "SLC"} {
    $widget(TitleFrame223_4) configure -state normal
    $widget(TitleFrame223_4) configure -text "AIRSAR Input Data File : CM####_c / l / p.hh "
    $widget(Entry223_4) configure -disabledbackground #FFFFFF
    $widget(Button223_4) configure -state normal
    $widget(TitleFrame223_5) configure -state normal
    $widget(TitleFrame223_5) configure -text "AIRSAR Input Data File : CM####_c / l / p.hv "
    $widget(Entry223_5) configure -disabledbackground #FFFFFF
    $widget(Button223_5) configure -state normal
    $widget(TitleFrame223_6) configure -state normal
    $widget(TitleFrame223_6) configure -text "AIRSAR Input Data File : CM####_c / l / p.vh "
    $widget(Entry223_6) configure -disabledbackground #FFFFFF
    $widget(Button223_6) configure -state normal
    $widget(TitleFrame223_7) configure -state normal
    $widget(TitleFrame223_7) configure -text "AIRSAR Input Data File : CM####_c / l / p.vv "
    $widget(Entry223_7) configure -disabledbackground #FFFFFF
    $widget(Button223_7) configure -state normal
    $widget(Checkbutton223_1) configure -state normal
    }} \
        -text {v5.01 and more ( since 1993 )} -value new \
        -variable AIRSARProcessor 
    vTcl:DefineAlias "$site_4_0.cpd88" "Radiobutton6" vTcl:WidgetProc "Toplevel223" 1
    radiobutton $site_4_0.cpd89 \
        \
        -command {global AIRSARDataFormat IEEEFormat
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3 FileInputSTK4 FileInputSTK5

set FileInputSTK1 ""; set FileInputSTK2 ""; set FileInputSTK3 ""; set FileInputSTK4 ""; set FileInputSTK5 ""; set FileInputSTK ""

$widget(TitleFrame223_2) configure -state normal
$widget(Radiobutton223_1) configure -state disable
$widget(Radiobutton223_2) configure -state normal

$widget(TitleFrame223_3) configure -state disable
$widget(TitleFrame223_3) configure -text ""
$widget(Entry223_3) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_3) configure -state disable 
$widget(TitleFrame223_4) configure -state disable
$widget(TitleFrame223_4) configure -text ""
$widget(Entry223_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_4) configure -state disable 
$widget(TitleFrame223_5) configure -state disable
$widget(TitleFrame223_5) configure -text ""
$widget(Entry223_5) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_5) configure -state disable 
$widget(TitleFrame223_6) configure -state disable
$widget(TitleFrame223_6) configure -text ""
$widget(Entry223_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_6) configure -state disable 
$widget(TitleFrame223_7) configure -state disable
$widget(TitleFrame223_7) configure -text ""
$widget(Entry223_7) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_7) configure -state disable 
$widget(TitleFrame223_8) configure -state disable
$widget(TitleFrame223_8) configure -text ""
$widget(Entry223_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_8) configure -state disable 

$widget(Button223_9) configure -state disable 
$widget(Menubutton223_1) configure -state disable 
$widget(Label223_1) configure -state disable; $widget(Entry223_1) configure -state disable  
$widget(Label223_2) configure -state disable; $widget(Entry223_2) configure -state disable  
$widget(Checkbutton223_1) configure -state disable; set IEEEFormat 0 

set AIRSARDataFormat "MLC"

$widget(TitleFrame223_3) configure -state normal
$widget(TitleFrame223_3) configure -text "TOPSAR Input Data File : L-Band Stokes Matrix MLC ( TS####_l.datgr )"
$widget(Entry223_3) configure -disabledbackground #FFFFFF
$widget(Button223_3) configure -state normal
$widget(TitleFrame223_4) configure -state normal
$widget(TitleFrame223_4) configure -text "TOPSAR Input Data File : C-Band VV  ( TS####_c.vvi2 )"
$widget(Entry223_4) configure -disabledbackground #FFFFFF
$widget(Button223_4) configure -state normal
$widget(TitleFrame223_5) configure -state normal
$widget(TitleFrame223_5) configure -text "TOPSAR Input Data File : C-Band DEM ( TS####.demi2 )"
$widget(Entry223_5) configure -disabledbackground #FFFFFF
$widget(Button223_5) configure -state normal
$widget(TitleFrame223_6) configure -state normal
$widget(TitleFrame223_6) configure -text "TOPSAR Input Data File : Correlation Coeff Map ( TS####.corgr )"
$widget(Entry223_6) configure -disabledbackground #FFFFFF
$widget(Button223_6) configure -state normal
$widget(TitleFrame223_7) configure -state normal
$widget(TitleFrame223_7) configure -text "TOPSAR Input Data File : Local Incidence Angle ( TS####.incgr )"
$widget(Entry223_7) configure -disabledbackground #FFFFFF
$widget(Button223_7) configure -state normal
$widget(TitleFrame223_8) configure -state normal
$widget(TitleFrame223_8) configure -text "TOPSAR Input Data File : P-Band Stokes Matrix MLC ( TS####_p.datgr )"
$widget(Entry223_8) configure -disabledbackground #FFFFFF
$widget(Button223_8) configure -state normal} \
        -text TOPSAR -value TOPSAR -variable AIRSARProcessor 
    vTcl:DefineAlias "$site_4_0.cpd89" "Radiobutton9" vTcl:WidgetProc "Toplevel223" 1
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd77 \
        -ipad 0 -text {AIRSAR Compressed Stokes Data Format} 
    vTcl:DefineAlias "$top.cpd77" "TitleFrame223_2" vTcl:WidgetProc "Toplevel223" 1
    bind $top.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd77 getframe]
    frame $site_4_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra73" "Frame6" vTcl:WidgetProc "Toplevel223" 1
    set site_5_0 $site_4_0.fra73
    radiobutton $site_5_0.cpd74 \
        \
        -command {global AIRSARProcessor IEEEFormat
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3 FileInputSTK4 FileInputSTK5

set FileInputSTK1 ""; set FileInputSTK2 ""; set FileInputSTK3 ""; set FileInputSTK4 ""; set FileInputSTK5 ""; set FileInputSTK ""

$widget(TitleFrame223_3) configure -state disable
$widget(TitleFrame223_3) configure -text ""
$widget(Entry223_3) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_3) configure -state disable 
$widget(TitleFrame223_4) configure -state disable
$widget(TitleFrame223_4) configure -text ""
$widget(Entry223_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_4) configure -state disable 
$widget(TitleFrame223_5) configure -state disable
$widget(TitleFrame223_5) configure -text ""
$widget(Entry223_5) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_5) configure -state disable 
$widget(TitleFrame223_6) configure -state disable
$widget(TitleFrame223_6) configure -text ""
$widget(Entry223_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_6) configure -state disable 
$widget(TitleFrame223_7) configure -state disable
$widget(TitleFrame223_7) configure -text ""
$widget(Entry223_7) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_7) configure -state disable 
$widget(TitleFrame223_8) configure -state disable
$widget(TitleFrame223_8) configure -text ""
$widget(Entry223_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_8) configure -state disable 

$widget(Button223_9) configure -state disable 
$widget(Menubutton223_1) configure -state disable 
$widget(Label223_1) configure -state disable; $widget(Entry223_1) configure -state disable  
$widget(Label223_2) configure -state disable; $widget(Entry223_2) configure -state disable  
$widget(Checkbutton223_1) configure -state disable; set IEEEFormat 0 

if {$AIRSARProcessor == "old"} {
    $widget(TitleFrame223_3) configure -state normal
    $widget(TitleFrame223_3) configure -text "AIRSAR STK or CM####_c / l / p.dat Input Data File"
    $widget(Entry223_3) configure -disabledbackground #FFFFFF
    $widget(Button223_3) configure -state normal
    }
if {$AIRSARProcessor == "new"} {
    $widget(TitleFrame223_4) configure -state normal
    $widget(TitleFrame223_4) configure -text "AIRSAR Input Data File : CM####_c / l / p.hh "
    $widget(Entry223_4) configure -disabledbackground #FFFFFF
    $widget(Button223_4) configure -state normal
    $widget(TitleFrame223_5) configure -state normal
    $widget(TitleFrame223_5) configure -text "AIRSAR Input Data File : CM####_c / l / p.hv "
    $widget(Entry223_5) configure -disabledbackground #FFFFFF
    $widget(Button223_5) configure -state normal
    $widget(TitleFrame223_6) configure -state normal
    $widget(TitleFrame223_6) configure -text "AIRSAR Input Data File : CM####_c / l / p.vh "
    $widget(Entry223_6) configure -disabledbackground #FFFFFF
    $widget(Button223_6) configure -state normal
    $widget(TitleFrame223_7) configure -state normal
    $widget(TitleFrame223_7) configure -text "AIRSAR Input Data File : CM####_c / l / p.vv "
    $widget(Entry223_7) configure -disabledbackground #FFFFFF
    $widget(Button223_7) configure -state normal
    $widget(Checkbutton223_1) configure -state normal
    }} \
        -text {Single Look Complex ( SLC )} -value SLC \
        -variable AIRSARDataFormat 
    vTcl:DefineAlias "$site_5_0.cpd74" "Radiobutton223_1" vTcl:WidgetProc "Toplevel223" 1
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame7" vTcl:WidgetProc "Toplevel223" 1
    set site_5_0 $site_4_0.cpd76
    radiobutton $site_5_0.cpd75 \
        \
        -command {global AIRSARProcessor IEEEFormat
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3 FileInputSTK4 FileInputSTK5

set FileInputSTK1 ""; set FileInputSTK2 ""; set FileInputSTK3 ""; set FileInputSTK4 ""; set FileInputSTK5 ""; set FileInputSTK ""

$widget(TitleFrame223_3) configure -state disable
$widget(TitleFrame223_3) configure -text ""
$widget(Entry223_3) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_3) configure -state disable 
$widget(TitleFrame223_4) configure -state disable
$widget(TitleFrame223_4) configure -text ""
$widget(Entry223_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_4) configure -state disable 
$widget(TitleFrame223_5) configure -state disable
$widget(TitleFrame223_5) configure -text ""
$widget(Entry223_5) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_5) configure -state disable 
$widget(TitleFrame223_6) configure -state disable
$widget(TitleFrame223_6) configure -text ""
$widget(Entry223_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_6) configure -state disable 
$widget(TitleFrame223_7) configure -state disable
$widget(TitleFrame223_7) configure -text ""
$widget(Entry223_7) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_7) configure -state disable 
$widget(TitleFrame223_8) configure -state disable
$widget(TitleFrame223_8) configure -text ""
$widget(Entry223_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button223_8) configure -state disable 

$widget(Button223_9) configure -state disable 
$widget(Menubutton223_1) configure -state disable 
$widget(Label223_1) configure -state disable; $widget(Entry223_1) configure -state disable  
$widget(Label223_2) configure -state disable; $widget(Entry223_2) configure -state disable  
$widget(Checkbutton223_1) configure -state disable; set IEEEFormat 0 

if {$AIRSARProcessor == "old"} {
    $widget(TitleFrame223_3) configure -state normal
    $widget(TitleFrame223_3) configure -text "AIRSAR STK or CM####_c / l / p.dat Input Data File"
    $widget(Entry223_3) configure -disabledbackground #FFFFFF
    $widget(Button223_3) configure -state normal
    }
if {$AIRSARProcessor == "new"} {
    $widget(TitleFrame223_3) configure -state normal
    $widget(TitleFrame223_3) configure -text "AIRSAR Input Data File : CM####_c / l / p.dat "
    $widget(Entry223_3) configure -disabledbackground #FFFFFF
    $widget(Button223_3) configure -state normal
    }
if {$AIRSARProcessor == "TOPSAR"} {
    $widget(TitleFrame223_3) configure -state normal
    $widget(TitleFrame223_3) configure -text "TOPSAR Input Data File : L-Band Stokes Matrix MLC ( TS####_l.datgr )"
    $widget(Entry223_3) configure -disabledbackground #FFFFFF
    $widget(Button223_3) configure -state normal
    $widget(TitleFrame223_4) configure -state normal
    $widget(TitleFrame223_4) configure -text "TOPSAR Input Data File : C-Band VV  ( TS####_c.vvi2 )"
    $widget(Entry223_4) configure -disabledbackground #FFFFFF
    $widget(Button223_4) configure -state normal
    $widget(TitleFrame223_5) configure -state normal
    $widget(TitleFrame223_5) configure -text "TOPSAR Input Data File : C-Band DEM ( TS####.demi2 )"
    $widget(Entry223_5) configure -disabledbackground #FFFFFF
    $widget(Button223_5) configure -state normal
    $widget(TitleFrame223_6) configure -state normal
    $widget(TitleFrame223_6) configure -text "TOPSAR Input Data File : Correlation Coeff Map ( TS####.corgr )"
    $widget(Entry223_6) configure -disabledbackground #FFFFFF
    $widget(Button223_6) configure -state normal
    $widget(TitleFrame223_7) configure -state normal
    $widget(TitleFrame223_7) configure -text "TOPSAR Input Data File : Local Incidence Angle ( TS####.incgr )"
    $widget(Entry223_7) configure -disabledbackground #FFFFFF
    $widget(Button223_7) configure -state normal
    $widget(TitleFrame223_8) configure -state normal
    $widget(TitleFrame223_8) configure -text "TOPSAR Input Data File : P-Band Stokes Matrix MLC ( TS####_p.datgr )"
    $widget(Entry223_8) configure -disabledbackground #FFFFFF
    $widget(Button223_8) configure -state normal
    }} \
        -text {Multi Look ( MLC )} -value MLC -variable AIRSARDataFormat 
    vTcl:DefineAlias "$site_5_0.cpd75" "Radiobutton223_2" vTcl:WidgetProc "Toplevel223" 1
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 20 -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 20 -side left 
    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame2" vTcl:WidgetProc "Toplevel223" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {AIRSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame223_3" vTcl:WidgetProc "Toplevel223" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputSTK 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry223_3" vTcl:WidgetProc "Toplevel223" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel223" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName AIRSARDirInput FileInputSTK
global AIRSARDataFormat AIRSARProcessor

$widget(Button223_9) configure -state normal

if {$AIRSARProcessor == "old"} {
    set types {
        {{STK Files}        {.stk}   }
        {{DAT Files}        {.dat}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "STK INPUT FILE"
    set FileInputSTK $FileName
    }
if {$AIRSARProcessor == "new"} {
    set types {
        {{DAT Files}        {.dat}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "CM####_c/l/p INPUT FILE"
    set FileInputSTK $FileName
    }
if {$AIRSARProcessor == "TOPSAR"} {
    set types {
        {{DATGR Files}        {.datgr}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "L-BAND STOKES MATRIX MLC INPUT FILE"
    set FileInputSTK $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button223_3" vTcl:WidgetProc "Toplevel223" 1
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
        -ipad 0 -text {AIRSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd80" "TitleFrame223_4" vTcl:WidgetProc "Toplevel223" 1
    bind $site_3_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputSTK1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry223_4" vTcl:WidgetProc "Toplevel223" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame15" vTcl:WidgetProc "Toplevel223" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName AIRSARDirInput FileInputSTK1
global AIRSARDataFormat AIRSARProcessor

$widget(Button223_9) configure -state normal

if {$AIRSARProcessor == "new"} {
    set types {
        {{HH Files}        {.hh}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "CM####_c/l/p INPUT FILE"
    set FileInputSTK1 $FileName
    }
if {$AIRSARProcessor == "TOPSAR"} {
    set types {
        {{VVI2 Files}        {.vvi2}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "C-BAND VV SIGMA0 (int2) INPUT FILE"
    set FileInputSTK1 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button223_4" vTcl:WidgetProc "Toplevel223" 1
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
        -ipad 0 -text {AIRSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd81" "TitleFrame223_5" vTcl:WidgetProc "Toplevel223" 1
    bind $site_3_0.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputSTK2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry223_5" vTcl:WidgetProc "Toplevel223" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel223" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName AIRSARDirInput FileInputSTK2
global AIRSARDataFormat AIRSARProcessor

$widget(Button223_9) configure -state normal

if {$AIRSARProcessor == "new"} {
    set types {
        {{HV Files}        {.hv}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "CM####_c/l/p INPUT FILE"
    set FileInputSTK2 $FileName
    }
if {$AIRSARProcessor == "TOPSAR"} {
    set types {
        {{DEMI2 Files}        {.demi2}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "C-band DEM (int2) INPUT FILE"
    set FileInputSTK2 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button223_5" vTcl:WidgetProc "Toplevel223" 1
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
        -ipad 0 -text {AIRSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd82" "TitleFrame223_6" vTcl:WidgetProc "Toplevel223" 1
    bind $site_3_0.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd82 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputSTK3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry223_6" vTcl:WidgetProc "Toplevel223" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel223" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName AIRSARDirInput FileInputSTK3
global AIRSARDataFormat AIRSARProcessor

$widget(Button223_9) configure -state normal

if {$AIRSARProcessor == "new"} {
    set types {
        {{VH Files}        {.vh}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "CM####_c/l/p INPUT FILE"
    set FileInputSTK3 $FileName
    }
if {$AIRSARProcessor == "TOPSAR"} {
    set types {
        {{CORGR Files}        {.corgr}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "CORRELATION COEFF MAP INPUT FILE"
    set FileInputSTK3 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button223_6" vTcl:WidgetProc "Toplevel223" 1
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
        -ipad 0 -text {AIRSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd83" "TitleFrame223_7" vTcl:WidgetProc "Toplevel223" 1
    bind $site_3_0.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd83 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputSTK4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry223_7" vTcl:WidgetProc "Toplevel223" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel223" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName AIRSARDirInput FileInputSTK4
global AIRSARDataFormat AIRSARProcessor

$widget(Button223_9) configure -state normal

if {$AIRSARProcessor == "new"} {
    set types {
        {{VV Files}        {.vv}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "CM####_c/l/p INPUT FILE"
    set FileInputSTK4 $FileName
    }
if {$AIRSARProcessor == "TOPSAR"} {
    set types {
        {{INCGR Files}        {.incgr}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "LOCAL INCIDENCE ANGLE INPUT FILE"
    set FileInputSTK4 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button223_7" vTcl:WidgetProc "Toplevel223" 1
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
        -ipad 0 -text {AIRSAR Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd84" "TitleFrame223_8" vTcl:WidgetProc "Toplevel223" 1
    bind $site_3_0.cpd84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd84 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputSTK5 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry223_8" vTcl:WidgetProc "Toplevel223" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel223" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd91 \
        \
        -command {global FileName AIRSARDirInput FileInputSTK5
global AIRSARDataFormat AIRSARProcessor

$widget(Button223_9) configure -state normal

if {$AIRSARProcessor == "TOPSAR"} {
    set types {
        {{DATGR Files}        {.datgr}   }
        {{All Files}        *        }
        }
    set FileName ""
    OpenFile $AIRSARDirInput $types "P-BAND STOKES MATRIX MLC INPUT FILE"
    set FileInputSTK5 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button223_8" vTcl:WidgetProc "Toplevel223" 1
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
    frame $top.cpd85 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd85" "Frame21" vTcl:WidgetProc "Toplevel223" 1
    set site_3_0 $top.cpd85
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global AIRSARDirOutput AIRSARFileInputFlag
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3 FileInputSTK4 FileInputSTK5
global AirsarHeader AIRSARDataFormat AIRSARProcessor AIRSARGenFac
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPAirsarConfig TMPAirsarFstHeader TMPAirsarParHeader TMPAirsarCalHeader TMPAirsarDemHeader OpenDirFile

if {$OpenDirFile == 0} {

DeleteFile $TMPAirsarFstHeader
DeleteFile $TMPAirsarParHeader
DeleteFile $TMPAirsarCalHeader
DeleteFile $TMPAirsarDemHeader

set AIRSARFileInputFlag 0
set config "true"
if {$AIRSARProcessor == ""} {
    set ErrorMessage "ENTER THE AIRSAR PROCESSOR VERSION"
    set VarError ""
    Window show $widget(Toplevel44)
    set config "false"
    }
if {$AIRSARDataFormat == ""} {
    set ErrorMessage "ENTER THE AIRSAR INPUT DATA FORMAT"
    set VarError ""
    Window show $widget(Toplevel44)
    set config "false"
    }

if {$AIRSARProcessor == "old"} {
    if {$FileInputSTK == ""} {
        set ErrorMessage "ENTER THE AIRSAR DATA FILE NAME : STK or CM####_c / l / p.dat"
        set VarError ""
        Window show $widget(Toplevel44)
        set config "false"
        }
    }
    
if {$AIRSARProcessor == "new"} {
    if {$AIRSARDataFormat == "MLC"} {
        if {$FileInputSTK == ""} {
            set ErrorMessage "ENTER THE AIRSAR DATA FILE NAME : CM####_c / l / p.dat"
            set VarError ""
            Window show $widget(Toplevel44)
            set config "false"
            }
        } else {
        if {$FileInputSTK1 == ""} {
            set ErrorMessage "ENTER THE AIRSAR DATA FILE NAME : CM####_c / l / p.hh"
            set VarError ""
            Window show $widget(Toplevel44)
            set config "false"
            }
        if {$FileInputSTK2 == ""} {
            set ErrorMessage "ENTER THE AIRSAR DATA FILE NAME : CM####_c / l / p.hv"
            set VarError ""
            Window show $widget(Toplevel44)
            set config "false"
            }
        if {$FileInputSTK3 == ""} {
            set ErrorMessage "ENTER THE AIRSAR DATA FILE NAME : CM####_c / l / p.vh"
            set VarError ""
            Window show $widget(Toplevel44)
            set config "false"
            }
        if {$FileInputSTK4 == ""} {
            set ErrorMessage "ENTER THE AIRSAR DATA FILE NAME : CM####_c / l / p.vv"
            set VarError ""
            Window show $widget(Toplevel44)
            set config "false"
            }
        }
    }        

if {$AIRSARProcessor == "TOPSAR"} {
    if {$FileInputSTK == ""} {
        set ErrorMessage "ENTER THE AIRSAR DATA FILE NAME : TS####_l.datgr"
        set VarError ""
        Window show $widget(Toplevel44)
        set config "false"
        }
    }

if {$config == "true"} {  
    set AirsarFile ""
    if {$AIRSARProcessor == "old"} {set AirsarFile $FileInputSTK }
    if {$AIRSARProcessor == "new"} {
        if {$AIRSARDataFormat == "SLC"} {set AirsarFile $FileInputSTK1 }
        if {$AIRSARDataFormat == "MLC"} {set AirsarFile $FileInputSTK }
        }
    if {$AIRSARProcessor == "TOPSAR"} {set AirsarFile $FileInputSTK }
    TextEditorRunTrace "Process The Function Soft/bin/data_import/airsar_header.exe" "k"
    TextEditorRunTrace "Arguments: -idf \x22$AirsarFile\x22 -ocf \x22$TMPAirsarConfig\x22 -ohf \x22$TMPAirsarFstHeader\x22 -opf \x22$TMPAirsarParHeader\x22 -okf \x22$TMPAirsarCalHeader\x22 -odf \x22$TMPAirsarDemHeader\x22 -pro $AIRSARProcessor -df $AIRSARDataFormat" "k"
    set f [ open "| Soft/bin/data_import/airsar_header.exe -idf \x22$AirsarFile\x22 -ocf \x22$TMPAirsarConfig\x22 -ohf \x22$TMPAirsarFstHeader\x22 -opf \x22$TMPAirsarParHeader\x22 -okf \x22$TMPAirsarCalHeader\x22 -odf \x22$TMPAirsarDemHeader\x22 -pro $AIRSARProcessor -df $AIRSARDataFormat" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    
    set NligFullSize 0
    set NcolFullSize 0
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NligFullSizeInput 0
    set NcolFullSizeInput 0
    set ConfigFile $TMPAirsarConfig
    set ErrorMessage ""
    WaitUntilCreated $ConfigFile
    if [file exists $ConfigFile] {
        set f [open $ConfigFile r]
        gets $f tmp
        if {$tmp == "HEADER_OK"} {
            gets $f tmp
            gets $f NligFullSize
            gets $f tmp
            gets $f tmp
            gets $f NcolFullSize
            gets $f tmp
            gets $f tmp
            gets $f AIRSARGenFac
            close $f
            set AirsarHeader 1
            set AIRSARFileInputFlag 1
            set NligInit 1
            set NligEnd $NligFullSize
            set NcolInit 1
            set NcolEnd $NcolFullSize
            set NligFullSizeInput $NligFullSize
            set NcolFullSizeInput $NcolFullSize
            $widget(Menubutton223_1) configure -state normal
            $widget(Button223_10) configure -state normal
            set ErrorMessage ""
            set WarningMessage "DON'T FORGET TO EXTRACT DATA"
            set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
            set VarAdvice ""
            Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
            tkwait variable VarAdvice
            }
        if {$tmp == "HEADER_ERROR"} {
            gets $f tmp
            close $f
            if {$tmp == 1} {set ErrorMessage "HEADER CONFIGURATION ERROR : PROCESSOR VERSION"}
            if {$tmp == 2} {set ErrorMessage "HEADER CONFIGURATION ERROR : DATA FORMAT"}
            if {$tmp == 3} {set ErrorMessage "HEADER CONFIGURATION ERROR : PROCESSOR VERSION & DATA FORMAT"}
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set AirsarHeader 1; set AIRSARDataFormat ""; set AIRSARProcessor ""
            set FileInputSTK1 ""; set FileInputSTK2 ""; set FileInputSTK3 ""
            set FileInputSTK4 ""; set FileInputSTK5 ""; set FileInputSTK ""
            $widget(Menubutton223_1) configure -state disable; $widget(Button223_9) configure -state disable; $widget(Button223_10) configure -state disable
            $widget(TitleFrame223_2) configure -state disable; $widget(Radiobutton223_1) configure -state disable; $widget(Radiobutton223_2) configure -state disable        
            $widget(TitleFrame223_3) configure -state disable; $widget(TitleFrame223_3) configure -text ""
            $widget(Entry223_3) configure -disabledbackground $PSPBackgroundColor; $widget(Button223_3) configure -state disable 
            $widget(TitleFrame223_4) configure -state disable; $widget(TitleFrame223_4) configure -text ""
            $widget(Entry223_4) configure -disabledbackground $PSPBackgroundColor; $widget(Button223_4) configure -state disable 
            $widget(TitleFrame223_5) configure -state disable; $widget(TitleFrame223_5) configure -text ""
            $widget(Entry223_5) configure -disabledbackground $PSPBackgroundColor; $widget(Button223_5) configure -state disable 
            $widget(TitleFrame223_6) configure -state disable; $widget(TitleFrame223_6) configure -text ""
            $widget(Entry223_6) configure -disabledbackground $PSPBackgroundColor; $widget(Button223_6) configure -state disable 
            $widget(TitleFrame223_7) configure -state disable; $widget(TitleFrame223_7) configure -text ""
            $widget(Entry223_7) configure -disabledbackground $PSPBackgroundColor; $widget(Button223_7) configure -state disable 
            $widget(TitleFrame223_8) configure -state disable; $widget(TitleFrame223_8) configure -text ""
            $widget(Entry223_8) configure -disabledbackground $PSPBackgroundColor; $widget(Button223_8) configure -state disable 
            $widget(Label223_1) configure -state disable; $widget(Entry223_1) configure -state disable  
            $widget(Label223_2) configure -state disable; $widget(Entry223_2) configure -state disable  
            $widget(Checkbutton223_1) configure -state disable; set IEEEFormat 0 
            }            
        if {$tmp == "NO_HEADER"} {
            close $f
            set AirsarHeader 0
            $widget(Label223_1) configure -state normal; $widget(Entry223_1) configure -state normal  
            $widget(Label223_2) configure -state normal; $widget(Entry223_2) configure -state normal  
            $widget(Button223_10) configure -state normal
            set NligFullSize "?"
            set NcolFullSize "?"
            set NligInit "?"
            set NligEnd "?"
            set NcolInit "?"
            set NcolEnd "?"
            set ErrorMessage ""
            set WarningMessage "AIRSAR INPUT DATA FILE HAS NO HEADER"
            set WarningMessage2 "ENTER THE NUMBER OF ROWS / COLUMNS"
            set VarAdvice ""
            Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
            tkwait variable VarAdvice
            }
        }
    }
}} \
        -cursor {} -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_3_0.but93" "Button223_9" vTcl:WidgetProc "Toplevel223" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    menubutton $site_3_0.men90 \
        -background #ffff00 -menu "$site_3_0.men90.m" -padx 5 -pady 4 \
        -relief raised -text {Edit Header} 
    vTcl:DefineAlias "$site_3_0.men90" "Menubutton223_1" vTcl:WidgetProc "Toplevel223" 1
    menu $site_3_0.men90.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage
global TMPAirsarFstHeader PSPTopLevel
#UTIL
global Load_TextEdit
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

if [file exists $TMPAirsarFstHeader] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top223 $TMPAirsarFstHeader
    }} \
        -label Header 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage
global TMPAirsarParHeader
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

if [file exists $TMPAirsarParHeader] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top223 $TMPAirsarParHeader
    }} \
        -label Parameter 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage
global TMPAirsarCalHeader
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

if [file exists $TMPAirsarCalHeader] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top223 $TMPAirsarCalHeader
    }} \
        -label Calibration 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage
global TMPAirsarDemHeader
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

if [file exists $TMPAirsarDemHeader] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top223 $TMPAirsarDemHeader
    }} \
        -label D.E.M 
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.men90 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra57 \
        -borderwidth 2 -relief groove -height 76 -width 200 
    vTcl:DefineAlias "$top.fra57" "Frame" vTcl:WidgetProc "Toplevel223" 1
    set site_3_0 $top.fra57
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame107" vTcl:WidgetProc "Toplevel223" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label223_1" vTcl:WidgetProc "Toplevel223" 1
    entry $site_4_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent41" "Entry223_1" vTcl:WidgetProc "Toplevel223" 1
    label $site_4_0.lab42 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_4_0.lab42" "Label223_2" vTcl:WidgetProc "Toplevel223" 1
    entry $site_4_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent43" "Entry223_2" vTcl:WidgetProc "Toplevel223" 1
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
    checkbutton $top.che71 \
        -text {Convert Input IEEE binary Format (LE<->BE)} \
        -variable IEEEFormat 
    vTcl:DefineAlias "$top.che71" "Checkbutton223_1" vTcl:WidgetProc "Toplevel223" 1
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel223" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile AirsarHeader TMPAirsarConfig AIRSARFileInputFlag
global VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {$AirsarHeader == 0} {  
    set TestVarName(0) "Initial Number of Rows"; set TestVarType(0) "int"; set TestVarValue(0) $NligFullSize; set TestVarMin(0) "0"; set TestVarMax(0) ""
    set TestVarName(1) "Initial Number of Cols"; set TestVarType(1) "int"; set TestVarValue(1) $NcolFullSize; set TestVarMin(1) "0"; set TestVarMax(1) ""
    TestVar 2
    if {$TestVarError == "ok"} {
        set AIRSARFileInputFlag 1
        set NligInit 1
        set NligEnd $NligFullSize
        set NcolInit 1
        set NcolEnd $NcolFullSize
        set NligFullSizeInput $NligFullSize
        set NcolFullSizeInput $NcolFullSize
        DeleteFile  $TMPAirsarConfig
        set f [open $TMPAirsarConfig w]
        puts $f "NO_HEADER"
        puts $f "nlig"
        puts $f $NligFullSize
        puts $f "---------"
        puts $f "ncol"
        puts $f $NcolFullSize
        puts $f "---------"
        puts $f "gen_fac"
        puts $f "0"
        puts $f "---------"
        puts $f "Offset_Data"
        puts $f "0"
        close $f
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel223); TextEditorRunTrace "Close Window AIRSAR Input File" "b"
        } else {
        set ErrorMessage "ENTER THE NUMBER OF ROWS / COLUMNS"
        set VarError ""
        Window show $widget(Toplevel44)
        } 
    } else {
    Window hide $widget(Toplevel223); TextEditorRunTrace "Close Window AIRSAR Input File" "b"
    }
}} \
        -cursor {} -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button223_10" vTcl:WidgetProc "Toplevel223" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {global AIRSARProcessor
    if {$AIRSARProcessor == "TOPSAR"} {
        HelpPdfEdit "Help/TOPSAR_Input_File.pdf"
        } else {
        HelpPdfEdit "Help/AIRSAR_Input_File.pdf" }} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel223" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel223); TextEditorRunTrace "Close Window AIRSAR Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel223" 1
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
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd85 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra57 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.che71 \
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
Window show .top223

main $argc $argv
