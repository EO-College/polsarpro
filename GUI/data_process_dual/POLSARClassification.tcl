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
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top311
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd79
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
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
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
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra28 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra28
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
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
    namespace eval ::widgets::$base.fra82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra82
    namespace eval ::widgets::$site_3_0.rad83 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad84 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.che72 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.che72 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra39
    namespace eval ::widgets::$site_6_0.lab33 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra40
    namespace eval ::widgets::$site_6_0.ent34 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.ent37 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra39
    namespace eval ::widgets::$site_6_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra40
    namespace eval ::widgets::$site_6_0.ent36 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.ent37 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.che75 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit84 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit84 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra90
    namespace eval ::widgets::$site_5_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra91
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra92 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra92
    namespace eval ::widgets::$site_6_0.cpd98 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd99 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.but78 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.but79 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra42 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra42
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m102 {
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
            vTclWindow.top311
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
    wm geometry $top 200x200+66+66; update
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

proc vTclWindow.top311 {base} {
    if {$base == ""} {
        set base .top311
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
    wm geometry $top 500x420+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: POLSAR - Unsupervised Classification"
    vTcl:DefineAlias "$top" "Toplevel311" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame4" vTcl:WidgetProc "Toplevel311" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel311" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable POLSARDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel311" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button42" vTcl:WidgetProc "Toplevel311" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel311" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable POLSAROutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel311" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -padx 1 -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel311" 1
    entry $site_6_0.cpd74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable POLSAROutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd74" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel311" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd80 \
        \
        -command {global DirName POLSARDirInput POLSAROutputDir

set POLSARDirOutputTmp $POLSAROutputDir
set DirName ""
OpenDir $POLSARDirInput "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set POLSAROutputDir $DirName
    } else {
    set POLSAROutputDir $POLSARDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    bindtags $site_6_0.cpd80 "$site_6_0.cpd80 Button $top all _vTclBalloon"
    bind $site_6_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra28 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra28" "Frame9" vTcl:WidgetProc "Toplevel311" 1
    set site_3_0 $top.fra28
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel311" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel311" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel311" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel311" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel311" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel311" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel311" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel311" 1
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
    frame $top.fra82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra82" "Frame8" vTcl:WidgetProc "Toplevel311" 1
    set site_3_0 $top.fra82
    radiobutton $site_3_0.rad83 \
        \
        -command {global POLSARDirInput POLSARDirOutput POLSAROutputDir POLSAROutputSubDir DataDirChannel1 DataDirChannel2

$widget(TitleFrame311_1) configure -state normal
$widget(TitleFrame311_2) configure -state normal
$widget(TitleFrame311_3) configure -state normal
$widget(Checkbutton311_1) configure -state normal
$widget(Checkbutton311_3) configure -state normal
if {$POLSAROutputSubDir == ""} {
    set POLSARDirInput $DataDirChannel1
    set POLSARDirOutput $DataDirChannel1
    set POLSAROutputDir $DataDirChannel1
    }} \
        -text {Master Channel} -value 1 -variable MasterSlaveChannel 
    vTcl:DefineAlias "$site_3_0.rad83" "Radiobutton1" vTcl:WidgetProc "Toplevel311" 1
    radiobutton $site_3_0.rad84 \
        \
        -command {global POLSARDirInput POLSARDirOutput POLSAROutputDir POLSAROutputSubDir DataDirChannel1 DataDirChannel2

$widget(TitleFrame311_1) configure -state normal
$widget(TitleFrame311_2) configure -state normal
$widget(TitleFrame311_3) configure -state normal
$widget(Checkbutton311_1) configure -state normal
$widget(Checkbutton311_3) configure -state normal
if {$POLSAROutputSubDir == ""} {
    set POLSARDirInput $DataDirChannel2
    set POLSARDirOutput $DataDirChannel2
    set POLSAROutputDir $DataDirChannel2
    }} \
        -text SlaveChannel -value 2 -variable MasterSlaveChannel 
    vTcl:DefineAlias "$site_3_0.rad84" "Radiobutton2" vTcl:WidgetProc "Toplevel311" 1
    pack $site_3_0.rad83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.rad84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit81 \
        -ipad 0 -text {H / A / Alpha Decomposition Files} 
    vTcl:DefineAlias "$top.tit81" "TitleFrame311_1" vTcl:WidgetProc "Toplevel311" 1
    bind $top.tit81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit81 getframe]
    checkbutton $site_4_0.che72 \
        \
        -command {global HAAlpFlag HAAlpNwinL HAAlpNwinC BMPHAAlp

if {$HAAlpFlag == 1} {
    set HAAlpNwinL 7
    set HAAlpNwinC 7
    set BMPHAAlp 1
    $widget(Label311_1) configure -state normal
    $widget(Entry311_1) configure -state normal
    $widget(Entry311_1) configure -disabledbackground #FFFFFF
    $widget(Label311_1a) configure -state normal
    $widget(Entry311_1a) configure -state normal
    $widget(Entry311_1a) configure -disabledbackground #FFFFFF
    $widget(Checkbutton311_2) configure -state normal
    } else {
    set HAAlpNwinL ""
    set HAAlpNwinC ""
    set BMPHAAlp 0
    $widget(Label311_1) configure -state disable
    $widget(Entry311_1) configure -state disable
    $widget(Entry311_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Label311_1a) configure -state disable
    $widget(Entry311_1a) configure -state disable
    $widget(Entry311_1a) configure -disabledbackground $PSPBackgroundColor
    $widget(Checkbutton311_2) configure -state disable
    }} \
        -variable HAAlpFlag 
    vTcl:DefineAlias "$site_4_0.che72" "Checkbutton311_1" vTcl:WidgetProc "Toplevel311" 1
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame53" vTcl:WidgetProc "Toplevel311" 1
    set site_5_0 $site_4_0.cpd82
    label $site_5_0.cpd77 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_5_0.cpd77" "Label311_1" vTcl:WidgetProc "Toplevel311" 1
    entry $site_5_0.cpd76 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable HAAlpNwinL -width 5 
    vTcl:DefineAlias "$site_5_0.cpd76" "Entry311_1" vTcl:WidgetProc "Toplevel311" 1
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    checkbutton $site_4_0.cpd83 \
        -text BMP -variable BMPHAAlp 
    vTcl:DefineAlias "$site_4_0.cpd83" "Checkbutton311_2" vTcl:WidgetProc "Toplevel311" 1
    frame $site_4_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame59" vTcl:WidgetProc "Toplevel311" 1
    set site_5_0 $site_4_0.cpd67
    label $site_5_0.cpd77 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_5_0.cpd77" "Label311_1a" vTcl:WidgetProc "Toplevel311" 1
    entry $site_5_0.cpd76 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable HAAlpNwinC -width 5 
    vTcl:DefineAlias "$site_5_0.cpd76" "Entry311_1a" vTcl:WidgetProc "Toplevel311" 1
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.che72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd73 \
        -ipad 0 -text {Wishart H / A / Alpha Classification} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame311_2" vTcl:WidgetProc "Toplevel311" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    checkbutton $site_4_0.che72 \
        \
        -command {global WishartFlag BMPWishart WishartNwinL WishartNwinC WishartPourcentage WishartIteration 
global ColorMapWishart8 ColorMap9 ColorMapWishart16 IdentFlag COLORMAPDir

if {$WishartFlag == 1} {
    set BMPWishart 1
    set WishartNwinL 3
    set WishartNwinC 3
    set WishartPourcentage 10
    set WishartIteration 10
    $widget(Label311_2) configure -state normal
    $widget(Entry311_2) configure -state normal
    $widget(Entry311_2) configure -disabledbackground #FFFFFF
    $widget(Label311_3) configure -state normal
    $widget(Entry311_3) configure -state normal
    $widget(Entry311_3) configure -disabledbackground #FFFFFF
    $widget(Label311_4) configure -state normal
    $widget(Entry311_4) configure -state normal
    $widget(Entry311_4) configure -disabledbackground #FFFFFF
    $widget(Label311_4a) configure -state normal
    $widget(Entry311_4a) configure -state normal
    $widget(Entry311_4a) configure -disabledbackground #FFFFFF
    $widget(Checkbutton311_4) configure -state normal
    set ColorMapWishart8 "$COLORMAPDir/Wishart_ColorMap8.pal"
    $widget(Label311_5) configure -state normal
    $widget(Entry311_5) configure -state normal
    $widget(Entry311_5) configure -disabledbackground #FFFFFF
    $widget(Button311_1) configure -state normal
    $widget(Button311_2) configure -state normal
    set ColorMapWishart16 "$COLORMAPDir/Wishart_ColorMap16.pal"
    $widget(Label311_7) configure -state normal
    $widget(Entry311_7) configure -state normal
    $widget(Entry311_7) configure -disabledbackground #FFFFFF
    $widget(Button311_5) configure -state normal
    $widget(Button311_6) configure -state normal
    $widget(Checkbutton311_5) configure -state normal
    } else {
    set BMPWishart 0
    set WishartNwinL ""
    set WishartNwinC ""
    set WishartPourcentage ""
    set WishartIteration ""
    $widget(Label311_2) configure -state disable
    $widget(Entry311_2) configure -state disable
    $widget(Entry311_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Label311_3) configure -state disable
    $widget(Entry311_3) configure -state disable
    $widget(Entry311_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label311_4) configure -state disable
    $widget(Entry311_4) configure -state disable
    $widget(Entry311_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Label311_4a) configure -state disable
    $widget(Entry311_4a) configure -state disable
    $widget(Entry311_4a) configure -disabledbackground $PSPBackgroundColor
    $widget(Checkbutton311_4) configure -state disable
    set ColorMapWishart8 ""
    $widget(Label311_5) configure -state disable
    $widget(Entry311_5) configure -state disable
    $widget(Entry311_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Button311_1) configure -state disable
    $widget(Button311_2) configure -state disable
    set ColorMap9 ""
    $widget(Label311_6) configure -state disable
    $widget(Entry311_6) configure -state disable
    $widget(Entry311_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Button311_3) configure -state disable
    $widget(Button311_4) configure -state disable
    set ColorMapWishart16 ""
    $widget(Label311_7) configure -state disable
    $widget(Entry311_7) configure -state disable
    $widget(Entry311_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Button311_5) configure -state disable
    $widget(Button311_6) configure -state disable
    set IdentFlag 0
    $widget(Checkbutton311_5) configure -state disable
    }} \
        -variable WishartFlag 
    vTcl:DefineAlias "$site_4_0.che72" "Checkbutton311_3" vTcl:WidgetProc "Toplevel311" 1
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame54" vTcl:WidgetProc "Toplevel311" 1
    set site_5_0 $site_4_0.cpd82
    frame $site_5_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.fra39" "Frame52" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.fra39
    label $site_6_0.lab33 \
        -padx 1 -text {% of Pixels Switching Class} 
    vTcl:DefineAlias "$site_6_0.lab33" "Label311_2" vTcl:WidgetProc "Toplevel311" 1
    label $site_6_0.lab35 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_6_0.lab35" "Label311_4" vTcl:WidgetProc "Toplevel311" 1
    pack $site_6_0.lab33 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.lab35 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_5_0.fra40" "Frame55" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.fra40
    entry $site_6_0.ent34 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartPourcentage -width 5 
    vTcl:DefineAlias "$site_6_0.ent34" "Entry311_2" vTcl:WidgetProc "Toplevel311" 1
    entry $site_6_0.ent37 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartNwinL -width 5 
    vTcl:DefineAlias "$site_6_0.ent37" "Entry311_4" vTcl:WidgetProc "Toplevel311" 1
    pack $site_6_0.ent34 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.ent37 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra39 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.fra40 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    checkbutton $site_4_0.cpd83 \
        -text BMP -variable BMPWishart 
    vTcl:DefineAlias "$site_4_0.cpd83" "Checkbutton311_4" vTcl:WidgetProc "Toplevel311" 1
    frame $site_4_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame56" vTcl:WidgetProc "Toplevel311" 1
    set site_5_0 $site_4_0.cpd66
    frame $site_5_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.fra39" "Frame57" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.fra39
    label $site_6_0.lab34 \
        -padx 1 -text {Maximum Number of Iterations} 
    vTcl:DefineAlias "$site_6_0.lab34" "Label311_3" vTcl:WidgetProc "Toplevel311" 1
    label $site_6_0.lab35 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_6_0.lab35" "Label311_4a" vTcl:WidgetProc "Toplevel311" 1
    pack $site_6_0.lab34 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.lab35 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_5_0.fra40" "Frame58" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.fra40
    entry $site_6_0.ent36 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartIteration -width 5 
    vTcl:DefineAlias "$site_6_0.ent36" "Entry311_3" vTcl:WidgetProc "Toplevel311" 1
    entry $site_6_0.ent37 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartNwinC -width 5 
    vTcl:DefineAlias "$site_6_0.ent37" "Entry311_4a" vTcl:WidgetProc "Toplevel311" 1
    pack $site_6_0.ent36 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.ent37 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra39 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.fra40 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.che72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame311_1" vTcl:WidgetProc "Toplevel311" 1
    set site_3_0 $top.fra74
    checkbutton $site_3_0.che75 \
        \
        -command {global WishartFlag ColorMap9 ColorMapWishart16 IdentFlag COLORMAPDir

if {$IdentFlag == 1} {
    set ColorMap9 "$COLORMAPDir/Planes_H_A_Alpha_ColorMap9.pal"
    $widget(Label311_6) configure -state normal
    $widget(Entry311_6) configure -state normal
    $widget(Entry311_6) configure -disabledbackground #FFFFFF
    $widget(Button311_3) configure -state normal
    $widget(Button311_4) configure -state normal
    set ColorMapWishart16 "$COLORMAPDir/Wishart_ColorMap16.pal"
    $widget(Label311_7) configure -state normal
    $widget(Entry311_7) configure -state normal
    $widget(Entry311_7) configure -disabledbackground #FFFFFF
    $widget(Button311_5) configure -state normal
    $widget(Button311_6) configure -state normal
    } else {
    set ColorMap9 ""
    $widget(Label311_6) configure -state disable
    $widget(Entry311_6) configure -state disable
    $widget(Entry311_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Button311_3) configure -state disable
    $widget(Button311_4) configure -state disable
    if {$WishartFlag == 0} {
        set ColorMapWishart16 ""
        $widget(Label311_7) configure -state disable
        $widget(Entry311_7) configure -state disable
        $widget(Entry311_7) configure -disabledbackground $PSPBackgroundColor
        $widget(Button311_5) configure -state disable
        $widget(Button311_6) configure -state disable
        }
    }} \
        -text {Basic Scattering Mechanism Identification} -variable IdentFlag 
    vTcl:DefineAlias "$site_3_0.che75" "Checkbutton311_5" vTcl:WidgetProc "Toplevel311" 1
    pack $site_3_0.che75 \
        -in $site_3_0 -anchor center -expand 0 -fill none -pady 5 -side left 
    TitleFrame $top.tit84 \
        -ipad 0 -text {Color Maps} 
    vTcl:DefineAlias "$top.tit84" "TitleFrame311_3" vTcl:WidgetProc "Toplevel311" 1
    bind $top.tit84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit84 getframe]
    frame $site_4_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra90" "Frame1" vTcl:WidgetProc "Toplevel311" 1
    set site_5_0 $site_4_0.fra90
    frame $site_5_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra91" "Frame2" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.fra91
    label $site_6_0.cpd94 \
        -text {ColorMap 8  } 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label311_5" vTcl:WidgetProc "Toplevel311" 1
    label $site_6_0.cpd78 \
        -text {ColorMap 9  } 
    vTcl:DefineAlias "$site_6_0.cpd78" "Label311_6" vTcl:WidgetProc "Toplevel311" 1
    label $site_6_0.cpd95 \
        -text {ColorMap 16} 
    vTcl:DefineAlias "$site_6_0.cpd95" "Label311_7" vTcl:WidgetProc "Toplevel311" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra92 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra92" "Frame3" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.fra92
    button $site_6_0.cpd98 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd98 {global ColorMapWishart8 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient .top38 $PSPTopLevel
    }

set ColorMapNumber 8
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMapWishart8] {
    set f [open $ColorMapWishart8 r]
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
set ColorMapIn $ColorMapWishart8
set ColorMapOut $ColorMapWishart8
WidgetShowFromWidget $widget(Toplevel311) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapWishart8 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd98" "Button311_2" vTcl:WidgetProc "Toplevel311" 1
    bindtags $site_6_0.cpd98 "$site_6_0.cpd98 Button $top all _vTclBalloon"
    bind $site_6_0.cpd98 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    button $site_6_0.cpd79 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd79 {global ColorMap9 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient .top38 $PSPTopLevel
    }

set ColorMapNumber 9
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMap9] {
    set f [open $ColorMap9 r]
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
set ColorMapIn $ColorMap9
set ColorMapOut $ColorMap9
WidgetShowFromWidget $widget(Toplevel311) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMap9 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd79" "Button311_4" vTcl:WidgetProc "Toplevel311" 1
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    button $site_6_0.cpd99 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd99 {global ColorMapWishart16 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient .top38 $PSPTopLevel
    }

set ColorMapNumber 16
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
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
WidgetShowFromWidget $widget(Toplevel311) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapWishart16 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd99" "Button311_6" vTcl:WidgetProc "Toplevel311" 1
    bindtags $site_6_0.cpd99 "$site_6_0.cpd99 Button $top all _vTclBalloon"
    bind $site_6_0.cpd99 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.cpd98 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd99 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame6" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.cpd77
    button $site_6_0.but78 \
        \
        -command {global FileName POLSARDirInput ColorMapWishart8

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$POLSARDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapWishart8 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but78" "Button311_1" vTcl:WidgetProc "Toplevel311" 1
    bindtags $site_6_0.but78 "$site_6_0.but78 Button $top all _vTclBalloon"
    bind $site_6_0.but78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.cpd81 \
        \
        -command {global FileName POLSARDirInput ColorMap9

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$POLSARDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMap9 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd81" "Button311_3" vTcl:WidgetProc "Toplevel311" 1
    bindtags $site_6_0.cpd81 "$site_6_0.cpd81 Button $top all _vTclBalloon"
    bind $site_6_0.cpd81 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.but79 \
        \
        -command {global FileName POLSARDirInput ColorMapWishart16

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$POLSARDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapWishart16 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but79" "Button311_5" vTcl:WidgetProc "Toplevel311" 1
    bindtags $site_6_0.but79 "$site_6_0.but79 Button $top all _vTclBalloon"
    bind $site_6_0.but79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.but78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.but79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame5" vTcl:WidgetProc "Toplevel311" 1
    set site_6_0 $site_5_0.fra93
    entry $site_6_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapWishart8 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd96" "Entry311_5" vTcl:WidgetProc "Toplevel311" 1
    entry $site_6_0.cpd80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMap9 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd80" "Entry311_6" vTcl:WidgetProc "Toplevel311" 1
    entry $site_6_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapWishart16 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd97" "Entry311_7" vTcl:WidgetProc "Toplevel311" 1
    pack $site_6_0.cpd96 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra91 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.fra92 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.fra90 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra42 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame20" vTcl:WidgetProc "Toplevel311" 1
    set site_3_0 $top.fra42
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global POLSARDirInput POLSARDirOutput POLSAROutputDir POLSAROutputSubDir
global HAAlpFlag WishartFlag IdentFlag HAAlpNwinL HAAlpNwinC BMPHAAlp WishartNwinL WishartNwinC BMPWishart 
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine
global BMPDirInput OpenDirFile IdentFile MasterSlaveChannel
global ColorMapWishart8 ColorMap9 ColorMapWishart16 TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config "false"
if {$HAAlpFlag =="1"} { set config "true" }
if {$WishartFlag =="1"} { set config "true" }
if {$IdentFlag =="1"} { set config "true" }

if {"$config"=="true"} {

    set POLSARDirOutput $POLSAROutputDir
    if {$POLSAROutputSubDir != ""} {append POLSARDirOutput "/$POLSAROutputSubDir"}

    #####################################################################
    #Create Directory
    set POLSARDirOutput [PSPCreateDirectoryMask $POLSARDirOutput $POLSAROutputDir $POLSARDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {

        set ClassificationInputFile ""

        if {$HAAlpFlag == "1"} {
            set TestVarName(0) "Window Size Row - H/A/Alpha Decomposition"; set TestVarType(0) "int"; set TestVarValue(0) $HAAlpNwinL; set TestVarMin(0) "1"; set TestVarMax(0) "1000"
            set TestVarName(1) "Window Size Col - H/A/Alpha Decomposition"; set TestVarType(1) "int"; set TestVarValue(1) $HAAlpNwinC; set TestVarMin(1) "1"; set TestVarMax(1) "1000"
            TestVar 2
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]
                set MaskCmd ""
                set MaskFile "$POLSARDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set Fonction "Creation of all the Binary Data Files"
                set Fonction2 "of the H / A / Alpha Decomposition"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/data_process_dual/h_a_alpha_decomposition.exe" "k"
                if {$POLSAROutputSubDir == ""} {
                    TextEditorRunTrace "Arguments: -idm \x22$DataDirChannel1\x22 -ids \x22$DataDirChannel2\x22 -od \x22$POLSARDirOutput\x22 -iodf S2T6 -nwr $HAAlpNwinL -nwc $HAAlpNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ms $MasterSlaveChannel  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/bin/data_process_dual/h_a_alpha_decomposition.exe -idm \x22$DataDirChannel1\x22 -ids \x22$DataDirChannel2\x22 -od \x22$POLSARDirOutput\x22 -iodf S2T6 -nwr $HAAlpNwinL -nwc $HAAlpNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ms $MasterSlaveChannel  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    }
                if {$POLSAROutputSubDir == "T6"} {
                    TextEditorRunTrace "Arguments: -id \x22$DataDirChannel1\x22 -od \x22$POLSARDirOutput\x22 -iodf T6 -nwr $HAAlpNwinL -nwc $HAAlpNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ms $MasterSlaveChannel  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                    set f [ open "| Soft/bin/data_process_dual/h_a_alpha_decomposition.exe -id \x22$DataDirChannel1\x22 -od \x22$POLSARDirOutput\x22 -iodf T6 -nwr $HAAlpNwinL -nwc $HAAlpNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ms $MasterSlaveChannel  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                    }
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if [file exists "$POLSARDirOutput/p1.bin"] {EnviWriteConfig "$POLSARDirOutput/p1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLSARDirOutput/p2.bin"] {EnviWriteConfig "$POLSARDirOutput/p2.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLSARDirOutput/alpha1.bin"] {EnviWriteConfig "$POLSARDirOutput/alpha1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLSARDirOutput/alpha2.bin"] {EnviWriteConfig "$POLSARDirOutput/alpha2.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLSARDirOutput/beta1.bin"] {EnviWriteConfig "$POLSARDirOutput/beta1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLSARDirOutput/beta2.bin"] {EnviWriteConfig "$POLSARDirOutput/beta2.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLSARDirOutput/alpha.bin"] {EnviWriteConfig "$POLSARDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLSARDirOutput/entropy.bin"] {EnviWriteConfig "$POLSARDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLSARDirOutput/anisotropy.bin"] {EnviWriteConfig "$POLSARDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
                #Update the Nlig/Ncol of the new image after processing
                set NligInit 1
                set NcolInit 1
                set NligEnd $FinalNlig
                set NcolEnd $FinalNcol
        
                if {$BMPHAAlp == "1"} {
                    if [file exists "$POLSARDirOutput/p1.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/p1.bin"
                        set BMPFileOutput "$POLSARDirOutput/p1.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE p1.bin FILE" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if [file exists "$POLSARDirOutput/p2.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/p2.bin"
                        set BMPFileOutput "$POLSARDirOutput/p2.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE p2.bin FILE" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if [file exists "$POLSARDirOutput/alpha1.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/alpha1.bin"
                        set BMPFileOutput "$POLSARDirOutput/alpha1.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE alpha1.bin FILE" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if [file exists "$POLSARDirOutput/alpha2.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/alpha2.bin"
                        set BMPFileOutput "$POLSARDirOutput/alpha2.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE alpha2.bin FILE" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if [file exists "$POLSARDirOutput/beta1.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/beta1.bin"
                        set BMPFileOutput "$POLSARDirOutput/beta1.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE alpha2.bin FILE" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if [file exists "$POLSARDirOutput/beta2.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/beta2.bin"
                        set BMPFileOutput "$POLSARDirOutput/beta2.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if [file exists "$POLSARDirOutput/alpha.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/alpha.bin"
                        set BMPFileOutput "$POLSARDirOutput/alpha.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE alpha.bin FILE" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if [file exists "$POLSARDirOutput/entropy.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/entropy.bin"
                        set BMPFileOutput "$POLSARDirOutput/entropy.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE entropy.bin FILE" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    if [file exists "$POLSARDirOutput/anisotropy.bin"] {
                        set BMPDirInput $POLSARDirOutput
                        set BMPFileInput "$POLSARDirOutput/anisotropy.bin"
                        set BMPFileOutput "$POLSARDirOutput/anisotropy.bmp"
                        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO OPEN THE anisotropy.bin FILE" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    }
                    # BMPHAAlp
                }
                #TestVar
            }
            # HAAlpFlag


        if {$WishartFlag == "1"} {
            set TestVarName(0) "Window Size Row - Classification"; set TestVarType(0) "int"; set TestVarValue(0) $WishartNwinL; set TestVarMin(0) "1"; set TestVarMax(0) "1000"
            set TestVarName(1) "Pourcentage"; set TestVarType(1) "float"; set TestVarValue(1) $WishartPourcentage; set TestVarMin(1) "0"; set TestVarMax(1) "100"
            set TestVarName(2) "Iteration"; set TestVarType(2) "int"; set TestVarValue(2) $WishartIteration; set TestVarMin(2) "1"; set TestVarMax(2) "100"
            set TestVarName(3) "ColorMap8"; set TestVarType(3) "file"; set TestVarValue(3) $ColorMapWishart8; set TestVarMin(3) ""; set TestVarMax(3) ""
            set TestVarName(4) "ColorMap16"; set TestVarType(4) "file"; set TestVarValue(4) $ColorMapWishart16; set TestVarMin(4) ""; set TestVarMax(4) ""
            set TestVarName(5) "Window Size Col - Classification"; set TestVarType(5) "int"; set TestVarValue(5) $WishartNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
            TestVar 6
            if {$TestVarError == "ok"} {
                set config "true"
                if [file exists "$POLSARDirOutput/entropy.bin"] {
                    } else {
                    set config "false"
                    set VarError ""
                    set ErrorMessage "THE FILE Entropy DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    } 
                if [file exists "$POLSARDirOutput/alpha.bin"] {
                    } else {
                    set config "false"
                    set VarError ""
                    set ErrorMessage "THE FILE Alpha DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    } 
                if [file exists "$POLSARDirOutput/anisotropy.bin"] {
                    } else {
                    set config "false"
                    set VarError ""
                    set ErrorMessage "THE FILE Anisotropy DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    } 
                if {"$config"=="true"} {
                    set HFile "$POLSARDirOutput/entropy.bin"
                    set AlpFile "$POLSARDirOutput/alpha.bin"
                    set AFile "$POLSARDirOutput/anisotropy.bin"
                    set MaskCmd ""
                    set MaskFile "$POLSARDirInput/mask_valid_pixels.bin"
                    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                    set Fonction "Creation of all the Binary Data and BMP Files"
                    set Fonction2 "of the WISHART - H/A/Alpha Classification"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    if {$POLSAROutputSubDir == ""} {
                        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/wishart_h_a_alpha_classifier.exe" "k"
                        TextEditorRunTrace "Arguments: -id \x22$POLSARDirInput\x22 -od \x22$POLSARDirOutput\x22 -iodf S2 -nwr $WishartNwinL -nwc $WishartNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct $WishartPourcentage -nit $WishartIteration -bmp $BMPWishart -co8 \x22$ColorMapWishart8\x22 -co16 \x22$ColorMapWishart16\x22 -hf \x22$HFile\x22 -af \x22$AFile\x22 -alf \x22$AlpFile\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                        set f [ open "| Soft/bin/data_process_sngl/wishart_h_a_alpha_classifier.exe -id \x22$POLSARDirInput\x22 -od \x22$POLSARDirOutput\x22 -iodf S2 -nwr $WishartNwinL -nwc $WishartNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct $WishartPourcentage -nit $WishartIteration -bmp $BMPWishart -co8 \x22$ColorMapWishart8\x22 -co16 \x22$ColorMapWishart16\x22 -hf \x22$HFile\x22 -af \x22$AFile\x22 -alf \x22$AlpFile\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                        }
                    if {$POLSAROutputSubDir == "T6"} {
                        TextEditorRunTrace "Process The Function Soft/bin/data_process_dual/wishart_h_a_alpha_classifier.exe" "k"
                        TextEditorRunTrace "Arguments: -id \x22$POLSARDirInput\x22 -od \x22$POLSARDirOutput\x22 -iodf T6 -nwr $WishartNwinL -nwc $WishartNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct $WishartPourcentage -nit $WishartIteration -bmp $BMPWishart -co8 \x22$ColorMapWishart8\x22 -co16 \x22$ColorMapWishart16\x22 -ms $MasterSlaveChannel -hf \x22$HFile\x22 -af \x22$AFile\x22 -alf \x22$AlpFile\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                        set f [ open "| Soft/bin/data_process_dual/wishart_h_a_alpha_classifier.exe -id \x22$POLSARDirInput\x22 -od \x22$POLSARDirOutput\x22 -iodf T6 -nwr $WishartNwinL -nwc $WishartNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct $WishartPourcentage -nit $WishartIteration -bmp $BMPWishart -co8 \x22$ColorMapWishart8\x22 -co16 \x22$ColorMapWishart16\x22 -ms $MasterSlaveChannel -hf \x22$HFile\x22 -af \x22$AFile\x22 -alf \x22$AlpFile\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                        }
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    set ClassificationFile "$POLSARDirOutput/wishart_H_alpha_class_"
                    append ClassificationFile $WishartNwinL; append ClassificationFile "x"; append ClassificationFile $WishartNwinC 
                    set ClassificationInputFile "$ClassificationFile.bin"
                    if [file exists $ClassificationInputFile] {EnviWriteConfigClassif $ClassificationInputFile $FinalNlig $FinalNcol 4 $ColorMapWishart8 8}
                    set ClassificationFile "$POLSARDirOutput/wishart_H_A_alpha_class_"
                    append ClassificationFile $WishartNwinL; append ClassificationFile "x"; append ClassificationFile $WishartNwinC 
                    set ClassificationInputFile "$ClassificationFile.bin"
                    if [file exists $ClassificationInputFile] {EnviWriteConfigClassif $ClassificationInputFile $FinalNlig $FinalNcol 4 $ColorMapWishart16 16}
                    }
                }
                #TestVar
            }
            # WishartFlag
        
        if {$IdentFlag == "1"} {
            set TestVarName(0) "ColorMap9"; set TestVarType(0) "file"; set TestVarValue(0) $ColorMap9; set TestVarMin(0) ""; set TestVarMax(0) ""
            set TestVarName(1) "ColorMap16"; set TestVarType(1) "file"; set TestVarValue(1) $ColorMapWishart16; set TestVarMin(1) ""; set TestVarMax(1) ""
            TestVar 2
            if {$TestVarError == "ok"} {
        
                set conf "true"
                if [file exists "$POLSARDirOutput/p1.bin"] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE p1 DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
                if [file exists "$POLSARDirOutput/p2.bin"] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE p2 DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
                if [file exists "$POLSARDirOutput/alpha1.bin"] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE alpha1 DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
                if [file exists "$POLSARDirOutput/alpha2.bin"] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE alpha2 DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
                if [file exists "$POLSARDirOutput/beta1.bin"] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE beta1 DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
                if [file exists "$POLSARDirOutput/beta2.bin"] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE beta2 DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
                if [file exists "$POLSARDirOutput/entropy.bin"] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE entropy DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
                if [file exists "$POLSARDirOutput/anisotropy.bin"] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE anisotropy DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
                set IdentFile $ClassificationInputFile
                if [file exists $IdentFile] {
                } else {
                set conf "false"
                set VarError ""
                set ErrorMessage "THE FILE $IdentFile DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } 
                if {"$conf"=="true"} {
                    set OffsetLig [expr $NligInit - 1]
                    set OffsetCol [expr $NcolInit - 1]
                    set FinalNlig [expr $NligEnd - $NligInit + 1]
                    set FinalNcol [expr $NcolEnd - $NcolInit + 1]
                    set Fonction "BASIC SCATTERING MECHANISM IDENTIFICATION"
                    set Fonction2 "and the associated BMP files"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/id_class_gen.exe" "k"
                    TextEditorRunTrace "Arguments: -id \x22$POLSARDirInput\x22 -od \x22$POLSARDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -if $IdentFile -clm \x22$ColorMapWishart16\x22" "k"
                    set f [ open "| Soft/bin/data_process_sngl/id_class_gen.exe -id \x22$POLSARDirInput\x22 -od \x22$POLSARDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -if $IdentFile -clm \x22$ColorMapWishart16\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if [file exists "$POLSARDirOutput/vol_class.bin"] {EnviWriteConfigClassif "$POLSARDirOutput/vol_class.bin" $FinalNlig $FinalNcol 4 $ColorMap9 9}
                    if [file exists "$POLSARDirOutput/sgl_class.bin"] {EnviWriteConfigClassif "$POLSARDirOutput/sgl_class.bin" $FinalNlig $FinalNcol 4 $ColorMap9 9}
                    if [file exists "$POLSARDirOutput/dbl_class.bin"] {EnviWriteConfigClassif "$POLSARDirOutput/dbl_class.bin" $FinalNlig $FinalNcol 4 $ColorMap9 9}
                    }
                }
                #TestVar
            }
            # IdentFlag
        }
        #TestVar
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel311); TextEditorRunTrace "Close Window POLSAR - Unsupervised Classification" "b"}
        } 
    }
    # config
}
# opendirfile} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel311" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command { HelpPdfEdit "Help/POLSARClassification.pdf" } \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel311" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel311); TextEditorRunTrace "Close Window POLSAR - Unsupervised Classification" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel311" 1
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
    menu $top.m102 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra28 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra82 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit84 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.fra42 \
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
Window show .top311

main $argc $argv
