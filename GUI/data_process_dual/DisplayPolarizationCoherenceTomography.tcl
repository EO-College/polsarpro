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
        {{[file join . GUI Images BMPColorBarJet.bmp]} {user image} user {}}

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
    set base .top343
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
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd73 getframe]
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
    namespace eval ::widgets::$site_3_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra72
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
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
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra73
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd77
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.cpd88 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd89 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd80
    namespace eval ::widgets::$site_8_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra79
    namespace eval ::widgets::$site_5_0.but80 {
        array set save {-command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.men75 {
        array set save {-_tooltip 1 -background 1 -image 1 -menu 1 -padx 1 -pady 1 -relief 1}
    }
    namespace eval ::widgets::$site_5_0.men75.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd84 getframe]
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
    namespace eval ::widgets::$site_8_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd89 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd89
    namespace eval ::widgets::$site_8_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd92
    namespace eval ::widgets::$site_8_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd96 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd96
    namespace eval ::widgets::$site_8_0.lab85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.fra80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra80
    namespace eval ::widgets::$site_5_0.ent81 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd79 getframe]
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
            vTclWindow.top343
            PCTcreateBMP
            PCTcloseBMP
            PCTviewBMP
            PCTload_bmp_file
            PCTMouseMotion
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
## Procedure:  PCTcreateBMP

proc ::PCTcreateBMP {} {
global TMPPCTBmp PCTExecFid
global BMPPCTX BMPPCTY PCTSlice BMPPCTZ
global PCTTomoNrow PCTTomoNcol PCTTomoNz
global ConfigFile VarError ErrorMessage Fonction
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$PCTSlice == ""} {
    set ErrorMessage "SELECT FIRST SLICE MODE" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

    DeleteFile $TMPPCTBmp

    if {$PCTSlice == "azimut"} {
        set TestVarName(0) "Azimut Pixel"; set TestVarType(0) "int"; set TestVarValue(0) $BMPPCTX; set TestVarMin(0) "1"; set TestVarMax(0) $PCTTomoNcol
        TestVar 1
        if {$TestVarError == "ok"} {
            set ProgressLine ""
            puts $PCTExecFid "azimut\n"
            flush $PCTExecFid
            fconfigure $PCTExecFid -buffering line
            while {$ProgressLine != "OKazimut"} {
                gets $PCTExecFid ProgressLine
                update
                }
            set ProgressLine ""
            puts $PCTExecFid "$BMPPCTX\n"
            flush $PCTExecFid
            fconfigure $PCTExecFid -buffering line
            while {$ProgressLine != "OKreadcol"} {
                gets $PCTExecFid ProgressLine
                update
                }
            set ProgressLine ""
            while {$ProgressLine != "OKazimutOK"} {
               gets $PCTExecFid ProgressLine
               update
               }
            }
        }

    if {$PCTSlice == "range"} {
        set TestVarName(0) "Range Pixel"; set TestVarType(0) "int"; set TestVarValue(0) $BMPPCTY; set TestVarMin(0) "1"; set TestVarMax(0) $PCTTomoNrow
        TestVar 1
        if {$TestVarError == "ok"} {
            set ProgressLine ""
            puts $PCTExecFid "range\n"
            flush $PCTExecFid
            fconfigure $PCTExecFid -buffering line
            while {$ProgressLine != "OKrange"} {
                gets $PCTExecFid ProgressLine
                update
                }
            set ProgressLine ""
            puts $PCTExecFid "$BMPPCTY\n"
            flush $PCTExecFid
            fconfigure $PCTExecFid -buffering line
            while {$ProgressLine != "OKreadlig"} {
                gets $PCTExecFid ProgressLine
                update
                }
            set ProgressLine ""
            while {$ProgressLine != "OKrangeOK"} {
               gets $PCTExecFid ProgressLine
               update
               }
            }
        }

    if {$PCTSlice == "height"} {
        set TestVarName(0) "Height Pixel"; set TestVarType(0) "int"; set TestVarValue(0) $BMPPCTZ; set TestVarMin(0) "1"; set TestVarMax(0) $PCTTomoNz
        TestVar 1
        if {$TestVarError == "ok"} {
            set ProgressLine ""
            puts $PCTExecFid "height\n"
            flush $PCTExecFid
            fconfigure $PCTExecFid -buffering line
            while {$ProgressLine != "OKheight"} {
                gets $PCTExecFid ProgressLine
                update
                }
            set ProgressLine ""
            puts $PCTExecFid "$BMPPCTZ\n"
            flush $PCTExecFid
            fconfigure $PCTExecFid -buffering line
            while {$ProgressLine != "OKreadz"} {
                gets $PCTExecFid ProgressLine
                update
                }
            set ProgressLine ""
            while {$ProgressLine != "OKheightOK"} {
               gets $PCTExecFid ProgressLine
               update
               }
            }
        }

    WaitUntilCreated $TMPPCTBmp
    if [file exists $TMPPCTBmp] {
        PCTviewBMP
        } else {
        Window hide .top344; TextEditorRunTrace "Close Window View BMP PCT" "b"
        set ErrorMessage "ERROR DURING THE BMP CREATION" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    #Slice
    }
}
#############################################################################
## Procedure:  PCTcloseBMP

proc ::PCTcloseBMP {} {
global PCTBMPImageOpen PCTSourceWidth PCTSourceHeight
global PCTBMPMouseX PCTBMPMouseY PCTZoomBMP
global PCTColorNumber 
global PCTImageSource PCTBMPImage
global PCTZMax PCTZMin PCTZValue OpenDirFile
#BMP PROCESS
global Load_ViewBMPPCT

if {$Load_ViewBMPPCT == 1} {

if {$OpenDirFile == 0} {

if { $PCTBMPImageOpen == 1 } {
    set PCTSourceWidth ""; set PCTSourceHeight ""
    set PCTBMPMouseX ""; set PCTBMPMouseY ""
    set PCTZMax ""; set PCTZMin ""; set PCTZValue ""
    set PCTZoomBMP "0:0"; set PCTBMPImageOpen "0"
    image delete PCTImageSource
    image delete PCTBMPImage
    Window hide .top344; TextEditorRunTrace "Close Window View BMP PCT" "b"
    }
}
}
}
#############################################################################
## Procedure:  PCTviewBMP

proc ::PCTviewBMP {} {
global PCTBMPImageOpen TMPPCTBmp PCTSourceWidth PCTSourceHeight 
global PCTBMPWidth PCTBMPHeight
global PCTBMPImage PCTImageSource 
global PCTColorNumber PCTColorNumberUtil 
global PCTZMax PCTZMin PCTZValue PCTBMPMouseX PCTBMPMouseY
global WidgetPosition

package require Img
#BMP PROCESS
global Load_ViewBMPPCT

if { $Load_ViewBMPPCT == 1 } {

if { $PCTBMPImageOpen == 1 } {
    image delete PCTImageSource
    image delete PCTBMPImage
    }
set PCTSourceWidth ""; set PCTSourceHeight ""
set PCTBMPMouseX ""; set PCTBMPMouseY ""
#set PCTZMax "+ 1.0"
#set PCTZMin "- 1.0"
set PCTZValue ""
set PCTZoomBMP "0:0"
set PCTColorNumberUtil $PCTColorNumber
set PCTBMPImageOpen "1"

PCTload_bmp_file $TMPPCTBmp
   
#set xwindow [winfo x .top343]; set ywindow [winfo y .top343]
#set geometrie "200x200+"; append geometrie $xwindow; append geometrie "+"; append geometrie $ywindow
#wm geometry .top344 $geometrie; update
.top344.cpd79.cpd80 configure -width $PCTBMPWidth -height $PCTBMPHeight
.top344.cpd79.cpd80 create image 0 0 -anchor nw -image PCTBMPImage

###############################################################
set geoscreenwidth [winfo width .top2]
set geoscreenheight [winfo height .top2]
set geoscreenwidths2 [expr $geoscreenwidth / 2]
set geoscreenheights2 [expr $geoscreenheight / 2]

set tx [winfo rootx .top2]
set ty [winfo rooty .top2]
set x [winfo x .top2]
set y [winfo y .top2]
set geoscreenborderw [expr {$tx-$x}]
set geoscreentitleh [expr {$ty-$y}]

set geomenuwidth [winfo width .top343]
set geomenuheight [winfo height .top343]
set geomenuX [winfo x .top343]
set geomenuY [winfo y .top343]

set geowidgetwidth [winfo width .top344]
set geowidgetheight [winfo height .top344]
set geowidgetwidths2 [expr $geowidgetwidth / 2]
set geowidgetheights2 [expr $geowidgetheight / 2]

set positionheight $geomenuY

#Positionnement a Droite
set positionwidth [expr $geomenuX + $geomenuwidth]; set positionwidth [expr $positionwidth + (3 * $geoscreenborderw)];
set limitwidth [expr $positionwidth + $geowidgetwidth]
set config "true"
if {$limitwidth > $geoscreenwidth} {set config "false"}

if {$config == "false"} {
    #Positionnement a Gauche
    set positionwidth [expr $geomenuX - $geowidgetwidth]; set positionwidth [expr $positionwidth - (3 * $geoscreenborderw)];
    set limitwidth $positionwidth
    set config "true"
    set limit [expr $geoscreenborderw + $geoscreenborderw]
    if {$limitwidth < $limit} {set config "false"}

    if {$config == "false"} {
        #Positionnement au Centre
        set positionwidth $geoscreenwidths2; set positionwidth [expr $positionwidth - $geowidgetwidths2]
        set positionheight $geoscreenheights2; set positionheight [expr $positionheight - $geowidgetheights2]
        }  
    }  

set geometrie $geowidgetwidth; append geometrie "x"; append geometrie $geowidgetheight; append geometrie "+";
append geometrie $positionwidth; append geometrie "+"; append geometrie $positionheight

wm geometry .top344 $geometrie; update

###############################################################
catch {wm geometry .top344 {}} 
Window show .top344; TextEditorRunTrace "Open Window View BMP PCT" "b"
}
}
#############################################################################
## Procedure:  PCTload_bmp_file

proc ::PCTload_bmp_file {bmpfile} {
global PCTSourceWidth PCTSourceHeight 
global PCTBMPWidth PCTBMPHeight PCTWidthBMP PCTHeightBMP PCTZoomBMP
global PCTImageSource PCTBMPImage

image create photo PCTImageSource -file $bmpfile
set PCTSourceWidth [image width PCTImageSource]
set PCTSourceHeight [image height PCTImageSource]

image create photo PCTBMPImage; PCTBMPImage blank

set PCTWidthBMP "500"
set PCTHeightBMP "500"

#show image
set PCTZoomBMP "0:0"
set subsample 0
if {$PCTSourceWidth > $PCTWidthBMP} {set subsample 1}
if {$PCTSourceHeight > $PCTHeightBMP} {set subsample 1}

set PCTBMPSample 1
if {$subsample == 0} {
    set PCTZoomBMP "1:$PCTBMPSample"
    set PCTBMPWidth $PCTSourceWidth
    set PCTBMPHeight $PCTSourceHeight
    } else {
    if {$PCTSourceWidth >= $PCTSourceHeight} {
        while {[expr round($PCTSourceWidth / $PCTBMPSample)] > $PCTWidthBMP} {incr PCTBMPSample}
        } else {
        while {[expr round($PCTSourceHeight / $PCTBMPSample)] > $PCTHeightBMP} {incr PCTBMPSample}
        } 
    set PCTZoomBMP "1:$PCTBMPSample"
    set PCTBMPWidth [expr round($PCTSourceWidth / $PCTBMPSample)]
    set PCTBMPHeight [expr round($PCTSourceHeight / $PCTBMPSample)]
    } 

PCTBMPImage copy PCTImageSource -from 0 0 $PCTSourceWidth $PCTSourceHeight -subsample $PCTBMPSample $PCTBMPSample
}
#############################################################################
## Procedure:  PCTMouseMotion

proc ::PCTMouseMotion {nx ny} {
global PCTColorNumber PCTColorNumberUtil
global PCTImageSource PCTBMPMouseX PCTBMPMouseY
global PCTRedPalette PCTGreenPalette PCTBluePalette
global PCTZMax PCTZMin PCTZValue
global PCTZoomBMP

set Num1 ""
set Num2 ""
set Num1 [string index $PCTZoomBMP 0]
set Num2 [string index $PCTZoomBMP 1]
if {$Num2 == ":"} {
    set Num $Num1
    set Den1 ""
    set Den2 ""
    set Den1 [string index $PCTZoomBMP 2]
    set Den2 [string index $PCTZoomBMP 3]
    if {$Den2 == ""} {
        set Den $Den1
        } else {
        set Den [expr 10*$Den1 + $Den2]
        }
    } else {
    set Num [expr 10*$Num1 + $Num2]
    set Den1 ""
    set Den2 ""
    set Den1 [string index $PCTZoomBMP 3]
    set Den2 [string index $PCTZoomBMP 4]
    if {$Den2 == ""} {
        set Den $Den1
        } else {
        set Den [expr 10*$Den1 + $Den2]
        }
    }

if {$Den >= $Num} {
    set PCTBMPSample $Den
    set PCTBMPMouseX [expr round($nx*$PCTBMPSample)]
    set PCTBMPMouseY [expr round($ny*$PCTBMPSample)]
    }
if {$Den < $Num} {
    set PCTBMPZoom $Num
    set PCTBMPMouseX [expr round($nx/$PCTBMPZoom)]
    set PCTBMPMouseY [expr round($ny/$PCTBMPZoom)]
    }

set PCTIndPal 0
set PCTpixcolor [PCTImageSource get $PCTBMPMouseX $PCTBMPMouseY]
set PCTcouleur [format #%02x%02x%02x [lindex $PCTpixcolor 0] [lindex $PCTpixcolor 1] [lindex $PCTpixcolor 2]]
for {set i 1} {$i <= $PCTColorNumber} {incr i} {
    set PCTcolor [format #%02x%02x%02x $PCTRedPalette($i) $PCTGreenPalette($i) $PCTBluePalette($i)]
    if {$PCTcouleur == $PCTcolor } {set PCTIndPal $i}
    }

if {$PCTIndPal != "0"} {
    set config "true"
    if {$PCTIndPal == "1" } { set config "false" }
    if {$PCTIndPal == "2" } { set config "false" }
    if {$config == "true" } {
        set Value [expr $PCTZMin + ($PCTIndPal-1)*($PCTZMax-$PCTZMin) / ($PCTColorNumberUtil-1)]
        set PCTZValue [format %5.2f $Value]
        } else {
        set PCTZValue "-----"
        }
    } else {
    set PCTZValue "-----"
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
    wm geometry $top 200x200+150+150; update
    wm maxsize $top 1924 1062
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

proc vTclWindow.top343 {base} {
    if {$base == ""} {
        set base .top343
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
    wm geometry $top 500x370+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Display Polarization Coherence Tomography"
    vTcl:DefineAlias "$top" "Toplevel343" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame3" vTcl:WidgetProc "Toplevel343" 1
    set site_3_0 $top.fra71
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel343" 1
    set site_4_0 $site_3_0.cpd78
    canvas $site_4_0.can73 \
        -borderwidth 2 -closeenough 1.0 -height 200 -relief ridge -width 200 
    vTcl:DefineAlias "$site_4_0.can73" "CANVASLENSPCT" vTcl:WidgetProc "Toplevel343" 1
    bind $site_4_0.can73 <Button-1> {
        MouseButtonDownLens %x %y
    }
    TitleFrame $site_4_0.cpd80 \
        -ipad 2 -text {Mouse Position} 
    vTcl:DefineAlias "$site_4_0.cpd80" "TitleFrame3" vTcl:WidgetProc "Toplevel343" 1
    bind $site_4_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd80 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame29" vTcl:WidgetProc "Toplevel343" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame30" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label27" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseX -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry52" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame31" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label28" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPMouseY -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry53" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra85 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_4_0.cpd73 \
        -ipad 2 -text {3-D Tomo Size} 
    vTcl:DefineAlias "$site_4_0.cpd73" "TitleFrame4" vTcl:WidgetProc "Toplevel343" 1
    bind $site_4_0.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd73 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame48" vTcl:WidgetProc "Toplevel343" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame49" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text R -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label33" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTTomoNrow -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry60" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame50" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text C -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label34" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTTomoNcol -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry61" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame51" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab76 \
        -relief groove -text Z -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label35" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTTomoNz -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry62" vTcl:WidgetProc "Toplevel343" 1
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
    pack $site_4_0.can73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    frame $site_3_0.fra72 \
        -borderwidth 2 -height 60 -width 125 
    vTcl:DefineAlias "$site_3_0.fra72" "Frame4" vTcl:WidgetProc "Toplevel343" 1
    set site_4_0 $site_3_0.fra72
    TitleFrame $site_4_0.cpd74 \
        -ipad 2 -text {Selected Pixel} 
    vTcl:DefineAlias "$site_4_0.cpd74" "TitleFrame5" vTcl:WidgetProc "Toplevel343" 1
    bind $site_4_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame52" vTcl:WidgetProc "Toplevel343" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame53" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label36" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPPCTX -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry63" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame54" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label37" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPPCTY -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry64" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra85 \
        -in $site_7_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_4_0.cpd77 \
        -ipad 2 -text {Slice Along} 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame6" vTcl:WidgetProc "Toplevel343" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    frame $site_6_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra73" "Frame2" vTcl:WidgetProc "Toplevel343" 1
    set site_7_0 $site_6_0.fra73
    radiobutton $site_7_0.cpd75 \
        \
        -command [list vTcl:DoCmdOption $site_7_0.cpd75 {global PCTRow PCTCol
global BMPPCTinc BMPPCTind BMPPCTval
global PCTRowMin PCTRowMax PCTColMin PCTColMax
global PCTTomoNrow PCTTomoNcol PCTTomoNz 
global PCTPixAz PCTPixRg PCTPixZ
global BMPPCTX BMPPCTY BMPPCTZ

set config "true"
if {$BMPPCTX == ""} { set config "false" }
if {$BMPPCTY == ""} { set config "false" }

set PCTRow "Height"
set PCTCol "Range"
set BMPPCTinc "5";
set PCTRowMin [format %5.2f $PCTPixZ]; set PCTRowMax [format %5.2f [expr $PCTTomoNz * $PCTPixZ] ]; 
set PCTColMin [format %5.2f $PCTPixRg]; set PCTColMax [format %5.2f [expr $PCTTomoNcol * $PCTPixRg] ]; 
if {$config == "true"} {
    set BMPPCTind $BMPPCTY
    set BMPPCTval [expr $BMPPCTind * $PCTPixAz]
    PCTcreateBMP
    }}] \
        -text {Col ( x )} -value range -variable PCTSlice 
    vTcl:DefineAlias "$site_7_0.cpd75" "Radiobutton344" vTcl:WidgetProc "Toplevel343" 1
    radiobutton $site_7_0.cpd74 \
        \
        -command [list vTcl:DoCmdOption $site_7_0.cpd74 {global PCTRow PCTCol
global BMPPCTinc BMPPCTind BMPPCTval
global PCTRowMin PCTRowMax PCTColMin PCTColMax
global PCTTomoNrow PCTTomoNcol PCTTomoNz 
global PCTPixAz PCTPixRg PCTPixZ
global BMPPCTX BMPPCTY BMPPCTZ

set config "true"
if {$BMPPCTX == ""} { set config "false" }
if {$BMPPCTY == ""} { set config "false" }

set PCTRow "Height"
set PCTCol "Azimut"
set BMPPCTinc "5";
set PCTRowMin [format %5.2f $PCTPixZ]; set PCTRowMax [format %5.2f [expr $PCTTomoNz * $PCTPixZ] ]; 
set PCTColMin [format %5.2f $PCTPixAz]; set PCTColMax [format %5.2f [expr $PCTTomoNcol * $PCTPixAz] ]; 
if {$config == "true"} {
    set BMPPCTind $BMPPCTX
    set BMPPCTval [expr $BMPPCTind * $PCTPixRg]
    PCTcreateBMP
    }}] \
        -text {Row ( y )} -value azimut -variable PCTSlice 
    vTcl:DefineAlias "$site_7_0.cpd74" "Radiobutton343" vTcl:WidgetProc "Toplevel343" 1
    radiobutton $site_7_0.cpd76 \
        \
        -command [list vTcl:DoCmdOption $site_7_0.cpd76 {global PCTRow PCTCol
global BMPPCTinc BMPPCTind BMPPCTval BMPPCTZ
global PCTRowMin PCTRowMax PCTColMin PCTColMax
global PCTTomoNrow PCTTomoNcol PCTTomoNz 
global PCTPixAz PCTPixRg PCTPixZ

set PCTRow "Azimut"
set PCTCol "Range"
set BMPPCTinc "5"; set BMPPCTZ "1"; set BMPPCTind "1"
set BMPPCTval [expr $BMPPCTind * $PCTPixZ]
set PCTRowMin [format %5.2f $PCTPixAz]; set PCTRowMax [format %5.2f [expr $PCTTomoNrow * $PCTPixAz] ]; 
set PCTColMin [format %5.2f $PCTPixRg]; set PCTColMax [format %5.2f [expr $PCTTomoNcol * $PCTPixRg] ]; 
PCTcreateBMP}] \
        -text {Height ( z )} -value height -variable PCTSlice 
    vTcl:DefineAlias "$site_7_0.cpd76" "Radiobutton345" vTcl:WidgetProc "Toplevel343" 1
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.cpd77 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd77" "Frame61" vTcl:WidgetProc "Toplevel343" 1
    set site_7_0 $site_6_0.cpd77
    frame $site_7_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame62" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.cpd79
    button $site_8_0.cpd88 \
        \
        -command {global BMPPCTind BMPPCTinc BMPPCTval
global PCTTomoNz PCTTomoNrow PCTTomoNcol
global PCTPixZ PCTPixAz PCTPixRg
global BMPPCTX BMPPCTY BMPPCTZ

if {$PCTSlice == "azimut"} {
    set BMPPCTind $BMPPCTX
    if {$BMPPCTind == $PCTTomoNcol} {
        set BMPPCTind "1"
        } else {
        set BMPPCTind [expr $BMPPCTind + $BMPPCTinc]
        if {$BMPPCTind > $PCTTomoNcol} {set BMPPCTind $PCTTomoNcol}
        }
    set BMPPCTval [expr $BMPPCTind * $PCTPixRg]
    set BMPPCTX $BMPPCTind
    }
if {$PCTSlice == "range"} {
    set BMPPCTind $BMPPCTY
    if {$BMPPCTind == $PCTTomoNrow} {
        set BMPPCTind "1"
        } else {
        set BMPPCTind [expr $BMPPCTind + $BMPPCTinc]
        if {$BMPPCTind > $PCTTomoNrow} {set BMPPCTind $PCTTomoNrow}
        }
    set BMPPCTval [expr $BMPPCTind * $PCTPixAz]
    set BMPPCTY $BMPPCTind
    }
if {$PCTSlice == "height"} {
    set BMPPCTind $BMPPCTZ
    if {$BMPPCTind == $PCTTomoNz} {
        set BMPPCTind "1"
        } else {
        set BMPPCTind [expr $BMPPCTind + $BMPPCTinc]
        if {$BMPPCTind > $PCTTomoNz} {set BMPPCTind $PCTTomoNz}
        }
    set BMPPCTval [expr $BMPPCTind * $PCTPixZ]
    set BMPPCTZ $BMPPCTind
    }

PCTcreateBMP} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_8_0.cpd88" "Button345" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPPCTinc -width 3 
    vTcl:DefineAlias "$site_8_0.cpd78" "Entry346" vTcl:WidgetProc "Toplevel343" 1
    button $site_8_0.cpd89 \
        \
        -command {global BMPPCTind BMPPCTinc BMPPCTval
global PCTTomoNz PCTTomoNrow PCTTomoNcol
global PCTPixZ PCTPixAz PCTPixRg
global BMPPCTX BMPPCTY BMPPCTZ

if {$PCTSlice == "azimut"} {
    set BMPPCTind $BMPPCTX
    if {$BMPPCTind == "1"} {
        set BMPPCTind $PCTTomoNcol
        } else {
        set BMPPCTind [expr $BMPPCTind - $BMPPCTinc]
        if {$BMPPCTind < "1"} {set BMPPCTind "1"}
        }
    set BMPPCTval [expr $BMPPCTind * $PCTPixRg]
    set BMPPCTX $BMPPCTind
    }
if {$PCTSlice == "range"} {
    set BMPPCTind $BMPPCTY
    if {$BMPPCTind == "1"} {
        set BMPPCTind $PCTTomoNrow
        } else {
        set BMPPCTind [expr $BMPPCTind - $BMPPCTinc]
        if {$BMPPCTind < "1"} {set BMPPCTind "1"}
        }
    set BMPPCTval [expr $BMPPCTind * $PCTPixAz]
    set BMPPCTY $BMPPCTind
    }
if {$PCTSlice == "height"} {
    set BMPPCTind $BMPPCTZ
    if {$BMPPCTind == "1"} {
        set BMPPCTind $PCTTomoNz
        } else {
        set BMPPCTind [expr $BMPPCTind - $BMPPCTinc]
        if {$BMPPCTind < "1"} {set BMPPCTind "1"}
        }
    set BMPPCTval [expr $BMPPCTind * $PCTPixZ]
    set BMPPCTZ $BMPPCTind
    }

PCTcreateBMP} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd89" "Button346" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.cpd88 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.cpd78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.cpd89 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    frame $site_7_0.cpd80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd80" "Frame63" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.cpd80
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable BMPPCTval -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry347" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable BMPPCTind -width 6 
    vTcl:DefineAlias "$site_8_0.cpd78" "Entry348" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 6 -side right 
    pack $site_8_0.cpd78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_4_0.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra79" "Frame5" vTcl:WidgetProc "Toplevel343" 1
    set site_5_0 $site_4_0.fra79
    button $site_5_0.but80 \
        \
        -command {global BMPLens LineXLensInit LineYLensInit LineXLens LineYLens plot2 line_color

if {$line_color == "white"} {
    set line_color "black"
    } else {
    set line_color "white"
    }

set b .top343.fra71.fra72.fra79.but80
$b configure -background $line_color -foreground $line_color

$widget(CANVASLENSPCT) dtag LineXLensInit
$widget(CANVASLENSPCT) dtag LineYLensInit
$widget(CANVASLENSPCT) create image 0 0 -anchor nw -image BMPLens
set LineXLensInit {0 0}
set LineYLensInit {0 0}
set LineXLens [$widget(CANVASLENSPCT) create line 0 0 0 $SizeLens -fill $line_color -width 2]
set LineYLens [$widget(CANVASLENSPCT) create line 0 0 $SizeLens 0 -fill $line_color -width 2]
$widget(CANVASLENSPCT) addtag LineXLensInit withtag $LineXLens
$widget(CANVASLENSPCT) addtag LineYLensInit withtag $LineYLens
set plot2(lastX) 0
set plot2(lastY) 0} \
        -pady 0 -relief ridge -text {   } 
    vTcl:DefineAlias "$site_5_0.but80" "Button1" vTcl:WidgetProc "Toplevel343" 1
    button $site_5_0.but71 \
        -background #ffff00 -command PCTcloseBMP -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_5_0.but71" "Button343_5" vTcl:WidgetProc "Toplevel343" 1
    bindtags $site_5_0.but71 "$site_5_0.but71 Button $top all _vTclBalloon"
    bind $site_5_0.but71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Close BMP Image}
    }
    menubutton $site_5_0.men75 \
        -background #ffff00 \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -menu "$site_5_0.men75.m" -padx 5 -pady 4 -relief raised 
    vTcl:DefineAlias "$site_5_0.men75" "Menubutton1" vTcl:WidgetProc "Toplevel343" 1
    bindtags $site_5_0.men75 "$site_5_0.men75 Menubutton $top all _vTclBalloon"
    bind $site_5_0.men75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save BMP Image}
    }
    menu $site_5_0.men75.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_5_0.men75.m add command \
        \
        -command {global FileName PCTDirOutput TMPPCTBmp
global PCTSlice PCTBMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

if {$PCTBMPImageOpen == 1} {

    set Types {
        {{BMP Files}        {.bmp}        }
        }

    if {$PCTSlice == "azimut" } { set BMPFileOutput "PCTsliceAzimut.bmp" }
    if {$PCTSlice == "range" } { set BMPFileOutput "PCTsliceRange.bmp" }
    if {$PCTSlice == "height" } { set BMPFileOutput "PCTsliceHeight.bmp" }
    set FileName ""
    set FileName [tk_getSaveFile -initialdir $PCTDirOutput -filetypes $Types -title "BMP OUTPUT FILE" -defaultextension .bmp -initialfile $BMPFileOutput]
    if {"$FileName" != ""} { CopyFile $TMPPCTBmp $FileName }        
    }
}} \
        -label {BMP Format} 
    $site_5_0.men75.m add separator \
        
    $site_5_0.men75.m add command \
        \
        -command {global FileName PCTDirOutput PCTImageSource
global PCTSlice PCTBMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

if {$PCTBMPImageOpen == 1} {

    set Types {
        {{GIF Files}        {.gif}        }
        }

    if {$PCTSlice == "azimut" } { set BMPFileOutput "PCTsliceAzimut.gif" }
    if {$PCTSlice == "range" } { set BMPFileOutput "PCTsliceRange.gif" }
    if {$PCTSlice == "height" } { set BMPFileOutput "PCTsliceHeight.gif" }
    set FileName ""
    set FileName [tk_getSaveFile -initialdir $PCTDirOutput -filetypes $Types -title "GIF OUTPUT FILE" -defaultextension .gif -initialfile $BMPFileOutput]
    if {"$FileName" != ""} { PCTImageSource write $FileName -format gif }        
    }
}} \
        -label {GIF Format} 
    $site_5_0.men75.m add separator \
        
    $site_5_0.men75.m add command \
        \
        -command {global FileName PCTDirOutput PCTImageSource
global PCTSlice PCTBMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

if {$PCTBMPImageOpen == 1} {

    set Types {
        {{JPG Files}        {.jpg}        }
        }

    if {$PCTSlice == "azimut" } { set BMPFileOutput "PCTsliceAzimut.jpg" }
    if {$PCTSlice == "range" } { set BMPFileOutput "PCTsliceRange.jpg" }
    if {$PCTSlice == "height" } { set BMPFileOutput "PCTsliceHeight.jpg" }
    set FileName ""
    set FileName [tk_getSaveFile -initialdir $PCTDirOutput -filetypes $Types -title "JPG OUTPUT FILE" -defaultextension .jpg -initialfile $BMPFileOutput]
    if {"$FileName" != ""} { PCTImageSource write $FileName -format jpeg }        
    }
}} \
        -label {JPG Format} 
    $site_5_0.men75.m add separator \
        
    $site_5_0.men75.m add command \
        \
        -command {global FileName PCTDirOutput PCTImageSource
global PCTSlice PCTBMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

if {$PCTBMPImageOpen == 1} {

    set Types {
        {{TIF Files}        {.tif}        }
        }

    if {$PCTSlice == "azimut" } { set BMPFileOutput "PCTsliceAzimut.tif" }
    if {$PCTSlice == "range" } { set BMPFileOutput "PCTsliceRange.tif" }
    if {$PCTSlice == "height" } { set BMPFileOutput "PCTsliceHeight.tif" }
    set FileName ""
    set FileName [tk_getSaveFile -initialdir $PCTDirOutput -filetypes $Types -title "TIF OUTPUT FILE" -defaultextension .tif -initialfile $BMPFileOutput]
    if {"$FileName" != ""} { PCTImageSource write $FileName -format tiff }        
    }
}} \
        -label {TIF Format} 
    pack $site_5_0.but80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.men75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -ipadx 1 -ipady 1 \
        -side left 
    TitleFrame $site_4_0.cpd84 \
        -ipad 2 -text Representation 
    vTcl:DefineAlias "$site_4_0.cpd84" "TitleFrame8" vTcl:WidgetProc "Toplevel343" 1
    bind $site_4_0.cpd84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd84 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame39" vTcl:WidgetProc "Toplevel343" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame40" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab85 \
        -text {BMP PCT Row : } 
    vTcl:DefineAlias "$site_8_0.lab85" "Label2" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab85 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd89 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd89" "Frame41" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.cpd89
    label $site_8_0.lab85 \
        -text {BMP PCT Col : } 
    vTcl:DefineAlias "$site_8_0.lab85" "Label3" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab85 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.fra84 \
        -in $site_7_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_7_0.cpd89 \
        -in $site_7_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    frame $site_6_0.cpd72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame42" vTcl:WidgetProc "Toplevel343" 1
    set site_7_0 $site_6_0.cpd72
    frame $site_7_0.cpd92 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd92" "Frame43" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.cpd92
    label $site_8_0.lab85 \
        -text {Min } 
    vTcl:DefineAlias "$site_8_0.lab85" "Label4" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTRowMax -width 6 
    vTcl:DefineAlias "$site_8_0.cpd88" "Entry5" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTRowMin -width 6 
    vTcl:DefineAlias "$site_8_0.cpd95" "Entry6" vTcl:WidgetProc "Toplevel343" 1
    label $site_8_0.cpd94 \
        -text {  Max } 
    vTcl:DefineAlias "$site_8_0.cpd94" "Label5" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab85 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd88 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd95 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd94 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd96 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd96" "Frame44" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.cpd96
    label $site_8_0.lab85 \
        -text {Min } 
    vTcl:DefineAlias "$site_8_0.lab85" "Label6" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTColMax -width 6 
    vTcl:DefineAlias "$site_8_0.cpd88" "Entry7" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTColMin -width 6 
    vTcl:DefineAlias "$site_8_0.cpd95" "Entry8" vTcl:WidgetProc "Toplevel343" 1
    label $site_8_0.cpd94 \
        -text {  Max } 
    vTcl:DefineAlias "$site_8_0.cpd94" "Label7" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab85 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd88 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd95 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.cpd94 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_7_0.cpd96 \
        -in $site_7_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra80" "Frame1" vTcl:WidgetProc "Toplevel343" 1
    set site_5_0 $site_4_0.fra80
    entry $site_5_0.ent81 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTZMin -width 5 
    vTcl:DefineAlias "$site_5_0.ent81" "Entry1" vTcl:WidgetProc "Toplevel343" 1
    entry $site_5_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTZMax -width 5 
    vTcl:DefineAlias "$site_5_0.cpd82" "Entry2" vTcl:WidgetProc "Toplevel343" 1
    label $site_5_0.lab83 \
        \
        -image [vTcl:image:get_image [file join . GUI Images BMPColorBarJet.bmp]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$site_5_0.lab83" "Label1" vTcl:WidgetProc "Toplevel343" 1
    pack $site_5_0.ent81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd79 \
        -ipad 2 -text {Tomogram Mouse Position} 
    vTcl:DefineAlias "$site_4_0.cpd79" "TitleFrame7" vTcl:WidgetProc "Toplevel343" 1
    bind $site_4_0.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd79 getframe]
    frame $site_6_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame57" vTcl:WidgetProc "Toplevel343" 1
    set site_7_0 $site_6_0.cpd75
    frame $site_7_0.fra84 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra84" "Frame58" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra84
    label $site_8_0.lab76 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label39" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTBMPMouseX -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry68" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.fra85 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra85" "Frame59" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.fra85
    label $site_8_0.lab76 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_8_0.lab76" "Label40" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTBMPMouseY -width 4 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry69" vTcl:WidgetProc "Toplevel343" 1
    pack $site_8_0.lab76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent78 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side right 
    frame $site_7_0.cpd75 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame60" vTcl:WidgetProc "Toplevel343" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab76 \
        -relief groove -text Val -width 4 
    vTcl:DefineAlias "$site_8_0.lab76" "Label41" vTcl:WidgetProc "Toplevel343" 1
    entry $site_8_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PCTZValue -width 6 
    vTcl:DefineAlias "$site_8_0.ent78" "Entry70" vTcl:WidgetProc "Toplevel343" 1
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
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra79 \
        -in $site_4_0 -anchor center -expand 0 -fill x -pady 6 -side bottom 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra80 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.fra72 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side right 
    frame $top.fra92 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel343" 1
    set site_3_0 $top.fra92
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DisplayPolarizationCoherenceTomography.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel343" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile PCTExecFid

if {$OpenDirFile == 0} {

set ErrorCatch "0"
set ProgressLine ""
set ErrorCatch [catch {puts $PCTExecFid "exit\n"}]
if { $ErrorCatch == "0" } {
    puts $PCTExecFid "exit\n"
    flush $PCTExecFid
    fconfigure $PCTExecFid -buffering line
    while {$ProgressLine != "OKexit"} {
        gets $PCTExecFid ProgressLine
        update
        }
    catch "close $PCTExecFid"
    }
set PCTExecFid ""

ClosePSPViewer
PCTcloseBMP
Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
Window hide $widget(Toplevel343); TextEditorRunTrace "Close Window Display PCT" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button343_0" vTcl:WidgetProc "Toplevel343" 1
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
        -in $top -anchor center -expand 1 -fill both -side top 
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
Window show .top343

main $argc $argv
