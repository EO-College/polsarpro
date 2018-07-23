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

        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top230
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.tit76 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit76 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit77 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit77 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra71
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-command 1 -justify 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_5_0 $site_4_0.cpd83
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra72
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra79
    namespace eval ::widgets::$site_6_0.fra80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra80
    namespace eval ::widgets::$site_7_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd81
    namespace eval ::widgets::$site_7_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd68 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.fra86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra86
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra88
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra90
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit99 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit99 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra77 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra77
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-command 1 -padx 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra84
    namespace eval ::widgets::$site_6_0.fra85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra85
    namespace eval ::widgets::$site_7_0.cpd87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd87
    namespace eval ::widgets::$site_8_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd86
    namespace eval ::widgets::$site_7_0.cpd88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd88
    namespace eval ::widgets::$site_8_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd68 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.fra92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra92
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra94
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd83
    namespace eval ::widgets::$site_5_0.fra98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra98
    namespace eval ::widgets::$site_6_0.cpd104 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra99 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra99
    namespace eval ::widgets::$site_6_0.cpd102 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra100 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra100
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd101 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
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
            vTclWindow.top230
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
    wm geometry $top 200x200+75+75; update
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

proc vTclWindow.top230 {base} {
    if {$base == ""} {
        set base .top230
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
    wm geometry $top 500x500+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Batch Procedure"
    vTcl:DefineAlias "$top" "Toplevel230" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -ipad 2 -text {Input Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel230" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BatchDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry230_149" vTcl:WidgetProc "Toplevel230" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel230" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit76 \
        -ipad 2 -text {Output Directory} 
    vTcl:DefineAlias "$top.tit76" "TitleFrame2" vTcl:WidgetProc "Toplevel230" 1
    bind $top.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit76 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BatchOutputDir 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry230_73" vTcl:WidgetProc "Toplevel230" 1
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame13" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab73" "Label1" vTcl:WidgetProc "Toplevel230" 1
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BatchOutputSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel230" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame2" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global DirName BatchDataDir BatchOutputDir

set BatchOutputDirTmp $BatchOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT MAIN DIRECTORY"
if {$DirName != "" } {
    set BatchOutputDir $DirName
    } else {
    set BatchOutputDir $BatchOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button230_92" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_5_0.cpd85 "$site_5_0.cpd85 Button $top all _vTclBalloon"
    bind $site_5_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel230" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label230_01" vTcl:WidgetProc "Toplevel230" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry230_01" vTcl:WidgetProc "Toplevel230" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label230_02" vTcl:WidgetProc "Toplevel230" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry230_02" vTcl:WidgetProc "Toplevel230" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label230_03" vTcl:WidgetProc "Toplevel230" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry230_03" vTcl:WidgetProc "Toplevel230" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label230_04" vTcl:WidgetProc "Toplevel230" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry230_04" vTcl:WidgetProc "Toplevel230" 1
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
    TitleFrame $top.tit77 \
        -ipad 2 -text {Speckle Filter} 
    vTcl:DefineAlias "$top.tit77" "TitleFrame3" vTcl:WidgetProc "Toplevel230" 1
    bind $top.tit77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit77 getframe]
    checkbutton $site_4_0.cpd79 \
        \
        -command {global BatchFilter BatchDataDir BatchDOutputDir BatchConvert BatchFilterCase
global BatchNlook BatchNwinFilterL BatchNwinFilterC

if {"$BatchFilter"=="0"} {
    $widget(Radiobutton230_3) configure -state disable
    $widget(Radiobutton230_4) configure -state disable
    $widget(Label230_3) configure -state disable
    $widget(Entry230_3) configure -state disable
    $widget(Label230_4a) configure -state disable
    $widget(Entry230_4a) configure -state disable
    $widget(Label230_4b) configure -state disable
    $widget(Entry230_4b) configure -state disable
    set BatchOutputDir $BatchDataDir
    set BatchFilterCase ""
    set BatchNlook ""
    set BatchNwinFilterL ""
    set BatchNwinFilterC ""
    } else {
    $widget(Radiobutton230_3) configure -state normal
    $widget(Radiobutton230_4) configure -state normal
    $widget(Label230_3) configure -state normal
    $widget(Entry230_3) configure -state normal
    $widget(Label230_4a) configure -state normal
    $widget(Entry230_4a) configure -state normal
    $widget(Label230_4b) configure -state disable
    $widget(Entry230_4b) configure -state disable
    set BatchDataDir $BatchOutputDir
    append BatchOutputDir "_LEE"
    set BatchFilterCase "lee"
    set BatchNlook 1
    set BatchNwinFilterL 7
    set BatchNwinFilterC 1
    }} \
        -variable BatchFilter 
    vTcl:DefineAlias "$site_4_0.cpd79" "Checkbutton230_3" vTcl:WidgetProc "Toplevel230" 1
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame215" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.cpd82
    label $site_5_0.lab23 \
        -padx 1 -text {Window Size : Row} 
    vTcl:DefineAlias "$site_5_0.lab23" "Label230_4a" vTcl:WidgetProc "Toplevel230" 1
    entry $site_5_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchNwinFilterL -width 3 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry230_4a" vTcl:WidgetProc "Toplevel230" 1
    label $site_5_0.cpd68 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.cpd68" "Label230_4b" vTcl:WidgetProc "Toplevel230" 1
    entry $site_5_0.cpd70 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchNwinFilterC -width 3 
    vTcl:DefineAlias "$site_5_0.cpd70" "Entry230_4b" vTcl:WidgetProc "Toplevel230" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 0 -fill none -ipadx 2 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 0 -fill none -ipadx 2 -side left 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -ipadx 2 -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 1 -fill none -ipadx 2 -side left 
    frame $site_4_0.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra71" "Frame3" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.fra71
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame4" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.cpd75
    radiobutton $site_6_0.cpd77 \
        \
        -command {global BatchDataDir BatchOutputDir
global BatchNlook BatchNwinFilterL BatchNwinFilterC

set BatchOutputDir $BatchDataDir
append BatchOutputDir "_BOX"

$widget(Label230_3) configure -state disable
$widget(Entry230_3) configure -state disable
$widget(Label230_4a) configure -state normal
$widget(Entry230_4a) configure -state normal
$widget(Label230_4b) configure -state normal
$widget(Entry230_4b) configure -state normal
set BatchNlook 1
set BatchNwinFilterL 7
set BatchNwinFilterC 7} \
        -justify left -text {BoxCar Filter} -value box \
        -variable BatchFilterCase 
    vTcl:DefineAlias "$site_6_0.cpd77" "Radiobutton230_3" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd76" "Frame7" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.cpd76
    radiobutton $site_6_0.cpd78 \
        \
        -command {global BatchDataDir BatchOutputDir
global BatchNlook BatchNwinFilterL BatchNwinFilterC

set BatchOutputDir $BatchDataDir
append BatchOutputDir "_LEE"

$widget(Label230_3) configure -state normal
$widget(Entry230_3) configure -state normal
$widget(Label230_4a) configure -state normal
$widget(Entry230_4a) configure -state normal
$widget(Label230_4b) configure -state disable
$widget(Entry230_4b) configure -state disable
set BatchNlook 1
set BatchNwinFilterL 7
set BatchNwinFilterC 1} \
        -text {J.S. Lee Refined Filter} -value lee -variable BatchFilterCase 
    vTcl:DefineAlias "$site_6_0.cpd78" "Radiobutton230_4" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side bottom 
    frame $site_4_0.cpd83 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_4_0.cpd83" "Frame218" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.cpd83
    label $site_5_0.lab23 \
        -padx 1 -text {Nb of Looks} 
    vTcl:DefineAlias "$site_5_0.lab23" "Label230_3" vTcl:WidgetProc "Toplevel230" 1
    entry $site_5_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchNlook -width 3 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry230_3" vTcl:WidgetProc "Toplevel230" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.fra71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit92 \
        -ipad 2 -text {H / A / Alpha Decomposition} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame5" vTcl:WidgetProc "Toplevel230" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    frame $site_4_0.fra72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra72" "Frame5" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.fra72
    checkbutton $site_5_0.cpd73 \
        \
        -command {global BatchDecomp BatchBMPDecomp BatchNwinDecompL BatchNwinDecompC BatchHAalpha_planes
global ColorMapPlanes9 RedPalette GreenPalette BluePalette COLORMAPDir PSPBackgroundColor

if {"$BatchDecomp"=="0"} {
    $widget(Checkbutton230_5) configure -state disable
    $widget(Label230_9) configure -state disable
    $widget(Label230_5a) configure -state disable
    $widget(Entry230_5a) configure -state disable
    $widget(Label230_5b) configure -state disable
    $widget(Entry230_5b) configure -state disable
    $widget(Label230_13) configure -state disable
    $widget(Entry230_13) configure -state disable
    $widget(Entry230_13) configure -disabledbackground $PSPBackgroundColor
    $widget(Button230_7) configure -state disable
    $widget(Button230_1) configure -state disable
    set BatchBMPDecomp 0
    set BatchNwinDecompL ""
    set BatchNwinDecompC ""
    set BatchHAalpha_planes 0
    set ColorMapPlanes9 ""
    } else {
    $widget(Checkbutton230_5) configure -state normal
    $widget(Label230_9) configure -state normal
    $widget(Label230_5a) configure -state normal
    $widget(Entry230_5a) configure -state normal
    $widget(Label230_5b) configure -state normal
    $widget(Entry230_5b) configure -state normal
    $widget(Label230_13) configure -state normal
    $widget(Entry230_13) configure -state normal
    $widget(Entry230_13) configure -disabledbackground #FFFFFF
    $widget(Button230_7) configure -state normal
    $widget(Button230_1) configure -state normal
    set BatchBMPDecomp 1
    set BatchNwinDecompL 3
    set BatchNwinDecompC 3
    set BatchHAalpha_planes 1
    set ColorMapPlanes9 "$COLORMAPDir/Planes_H_A_Alpha_ColorMap9.pal"
    for {set i 0} {$i < 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    }} \
        -variable BatchDecomp 
    vTcl:DefineAlias "$site_5_0.cpd73" "Checkbutton230_4" vTcl:WidgetProc "Toplevel230" 1
    frame $site_5_0.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra79" "Frame8" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra79
    frame $site_6_0.fra80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra80" "Frame10" vTcl:WidgetProc "Toplevel230" 1
    set site_7_0 $site_6_0.fra80
    checkbutton $site_7_0.cpd83 \
        -text {H / A / Alpha Planes (BMP)} -variable BatchHAalpha_planes 
    vTcl:DefineAlias "$site_7_0.cpd83" "Checkbutton230_5" vTcl:WidgetProc "Toplevel230" 1
    pack $site_7_0.cpd83 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd81" "Frame11" vTcl:WidgetProc "Toplevel230" 1
    set site_7_0 $site_6_0.cpd81
    label $site_7_0.lab82 \
        -text {+ Classifier (Bin + BMP)} 
    vTcl:DefineAlias "$site_7_0.lab82" "Label230_9" vTcl:WidgetProc "Toplevel230" 1
    pack $site_7_0.lab82 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra80 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side bottom 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame216" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.cpd71
    label $site_6_0.lab23 \
        -padx 1 -text {Window Size : Row} 
    vTcl:DefineAlias "$site_6_0.lab23" "Label230_5a" vTcl:WidgetProc "Toplevel230" 1
    entry $site_6_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchNwinDecompL -width 3 
    vTcl:DefineAlias "$site_6_0.ent24" "Entry230_5a" vTcl:WidgetProc "Toplevel230" 1
    label $site_6_0.cpd68 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_6_0.cpd68" "Label230_5b" vTcl:WidgetProc "Toplevel230" 1
    entry $site_6_0.cpd70 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchNwinDecompC -width 3 
    vTcl:DefineAlias "$site_6_0.cpd70" "Entry230_5b" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.lab23 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 2 -side left 
    pack $site_6_0.ent24 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 2 -side left 
    pack $site_6_0.cpd68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -ipadx 2 -side left 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 1 -fill none -ipadx 2 -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra79 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd76 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame111" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra86" "Frame15" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra86
    label $site_6_0.cpd87 \
        -text {ColorMap 9  } 
    vTcl:DefineAlias "$site_6_0.cpd87" "Label230_13" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame16" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapPlanes9 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry230_13" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame17" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName BatchDirInput ColorMapPlanes9

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$BatchDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapPlanes9 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button230_1" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.cpd91 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd91 {global ColorMapPlanes9 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMapNumber 9
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
WaitUntilCreated $ColorMapPlanes9
if [file exists $ColorMapPlanes9] {
    set f [open $ColorMapPlanes9 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMapPlanes9
set ColorMapOut $ColorMapPlanes9
WidgetShowFromWidget $widget(Toplevel230) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapSupervised16 $ColorMapOut
   }}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd91" "Button230_7" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_6_0.cpd91 "$site_6_0.cpd91 Button $top all _vTclBalloon"
    bind $site_6_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra86 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra90 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.fra72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.tit99 \
        -ipad 2 -text {Unsupervised Wishart - H / A / Alpha Classification} 
    vTcl:DefineAlias "$top.tit99" "TitleFrame6" vTcl:WidgetProc "Toplevel230" 1
    bind $top.tit99 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit99 getframe]
    frame $site_4_0.fra77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra77" "Frame6" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.fra77
    checkbutton $site_5_0.cpd78 \
        \
        -command {global BatchWishart BatchWishartPourcentage BatchWishartIteration BatchNwinWishartL BatchNwinWishartL BatchBMPWishart
global ColorMapWishart8 ColorMapWishart16 RedPalette GreenPalette BluePalette COLORMAPDir PSPBackgroundColor

if {"$BatchWishart"=="0"} {
    $widget(Label230_6) configure -state disable
    $widget(Entry230_6) configure -state disable
    $widget(Label230_7) configure -state disable
    $widget(Entry230_7) configure -state disable
    $widget(Label230_8a) configure -state disable
    $widget(Entry230_8a) configure -state disable
    $widget(Label230_8b) configure -state disable
    $widget(Entry230_8b) configure -state disable
    $widget(Label230_12) configure -state disable
    $widget(Entry230_12) configure -state disable
    $widget(Entry230_12) configure -disabledbackground $PSPBackgroundColor
    $widget(Button230_6) configure -state disable
    $widget(Button230_2) configure -state disable
    $widget(Label230_14) configure -state disable
    $widget(Entry230_14) configure -state disable
    $widget(Entry230_14) configure -disabledbackground $PSPBackgroundColor
    $widget(Button230_8) configure -state disable
    $widget(Button230_3) configure -state disable
    set BatchBMPWishart 0
    set BatchNwinWishartL ""
    set BatchNwinWishartC ""
    set BatchWishartPourcentage ""
    set BatchWishartIteration ""
    set ColorMapWishart8 ""
    set ColorMapWishart16 ""
    } else {
    $widget(Label230_6) configure -state normal
    $widget(Entry230_6) configure -state normal
    $widget(Label230_7) configure -state normal
    $widget(Entry230_7) configure -state normal
    $widget(Label230_8a) configure -state normal
    $widget(Entry230_8a) configure -state normal
    $widget(Label230_8b) configure -state normal
    $widget(Entry230_8b) configure -state normal
    $widget(Label230_12) configure -state normal
    $widget(Entry230_12) configure -state normal
    $widget(Entry230_12) configure -disabledbackground #FFFFFF
    $widget(Button230_6) configure -state normal
    $widget(Button230_2) configure -state normal
    $widget(Label230_14) configure -state normal
    $widget(Entry230_14) configure -state normal
    $widget(Entry230_14) configure -disabledbackground #FFFFFF
    $widget(Button230_8) configure -state normal
    $widget(Button230_3) configure -state normal
    set BatchBMPWishart 1
    set BatchNwinWishartL 3
    set BatchNwinWishartC 3
    set BatchWishartPourcentage 10
    set BatchWishartIteration 10
    set ColorMapWishart8 "$COLORMAPDir/Wishart_ColorMap8.pal"
    set ColorMapWishart16 "$COLORMAPDir/Wishart_ColorMap16.pal"
    for {set i 0} {$i < 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    }} \
        -padx 1 -variable BatchWishart 
    vTcl:DefineAlias "$site_5_0.cpd78" "Checkbutton230_6" vTcl:WidgetProc "Toplevel230" 1
    frame $site_5_0.fra84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra84" "Frame12" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra84
    frame $site_6_0.fra85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra85" "Frame14" vTcl:WidgetProc "Toplevel230" 1
    set site_7_0 $site_6_0.fra85
    frame $site_7_0.cpd87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd87" "Frame230" vTcl:WidgetProc "Toplevel230" 1
    set site_8_0 $site_7_0.cpd87
    label $site_8_0.lab23 \
        -padx 1 -text {% of Pixels Switching Class} 
    vTcl:DefineAlias "$site_8_0.lab23" "Label230_6" vTcl:WidgetProc "Toplevel230" 1
    entry $site_8_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchWishartPourcentage -width 3 
    vTcl:DefineAlias "$site_8_0.ent24" "Entry230_6" vTcl:WidgetProc "Toplevel230" 1
    pack $site_8_0.lab23 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.ent24 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd87 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    frame $site_6_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd86" "Frame18" vTcl:WidgetProc "Toplevel230" 1
    set site_7_0 $site_6_0.cpd86
    frame $site_7_0.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd88" "Frame231" vTcl:WidgetProc "Toplevel230" 1
    set site_8_0 $site_7_0.cpd88
    label $site_8_0.lab23 \
        -padx 1 -text {Maximum Number of Iterations} 
    vTcl:DefineAlias "$site_8_0.lab23" "Label230_7" vTcl:WidgetProc "Toplevel230" 1
    entry $site_8_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchWishartIteration -width 3 
    vTcl:DefineAlias "$site_8_0.ent24" "Entry230_7" vTcl:WidgetProc "Toplevel230" 1
    pack $site_8_0.lab23 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.ent24 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd88 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.fra85 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side bottom 
    frame $site_5_0.cpd72 \
        -borderwidth 2 -height 75 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame217" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.lab23 \
        -padx 1 -text {Window Size : Row} 
    vTcl:DefineAlias "$site_6_0.lab23" "Label230_8a" vTcl:WidgetProc "Toplevel230" 1
    entry $site_6_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchNwinWishartL -width 3 
    vTcl:DefineAlias "$site_6_0.ent24" "Entry230_8a" vTcl:WidgetProc "Toplevel230" 1
    label $site_6_0.cpd68 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_6_0.cpd68" "Label230_8b" vTcl:WidgetProc "Toplevel230" 1
    entry $site_6_0.cpd70 \
        -background white -foreground #ff0000 -justify center \
        -textvariable BatchNwinWishartC -width 3 
    vTcl:DefineAlias "$site_6_0.cpd70" "Entry230_8b" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.lab23 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 2 -side left 
    pack $site_6_0.ent24 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 2 -side left 
    pack $site_6_0.cpd68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -ipadx 2 -side left 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 1 -fill none -ipadx 2 -side left 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra84 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame112" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.cpd82
    frame $site_5_0.fra92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra92" "Frame19" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra92
    label $site_6_0.cpd97 \
        -text {ColorMap 8  } 
    vTcl:DefineAlias "$site_6_0.cpd97" "Label230_12" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame21" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra93
    entry $site_6_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapWishart8 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd96" "Entry230_12" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.cpd96 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra94" "Frame22" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra94
    button $site_6_0.cpd73 \
        \
        -command {global FileName BatchDirInput ColorMapWishart8

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$BatchDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapWishart8 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd73" "Button230_2" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_6_0.cpd73 "$site_6_0.cpd73 Button $top all _vTclBalloon"
    bind $site_6_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.cpd95 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd95 {global ColorMapWishart8 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMapNumber 8
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
WaitUntilCreated $ColorMapWishart8
if [file exists $ColorMapWishart8] {
    set f [open $ColorMapWishart8 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i <= $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal

set VarColorMap ""
set ColorMapIn $ColorMapWishart8
set ColorMapOut $ColorMapWishart8
WidgetShowFromWidget $widget(Toplevel230) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapWishart8 $ColorMapOut
   }}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd95" "Button230_6" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_6_0.cpd95 "$site_6_0.cpd95 Button $top all _vTclBalloon"
    bind $site_6_0.cpd95 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd83 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd83" "Frame235" vTcl:WidgetProc "Toplevel230" 1
    set site_5_0 $site_4_0.cpd83
    frame $site_5_0.fra98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra98" "Frame23" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra98
    label $site_6_0.cpd104 \
        -text {ColorMap 16} 
    vTcl:DefineAlias "$site_6_0.cpd104" "Label230_14" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.cpd104 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra99 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra99" "Frame24" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra99
    entry $site_6_0.cpd102 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapWishart16 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd102" "Entry230_14" vTcl:WidgetProc "Toplevel230" 1
    pack $site_6_0.cpd102 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra100 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra100" "Frame25" vTcl:WidgetProc "Toplevel230" 1
    set site_6_0 $site_5_0.fra100
    button $site_6_0.cpd74 \
        \
        -command {global FileName BatchDirInput ColorMapWishart16

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$BatchDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapWishart16 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd74" "Button230_3" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_6_0.cpd74 "$site_6_0.cpd74 Button $top all _vTclBalloon"
    bind $site_6_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.cpd101 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd101 {global ColorMapWishart16 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient $widget(Toplevel38) $PSPTopLevel
    }

set ColorMapNumber 16
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
WaitUntilCreated $ColorMapWishart16
if [file exists $ColorMapWishart16] {
    set f [open $ColorMapWishart16 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur

.top38.fra35.but38 configure -state normal

set VarColorMap ""
set ColorMapIn $ColorMapWishart16
set ColorMapOut $ColorMapWishart16
WidgetShowFromWidget $widget(Toplevel230) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapWishart16 $ColorMapOut
   }}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd101" "Button230_8" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_6_0.cpd101 "$site_6_0.cpd101 Button $top all _vTclBalloon"
    bind $site_6_0.cpd101 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd101 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra98 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra99 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra100 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.fra77 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel230" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir BatchDataDir BatchDirInput BatchDirOutput BatchOutputDir BatchOutputSubDir
global BatchFilter BatchFilterCase BatchNlook BatchNwinFilterL BatchNwinFilterC
global BatchDecomp BatchNwinDecompL BatchNwinDecompC BatchBMPDecomp BatchHAalpha_planes
global BatchWishart BatchNwinWishartL BatchNwinWishartC BatchWishartPourcentage BatchWishartIteration BatchBMPWishart
global ColorMapWishart8 ColorMapWishart16 ColorMapPlanes9
global BMPDirInput BatchProcessFonction PSPMemory TMPMemoryAllocError 
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType 

if {$OpenDirFile == 0} {

set VarBatch "good"

if {$BatchFilter=="1"} {
    set BatchFilterDirInput $BatchDirInput
    set BatchFilterDirOutput $BatchOutputDir
    if {$BatchOutputSubDir != ""} {append BatchFilterDirOutput "/$BatchOutputSubDir"}

    #####################################################################
    #Create Directory
    set BatchFilterDirOutput [PSPCreateDirectory $BatchFilterDirOutput $BatchOutputDir $BatchProcessFonction]
    #####################################################################       

    if {$VarWarning!="ok"} {
	set VarBatch "bad"
	} else {
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        set TestVarName(4) "Number of Looks"; set TestVarType(4) "float"; set TestVarValue(4) $BatchNlook; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "Window Size Filter Row"; set TestVarType(5) "int"; set TestVarValue(5) $BatchNwinFilterL; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
        set TestVarName(6) "Window Size Filter Col"; set TestVarType(6) "int"; set TestVarValue(6) $BatchNwinFilterC; set TestVarMin(6) "1"; set TestVarMax(6) "1000"
        TestVar 7
        if {$TestVarError == "ok"} {

            set ConfigFile "$BatchFilterDirOutput/config.txt"
            WriteConfig
  
            set MaskCmd ""
            set MaskFile "$BatchFilterDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

            if {$BatchFilterCase == "box"} {
                set Fonction "BOXCAR Speckle Filter"
                set Fonction2 ""
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                set BatchFilterFunction "Soft/speckle_filter/boxcar_filter.exe"
                TextEditorRunTrace "Process The Function $BatchFilterFunction" "k"
                TextEditorRunTrace "Arguments: -id \x22$BatchFilterDirInput\x22 -od \x22$BatchFilterDirOutput\x22 -iodf $BatchProcessFonction -nwr $BatchNwinFilterL -nwc $BatchNwinFilterC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/speckle_filter/boxcar_filter.exe -id \x22$BatchFilterDirInput\x22 -od \x22$BatchFilterDirOutput\x22 -iodf $BatchProcessFonction -nwr $BatchNwinFilterL -nwc $BatchNwinFilterC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                }
            if {$BatchFilterCase == "lee"} {
                set Fonction "LEE Refined Speckle Filter"
                set Fonction2 ""
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                set BatchFilterFunction "Soft/speckle_filter/lee_refined_filter.exe"
                TextEditorRunTrace "Process The Function $BatchFilterFunction" "k"
                TextEditorRunTrace "Arguments: -id \x22$BatchFilterDirInput\x22 -od \x22$BatchFilterDirOutput\x22 -iodf $BatchProcessFonction -nw $BatchNwinFilterL -nlk $BatchNlook -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/speckle_filter/lee_refined_filter.exe -id \x22$BatchFilterDirInput\x22 -od \x22$BatchFilterDirOutput\x22 -iodf $BatchProcessFonction -nw $BatchNwinFilterL -nlk $BatchNlook -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                }
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$BatchProcessFonction == "T3"} {EnviWriteConfigT $BatchFilterDirOutput $FinalNlig $FinalNcol}
            if {$BatchProcessFonction == "C3"} {EnviWriteConfigC $BatchFilterDirOutput $FinalNlig $FinalNcol}
            if {$BatchProcessFonction == "T4"} {EnviWriteConfigT $BatchFilterDirOutput $FinalNlig $FinalNcol}
            if {$BatchProcessFonction == "C4"} {EnviWriteConfigC $BatchFilterDirOutput $FinalNlig $FinalNcol}

            #Update the Nlig/Ncol of the new image after processing
            set NligInit 1
            set NcolInit 1
            set NligEnd $FinalNlig
            set NcolEnd $FinalNcol

            set BatchDirInput $BatchFilterDirOutput
            set DataDir $BatchOutputDir
            } else {
            set VarBatch "bad"
            }
        }
}

if {$VarBatch=="good"} {

if {$BatchDecomp=="1"} {
    set BatchDecompDirInput $BatchDirInput
    set BatchDecompDirOutput $BatchOutputDir
    if {$BatchOutputSubDir != ""} {append BatchDecompDirOutput "/$BatchOutputSubDir"}

    if [file isdirectory $BatchDecompDirOutput] {
        set VarWarning "ok"
        } else {
    #####################################################################
    #Create Directory
    set BatchDecompDirOutput [PSPCreateDirectory $BatchDecompDirOutput $BatchOutputDir $BatchProcessFonction]
    #####################################################################       
        }

    if {$VarWarning!="ok"} {
	set VarBatch "bad"
	} else {
        set BMPDirInput $BatchDecompDirOutput
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        set TestVarName(4) "Window Size Decomp Row"; set TestVarType(4) "int"; set TestVarValue(4) $BatchNwinDecompL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "ColorMap9"; set TestVarType(5) "file"; set TestVarValue(5) $ColorMapPlanes9; set TestVarMin(5) ""; set TestVarMax(5) ""
        set TestVarName(6) "Window Size Decomp Col"; set TestVarType(6) "int"; set TestVarValue(6) $BatchNwinDecompC; set TestVarMin(6) "1"; set TestVarMax(6) "1000"
        TestVar 7
        if {$TestVarError == "ok"} {

            set MaskCmd ""
            set MaskFile "$BatchDecompDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

            set Fonction "Creation of all the Binary Data Files"
            set Fonction2 "of the H / A / Alpha Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            set BatchProcessF $BatchProcessFonction
            if {"$BatchProcessFonction" == "C3"} { set BatchProcessF "C3T3" }
            if {"$BatchProcessFonction" == "C4"} { set BatchProcessF "C4T4" }
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/h_a_alpha_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$BatchDecompDirInput\x22 -od \x22$BatchDecompDirOutput\x22 -iodf $BatchProcessF -nwr $BatchNwinDecompL -nwc $BatchNwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 1 -fl4 1 -fl5 1 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/h_a_alpha_decomposition.exe -id \x22$BatchDecompDirInput\x22 -od \x22$BatchDecompDirOutput\x22 -iodf $BatchProcessF -nwr $BatchNwinDecompL -nwc $BatchNwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 1 -fl4 1 -fl5 1 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$BatchDecompDirOutput/entropy.bin"] {EnviWriteConfig "$BatchDecompDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$BatchDecompDirOutput/anisotropy.bin"] {EnviWriteConfig "$BatchDecompDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$BatchDecompDirOutput/alpha.bin"] {EnviWriteConfig "$BatchDecompDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}

            #Update the Nlig/Ncol of the new image after processing
            set NligInit 1
            set NcolInit 1
            set NligEnd $FinalNlig
            set NcolEnd $FinalNcol

            set Fonction "Creation of the BMP File"
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
            if [file exists "$BatchDecompDirOutput/alpha.bin"] {
                set BMPFileInput "$BatchDecompDirOutput/alpha.bin"
                set BMPFileOutput "$BatchDecompDirOutput/alpha.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                }
            if [file exists "$BatchDecompDirOutput/entropy.bin"] {
                set BMPFileInput "$BatchDecompDirOutput/entropy.bin"
                set BMPFileOutput "$BatchDecompDirOutput/entropy.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                }
            if [file exists "$BatchDecompDirOutput/anisotropy.bin"] {
                set BMPFileInput "$BatchDecompDirOutput/anisotropy.bin"
                set BMPFileOutput "$BatchDecompDirOutput/anisotropy.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                }
    
            if {$BatchHAalpha_planes==1} {
                set config "true"
                if [file exists "$BatchDecompDirInput/entropy.bin"] {
                    } else {
                    set config "false"
                    set VarError ""
                    set ErrorMessage "THE FILE entropy DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    } 
                if [file exists "$BatchDecompDirInput/alpha.bin"] {
                    } else {
                    set config "false"
                    set VarError ""
                    set ErrorMessage "THE FILE alpha DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    } 
                if [file exists "$BatchDecompDirInput/anisotropy.bin"] {
                    } else {
                    set config "false"
                    set VarError ""
                    set ErrorMessage "THE FILE anisotropy DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    } 
                if {"$config"=="true"} {
                    set OffsetLig [expr $NligInit - 1]
                    set OffsetCol [expr $NcolInit - 1]
                    set FinalNlig [expr $NligEnd - $NligInit + 1]
                    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

                    PsPScatterPlot "$BatchDecompDirOutput/entropy.bin" "$BatchDecompDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$BatchDecompDirOutput/alpha.bin" "$BatchDecompDirOutput/mask_valid_pixels.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol HAlpha "Entropy" "Alpha (deg)" "H - Alpha Plane" 1 .top230
                    PsPScatterPlot "$BatchDecompDirOutput/entropy.bin" "$BatchDecompDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$BatchDecompDirOutput/anisotropy.bin" "$BatchDecompDirOutput/mask_valid_pixels.bin" float real 0 0 1 $OffsetLig $OffsetCol $FinalNlig $FinalNcol HA "Entropy" "Anisotropy" "H - A Plane" 3 .top230
                    PsPScatterPlot "$BatchDecompDirOutput/anisotropy.bin" "$BatchDecompDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$BatchDecompDirOutput/alpha.bin" "$BatchDecompDirOutput/mask_valid_pixels.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol AAlpha "Anisotropy" "Alpha (deg)" "A - Alpha Plane" 2 .top230

                    set Fonction "H/A/Alpha PLANES & CLASSIFICATION"
                    set Fonction2 "and the associated BMP files"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/data_process_sngl/h_a_alpha_planes_classifier.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$BatchDecompDirOutput\x22 -od \x22$BatchDecompDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hal 1 -anal 1 -han 1 -clm \x22$ColorMapPlanes9\x22 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/data_process_sngl/h_a_alpha_planes_classifier.exe -id \x22$BatchDecompDirOutput\x22 -od \x22$BatchDecompDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hal 1 -anal 1 -han 1 -clm \x22$ColorMapPlanes9\x22 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if [file exists "$BatchDecompDirOutput/H_alpha_class.bin"] { EnviWriteConfigClassif "$BatchDecompDirOutput/H_alpha_class.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes9 9 }
                    if [file exists "$BatchDecompDirOutput/A_alpha_class.bin"] { EnviWriteConfigClassif "$BatchDecompDirOutput/A_alpha_class.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes9 9 }
                    if [file exists "$BatchDecompDirOutput/H_A_class.bin"] { EnviWriteConfigClassif "$BatchDecompDirOutput/H_A_class.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes9 9 }
                    #Update the Nlig/Ncol of the new image after processing
                    set NligInit 1
                    set NcolInit 1
                    set NligEnd $FinalNlig
                    set NcolEnd $FinalNcol
                    }
                }
            } else {
            set VarBatch "bad"
            }
        }
    }
}

if {$VarBatch=="good"} {

if {$BatchWishart=="1"} {
    set BatchWishartDirInput $BatchDirInput
    set BatchWishartDirOutput $BatchOutputDir
    if {$BatchOutputSubDir != ""} {append BatchWishartDirOutput "/$BatchOutputSubDir"}

    if [file isdirectory $BatchWishartDirOutput] {
        set VarWarning "ok"
        } else {
    #####################################################################
    #Create Directory
    set BatchWishartDirOutput [PSPCreateDirectory $BatchWishartDirOutput $BatchOutputDir $BatchProcessFonction]
    #####################################################################       
        }

    if {$VarWarning!="ok"} {
	set VarBatch "bad"
	} else {
        set config "true"
        set WishartEntropyFile "$BatchWishartDirInput/entropy.bin"
        if [file exists $WishartEntropyFile] {
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE entropy DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } 
        set WishartAlphaFile "$BatchWishartDirInput/alpha.bin"
        if [file exists $WishartAlphaFile] {
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE alpha DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } 
        set WishartAnisotropyFile "$BatchWishartDirInput/anisotropy.bin"
        if [file exists $WishartAnisotropyFile] {
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE anisotropy DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } 
        if {"$config"=="true"} {
            set BMPDirInput $BatchWishartDirOutput
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]

            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            set TestVarName(4) "Window Size Classification Row"; set TestVarType(4) "int"; set TestVarValue(4) $BatchNwinWishartL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
            set TestVarName(5) "Pourcentage"; set TestVarType(5) "float"; set TestVarValue(5) $BatchWishartPourcentage; set TestVarMin(5) "0"; set TestVarMax(5) "100"
            set TestVarName(6) "Iteration"; set TestVarType(6) "int"; set TestVarValue(6) $BatchWishartIteration; set TestVarMin(6) "1"; set TestVarMax(6) "100"
            set TestVarName(7) "ColorMap8"; set TestVarType(7) "file"; set TestVarValue(7) $ColorMapWishart8; set TestVarMin(7) ""; set TestVarMax(7) ""
            set TestVarName(8) "ColorMap16"; set TestVarType(8) "file"; set TestVarValue(8) $ColorMapWishart16; set TestVarMin(8) ""; set TestVarMax(8) ""
            set TestVarName(9) "Window Size Classification Col"; set TestVarType(9) "int"; set TestVarValue(9) $BatchNwinWishartC; set TestVarMin(9) "1"; set TestVarMax(9) "1000"
            TestVar 10
            if {$TestVarError == "ok"} {

                set MaskCmd ""
                set MaskFile "$BatchWishartDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

                set Fonction "Creation of all the Binary Data and BMP Files"
                set Fonction2 "of the WISHART - H/A/Alpha Classification"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update

                TextEditorRunTrace "Process The Function Soft/data_process_sngl/wishart_h_a_alpha_classifier.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$BatchWishartDirInput\x22 -od \x22$BatchWishartDirOutput\x22 -iodf $BatchProcessFonction -nwr $BatchNwinWishartL -nwc $BatchNwinWishartC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct $BatchWishartPourcentage -nit $BatchWishartIteration -bmp $BatchBMPWishart -co8 \x22$ColorMapWishart8\x22 -co16 \x22$ColorMapWishart16\x22 -hf \x22$WishartEntropyFile\x22 -af \x22$WishartAnisotropyFile\x22 -alf \x22$WishartAlphaFile\x22 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_sngl/wishart_h_a_alpha_classifier.exe -id \x22$BatchWishartDirInput\x22 -od \x22$BatchWishartDirOutput\x22 -iodf $BatchProcessFonction -nwr $BatchNwinWishartL -nwc $BatchNwinWishartC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct $BatchWishartPourcentage -nit $BatchWishartIteration -bmp $BatchBMPWishart -co8 \x22$ColorMapWishart8\x22 -co16 \x22$ColorMapWishart16\x22 -hf \x22$WishartEntropyFile\x22 -af \x22$WishartAnisotropyFile\x22 -alf \x22$WishartAlphaFile\x22 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                set ClassificationFile "$BatchWishartDirOutput/wishart_H_alpha_class_"
                append ClassificationFile $BatchNwinWishartL; append ClassificationFile "x"; append ClassificationFile $BatchNwinWishartC
                set ClassificationInputFile "$ClassificationFile.bin"
                if [file exists $ClassificationInputFile] {EnviWriteConfigClassif $ClassificationInputFile $FinalNlig $FinalNcol 4 $ColorMapWishart8 8}
                set ClassificationFile "$BatchWishartDirOutput/wishart_H_A_alpha_class_"
                append ClassificationFile $BatchNwinWishartL; append ClassificationFile "x"; append ClassificationFile $BatchNwinWishartC
                set ClassificationInputFile "$ClassificationFile.bin"
                if [file exists $ClassificationInputFile] {EnviWriteConfigClassif $ClassificationInputFile $FinalNlig $FinalNcol 4 $ColorMapWishart16 16}
                #Update the Nlig/Ncol of the new image after processing
                set NligInit 1
                set NcolInit 1
                set NligEnd $FinalNlig
                set NcolEnd $FinalNcol
                } else {
                set VarBatch "bad"
                }
            }
        }
}
}
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/BatchProcess.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel230" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide .top401; Window hide .top402; Window hide .top419
Window hide $widget(Toplevel230); TextEditorRunTrace "Close Window Batch Procedure" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel230" 1
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
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit99 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra83 \
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
Window show .top230

main $argc $argv
