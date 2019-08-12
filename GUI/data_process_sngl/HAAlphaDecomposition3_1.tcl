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
    set base .top320
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
    namespace eval ::widgets::$base.fra45 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra45
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra46 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra46
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra47 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra47
    namespace eval ::widgets::$site_3_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che39 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
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
    namespace eval ::widgets::$base.fra109 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra109
    namespace eval ::widgets::$site_3_0.che110 {
        array set save {-command 1 -state 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra111 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra111
    namespace eval ::widgets::$site_4_0.che112 {
        array set save {-anchor 1 -command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.che113 {
        array set save {-anchor 1 -command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra117 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra117
    namespace eval ::widgets::$site_4_0.che114 {
        array set save {-anchor 1 -command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.che115 {
        array set save {-anchor 1 -command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che116 {
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
    namespace eval ::widgets::$site_3_0.cpd86 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd86
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd89 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd89
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
    namespace eval ::widgets::$site_4_0.che75 {
        array set save {-text 1 -variable 1}
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
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top320
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

proc vTclWindow.top320 {base} {
    if {$base == ""} {
        set base .top320
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
    wm geometry $top 500x420+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: H / A / Alpha Decomposition Parameters"
    vTcl:DefineAlias "$top" "Toplevel320" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd86 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd86" "Frame4" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.cpd86
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel320" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HAAlpDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel320" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel320" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel320" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel320" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable HAAlpOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel320" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel320" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd81 \
        -padx 1 -text / 
    vTcl:DefineAlias "$site_6_0.cpd81" "Label14" vTcl:WidgetProc "Toplevel320" 1
    entry $site_6_0.cpd80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable HAAlpOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd80" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel320" 1
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side left 
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame17" vTcl:WidgetProc "Toplevel320" 1
    set site_6_0 $site_5_0.cpd79
    button $site_6_0.cpd87 \
        \
        -command {global DirName DataDir HAAlpOutputDir

set HAAlpDirOutputTmp $HAAlpOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set HAAlpOutputDir $DirName
    } else {
    set HAAlpOutputDir $HAAlpDirOutputTmp
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
    vTcl:DefineAlias "$top.fra36" "Frame9" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.fra36
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel320" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel320" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel320" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel320" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel320" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel320" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel320" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel320" 1
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
    frame $top.fra45 \
        -borderwidth 2 -relief groove -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra45" "Frame39" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.fra45
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$alpbetdelgam"=="1"} {
    $widget(Checkbutton320_1) configure -state normal
    } else {
    $widget(Checkbutton320_1) configure -state disable
    set BMPalpbetdelgam "0"
    }} \
        -padx 1 -text {Alpha, Beta, Delta, Gamma, Lambda} \
        -variable alpbetdelgam 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton21" vTcl:WidgetProc "Toplevel320" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPalpbetdelgam 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton320_1" vTcl:WidgetProc "Toplevel320" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.cpd72 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame44" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.cpd72
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$lambda"=="1"} {
    $widget(Checkbutton320_2) configure -state normal
    } else {
    $widget(Checkbutton320_2) configure -state disable
    set BMPlambda "0"
    }} \
        -padx 1 -text Lambda -variable lambda 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton24" vTcl:WidgetProc "Toplevel320" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPlambda 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton320_2" vTcl:WidgetProc "Toplevel320" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra46 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra46" "Frame40" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.fra46
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$alpha"=="1"} {
    $widget(Checkbutton320_3) configure -state normal
    } else {
    $widget(Checkbutton320_3) configure -state disable
    set BMPalpha "0"
    }} \
        -padx 1 -text Alpha -variable alpha 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton23" vTcl:WidgetProc "Toplevel320" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPalpha 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton320_3" vTcl:WidgetProc "Toplevel320" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra47 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra47" "Frame41" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.fra47
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$entropy"=="1"} {
    $widget(Checkbutton320_4) configure -state normal
    } else {
    $widget(Checkbutton320_4) configure -state disable
    set BMPentropy "0"
    }} \
        -padx 1 -text {Entropy ( H )} -variable entropy 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton25" vTcl:WidgetProc "Toplevel320" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPentropy 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton320_4" vTcl:WidgetProc "Toplevel320" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra48 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra48" "Frame42" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.fra48
    checkbutton $site_3_0.che38 \
        \
        -command {if {"$anisotropy"=="1"} {
    $widget(Checkbutton320_5) configure -state normal
    } else {
    $widget(Checkbutton320_5) configure -state disable
    set BMPanisotropy "0"
    }} \
        -padx 1 -text {Anisotropy  ( A )} -variable anisotropy 
    vTcl:DefineAlias "$site_3_0.che38" "Checkbutton27" vTcl:WidgetProc "Toplevel320" 1
    checkbutton $site_3_0.che39 \
        -command {} -padx 1 -text BMP -variable BMPanisotropy 
    vTcl:DefineAlias "$site_3_0.che39" "Checkbutton320_5" vTcl:WidgetProc "Toplevel320" 1
    pack $site_3_0.che38 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.che39 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra109 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra109" "Frame660" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.fra109
    checkbutton $site_3_0.che110 \
        \
        -command {global combinationsHA CombHA CombH1mA Comb1mHA Comb1mH1mA

if {$combinationsHA == "1"} {
    $widget(Checkbutton320_6) configure -state normal
    $widget(Checkbutton320_7) configure -state normal
    $widget(Checkbutton320_8) configure -state normal
    $widget(Checkbutton320_9) configure -state normal
    }
if {$combinationsHA == "0"} {
    set CombHA "0"
    set CombH1mA "0"
    set Comb1mHA "0"
    set Comb1mH1mA "0"
    set BMPcombinationsHA "0"
    $widget(Checkbutton320_6) configure -state disable
    $widget(Checkbutton320_7) configure -state disable
    $widget(Checkbutton320_8) configure -state disable
    $widget(Checkbutton320_9) configure -state disable
    $widget(Checkbutton320_10) configure -state disable
    }} \
        -state normal -text {Combinations ( H , A )} -variable combinationsHA 
    vTcl:DefineAlias "$site_3_0.che110" "Checkbutton617" vTcl:WidgetProc "Toplevel320" 1
    frame $site_3_0.fra111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra111" "Frame661" vTcl:WidgetProc "Toplevel320" 1
    set site_4_0 $site_3_0.fra111
    checkbutton $site_4_0.che112 \
        -anchor center \
        -command {global CombHA CombH1mA Comb1mHA Comb1mH1mA 

if {$CombHA == "1"} {
    $widget(Checkbutton320_10) configure -state normal
    } else {
    set config "0"
    if {$CombHA == "1"} {incr config}
    if {$CombH1mA == "1"} {incr config}
    if {$Comb1mHA == "1"} {incr config}
    if {$Comb1mH1mA == "1"} {incr config}
    if {$config == "0"} {
        set BMPcombinationsHA "0"
        $widget(Checkbutton320_10) configure -state disable
        }
    }} \
        -padx 1 -text {H A} -variable CombHA 
    vTcl:DefineAlias "$site_4_0.che112" "Checkbutton320_6" vTcl:WidgetProc "Toplevel320" 1
    checkbutton $site_4_0.che113 \
        -anchor center \
        -command {global CombHA CombH1mA Comb1mHA Comb1mH1mA 

if {$CombH1mA == "1"} {
    $widget(Checkbutton320_10) configure -state normal
    } else {
    set config "0"
    if {$CombHA == "1"} {incr config}
    if {$CombH1mA == "1"} {incr config}
    if {$Comb1mHA == "1"} {incr config}
    if {$Comb1mH1mA == "1"} {incr config}
    if {$config == "0"} {
        set BMPcombinationsHA "0"
        $widget(Checkbutton320_10) configure -state disable
        }
    }} \
        -padx 1 -text {H (1 - A)} -variable CombH1mA 
    vTcl:DefineAlias "$site_4_0.che113" "Checkbutton320_7" vTcl:WidgetProc "Toplevel320" 1
    pack $site_4_0.che112 \
        -in $site_4_0 -anchor w -expand 1 -fill none -side top 
    pack $site_4_0.che113 \
        -in $site_4_0 -anchor w -expand 1 -fill none -side top 
    frame $site_3_0.fra117 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra117" "Frame662" vTcl:WidgetProc "Toplevel320" 1
    set site_4_0 $site_3_0.fra117
    checkbutton $site_4_0.che114 \
        -anchor center \
        -command {global CombHA CombH1mA Comb1mHA Comb1mH1mA 

if {$Comb1mHA == "1"} {
    $widget(Checkbutton320_10) configure -state normal
    } else {
    set config "0"
    if {$CombHA == "1"} {incr config}
    if {$CombH1mA == "1"} {incr config}
    if {$Comb1mHA == "1"} {incr config}
    if {$Comb1mH1mA == "1"} {incr config}
    if {$config == "0"} {
        set BMPcombinationsHA "0"
        $widget(Checkbutton320_10) configure -state disable
        }
    }} \
        -text {(1 - H) A} -variable Comb1mHA 
    vTcl:DefineAlias "$site_4_0.che114" "Checkbutton320_8" vTcl:WidgetProc "Toplevel320" 1
    checkbutton $site_4_0.che115 \
        -anchor center \
        -command {global CombHA CombH1mA Comb1mHA Comb1mH1mA 

if {$Comb1mH1mA == "1"} {
    $widget(Checkbutton320_10) configure -state normal
    } else {
    set config "0"
    if {$CombHA == "1"} {incr config}
    if {$CombH1mA == "1"} {incr config}
    if {$Comb1mHA == "1"} {incr config}
    if {$Comb1mH1mA == "1"} {incr config}
    if {$config == "0"} {
        set BMPcombinationsHA "0"
        $widget(Checkbutton320_10) configure -state disable
        }
    }} \
        -text {(1 - H) (1 - A)} -variable Comb1mH1mA 
    vTcl:DefineAlias "$site_4_0.che115" "Checkbutton320_9" vTcl:WidgetProc "Toplevel320" 1
    pack $site_4_0.che114 \
        -in $site_4_0 -anchor w -expand 1 -fill none -side top 
    pack $site_4_0.che115 \
        -in $site_4_0 -anchor w -expand 1 -fill none -side top 
    checkbutton $site_3_0.che116 \
        -padx 1 -text BMP -variable BMPcombinationsHA 
    vTcl:DefineAlias "$site_3_0.che116" "Checkbutton320_10" vTcl:WidgetProc "Toplevel320" 1
    pack $site_3_0.che110 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_3_0.fra111 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra117 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che116 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra55 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra55" "Frame47" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.fra55
    frame $site_3_0.fra24 \
        -borderwidth 2 -cursor {} -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame48" vTcl:WidgetProc "Toplevel320" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -padx 1 -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label320" vTcl:WidgetProc "Toplevel320" 1
    entry $site_4_0.ent58 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinHAAlpC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry22" vTcl:WidgetProc "Toplevel320" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd86 \
        -borderwidth 2 -cursor {} -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd86" "Frame49" vTcl:WidgetProc "Toplevel320" 1
    set site_4_0 $site_3_0.cpd86
    label $site_4_0.lab57 \
        -padx 1 -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label321" vTcl:WidgetProc "Toplevel320" 1
    entry $site_4_0.ent58 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinHAAlpL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry23" vTcl:WidgetProc "Toplevel320" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {set NwinHAAlpL "?"; set NwinHAAlpC "?"
set alpbetdelgam "1"
set lambda "1"
set alpha "1"
set entropy "1"
set anisotropy "1"
set combinationsHA "1"
set CombHA "1"
set CombH1mA "1"
set Comb1mHA "1"
set Comb1mH1mA "1"
set BMPalpbetdelgam "1"
set BMPlambda "1"
set BMPalpha "1"
set BMPentropy "1"
set BMPanisotropy "1"
set BMPcombinationsHA "1"
$widget(Checkbutton320_1) configure -state normal
$widget(Checkbutton320_2) configure -state normal
$widget(Checkbutton320_3) configure -state normal
$widget(Checkbutton320_4) configure -state normal
$widget(Checkbutton320_5) configure -state normal
$widget(Checkbutton320_6) configure -state normal
$widget(Checkbutton320_7) configure -state normal
$widget(Checkbutton320_8) configure -state normal
$widget(Checkbutton320_9) configure -state normal
$widget(Checkbutton320_10) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel320" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.cpd66 \
        -background #ffff00 \
        -command {set NwinHAAlpL "?"; set NwinHAAlpC "?"
set alpbetdelgam "0"
set lambda "0"
set alpha "0"
set entropy "0"
set anisotropy "0"
set combinationsHA "0"
set CombHA "0"
set CombH1mA "0"
set Comb1mHA "0"
set Comb1mH1mA "0"
set BMPalpbetdelgam "0"
set BMPlambda "0"
set BMPalpha "0"
set BMPentropy "0"
set BMPanisotropy "0"
set BMPcombinationsHA "0"
$widget(Checkbutton320_1) configure -state disable
$widget(Checkbutton320_2) configure -state disable
$widget(Checkbutton320_3) configure -state disable
$widget(Checkbutton320_4) configure -state disable
$widget(Checkbutton320_5) configure -state disable
$widget(Checkbutton320_6) configure -state disable
$widget(Checkbutton320_7) configure -state disable
$widget(Checkbutton320_8) configure -state disable
$widget(Checkbutton320_9) configure -state disable
$widget(Checkbutton320_10) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd66" "Button104" vTcl:WidgetProc "Toplevel320" 1
    bindtags $site_3_0.cpd66 "$site_3_0.cpd66 Button $top all _vTclBalloon"
    bind $site_3_0.cpd66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 30 -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $top.cpd89 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd89" "Frame8" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.cpd89
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame10" vTcl:WidgetProc "Toplevel320" 1
    set site_4_0 $site_3_0.fra72
    checkbutton $site_4_0.che75 \
        -text {Equivalence between [ T ]  and  [ C ] eigen-decompositions. } \
        -variable EquivHAAlpDecomp 
    vTcl:DefineAlias "$site_4_0.che75" "Checkbutton320_11" vTcl:WidgetProc "Toplevel320" 1
    pack $site_4_0.che75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel320" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global HAAlpDirInput HAAlpDirOutput HAAlpOutputDir HAAlpOutputSubDir
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2
global VarError ErrorMessage ProgressLine
global HAAlphaDecompositionFonction EquivHAAlpDecomp NwinHAAlpL NwinHAAlpC
global BMPDirInput OpenDirFile TMPMemoryAllocError

if {$OpenDirFile == 0} {

set config "false"
if {"$alpbetdelgam"=="1"} { set config "true" }
if {"$alpha"=="1"} { set config "true" }
if {"$lambda"=="1"} { set config "true" }
if {"$entropy"=="1"} { set config "true" }
if {"$anisotropy"=="1"} { set config "true" }
if {"$combinationsHA"=="1"} { set config "true" }

if {"$config"=="true"} {

    set HAAlpDirOutput $HAAlpOutputDir
    if {$HAAlpOutputSubDir != ""} {append HAAlpDirOutput "/$HAAlpOutputSubDir"}

    #####################################################################
    #Create Directory
    set HAAlpDirOutput [PSPCreateDirectoryMask $HAAlpDirOutput $HAAlpOutputDir $HAAlpDirInput]
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
        set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinHAAlpL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinHAAlpC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
        TestVar 6
        if {$TestVarError == "ok"} {
            set Fonction "Creation of all the Binary Data Files"
            set Fonction2 "of the H / A / Alpha Decomposition"
            set MaskCmd ""
            set MaskFile "$HAAlpDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set HAAlphaDecompositionF $HAAlphaDecompositionFonction
            if {"$HAAlphaDecompositionFonction" == "S2"} { set HAAlphaDecompositionF "S2T3" }
            if {"$HAAlphaDecompositionFonction" == "C3"} {
                if {$EquivHAAlpDecomp == "1"} { set HAAlphaDecompositionF "C3T3" }
                }
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$HAAlpDirInput\x22 -od \x22$HAAlpDirOutput\x22 -iodf $HAAlphaDecompositionF -nwr $NwinHAAlpL -nwc $NwinHAAlpC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $alpbetdelgam -fl2 $lambda -fl3 $alpha -fl4 $entropy -fl5 $anisotropy -fl6 $CombHA -fl7 $CombH1mA -fl8 $Comb1mHA -fl9 $Comb1mH1mA  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe -id \x22$HAAlpDirInput\x22 -od \x22$HAAlpDirOutput\x22 -iodf $HAAlphaDecompositionF -nwr $NwinHAAlpL -nwc $NwinHAAlpC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $alpbetdelgam -fl2 $lambda -fl3 $alpha -fl4 $entropy -fl5 $anisotropy -fl6 $CombHA -fl7 $CombH1mA -fl8 $Comb1mHA -fl9 $Comb1mH1mA  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
    	  	TextEditorRunTrace "Check RunTime Errors" "r"
    	  	CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$alpbetdelgam"=="1"} {
                if [file exists "$HAAlpDirOutput/lambda.bin"] {EnviWriteConfig "$HAAlpDirOutput/lambda.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/alpha.bin"] {EnviWriteConfig "$HAAlpDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/beta.bin"] {EnviWriteConfig "$HAAlpDirOutput/beta.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/delta.bin"] {EnviWriteConfig "$HAAlpDirOutput/delta.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/gamma.bin"] {EnviWriteConfig "$HAAlpDirOutput/gamma.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$lambda"=="1"} {
                if [file exists "$HAAlpDirOutput/lambda.bin"] {EnviWriteConfig "$HAAlpDirOutput/lambda.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$alpha"=="1"} {
                if [file exists "$HAAlpDirOutput/alpha.bin"] {EnviWriteConfig "$HAAlpDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$entropy"=="1"} {
                if [file exists "$HAAlpDirOutput/entropy.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$anisotropy"=="1"} {
                if [file exists "$HAAlpDirOutput/anisotropy.bin"] {EnviWriteConfig "$HAAlpDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
                }
            if {"$combinationsHA"=="1"} {
                if [file exists "$HAAlpDirOutput/combination_HA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_HA.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/combination_H1mA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_H1mA.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/combination_1mHA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_1mHA.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$HAAlpDirOutput/combination_1mH1mA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_1mH1mA.bin" $FinalNlig $FinalNcol 4}
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
     
        if {"$BMPalpbetdelgam"=="1"} {
            if [file exists "$HAAlpDirOutput/alpha.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/alpha.bin"
                set BMPFileOutput "$HAAlpDirOutput/alpha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/beta.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/beta.bin"
                set BMPFileOutput "$HAAlpDirOutput/beta.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/delta.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/delta.bin"
                set BMPFileOutput "$HAAlpDirOutput/delta.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/gamma.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/gamma.bin"
                set BMPFileOutput "$HAAlpDirOutput/gamma.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$HAAlpDirOutput/lambda.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/lambda.bin"
                set BMPFileOutput "$HAAlpDirOutput/lambda_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
             
        if {"$BMPlambda"=="1"} {
            if [file exists "$HAAlpDirOutput/lambda.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/lambda.bin"
                set BMPFileOutput "$HAAlpDirOutput/lambda_db.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPalpha"=="1"} {
            if [file exists "$HAAlpDirOutput/alpha.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/alpha.bin"
                set BMPFileOutput "$HAAlpDirOutput/alpha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
             
        if {"$BMPentropy"=="1"} {
            if [file exists "$HAAlpDirOutput/entropy.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/entropy.bin"
                set BMPFileOutput "$HAAlpDirOutput/entropy.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
             
        if {"$BMPanisotropy"=="1"} {
            if [file exists "$HAAlpDirOutput/anisotropy.bin"] {
                set BMPDirInput $HAAlpDirOutput
                set BMPFileInput "$HAAlpDirOutput/anisotropy.bin"
                set BMPFileOutput "$HAAlpDirOutput/anisotropy.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$BMPcombinationsHA"=="1"} {
            if {$CombHA == 1} {
                if [file exists "$HAAlpDirOutput/combination_HA.bin"] {
                    set BMPDirInput $HAAlpDirOutput
                    set BMPFileInput "$HAAlpDirOutput/combination_HA.bin"
                    set BMPFileOutput "$HAAlpDirOutput/combination_HA.bmp"
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$CombH1mA == 1} {
                if [file exists "$HAAlpDirOutput/combination_H1mA.bin"] {
                    set BMPDirInput $HAAlpDirOutput
                    set BMPFileInput "$HAAlpDirOutput/combination_H1mA.bin"
                    set BMPFileOutput "$HAAlpDirOutput/combination_H1mA.bmp"
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$Comb1mHA == 1} {
                if [file exists "$HAAlpDirOutput/combination_1mHA.bin"] {
                    set BMPDirInput $HAAlpDirOutput
                    set BMPFileInput "$HAAlpDirOutput/combination_1mHA.bin"
                    set BMPFileOutput "$HAAlpDirOutput/combination_1mHA.bmp"
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$Comb1mH1mA == 1} {
                if [file exists "$HAAlpDirOutput/combination_1mH1mA.bin"] {
                    set BMPDirInput $HAAlpDirOutput
                    set BMPFileInput "$HAAlpDirOutput/combination_1mH1mA.bin"
                    set BMPFileOutput "$HAAlpDirOutput/combination_1mH1mA.bmp"
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            }
        }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel320); TextEditorRunTrace "Close Window H A Alpha Decomposition Parameters 3" "b"}
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel320" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/HAAlphaDecomposition3_1.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel320" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel320); TextEditorRunTrace "Close Window H A Alpha Decomposition Parameters 3" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel320" 1
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
    pack $top.cpd86 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra45 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra46 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra47 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra48 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra109 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra55 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd89 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -pady 5 -side top 

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
Window show .top320

main $argc $argv
