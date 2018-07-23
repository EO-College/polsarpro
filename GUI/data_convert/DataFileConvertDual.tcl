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

        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {file not found!} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}

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
    set base .top302
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd77 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra27 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra27
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra96 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra96
    namespace eval ::widgets::$site_3_0.fra97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra97
    namespace eval ::widgets::$site_4_0.fra102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra102
    namespace eval ::widgets::$site_5_0.cpd105 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra103 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra103
    namespace eval ::widgets::$site_5_0.cpd106 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra104 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra104
    namespace eval ::widgets::$site_5_0.cpd107 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd98
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd111
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1}
    }
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1}
    }
    namespace eval ::widgets::$site_4_0.cpd109 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd109
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent26 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd110 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd110
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent26 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd77
    namespace eval ::widgets::$site_3_0.lab80 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent81 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit80 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit80 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd76
    namespace eval ::widgets::$site_3_0.cpd80 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd79 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd79 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.lab75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top302
            DualConvertDATA_S2
            DualConvertDATA_T6
            DualConvertDATA_S2T6
            DualConvertRGB_S2
            DualConvertRGB_T6
            DualConvertDATA_SPP
            DualConvertDATA_SPPT4
            DualConvertDATA_T4
            DualConvertRGB_T4
            DualConvertRGB_SPP
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
## Procedure:  DualConvertDATA_S2

proc ::DualConvertDATA_S2 {} {
global DataDirChannel1 DataDirChannel2 OpenDirFile DataFormatActive 
global ConvertMasterDirInput ConvertMasterOutputDir ConvertSlaveDirInput ConvertSlaveOutputDir
global ConvertFonction ConvertExtractFonction ConvertOutputFormat ConvertSymmetrisation
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global MultiLookRow MultiLookCol SubSampRow SubSampCol
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine ConfigFile PolarCase PolarType PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config1 "ok"; set config2 "ok"            
if {$ConvertMasterOutputDir == $ConvertMasterDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set config1 "no"
    }
if {$ConvertSlaveOutputDir == $ConvertSlaveDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set config2 "no"
    }
set config $config1
append config $config2

if {$config == "okok"} {          
    #####################################################################
    #Create Directory
    set config1 "ok"
    set DirNameCreate $ConvertMasterOutputDir
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixS $ConvertMasterOutputDir
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show .top32; TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            set config1 "ok"
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set config1 "no"
            }
        }
    #####################################################################       
    #####################################################################
    #Create Directory
    set config2 "ok"
    set DirNameCreate $ConvertSlaveOutputDir
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixS $ConvertSlaveOutputDir
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show .top32; TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            set config2 "ok"
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set config2 "no"
            }
        }
    #####################################################################       
    set config $config1
    append config $config2

    if {$config == "okok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$ConvertExtractFonction == "Full"} {TestVar 4}
        if {$ConvertExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Row"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Col"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction ""
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set ConvertSymmetrisation "1"   

            set ExtractFunction "Soft/data_convert/data_convert.exe"
            TextEditorRunTrace "Process The Function $ExtractFunction" "k"
            set ExtractCommand "-id \x22$ConvertMasterDirInput\x22 -od \x22$ConvertMasterDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
            append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
            if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
            if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
            if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

            TextEditorRunTrace "Arguments: $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
            set f [ open "| $ExtractFunction $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            
            set ExtractFunction "Soft/data_convert/data_convert.exe"
            TextEditorRunTrace "Process The Function $ExtractFunction" "k"
            set ExtractCommand "-id \x22$ConvertSlaveDirInput\x22 -od \x22$ConvertSlaveDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
            append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
            if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
            if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
            if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

            TextEditorRunTrace "Arguments: $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
            set f [ open "| $ExtractFunction $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            MapInfoWriteConfig $ConvertMasterOutputDir

            set ConfigFile "$ConvertMasterOutputDir/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                EnviWriteConfigS $ConvertMasterOutputDir $NligFullSize $NcolFullSize
                DualConvertRGB_S2 $ConvertMasterOutputDir
                set DataDirChannel1 $ConvertMasterOutputDir
                set DataFormatActive "S2"
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }
    
            MapInfoWriteConfig $ConvertSlaveOutputDir

            set ConfigFile "$ConvertSlaveOutputDir/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                EnviWriteConfigS $ConvertSlaveOutputDir $NligFullSize $NcolFullSize
                DualConvertRGB_S2 $ConvertSlaveOutputDir
                set DataDirChannel2 $ConvertSlaveOutputDir
                set DataFormatActive "S2"
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }

            Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"
            }
        } else {
        if {$config =="nono"} {Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"}
        }
    }
}
}
#############################################################################
## Procedure:  DualConvertDATA_T6

proc ::DualConvertDATA_T6 {} {
global DataDirChannel1 DataDirChannel2 OpenDirFile DataFormatActive 
global ConvertMasterDirInput ConvertDirOutput ConvertMasterSlaveOutputDir ConvertOutputSubDir
global ConvertFonction ConvertExtractFonction ConvertOutputFormat ConvertSymmetrisation
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global MultiLookRow MultiLookCol SubSampRow SubSampCol
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine ConfigFile PolarCase PolarType PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set ConvertDirOutput $ConvertMasterSlaveOutputDir
if {$ConvertOutputSubDir != ""} {append ConvertDirOutput "/$ConvertOutputSubDir"}
            
if {$ConvertDirOutput == $ConvertMasterDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
} else {
          
    #####################################################################
    #Create Directory
    set DirNameCreate $ConvertDirOutput
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixT $ConvertDirOutput
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show .top32; TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set ConvertDirOutput $ConvertMasterSlaveOutputDir
            }
        }
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$ConvertExtractFonction == "Full"} {TestVar 4}
        if {$ConvertExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Row"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Col"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$ConvertExtractFonction == "MultiLook"} {
            set TestVarName(4) "Multi Look Row"; set TestVarType(4) "int"; set TestVarValue(4) $MultiLookRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Multi Look Col"; set TestVarType(5) "int"; set TestVarValue(5) $MultiLookCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction ""
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set ConvertSymmetrisation "1"   
            
            set ExtractFunction "Soft/data_convert/data_convert.exe"
            TextEditorRunTrace "Process The Function $ExtractFunction" "k"
            set ExtractCommand "-id \x22$ConvertMasterDirInput\x22 -od \x22$ConvertDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
            append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
            if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
            if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
            if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

            TextEditorRunTrace "Arguments: $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
            set f [ open "| $ExtractFunction $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
            PsPprogressBar $f           
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
            MapInfoWriteConfig $ConvertDirOutput

            set ConfigFile "$ConvertDirOutput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                EnviWriteConfigT $ConvertDirOutput $NligFullSize $NcolFullSize
                DualConvertRGB_T6
                set DataDirChannel1 $ConvertMasterSlaveOutputDir
                set DataDirChannel2 $ConvertMasterSlaveOutputDir
                set DataFormatActive "T6"
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }

            Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"}
        }
    }
}
}
#############################################################################
## Procedure:  DualConvertDATA_S2T6

proc ::DualConvertDATA_S2T6 {} {
global DataDirChannel1 DataDirChannel2 OpenDirFile DataFormatActive 
global ConvertMasterDirInput ConvertSlaveDirInput
global ConvertDirOutput ConvertMasterSlaveOutputDir ConvertOutputSubDir
global ConvertFonction ConvertExtractFonction ConvertOutputFormat ConvertSymmetrisation
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global MultiLookRow MultiLookCol SubSampRow SubSampCol
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine ConfigFile PolarCase PolarType PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set ConvertDirOutput $ConvertMasterSlaveOutputDir
if {$ConvertOutputSubDir != ""} {append ConvertDirOutput "/$ConvertOutputSubDir"}

set config1 "ok"; set config2 "ok"            
if {$ConvertDirOutput == $ConvertMasterDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set config1 "no"
    }
if {$ConvertDirOutput == $ConvertSlaveDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set config2 "no"
    }
set config $config1
append config $config2

if {$config == "okok"} {          
    #####################################################################
    #Create Directory
    set DirNameCreate $ConvertDirOutput
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixT $ConvertDirOutput
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show .top32; TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set ConvertDirOutput $ConvertMasterSlaveOutputDir
            }
        }
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$ConvertExtractFonction == "Full"} {TestVar 4}
        if {$ConvertExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Row"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Col"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$ConvertExtractFonction == "MultiLook"} {
            set TestVarName(4) "Multi Look Row"; set TestVarType(4) "int"; set TestVarValue(4) $MultiLookRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Multi Look Col"; set TestVarType(5) "int"; set TestVarValue(5) $MultiLookCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction ""
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set ConvertSymmetrisation "1"   
            
            set ExtractFunction "Soft/data_convert/data_convert_dual.exe"
            TextEditorRunTrace "Process The Function $ExtractFunction" "k"
            set ExtractCommand "-idm \x22$ConvertMasterDirInput\x22 -ids \x22$ConvertSlaveDirInput\x22 -od \x22$ConvertDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
            append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
            if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
            if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
            if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

            TextEditorRunTrace "Arguments: $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
            set f [ open "| $ExtractFunction $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
            PsPprogressBar $f           
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
            MapInfoWriteConfig $ConvertDirOutput

            set ConfigFile "$ConvertDirOutput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                EnviWriteConfigT $ConvertDirOutput $NligFullSize $NcolFullSize
                DualConvertRGB_T6
                set DataDirChannel1 $ConvertMasterSlaveOutputDir
                set DataDirChannel2 $ConvertMasterSlaveOutputDir
                set DataFormatActive "T6"
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }
    
            Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"}
        }
    }
}
}
#############################################################################
## Procedure:  DualConvertRGB_S2

proc ::DualConvertRGB_S2 {Directory} {
global BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError 
   
set RGBDirInput $Directory
set RGBDirOutput $Directory
set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
set config "true"
set fichier "$RGBDirInput/s11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s12.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s12.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s21.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s21.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  DualConvertRGB_T6

proc ::DualConvertRGB_T6 {} {
global ConvertDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError 
   
set RGBDirInput $ConvertDirOutput
set RGBDirOutput $ConvertDirOutput
set RGBFileOutput "$RGBDirOutput/PauliRGB_T1.bmp"
set config "true"
set fichier "$RGBDirInput/T11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/T22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/T33.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T33.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file_T6.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -ch 1 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file_T6.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -ch 1 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
set RGBDirInput $ConvertDirOutput
set RGBDirOutput $ConvertDirOutput
set RGBFileOutput "$RGBDirOutput/PauliRGB_T2.bmp"
set config "true"
set fichier "$RGBDirInput/T44.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T44.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/T55.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T55.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/T66.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T66.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file_T6.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -ch 2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file_T6.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -ch 2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  DualConvertDATA_SPP

proc ::DualConvertDATA_SPP {} {
global DataDirChannel1 DataDirChannel2 OpenDirFile DataFormatActive 
global ConvertMasterDirInput ConvertMasterOutputDir ConvertSlaveDirInput ConvertSlaveOutputDir
global ConvertFonction ConvertExtractFonction ConvertOutputFormat ConvertSymmetrisation
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global MultiLookRow MultiLookCol SubSampRow SubSampCol
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine ConfigFile PolarCase PolarType PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config1 "ok"; set config2 "ok"            
if {$ConvertMasterOutputDir == $ConvertMasterDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set config1 "no"
    }
if {$ConvertSlaveOutputDir == $ConvertSlaveDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set config2 "no"
    }
set config $config1
append config $config2

if {$config == "okok"} {          
    #####################################################################
    #Create Directory
    set config1 "ok"
    set DirNameCreate $ConvertMasterOutputDir
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixS $ConvertMasterOutputDir
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show .top32; TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            set config1 "ok"
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set config1 "no"
            }
        }
    #####################################################################       
    #####################################################################
    #Create Directory
    set config2 "ok"
    set DirNameCreate $ConvertSlaveOutputDir
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixS $ConvertSlaveOutputDir
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show .top32; TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            set config2 "ok"
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set config2 "no"
            }
        }
    #####################################################################       
    set config $config1
    append config $config2

    if {$config == "okok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$ConvertExtractFonction == "Full"} {TestVar 4}
        if {$ConvertExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Row"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Col"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction ""
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set ConvertSymmetrisation "1"   

            set ExtractFunction "Soft/data_convert/data_convert.exe"
            TextEditorRunTrace "Process The Function $ExtractFunction" "k"
            set ExtractCommand "-id \x22$ConvertMasterDirInput\x22 -od \x22$ConvertMasterDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
            append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
            if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
            if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
            if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

            TextEditorRunTrace "Arguments: $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
            set f [ open "| $ExtractFunction $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            
            set ExtractFunction "Soft/data_convert/data_convert.exe"
            TextEditorRunTrace "Process The Function $ExtractFunction" "k"
            set ExtractCommand "-id \x22$ConvertSlaveDirInput\x22 -od \x22$ConvertSlaveDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
            append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
            if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
            if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
            if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

            TextEditorRunTrace "Arguments: $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
            set f [ open "| $ExtractFunction $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            MapInfoWriteConfig $ConvertMasterOutputDir

            set ConfigFile "$ConvertMasterOutputDir/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                EnviWriteConfigS $ConvertMasterOutputDir $NligFullSize $NcolFullSize
                DualConvertRGB_SPP $ConvertMasterOutputDir
                set DataDirChannel1 $ConvertMasterOutputDir
                set DataFormatActive "SPP"
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }
    
            MapInfoWriteConfig $ConvertSlaveOutputDir

            set ConfigFile "$ConvertSlaveOutputDir/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                EnviWriteConfigS $ConvertSlaveOutputDir $NligFullSize $NcolFullSize
                DualConvertRGB_SPP $ConvertSlaveOutputDir
                set DataDirChannel2 $ConvertSlaveOutputDir
                set DataFormatActive "SPP"
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }

            Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"
            }
        } else {
        if {$config =="nono"} {Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"}
        }
    }
}
}
#############################################################################
## Procedure:  DualConvertDATA_SPPT4

proc ::DualConvertDATA_SPPT4 {} {
global DataDirChannel1 DataDirChannel2 OpenDirFile DataFormatActive 
global ConvertMasterDirInput ConvertSlaveDirInput
global ConvertDirOutput ConvertMasterSlaveOutputDir ConvertOutputSubDir
global ConvertFonction ConvertExtractFonction ConvertOutputFormat ConvertSymmetrisation
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global MultiLookRow MultiLookCol SubSampRow SubSampCol
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine ConfigFile PolarCase PolarType PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set ConvertDirOutput $ConvertMasterSlaveOutputDir
if {$ConvertOutputSubDir != ""} {append ConvertDirOutput "/$ConvertOutputSubDir"}

set config1 "ok"; set config2 "ok"            
if {$ConvertDirOutput == $ConvertMasterDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set config1 "no"
    }
if {$ConvertDirOutput == $ConvertSlaveDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set config2 "no"
    }
set config $config1
append config $config2

if {$config == "okok"} {          
    #####################################################################
    #Create Directory
    set DirNameCreate $ConvertDirOutput
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixT $ConvertDirOutput
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show .top32; TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set ConvertDirOutput $ConvertMasterSlaveOutputDir
            }
        }
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$ConvertExtractFonction == "Full"} {TestVar 4}
        if {$ConvertExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Row"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Col"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$ConvertExtractFonction == "MultiLook"} {
            set TestVarName(4) "Multi Look Row"; set TestVarType(4) "int"; set TestVarValue(4) $MultiLookRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Multi Look Col"; set TestVarType(5) "int"; set TestVarValue(5) $MultiLookCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction ""
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set ConvertSymmetrisation "1"   
            
            set ExtractFunction "Soft/data_convert/data_convert_dual_pp.exe"
            TextEditorRunTrace "Process The Function $ExtractFunction" "k"
            set ExtractCommand "-idm \x22$ConvertMasterDirInput\x22 -ids \x22$ConvertSlaveDirInput\x22 -od \x22$ConvertDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
            append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
            if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
            if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
            if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

            TextEditorRunTrace "Arguments: $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
            set f [ open "| $ExtractFunction $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
            PsPprogressBar $f           
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
            MapInfoWriteConfig $ConvertDirOutput

            set ConfigFile "$ConvertDirOutput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                EnviWriteConfigT $ConvertDirOutput $NligFullSize $NcolFullSize
                DualConvertRGB_T4
                set DataDirChannel1 $ConvertMasterSlaveOutputDir
                set DataDirChannel2 $ConvertMasterSlaveOutputDir
                set DataFormatActive "T4"
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }
    
            Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"}
        }
    }
}
}
#############################################################################
## Procedure:  DualConvertDATA_T4

proc ::DualConvertDATA_T4 {} {
global DataDirChannel1 DataDirChannel2 OpenDirFile DataFormatActive 
global ConvertMasterDirInput ConvertDirOutput ConvertMasterSlaveOutputDir ConvertOutputSubDir
global ConvertFonction ConvertExtractFonction ConvertOutputFormat ConvertSymmetrisation
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global MultiLookRow MultiLookCol SubSampRow SubSampCol
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine ConfigFile PolarCase PolarType PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set ConvertDirOutput $ConvertMasterSlaveOutputDir
if {$ConvertOutputSubDir != ""} {append ConvertDirOutput "/$ConvertOutputSubDir"}
            
if {$ConvertDirOutput == $ConvertMasterDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
} else {
          
    #####################################################################
    #Create Directory
    set DirNameCreate $ConvertDirOutput
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        DeleteMatrixT $ConvertDirOutput
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show .top32; TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                set VarWarning ""
                }
            } else {
            set ConvertDirOutput $ConvertMasterSlaveOutputDir
            }
        }
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$ConvertExtractFonction == "Full"} {TestVar 4}
        if {$ConvertExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Row"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Col"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$ConvertExtractFonction == "MultiLook"} {
            set TestVarName(4) "Multi Look Row"; set TestVarType(4) "int"; set TestVarValue(4) $MultiLookRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Multi Look Col"; set TestVarType(5) "int"; set TestVarValue(5) $MultiLookCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction ""
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set ConvertSymmetrisation "1"   
            
            set ExtractFunction "Soft/data_convert/data_convert.exe"
            TextEditorRunTrace "Process The Function $ExtractFunction" "k"
            set ExtractCommand "-id \x22$ConvertMasterDirInput\x22 -od \x22$ConvertDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
            append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
            if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
            if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
            if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

            TextEditorRunTrace "Arguments: $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" "k"
            set f [ open "| $ExtractFunction $ExtractCommand -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22" r]
            PsPprogressBar $f           
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
            MapInfoWriteConfig $ConvertDirOutput

            set ConfigFile "$ConvertDirOutput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                EnviWriteConfigT $ConvertDirOutput $NligFullSize $NcolFullSize
                DualConvertRGB_T4
                set DataDirChannel1 $ConvertMasterSlaveOutputDir
                set DataDirChannel2 $ConvertMasterSlaveOutputDir
                set DataFormatActive "T4"
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }

            Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide .top302; TextEditorRunTrace "Close Window Data File Convert" "b"}
        }
    }
}
}
#############################################################################
## Procedure:  DualConvertRGB_T4

proc ::DualConvertRGB_T4 {} {
global ConvertDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError 
   
set RGBDirInput $ConvertDirOutput
set RGBDirOutput $ConvertDirOutput
set RGBFileOutput "$RGBDirOutput/RGB1_T1.bmp"
set config "true"
set fichier "$RGBDirInput/T11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/T22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/T12_real.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T12_real.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file_T4.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -ch 1 -rgbf RGB1 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file_T4.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -ch 1 -rgbf RGB1 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
set RGBDirInput $ConvertDirOutput
set RGBDirOutput $ConvertDirOutput
set RGBFileOutput "$RGBDirOutput/RGB1_T2.bmp"
set config "true"
set fichier "$RGBDirInput/T33.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T33.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/T44.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T44.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/T34_real.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE T34_real.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file_T4.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -ch 2 -rgbf RGB1 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file_T4.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -ch 2 -rgbf RGB1 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  DualConvertRGB_SPP

proc ::DualConvertRGB_SPP {Directory} {
global BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError 
   
set RGBDirInput $Directory
set RGBDirOutput $Directory
set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
set Channel1 ""
set Channel2 ""
if {$PolarType == "pp1"} {set Channel1 "s11"; set Channel2 "s21"}
if {$PolarType == "pp2"} {set Channel1 "s22"; set Channel2 "s12"}
if {$PolarType == "pp3"} {set Channel1 "s11"; set Channel2 "s22"}
set config "true"
set fichier "$RGBDirInput/"
append fichier "$Channel1.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE $fichier HAS NOT BEEN CREATED"
    WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/"
append fichier "$Channel2.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE $fichier HAS NOT BEEN CREATED"
    WidgetShow .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }

if {"$config"=="true"} {
    set MaskCmd ""
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
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

proc vTclWindow.top302 {base} {
    if {$base == ""} {
        set base .top302
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
    wm geometry $top 500x480+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data File Conversion"
    vTcl:DefineAlias "$top" "Toplevel302" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel302" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame302_1" vTcl:WidgetProc "Toplevel302" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ConvertMasterDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry302_01" vTcl:WidgetProc "Toplevel302" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel302" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd77 \
        -ipad 0 -text {Input Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd77" "TitleFrame302_2" vTcl:WidgetProc "Toplevel302" 1
    bind $site_3_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd77 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ConvertSlaveDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry302_02" vTcl:WidgetProc "Toplevel302" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame12" vTcl:WidgetProc "Toplevel302" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button36" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra27 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra27" "Frame9" vTcl:WidgetProc "Toplevel302" 1
    set site_3_0 $top.fra27
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel302" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel302" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel302" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel302" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel302" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel302" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel302" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel302" 1
    pack $site_3_0.lab57 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent58 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab59 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent60 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab61 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent62 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab63 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_3_0.ent64 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra96 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra96" "Frame3" vTcl:WidgetProc "Toplevel302" 1
    set site_3_0 $top.fra96
    frame $site_3_0.fra97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra97" "Frame4" vTcl:WidgetProc "Toplevel302" 1
    set site_4_0 $site_3_0.fra97
    frame $site_4_0.fra102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra102" "Frame6" vTcl:WidgetProc "Toplevel302" 1
    set site_5_0 $site_4_0.fra102
    radiobutton $site_5_0.cpd105 \
        \
        -command {global MultiLookRow MultiLookCol SubSampRow SubSampCol
global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir
global DataFormatActive ConvertOutputFormat

set MultiLookRow ""
set MultiLookCol ""
set SubSampRow ""
set SubSampCol ""
$widget(Label302_1) configure -state disable
$widget(Label302_2) configure -state disable
$widget(Label302_3) configure -state disable
$widget(Label302_4) configure -state disable
$widget(Entry302_1) configure -state disable
$widget(Entry302_2) configure -state disable
$widget(Entry302_3) configure -state disable
$widget(Entry302_4) configure -state disable

set ConvertOutputFormat ""
set ConvertMasterOutputDir ""
set ConvertSlaveOutputDir ""
set ConvertMasterSlaveOutputDir ""
set ConvertOutputSubDir ""
$widget(TitleFrame302_3) configure -text ""
$widget(Entry302_03) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_03) configure -state disable
$widget(Button302_1) configure -state disable
$widget(TitleFrame302_4) configure -text ""
$widget(Entry302_04) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_04) configure -state disable
$widget(Button302_2) configure -state disable
$widget(TitleFrame302_5) configure -text ""
$widget(Entry302_05) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_05) configure -state disable
$widget(Entry302_06) configure -disabledbackground $PSPBackgroundColor
$widget(Button302_3) configure -state disable
$widget(Label302_01) configure -state disable

if {$DataFormatActive == "S2"} { 
    $widget(Radiobutton302_1) configure -state normal
    }
if {$DataFormatActive == "SPP"} { 
    $widget(Radiobutton302_4) configure -state normal
    }} \
        -text {Full Resolution} -value Full -variable ConvertExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd105" "Radiobutton302_15" vTcl:WidgetProc "Toplevel302" 1
    pack $site_5_0.cpd105 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.fra103 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra103" "Frame7" vTcl:WidgetProc "Toplevel302" 1
    set site_5_0 $site_4_0.fra103
    radiobutton $site_5_0.cpd106 \
        \
        -command {global MultiLookRow MultiLookCol SubSampRow SubSampCol
global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir
global DataFormatActive ConvertOutputFormat

set MultiLookRow ""
set MultiLookCol ""
set SubSampRow " ? "
set SubSampCol " ? "
$widget(Label302_1) configure -state normal
$widget(Label302_2) configure -state normal
$widget(Label302_3) configure -state disable
$widget(Label302_4) configure -state disable
$widget(Entry302_1) configure -state normal
$widget(Entry302_2) configure -state normal
$widget(Entry302_3) configure -state disable
$widget(Entry302_4) configure -state disable

set ConvertOutputFormat ""
set ConvertMasterOutputDir ""
set ConvertSlaveOutputDir ""
set ConvertMasterSlaveOutputDir ""
set ConvertOutputSubDir ""
$widget(TitleFrame302_3) configure -text ""
$widget(Entry302_03) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_03) configure -state disable
$widget(Button302_1) configure -state disable
$widget(TitleFrame302_4) configure -text ""
$widget(Entry302_04) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_04) configure -state disable
$widget(Button302_2) configure -state disable
$widget(TitleFrame302_5) configure -text ""
$widget(Entry302_05) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_05) configure -state disable
$widget(Entry302_06) configure -disabledbackground $PSPBackgroundColor
$widget(Button302_3) configure -state disable
$widget(Label302_01) configure -state disable

if {$DataFormatActive == "SPP"} { 
    $widget(Radiobutton302_4) configure -state normal
    }

if {$DataFormatActive == "S2"} { 
    $widget(Radiobutton302_1) configure -state normal
    }} \
        -text {Sub Sampling} -value SubSamp -variable ConvertExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd106" "Radiobutton302_16" vTcl:WidgetProc "Toplevel302" 1
    pack $site_5_0.cpd106 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.fra104 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra104" "Frame8" vTcl:WidgetProc "Toplevel302" 1
    set site_5_0 $site_4_0.fra104
    radiobutton $site_5_0.cpd107 \
        \
        -command {global MultiLookRow MultiLookCol SubSampRow SubSampCol
global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir
global DataFormatActive ConvertOutputFormat

set MultiLookRow " ? "
set MultiLookCol " ? "
set SubSampRow ""
set SubSampCol ""
$widget(Label302_1) configure -state disable
$widget(Label302_2) configure -state disable
$widget(Label302_3) configure -state normal
$widget(Label302_4) configure -state normal
$widget(Entry302_1) configure -state disable
$widget(Entry302_2) configure -state disable
$widget(Entry302_3) configure -state normal
$widget(Entry302_4) configure -state normal

set ConvertOutputFormat ""
set ConvertMasterOutputDir ""
set ConvertSlaveOutputDir ""
set ConvertMasterSlaveOutputDir ""
set ConvertOutputSubDir ""
$widget(TitleFrame302_3) configure -text ""
$widget(Entry302_03) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_03) configure -state disable
$widget(Button302_1) configure -state disable
$widget(TitleFrame302_4) configure -text ""
$widget(Entry302_04) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_04) configure -state disable
$widget(Button302_2) configure -state disable
$widget(TitleFrame302_5) configure -text ""
$widget(Entry302_05) configure -disabledbackground $PSPBackgroundColor
$widget(Entry302_05) configure -state disable
$widget(Entry302_06) configure -disabledbackground $PSPBackgroundColor
$widget(Button302_3) configure -state disable
$widget(Label302_01) configure -state disable

if {$DataFormatActive == "SPP"} {
    $widget(Radiobutton302_4) configure -state disable
    }

if {$DataFormatActive == "S2"} {
    $widget(Radiobutton302_1) configure -state disable
    }} \
        -text {Multi Look} -value MultiLook -variable ConvertExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd107" "Radiobutton302_17" vTcl:WidgetProc "Toplevel302" 1
    pack $site_5_0.cpd107 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra102 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra103 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra104 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $site_3_0.cpd98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd98" "Frame5" vTcl:WidgetProc "Toplevel302" 1
    set site_4_0 $site_3_0.cpd98
    frame $site_4_0.cpd111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd111" "Frame153" vTcl:WidgetProc "Toplevel302" 1
    set site_5_0 $site_4_0.cpd111
    label $site_5_0.lab23 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab23" "Label203" vTcl:WidgetProc "Toplevel302" 1
    label $site_5_0.lab25 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab25" "Label204" vTcl:WidgetProc "Toplevel302" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_4_0.cpd109 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd109" "Frame154" vTcl:WidgetProc "Toplevel302" 1
    set site_5_0 $site_4_0.cpd109
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label302_2" vTcl:WidgetProc "Toplevel302" 1
    entry $site_5_0.ent26 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable SubSampRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry302_2" vTcl:WidgetProc "Toplevel302" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label302_1" vTcl:WidgetProc "Toplevel302" 1
    entry $site_5_0.ent24 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable SubSampCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry302_1" vTcl:WidgetProc "Toplevel302" 1
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd110 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd110" "Frame155" vTcl:WidgetProc "Toplevel302" 1
    set site_5_0 $site_4_0.cpd110
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label302_4" vTcl:WidgetProc "Toplevel302" 1
    entry $site_5_0.ent26 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable MultiLookRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry302_4" vTcl:WidgetProc "Toplevel302" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label302_3" vTcl:WidgetProc "Toplevel302" 1
    entry $site_5_0.ent24 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable MultiLookCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry302_3" vTcl:WidgetProc "Toplevel302" 1
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd109 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd110 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.fra97 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame13" vTcl:WidgetProc "Toplevel302" 1
    set site_3_0 $top.cpd77
    label $site_3_0.lab80 \
        -text { Input Data Format   } 
    vTcl:DefineAlias "$site_3_0.lab80" "Label3" vTcl:WidgetProc "Toplevel302" 1
    entry $site_3_0.ent81 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ConvertInputFormat -width 40 
    vTcl:DefineAlias "$site_3_0.ent81" "Entry3" vTcl:WidgetProc "Toplevel302" 1
    pack $site_3_0.lab80 \
        -in $site_3_0 -anchor center -expand 0 -fill none -ipadx 5 -side left 
    pack $site_3_0.ent81 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit80 \
        -text {Output Data Format} 
    vTcl:DefineAlias "$top.tit80" "TitleFrame2" vTcl:WidgetProc "Toplevel302" 1
    bind $top.tit80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit80 getframe]
    frame $site_4_0.cpd69
    set site_5_0 $site_4_0.cpd69
    frame $site_5_0.cpd70
    set site_6_0 $site_5_0.cpd70
    radiobutton $site_6_0.cpd66 \
        \
        -command {global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir ConvertExtractFonction

if {$ConvertExtractFonction == ""} {
    set ConvertOutputFormat ""
    } else {
    set ConvertOutputSubDir ""
    if {$ConvertExtractFonction == "Full"} {
        set ConvertMasterOutputDir $MasterOutputDir; append ConvertMasterOutputDir "_FUL"
        set ConvertSlaveOutputDir $SlaveOutputDir; append ConvertSlaveOutputDir "_FUL"
        }
    if {$ConvertExtractFonction == "SubSamp"} {
        set ConvertMasterOutputDir $MasterOutputDir; append ConvertMasterOutputDir "_SSP"
        set ConvertSlaveOutputDir $SlaveOutputDir; append ConvertSlaveOutputDir "_SSP"
        }
    set ConvertMasterSlaveOutputDir ""
    $widget(TitleFrame302_3) configure -text "Output Master Directory"
    $widget(Entry302_03) configure -disabledbackground #FFFFFF
    $widget(Entry302_03) configure -state normal
    $widget(Button302_1) configure -state normal
    $widget(TitleFrame302_4) configure -text "Output Slave Directory"
    $widget(Entry302_04) configure -disabledbackground #FFFFFF
    $widget(Entry302_04) configure -state normal
    $widget(Button302_2) configure -state normal
    $widget(TitleFrame302_5) configure -text ""
    $widget(Entry302_05) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_05) configure -state disable
    $widget(Entry302_06) configure -disabledbackground $PSPBackgroundColor
    $widget(Button302_3) configure -state disable
    $widget(Label302_01) configure -state disable
    }} \
        -text {2 x [SPP] >> 2 x [SPP]} -value SPP \
        -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd66" "Radiobutton302_4" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71
    set site_6_0 $site_5_0.cpd71
    radiobutton $site_6_0.cpd72 \
        \
        -command {global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir ConvertExtractFonction

if {$ConvertExtractFonction == ""} {
    set ConvertOutputFormat ""
    } else {
    set ConvertOutputSubDir ""
    if {$ConvertExtractFonction == "Full"} {
        set ConvertMasterOutputDir $MasterOutputDir; append ConvertMasterOutputDir "_FUL"
        set ConvertSlaveOutputDir $SlaveOutputDir; append ConvertSlaveOutputDir "_FUL"
        }
    if {$ConvertExtractFonction == "SubSamp"} {
        set ConvertMasterOutputDir $MasterOutputDir; append ConvertMasterOutputDir "_SSP"
        set ConvertSlaveOutputDir $SlaveOutputDir; append ConvertSlaveOutputDir "_SSP"
        }
    set ConvertMasterSlaveOutputDir ""
    $widget(TitleFrame302_3) configure -text "Output Master Directory"
    $widget(Entry302_03) configure -disabledbackground #FFFFFF
    $widget(Entry302_03) configure -state normal
    $widget(Button302_1) configure -state normal
    $widget(TitleFrame302_4) configure -text "Output Slave Directory"
    $widget(Entry302_04) configure -disabledbackground #FFFFFF
    $widget(Entry302_04) configure -state normal
    $widget(Button302_2) configure -state normal
    $widget(TitleFrame302_5) configure -text ""
    $widget(Entry302_05) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_05) configure -state disable
    $widget(Entry302_06) configure -disabledbackground $PSPBackgroundColor
    $widget(Button302_3) configure -state disable
    $widget(Label302_01) configure -state disable
    }} \
        -text {2 x [S2] >> 2 x  [S2]} -value S2 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd72" "Radiobutton302_1" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    frame $site_4_0.cpd68
    set site_5_0 $site_4_0.cpd68
    frame $site_5_0.cpd74
    set site_6_0 $site_5_0.cpd74
    radiobutton $site_6_0.cpd66 \
        \
        -command {global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir ConvertExtractFonction

if {$ConvertExtractFonction == ""} {
    set ConvertOutputFormat ""
    } else {
    set ConvertOutputSubDir "T4"
    set ConvertMasterOutputDir ""
    set ConvertSlaveOutputDir ""
    if {$ConvertExtractFonction == "Full"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_FUL"
        }
    if {$ConvertExtractFonction == "SubSamp"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_SSP"
        }
    if {$ConvertExtractFonction == "MultiLook"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_MLK"
        }
    $widget(TitleFrame302_3) configure -text ""
    $widget(Entry302_03) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_03) configure -state disable
    $widget(Button302_1) configure -state disable
    $widget(TitleFrame302_4) configure -text ""
    $widget(Entry302_04) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_04) configure -state disable
    $widget(Button302_2) configure -state disable
    $widget(TitleFrame302_5) configure -text "Output Master-Slave Directory"
    $widget(Entry302_05) configure -disabledbackground #FFFFFF
    $widget(Entry302_05) configure -state normal
    $widget(Entry302_06) configure -disabledbackground #FFFFFF
    $widget(Button302_3) configure -state normal
    $widget(Label302_01) configure -state normal
    }} \
        -text {2 x [SPP] >> [T4]} -value SPPT4 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd66" "Radiobutton302_6" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd75
    set site_6_0 $site_5_0.cpd75
    radiobutton $site_6_0.cpd66 \
        \
        -command {global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir ConvertExtractFonction

if {$ConvertExtractFonction == ""} {
    set ConvertOutputFormat ""
    } else {
    set ConvertOutputSubDir "T6"
    set ConvertMasterOutputDir ""
    set ConvertSlaveOutputDir ""
    if {$ConvertExtractFonction == "Full"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_FUL"
        }
    if {$ConvertExtractFonction == "SubSamp"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_SSP"
        }
    if {$ConvertExtractFonction == "MultiLook"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_MLK"
        }
    $widget(TitleFrame302_3) configure -text ""
    $widget(Entry302_03) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_03) configure -state disable
    $widget(Button302_1) configure -state disable
    $widget(TitleFrame302_4) configure -text ""
    $widget(Entry302_04) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_04) configure -state disable
    $widget(Button302_2) configure -state disable
    $widget(TitleFrame302_5) configure -text "Output Master-Slave Directory"
    $widget(Entry302_05) configure -disabledbackground #FFFFFF
    $widget(Entry302_05) configure -state normal
    $widget(Entry302_06) configure -disabledbackground #FFFFFF
    $widget(Button302_3) configure -state normal
    $widget(Label302_01) configure -state normal
    }} \
        -text {2 x [S2] >> [T6]} -value S2T6 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd66" "Radiobutton302_3" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    frame $site_4_0.cpd67
    set site_5_0 $site_4_0.cpd67
    frame $site_5_0.cpd72
    set site_6_0 $site_5_0.cpd72
    radiobutton $site_6_0.cpd66 \
        \
        -command {global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir ConvertExtractFonction

if {$ConvertExtractFonction == ""} {
    set ConvertOutputFormat ""
    } else {
    set ConvertOutputSubDir "T4"
    set ConvertMasterOutputDir ""
    set ConvertSlaveOutputDir ""
    if {$ConvertExtractFonction == "Full"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_FUL"
        }
    if {$ConvertExtractFonction == "SubSamp"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_SSP"
        }
    if {$ConvertExtractFonction == "MultiLook"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_MLK"
        }
    $widget(TitleFrame302_3) configure -text ""
    $widget(Entry302_03) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_03) configure -state disable
    $widget(Button302_1) configure -state disable
    $widget(TitleFrame302_4) configure -text ""
    $widget(Entry302_04) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_04) configure -state disable
    $widget(Button302_2) configure -state disable
    $widget(TitleFrame302_5) configure -text "Output Master-Slave Directory"
    $widget(Entry302_05) configure -disabledbackground #FFFFFF
    $widget(Entry302_05) configure -state normal
    $widget(Entry302_06) configure -disabledbackground #FFFFFF
    $widget(Button302_3) configure -state normal
    $widget(Label302_01) configure -state normal
    }} \
        -text {[T4] >> [T4]} -value T4 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd66" "Radiobutton302_5" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd73
    set site_6_0 $site_5_0.cpd73
    radiobutton $site_6_0.cpd74 \
        \
        -command {global ConvertOutputSubDir ConvertMasterSlaveOutputDir
global ConvertMasterOutputDir ConvertSlaveOutputDir
global MasterOutputDir SlaveOutputDir ConvertExtractFonction

if {$ConvertExtractFonction == ""} {
    set ConvertOutputFormat ""
    } else {
    set ConvertOutputSubDir "T6"
    set ConvertMasterOutputDir ""
    set ConvertSlaveOutputDir ""
    if {$ConvertExtractFonction == "Full"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_FUL"
        }
    if {$ConvertExtractFonction == "SubSamp"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_SSP"
        }
    if {$ConvertExtractFonction == "MultiLook"} {
        set ConvertMasterSlaveOutputDir $MasterSlaveOutputDir; append ConvertMasterSlaveOutputDir "_MLK"
        }
    $widget(TitleFrame302_3) configure -text ""
    $widget(Entry302_03) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_03) configure -state disable
    $widget(Button302_1) configure -state disable
    $widget(TitleFrame302_4) configure -text ""
    $widget(Entry302_04) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry302_04) configure -state disable
    $widget(Button302_2) configure -state disable
    $widget(TitleFrame302_5) configure -text "Output Master-Slave Directory"
    $widget(Entry302_05) configure -disabledbackground #FFFFFF
    $widget(Entry302_05) configure -state normal
    $widget(Entry302_06) configure -disabledbackground #FFFFFF
    $widget(Button302_3) configure -state normal
    $widget(Label302_01) configure -state normal
    }} \
        -text {[T6] >> [T6]} -value T6 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd74" "Radiobutton302_2" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd76" "Frame10" vTcl:WidgetProc "Toplevel302" 1
    set site_3_0 $top.cpd76
    TitleFrame $site_3_0.cpd80 \
        -ipad 0 -text {Output Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd80" "TitleFrame302_3" vTcl:WidgetProc "Toplevel302" 1
    bind $site_3_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ConvertMasterOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry302_03" vTcl:WidgetProc "Toplevel302" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel302" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd95 \
        \
        -command {global DirName DataDirChannel1 ConvertMasterOutputDir MasterOutputDir
global VarWarning WarningMessage WarningMessage2

set ConvertMasterOutputDirTmp $ConvertMasterOutputDir
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT MASTER DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN MASTER DIRECTORY"
    set WarningMessage2 "IS CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set ConvertMasterOutputDir $DirName
        set MasterOutputDir $DirName
        set ConvertExtractFonction "Full"
        set MultiLookRow ""
        set MultiLookCol ""
        set SubSampRow ""
        set SubSampCol ""
        $widget(Label302_1) configure -state disable
        $widget(Label302_2) configure -state disable
        $widget(Label302_3) configure -state disable
        $widget(Label302_4) configure -state disable
        $widget(Entry302_1) configure -state disable
        $widget(Entry302_2) configure -state disable
        $widget(Entry302_3) configure -state disable
        $widget(Entry302_4) configure -state disable
        } else {
        set ConvertMasterOutputDir $ConvertMasterOutputDirTmp
        }
    } else {
    set ConvertMasterOutputDir $ConvertMasterOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd95" "Button302_1" vTcl:WidgetProc "Toplevel302" 1
    bindtags $site_6_0.cpd95 "$site_6_0.cpd95 Button $top all _vTclBalloon"
    bind $site_6_0.cpd95 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd79 \
        -ipad 0 -text {Output Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd79" "TitleFrame302_4" vTcl:WidgetProc "Toplevel302" 1
    bind $site_3_0.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd79 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ConvertSlaveOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry302_04" vTcl:WidgetProc "Toplevel302" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel302" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd95 \
        \
        -command {global DirName DataDir ConvertSlaveOutputDir SlaveOutputDir
global VarWarning WarningMessage WarningMessage2

set ConvertSlaveOutputDirTmp $ConvertSlaveOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT SLAVE DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN SLAVE DIRECTORY"
    set WarningMessage2 "IS CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set ConvertSlaveOutputDir $DirName
        set SlaveOutputDir $DirName
        set ConvertExtractFonction "Full"
        set MultiLookRow ""
        set MultiLookCol ""
        set SubSampRow ""
        set SubSampCol ""
        $widget(Label302_1) configure -state disable
        $widget(Label302_2) configure -state disable
        $widget(Label302_3) configure -state disable
        $widget(Label302_4) configure -state disable
        $widget(Entry302_1) configure -state disable
        $widget(Entry302_2) configure -state disable
        $widget(Entry302_3) configure -state disable
        $widget(Entry302_4) configure -state disable
        } else {
        set ConvertSlaveOutputDir $ConvertSlaveOutputDirTmp
        }
    } else {
    set ConvertSlaveOutputDir $ConvertSlaveOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd95" "Button302_2" vTcl:WidgetProc "Toplevel302" 1
    bindtags $site_6_0.cpd95 "$site_6_0.cpd95 Button $top all _vTclBalloon"
    bind $site_6_0.cpd95 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Master-Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame302_5" vTcl:WidgetProc "Toplevel302" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ConvertMasterSlaveOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry302_05" vTcl:WidgetProc "Toplevel302" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame15" vTcl:WidgetProc "Toplevel302" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab75 \
        -text {/ } 
    vTcl:DefineAlias "$site_6_0.lab75" "Label302_01" vTcl:WidgetProc "Toplevel302" 1
    entry $site_6_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ConvertOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd77" "Entry302_06" vTcl:WidgetProc "Toplevel302" 1
    pack $site_6_0.lab75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel302" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd95 \
        \
        -command {global DirName DataDir ConvertMasterSlaveOutputDir MasterSlaveOutputDir ConvertOutputSubDir
global VarWarning WarningMessage WarningMessage2

set ConvertMasterSlaveOutputDirTmp $ConvertMasterSlaveOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT MASTER-SLAVE DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set ConvertMasterSlaveOutputDir $DirName
        set MasterSlaveOutputDir $DirName
        set ConvertExtractFonction "Full"
        set MultiLookRow ""
        set MultiLookCol ""
        set SubSampRow ""
        set SubSampCol ""
        $widget(Label302_1) configure -state disable
        $widget(Label302_2) configure -state disable
        $widget(Label302_3) configure -state disable
        $widget(Label302_4) configure -state disable
        $widget(Entry302_1) configure -state disable
        $widget(Entry302_2) configure -state disable
        $widget(Entry302_3) configure -state disable
        $widget(Entry302_4) configure -state disable
        } else {
        set ConvertMasterSlaveOutputDir $ConvertMasterSlaveOutputDirTmp
        }
    } else {
    set ConvertMasterSlaveOutputDir $ConvertMasterSlaveOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd95" "Button302_3" vTcl:WidgetProc "Toplevel302" 1
    bindtags $site_6_0.cpd95 "$site_6_0.cpd95 Button $top all _vTclBalloon"
    bind $site_6_0.cpd95 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd80 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd79 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra41 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame20" vTcl:WidgetProc "Toplevel302" 1
    set site_3_0 $top.fra41
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ConvertOutputFormat 
global VarError VarAdvice ErrorMessage VarWarning WarningMessage WarningMessage2

if {$OpenDirFile == 0} {

if {$ConvertOutputFormat == ""} {
    set ErrorMessage "DEFINE THE OUTPUT FORMAT FIRST"
    set VarError ""
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    } else {
    set WarningMessage "DON'T FORGET TO UPDATE THE SIZE (Nrow, Ncol)"
    set WarningMessage2 "OF THE AUXILIARY FILES (Flat Earth, kz ...)"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    if {$ConvertOutputFormat == "S2"} { DualConvertDATA_S2 }
    if {$ConvertOutputFormat == "S2T6"} { DualConvertDATA_S2T6 }
    if {$ConvertOutputFormat == "T6"} { DualConvertDATA_T6 }
    if {$ConvertOutputFormat == "SPP"} { DualConvertDATA_SPP }
    if {$ConvertOutputFormat == "SPPT4"} { DualConvertDATA_SPPT4 }
    if {$ConvertOutputFormat == "T4"} { DualConvertDATA_T4 }
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel302" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DataFileConvertDual.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel302" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel302); TextEditorRunTrace "Close Window Convert Data" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel302" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra27 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra96 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit80 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra41 \
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
Window show .top302

main $argc $argv
