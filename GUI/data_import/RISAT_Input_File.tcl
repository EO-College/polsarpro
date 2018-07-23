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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}
        {{[file join . GUI Images RISAT.gif]} {user image} user {}}

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
    set base .top449
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab49 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-image 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-image 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra88
    namespace eval ::widgets::$site_3_0.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra68
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_3_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra90
    namespace eval ::widgets::$site_4_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra91
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd97
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd98
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd97
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd99 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd99
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd66
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd97
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd99 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd99
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd66
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd90 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd90 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd97
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd100
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd101
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.fra57 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra57
    namespace eval ::widgets::$site_3_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra39
    namespace eval ::widgets::$site_4_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent41 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab42 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent43 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
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
            vTclWindow.top449
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
    wm geometry $top 200x200+125+125; update
    wm maxsize $top 1684 1032
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

proc vTclWindow.top449 {base} {
    if {$base == ""} {
        set base .top449
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
    wm geometry $top 500x590+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "RISAT Input Data File ( CEOS Format )"
    vTcl:DefineAlias "$top" "Toplevel449" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab49 \
        -image [vTcl:image:get_image [file join . GUI Images RISAT.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab49" "Label73" vTcl:WidgetProc "Toplevel449" 1
    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame1" vTcl:WidgetProc "Toplevel449" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel449" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RISATDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel449" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -state disabled -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button1" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame5" vTcl:WidgetProc "Toplevel449" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable RISATDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel449" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame12" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -command {global DirName DataDir RISATDirOutput
global VarWarning WarningMessage WarningMessage2

set RISATOutputDirTmp $RISATDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set RISATDirOutput $DirName
        } else {
        set RISATDirOutput $RISATOutputDirTmp
        }
    } else {
    set RISATDirOutput $RISATOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button2" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd72 \
        -ipad 0 -text {Band-Meta File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame6" vTcl:WidgetProc "Toplevel449" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RISATBandMetaFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel449" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -state disabled -text button 
    vTcl:DefineAlias "$site_5_0.but71" "Button3" vTcl:WidgetProc "Toplevel449" 1
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra88" "Frame30" vTcl:WidgetProc "Toplevel449" 1
    set site_3_0 $top.fra88
    frame $site_3_0.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra68" "Frame2" vTcl:WidgetProc "Toplevel449" 1
    set site_4_0 $site_3_0.fra68
    button $site_4_0.cpd69 \
        -background #ffff00 \
        -command {global RISATLeaderFile RISATGridFile RISATBandMetaFile RISATDataFormat
global RISATDirInput RISATDirOutput TMPGoogle RISATIncAngFile 
global RISATMode TMPRISATConfig
global RISATSceneID RISATResRg RISATResAz RISATPixAz RISATPixRg
global RISATImgFormat RISATProcLevel RISATincang RISATImgMode
global FileInput1 FileInput2 FileInput3 FileInput4
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global ErrorMessage VarError PolarType ActiveProgram
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

DeleteFile $TMPGoogle
DeleteFile $TMPRISATConfig

$widget(Label449_10) configure -state normal; $widget(Entry449_10) configure -disabledbackground #FFFFFF
$widget(Label449_11) configure -state normal; $widget(Entry449_11) configure -disabledbackground #FFFFFF
$widget(Label449_17) configure -state normal; $widget(Entry449_17) configure -disabledbackground #FFFFFF
$widget(Label449_18) configure -state normal; $widget(Entry449_18) configure -disabledbackground #FFFFFF
$widget(Label449_19) configure -state normal; $widget(Entry449_19) configure -disabledbackground #FFFFFF
$widget(Label449_20) configure -state normal; $widget(Entry449_20) configure -disabledbackground #FFFFFF
$widget(Label449_21) configure -state normal; $widget(Entry449_21) configure -disabledbackground #FFFFFF
$widget(Label449_22) configure -state normal; $widget(Entry449_22) configure -disabledbackground #FFFFFF
$widget(Label449_23) configure -state normal; $widget(Entry449_23) configure -disabledbackground #FFFFFF
$widget(Label449_24) configure -state normal; $widget(Entry449_24) configure -disabledbackground #FFFFFF

set config "true"
if {$RISATBandMetaFile == ""} { set config "false1" }

if {$config == "true"} {
  set RISATPol1 ""; set RISATPol2 ""; set RISATPol3 ""; set RISATPol4 ""
  set RISATCalPol1 ""; set RISATCalfac1 ""
  set RISATCalPol2 ""; set RISATCalfac2 ""
  set RISATCalPol3 ""; set RISATCalfac3 ""
  set RISATCalPol4 ""; set RISATCalfac4 ""
  set f [open $RISATBandMetaFile r]
  gets $f tmp;
  if {[string first "ProductID" $tmp] != "-1"} { set RISATSceneID [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
  close $f
  set f [open $RISATBandMetaFile r]
  while { ![eof $f] } {
      gets $f tmp;
      if {[string first "InputResolutionAlong" $tmp] != "-1"} { set RISATResRg [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "InputResolutionAcross" $tmp] != "-1"} { set RISATResAz [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "OutputLineSpacing" $tmp] != "-1"} { set RISATPixAz [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "OutputPixelSpacing" $tmp] != "-1"} { set RISATPixRg [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ImageFormat" $tmp] != "-1"} { set RISATImgFormat [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProcessingLevel" $tmp] != "-1"} { set RISATProcLevel [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "NoScans" $tmp] != "-1"} { set RISATscans [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "NoPixels" $tmp] != "-1"} { set RISATpixels [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProdULLat" $tmp] != "-1"} { set RISATLat00 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProdULLon" $tmp] != "-1"} { set RISATLon00 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProdURLat" $tmp] != "-1"} { set RISATLat0N [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProdURLon" $tmp] != "-1"} { set RISATLon0N [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProdLLLat" $tmp] != "-1"} { set RISATLatN0 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProdLLLon" $tmp] != "-1"} { set RISATLonN0 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProdLRLat" $tmp] != "-1"} { set RISATLatNN [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ProdLRLon" $tmp] != "-1"} { set RISATLonNN [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "SceneCenterLat" $tmp] != "-1"} { set RISATLatCenter [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "SceneCenterLon" $tmp] != "-1"} { set RISATLonCenter [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "IncidenceAngle" $tmp] != "-1"} { set RISATincang [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "ImagingMode" $tmp] != "-1"} { set RISATImgMode [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "NoOfPolarizations" $tmp] != "-1"} { set RISATnoPol [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "TxRxPol1" $tmp] != "-1"} { set RISATPol1 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "TxRxPol2" $tmp] != "-1"} { set RISATPol2 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "TxRxPol3" $tmp] != "-1"} { set RISATPol3 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      if {[string first "TxRxPol4" $tmp] != "-1"} { set RISATPol4 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      set CalString "Calibration_Constant_"; append CalString $RISATPol1
      if {[string first $CalString $tmp] != "-1"} { set RISATCalPol1 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      set CalString "Calibration_Constant_"; append CalString $RISATPol2
      if {[string first $CalString $tmp] != "-1"} { set RISATCalPol2 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      set CalString "Calibration_Constant_"; append CalString $RISATPol3
      if {[string first $CalString $tmp] != "-1"} { set RISATCalPol3 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      set CalString "Calibration_Constant_"; append CalString $RISATPol4
      if {[string first $CalString $tmp] != "-1"} { set RISATCalPol4 [string range $tmp [expr [string first "=" $tmp] + 1 ] [string length $tmp] ] }
      }
  close $f

  set config "true"
  if {$RISATProcLevel != "SLC"} { set config "false2" }

  if {$config == "true"} {
    set RISATGridFile ""

    set f [open $TMPRISATConfig w]
    puts $f $RISATLat00
    puts $f $RISATLon00
    puts $f $RISATLat0N
    puts $f $RISATLon0N
    puts $f $RISATLatNN
    puts $f $RISATLonNN
    puts $f $RISATLatN0
    puts $f $RISATLonN0
    puts $f $RISATLatCenter
    puts $f $RISATLonCenter
    close $f

    set configrisat "true"
    if {$RISATImgFormat != "CEOS"} {set configrisat "CEOS"}
    if {$RISATProcLevel != "SLC"} {set configrisat "SLC"}
    set RISATImgModeTmp "0"
    if {$RISATImgMode == "CFRS1"} {set RISATImgModeTmp "1"}
    if {$RISATImgMode == "FRS1"}  {set RISATImgModeTmp "1"}
    if {$RISATImgMode == "MRS"}   {set RISATImgModeTmp "1"}
    if {$RISATImgMode == "MRS "}  {set RISATImgModeTmp "1"}
    if {$RISATImgModeTmp == "0"} {set configrisat "MODE"}
    if {$RISATnoPol == "1"} {set configrisat "1"}

    if {$configrisat == "true"} {
        if {$RISATnoPol == 2} {set ModeRISAT "dual1.1"}
        if {$RISATnoPol == 4} {set ModeRISAT "quad1.1"}

        if {$RISATDataFormat != $ModeRISAT} {
            set ErrorMessage "ERROR IN THE RISAT-PALSAR DATA MODE and/or LEVEL"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            MenuRAZ
            ClosePSPViewer
            CloseAllWidget
            if {$ActiveProgram == "RISAT"} {
                if {$RISATDataFormat == "dual1.1"} { TextEditorRunTrace "Close EO-SI Dual Pol" "b" }
                if {$RISATDataFormat == "quad1.1"} { TextEditorRunTrace "Close EO-SI" "b" }
                if {$ModeRISAT == "dual1.1"} { TextEditorRunTrace "Open EO-SI Dual Pol" "b" }
                if {$ModeRISAT == "quad1.1"} { TextEditorRunTrace "Open EO-SI" "b" }
                set RISATDataFormat $ModeRISAT
                $widget(MenubuttonRISAT) configure -background #FFFF00
                MenuEnvImp
                InitDataDir
                CheckEnvironnement
                }
            Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
    
            } else {
    
            TextEditorRunTrace "Process The Function Soft/data_import/risat_google.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$TMPRISATConfig\x22 -od \x22$RISATDirOutput\x22" "k"
            set f [ open "| Soft/data_import/risat_google.exe -if \x22$TMPRISATConfig\x22 -od \x22$RISATDirOutput\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set GoogleLatCenter $RISATLatCenter
            set GoogleLongCenter $RISATLonCenter
            set GoogleLat00 $RISATLat00
            set GoogleLong00 $RISATLon00
            set GoogleLat0N $RISATLat0N
            set GoogleLong0N $RISATLon0N
            set GoogleLatN0 $RISATLatN0
            set GoogleLongN0 $RISATLonN0
            set GoogleLatNN $RISATLatNN
            set GoogleLongNN $RISATLonNN
            $widget(Button449_20) configure -state normal

            $widget(Entry449_12) configure -disabledbackground #FFFFFF
            set RISATLeaderFile "$RISATDirInput/scene_"; append RISATLeaderFile $RISATPol1
            append RISATLeaderFile "/lea_01.001"
            if [file exists $RISATLeaderFile] {
                $widget(TitleFrame449_1) configure -state normal
                $widget(Label449_13) configure -state disable; $widget(Entry449_13) configure -disabledbackground $PSPBackgroundColor
                $widget(Label449_14) configure -state disable; $widget(Entry449_14) configure -disabledbackground $PSPBackgroundColor
                $widget(Label449_15) configure -state disable; $widget(Entry449_15) configure -disabledbackground $PSPBackgroundColor
                $widget(Label449_16) configure -state disable; $widget(Entry449_16) configure -disabledbackground $PSPBackgroundColor
                if {$RISATnoPol == "2"} {
                    if {$RISATPol1 == "RH" & $RISATPol2 == "RV"} {
                        set FileHH "$RISATDirInput/scene_RH/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_RV/dat_01.001"   
                        set PolarType "pp1"; set RISATMode "Compact - Pol"
                        set RISATCalfac1 $RISATCalPol1; set RISATCalfac2 $RISATCalPol2
                        }
                    if {$RISATPol1 == "RV" & $RISATPol2 == "RH"} {
                        set FileHH "$RISATDirInput/scene_RH/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_RV/dat_01.001"   
                        set PolarType "pp1"; set RISATMode "Compact - Pol"
                        set RISATCalfac1 $RISATCalPol2; set RISATCalfac2 $RISATCalPol1
                        }
                    if {$RISATPol1 == "LH" & $RISATPol2 == "LV"} {
                        set FileHH "$RISATDirInput/scene_LH/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_LV/dat_01.001"   
                        set PolarType "pp1"; set RISATMode "Compact - Pol"
                        set RISATCalfac1 $RISATCalPol1; set RISATCalfac2 $RISATCalPol2
                        }
                    if {$RISATPol1 == "LV" & $RISATPol2 == "LH"} {
                        set FileHH "$RISATDirInput/scene_LH/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_LV/dat_01.001"   
                        set PolarType "pp1"; set RISATMode "Compact - Pol"
                        set RISATCalfac1 $RISATCalPol2; set RISATCalfac2 $RISATCalPol1
                        }
                    if {$RISATPol1 == "HH" & $RISATPol2 == "HV"} {
                        set FileHH "$RISATDirInput/scene_HH/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_HV/dat_01.001"   
                        set PolarType "pp1"; set RISATMode "Dual - Pol (pp1)"
                        set RISATCalfac1 $RISATCalPol1; set RISATCalfac2 $RISATCalPol2
                        }
                    if {$RISATPol1 == "HV" & $RISATPol2 == "HH"} {
                        set FileHH "$RISATDirInput/scene_HH/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_HV/dat_01.001"   
                        set PolarType "pp1"; set RISATMode "Dual - Pol (pp1)"
                        set RISATCalfac1 $RISATCalPol2; set RISATCalfac2 $RISATCalPol1
                        }
                    if {$RISATPol1 == "VH" & $RISATPol2 == "VV"} {
                        set FileHH "$RISATDirInput/scene_VV/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_VH/dat_01.001"   
                        set PolarType "pp2"; set RISATMode "Dual - Pol (pp2)"
                        set RISATCalfac1 $RISATCalPol2; set RISATCalfac2 $RISATCalPol1
                        }
                    if {$RISATPol1 == "VV" & $RISATPol2 == "VH"} {
                        set FileHH "$RISATDirInput/scene_VV/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_VH/dat_01.001"   
                        set PolarType "pp2"; set RISATMode "Dual - Pol (pp2)"
                        set RISATCalfac1 $RISATCalPol1; set RISATCalfac2 $RISATCalPol2
                        }
                    if {$RISATPol1 == "HH" & $RISATPol2 == "VV"} {
                        set FileHH "$RISATDirInput/scene_HH/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_VV/dat_01.001"   
                        set PolarType "pp3"; set RISATMode "Dual - Pol (pp3)"
                        set RISATCalfac1 $RISATCalPol1; set RISATCalfac2 $RISATCalPol2
                        }
                    if {$RISATPol1 == "VV" & $RISATPol2 == "HH"} {
                        set FileHH "$RISATDirInput/scene_HH/dat_01.001"   
                        set FileHV "$RISATDirInput/scene_VV/dat_01.001"   
                        set PolarType "pp3"; set RISATMode "Dual - Pol (pp3)"
                        set RISATCalfac1 $RISATCalPol2; set RISATCalfac2 $RISATCalPol1
                        }
                    set RISATCalfac3 ""; set RISATCalfac4 ""
                    set config "true"
                    if [file exists $FileHH] { } else { set config "false" }
                    if [file exists $FileHV] { } else { set config "false" }
                    if {$config == "true"} {
                        $widget(TitleFrame449_2) configure -state normal
                        set FileInput1 $FileHH
                        $widget(Label449_13) configure -state normal; $widget(Entry449_13) configure -disabledbackground #FFFFFF
                        set FileInput2 $FileHV
                        $widget(Label449_14) configure -state normal; $widget(Entry449_14) configure -disabledbackground #FFFFFF
                        } else {
                        set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""
                        set VarError ""
                        set ErrorMessage "THE IMAGE DATA FILES DO NOT EXIST" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
                        }
                    }
        
                if {$RISATnoPol == "4"} {
                    set FileHH "$RISATDirInput/scene_HH/dat_01.001"   
                    set FileHV "$RISATDirInput/scene_HV/dat_01.001"   
                    set FileVH "$RISATDirInput/scene_VH/dat_01.001"   
                    set FileVV "$RISATDirInput/scene_VV/dat_01.001"   
                    set RISATCalfac1 $RISATCalPol1; set RISATCalfac2 $RISATCalPol2
                    set RISATCalfac3 $RISATCalPol3; set RISATCalfac4 $RISATCalPol4
                    set config "true"
                    if [file exists $FileHH] { } else { set config "false" }
                    if [file exists $FileHV] { } else { set config "false" }
                    if [file exists $FileVH] { } else { set config "false" }
                    if [file exists $FileVV] { } else { set config "false" }
                    if {$config == "true"} {
                        set PolarType "full";  set RISATMode "Quad - Pol"
                        $widget(TitleFrame449_2) configure -state normal
                        set FileInput1 $FileHH
                        $widget(Label449_13) configure -state normal; $widget(Entry449_13) configure -disabledbackground #FFFFFF
                        set FileInput2 $FileVH
                        $widget(Label449_14) configure -state normal; $widget(Entry449_14) configure -disabledbackground #FFFFFF
                        set FileInput3 $FileHV
                        $widget(Label449_15) configure -state normal; $widget(Entry449_15) configure -disabledbackground #FFFFFF
                        set FileInput4 $FileVV
                        $widget(Label449_16) configure -state normal; $widget(Entry449_16) configure -disabledbackground #FFFFFF
                        $widget(Button449_9) configure -state normal
                        } else {
                        set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""
                        set VarError ""
                        set ErrorMessage "THE IMAGE DATA FILES DO NOT EXIST" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
                        }
                   }

                set RISATFileInputFlag 0

                DeleteFile  $TMPRISATConfig

                TextEditorRunTrace "Process The Function Soft/data_import/risat_header.exe" "k"
                TextEditorRunTrace "Arguments: -od \x22$RISATDirOutput\x22 -ilf \x22$RISATLeaderFile\x22 -iif \x22$FileInput1\x22 -ocf \x22$TMPRISATConfig\x22" "k"
                set f [ open "| Soft/data_import/risat_header.exe -od \x22$RISATDirOutput\x22 -ilf \x22$RISATLeaderFile\x22 -iif \x22$FileInput1\x22 -ocf \x22$TMPRISATConfig\x22" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WaitUntilCreated $TMPRISATConfig

                set f [open $TMPRISATConfig r]
                gets $f tmp1; gets $f tmp2; gets $f tmp3
                gets $f tmp4; gets $f tmp5; gets $f tmp6
                gets $f tmp7; gets $f tmp8;
                close $f
                set f [open $TMPRISATConfig w]
                puts $f $tmp1; puts $f $tmp2; puts $f $tmp3
                puts $f $tmp4; puts $f $tmp5; puts $f $tmp6
                puts $f $tmp7; puts $f $tmp8;
                puts $f $tmp3; puts $f "inc_angle"; puts $f $RISATincang
                puts $f $tmp3; puts $f "cal_fac_pol1"; puts $f $RISATCalfac1
                puts $f $tmp3; puts $f "cal_fac_pol2"; puts $f $RISATCalfac2
                puts $f $tmp3; puts $f "cal_fac_pol3"; puts $f $RISATCalfac3
                puts $f $tmp3; puts $f "cal_fac_pol4"; puts $f $RISATCalfac4
                close $f

                set NligFullSize $RISATscans; set NcolFullSize $RISATpixels
                set TestVarName(0) "Initial Number of Rows"; set TestVarType(0) "int"; set TestVarValue(0) $NligFullSize; set TestVarMin(0) "0"; set TestVarMax(0) ""
                set TestVarName(1) "Initial Number of Cols"; set TestVarType(1) "int"; set TestVarValue(1) $NcolFullSize; set TestVarMin(1) "0"; set TestVarMax(1) ""
                TestVar 2
                if {$TestVarError == "ok"} {
                    $widget(TitleFrame449_3) configure -state normal
                    $widget(Entry449_25) configure -disabledbackground #FFFFFF
                    set RISATGridFile "$RISATDirInput/"; append RISATGridFile $RISATSceneID
                    append RISATGridFile "_"; append RISATGridFile "$RISATPol1"; append RISATGridFile "_L1_SlantRange_grid.txt"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/data_import/risat_inc_angle_extract.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$RISATGridFile\x22 -od \x22$RISATDirOutput\x22 -fnr $NligFullSize -fnc $NcolFullSize" "k"
                    set f [ open "| Soft/data_import/risat_inc_angle_extract.exe -if \x22$RISATGridFile\x22 -od \x22$RISATDirOutput\x22 -fnr $NligFullSize -fnc $NcolFullSize" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    set RISATIncAngFile "$RISATDirOutput/incidence_angle.bin"
                    EnviWriteConfig $RISATIncAngFile $NligFullSize $NcolFullSize 4
                    set RISATFileInputFlag 1
                    set NligInit 1; set NligEnd $NligFullSize
                    set NcolInit 1; set NcolEnd $NcolFullSize
                    set NligFullSizeInput $NligFullSize
                    set NcolFullSizeInput $NcolFullSize
                    $widget(Label449_1) configure -state normal; $widget(Entry449_1) configure -disabledbackground #FFFFFF
                    $widget(Label449_2) configure -state normal; $widget(Entry449_2) configure -disabledbackground #FFFFFF
                    $widget(Button449_10) configure -state normal
                    } else {
                    set ErrorMessage "ROWS / COLS EXTRACTION ERROR"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    set NligInit ""; set NligEnd ""; set NligFullSize ""; set NcolInit ""; set NcolEnd ""; set NcolFullSize ""
                    set NligFullSizeInput ""; set NcolFullSizeInput ""
                    set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""; 
                    Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
                    }
                } else {
                set NligInit ""; set NligEnd ""; set NligFullSize ""; set NcolInit ""; set NcolEnd ""; set NcolFullSize ""
                set NligFullSizeInput ""; set NcolFullSizeInput ""
                set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 "" 
                set VarError ""
                set ErrorMessage "THE SAR LEADER FILE DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
                }
            }
        } else {
        set VarError ""
        if {$configrisat == "CEOS"} {set ErrorMessage "THIS IS NOT A RISAT CEOS PRODUCT"}
        if {$configrisat == "SLC"} {set ErrorMessage "THIS IS NOT A RISAT LEVEL-1 SLC PRODUCT"}
        if {$configrisat == "MODE"} {set ErrorMessage "THIS IS NOT A RISAT CFRS1 or FRS1 or MRS PRODUCT"}
        if {$configrisat == "1"} {set ErrorMessage "THIS IS NOT A RISAT POLARIMETRIC PRODUCT"}
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set NligInit ""; set NligEnd ""; set NligFullSize ""; set NcolInit ""; set NcolEnd ""; set NcolFullSize ""
        set NligFullSizeInput ""; set NcolFullSizeInput ""
        set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 "" 
        Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
        }
      } else {
      set VarError ""
      set ErrorMessage "THIS IS NOT A RISAT LEVEL-1 SLC PRODUCT"
      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
      tkwait variable VarError
      set NligInit ""; set NligEnd ""; set NligFullSize ""; set NcolInit ""; set NcolEnd ""; set NcolFullSize ""
      set NligFullSizeInput ""; set NcolFullSizeInput ""
      set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 "" 
      Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
      }
    } else {
    set VarError ""
    set ErrorMessage "THE RISAT BAND-META FILE DOES NOT EXIST"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set NligInit ""; set NligEnd ""; set NligFullSize ""; set NcolInit ""; set NcolEnd ""; set NcolFullSize ""
    set NligFullSizeInput ""; set NcolFullSizeInput ""
    set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 "" 
    Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
    }
}} \
        -cursor {} -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_4_0.cpd69" "Button220" vTcl:WidgetProc "Toplevel449" 1
    bindtags $site_4_0.cpd69 "$site_4_0.cpd69 Button $top all _vTclBalloon"
    bind $site_4_0.cpd69 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_4_0.cpd70 \
        \
        -command {global FileName VarError ErrorMessage RISATDirOutput

set RISATFile "$RISATDirOutput/GEARTH_POLY.kml"
if [file exists $RISATFile] {
    GoogleEarth $RISATFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -pady 2 
    vTcl:DefineAlias "$site_4_0.cpd70" "Button449_20" vTcl:WidgetProc "Toplevel449" 1
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    frame $site_3_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra90" "Frame31" vTcl:WidgetProc "Toplevel449" 1
    set site_4_0 $site_3_0.fra90
    frame $site_4_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra91" "Frame32" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.fra91
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame34" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.fra93
    label $site_6_0.cpd94 \
        -text {Scene ID   } 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_10" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATSceneID 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_10" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd97" "Frame35" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd97
    label $site_6_0.cpd94 \
        -text Mode 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_11" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATMode 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_11" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd98" "Frame33" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd98
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame36" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.fra93
    label $site_6_0.cpd94 \
        -text Mode 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_17" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATImgMode -width 6 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_17" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd97" "Frame37" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd97
    label $site_6_0.cpd94 \
        -text Level 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_18" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATProcLevel -width 6 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_18" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd99 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd99" "Frame38" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd99
    label $site_6_0.cpd94 \
        -text {Inc Ang} 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_19" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATincang -width 6 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_19" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd66" "Frame39" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd66
    label $site_6_0.cpd94 \
        -text Format 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_20" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATImgFormat -width 6 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_20" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd99 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame40" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd67
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame41" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.fra93
    label $site_6_0.cpd94 \
        -text {Res Rg} 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_21" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATResRg -width 6 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_21" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd97" "Frame42" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd97
    label $site_6_0.cpd94 \
        -text {Res Az} 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_22" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATResAz -width 6 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_22" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd99 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd99" "Frame43" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd99
    label $site_6_0.cpd94 \
        -text {Pix Az} 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_24" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATPixAz -width 6 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_24" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd66" "Frame44" vTcl:WidgetProc "Toplevel449" 1
    set site_6_0 $site_5_0.cpd66
    label $site_6_0.cpd94 \
        -text {Pix Rg} 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label449_23" vTcl:WidgetProc "Toplevel449" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RISATPixRg -width 6 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry449_23" vTcl:WidgetProc "Toplevel449" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd99 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra91 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.fra68 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.fra90 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {SAR Incidence Angle Grid File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame449_3" vTcl:WidgetProc "Toplevel449" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame19" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd92
    label $site_5_0.lab91 \
        -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label9" vTcl:WidgetProc "Toplevel449" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RISATGridFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry449_25" vTcl:WidgetProc "Toplevel449" 1
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd90 \
        -ipad 0 -text {SAR Leader File} 
    vTcl:DefineAlias "$top.cpd90" "TitleFrame449_1" vTcl:WidgetProc "Toplevel449" 1
    bind $top.cpd90 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd90 getframe]
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame14" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd92
    label $site_5_0.lab91 \
        -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label8" vTcl:WidgetProc "Toplevel449" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RISATLeaderFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry449_12" vTcl:WidgetProc "Toplevel449" 1
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd92 \
        -ipad 0 -text {SAR Image Files} 
    vTcl:DefineAlias "$top.cpd92" "TitleFrame449_2" vTcl:WidgetProc "Toplevel449" 1
    bind $top.cpd92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd92 getframe]
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd92
    label $site_5_0.lab91 \
        -text s11 -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label449_13" vTcl:WidgetProc "Toplevel449" 1
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry449_13" vTcl:WidgetProc "Toplevel449" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd97" "Frame16" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd97
    label $site_5_0.lab91 \
        -text s12 -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label449_14" vTcl:WidgetProc "Toplevel449" 1
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry449_14" vTcl:WidgetProc "Toplevel449" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd100 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd100" "Frame17" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd100
    label $site_5_0.lab91 \
        -text s21 -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label449_15" vTcl:WidgetProc "Toplevel449" 1
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput3 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry449_15" vTcl:WidgetProc "Toplevel449" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd101 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd101" "Frame18" vTcl:WidgetProc "Toplevel449" 1
    set site_5_0 $site_4_0.cpd101
    label $site_5_0.lab91 \
        -text s22 -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label449_16" vTcl:WidgetProc "Toplevel449" 1
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput4 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry449_16" vTcl:WidgetProc "Toplevel449" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd101 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra57 \
        -borderwidth 2 -relief groove -height 76 -width 200 
    vTcl:DefineAlias "$top.fra57" "Frame" vTcl:WidgetProc "Toplevel449" 1
    set site_3_0 $top.fra57
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame107" vTcl:WidgetProc "Toplevel449" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label449_1" vTcl:WidgetProc "Toplevel449" 1
    entry $site_4_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent41" "Entry449_1" vTcl:WidgetProc "Toplevel449" 1
    label $site_4_0.lab42 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_4_0.lab42" "Label449_2" vTcl:WidgetProc "Toplevel449" 1
    entry $site_4_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent43" "Entry449_2" vTcl:WidgetProc "Toplevel449" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent41 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.lab42 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent43 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.fra39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side bottom 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel449" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile RISATFileInputFlag
global VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError

if {$OpenDirFile == 0} {
    if {$RISATFileInputFlag == 1} {
        set ErrorMessage ""
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
        }
    }} \
        -cursor {} -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button449_10" vTcl:WidgetProc "Toplevel449" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/RISAT_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel449" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel449); TextEditorRunTrace "Close Window RISAT Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel449" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel the Function}
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
    pack $top.lab49 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra88 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd90 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra57 \
        -in $top -anchor center -expand 0 -fill none -pady 3 -side top 
    pack $top.fra59 \
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
Window show .top449

main $argc $argv
