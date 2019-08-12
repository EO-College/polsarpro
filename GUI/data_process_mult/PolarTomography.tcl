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

        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}

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
    set base .top523
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd66
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.cpd88 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd88 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.lab76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.lab76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd79
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd80 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.lab76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.lab76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd79
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd68 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd68 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd78
    namespace eval ::widgets::$site_4_0.can73 {
        array set save {-borderwidth 1 -closeenough 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
    namespace eval ::widgets::$site_4_0.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra66
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd82 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd67 getframe]
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
    namespace eval ::widgets::$site_4_0.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra69
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd72 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd72
    namespace eval ::widgets::$site_8_0.cpd92 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd92
    namespace eval ::widgets::$site_9_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_9_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.fra73 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra73
    namespace eval ::widgets::$site_8_0.cpd75 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd74 {
        array set save {-borderwidth 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra87
    namespace eval ::widgets::$site_5_0.cpd88 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd88 getframe]
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
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra85
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd74
    namespace eval ::widgets::$site_9_0.lab76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_9_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra70
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.rad66 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra90
    namespace eval ::widgets::$site_3_0.cpd91 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd91 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd93 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd96 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd98 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd78
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd100 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra110 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra110
    namespace eval ::widgets::$site_4_0.cpd112 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd112 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd107 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd107
    namespace eval ::widgets::$site_7_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd104 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd104
    namespace eval ::widgets::$site_7_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd109 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd109
    namespace eval ::widgets::$site_7_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd105 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd105
    namespace eval ::widgets::$site_7_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra113 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra113
    namespace eval ::widgets::$site_5_0.cpd114 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd114 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd104 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd104
    namespace eval ::widgets::$site_8_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd66 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd66
    namespace eval ::widgets::$site_8_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd67 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd67
    namespace eval ::widgets::$site_8_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd69 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd69
    namespace eval ::widgets::$site_8_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra92 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra92
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but66 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
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
            vTclWindow.top523
            PTOMprocesschannel
            PTOMprocessmatrix
            PTOMprocessdecomp
            PTOMprocesshaalp
            PTOMprocessspan
            PTOMreset
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
## Procedure:  PTOMprocesschannel

proc ::PTOMprocesschannel {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMprocessNwinL PTOMprocessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        if {"$PTOMhhpvv"=="1"} { 
            set FileSource "$PTOMProcessDirInput/T11.bin"
            set FileTarget "$PTOMProcessDirOutput/tomo_HHpVV.bin"
            CopyFile $FileSource $FileTarget
            set FileSource "$PTOMProcessDirInput/T11.bin.hdr"
            set FileTarget "$PTOMProcessDirOutput/tomo_HHpVV.bin.hdr"
            CopyFile $FileSource $FileTarget
            }
        if {"$PTOMhhmvv"=="1"} { 
            set FileSource "$PTOMProcessDirInput/T22.bin"
            set FileTarget "$PTOMProcessDirOutput/tomo_HHmVV.bin"
            CopyFile $FileSource $FileTarget
            set FileSource "$PTOMProcessDirInput/T22.bin.hdr"
            set FileTarget "$PTOMProcessDirOutput/tomo_HHmVV.bin.hdr"
            CopyFile $FileSource $FileTarget
            }

        set config "false"
        if {"$PTOMhh"=="1"} { set config "true"}
        if {"$PTOMhv"=="1"} { set config "true"}
        if {"$PTOMvv"=="1"} { set config "true"}
        if {"$config"=="true"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_convert/data_convert.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_convert/data_convert.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            EnviWriteConfigC $TMPDirectory $FinalNlig $FinalNcol
            if {"$PTOMhh"=="1"} { 
                set FileSource "$TMPDirectory/C11.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_HH.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C11.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_HH.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            if {"$PTOMhv"=="1"} { 
                set FileSource "$TMPDirectory/C22.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_HV.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C22.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_HV.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            if {"$PTOMvv"=="1"} { 
                set FileSource "$TMPDirectory/C33.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_VV.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C33.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_VV.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            }

        set config "false"
        if {"$PTOMll"=="1"} { set config "true"}
        if {"$PTOMlr"=="1"} { set config "true"}
        if {"$PTOMrr"=="1"} { set config "true"}
        if {"$config"=="true"} {
            set FileTarget "$TMPDirectory/config.txt"
            set FileSource "$PTOMProcessDirInput/config.txt"
            CopyFile $FileSource $FileTarget
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/basis_change/basis_change.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -phi 0 -tau 45 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/basis_change/basis_change.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -phi 0 -tau 45 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            EnviWriteConfigT $TMPDirectory $FinalNlig $FinalNcol
            WaitUntilCreated "$TMPDirectory/T33.bin.hdr"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_convert/data_convert.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_convert/data_convert.exe -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            EnviWriteConfigC $TMPDirectory $FinalNlig $FinalNcol
            if {"$PTOMll"=="1"} { 
                set FileSource "$TMPDirectory/C11.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_LL.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C11.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_LL.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            if {"$PTOMlr"=="1"} { 
                set FileSource "$TMPDirectory/C22.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_LR.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C22.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_LR.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            if {"$PTOMrr"=="1"} { 
                set FileSource "$TMPDirectory/C33.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_RR.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C33.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_RR.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            }

        }
    }
}
}
#############################################################################
## Procedure:  PTOMprocessmatrix

proc ::PTOMprocessmatrix {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMprocessNwinL PTOMprocessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $PTOMprocessNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $PTOMprocessNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        if {$PTOMcorrT3 == "1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 12 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 12 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError      
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro12.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_Ro12.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}

            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 13 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 13 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro13.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_Ro13.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}
        
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 23 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 23 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro23.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_Ro23.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}
            }
            
        if {$PTOMcorrCCC == "1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr_CCC.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr_CCC.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/CCC.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_CCC.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}        
            }
            
        if {$PTOMcorrCCCN == "1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr_CCC_norm.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr_CCC_norm.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/CCCnorm.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_CCCnorm.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}        
            }
            
        if {$PTOMcorrC3 == "1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_convert/data_convert.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_convert/data_convert.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 12 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 12 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError      
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro12.bin"
            set FileNameOutput "$PTOMProcessDirOutput/C3_Ro12.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}

            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 13 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 13 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro13.bin"
            set FileNameOutput "$PTOMProcessDirOutput/C3_Ro13.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}
        
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 23 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 23 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro23.bin"
            set FileNameOutput "$PTOMProcessDirOutput/C3_Ro23.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}
            }
        }
    }
}
}
#############################################################################
## Procedure:  PTOMprocessdecomp

proc ::PTOMprocessdecomp {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam
global PTOMprocessNwinL PTOMprocessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $PTOMprocessNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $PTOMprocessNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        if {"$PTOMfree"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/freeman_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/freeman_decomposition.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3  -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/Freeman_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Freeman_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Freeman_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Freeman_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Freeman_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Freeman_Vol.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMvz"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/vanzyl92_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/vanzyl92_3components_decomposition.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/VanZyl3_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/VanZyl3_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/VanZyl3_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/VanZyl3_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/VanZyl3_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/VanZyl3_Vol.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMnned"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/arii_nned_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/arii_nned_3components_decomposition.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/Arii3_NNED_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Arii3_NNED_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Arii3_NNED_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Arii3_NNED_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Arii3_NNED_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Arii3_NNED_Vol.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMyam"=="1"} {
            set Fonction2 "of the Yamaguchi Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/yamaguchi_4components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -mod S4R -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/yamaguchi_4components_decomposition.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -mod S4R -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/Yamaguchi4_S4R_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Yamaguchi4_S4R_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Yamaguchi4_S4R_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Yamaguchi4_S4R_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Yamaguchi4_S4R_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Yamaguchi4_S4R_Vol.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Yamaguchi4_S4R_Hlx.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Yamaguchi4_S4R_Hlx.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMsingh"=="1"} {
            set Fonction2 "of the Singh Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/singh_4components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -mod G4U2 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/singh_4components_decomposition.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -mod G4U2 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/Singh4_G4U2_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Singh4_G4U2_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Singh4_G4U2_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Singh4_G4U2_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Singh4_G4U2_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Singh4_G4U2_Vol.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Singh4_G4U2_Hlx.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Singh4_G4U2_Hlx.bin" $FinalNlig $FinalNcol 4}
            }           
        }
    }
}
}
#############################################################################
## Procedure:  PTOMprocesshaalp

proc ::PTOMprocesshaalp {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd
global PTOMprocessNwinL PTOMprocessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $PTOMprocessNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $PTOMprocessNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        if {"$PTOMhaalp"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 1 -fl3 1 -fl4 1 -fl5 1 -fl6 0 -fl7 0 -fl8 0 -fl9 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 1 -fl3 1 -fl4 1 -fl5 1 -fl6 0 -fl7 0 -fl8 0 -fl9 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
  	    TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/lambda.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/lambda.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/alpha.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/anisotropy.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMshannon"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 1 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 1 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/entropy_shannon.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_I.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_I.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_P.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_P.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_norm.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_I_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_I_norm.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_P_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_P_norm.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMprob"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 1 -fl2 1 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 1 -fl2 1 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/l1.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/l1.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/l2.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/l2.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/l3.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/l3.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/p1.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/p1.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/p2.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/p2.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/p3.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/p3.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMasym"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 1 -fl7 1 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 1 -fl7 1 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/asymetry.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/asymetry.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/polarisation_fraction.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/polarisation_fraction.bin" $FinalNlig $FinalNcol 4}
            }
            
        if {"$PTOMerd"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 1 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMprocessNwinL -nwc $PTOMprocessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 1 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/serd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/serd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/derd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/derd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/serd_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/serd_norm.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/derd_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/derd_norm.bin" $FinalNlig $FinalNcol 4}
            }
        }
    }
}
}
#############################################################################
## Procedure:  PTOMprocessspan

proc ::PTOMprocessspan {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMprocessNwinL PTOMprocessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -fmt lin -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -fmt lin -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError      
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        set FileNameOutput "$PTOMProcessDirOutput/span.bin"
        if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 4}

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$PTOMProcessDirInput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError      
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        set FileNameOutput "$PTOMProcessDirOutput/span_db.bin"
        if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 4}
        }
    }
}
}
#############################################################################
## Procedure:  PTOMreset

proc ::PTOMreset {} {
global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMspan PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd

set PTOMhh ""; set PTOMhv ""; set PTOMvv ""; set PTOMhhpvv ""; set PTOMhhmvv ""; set PTOMrr ""; set PTOMlr ""; set PTOMll ""
set PTOMspan ""; set PTOMcorrT3 ""; set PTOMcorrC3 ""; set PTOMcorrCCC ""; set PTOMcorrCCCN ""
set PTOMnned ""; set PTOMvz ""; set PTOMfree ""; set PTOMsingh ""; set PTOMyam ""
set PTOMhaalp ""; set PTOMshannon ""; set PTOMprob ""; set PTOMasym ""; set PTOMerd ""
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
    wm geometry $top 200x200+75+75; update
    wm maxsize $top 3364 1032
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

proc vTclWindow.top523 {base} {
    if {$base == ""} {
        set base .top523
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
    wm geometry $top 500x710+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Polarimetric Tomography ( Pol-TomSAR )"
    vTcl:DefineAlias "$top" "Toplevel523" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd66 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame21" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.cpd66
    TitleFrame $site_3_0.cpd67 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame12" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame54" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd75
    entry $site_6_0.cpd71 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PTOMOutputDir 
    vTcl:DefineAlias "$site_6_0.cpd71" "Entry67" vTcl:WidgetProc "Toplevel523" 1
    entry $site_6_0.cpd69 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PTOMOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd69" "Entry64" vTcl:WidgetProc "Toplevel523" 1
    label $site_6_0.cpd70 \
        -text / -width 2 
    vTcl:DefineAlias "$site_6_0.cpd70" "Label40" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd67 \
        -ipad 0 -text {Input 2D Slant-Range DEM File} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame523_1" vTcl:WidgetProc "Toplevel523" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    frame $site_4_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame70" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.cpd75
    entry $site_5_0.cpd71 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PTOMDEMFile 
    vTcl:DefineAlias "$site_5_0.cpd71" "Entry523_1" vTcl:WidgetProc "Toplevel523" 1
    button $site_5_0.cpd70 \
        \
        -command {global FileName PTOMDirInput PTOMDEMFile

set types {
    {{Bin Files}        {.bin}        }
    }
set FileName ""
OpenFile "$PTOMDirInput" $types "2D SLANT-RANGE DEM FILE"
if {$FileName != ""} {
    set PTOMDEMFile $FileName
    $widget(Checkbutton523_0) configure -state normal
    } else {
    set PTOMDEMFile "Select Input Slant-Range DEM File"
    $widget(Checkbutton523_0) configure -state disable
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd70" "Button523_1" vTcl:WidgetProc "Toplevel523" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd71 \
        -ipad 0 -text {Input 2DSlant-Range Top Height File} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame523_2" vTcl:WidgetProc "Toplevel523" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    frame $site_4_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame71" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.cpd75
    entry $site_5_0.cpd71 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PTOMHeightFile 
    vTcl:DefineAlias "$site_5_0.cpd71" "Entry523_2" vTcl:WidgetProc "Toplevel523" 1
    button $site_5_0.cpd70 \
        \
        -command {global FileName PTOMDirInput PTOMHeightFile

set types {
    {{Bin Files}        {.bin}        }
    }
set FileName ""
OpenFile "$PTOMDirInput" $types "2D SLANT-RANGE TOP HEIGHT FILE"
if {$FileName != ""} {
    set PTOMHeightFile $FileName
    } else {
    set PTOMHeightFile "Select Input Slant-Range Top Height File"
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd70" "Button523_2" vTcl:WidgetProc "Toplevel523" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame22" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd88 \
        -ipad 0 -text {Slant-Range Row values} 
    vTcl:DefineAlias "$site_3_0.cpd88" "TitleFrame8" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd88 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd88 getframe]
    frame $site_5_0.cpd73 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame67" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.lab76 \
        -text {min } 
    vTcl:DefineAlias "$site_6_0.lab76" "Label50" vTcl:WidgetProc "Toplevel523" 1
    entry $site_6_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMRowmin -width 7 
    vTcl:DefineAlias "$site_6_0.ent78" "Entry76" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.lab76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.ent78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side right 
    frame $site_5_0.cpd74 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame72" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab76 \
        -text {max } 
    vTcl:DefineAlias "$site_6_0.lab76" "Label51" vTcl:WidgetProc "Toplevel523" 1
    entry $site_6_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMRowmax -width 7 
    vTcl:DefineAlias "$site_6_0.ent78" "Entry77" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.lab76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.ent78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side right 
    frame $site_5_0.cpd78 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame73" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd78
    frame $site_6_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd79" "Frame16" vTcl:WidgetProc "Toplevel523" 1
    set site_7_0 $site_6_0.cpd79
    radiobutton $site_7_0.cpd75 \
        -borderwidth 0 \
        -command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "col"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "col_"
    append PTOMOutputDir $BMPPTOMX
    }} \
        -text {[m]} -value m -variable PTOMRowunit 
    vTcl:DefineAlias "$site_7_0.cpd75" "Radiobutton353" vTcl:WidgetProc "Toplevel523" 1
    radiobutton $site_7_0.cpd74 \
        -borderwidth 0 \
        -command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "lig"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "row_"
    append PTOMOutputDir $BMPPTOMY
    }} \
        -text {[bin]} -value bin -variable PTOMRowunit 
    vTcl:DefineAlias "$site_7_0.cpd74" "Radiobutton354" vTcl:WidgetProc "Toplevel523" 1
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd80 \
        -ipad 0 -text {Slant-Range Col values} 
    vTcl:DefineAlias "$site_3_0.cpd80" "TitleFrame10" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
    frame $site_5_0.cpd73 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame74" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.lab76 \
        -text {min } 
    vTcl:DefineAlias "$site_6_0.lab76" "Label52" vTcl:WidgetProc "Toplevel523" 1
    entry $site_6_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMColmin -width 7 
    vTcl:DefineAlias "$site_6_0.ent78" "Entry78" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.lab76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.ent78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side right 
    frame $site_5_0.cpd74 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame75" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab76 \
        -text {max } 
    vTcl:DefineAlias "$site_6_0.lab76" "Label53" vTcl:WidgetProc "Toplevel523" 1
    entry $site_6_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMColmax -width 7 
    vTcl:DefineAlias "$site_6_0.ent78" "Entry79" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.lab76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.ent78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side right 
    frame $site_5_0.cpd78 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame76" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd78
    frame $site_6_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd79" "Frame17" vTcl:WidgetProc "Toplevel523" 1
    set site_7_0 $site_6_0.cpd79
    radiobutton $site_7_0.cpd75 \
        -borderwidth 0 \
        -command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "col"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "col_"
    append PTOMOutputDir $BMPPTOMX
    }} \
        -text {[m]} -value m -variable PTOMColunit 
    vTcl:DefineAlias "$site_7_0.cpd75" "Radiobutton355" vTcl:WidgetProc "Toplevel523" 1
    radiobutton $site_7_0.cpd74 \
        -borderwidth 0 \
        -command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "lig"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "row_"
    append PTOMOutputDir $BMPPTOMY
    }} \
        -text {[bin]} -value bin -variable PTOMColunit 
    vTcl:DefineAlias "$site_7_0.cpd74" "Radiobutton356" vTcl:WidgetProc "Toplevel523" 1
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd88 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd80 \
        -in $site_3_0 -anchor center -expand 1 -fill x -padx 1 -side left 
    TitleFrame $top.cpd68 \
        -ipad 1 -text {Pol-TomSAR coherence maps analysis} 
    vTcl:DefineAlias "$top.cpd68" "TitleFrame523" vTcl:WidgetProc "Toplevel523" 1
    bind $top.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd68 getframe]
    frame $site_4_0.cpd74 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame80" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.cpd74
    label $site_5_0.lab85 \
        -text {Window Size : Row} 
    vTcl:DefineAlias "$site_5_0.lab85" "Label21" vTcl:WidgetProc "Toplevel523" 1
    entry $site_5_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMCohMapNwinC -width 5 
    vTcl:DefineAlias "$site_5_0.cpd88" "Entry17" vTcl:WidgetProc "Toplevel523" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMCohMapNwinL -width 5 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry18" vTcl:WidgetProc "Toplevel523" 1
    label $site_5_0.cpd94 \
        -text {  Col} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label22" vTcl:WidgetProc "Toplevel523" 1
    pack $site_5_0.lab85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd88 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame81" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.cpd75
    label $site_5_0.lab85 \
        -text {Sub-sampling : Row} 
    vTcl:DefineAlias "$site_5_0.lab85" "Label24" vTcl:WidgetProc "Toplevel523" 1
    entry $site_5_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMCohMapSSC -width 5 
    vTcl:DefineAlias "$site_5_0.cpd88" "Entry19" vTcl:WidgetProc "Toplevel523" 1
    entry $site_5_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMCohMapSSL -width 5 
    vTcl:DefineAlias "$site_5_0.cpd95" "Entry20" vTcl:WidgetProc "Toplevel523" 1
    label $site_5_0.cpd94 \
        -text {  Col} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label25" vTcl:WidgetProc "Toplevel523" 1
    pack $site_5_0.lab85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd88 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    button $site_4_0.cpd76 \
        -background #ffff00 \
        -command {global PTOMDirInput PTOMDEM PTOMDEMFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global OpenDirFile PTOMCohMapNwinL PTOMCohMapNwinC PTOMCohMapSSL PTOMCohMapSSL

if {$OpenDirFile == 0} {
    set TestVarName(0) "Slant-Range DEM File"; set TestVarType(0) "file"; set TestVarValue(0) $PTOMDEMFile; set TestVarMin(0) ""; set TestVarMax(0) ""
    TestVar 1
    if {$TestVarError == "ok"} {
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_mult/Tomo_coh_disp.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PTOMDirInput\x22 -dem \x22$PTOMDEMFile\x22 -nwr $PTOMCohMapNwinL -nwc $PTOMCohMapNwinC -fr $PTOMCohMapSSL -fc $PTOMCohMapSSC -cd $PTOMDEM" "k"
        set f [ open "| Soft/bin/data_process_mult/Tomo_coh_disp.exe -id \x22$PTOMDirInput\x22 -dem \x22$PTOMDEMFile\x22 -nwr $PTOMCohMapNwinL -nwc $PTOMCohMapNwinC -fr $PTOMCohMapSSL -fc $PTOMCohMapSSC -cd $PTOMDEM" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"    
        if {$PTOMDEM == 0} {
            if [file exists "$PTOMDirInput/Pol_Space_lexico_tomographic_coherences.bmp"] { Gimp "$PTOMDirInput/Pol_Space_lexico_tomographic_coherences.bmp" }
            if [file exists "$PTOMDirInput/Space_pol_lexico_tomographic_coherences.bmp"] { Gimp "$PTOMDirInput/Space_pol_lexico_tomographic_coherences.bmp" }
            if [file exists "$PTOMDirInput/Pol_Space_Pauli_tomographic_coherences.bmp"] { Gimp "$PTOMDirInput/Pol_Space_Pauli_tomographic_coherences.bmp" }
            if [file exists "$PTOMDirInput/Space_pol_Pauli_tomographic_coherences.bmp"] { Gimp "$PTOMDirInput/Space_pol_Pauli_tomographic_coherences.bmp" }
            } else {
            if [file exists "$PTOMDirInput/Pol_Space_lexico_tomographic_coherences_DEMcomp.bmp"] { Gimp "$PTOMDirInput/Pol_Space_lexico_tomographic_coherences_DEMcomp.bmp" }
            if [file exists "$PTOMDirInput/Space_pol_lexico_tomographic_coherences_DEMcomp.bmp"] { Gimp "$PTOMDirInput/Space_pol_lexico_tomographic_coherences_DEMcomp.bmp" }
            if [file exists "$PTOMDirInput/Pol_Space_Pauli_tomographic_coherences_DEMcomp.bmp"] { Gimp "$PTOMDirInput/Pol_Space_Pauli_tomographic_coherences_DEMcomp.bmp" }
            if [file exists "$PTOMDirInput/Space_pol_Pauli_tomographic_coherences_DEMcomp.bmp"] { Gimp "$PTOMDirInput/Space_pol_Pauli_tomographic_coherences_DEMcomp.bmp" }
            }
        }
    }} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_4_0.cpd76" "Button526" vTcl:WidgetProc "Toplevel523" 1
    bindtags $site_4_0.cpd76 "$site_4_0.cpd76 Button $top all _vTclBalloon"
    bind $site_4_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Display the Coherence Map}
    }
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel523" 1
    set site_4_0 $site_3_0.cpd78
    canvas $site_4_0.can73 \
        -borderwidth 2 -closeenough 1.0 -height 200 -relief ridge -width 200 
    vTcl:DefineAlias "$site_4_0.can73" "CANVASLENSPTOM" vTcl:WidgetProc "Toplevel523" 1
    bind $site_4_0.can73 <Button-1> {
        MouseButtonDownLens %x %y
    }
    pack $site_4_0.can73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel523" 1
    set site_4_0 $site_3_0.fra72
    frame $site_4_0.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra66" "Frame6" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.fra66
    TitleFrame $site_5_0.cpd82 \
        -ipad 1 -text {Mouse Position} 
    vTcl:DefineAlias "$site_5_0.cpd82" "TitleFrame7" vTcl:WidgetProc "Toplevel523" 1
    bind $site_5_0.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd82 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame47" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame48" vTcl:WidgetProc "Toplevel523" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_9_0.lab76" "Label34" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseX -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry59" vTcl:WidgetProc "Toplevel523" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame51" vTcl:WidgetProc "Toplevel523" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_9_0.lab76" "Label35" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseY -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry60" vTcl:WidgetProc "Toplevel523" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_5_0.cpd67 \
        -ipad 1 -text {Selected Pixel} 
    vTcl:DefineAlias "$site_5_0.cpd67" "TitleFrame9" vTcl:WidgetProc "Toplevel523" 1
    bind $site_5_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd67 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame55" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame56" vTcl:WidgetProc "Toplevel523" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_9_0.lab76" "Label38" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPPTOMX -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry65" vTcl:WidgetProc "Toplevel523" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame64" vTcl:WidgetProc "Toplevel523" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_9_0.lab76" "Label42" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPPTOMY -width 4 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry66" vTcl:WidgetProc "Toplevel523" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    frame $site_4_0.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra69" "Frame2" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.fra69
    TitleFrame $site_5_0.cpd72 \
        -ipad 1 -text {Window Size} 
    vTcl:DefineAlias "$site_5_0.cpd72" "TitleFrame11" vTcl:WidgetProc "Toplevel523" 1
    bind $site_5_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd72 getframe]
    frame $site_7_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd72" "Frame49" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd72
    frame $site_8_0.cpd92 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd92" "Frame50" vTcl:WidgetProc "Toplevel523" 1
    set site_9_0 $site_8_0.cpd92
    label $site_9_0.lab85 \
        -text Row 
    vTcl:DefineAlias "$site_9_0.lab85" "Label11" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMNwinC -width 5 
    vTcl:DefineAlias "$site_9_0.cpd88" "Entry9" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMNwinL -width 5 
    vTcl:DefineAlias "$site_9_0.cpd95" "Entry11" vTcl:WidgetProc "Toplevel523" 1
    label $site_9_0.cpd94 \
        -text {  Col} 
    vTcl:DefineAlias "$site_9_0.cpd94" "Label12" vTcl:WidgetProc "Toplevel523" 1
    pack $site_9_0.lab85 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_9_0.cpd88 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side right 
    pack $site_9_0.cpd95 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.cpd94 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd92 \
        -in $site_8_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd86 \
        -ipad 1 -text {Tomogram Along :} 
    vTcl:DefineAlias "$site_5_0.cpd86" "TitleFrame13" vTcl:WidgetProc "Toplevel523" 1
    bind $site_5_0.cpd86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd86 getframe]
    frame $site_7_0.fra73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra73" "Frame10" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.fra73
    radiobutton $site_8_0.cpd75 \
        -borderwidth 0 \
        -command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "col"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "col_"
    append PTOMOutputDir $BMPPTOMX
    }} \
        -text {Col ( X )} -value col -variable PTOMSlice 
    vTcl:DefineAlias "$site_8_0.cpd75" "Radiobutton349" vTcl:WidgetProc "Toplevel523" 1
    radiobutton $site_8_0.cpd74 \
        -borderwidth 0 \
        -command {global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMSlice == "lig"} { 
    set PTOMOutputDir $PTOMDirInput
    append PTOMOutputDir "/profile_beamformer_"
    if {$PTOMDEM == "1"} { 
        append PTOMOutputDir "DEMcomp_"
        } else {
        append PTOMOutputDir ""
        }
    append PTOMOutputDir "row_"
    append PTOMOutputDir $BMPPTOMY
    }} \
        -text {Row ( Y )} -value lig -variable PTOMSlice 
    vTcl:DefineAlias "$site_8_0.cpd74" "Radiobutton350" vTcl:WidgetProc "Toplevel523" 1
    pack $site_8_0.cpd75 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra73 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill x -ipady 2 -side left 
    frame $site_4_0.fra87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra87" "Frame7" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.fra87
    TitleFrame $site_5_0.cpd88 \
        -ipad 1 -text {Height (z) values} 
    vTcl:DefineAlias "$site_5_0.cpd88" "TitleFrame5" vTcl:WidgetProc "Toplevel523" 1
    bind $site_5_0.cpd88 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd88 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame36" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd75
    frame $site_8_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra84" "Frame38" vTcl:WidgetProc "Toplevel523" 1
    set site_9_0 $site_8_0.fra84
    label $site_9_0.lab76 \
        -text {z min } 
    vTcl:DefineAlias "$site_9_0.lab76" "Label32" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMzmin -width 8 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry57" vTcl:WidgetProc "Toplevel523" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra85" "Frame45" vTcl:WidgetProc "Toplevel523" 1
    set site_9_0 $site_8_0.fra85
    label $site_9_0.lab76 \
        -text {z max } 
    vTcl:DefineAlias "$site_9_0.lab76" "Label33" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMzmax -width 8 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry58" vTcl:WidgetProc "Toplevel523" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    frame $site_8_0.cpd74 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.cpd74" "Frame52" vTcl:WidgetProc "Toplevel523" 1
    set site_9_0 $site_8_0.cpd74
    label $site_9_0.lab76 \
        -text {delta z } 
    vTcl:DefineAlias "$site_9_0.lab76" "Label36" vTcl:WidgetProc "Toplevel523" 1
    entry $site_9_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable PTOMdz -width 5 
    vTcl:DefineAlias "$site_9_0.ent78" "Entry61" vTcl:WidgetProc "Toplevel523" 1
    pack $site_9_0.lab76 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side left 
    pack $site_9_0.ent78 \
        -in $site_9_0 -anchor center -expand 1 -fill none -side right 
    pack $site_8_0.fra84 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.fra85 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.cpd74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    TitleFrame $site_4_0.cpd77 \
        -ipad 1 -text {Pol-TomSAR analysis} 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame6" vTcl:WidgetProc "Toplevel523" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    button $site_6_0.cpd66 \
        -background #cccccc \
        -command {global PTOMgeneDEM PTOMDEMFile PTOMSRunitDEM PTOMNRvalDEM PTOMFRvalDEM
global PTOMgeneHeight PTOMHeightFile PTOMSRunitHeight PTOMNRvalHeight PTOMFRvalHeight
global OpenDirFile PTOMDirInput
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType

global Load_PolarTomographyGenerator PSPTopLevel

if {$OpenDirFile == 0} {

    if {$Load_PolarTomographyGenerator == 0} {
        source "GUI/data_process_mult/PolarTomographyGenerator.tcl"
        set Load_PolarTomographyGenerator 1
        WmTransient $widget(Toplevel523a) $PSPTopLevel
        }

    $widget(TitleFrame523a_1) configure -state disable; $widget(TitleFrame523a_2) configure -state disable; $widget(TitleFrame523a_3) configure -state disable
    $widget(Radiobutton523a_1) configure -state disable; $widget(Radiobutton523a_2) configure -state disable
    $widget(Label523a_1) configure -state disable; $widget(Label523a_2) configure -state disable
    $widget(Entry523a_1) configure -state disable; $widget(Entry523a_2) configure -state disable
    set PTOMgeneDEM 0
    set PTOMSRunitDEM " "; set PTOMNRvalDEM " "; set PTOMFRvalDEM " "
    if [file exists $PTOMDEMFile] {
        $widget(Checkbutton523a_1) configure -state disable
        } else {
        $widget(Checkbutton523a_1) configure -state normal
        set PTOMDEMFile "Generate Input Slant-Range DEM File"
        }

    $widget(TitleFrame523a_4) configure -state disable; $widget(TitleFrame523a_5) configure -state disable; $widget(TitleFrame523a_6) configure -state disable
    $widget(Radiobutton523a_3) configure -state disable; $widget(Radiobutton523a_4) configure -state disable
    $widget(Label523a_3) configure -state disable; $widget(Label523a_4) configure -state disable
    $widget(Entry523a_3) configure -state disable; $widget(Entry523a_4) configure -state disable
    set PTOMgeneHeight 0
    set PTOMSRunitHeight " "; set PTOMNRvalHeight " "; set PTOMFRvalHeight " "
    if [file exists $PTOMHeightFile] {
        $widget(Checkbutton523a_2) configure -state disable
        } else {
        $widget(Checkbutton523a_2) configure -state normal
        set PTOMHeightFile "Generate Input Slant-Range Top Height File"
        }

    WidgetShowFromMenuFix $widget(Toplevel523) $widget(Toplevel523a); TextEditorRunTrace "Open Window Polarimetric Tomography Generator" "b"
    }} \
        -padx 4 -pady 2 -text Gene 
    vTcl:DefineAlias "$site_6_0.cpd66" "Button528" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_6_0.cpd80 \
        \
        -command {global PTOMDEM PTOMDEMFile PTOMHeightFile
global PTOMDirInput PTOMOutputDir PTOMSlice PTOMDEM
global BMPPTOMX BMPPTOMY

if {$PTOMDEM == 0} {
    if {$PTOMSlice == "col"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_col_"
        append PTOMOutputDir $BMPPTOMX
        }    
    if {$PTOMSlice == "lig"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_row_"
        append PTOMOutputDir $BMPPTOMY
        }    
    } else {
    if {$PTOMSlice == "col"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_DEMcomp_col_"
        append PTOMOutputDir $BMPPTOMX
        }    
    if {$PTOMSlice == "lig"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_DEMcomp_row_"
        append PTOMOutputDir $BMPPTOMY
        }    
    }} \
        -text {DEM compensation} -variable PTOMDEM 
    vTcl:DefineAlias "$site_6_0.cpd80" "Checkbutton523_0" vTcl:WidgetProc "Toplevel523" 1
    button $site_6_0.cpd81 \
        -background #ffff00 \
        -command {global PTOMDirInput PTOMDirOutput PTOMOutputDir PTOMOutputSubDir
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMNwinL PTOMNwinC PTOMDEM PTOMalgo PTOMSlice PTOMzmin PTOMzmax PTOMdz
global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMspan PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd
global PTOMprocessNwinL PTOMprocessNwinC PSPBackgroundColor
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize
global PTOMzdim PTOMxdim PTOMzmin PTOMzmax PTOMxmin PTOMxmax 
global BMPPTOMX BMPPTOMY 
global PTOMDEMFile PTOMHeightFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType

global OpenDirFile 

if {$OpenDirFile == 0} {

    $widget(TitleFrame523_3) configure -state disable; $widget(TitleFrame523_4) configure -state disable
    $widget(TitleFrame523_5) configure -state disable; $widget(TitleFrame523_6) configure -state disable
    $widget(TitleFrame523_8) configure -state disable; $widget(TitleFrame523_9) configure -state disable
    $widget(Entry523_3) configure -state disable; $widget(Entry523_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Button523_3) configure -state disable; $widget(Button523_4) configure -state disable
    $widget(Button523_5) configure -state disable; $widget(Button523_6) configure -state disable
    $widget(Radiobutton523_1) configure -state disable; $widget(Radiobutton523_2) configure -state disable
    $widget(Checkbutton523_1) configure -state disable; $widget(Checkbutton523_2) configure -state disable
    $widget(Checkbutton523_3) configure -state disable; $widget(Checkbutton523_4) configure -state disable
    $widget(Checkbutton523_5) configure -state disable; $widget(Checkbutton523_6) configure -state disable
    $widget(Checkbutton523_7) configure -state disable; $widget(Checkbutton523_8) configure -state disable
    $widget(Checkbutton523_9) configure -state disable; $widget(Checkbutton523_10) configure -state disable
    $widget(Checkbutton523_11) configure -state disable; $widget(Checkbutton523_12) configure -state disable
    $widget(Checkbutton523_13) configure -state disable; $widget(Checkbutton523_14) configure -state disable
    $widget(Checkbutton523_15) configure -state disable; $widget(Checkbutton523_16) configure -state disable
    $widget(Checkbutton523_17) configure -state disable; $widget(Checkbutton523_18) configure -state disable
    $widget(Checkbutton523_19) configure -state disable; $widget(Checkbutton523_20) configure -state disable
    $widget(Checkbutton523_21) configure -state disable; $widget(Checkbutton523_22) configure -state disable
    $widget(Checkbutton523_23) configure -state disable
    set PTOMhh ""; set PTOMhv ""; set PTOMvv ""; set PTOMhhpvv ""; set PTOMhhmvv ""; set PTOMrr ""; set PTOMlr ""; set PTOMll ""
    set PTOMspan ""; set PTOMcorrT3 ""; set PTOMcorrC3 ""; set PTOMcorrCCC ""; set PTOMcorrCCCN ""
    set PTOMnned ""; set PTOMvz ""; set PTOMfree ""; set PTOMsingh ""; set PTOMyam ""
    set PTOMhaalp ""; set PTOMshannon ""; set PTOMprob ""; set PTOMasym ""; set PTOMerd ""
    set PTOMprocessNwinL ""; set PTOMprocessNwinC ""; set PTOMalgo " "

    set PTOMProcessDirInput ""; set PTOMProcessDirOutput ""; set PTOMProcessOutputDir ""; set PTOMProcessOutputSubDir ""

    #PROCESS
    set config ""
    if {$PTOMSlice == "col"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_"
        if {$PTOMDEM == "1"} { 
            append PTOMOutputDir "DEMcomp_"
            } else {
            append PTOMOutputDir ""
            }
        append PTOMOutputDir "col_"
        append PTOMOutputDir $BMPPTOMX
        }
    if {$PTOMSlice == "lig"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_beamformer_"
        if {$PTOMDEM == "1"} { 
            append PTOMOutputDir "DEMcomp_"
            } else {
            append PTOMOutputDir ""
            }
        append PTOMOutputDir "row_"
        append PTOMOutputDir $BMPPTOMY
        }
    set PTOMDirOutput $PTOMOutputDir
    if {$PTOMOutputSubDir != ""} {append PTOMDirOutput "/$PTOMOutputSubDir"}
    #####################################################################
    #Create Directory
    set PTOMDirOutput [PSPCreateDirectory $PTOMDirOutput $PTOMOutputDir $PTOMDirInput]
    #####################################################################       
    if {"$VarWarning"=="ok"} { set PTOMDirOutputBF $PTOMDirOutput; append config "1"}

    if {$PTOMSlice == "col"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_capon_"
        if {$PTOMDEM == "1"} { 
            append PTOMOutputDir "DEMcomp_"
            } else {
            append PTOMOutputDir ""
            }
        append PTOMOutputDir "col_"
        append PTOMOutputDir $BMPPTOMX
        }
    if {$PTOMSlice == "lig"} { 
        set PTOMOutputDir $PTOMDirInput
        append PTOMOutputDir "/profile_capon_"
        if {$PTOMDEM == "1"} { 
            append PTOMOutputDir "DEMcomp_"
            } else {
            append PTOMOutputDir ""
            }
        append PTOMOutputDir "row_"
        append PTOMOutputDir $BMPPTOMY
        }
    set PTOMDirOutput $PTOMOutputDir
    if {$PTOMOutputSubDir != ""} {append PTOMDirOutput "/$PTOMOutputSubDir"}
    #####################################################################
    #Create Directory
    set PTOMDirOutput [PSPCreateDirectory $PTOMDirOutput $PTOMOutputDir $PTOMDirInput]
    #####################################################################       
    if {"$VarWarning"=="ok"} { set PTOMDirOutputCapon $PTOMDirOutput; append config "2"}

if {"$config"=="12"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    if {$PTOMSlice == "col"} { 
        set PTOMrowcut 1; set PTOMind $BMPPTOMX
        set TestVarName(0) "Selected Pixel Col"; set TestVarType(0) "int"; set TestVarValue(0) $BMPPTOMX; set TestVarMin(0) "0"; set TestVarMax(0) $NcolFullSize
        }
    if {$PTOMSlice == "lig"} {
        set PTOMrowcut 0; set PTOMind $BMPPTOMY
        set TestVarName(0) "Selected Pixel Row"; set TestVarType(0) "int"; set TestVarValue(0) $BMPPTOMY; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
         }

    set TestVarName(1) "Window Size Row"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNwinL; set TestVarMin(1) "1"; set TestVarMax(1) "1000"
    set TestVarName(2) "Window Size Col"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNwinC; set TestVarMin(2) "1"; set TestVarMax(2) "1000"
    set TestVarName(3) "z min"; set TestVarType(3) "float"; set TestVarValue(3) $PTOMzmin; set TestVarMin(3) "-9999"; set TestVarMax(3) "9999"
    set TestVarName(4) "z max"; set TestVarType(4) "float"; set TestVarValue(4) $PTOMzmax; set TestVarMin(4) "-9999"; set TestVarMax(4) "9999"
    set TestVarName(5) "z min"; set TestVarType(5) "float"; set TestVarValue(5) $PTOMdz; set TestVarMin(5) "0"; set TestVarMax(5) "9999"
    set TestVarName(6) "Slant-Range DEM File"; set TestVarType(6) "file"; set TestVarValue(6) $PTOMDEMFile; set TestVarMin(6) ""; set TestVarMax(6) ""
    set TestVarName(7) "Slant-Range Top Height File"; set TestVarType(7) "file"; set TestVarValue(7) $PTOMHeightFile; set TestVarMin(7) ""; set TestVarMax(7) ""
    TestVar 8

    if {$TestVarError == "ok"} {
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_mult/Tomo_NP_Spec_est.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PTOMDirInput\x22 -odbf \x22$PTOMDirOutputBF\x22 -odca \x22$PTOMDirOutputCapon\x22 -dem \x22$PTOMDEMFile \x22 -th \x22$PTOMHeightFile\x22 -nwr $PTOMNwinL -nwc $PTOMNwinC -ind $PTOMind -rc $PTOMrowcut -cd $PTOMDEM -zmin $PTOMzmin -zmax $PTOMzmax -dz $PTOMdz" "k"
        set f [ open "| Soft/bin/data_process_mult/Tomo_NP_Spec_est.exe -id \x22$PTOMDirInput\x22 -odbf \x22$PTOMDirOutputBF\x22 -odca \x22$PTOMDirOutputCapon\x22 -dem \x22$PTOMDEMFile \x22 -th \x22$PTOMHeightFile\x22 -nwr $PTOMNwinL -nwc $PTOMNwinC -ind $PTOMind -rc $PTOMrowcut -cd $PTOMDEM -zmin $PTOMzmin -zmax $PTOMzmax -dz $PTOMdz" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"    

        set ConfigFileTomo "$PTOMDirOutputBF/config.txt"  
        WaitUntilCreated $ConfigFileTomo
        if [file exists $ConfigFileTomo] {
            set f [open $ConfigFileTomo r]
            gets $f tmp
            gets $f PTOMNligFullSize
            gets $f tmp
            gets $f tmp
            gets $f PTOMNcolFullSize
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f PTOMzdim
            gets $f tmp
            gets $f tmp
            gets $f PTOMxdim
            gets $f tmp
            gets $f tmp
            gets $f PTOMzmin
            gets $f tmp
            gets $f tmp
            gets $f PTOMzmax
            gets $f tmp
            gets $f tmp
            gets $f PTOMxmin
            gets $f tmp
            gets $f tmp
            gets $f PTOMxmax
            close $f
            set PTOMNligInit "1"; set PTOMNcolInit "1";
            set PTOMNligEnd $PTOMNligFullSize; set PTOMNcolEnd $PTOMNcolFullSize        
            }
            
        EnviWriteConfigT $PTOMDirOutputBF $PTOMNligEnd $PTOMNcolEnd
        EnviWriteConfigT $PTOMDirOutputCapon $PTOMNligEnd $PTOMNcolEnd
        EnviWriteConfig "$PTOMDirOutputBF/DEM_profile.bin" $PTOMNligEnd $PTOMNcolEnd 4            
        EnviWriteConfig "$PTOMDirOutputBF/z_top_profile.bin" $PTOMNligEnd $PTOMNcolEnd 4            
        EnviWriteConfig "$PTOMDirOutputCapon/DEM_profile.bin" $PTOMNligEnd $PTOMNcolEnd 4            
        EnviWriteConfig "$PTOMDirOutputCapon/z_top_profile.bin" $PTOMNligEnd $PTOMNcolEnd 4            

        set PTOMalgo "beam"
        set PTOMProcessDirInput $PTOMDirOutputBF 
        set PTOMProcessDirOutput $PTOMDirOutputBF
        set PTOMProcessOutputDir $PTOMDirOutputBF
        set PTOMProcessOutputSubDir ""
        $widget(TitleFrame523_3) configure -state normal; $widget(TitleFrame523_4) configure -state normal
        $widget(TitleFrame523_5) configure -state normal; $widget(TitleFrame523_6) configure -state normal
        $widget(TitleFrame523_8) configure -state normal; $widget(TitleFrame523_9) configure -state normal
        $widget(Entry523_3) configure -state disable; $widget(Entry523_3) configure -disabledbackground #FFFFFF
        $widget(Button523_3) configure -state normal; $widget(Button523_4) configure -state normal
        $widget(Button523_5) configure -state normal; $widget(Button523_6) configure -state normal
        $widget(Radiobutton523_1) configure -state normal; $widget(Radiobutton523_2) configure -state normal
        $widget(Checkbutton523_1) configure -state normal; $widget(Checkbutton523_2) configure -state normal
        $widget(Checkbutton523_3) configure -state normal; $widget(Checkbutton523_4) configure -state normal
        $widget(Checkbutton523_5) configure -state normal; $widget(Checkbutton523_6) configure -state normal
        $widget(Checkbutton523_7) configure -state normal; $widget(Checkbutton523_8) configure -state normal
        $widget(Checkbutton523_9) configure -state normal; $widget(Checkbutton523_10) configure -state normal
        $widget(Checkbutton523_11) configure -state normal; $widget(Checkbutton523_12) configure -state normal
        $widget(Checkbutton523_13) configure -state normal; $widget(Checkbutton523_14) configure -state normal
        $widget(Checkbutton523_15) configure -state normal; $widget(Checkbutton523_16) configure -state normal
        $widget(Checkbutton523_17) configure -state normal; $widget(Checkbutton523_18) configure -state normal
        $widget(Checkbutton523_19) configure -state normal; $widget(Checkbutton523_20) configure -state normal
        $widget(Checkbutton523_21) configure -state normal; $widget(Checkbutton523_22) configure -state normal
        $widget(Checkbutton523_23) configure -state normal
        set PTOMprocessNwinL "1"; set PTOMprocessNwinC "1" 
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_6_0.cpd81" "Button527" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra66 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra69 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra87 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side right 
    frame $top.fra70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra70" "Frame12" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.fra70
    TitleFrame $site_3_0.cpd72 \
        -ipad 0 -text Algorithm 
    vTcl:DefineAlias "$site_3_0.cpd72" "TitleFrame523_8" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    frame $site_5_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame40" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd75
    radiobutton $site_6_0.rad66 \
        \
        -command {global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir PTOMDirOutputBF
global Load_CreatePolTomoDisplay Load_PolarTomographyGenerator

set PTOMProcessDirInput $PTOMDirOutputBF 
set PTOMProcessDirOutput $PTOMDirOutputBF
set PTOMProcessOutputDir $PTOMDirOutputBF
set PTOMProcessOutputSubDir ""

Window hide .top401tomo
if {$Load_CreatePolTomoDisplay == 1} {
    Window hide $widget(Toplevel524); TextEditorRunTrace "Close Window Create Tomogram Display File" "b"
    }
if {$Load_PolarTomographyGenerator == 1} {
    Window hide $widget(Toplevel523a); TextEditorRunTrace "Close Window Polarimetric Tomography Generator" "b"
    }
PTOMreset} \
        -text B.F -value beam -variable PTOMalgo 
    vTcl:DefineAlias "$site_6_0.rad66" "Radiobutton523_1" vTcl:WidgetProc "Toplevel523" 1
    radiobutton $site_6_0.cpd67 \
        \
        -command {global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir PTOMDirOutputCapon
global Load_CreatePolTomoDisplay Load_PolarTomographyGenerator

set PTOMProcessDirInput $PTOMDirOutputCapon
set PTOMProcessDirOutput $PTOMDirOutputCapon
set PTOMProcessOutputDir $PTOMDirOutputCapon
set PTOMProcessOutputSubDir ""

Window hide .top401tomo
if {$Load_CreatePolTomoDisplay == 1} {
    Window hide $widget(Toplevel524); TextEditorRunTrace "Close Window Create Tomogram Display File" "b"
    }
if {$Load_PolarTomographyGenerator == 1} {
    Window hide $widget(Toplevel523a); TextEditorRunTrace "Close Window Polarimetric Tomography Generator" "b"
    }
PTOMreset} \
        -text Capon -value capon -variable PTOMalgo 
    vTcl:DefineAlias "$site_6_0.cpd67" "Radiobutton523_2" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.rad66 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd67 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Input - Output Process Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame523_9" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    frame $site_5_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame65" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd75
    entry $site_6_0.cpd71 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PTOMProcessDirInput 
    vTcl:DefineAlias "$site_6_0.cpd71" "Entry523_3" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill both -padx 2 -side left 
    frame $top.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra90" "Frame5" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.fra90
    TitleFrame $site_3_0.cpd91 \
        -ipad 0 -text {Polarization Channels} 
    vTcl:DefineAlias "$site_3_0.cpd91" "TitleFrame523_3" vTcl:WidgetProc "Toplevel523" 1
    bind $site_3_0.cpd91 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd91 getframe]
    frame $site_5_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame39" vTcl:WidgetProc "Toplevel523" 1
    set site_6_0 $site_5_0.cpd75
    checkbutton $site_6_0.che78 \
        -text HH -variable PTOMhh 
    vTcl:DefineAlias "$site_6_0.che78" "Checkbutton523_1" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_6_0.cpd79 \
        -text HV -variable PTOMhv 
    vTcl:DefineAlias "$site_6_0.cpd79" "Checkbutton523_2" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_6_0.cpd93 \
        -text VV -variable PTOMvv 
    vTcl:DefineAlias "$site_6_0.cpd93" "Checkbutton523_3" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_6_0.cpd94 \
        -text {HH + VV} -variable PTOMhhpvv 
    vTcl:DefineAlias "$site_6_0.cpd94" "Checkbutton523_4" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_6_0.cpd95 \
        -text {HH - VV} -variable PTOMhhmvv 
    vTcl:DefineAlias "$site_6_0.cpd95" "Checkbutton523_5" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_6_0.cpd96 \
        -text LL -variable PTOMll 
    vTcl:DefineAlias "$site_6_0.cpd96" "Checkbutton523_6" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_6_0.cpd97 \
        -text LR -variable PTOMlr 
    vTcl:DefineAlias "$site_6_0.cpd97" "Checkbutton523_7" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_6_0.cpd98 \
        -text RR -variable PTOMrr 
    vTcl:DefineAlias "$site_6_0.cpd98" "Checkbutton523_8" vTcl:WidgetProc "Toplevel523" 1
    pack $site_6_0.che78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd93 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd96 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd98 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_3_0.cpd78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame13" vTcl:WidgetProc "Toplevel523" 1
    set site_4_0 $site_3_0.cpd78
    TitleFrame $site_4_0.cpd76 \
        -ipad 0 -text {Matrix Elements} 
    vTcl:DefineAlias "$site_4_0.cpd76" "TitleFrame523_4" vTcl:WidgetProc "Toplevel523" 1
    bind $site_4_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame44" vTcl:WidgetProc "Toplevel523" 1
    set site_7_0 $site_6_0.cpd75
    checkbutton $site_7_0.che78 \
        -text Span -variable PTOMspan 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton523_9" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_7_0.cpd79 \
        -text {Corr Coeffs - [T3]} -variable PTOMcorrT3 
    vTcl:DefineAlias "$site_7_0.cpd79" "Checkbutton523_10" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_7_0.cpd100 \
        -text {Corr Coeffs - [C3]} -variable PTOMcorrC3 
    vTcl:DefineAlias "$site_7_0.cpd100" "Checkbutton523_11" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_7_0.cpd71 \
        -text C.C.C -variable PTOMcorrCCC 
    vTcl:DefineAlias "$site_7_0.cpd71" "Checkbutton523_12" vTcl:WidgetProc "Toplevel523" 1
    checkbutton $site_7_0.cpd72 \
        -text {Normalized C.C.C} -variable PTOMcorrCCCN 
    vTcl:DefineAlias "$site_7_0.cpd72" "Checkbutton523_21" vTcl:WidgetProc "Toplevel523" 1
    pack $site_7_0.che78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd100 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $site_3_0.fra110 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra110" "Frame9" vTcl:WidgetProc "Toplevel523" 1
    set site_4_0 $site_3_0.fra110
    TitleFrame $site_4_0.cpd112 \
        -ipad 0 -text {Polarimetric Decompositions} 
    vTcl:DefineAlias "$site_4_0.cpd112" "TitleFrame523_5" vTcl:WidgetProc "Toplevel523" 1
    bind $site_4_0.cpd112 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd112 getframe]
    frame $site_6_0.cpd107 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd107" "Frame59" vTcl:WidgetProc "Toplevel523" 1
    set site_7_0 $site_6_0.cpd107
    checkbutton $site_7_0.che78 \
        -text {Arii NNED 3 components} -variable PTOMnned 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton523_13" vTcl:WidgetProc "Toplevel523" 1
    pack $site_7_0.che78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame60" vTcl:WidgetProc "Toplevel523" 1
    set site_7_0 $site_6_0.cpd75
    checkbutton $site_7_0.che78 \
        -text {Van Zyl 3 components} -variable PTOMvz 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton523_14" vTcl:WidgetProc "Toplevel523" 1
    pack $site_7_0.che78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd104 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd104" "Frame61" vTcl:WidgetProc "Toplevel523" 1
    set site_7_0 $site_6_0.cpd104
    checkbutton $site_7_0.che78 \
        -text {Freeman 3 components} -variable PTOMfree 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton523_15" vTcl:WidgetProc "Toplevel523" 1
    pack $site_7_0.che78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd109 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd109" "Frame62" vTcl:WidgetProc "Toplevel523" 1
    set site_7_0 $site_6_0.cpd109
    checkbutton $site_7_0.che78 \
        -text {Singh 4 components} -variable PTOMsingh 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton523_16" vTcl:WidgetProc "Toplevel523" 1
    pack $site_7_0.che78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd105 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd105" "Frame63" vTcl:WidgetProc "Toplevel523" 1
    set site_7_0 $site_6_0.cpd105
    checkbutton $site_7_0.che78 \
        -text {Yamaguchi 4 components} -variable PTOMyam 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton523_17" vTcl:WidgetProc "Toplevel523" 1
    pack $site_7_0.che78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd107 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd104 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd109 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd105 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_4_0.fra113 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra113" "Frame11" vTcl:WidgetProc "Toplevel523" 1
    set site_5_0 $site_4_0.fra113
    TitleFrame $site_5_0.cpd114 \
        -ipad 0 -text {Eigenvalues parameters} 
    vTcl:DefineAlias "$site_5_0.cpd114" "TitleFrame523_6" vTcl:WidgetProc "Toplevel523" 1
    bind $site_5_0.cpd114 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd114 getframe]
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame42" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd75
    checkbutton $site_8_0.che78 \
        -text {Entropy / Anisotropy / Alpha / Lambda} -variable PTOMhaalp 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton523_18" vTcl:WidgetProc "Toplevel523" 1
    pack $site_8_0.che78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd104 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd104" "Frame53" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd104
    checkbutton $site_8_0.che78 \
        -text {Shannon Entropy} -variable PTOMshannon 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton523_19" vTcl:WidgetProc "Toplevel523" 1
    pack $site_8_0.che78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd66 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd66" "Frame57" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd66
    checkbutton $site_8_0.che78 \
        -text {Probabilities (p1,p2,p3)  / eigenvalues (L1,L2,L3) } \
        -variable PTOMprob 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton523_20" vTcl:WidgetProc "Toplevel523" 1
    pack $site_8_0.che78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd67 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd67" "Frame68" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd67
    checkbutton $site_8_0.che78 \
        -text {Eigenvalue Relative Difference (E.R.D)} -variable PTOMerd 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton523_22" vTcl:WidgetProc "Toplevel523" 1
    pack $site_8_0.che78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd69 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd69" "Frame69" vTcl:WidgetProc "Toplevel523" 1
    set site_8_0 $site_7_0.cpd69
    checkbutton $site_8_0.che78 \
        -text {Polarisation asymetry / polarisation fraction} \
        -variable PTOMasym 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton523_23" vTcl:WidgetProc "Toplevel523" 1
    pack $site_8_0.che78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd104 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd66 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd67 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd69 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd114 \
        -in $site_5_0 -anchor center -expand 1 -fill both -padx 1 -side top 
    pack $site_4_0.cpd112 \
        -in $site_4_0 -anchor center -expand 1 -fill both -padx 1 -side right 
    pack $site_4_0.fra113 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    pack $site_3_0.cpd91 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra110 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel523" 1
    set site_3_0 $top.fra92
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMspan PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd
global PTOMprocessNwinL PTOMprocessNwinC PSPBackgroundColor
global OpenDirFile 

if {$OpenDirFile == 0} {
$widget(Button523_4) configure -state disable

set config "false"
if {$PTOMhh == "1"} {set config "true"}
if {$PTOMhv == "1"} {set config "true"}
if {$PTOMvv == "1"} {set config "true"}
if {$PTOMhhpvv == "1"} {set config "true"}
if {$PTOMhhmvv == "1"} {set config "true"}
if {$PTOMll == "1"} {set config "true"}
if {$PTOMlr == "1"} {set config "true"}
if {$PTOMrr == "1"} {set config "true"}
if {$config == "true"} { PTOMprocesschannel }

set config "false"
if {$PTOMspan == "1"} {set config "true"}
if {$config == "true"} { PTOMprocessspan }

set config "false"
if {$PTOMcorrT3 == "1"} {set config "true"}
if {$PTOMcorrC3 == "1"} {set config "true"}
if {$PTOMcorrCCC == "1"} {set config "true"}
if {$PTOMcorrCCCN == "1"} {set config "true"}
if {$config == "true"} { PTOMprocessmatrix }

set config "false"
if {$PTOMnned == "1"} {set config "true"}
if {$PTOMvz == "1"} {set config "true"}
if {$PTOMfree == "1"} {set config "true"}
if {$PTOMsingh == "1"} {set config "true"}
if {$PTOMyam == "1"} {set config "true"}
if {$config == "true"} { PTOMprocessdecomp }

set config "false"
if {$PTOMhaalp == "1"} {set config "true"}
if {$PTOMshannon == "1"} {set config "true"}
if {$PTOMerd == "1"} {set config "true"}
if {$PTOMprob == "1"} {set config "true"}
if {$PTOMasym == "1"} {set config "true"}
if {$config == "true"} { PTOMprocesshaalp }

$widget(Button523_4) configure -state normal
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button523_3" vTcl:WidgetProc "Toplevel523" 1
    button $site_3_0.cpd69 \
        -background #ffff00 \
        -command {global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMspan PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd

set PTOMhh "1"; set PTOMhv "1"; set PTOMvv "1"; set PTOMhhpvv "1"; set PTOMhhmvv "1"; set PTOMrr "1"; set PTOMlr "1"; set PTOMll "1"
set PTOMspan "1"; set PTOMcorrT3 "1"; set PTOMcorrC3 "1"; set PTOMcorrCCC "1"; set PTOMcorrCCCN "1"
set PTOMnned "1"; set PTOMvz "1"; set PTOMfree "1"; set PTOMsingh "1"; set PTOMyam "1"
set PTOMhaalp "1"; set PTOMshannon "1"; set PTOMprob "1"; set PTOMasym "1"; set PTOMerd "1"} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd69" "Button523_5" vTcl:WidgetProc "Toplevel523" 1
    button $site_3_0.but66 \
        -background #ffff00 -command PTOMreset -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but66" "Button523_6" vTcl:WidgetProc "Toplevel523" 1
    button $site_3_0.cpd68 \
        -background #ffff00 \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram ColorMap ColorMapFile CONFIGDir
global PTOMDisplayFileInput PTOMDisplayFileMask
global MinMaxAutoPTOMDisplay MinMaxContrastPTOMDisplay MinMaxNormalisationPTOMDisplay
global InputFormat OutputFormat MinPTOMDisplay MaxPTOMDisplay MinCPTOMDisplay MaxCPTOMDisplay
global PTOMNligInit PTOMNligEnd PTOMNcolInit PTOMNcolEnd PTOMNcolFullSize PTOMNligFullSize
global PTOMzdim PTOMxdim PTOMzmin PTOMzmax PTOMxmin PTOMxmax 
global PTOMDisplayDirOutput PTOMDisplayDirInput PTOMDisplayZGroundFile PTOMDisplayZTopFile
global PTOMDisplayLabelX PTOMDisplayLabelY PTOMDisplayTitle
global PTOMProcessDirInput PTOMProcessDirOutput
global PTOMGifCol PTOMGifLig

#PTOMDisplay PROCESS
global Load_CreatePolTomoDisplay PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_CreatePolTomoDisplay == 0} {
        source "GUI/bmp_process/CreatePolTomoDisplay.tcl"
        set Load_CreatePolTomoDisplay 1
        WmTransient $widget(Toplevel524) $PSPTopLevel
        }

    set InputFormat "float"; set OutputFormat "real"
    set MinMaxAutoPTOMDisplay 1; set MinMaxContrastPTOMDisplay 0
    set MinMaxNormalisationPTOMDisplay 0
    set MinPTOMDisplay "Auto"; set MaxPTOMDisplay "Auto"
    set MinCPTOMDisplay ""; set MaxCPTOMDisplay ""

    set PTOMNligInit ""; set PTOMNligEnd ""
    set PTOMNcolInit ""; set PTOMNcolEnd ""
    set PTOMNcolFullSize ""; set PTOMNligFullSize ""
    set PTOMzdim ""; set PTOMxdim ""
    set PTOMzmin ""; set PTOMzmax ""
    set PTOMxmin ""; set PTOMxmax ""

    set PTOMDisplayFileInput ""; set PTOMDisplayFileOutput ""
    set PTOMDisplayZGroundFile ""; set PTOMDisplayZTopFile ""

    set PTOMDisplayLabelX "X axis label"
    set PTOMDisplayLabelY "Y axis label"
    set PTOMDisplayTitle "Title of the Tomogram"
    
    set PTOMGifCol 1280
    set PTOMGifLig 480

    $widget(Label524_1) configure -state disable
    $widget(Entry524_1) configure -state disable
    $widget(Label524_2) configure -state disable
    $widget(Entry524_2) configure -state disable
    $widget(Label524_3) configure -state disable
    $widget(Entry524_3) configure -state disable
    $widget(Entry524_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label524_4) configure -state disable
    $widget(Entry524_4) configure -state disable
    $widget(Entry524_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button524_1) configure -state disable
    $widget(Button524_3) configure -state disable
    $widget(Button524_4) configure -state disable
    $widget(Checkbutton524_1) configure -state normal
    $widget(Checkbutton524_2) configure -state normal

    set ConfigFile ""
    set PTOMDisplayDirInput $PTOMProcessDirInput
    set PTOMDisplayDirOutput $PTOMProcessDirOutput
    set PTOMDisplayFileOutput ""

    set ConfigFile "$PTOMDisplayDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel523) $widget(Toplevel524); TextEditorRunTrace "Open Window Create Tomogram Display File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }


# Config Format
}
}} \
        -padx 4 -pady 2 -text Display 
    vTcl:DefineAlias "$site_3_0.cpd68" "Button523_4" vTcl:WidgetProc "Toplevel523" 1
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/data_process_dual/DisplayPolarizationCoherenceTomography.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel523" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile Load_CreatePolTomoDisplay Load_PolarTomographyGenerator

if {$OpenDirFile == 0} {
Window hide .top401tomo
ClosePSPViewer
if {$Load_CreatePolTomoDisplay == 1} {
    Window hide $widget(Toplevel524); TextEditorRunTrace "Close Window Create Tomogram Display File" "b"
    }
if {$Load_PolarTomographyGenerator == 1} {
    Window hide $widget(Toplevel523a); TextEditorRunTrace "Close Window Polarimetric Tomography Generator" "b"
    }
Window hide $widget(Toplevel523); TextEditorRunTrace "Close Window Polarimetric Tomography" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button523_0" vTcl:WidgetProc "Toplevel523" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra70 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra90 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra92 \
        -in $top -anchor center -expand 1 -fill x -side bottom 

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
Window show .top523

main $argc $argv
