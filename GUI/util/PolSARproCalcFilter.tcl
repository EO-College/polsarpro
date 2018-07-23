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
    set base .top603
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra68 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra68
    namespace eval ::widgets::$site_3_0.rad69 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd70
    namespace eval ::widgets::$site_3_0.rad69 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
    namespace eval ::widgets::$site_3_0.rad69 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.rad69 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit73 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent75 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra79
    namespace eval ::widgets::$site_3_0.cpd80 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd82 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.but83 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
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
    wm geometry $top 200x200+50+50; update
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

proc vTclWindow.top603 {base} {
    if {$base == ""} {
        set base .top603
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
    wm geometry $top 150x175+30+130; update
    wm maxsize $top 1676 1024
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Filter"
    vTcl:DefineAlias "$top" "Toplevel603" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra68 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra68" "Frame1" vTcl:WidgetProc "Toplevel603" 1
    set site_3_0 $top.fra68
    radiobutton $site_3_0.rad69 \
        -borderwidth 0 \
        -command {global PSPCalcNwinL PSPCalcNwinC PSPCalcNlook
global PSPBackgroundColor

set PSPCalcNwinL "5"; set PSPCalcNwinC "5"
set PSPCalcNlook ""
.top603.tit73.f.cpd76 configure -state normal
.top603.tit73.f.cpd78 configure -state normal
.top603.tit73.f.cpd78 configure -disabledbackground #FFFFFF
.top603.fra79.cpd80 configure -state disable
.top603.fra79.cpd82 configure -state disable
.top603.fra79.cpd82 configure -disabledbackground $PSPBackgroundColor} \
        -text {Box Car} -value boxcar -variable PSPCalcFilter 
    vTcl:DefineAlias "$site_3_0.rad69" "Radiobutton1" vTcl:WidgetProc "Toplevel603" 1
    pack $site_3_0.rad69 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd70" "Frame2" vTcl:WidgetProc "Toplevel603" 1
    set site_3_0 $top.cpd70
    radiobutton $site_3_0.rad69 \
        -borderwidth 0 \
        -command {global PSPCalcNwinL PSPCalcNwinC PSPCalcNlook
global PSPBackgroundColor

set PSPCalcNwinL "5"; set PSPCalcNwinC ""
set PSPCalcNlook "1"
.top603.tit73.f.cpd76 configure -state disable
.top603.tit73.f.cpd78 configure -state disable
.top603.tit73.f.cpd78 configure -disabledbackground $PSPBackgroundColor
.top603.fra79.cpd80 configure -state normal
.top603.fra79.cpd82 configure -state normal
.top603.fra79.cpd82 configure -disabledbackground #FFFFFF} \
        -text {Lee Refined} -value lee -variable PSPCalcFilter 
    vTcl:DefineAlias "$site_3_0.rad69" "Radiobutton2" vTcl:WidgetProc "Toplevel603" 1
    pack $site_3_0.rad69 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame3" vTcl:WidgetProc "Toplevel603" 1
    set site_3_0 $top.cpd71
    radiobutton $site_3_0.rad69 \
        -borderwidth 0 \
        -command {global PSPCalcNwinL PSPCalcNwinC PSPCalcNlook
global PSPBackgroundColor

set PSPCalcNwinL "5"; set PSPCalcNwinC "5"
set PSPCalcNlook ""
.top603.tit73.f.cpd76 configure -state normal
.top603.tit73.f.cpd78 configure -state normal
.top603.tit73.f.cpd78 configure -disabledbackground #FFFFFF
.top603.fra79.cpd80 configure -state disable
.top603.fra79.cpd82 configure -state disable
.top603.fra79.cpd82 configure -disabledbackground $PSPBackgroundColor} \
        -text Median -value median -variable PSPCalcFilter 
    vTcl:DefineAlias "$site_3_0.rad69" "Radiobutton3" vTcl:WidgetProc "Toplevel603" 1
    pack $site_3_0.rad69 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame4" vTcl:WidgetProc "Toplevel603" 1
    set site_3_0 $top.cpd72
    radiobutton $site_3_0.rad69 \
        -borderwidth 0 \
        -command {global PSPCalcNwinL PSPCalcNwinC PSPCalcNlook
global PSPBackgroundColor

set PSPCalcNwinL "5"; set PSPCalcNwinC ""
set PSPCalcNlook ""
.top603.tit73.f.cpd76 configure -state disable
.top603.tit73.f.cpd78 configure -state disable
.top603.tit73.f.cpd78 configure -disabledbackground $PSPBackgroundColor
.top603.fra79.cpd80 configure -state disable
.top603.fra79.cpd82 configure -state disable
.top603.fra79.cpd82 configure -disabledbackground $PSPBackgroundColor} \
        -text Nagao -value nagao -variable PSPCalcFilter 
    vTcl:DefineAlias "$site_3_0.rad69" "Radiobutton4" vTcl:WidgetProc "Toplevel603" 1
    pack $site_3_0.rad69 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit73 \
        -text {Window Size} 
    vTcl:DefineAlias "$top.tit73" "TitleFrame1" vTcl:WidgetProc "Toplevel603" 1
    bind $top.tit73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit73 getframe]
    label $site_4_0.lab74 \
        -text Row 
    vTcl:DefineAlias "$site_4_0.lab74" "Label1" vTcl:WidgetProc "Toplevel603" 1
    entry $site_4_0.ent75 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcNwinL -width 4 
    vTcl:DefineAlias "$site_4_0.ent75" "Entry1" vTcl:WidgetProc "Toplevel603" 1
    label $site_4_0.cpd76 \
        -text Col 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label2" vTcl:WidgetProc "Toplevel603" 1
    entry $site_4_0.cpd78 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcNwinC -width 4 
    vTcl:DefineAlias "$site_4_0.cpd78" "Entry2" vTcl:WidgetProc "Toplevel603" 1
    pack $site_4_0.lab74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side right 
    frame $top.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra79" "Frame5" vTcl:WidgetProc "Toplevel603" 1
    set site_3_0 $top.fra79
    label $site_3_0.cpd80 \
        -text {Number of Looks} 
    vTcl:DefineAlias "$site_3_0.cpd80" "Label3" vTcl:WidgetProc "Toplevel603" 1
    entry $site_3_0.cpd82 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PSPCalcNlook -width 4 
    vTcl:DefineAlias "$site_3_0.cpd82" "Entry3" vTcl:WidgetProc "Toplevel603" 1
    pack $site_3_0.cpd80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd82 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    button $top.but83 \
        -background #ffff00 \
        -command {global OpenDirFile PSPCalcRunButton PSPCalcOperatorName
global PSPCalcOp2Name PSPCalcNwinL PSPCalcNwinC PSPCalcFilter PSPCalcOperand2
global PSPCalcNwinL PSPCalcNwinC

if {$OpenDirFile == 0} {
if {$PSPCalcFilter == "boxcar"} { set PSPCalcOperatorName ".boxcar(?x?)" }
if {$PSPCalcFilter == "lee"} { set PSPCalcOperatorName ".lee refined(?x?)"; set PSPCalcNwinC $PSPCalcNwinL }
if {$PSPCalcFilter == "median"} { set PSPCalcOperatorName ".median(?x?)" }
if {$PSPCalcFilter == "nagao"} { set PSPCalcOperatorName ".nagao(?x?)"; if {$PSPCalcNwinL < "5"} {set PSPCalcNwinL "5"}; set PSPCalcNwinC $PSPCalcNwinL }
set PSPCalcOp2Name "Value = "
append PSPCalcOp2Name "$PSPCalcNwinL x $PSPCalcNwinC"
set PSPCalcOperand2 "integer value"
$PSPCalcRunButton configure -state normal -background #FFFF00
Window hide $widget(Toplevel603)
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$top.but83" "Button1" vTcl:WidgetProc "Toplevel603" 1
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd70 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit73 \
        -in $top -anchor center -expand 1 -fill x -pady 2 -side top 
    pack $top.fra79 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.but83 \
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
Window show .top603

main $argc $argv
