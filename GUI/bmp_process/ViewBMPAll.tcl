#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

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
    set base .top339
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.fra76 {
        array set save {-background 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra76
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-relief 1 -text 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.can78 {
        array set save {-background 1 -closeenough 1 -height 1 -highlightthickness 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra77 {
        array set save {-background 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra77
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-relief 1 -text 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.can79 {
        array set save {-background 1 -closeenough 1 -height 1 -highlightthickness 1 -width 1}
    }
    namespace eval ::widgets::$base.fra75 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra75
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-background 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd77
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-relief 1 -text 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.can80 {
        array set save {-background 1 -closeenough 1 -height 1 -highlightthickness 1 -width 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
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

proc vTclWindow.top339 {base} {
    if {$base == ""} {
        set base .top339
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
    wm geometry $top 900x640+10+110; update
    wm maxsize $top 1604 1185
    wm minsize $top 104 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "New Toplevel 1"
    vTcl:DefineAlias "$top" "VIEWBMPALL" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra74 \
        -borderwidth 2 -background #ffffff -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame1" vTcl:WidgetProc "VIEWBMPALL" 1
    set site_3_0 $top.fra74
    frame $site_3_0.fra76 \
        -background #ffffff -height 300 -width 300 
    vTcl:DefineAlias "$site_3_0.fra76" "Frame3" vTcl:WidgetProc "VIEWBMPALL" 1
    set site_4_0 $site_3_0.fra76
    label $site_4_0.cpd74 \
        -relief ridge -text label -textvariable BMPTitleOverviewAll 
    vTcl:DefineAlias "$site_4_0.cpd74" "Label1" vTcl:WidgetProc "VIEWBMPALL" 1
    canvas $site_4_0.can78 \
        -background #ffffff -closeenough 1.0 -height 300 \
        -highlightthickness 0 -width 300 
    vTcl:DefineAlias "$site_4_0.can78" "CANVASOVERVIEWALL" vTcl:WidgetProc "VIEWBMPALL" 1
    bind $site_4_0.can78 <B1-Motion> {
        RectOverviewAllMove %W %x %y %W
    }
    bind $site_4_0.can78 <Button-1> {
        MouseButtonDownOverviewAll %x %y
    }
    bind $site_4_0.can78 <ButtonRelease-1> {
        MouseButtonReleaseOverviewAll %x %y
    }
    bind $site_4_0.can78 <Motion> {
        MouseMotionOverview %x %y
    }
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.can78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.fra77 \
        -background #ffffff -height 300 -width 300 
    vTcl:DefineAlias "$site_3_0.fra77" "Frame4" vTcl:WidgetProc "VIEWBMPALL" 1
    set site_4_0 $site_3_0.fra77
    label $site_4_0.cpd75 \
        -relief ridge -text label -textvariable BMPTitleLensAll 
    vTcl:DefineAlias "$site_4_0.cpd75" "Label2" vTcl:WidgetProc "VIEWBMPALL" 1
    canvas $site_4_0.can79 \
        -background #ffffff -closeenough 1.0 -height 300 \
        -highlightthickness 0 -width 300 
    vTcl:DefineAlias "$site_4_0.can79" "CANVASLENSALL" vTcl:WidgetProc "VIEWBMPALL" 1
    bind $site_4_0.can79 <Motion> {
        MouseMotionLensAll %x %y
    }
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.can79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.fra76 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side top 
    pack $site_3_0.fra77 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side bottom 
    frame $top.fra75 \
        -borderwidth 2 -background #000000 -height 600 -width 600 
    vTcl:DefineAlias "$top.fra75" "Frame2" vTcl:WidgetProc "VIEWBMPALL" 1
    set site_3_0 $top.fra75
    frame $site_3_0.cpd77 \
        -background #ffffff -height 600 -width 600 
    vTcl:DefineAlias "$site_3_0.cpd77" "Frame5" vTcl:WidgetProc "VIEWBMPALL" 1
    set site_4_0 $site_3_0.cpd77
    label $site_4_0.cpd76 \
        -relief ridge -text label -textvariable BMPTitleViewAll 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label4" vTcl:WidgetProc "VIEWBMPALL" 1
    canvas $site_4_0.can80 \
        -background #ffffff -closeenough 1.0 -height 600 \
        -highlightthickness 0 -width 600 
    vTcl:DefineAlias "$site_4_0.can80" "CANVASVIEWALL" vTcl:WidgetProc "VIEWBMPALL" 1
    bind $site_4_0.can80 <B1-Motion> {
        RectLensAllMove %W %x %y %W
    }
    bind $site_4_0.can80 <Button-1> {
        MouseButtonDownLensAll %x %y
    }
    bind $site_4_0.can80 <Button-3> {
        MouseButtonRightDownLensAll %x %y
    }
    bind $site_4_0.can80 <ButtonRelease-1> {
        MouseButtonReleaseLensAll %x %y
    }
    bind $site_4_0.can80 <Motion> {
        MouseMotionViewAll %x %y
    }
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.can80 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill y -side left 
    pack $top.fra75 \
        -in $top -anchor center -expand 1 -fill y -side right 

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
Window show .top339

main $argc $argv
