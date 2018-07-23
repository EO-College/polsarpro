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
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
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
    set base .top319
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-text 1}
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
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit76 {
        array set save {-text 1}
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
    namespace eval ::widgets::$base.cpd94 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra75 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra75
    namespace eval ::widgets::$site_3_0.che77 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.com79 {
        array set save {-entrybg 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$base.cpd93 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd93
    namespace eval ::widgets::$site_3_0.che77 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd89 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd89
    namespace eval ::widgets::$site_3_0.che77 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra80 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra80
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd81
    namespace eval ::widgets::$site_4_0.che77 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra83
    namespace eval ::widgets::$site_4_0.fra84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra84
    namespace eval ::widgets::$site_5_0.lab86 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd87 {
        array set save {-borderwidth 1 -relief 1}
    }
    set site_6_0 $site_5_0.cpd87
    namespace eval ::widgets::$site_6_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd77
    namespace eval ::widgets::$site_7_0.but79 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.but80 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd88
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra90
    namespace eval ::widgets::$site_3_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd91
    namespace eval ::widgets::$site_4_0.lab78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.com79 {
        array set save {-entrybg 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd92
    namespace eval ::widgets::$site_4_0.lab78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.com79 {
        array set save {-entrybg 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
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
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -image 1 -pady 1 -text 1 -width 1}
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
            vTclWindow.top319
            HeightInvUpdate
            Gamma_Files
            HeightInv_DEM
            HeightInv_RVOG
            HeightInv_COH
            HeightInv_Phase
            PhaseCenter_File
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
## Procedure:  HeightInvUpdate

proc ::HeightInvUpdate {} {
global PhaseCenterChannel PhaseTopChannel PhaseGroundChannel
global HeightInvDirInput HeightInvList HeightInvString
global VarError ErrorMessage

set HeightInvList(0) ""
for {set i 1} {$i < 100} {incr i } { set HeightInvList($i) "" }

set NumList 0
if [file exists "$HeightInvDirInput/cmplx_coh_HH.bin"] {
    incr NumList
    set HeightInvList($NumList) "HH"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_HH.bin"] {
    incr NumList
    set HeightInvList($NumList) "HH (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_HV.bin"] {
    incr NumList
    set HeightInvList($NumList) "HV"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_HV.bin"] {
    incr NumList
    set HeightInvList($NumList) "HV (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_VV.bin"] {
    incr NumList
    set HeightInvList($NumList) "VV"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_VV.bin"] {
    incr NumList
    set HeightInvList($NumList) "VV (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_HHpVV.bin"] {
    incr NumList
    set HeightInvList($NumList) "HH + VV"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_HHpVV.bin"] {
    incr NumList
    set HeightInvList($NumList) "HH + VV (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_HHmVV.bin"] {
    incr NumList
    set HeightInvList($NumList) "HH - VV"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_HHmVV.bin"] {
    incr NumList
    set HeightInvList($NumList) "HH - VV (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_HVpVH.bin"] {
    incr NumList
    set HeightInvList($NumList) "HV + VH"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_HVpVH.bin"] {
    incr NumList
    set HeightInvList($NumList) "HV + VH (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_LL.bin"] {
    incr NumList
    set HeightInvList($NumList) "LL"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_LL.bin"] {
    incr NumList
    set HeightInvList($NumList) "LL (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_LR.bin"] {
    incr NumList
    set HeightInvList($NumList) "LR"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_LR.bin"] {
    incr NumList
    set HeightInvList($NumList) "LR (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_RR.bin"] {
    incr NumList
    set HeightInvList($NumList) "RR"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_RR.bin"] {
    incr NumList
    set HeightInvList($NumList) "RR (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_Opt1.bin"] {
    incr NumList
    set HeightInvList($NumList) "OPT 1"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_Opt1.bin"] {
    incr NumList
    set HeightInvList($NumList) "OPT 1 (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_Opt2.bin"] {
    incr NumList
    set HeightInvList($NumList) "OPT 2"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_Opt2.bin"] {
    incr NumList
    set HeightInvList($NumList) "OPT 2 (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_Opt3.bin"] {
    incr NumList
    set HeightInvList($NumList) "OPT 3"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_Opt3.bin"] {
    incr NumList
    set HeightInvList($NumList) "OPT 3 (avg)"
    }

if [file exists "$HeightInvDirInput/cmplx_coh_Ch1.bin"] {
    incr NumList
    set HeightInvList($NumList) "Ch1"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_Ch1.bin"] {
    incr NumList
    set HeightInvList($NumList) "Ch1 (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_Ch2.bin"] {
    incr NumList
    set HeightInvList($NumList) "Ch2"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_Ch2.bin"] {
    incr NumList
    set HeightInvList($NumList) "Ch2 (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_Ch1pCh2.bin"] {
    incr NumList
    set HeightInvList($NumList) "Ch1 + Ch2"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_Ch1pCh2.bin"] {
    incr NumList
    set HeightInvList($NumList) "Ch1 + Ch2 (avg)"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_Ch1mCh2.bin"] {
    incr NumList
    set HeightInvList($NumList) "Ch1 - Ch2"
    }
if [file exists "$HeightInvDirInput/cmplx_coh_avg_Ch1mCh2.bin"] {
    incr NumList
    set HeightInvList($NumList) "Ch1 - Ch2 (avg)"
    }

if {$NumList == 0} {              
    set VarError ""
    set ErrorMessage "COMPLEX COHERENCE FILES MUST BE CREATED FIRST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set HeightInvString ""
    for {set i 1} {$i <= $NumList} {incr i } { lappend HeightInvString $HeightInvList($i) }
    .top319.fra75.com79 configure -values $HeightInvString
    .top319.fra90.cpd91.com79 configure -values $HeightInvString
    .top319.fra90.cpd92.com79 configure -values $HeightInvString
    set PhaseCenterChannel $HeightInvList(1)
    set PhaseTopChannel $HeightInvList(1)
    set PhaseGroundChannel $HeightInvList(1)
    }
}
#############################################################################
## Procedure:  Gamma_Files

proc ::Gamma_Files {} {
global HeightInvDirInput
global GammaHighFile GammaLowFile 
global PhaseTopChannel PhaseGroundChannel

set GammaHighFile ""
if {$PhaseTopChannel == "HH" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_HH.bin" }
if {$PhaseTopChannel == "HH (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_HH.bin" }
if {$PhaseTopChannel == "HV" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_HV.bin" }
if {$PhaseTopChannel == "HV (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_HV.bin" }
if {$PhaseTopChannel == "VV" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_VV.bin" }
if {$PhaseTopChannel == "VV (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_VV.bin" }
if {$PhaseTopChannel == "LL" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_LL.bin" }
if {$PhaseTopChannel == "LL (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_LL.bin" }
if {$PhaseTopChannel == "LR" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_LR.bin" }
if {$PhaseTopChannel == "LR (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_LR.bin" }
if {$PhaseTopChannel == "RR" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_RR.bin" }
if {$PhaseTopChannel == "RR (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_RR.bin" }
if {$PhaseTopChannel == "HH + VV" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_HHpVV.bin" }
if {$PhaseTopChannel == "HH + VV (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_HHpVV.bin" }
if {$PhaseTopChannel == "HV + VH" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_HVpVH.bin" }
if {$PhaseTopChannel == "HV + VH (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_HVpVH.bin" }
if {$PhaseTopChannel == "HH - VV" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_HHmVV.bin" }
if {$PhaseTopChannel == "HH - VV (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_HHmVV.bin" }
if {$PhaseTopChannel == "OPT 1" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_Opt1.bin" }
if {$PhaseTopChannel == "OPT 1 (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_Opt1.bin" }
if {$PhaseTopChannel == "OPT 2" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_Opt2.bin" }
if {$PhaseTopChannel == "OPT 2 (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_Opt2.bin" }
if {$PhaseTopChannel == "OPT 3" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_Opt3.bin" }
if {$PhaseTopChannel == "OPT 3 (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_Opt3.bin" }

if {$PhaseTopChannel == "Ch1" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_Ch1.bin" }
if {$PhaseTopChannel == "Ch1 (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_Ch1.bin" }
if {$PhaseTopChannel == "Ch2" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_Ch2.bin" }
if {$PhaseTopChannel == "Ch2 (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_Ch2.bin" }
if {$PhaseTopChannel == "Ch1 + Ch2" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_Ch1pCh2.bin" }
if {$PhaseTopChannel == "Ch1 + Ch2 (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_Ch1pCh2.bin" }
if {$PhaseTopChannel == "Ch1 - Ch2" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_Ch1mCh2.bin" }
if {$PhaseTopChannel == "Ch1 - Ch2 (avg)" } { set GammaHighFile "$HeightInvDirInput/cmplx_coh_avg_Ch1mCh2.bin" }

set GammaLowFile ""
if {$PhaseGroundChannel == "HH" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_HH.bin" }
if {$PhaseGroundChannel == "HH (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_HH.bin" }
if {$PhaseGroundChannel == "HV" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_HV.bin" }
if {$PhaseGroundChannel == "HV (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_HV.bin" }
if {$PhaseGroundChannel == "VV" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_VV.bin" }
if {$PhaseGroundChannel == "VV (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_VV.bin" }
if {$PhaseGroundChannel == "LL" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_LL.bin" }
if {$PhaseGroundChannel == "LL (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_LL.bin" }
if {$PhaseGroundChannel == "LR" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_LR.bin" }
if {$PhaseGroundChannel == "LR (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_LR.bin" }
if {$PhaseGroundChannel == "RR" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_RR.bin" }
if {$PhaseGroundChannel == "RR (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_RR.bin" }
if {$PhaseGroundChannel == "HH + VV" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_HHpVV.bin" }
if {$PhaseGroundChannel == "HH + VV (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_HHpVV.bin" }
if {$PhaseGroundChannel == "HV + VH" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_HVpVH.bin" }
if {$PhaseGroundChannel == "HV + VH (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_HVpVH.bin" }
if {$PhaseGroundChannel == "HH - VV" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_HHmVV.bin" }
if {$PhaseGroundChannel == "HH - VV (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_HHmVV.bin" }
if {$PhaseGroundChannel == "OPT 1" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_Opt1.bin" }
if {$PhaseGroundChannel == "OPT 1 (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_Opt1.bin" }
if {$PhaseGroundChannel == "OPT 2" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_Opt2.bin" }
if {$PhaseGroundChannel == "OPT 2 (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_Opt2.bin" }
if {$PhaseGroundChannel == "OPT 3" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_Opt3.bin" }
if {$PhaseGroundChannel == "OPT 3 (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_Opt3.bin" }

if {$PhaseGroundChannel == "Ch1" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_Ch1.bin" }
if {$PhaseGroundChannel == "Ch1 (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_Ch1.bin" }
if {$PhaseGroundChannel == "Ch2" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_Ch2.bin" }
if {$PhaseGroundChannel == "Ch2 (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_Ch2.bin" }
if {$PhaseGroundChannel == "Ch1 + Ch2" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_Ch1pCh2.bin" }
if {$PhaseGroundChannel == "Ch1 + Ch2 (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_Ch1pCh2.bin" }
if {$PhaseGroundChannel == "Ch1 - Ch2" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_Ch1mCh2.bin" }
if {$PhaseGroundChannel == "Ch1 - Ch2 (avg)" } { set GammaLowFile "$HeightInvDirInput/cmplx_coh_avg_Ch1mCh2.bin" }
}
#############################################################################
## Procedure:  HeightInv_DEM

proc ::HeightInv_DEM {} {
global DataDirChannel1 DataDirChannel2 DirName GammaHighFile GammaLowFile
global HeightInvDirInput HeightInvDirOutput HeightInvOutputDir HeightInvOutputSubDir
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile OpenDirFile KzFile
global OffsetLig OffsetCol FinalNlig FinalNcol HeightInvConfig
global VarError ErrorMessage
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    Gamma_Files

    set TestVarName(0) "Gamma High File"; set TestVarType(0) "file"; set TestVarValue(0) $GammaHighFile; set TestVarMin(0) ""; set TestVarMax(0) ""
    set TestVarName(1) "Gamma Low File"; set TestVarType(1) "file"; set TestVarValue(1) $GammaLowFile; set TestVarMin(1) ""; set TestVarMax(1) ""
    TestVar 2
    if {$TestVarError == "ok"} {

        set Fonction "Height Estimation from"
        set Fonction2 "Inversion Procedures - DEM"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/height_estimation_inversion_procedure_DEM.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$HeightInvDirInput\x22 -od \x22$HeightInvDirOutput\x22 -ifgh \x22$GammaHighFile\x22 -ifgl \x22$GammaLowFile\x22 -kz \x22$KzFile\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
        set f [ open "| Soft/data_process_dual/height_estimation_inversion_procedure_DEM.exe -id \x22$HeightInvDirInput\x22 -od \x22$HeightInvDirOutput\x22 -ifgh \x22$GammaHighFile\x22 -ifgl \x22$GammaLowFile\x22 -kz \x22$KzFile\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set filename "$HeightInvDirOutput/DEM_diff_heights"
        EnviWriteConfig "$filename.bin" $FinalNlig $FinalNcol 4

        set HeightInvConfig "true"
        set BMPDirInput $HeightInvDirOutput

        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -10 10
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }   
    }
}
#############################################################################
## Procedure:  HeightInv_RVOG

proc ::HeightInv_RVOG {} {
global DataDirChannel1 DataDirChannel2 DirName GammaHighFile GammaLowFile
global HeightInvDirInput HeightInvDirOutput HeightInvOutputDir HeightInvOutputSubDir
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile OpenDirFile KzFile HeightInvNwin HeightInvFactor
global OffsetLig OffsetCol FinalNlig FinalNcol HeightInvConfig
global VarError ErrorMessage
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    Gamma_Files

    set TestVarName(0) "Gamma High File"; set TestVarType(0) "file"; set TestVarValue(0) $GammaHighFile; set TestVarMin(0) ""; set TestVarMax(0) ""
    set TestVarName(1) "Gamma Low File"; set TestVarType(1) "file"; set TestVarValue(1) $GammaLowFile; set TestVarMin(1) ""; set TestVarMax(1) ""
    set TestVarName(2) "Fraction Factor"; set TestVarType(2) "float"; set TestVarValue(2) $HeightInvFactor; set TestVarMin(2) "0.0"; set TestVarMax(2) "10000.00"
    TestVar 3
    if {$TestVarError == "ok"} {

        set Fonction "Height Estimation from"
        set Fonction2 "Inversion Procedures - RVOG"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/height_estimation_inversion_procedure_RVOG.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$HeightInvDirInput\x22 -od \x22$HeightInvDirOutput\x22 -ifgh \x22$GammaHighFile\x22 -ifgl \x22$GammaLowFile\x22 -kz \x22$KzFile\x22 -nwr $HeightInvNwin -nwc $HeightInvNwin -coef $HeightInvFactor -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
        set f [ open "| Soft/data_process_dual/height_estimation_inversion_procedure_RVOG.exe -id \x22$HeightInvDirInput\x22 -od \x22$HeightInvDirOutput\x22 -ifgh \x22$GammaHighFile\x22 -ifgl \x22$GammaLowFile\x22 -kz \x22$KzFile\x22 -nwr $HeightInvNwin -nwc $HeightInvNwin -coef $HeightInvFactor -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        EnviWriteConfig "$HeightInvDirOutput/Ground_phase.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$HeightInvDirOutput/Ground_phase_median.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$HeightInvDirOutput/RVOG_phase_heights.bin" $FinalNlig $FinalNcol 4
        EnviWriteConfig "$HeightInvDirOutput/RVOG_heights.bin" $FinalNlig $FinalNcol 4

        set HeightInvConfig "true"
        set BMPDirInput $HeightInvDirOutput

        set filename "$HeightInvDirOutput/Ground_phase"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180 180
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set filename "$HeightInvDirOutput/Ground_phase_median"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180 180
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set filename "$HeightInvDirOutput/RVOG_phase_heights"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -25 25
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set filename "$HeightInvDirOutput/RVOG_heights"
        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -25 25
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }   
    }
}
#############################################################################
## Procedure:  HeightInv_COH

proc ::HeightInv_COH {} {
global DataDirChannel1 DataDirChannel2 DirName GammaHighFile GammaLowFile
global HeightInvDirInput HeightInvDirOutput HeightInvOutputDir HeightInvOutputSubDir
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile OpenDirFile KzFile
global OffsetLig OffsetCol FinalNlig FinalNcol HeightInvConfig
global VarError ErrorMessage
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    Gamma_Files

    set TestVarName(0) "Gamma High File"; set TestVarType(0) "file"; set TestVarValue(0) $GammaHighFile; set TestVarMin(0) ""; set TestVarMax(0) ""
    set TestVarName(1) "Gamma Low File"; set TestVarType(1) "file"; set TestVarValue(1) $GammaLowFile; set TestVarMin(1) ""; set TestVarMax(1) ""
    TestVar 2
    if {$TestVarError == "ok"} {

        set Fonction "Height Estimation from"
        set Fonction2 "Inversion Procedures - DEM"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_dual/height_estimation_inversion_procedure_COH.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$HeightInvDirInput\x22 -od \x22$HeightInvDirOutput\x22 -ifgh \x22$GammaHighFile\x22 -ifgl \x22$GammaLowFile\x22 -kz \x22$KzFile\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
        set f [ open "| Soft/data_process_dual/height_estimation_inversion_procedure_COH.exe -id \x22$HeightInvDirInput\x22 -od \x22$HeightInvDirOutput\x22 -ifgh \x22$GammaHighFile\x22 -ifgl \x22$GammaLowFile\x22 -kz \x22$KzFile\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set filename "$HeightInvDirOutput/Coh_heights"
        EnviWriteConfig "$filename.bin" $FinalNlig $FinalNcol 4

        set HeightInvConfig "true"
        set BMPDirInput $HeightInvDirOutput

        if [file exists "$filename.bin"] {
            set BMPFileInput "$filename.bin"
            set BMPFileOutput "$filename.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -25 25
            } else {
            set config "false"
            set VarError ""
            set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }   
    }
}
#############################################################################
## Procedure:  HeightInv_Phase

proc ::HeightInv_Phase {} {
global DataDirChannel1 DataDirChannel2 DirName GammaHighFile GammaLowFile
global HeightInvDirInput HeightInvDirOutput HeightInvOutputDir HeightInvOutputSubDir
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile OpenDirFile KzFile PhaseCenterType PhaseCenterAvg
global OffsetLig OffsetCol FinalNlig FinalNcol HeightInvConfig
global VarError ErrorMessage
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    PhaseCenter_File

    set Fonction "Height Estimation from"
    set Fonction2 "Phase Center Estimation"
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/data_process_dual/phase_center_height_estimation.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$HeightInvDirInput\x22 -od \x22$HeightInvDirOutput\x22 -kz \x22$KzFile\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -type $PhaseCenterType -avg $PhaseCenterAvg" "k"
    set f [ open "| Soft/data_process_dual/phase_center_height_estimation.exe -id \x22$HeightInvDirInput\x22 -od \x22$HeightInvDirOutput\x22 -kz \x22$KzFile\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -type $PhaseCenterType -avg $PhaseCenterAvg" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    set filename "$HeightInvDirOutput/phase_center_height_"
    if {$PhaseCenterAvg == 1} { append filename "avg_" }
    append filename $PhaseCenterType 
    EnviWriteConfig "$filename.bin" $FinalNlig $FinalNcol 4

    set HeightInvConfig "true"
    set BMPDirInput $HeightInvDirOutput

    if [file exists "$filename.bin"] {
        set BMPFileInput "$filename.bin"
        set BMPFileOutput "$filename.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -15 15
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE $filename.bin DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }   
    }
}
#############################################################################
## Procedure:  PhaseCenter_File

proc ::PhaseCenter_File {} {
global HeightInvDirInput PhaseCenterType
global PhaseCenterAvg PhaseCenterChannel

set PhaseCenterType ""; set PhaseCenterAvg 0
if {$PhaseCenterChannel == "HH" } { set PhaseCenterType "HH" }
if {$PhaseCenterChannel == "HH (avg)" } { set PhaseCenterType "HH"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "HV" } { set PhaseCenterType "HV" }
if {$PhaseCenterChannel == "HV (avg)" } { set PhaseCenterType "HV"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "VV" } { set PhaseCenterType "VV" }
if {$PhaseCenterChannel == "VV (avg)" } { set PhaseCenterType "VV"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "LL" } { set PhaseCenterType "LL" }
if {$PhaseCenterChannel == "LL (avg)" } { set PhaseCenterType "LL"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "LR" } { set PhaseCenterType "LR" }
if {$PhaseCenterChannel == "LR (avg)" } { set PhaseCenterType "LR"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "RR" } { set PhaseCenterType "RR" }
if {$PhaseCenterChannel == "RR (avg)" } { set PhaseCenterType "RR"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "HH + VV" } { set PhaseCenterType "HHpVV" }
if {$PhaseCenterChannel == "HH + VV (avg)" } { set PhaseCenterType "HHpVV"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "HV + VH" } { set PhaseCenterType "HVpVH" }
if {$PhaseCenterChannel == "HV + VH (avg)" } { set PhaseCenterType "HVpVH"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "HH - VV" } { set PhaseCenterType "HHmVV" }
if {$PhaseCenterChannel == "HH - VV (avg)" } { set PhaseCenterType "HHmVV"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "OPT 1" } { set PhaseCenterType "Opt1" }
if {$PhaseCenterChannel == "OPT 1 (avg)" } { set PhaseCenterType "Opt1"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "OPT 2" } { set PhaseCenterType "Opt2" }
if {$PhaseCenterChannel == "OPT 2 (avg)" } { set PhaseCenterType "Opt2"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "OPT 3" } { set PhaseCenterType "Opt3" }
if {$PhaseCenterChannel == "OPT 3 (avg)" } { set PhaseCenterType "Opt3"; set PhaseCenterAvg 1 }

if {$PhaseCenterChannel == "Ch1" } { set PhaseCenterType "Ch1" }
if {$PhaseCenterChannel == "Ch1 (avg)" } { set PhaseCenterType "Ch1"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "Ch2" } { set PhaseCenterType "Ch2" }
if {$PhaseCenterChannel == "Ch2 (avg)" } { set PhaseCenterType "Ch2"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "Ch1 + Ch2" } { set PhaseCenterType "Ch1pCh2" }
if {$PhaseCenterChannel == "Ch1 + Ch2 (avg)" } { set PhaseCenterType "Ch1pCh2"; set PhaseCenterAvg 1 }
if {$PhaseCenterChannel == "Ch1 - Ch2" } { set PhaseCenterType "Ch1mCh2" }
if {$PhaseCenterChannel == "Ch1 - Ch2 (avg)" } { set PhaseCenterType "Ch1mCh2"; set PhaseCenterAvg 1 }

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

proc vTclWindow.top319 {base} {
    if {$base == ""} {
        set base .top319
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
    wm geometry $top 500x450+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Height Estimation from Inversion Procedures"
    vTcl:DefineAlias "$top" "Toplevel319" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Master - Slave Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel319" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HeightInvDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry319_149" vTcl:WidgetProc "Toplevel319" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel319" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -command {global ConfigFile VarError ErrorMessage
global HeightInvCohAvg HeightInvNwin HeightInvFactor
global DirName DataDirChannel1 HeightInvDirInput

set HeightInvDirInputTmp $HeightInvDirInput
set DirName ""
OpenDir $DataDirChannel1 "DATA INPUT MAIN DIRECTORY"
if {$DirName != "" } {
    if [file exists "$DirName/config.txt"] {
        set ConfigFile "$DirName/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            set HeightInvDirInput $DirName
            set HeightInvCohAvg 0; set HeightInvNwin 5; set HeightInvFactor 0.5
            } else {
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        } else {
        set HeightInvDirInput $HeightInvDirInputTmp
        set ErrorMessage "ENTER A VALID DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set HeightInvDirInput $HeightInvDirInputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel319" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit76 \
        -text {Output Master - Slave Directory} 
    vTcl:DefineAlias "$top.tit76" "TitleFrame2" vTcl:WidgetProc "Toplevel319" 1
    bind $top.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit76 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable HeightInvOutputDir 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry319_73" vTcl:WidgetProc "Toplevel319" 1
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame13" vTcl:WidgetProc "Toplevel319" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab73" "Label1" vTcl:WidgetProc "Toplevel319" 1
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable HeightInvOutputSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel319" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame2" vTcl:WidgetProc "Toplevel319" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global DirName DataDirChannel1 HeightInvOutputDir

set HeightInvOutputDirTmp $HeightInvOutputDir
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT MAIN DIRECTORY"
if {$DirName != "" } {
    set HeightInvOutputDir $DirName
    } else {
    set HeightInvOutputDir $HeightInvOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button319_92" vTcl:WidgetProc "Toplevel319" 1
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
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel319" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label319_01" vTcl:WidgetProc "Toplevel319" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry319_01" vTcl:WidgetProc "Toplevel319" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label319_02" vTcl:WidgetProc "Toplevel319" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry319_02" vTcl:WidgetProc "Toplevel319" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label319_03" vTcl:WidgetProc "Toplevel319" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry319_03" vTcl:WidgetProc "Toplevel319" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label319_04" vTcl:WidgetProc "Toplevel319" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry319_04" vTcl:WidgetProc "Toplevel319" 1
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
    button $top.cpd94 \
        -background #ffff00 -command HeightInvUpdate -padx 4 -pady 2 \
        -text {Update List} 
    vTcl:DefineAlias "$top.cpd94" "Button17" vTcl:WidgetProc "Toplevel319" 1
    bindtags $top.cpd94 "$top.cpd94 Button $top all _vTclBalloon"
    bind $top.cpd94 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Update List}
    }
    frame $top.fra75 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra75" "Frame5" vTcl:WidgetProc "Toplevel319" 1
    set site_3_0 $top.fra75
    checkbutton $site_3_0.che77 \
        \
        -command {global PhaseCenterHeight HeightInvDEM HeightInvCoh HeightInvRVOG
global KzFile

if {$PhaseCenterHeight == 1} {
    $widget(Label319_1) configure -state normal
    $widget(ComboBox319_1) configure -state normal -entrybg #FFFFFF
    $widget(TitleFrame319_1) configure -state normal
    $widget(Button319_4) configure -state normal
    $widget(Entry319_3) configure -state disable
    $widget(Entry319_3) configure -disabledbackground #FFFFFF
    set KzFile ""
} else {
    $widget(Label319_1) configure -state disable
    $widget(ComboBox319_1) configure -state disabled -entrybg $PSPBackgroundColor
    set config "off"
    if {$HeightInvCoh == 1} { set config "on" }
    if {$HeightInvDEM == 1} { set config "on" }
    if {$HeightInvRVOG == 1} { set config "on" }
    if {$config == "off" } {
        $widget(TitleFrame319_1) configure -state disable
        $widget(Button319_4) configure -state disable
        $widget(Entry319_3) configure -state disable
        $widget(Entry319_3) configure -disabledbackground $PSPBackgroundColor
        set KzFile ""
        }
}} \
        -text {Polarimetric Phase Centre Height Estimation} \
        -variable PhaseCenterHeight 
    vTcl:DefineAlias "$site_3_0.che77" "Checkbutton2" vTcl:WidgetProc "Toplevel319" 1
    ComboBox $site_3_0.com79 \
        -entrybg #ffffff -takefocus 1 -textvariable PhaseCenterChannel \
        -width 12 
    vTcl:DefineAlias "$site_3_0.com79" "ComboBox319_1" vTcl:WidgetProc "Toplevel319" 1
    bindtags $site_3_0.com79 "$site_3_0.com79 BwComboBox $top all"
    label $site_3_0.lab78 \
        -text {Polarimetric Channel} 
    vTcl:DefineAlias "$site_3_0.lab78" "Label319_1" vTcl:WidgetProc "Toplevel319" 1
    pack $site_3_0.che77 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.com79 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_3_0.lab78 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    frame $top.cpd93 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd93" "Frame19" vTcl:WidgetProc "Toplevel319" 1
    set site_3_0 $top.cpd93
    checkbutton $site_3_0.che77 \
        \
        -command {global HeightInvDEM HeightInvCoh HeightInvRVOG PhaseCenterHeight
global KzFile

if {$HeightInvDEM == 1} {
    $widget(Label319_4) configure -state normal
    $widget(ComboBox319_2) configure -state normal -entrybg #FFFFFF
    $widget(Label319_5) configure -state normal
    $widget(ComboBox319_3) configure -state normal -entrybg #FFFFFF
    $widget(TitleFrame319_1) configure -state normal
    $widget(Button319_4) configure -state normal
    $widget(Entry319_3) configure -state disable
    $widget(Entry319_3) configure -disabledbackground #FFFFFF
    set KzFile ""
} else {
    set config "off"
    if {$HeightInvCoh == 1} { set config "on" }
    if {$HeightInvRVOG == 1} { set config "on" }
    if {$config == "off" } {
        $widget(Label319_4) configure -state disable
        $widget(ComboBox319_2) configure -state disabled -entrybg $PSPBackgroundColor
        $widget(Label319_5) configure -state disable
        $widget(ComboBox319_3) configure -state disabled -entrybg $PSPBackgroundColor
        }
    if {$PhaseCenterHeight == 1} { set config "on" }
    if {$config == "off" } {
        $widget(TitleFrame319_1) configure -state disable
        $widget(Button319_4) configure -state disable
        $widget(Entry319_3) configure -state disable
        $widget(Entry319_3) configure -disabledbackground $PSPBackgroundColor
        set KzFile ""
        }
}} \
        -text {DEM Differencing Algorithm} -variable HeightInvDEM 
    vTcl:DefineAlias "$site_3_0.che77" "Checkbutton5" vTcl:WidgetProc "Toplevel319" 1
    pack $site_3_0.che77 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.cpd89 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd89" "Frame8" vTcl:WidgetProc "Toplevel319" 1
    set site_3_0 $top.cpd89
    checkbutton $site_3_0.che77 \
        \
        -command {global HeightInvDEM HeightInvCoh HeightInvRVOG PhaseCenterHeight
global KzFile

if {$HeightInvCoh == 1} {
    $widget(Label319_4) configure -state normal
    $widget(ComboBox319_2) configure -state normal -entrybg #FFFFFF
    $widget(Label319_5) configure -state normal
    $widget(ComboBox319_3) configure -state normal -entrybg #FFFFFF
    $widget(TitleFrame319_1) configure -state normal
    $widget(Button319_4) configure -state normal
    $widget(Entry319_3) configure -state disable
    $widget(Entry319_3) configure -disabledbackground #FFFFFF
    set KzFile ""
} else {
    set config "off"
    if {$HeightInvDEM == 1} { set config "on" }
    if {$HeightInvRVOG == 1} { set config "on" }
    if {$config == "off" } {
        $widget(Label319_4) configure -state disable
        $widget(ComboBox319_2) configure -state disabled -entrybg $PSPBackgroundColor
        $widget(Label319_5) configure -state disable
        $widget(ComboBox319_3) configure -state disabled -entrybg $PSPBackgroundColor
        }
    if {$PhaseCenterHeight == 1} { set config "on" }
    if {$config == "off" } {
        $widget(TitleFrame319_1) configure -state disable
        $widget(Button319_4) configure -state disable
        $widget(Entry319_3) configure -state disable
        $widget(Entry319_3) configure -disabledbackground $PSPBackgroundColor
        set KzFile ""
        }
}} \
        -text {Coherence Amplitude Inversion Procedure} \
        -variable HeightInvCoh 
    vTcl:DefineAlias "$site_3_0.che77" "Checkbutton4" vTcl:WidgetProc "Toplevel319" 1
    pack $site_3_0.che77 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra80 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra80" "Frame6" vTcl:WidgetProc "Toplevel319" 1
    set site_3_0 $top.fra80
    frame $site_3_0.cpd81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd81" "Frame7" vTcl:WidgetProc "Toplevel319" 1
    set site_4_0 $site_3_0.cpd81
    checkbutton $site_4_0.che77 \
        \
        -command {global HeightInvDEM HeightInvCoh HeightInvRVOG PhaseCenterHeight
global HeightInvNwin HeightInvFactor KzFile

if {$HeightInvRVOG == 1} {
    $widget(Label319_2) configure -state normal
    $widget(Button319_2) configure -state normal
    $widget(Button319_3) configure -state normal
    $widget(Entry319_1) configure -state disable
    $widget(Entry319_1) configure -disabledbackground #FFFFFF
    set HeightInvNwin "11"
    $widget(Label319_3) configure -state normal
    $widget(Entry319_2) configure -state normal
    $widget(Entry319_2) configure -disabledbackground #FFFFFF
    set HeightInvFactor "0.5"
    
    $widget(Label319_4) configure -state normal
    $widget(ComboBox319_2) configure -state normal -entrybg #FFFFFF
    $widget(Label319_5) configure -state normal
    $widget(ComboBox319_3) configure -state normal -entrybg #FFFFFF
    $widget(TitleFrame319_1) configure -state normal
    $widget(Button319_4) configure -state normal
    $widget(Entry319_3) configure -state disable
    $widget(Entry319_3) configure -disabledbackground #FFFFFF
    set KzFile ""
} else {
    $widget(Label319_2) configure -state disable
    $widget(Button319_2) configure -state disable
    $widget(Button319_3) configure -state disable
    $widget(Entry319_1) configure -state disable
    $widget(Entry319_1) configure -disabledbackground $PSPBackgroundColor
    set HeightInvNwin ""
    $widget(Label319_3) configure -state disable
    $widget(Entry319_2) configure -state disable
    $widget(Entry319_2) configure -disabledbackground $PSPBackgroundColor
    set HeightInvFactor ""
    
    set config "off"
    if {$HeightInvDEM == 1} { set config "on" }
    if {$HeightInvCoh == 1} { set config "on" }
    if {$config == "off" } {
        $widget(Label319_4) configure -state disable
        $widget(ComboBox319_2) configure -state disabled -entrybg $PSPBackgroundColor
        $widget(Label319_5) configure -state disable
        $widget(ComboBox319_3) configure -state disabled -entrybg $PSPBackgroundColor
        }
    if {$PhaseCenterHeight == 1} { set config "on" }
    if {$config == "off" } {
        $widget(TitleFrame319_1) configure -state disable
        $widget(Button319_4) configure -state disable
        $widget(Entry319_3) configure -state disable
        $widget(Entry319_3) configure -disabledbackground $PSPBackgroundColor
        set KzFile ""
        }
}} \
        -text {Ground Phase Estimation and RVOG Inversion Procedure} \
        -variable HeightInvRVOG 
    vTcl:DefineAlias "$site_4_0.che77" "Checkbutton3" vTcl:WidgetProc "Toplevel319" 1
    pack $site_4_0.che77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.fra83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra83" "Frame11" vTcl:WidgetProc "Toplevel319" 1
    set site_4_0 $site_3_0.fra83
    frame $site_4_0.fra84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra84" "Frame12" vTcl:WidgetProc "Toplevel319" 1
    set site_5_0 $site_4_0.fra84
    label $site_5_0.lab86 \
        -text {Median Window Size  } 
    vTcl:DefineAlias "$site_5_0.lab86" "Label319_2" vTcl:WidgetProc "Toplevel319" 1
    frame $site_5_0.cpd87 \
        -borderwidth 2 -relief groove 
    set site_6_0 $site_5_0.cpd87
    entry $site_6_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable HeightInvNwin -width 5 
    vTcl:DefineAlias "$site_6_0.ent78" "Entry319_1" vTcl:WidgetProc "Toplevel319" 1
    frame $site_6_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd77" "Frame15" vTcl:WidgetProc "Toplevel319" 1
    set site_7_0 $site_6_0.cpd77
    button $site_7_0.but79 \
        \
        -command {global HeightInvNwin

set HeightInvNwin [expr $HeightInvNwin - 2]
if {$HeightInvNwin == "-1"} {set HeightInvNwin 31}} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but79" "Button319_2" vTcl:WidgetProc "Toplevel319" 1
    button $site_7_0.but80 \
        \
        -command {global HeightInvNwin

set HeightInvNwin [expr $HeightInvNwin + 2]
if {$HeightInvNwin == 33} {set HeightInvNwin 1}} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.but80" "Button319_3" vTcl:WidgetProc "Toplevel319" 1
    pack $site_7_0.but79 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.but80 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.lab86 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd87 \
        -in $site_5_0 -anchor center -expand 1 -fill none -ipady 2 -side left 
    frame $site_4_0.cpd88
    set site_5_0 $site_4_0.cpd88
    label $site_5_0.cpd82 \
        -text {Weighting Coherence Fraction Factor  } 
    vTcl:DefineAlias "$site_5_0.cpd82" "Label319_3" vTcl:WidgetProc "Toplevel319" 1
    entry $site_5_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable HeightInvFactor -width 5 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry319_2" vTcl:WidgetProc "Toplevel319" 1
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.ent83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.fra84 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.fra83 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra90" "Frame10" vTcl:WidgetProc "Toplevel319" 1
    set site_3_0 $top.fra90
    frame $site_3_0.cpd91 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel319" 1
    set site_4_0 $site_3_0.cpd91
    label $site_4_0.lab78 \
        -text {Top Phase Centre} 
    vTcl:DefineAlias "$site_4_0.lab78" "Label319_4" vTcl:WidgetProc "Toplevel319" 1
    ComboBox $site_4_0.com79 \
        -entrybg white -takefocus 1 -textvariable PhaseTopChannel -width 12 
    vTcl:DefineAlias "$site_4_0.com79" "ComboBox319_2" vTcl:WidgetProc "Toplevel319" 1
    bindtags $site_4_0.com79 "$site_4_0.com79 BwComboBox $top all"
    pack $site_4_0.lab78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.com79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    frame $site_3_0.cpd92 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd92" "Frame18" vTcl:WidgetProc "Toplevel319" 1
    set site_4_0 $site_3_0.cpd92
    label $site_4_0.lab78 \
        -text {Ground Phase Centre} 
    vTcl:DefineAlias "$site_4_0.lab78" "Label319_5" vTcl:WidgetProc "Toplevel319" 1
    ComboBox $site_4_0.com79 \
        -entrybg white -takefocus 1 -textvariable PhaseGroundChannel \
        -width 12 
    vTcl:DefineAlias "$site_4_0.com79" "ComboBox319_3" vTcl:WidgetProc "Toplevel319" 1
    bindtags $site_4_0.com79 "$site_4_0.com79 BwComboBox $top all"
    pack $site_4_0.lab78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.com79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_3_0.cpd91 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipady 2 -side left 
    pack $site_3_0.cpd92 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipady 2 -side left 
    TitleFrame $top.tit92 \
        -ipad 2 -text {2D Kz File} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame319_1" vTcl:WidgetProc "Toplevel319" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    frame $site_4_0.cpd76 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame111" vTcl:WidgetProc "Toplevel319" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame16" vTcl:WidgetProc "Toplevel319" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable KzFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry319_3" vTcl:WidgetProc "Toplevel319" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame17" vTcl:WidgetProc "Toplevel319" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName DataDirChannel2 KzFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D Kz FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Kz Files}        {.dat}        }
{{Kz Files}        {.bin}        }
}
set FileName ""
OpenFile "$DataDirChannel2" $types "2D Kz FILE"
if {$FileName != ""} {
    set KzFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button319_4" vTcl:WidgetProc "Toplevel319" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra90 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel319" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2 DirName HeightInvConfig
global HeightInvDirInput HeightInvDirOutput HeightInvOutputDir HeightInvOutputSubDir
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile OpenDirFile KzFile PhaseCenterHeight HeightInvDEM HeightInvCoh HeightInvRVOG
global OffsetLig OffsetCol FinalNlig FinalNcol HeightInvConfig
global VarError ErrorMessage
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config "false"
if {$PhaseCenterHeight == "1" } {set config "true"}
if {$HeightInvDEM == "1" } {set config "true"}
if {$HeightInvCoh == "1" } {set config "true"}
if {$HeightInvRVOG == "1" } {set config "true"}
if {$config == "false"} {
    set VarError ""
    set ErrorMessage "SELECT AN INVERSION PROCEDURE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    
    set configrun "true"
    set cconfig "false"
    if {$HeightInvDEM == "1" } {set cconfig "true"}
    if {$HeightInvCoh == "1" } {set cconfig "true"}
    if {$HeightInvRVOG == "1" } {set cconfig "true"}
    if {$cconfig == "true"} {
        if {$PhaseTopChannel == $PhaseGroundChannel } {
            set VarError ""
            set ErrorMessage "THE TWO PHASE CENTERS MUST BE DIFFERENT" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set configrun "false"
            }
        }
        
    if {$configrun == "true"} {

        set HeightInvDirOutput $HeightInvOutputDir
        if {$HeightInvOutputSubDir != ""} {append HeightInvDirOutput "/$HeightInvOutputSubDir"}

        #####################################################################
        #Create Directory
        set HeightInvDirOutput [PSPCreateDirectoryMask $HeightInvDirOutput $HeightInvOutputDir $HeightInvDirInput]
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
            set TestVarName(4) "2D Kz File"; set TestVarType(4) "file"; set TestVarValue(4) $KzFile; set TestVarMin(4) ""; set TestVarMax(4) ""
            TestVar 5
            if {$TestVarError == "ok"} {
                set HeightInvConfig "false"
                if { $PhaseCenterHeight == "1" } { HeightInv_Phase }
                if { $HeightInvDEM == "1" } { HeightInv_DEM }
                if { $HeightInvCoh == "1" } { HeightInv_COH }
                if { $HeightInvRVOG == "1" } { HeightInv_RVOG }
                set BMPDirInput $HeightInvDirOutput
                if { $HeightInvConfig == "true" } { $widget(Button319_1) configure -state normal }
                }   
                #TestVar
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel319); TextEditorRunTrace "Close Window Height Estimation from Inversion Procedures" "b"}
        }
        #VarWarning
    }
    #configrun
}
#config

}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel319" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but73 \
        -background #ffff00 \
        -command {global DataDir FileName
global HeightInvDirInput HeightInvDirOutput HeightInvOutputDir HeightInvOutputSubDir
global HistoDirInput HistoDirOutput HistoOutputDir HistoOutputSubDir
global HistoFileInput HistoFileOpen
global TMPStatisticsTxt TMPStatisticsBin TMPStatResultsTxt
global BMPDirInput BMPViewFileInput
global LineXLensInit LineYLensInit line_color
global ConfigFile VarError ErrorMessage Fonction
global VarWarning WarningMesage WarningMessage2
global HistoExecFid HistoOutputFile
global GnuPlotPath GnuplotPipeFid GnuplotPipeHisto
global GnuOutputFormat GnuOutputFile 
global GnuHistoTitle GnuHistoLabel GnuHistoStyle
global HistoInputFormat HistoOutputFormat
global MinMaxAutoHisto MinHisto MaxHisto
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol AreaPointN
global widget SourceWidth SourceHeight WidthBMP HeightBMP BMPWidth BMPHeight
global ZoomBMP BMPImage ImageSource BMPCanvas
global TrainingAreaToolLine rect_color VarHistoSave VarStatToolLine                    

#DATA PROCESS SNGL
global Load_Histograms
#BMP PROCESS
global Load_ViewBMPLens PSPTopLevel

ClosePSPViewer
Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"

set config "true"
if {$HistoExecFid != ""} {
    set ErrorMessage "STATISTICS - HISTOGRAM IS ALREADY RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$GnuplotPipeFid != ""} {
    set ErrorMessage "GNUPLOT IS ALREADY RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$config == "true"} {
if [file exists "$HeightInvDirInput/config.txt"] {
    set HistoDirInput $HeightInvDirInput
    set HistoDirOutput $HeightInvDirOutput
    set HistoOutputDir $HeightInvOutputDir
    set HistoOutputSubDir $HeightInvOutputSubDir
    set BMPDirInput $HistoDirInput
    set ConfigFile "$HistoDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$OpenDirFile == 0} {
            set WarningMessage "OPEN A BMP FILE"
            set WarningMessage2 "TO SELECT AN AREA"
            set VarWarning ""
            Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
            tkwait variable VarWarning

            if {$VarWarning == "ok"} {
                LoadPSPViewer
                Window show $widget(Toplevel64); TextEditorRunTrace "Open Window PolSARpro Viewer" "b"

                if {$Load_Histograms == 0} {
                    source "GUI/data_process_sngl/Histograms.tcl"
                    set Load_Histograms 1
                    WmTransient $widget(Toplevel260) $PSPTopLevel
                    }
                set line_color "white"
                set b .top260.fra73.fra74.but77
                $b configure -background $line_color -foreground $line_color
                set GnuOutputFormat "SCREEN"
                set GnuOutputFile ""; set HistoOutputFile ""
                set NTrainingArea(0) 0; set AreaPoint(0) 0; set AreaPointLig(0) 0; set AreaPointCol(0) 0
                for {set i 0} {$i <= 2} {incr i} {
                    set NTrainingArea($i) ""
                    for {set j 0} {$j <= 2} {incr j} {
                        set Argument [expr (100*$i + $j)]
                        set AreaPoint($Argument) ""
                        for {set k 0} {$k <= 17} {incr k} {
                            set Argument [expr (10000*$i + 100*$j + $k)]
                            set AreaPointLig($Argument) ""
                            set AreaPointCol($Argument) ""
                            }
                        }
                    }           
                set AreaClassN 1; set NTrainingAreaClass 1; set AreaN 1; set NTrainingArea(1) 1; set AreaPointN ""
                set TrainingAreaToolLine "false"; set rect_color "white"; set VarHistoSave "no"; set VarStatToolLine "stop"                    
                set MouseInitX ""; set MouseInitY ""; set MouseEndX ""; set MouseEndY ""; set MouseNlig ""; set MouseNcol ""
                $widget(Button260_2) configure -state disable
                $widget(Button260_3) configure -state disable
                $widget(Button260_4) configure -state disable
                $widget(Button260_5) configure -state disable
                $widget(Radiobutton260_1) configure -state disable
                $widget(Radiobutton260_2) configure -state disable
                DeleteFile $TMPStatisticsTxt
                DeleteFile $TMPStatisticsBin
                DeleteFile $TMPStatResultsTxt
                TextEditorRunTrace "Launch The Process Soft/data_process_sngl/statistics_histogram_extract.exe" "k"
                TextEditorRunTrace "Arguments: \x22$TMPStatisticsTxt\x22 \x22$TMPStatisticsBin\x22" "k"
                set HistoExecFid [ open "| Soft/data_process_sngl/statistics_histogram_extract.exe \x22$TMPStatisticsTxt\x22 \x22$TMPStatisticsBin\x22" r+]
                set GnuplotPipeStat "";  set HistoFileInput ""; set HistoFileOpen 0
                set GnuHistoTitle "HISTOGRAM"; set GnuHistoLabel "Label"; set GnuHistoStyle "lines"
                set HistoInputFormat "float"; set HistoOutputFormat "real"
                $widget(Radiobutton260_3) configure -state disable; $widget(Radiobutton260_4) configure -state disable
                set MinMaxAutoHisto 1; set MinHisto "Auto"; set MaxHisto "Auto"
                $widget(TitleFrame260_1) configure -state disable; $widget(Checkbutton260_1) configure -state disable
                $widget(Label260_1) configure -state disable; $widget(Entry260_1) configure -state disable
                $widget(Label260_2) configure -state disable; $widget(Entry260_2) configure -state disable
                $widget(Button260_1) configure -state disable
                #set xwindow [winfo x $widget(Toplevel319)]; set ywindow [winfo y $widget(Toplevel319)]
                #set geometrie "500x300+"; append geometrie $xwindow; append geometrie "+"; append geometrie [expr $ywindow + 350]
                #wm geometry $widget(Toplevel260) $geometrie; update
                WidgetShowFromWidget $widget(Toplevel319) $widget(Toplevel260); TextEditorRunTrace "Open Window Histograms" "b"
                }
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Hist 
    vTcl:DefineAlias "$site_3_0.but73" "Button319_1" vTcl:WidgetProc "Toplevel319" 1
    bindtags $site_3_0.but73 "$site_3_0.but73 Button $top all _vTclBalloon"
    bind $site_3_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Function Histogram}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/HeightEstimationInversionProcedure.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel319" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global HistoExecFid GnuplotPipeFid GnuplotPipeHisto
global Load_SaveHisto Load_Histograms

if {$OpenDirFile == 0} {

if {$Load_Histograms == 1} {
    if {$Load_SaveHisto == 1} {Window hide $widget(Toplevel261); TextEditorRunTrace "Close Window Save Histograms" "b"}
    if {$HistoExecFid != ""} {
        puts $HistoExecFid "exit\n"
        flush $HistoExecFid
        fconfigure $HistoExecFid -buffering line
        while {$ProgressLine != "OKexit"} {
            gets $HistoExecFid ProgressLine
            update
            }
        catch "close $HistoExecFid"
        set HistoExecFid ""

        PlotHistoRAZ   
        PlotHistoClose 
        ClosePSPViewer
        Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
        Window hide $widget(Toplevel260); TextEditorRunTrace "Close Window Histograms" "b"
        }
    }
Window hide $widget(Toplevel319); TextEditorRunTrace "Close Window Height Estimation from Inversion Procedures" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel319" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
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
    pack $top.cpd94 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $top.fra75 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -side top 
    pack $top.cpd93 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd89 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra80 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra90 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit92 \
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
Window show .top319

main $argc $argv
