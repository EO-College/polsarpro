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
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
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
    set base .top330PP
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit73 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra85
    namespace eval ::widgets::$site_8_0.lab76 {
        array set save {-relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
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
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd85
    namespace eval ::widgets::$site_7_0.cpd87 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd87
    namespace eval ::widgets::$site_8_0.che88 {
        array set save {-borderwidth 1 -command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd86 {
        array set save {}
    }
    set site_8_0 $site_7_0.cpd86
    namespace eval ::widgets::$site_8_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd75
    namespace eval ::widgets::$site_9_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.fra84
    namespace eval ::widgets::$site_10_0.che74 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd71
    namespace eval ::widgets::$site_10_0.cpd75 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd89 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd89
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd67 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd67
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd68 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd68
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd69 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd69
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd70 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd70
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd73 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd73
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd74
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd72
    namespace eval ::widgets::$site_9_0.fra84 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.fra84
    namespace eval ::widgets::$site_10_0.cpd77 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd71
    namespace eval ::widgets::$site_10_0.cpd78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd90 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd90
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd77 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd77
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd78 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd78
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd79 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd79
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd80 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd80
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd81 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd81
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd82 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd82
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd74
    namespace eval ::widgets::$site_8_0.rad75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad76 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra77
    namespace eval ::widgets::$site_9_0.lab78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent79 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra79
    namespace eval ::widgets::$site_5_0.but80 {
        array set save {-command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but83 {
        array set save {-background 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.but67 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top330PP
            CmplxPlaneCloseFilesPP
            CmplxPlaneOpenFilesPP
            CmplxPlaneExtractPP
            CmplxPlaneInputFilePP
            CmplxPlaneExtractPPPlot
            CmplxPlaneExtractPPPlotThumb
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
## Procedure:  CmplxPlaneCloseFilesPP

proc ::CmplxPlaneCloseFilesPP {} {
global FileName CmplxPlaneExecFid
global CmplxPlaneRepresentation CmplxPlaneLength
global CmplxPlaneCh1 CmplxPlaneCh2
global CmplxPlaneCh1pCh2 CmplxPlaneCh1mCh2
global CmplxPlaneOpt1 CmplxPlaneOpt2
global CmplxPlaneNR1 CmplxPlaneNR2
global CmplxPlanePDH CmplxPlanePDL 
global CmplxPlaneMaxMag CmplxPlaneMinMag
global CmplxPlaneMaxPha CmplxPlaneMinPha
global CmplxPlaneMagHigh CmplxPlaneMagLow
global CmplxPlanePhaHigh CmplxPlanePhaLow
global CmplxPlaneNopen

set CB_Ch1 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.fra84.che74
set CB_Ch2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.fra84.cpd77
set CB_Ch1pCh2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd71.cpd75
set CB_Ch1mCh2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd71.cpd78
set CB_Opt1 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd89.cpd76
set CB_Opt2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd90.cpd76
set CB_NR1 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd67.cpd76
set CB_NR2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd77.cpd76
set CB_PDH .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd68.cpd76 
set CB_PDL .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd78.cpd76
set CB_MaxMag .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd69.cpd76
set CB_MinMag .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd79.cpd76
set CB_MaxPha .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd70.cpd76
set CB_MinPha .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd80.cpd76
set CB_MagHigh .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd73.cpd76
set CB_MagLow .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd81.cpd76
set CB_PhaHigh .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd74.cpd76 
set CB_PhaLow .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd82.cpd76

if {$CmplxPlaneExecFid != "" } {
    set ProgressLine ""
    puts $CmplxPlaneExecFid "closefile\n"
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKclosefile"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    set ProgressLine ""
    while {$ProgressLine != "OKfinclosefile"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
        
    $CB_Ch1 configure -state disable; $CB_Ch2 configure -state disable;
    $CB_Ch1pCh2 configure -state disable; $CB_Ch1mCh2 configure -state disable;
    $CB_Opt1 configure -state disable; $CB_Opt2 configure -state disable;
    $CB_NR1 configure -state disable; $CB_NR2 configure -state disable;
    $CB_PDH configure -state disable; $CB_PDL configure -state disable;
    $CB_MaxMag configure -state disable; $CB_MinMag configure -state disable;
    $CB_MaxPha configure -state disable; $CB_MinPha configure -state disable;
    $CB_MagHigh configure -state disable; $CB_MagLow configure -state disable;
    $CB_PhaHigh configure -state disable; $CB_PhaLow configure -state disable;
    .top330PP.fra71.fra72.cpd77.f.cpd85.cpd74.fra77.lab78 configure -state disable
    .top330PP.fra71.fra72.cpd77.f.cpd85.cpd74.fra77.ent79 configure -state disable
    set CmplxPlaneRepresentation "point"; set CmplxPlaneLength "11"
    set CmplxPlaneCh1 0; set CmplxPlaneCh2 0
    set CmplxPlaneCh1pCh2 0; set CmplxPlaneCh1mCh2 0;
    set CmplxPlaneOpt1 0; set CmplxPlaneOpt2 0;
    set CmplxPlaneNR1 0; set CmplxPlaneNR2 0;
    set CmplxPlanePDH 0; set CmplxPlanePDL 0
    set CmplxPlaneMaxMag 0; set CmplxPlaneMinMag 0
    set CmplxPlaneMaxPha 0; set CmplxPlaneMinPha 0
    set CmplxPlaneMagHigh 0; set CmplxPlaneMagLow 0
    set CmplxPlanePhaHigh 0; set CmplxPlanePhaLow 0
    set CmplxPlaneNopen 0
    }
}
#############################################################################
## Procedure:  CmplxPlaneOpenFilesPP

proc ::CmplxPlaneOpenFilesPP {} {
global CmplxPlaneExecFid CmplxPlaneDirInput CmplxPlaneAvgCoh
global CmplxPlaneRepresentation CmplxPlaneLength
global CmplxPlaneCh1 CmplxPlaneCh2
global CmplxPlaneCh1pCh2 CmplxPlaneCh1mCh2
global CmplxPlaneOpt1 CmplxPlaneOpt2
global CmplxPlaneNR1 CmplxPlaneNR2
global CmplxPlanePDH CmplxPlanePDL 
global CmplxPlaneMaxMag CmplxPlaneMinMag
global CmplxPlaneMaxPha CmplxPlaneMinPha
global CmplxPlaneMagHigh CmplxPlaneMagLow
global CmplxPlanePhaHigh CmplxPlanePhaLow
global CmplxPlaneNopen CmplxPlaneTitle
global VarError ErrorMessage

set CmplxPlaneTitle(0) ""; for {set i 0} {$i <= 30} {incr i} {set CmplxPlaneTitle($i) ""}
set CB_Ch1 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.fra84.che74
set CB_Ch2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.fra84.cpd77
set CB_Ch1pCh2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd71.cpd75
set CB_Ch1mCh2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd71.cpd78
set CB_Opt1 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd89.cpd76
set CB_Opt2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd90.cpd76
set CB_NR1 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd67.cpd76
set CB_NR2 .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd77.cpd76
set CB_PDH .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd68.cpd76 
set CB_PDL .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd78.cpd76
set CB_MaxMag .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd69.cpd76
set CB_MinMag .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd79.cpd76
set CB_MaxPha .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd70.cpd76
set CB_MinPha .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd80.cpd76
set CB_MagHigh .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd73.cpd76
set CB_MagLow .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd81.cpd76
set CB_PhaHigh .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd75.cpd74.cpd76 
set CB_PhaLow .top330PP.fra71.fra72.cpd77.f.cpd85.cpd86.cpd72.cpd82.cpd76


if {$CmplxPlaneAvgCoh == 0} {
    set CmplxPlaneNopen 0
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_Ch1.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Ch1"
        set CmplxPlaneCh1 1; $CB_Ch1 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_Ch2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Ch2"
        set CmplxPlaneCh2 1; $CB_Ch2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_Ch1pCh2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Ch1pCh2"
        set CmplxPlaneCh1pCh2 1; $CB_Ch1pCh2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_Ch1mCh2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Ch1mCh2"
        set CmplxPlaneCh1mCh2 1; $CB_Ch1mCh2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_Opt1.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Opt1"
        set CmplxPlaneOpt1 1; $CB_Opt1 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_Opt2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Opt2"
        set CmplxPlaneOpt2 1; $CB_Opt2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_Opt_NR1.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "NR1"
        set CmplxPlaneNR1 1; $CB_NR1 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_Opt_NR2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "NR2"
        set CmplxPlaneNR2 1; $CB_NR2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_PDHigh.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "PDH"
        set CmplxPlanePDH 1; $CB_PDH configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_PDLow.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "PDL"
        set CmplxPlanePDL 1; $CB_PDL configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_MaxMag.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MaxMag"
        set CmplxPlaneMaxMag 1; $CB_MaxMag configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_MinMag.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MinMag"
        set CmplxPlaneMinMag 1; $CB_MinMag configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_MaxPha.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MaxPha"
        set CmplxPlaneMaxPha 1; $CB_MaxPha configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_MinPha.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MinPha"
        set CmplxPlaneMinPha 1; $CB_MinPha configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_maxdiff_MagHigh.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MagHigh"
        set CmplxPlaneMagHigh 1; $CB_MagHigh configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_maxdiff_MagLow.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MagLow"
        set CmplxPlaneMagLow 1; $CB_MagLow configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_maxdiff_PhaHigh.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "PhaHigh"
        set CmplxPlanePhaHigh 1; $CB_PhaHigh configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_maxdiff_PhaLow.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "PhaLow"
        set CmplxPlanePhaLow 1; $CB_PhaLow configure -state normal
        incr CmplxPlaneNopen
        }

    } else {
    set CmplxPlaneNopen 0
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_Ch1.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Ch1"
        set CmplxPlaneCh1 1; $CB_Ch1 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_Ch2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Ch2"
        set CmplxPlaneCh2 1; $CB_Ch2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_Ch1pCh2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Ch1pCh2"
        set CmplxPlaneCh1pCh2 1; $CB_Ch1pCh2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_Ch1mCh2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Ch1mCh2"
        set CmplxPlaneCh1mCh2 1; $CB_Ch1mCh2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_Opt1.bin"] {
        CmplxPlaneOpen1File "Opt1"
        set CmplxPlaneOpt1 1; $CB_Opt1 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_Opt2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "Opt2"
        set CmplxPlaneOpt2 1; $CB_Opt2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_Opt_NR1.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "NR1"
        set CmplxPlaneNR1 1; $CB_NR1 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_Opt_NR2.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "NR2"
        set CmplxPlaneNR2 1; $CB_NR2 configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_PDHigh.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "PDH"
        set CmplxPlanePDH 1; $CB_PDH configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_PDLow.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "PDL"
        set CmplxPlanePDL 1; $CB_PDL configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_MaxMag.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MaxMag"
        set CmplxPlaneMaxMag 1; $CB_MaxMag configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_MinMag.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MinMag"
        set CmplxPlaneMinMag 1; $CB_MinMag configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_MaxPha.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MaxPha"
        set CmplxPlaneMaxPha 1; $CB_MaxPha configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_MinPha.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MinPha"
        set CmplxPlaneMinPha 1; $CB_MinPha configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_maxdiff_MagHigh.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MagHigh"
        set CmplxPlaneMagHigh 1; $CB_MagHigh configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_maxdiff_MagLow.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "MagLow"
        set CmplxPlaneMagLow 1; $CB_MagLow configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_maxdiff_PhaHigh.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "PhaHigh"
        set CmplxPlanePhaHigh 1; $CB_PhaHigh configure -state normal
        incr CmplxPlaneNopen
        }
    if [file exists "$CmplxPlaneDirInput/cmplx_coh_avg_maxdiff_PhaLow.bin"] {
        set CmplxPlaneTitle($CmplxPlaneNopen) "PhaLow"
        set CmplxPlanePhaLow 1; $CB_PhaLow configure -state normal
        incr CmplxPlaneNopen
        }
    }
    
if {$CmplxPlaneNopen == 0} {
    set VarError ""
    set ErrorMessage "NO COMPLEX COHERENCE FILES HAVE BEEN CREATED" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    if {$CmplxPlaneExecFid != ""} {
        set ProgressLine ""
        puts $CmplxPlaneExecFid "openfile\n"
        flush $CmplxPlaneExecFid
        fconfigure $CmplxPlaneExecFid -buffering line
        while {$ProgressLine != "OKopenfile"} {
            gets $CmplxPlaneExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $CmplxPlaneExecFid "$CmplxPlaneAvgCoh\n"
        flush $CmplxPlaneExecFid
        fconfigure $CmplxPlaneExecFid -buffering line
        while {$ProgressLine != "OKreadavg"} {
            gets $CmplxPlaneExecFid ProgressLine
            update
            }
        set ProgressLine ""
        puts $CmplxPlaneExecFid "$CmplxPlaneNopen\n"
        flush $CmplxPlaneExecFid
        fconfigure $CmplxPlaneExecFid -buffering line
        while {$ProgressLine != "OKreadNopen"} {
            gets $CmplxPlaneExecFid ProgressLine
            update
            }
        for {set i 0} {$i < $CmplxPlaneNopen} {incr i} {
            set ProgressLine ""
            puts $CmplxPlaneExecFid "$CmplxPlaneTitle($i)\n"
            flush $CmplxPlaneExecFid
            fconfigure $CmplxPlaneExecFid -buffering line
            while {$ProgressLine != "OKreadfile"} {
                gets $CmplxPlaneExecFid ProgressLine
                update
                }
            }            
        set ProgressLine ""
        while {$ProgressLine != "OKfinopenfile"} {
            gets $CmplxPlaneExecFid ProgressLine
            update
            }
        }    
    }
}
#############################################################################
## Procedure:  CmplxPlaneExtractPP

proc ::CmplxPlaneExtractPP {} {
global CmplxPlaneExecFid CmplxPlaneTitle CmplxPlaneExtractVar
global CmplxPlaneRepresentation CmplxPlaneLength
global CmplxPlaneCh1 CmplxPlaneCh2
global CmplxPlaneCh1pCh2 CmplxPlaneCh1mCh2 
global CmplxPlaneOpt1 CmplxPlaneOpt2 
global CmplxPlaneNR1 CmplxPlaneNR2 
global CmplxPlanePDH CmplxPlanePDL 
global CmplxPlaneMaxMag CmplxPlaneMinMag
global CmplxPlaneMaxPha CmplxPlaneMinPha
global CmplxPlaneMagHigh CmplxPlaneMagLow
global CmplxPlanePhaHigh CmplxPlanePhaLow
global CmplxPlaneN TMPCmplxPlaneTxt
global BMPCmplxPlaneX BMPCmplxPlaneY
global VarError ErrorMessage

set config 0
if {$CmplxPlaneCh1 == 1} { incr config }
if {$CmplxPlaneCh2 == 1} { incr config }
if {$CmplxPlaneCh1pCh2 == 1} { incr config }
if {$CmplxPlaneCh1mCh2 == 1} { incr config }
if {$CmplxPlaneOpt1 == 1} { incr config }
if {$CmplxPlaneOpt2 == 1} { incr config }
if {$CmplxPlaneNR1 == 1} { incr config }
if {$CmplxPlaneNR2 == 1} { incr config }
if {$CmplxPlanePDH == 1} { incr config }
if {$CmplxPlanePDL == 1} { incr config }
if {$CmplxPlaneMaxMag == 1} { incr config }
if {$CmplxPlaneMinMag == 1} { incr config }
if {$CmplxPlaneMaxPha == 1} { incr config }
if {$CmplxPlaneMinPha == 1} { incr config }
if {$CmplxPlaneMagHigh == 1} { incr config }
if {$CmplxPlaneMagLow == 1} { incr config }
if {$CmplxPlanePhaHigh == 1} { incr config }
if {$CmplxPlanePhaLow == 1} { incr config }
if {$config == 0} {
    set VarError ""
    set ErrorMessage "SELECT A COMPLEX COHERENCE CHANNEL" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

    DeleteFile $TMPCmplxPlaneTxt

if {$CmplxPlaneExecFid != ""} {
    set ProgressLine ""
    puts $CmplxPlaneExecFid "extract\n"
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKextract"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $CmplxPlaneExecFid "$BMPCmplxPlaneX\n"
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadcol"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $CmplxPlaneExecFid "$BMPCmplxPlaneY\n"
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadlig"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    set ProgressLine ""
    puts $CmplxPlaneExecFid "$CmplxPlaneRepresentation\n"
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadrepresentation"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    
    set ProgressLine ""
    if {$CmplxPlaneRepresentation == "point"} { puts $CmplxPlaneExecFid "0\n" }
    if {$CmplxPlaneRepresentation == "area"} { puts $CmplxPlaneExecFid "$CmplxPlaneLength\n" }
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadlength"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    set CmplxPlaneN 0
    if {$CmplxPlaneCh1 == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Ch1"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneCh2 == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Ch2"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneCh1pCh2 == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Ch1 + Ch2"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneCh1mCh2 == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Ch1 - Ch2"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneOpt1 == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Opt 1"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneOpt2 == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Opt 2"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneNR1 == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "NR 1"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneNR2 == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "NR 2"
        incr CmplxPlaneN
        }
    if {$CmplxPlanePDH == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "PD High"
        incr CmplxPlaneN
        }
    if {$CmplxPlanePDL == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "PD Low"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneMaxMag == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Max Mag"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneMinMag == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Min Mag"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneMaxPha == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Max Pha"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneMinPha == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Min Pha"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneMagHigh == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Mag High"
        incr CmplxPlaneN
        }
    if {$CmplxPlaneMagLow == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Mag Low"
        incr CmplxPlaneN
        }
    if {$CmplxPlanePhaHigh == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Pha High"
        incr CmplxPlaneN
        }
    if {$CmplxPlanePhaLow == 1} {
        set CmplxPlaneTitle($CmplxPlaneN) "Pha Low"
        incr CmplxPlaneN
        }
    set ProgressLine ""
    puts $CmplxPlaneExecFid "$CmplxPlaneN\n"
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadN"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
        
    for {set i 0} {$i < $CmplxPlaneN } {incr i} { CmplxPlaneInputFilePP $CmplxPlaneTitle($i) $i }

    set ProgressLine ""
    while {$ProgressLine != "OKfinextract"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    set CmplxPlaneExtractVar "true"    
    #ExecFid        
    }        
#config        
}
}
#############################################################################
## Procedure:  CmplxPlaneInputFilePP

proc ::CmplxPlaneInputFilePP {namefile numfile} {
global CmplxPlaneExecFid CmplxPlaneLabel

if {$CmplxPlaneExecFid != ""} {
    set ProgressLine ""
    set nf $namefile
    if {$namefile == "Ch1"} { set nf "Ch1" } 
    if {$namefile == "Ch2"} { set nf "Ch2" } 
    if {$namefile == "Ch1 + Ch2"} { set nf "Ch1pCh2" } 
    if {$namefile == "Ch1 - Ch2"} { set nf "Ch1mCh2" } 
    if {$namefile == "Opt 1"} { set nf "Opt1" } 
    if {$namefile == "Opt 2"} { set nf "Opt2" } 
    if {$namefile == "NR 1"} { set nf "NR1" } 
    if {$namefile == "NR 2"} { set nf "NR2" } 
    if {$namefile == "PD High"} { set nf "PDH" } 
    if {$namefile == "PD Low"} { set nf "PDL" } 
    if {$namefile == "Max Mag"} { set nf "MaxMag" } 
    if {$namefile == "Min Mag"} { set nf "MinMag" } 
    if {$namefile == "Max Pha"} { set nf "MaxPha" } 
    if {$namefile == "Min Pha"} { set nf "MinPha" } 
    if {$namefile == "Mag High"} { set nf "MagHigh" } 
    if {$namefile == "Mag Low"} { set nf "MagLow" } 
    if {$namefile == "Pha High"} { set nf "PhaHigh" } 
    if {$namefile == "Pha Low"} { set nf "PhaLow" } 
    puts $CmplxPlaneExecFid "$nf\n"
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKreadname"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    if {$numfile == 0} {
        set CmplxPlaneLabel($numfile) 2
        } else {
        set numfilem1 [expr $numfile - 1]
        if {$CmplxPlaneLabel($numfilem1) == 2} { set CmplxPlaneLabel($numfile) 1 }
        if {$CmplxPlaneLabel($numfilem1) == 1} { set CmplxPlaneLabel($numfile) 6 }
        if {$CmplxPlaneLabel($numfilem1) == 6} { set CmplxPlaneLabel($numfile) 2 }
        }
    }        
}
#############################################################################
## Procedure:  CmplxPlaneExtractPPPlot

proc ::CmplxPlaneExtractPPPlot {} {
global CmplxPlaneExecFid GnuplotPipeFid
global GnuOutputFormat GnuOutputFile GnuplotPipeCmplxPlane
global CmplxPlaneTitle CmplxPlaneLabel
global CmplxPlaneExtractVar
global CmplxPlaneN TMPCmplxPlaneTxt
global CmplxPlaneRepresentation
global CONFIGDir
global ImageMagickMaker TMPGnuPlotTk1 TMPGnuPlot1Tk


set CmplxPlaneLabel(0) ""; for {set i 0} {$i <= 20} {incr i} {set CmplxPlaneLabel($i) ""}
set CmplxPlaneTitle(0) ""; for {set i 0} {$i <= 20} {incr i} {set CmplxPlaneTitle($i) ""}

set CmplxPlaneExtractVar "false"
if {$CmplxPlaneExecFid != ""} { CmplxPlaneExtractPP }

if {$CmplxPlaneExtractVar == "true"} {
    set xwindow [winfo x .top330PP]; set ywindow [winfo y .top330PP]

    DeleteFile $TMPGnuPlotTk1
    DeleteFile $TMPGnuPlot1Tk

    if {$GnuplotPipeCmplxPlane == ""} {
        GnuPlotInit 0 0 1 1
        set GnuplotPipeCmplxPlane $GnuplotPipeFid
        }
    CmplxPlaneExtractPPPlotThumb
    set GnuOutputFile $TMPGnuPlotTk1
    set GnuOutputFormat "gif"
    GnuPlotTerm $GnuplotPipeCmplxPlane $GnuOutputFormat
  
    puts $GnuplotPipeCmplxPlane "load '$CONFIGDir/GnuplotCmplxPlane.txt'"; flush $GnuplotPipeCmplxPlane

    set PlotCommand "plot "
    set CmplxPlaneNm1 [expr $CmplxPlaneN - 1]

    if {$CmplxPlaneRepresentation == "point"} {
        for {set i 0} {$i < $CmplxPlaneN} {incr i} {
            set xx [expr 2*$i + 1]; set yy [expr 2*$i + 2]
            append PlotCommand "'$TMPCmplxPlaneTxt' using $xx:$yy with lines lw 2 title '$CmplxPlaneTitle($i)'"
            if {$i != $CmplxPlaneNm1} { append PlotCommand ", " }
            }    
        }
    if {$CmplxPlaneRepresentation == "area"} {
        for {set i 0} {$i < $CmplxPlaneN} {incr i} {
            set xx [expr 2*$i + 1]; set yy [expr 2*$i + 2]
            append PlotCommand "'$TMPCmplxPlaneTxt' using $xx:$yy with points pt $CmplxPlaneLabel($i) ps 3 title '$CmplxPlaneTitle($i)'"
            if {$i != $CmplxPlaneNm1} { append PlotCommand ", " }
            }    
        }
    
    puts $GnuplotPipeCmplxPlane "$PlotCommand"; flush $GnuplotPipeCmplxPlane

    puts $GnuplotPipeCmplxPlane "unset output"; flush $GnuplotPipeCmplxPlane 

    set ErrorCatch [catch {puts $GnuplotPipeCmplxPlane "quit"}]
    if { $ErrorCatch == "0" } {
        puts $GnuplotPipeCmplxPlane "quit"; flush $GnuplotPipeCmplxPlane 
        }
    catch "close $GnuplotPipeCmplxPlane"
    set GnuplotPipeCmplxPlane ""

    .top330PP.fra71.fra72.fra79.but81 configure -state normal
    .top330PP.fra71.fra72.fra79.but83 configure -state normal
    .top330PP.fra71.fra72.fra79.but71 configure -state normal
    .top330PP.fra71.fra72.fra79.but67 configure -state normal

    WaitUntilCreated $TMPGnuPlotTk1
    ViewGnuPlotTK 1 .top330PP "Complex Plane"
    }
    
}
#############################################################################
## Procedure:  CmplxPlaneExtractPPPlotThumb

proc ::CmplxPlaneExtractPPPlotThumb {} {
global CmplxPlaneExecFid GnuplotPipeFid
global GnuOutputFormat GnuOutputFile GnuplotPipeCmplxPlane
global CmplxPlaneTitle CmplxPlaneLabel
global CmplxPlaneExtractVar
global CmplxPlaneN TMPCmplxPlaneTxt
global CmplxPlaneRepresentation
global CONFIGDir
global ImageMagickMaker TMPGnuPlotTk1 TMPGnuPlot1Tk

    set xwindow [winfo x .top330PP]; set ywindow [winfo y .top330PP]

    DeleteFile $TMPGnuPlot1Tk
    set GnuOutputFile $TMPGnuPlot1Tk
    set GnuOutputFormat "png"
    GnuPlotTerm $GnuplotPipeCmplxPlane $GnuOutputFormat
  
    puts $GnuplotPipeCmplxPlane "load '$CONFIGDir/GnuplotCmplxPlane.txt'"; flush $GnuplotPipeCmplxPlane

    set PlotCommand "plot "
    set CmplxPlaneNm1 [expr $CmplxPlaneN - 1]

    if {$CmplxPlaneRepresentation == "point"} {
        for {set i 0} {$i < $CmplxPlaneN} {incr i} {
            set xx [expr 2*$i + 1]; set yy [expr 2*$i + 2]
            append PlotCommand "'$TMPCmplxPlaneTxt' using $xx:$yy with lines lw 2 title '$CmplxPlaneTitle($i)'"
            if {$i != $CmplxPlaneNm1} { append PlotCommand ", " }
            }    
        }
    if {$CmplxPlaneRepresentation == "area"} {
        for {set i 0} {$i < $CmplxPlaneN} {incr i} {
            set xx [expr 2*$i + 1]; set yy [expr 2*$i + 2]
            append PlotCommand "'$TMPCmplxPlaneTxt' using $xx:$yy with points pt $CmplxPlaneLabel($i) ps 3 title '$CmplxPlaneTitle($i)'"
            if {$i != $CmplxPlaneNm1} { append PlotCommand ", " }
            }    
        }
    
    puts $GnuplotPipeCmplxPlane "$PlotCommand"; flush $GnuplotPipeCmplxPlane

    puts $GnuplotPipeCmplxPlane "unset output"; flush $GnuplotPipeCmplxPlane 

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
    wm geometry $top 200x200+250+250; update
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

proc vTclWindow.top330PP {base} {
    if {$base == ""} {
        set base .top330PP
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
    wm geometry $top 500x400+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Coherences - Complex Plane"
    vTcl:DefineAlias "$top" "Toplevel330PP" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit73 \
        -text {Complex Coherence Raw Data Directory} 
    vTcl:DefineAlias "$top.tit73" "TitleFrame1" vTcl:WidgetProc "Toplevel330PP" 1
    bind $top.tit73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit73 getframe]
    entry $site_4_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CmplxPlaneDirInput 
    vTcl:DefineAlias "$site_4_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel330PP" 1
    button $site_4_0.but76 \
        \
        -command {global DataDir FileName DirName
global CmplxPlaneDirInput CmplxPlaneDirOutput CmplxPlaneOutputDir CmplxPlaneOutputSubDir
global TMPCmplxPlaneTxt
global BMPDirInput BMPViewFileInput
global LineXLensInit LineYLensInit line_color
global BMPCmplxPlaneX BMPCmplxPlaneY BMPCmplxPlaneValue
global OpenDirFile
global BMPCmplxPlaneX0 BMPCmplxPlaneY0
global CmplxPlaneCh1 CmplxPlaneCh2
global CmplxPlaneCh1pCh2 CmplxPlaneCh1mCh2
global CmplxPlaneOpt1 CmplxPlaneOpt2
global CmplxPlaneNR1 CmplxPlaneNR2
global CmplxPlanePDH CmplxPlanePDL 
global CmplxPlaneMaxMag CmplxPlaneMinMag
global CmplxPlaneMaxPha CmplxPlaneMinPha
global CmplxPlaneMagHigh CmplxPlaneMagLow
global CmplxPlanePhaHigh CmplxPlanePhaLow
global CmplxPlaneGHigh CmplxPlaneGLow CmplxPlaneAvgCoh
global ConfigFile VarError ErrorMessage Fonction
global VarWarning WarningMesage WarningMessage2
global CmplxPlaneExecFid CmplxPlaneOutputFile
global CmplxPlaneRepresentation CmplxPlaneLength
global GnuPlotPath GnuplotPipeFid GnuplotPipeCmplxPlane
global GnuOutputFormat GnuOutputFile
global CmplxPlaneLabel CmplxPlaneFile CmplxPlaneTitle CmplxPlaneN
#BMP PROCESS
global Load_ViewBMPLens Load_SaveCmplxPlane PSPTopLevel

if {$OpenDirFile == 0} {

set config ""
set CmplxPlaneDirInputTmp $CmplxPlaneDirInput
set DirName ""
OpenDir $CmplxPlaneDirInput "DATA INPUT DIRECTORY"
if {$DirName != "" } {
    set CmplxPlaneDirInput $DirName
    set config "true"
    } else {
    set CmplxPlaneDirInput $CmplxPlaneDirInputTmp
    set config "false"
    }

if {$config == "true" } {
if [file exists "$CmplxPlaneDirInput/config.txt"] {
    set BMPDirInput $CmplxPlaneDirInput
    set ConfigFile "$CmplxPlaneDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$OpenDirFile == 0} {
            if {$Load_SaveCmplxPlane == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}
            set WarningMessage "OPEN A BMP FILE"
            set WarningMessage2 "TO SELECT AN AREA"
            set VarWarning ""
            Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
            tkwait variable VarWarning

            if {$VarWarning == "ok"} {
                ClosePSPViewer
                Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"

                set types {
                    {{BMP Files}        {.bmp}        }
                    }
                set FileName ""
                OpenFile $BMPDirInput $types "INPUT BMP FILE"

                if {$FileName != ""} {
                    set BMPImageOpen "1"
                    set BMPViewFileInput $FileName

                    if {$Load_ViewBMPLens == 0} {
                        source "GUI/bmp_process/ViewBMPLens.tcl"
                        set Load_ViewBMPLens 1
                        WmTransient .top73 $PSPTopLevel
                        }

                    if {$CmplxPlaneExecFid != ""} {
                        puts $CmplxPlaneExecFid "exit\n"
                        flush $CmplxPlaneExecFid
                        fconfigure $CmplxPlaneExecFid -buffering line
                        while {$ProgressLine != "OKexit"} {
                            gets $CmplxPlaneExecFid ProgressLine
                            update
                            }
                        catch "close $CmplxPlaneExecFid"
                        set CmplxPlaneExecFid ""
                        }
                    if {$GnuplotPipeCmplxPlane != ""} {
                        catch "close $GnuplotPipeCmplxPlane"
                        set GnuplotPipeCmplxPlane ""
                        }
                    set GnuplotPipeFid ""
                    .top330PP.fra71.fra72.fra79.but81 configure -state disable
                    .top330PP.fra71.fra72.fra79.but83 configure -state disable
                    .top330PP.fra71.fra72.fra79.but71 configure -state disable
                    .top330PP.fra71.fra72.fra79.but67 configure -state disable
                    
                    $widget(CANVASLENSCMPLXPLANEPP) dtag $LineXLensInit
                    $widget(CANVASLENSCMPLXPLANEPP) dtag $LineYLensInit

                    set CmplxPlaneLabel(0) ""; for {set i 0} {$i <= 20} {incr i} {set CmplxPlaneLabel($i) ""}
                    set CmplxPlaneFile(0) ""; for {set i 0} {$i <= 20} {incr i} {set CmplxPlaneFile($i) ""}
                    set CmplxPlaneTitle(0) ""; for {set i 0} {$i <= 20} {incr i} {set CmplxPlaneTitle($i) ""}
                    set CmplxPlaneN "0"

                    $widget(Button330PP_1) configure -state disable; $widget(Button330PP_2) configure -state disable;
                    $widget(Button330PP_3) configure -state disable; $widget(Button330PP_4) configure -state disable;
                    $widget(Checkbutton330PP_1) configure -state disable; $widget(Checkbutton330PP_2) configure -state disable;
                    $widget(Checkbutton330PP_4) configure -state disable; $widget(Checkbutton330PP_5) configure -state disable;
                    $widget(Checkbutton330PP_10) configure -state disable; $widget(Checkbutton330PP_11) configure -state disable;
                    $widget(Checkbutton330PP_13) configure -state disable; $widget(Checkbutton330PP_14) configure -state disable;
                    $widget(Checkbutton330PP_16) configure -state disable; $widget(Checkbutton330PP_17) configure -state disable; $widget(Checkbutton330PP_18) configure -state disable;
                    $widget(Checkbutton330PP_19) configure -state disable; $widget(Checkbutton330PP_20) configure -state disable; $widget(Checkbutton330PP_21) configure -state disable;
                    $widget(Checkbutton330PP_22) configure -state disable; $widget(Checkbutton330PP_23) configure -state disable; $widget(Checkbutton330PP_24) configure -state disable;
                    $widget(Checkbutton330PP_25) configure -state disable;
                    $widget(Checkbutton330PP_0) configure -state normal
                    $widget(Label330PP_1) configure -state disable
                    $widget(Entry330PP_1) configure -state disable
                    set line_color "white"
                    set b .top330PP.fra71.fra72.fra79.but80
                    $b configure -background $line_color -foreground $line_color
                    set BMPCmplxPlaneX ""; set BMPCmplxPlaneY ""
                    set BMPCmplxPlaneX0 ""; set BMPCmplxPlaneY0 ""
                    set BMPCmplxPlaneValue ""
                    set GnuOutputFormat "SCREEN"
                    set GnuOutputFile ""; set CmplxPlaneOutputFile ""
                    set CmplxPlaneRepresentation "point"; set CmplxPlaneLength "11"
                    LoadPSPViewer
                    load_bmp_caracteristics $BMPViewFileInput
                    load_bmp_file $BMPViewFileInput    
                    load_bmp_lens_line $widget(Toplevel330PP) $widget(CANVASLENSCMPLXPLANEPP)
                    MouseActiveFunction "LensCMPLXPLANEPP"
                    WidgetShow $widget(Toplevel330PP); TextEditorRunTrace "Open Window Coherence - Complex Plane" "b"
                    TextEditorRunTrace "Launch The Process Soft/data_process_dual/cmplx_plane_extract.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$CmplxPlaneDirInput\x22 -of \x22$TMPCmplxPlaneTxt\x22" "k"
                    set CmplxPlaneExecFid [ open "| Soft/data_process_dual/cmplx_plane_extract.exe -id \x22$CmplxPlaneDirInput\x22 -of \x22$TMPCmplxPlaneTxt\x22" r+]
                    set CmplxPlaneCh1 0; set CmplxPlaneHV 0; set CmplxPlaneCh2 0
                    set CmplxPlaneCh1pCh2 0; set CmplxPlaneCh1mCh2 0; set CmplxPlaneHVpVH 0
                    set CmplxPlaneOpt1 0; set CmplxPlaneOpt2 0; set CmplxPlaneOpt3 0
                    set CmplxPlaneRR 0; set CmplxPlaneLR 0; set CmplxPlaneLL 0
                    set CmplxPlaneNR1 0; set CmplxPlaneNR2 0; set CmplxPlaneNR3 0
                    set CmplxPlanePDH 0; set CmplxPlanePDL 0
                    set CmplxPlaneMaxMag 0; set CmplxPlaneMinMag 0
                    set CmplxPlaneMaxPha 0; set CmplxPlaneMinPha 0
                    set CmplxPlaneMagHigh 0; set CmplxPlaneMagLow 0
                    set CmplxPlanePhaHigh 0; set CmplxPlanePhaLow 0
                    set CmplxPlaneGHigh 0; set CmplxPlaneGLow 0; set CmplxPlaneAvgCoh 0
                    CmplxPlaneOpenFilesPP
                    }
                }
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.but76" "Button2" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.but76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel330PP" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel330PP" 1
    set site_4_0 $site_3_0.cpd78
    canvas $site_4_0.can73 \
        -borderwidth 2 -closeenough 1.0 -height 200 -relief ridge -width 200 
    vTcl:DefineAlias "$site_4_0.can73" "CANVASLENSCMPLXPLANEPP" vTcl:WidgetProc "Toplevel330PP" 1
    bind $site_4_0.can73 <Button-1> {
        MouseButtonDownLens %x %y
    }
    TitleFrame $site_4_0.cpd80 \
        -ipad 2 -text {Mouse Position} 
    vTcl:DefineAlias "$site_4_0.cpd80" "TitleFrame3" vTcl:WidgetProc "Toplevel330PP" 1
    bind $site_4_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd80 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame29" vTcl:WidgetProc "Toplevel330PP" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame30" vTcl:WidgetProc "Toplevel330PP" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label27" vTcl:WidgetProc "Toplevel330PP" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseX -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry52" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame31" vTcl:WidgetProc "Toplevel330PP" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label28" vTcl:WidgetProc "Toplevel330PP" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseY -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry53" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame32" vTcl:WidgetProc "Toplevel330PP" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab76 \
        -relief groove -text Val -width 4 
    vTcl:DefineAlias "$site_8_0.lab76" "Label29" vTcl:WidgetProc "Toplevel330PP" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPValue -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry54" vTcl:WidgetProc "Toplevel330PP" 1
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
    TitleFrame $site_4_0.cpd75 \
        -ipad 2 -text {Pixel Values} 
    vTcl:DefineAlias "$site_4_0.cpd75" "TitleFrame8" vTcl:WidgetProc "Toplevel330PP" 1
    bind $site_4_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame45" vTcl:WidgetProc "Toplevel330PP" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame46" vTcl:WidgetProc "Toplevel330PP" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label33" vTcl:WidgetProc "Toplevel330PP" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPCmplxPlaneX -width 5 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry58" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame47" vTcl:WidgetProc "Toplevel330PP" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label34" vTcl:WidgetProc "Toplevel330PP" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPCmplxPlaneY -width 5 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry59" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame48" vTcl:WidgetProc "Toplevel330PP" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab76 \
        -relief groove -text Val -width 4 
    vTcl:DefineAlias "$site_8_0.lab76" "Label35" vTcl:WidgetProc "Toplevel330PP" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPCmplxPlaneValue -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry60" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.fra85 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.can73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel330PP" 1
    set site_4_0 $site_3_0.fra72
    TitleFrame $site_4_0.cpd77 \
        -ipad 1 -text Representation 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame6" vTcl:WidgetProc "Toplevel330PP" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    frame $site_6_0.cpd85 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd85" "Frame1" vTcl:WidgetProc "Toplevel330PP" 1
    set site_7_0 $site_6_0.cpd85
    frame $site_7_0.cpd87 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd87" "Frame2" vTcl:WidgetProc "Toplevel330PP" 1
    set site_8_0 $site_7_0.cpd87
    checkbutton $site_8_0.che88 \
        -borderwidth 0 \
        -command {CmplxPlaneCloseFilesPP
CmplxPlaneOpenFilesPP} \
        -text {Averaged Coherences} -variable CmplxPlaneAvgCoh 
    vTcl:DefineAlias "$site_8_0.che88" "Checkbutton330PP_0" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_8_0.che88 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    frame $site_7_0.cpd86
    set site_8_0 $site_7_0.cpd86
    frame $site_8_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd75" "Frame52" vTcl:WidgetProc "Toplevel330PP" 1
    set site_9_0 $site_8_0.cpd75
    frame $site_9_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.fra84" "Frame53" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.fra84
    checkbutton $site_10_0.che74 \
        -text Ch1 -variable CmplxPlaneCh1 
    vTcl:DefineAlias "$site_10_0.che74" "Checkbutton330PP_1" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.che74 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd71" "Frame54" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd71
    checkbutton $site_10_0.cpd75 \
        -text {Ch1 + Ch2} -variable CmplxPlaneCh1pCh2 
    vTcl:DefineAlias "$site_10_0.cpd75" "Checkbutton330PP_4" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd75 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd89 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd89" "Frame64" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd89
    checkbutton $site_10_0.cpd76 \
        -text {Opt 1} -variable CmplxPlaneOpt1 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_10" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd67 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd67" "Frame67" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd67
    checkbutton $site_10_0.cpd76 \
        -text {NR 1} -variable CmplxPlaneNR1 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_13" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd68 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd68" "Frame68" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd68
    checkbutton $site_10_0.cpd76 \
        -text {PD High} -variable CmplxPlanePDH 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_16" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd69 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd69" "Frame69" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd69
    checkbutton $site_10_0.cpd76 \
        -text {Max Mag} -variable CmplxPlaneMaxMag 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_18" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd70 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd70" "Frame70" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd70
    checkbutton $site_10_0.cpd76 \
        -text {Max Pha} -variable CmplxPlaneMaxPha 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_20" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd73 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd73" "Frame71" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd73
    checkbutton $site_10_0.cpd76 \
        -text {Mag High} -variable CmplxPlaneMagHigh 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_22" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd74 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd74" "Frame72" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd74
    checkbutton $site_10_0.cpd76 \
        -text {Pha High} -variable CmplxPlanePhaHigh 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_24" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.fra84 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd71 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd89 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd67 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd68 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd69 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd70 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd73 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd74 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    frame $site_8_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd72" "Frame56" vTcl:WidgetProc "Toplevel330PP" 1
    set site_9_0 $site_8_0.cpd72
    frame $site_9_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.fra84" "Frame57" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.fra84
    checkbutton $site_10_0.cpd77 \
        -text Ch2 -variable CmplxPlaneCh2 
    vTcl:DefineAlias "$site_10_0.cpd77" "Checkbutton330PP_2" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd77 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd71" "Frame58" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd71
    checkbutton $site_10_0.cpd78 \
        -text {Ch1 - Ch2} -variable CmplxPlaneCh1mCh2 
    vTcl:DefineAlias "$site_10_0.cpd78" "Checkbutton330PP_5" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd78 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd90 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd90" "Frame65" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd90
    checkbutton $site_10_0.cpd76 \
        -text {Opt 2} -variable CmplxPlaneOpt2 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_11" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd77 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd77" "Frame73" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd77
    checkbutton $site_10_0.cpd76 \
        -text {NR 2} -variable CmplxPlaneNR2 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_14" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd78 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd78" "Frame74" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd78
    checkbutton $site_10_0.cpd76 \
        -text {PD Low} -variable CmplxPlanePDL 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_17" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd79 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd79" "Frame75" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd79
    checkbutton $site_10_0.cpd76 \
        -text {Min Mag} -variable CmplxPlaneMinMag 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_19" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd80 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd80" "Frame76" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd80
    checkbutton $site_10_0.cpd76 \
        -text {Min Pha} -variable CmplxPlaneMinPha 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_21" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd81 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd81" "Frame77" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd81
    checkbutton $site_10_0.cpd76 \
        -text {Mag Low} -variable CmplxPlaneMagLow 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_23" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    frame $site_9_0.cpd82 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.cpd82" "Frame78" vTcl:WidgetProc "Toplevel330PP" 1
    set site_10_0 $site_9_0.cpd82
    checkbutton $site_10_0.cpd76 \
        -text {Pha Low} -variable CmplxPlanePhaLow 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton330PP_25" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.fra84 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd71 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd90 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd77 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd78 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd79 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd80 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd81 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_9_0.cpd82 \
        -in $site_9_0 -anchor center -expand 0 -fill x -side top 
    pack $site_8_0.cpd75 \
        -in $site_8_0 -anchor center -expand 1 -fill y -side left 
    pack $site_8_0.cpd72 \
        -in $site_8_0 -anchor center -expand 1 -fill y -side left 
    frame $site_7_0.cpd74 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd74" "Frame6" vTcl:WidgetProc "Toplevel330PP" 1
    set site_8_0 $site_7_0.cpd74
    radiobutton $site_8_0.rad75 \
        \
        -command {$widget(Label330PP_1) configure -state disable
$widget(Entry330PP_1) configure -state disable} \
        -text Point -value point -variable CmplxPlaneRepresentation 
    vTcl:DefineAlias "$site_8_0.rad75" "Radiobutton1" vTcl:WidgetProc "Toplevel330PP" 1
    radiobutton $site_8_0.rad76 \
        \
        -command {$widget(Label330PP_1) configure -state normal
$widget(Entry330PP_1) configure -state normal} \
        -text Area -value area -variable CmplxPlaneRepresentation 
    vTcl:DefineAlias "$site_8_0.rad76" "Radiobutton2" vTcl:WidgetProc "Toplevel330PP" 1
    frame $site_8_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra77" "Frame9" vTcl:WidgetProc "Toplevel330PP" 1
    set site_9_0 $site_8_0.fra77
    label $site_9_0.lab78 \
        -text {Area Size (pix)} 
    vTcl:DefineAlias "$site_9_0.lab78" "Label330PP_1" vTcl:WidgetProc "Toplevel330PP" 1
    entry $site_9_0.ent79 \
        -background white -disabledforeground SystemDisabledText \
        -foreground #ff0000 -justify center -state disabled \
        -textvariable CmplxPlaneLength -width 5 
    vTcl:DefineAlias "$site_9_0.ent79" "Entry330PP_1" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_9_0.lab78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent79 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.rad75 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.rad76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra77 \
        -in $site_8_0 -anchor center -expand 0 -fill x -side left 
    pack $site_7_0.cpd87 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd86 \
        -in $site_7_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 0 -fill both -side top 
    frame $site_4_0.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra79" "Frame5" vTcl:WidgetProc "Toplevel330PP" 1
    set site_5_0 $site_4_0.fra79
    button $site_5_0.but80 \
        \
        -command {global BMPLens LineXLensInit LineYLensInit LineXLens LineYLens plot2 line_color 

if {$line_color == "white"} {
    set line_color "black"
    } else {
    set line_color "white"
    }

set b .top330PP.fra71.fra72.fra79.but80
$b configure -background $line_color -foreground $line_color

$widget(CANVASLENSCMPLXPLANEPP) dtag LineXLensInit
$widget(CANVASLENSCMPLXPLANEPP) dtag LineYLensInit
$widget(CANVASLENSCMPLXPLANEPP) create image 0 0 -anchor nw -image BMPLens
set LineXLensInit {0 0}
set LineYLensInit {0 0}
set LineXLens [$widget(CANVASLENSCMPLXPLANEPP) create line 0 0 0 $SizeLens -fill $line_color -width 2]
set LineYLens [$widget(CANVASLENSCMPLXPLANEPP) create line 0 0 $SizeLens 0 -fill $line_color -width 2]
$widget(CANVASLENSCMPLXPLANEPP) addtag LineXLensInit withtag $LineXLens
$widget(CANVASLENSCMPLXPLANEPP) addtag LineYLensInit withtag $LineYLens
set plot2(lastX) 0
set plot2(lastY) 0} \
        -pady 0 -relief ridge -text {   } 
    vTcl:DefineAlias "$site_5_0.but80" "Button1" vTcl:WidgetProc "Toplevel330PP" 1
    button $site_5_0.but81 \
        -background #ffff00 \
        -command {global GnuplotPipeCmplxPlane GnuOutputFormat CONFIGDir

if {$GnuplotPipeCmplxPlane != ""} {
    if {$GnuOutputFormat == "SCREEN"} {
        puts $GnuplotPipeCmplxPlane "clear"; flush $GnuplotPipeCmplxPlane
        puts $GnuplotPipeCmplxPlane "reset"; flush $GnuplotPipeCmplxPlane
        }
    puts $GnuplotPipeCmplxPlane "load '$CONFIGDir/GnuplotCmplxPlane.txt'"; flush $GnuplotPipeCmplxPlane
    }} \
        -padx 4 -pady 2 -text Clear 
    vTcl:DefineAlias "$site_5_0.but81" "Button330PP_1" vTcl:WidgetProc "Toplevel330PP" 1
    button $site_5_0.but83 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput CmplxPlaneDirOutput
global GnuplotPipeFid
global SaveDisplayOutputFile1

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

    set SaveDisplayDirOutput $CmplxPlaneDirOutput
    set SaveDisplayOutputFile1 "Coherence_Complex_Plane"
    
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel330PP) $widget(Toplevel456); TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but83" "Button330PP_2" vTcl:WidgetProc "Toplevel330PP" 1
    button $site_5_0.but67 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1

Gimp $TMPGnuPlotTk1} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but67" "Button330PP_4" vTcl:WidgetProc "Toplevel330PP" 1
    button $site_5_0.but71 \
        -background #ffff00 \
        -command {global GnuplotPipeFid GnuplotPipeCmplxPlane

if {$GnuplotPipeCmplxPlane != ""} {
    catch "close $GnuplotPipeCmplxPlane"
    set GnuplotPipeCmplxPlane ""
    }
set GnuplotPipeFid ""
Window hide .top401
.top330PP.fra71.fra72.fra79.but81 configure -state disable
.top330PP.fra71.fra72.fra79.but83 configure -state disable
.top330PP.fra71.fra72.fra79.but71 configure -state disable} \
        -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_5_0.but71" "Button330PP_3" vTcl:WidgetProc "Toplevel330PP" 1
    pack $site_5_0.but80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.fra79 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side left 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel330PP" 1
    set site_3_0 $top.fra92
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CoherenceCmplxPlane.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel330PP" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global CmplxPlaneExecFid GnuplotPipeFid GnuplotPipeCmplxPlane Load_SaveDisplay1

if {$OpenDirFile == 0} {

if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}

set ErrorCatch "0"
set ProgressLine ""
set ErrorCatch [catch {puts $CmplxPlaneExecFid "exit\n"}]
if { $ErrorCatch == "0" } {
    puts $CmplxPlaneExecFid "exit\n"
    flush $CmplxPlaneExecFid
    fconfigure $CmplxPlaneExecFid -buffering line
    while {$ProgressLine != "OKexit"} {
        gets $CmplxPlaneExecFid ProgressLine
        update
        }
    catch "close $CmplxPlaneExecFid"
    }
set CmplxPlaneExecFid ""

if {$GnuplotPipeCmplxPlane != ""} {
    catch "close $GnuplotPipeCmplxPlane"
    set GnuplotPipeCmplxPlane ""
    }
set GnuplotPipeFid ""
Window hide .top401
ClosePSPViewer
Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
Window hide $widget(Toplevel330PP); TextEditorRunTrace "Close Window Coherences - Complex Plane" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button330PP_0" vTcl:WidgetProc "Toplevel330PP" 1
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
    pack $top.tit73 \
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
Window show .top330PP

main $argc $argv
