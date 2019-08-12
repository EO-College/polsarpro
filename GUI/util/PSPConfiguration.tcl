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

        {{[file join . GUI Images PSPv5pdgfullsmall.gif]} {user image} user {}}
        {{[file join . GUI Images PSPMemory.gif]} {user image} user {}}
        {{[file join . GUI Images PSPTransparent.gif]} {user image} user {}}
        {{[file join . GUI Images PSPWidget399.gif]} {user image} user {}}
        {{[file join . GUI Images PSPWidgetCorner.gif]} {user image} user {}}
        {{[file join . GUI Images PSPWidgetCenter.gif]} {user image} user {}}
        {{[file join . GUI Images PSPThumbnails.gif]} {user image} user {}}
        {{[file join . GUI Images PSPViewBMP.gif]} {user image} user {}}
        {{[file join . GUI Images PSPViewRGB.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images PSPScreenBanner.gif]} {user image} user {}}
        {{[file join . GUI Images PSPScreenFull.gif]} {user image} user {}}
        {{[file join . GUI Images PSPRunTrace.gif]} {user image} user {}}
        {{[file join . GUI Images PSPMireTV.gif]} {user image} user {}}
        {{[file join . GUI Images PSPCheckNewRelease.gif]} {user image} user {}}

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
    set base .top11
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab67 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd77
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd96
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd89
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd99 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd99
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd101
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra78
    namespace eval ::widgets::$site_4_0.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra79
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent83 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.rad93 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd98
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.rad93 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd90
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.rad93 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd100
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra108 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.fra108
    namespace eval ::widgets::$site_6_0.cpd109 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.but110 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd111 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd102
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd66
    namespace eval ::widgets::$site_7_0.cpd94 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd67
    namespace eval ::widgets::$site_7_0.rad93 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd68
    namespace eval ::widgets::$site_7_0.rad93 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd103 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd103
    namespace eval ::widgets::$site_6_0.cpd104 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd104
    namespace eval ::widgets::$site_7_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd105 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd105
    namespace eval ::widgets::$site_7_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.rad93 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd95
    namespace eval ::widgets::$site_6_0.rad93 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra106 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra106
    namespace eval ::widgets::$site_3_0.but107 {
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
    wm geometry $top 200x200+225+225; update
    wm maxsize $top 5124 1422
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

proc vTclWindow.top11 {base} {
    if {$base == ""} {
        set base .top11
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
    wm geometry $top 510x715+10+110; update
    wm maxsize $top 3360 1028
    wm minsize $top 162 8
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PolSARpro : Configuration Panel"
    vTcl:DefineAlias "$top" "Toplevel11" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab67 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPv5pdgfullsmall.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab67" "Label1" vTcl:WidgetProc "Toplevel11" 1
    frame $top.fra76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame4" vTcl:WidgetProc "Toplevel11" 1
    set site_3_0 $top.fra76
    frame $site_3_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd77" "Frame2" vTcl:WidgetProc "Toplevel11" 1
    set site_4_0 $site_3_0.cpd77
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame3" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd74
    label $site_5_0.cpd71 \
        -image [vTcl:image:get_image [file join . GUI Images PSPMemory.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label5" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame25" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd66
    label $site_5_0.cpd71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPScreenFull.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label21" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.cpd97 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPScreenBanner.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$site_5_0.cpd97" "Label22" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd96 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd96" "Frame10" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd96
    label $site_5_0.cpd71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPWidgetCenter.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label7" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.cpd97 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPWidgetCorner.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$site_5_0.cpd97" "Label12" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd89 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd89" "Frame11" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd89
    label $site_5_0.cpd72 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPWidget399.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd72" "Label9" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd99 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd99" "Frame15" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd99
    label $site_5_0.cpd71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPThumbnails.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label15" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd101 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd101" "Frame17" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd101
    label $site_5_0.cpd71 \
        -image [vTcl:image:get_image [file join . GUI Images PSPViewRGB.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label18" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.cpd97 \
        -image [vTcl:image:get_image [file join . GUI Images PSPViewBMP.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$site_5_0.cpd97" "Label19" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame28" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd67
    label $site_5_0.cpd71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPRunTrace.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label27" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -ipady 5 \
        -side right 
    frame $site_4_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame37" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.cpd72 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images PSPCheckNewRelease.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd72" "Label33" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd68 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd68" "Frame31" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd68
    label $site_5_0.cpd71 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images PSPMireTV.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label30" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd99 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd101 \
        -in $site_4_0 -anchor center -expand 0 -fill x -pady 10 -side top 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -pady 10 -side top 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 0 -fill x -pady 10 -side top 
    frame $site_3_0.fra78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra78" "Frame5" vTcl:WidgetProc "Toplevel11" 1
    set site_4_0 $site_3_0.fra78
    frame $site_4_0.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra79" "Frame6" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.fra79
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label3" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.lab81 \
        -text {ALLOCATED MEMORY (RAM) SIZE (in Mb)} 
    vTcl:DefineAlias "$site_5_0.lab81" "Label2" vTcl:WidgetProc "Toplevel11" 1
    entry $site_5_0.ent83 \
        -background white -disabledforeground #0000ff -foreground #0000ff \
        -justify center -textvariable PSPMemory -width 10 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry1" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.lab81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd68" "Frame26" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd68
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label23" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.lab81 \
        -text {MAIN SCREEN} 
    vTcl:DefineAlias "$site_5_0.lab81" "Label26" vTcl:WidgetProc "Toplevel11" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame27" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.cpd95
    radiobutton $site_6_0.rad93 \
        -text {Top Banner} -value 0 -variable PSPFullScreen 
    vTcl:DefineAlias "$site_6_0.rad93" "Radiobutton9" vTcl:WidgetProc "Toplevel11" 1
    radiobutton $site_6_0.cpd94 \
        -text {Full Screen} -value 1 -variable PSPFullScreen 
    vTcl:DefineAlias "$site_6_0.cpd94" "Radiobutton10" vTcl:WidgetProc "Toplevel11" 1
    pack $site_6_0.rad93 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.lab81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd98" "Frame13" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd98
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label13" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.lab81 \
        -text {WIDGET POSITION} 
    vTcl:DefineAlias "$site_5_0.lab81" "Label14" vTcl:WidgetProc "Toplevel11" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame14" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.cpd95
    radiobutton $site_6_0.rad93 \
        -text Corner -value 0 -variable WidgetPosition 
    vTcl:DefineAlias "$site_6_0.rad93" "Radiobutton5" vTcl:WidgetProc "Toplevel11" 1
    radiobutton $site_6_0.cpd94 \
        -text Center -value 1 -variable WidgetPosition 
    vTcl:DefineAlias "$site_6_0.cpd94" "Radiobutton6" vTcl:WidgetProc "Toplevel11" 1
    pack $site_6_0.rad93 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.lab81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd90" "Frame12" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd90
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label10" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.lab81 \
        -text {DISPLAY "PROCESSING" WIDGET} 
    vTcl:DefineAlias "$site_5_0.lab81" "Label11" vTcl:WidgetProc "Toplevel11" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame9" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.cpd95
    radiobutton $site_6_0.rad93 \
        -text yes -value 1 -variable PSPShow399 
    vTcl:DefineAlias "$site_6_0.rad93" "Radiobutton3" vTcl:WidgetProc "Toplevel11" 1
    radiobutton $site_6_0.cpd94 \
        -text no -value 0 -variable PSPShow399 
    vTcl:DefineAlias "$site_6_0.cpd94" "Radiobutton4" vTcl:WidgetProc "Toplevel11" 1
    pack $site_6_0.rad93 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.lab81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd100 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd100" "Frame16" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd100
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label16" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.lab81 \
        -text {THUMBNAILS RESIZE FACTOR} 
    vTcl:DefineAlias "$site_5_0.lab81" "Label17" vTcl:WidgetProc "Toplevel11" 1
    frame $site_5_0.fra108 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra108" "Frame24" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.fra108
    entry $site_6_0.cpd109 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPThumb -width 6 
    vTcl:DefineAlias "$site_6_0.cpd109" "Entry2" vTcl:WidgetProc "Toplevel11" 1
    button $site_6_0.but110 \
        \
        -command {global PSPThumb

set PSPThumb [expr $PSPThumb + 10]
if {$PSPThumb == 110} { set PSPThumb 10 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_6_0.but110" "Button2" vTcl:WidgetProc "Toplevel11" 1
    button $site_6_0.cpd111 \
        \
        -command {global PSPThumb

set PSPThumb [expr $PSPThumb - 10]
if {$PSPThumb == 0} { set PSPThumb 100 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd111" "Button3" vTcl:WidgetProc "Toplevel11" 1
    pack $site_6_0.cpd109 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.but110 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_6_0.cpd111 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.lab81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra108 \
        -in $site_5_0 -anchor center -expand 0 -fill none -ipadx 2 -ipady 2 \
        -side right 
    frame $site_4_0.cpd102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd102" "Frame18" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd102
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label20" vTcl:WidgetProc "Toplevel11" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame19" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.cpd95
    frame $site_6_0.cpd66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd66" "Frame32" vTcl:WidgetProc "Toplevel11" 1
    set site_7_0 $site_6_0.cpd66
    radiobutton $site_7_0.cpd94 \
        -text no -value 0 -variable PSPViewGimpBMP 
    vTcl:DefineAlias "$site_7_0.cpd94" "Radiobutton14" vTcl:WidgetProc "Toplevel11" 1
    pack $site_7_0.cpd94 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd67 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd67" "Frame33" vTcl:WidgetProc "Toplevel11" 1
    set site_7_0 $site_6_0.cpd67
    radiobutton $site_7_0.rad93 \
        -text Gimp -value 1 -variable PSPViewGimpBMP 
    vTcl:DefineAlias "$site_7_0.rad93" "Radiobutton15" vTcl:WidgetProc "Toplevel11" 1
    pack $site_7_0.rad93 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd68 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd68" "Frame34" vTcl:WidgetProc "Toplevel11" 1
    set site_7_0 $site_6_0.cpd68
    radiobutton $site_7_0.rad93 \
        -text MapAlgebra -value 2 -variable PSPViewGimpBMP 
    vTcl:DefineAlias "$site_7_0.rad93" "Radiobutton17" vTcl:WidgetProc "Toplevel11" 1
    pack $site_7_0.rad93 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd67 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd68 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd103 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd103" "Frame20" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.cpd103
    frame $site_6_0.cpd104 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd104" "Frame22" vTcl:WidgetProc "Toplevel11" 1
    set site_7_0 $site_6_0.cpd104
    label $site_7_0.lab81 \
        -text {AUTOMATIC DISPLAY OF GENERATED} 
    vTcl:DefineAlias "$site_7_0.lab81" "Label24" vTcl:WidgetProc "Toplevel11" 1
    pack $site_7_0.lab81 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd105 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd105" "Frame23" vTcl:WidgetProc "Toplevel11" 1
    set site_7_0 $site_6_0.cpd105
    label $site_7_0.lab81 \
        -text {BMP and RGB FILES WITH : ....} 
    vTcl:DefineAlias "$site_7_0.lab81" "Label25" vTcl:WidgetProc "Toplevel11" 1
    pack $site_7_0.lab81 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd104 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd105 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd103 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame29" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label28" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.lab81 \
        -text {DISPLAY "RUN TRACE" WIDGET} 
    vTcl:DefineAlias "$site_5_0.lab81" "Label29" vTcl:WidgetProc "Toplevel11" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame30" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.cpd95
    radiobutton $site_6_0.rad93 \
        -text yes -value 1 -variable PSPRunTrace 
    vTcl:DefineAlias "$site_6_0.rad93" "Radiobutton11" vTcl:WidgetProc "Toplevel11" 1
    radiobutton $site_6_0.cpd94 \
        -text no -value 0 -variable PSPRunTrace 
    vTcl:DefineAlias "$site_6_0.cpd94" "Radiobutton12" vTcl:WidgetProc "Toplevel11" 1
    pack $site_6_0.rad93 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.lab81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame35" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd66
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label31" vTcl:WidgetProc "Toplevel11" 1
    frame $site_5_0.cpd95 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd95" "Frame36" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.cpd95
    radiobutton $site_6_0.rad93 \
        -text yes -value 1 -variable PSPCheckNewRelease 
    vTcl:DefineAlias "$site_6_0.rad93" "Radiobutton7" vTcl:WidgetProc "Toplevel11" 1
    radiobutton $site_6_0.cpd94 \
        -text no -value 0 -variable PSPCheckNewRelease 
    vTcl:DefineAlias "$site_6_0.cpd94" "Radiobutton8" vTcl:WidgetProc "Toplevel11" 1
    pack $site_6_0.rad93 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame38" vTcl:WidgetProc "Toplevel11" 1
    set site_6_0 $site_5_0.cpd70
    label $site_6_0.lab81 \
        -text {AUTOMATIC CHECK FOR NEW  } 
    vTcl:DefineAlias "$site_6_0.lab81" "Label35" vTcl:WidgetProc "Toplevel11" 1
    label $site_6_0.cpd71 \
        -text {RELEASES AND / OR UPDATES} 
    vTcl:DefineAlias "$site_6_0.cpd71" "Label36" vTcl:WidgetProc "Toplevel11" 1
    pack $site_6_0.lab81 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame7" vTcl:WidgetProc "Toplevel11" 1
    set site_5_0 $site_4_0.cpd70
    label $site_5_0.cpd80 \
        \
        -image [vTcl:image:get_image [file join . GUI Images PSPTransparent.gif]] \
        -text label 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label4" vTcl:WidgetProc "Toplevel11" 1
    label $site_5_0.lab81 \
        -text {WIDGET SIZE / SCREEN ADJUST} 
    vTcl:DefineAlias "$site_5_0.lab81" "Label6" vTcl:WidgetProc "Toplevel11" 1
    button $site_5_0.but71 \
        -background #ffff00 \
        -command {global OpenDirFile VarWidgetSizeRatio
global WidgetSizeWidthInitial WidgetSizeHeightInitial
global WidgetSizeWidthCurrent WidgetSizeHeightCurrent
global WidgetSizeWidthRatio WidgetSizeHeightRatio

global CONFIGDir PSPMemory PSPFullScreen WidgetPosition
global PSPThumb PSPShow399 PSPShow28 PSPViewGimpBMP PSPRunTrace

global Load_PSPWidgetSizeAdjustCmd Load_PSPWidgetSizeAdjust PSPTopLevel

if {$OpenDirFile == 0} {
    if {$Load_PSPWidgetSizeAdjustCmd == 0} {
        source "GUI/util/PSPWidgetSizeAdjustCmd.tcl"
        set Load_PSPWidgetSizeAdjustCmd 1
        WmTransient .top8 $PSPTopLevel
        WidgetGeometryRight .top8
        }
    if {$Load_PSPWidgetSizeAdjust == 0} {
        source "GUI/util/PSPWidgetSizeAdjust.tcl"
        set Load_PSPWidgetSizeAdjust 1
        WmTransient .top9 $PSPTopLevel
        WidgetGeometryLeft .top9
        }
    set VarWidgetSizeRatio ""
    set WidgetSizeWidthInitial 520; set WidgetSizeHeightInitial 740
    set WidgetSizeWidthCurrent [winfo width .top9]
    set WidgetSizeHeightCurrent [winfo height .top9]
    set WidgetSizeWidthRatio [expr ($WidgetSizeWidthCurrent * 1.0) / ($WidgetSizeWidthInitial * 1.0)]
    set WidgetSizeHeightRatio [expr ($WidgetSizeHeightCurrent * 1.0) / ($WidgetSizeHeightInitial * 1.0)]
    Window show .top8; TextEditorRunTrace "Open PSP Widget Size Adjust Cmd" "b"
    Window show .top9; TextEditorRunTrace "Open PSP Widget Size Adjust" "b"
    tkwait variable VarWidgetSizeRatio
    set f [open "$CONFIGDir/PolSARproConfiguration.txt" w]
    puts $f $PSPMemory
    puts $f $PSPFullScreen
    puts $f $WidgetPosition
    puts $f $PSPThumb
    puts $f $PSPShow399
    puts $f $PSPShow28
    puts $f $PSPViewGimpBMP
    puts $f $PSPRunTrace
    puts $f $WidgetSizeWidthRatio
    puts $f $WidgetSizeHeightRatio
    close $f
    }} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_5_0.but71" "Button4" vTcl:WidgetProc "Toplevel11" 1
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.lab81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra79 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd102 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 0 -fill x -ipady 5 -side top 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 0 -fill both -side left 
    pack $site_3_0.fra78 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra106 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra106" "Frame21" vTcl:WidgetProc "Toplevel11" 1
    set site_3_0 $top.fra106
    button $site_3_0.but107 \
        -background #ffff00 \
        -command {global PSPMemory PSPFullScreen WidgetPosition PSPThumb PSPShow399 PSPShow28 PSPViewGimpBMP PSPRunTrace PSPCheckNewRelease
global PSPMemoryOld PSPFullScreenOld WidgetPositionOld PSPThumbOld PSPShow399Old PSPShow28Old
global PSPViewGimpBMPOld PSPRunTraceOld PSPCheckNewReleaseOld
global OpenDirFile CONFIGDir PSPThumbnails WidgetSizeWidthRatio WidgetSizeHeightRatio

if {$OpenDirFile == 0} {

set change "ko"
if { $PSPFullScreenOld != $PSPFullScreen } {
    PSPFullScreenInit
    set change "ok"
    }
if { $WidgetPositionOld != $WidgetPosition } { set change "ok" }
if { $PSPThumbOld != $PSPThumb } {
    set change "ok"
    set PSPThumbnails [expr ($PSPThumb / 100)]
    }
if { $PSPShow399Old != $PSPShow399 } { set change "ok" }
if { $PSPShow28Old != $PSPShow28 } { set change "ok" }
if { $PSPViewGimpBMPOld != $PSPViewGimpBMP } { set change "ok" }
if { $PSPCheckNewReleaseOld != $PSPCheckNewRelease } { set change "ok" }
if { $PSPRunTraceOld != $PSPRunTrace } {
    set change "ok"
    if { $PSPRunTrace == 0 } { Window hide $widget(Toplevel12) }
    if { $PSPRunTrace == 1 } { Window show $widget(Toplevel12) }   
    PSPFullScreenInit
    }

if {$change == "ok"} {
    set f [open "$CONFIGDir/PolSARproConfiguration.txt" w]
    puts $f $PSPMemory
    puts $f $PSPFullScreen
    puts $f $WidgetPosition
    puts $f $PSPThumb
    puts $f $PSPShow399
    puts $f $PSPShow28
    puts $f $PSPViewGimpBMP
    puts $f $PSPRunTrace
    puts $f $PSPCheckNewRelease
    puts $f $WidgetSizeWidthRatio
    puts $f $WidgetSizeHeightRatio
    close $f
    }
    
Window hide $widget(Toplevel11); TextEditorRunTrace "Close Window PolSARpro Configuration" "b"
}} \
        -padx 4 -pady 2 -text {Save & Exit} 
    vTcl:DefineAlias "$site_3_0.but107" "Button1" vTcl:WidgetProc "Toplevel11" 1
    pack $site_3_0.but107 \
        -in $site_3_0 -anchor center -expand 0 -fill none -ipady 2 -padx 20 \
        -side right 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab67 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra106 \
        -in $top -anchor center -expand 0 -fill x -side bottom 

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
Window show .top11

main $argc $argv
