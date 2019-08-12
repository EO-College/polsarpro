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
    set base .top245
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
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
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.tit73 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.tit73 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.but77 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd78 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-background 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra81
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd66
    namespace eval ::widgets::$site_7_0.cpd82 {
        array set save {-background 1 -command 1 -image 1}
    }
    namespace eval ::widgets::$site_7_0.cpd83 {
        array set save {-background 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
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
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd73
    namespace eval ::widgets::$site_8_0.cpd95 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
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
    namespace eval ::widgets::$site_8_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra84
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra85
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
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
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra85
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.tit82 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.tit82 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd83 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd84 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd85 getframe]
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
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
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
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd92 getframe]
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
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd93
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
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd92 getframe]
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
            vTclWindow.top245
            PlotCalib3D
            ExtractCalibrator
            PlotCalib1D
            ClearCalibValue
            EditCalibValue
            PlotCalib1DThumb
            PlotCalib3DThumb
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
## Procedure:  PlotCalib3D

proc ::PlotCalib3D {} {
global TMPCalibrator3Ds11Txt TMPCalibrator3Ds11Bin
global TMPCalibrator3Ds12Txt TMPCalibrator3Ds12Bin
global TMPCalibrator3Ds21Txt TMPCalibrator3Ds21Bin
global TMPCalibrator3Ds22Txt TMPCalibrator3Ds22Bin
global TMPCalibratorValTxt
global CalibOutputFormat CalibOutputUnit CalibOutputRepresentation
global GnuplotPipeFid GnuplotPipeCalib GnuOutputFormat GnuOutputFile 
global GnuCalibChannelId GnuCalibChannel GnuCalibFile
global GnuXview GnuZview
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set TestVarName(0) "Orientation Elevation (°)"; set TestVarType(0) "float"; set TestVarValue(0) $GnuXview; set TestVarMin(0) "0.0"; set TestVarMax(0) "180.0"
set TestVarName(1) "Orientation Azimut (°)"; set TestVarType(1) "float"; set TestVarValue(1) $GnuZview; set TestVarMin(1) "0.0"; set TestVarMax(1) "360.0"
TestVar 2
if {$TestVarError == "ok"} {

set xwindow [winfo x .top245]; set ywindow [winfo y .top245]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk

if [file exists $TMPCalibratorValTxt] {
    EditCalibValue
    } else {
    ClearCalibValue
    }

if {$GnuCalibChannelId == 1} {
    set GnuCalibChannel "Mod s11"
    if [file exists $TMPCalibrator3Ds11Txt] {
        if {$GnuplotPipeCalib == ""} {
            GnuPlotInit 0 0 1 1
            set GnuplotPipeCalib $GnuplotPipeFid
	    }
        #PlotCalib3DThumb
        set GnuOutputFile $TMPGnuPlotTk1
        set GnuOutputFormat "gif"
        GnuPlotTerm $GnuplotPipeCalib $GnuOutputFormat
        set Unit ""; if {$CalibOutputUnit == "dB"} {set Unit "dB"}
        GnuPlot3D $GnuplotPipeCalib $TMPCalibrator3Ds11Txt $TMPCalibrator3Ds11Bin "X" "Y" $Unit $GnuXview $GnuZview "Normalized Calibrator Response : s11 Channel" 1 $CalibOutputFormat 1
        }
    }
if {$GnuCalibChannelId == 2} {
    set GnuCalibChannel "Mod s12"
    if [file exists $TMPCalibrator3Ds12Txt] {
        if {$GnuplotPipeCalib == ""} {
            GnuPlotInit 0 0 1 1
            set GnuplotPipeCalib $GnuplotPipeFid
	    }
        #PlotCalib3DThumb
        set GnuOutputFile $TMPGnuPlotTk1
        set GnuOutputFormat "gif"
        GnuPlotTerm $GnuplotPipeCalib $GnuOutputFormat
        set Unit ""; if {$CalibOutputUnit == "dB"} {set Unit "dB"}
        GnuPlot3D $GnuplotPipeCalib $TMPCalibrator3Ds12Txt $TMPCalibrator3Ds12Bin "X" "Y" $Unit $GnuXview $GnuZview "Normalized Calibrator Response : s12 Channel" 1 $CalibOutputFormat 1
        }
    }
if {$GnuCalibChannelId == 3} {
    set GnuCalibChannel "Mod s21"
    if [file exists $TMPCalibrator3Ds21Txt] {
        if {$GnuplotPipeCalib == ""} {
            GnuPlotInit 0 0 1 1
            set GnuplotPipeCalib $GnuplotPipeFid
	    }
        #PlotCalib3DThumb
        set GnuOutputFile $TMPGnuPlotTk1
        set GnuOutputFormat "gif"
        GnuPlotTerm $GnuplotPipeCalib $GnuOutputFormat
        set Unit ""; if {$CalibOutputUnit == "dB"} {set Unit "dB"}
        GnuPlot3D $GnuplotPipeCalib $TMPCalibrator3Ds21Txt $TMPCalibrator3Ds21Bin "X" "Y" $Unit $GnuXview $GnuZview "Normalized Calibrator Response : s21 Channel" 1 $CalibOutputFormat 1
        }
    }
if {$GnuCalibChannelId == 4} {
    set GnuCalibChannel "Mod s22"
    if [file exists $TMPCalibrator3Ds22Txt] {
        if {$GnuplotPipeCalib == ""} {
            GnuPlotInit 0 0 1 1
            set GnuplotPipeCalib $GnuplotPipeFid
	    }
        #PlotCalib3DThumb
        set GnuOutputFile $TMPGnuPlotTk1
        set GnuOutputFormat "gif"
        GnuPlotTerm $GnuplotPipeCalib $GnuOutputFormat
        set Unit ""; if {$CalibOutputUnit == "dB"} {set Unit "dB"}
        GnuPlot3D $GnuplotPipeCalib $TMPCalibrator3Ds22Txt $TMPCalibrator3Ds22Bin "X" "Y" $Unit $GnuXview $GnuZview "Normalized Calibrator Response : s22 Channel" 1 $CalibOutputFormat 1
        }
    }

    puts $GnuplotPipeCalib "unset output"; flush $GnuplotPipeCalib 

    set ErrorCatch [catch {puts $GnuplotPipeCalib "quit"}]
    if { $ErrorCatch == "0" } {
        puts $GnuplotPipeCalib "quit"; flush $GnuplotPipeCalib 
        }
    catch "close $GnuplotPipeCalib"
    set GnuplotPipeCalib ""

    WaitUntilCreated $TMPGnuPlotTk1
    Gimp $TMPGnuPlotTk1
    #ViewGnuPlotTKThumb 1 .top245 "Normalized Calibrator Response"
    }
}
#############################################################################
## Procedure:  ExtractCalibrator

proc ::ExtractCalibrator {} {
global NligFullSize NcolFullSize ErrorMessage VarError
global BMPCalibXX BMPCalibYY CalibOutputRangeLength CalibOutputFormat CalibOutputUnit CalibExecFid
global TMPCalibratorTxt TMPCalibratorBin TMPCalibratorValTxt TMPCalibratorValBin
global TMPCalibrator3Ds11Txt TMPCalibrator3Ds12Txt TMPCalibrator3Ds21Txt TMPCalibrator3Ds22Txt
global TMPCalibrator3Ds11Bin TMPCalibrator3Ds12Bin TMPCalibrator3Ds21Bin TMPCalibrator3Ds22Bin
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set TestVarName(0) "Range Length (pix)"; set TestVarType(0) "int"; set TestVarValue(0) $CalibOutputRangeLength; set TestVarMin(0) "0"; set TestVarMax(0) $NcolFullSize
set TestVarName(1) "Range Length (pix)"; set TestVarType(1) "int"; set TestVarValue(1) $CalibOutputRangeLength; set TestVarMin(1) "0"; set TestVarMax(1) $NligFullSize
TestVar 2
if {$TestVarError == "ok"} {
    set config "true"
    if {$BMPCalibXX == ""} {set config "false"}
    if {$BMPCalibYY == ""} {set config "false"}
    if {$config == "true"} {
        set conf "true"
        if {[expr $BMPCalibXX + $CalibOutputRangeLength/2] > $NcolFullSize } {set conf "false"}
        if {[expr $BMPCalibXX - $CalibOutputRangeLength/2] < 0 } {set conf "false"}
        if {[expr $BMPCalibYY + $CalibOutputRangeLength/2] > $NligFullSize } {set conf "false"}
        if {[expr $BMPCalibYY - $CalibOutputRangeLength/2] < 0 } {set conf "false"}
        if {$conf == "false"} {
            set ErrorMessage "CONFLICT POSITION / RANGE LENGTH" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            DeleteFile $TMPCalibratorTxt
            DeleteFile $TMPCalibratorBin
            DeleteFile $TMPCalibratorValBin
            DeleteFile $TMPCalibrator3Ds11Txt
            DeleteFile $TMPCalibrator3Ds12Txt
            DeleteFile $TMPCalibrator3Ds21Txt
            DeleteFile $TMPCalibrator3Ds22Txt
            DeleteFile $TMPCalibrator3Ds11Bin
            DeleteFile $TMPCalibrator3Ds12Bin
            DeleteFile $TMPCalibrator3Ds21Bin
            DeleteFile $TMPCalibrator3Ds22Bin
            set ProgressLine ""
            puts $CalibExecFid "plot\n"
            flush $CalibExecFid
            fconfigure $CalibExecFid -buffering line
            while {$ProgressLine != "OKplot"} {
                gets $CalibExecFid ProgressLine
                update
                }
            set ProgressLine ""
            puts $CalibExecFid "$CalibOutputRangeLength\n"
            flush $CalibExecFid
            fconfigure $CalibExecFid -buffering line
            while {$ProgressLine != "OKrangelength"} {
                gets $CalibExecFid ProgressLine
                update
                }
            set ProgressLine ""
            puts $CalibExecFid "$BMPCalibXX\n"
            flush $CalibExecFid
            fconfigure $CalibExecFid -buffering line
            while {$ProgressLine != "OKreadcol"} {
                gets $CalibExecFid ProgressLine
                update
                }
            set ProgressLine ""
            puts $CalibExecFid "$BMPCalibYY\n"
            flush $CalibExecFid
            fconfigure $CalibExecFid -buffering line
            while {$ProgressLine != "OKreadlig"} {
                gets $CalibExecFid ProgressLine
                update
                }
            set ProgressLine ""
            puts $CalibExecFid "$CalibOutputUnit\n"
            flush $CalibExecFid
            fconfigure $CalibExecFid -buffering line
            while {$ProgressLine != "OKformat"} {
                gets $CalibExecFid ProgressLine
                update
                }
            set ProgressLine ""
            while {$ProgressLine != "OKplotOK"} {
                gets $CalibExecFid ProgressLine
                update
                }
            }
        }
    }
}
#############################################################################
## Procedure:  PlotCalib1D

proc ::PlotCalib1D {} {
global TMPCalibratorTxt TMPCalibratorBin TMPCalibratorValTxt
global CalibOutputFormat CalibOutputUnit CalibOutputRepresentation
global GnuplotPipeFid GnuplotPipeCalib GnuOutputFormat GnuOutputFile 
global GnuCalibChannelId GnuCalibChannel GnuCalibFile
global TMPGnuPlotTk1 TMPGnuPlot1Tk PSPThumbnails

set xwindow [winfo x .top245]; set ywindow [winfo y .top245]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk
    
if {$GnuplotPipeCalib == ""} {
    GnuPlotInit 0 0 1 1
    set GnuplotPipeCalib $GnuplotPipeFid
    }
    
#PlotCalib1DThumb

set GnuOutputFile $TMPGnuPlotTk1
set GnuOutputFormat "gif"
GnuPlotTerm $GnuplotPipeCalib $GnuOutputFormat

if [file exists $TMPCalibratorValTxt] {
    EditCalibValue
    } else {
    ClearCalibValue
    }

if {$GnuCalibChannelId == 1} {set GnuCalibChannel "Mod s11"}
if {$GnuCalibChannelId == 2} {set GnuCalibChannel "Mod s12"}
if {$GnuCalibChannelId == 3} {set GnuCalibChannel "Mod s21"}
if {$GnuCalibChannelId == 4} {set GnuCalibChannel "Mod s22"}
if {$GnuCalibChannelId == 5} {set GnuCalibChannel "Mod All"}
if {$GnuCalibChannelId == 6} {set GnuCalibChannel "Arg12-11"}
if {$GnuCalibChannelId == 7} {set GnuCalibChannel "Arg21-11"}
if {$GnuCalibChannelId == 8} {set GnuCalibChannel "Arg22-11"}
if {$GnuCalibChannelId == 9} {set GnuCalibChannel "Arg All"}

WaitUntilCreated $TMPCalibratorTxt
if [file exists $TMPCalibratorTxt] {
    set f [open $TMPCalibratorTxt r]
    gets $f xmax;
    gets $f yminmodx; gets $f ymaxmodx; gets $f yminargx; gets $f ymaxargx
    gets $f yminmody; gets $f ymaxmody; gets $f yminargy; gets $f ymaxargy
    close $f
    }
set xmin "0"
incr xmax -1

puts $GnuplotPipeCalib "set autoscale"; flush $GnuplotPipeCalib
        
if {$CalibOutputFormat == "xrange"} {
    puts $GnuplotPipeCalib "set xlabel 'X Range'"; flush $GnuplotPipeCalib
    puts $GnuplotPipeCalib "set title 'X Range Profile - Channel $GnuCalibChannel' textcolor lt 3"; flush $GnuplotPipeCalib
    }
if {$CalibOutputFormat == "yrange"} {
    puts $GnuplotPipeCalib "set xlabel 'Y Range'"; flush $GnuplotPipeCalib
    puts $GnuplotPipeCalib "set title 'Y Range Profile - Channel $GnuCalibChannel' textcolor lt 3"; flush $GnuplotPipeCalib
    }
set xrg "\x5B$xmin:$xmax\x5D"; puts $GnuplotPipeCalib "set xrange $xrg noreverse nowriteback"; flush $GnuplotPipeCalib
if {$CalibOutputRepresentation == "amplitude"} {
    if {$CalibOutputUnit == "db"} {puts $GnuplotPipeCalib "set ylabel 'Amplitude - dB'"; flush $GnuplotPipeCalib}
    if {$CalibOutputUnit == "lin"} {puts $GnuplotPipeCalib "set ylabel 'Amplitude'"; flush $GnuplotPipeCalib}
    if {$CalibOutputFormat == "xrange"} {set yrg "\x5B$yminmodx:$ymaxmodx\x5D"; puts $GnuplotPipeCalib "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeCalib}
    if {$CalibOutputFormat == "yrange"} {set yrg "\x5B$yminmody:$ymaxmody\x5D"; puts $GnuplotPipeCalib "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeCalib}
    }
if {$CalibOutputRepresentation == "phase"} {
    puts $GnuplotPipeCalib "set ylabel 'Argument - (°)'"; flush $GnuplotPipeCalib
    if {$CalibOutputFormat == "xrange"} {set yrg "\x5B$yminargx:$ymaxargx\x5D"; puts $GnuplotPipeCalib "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeCalib}
    if {$CalibOutputFormat == "yrange"} {set yrg "\x5B$yminargy:$ymaxargy\x5D"; puts $GnuplotPipeCalib "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeCalib}
    }
if {$CalibOutputFormat == "xrange"} {
    if {$GnuCalibChannelId == 1} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:2 title 's11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 2} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:3 title 's12 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 3} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:4 title 's21 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 4} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 5} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:2 title 's11 channel' with lines, '$TMPCalibratorBin' using 1:3 title 's12 channel' with lines, '$TMPCalibratorBin' using 1:4 title 's21 channel' with lines, '$TMPCalibratorBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 6} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:6 title 'Arg12-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 7} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:7 title 'Arg21-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 8} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:8 title 'Arg22-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 9} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:6 title 'Arg12-11 channel' with lines, '$TMPCalibratorBin' using 1:7 title 'Arg21-11 channel' with lines, '$TMPCalibratorBin' using 1:8 title 'Arg22-11 channel' with lines"; flush $GnuplotPipeCalib}
    }
if {$CalibOutputFormat == "yrange"} {
    if {$GnuCalibChannelId == 1} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:9 title 's11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 2} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:10 title 's12 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 3} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:11 title 's21 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 4} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:12 title 's22 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 5} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:9 title 's11 channel' with lines, '$TMPCalibratorBin' using 1:10 title 's12 channel' with lines, '$TMPCalibratorBin' using 1:11 title 's21 channel' with lines, '$TMPCalibratorBin' using 1:12 title 's22 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 6} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:13 title 'Arg12-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 7} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:14 title 'Arg21-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 8} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:15 title 'Arg22-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 9} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:13 title 'Arg12-11 channel' with lines, '$TMPCalibratorBin' using 1:14 title 'Arg21-11 channel' with lines, '$TMPCalibratorBin' using 1:15 title 'Arg22-11 channel' with lines"; flush $GnuplotPipeCalib}
    }    

puts $GnuplotPipeCalib "unset output"; flush $GnuplotPipeCalib 

set ErrorCatch [catch {puts $GnuplotPipeCalib "quit"}]
if { $ErrorCatch == "0" } {
    puts $GnuplotPipeCalib "quit"; flush $GnuplotPipeCalib 
    }
catch "close $GnuplotPipeCalib"
set GnuplotPipeCalib ""

WaitUntilCreated $TMPGnuPlotTk1
Gimp $TMPGnuPlotTk1
#ViewGnuPlotTKThumb 1 .top245 "Range Profile"
}
#############################################################################
## Procedure:  ClearCalibValue

proc ::ClearCalibValue {} {
global Resol3X Resol6X Resol9X
global Resol3Y Resol6Y Resol9Y
global PSLRX ISLRX SSLRX
global PSLRY ISLRY SSLRY

set Resol3X ""; set Resol6X ""; set Resol9X ""
set Resol3Y ""; set Resol6Y ""; set Resol9Y ""
set PSLRX ""; set ISLRX ""; set SSLRX ""
set PSLRY ""; set ISLRY ""; set SSLRY ""
}
#############################################################################
## Procedure:  EditCalibValue

proc ::EditCalibValue {} {
global TMPCalibratorValTxt GnuCalibChannelId
global Resol3X Resol6X Resol9X
global Resol3Y Resol6Y Resol9Y
global PSLRX ISLRX SSLRX
global PSLRY ISLRY SSLRY

ClearCalibValue
if {$GnuCalibChannelId < 5} {
    set f [open $TMPCalibratorValTxt r]
    if {$GnuCalibChannelId == 1} {
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        }
    if {$GnuCalibChannelId == 2} {
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        }
    if {$GnuCalibChannelId == 3} {
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        }
    if {$GnuCalibChannelId == 4} {
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        gets $f Resol3X; gets $f Resol6X; gets $f Resol9X;
        gets $f PSLRX; gets $f SSLRX; gets $f ISLRX;
        gets $f Resol3Y; gets $f Resol6Y; gets $f Resol9Y;
        gets $f PSLRY; gets $f SSLRY; gets $f ISLRY;
        }
    close $f
    }
}
#############################################################################
## Procedure:  PlotCalib1DThumb

proc ::PlotCalib1DThumb {} {
global TMPCalibratorTxt TMPCalibratorBin TMPCalibratorValTxt
global CalibOutputFormat CalibOutputUnit CalibOutputRepresentation
global GnuplotPipeFid GnuplotPipeCalib GnuOutputFormat GnuOutputFile 
global GnuCalibChannelId GnuCalibChannel GnuCalibFile
global TMPGnuPlotTk1 TMPGnuPlot1Tk PSPThumbnails

set xwindow [winfo x .top245]; set ywindow [winfo y .top245]

DeleteFile $TMPGnuPlot1Tk
    
set GnuOutputFile $TMPGnuPlot1Tk
set GnuOutputFormat "png"
GnuPlotTerm $GnuplotPipeCalib $GnuOutputFormat

if [file exists $TMPCalibratorValTxt] {
    EditCalibValue
    } else {
    ClearCalibValue
    }

if {$GnuCalibChannelId == 1} {set GnuCalibChannel "Mod s11"}
if {$GnuCalibChannelId == 2} {set GnuCalibChannel "Mod s12"}
if {$GnuCalibChannelId == 3} {set GnuCalibChannel "Mod s21"}
if {$GnuCalibChannelId == 4} {set GnuCalibChannel "Mod s22"}
if {$GnuCalibChannelId == 5} {set GnuCalibChannel "Mod All"}
if {$GnuCalibChannelId == 6} {set GnuCalibChannel "Arg12-11"}
if {$GnuCalibChannelId == 7} {set GnuCalibChannel "Arg21-11"}
if {$GnuCalibChannelId == 8} {set GnuCalibChannel "Arg22-11"}
if {$GnuCalibChannelId == 9} {set GnuCalibChannel "Arg All"}

WaitUntilCreated $TMPCalibratorTxt
if [file exists $TMPCalibratorTxt] {
    set f [open $TMPCalibratorTxt r]
    gets $f xmax;
    gets $f yminmodx; gets $f ymaxmodx; gets $f yminargx; gets $f ymaxargx
    gets $f yminmody; gets $f ymaxmody; gets $f yminargy; gets $f ymaxargy
    close $f
    }
set xmin "0"
incr xmax -1

puts $GnuplotPipeCalib "set autoscale"; flush $GnuplotPipeCalib
        
if {$CalibOutputFormat == "xrange"} {
    puts $GnuplotPipeCalib "set xlabel 'X Range'"; flush $GnuplotPipeCalib
    puts $GnuplotPipeCalib "set title 'X Range Profile - Channel $GnuCalibChannel' textcolor lt 3"; flush $GnuplotPipeCalib
    }
if {$CalibOutputFormat == "yrange"} {
    puts $GnuplotPipeCalib "set xlabel 'Y Range'"; flush $GnuplotPipeCalib
    puts $GnuplotPipeCalib "set title 'Y Range Profile - Channel $GnuCalibChannel' textcolor lt 3"; flush $GnuplotPipeCalib
    }
set xrg "\x5B$xmin:$xmax\x5D"; puts $GnuplotPipeCalib "set xrange $xrg noreverse nowriteback"; flush $GnuplotPipeCalib
if {$CalibOutputRepresentation == "amplitude"} {
    if {$CalibOutputUnit == "db"} {puts $GnuplotPipeCalib "set ylabel 'Amplitude - dB'"; flush $GnuplotPipeCalib}
    if {$CalibOutputUnit == "lin"} {puts $GnuplotPipeCalib "set ylabel 'Amplitude'"; flush $GnuplotPipeCalib}
    if {$CalibOutputFormat == "xrange"} {set yrg "\x5B$yminmodx:$ymaxmodx\x5D"; puts $GnuplotPipeCalib "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeCalib}
    if {$CalibOutputFormat == "yrange"} {set yrg "\x5B$yminmody:$ymaxmody\x5D"; puts $GnuplotPipeCalib "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeCalib}
    }
if {$CalibOutputRepresentation == "phase"} {
    puts $GnuplotPipeCalib "set ylabel 'Argument - (°)'"; flush $GnuplotPipeCalib
    if {$CalibOutputFormat == "xrange"} {set yrg "\x5B$yminargx:$ymaxargx\x5D"; puts $GnuplotPipeCalib "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeCalib}
    if {$CalibOutputFormat == "yrange"} {set yrg "\x5B$yminargy:$ymaxargy\x5D"; puts $GnuplotPipeCalib "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeCalib}
    }
if {$CalibOutputFormat == "xrange"} {
    if {$GnuCalibChannelId == 1} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:2 title 's11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 2} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:3 title 's12 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 3} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:4 title 's21 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 4} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 5} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:2 title 's11 channel' with lines, '$TMPCalibratorBin' using 1:3 title 's12 channel' with lines, '$TMPCalibratorBin' using 1:4 title 's21 channel' with lines, '$TMPCalibratorBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 6} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:6 title 'Arg12-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 7} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:7 title 'Arg21-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 8} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:8 title 'Arg22-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 9} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:6 title 'Arg12-11 channel' with lines, '$TMPCalibratorBin' using 1:7 title 'Arg21-11 channel' with lines, '$TMPCalibratorBin' using 1:8 title 'Arg22-11 channel' with lines"; flush $GnuplotPipeCalib}
    }
if {$CalibOutputFormat == "yrange"} {
    if {$GnuCalibChannelId == 1} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:9 title 's11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 2} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:10 title 's12 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 3} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:11 title 's21 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 4} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:12 title 's22 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 5} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:9 title 's11 channel' with lines, '$TMPCalibratorBin' using 1:10 title 's12 channel' with lines, '$TMPCalibratorBin' using 1:11 title 's21 channel' with lines, '$TMPCalibratorBin' using 1:12 title 's22 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 6} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:13 title 'Arg12-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 7} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:14 title 'Arg21-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 8} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:15 title 'Arg22-11 channel' with lines"; flush $GnuplotPipeCalib}
    if {$GnuCalibChannelId == 9} {puts $GnuplotPipeCalib "plot '$TMPCalibratorBin' using 1:13 title 'Arg12-11 channel' with lines, '$TMPCalibratorBin' using 1:14 title 'Arg21-11 channel' with lines, '$TMPCalibratorBin' using 1:15 title 'Arg22-11 channel' with lines"; flush $GnuplotPipeCalib}
    }    

puts $GnuplotPipeCalib "unset output"; flush $GnuplotPipeCalib 

WaitUntilCreated $TMPGnuPlot1Tk
}
#############################################################################
## Procedure:  PlotCalib3DThumb

proc ::PlotCalib3DThumb {} {
global TMPCalibrator3Ds11Txt TMPCalibrator3Ds11Bin
global TMPCalibrator3Ds12Txt TMPCalibrator3Ds12Bin
global TMPCalibrator3Ds21Txt TMPCalibrator3Ds21Bin
global TMPCalibrator3Ds22Txt TMPCalibrator3Ds22Bin
global TMPCalibratorValTxt
global CalibOutputFormat CalibOutputUnit CalibOutputRepresentation
global GnuplotPipeFid GnuplotPipeCalib GnuOutputFormat GnuOutputFile 
global GnuCalibChannelId GnuCalibChannel GnuCalibFile
global GnuXview GnuZview
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top245]; set ywindow [winfo y .top245]

DeleteFile $TMPGnuPlot1Tk

if [file exists $TMPCalibratorValTxt] {
    EditCalibValue
    } else {
    ClearCalibValue
    }

set GnuOutputFile $TMPGnuPlot1Tk
set GnuOutputFormat "png"
GnuPlotTerm $GnuplotPipeCalib $GnuOutputFormat

if {$GnuCalibChannelId == 1} {
    set GnuCalibChannel "Mod s11"
    if [file exists $TMPCalibrator3Ds11Txt] {
        set Unit ""; if {$CalibOutputUnit == "dB"} {set Unit "dB"}
        GnuPlot3D $GnuplotPipeCalib $TMPCalibrator3Ds11Txt $TMPCalibrator3Ds11Bin "X" "Y" $Unit $GnuXview $GnuZview "Normalized Calibrator Response : s11 Channel" 1 $CalibOutputFormat 1
        }
    }
if {$GnuCalibChannelId == 2} {
    set GnuCalibChannel "Mod s12"
    if [file exists $TMPCalibrator3Ds12Txt] {
        set Unit ""; if {$CalibOutputUnit == "dB"} {set Unit "dB"}
        GnuPlot3D $GnuplotPipeCalib $TMPCalibrator3Ds12Txt $TMPCalibrator3Ds12Bin "X" "Y" $Unit $GnuXview $GnuZview "Normalized Calibrator Response : s12 Channel" 1 $CalibOutputFormat 1
        }
    }
if {$GnuCalibChannelId == 3} {
    set GnuCalibChannel "Mod s21"
    if [file exists $TMPCalibrator3Ds21Txt] {
        set Unit ""; if {$CalibOutputUnit == "dB"} {set Unit "dB"}
        GnuPlot3D $GnuplotPipeCalib $TMPCalibrator3Ds21Txt $TMPCalibrator3Ds21Bin "X" "Y" $Unit $GnuXview $GnuZview "Normalized Calibrator Response : s21 Channel" 1 $CalibOutputFormat 1
        }
    }
if {$GnuCalibChannelId == 4} {
    set GnuCalibChannel "Mod s22"
    if [file exists $TMPCalibrator3Ds22Txt] {
        set Unit ""; if {$CalibOutputUnit == "dB"} {set Unit "dB"}
        GnuPlot3D $GnuplotPipeCalib $TMPCalibrator3Ds22Txt $TMPCalibrator3Ds22Bin "X" "Y" $Unit $GnuXview $GnuZview "Normalized Calibrator Response : s22 Channel" 1 $CalibOutputFormat 1
        }
    }

puts $GnuplotPipeCalib "unset output"; flush $GnuplotPipeCalib 

WaitUntilCreated $TMPGnuPlot1Tk
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

proc vTclWindow.top245 {base} {
    if {$base == ""} {
        set base .top245
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
    wm geometry $top 500x360+200+70; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Calibrator Assessment"
    vTcl:DefineAlias "$top" "Toplevel245" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel245" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel245" 1
    set site_4_0 $site_3_0.cpd78
    canvas $site_4_0.can73 \
        -borderwidth 2 -closeenough 1.0 -height 200 -relief ridge -width 200 
    vTcl:DefineAlias "$site_4_0.can73" "CANVASLENSCALIB" vTcl:WidgetProc "Toplevel245" 1
    bind $site_4_0.can73 <Button-1> {
        MouseButtonDownLens %x %y
    }
    TitleFrame $site_4_0.cpd80 \
        -ipad 2 -text {Mouse Position} 
    vTcl:DefineAlias "$site_4_0.cpd80" "TitleFrame3" vTcl:WidgetProc "Toplevel245" 1
    bind $site_4_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd80 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame29" vTcl:WidgetProc "Toplevel245" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame30" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label27" vTcl:WidgetProc "Toplevel245" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseX -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry52" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame31" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label28" vTcl:WidgetProc "Toplevel245" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseY -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry53" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame32" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab76 \
        -relief groove -text Val -width 4 
    vTcl:DefineAlias "$site_8_0.lab76" "Label29" vTcl:WidgetProc "Toplevel245" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPValue -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry54" vTcl:WidgetProc "Toplevel245" 1
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
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame6" vTcl:WidgetProc "Toplevel245" 1
    set site_5_0 $site_4_0.cpd71
    frame $site_5_0.fra87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra87" "Frame9" vTcl:WidgetProc "Toplevel245" 1
    set site_6_0 $site_5_0.fra87
    button $site_6_0.cpd71 \
        \
        -command {global BMPLens LineXLensInit LineYLensInit LineXLens LineYLens plot2 line_color

if {$line_color == "white"} {
    set line_color "black"
    } else {
    set line_color "white"
    }

set b .top245.fra71.cpd78.cpd71.fra87.cpd71
$b configure -background $line_color -foreground $line_color

$widget(CANVASLENSCALIB) dtag LineXLensInit
$widget(CANVASLENSCALIB) dtag LineYLensInit
$widget(CANVASLENSCALIB) create image 0 0 -anchor nw -image BMPLens
set LineXLensInit {0 0}
set LineYLensInit {0 0}
set LineXLens [$widget(CANVASLENSCALIB) create line 0 0 0 $SizeLens -fill $line_color -width 2]
set LineYLens [$widget(CANVASLENSCALIB) create line 0 0 $SizeLens 0 -fill $line_color -width 2]
$widget(CANVASLENSCALIB) addtag LineXLensInit withtag $LineXLens
$widget(CANVASLENSCALIB) addtag LineYLensInit withtag $LineYLens
set plot2(lastX) 0
set plot2(lastY) 0} \
        -pady 0 -relief ridge -text {   } 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button9" vTcl:WidgetProc "Toplevel245" 1
    button $site_6_0.cpd88 \
        -background #ffff00 \
        -command {global CalibOutputFormat GnuCalibChannelId
global BMPCalibX BMPCalibY BMPCalibXX BMPCalibYY
global BMPCalibXSize BMPCalibYSize
global TMPCalibratorValBin TMPCalibratorValTxt
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

#Avoid any changement of pixel value under test by clicking in the window
set BMPCalibXX $BMPCalibX
set BMPCalibYY $BMPCalibY

ClearCalibValue
ExtractCalibrator
if [file exists $TMPCalibratorValBin] {
    DeleteFile $TMPCalibratorValTxt
    set TestVarName(0) "Pixel Size X"; set TestVarType(0) "float"; set TestVarValue(0) $BMPCalibXSize; set TestVarMin(0) "0"; set TestVarMax(0) "100"
    set TestVarName(1) "Pixel Size Y"; set TestVarType(1) "float"; set TestVarValue(1) $BMPCalibYSize; set TestVarMin(1) "0"; set TestVarMax(1) "100"
    TestVar 2
    if {$TestVarError == "ok"} {
        TextEditorRunTrace "Launch The Process Soft/bin/calibration/calibrator.exe" "k"
        TextEditorRunTrace "Arguments: \x22$TMPCalibratorValTxt\x22 \x22$TMPCalibratorValBin\x22 $BMPCalibXSize $BMPCalibYSize" "k"
        set f [ open "| Soft/bin/calibration/calibrator.exe \x22$TMPCalibratorValTxt\x22 \x22$TMPCalibratorValBin\x22 $BMPCalibXSize $BMPCalibYSize" r+]
        catch "close $f"
        }
    }        
if {$GnuCalibChannelId == 0} { set GnuCalibChannelId 1 }

if {$CalibOutputFormat == "mesh"} {
    PlotCalib3D
    } else {
    PlotCalib1D
    }} \
        -padx 4 -pady 2 -text Plot 
    vTcl:DefineAlias "$site_6_0.cpd88" "Button245" vTcl:WidgetProc "Toplevel245" 1
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    TitleFrame $site_5_0.tit73 \
        -text Channel 
    vTcl:DefineAlias "$site_5_0.tit73" "TitleFrame2" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.tit73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit73 getframe]
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame1" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd76
    button $site_8_0.but77 \
        \
        -command {global CalibOutputFormat GnuCalibChannelId CalibOutputRepresentation

incr GnuCalibChannelId
if {$CalibOutputRepresentation == "amplitude"} {
    if {$CalibOutputFormat == "mesh"} {
        if {$GnuCalibChannelId == 5} { set GnuCalibChannelId 1 }
        } else {
        if {$GnuCalibChannelId == 6} { set GnuCalibChannelId 1 }
        }
    }
if {$CalibOutputRepresentation == "phase"} {
    if {$GnuCalibChannelId == 10} { set GnuCalibChannelId 6 }
    }
    
if {$CalibOutputFormat == "mesh"} {
    PlotCalib3D
    } else {
    PlotCalib1D
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_8_0.but77" "Button6" vTcl:WidgetProc "Toplevel245" 1
    button $site_8_0.cpd78 \
        \
        -command {global CalibOutputFormat GnuCalibChannelId CalibOutputRepresentation

incr GnuCalibChannelId -1
if {$CalibOutputRepresentation == "amplitude"} {
    if {$CalibOutputFormat == "mesh"} {
        if {$GnuCalibChannelId == 0} { set GnuCalibChannelId 4 }
        } else {
        if {$GnuCalibChannelId == 0} { set GnuCalibChannelId 5 }
        }
    }
if {$CalibOutputRepresentation == "phase"} {
    if {$GnuCalibChannelId == 5} { set GnuCalibChannelId 9 }
    }
if {$GnuCalibChannelId == 0} { set GnuCalibChannelId 9 }
if {$CalibOutputFormat == "mesh"} {
    PlotCalib3D
    } else {
    PlotCalib1D
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd78" "Button7" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.but77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    pack $site_8_0.cpd78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    entry $site_7_0.cpd80 \
        -background white -textvariable GnuCalibChannel -width 8 
    vTcl:DefineAlias "$site_7_0.cpd80" "Entry1" vTcl:WidgetProc "Toplevel245" 1
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side right 
    frame $site_5_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra81" "Frame2" vTcl:WidgetProc "Toplevel245" 1
    set site_6_0 $site_5_0.fra81
    frame $site_6_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd66" "Frame5" vTcl:WidgetProc "Toplevel245" 1
    set site_7_0 $site_6_0.cpd66
    button $site_7_0.cpd82 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput CalibDirOutput
global GnuplotPipeFid
global SaveDisplayOutputFile1
global CalibOutputFormat GnuCalibChannel

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

    set SaveDisplayDirOutput $CalibDirOutput

    if {$CalibOutputFormat == "mesh"} {
        if {$GnuCalibChannel == "Mod s11"} {set SaveDisplayOutputFile1 "Calibrator3D_Mod_s11" }
        if {$GnuCalibChannel == "Mod s12"} {set SaveDisplayOutputFile1 "Calibrator3D_Mod_s12" }
        if {$GnuCalibChannel == "Mod s21"} {set SaveDisplayOutputFile1 "Calibrator3D_Mod_s21" }
        if {$GnuCalibChannel == "Mod s22"} {set SaveDisplayOutputFile1 "Calibrator3D_Mod_s22" }
        } else {
        if {$GnuCalibChannel == "Mod s11"} {set SaveDisplayOutputFile1 "Calibrator_Mod_s11" }
        if {$GnuCalibChannel == "Mod s12"} {set SaveDisplayOutputFile1 "Calibrator_Mod_s12" }
        if {$GnuCalibChannel == "Mod s21"} {set SaveDisplayOutputFile1 "Calibrator_Mod_s21" }
        if {$GnuCalibChannel == "Mod s22"} {set SaveDisplayOutputFile1 "Calibrator_Mod_s22" }
        if {$GnuCalibChannel == "Mod All"} {set SaveDisplayOutputFile1 "Calibrator_Mod_All_Channels" }
        if {$GnuCalibChannel == "Arg12-11"} {set SaveDisplayOutputFile1 "Calibrator_Arg_s12s11" }
        if {$GnuCalibChannel == "Arg21-11"} {set SaveDisplayOutputFile1 "Calibrator_Arg_s21s11" }
        if {$GnuCalibChannel == "Arg22-11"} {set SaveDisplayOutputFile1 "Calibrator_Arg_s22s11" }
        if {$GnuCalibChannel == "Arg All"} {set SaveDisplayOutputFile1 "Calibrator_Arg_All_Channels" }
        }
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel245) $widget(Toplevel456); TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] 
    vTcl:DefineAlias "$site_7_0.cpd82" "Button243" vTcl:WidgetProc "Toplevel245" 1
    button $site_7_0.cpd83 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1

Gimp $TMPGnuPlotTk1} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -padx 0 -pady 0 -text { } 
    vTcl:DefineAlias "$site_7_0.cpd83" "Button244" vTcl:WidgetProc "Toplevel245" 1
    pack $site_7_0.cpd82 \
        -in $site_7_0 -anchor center -expand 1 -fill none -ipady 1 -side left 
    pack $site_7_0.cpd83 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    button $site_6_0.cpd83 \
        -background #ffff00 \
        -command {global GnuplotPipeFid GnuplotPipeCalib

if {$GnuplotPipeCalib != ""} {
    catch "close $GnuplotPipeCalib"
    set GnuplotPipeCalib ""
    }
set GnuplotPipeFid ""
Window hide .top401} \
        -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_6_0.cpd83" "Button242" vTcl:WidgetProc "Toplevel245" 1
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra87 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.tit73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra81 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.can73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel245" 1
    set site_4_0 $site_3_0.fra72
    TitleFrame $site_4_0.cpd77 \
        -ipad 2 -text Representation 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame6" vTcl:WidgetProc "Toplevel245" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame33" vTcl:WidgetProc "Toplevel245" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame34" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.fra84
    radiobutton $site_8_0.rad78 \
        -command {global ErrorMessage VarError GnuplotPipeCalib

PlotCalib1D} \
        -text {X Range} -value xrange -variable CalibOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton245_1" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame35" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd71
    radiobutton $site_8_0.rad78 \
        \
        -command {global ErrorMessage VarError GnuplotPipeCalib

    PlotCalib1D
} \
        -text {Y Range} -value yrange -variable CalibOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton245_2" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd72" "Frame39" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd72
    radiobutton $site_8_0.rad78 \
        \
        -command {global ErrorMessage VarError GnuplotPipeCalib

    PlotCalib3D} \
        -text {(X,Y) Range} -value mesh -variable CalibOutputFormat 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton245_5" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    frame $site_6_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame36" vTcl:WidgetProc "Toplevel245" 1
    set site_7_0 $site_6_0.cpd72
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame37" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.fra84
    radiobutton $site_8_0.rad78 \
        \
        -command {global CalibOutputFormat GnuCalibChannelId
global ErrorMessage VarError GnuplotPipeCalib

    $widget(Radiobutton245_5) configure -state normal
    $widget(Radiobutton245_6) configure -state normal
    $widget(Radiobutton245_7) configure -state normal
    $widget(TitleFrame245_1) configure -state normal

    set GnuCalibChannelId 1

    if {$CalibOutputFormat == "mesh"} {
        PlotCalib3D
        } else {
        PlotCalib1D
        }} \
        -text Amplitude -value amplitude -variable CalibOutputRepresentation 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton245_3" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame38" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd71
    radiobutton $site_8_0.rad78 \
        \
        -command {global CalibOutputFormat GnuCalibChannelId
global ErrorMessage VarError GnuplotPipeCalib

    set CalibOutputFormat "xrange"
    $widget(Radiobutton245_5) configure -state disable
    $widget(Radiobutton245_6) configure -state disable
    $widget(Radiobutton245_7) configure -state disable
    $widget(TitleFrame245_1) configure -state disable

    set GnuCalibChannelId 6
    
    PlotCalib1D
} \
        -text Phase -value phase -variable CalibOutputRepresentation 
    vTcl:DefineAlias "$site_8_0.rad78" "Radiobutton245_4" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.rad78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd73 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd73" "Frame40" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd73
    label $site_8_0.cpd95 \
        -text {Range Length (pix)   } 
    vTcl:DefineAlias "$site_8_0.cpd95" "Label1" vTcl:WidgetProc "Toplevel245" 1
    entry $site_8_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable CalibOutputRangeLength -width 4 
    vTcl:DefineAlias "$site_8_0.cpd97" "Entry2" vTcl:WidgetProc "Toplevel245" 1
    pack $site_8_0.cpd95 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd97 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame7" vTcl:WidgetProc "Toplevel245" 1
    set site_5_0 $site_4_0.cpd75
    TitleFrame $site_5_0.cpd76 \
        -ipad 2 -text {Pixel Values} 
    vTcl:DefineAlias "$site_5_0.cpd76" "TitleFrame7" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame41" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame42" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label30" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPCalibX -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry55" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame43" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label31" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPCalibY -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry56" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $site_5_0.cpd86 \
        -ipad 2 -text {Pixel Sizes} 
    vTcl:DefineAlias "$site_5_0.cpd86" "TitleFrame9" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame44" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame48" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label32" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPCalibXSize -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry57" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame49" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label33" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPCalibYSize -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry60" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $site_5_0.tit82 \
        -text Format 
    vTcl:DefineAlias "$site_5_0.tit82" "TitleFrame245_1" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.tit82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit82 getframe]
    radiobutton $site_7_0.cpd83 \
        \
        -command {global ErrorMessage VarError GnuplotPipeCalib
global CalibOutputFormat GnuCalibChannelId

    ExtractCalibrator
    if {$GnuCalibChannelId == 0} { set GnuCalibChannelId 1 }
    if {$CalibOutputFormat == "mesh"} {
        PlotCalib3D
        } else {
        PlotCalib1D
        }
} \
        -text dB -value dB -variable CalibOutputUnit 
    vTcl:DefineAlias "$site_7_0.cpd83" "Radiobutton245_6" vTcl:WidgetProc "Toplevel245" 1
    radiobutton $site_7_0.cpd84 \
        \
        -command {global ErrorMessage VarError GnuplotPipeCalib
global CalibOutputFormat GnuCalibChannelId

    ExtractCalibrator
    if {$GnuCalibChannelId == 0} { set GnuCalibChannelId 1 }
    if {$CalibOutputFormat == "mesh"} {
        PlotCalib3D
        } else {
        PlotCalib1D
        }
} \
        -text lin -value lin -variable CalibOutputUnit 
    vTcl:DefineAlias "$site_7_0.cpd84" "Radiobutton245_7" vTcl:WidgetProc "Toplevel245" 1
    pack $site_7_0.cpd83 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.cpd84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    TitleFrame $site_5_0.cpd85 \
        -ipad 2 -text Orientation 
    vTcl:DefineAlias "$site_5_0.cpd85" "TitleFrame8" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd85 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd85 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame45" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame46" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GnuXview -width 5 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry58" vTcl:WidgetProc "Toplevel245" 1
    button $site_9_0.but86 \
        \
        -command {global GnuXview

set GnuTmp [expr $GnuXview + 5]
if {$GnuTmp > 180} {set GnuTmp [expr $GnuTmp - 180]}
set GnuXview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.but86" "Button2" vTcl:WidgetProc "Toplevel245" 1
    button $site_9_0.cpd87 \
        \
        -command {global GnuXview

set GnuTmp [expr $GnuXview - 5]
if {$GnuTmp < 0} {set GnuTmp [expr $GnuTmp + 180]}
set GnuXview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd87" "Button3" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_9_0.but86 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd87 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame47" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GnuZview -width 5 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry59" vTcl:WidgetProc "Toplevel245" 1
    button $site_9_0.cpd88 \
        \
        -command {global GnuZview

set GnuTmp [expr $GnuZview + 5]
if {$GnuTmp > 360} {set GnuTmp [expr $GnuTmp - 360]}
set GnuZview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_9_0.cpd88" "Button4" vTcl:WidgetProc "Toplevel245" 1
    button $site_9_0.cpd89 \
        \
        -command {global GnuZview

set GnuTmp [expr $GnuZview - 5]
if {$GnuTmp < 0} {set GnuTmp [expr $GnuTmp + 360]}
set GnuZview $GnuTmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_9_0.cpd89" "Button5" vTcl:WidgetProc "Toplevel245" 1
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
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.tit82 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    frame $site_4_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame10" vTcl:WidgetProc "Toplevel245" 1
    set site_5_0 $site_4_0.cpd91
    TitleFrame $site_5_0.cpd76 \
        -ipad 2 -text P.S.L.R 
    vTcl:DefineAlias "$site_5_0.cpd76" "TitleFrame10" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame50" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame51" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label34" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSLRX -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry61" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame52" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label35" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSLRY -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry62" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $site_5_0.cpd86 \
        -ipad 2 -text I.S.L.R 
    vTcl:DefineAlias "$site_5_0.cpd86" "TitleFrame11" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame53" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame54" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label36" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ISLRX -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry63" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame55" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label37" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ISLRY -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry64" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $site_5_0.cpd92 \
        -ipad 2 -text S.S.L.R 
    vTcl:DefineAlias "$site_5_0.cpd92" "TitleFrame12" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd92 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame56" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame57" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label38" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SSLRX -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry65" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame58" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label39" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SSLRY -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry66" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    frame $site_4_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd93" "Frame11" vTcl:WidgetProc "Toplevel245" 1
    set site_5_0 $site_4_0.cpd93
    TitleFrame $site_5_0.cpd76 \
        -ipad 2 -text {Resolution -3dB} 
    vTcl:DefineAlias "$site_5_0.cpd76" "TitleFrame13" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd76 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame59" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame60" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label40" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Resol3X -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry67" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame61" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label41" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Resol3Y -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry68" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $site_5_0.cpd86 \
        -ipad 2 -text {Resolution -6dB} 
    vTcl:DefineAlias "$site_5_0.cpd86" "TitleFrame14" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame62" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame63" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label42" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Resol6X -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry69" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame64" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label43" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Resol6Y -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry70" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    TitleFrame $site_5_0.cpd92 \
        -ipad 2 -text {Resolution -9dB} 
    vTcl:DefineAlias "$site_5_0.cpd92" "TitleFrame15" vTcl:WidgetProc "Toplevel245" 1
    bind $site_5_0.cpd92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd92 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame65" vTcl:WidgetProc "Toplevel245" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame66" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label44" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Resol9X -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry71" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame67" vTcl:WidgetProc "Toplevel245" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 3 
    vTcl:DefineAlias "$site_9_0.lab76" "Label45" vTcl:WidgetProc "Toplevel245" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Resol9Y -width 6 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry72" vTcl:WidgetProc "Toplevel245" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side left 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel245" 1
    set site_3_0 $top.fra92
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CalibrationCalibrator.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel245" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global CalibExecFid Load_SaveDisplay1
global GnuplotPipeFid GnuplotPipeCalib

if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}

set ErrorCatch "0"
set ProgressLine ""
set ErrorCatch [catch {puts $CalibExecFid "exit\n"}]
if { $ErrorCatch == "0" } {
    puts $CalibExecFid "exit\n"
    flush $CalibExecFid
    fconfigure $CalibExecFid -buffering line
    while {$ProgressLine != "OKexit"} {
        gets $CalibExecFid ProgressLine
        update
        }
    catch "close $CalibExecFid"
    }
set CalibExecFid ""

if {$GnuplotPipeCalib != ""} {
    catch "close $GnuplotPipeCalib"
    set GnuplotPipeCalib ""
    }
set GnuplotPipeFid ""    
Window hide .top401
ClosePSPViewer
Window hide $widget(Toplevel245); TextEditorRunTrace "Close Window Calibration Calibrator" "b"} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button245_2" vTcl:WidgetProc "Toplevel245" 1
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
Window show .top245

main $argc $argv
