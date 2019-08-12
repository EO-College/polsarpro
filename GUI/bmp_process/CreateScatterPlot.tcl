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
        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
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
    set base .top407
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra67 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd89 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra77
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd79
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.cpd102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd102
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-_tooltip 1 -background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra67
    namespace eval ::widgets::$site_7_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd70
    namespace eval ::widgets::$site_7_0.ent71 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd74
    namespace eval ::widgets::$site_7_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.ent71 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd73
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd89 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra77
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd79
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.cpd102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd102
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-_tooltip 1 -background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra67
    namespace eval ::widgets::$site_7_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd70
    namespace eval ::widgets::$site_7_0.ent71 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd74
    namespace eval ::widgets::$site_7_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.ent71 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.tit75 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.tit75 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd77 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd78 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra38 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra38
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but66 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
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
            vTclWindow.top407
            PlotScatterPlot
            PlotScatterPlotThumb
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
## Procedure:  PlotScatterPlot

proc ::PlotScatterPlot {} {
global GnuplotPipeFid GnuplotPipeScatterPlot GnuXview GnuZview  
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPGnuPlotTk1 TMPGnuPlot1Tk GnuOutputFormat GnuOutputFile
global TMPScatterPlotFileOutputXYbin TMPScatterPlotFileOutputXYtxt
global ScatterPlotLabelX ScatterPlotLabelY ScatterPlotTitle
global PlatForm WinDir GnuPlotPath WGNUPLOTINIDir

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk

WaitUntilCreated $TMPScatterPlotFileOutputXYtxt
if [file exists $TMPScatterPlotFileOutputXYtxt] {
    if {$GnuplotPipeScatterPlot == ""} {
      if {$PlatForm == "windows"} {
        set Wgnuplot_Config "$WGNUPLOTINIDir/WGNUPLOT.INI"
        DeleteFile $Wgnuplot_Config
        set f [open $Wgnuplot_Config w+]
        puts $f "\x5BWGNUPLOT\x5D"
        puts $f "TextOrigin=0 0"
        puts $f "TextSize=640 150"
        puts $f "TextFont=Terminal,8"
        puts $f "GraphOrigin=0 0"
        puts $f "GraphSize=1 1"
        puts $f "Graph=Arial,8"
        puts $f "GraphColor=1"
        puts $f "GraphToTop=1"
        puts $f "GraphBackground=255 255 255"
        puts $f "Border=0 0 0 0 0"
        puts $f "Axis=192 192 192 2 2"
        puts $f "Line1=255 255 255 0 0"
        puts $f "Line2=255 255 255 0 1"
        puts $f "Line3=255 0 0 0 2"
        puts $f "Line4=255 0 255 0 3"
        puts $f "Line5=0 0 128 0 4"
        close $f
        }
        set GnuplotPipeFid [ open "| $GnuPlotPath" r+]
    	set GnuplotPipeScatterPlot $GnuplotPipeFid
	}

    #PlotScatterPlotThumb
    
    set GnuOutputFile $TMPGnuPlotTk1
    puts $GnuplotPipeScatterPlot "reset"; flush $GnuplotPipeScatterPlot 
    puts $GnuplotPipeScatterPlot "clear"; flush $GnuplotPipeScatterPlot 
    puts $GnuplotPipeScatterPlot "set terminal gif medium size 640,480 font 'arial'"; flush $GnuplotPipeScatterPlot 
    puts $GnuplotPipeScatterPlot "set output \x22$GnuOutputFile\x22"; flush $GnuplotPipeScatterPlot 
    
    if [file exists $TMPScatterPlotFileOutputXYtxt ] {
        set f [open $TMPScatterPlotFileOutputXYtxt r]
        gets $f tmp; gets $f xmin; gets $f xmax
        gets $f tmp; gets $f ymin; gets $f ymax
        gets $f zmin; gets $f zmax
        gets $f min; gets $f max
        gets $f Nctr; gets $f NctrStart; gets $f NctrIncr
        close $f
        }

    if [file exists $TMPScatterPlotFileOutputXYbin ] {  
        puts $GnuplotPipeScatterPlot "set colorbox"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set autoscale xfix"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set autoscale yfix"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set palette defined (0 '#000090',1 '#000FFF',2 '#0090FF',3 '#0FFFEE',4 '#90FF70',5 '#FFEE00',6 '#FF7000',7 '#EE0000',8 '#7F0000')"; flush $GnuplotPipeScatterPlot 
        set cbrg "\x5B$zmin:$zmax\x5D";puts $GnuplotPipeScatterPlot "set cbrange $cbrg"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set linewidth 3"; flush $GnuplotPipeScatterPlot 

        set xlbl $ScatterPlotLabelX
        set ylbl $ScatterPlotLabelY
        set zlbl ""
        puts $GnuplotPipeScatterPlot "set xlabel \x22$xlbl\x22"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set ylabel \x22$ylbl\x22"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set zlabel \x22$zlbl\x22"; flush $GnuplotPipeScatterPlot 
        set titre "$ScatterPlotTitle - (Scale: 10^n)"
        puts $GnuplotPipeScatterPlot "set title \x22$titre\x22 textcolor lt 3"; flush $GnuplotPipeScatterPlot 

        set minmaxval "Max = $max $zlbl"
        puts $GnuplotPipeScatterPlot "set label \x22$minmaxval\x22 at screen 0.05, screen 0.020 textcolor lt 1"; flush $GnuplotPipeScatterPlot 
        set minmaxval "Min = $min $zlbl"
        puts $GnuplotPipeScatterPlot "set label \x22$minmaxval\x22 at screen 0.65, screen 0.020 textcolor lt 1"; flush $GnuplotPipeScatterPlot 

        set xrg "\x5B$xmin:$xmax\x5D"; puts $GnuplotPipeScatterPlot "set xrange $xrg noreverse nowriteback"; flush $GnuplotPipeScatterPlot 
        set yrg "\x5B$ymin:$ymax\x5D"; puts $GnuplotPipeScatterPlot "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeScatterPlot 
        set zrg "\x5B$zmin:$zmax\x5D"; puts $GnuplotPipeScatterPlot "set zrange $zrg noreverse nowriteback"; flush $GnuplotPipeScatterPlot 

        set ArgumentGnuPlot "\x22$TMPScatterPlotFileOutputXYbin\x22 binary matrix with image notitle"
        puts $GnuplotPipeScatterPlot "plot $ArgumentGnuPlot"; flush $GnuplotPipeScatterPlot 
        }

    puts $GnuplotPipeScatterPlot "unset output"; flush $GnuplotPipeScatterPlot 

    set ErrorCatch [catch {puts $GnuplotPipeScatterPlot "quit"}]
    if { $ErrorCatch == "0" } {
        puts $GnuplotPipeScatterPlot "quit"; flush $GnuplotPipeScatterPlot 
        }
    catch "close $GnuplotPipeScatterPlot"
    set GnuplotPipeScatterPlot ""
    set GnuplotPipeFid "" 

    WaitUntilCreated $TMPGnuPlotTk1
    Gimp $TMPGnuPlotTk1

    set ProgressLine "0"; update
    #ViewGnuPlotTKThumb 1 .top407 "Scatter Plot"   
    }
}
#############################################################################
## Procedure:  PlotScatterPlotThumb

proc ::PlotScatterPlotThumb {} {
global GnuplotPipeFid GnuplotPipeScatterPlot GnuXview GnuZview  
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPGnuPlotTk1 TMPGnuPlot1Tk GnuOutputFormat GnuOutputFile
global TMPScatterPlotFileOutputXYbin TMPScatterPlotFileOutputXYtxt
global ScatterPlotLabelX ScatterPlotLabelY ScatterPlotTitle PSPThumbnails
global PlatForm WinDir GnuPlotPath WGNUPLOTINIDir

DeleteFile $TMPGnuPlot1Tk

WaitUntilCreated $TMPScatterPlotFileOutputXYtxt
WaitUntilCreated $TMPScatterPlotFileOutputXYbin

if [file exists $TMPScatterPlotFileOutputXYtxt] {  
    set GnuOutputFile $TMPGnuPlot1Tk
    puts $GnuplotPipeScatterPlot "reset"; flush $GnuplotPipeScatterPlot 
    puts $GnuplotPipeScatterPlot "clear"; flush $GnuplotPipeScatterPlot 
    set GnuSizeCol [expr (640 * $PSPThumbnails)]
    set GnuSizeLig [expr (480 * $PSPThumbnails)]
    set GnuSize $GnuSizeCol; append GnuSize ","; append GnuSize $GnuSizeLig
    puts $GnuplotPipeScatterPlot "set terminal png tiny size $GnuSize font 'arial'"; flush $GnuplotPipeScatterPlot 
    puts $GnuplotPipeScatterPlot "set output \x22$GnuOutputFile\x22"; flush $GnuplotPipeScatterPlot 
    
    if [file exists $TMPScatterPlotFileOutputXYtxt ] {
        set f [open $TMPScatterPlotFileOutputXYtxt r]
        gets $f tmp; gets $f xmin; gets $f xmax
        gets $f tmp; gets $f ymin; gets $f ymax
        gets $f zmin; gets $f zmax
        gets $f min; gets $f max
        gets $f Nctr; gets $f NctrStart; gets $f NctrIncr
        close $f
        }

    if [file exists $TMPScatterPlotFileOutputXYbin ] {  
        puts $GnuplotPipeScatterPlot "set colorbox"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set autoscale xfix"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set autoscale yfix"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set palette defined (0 '#000090',1 '#000FFF',2 '#0090FF',3 '#0FFFEE',4 '#90FF70',5 '#FFEE00',6 '#FF7000',7 '#EE0000',8 '#7F0000')"; flush $GnuplotPipeScatterPlot 
        set cbrg "\x5B$zmin:$zmax\x5D";puts $GnuplotPipeScatterPlot "set cbrange $cbrg"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set linewidth 3"; flush $GnuplotPipeScatterPlot 

        set xlbl $ScatterPlotLabelX
        set ylbl $ScatterPlotLabelY
        set zlbl ""
        puts $GnuplotPipeScatterPlot "set xlabel \x22$xlbl\x22"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set ylabel \x22$ylbl\x22"; flush $GnuplotPipeScatterPlot 
        puts $GnuplotPipeScatterPlot "set zlabel \x22$zlbl\x22"; flush $GnuplotPipeScatterPlot 
        set titre "$ScatterPlotTitle - (Scale: 10^n)"
        puts $GnuplotPipeScatterPlot "set title \x22$titre\x22 textcolor lt 3"; flush $GnuplotPipeScatterPlot 

        set minmaxval "Max = $max $zlbl"
        puts $GnuplotPipeScatterPlot "set label \x22$minmaxval\x22 at screen 0.05, screen 0.020 textcolor lt 1"; flush $GnuplotPipeScatterPlot 
        set minmaxval "Min = $min $zlbl"
        puts $GnuplotPipeScatterPlot "set label \x22$minmaxval\x22 at screen 0.65, screen 0.020 textcolor lt 1"; flush $GnuplotPipeScatterPlot 

        set xrg "\x5B$xmin:$xmax\x5D"; puts $GnuplotPipeScatterPlot "set xrange $xrg noreverse nowriteback"; flush $GnuplotPipeScatterPlot 
        set yrg "\x5B$ymin:$ymax\x5D"; puts $GnuplotPipeScatterPlot "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeScatterPlot 
        set zrg "\x5B$zmin:$zmax\x5D"; puts $GnuplotPipeScatterPlot "set zrange $zrg noreverse nowriteback"; flush $GnuplotPipeScatterPlot 

        set ArgumentGnuPlot "\x22$TMPScatterPlotFileOutputXYbin\x22 binary matrix with image notitle"
        puts $GnuplotPipeScatterPlot "plot $ArgumentGnuPlot"; flush $GnuplotPipeScatterPlot 
        }

    puts $GnuplotPipeScatterPlot "unset output"; flush $GnuplotPipeScatterPlot 

    WaitUntilCreated $TMPGnuPlot1Tk
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
    wm geometry $top 200x200+125+125; update
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

proc vTclWindow.top407 {base} {
    if {$base == ""} {
        set base .top407
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
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create Scatter Plot"
    vTcl:DefineAlias "$top" "Toplevel407" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra67 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame11" vTcl:WidgetProc "Toplevel407" 1
    set site_3_0 $top.fra67
    TitleFrame $site_3_0.cpd69 \
        -ipad 0 -text {Input Data File ( X )} 
    vTcl:DefineAlias "$site_3_0.cpd69" "TitleFrame8" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ScatterPlotFileInputX 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel407" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel407" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName ScatterPlotDirInput ScatterPlotFileInputX ScatterPlotFileMaskX
global MinMaxAutoScatterPlotX MinMaxContrastScatterPlotX
global InputFormatX OutputFormatX MinScatterPlotX MaxScatterPlotX MinCScatterPlotX MaxCScatterPlotX
global ConfigFile NligInit VarError ErrorMessage

set ScatterPlotFileInputX ""
set NligInit ""
set NligEnd ""
set NcolInit ""
set NcolEnd ""
set NcolFullSize ""
set InputFormatX "float"
set OutputFormatX "real"
set MinMaxAutoScatterPlotX 1
set MinMaxContrastScatterPlotX 0
$widget(Label407_1) configure -state disable
$widget(Entry407_1) configure -state disable
$widget(Label407_2) configure -state disable
$widget(Entry407_2) configure -state disable
$widget(Label407_3) configure -state disable
$widget(Entry407_3) configure -state disable
$widget(Entry407_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label407_4) configure -state disable
$widget(Entry407_4) configure -state disable
$widget(Entry407_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button407_1) configure -state disable
set MinScatterPlotX "Auto"
set MaxScatterPlotX "Auto"
set MinCScatterPlotX ""
set MaxCScatterPlotX ""

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $ScatterPlotDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; gets $f tmp 
            gets $f tmp; gets $f tmp
            gets $f tmp; gets $f tmp
            if {$tmp == "data type = 2"} {set InputFormatX "int"; set OutputFormatX "real"}
            if {$tmp == "data type = 4"} {set InputFormatX "float"; set OutputFormatX "real"}
            if {$tmp == "data type = 6"} {set InputFormatX "cmplx"; set OutputFormatX "mod"}

            set ScatterPlotDirInputX [file dirname $FileName]
            set ConfigFile "$ScatterPlotDirInputX/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                set ScatterPlotFileMaskX "$ScatterPlotDirInputX/mask_valid_pixels.bin"
                if [file exists $ScatterPlotFileMaskX] {
                    set ScatterPlotFileInputX $FileName
                    } else {
                    set ErrorMessage "THE mask_valid_pixels.bin FILE DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    if {$VarError == "cancel"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
                    }    
                } else {
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                if {$VarError == "cancel"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
                }    
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            if {$VarError == "cancel"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
        }    
    }
} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd70 \
        -ipad 0 -text {Data Format} 
    vTcl:DefineAlias "$site_3_0.cpd70" "TitleFrame1" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    radiobutton $site_5_0.cpd82 \
        -padx 1 -text Complex -value cmplx -variable InputFormatX 
    radiobutton $site_5_0.cpd83 \
        -padx 1 -text Float -value float -variable InputFormatX 
    radiobutton $site_5_0.cpd84 \
        -padx 1 -text Integer -value int -variable InputFormatX 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text Show 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame2" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    radiobutton $site_5_0.cpd86 \
        -padx 1 -text Modulus -value mod -variable OutputFormatX 
    vTcl:DefineAlias "$site_5_0.cpd86" "Radiobutton35" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd71 \
        -padx 1 -text 10log(Mod) -value db10 -variable OutputFormatX 
    vTcl:DefineAlias "$site_5_0.cpd71" "Radiobutton43" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd87 \
        -padx 1 -text 20log(Mod) -value db20 -variable OutputFormatX 
    vTcl:DefineAlias "$site_5_0.cpd87" "Radiobutton36" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd89 \
        -padx 1 -text Phase -value pha -variable OutputFormatX 
    vTcl:DefineAlias "$site_5_0.cpd89" "Radiobutton37" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd90 \
        -padx 1 -text Real -value real -variable OutputFormatX 
    vTcl:DefineAlias "$site_5_0.cpd90" "Radiobutton38" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd92 \
        -padx 1 -text Imag -value imag -variable OutputFormatX 
    vTcl:DefineAlias "$site_5_0.cpd92" "Radiobutton39" vTcl:WidgetProc "Toplevel407" 1
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd89 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd72 \
        -ipad 0 -text {Minimum / Maximum Values} 
    vTcl:DefineAlias "$site_3_0.cpd72" "TitleFrame6" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    frame $site_5_0.cpd72
    set site_6_0 $site_5_0.cpd72
    frame $site_6_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra77" "Frame3" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.fra77
    checkbutton $site_7_0.cpd78 \
        \
        -command {global MinMaxAutoScatterPlotX
if {"$MinMaxAutoScatterPlotX"=="1"} {
    $widget(Label407_1) configure -state disable
    $widget(Entry407_1) configure -state disable
    $widget(Label407_2) configure -state disable
    $widget(Entry407_2) configure -state disable
    $widget(Label407_3) configure -state disable
    $widget(Entry407_3) configure -state disable
    $widget(Entry407_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label407_4) configure -state disable
    $widget(Entry407_4) configure -state disable
    $widget(Entry407_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button407_1) configure -state disable
    set MinScatterPlotX "Auto"
    set MaxScatterPlotX "Auto"
    set MinCScatterPlotX ""
    set MaxCScatterPlotX ""
    } else {
    $widget(Label407_1) configure -state normal
    $widget(Entry407_1) configure -state normal
    $widget(Label407_2) configure -state normal
    $widget(Entry407_2) configure -state normal
    $widget(Label407_3) configure -state normal
    $widget(Entry407_3) configure -state disable
    $widget(Entry407_3) configure -disabledbackground #FFFFFF
    $widget(Label407_4) configure -state normal
    $widget(Entry407_4) configure -state disable
    $widget(Entry407_4) configure -disabledbackground #FFFFFF
    $widget(Button407_1) configure -state normal
    set MinScatterPlotX "?"
    set MaxScatterPlotX "?"
    set MinCScatterPlotX ""
    set MaxCScatterPlotX ""
    }} \
        -padx 1 -text Automatic -variable MinMaxAutoScatterPlotX 
    vTcl:DefineAlias "$site_7_0.cpd78" "Checkbutton43" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd79" "Frame4" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd79
    checkbutton $site_7_0.cpd78 \
        -padx 1 -text {Enhanced Contrast} \
        -variable MinMaxContrastScatterPlotX 
    vTcl:DefineAlias "$site_7_0.cpd78" "Checkbutton44" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra77 \
        -in $site_6_0 -anchor w -expand 1 -fill none -side top 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor w -expand 0 -fill none -side top 
    frame $site_5_0.cpd73
    set site_6_0 $site_5_0.cpd73
    frame $site_6_0.cpd102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd102" "Frame69" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd102
    button $site_7_0.cpd75 \
        -background #ffff00 \
        -command {global ScatterPlotFileInputX MaxScatterPlotX MinScatterPlotX MaxCScatterPlotX MinCScatterPlotX TMPMinMaxBmp OpenDirFile

if {$OpenDirFile == 0} {
#read MinMaxScatterPlot
set MinMaxScatterPlotvalues $TMPMinMaxBmp
DeleteFile $MinMaxScatterPlotvalues

set OffsetLig [expr $NligInit - 1]
set OffsetCol [expr $NcolInit - 1]
set FinalNlig [expr $NligEnd - $NligInit + 1]
set FinalNcol [expr $NcolEnd - $NcolInit + 1]

set MaskCmd ""
set MaskDir [file dirname $ScatterPlotFileInputX]
set MaskFile "$MaskDir/mask_valid_pixels.bin"
if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

set Fonction "Min / Max Values Determination of the Bin File :"
set Fonction2 "$ScatterPlotFileInputX"    
set ProgressLine "0"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
update
TextEditorRunTrace "Process The Function Soft/bin/bmp_process/MinMaxBMP.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$ScatterPlotFileInputX\x22 -ift $InputFormatX -oft $OutputFormatX -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/bmp_process/MinMaxBMP.exe -if \x22$ScatterPlotFileInputX\x22 -ift $InputFormatX -oft $OutputFormatX -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

WaitUntilCreated $MinMaxScatterPlotvalues
if [file exists $MinMaxScatterPlotvalues] {
    set f [open $MinMaxScatterPlotvalues r]
    gets $f MaxScatterPlotX
    gets $f MinScatterPlotX
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f MaxCScatterPlotX
    gets $f MinCScatterPlotX
    close $f
    }
}} \
        -pady 2 -text MinMax 
    vTcl:DefineAlias "$site_7_0.cpd75" "Button407_1" vTcl:WidgetProc "Toplevel407" 1
    bindtags $site_7_0.cpd75 "$site_7_0.cpd75 Button $top all _vTclBalloon"
    bind $site_7_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Find the Min Max values}
    }
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra67" "Frame1" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.fra67
    label $site_7_0.lab68 \
        -text Min 
    vTcl:DefineAlias "$site_7_0.lab68" "Label407_1" vTcl:WidgetProc "Toplevel407" 1
    label $site_7_0.cpd69 \
        -text {Min E.C} 
    vTcl:DefineAlias "$site_7_0.cpd69" "Label407_3" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.lab68 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd70" "Frame6" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd70
    entry $site_7_0.ent71 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MinScatterPlotX -width 12 
    vTcl:DefineAlias "$site_7_0.ent71" "Entry407_1" vTcl:WidgetProc "Toplevel407" 1
    entry $site_7_0.cpd73 \
        -background white -disabledforeground #0000ff -foreground #0000ff \
        -justify center -state disabled -textvariable MinCScatterPlotX \
        -width 12 
    vTcl:DefineAlias "$site_7_0.cpd73" "Entry407_3" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.ent71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd74" "Frame7" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd74
    label $site_7_0.lab68 \
        -text Max 
    vTcl:DefineAlias "$site_7_0.lab68" "Label407_2" vTcl:WidgetProc "Toplevel407" 1
    label $site_7_0.cpd69 \
        -text {Max E.C} 
    vTcl:DefineAlias "$site_7_0.cpd69" "Label407_4" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.lab68 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame8" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd75
    entry $site_7_0.ent71 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MaxScatterPlotX -width 12 
    vTcl:DefineAlias "$site_7_0.ent71" "Entry407_2" vTcl:WidgetProc "Toplevel407" 1
    entry $site_7_0.cpd73 \
        -background white -disabledforeground #0000ff -foreground #0000ff \
        -justify center -state disabled -textvariable MaxCScatterPlotX \
        -width 12 
    vTcl:DefineAlias "$site_7_0.cpd73" "Entry407_4" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.ent71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_6_0.cpd102 \
        -in $site_6_0 -anchor center -expand 1 -fill y -padx 5 -side right 
    pack $site_6_0.fra67 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd73 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd73" "Frame12" vTcl:WidgetProc "Toplevel407" 1
    set site_3_0 $top.cpd73
    TitleFrame $site_3_0.cpd69 \
        -ipad 0 -text {Input Data File ( Y )} 
    vTcl:DefineAlias "$site_3_0.cpd69" "TitleFrame9" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ScatterPlotFileInputY 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel407" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel407" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName ScatterPlotDirInput ScatterPlotFileInputY ScatterPlotFileMaskY
global MinMaxAutoScatterPlotY MinMaxContrastScatterPlotY
global InputFormatY OutputFormatY MinScatterPlotY MaxScatterPlotY MinCScatterPlotY MaxCScatterPlotY
global ConfigFile NligInit VarError ErrorMessage

set ScatterPlotFileInputY ""
set NligInit ""
set NligEnd ""
set NcolInit ""
set NcolEnd ""
set NcolFullSize ""
set InputFormatY "float"
set OutputFormatY "real"
set MinMaxAutoScatterPlotY 1
set MinMaxContrastScatterPlotY 0
$widget(Label407_5) configure -state disable
$widget(Entry407_5) configure -state disable
$widget(Label407_6) configure -state disable
$widget(Entry407_6) configure -state disable
$widget(Label407_7) configure -state disable
$widget(Entry407_7) configure -state disable
$widget(Entry407_7) configure -disabledbackground $PSPBackgroundColor
$widget(Label407_8) configure -state disable
$widget(Entry407_8) configure -state disable
$widget(Entry407_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button407_2) configure -state disable
set MinScatterPlotY "Auto"
set MaxScatterPlotY "Auto"
set MinCScatterPlotY ""
set MaxCScatterPlotY ""

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $ScatterPlotDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; gets $f tmp 
            gets $f tmp; gets $f tmp
            gets $f tmp; gets $f tmp
            if {$tmp == "data type = 2"} {set InputFormatY "int"; set OutputFormatY "real"}
            if {$tmp == "data type = 4"} {set InputFormatY "float"; set OutputFormatY "real"}
            if {$tmp == "data type = 6"} {set InputFormatY "cmplx"; set OutputFormatY "mod"}

            set ScatterPlotDirInputY [file dirname $FileName]
            set ConfigFile "$ScatterPlotDirInputY/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                set ScatterPlotFileMaskY "$ScatterPlotDirInputY/mask_valid_pixels.bin"
                if [file exists $ScatterPlotFileMaskY] {
                    set ScatterPlotFileInputY $FileName
                    } else {
                    set ErrorMessage "THE mask_valid_pixels.bin FILE DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    if {$VarError == "cancel"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
                    }    
                } else {
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                if {$VarError == "cancel"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
                }    
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            if {$VarError == "cancel"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
        }    
    }
} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd70 \
        -ipad 0 -text {Data Format} 
    vTcl:DefineAlias "$site_3_0.cpd70" "TitleFrame3" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    radiobutton $site_5_0.cpd82 \
        -padx 1 -text Complex -value cmplx -variable InputFormatY 
    radiobutton $site_5_0.cpd83 \
        -padx 1 -text Float -value float -variable InputFormatY 
    radiobutton $site_5_0.cpd84 \
        -padx 1 -text Integer -value int -variable InputFormatY 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text Show 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame4" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    radiobutton $site_5_0.cpd86 \
        -padx 1 -text Modulus -value mod -variable OutputFormatY 
    vTcl:DefineAlias "$site_5_0.cpd86" "Radiobutton40" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd71 \
        -padx 1 -text 10log(Mod) -value db10 -variable OutputFormatY 
    vTcl:DefineAlias "$site_5_0.cpd71" "Radiobutton44" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd87 \
        -padx 1 -text 20log(Mod) -value db20 -variable OutputFormatY 
    vTcl:DefineAlias "$site_5_0.cpd87" "Radiobutton41" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd89 \
        -padx 1 -text Phase -value pha -variable OutputFormatY 
    vTcl:DefineAlias "$site_5_0.cpd89" "Radiobutton42" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd90 \
        -padx 1 -text Real -value real -variable OutputFormatY 
    vTcl:DefineAlias "$site_5_0.cpd90" "Radiobutton45" vTcl:WidgetProc "Toplevel407" 1
    radiobutton $site_5_0.cpd92 \
        -padx 1 -text Imag -value imag -variable OutputFormatY 
    vTcl:DefineAlias "$site_5_0.cpd92" "Radiobutton46" vTcl:WidgetProc "Toplevel407" 1
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd89 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd72 \
        -ipad 0 -text {Minimum / Maximum Values} 
    vTcl:DefineAlias "$site_3_0.cpd72" "TitleFrame10" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    frame $site_5_0.cpd72
    set site_6_0 $site_5_0.cpd72
    frame $site_6_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra77" "Frame13" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.fra77
    checkbutton $site_7_0.cpd78 \
        \
        -command {global MinMaxAutoScatterPlotY
if {"$MinMaxAutoScatterPlotY"=="1"} {
    $widget(Label407_5) configure -state disable
    $widget(Entry407_5) configure -state disable
    $widget(Label407_6) configure -state disable
    $widget(Entry407_6) configure -state disable
    $widget(Label407_7) configure -state disable
    $widget(Entry407_7) configure -state disable
    $widget(Entry407_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Label407_8) configure -state disable
    $widget(Entry407_8) configure -state disable
    $widget(Entry407_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Button407_2) configure -state disable
    set MinScatterPlotY "Auto"
    set MaxScatterPlotY "Auto"
    set MinCScatterPlotY ""
    set MaxCScatterPlotY ""
    } else {
    $widget(Label407_5) configure -state normal
    $widget(Entry407_5) configure -state normal
    $widget(Label407_6) configure -state normal
    $widget(Entry407_6) configure -state normal
    $widget(Label407_7) configure -state normal
    $widget(Entry407_7) configure -state disable
    $widget(Entry407_7) configure -disabledbackground #FFFFFF
    $widget(Label407_8) configure -state normal
    $widget(Entry407_8) configure -state disable
    $widget(Entry407_8) configure -disabledbackground #FFFFFF
    $widget(Button407_2) configure -state normal
    set MinScatterPlotY "?"
    set MaxScatterPlotY "?"
    set MinCScatterPlotY ""
    set MaxCScatterPlotY ""
    }} \
        -padx 1 -text Automatic -variable MinMaxAutoScatterPlotY 
    vTcl:DefineAlias "$site_7_0.cpd78" "Checkbutton45" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd79" "Frame14" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd79
    checkbutton $site_7_0.cpd78 \
        -padx 1 -text {Enhanced Contrast} \
        -variable MinMaxContrastScatterPlotY 
    vTcl:DefineAlias "$site_7_0.cpd78" "Checkbutton46" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra77 \
        -in $site_6_0 -anchor w -expand 1 -fill none -side top 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor w -expand 0 -fill none -side top 
    frame $site_5_0.cpd73
    set site_6_0 $site_5_0.cpd73
    frame $site_6_0.cpd102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd102" "Frame70" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd102
    button $site_7_0.cpd75 \
        -background #ffff00 \
        -command {global ScatterPlotFileInputY MaxScatterPlotY MinScatterPlotY MaxCScatterPlotY MinCScatterPlotY TMPMinMaxBmp OpenDirFile

if {$OpenDirFile == 0} {
#read MinMaxScatterPlot
set MinMaxScatterPlotvalues $TMPMinMaxBmp
DeleteFile $MinMaxScatterPlotvalues

set OffsetLig [expr $NligInit - 1]
set OffsetCol [expr $NcolInit - 1]
set FinalNlig [expr $NligEnd - $NligInit + 1]
set FinalNcol [expr $NcolEnd - $NcolInit + 1]

set MaskCmd ""
set MaskDir [file dirname $ScatterPlotFileInputY]
set MaskFile "$MaskDir/mask_valid_pixels.bin"
if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

set Fonction "Min / Max Values Determination of the Bin File :"
set Fonction2 "$ScatterPlotFileInputY"    
set ProgressLine "0"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
update
TextEditorRunTrace "Process The Function Soft/bin/bmp_process/MinMaxBMP.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$ScatterPlotFileInputY\x22 -ift $InputFormatY -oft $OutputFormatY -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/bmp_process/MinMaxBMP.exe -if \x22$ScatterPlotFileInputY\x22 -ift $InputFormatY -oft $OutputFormatY -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

WaitUntilCreated $MinMaxScatterPlotvalues
if [file exists $MinMaxScatterPlotvalues] {
    set f [open $MinMaxScatterPlotvalues r]
    gets $f MaxScatterPlotY
    gets $f MinScatterPlotY
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f MaxCScatterPlotY
    gets $f MinCScatterPlotY
    close $f
    }
}} \
        -pady 2 -text MinMax 
    vTcl:DefineAlias "$site_7_0.cpd75" "Button407_2" vTcl:WidgetProc "Toplevel407" 1
    bindtags $site_7_0.cpd75 "$site_7_0.cpd75 Button $top all _vTclBalloon"
    bind $site_7_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Find the Min Max values}
    }
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra67" "Frame15" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.fra67
    label $site_7_0.lab68 \
        -text Min 
    vTcl:DefineAlias "$site_7_0.lab68" "Label407_5" vTcl:WidgetProc "Toplevel407" 1
    label $site_7_0.cpd69 \
        -text {Min E.C} 
    vTcl:DefineAlias "$site_7_0.cpd69" "Label407_7" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.lab68 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd70" "Frame16" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd70
    entry $site_7_0.ent71 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MinScatterPlotY -width 12 
    vTcl:DefineAlias "$site_7_0.ent71" "Entry407_5" vTcl:WidgetProc "Toplevel407" 1
    entry $site_7_0.cpd73 \
        -background white -disabledforeground #0000ff -foreground #0000ff \
        -justify center -state disabled -textvariable MinCScatterPlotY \
        -width 12 
    vTcl:DefineAlias "$site_7_0.cpd73" "Entry407_7" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.ent71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd74" "Frame17" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd74
    label $site_7_0.lab68 \
        -text Max 
    vTcl:DefineAlias "$site_7_0.lab68" "Label407_6" vTcl:WidgetProc "Toplevel407" 1
    label $site_7_0.cpd69 \
        -text {Max E.C} 
    vTcl:DefineAlias "$site_7_0.cpd69" "Label407_8" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.lab68 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame18" vTcl:WidgetProc "Toplevel407" 1
    set site_7_0 $site_6_0.cpd75
    entry $site_7_0.ent71 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MaxScatterPlotY -width 12 
    vTcl:DefineAlias "$site_7_0.ent71" "Entry407_6" vTcl:WidgetProc "Toplevel407" 1
    entry $site_7_0.cpd73 \
        -background white -disabledforeground #0000ff -foreground #0000ff \
        -justify center -state disabled -textvariable MaxCScatterPlotY \
        -width 12 
    vTcl:DefineAlias "$site_7_0.cpd73" "Entry407_8" vTcl:WidgetProc "Toplevel407" 1
    pack $site_7_0.ent71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_6_0.cpd102 \
        -in $site_6_0 -anchor center -expand 1 -fill y -padx 5 -side right 
    pack $site_6_0.fra67 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame2" vTcl:WidgetProc "Toplevel407" 1
    set site_3_0 $top.fra74
    TitleFrame $site_3_0.tit75 \
        -ipad 1 -text {Label ( X )} 
    vTcl:DefineAlias "$site_3_0.tit75" "TitleFrame5" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.tit75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit75 getframe]
    entry $site_5_0.cpd76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ScatterPlotLabelX 
    vTcl:DefineAlias "$site_5_0.cpd76" "EntryTopXXCh13" vTcl:WidgetProc "Toplevel407" 1
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd77 \
        -ipad 1 -text {Label ( Y )} 
    vTcl:DefineAlias "$site_3_0.cpd77" "TitleFrame7" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd77 getframe]
    entry $site_5_0.cpd76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ScatterPlotLabelY 
    vTcl:DefineAlias "$site_5_0.cpd76" "EntryTopXXCh14" vTcl:WidgetProc "Toplevel407" 1
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd78 \
        -ipad 1 -text {Title Scatter Plot} 
    vTcl:DefineAlias "$site_3_0.cpd78" "TitleFrame13" vTcl:WidgetProc "Toplevel407" 1
    bind $site_3_0.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd78 getframe]
    entry $site_5_0.cpd76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ScatterPlotTitle -width 30 
    vTcl:DefineAlias "$site_5_0.cpd76" "EntryTopXXCh15" vTcl:WidgetProc "Toplevel407" 1
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.tit75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra38 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel407" 1
    set site_3_0 $top.fra38
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ScatterPlotDirOutput ScatterPlotFileOutput NligInit 
global ScatterPlotFileInputX ScatterPlotFileMaskX 
global MinMaxAutoScatterPlotX MinMaxContrastScatterPlotX
global InputFormatX OutputFormatX MinScatterPlotX MaxScatterPlotX MinCScatterPlotX MaxCScatterPlotX
global ScatterPlotFileInputY ScatterPlotFileMaskY 
global MinMaxAutoScatterPlotY MinMaxContrastScatterPlotY
global InputFormatY OutputFormatY MinScatterPlotY MaxScatterPlotY MinCScatterPlotY MaxCScatterPlotY
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPScatterPlotFileOutputXtxt TMPScatterPlotFileOutputXbin TMPScatterPlotFileOutputXmask
global TMPScatterPlotFileOutputYtxt TMPScatterPlotFileOutputYbin TMPScatterPlotFileOutputYmask
global TMPScatterPlotFileOutputXYbin TMPScatterPlotFileOutputXYtxt

if {$OpenDirFile == 0} {

if {"$NligInit"!="0"} {
    set config "true"
    if {"$ScatterPlotFileInputX"==""} {
        set config "false"
        set VarError ""
        set ErrorMessage "INVALID INPUT DATA FILE X"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if {"$ScatterPlotFileInputY"==""} {
        set config "false"
        set VarError ""
        set ErrorMessage "INVALID INPUT DATA FILE Y"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {"$config"=="true"} {
        set VarWarning "ok"
        if {"$VarWarning"=="ok"} {
           if {$MinMaxAutoScatterPlotX == 0} {
                if {$MinMaxContrastScatterPlotX == 0} {set MinMaxScatterPlotX 0}
                if {$MinMaxContrastScatterPlotX == 1} {set MinMaxScatterPlotX 2}
                }            
            if {$MinMaxAutoScatterPlotX == 1} {
                if {$MinMaxContrastScatterPlotX == 0} {set MinMaxScatterPlotX 3}
                if {$MinMaxContrastScatterPlotX == 1} {set MinMaxScatterPlotX 1}
                set MinScatterPlotX "-9999"
                set MaxScatterPlotX "+9999"
                }

            if {$MinMaxAutoScatterPlotY == 0} {
                if {$MinMaxContrastScatterPlotY == 0} {set MinMaxScatterPlotY 0}
                if {$MinMaxContrastScatterPlotY == 1} {set MinMaxScatterPlotY 2}
                }            
            if {$MinMaxAutoScatterPlotY == 1} {
                if {$MinMaxContrastScatterPlotY == 0} {set MinMaxScatterPlotY 3}
                if {$MinMaxContrastScatterPlotY == 1} {set MinMaxScatterPlotY 1}
                set MinScatterPlotY "-9999"
                set MaxScatterPlotY "+9999"
                }

            set TestVarName(0) "Min Value"; set TestVarType(0) "float"; set TestVarValue(0) $MinScatterPlotX; set TestVarMin(0) "-10000.00"; set TestVarMax(0) "10000.00"
            set TestVarName(1) "Max Value"; set TestVarType(1) "float"; set TestVarValue(1) $MaxScatterPlotX; set TestVarMin(1) "-10000.00"; set TestVarMax(1) "10000.00"
            set TestVarName(2) "Min Value"; set TestVarType(2) "float"; set TestVarValue(2) $MinScatterPlotY; set TestVarMin(2) "-10000.00"; set TestVarMax(2) "10000.00"
            set TestVarName(3) "Max Value"; set TestVarType(3) "float"; set TestVarValue(3) $MaxScatterPlotY; set TestVarMin(3) "-10000.00"; set TestVarMax(3) "10000.00"
            TestVar 4
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
                DeleteFile $TMPScatterPlotFileOutputXbin
                DeleteFile $TMPScatterPlotFileOutputXtxt
                DeleteFile $TMPScatterPlotFileOutputXmask
                DeleteFile $TMPScatterPlotFileOutputYbin
                DeleteFile $TMPScatterPlotFileOutputYtxt
                DeleteFile $TMPScatterPlotFileOutputYmask
                DeleteFile $TMPScatterPlotFileOutputXYbin
                DeleteFile $TMPScatterPlotFileOutputXYtxt

                set ScatterPlotDirOutput [file dirname $ScatterPlotFileInputX]
                set BorderType "Null"

                set Fonction "Creation of the ScatterPlot File :"
                set Fonction2 "$ScatterPlotFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/prepare_scatterplot.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$ScatterPlotFileInputX\x22 -mask \x22$ScatterPlotFileMaskX\x22 -obf \x22$TMPScatterPlotFileOutputXbin\x22 -otf \x22$TMPScatterPlotFileOutputXtxt\x22 -omf \x22$TMPScatterPlotFileOutputXmask\x22 -ift $InputFormatX -oft $OutputFormatX -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxScatterPlotX -min $MinScatterPlotX -max $MaxScatterPlotX -bord $BorderType" "k"
                set f [ open "| Soft/bin/bmp_process/prepare_scatterplot.exe -if \x22$ScatterPlotFileInputX\x22 -mask \x22$ScatterPlotFileMaskX\x22 -obf \x22$TMPScatterPlotFileOutputXbin\x22 -otf \x22$TMPScatterPlotFileOutputXtxt\x22 -omf \x22$TMPScatterPlotFileOutputXmask\x22 -ift $InputFormatX -oft $OutputFormatX -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxScatterPlotX -min $MinScatterPlotX -max $MaxScatterPlotX -bord $BorderType" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/prepare_scatterplot.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$ScatterPlotFileInputY\x22 -mask \x22$ScatterPlotFileMaskY\x22 -obf \x22$TMPScatterPlotFileOutputYbin\x22 -otf \x22$TMPScatterPlotFileOutputYtxt\x22 -omf \x22$TMPScatterPlotFileOutputYmask\x22 -ift $InputFormatY -oft $OutputFormatY -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxScatterPlotY -min $MinScatterPlotY -max $MaxScatterPlotY -bord $BorderType" "k"
                set f [ open "| Soft/bin/bmp_process/prepare_scatterplot.exe -if \x22$ScatterPlotFileInputY\x22 -mask \x22$ScatterPlotFileMaskY\x22 -obf \x22$TMPScatterPlotFileOutputYbin\x22 -otf \x22$TMPScatterPlotFileOutputYtxt\x22 -omf \x22$TMPScatterPlotFileOutputYmask\x22 -ift $InputFormatY -oft $OutputFormatY -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxScatterPlotY -min $MinScatterPlotY -max $MaxScatterPlotY -bord $BorderType" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_scatterplot.exe" "k"
                TextEditorRunTrace "Arguments: -ifbX \x22$TMPScatterPlotFileOutputXbin\x22 -iftX \x22$TMPScatterPlotFileOutputXtxt\x22 -ifmX \x22$TMPScatterPlotFileOutputXmask\x22 -ifbY \x22$TMPScatterPlotFileOutputYbin\x22 -iftY \x22$TMPScatterPlotFileOutputYtxt\x22 -ifmY \x22$TMPScatterPlotFileOutputYmask\x22 -ofb \x22$TMPScatterPlotFileOutputXYbin\x22 -oft \x22$TMPScatterPlotFileOutputXYtxt\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
                set f [ open "| Soft/bin/bmp_process/create_scatterplot.exe -ifbX \x22$TMPScatterPlotFileOutputXbin\x22 -iftX \x22$TMPScatterPlotFileOutputXtxt\x22 -ifmX \x22$TMPScatterPlotFileOutputXmask\x22 -ifbY \x22$TMPScatterPlotFileOutputYbin\x22 -iftY \x22$TMPScatterPlotFileOutputYtxt\x22 -ifmY \x22$TMPScatterPlotFileOutputYmask\x22 -ofb \x22$TMPScatterPlotFileOutputXYbin\x22 -oft \x22$TMPScatterPlotFileOutputXYtxt\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                WaitUntilCreated $TMPScatterPlotFileOutputXYbin
                WaitUntilCreated $TMPScatterPlotFileOutputXYtxt

                PlotScatterPlot
                $widget(Button407_3) configure -state normal
                $widget(Button407_4) configure -state normal
                }
            } else {
            if {"$VarWarning"=="no"} {Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create ScatterPlot File" "b"}
            }
        }
    } else {
        set VarError ""
        set ErrorMessage "ENTER A VALID INPUT DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel407" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but66 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global GnuplotPipeFid SaveDisplayDirOutput ScatterPlotDirOutput 
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

    set SaveDisplayOutputFile1 "Scatter_Plot"
    set SaveDisplayDirOutput $ScatterPlotDirOutput

    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel407) $widget(Toplevel456); TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_3_0.but66" "Button407_3" vTcl:WidgetProc "Toplevel407" 1
    bindtags $site_3_0.but66 "$site_3_0.but66 Button $top all _vTclBalloon"
    bind $site_3_0.but66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save}
    }
    button $site_3_0.but75 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1

Gimp $TMPGnuPlotTk1} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but75" "Button407_4" vTcl:WidgetProc "Toplevel407" 1
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CreateScatterPlot.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel407" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global DisplayMainMenu OpenDirFile Load_SaveDisplay1 

if {$OpenDirFile == 0} {
if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}
Window hide .top401
Window hide $widget(Toplevel407); TextEditorRunTrace "Close Window Create Scatter Plot File" "b"
if {$DisplayMainMenu == 1} {
    set DisplayMainMenu 0
    WidgetShow $widget(Toplevel2)
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel407" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra67 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra38 \
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
Window show .top407

main $argc $argv
