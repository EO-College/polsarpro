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
    set base .top351a
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd74
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
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra102 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra102
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
    namespace eval ::widgets::$base.fra109 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra109
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit68 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit68 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che79 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che80 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che81 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che82 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd93
    namespace eval ::widgets::$site_5_0.che78 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che79 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che80 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che81 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che82 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.che83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd88
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra24 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra24
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd70
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd91 {
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
            vTclWindow.top351a
            WidgetOn351a
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
## Procedure:  WidgetOn351a

proc ::WidgetOn351a {} {
global ParaHHovHV ParaHVovHH ParaHHovVV ParaVVovHH ParaHVovVV ParaVVovHV
global ParaHHovVH ParaVHovHH ParaHVovVH ParaVHovHV ParaVHovVV ParaVVovVH
global ParaNwinL ParaNwinC ParaBMP ParametersFonction ParametersFonctionPP

set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 0; set ParaVVovHH 0; set ParaHVovVV 0; set ParaVVovHV 0
set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
set ParaNwinL "?"
set ParaNwinC "?"
set ParaBMP 0

set ButHHHV .top351a.tit68.f.cpd92.che78; set ButHVHH .top351a.tit68.f.cpd92.che79
set ButHHVV .top351a.tit68.f.cpd92.che80; set ButVVHH .top351a.tit68.f.cpd92.che81
set ButHVVV .top351a.tit68.f.cpd92.che82; set ButVVHV .top351a.tit68.f.cpd92.che83

set ButHHVH .top351a.tit68.f.cpd93.che78; set ButVHHH .top351a.tit68.f.cpd93.che79
set ButHVVH .top351a.tit68.f.cpd93.che80; set ButVHHV .top351a.tit68.f.cpd93.che81
set ButVHVV .top351a.tit68.f.cpd93.che82; set ButVVVH .top351a.tit68.f.cpd93.che83

$ButHHHV configure -state disable
$ButHVHH configure -state disable
$ButHHVV configure -state disable
$ButVVHH configure -state disable
$ButHVVV configure -state disable
$ButVVHV configure -state disable

$ButHHVH configure -state disable
$ButVHHH configure -state disable
$ButHVVH configure -state disable
$ButVHHV configure -state disable
$ButVHVV configure -state disable
$ButVVVH configure -state disable

if {$ParametersFonction == "S2m"} {
    $ButHHHV configure -state normal
    $ButHVHH configure -state normal
    $ButHHVV configure -state normal
    $ButVVHH configure -state normal
    $ButHVVV configure -state normal
    $ButVVHV configure -state normal
    }

if {$ParametersFonction == "S2b"} {
    $ButHHHV configure -state normal
    $ButHVHH configure -state normal
    $ButHHVV configure -state normal
    $ButVVHH configure -state normal
    $ButHVVV configure -state normal
    $ButVVHV configure -state normal

    $ButHHVH configure -state normal
    $ButVHHH configure -state normal
    $ButHVVH configure -state normal
    $ButVHHV configure -state normal
    $ButVHVV configure -state normal
    $ButVVVH configure -state normal
    }
    
if {$ParametersFonction == "T3"} {
    $ButHHHV configure -state normal
    $ButHVHH configure -state normal
    $ButHHVV configure -state normal
    $ButVVHH configure -state normal
    $ButHVVV configure -state normal
    $ButVVHV configure -state normal
    }

if {$ParametersFonction == "T4"} {
    $ButHHHV configure -state normal
    $ButHVHH configure -state normal
    $ButHHVV configure -state normal
    $ButVVHH configure -state normal
    $ButHVVV configure -state normal
    $ButVVHV configure -state normal

    $ButHHVH configure -state normal
    $ButVHHH configure -state normal
    $ButHVVH configure -state normal
    $ButVHHV configure -state normal
    $ButVHVV configure -state normal
    $ButVVVH configure -state normal
    }
    
if {$ParametersFonction == "C2"} {
    $ButHHVV configure -state normal
    $ButVVHH configure -state normal
    }
    
if {$ParametersFonction == "C3"} {
    $ButHHHV configure -state normal
    $ButHVHH configure -state normal
    $ButHHVV configure -state normal
    $ButVVHH configure -state normal
    $ButHVVV configure -state normal
    $ButVVHV configure -state normal
    }
    
if {$ParametersFonction == "C4"} {
    $ButHHHV configure -state normal
    $ButHVHH configure -state normal
    $ButHHVV configure -state normal
    $ButVVHH configure -state normal
    $ButHVVV configure -state normal
    $ButVVHV configure -state normal

    $ButHHVH configure -state normal
    $ButVHHH configure -state normal
    $ButHVVH configure -state normal
    $ButVHHV configure -state normal
    $ButVHVV configure -state normal
    $ButVVVH configure -state normal
    }
    
if {$ParametersFonction == "SPP"} {
    if {$ParametersFonctionPP == "pp1"} {
        $ButHHVH configure -state normal
        $ButVHHH configure -state normal
        }
    if {$ParametersFonctionPP == "pp3"} {
        $ButHHVV configure -state normal
        $ButVVHH configure -state normal
        }
    if {$ParametersFonctionPP == "pp2"} {
        $ButHVVV configure -state normal
        $ButVVHV configure -state normal
        }
    }    
    
if {$ParametersFonction == "IPP"} {
    if {$ParametersFonctionPP == "pp5"} {
        $ButHHVH configure -state normal
        $ButVHHH configure -state normal
        }
    if {$ParametersFonctionPP == "pp7"} {
        $ButHHVV configure -state normal
        $ButVVHH configure -state normal
        }
    if {$ParametersFonctionPP == "pp6"} {
        $ButHVVV configure -state normal
        $ButVVHV configure -state normal
        }
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

proc vTclWindow.top351a {base} {
    if {$base == ""} {
        set base .top351a
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
    wm geometry $top 500x280+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Parameters"
    vTcl:DefineAlias "$top" "Toplevel351a" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd74 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd74" "Frame4" vTcl:WidgetProc "Toplevel351a" 1
    set site_3_0 $top.cpd74
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel351a" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ParametersDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel351a" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel351a" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel351a" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel351a" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ParametersOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel351a" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel351a" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel351a" 1
    entry $site_6_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ParametersOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd72" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel351a" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel351a" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd75 \
        \
        -command {global DirName DataDir ParametersOutputDir

set ParametersDirOutputTmp $ParametersOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set ParametersOutputDir $DirName
    } else {
    set ParametersOutputDir $ParametersDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd75" "Button82" vTcl:WidgetProc "Toplevel351a" 1
    bindtags $site_6_0.cpd75 "$site_6_0.cpd75 Button $top all _vTclBalloon"
    bind $site_6_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd75 \
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
    frame $top.fra102 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra102" "Frame9" vTcl:WidgetProc "Toplevel351a" 1
    set site_3_0 $top.fra102
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel351a" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel351a" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel351a" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel351a" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel351a" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel351a" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel351a" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel351a" 1
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
    frame $top.fra109 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra109" "Frame20" vTcl:WidgetProc "Toplevel351a" 1
    set site_3_0 $top.fra109
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ParametersDirInput ParametersDirOutput ParametersOutputDir ParametersOutputSubDir
global ParametersFonction ParametersFonctionPP ParaBMP ParaNwinL ParaNwinC
global BMPDirInput
global ParaHHovHV ParaHVovHH ParaHHovVV ParaVVovHH ParaHVovVV ParaVVovHV
global ParaHHovVH ParaVHovHH ParaHVovVH ParaVHovHV ParaVHovVV ParaVVovVH
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config "true"
set TestVarName(0) "Window Size Row"; set TestVarType(0) "int"; set TestVarValue(0) $ParaNwinL; set TestVarMin(0) "1"; set TestVarMax(0) "100"
set TestVarName(1) "Window Size Col"; set TestVarType(1) "int"; set TestVarValue(1) $ParaNwinC; set TestVarMin(1) "1"; set TestVarMax(1) "100"
TestVar 2
if {$TestVarError == "ok"} {
    set config "true"
    } else {
    set config "false"
    }
if {$config == "true"} {

    set ParametersDirOutput $ParametersOutputDir 
    if {$ParametersOutputSubDir != ""} {append ParametersDirOutput "/$ParametersOutputSubDir"}

    #####################################################################
    #Create Directory
    set ParametersDirOutput [PSPCreateDirectoryMask $ParametersDirOutput $ParametersOutputDir $ParametersDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {

    set Nratio 0
    for {set i 0} {$i < 16} {incr i} {
    set ParaRatio($i) ""
    }
    if {$ParaHHovHV == 1} { incr Nratio; set ParaRatio($Nratio) "11ov12" }
    if {$ParaHVovHH == 1} { incr Nratio; set ParaRatio($Nratio) "12ov11" }
    if {$ParaHHovVV == 1} { incr Nratio; set ParaRatio($Nratio) "11ov22" }
    if {$ParaVVovHH == 1} { incr Nratio; set ParaRatio($Nratio) "22ov11" }
    if {$ParaHVovVV == 1} { incr Nratio; set ParaRatio($Nratio) "12ov22" }
    if {$ParaVVovHV == 1} { incr Nratio; set ParaRatio($Nratio) "22ov12" }
    if {$ParaHHovVH == 1} { incr Nratio; set ParaRatio($Nratio) "11ov21" }
    if {$ParaVHovHH == 1} { incr Nratio; set ParaRatio($Nratio) "21ov11" }
    if {$ParaHVovVH == 1} { incr Nratio; set ParaRatio($Nratio) "12ov21" }
    if {$ParaVHovHV == 1} { incr Nratio; set ParaRatio($Nratio) "21ov12" }
    if {$ParaVHovVV == 1} { incr Nratio; set ParaRatio($Nratio) "21ov22" }
    if {$ParaVVovVH == 1} { incr Nratio; set ParaRatio($Nratio) "22ov21" }
    incr Nratio
    for {set i 1} {$i < $Nratio} {incr i} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set Fonction  "Creation of the Reflectivity Ratio"
        set Fonction2 "Element : reflectivity_$ParaRatio($i)"
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/ratio_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rat $ParaRatio($i)  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/ratio_elements.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rat $ParaRatio($i)  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        set RatioFile "$ParametersDirOutput/reflectivity_"; append RatioFile $ParaRatio($i); append RatioFile ".bin"
        if [file exists $RatioFile] {EnviWriteConfig $RatioFile $FinalNlig $FinalNcol 4}
        
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if [file exists $RatioFile] {
                set BMPFileInput $RatioFile
                set RatioFileBMP "$ParametersDirOutput/reflectivity_"; append RatioFileBMP $ParaRatio($i); append RatioFileBMP ".bmp"
                set BMPFileOutput $RatioFileBMP
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } #parabmp
        }
        #ratio

    } #testvarerror
    
    } else {
    if {"$VarWarning"=="no"} {
        Window hide $widget(Toplevel351a)
        if {$ParametersFonction == "S2m"} {TextEditorRunTrace "Close Window S2 Parameters" "b"}
        if {$ParametersFonction == "S2b"} {TextEditorRunTrace "Close Window S2 Parameters" "b"}
        if {$ParametersFonction == "T3"} {TextEditorRunTrace "Close Window T3 Parameters" "b"}
        if {$ParametersFonction == "T4"} {TextEditorRunTrace "Close Window T4 Parameters" "b"}
        if {$ParametersFonction == "C2"} {TextEditorRunTrace "Close Window C2 Parameters" "b"}
        if {$ParametersFonction == "C3"} {TextEditorRunTrace "Close Window C3 Parameters" "b"}
        if {$ParametersFonction == "C4"} {TextEditorRunTrace "Close Window C4 Parameters" "b"}
        if {$ParametersFonction == "SPP"} {TextEditorRunTrace "Close Window SPP Parameters" "b"}
        if {$ParametersFonction == "IPP"} {TextEditorRunTrace "Close Window IPP Parameters" "b"}
        }
    }
}
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel351a" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ParametersPR.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel351a" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile ParametersFonction
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel351a); 
if {$ParametersFonction == "S2m"} {TextEditorRunTrace "Close Window S2 Parameters" "b"}
if {$ParametersFonction == "S2b"} {TextEditorRunTrace "Close Window S2 Parameters" "b"}
if {$ParametersFonction == "T3"} {TextEditorRunTrace "Close Window T3 Parameters" "b"}
if {$ParametersFonction == "T4"} {TextEditorRunTrace "Close Window T4 Parameters" "b"}
if {$ParametersFonction == "C2"} {TextEditorRunTrace "Close Window C2 Parameters" "b"}
if {$ParametersFonction == "C3"} {TextEditorRunTrace "Close Window C3 Parameters" "b"}
if {$ParametersFonction == "C4"} {TextEditorRunTrace "Close Window C4 Parameters" "b"}
if {$ParametersFonction == "SPP"} {TextEditorRunTrace "Close Window SPP Parameters" "b"}
if {$ParametersFonction == "IPP"} {TextEditorRunTrace "Close Window IPP Parameters" "b"}
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel351a" 1
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
    TitleFrame $top.tit68 \
        -text {Reflectivity Ratio} 
    vTcl:DefineAlias "$top.tit68" "TitleFrame1" vTcl:WidgetProc "Toplevel351a" 1
    bind $top.tit68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit68 getframe]
    frame $site_4_0.cpd92 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame8" vTcl:WidgetProc "Toplevel351a" 1
    set site_5_0 $site_4_0.cpd92
    checkbutton $site_5_0.che78 \
        -text {11 / 12} -variable ParaHHovHV 
    vTcl:DefineAlias "$site_5_0.che78" "Checkbutton29" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che79 \
        -text {12 / 11} -variable ParaHVovHH 
    vTcl:DefineAlias "$site_5_0.che79" "Checkbutton30" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che80 \
        -text {11 / 22} -variable ParaHHovVV 
    vTcl:DefineAlias "$site_5_0.che80" "Checkbutton31" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che81 \
        -text {22 / 11} -variable ParaVVovHH 
    vTcl:DefineAlias "$site_5_0.che81" "Checkbutton32" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che82 \
        -text {12 / 22} -variable ParaHVovVV 
    vTcl:DefineAlias "$site_5_0.che82" "Checkbutton33" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che83 \
        -text {22 / 12} -variable ParaVVovHV 
    vTcl:DefineAlias "$site_5_0.che83" "Checkbutton34" vTcl:WidgetProc "Toplevel351a" 1
    pack $site_5_0.che78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.che79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd93 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd93" "Frame10" vTcl:WidgetProc "Toplevel351a" 1
    set site_5_0 $site_4_0.cpd93
    checkbutton $site_5_0.che78 \
        -text {11 / 21} -variable ParaHHovVH 
    vTcl:DefineAlias "$site_5_0.che78" "Checkbutton35" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che79 \
        -text {21 / 11} -variable ParaVHovHH 
    vTcl:DefineAlias "$site_5_0.che79" "Checkbutton36" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che80 \
        -text {12 / 21} -variable ParaHVovVH 
    vTcl:DefineAlias "$site_5_0.che80" "Checkbutton37" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che81 \
        -text {21 / 12} -variable ParaVHovHV 
    vTcl:DefineAlias "$site_5_0.che81" "Checkbutton38" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che82 \
        -text {21 / 22} -variable ParaVHovVV 
    vTcl:DefineAlias "$site_5_0.che82" "Checkbutton39" vTcl:WidgetProc "Toplevel351a" 1
    checkbutton $site_5_0.che83 \
        -text {22 / 21} -variable ParaVVovVH 
    vTcl:DefineAlias "$site_5_0.che83" "Checkbutton40" vTcl:WidgetProc "Toplevel351a" 1
    pack $site_5_0.che78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.che79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.che83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame51" vTcl:WidgetProc "Toplevel351a" 1
    set site_3_0 $top.cpd88
    checkbutton $site_3_0.cpd66 \
        -padx 1 -text BMP -variable ParaBMP 
    vTcl:DefineAlias "$site_3_0.cpd66" "Checkbutton468" vTcl:WidgetProc "Toplevel351a" 1
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame52" vTcl:WidgetProc "Toplevel351a" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label36" vTcl:WidgetProc "Toplevel351a" 1
    entry $site_4_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ParaNwinL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry24" vTcl:WidgetProc "Toplevel351a" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd70 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd70" "Frame53" vTcl:WidgetProc "Toplevel351a" 1
    set site_4_0 $site_3_0.cpd70
    label $site_4_0.lab57 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label37" vTcl:WidgetProc "Toplevel351a" 1
    entry $site_4_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ParaNwinC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry25" vTcl:WidgetProc "Toplevel351a" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {global ParaHHovHV ParaHVovHH ParaHHovVV ParaVVovHH ParaHVovVV ParaVVovHV
global ParaHHovVH ParaVHovHH ParaHVovVH ParaVHovHV ParaVHovVV ParaVVovVH
global ParaNwinL ParaNwinC ParaBMP ParametersFonction ParametersFonctionPP

set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 0; set ParaVVovHH 0; set ParaHVovVV 0; set ParaVVovHV 0
set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
set ParaNwinL "?"
set ParaNwinC "?"
set ParaBMP 1

if {$ParametersFonction == "S2m"} {
    set ParaHHovHV 1; set ParaHVovHH 1; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 1; set ParaVVovHV 1
    set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
    }

if {$ParametersFonction == "S2b"} {
    set ParaHHovHV 1; set ParaHVovHH 1; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 1; set ParaVVovHV 1
    set ParaHHovVH 1; set ParaVHovHH 1; set ParaHVovVH 1; set ParaVHovHV 1; set ParaVHovVV 1; set ParaVVovVH 1
    }
    
if {$ParametersFonction == "T3"} {
    set ParaHHovHV 1; set ParaHVovHH 1; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 1; set ParaVVovHV 1
    set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
    }

if {$ParametersFonction == "T4"} {
    set ParaHHovHV 1; set ParaHVovHH 1; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 1; set ParaVVovHV 1
    set ParaHHovVH 1; set ParaVHovHH 1; set ParaHVovVH 1; set ParaVHovHV 1; set ParaVHovVV 1; set ParaVVovVH 1
    }
    
if {$ParametersFonction == "C2"} {
    set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 0; set ParaVVovHV 0
    set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
    }
    
if {$ParametersFonction == "C3"} {
    set ParaHHovHV 1; set ParaHVovHH 1; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 1; set ParaVVovHV 1
    set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
    }
    
if {$ParametersFonction == "C4"} {
    set ParaHHovHV 1; set ParaHVovHH 1; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 1; set ParaVVovHV 1
    set ParaHHovVH 1; set ParaVHovHH 1; set ParaHVovVH 1; set ParaVHovHV 1; set ParaVHovVV 1; set ParaVVovVH 1
    }
    
if {$ParametersFonction == "SPP"} {
    if {$ParametersFonctionPP == "pp1"} {
        set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 0; set ParaVVovHH 0; set ParaHVovVV 0; set ParaVVovHV 0
        set ParaHHovVH 1; set ParaVHovHH 1; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
        }
    if {$ParametersFonctionPP == "pp3"} {
        set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 0; set ParaVVovHV 0
        set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
        }
    if {$ParametersFonctionPP == "pp2"} {
        set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 0; set ParaVVovHH 0; set ParaHVovVV 1; set ParaVVovHV 1
        set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
        }
    }    
    
if {$ParametersFonction == "IPP"} {
    if {$ParametersFonctionPP == "pp5"} {
        set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 0; set ParaVVovHH 0; set ParaHVovVV 0; set ParaVVovHV 0
        set ParaHHovVH 1; set ParaVHovHH 1; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
        }
    if {$ParametersFonctionPP == "pp7"} {
        set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 1; set ParaVVovHH 1; set ParaHVovVV 0; set ParaVVovHV 0
        set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
        }
    if {$ParametersFonctionPP == "pp6"} {
        set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 0; set ParaVVovHH 0; set ParaHVovVV 1; set ParaVVovHV 1
        set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
        }
    }} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button18" vTcl:WidgetProc "Toplevel351a" 1
    bindtags $site_3_0.cpd67 "$site_3_0.cpd67 Button $top all _vTclBalloon"
    bind $site_3_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.cpd91 \
        -background #ffff00 \
        -command {global ParaHHovHV ParaHVovHH ParaHHovVV ParaVVovHH ParaHVovVV ParaVVovHV
global ParaHHovVH ParaVHovHH ParaHVovVH ParaVHovHV ParaVHovVV ParaVVovVH
global ParaNwinL ParaNwinC ParaBMP

set ParaHHovHV 0; set ParaHVovHH 0; set ParaHHovVV 0; set ParaVVovHH 0; set ParaHVovVV 0; set ParaVVovHV 0
set ParaHHovVH 0; set ParaVHovHH 0; set ParaHVovVH 0; set ParaVHovHV 0; set ParaVHovVV 0; set ParaVVovVH 0
set ParaNwinL "?"
set ParaNwinC "?"
set ParaBMP 0} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd91" "Button17" vTcl:WidgetProc "Toplevel351a" 1
    bindtags $site_3_0.cpd91 "$site_3_0.cpd91 Button $top all _vTclBalloon"
    bind $site_3_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd91 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra102 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra109 \
        -in $top -anchor center -expand 1 -fill x -side bottom 
    pack $top.tit68 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd88 \
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
Window show .top351a

main $argc $argv
