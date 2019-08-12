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
        {{[file join . GUI Images CIE-RGB.gif]} {user image} user {}}
        {{[file join . GUI Images CIE-lab.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}

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
    set base .top30
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd113 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd113
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
    namespace eval ::widgets::$site_6_0.cpd116 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd117 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra42 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra42
    namespace eval ::widgets::$site_3_0.cpd45 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd45
    namespace eval ::widgets::$site_4_0.lab46 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd44 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd47 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd47
    namespace eval ::widgets::$site_4_0.lab46 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd44 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd114 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd114
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-foreground 1 -ipad 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd48 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd48 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra44 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra44
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.cpd52 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd51 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd51 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd47 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent48 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd48 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra49 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra49
    namespace eval ::widgets::$site_4_0.fra50 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra50
    namespace eval ::widgets::$site_5_0.cpd53 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd53
    namespace eval ::widgets::$site_6_0.cpd52 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd54 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd54
    namespace eval ::widgets::$site_6_0.cpd52 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.fra55 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra55
    namespace eval ::widgets::$site_5_0.cpd56 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd57 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd115 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd115
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
    namespace eval ::widgets::$site_6_0.cpd107 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top30
            CreateRGBCombine3
            CreateRGBCombine4
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
## Procedure:  CreateRGBCombine3

proc ::CreateRGBCombine3 {} {
global TMPFileNull RGBDirInput RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputOdd FileInputVol FileInputDbl FileInputHlx RGBvl RGBbin
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize PSPViewGimpBMP
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile MaskCmd TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set config "false"
if {"$FileInputOdd"=="$TMPFileNull"} {set config "true"}
if {"$FileInputDbl"=="$TMPFileNull"} {set config "true"}
if {"$FileInputVol"=="$TMPFileNull"} {set config "true"}
if {"$config"=="true"} {
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_null_file.exe" "k"
    TextEditorRunTrace "Arguments: -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
    set f [ open "| Soft/bin/bmp_process/create_null_file.exe -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
    }
TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_ciergb_file.exe" "k"
TextEditorRunTrace "Arguments: -ifo \x22$FileInputOdd\x22 -ifd \x22$FileInputDbl\x22 -ifv \x22$FileInputVol\x22  -of \x22$RGBFileOutput\x22 -inr $FinalNlig -inc $FinalNcol -lv $RGBvl -bin $RGBbin -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/bmp_process/create_ciergb_file.exe -ifo \x22$FileInputOdd\x22 -ifd \x22$FileInputDbl\x22 -ifv \x22$FileInputVol\x22 -of \x22$RGBFileOutput\x22 -inr $FinalNlig -inc $FinalNcol -lv $RGBvl -bin $RGBbin -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
set BMPDirInput $RGBDirOutput
if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
}
#############################################################################
## Procedure:  CreateRGBCombine4

proc ::CreateRGBCombine4 {} {
global TMPFileNull RGBDirInput RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputOdd FileInputVol FileInputDbl FileInputHlx RGBlv RGBlab RGBbin
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize PSPViewGimpBMP
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile MaskCmd TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set config "false"
if {"$FileInputOdd"=="$TMPFileNull"} {set config "true"}
if {"$FileInputDbl"=="$TMPFileNull"} {set config "true"}
if {"$FileInputVol"=="$TMPFileNull"} {set config "true"}
if {"$FileInputHlx"=="$TMPFileNull"} {set config "true"}
if {"$config"=="true"} {
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_null_file.exe" "k"
    TextEditorRunTrace "Arguments: -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
    set f [ open "| Soft/bin/bmp_process/create_null_file.exe -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
    }
TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_cielab_file.exe" "k"
TextEditorRunTrace "Arguments: -ifo \x22$FileInputOdd\x22 -ifd \x22$FileInputDbl\x22 -ifv \x22$FileInputVol\x22 -ifh \x22$FileInputHlx\x22 -of \x22$RGBFileOutput\x22 -inr $FinalNlig -inc $FinalNcol -lv $RGBlv -lab $RGBlab -bin $RGBbin -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/bmp_process/create_cielab_file.exe -ifo \x22$FileInputOdd\x22 -ifd \x22$FileInputDbl\x22 -ifv \x22$FileInputVol\x22 -ifh \x22$FileInputHlx\x22 -of \x22$RGBFileOutput\x22 -inr $FinalNlig -inc $FinalNcol -lv $RGBlv -lab $RGBlab -bin $RGBbin -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
set BMPDirInput $RGBDirOutput
if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
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
    wm geometry $top 200x200+44+44; update
    wm maxsize $top 3844 1065
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

proc vTclWindow.top30 {base} {
    if {$base == ""} {
        set base .top30
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
    wm geometry $top 500x500+10+100; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create CIE-Lab RGB File"
    vTcl:DefineAlias "$top" "Toplevel30" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd113 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd113" "Frame1" vTcl:WidgetProc "Toplevel30" 1
    set site_3_0 $top.cpd113
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel30" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RGBDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel30" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame16" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd116 \
        \
        -command {global DirName DataDir BMPDirInput RGBFunction RGBDirInput RGBDirOutput
global ConfigFile VarError ErrorMessage
global RGBvl RGBlv RGBlab RGBbin
global FileInputOdd FileInputVol FileInputDbl FileInputHlx

set RGBFormat " "
set RGBDirInput " "
set VarError ""
set RGBvl " "; set RGBlv " "
set RGBlab " "; set RGBbin " "
set FileInputOdd " "
set FileInputVol " "
set FileInputDbl " "
set FileInputHlx " "

$widget(Button30_0) configure -state disable
$widget(TitleFrame30_1) configure -state disable
$widget(Entry30_1) configure -state disable
$widget(Button30_1) configure -state disable
$widget(TitleFrame30_2) configure -state disable
$widget(Entry30_2) configure -state disable
$widget(Button30_2) configure -state disable
$widget(TitleFrame30_3) configure -state disable
$widget(Entry30_3) configure -state disable
$widget(Button30_3) configure -state disable
$widget(TitleFrame30_4) configure -state disable
$widget(Entry30_4) configure -state disable
$widget(Button30_4) configure -state disable
$widget(TitleFrame30_5) configure -state disable
$widget(Entry30_5) configure -state disable
$widget(Button30_5) configure -state disable
$widget(Button30_6) configure -state disable
$widget(Label30_6) configure -state disable
$widget(Entry30_6) configure -state disable
$widget(Label30_7) configure -state disable
$widget(Entry30_7) configure -state disable
$widget(Label30_8) configure -state disable
$widget(Entry30_8) configure -state disable

set RGBDirInputTmp $BMPDirInput
set DirName ""
OpenDir $DataDir "DATA INPUT DIRECTORY"
if {$DirName != ""} {
    set RGBDirInput $DirName
    } else {
    set RGBDirInput $RGBDirInputTmp
    } 
set RGBDirOutput $RGBDirInput

set ConfigFile "$RGBDirInput/config.txt"
set ErrorMessage ""
LoadConfig
if {"$ErrorMessage" != ""} {
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RGBDirInput ""
    set RGBDirOutput ""
    if {$VarError == "cancel"} {Window hide $widget(Toplevel30); TextEditorRunTrace "Close Window Create CIE-Lab RGB File" "b"}
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd116" "Button36" vTcl:WidgetProc "Toplevel30" 1
    bindtags $site_6_0.cpd116 "$site_6_0.cpd116 Button $top all _vTclBalloon"
    bind $site_6_0.cpd116 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd116 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel30" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel30" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd117 \
        \
        -command {global DirName DataDir RGBDirOutput RGBFormat RGBFileOutput

set RGBDirOutputTmp $RGBDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set RGBDirOutput $DirName
    } else {
    set RGBDirOutput $RGBDirOutputTmp
    }
if {$RGBFormat == "combine3"} {set RGBFileOutput "$RGBDirOutput/Combine_CIE-RGB.bmp" }
if {$RGBFormat == "combine4"} {set RGBFileOutput "$RGBDirOutput/Combine_CIE-Lab.bmp" }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    bindtags $site_6_0.cpd117 "$site_6_0.cpd117 Button $top all _vTclBalloon"
    bind $site_6_0.cpd117 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd117 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra41 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame9" vTcl:WidgetProc "Toplevel30" 1
    set site_3_0 $top.fra41
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel30" 1
    entry $site_3_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel30" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel30" 1
    entry $site_3_0.ent60 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel30" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel30" 1
    entry $site_3_0.ent62 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel30" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel30" 1
    entry $site_3_0.ent64 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel30" 1
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
    frame $top.fra42 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame67" vTcl:WidgetProc "Toplevel30" 1
    set site_3_0 $top.fra42
    frame $site_3_0.cpd45 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd45" "Frame68" vTcl:WidgetProc "Toplevel30" 1
    set site_4_0 $site_3_0.cpd45
    label $site_4_0.lab46 \
        \
        -image [vTcl:image:get_image [file join . GUI Images CIE-RGB.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.lab46" "Label1" vTcl:WidgetProc "Toplevel30" 1
    radiobutton $site_4_0.cpd44 \
        \
        -command {global FileInputOdd FileInputVol FileInputDbl FileInputHlx TMPFileNull
global RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType
global RGBvl RGBlv RGBlab RGBbin

set RGBFormat "combine3"
set FileInputOdd $TMPFileNull
set FileInputVol $TMPFileNull
set FileInputDbl $TMPFileNull
set FileInputHlx " "
set RGBFileOutput "$RGBDirOutput/Combine_CIE-RGB.bmp"
$widget(Button30_0) configure -state normal
$widget(TitleFrame30_1) configure -state normal
$widget(Entry30_1) configure -state normal
$widget(Button30_1) configure -state normal
$widget(TitleFrame30_2) configure -state normal
$widget(Entry30_2) configure -state normal
$widget(Button30_2) configure -state normal
$widget(TitleFrame30_3) configure -state normal
$widget(Entry30_3) configure -state normal
$widget(Button30_3) configure -state normal
$widget(TitleFrame30_4) configure -state disable
$widget(Entry30_4) configure -state disable
$widget(Button30_4) configure -state disable
$widget(TitleFrame30_5) configure -state normal
$widget(Entry30_5) configure -state normal
$widget(Button30_5) configure -state normal
$widget(Button30_6) configure -state normal
$widget(Label30_6) configure -state disable
$widget(Entry30_6) configure -state disable
$widget(Label30_7) configure -state disable
$widget(Entry30_7) configure -state disable
$widget(Label30_8) configure -state normal
$widget(Entry30_8) configure -state normal

set RGBvl "2.0"
set RGBlv " "
set RGBlab " "
set RGBbin "32768"} \
        -text {Combine 3 Channels (CIE RGB)} -value combine3 \
        -variable RGBFormat 
    vTcl:DefineAlias "$site_4_0.cpd44" "Radiobutton30" vTcl:WidgetProc "Toplevel30" 1
    pack $site_4_0.lab46 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd44 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd47 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd47" "Frame69" vTcl:WidgetProc "Toplevel30" 1
    set site_4_0 $site_3_0.cpd47
    label $site_4_0.lab46 \
        \
        -image [vTcl:image:get_image [file join . GUI Images CIE-lab.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.lab46" "Label2" vTcl:WidgetProc "Toplevel30" 1
    radiobutton $site_4_0.cpd44 \
        \
        -command {global FileInputOdd FileInputVol FileInputDbl FileInputHlx TMPFileNull
global RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType
global RGBvl RGBlv RGBlab RGBbin

set RGBFormat "combine4"
set FileInputOdd $TMPFileNull
set FileInputVol $TMPFileNull
set FileInputDbl $TMPFileNull
set FileInputHlx $TMPFileNull
set RGBFileOutput "$RGBDirOutput/Combine_CIE-Lab.bmp"
$widget(Button30_0) configure -state normal
$widget(TitleFrame30_1) configure -state normal
$widget(Entry30_1) configure -state normal
$widget(Button30_1) configure -state normal
$widget(TitleFrame30_2) configure -state normal
$widget(Entry30_2) configure -state normal
$widget(Button30_2) configure -state normal
$widget(TitleFrame30_3) configure -state normal
$widget(Entry30_3) configure -state normal
$widget(Button30_3) configure -state normal
$widget(TitleFrame30_4) configure -state normal
$widget(Entry30_4) configure -state normal
$widget(Button30_4) configure -state normal
$widget(TitleFrame30_5) configure -state normal
$widget(Entry30_5) configure -state normal
$widget(Button30_5) configure -state normal
$widget(Button30_6) configure -state normal
$widget(Label30_6) configure -state normal
$widget(Entry30_6) configure -state normal
$widget(Label30_7) configure -state normal
$widget(Entry30_7) configure -state normal
$widget(Label30_8) configure -state disable
$widget(Entry30_8) configure -state disable

set RGBvl " "
set RGBlv "0.01"
set RGBlab "15.0"
set RGBbin 32768} \
        -text {Combine 4 Channels (CIE Lab)} -value combine4 \
        -variable RGBFormat 
    vTcl:DefineAlias "$site_4_0.cpd44" "Radiobutton40" vTcl:WidgetProc "Toplevel30" 1
    pack $site_4_0.lab46 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd44 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd45 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.cpd47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    frame $top.cpd114 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd114" "Frame2" vTcl:WidgetProc "Toplevel30" 1
    set site_3_0 $top.cpd114
    TitleFrame $site_3_0.cpd97 \
        -foreground #0000ff -ipad 0 -text {Single Bounce Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame30_1" vTcl:WidgetProc "Toplevel30" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputOdd 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry30_1" vTcl:WidgetProc "Toplevel30" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame18" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd119 \
        \
        -command {global FileName RGBDirInput RGBDirOutput RGBFileOutput FileInputOdd RGBFormat
global VarError ErrorMessage TMPFileNull

if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "SINGLE BOUNCE INPUT FILE"
    if {$FileName != ""} {
        set FileInputOdd $FileName
        } else {
        set FileInputOdd $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd119" "Button30_1" vTcl:WidgetProc "Toplevel30" 1
    bindtags $site_6_0.cpd119 "$site_6_0.cpd119 Button $top all _vTclBalloon"
    bind $site_6_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd119 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -foreground #009900 -ipad 0 \
        -text {Volume / Random Scattering Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame30_2" vTcl:WidgetProc "Toplevel30" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputVol 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry30_2" vTcl:WidgetProc "Toplevel30" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd120 \
        \
        -command {global FileName RGBDirInput RGBDirOutput RGBFileOutput FileInputVol RGBFormat
global VarError ErrorMessage TMPFileNull

if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "VOLUME INPUT FILE"
    if {$FileName != ""} {
        set FileInputVol $FileName
        } else {
        set FileInputVol $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd120" "Button30_2" vTcl:WidgetProc "Toplevel30" 1
    bindtags $site_6_0.cpd120 "$site_6_0.cpd120 Button $top all _vTclBalloon"
    bind $site_6_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd120 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd118 \
        -foreground #ff0000 -ipad 0 -text {Double Bounce Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame30_3" vTcl:WidgetProc "Toplevel30" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputDbl 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry30_3" vTcl:WidgetProc "Toplevel30" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd121 \
        \
        -command {global FileName RGBDirInput RGBDirOutput RGBFileOutput FileInputDbl RGBFormat
global VarError ErrorMessage TMPFileNull

if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "DOUBLE BOUNCE INPUT FILE"
    if {$FileName != ""} {
        set FileInputDbl $FileName
        } else {
        set FileInputDbl $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd121" "Button30_3" vTcl:WidgetProc "Toplevel30" 1
    bindtags $site_6_0.cpd121 "$site_6_0.cpd121 Button $top all _vTclBalloon"
    bind $site_6_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd121 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd48 \
        -foreground #000000 -ipad 0 \
        -text {Helix / Non Symmetric Scattering Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd48" "TitleFrame30_4" vTcl:WidgetProc "Toplevel30" 1
    bind $site_3_0.cpd48 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd48 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputHlx 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry30_4" vTcl:WidgetProc "Toplevel30" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame28" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd121 \
        \
        -command {global FileName RGBDirInput RGBDirOutput RGBFileOutput FileInputHlx RGBFormat
global VarError ErrorMessage TMPFileNull

if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "HELIX INPUT FILE"
    if {$FileName != ""} {
        set FileInputHlx $FileName
        } else {
        set FileInputHlx $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd121" "Button30_4" vTcl:WidgetProc "Toplevel30" 1
    bindtags $site_6_0.cpd121 "$site_6_0.cpd121 Button $top all _vTclBalloon"
    bind $site_6_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd121 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd48 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra44 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra44" "Frame4" vTcl:WidgetProc "Toplevel30" 1
    set site_3_0 $top.fra44
    frame $site_3_0.cpd66 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame11" vTcl:WidgetProc "Toplevel30" 1
    set site_4_0 $site_3_0.cpd66
    label $site_4_0.cpd52 \
        -text {Truncature value (%)} 
    vTcl:DefineAlias "$site_4_0.cpd52" "Label30_8" vTcl:WidgetProc "Toplevel30" 1
    entry $site_4_0.cpd67 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -textvariable RGBvl -width 7 
    vTcl:DefineAlias "$site_4_0.cpd67" "Entry30_8" vTcl:WidgetProc "Toplevel30" 1
    pack $site_4_0.cpd52 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd51 \
        -text {Bins Number} 
    vTcl:DefineAlias "$site_3_0.cpd51" "TitleFrame30_5" vTcl:WidgetProc "Toplevel30" 1
    bind $site_3_0.cpd51 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd51 getframe]
    button $site_5_0.cpd47 \
        \
        -command {global RGBbin

set RGBbin [expr $RGBbin * 2]
if {$RGBbin == 131072} {set RGBbin 2}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] \
        -pady 0 -text . 
    vTcl:DefineAlias "$site_5_0.cpd47" "Button30_5" vTcl:WidgetProc "Toplevel30" 1
    entry $site_5_0.ent48 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -textvariable RGBbin -width 7 
    vTcl:DefineAlias "$site_5_0.ent48" "Entry30_5" vTcl:WidgetProc "Toplevel30" 1
    button $site_5_0.cpd48 \
        \
        -command {global RGBbin

set RGBbin [expr $RGBbin / 2]
if {$RGBbin == 1} {set RGBbin 65536}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text . 
    vTcl:DefineAlias "$site_5_0.cpd48" "Button30_6" vTcl:WidgetProc "Toplevel30" 1
    pack $site_5_0.cpd47 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.ent48 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.cpd48 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.fra49 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra49" "Frame5" vTcl:WidgetProc "Toplevel30" 1
    set site_4_0 $site_3_0.fra49
    frame $site_4_0.fra50 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra50" "Frame6" vTcl:WidgetProc "Toplevel30" 1
    set site_5_0 $site_4_0.fra50
    frame $site_5_0.cpd53 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd53" "Frame7" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd53
    label $site_6_0.cpd52 \
        -text {N% value (L-axis)} 
    vTcl:DefineAlias "$site_6_0.cpd52" "Label30_6" vTcl:WidgetProc "Toplevel30" 1
    pack $site_6_0.cpd52 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd54 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd54" "Frame8" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd54
    label $site_6_0.cpd52 \
        -text {M% value (ab-plane)} 
    vTcl:DefineAlias "$site_6_0.cpd52" "Label30_7" vTcl:WidgetProc "Toplevel30" 1
    pack $site_6_0.cpd52 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd53 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd54 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    frame $site_4_0.fra55 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra55" "Frame10" vTcl:WidgetProc "Toplevel30" 1
    set site_5_0 $site_4_0.fra55
    entry $site_5_0.cpd56 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -textvariable RGBlv -width 7 
    vTcl:DefineAlias "$site_5_0.cpd56" "Entry30_6" vTcl:WidgetProc "Toplevel30" 1
    entry $site_5_0.cpd57 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -textvariable RGBlab -width 7 
    vTcl:DefineAlias "$site_5_0.cpd57" "Entry30_7" vTcl:WidgetProc "Toplevel30" 1
    pack $site_5_0.cpd56 \
        -in $site_5_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_5_0.cpd57 \
        -in $site_5_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_4_0.fra50 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.fra55 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 3 -side left 
    pack $site_3_0.fra49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.cpd115 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd115" "Frame3" vTcl:WidgetProc "Toplevel30" 1
    set site_3_0 $top.cpd115
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output RGB File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel30" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel30" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel30" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd107 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    pack $site_6_0.cpd107 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel30" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global TMPFileNull RGBDirInput RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputOdd FileInputVol FileInputDbl FileInputHlx
global RGBvl RGBlv RGBlab RGBbin
global OffsetLig OffsetCol FinalNlig FinalNcol NligFullSize NcolFullSize
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile MaskCmd TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {"$RGBDirInput"!=""} {

    #####################################################################
    #Create Directory
    set RGBDirOutput [PSPCreateDirectoryMask $RGBDirOutput $RGBDirOutput $RGBDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
    
        set config "true"
        if {"$RGBFormat"=="combine3"} {
            if {"$FileInputOdd"==""} {set config "false"}
            if {"$FileInputDbl"==""} {set config "false"}
            if {"$FileInputVol"==""} {set config "false"}
            }
        if {"$RGBFormat"=="combine4"} {
            if {"$FileInputOdd"==""} {set config "false"}
            if {"$FileInputDbl"==""} {set config "false"}
            if {"$FileInputVol"==""} {set config "false"}
            if {"$FileInputHlx"==""} {set config "false"}
            }
        if {"$config"=="false"} {
            set VarError ""
            set ErrorMessage "INVALID INPUT FILES" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        if {"$config"=="true"} {
            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            if {"$RGBFormat"=="combine3"} {
                set TestVarName(4) "Truncature value (%)"; set TestVarType(4) "float"; set TestVarValue(4) $RGBvl; set TestVarMin(4) 0; set TestVarMax(4) 100
                TestVar 5
                }
            if {"$RGBFormat"=="combine4"} {
                set TestVarName(4) "N% value (L-axis)"; set TestVarType(4) "float"; set TestVarValue(4) $RGBlv; set TestVarMin(4) 0; set TestVarMax(4) 100
                set TestVarName(5) "M% value (ab-plane)"; set TestVarType(5) "float"; set TestVarValue(5) $RGBlab; set TestVarMin(5) 0; set TestVarMax(5) 100
                TestVar 6
                }
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
                set Fonction "Creation of the CIE-Lab RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                if {"$RGBFormat"=="combine3"} {
                    set MaskCmd ""; set MaskDir ""
                    if {"$FileInputOdd" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputOdd] }
                    if {"$FileInputDbl" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputDbl] }
                    if {"$FileInputVol" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputVol] }
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                    CreateRGBCombine3
                    }
                if {"$RGBFormat"=="combine4"} {
                    set MaskCmd ""; set MaskDir ""
                    if {"$FileInputOdd" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputOdd] }
                    if {"$FileInputDbl" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputDbl] }
                    if {"$FileInputVol" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputVol] }
                    if {"$FileInputHlx" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputHlx] }
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                    CreateRGBCombine4
                    }
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                Window hide $widget(Toplevel30); TextEditorRunTrace "Close Window Create CIE-Lab RGB File" "b"
                }
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel30); TextEditorRunTrace "Close Window Create CIE-Lab RGB File" "b"}
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button30_0" vTcl:WidgetProc "Toplevel30" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit "Help/CreateRGBFile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel30" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global DisplayMainMenu OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel30); TextEditorRunTrace "Close Window Create RGB File" "b"
if {$DisplayMainMenu == 1} {
    set DisplayMainMenu 0
    WidgetShow $widget(Toplevel2)
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel30" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit  the Function}
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
    pack $top.cpd113 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra41 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra42 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd114 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra44 \
        -in $top -anchor center -expand 0 -fill x -pady 10 -side top 
    pack $top.cpd115 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -pady 5 -side bottom 

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
Window show .top30

main $argc $argv
