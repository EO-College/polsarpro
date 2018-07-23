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

        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images cv_small.png]} {user image} user {}}

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
    set base .top395
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -activebackground 1 -activeforeground 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -takefocus 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -activebackground 1 -activeforeground 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$base.fra55 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra55
    namespace eval ::widgets::$site_3_0.fra84 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra84
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd87
    namespace eval ::widgets::$site_5_0.cpd126 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd126
    namespace eval ::widgets::$site_6_0.cpd124 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd125 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd118 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd118
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra90 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.fra90
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd119
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra90 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.fra90
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd121 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd121
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra90 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.fra90
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd86
    namespace eval ::widgets::$site_5_0.cpd126 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd126
    namespace eval ::widgets::$site_6_0.cpd124 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd125 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd118 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd118
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra90 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.fra90
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd119
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra90 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.fra90
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd121 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd121
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra90 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.fra90
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-activebackground 1 -activeforeground 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-activebackground 1 -activeforeground 1 -borderwidth 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra81 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra81
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd83
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd88 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd88
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-activebackground 1 -activeforeground 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-activebackground 1 -activeforeground 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top395
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
    wm maxsize $top 1676 1024
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

proc vTclWindow.top395 {base} {
    if {$base == ""} {
        set base .top395
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -highlightcolor black 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 480x230+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "SVM RBF Kernel Parameters Optimisation (Cross Validation)"
    vTcl:DefineAlias "$top" "Toplevel395" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra59 \
        -relief groove -height 35 -highlightcolor black -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel395" 1
    set site_3_0 $top.fra59
    button $site_3_0.but23 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/data_process_sngl/SVMSupervisedClassification.pdf"} \
        -foreground SystemButtonText -highlightcolor SystemWindowFrame \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -takefocus 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel395" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -background #ffff00 \
        -command {WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"
$widget(Button394_1) configure -state normal
Window hide $widget(Toplevel395); TextEditorRunTrace "Close Window SVM RBF Cross Validation" "b"} \
        -foreground black -highlightcolor black -padx 4 -pady 2 -takefocus 0 \
        -text {Exit and Save CV Parameters} 
    vTcl:DefineAlias "$site_3_0.but24" "Button395_1" vTcl:WidgetProc "Toplevel395" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra55 \
        -borderwidth 1 -relief groove -height 300 -highlightcolor black \
        -width 200 
    vTcl:DefineAlias "$top.fra55" "Frame9" vTcl:WidgetProc "Toplevel395" 1
    set site_3_0 $top.fra55
    frame $site_3_0.fra84 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_3_0.fra84" "Frame1" vTcl:WidgetProc "Toplevel395" 1
    set site_4_0 $site_3_0.fra84
    frame $site_4_0.cpd87 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_4_0.cpd87" "Frame51" vTcl:WidgetProc "Toplevel395" 1
    set site_5_0 $site_4_0.cpd87
    frame $site_5_0.cpd126 \
        -relief groove -height 75 -highlightcolor black -width 150 
    vTcl:DefineAlias "$site_5_0.cpd126" "Frame5" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd126
    label $site_6_0.cpd124 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text Log2(C) 
    vTcl:DefineAlias "$site_6_0.cpd124" "Label139" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd125 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text C 
    vTcl:DefineAlias "$site_6_0.cpd125" "Label140" vTcl:WidgetProc "Toplevel395" 1
    pack $site_6_0.cpd124 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd125 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 5 -padx 15 \
        -side left 
    frame $site_5_0.cpd118 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd118" "Frame52" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd118
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable CBegin -width 7 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry62" vTcl:WidgetProc "Toplevel395" 1
    entry $site_6_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable Log2cBegin -width 2 
    vTcl:DefineAlias "$site_6_0.cpd88" "Entry63" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd70 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text {Min  } 
    vTcl:DefineAlias "$site_6_0.cpd70" "Label144" vTcl:WidgetProc "Toplevel395" 1
    frame $site_6_0.fra90 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_6_0.fra90" "Frame53" vTcl:WidgetProc "Toplevel395" 1
    set site_7_0 $site_6_0.fra90
    button $site_7_0.cpd92 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set VarError ""
set tmp [expr $Log2cBegin + 1]

if {$tmp > $Log2cEnd} {
	    set ErrorMessage "Log2(c) min need to be lower than Log2(C) max"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
#	    tkwait variable VarError
} else {
set Log2cBegin [expr $Log2cBegin + 1]
set CBegin [expr pow(2,$Log2cBegin)]
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.cpd92" "Button46" vTcl:WidgetProc "Toplevel395" 1
    button $site_7_0.cpd91 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2cBegin - 1]
set VarError 0

if {$tmp > $Log2cEnd } {
	    set ErrorMessage "Log2(c) min need to be lower than Log2(C) max"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            set VarError 1
#	    tkwait variable VarError
}
if {$tmp < 1 } {
	    set ErrorMessage "Log2(c) min need to be greater than 0"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            set VarError 1
#	    tkwait variable VarError
}

 if {$VarError == 0} {
set Log2cBegin [expr $Log2cBegin - 1]
set CBegin [expr pow(2,$Log2cBegin)]
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd91" "Button47" vTcl:WidgetProc "Toplevel395" 1
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra90 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd119 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd119" "Frame54" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd119
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable CEnd -width 7 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry64" vTcl:WidgetProc "Toplevel395" 1
    entry $site_6_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable Log2cEnd -width 2 
    vTcl:DefineAlias "$site_6_0.cpd88" "Entry65" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd71 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text {Max } 
    vTcl:DefineAlias "$site_6_0.cpd71" "Label145" vTcl:WidgetProc "Toplevel395" 1
    frame $site_6_0.fra90 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_6_0.fra90" "Frame55" vTcl:WidgetProc "Toplevel395" 1
    set site_7_0 $site_6_0.fra90
    button $site_7_0.cpd92 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2cEnd + 1]

if {$tmp > 16} {
	    set ErrorMessage "Log2(c) max dont exceed 16, could be to much time consuming"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
} else {
set Log2cEnd [expr $Log2cEnd + 1]
set CEnd [expr pow(2,$Log2cEnd)]
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.cpd92" "Button48" vTcl:WidgetProc "Toplevel395" 1
    button $site_7_0.cpd91 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2cEnd - 1]
set VarError 0

if {$tmp < $Log2cBegin } {
	    set ErrorMessage "Log2(c) max need to be greater than Log2(C) min"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            set VarError 1
#	    tkwait variable VarError
}
if {$tmp < 1 } {
	    set ErrorMessage "Log2(c) max need to be greater than 0"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            set VarError 1
#	    tkwait variable VarError
}

 if {$VarError == 0} {
set Log2cEnd $tmp
set CEnd [expr pow(2,$Log2cEnd)]
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd91" "Button49" vTcl:WidgetProc "Toplevel395" 1
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra90 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd121 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd121" "Frame56" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd121
    entry $site_6_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable Log2cStep -width 2 
    vTcl:DefineAlias "$site_6_0.cpd88" "Entry67" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd72 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text Step 
    vTcl:DefineAlias "$site_6_0.cpd72" "Label146" vTcl:WidgetProc "Toplevel395" 1
    frame $site_6_0.fra90 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_6_0.fra90" "Frame57" vTcl:WidgetProc "Toplevel395" 1
    set site_7_0 $site_6_0.fra90
    button $site_7_0.cpd92 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2cStep + 1]

if {$tmp > 4} {
	    set ErrorMessage "Log2(c) Step is to big"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
} else {
set Log2cStep $tmp
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.cpd92" "Button50" vTcl:WidgetProc "Toplevel395" 1
    button $site_7_0.cpd91 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2cStep - 1]

if {$tmp < 1} {
	    set ErrorMessage "Log2(c) Step is to low"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
} else {
set Log2cStep $tmp
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd91" "Button51" vTcl:WidgetProc "Toplevel395" 1
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra90 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd126 \
        -in $site_5_0 -anchor e -expand 0 -fill none -side top 
    pack $site_5_0.cpd118 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    pack $site_5_0.cpd121 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    frame $site_4_0.cpd86 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_4_0.cpd86" "Frame58" vTcl:WidgetProc "Toplevel395" 1
    set site_5_0 $site_4_0.cpd86
    frame $site_5_0.cpd126 \
        -relief groove -height 75 -highlightcolor black -width 150 
    vTcl:DefineAlias "$site_5_0.cpd126" "Frame6" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd126
    label $site_6_0.cpd124 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text Log2(G) 
    vTcl:DefineAlias "$site_6_0.cpd124" "Label141" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd125 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text G 
    vTcl:DefineAlias "$site_6_0.cpd125" "Label142" vTcl:WidgetProc "Toplevel395" 1
    pack $site_6_0.cpd124 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd125 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 5 -padx 18 \
        -side left 
    frame $site_5_0.cpd118 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd118" "Frame59" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd118
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable GBegin -width 7 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry68" vTcl:WidgetProc "Toplevel395" 1
    entry $site_6_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable Log2gBegin -width 2 
    vTcl:DefineAlias "$site_6_0.cpd88" "Entry69" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd73 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text {Min  } 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label147" vTcl:WidgetProc "Toplevel395" 1
    frame $site_6_0.fra90 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_6_0.fra90" "Frame60" vTcl:WidgetProc "Toplevel395" 1
    set site_7_0 $site_6_0.fra90
    button $site_7_0.cpd92 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set VarError ""
set tmp [expr $Log2gBegin + 1]

if {$tmp > $Log2gEnd} {
	    set ErrorMessage "Log2(g) min need to be lower than Log2(g) max"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
#	    tkwait variable VarError
} else {
set Log2gBegin $tmp
set GBegin [expr pow(2,$Log2gBegin)]
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.cpd92" "Button52" vTcl:WidgetProc "Toplevel395" 1
    button $site_7_0.cpd91 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2gBegin - 1]
set VarError 0

if {$tmp > $Log2gEnd } {
	    set ErrorMessage "Log2(g) min need to be lower than Log2(g) max"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            set VarError 1
#	    tkwait variable VarError
}
if {$tmp < -6 } {
	    set ErrorMessage "Log2(c) min need to be greater than -6"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            set VarError 1
#	    tkwait variable VarError
}

 if {$VarError == 0} {
set Log2gBegin $tmp
set GBegin [expr pow(2,$Log2gBegin)]
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd91" "Button54" vTcl:WidgetProc "Toplevel395" 1
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra90 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd119 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd119" "Frame61" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd119
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable GEnd -width 7 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry70" vTcl:WidgetProc "Toplevel395" 1
    entry $site_6_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable Log2gEnd -width 2 
    vTcl:DefineAlias "$site_6_0.cpd88" "Entry71" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd74 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text {Max } 
    vTcl:DefineAlias "$site_6_0.cpd74" "Label151" vTcl:WidgetProc "Toplevel395" 1
    frame $site_6_0.fra90 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_6_0.fra90" "Frame62" vTcl:WidgetProc "Toplevel395" 1
    set site_7_0 $site_6_0.fra90
    button $site_7_0.cpd92 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2gEnd + 1]

if {$tmp > 1} {
	    set ErrorMessage "Log2(g) max dont exceed 1"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
} else {
set Log2gEnd $tmp
set GEnd [expr pow(2,$Log2gEnd)]
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.cpd92" "Button55" vTcl:WidgetProc "Toplevel395" 1
    button $site_7_0.cpd91 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2gEnd - 1]
set VarError 0

if {$tmp < $Log2gBegin } {
	    set ErrorMessage "Log2(g) max need to be greater than Log2(g) min"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            set VarError 1
#	    tkwait variable VarError
}
if {$tmp < -6 } {
	    set ErrorMessage "Log2(c) max need to be greater than -6"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            set VarError 1
#	    tkwait variable VarError
}

 if {$VarError == 0} {
set Log2gEnd $tmp
set GEnd [expr pow(2,$Log2gEnd)]
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd91" "Button56" vTcl:WidgetProc "Toplevel395" 1
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra90 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd121 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd121" "Frame63" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd121
    entry $site_6_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable Log2gStep -width 2 
    vTcl:DefineAlias "$site_6_0.cpd88" "Entry73" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd75 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text Step 
    vTcl:DefineAlias "$site_6_0.cpd75" "Label152" vTcl:WidgetProc "Toplevel395" 1
    frame $site_6_0.fra90 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_6_0.fra90" "Frame64" vTcl:WidgetProc "Toplevel395" 1
    set site_7_0 $site_6_0.fra90
    button $site_7_0.cpd92 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2gStep + 1]

if {$tmp > 4} {
	    set ErrorMessage "Log2(g) Step is to big"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
} else {
set Log2gStep $tmp
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.cpd92" "Button57" vTcl:WidgetProc "Toplevel395" 1
    button $site_7_0.cpd91 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -command {global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

set tmp [expr $Log2gStep - 1]

if {$tmp < 1} {
	    set ErrorMessage "Log2(g) Step is to low"
	    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
} else {
set Log2gStep $tmp
}} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd91" "Button58" vTcl:WidgetProc "Toplevel395" 1
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra90 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd126 \
        -in $site_5_0 -anchor e -expand 0 -fill none -side top 
    pack $site_5_0.cpd118 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    pack $site_5_0.cpd121 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    button $site_4_0.cpd85 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -borderwidth 0 -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images cv_small.png]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd85" "Button1" vTcl:WidgetProc "Toplevel395" 1
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.fra81 \
        -relief groove -height 75 -highlightcolor black -width 150 
    vTcl:DefineAlias "$site_3_0.fra81" "Frame2" vTcl:WidgetProc "Toplevel395" 1
    set site_4_0 $site_3_0.fra81
    frame $site_4_0.cpd83 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_4_0.cpd83" "Frame7" vTcl:WidgetProc "Toplevel395" 1
    set site_5_0 $site_4_0.cpd83
    label $site_5_0.cpd80 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text {One best couple (C,G)} 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label148" vTcl:WidgetProc "Toplevel395" 1
    frame $site_5_0.cpd88 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd88" "Frame8" vTcl:WidgetProc "Toplevel395" 1
    set site_6_0 $site_5_0.cpd88
    label $site_6_0.cpd82 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text C 
    vTcl:DefineAlias "$site_6_0.cpd82" "Label149" vTcl:WidgetProc "Toplevel395" 1
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable BestRBFGamma -width 5 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry79" vTcl:WidgetProc "Toplevel395" 1
    label $site_6_0.cpd84 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -foreground black -highlightcolor black -text G 
    vTcl:DefineAlias "$site_6_0.cpd84" "Label150" vTcl:WidgetProc "Toplevel395" 1
    entry $site_6_0.cpd83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable BestCostVal -width 5 
    vTcl:DefineAlias "$site_6_0.cpd83" "Entry78" vTcl:WidgetProc "Toplevel395" 1
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd88 \
        -in $site_5_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    button $site_4_0.cpd71 \
        -activebackground SystemButtonFace -activeforeground SystemButtonText \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_4_0.cpd71 {global SupervisedDirInput SupervisedDirOutput SupervisedOutputDir SupervisedOutputSubDir SupervisedTrainingProcess
global SupervisedClusterFonction SupervisedSVMClassifierFonction WriteBestCVResultsFunction SupervisedClassifierConfusionMatrixFonction
global BMPSupervised ColorMapSupervised16 FileTrainingArea
global RejectClass RejectRatio ConfusionMatrix Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile  DataDir

global SVMBatch  TMPScriptSVM  TMPTrainingSetNorm  TMPTrainingSet SVMConfigFile SVMRangeFile SVMModelFile ClassificationFile
global TMPSVMRange TMPSVMConfig
global TrainingSamplingVal TrainingSampling UnbalanceTraining OldModel NewModel
global CostVal PolyDeg PolyDegVar RBFGamma RBFGammaVar 
global RBFCV Kernel TMPSVMBestCG
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep
global ProbOut DistOut SVMColorMapSupervised16

global PolarIndic PolarFiles Npolar PolarIndicSaveList PolarIndicFloatNum

set WriteBestCVResultsFunction "Soft/SVM/write_best_cv_results.exe"

set PolsarProDir [pwd]; append PolsarProDir "/"

set SessionYear [clock format [clock seconds] -format "%Y"]
set SessionMonth [clock format [clock seconds] -format "%m"]
set SessionDay [clock format [clock seconds] -format "%d"]
set SessionHour [clock format [clock seconds] -format "%H"]
set SessionMinute [clock format [clock seconds] -format "%M"]
set SessionSecond [clock format [clock seconds] -format "%S"]
set SessionName $SessionYear;append SessionName "_$SessionMonth";append SessionName "_$SessionDay"
append SessionName "_$SessionHour";append SessionName "_$SessionMinute";append SessionName "_$SessionSecond"

set SVMBatch "0"
set NewModel "1"
set RBFCV "1"
set PolyDeg "DISABLE"
set RBFGamma "DISABLE"
set PolyDegVar ""
set RBFGammaVar ""

set Date [clock format [clock seconds] -format "%A %d %B %Y"]

if {$OpenDirFile == 0} {

set config "true"

if {$config == "true"} {

    if {$SupervisedTrainingProcess == 0} {
        set SupervisedDirOutput $SupervisedOutputDir 
        if {$SupervisedOutputSubDir != ""} {append SupervisedDirOutput "/$SupervisedOutputSubDir"}
        }
        
    #####################################################################
    #Create Directory
    set SupervisedDirOutput [PSPCreateDirectoryMask $SupervisedDirOutput $SupervisedOutputDir $SupervisedDirInput]
    #####################################################################       

    set SVMSupervisedDirInput "$SupervisedDirInput/"
    set SVMSupervisedDirOutput "$SupervisedDirOutput/"
    set SVMColorMapSupervised16 $ColorMapSupervised16
    set SVMConfigFile "$TMPSVMConfig"
    set SVMRangeFile  "$TMPSVMRange"
    set SVMModelFile "$SupervisedDirOutput/"; append SVMModelFile "svm_model_file_$SessionName.txt"
    set ClassificationFile "$SupervisedDirOutput/"; append ClassificationFile "svm_classification_file_$SessionName.bin"
    


if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    if {$RejectClass == "0"} {set RejectRatio "0.0"}

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Reject Ratio"; set TestVarType(4) "float"; set TestVarValue(4) $RejectRatio; set TestVarMin(4) ""; set TestVarMax(4) ""
    set TestVarName(5) "ColorMap16"; set TestVarType(5) "file"; set TestVarValue(5) $ColorMapSupervised16; set TestVarMin(5) ""; set TestVarMax(5) ""
    set TestVarName(6) "Cost"; set TestVarType(6) "int"; set TestVarValue(6) $CostVal; set TestVarMin(6) "1"; set TestVarMax(6) 131072
    set TestVarName(7) "Training Sampling Value"; set TestVarType(7) "int"; set TestVarValue(7) $TrainingSamplingVal; set TestVarMin(7) 100; set TestVarMax(7) 6000
 
  if {$PolarIndic == "Ipp"} {
    set Npolar "4"
    set PolarFiles "I11.bin I22.bin I12.bin I21.bin"
    }

  if {$PolarIndic == "C2"} {
    set Npolar "4"
    set PolarFiles "C11.bin C22.bin C12_real.bin C12_imag.bin"
    }
  if {$PolarIndic == "C3"} {
    set Npolar "9"
    set PolarFiles "C11.bin C22.bin C33.bin C12_real.bin C12_imag.bin C13_real.bin C13_imag.bin C23_real.bin C23_imag.bin"
    }
  if {$PolarIndic == "C4"} {
    set Npolar "16"
    set PolarFiles "C11.bin C22.bin C33.bin C44.bin C12_real.bin C12_imag.bin C13_real.bin C13_imag.bin C14_real.bin C14_imag.bin C23_real.bin C23_imag.bin C24_real.bin C24_imag.bin C34_real.bin C34_imag.bin"
    }
    
  if {$PolarIndic == "T3"} {
    set Npolar "9"
    set PolarFiles "T11.bin T22.bin T33.bin T12_real.bin T12_imag.bin T13_real.bin T13_imag.bin T23_real.bin T23_imag.bin"
    }
    
  if {$PolarIndic == "T4"} {
    set Npolar "16"
    set PolarFiles "T11.bin T22.bin T33.bin T44.bin T12_real.bin T12_imag.bin T13_real.bin T13_imag.bin T14_real.bin T14_imag.bin T23_real.bin T23_imag.bin T24_real.bin T24_imag.bin T34_real.bin T34_imag.bin"
    }
    
  if {$PolarIndic == "Other"} {
    if {$Npolar == "0"} { 
      set VarError ""
      set ErrorMessage "INVALID Input Polarimetric Indicators"
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      }
    }

  if {$TrainingSampling == "0"} {
    set TrainingSamplingVal "0"
    }

    TestVar 8

#    set $TestVarError "ok"
    if {$TestVarError == "ok"} {

    WidgetShowTop399; TextEditorRunTrace "Open Window Processing" "b"

# Je teste si l'utilisateur à bien creer le fichier des zones d'entrainement
    if [file exists $FileTrainingArea] {
        DeleteFile $TMPSVMBestCG
        set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
        set Fonction ""; set Fonction2 "SVM RBF Cross Validation"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function $SupervisedSVMClassifierFonction" "k"
        TextEditorRunTrace "Arguments: $SVMBatch \x22$PolsarProDir\x22 \x22$TMPScriptSVM\x22 \x22$SVMSupervisedDirInput\x22 $BMPSupervised \x22$SVMColorMapSupervised16\x22 \x22$SVMConfigFile\x22 \x22$MaskFile\x22 \x22$SVMSupervisedDirOutput\x22 \x22$FileTrainingArea\x22 \x22$TMPTrainingSet\x22 \x22$SVMRangeFile\x22 \x22$TMPTrainingSetNorm\x22 \x22$SVMModelFile\x22 \x22$ClassificationFile\x22 $TrainingSamplingVal $UnbalanceTraining $NewModel $RBFCV $Log2cBegin $Log2cEnd $Log2cStep $Log2gBegin $Log2gEnd $Log2gStep $Kernel $CostVal $PolyDeg $RBFGamma $ProbOut $DistOut $Npolar $PolarFiles" "k"
	set f [ open "| $SupervisedSVMClassifierFonction $SVMBatch \x22$PolsarProDir\x22 \x22$TMPScriptSVM\x22 \x22$SVMSupervisedDirInput\x22 $BMPSupervised \x22$SVMColorMapSupervised16\x22 \x22$SVMConfigFile\x22 \x22$MaskFile\x22 \x22$SVMSupervisedDirOutput\x22 \x22$FileTrainingArea\x22 \x22$TMPTrainingSet\x22 \x22$SVMRangeFile\x22 \x22$TMPTrainingSetNorm\x22 \x22$SVMModelFile\x22 \x22$ClassificationFile\x22 $TrainingSamplingVal $UnbalanceTraining $NewModel $RBFCV $Log2cBegin $Log2cEnd $Log2cStep $Log2gBegin $Log2gEnd $Log2gStep $Kernel $CostVal $PolyDeg $RBFGamma $ProbOut $DistOut $Npolar $PolarFiles" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        TextEditorRunTrace "Process The Function $WriteBestCVResultsFunction" "k"     
        TextEditorRunTrace "Arguments: \x22$SVMSupervisedDirInput\x22 \x22$TMPSVMBestCG\x22" "k"
        set f [ open "| $WriteBestCVResultsFunction \x22$SVMSupervisedDirInput\x22 \x22$TMPSVMBestCG\x22" r] 
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        
        TextEditorRunTrace "Process The Function Read best CV" "k"     
        WaitUntilCreated $TMPSVMBestCG
        if [file exists $TMPSVMBestCG] {
       	  set fileID [open $TMPSVMBestCG r]
       	  set fileData [read $fileID]
          set fileLines [split $fileData "\n"]
          set i 0
          foreach line $fileLines {
            if {$i == 0} {set BestCostVal [expr int($line)]}
              if {$i == 1} {set BestRBFGamma $line}	
	      incr i 
              }
            set CostVal $BestCostVal
            set RBFGamma $BestRBFGamma
            set RBFGammaVar $BestRBFGamma
            close $fileID
            }

        WidgetShowFromWidget .top394 .top395     

        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        } else {
        set ErrorMessage "TRAINING AREAS OVERLAPPED" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

      WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"
      $widget(Button395_1) configure -state normal
      }

    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel395); TextEditorRunTrace "Close Window SVM RBF Cross Validation" "b"}
    }
  }
}}] \
        -foreground black -highlightcolor black -padx 4 -pady 2 -takefocus 0 \
        -text {Run RBF Kernel Parameters Optimisation} 
    vTcl:DefineAlias "$site_4_0.cpd71" "Button17" vTcl:WidgetProc "Toplevel395" 1
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -ipadx 3 \
        -side right 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra84 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    pack $site_3_0.fra81 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipadx 50 -ipady 5 \
        -side top 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -side bottom 
    pack $top.fra55 \
        -in $top -anchor center -expand 1 -fill both -side top 

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
Window show .top395

main $argc $argv
