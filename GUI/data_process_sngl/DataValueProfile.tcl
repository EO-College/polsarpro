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

        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images GIMPshortcut.gif]} {user image} user {}}

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
    set base .top257
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd94 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd94 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd99 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd99
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd78
    namespace eval ::widgets::$site_4_0.can73 {
        array set save {-borderwidth 1 -closeenough 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd80 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra84
    namespace eval ::widgets::$site_8_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra85
    namespace eval ::widgets::$site_8_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.fra87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra87
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd73 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra84
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.but86 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd87 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra85
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd88 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd89 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra81
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd70
    namespace eval ::widgets::$site_7_0.cpd82 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1}
    }
    namespace eval ::widgets::$site_7_0.cpd83 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd86 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra84
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd71
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd72
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra84
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra85
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd78 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra85
    namespace eval ::widgets::$site_8_0.rad79 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd84 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd85
    namespace eval ::widgets::$site_8_0.rad79 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd84 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra84
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd71
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd72
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra84
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd71
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd89 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd89
    namespace eval ::widgets::$site_8_0.rad78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd90 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.but80 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd93 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra84
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m71 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top257
            ProfileInitWidget
            ProfileReset
            ProfileCreateShowValue
            ProfileExtractData
            ProfileFileOpenClose
            ProfileInitWindow
            ProfileCreateXYBin
            ProfilePlot1D
            ProfilePlot3D
            ProfilePlot1DThumb
            ProfilePlot3DThumb
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
## Procedure:  ProfileInitWidget

proc ::ProfileInitWidget {} {
global TF257 But257 CBut257 RBut257 Lbl257 Ent257

set TF257(0) 0
set TF257(1) .top257.fra71.cpd78.cpd71.cpd73
set TF257(2) .top257.fra71.fra72.cpd90
set TF257(3) .top257.fra71.fra72.cpd77
set TF257(4) .top257.fra71.fra72.cpd78
set TF257(5) .top257.fra71.fra72.cpd93
set TF257(6) .top257.fra71.fra72.cpd86

set But257(0) 0
set But257(1) .top257.fra71.cpd78.cpd71.cpd73.f.cpd75.fra84.but86
set But257(2) .top257.fra71.cpd78.cpd71.cpd73.f.cpd75.fra84.cpd87
set But257(3) .top257.fra71.cpd78.cpd71.cpd73.f.cpd75.fra85.cpd88
set But257(4) .top257.fra71.cpd78.cpd71.cpd73.f.cpd75.fra85.cpd89
set But257(5) .top257.fra71.fra72.cpd90.f.but80
set But257(6) .top257.fra71.cpd78.cpd71.fra87.cpd88
set But257(7) .top257.fra71.cpd78.cpd71.fra81.cpd70.cpd82
set But257(8) .top257.fra71.cpd78.cpd71.fra81.cpd83
set But257(9) .top257.fra71.cpd78.cpd71.fra81.cpd70.cpd83

set CBut257(0) 0
set CBut257(1) .top257.fra71.fra72.cpd90.f.cpd74

set RBut257(0) 0
set RBut257(1) .top257.fra71.fra72.cpd77.f.cpd72.fra84.rad78
set RBut257(2) .top257.fra71.fra72.cpd77.f.cpd72.cpd71.rad78
set RBut257(3) .top257.fra71.fra72.cpd77.f.cpd72.cpd88.rad78
set RBut257(4) .top257.fra71.fra72.cpd77.f.cpd72.cpd89.rad78
set RBut257(5) .top257.fra71.fra72.cpd78.f.cpd75.cpd85.rad79
set RBut257(6) .top257.fra71.fra72.cpd78.f.cpd75.cpd85.cpd84
set RBut257(7) .top257.fra71.fra72.cpd77.f.cpd75.fra84.rad78
set RBut257(8) .top257.fra71.fra72.cpd77.f.cpd75.cpd71.rad78
set RBut257(9) .top257.fra71.fra72.cpd77.f.cpd75.cpd72.rad78
set RBut257(10) .top257.fra71.fra72.cpd78.f.cpd75.fra85.rad79
set RBut257(11) .top257.fra71.fra72.cpd78.f.cpd75.fra85.cpd80
set RBut257(12) .top257.fra71.fra72.cpd78.f.cpd75.fra85.cpd84
set RBut257(13) .top257.fra71.fra72.cpd78.f.cpd75.cpd85.cpd80
set RBut257(14) .top257.fra71.fra72.cpd86.f.cpd75.fra84.rad78
set RBut257(15) .top257.fra71.fra72.cpd86.f.cpd75.cpd71.rad78
set RBut257(16) .top257.fra71.fra72.cpd86.f.cpd75.cpd72.rad78

set Lbl257(0) 0
set Lbl257(3) .top257.fra71.fra72.cpd90.f.cpd76
set Lbl257(4) .top257.fra71.fra72.cpd90.f.cpd77
set Lbl257(5) .top257.fra71.fra72.cpd75.cpd76.f.cpd75.cpd77
set Lbl257(6) .top257.fra71.fra72.cpd71.cpd73.cpd95
set Lbl257(8) .top257.fra71.fra72.cpd71.cpd74.cpd95
 
set Ent257(0) 0
set Ent257(1) .top257.fra71.cpd78.cpd71.cpd73.f.cpd75.fra84.ent78
set Ent257(2) .top257.fra71.cpd78.cpd71.cpd73.f.cpd75.fra85.ent78
set Ent257(3) .top257.fra71.fra72.cpd90.f.cpd78
set Ent257(4) .top257.fra71.fra72.cpd90.f.cpd79
set Ent257(5) .top257.fra71.fra72.cpd75.cpd76.f.cpd75.cpd75
set Ent257(6) .top257.fra71.fra72.cpd71.cpd73.cpd97
set Ent257(7) .top257.fra71.fra72.cpd93.f.cpd75.fra84.ent78
set Ent257(8) .top257.fra71.fra72.cpd71.cpd74.cpd97
}
#############################################################################
## Procedure:  ProfileReset

proc ::ProfileReset {} {
global TF257 But257 CBut257 RBut257 Lbl257 Ent257
global ProfileFileInput ProfileFileOpen ProfileShow
global ProfileInputFormat ProfileOutputFormat
global MinMaxAutoProfile MinProfile MaxProfile
global ProfileRealValue ProfileImagValue ProfileShowValue
global GnuXview GnuZview ProfileLength PSPBackgroundColor
global ProfileRepresentation ProfileRepresentation3D
global NligInit NcolInit NligFullSize NcolFullSize
global GnuplotPipeFid GnuplotPipeProfile

if {$GnuplotPipeProfile != ""} {
    catch "close $GnuplotPipeProfile"
    set GnuplotPipeProfile ""
    }
set GnuplotPipeFid ""
Window hide .top401

set ProfileFileOpen 0

$TF257(1) configure -state disable
$Ent257(1) configure -state disable
$Ent257(1) configure -disabledbackground $PSPBackgroundColor
$Ent257(2) configure -state disable
$Ent257(2) configure -disabledbackground $PSPBackgroundColor
$But257(1) configure -state disable
$But257(2) configure -state disable
$But257(3) configure -state disable
$But257(4) configure -state disable
$TF257(3) configure -state disable
$RBut257(1) configure -state disable
$RBut257(2) configure -state disable
$RBut257(3) configure -state disable
$RBut257(4) configure -state disable
$RBut257(7) configure -state disable
$RBut257(8) configure -state disable
$RBut257(9) configure -state disable
$Lbl257(6) configure -state disable
$Ent257(6) configure -state disable
$Ent257(6) configure -disabledbackground $PSPBackgroundColor
$But257(6) configure -state disable
$But257(7) configure -state disable
$But257(8) configure -state disable
$But257(9) configure -state disable
set ProfileLength ""; set GnuXview ""; set GnuZview ""
set ProfileRepresentation ""; set ProfileRepresentation3D ""

set ProfileShow 0
set ProfileFileInput ""
$TF257(6) configure -state disable
$RBut257(14) configure -state disable
$RBut257(15) configure -state disable
$RBut257(16) configure -state disable
set NligInit ""; set NligEnd ""
set NcolInit ""; set NcolEnd ""
set NligFullSize ""; set NcolFullSize ""
set ProfileInputFormat ""
$TF257(4) configure -state disable
$RBut257(5) configure -state disable
$RBut257(6) configure -state disable
$RBut257(10) configure -state disable
$RBut257(11) configure -state disable
$RBut257(12) configure -state disable
$RBut257(13) configure -state disable
$Ent257(5) configure -disabledbackground $PSPBackgroundColor
$Lbl257(5) configure -state disable
set ProfileOutputFormat ""
$Ent257(8) configure -disabledbackground $PSPBackgroundColor
$Lbl257(8) configure -state disable
set MinMaxAutoProfile 0
set MinProfile ""; set MaxProfile ""
$TF257(2) configure -state disable
$CBut257(1) configure -state disable
$Lbl257(3) configure -state disable
$Ent257(3) configure -state disable
$Lbl257(4) configure -state disable
$Ent257(4) configure -state disable
$But257(5) configure -state disable
set ProfileRealValue ""; set ProfileImagValue ""
set ProfileShowValue ""
    
set GnuProfileTitle ""
$TF257(5) configure -state disable
$Ent257(7) configure -state disable
$Ent257(7) configure -disabledbackground $PSPBackgroundColor
}
#############################################################################
## Procedure:  ProfileCreateShowValue

proc ::ProfileCreateShowValue {} {
global ProfileInputFormat ProfileOutputFormat
global ProfileRealValue ProfileImagValue
global ProfileShowValue

set ProfileShowValue ""
if {$ProfileInputFormat == "cmplx"} {
    if {$ProfileOutputFormat == "mod"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue + $ProfileImagValue * $ProfileImagValue)]
        }
    if {$ProfileOutputFormat == "db10"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue + $ProfileImagValue * $ProfileImagValue)]
        if {$ProfileShowValue < 0.0000000001} { set ProfileShowValue 0.0000000001 }
        set ProfileShowValue [expr 10.0 * log10($ProfileShowValue)]
        }
    if {$ProfileOutputFormat == "db20"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue + $ProfileImagValue * $ProfileImagValue)]
        if {$ProfileShowValue < 0.0000000001} { set ProfileShowValue 0.0000000001 }
        set ProfileShowValue [expr 20.0 * log10($ProfileShowValue)]
        }
    if {$ProfileOutputFormat == "pha"} {
        set ProfileShowValue [expr atan2($ProfileImagValue,$ProfileRealValue)]
        set ProfileShowValue [expr $ProfileShowValue * (180.0 / 3.1415926535)]
        }
    if {$ProfileOutputFormat == "real"} { set ProfileShowValue $ProfileRealValue }
    if {$ProfileOutputFormat == "imag"} { set ProfileShowValue $ProfileImagValue }
    }
if {$ProfileInputFormat == "float"} {
    if {$ProfileOutputFormat == "mod"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue)]
        }
    if {$ProfileOutputFormat == "db10"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue)]
        if {$ProfileShowValue < 0.0000000001} { set ProfileShowValue 0.0000000001 }
        set ProfileShowValue [expr 10.0 * log10($ProfileShowValue)]
        }
    if {$ProfileOutputFormat == "db20"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue)]
        if {$ProfileShowValue < 0.0000000001} { set ProfileShowValue 0.0000000001 }
        set ProfileShowValue [expr 20.0 * log10($ProfileShowValue)]
        }
    if {$ProfileOutputFormat == "real"} { set ProfileShowValue $ProfileRealValue }
    }
if {$ProfileInputFormat == "int"} {
    if {$ProfileOutputFormat == "mod"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue)]
        }
    if {$ProfileOutputFormat == "db10"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue)]
        if {$ProfileShowValue < 0.0000000001} { set ProfileShowValue 0.0000000001 }
        set ProfileShowValue [expr 10.0 * log10($ProfileShowValue)]
        }
    if {$ProfileOutputFormat == "db20"} {
        set ProfileShowValue [expr sqrt($ProfileRealValue * $ProfileRealValue)]
        if {$ProfileShowValue < 0.0000000001} { set ProfileShowValue 0.0000000001 }
        set ProfileShowValue [expr 20.0 * log10($ProfileShowValue)]
        }
    if {$ProfileOutputFormat == "real"} { set ProfileShowValue $ProfileRealValue }
    }
        
}
#############################################################################
## Procedure:  ProfileExtractData

proc ::ProfileExtractData {} {
global OpenDirFile NligFullSize NcolFullSize ErrorMessage VarError
global ProfileFileInput BMPProfileX BMPProfileY ProfileLength ProfileExecFid
global ProfileInputFormat ProfileRealValue ProfileImagValue
global ProfileShow ProfileFileOpen
global TMPProfileTxt TMPProfileXTxt TMPProfileYTxt TMPProfileXYTxt
global TMPProfileXBin TMPProfileYBin TMPProfileXYBin
global TMPProfile1DXBin TMPProfile1DYBin TMPProfile3DBin
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {$ProfileFileInput == ""} {
    set VarError ""
    set ErrorMessage "ENTER THE INPUT DATA FILE NAME" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

if {$ProfileInputFormat == ""} {
    set VarError ""
    set ErrorMessage "SELECT THE INPUT DATA FORMAT" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

#Avoid any changement of pixel value under test by clicking in the window
set BMPProfileXX $BMPProfileX
set BMPProfileYY $BMPProfileY

DeleteFile $TMPProfileTxt
DeleteFile $TMPProfileXTxt
DeleteFile $TMPProfileXBin
DeleteFile $TMPProfileYTxt
DeleteFile $TMPProfileYBin
DeleteFile $TMPProfileXYTxt
DeleteFile $TMPProfileXYBin
DeleteFile $TMPProfile1DXBin
DeleteFile $TMPProfile1DYBin
DeleteFile $TMPProfile3DBin
set ProgressLine ""
puts $ProfileExecFid "extractval\n"
flush $ProfileExecFid
fconfigure $ProfileExecFid -buffering line
while {$ProgressLine != "OKextractval"} {
    gets $ProfileExecFid ProgressLine
    update
    }
set ProgressLine ""
puts $ProfileExecFid "$BMPProfileXX\n"
flush $ProfileExecFid
fconfigure $ProfileExecFid -buffering line
while {$ProgressLine != "OKreadcol"} {
    gets $ProfileExecFid ProgressLine
    update
    }
set ProgressLine ""
puts $ProfileExecFid "$BMPProfileYY\n"
flush $ProfileExecFid
fconfigure $ProfileExecFid -buffering line
while {$ProgressLine != "OKreadlig"} {
    gets $ProfileExecFid ProgressLine
    update
    }
set ProgressLine ""
while {$ProgressLine != "OKfinextractval"} {
    gets $ProfileExecFid ProgressLine
    update
    }
set ProgressLine ""

WaitUntilCreated $TMPProfileTxt 
if [file exists $TMPProfileTxt] {
    set f [open $TMPProfileTxt r]
    gets $f ProfileRealValue
    if {$ProfileInputFormat == "cmplx"} { gets $f ProfileImagValue }
    close $f
    if {$ProfileShow == 0} { ProfileInitWindow }
    ProfileCreateXYBin
    }
    
#InputFormat
}
#InputFile
}
#OpenDirFile
}
}
#############################################################################
## Procedure:  ProfileFileOpenClose

proc ::ProfileFileOpenClose {} {
global FileName ProfileDirInput ProfileFileInput
global ProfileExecFid ProfileFileOpen
global ProfileInputFormat ProfileInputFormatOld

if {$ProfileFileOpen == 1 } {
    set ProgressLine ""
    puts $ProfileExecFid "closefile\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKclosefile"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $ProfileExecFid "$ProfileInputFormatOld\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKreadformat"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    while {$ProgressLine != "OKfinclosefile"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProfileFileOpen 0
    set ProgressLine ""
    }
    
if {$ProfileFileOpen == 0 } {
    set ProgressLine ""
    puts $ProfileExecFid "openfile\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKopenfile"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $ProfileExecFid "$ProfileDirInput\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKreaddir"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $ProfileExecFid "$ProfileFileInput\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKreadfile"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $ProfileExecFid "$ProfileInputFormat\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKreadformat"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    while {$ProgressLine != "OKfinopenfile"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProfileInputFormatOld $ProfileInputFormat
    set ProfileFileOpen 1 
    set ProgressLine ""
    }
}
#############################################################################
## Procedure:  ProfileInitWindow

proc ::ProfileInitWindow {} {
global TF257 But257 CBut257 RBut257 Lbl257 Ent257
global ProfileFileInput ProfileShow
global ProfileInputFormat ProfileOutputFormat
global MinMaxAutoProfile MinProfile MaxProfile
global ProfileRealValue ProfileImagvalue
global ProfileRepresentation ProfileRepresentation3D
global GnuXview GnuZview ProfileLength GnuProfileTitle
global NligInit NcolInit NligFullSize NcolFullSize

set ProfileShow 1

$TF257(3) configure -state normal
$RBut257(7) configure -state normal
$RBut257(8) configure -state normal
$RBut257(9) configure -state normal
$Lbl257(6) configure -state normal
$Ent257(6) configure -state normal
$Ent257(6) configure -disabledbackground #FFFFFF
$But257(6) configure -state normal
$But257(7) configure -state normal
$But257(8) configure -state normal
$But257(9) configure -state normal
set ProfileLength "30"
set ProfileRepresentation "xrange"
set ProfileRepresentation3D ""

$TF257(4) configure -state normal
if {$ProfileInputFormat == "cmplx"} { $RBut257(5) configure -state normal}
if {$ProfileInputFormat == "cmplx"} { $RBut257(6) configure -state normal}
$RBut257(10) configure -state normal
$RBut257(11) configure -state normal
$RBut257(12) configure -state normal
$RBut257(13) configure -state normal
set ProfileOutputFormat "real"

$Ent257(8) configure -disabledbackground #FFFFFF
$Lbl257(8) configure -state normal
ProfileCreateShowValue

set MinMaxAutoProfile 1
set MinProfile "Auto"; set MaxProfile "Auto"
$TF257(2) configure -state normal
$CBut257(1) configure -state normal
$Lbl257(3) configure -state disable
$Ent257(3) configure -state disable
$Lbl257(4) configure -state disable
$Ent257(4) configure -state disable
$But257(5) configure -state disable
    
set GnuProfileTitle "RANGE PROFILE"
$TF257(5) configure -state normal
$Ent257(7) configure -state normal
$Ent257(7) configure -disabledbackground #FFFFFF
}
#############################################################################
## Procedure:  ProfileCreateXYBin

proc ::ProfileCreateXYBin {} {
global OpenDirFile ProfileExecFid
global ProfileLength ProfileInputFormat ProfileOutputFormat
global MinMaxAutoProfile MinProfile MaxProfile
global TMPProfileTxt TMPProfileXTxt TMPProfileYTxt TMPProfileXYTxt
global TMPProfileXBin TMPProfileYBin TMPProfileXYBin
global TMPProfile1DXBin TMPProfile1DYBin TMPProfile3DBin
global ProfileRepresentation ProfileRepresentation3D
global VarError ErrorMessage 
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {$ProfileOutputFormat == ""} {
    set VarError ""
    set ErrorMessage "SELECT THE OUTPUT DATA FORMAT" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

DeleteFile $TMPProfileXTxt
DeleteFile $TMPProfileXBin
DeleteFile $TMPProfileYTxt
DeleteFile $TMPProfileYBin
DeleteFile $TMPProfileXYTxt
DeleteFile $TMPProfileXYBin
DeleteFile $TMPProfile1DXBin
DeleteFile $TMPProfile1DYBin
DeleteFile $TMPProfile3DBin
if {$MinMaxAutoProfile == 1} {
    set RunMin "-9999"
    set RunMax "+9999"
    } else {
    set RunMin $MinProfile
    set RunMax $MaxProfile
    }
if {$ProfileInputFormat == "int"} {
    set TestVarName(0) "Min Value"; set TestVarType(0) "int"; set TestVarValue(0) $RunMin; set TestVarMin(0) "-10000"; set TestVarMax(0) "10000"
    set TestVarName(1) "Max Value"; set TestVarType(1) "int"; set TestVarValue(1) $RunMax; set TestVarMin(1) "-10000"; set TestVarMax(1) "10000"
    } else {
    set TestVarName(0) "Min Value"; set TestVarType(0) "float"; set TestVarValue(0) $RunMin; set TestVarMin(0) "-10000.00"; set TestVarMax(0) "10000.00"
    set TestVarName(1) "Max Value"; set TestVarType(1) "float"; set TestVarValue(1) $RunMax; set TestVarMin(1) "-10000.00"; set TestVarMax(1) "10000.00"
    }
TestVar 2
if {$TestVarError == "ok"} {
    set ProgressLine ""
    puts $ProfileExecFid "extractbin\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKextractbin"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $ProfileExecFid "$ProfileLength\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKrangelength"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $ProfileExecFid "$ProfileOutputFormat\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKreadformat"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $ProfileExecFid "$MinMaxAutoProfile\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKminmaxauto"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    if {$MinMaxAutoProfile == 0} {
        set ProgressLine ""
        puts $ProfileExecFid "$RunMin\n"
        flush $ProfileExecFid
        fconfigure $ProfileExecFid -buffering line
        while {$ProgressLine != "OKmin"} {
            gets $ProfileExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $ProfileExecFid "$RunMax\n"
        flush $ProfileExecFid
        fconfigure $ProfileExecFid -buffering line
        while {$ProgressLine != "OKmax"} {
            gets $ProfileExecFid ProgressLine
            update
            }
        }
    set ProgressLine ""
    while {$ProgressLine != "OKfinextractbin"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""

    if [file exists $TMPProfile3DBin] {
        ProfileCreateShowValue
        if {$ProfileRepresentation == "xrange"} { ProfilePlot1D }
        if {$ProfileRepresentation == "yrange"} { ProfilePlot1D }
        if {$ProfileRepresentation == "xyrange"} { ProfilePlot3D }
        } else {
        set VarError ""
        set ErrorMessage "PROBLEM DURING DATA PROFILE GENERATION" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    #VarError        
    }    
#OutputFormat
}
#OpenDirFile
}
}
#############################################################################
## Procedure:  ProfilePlot1D

proc ::ProfilePlot1D {} {
global TMPProfileXTxt TMPProfileXBin TMPProfileYTxt TMPProfileYBin
global ProfileOutputFormat ProfileRepresentation
global GnuplotPipeFid GnuplotPipeProfile GnuOutputFormat
global GnuProfileTitle GnuOutputFile 
global ImageMagickMaker TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top257]; set ywindow [winfo y .top257]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk

if {$GnuplotPipeProfile == ""} {
    GnuPlotInit 0 0 1 1
    set GnuplotPipeProfile $GnuplotPipeFid
    }
    
ProfilePlot1DThumb

set GnuOutputFile $TMPGnuPlotTk1
set GnuOutputFormat "gif"
GnuPlotTerm $GnuplotPipeProfile $GnuOutputFormat

    
puts $GnuplotPipeProfile "set autoscale"; flush $GnuplotPipeProfile
if {$ProfileRepresentation == "xrange"} {
    WaitUntilCreated $TMPProfileXTxt 
    if [file exists $TMPProfileXTxt] {
        set f [open $TMPProfileXTxt r]
        gets $f xmax;
        gets $f ymin;
        gets $f ymax
        close $f
        }
    puts $GnuplotPipeProfile "set xlabel 'X Range'"; flush $GnuplotPipeProfile
    }
if {$ProfileRepresentation == "yrange"} {
    WaitUntilCreated $TMPProfileYTxt 
    if [file exists $TMPProfileYTxt] {
        set f [open $TMPProfileYTxt r]
        gets $f xmax;
        gets $f ymin;
        gets $f ymax
        close $f
        }
    puts $GnuplotPipeProfile "set xlabel 'Y Range'"; flush $GnuplotPipeProfile
    }

set ymin [expr floor($ymin)]
set ymax [expr ceil($ymax)]

set xmin "0"
incr xmax -1
    
set xrg "\x5B$xmin:$xmax\x5D"; puts $GnuplotPipeProfile "set xrange $xrg noreverse nowriteback"; flush $GnuplotPipeProfile
set yrg "\x5B$ymin:$ymax\x5D"; puts $GnuplotPipeProfile "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeProfile

if {$ProfileOutputFormat == "mod"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "db10"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude - dB'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "db20"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude - dB'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "pha"} {puts $GnuplotPipeProfile "set ylabel 'Argument - (°)'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "real"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "imag"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude'"; flush $GnuplotPipeProfile}

puts $GnuplotPipeProfile "set title '$GnuProfileTitle' textcolor lt 3"; flush $GnuplotPipeProfile

if {$ProfileRepresentation == "xrange"} {puts $GnuplotPipeProfile "plot '$TMPProfileXBin' using 1:2 notitle with lines"; flush $GnuplotPipeProfile}
if {$ProfileRepresentation == "yrange"} {puts $GnuplotPipeProfile "plot '$TMPProfileYBin' using 1:2 notitle with lines"; flush $GnuplotPipeProfile}

puts $GnuplotPipeProfile "unset output"; flush $GnuplotPipeProfile 

set ErrorCatch [catch {puts $GnuplotPipeProfile "quit"}]
if { $ErrorCatch == "0" } {
    puts $GnuplotPipeProfile "quit"; flush $GnuplotPipeProfile 
    }
catch "close $GnuplotPipeProfile"
set GnuplotPipeProfile ""

WaitUntilCreated $TMPGnuPlotTk1

ViewGnuPlotTK 1 .top257 $GnuProfileTitle
}
#############################################################################
## Procedure:  ProfilePlot3D

proc ::ProfilePlot3D {} {
global TMPProfileXYTxt TMPProfileXYBin
global ProfileOutputFormat ProfileRepresentation ProfileRepresentation3D
global GnuplotPipeFid GnuplotPipeProfile GnuOutputFormat GnuOutputFile 
global GnuProfileTitle GnuXview GnuZview
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global ImageMagickMaker TMPGnuPlotTk1 TMPGnuPlot1Tk

set TestVarName(0) "Orientation Elevation (°)"; set TestVarType(0) "float"; set TestVarValue(0) $GnuXview; set TestVarMin(0) "0.0"; set TestVarMax(0) "180.0"
set TestVarName(1) "Orientation Azimut (°)"; set TestVarType(1) "float"; set TestVarValue(1) $GnuZview; set TestVarMin(1) "0.0"; set TestVarMax(1) "360.0"
TestVar 2

if {$TestVarError == "ok"} {

if [file exists $TMPProfileXYTxt] {

set xwindow [winfo x .top257]; set ywindow [winfo y .top257]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk

if {$GnuplotPipeProfile == ""} {
    GnuPlotInit 0 0 1 1
    set GnuplotPipeProfile $GnuplotPipeFid
    }
    
ProfilePlot3DThumb

set GnuOutputFile $TMPGnuPlotTk1
set GnuOutputFormat "gif"
GnuPlotTerm $GnuplotPipeProfile $GnuOutputFormat

set Unit ""
if {$ProfileOutputFormat == "db10"} {set Unit "dB"}
if {$ProfileOutputFormat == "db20"} {set Unit "dB"}
if {$ProfileOutputFormat == "pha"} {set Unit "Arg(°)"}

GnuPlot3D $GnuplotPipeProfile $TMPProfileXYTxt $TMPProfileXYBin "Pix" "Pix" $Unit $GnuXview $GnuZview $GnuProfileTitle 1 $ProfileRepresentation3D 1

puts $GnuplotPipeProfile "unset output"; flush $GnuplotPipeProfile 

set ErrorCatch [catch {puts $GnuplotPipeProfile "quit"}]
if { $ErrorCatch == "0" } {
    puts $GnuplotPipeProfile "quit"; flush $GnuplotPipeProfile 
    }
catch "close $GnuplotPipeProfile"
set GnuplotPipeProfile ""

WaitUntilCreated $TMPGnuPlotTk1

ViewGnuPlotTK 1 .top257 $GnuProfileTitle
#file
}
#VarError
}
}
#############################################################################
## Procedure:  ProfilePlot1DThumb

proc ::ProfilePlot1DThumb {} {
global TMPProfileXTxt TMPProfileXBin TMPProfileYTxt TMPProfileYBin
global ProfileOutputFormat ProfileRepresentation
global GnuplotPipeFid GnuplotPipeProfile GnuOutputFormat
global GnuProfileTitle GnuOutputFile 
global ImageMagickMaker TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top257]; set ywindow [winfo y .top257]

DeleteFile $TMPGnuPlot1Tk

set GnuOutputFile $TMPGnuPlot1Tk
set GnuOutputFormat "png"
GnuPlotTerm $GnuplotPipeProfile $GnuOutputFormat

    
puts $GnuplotPipeProfile "set autoscale"; flush $GnuplotPipeProfile
if {$ProfileRepresentation == "xrange"} {
    WaitUntilCreated $TMPProfileXTxt 
    if [file exists $TMPProfileXTxt] {
        set f [open $TMPProfileXTxt r]
        gets $f xmax;
        gets $f ymin;
        gets $f ymax
        close $f
        }
    puts $GnuplotPipeProfile "set xlabel 'X Range'"; flush $GnuplotPipeProfile
    }
if {$ProfileRepresentation == "yrange"} {
    WaitUntilCreated $TMPProfileYTxt 
    if [file exists $TMPProfileYTxt] {
        set f [open $TMPProfileYTxt r]
        gets $f xmax;
        gets $f ymin;
        gets $f ymax
        close $f
        }
    puts $GnuplotPipeProfile "set xlabel 'Y Range'"; flush $GnuplotPipeProfile
    }

set ymin [expr floor($ymin)]
set ymax [expr ceil($ymax)]

set xmin "0"
incr xmax -1
    
set xrg "\x5B$xmin:$xmax\x5D"; puts $GnuplotPipeProfile "set xrange $xrg noreverse nowriteback"; flush $GnuplotPipeProfile
set yrg "\x5B$ymin:$ymax\x5D"; puts $GnuplotPipeProfile "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeProfile

if {$ProfileOutputFormat == "mod"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "db10"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude - dB'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "db20"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude - dB'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "pha"} {puts $GnuplotPipeProfile "set ylabel 'Argument - (°)'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "real"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude'"; flush $GnuplotPipeProfile}
if {$ProfileOutputFormat == "imag"} {puts $GnuplotPipeProfile "set ylabel 'Amplitude'"; flush $GnuplotPipeProfile}

puts $GnuplotPipeProfile "set title '$GnuProfileTitle' textcolor lt 3"; flush $GnuplotPipeProfile

if {$ProfileRepresentation == "xrange"} {puts $GnuplotPipeProfile "plot '$TMPProfileXBin' using 1:2 notitle with lines"; flush $GnuplotPipeProfile}
if {$ProfileRepresentation == "yrange"} {puts $GnuplotPipeProfile "plot '$TMPProfileYBin' using 1:2 notitle with lines"; flush $GnuplotPipeProfile}

puts $GnuplotPipeProfile "unset output"; flush $GnuplotPipeProfile 

WaitUntilCreated $TMPGnuPlot1Tk
}
#############################################################################
## Procedure:  ProfilePlot3DThumb

proc ::ProfilePlot3DThumb {} {
global TMPProfileXYTxt TMPProfileXYBin
global ProfileOutputFormat ProfileRepresentation ProfileRepresentation3D
global GnuplotPipeFid GnuplotPipeProfile GnuOutputFormat GnuOutputFile 
global GnuProfileTitle GnuXview GnuZview
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global ImageMagickMaker TMPGnuPlotTk1 TMPGnuPlot1Tk

if [file exists $TMPProfileXYTxt] {

set xwindow [winfo x .top257]; set ywindow [winfo y .top257]

DeleteFile $TMPGnuPlot1Tk

set GnuOutputFile $TMPGnuPlot1Tk
set GnuOutputFormat "png"
GnuPlotTerm $GnuplotPipeProfile $GnuOutputFormat

set Unit ""
if {$ProfileOutputFormat == "db10"} {set Unit "dB"}
if {$ProfileOutputFormat == "db20"} {set Unit "dB"}
if {$ProfileOutputFormat == "pha"} {set Unit "Arg(°)"}

GnuPlot3D $GnuplotPipeProfile $TMPProfileXYTxt $TMPProfileXYBin "Pix" "Pix" $Unit $GnuXview $GnuZview $GnuProfileTitle 1 $ProfileRepresentation3D 1

puts $GnuplotPipeProfile "unset output"; flush $GnuplotPipeProfile 

WaitUntilCreated $TMPGnuPlot1Tk
#file
}
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
    wm geometry $top 200x200+175+175; update
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

proc vTclWindow.top257 {base} {
    if {$base == ""} {
        set base .top257
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m71" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x410+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Analysis : Value - Profile"
    vTcl:DefineAlias "$top" "Toplevel257" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd94 \
        -ipad 2 -text {Input Data File} 
    vTcl:DefineAlias "$top.cpd94" "TitleFrame15" vTcl:WidgetProc "Toplevel257" 1
    bind $top.cpd94 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd94 getframe]
    entry $site_4_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ProfileFileInput -width 6 
    vTcl:DefineAlias "$site_4_0.cpd95" "Entry69" vTcl:WidgetProc "Toplevel257" 1
    frame $site_4_0.cpd99 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd99" "Frame1" vTcl:WidgetProc "Toplevel257" 1
    set site_5_0 $site_4_0.cpd99
    button $site_5_0.cpd100 \
        \
        -command {global FileName ProfileDirInput ProfileFileInput
global ProfileExecFid ProfileFileOpen
global ProfileInputFormat ProfileInputFormatOld
global ConfigFile VarError ErrorMessage

if {$ProfileFileOpen == 1 } {
    set ProgressLine ""
    puts $ProfileExecFid "closefile\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKclosefile"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $ProfileExecFid "$ProfileInputFormatOld\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKreadformat"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProgressLine ""
    while {$ProgressLine != "OKfinclosefile"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    set ProfileFileOpen 0
    set ProgressLine ""
    }

ProfileReset

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $ProfileDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
    set ProfileDirInput [file dirname $FileName]
    set ConfigFile "$ProfileDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set ProfileFileInput $FileName
        set ProfileInputFormat ""
        $widget(TitleFrame257_6) configure -state normal
        $widget(Radiobutton257_14) configure -state normal
        $widget(Radiobutton257_15) configure -state normal
        $widget(Radiobutton257_16) configure -state normal
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel257); TextEditorRunTrace "Close Window Data Value - Profile" "b"}
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 4 -pady 2 -text button 
    vTcl:DefineAlias "$site_5_0.cpd100" "Button1" vTcl:WidgetProc "Toplevel257" 1
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd95 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd99 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel257" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel257" 1
    set site_4_0 $site_3_0.cpd78
    canvas $site_4_0.can73 \
        -borderwidth 2 -closeenough 1.0 -height 200 -relief ridge -width 200 
    vTcl:DefineAlias "$site_4_0.can73" "CANVASLENSPROFILE" vTcl:WidgetProc "Toplevel257" 1
    bind $site_4_0.can73 <Button-1> {
        MouseButtonDownLens %x %y
    }
    TitleFrame $site_4_0.cpd80 \
        -ipad 2 -text {Mouse Position} 
    vTcl:DefineAlias "$site_4_0.cpd80" "TitleFrame3" vTcl:WidgetProc "Toplevel257" 1
    bind $site_4_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd80 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame29" vTcl:WidgetProc "Toplevel257" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame30" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label27" vTcl:WidgetProc "Toplevel257" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseX -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry52" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame31" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label28" vTcl:WidgetProc "Toplevel257" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseY -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry53" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame32" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab76 \
        -relief groove -text Val -width 4 
    vTcl:DefineAlias "$site_8_0.lab76" "Label29" vTcl:WidgetProc "Toplevel257" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPValue -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry54" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.fra85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd71 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame6" vTcl:WidgetProc "Toplevel257" 1
    set site_5_0 $site_4_0.cpd71
    frame $site_5_0.fra87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra87" "Frame9" vTcl:WidgetProc "Toplevel257" 1
    set site_6_0 $site_5_0.fra87
    button $site_6_0.cpd71 \
        \
        -command {global BMPLens LineXLensInit LineYLensInit LineXLens LineYLens plot2 line_color

if {$line_color == "white"} {
    set line_color "black"
    } else {
    set line_color "white"
    }

set b .top257.fra71.cpd78.cpd71.fra87.cpd71
$b configure -background $line_color -foreground $line_color

$widget(CANVASLENSPROFILE) dtag LineXLensInit
$widget(CANVASLENSPROFILE) dtag LineYLensInit
$widget(CANVASLENSPROFILE) create image 0 0 -anchor nw -image BMPLens
set LineXLensInit {0 0}
set LineYLensInit {0 0}
set LineXLens [$widget(CANVASLENSPROFILE) create line 0 0 0 $SizeLens -fill $line_color -width 2]
set LineYLens [$widget(CANVASLENSPROFILE) create line 0 0 $SizeLens 0 -fill $line_color -width 2]
$widget(CANVASLENSPROFILE) addtag LineXLensInit withtag $LineXLens
$widget(CANVASLENSPROFILE) addtag LineYLensInit withtag $LineYLens
set plot2(lastX) 0
set plot2(lastY) 0} \
        -pady 0 -relief ridge -text {   } 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button9" vTcl:WidgetProc "Toplevel257" 1
    button $site_6_0.cpd88 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} { ProfileCreateXYBin }} \
        -padx 4 -pady 2 -text Plot 
    vTcl:DefineAlias "$site_6_0.cpd88" "Button257_6" vTcl:WidgetProc "Toplevel257" 1
    bindtags $site_6_0.cpd88 "$site_6_0.cpd88 Button $top all _vTclBalloon"
    bind $site_6_0.cpd88 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Plot}
    }
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    TitleFrame $site_5_0.cpd73 \
        -ipad 2 -text Orientation 
    vTcl:DefineAlias "$site_5_0.cpd73" "TitleFrame257_1" vTcl:WidgetProc "Toplevel257" 1
    bind $site_5_0.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd73 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame45" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame46" vTcl:WidgetProc "Toplevel257" 1
    set site_9_0 $site_8_0.fra84
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GnuXview -width 5 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry257_1" vTcl:WidgetProc "Toplevel257" 1
    button $site_9_0.but86 \
        \
        -command {global GnuXview

set GnuTmp [expr $GnuXview + 5]
if {$GnuTmp > 180} {set GnuTmp [expr $GnuTmp - 180]}
set GnuXview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.but86" "Button257_1" vTcl:WidgetProc "Toplevel257" 1
    button $site_9_0.cpd87 \
        \
        -command {global GnuXview

set GnuTmp [expr $GnuXview - 5]
if {$GnuTmp < 0} {set GnuTmp [expr $GnuTmp + 180]}
set GnuXview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd87" "Button257_2" vTcl:WidgetProc "Toplevel257" 1
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_9_0.but86 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd87 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame47" vTcl:WidgetProc "Toplevel257" 1
    set site_9_0 $site_8_0.fra85
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GnuZview -width 5 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry257_2" vTcl:WidgetProc "Toplevel257" 1
    button $site_9_0.cpd88 \
        \
        -command {global GnuZview

set GnuTmp [expr $GnuZview + 5]
if {$GnuTmp > 360} {set GnuTmp [expr $GnuTmp - 360]}
set GnuZview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.cpd88" "Button257_3" vTcl:WidgetProc "Toplevel257" 1
    button $site_9_0.cpd89 \
        \
        -command {global GnuZview

set GnuTmp [expr $GnuZview - 5]
if {$GnuTmp < 0} {set GnuTmp [expr $GnuTmp + 360]}
set GnuZview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd89" "Button257_4" vTcl:WidgetProc "Toplevel257" 1
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_9_0.cpd88 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd89 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    frame $site_5_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra81" "Frame2" vTcl:WidgetProc "Toplevel257" 1
    set site_6_0 $site_5_0.fra81
    frame $site_6_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd70" "Frame5" vTcl:WidgetProc "Toplevel257" 1
    set site_7_0 $site_6_0.cpd70
    button $site_7_0.cpd82 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput ProfileDirOutput
global GnuplotPipeFid
global SaveDisplayOutputFile1 ProfileRepresentation

#BMP_PROCESS
global Load_SaveDisplay1 PSPTopLevel

if {$GnuplotPipeFid == ""} {
    set ErrorMessage "GNUPLOT IS NOT RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

    if {$Load_SaveDisplay1 == 0} {
        source "GUI/bmp_process/SaveDisplay1.tcl"
        set Load_SaveDisplay1 1
        WmTransient $widget(Toplevel456) $PSPTopLevel
        }

    if {$ProfileRepresentation == "xyrange"} {
        set SaveDisplayOutputFile1 "Data_Profile3D"
        } else {
        set SaveDisplayOutputFile1 "Data_Profile1D"
        }

    set SaveDisplayDirOutput $ProfileDirOutput

    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel257) $widget(Toplevel456); TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] 
    vTcl:DefineAlias "$site_7_0.cpd82" "Button257_7" vTcl:WidgetProc "Toplevel257" 1
    bindtags $site_7_0.cpd82 "$site_7_0.cpd82 Button $top all _vTclBalloon"
    bind $site_7_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save}
    }
    button $site_7_0.cpd83 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1

Gimp $TMPGnuPlotTk1} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -padx 0 -pady 0 -text { } 
    vTcl:DefineAlias "$site_7_0.cpd83" "Button257_9" vTcl:WidgetProc "Toplevel257" 1
    bindtags $site_7_0.cpd83 "$site_7_0.cpd83 Button $top all _vTclBalloon"
    bind $site_7_0.cpd83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Close}
    }
    pack $site_7_0.cpd82 \
        -in $site_7_0 -anchor center -expand 1 -fill none -ipady 1 -side left 
    pack $site_7_0.cpd83 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    button $site_6_0.cpd83 \
        -background #ffff00 \
        -command {global GnuplotPipeFid GnuplotPipeProfile

if {$GnuplotPipeProfile != ""} {
    catch "close $GnuplotPipeProfile"
    set GnuplotPipeProfile ""
    }
set GnuplotPipeFid ""
Window hide .top401} \
        -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_6_0.cpd83" "Button257_8" vTcl:WidgetProc "Toplevel257" 1
    bindtags $site_6_0.cpd83 "$site_6_0.cpd83 Button $top all _vTclBalloon"
    bind $site_6_0.cpd83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Close}
    }
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra87 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra81 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.can73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel257" 1
    set site_4_0 $site_3_0.fra72
    TitleFrame $site_4_0.cpd86 \
        -ipad 0 -text {Input Data Format} 
    vTcl:DefineAlias "$site_4_0.cpd86" "TitleFrame257_6" vTcl:WidgetProc "Toplevel257" 1
    bind $site_4_0.cpd86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd86 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame44" vTcl:WidgetProc "Toplevel257" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame48" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.fra84
    radiobutton $site_8_0.rad78 \
        \
        -command {global ProfileShow ProfileImagValue ProfileOutputFormat

ProfileFileOpenClose
$widget(Entry257_5) configure -disabledbackground #FFFFFF
$widget(Label257_5) configure -state normal
if {$ProfileShow == 1} {
    $widget(Radiobutton257_5) configure -state normal
    $widget(Radiobutton257_6) configure -state normal
    set ProfileImagValue ""
    set ProfileOutputFormat "real"
    }} \
        -text Complex -value cmplx -variable ProfileInputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_14" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame49" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd71
    radiobutton $site_8_0.rad78 \
        \
        -command {global ProfileShow ProfileImagValue ProfileOutputFormat PSPBackgroundColor

ProfileFileOpenClose
$widget(Entry257_5) configure -disabledbackground $PSPBackgroundColor
$widget(Label257_5) configure -state disable
if {$ProfileShow == 1} {
    $widget(Radiobutton257_5) configure -state disable
    $widget(Radiobutton257_6) configure -state disable
    set ProfileImagValue ""
    set ProfileOutputFormat "real"
    }} \
        -text Float -value float -variable ProfileInputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_15" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd72" "Frame50" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd72
    radiobutton $site_8_0.rad78 \
        \
        -command {global ProfileShow ProfileImagValue ProfileOutputFormat PSPBackgroundColor

ProfileFileOpenClose
$widget(Entry257_5) configure -disabledbackground $PSPBackgroundColor
$widget(Label257_5) configure -state disable
if {$ProfileShow == 1} {
    $widget(Radiobutton257_5) configure -state disable
    $widget(Radiobutton257_6) configure -state disable
    set ProfileImagValue ""
    set ProfileOutputFormat "real"
    }} \
        -text Integer -value int -variable ProfileInputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_16" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_4_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame7" vTcl:WidgetProc "Toplevel257" 1
    set site_5_0 $site_4_0.cpd75
    TitleFrame $site_5_0.cpd76 \
        -ipad 2 -text {Pixel Values} 
    vTcl:DefineAlias "$site_5_0.cpd76" "TitleFrame7" vTcl:WidgetProc "Toplevel257" 1
    bind $site_5_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame41" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd75
    entry $site_8_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ProfileImagValue -width 11 
    vTcl:DefineAlias "$site_8_0.cpd75" "Entry257_5" vTcl:WidgetProc "Toplevel257" 1
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame42" vTcl:WidgetProc "Toplevel257" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label30" vTcl:WidgetProc "Toplevel257" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPProfileX -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry55" vTcl:WidgetProc "Toplevel257" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame43" vTcl:WidgetProc "Toplevel257" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label31" vTcl:WidgetProc "Toplevel257" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPProfileY -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry56" vTcl:WidgetProc "Toplevel257" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    label $site_8_0.cpd77 \
        -padx 0 -pady 0 -text +j 
    vTcl:DefineAlias "$site_8_0.cpd77" "Label257_5" vTcl:WidgetProc "Toplevel257" 1
    entry $site_8_0.cpd76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ProfileRealValue -width 11 
    vTcl:DefineAlias "$site_8_0.cpd76" "Entry74" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.cpd75 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 1 -side right 
    pack $site_8_0.cpd76 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $site_4_0.cpd78 \
        -ipad 0 -text Show 
    vTcl:DefineAlias "$site_4_0.cpd78" "TitleFrame257_4" vTcl:WidgetProc "Toplevel257" 1
    bind $site_4_0.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd78 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame68" vTcl:WidgetProc "Toplevel257" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame70" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.fra85
    radiobutton $site_8_0.rad79 \
        -command ProfileCreateXYBin -text Modulus -value mod \
        -variable ProfileOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad79" "Radiobutton257_10" vTcl:WidgetProc "Toplevel257" 1
    radiobutton $site_8_0.cpd80 \
        -command ProfileCreateXYBin -text 10log(Mod) -value db10 \
        -variable ProfileOutputFormat 
    vTcl:DefineAlias "$site_8_0.cpd80" "Radiobutton257_11" vTcl:WidgetProc "Toplevel257" 1
    radiobutton $site_8_0.cpd84 \
        -command ProfileCreateXYBin -text 20log(Mod) -value db20 \
        -variable ProfileOutputFormat 
    vTcl:DefineAlias "$site_8_0.cpd84" "Radiobutton257_12" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad79 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd80 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd84 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd85" "Frame71" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd85
    radiobutton $site_8_0.rad79 \
        -command ProfileCreateXYBin -text Phase -value pha \
        -variable ProfileOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad79" "Radiobutton257_5" vTcl:WidgetProc "Toplevel257" 1
    radiobutton $site_8_0.cpd80 \
        -command ProfileCreateXYBin -text {Real Part} -value real \
        -variable ProfileOutputFormat 
    vTcl:DefineAlias "$site_8_0.cpd80" "Radiobutton257_13" vTcl:WidgetProc "Toplevel257" 1
    radiobutton $site_8_0.cpd84 \
        -command ProfileCreateXYBin -text {Imag part} -value imag \
        -variable ProfileOutputFormat 
    vTcl:DefineAlias "$site_8_0.cpd84" "Radiobutton257_6" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad79 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd80 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd84 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side left 
    frame $site_4_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame53" vTcl:WidgetProc "Toplevel257" 1
    set site_5_0 $site_4_0.cpd71
    frame $site_5_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame55" vTcl:WidgetProc "Toplevel257" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.cpd95 \
        -text {Range Length (pix)   } 
    vTcl:DefineAlias "$site_6_0.cpd95" "Label257_6" vTcl:WidgetProc "Toplevel257" 1
    entry $site_6_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ProfileLength -width 5 
    vTcl:DefineAlias "$site_6_0.cpd97" "Entry257_6" vTcl:WidgetProc "Toplevel257" 1
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame56" vTcl:WidgetProc "Toplevel257" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.cpd95 \
        -text Value 
    vTcl:DefineAlias "$site_6_0.cpd95" "Label257_8" vTcl:WidgetProc "Toplevel257" 1
    entry $site_6_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ProfileShowValue -width 11 
    vTcl:DefineAlias "$site_6_0.cpd97" "Entry257_8" vTcl:WidgetProc "Toplevel257" 1
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $site_4_0.cpd77 \
        -ipad 2 -text Representation 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame257_3" vTcl:WidgetProc "Toplevel257" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame33" vTcl:WidgetProc "Toplevel257" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame34" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.fra84
    radiobutton $site_8_0.rad78 \
        \
        -command {global ErrorMessage VarError GnuplotPipeProfile
global GnuXview GnuZview ProfileRepresentation3D PSPBackgroundColor

    $widget(TitleFrame257_1) configure -state disable
    $widget(Entry257_1) configure -state disable
    $widget(Entry257_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry257_2) configure -state disable
    $widget(Entry257_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Button257_1) configure -state disable
    $widget(Button257_2) configure -state disable
    $widget(Button257_3) configure -state disable
    $widget(Button257_4) configure -state disable
    $widget(Radiobutton257_1) configure -state disable
    $widget(Radiobutton257_2) configure -state disable
    $widget(Radiobutton257_3) configure -state disable
    $widget(Radiobutton257_4) configure -state disable
    set GnuXview ""; set GnuZview ""
    set ProfileRepresentation3D ""
    ProfileCreateXYBin} \
        -text {X Range} -value xrange -variable ProfileRepresentation 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_7" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame35" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd71
    radiobutton $site_8_0.rad78 \
        \
        -command {global ErrorMessage VarError GnuplotPipeProfile
global GnuXview GnuZview ProfileRepresentation3D PSPBackgroundColor

    $widget(TitleFrame257_1) configure -state disable
    $widget(Entry257_1) configure -state disable
    $widget(Entry257_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry257_2) configure -state disable
    $widget(Entry257_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Button257_1) configure -state disable
    $widget(Button257_2) configure -state disable
    $widget(Button257_3) configure -state disable
    $widget(Button257_4) configure -state disable
    $widget(Radiobutton257_1) configure -state disable
    $widget(Radiobutton257_2) configure -state disable
    $widget(Radiobutton257_3) configure -state disable
    $widget(Radiobutton257_4) configure -state disable
    set GnuXview ""; set GnuZview ""
    set ProfileRepresentation3D ""
    ProfileCreateXYBin
} \
        -text {Y Range} -value yrange -variable ProfileRepresentation 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_8" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd72" "Frame39" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd72
    radiobutton $site_8_0.rad78 \
        \
        -command {global ErrorMessage VarError GnuplotPipeProfile
global GnuXview GnuZview ProfileRepresentation3D

    $widget(TitleFrame257_1) configure -state normal
    $widget(Entry257_1) configure -state normal
    $widget(Entry257_1) configure -disabledbackground #FFFFFF
    $widget(Entry257_2) configure -state normal
    $widget(Entry257_2) configure -disabledbackground #FFFFFF
    $widget(Button257_1) configure -state normal
    $widget(Button257_2) configure -state normal
    $widget(Button257_3) configure -state normal
    $widget(Button257_4) configure -state normal
    $widget(Radiobutton257_1) configure -state normal
    $widget(Radiobutton257_2) configure -state normal
    $widget(Radiobutton257_3) configure -state normal
    $widget(Radiobutton257_4) configure -state normal
    set GnuXview "60"; set GnuZview "30"
    set ProfileRepresentation3D "mesh"
    ProfileCreateXYBin} \
        -text {(X,Y) Range} -value xyrange -variable ProfileRepresentation 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_9" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame36" vTcl:WidgetProc "Toplevel257" 1
    set site_7_0 $site_6_0.cpd72
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame37" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.fra84
    radiobutton $site_8_0.rad78 \
        -command ProfileCreateXYBin -text Mesh -value mesh \
        -variable ProfileRepresentation3D 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_1" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame38" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd71
    radiobutton $site_8_0.rad78 \
        -command ProfileCreateXYBin -text Surface -value surface \
        -variable ProfileRepresentation3D 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_2" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd88 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame40" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd88
    radiobutton $site_8_0.rad78 \
        -command ProfileCreateXYBin -text {Mesh C} -value meshcolor \
        -variable ProfileRepresentation3D 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_3" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd89 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd89" "Frame52" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.cpd89
    radiobutton $site_8_0.rad78 \
        -command ProfileCreateXYBin -text {Mesh S} -value meshsurface \
        -variable ProfileRepresentation3D 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton257_4" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd89 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_4_0.cpd90 \
        -ipad 2 -text {Minimum / Maximum Values ( y-axis )} 
    vTcl:DefineAlias "$site_4_0.cpd90" "TitleFrame257_2" vTcl:WidgetProc "Toplevel257" 1
    bind $site_4_0.cpd90 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd90 getframe]
    checkbutton $site_6_0.cpd74 \
        \
        -command {global MinMaxAutoProfile MinProfile MaxProfile

if {$MinMaxAutoProfile == 1} {
    set MinProfile "Auto"; set MaxProfile "Auto"
    $Lbl257(3) configure -state disable; $Ent257(3) configure -state disable
    $Lbl257(4) configure -state disable; $Ent257(4) configure -state disable
    $But257(5) configure -state disable
    }
if {$MinMaxAutoProfile == 0} {
    set MinProfile "?"; set MaxProfile "?"
    $Lbl257(3) configure -state normal; $Ent257(3) configure -state normal
    $Lbl257(4) configure -state normal; $Ent257(4) configure -state normal
    $But257(5) configure -state normal
    }} \
        -text Auto -variable MinMaxAutoProfile 
    vTcl:DefineAlias "$site_6_0.cpd74" "Checkbutton257_1" vTcl:WidgetProc "Toplevel257" 1
    label $site_6_0.cpd76 \
        -text Min 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label257_3" vTcl:WidgetProc "Toplevel257" 1
    entry $site_6_0.cpd78 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MinProfile -width 8 
    vTcl:DefineAlias "$site_6_0.cpd78" "Entry257_3" vTcl:WidgetProc "Toplevel257" 1
    label $site_6_0.cpd77 \
        -text Max 
    vTcl:DefineAlias "$site_6_0.cpd77" "Label257_4" vTcl:WidgetProc "Toplevel257" 1
    entry $site_6_0.cpd79 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MaxProfile -width 8 
    vTcl:DefineAlias "$site_6_0.cpd79" "Entry257_4" vTcl:WidgetProc "Toplevel257" 1
    button $site_6_0.but80 \
        -background #ffff00 \
        -command {global TMPProfile1DXBin TMPProfile1DYBin TMPProfile3DBin
global ProfileLength ProfileInputFormat 
global MinProfile MaxProfile
global VarError ErrorMessage OpenDirFile
global TMPMinMaxBmp ProfileRepresentation

if {$OpenDirFile == 0} {

if {$ProfileRepresentation == "xyrange"} {
    if [file exists $TMPProfile3DBin] {
        DeleteFile $TMPMinMaxBmp
        set Fonction "Min / Max Values Determination of the Bin File :"
        set Fonction2 "$TMPProfile3DBin"    
        set ProgressLine "0"
        if {$ProfileInputFormat == "int"} {
            set FormatIn "int"
            } else {
            set FormatIn "float"
            }
        set ProgressLine ""
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bmp_process/MinMaxBMP.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPProfile3DBin\x22 -ift $FormatIn -oft real -nc $ProfileLength -ofr 0 -ofc 0 -fnr $ProfileLength -fnc $ProfileLength -of \x22$TMPMinMaxBmp\x22" "k"
        set f [ open "| Soft/bmp_process/MinMaxBMP.exe -if \x22$TMPProfile3DBin\x22 -ift $FormatIn -oft real -nc $ProfileLength -ofr 0 -ofc 0 -fnr $ProfileLength -fnc $ProfileLength -of \x22$TMPMinMaxBmp\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        
        WaitUntilCreated $TMPMinMaxBmp 
        if [file exists $TMPMinMaxBmp] {
            set f [open $TMPMinMaxBmp r]
            gets $f MaxProfile
            gets $f MinProfile
            close $f
            }
        } else {
        set ErrorMessage "PROBLEM DURING DATA EXTRACTION" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }        
if {$ProfileRepresentation == "xrange"} {
    if [file exists $TMPProfile1DXBin] {
        DeleteFile $TMPMinMaxBmp
        set Fonction "Min / Max Values Determination of the Bin File :"
        set Fonction2 "$TMPProfile1DXBin"    
        set ProgressLine "0"
        if {$ProfileInputFormat == "int"} {
            set FormatIn "int"
            } else {
            set FormatIn "float"
            }
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bmp_process/MinMaxBMP.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPProfile1DXBin\x22 -ift $FormatIn -oft real -nc 1 -ofr 0 -ofc 0 -fnr $ProfileLength -fnc 1 -of \x22$TMPMinMaxBmp\x22" "k"
        set f [ open "| Soft/bmp_process/MinMaxBMP.exe -if \x22$TMPProfile1DXBin\x22 -ift $FormatIn -oft real -nc 1 -ofr 0 -ofc 0 -fnr $ProfileLength -fnc 1 -of \x22$TMPMinMaxBmp\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        
        WaitUntilCreated $TMPMinMaxBmp 
        if [file exists $TMPMinMaxBmp] {
            set f [open $TMPMinMaxBmp r]
            gets $f MaxProfile
            gets $f MinProfile
            close $f
            }
        } else {
        set ErrorMessage "PROBLEM DURING DATA EXTRACTION" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }        
if {$ProfileRepresentation == "yrange"} {
    if [file exists $TMPProfile1DYBin] {
        DeleteFile $TMPMinMaxBmp
        set Fonction "Min / Max Values Determination of the Bin File :"
        set Fonction2 "$TMPProfile1DYBin"    
        set ProgressLine "0"
        if {$ProfileInputFormat == "int"} {
            set FormatIn "int"
            } else {
            set FormatIn "float"
            }
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bmp_process/MinMaxBMP.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPProfile1DYBin\x22 -ift $FormatIn -oft real -nc 1 -ofr 0 -ofc 0 -fnr $ProfileLength -fnc 1 -of \x22$TMPMinMaxBmp\x22" "k"
        set f [ open "| Soft/bmp_process/MinMaxBMP.exe -if \x22$TMPProfile1DYBin\x22 -ift $FormatIn -oft real -nc 1 -ofr 0 -ofc 0 -fnr $ProfileLength -fnc 1 -of \x22$TMPMinMaxBmp\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        
        WaitUntilCreated $TMPMinMaxBmp 
        if [file exists $TMPMinMaxBmp] {
            set f [open $TMPMinMaxBmp r]
            gets $f MaxProfile
            gets $f MinProfile
            close $f
            }
        } else {
        set ErrorMessage "PROBLEM DURING DATA EXTRACTION" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }        
}} \
        -padx 4 -pady 2 -text MinMax 
    vTcl:DefineAlias "$site_6_0.but80" "Button257_5" vTcl:WidgetProc "Toplevel257" 1
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.but80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $site_4_0.cpd93 \
        -ipad 2 -text {Profile Title} 
    vTcl:DefineAlias "$site_4_0.cpd93" "TitleFrame257_5" vTcl:WidgetProc "Toplevel257" 1
    bind $site_4_0.cpd93 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd93 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame61" vTcl:WidgetProc "Toplevel257" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame62" vTcl:WidgetProc "Toplevel257" 1
    set site_8_0 $site_7_0.fra84
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GnuProfileTitle -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry257_7" vTcl:WidgetProc "Toplevel257" 1
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side right 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side left 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel257" 1
    set site_3_0 $top.fra92
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DataValueProfile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel257" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global ProfileExecFid Load_SaveDisplay1
global GnuplotPipeFid GnuplotPipeProfile
global OpenDirFile

if {$OpenDirFile == 0} {

if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}

set ErrorCatch "0"
set ProgressLine ""
set ErrorCatch [catch {puts $ProfileExecFid "exit\n"}]
if { $ErrorCatch == "0" } {
    puts $ProfileExecFid "exit\n"
    flush $ProfileExecFid
    fconfigure $ProfileExecFid -buffering line
    while {$ProgressLine != "OKexit"} {
        gets $ProfileExecFid ProgressLine
        update
        }
    catch "close $ProfileExecFid"
    }
set ProfileExecFid ""
set ProgressLine ""

if {$GnuplotPipeProfile != ""} {
    catch "close $GnuplotPipeProfile"
    set GnuplotPipeProfile ""
    }
set GnuplotPipeFid ""    
Window hide .top401
ClosePSPViewer
Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
Window hide $widget(Toplevel257); TextEditorRunTrace "Close Window Data Value - Profile" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button257_02" vTcl:WidgetProc "Toplevel257" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd94 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.fra92 \
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
Window show .top257

main $argc $argv
