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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}

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
    set base .top378PP
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
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
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
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
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd86 {
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
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent94 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra29 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra29
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
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra67
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd69 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.fra69 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra69
    namespace eval ::widgets::$site_7_0.che71 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd70 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.fra69 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra69
    namespace eval ::widgets::$site_7_0.che71 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.fra69 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra69
    namespace eval ::widgets::$site_6_0.che71 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.che71 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra74
    namespace eval ::widgets::$site_4_0.lab75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.lab75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra36 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra36
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
            vTclWindow.top378PP
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

proc vTclWindow.top378PP {base} {
    if {$base == ""} {
        set base .top378PP
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
    wm geometry $top 500x330+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Correlation Coefficients (6x6)"
    vTcl:DefineAlias "$top" "Toplevel378PP" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame2" vTcl:WidgetProc "Toplevel378PP" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame378PP_1" vTcl:WidgetProc "Toplevel378PP" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RoMasterDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry378PP_01" vTcl:WidgetProc "Toplevel378PP" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel378PP" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd81 \
        -ipad 0 -text {Input Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd81" "TitleFrame378PP_2" vTcl:WidgetProc "Toplevel378PP" 1
    bind $site_3_0.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RoSlaveDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry378PP_02" vTcl:WidgetProc "Toplevel378PP" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel378PP" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button35" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Master-Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame378PP_3" vTcl:WidgetProc "Toplevel378PP" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RoOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry378PP_03" vTcl:WidgetProc "Toplevel378PP" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame1" vTcl:WidgetProc "Toplevel378PP" 1
    set site_6_0 $site_5_0.cpd95
    label $site_6_0.cpd97 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd97" "Label378PP_01" vTcl:WidgetProc "Toplevel378PP" 1
    entry $site_6_0.ent94 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RoOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.ent94" "Entry378PP_04" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.ent94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel378PP" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global DirName DataDirChannel1 RoOutputDir

set RoDirOutputTmp $RoOutputDir
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set RoOutputDir $DirName
    } else {
    set RoOutputDir $RoDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button378PP_01" vTcl:WidgetProc "Toplevel378PP" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra29 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra29" "Frame9" vTcl:WidgetProc "Toplevel378PP" 1
    set site_3_0 $top.fra29
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel378PP" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel378PP" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel378PP" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel378PP" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel378PP" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel378PP" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel378PP" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel378PP" 1
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
    frame $top.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame10" vTcl:WidgetProc "Toplevel378PP" 1
    set site_3_0 $top.fra66
    frame $site_3_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra67" "Frame12" vTcl:WidgetProc "Toplevel378PP" 1
    set site_4_0 $site_3_0.fra67
    TitleFrame $site_4_0.cpd69 \
        -ipad 0 -text Master 
    vTcl:DefineAlias "$site_4_0.cpd69" "TitleFrame5" vTcl:WidgetProc "Toplevel378PP" 1
    bind $site_4_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd69 getframe]
    frame $site_6_0.fra69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra69" "Frame16" vTcl:WidgetProc "Toplevel378PP" 1
    set site_7_0 $site_6_0.fra69
    checkbutton $site_7_0.che71 \
        -text {Ro12 = ( M-Ch1 , M-Ch2 )} -variable Ro12 
    vTcl:DefineAlias "$site_7_0.che71" "Checkbutton378PP" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_7_0.che71 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra69 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $site_4_0.cpd70 \
        -ipad 0 -text Slave 
    vTcl:DefineAlias "$site_4_0.cpd70" "TitleFrame6" vTcl:WidgetProc "Toplevel378PP" 1
    bind $site_4_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd70 getframe]
    frame $site_6_0.fra69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra69" "Frame17" vTcl:WidgetProc "Toplevel378PP" 1
    set site_7_0 $site_6_0.fra69
    checkbutton $site_7_0.che71 \
        -text {Ro34 = ( S-Ch1 , S-Ch2 )} -variable Ro34 
    vTcl:DefineAlias "$site_7_0.che71" "Checkbutton379" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_7_0.che71 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra69 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill x -ipadx 10 -side top 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 0 -fill x -ipadx 10 -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Master - Slave} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame7" vTcl:WidgetProc "Toplevel378PP" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    frame $site_5_0.fra69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra69" "Frame18" vTcl:WidgetProc "Toplevel378PP" 1
    set site_6_0 $site_5_0.fra69
    checkbutton $site_6_0.che71 \
        -text {Ro13 = ( M-Ch1 , S-Ch1 )} -variable Ro13 
    vTcl:DefineAlias "$site_6_0.che71" "Checkbutton380" vTcl:WidgetProc "Toplevel378PP" 1
    checkbutton $site_6_0.cpd72 \
        -text {Ro14 = ( M-Ch1 , S-Ch2 )} -variable Ro14 
    vTcl:DefineAlias "$site_6_0.cpd72" "Checkbutton381" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_6_0.che71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    frame $site_5_0.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame19" vTcl:WidgetProc "Toplevel378PP" 1
    set site_6_0 $site_5_0.cpd71
    checkbutton $site_6_0.che71 \
        -text {Ro23 = ( M-Ch2 , S-Ch1 )} -variable Ro24 
    vTcl:DefineAlias "$site_6_0.che71" "Checkbutton382" vTcl:WidgetProc "Toplevel378PP" 1
    checkbutton $site_6_0.cpd72 \
        -text {Ro24 = ( M-Ch2 , S-Ch2 )} -variable Ro24 
    vTcl:DefineAlias "$site_6_0.cpd72" "Checkbutton383" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_6_0.che71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.fra69 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.fra67 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill y -ipadx 10 -side left 
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame3" vTcl:WidgetProc "Toplevel378PP" 1
    set site_3_0 $top.fra73
    checkbutton $site_3_0.che78 \
        -text {BMP ( Mod / Phase )} -variable BMPmodphaRo 
    vTcl:DefineAlias "$site_3_0.che78" "Checkbutton378PP_16" vTcl:WidgetProc "Toplevel378PP" 1
    frame $site_3_0.fra74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra74" "Frame4" vTcl:WidgetProc "Toplevel378PP" 1
    set site_4_0 $site_3_0.fra74
    label $site_4_0.lab75 \
        -text {Window Size : Row} 
    vTcl:DefineAlias "$site_4_0.lab75" "Label1" vTcl:WidgetProc "Toplevel378PP" 1
    entry $site_4_0.ent76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NwinLRo -width 5 
    vTcl:DefineAlias "$site_4_0.ent76" "Entry1" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_4_0.lab75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    frame $site_3_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame8" vTcl:WidgetProc "Toplevel378PP" 1
    set site_4_0 $site_3_0.cpd66
    label $site_4_0.lab75 \
        -text { Col} 
    vTcl:DefineAlias "$site_4_0.lab75" "Label2" vTcl:WidgetProc "Toplevel378PP" 1
    entry $site_4_0.ent76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NwinCRo -width 5 
    vTcl:DefineAlias "$site_4_0.ent76" "Entry2" vTcl:WidgetProc "Toplevel378PP" 1
    pack $site_4_0.lab75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.ent76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {global NwinLRo NwinCRo BMPmodphaRo
global Ro12 Ro13 Ro14 Ro34 Ro23 Ro24

set NwinLRo "?"
set NwinCRo "?"
set Ro12 "1"; set Ro13 "1"; set Ro14 "1"
set Ro34 "1"; set Ro23 "1"; set Ro24 "1"
set BMPmodphaRo "1"} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button2" vTcl:WidgetProc "Toplevel378PP" 1
    bindtags $site_3_0.cpd67 "$site_3_0.cpd67 Button $top all _vTclBalloon"
    bind $site_3_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters }
    }
    button $site_3_0.but77 \
        -background #ffff00 \
        -command {global NwinLRo NwinCRo BMPmodphaRo
global Ro12 Ro13 Ro14 Ro34 Ro23 Ro24

set NwinLRo ""
set NwinCRo ""
set Ro12 "0"; set Ro13 "0"; set Ro14 "0"
set Ro34 "0"; set Ro23 "0"; set Ro24 "0"
set BMPmodphaRo "0"} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but77" "Button1" vTcl:WidgetProc "Toplevel378PP" 1
    bindtags $site_3_0.but77 "$site_3_0.but77 Button $top all _vTclBalloon"
    bind $site_3_0.but77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.che78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra36 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame20" vTcl:WidgetProc "Toplevel378PP" 1
    set site_3_0 $top.fra36
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2 DirName
global RoMasterDirInput RoSlaveDirInput RoDirOutput RoOutputDir RoOutputSubDir
global CorrelationFonction NwinLRo NwinCRo BMPmodphaRo
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global BMPDirInput PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType 

if {$OpenDirFile == 0} {

set RoDirOutput $RoOutputDir
if {$RoOutputSubDir != ""} {append RoDirOutput "/$RoOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set RoDirOutput [PSPCreateDirectoryMask $RoDirOutput $RoOutputDir $RoMasterDirInput]
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
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinLRo; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinCRo; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {

    set MaskCmd ""
    if {$CorrelationFonction == "SPP"} {
        set ConfigFile "$RoDirOutput/config.txt"
        WriteConfig
        set MaskFileOut "$RoDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFileOut] {
            set MaskCmd "-mask \x22$MaskFileOut\x22"
            } else {
            set MaskFile1 "$RoMasterDirInput/mask_valid_pixels.bin"
            set MaskFile2 "$RoSlaveDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile1] {
                if [file exists $MaskFile2] {
                    set MaskFileOut "$RoDirOutput/mask_valid_pixels.bin"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/calculator/file_operand_file.exe" "k"
                    TextEditorRunTrace "Arguments: -if1 \x22$MaskFile1\x22 -it1 float -if2 \x22$MaskFile2\x22 -it2 float -of \x22$MaskFileOut\x22 -ot float -op mulfile -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
                    set f [ open "| Soft/calculator/file_operand_file.exe -if1 \x22$MaskFile1\x22 -it1 float -if2 \x22$MaskFile2\x22 -it2 float -of \x22$MaskFileOut\x22 -ot float -op mulfile -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"          
                    EnviWriteConfig $MaskFileOut $FinalNlig $FinalNcol 4
                    if [file exists $MaskFileOut] {set MaskCmd "-mask \x22$MaskFileOut\x22"}
                    } 
                } 
            }
        }
    if {$CorrelationFonction == "T4"} {
        set MaskFile "$RoMasterDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-maskm \x22$MaskFile\x22"}
        }

    set CorrelFonction $CorrelationFonction
    if {$CorrelationFonction == "SPP"} { set CorrelFonction "SPPT4" }

    if {"$Ro12" == 1} {
        set RoElmt 12
        set RoFile "$RoDirOutput/RoM-Ch1_M-Ch2"
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoFile.bin"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/process_corr_PP.exe" "k"
        if {$CorrelationFonction == "SPP"} {
           TextEditorRunTrace "Arguments: -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        if {$CorrelationFonction == "T4"} {
           TextEditorRunTrace "Arguments: -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoFile.bin" $FinalNlig $FinalNcol 6
        if {$BMPmodphaRo=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoFile.bin"
            set BMPFileOutput $RoFile; append BMPFileOutput "_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            set BMPFileOutput $RoFile; append BMPFileOutput "_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }

    if {"$Ro13" == 1} {
        set RoElmt 13
        set RoFile "$RoDirOutput/RoM-Ch1_S-Ch1"
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoFile.bin"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/process_corr_PP.exe" "k"
        if {$CorrelationFonction == "SPP"} {
           TextEditorRunTrace "Arguments: -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        if {$CorrelationFonction == "T4"} {
           TextEditorRunTrace "Arguments: -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoFile.bin" $FinalNlig $FinalNcol 6
        if {$BMPmodphaRo=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoFile.bin"
            set BMPFileOutput $RoFile; append BMPFileOutput "_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            set BMPFileOutput $RoFile; append BMPFileOutput "_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }

    if {"$Ro14" == 1} {
        set RoElmt 14
        set RoFile "$RoDirOutput/RoM-Ch1_S-Ch2"
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoFile.bin"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/process_corr_PP.exe" "k"
        if {$CorrelationFonction == "SPP"} {
           TextEditorRunTrace "Arguments: -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        if {$CorrelationFonction == "T4"} {
           TextEditorRunTrace "Arguments: -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoFile.bin" $FinalNlig $FinalNcol 6
        if {$BMPmodphaRo=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoFile.bin"
            set BMPFileOutput $RoFile; append BMPFileOutput "_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            set BMPFileOutput $RoFile; append BMPFileOutput "_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }

    if {"$Ro23" == 1} {
        set RoElmt 23
        set RoFile "$RoDirOutput/RoM-Ch2_S-Ch1"
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoFile.bin"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/process_corr_PP.exe" "k"
        if {$CorrelationFonction == "SPP"} {
           TextEditorRunTrace "Arguments: -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        if {$CorrelationFonction == "T4"} {
           TextEditorRunTrace "Arguments: -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoFile.bin" $FinalNlig $FinalNcol 6
        if {$BMPmodphaRo=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoFile.bin"
            set BMPFileOutput $RoFile; append BMPFileOutput "_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            set BMPFileOutput $RoFile; append BMPFileOutput "_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }


    if {"$Ro24" == 1} {
        set RoElmt 24
        set RoFile "$RoDirOutput/RoM-Ch2_S-Ch2"
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoFile.bin"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/process_corr_PP.exe" "k"
        if {$CorrelationFonction == "SPP"} {
           TextEditorRunTrace "Arguments: -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        if {$CorrelationFonction == "T4"} {
           TextEditorRunTrace "Arguments: -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoFile.bin" $FinalNlig $FinalNcol 6
        if {$BMPmodphaRo=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoFile.bin"
            set BMPFileOutput $RoFile; append BMPFileOutput "_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            set BMPFileOutput $RoFile; append BMPFileOutput "_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }


    if {"$Ro34" == 1} {
        set RoElmt 34
        set RoFile "$RoDirOutput/RoS-Ch1_S-Ch2"
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$RoFile.bin"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/process_corr_PP.exe" "k"
        if {$CorrelationFonction == "SPP"} {
           TextEditorRunTrace "Arguments: -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -idm \x22$RoMasterDirInput\x22 -ids \x22$RoSlaveDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        if {$CorrelationFonction == "T4"} {
           TextEditorRunTrace "Arguments: -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
           set f [ open "| Soft/data_process_dual/process_corr_PP.exe -id \x22$RoMasterDirInput\x22 -od \x22$RoDirOutput\x22 -iodf $CorrelFonction -elt $RoElmt -nwr $NwinLRo -nwc $NwinCRo -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
           }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$RoFile.bin" $FinalNlig $FinalNcol 6
        if {$BMPmodphaRo=="1"} {
            set BMPDirInput $RoDirOutput
            set BMPFileInput "$RoFile.bin"
            set BMPFileOutput $RoFile; append BMPFileOutput "_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx mod jet  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
            set BMPFileOutput $RoFile; append BMPFileOutput "_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
            }
        }

    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel378PP); TextEditorRunTrace "Close Window Correlation Coefficients 6" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel378PP" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CorrelationCoefficients6.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel378PP" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel378PP); TextEditorRunTrace "Close Window Correlation Coefficients 4" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel378PP" 1
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
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra29 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra36 \
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
Window show .top378PP

main $argc $argv
