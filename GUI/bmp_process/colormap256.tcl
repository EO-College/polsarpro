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
    set base .top62
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra35 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra35
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra89 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra89
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra90 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra90
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra91 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra91
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra93 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra93
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra94 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra94
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra95 {
        array set save {-borderwidth 1 -cursor 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra95
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top62
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

proc vTclWindow.top62 {base} {
    if {$base == ""} {
        set base .top62
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
    wm geometry $top 500x200+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "ColorMap 256"
    vTcl:DefineAlias "$top" "Toplevel62" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra35 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    set site_3_0 $top.fra35
    button $site_3_0.but36 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but36 1} \
        -pady 0 -text {  } 
    button $site_3_0.but37 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but37 2} \
        -pady 0 -text {  } 
    button $site_3_0.but38 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but38 3} \
        -pady 0 -text {  } 
    button $site_3_0.but39 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but39 4} \
        -pady 0 -text {  } 
    button $site_3_0.but40 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but40 5} \
        -pady 0 -text {  } 
    button $site_3_0.but41 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but41 6} \
        -pady 0 -text {  } 
    button $site_3_0.but42 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but42 7} \
        -pady 0 -text {  } 
    button $site_3_0.but43 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but43 8} \
        -pady 0 -text {  } 
    button $site_3_0.but44 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but44 9} \
        -pady 0 -text {  } 
    button $site_3_0.but45 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but45 10} \
        -pady 0 -text {  } 
    button $site_3_0.but46 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but46 11} \
        -pady 0 -text {  } 
    button $site_3_0.but47 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but47 12} \
        -pady 0 -text {  } 
    button $site_3_0.but48 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but48 13} \
        -pady 0 -text {  } 
    button $site_3_0.but49 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but49 14} \
        -pady 0 -text {  } 
    button $site_3_0.but50 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but50 15} \
        -pady 0 -text {  } 
    button $site_3_0.but51 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but51 16} \
        -pady 0 -text {  } 
    button $site_3_0.but70 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but70 17} \
        -pady 0 -text {  } 
    button $site_3_0.but71 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but71 18} \
        -pady 0 -text {  } 
    button $site_3_0.but72 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but72 19} \
        -pady 0 -text {  } 
    button $site_3_0.but73 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but73 20} \
        -pady 0 -text {  } 
    button $site_3_0.but74 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but74 21} \
        -pady 0 -text {  } 
    button $site_3_0.but75 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but75 22} \
        -pady 0 -text {  } 
    button $site_3_0.but76 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but76 23} \
        -pady 0 -text {  } 
    button $site_3_0.but77 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but77 24} \
        -pady 0 -text {  } 
    button $site_3_0.but78 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but78 25} \
        -pady 0 -text {  } 
    button $site_3_0.but79 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but79 26} \
        -pady 0 -text {  } 
    button $site_3_0.but80 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but80 27} \
        -pady 0 -text {  } 
    button $site_3_0.but83 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but83 28} \
        -pady 0 -text {  } 
    button $site_3_0.but84 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but84 29} \
        -pady 0 -text {  } 
    button $site_3_0.but85 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but85 30} \
        -pady 0 -text {  } 
    button $site_3_0.but86 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but86 31} \
        -pady 0 -text {  } 
    button $site_3_0.but87 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra35.but87 32} \
        -pady 0 -text {  } 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra89 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra89" "Frame263" vTcl:WidgetProc "Toplevel62" 1
    set site_3_0 $top.fra89
    button $site_3_0.but36 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but36 33} \
        -pady 0 -text {  } 
    button $site_3_0.but37 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but37 34} \
        -pady 0 -text {  } 
    button $site_3_0.but38 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but38 35} \
        -pady 0 -text {  } 
    button $site_3_0.but39 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but39 36} \
        -pady 0 -text {  } 
    button $site_3_0.but40 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but40 37} \
        -pady 0 -text {  } 
    button $site_3_0.but41 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but41 38} \
        -pady 0 -text {  } 
    button $site_3_0.but42 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but42 39} \
        -pady 0 -text {  } 
    button $site_3_0.but43 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but43 40} \
        -pady 0 -text {  } 
    button $site_3_0.but44 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but44 41} \
        -pady 0 -text {  } 
    button $site_3_0.but45 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but45 42} \
        -pady 0 -text {  } 
    button $site_3_0.but46 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but46 43} \
        -pady 0 -text {  } 
    button $site_3_0.but47 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but47 44} \
        -pady 0 -text {  } 
    button $site_3_0.but48 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but48 45} \
        -pady 0 -text {  } 
    button $site_3_0.but49 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but49 46} \
        -pady 0 -text {  } 
    button $site_3_0.but50 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but50 47} \
        -pady 0 -text {  } 
    button $site_3_0.but51 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but51 48} \
        -pady 0 -text {  } 
    button $site_3_0.but70 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but70 49} \
        -pady 0 -text {  } 
    button $site_3_0.but71 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but71 50} \
        -pady 0 -text {  } 
    button $site_3_0.but72 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but72 51} \
        -pady 0 -text {  } 
    button $site_3_0.but73 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but73 52} \
        -pady 0 -text {  } 
    button $site_3_0.but74 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but74 53} \
        -pady 0 -text {  } 
    button $site_3_0.but75 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but75 54} \
        -pady 0 -text {  } 
    button $site_3_0.but76 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but76 55} \
        -pady 0 -text {  } 
    button $site_3_0.but77 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but77 56} \
        -pady 0 -text {  } 
    button $site_3_0.but78 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but78 57} \
        -pady 0 -text {  } 
    button $site_3_0.but79 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but79 58} \
        -pady 0 -text {  } 
    button $site_3_0.but80 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but80 59} \
        -pady 0 -text {  } 
    button $site_3_0.but83 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but83 60} \
        -pady 0 -text {  } 
    button $site_3_0.but84 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but84 61} \
        -pady 0 -text {  } 
    button $site_3_0.but85 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but85 62} \
        -pady 0 -text {  } 
    button $site_3_0.but86 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but86 63} \
        -pady 0 -text {  } 
    button $site_3_0.but87 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra89.but87 64} \
        -pady 0 -text {  } 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra90 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra90" "Frame292" vTcl:WidgetProc "Toplevel62" 1
    set site_3_0 $top.fra90
    button $site_3_0.but36 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but36 65} \
        -pady 0 -text {  } 
    button $site_3_0.but37 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but37 66} \
        -pady 0 -text {  } 
    button $site_3_0.but38 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but38 67} \
        -pady 0 -text {  } 
    button $site_3_0.but39 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but39 68} \
        -pady 0 -text {  } 
    button $site_3_0.but40 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but40 69} \
        -pady 0 -text {  } 
    button $site_3_0.but41 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but41 70} \
        -pady 0 -text {  } 
    button $site_3_0.but42 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but42 71} \
        -pady 0 -text {  } 
    button $site_3_0.but43 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but43 72} \
        -pady 0 -text {  } 
    button $site_3_0.but44 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but44 73} \
        -pady 0 -text {  } 
    button $site_3_0.but45 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but45 74} \
        -pady 0 -text {  } 
    button $site_3_0.but46 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but46 75} \
        -pady 0 -text {  } 
    button $site_3_0.but47 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but47 76} \
        -pady 0 -text {  } 
    button $site_3_0.but48 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but48 77} \
        -pady 0 -text {  } 
    button $site_3_0.but49 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but49 78} \
        -pady 0 -text {  } 
    button $site_3_0.but50 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but50 79} \
        -pady 0 -text {  } 
    button $site_3_0.but51 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but51 80} \
        -pady 0 -text {  } 
    button $site_3_0.but70 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but70 81} \
        -pady 0 -text {  } 
    button $site_3_0.but71 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but71 82} \
        -pady 0 -text {  } 
    button $site_3_0.but72 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but72 83} \
        -pady 0 -text {  } 
    button $site_3_0.but73 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but73 84} \
        -pady 0 -text {  } 
    button $site_3_0.but74 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but74 85} \
        -pady 0 -text {  } 
    button $site_3_0.but75 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but75 86} \
        -pady 0 -text {  } 
    button $site_3_0.but76 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but76 87} \
        -pady 0 -text {  } 
    button $site_3_0.but77 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but77 88} \
        -pady 0 -text {  } 
    button $site_3_0.but78 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but78 89} \
        -pady 0 -text {  } 
    button $site_3_0.but79 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but79 90} \
        -pady 0 -text {  } 
    button $site_3_0.but80 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but80 91} \
        -pady 0 -text {  } 
    button $site_3_0.but83 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but83 92} \
        -pady 0 -text {  } 
    button $site_3_0.but84 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but84 93} \
        -pady 0 -text {  } 
    button $site_3_0.but85 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but85 94} \
        -pady 0 -text {  } 
    button $site_3_0.but86 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but86 95} \
        -pady 0 -text {  } 
    button $site_3_0.but87 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra90.but87 96} \
        -pady 0 -text {  } 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra91 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra91" "Frame293" vTcl:WidgetProc "Toplevel62" 1
    set site_3_0 $top.fra91
    button $site_3_0.but36 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but36 97} \
        -pady 0 -text {  } 
    button $site_3_0.but37 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but37 98} \
        -pady 0 -text {  } 
    button $site_3_0.but38 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but38 99} \
        -pady 0 -text {  } 
    button $site_3_0.but39 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but39 100} \
        -pady 0 -text {  } 
    button $site_3_0.but40 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but40 101} \
        -pady 0 -text {  } 
    button $site_3_0.but41 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but41 102} \
        -pady 0 -text {  } 
    button $site_3_0.but42 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but42 103} \
        -pady 0 -text {  } 
    button $site_3_0.but43 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but43 104} \
        -pady 0 -text {  } 
    button $site_3_0.but44 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but44 105} \
        -pady 0 -text {  } 
    button $site_3_0.but45 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but45 106} \
        -pady 0 -text {  } 
    button $site_3_0.but46 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but46 107} \
        -pady 0 -text {  } 
    button $site_3_0.but47 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but47 108} \
        -pady 0 -text {  } 
    button $site_3_0.but48 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but48 109} \
        -pady 0 -text {  } 
    button $site_3_0.but49 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but49 110} \
        -pady 0 -text {  } 
    button $site_3_0.but50 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but50 111} \
        -pady 0 -text {  } 
    button $site_3_0.but51 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but51 112} \
        -pady 0 -text {  } 
    button $site_3_0.but70 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but70 113} \
        -pady 0 -text {  } 
    button $site_3_0.but71 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but71 114} \
        -pady 0 -text {  } 
    button $site_3_0.but72 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but72 115} \
        -pady 0 -text {  } 
    button $site_3_0.but73 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but73 116} \
        -pady 0 -text {  } 
    button $site_3_0.but74 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but74 117} \
        -pady 0 -text {  } 
    button $site_3_0.but75 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but75 118} \
        -pady 0 -text {  } 
    button $site_3_0.but76 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but76 119} \
        -pady 0 -text {  } 
    button $site_3_0.but77 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but77 120} \
        -pady 0 -text {  } 
    button $site_3_0.but78 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but78 121} \
        -pady 0 -text {  } 
    button $site_3_0.but79 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but79 122} \
        -pady 0 -text {  } 
    button $site_3_0.but80 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but80 123} \
        -pady 0 -text {  } 
    button $site_3_0.but83 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but83 124} \
        -pady 0 -text {  } 
    button $site_3_0.but84 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but84 125} \
        -pady 0 -text {  } 
    button $site_3_0.but85 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but85 126} \
        -pady 0 -text {  } 
    button $site_3_0.but86 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but86 127} \
        -pady 0 -text {  } 
    button $site_3_0.but87 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra91.but87 128} \
        -pady 0 -text {  } 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra92 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame294" vTcl:WidgetProc "Toplevel62" 1
    set site_3_0 $top.fra92
    button $site_3_0.but36 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but36 129} \
        -pady 0 -text {  } 
    button $site_3_0.but37 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but37 130} \
        -pady 0 -text {  } 
    button $site_3_0.but38 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but38 131} \
        -pady 0 -text {  } 
    button $site_3_0.but39 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but39 132} \
        -pady 0 -text {  } 
    button $site_3_0.but40 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but40 133} \
        -pady 0 -text {  } 
    button $site_3_0.but41 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but41 134} \
        -pady 0 -text {  } 
    button $site_3_0.but42 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but42 135} \
        -pady 0 -text {  } 
    button $site_3_0.but43 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but43 136} \
        -pady 0 -text {  } 
    button $site_3_0.but44 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but44 137} \
        -pady 0 -text {  } 
    button $site_3_0.but45 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but45 138} \
        -pady 0 -text {  } 
    button $site_3_0.but46 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but46 139} \
        -pady 0 -text {  } 
    button $site_3_0.but47 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but47 140} \
        -pady 0 -text {  } 
    button $site_3_0.but48 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but48 141} \
        -pady 0 -text {  } 
    button $site_3_0.but49 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but49 142} \
        -pady 0 -text {  } 
    button $site_3_0.but50 \
        \
        -command {global BMPCanvas
 
UpdateColorMap $widget($BMPCanvas) .top62.fra92.but50 143} \
        -pady 0 -text {  } 
    button $site_3_0.but51 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but51 144} \
        -pady 0 -text {  } 
    button $site_3_0.but70 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but70 145} \
        -pady 0 -text {  } 
    button $site_3_0.but71 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but71 146} \
        -pady 0 -text {  } 
    button $site_3_0.but72 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but72 147} \
        -pady 0 -text {  } 
    button $site_3_0.but73 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but73 148} \
        -pady 0 -text {  } 
    button $site_3_0.but74 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but74 149} \
        -pady 0 -text {  } 
    button $site_3_0.but75 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but75 150} \
        -pady 0 -text {  } 
    button $site_3_0.but76 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but76 151} \
        -pady 0 -text {  } 
    button $site_3_0.but77 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but77 152} \
        -pady 0 -text {  } 
    button $site_3_0.but78 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but78 153} \
        -pady 0 -text {  } 
    button $site_3_0.but79 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but79 154} \
        -pady 0 -text {  } 
    button $site_3_0.but80 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but80 155} \
        -pady 0 -text {  } 
    button $site_3_0.but83 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but83 156} \
        -pady 0 -text {  } 
    button $site_3_0.but84 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but84 157} \
        -pady 0 -text {  } 
    button $site_3_0.but85 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but85 158} \
        -pady 0 -text {  } 
    button $site_3_0.but86 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but86 159} \
        -pady 0 -text {  } 
    button $site_3_0.but87 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra92.but87 160} \
        -pady 0 -text {  } 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra93 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra93" "Frame295" vTcl:WidgetProc "Toplevel62" 1
    set site_3_0 $top.fra93
    button $site_3_0.but36 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but36 161} \
        -pady 0 -text {  } 
    button $site_3_0.but37 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but37 162} \
        -pady 0 -text {  } 
    button $site_3_0.but38 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but38 163} \
        -pady 0 -text {  } 
    button $site_3_0.but39 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but39 164} \
        -pady 0 -text {  } 
    button $site_3_0.but40 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but40 165} \
        -pady 0 -text {  } 
    button $site_3_0.but41 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but41 166} \
        -pady 0 -text {  } 
    button $site_3_0.but42 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but42 167} \
        -pady 0 -text {  } 
    button $site_3_0.but43 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but43 168} \
        -pady 0 -text {  } 
    button $site_3_0.but44 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but44 169} \
        -pady 0 -text {  } 
    button $site_3_0.but45 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but45 170} \
        -pady 0 -text {  } 
    button $site_3_0.but46 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but46 171} \
        -pady 0 -text {  } 
    button $site_3_0.but47 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but47 172} \
        -pady 0 -text {  } 
    button $site_3_0.but48 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but48 173} \
        -pady 0 -text {  } 
    button $site_3_0.but49 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but49 174} \
        -pady 0 -text {  } 
    button $site_3_0.but50 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but50 175} \
        -pady 0 -text {  } 
    button $site_3_0.but51 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but51 176} \
        -pady 0 -text {  } 
    button $site_3_0.but70 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but70 177} \
        -pady 0 -text {  } 
    button $site_3_0.but71 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but71 178} \
        -pady 0 -text {  } 
    button $site_3_0.but72 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but72 179} \
        -pady 0 -text {  } 
    button $site_3_0.but73 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but73 180} \
        -pady 0 -text {  } 
    button $site_3_0.but74 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but74 181} \
        -pady 0 -text {  } 
    button $site_3_0.but75 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but75 182} \
        -pady 0 -text {  } 
    button $site_3_0.but76 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but76 183} \
        -pady 0 -text {  } 
    button $site_3_0.but77 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but77 184} \
        -pady 0 -text {  } 
    button $site_3_0.but78 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but78 185} \
        -pady 0 -text {  } 
    button $site_3_0.but79 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but79 186} \
        -pady 0 -text {  } 
    button $site_3_0.but80 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but80 187} \
        -pady 0 -text {  } 
    button $site_3_0.but83 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but83 188} \
        -pady 0 -text {  } 
    button $site_3_0.but84 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but84 189} \
        -pady 0 -text {  } 
    button $site_3_0.but85 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but85 190} \
        -pady 0 -text {  } 
    button $site_3_0.but86 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but86 191} \
        -pady 0 -text {  } 
    button $site_3_0.but87 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra93.but87 192} \
        -pady 0 -text {  } 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra94 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra94" "Frame296" vTcl:WidgetProc "Toplevel62" 1
    set site_3_0 $top.fra94
    button $site_3_0.but36 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but36 193} \
        -pady 0 -text {  } 
    button $site_3_0.but37 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but37 194} \
        -pady 0 -text {  } 
    button $site_3_0.but38 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but38 195} \
        -pady 0 -text {  } 
    button $site_3_0.but39 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but39 196} \
        -pady 0 -text {  } 
    button $site_3_0.but40 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but40 197} \
        -pady 0 -text {  } 
    button $site_3_0.but41 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but41 198} \
        -pady 0 -text {  } 
    button $site_3_0.but42 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but42 199} \
        -pady 0 -text {  } 
    button $site_3_0.but43 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but43 200} \
        -pady 0 -text {  } 
    button $site_3_0.but44 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but44 201} \
        -pady 0 -text {  } 
    button $site_3_0.but45 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but45 202} \
        -pady 0 -text {  } 
    button $site_3_0.but46 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but46 203} \
        -pady 0 -text {  } 
    button $site_3_0.but47 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but47 204} \
        -pady 0 -text {  } 
    button $site_3_0.but48 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but48 205} \
        -pady 0 -text {  } 
    button $site_3_0.but49 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but49 206} \
        -pady 0 -text {  } 
    button $site_3_0.but50 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but50 207} \
        -pady 0 -text {  } 
    button $site_3_0.but51 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but51 208} \
        -pady 0 -text {  } 
    button $site_3_0.but70 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but70 209} \
        -pady 0 -text {  } 
    button $site_3_0.but71 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but71 210} \
        -pady 0 -text {  } 
    button $site_3_0.but72 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but72 211} \
        -pady 0 -text {  } 
    button $site_3_0.but73 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but73 212} \
        -pady 0 -text {  } 
    button $site_3_0.but74 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but74 213} \
        -pady 0 -text {  } 
    button $site_3_0.but75 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but75 214} \
        -pady 0 -text {  } 
    button $site_3_0.but76 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but76 215} \
        -pady 0 -text {  } 
    button $site_3_0.but77 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but77 216} \
        -pady 0 -text {  } 
    button $site_3_0.but78 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but78 217} \
        -pady 0 -text {  } 
    button $site_3_0.but79 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but79 218} \
        -pady 0 -text {  } 
    button $site_3_0.but80 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but80 219} \
        -pady 0 -text {  } 
    button $site_3_0.but83 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but83 220} \
        -pady 0 -text {  } 
    button $site_3_0.but84 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but84 221} \
        -pady 0 -text {  } 
    button $site_3_0.but85 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but85 222} \
        -pady 0 -text {  } 
    button $site_3_0.but86 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but86 223} \
        -pady 0 -text {  } 
    button $site_3_0.but87 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra94.but87 224} \
        -pady 0 -text {  } 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra95 \
        -borderwidth 2 -cursor {} -height 75 -width 125 
    vTcl:DefineAlias "$top.fra95" "Frame297" vTcl:WidgetProc "Toplevel62" 1
    set site_3_0 $top.fra95
    button $site_3_0.but36 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but36 225} \
        -pady 0 -text {  } 
    button $site_3_0.but37 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but37 226} \
        -pady 0 -text {  } 
    button $site_3_0.but38 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but38 227} \
        -pady 0 -text {  } 
    button $site_3_0.but39 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but39 228} \
        -pady 0 -text {  } 
    button $site_3_0.but40 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but40 229} \
        -pady 0 -text {  } 
    button $site_3_0.but41 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but41 230} \
        -pady 0 -text {  } 
    button $site_3_0.but42 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but42 231} \
        -pady 0 -text {  } 
    button $site_3_0.but43 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but43 232} \
        -pady 0 -text {  } 
    button $site_3_0.but44 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but44 233} \
        -pady 0 -text {  } 
    button $site_3_0.but45 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but45 234} \
        -pady 0 -text {  } 
    button $site_3_0.but46 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but46 235} \
        -pady 0 -text {  } 
    button $site_3_0.but47 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but47 236} \
        -pady 0 -text {  } 
    button $site_3_0.but48 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but48 237} \
        -pady 0 -text {  } 
    button $site_3_0.but49 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but49 238} \
        -pady 0 -text {  } 
    button $site_3_0.but50 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but50 239} \
        -pady 0 -text {  } 
    button $site_3_0.but51 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but51 240} \
        -pady 0 -text {  } 
    button $site_3_0.but70 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but70 241} \
        -pady 0 -text {  } 
    button $site_3_0.but71 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but71 242} \
        -pady 0 -text {  } 
    button $site_3_0.but72 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but72 243} \
        -pady 0 -text {  } 
    button $site_3_0.but73 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but73 244} \
        -pady 0 -text {  } 
    button $site_3_0.but74 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but74 245} \
        -pady 0 -text {  } 
    button $site_3_0.but75 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but75 246} \
        -pady 0 -text {  } 
    button $site_3_0.but76 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but76 247} \
        -pady 0 -text {  } 
    button $site_3_0.but77 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but77 248} \
        -pady 0 -text {  } 
    button $site_3_0.but78 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but78 249} \
        -pady 0 -text {  } 
    button $site_3_0.but79 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but79 250} \
        -pady 0 -text {  } 
    button $site_3_0.but80 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but80 251} \
        -pady 0 -text {  } 
    button $site_3_0.but83 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but83 252} \
        -pady 0 -text {  } 
    button $site_3_0.but84 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but84 253} \
        -pady 0 -text {  } 
    button $site_3_0.but85 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but85 254} \
        -pady 0 -text {  } 
    button $site_3_0.but86 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but86 255} \
        -pady 0 -text {  } 
    button $site_3_0.but87 \
        \
        -command {global BMPCanvas

UpdateColorMap $widget($BMPCanvas) .top62.fra95.but87 256} \
        -pady 0 -text {  } 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra35 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra89 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra90 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra91 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra92 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra93 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra94 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra95 \
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
Window show .top62

main $argc $argv
