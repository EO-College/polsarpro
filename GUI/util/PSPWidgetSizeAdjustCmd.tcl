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

        {{[file join . GUI Images PSPWidgetSizeAdjust.gif]} {user image} user {}}
        {{[file join . GUI Images left2.gif]} {user image} user {}}
        {{[file join . GUI Images left1.gif]} {user image} user {}}
        {{[file join . GUI Images right1.gif]} {user image} user {}}
        {{[file join . GUI Images right2.gif]} {user image} user {}}
        {{[file join . GUI Images down1.gif]} {user image} user {}}
        {{[file join . GUI Images down2.gif]} {user image} user {}}
        {{[file join . GUI Images up1.gif]} {user image} user {}}
        {{[file join . GUI Images up2.gif]} {user image} user {}}

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
    set base .top8
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd82 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd82
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd67
    namespace eval ::widgets::$site_6_0.cpd68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd76
    namespace eval ::widgets::$site_7_0.ent72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd69
    namespace eval ::widgets::$site_8_0.but70 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd72 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd76
    namespace eval ::widgets::$site_7_0.ent72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd69
    namespace eval ::widgets::$site_8_0.but70 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd72 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.lab83 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.m77 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            WmTransientLeftUpdate
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

proc ::main {argc argv} {}
#############################################################################
## Procedure:  WmTransientLeftUpdate

proc ::WmTransientLeftUpdate {} {
global PlatForm
global WidgetSizeWidthInitial WidgetSizeHeightInitial
global WidgetSizeWidthRatio WidgetSizeHeightRatio

set geoscreenwidth [winfo screenwidth .top2]
set geoscreenheight [winfo screenheight .top2]

set tx [winfo rootx .top2]
set ty [winfo rooty .top2]
set x [winfo x .top2]
set y [winfo y .top2]
set geoscreenborderw [expr {$tx-$x}]
set geoscreentitleh [expr {$ty-$y}]
if {$PlatForm == "unix"} {
    set geoscreentitleh [expr {$y-1}]
    set geoscreenborderw [expr 1 + round(($geoscreentitleh * 1.0) / 10.0)]
    }

set newwidgetwidth [expr round($WidgetSizeWidthInitial * $WidgetSizeWidthRatio )]
set newwidgetheight [expr round($WidgetSizeHeightInitial * $WidgetSizeHeightRatio )]

set positionwidth [expr 2 * $geoscreenborderw] 

set FrameGalBd 2; set FrameBd 2; set ButtonBd 3; set BorderHeight 62; ; set ButtonHeight 26
set offsetheight [expr $geoscreentitleh + $geoscreenborderw ] 
set offsetheight [expr $offsetheight + (2 * $FrameGalBd) + (2 * $FrameBd) + (2 * $ButtonBd) + $BorderHeight ] 
set offsetheight [expr $offsetheight + (2 * $FrameGalBd) + (2 * $FrameBd) + (2 * $ButtonBd) + $ButtonHeight ] 

set positionheight $offsetheight 

set geometrie $newwidgetwidth; append geometrie "x"; append geometrie $newwidgetheight; append geometrie "+";
append geometrie $positionwidth; append geometrie "+"; append geometrie $positionheight
wm geometry .top9 $geometrie; update
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {}

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
    wm maxsize $top 5116 1414
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

proc vTclWindow.top8 {base} {
    if {$base == ""} {
        set base .top8
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m77" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 480x600+10+10; update
    wm maxsize $top 3364 1032
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PolSARpro : Widget Size Adjust Cmd"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd82 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd82" "Frame10" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.cpd82
    button $site_3_0.cpd66 \
        -background #ffff00 \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeWidthRatio 1.0
set WidgetSizeHeightRatio 1.0
WmTransientLeftUpdate} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd66" "Button21" vTcl:WidgetProc "Toplevel1" 1
    button $site_3_0.cpd84 \
        -background #ffff00 \
        -command {global OpenDirFile VarWidgetSizeRatio
global WidgetSizeWidthInitial WidgetSizeHeightInitial
global WidgetSizeWidthCurrent WidgetSizeHeightCurrent
global WidgetSizeWidthRatio WidgetSizeHeightRatio

if {$OpenDirFile == 0} {
    Window hide .top9; TextEditorRunTrace "Close Window PSP Widget Size Adjust" "b"
    Window hide .top8; TextEditorRunTrace "Close Window PSP Widget Size Adjust Cmd" "b"
    set VarWidgetSizeRatio 1
    }} \
        -padx 4 -pady 2 -text {Save and Exit} 
    vTcl:DefineAlias "$site_3_0.cpd84" "Button16" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.fra66
    TitleFrame $site_3_0.cpd67 \
        -text {Widget Size Ratio} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame4" vTcl:WidgetProc "Toplevel1" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.cpd67
    set site_6_0 $site_5_0.cpd67
    label $site_6_0.cpd68 \
        -text Width 
    vTcl:DefineAlias "$site_6_0.cpd68" "Label33" vTcl:WidgetProc "Toplevel1" 1
    frame $site_6_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd76" "Frame29" vTcl:WidgetProc "Toplevel1" 1
    set site_7_0 $site_6_0.cpd76
    entry $site_7_0.ent72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -justify center -state disabled \
        -textvariable WidgetSizeWidthRatio -width 7 
    vTcl:DefineAlias "$site_7_0.ent72" "Entry19" vTcl:WidgetProc "Toplevel1" 1
    frame $site_7_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd69" "Frame31" vTcl:WidgetProc "Toplevel1" 1
    set site_8_0 $site_7_0.cpd69
    button $site_8_0.but70 \
        \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeWidthRatio [expr $WidgetSizeWidthRatio - 0.1]
WmTransientLeftUpdate} \
        -image [vTcl:image:get_image [file join . GUI Images left2.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.but70" "Button1" vTcl:WidgetProc "Toplevel1" 1
    button $site_8_0.cpd71 \
        \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeWidthRatio [expr $WidgetSizeWidthRatio - 0.01]
WmTransientLeftUpdate} \
        -image [vTcl:image:get_image [file join . GUI Images left1.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd71" "Button2" vTcl:WidgetProc "Toplevel1" 1
    button $site_8_0.cpd72 \
        \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeWidthRatio [expr $WidgetSizeWidthRatio + 0.01]
WmTransientLeftUpdate} \
        -image [vTcl:image:get_image [file join . GUI Images right1.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd72" "Button3" vTcl:WidgetProc "Toplevel1" 1
    button $site_8_0.cpd73 \
        \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeWidthRatio [expr $WidgetSizeWidthRatio + 0.1]
WmTransientLeftUpdate} \
        -image [vTcl:image:get_image [file join . GUI Images right2.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd73" "Button4" vTcl:WidgetProc "Toplevel1" 1
    pack $site_8_0.but70 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd71 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd72 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent72 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    pack $site_7_0.cpd69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.cpd74
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.cpd68 \
        -text Height 
    vTcl:DefineAlias "$site_6_0.cpd68" "Label34" vTcl:WidgetProc "Toplevel1" 1
    frame $site_6_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd76" "Frame30" vTcl:WidgetProc "Toplevel1" 1
    set site_7_0 $site_6_0.cpd76
    entry $site_7_0.ent72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -justify center -state disabled \
        -textvariable WidgetSizeHeightRatio -width 7 
    vTcl:DefineAlias "$site_7_0.ent72" "Entry20" vTcl:WidgetProc "Toplevel1" 1
    frame $site_7_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd69" "Frame32" vTcl:WidgetProc "Toplevel1" 1
    set site_8_0 $site_7_0.cpd69
    button $site_8_0.but70 \
        \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeHeightRatio [expr $WidgetSizeHeightRatio + 0.1]
WmTransientLeftUpdate} \
        -image [vTcl:image:get_image [file join . GUI Images up2.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.but70" "Button5" vTcl:WidgetProc "Toplevel1" 1
    button $site_8_0.cpd71 \
        \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeHeightRatio [expr $WidgetSizeHeightRatio + 0.01]
WmTransientLeftUpdate} \
        -image [vTcl:image:get_image [file join . GUI Images up1.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd71" "Button6" vTcl:WidgetProc "Toplevel1" 1
    button $site_8_0.cpd72 \
        \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeHeightRatio [expr $WidgetSizeHeightRatio - 0.01]
WmTransientLeftUpdate} \
        -image [vTcl:image:get_image [file join . GUI Images down1.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd72" "Button7" vTcl:WidgetProc "Toplevel1" 1
    button $site_8_0.cpd73 \
        \
        -command {global WidgetSizeWidthRatio WidgetSizeHeightRatio

set WidgetSizeHeightRatio [expr $WidgetSizeHeightRatio - 0.1]
WmTransientLeftUpdate} \
        -image [vTcl:image:get_image [file join . GUI Images down2.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd73" "Button8" vTcl:WidgetProc "Toplevel1" 1
    pack $site_8_0.but70 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd71 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd72 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent72 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    pack $site_7_0.cpd69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 0 -fill x -padx 5 -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    label $top.lab83 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPWidgetSizeAdjust.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$top.lab83" "Label1" vTcl:WidgetProc "Toplevel1" 1
    menu $top.m77 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd82 \
        -in $top -anchor center -expand 0 -fill x -side bottom 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.lab83 \
        -in $top -anchor center -expand 1 -fill none -side top 

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

Window show .
Window show .top8

main $argc $argv
