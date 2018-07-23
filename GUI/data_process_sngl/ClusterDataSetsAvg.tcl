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
    set base .top375
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
        array set save {-image 1 -pady 1 -relief 1 -text 1}
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
    namespace eval ::widgets::$base.cpd86 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd86 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra72
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd79 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd80 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.rad87 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd89 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd90 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd91 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd94 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd72
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd84
    namespace eval ::widgets::$site_8_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.cpd67 {
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
            vTclWindow.top375
            ClusterDataT
            ClusterDataC
            ClusterDataI
            ClusterRGB_T3
            ClusterRGB_IPP
            ClusterRGB_C2
            ClusterRGB_C3
            ClusterRGB_C4
            ClusterDataS
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
## Procedure:  ClusterDataT

proc ::ClusterDataT {} {
global FinalNlig FinalNcol ConfigFile
global ClusterDirInput ClusterDirOutput 
global ClusterFileInData ClusterAvgOutputSubDirFormat ClusterFormat

set ConfigFile "$ClusterDirOutput/config.txt"
WriteConfig

set ClusterFileIn "$ClusterDirInput/T11.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T11.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
      
set ClusterFileIn "$ClusterDirInput/T12_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T12_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T12_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T12_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/T13_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T13_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T13_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T13_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/T14_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T14_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T14_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T14_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
set ClusterFileIn "$ClusterDirInput/T15_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T15_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T15_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T15_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/T16_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T16_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T16_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T16_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }


set ClusterFileIn "$ClusterDirInput/T22.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T22.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
set ClusterFileIn "$ClusterDirInput/T23_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T23_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T23_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T23_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T24_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T24_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T24_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T24_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
set ClusterFileIn "$ClusterDirInput/T25_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T25_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T25_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T25_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T26_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T26_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T26_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T26_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/T33.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T33.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T34_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T34_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T34_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T34_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T35_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T35_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T35_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T35_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T36_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T36_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T36_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T36_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/T44.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T44.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T45_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T45_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T45_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T45_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T46_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T46_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T46_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T46_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/T55.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T55.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T56_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T56_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/T56_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T56_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
set ClusterFileIn "$ClusterDirInput/T66.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/T66.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
}
#############################################################################
## Procedure:  ClusterDataC

proc ::ClusterDataC {} {
global FinalNlig FinalNcol ConfigFile
global ClusterDirInput ClusterDirOutput 
global ClusterFileInData ClusterAvgOutputSubDirFormat ClusterFormat

set ConfigFile "$ClusterDirOutput/config.txt"
WriteConfig

set ClusterFileIn "$ClusterDirInput/C11.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C11.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
set ClusterFileIn "$ClusterDirInput/C12_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C12_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C12_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C12_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/C13_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C13_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C13_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C13_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C14_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C14_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C14_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C14_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/C22.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C22.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
set ClusterFileIn "$ClusterDirInput/C23_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C23_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C23_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C23_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C24_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C24_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C24_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C24_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
set ClusterFileIn "$ClusterDirInput/C33.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C33.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C34_real.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C34_real.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
set ClusterFileIn "$ClusterDirInput/C34_imag.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C34_imag.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/C44.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/C44.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
}
#############################################################################
## Procedure:  ClusterDataI

proc ::ClusterDataI {} {
global FinalNlig FinalNcol ConfigFile
global ClusterDirInput ClusterDirOutput 
global ClusterFileInData ClusterAvgOutputSubDirFormat ClusterFormat

set ConfigFile "$ClusterDirOutput/config.txt"
WriteConfig

set ClusterFileIn "$ClusterDirInput/I11.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/I11.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
set ClusterFileIn "$ClusterDirInput/I12.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/I12.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
   
set ClusterFileIn "$ClusterDirInput/I21.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/I21.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }

set ClusterFileIn "$ClusterDirInput/I22.bin"
if [file exists $ClusterFileIn] {
    set ClusterFileOut "$ClusterDirOutput/I22.bin"
    PSPcluster_avg_prm $ClusterFileIn $ClusterFileInData $ClusterFileOut $FinalNlig $FinalNcol
    }
    
}
#############################################################################
## Procedure:  ClusterRGB_T3

proc ::ClusterRGB_T3 {} {
global ClusterDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError
   
set RGBDirInput $ClusterDirOutput
set RGBDirOutput $ClusterDirOutput
set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
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
    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  ClusterRGB_IPP

proc ::ClusterRGB_IPP {} {
global ClusterDirOutput BMPDirInput ClusterOutputFormatPP
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PolarType PSPMemory TMPMemoryAllocError
   
set RGBDirInput $ClusterDirOutput
set RGBDirOutput $ClusterDirOutput
set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
if {$PolarType == "pp5"} {set Channel1 "I11"; set Channel2 "I21"}
if {$PolarType == "pp6"} {set Channel1 "I12"; set Channel2 "I22"}
if {$PolarType == "pp7"} {set Channel1 "I11"; set Channel2 "I22"}
set config "true"
set fichier "$RGBDirInput/"
append fichier "$Channel1.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE $fichier HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/"
append fichier "$Channel2.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE $fichier HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf IPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf IPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  ClusterRGB_C2

proc ::ClusterRGB_C2 {} {
global ClusterDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError
   
set RGBDirInput $ClusterDirOutput
set RGBDirOutput $ClusterDirOutput
set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
set config "true"
set fichier "$RGBDirInput/C11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C12_real.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C12_real.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  ClusterRGB_C3

proc ::ClusterRGB_C3 {} {
global ClusterDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PSPMemory TMPMemoryAllocError
   
set RGBDirInput $ClusterDirOutput
set RGBDirOutput $ClusterDirOutput
set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
set config "true"
set fichier "$RGBDirInput/C11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C33.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C33.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C13_real.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C13_real.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  ClusterRGB_C4

proc ::ClusterRGB_C4 {} {
global ClusterDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP 
global ProgressLine PSPMemory TMPMemoryAllocError
   
set RGBDirInput $ClusterDirOutput
set RGBDirOutput $ClusterDirOutput
set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
set config "true"
set fichier "$RGBDirInput/C11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C33.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C33.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C44.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C44.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C23_real.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C23_real.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C14_real.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C14_real.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set MaskCmd ""
    set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C4 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C4 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -auto 1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  ClusterDataS

proc ::ClusterDataS {} {
global FinalNlig FinalNcol ConfigFile PSPMemory TMPMemoryAllocError
global ClusterDirInput ClusterDirOutput PolarType
global ClusterFileInData ClusterAvgOutputSubDirFormat ClusterFormat

set Fonction "Creation of the Averaged Data File"
set Fonction2 ""

if {$ClusterFormat == "S2m"} { set ClusterF "S2T3" }
if {$ClusterFormat == "S2b"} { set ClusterF "S2T4" }
if {$ClusterFormat == "SPP"} { set ClusterF "SPP" }

set MaskCmd ""
set MaskFile "$ClusterDirInput/mask_valid_pixels.bin"
if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

set ProgressLine "0"
update
TextEditorRunTrace "Process The Function Soft/data_process_sngl/cluster_avg_S2SPP.exe" "k"
TextEditorRunTrace "Arguments: -icf \x22$ClusterFileInData\x22 -id \x22$ClusterDirInput\x22 -od \x22$ClusterDirOutput\x22 -iodf $ClusterF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
set f [ open "| Soft/bmp_process/Soft/data_process_sngl/cluster_avg_S2SPP.exe -icf \x22$ClusterFileInData\x22 -id \x22$ClusterDirInput\x22 -od \x22$ClusterDirOutput\x22 -iodf $ClusterF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
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

proc vTclWindow.top375 {base} {
    if {$base == ""} {
        set base .top375
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
    wm geometry $top 500x350+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Data Clustering - Data Sets Averaging"
    vTcl:DefineAlias "$top" "Toplevel375" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel375" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ClusterDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry375_149" vTcl:WidgetProc "Toplevel375" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel375" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel375" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit76 \
        -text {Output Directory} 
    vTcl:DefineAlias "$top.tit76" "TitleFrame2" vTcl:WidgetProc "Toplevel375" 1
    bind $top.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit76 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ClusterOutputDir 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry375_73" vTcl:WidgetProc "Toplevel375" 1
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame13" vTcl:WidgetProc "Toplevel375" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab73" "Label1" vTcl:WidgetProc "Toplevel375" 1
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ClusterOutputSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel375" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame2" vTcl:WidgetProc "Toplevel375" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global DirName DataDir ClusterOutputDir

set ClusterOutputDirTmp $ClusterOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT MAIN DIRECTORY"
if {$DirName != "" } {
    set ClusterOutputDir $DirName
    } else {
    set ClusterOutputDir $ClusterOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button375_92" vTcl:WidgetProc "Toplevel375" 1
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
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel375" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label375_01" vTcl:WidgetProc "Toplevel375" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry375_01" vTcl:WidgetProc "Toplevel375" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label375_02" vTcl:WidgetProc "Toplevel375" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry375_02" vTcl:WidgetProc "Toplevel375" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label375_03" vTcl:WidgetProc "Toplevel375" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry375_03" vTcl:WidgetProc "Toplevel375" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label375_04" vTcl:WidgetProc "Toplevel375" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry375_04" vTcl:WidgetProc "Toplevel375" 1
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
    TitleFrame $top.cpd86 \
        -ipad 2 -text {Polarimetric Data Sets Averaging} 
    vTcl:DefineAlias "$top.cpd86" "TitleFrame13" vTcl:WidgetProc "Toplevel375" 1
    bind $top.cpd86 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd86 getframe]
    frame $site_4_0.fra72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra72" "Frame11" vTcl:WidgetProc "Toplevel375" 1
    set site_5_0 $site_4_0.fra72
    TitleFrame $site_5_0.cpd79 \
        -text {Input Cluster File} 
    vTcl:DefineAlias "$site_5_0.cpd79" "TitleFrame375_7" vTcl:WidgetProc "Toplevel375" 1
    bind $site_5_0.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd79 getframe]
    entry $site_7_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ClusterFileInData -width 60 
    vTcl:DefineAlias "$site_7_0.cpd77" "Entry375_8" vTcl:WidgetProc "Toplevel375" 1
    button $site_7_0.cpd78 \
        \
        -command {global FileName ClusterDirInput ClusterFileInData

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$ClusterDirInput" $types "INPUT CLUSTER FILE"
if {$FileName != ""} { set ClusterFileInData $FileName }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd78" "Button375_9" vTcl:WidgetProc "Toplevel375" 1
    bindtags $site_7_0.cpd78 "$site_7_0.cpd78 Button $top all _vTclBalloon"
    bind $site_7_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $site_5_0.cpd80 \
        -text {Output Data Format} 
    vTcl:DefineAlias "$site_5_0.cpd80" "TitleFrame375_8" vTcl:WidgetProc "Toplevel375" 1
    bind $site_5_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd80 getframe]
    radiobutton $site_7_0.rad87 \
        \
        -command {global ClusterAvgOutputSubDir
set ClusterAvgOutputSubDir "C2"} \
        -text C2 -value C2 -variable ClusterAvgOutputSubDirFormat 
    vTcl:DefineAlias "$site_7_0.rad87" "Radiobutton375_1" vTcl:WidgetProc "Toplevel375" 1
    radiobutton $site_7_0.cpd89 \
        \
        -command {global ClusterAvgOutputSubDir
set ClusterAvgOutputSubDir "C3"} \
        -text C3 -value C3 -variable ClusterAvgOutputSubDirFormat 
    vTcl:DefineAlias "$site_7_0.cpd89" "Radiobutton375_2" vTcl:WidgetProc "Toplevel375" 1
    radiobutton $site_7_0.cpd90 \
        \
        -command {global ClusterAvgOutputSubDir
set ClusterAvgOutputSubDir "C4"} \
        -text C4 -value C4 -variable ClusterAvgOutputSubDirFormat 
    vTcl:DefineAlias "$site_7_0.cpd90" "Radiobutton375_3" vTcl:WidgetProc "Toplevel375" 1
    radiobutton $site_7_0.cpd91 \
        \
        -command {global ClusterAvgOutputSubDir
set ClusterAvgOutputSubDir "T3"} \
        -text T3 -value T3 -variable ClusterAvgOutputSubDirFormat 
    vTcl:DefineAlias "$site_7_0.cpd91" "Radiobutton375_4" vTcl:WidgetProc "Toplevel375" 1
    radiobutton $site_7_0.cpd92 \
        \
        -command {global ClusterAvgOutputSubDir
set ClusterAvgOutputSubDir "T4"} \
        -text T4 -value T4 -variable ClusterAvgOutputSubDirFormat 
    vTcl:DefineAlias "$site_7_0.cpd92" "Radiobutton375_5" vTcl:WidgetProc "Toplevel375" 1
    radiobutton $site_7_0.cpd93 \
        \
        -command {global ClusterAvgOutputSubDir
set ClusterAvgOutputSubDir ""} \
        -text {( Ixx, Ixy )} -value IPP \
        -variable ClusterAvgOutputSubDirFormat 
    vTcl:DefineAlias "$site_7_0.cpd93" "Radiobutton375_6" vTcl:WidgetProc "Toplevel375" 1
    pack $site_7_0.rad87 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd89 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd90 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd91 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd94 \
        -text {Output Directory} 
    vTcl:DefineAlias "$site_5_0.cpd94" "TitleFrame375_9" vTcl:WidgetProc "Toplevel375" 1
    bind $site_5_0.cpd94 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd94 getframe]
    entry $site_7_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ClusterAvgOutputDir -width 52 
    vTcl:DefineAlias "$site_7_0.cpd82" "Entry375_9" vTcl:WidgetProc "Toplevel375" 1
    frame $site_7_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd72" "Frame14" vTcl:WidgetProc "Toplevel375" 1
    set site_8_0 $site_7_0.cpd72
    label $site_8_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_8_0.lab73" "Label375_1" vTcl:WidgetProc "Toplevel375" 1
    entry $site_8_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ClusterAvgOutputSubDir -width 3 
    vTcl:DefineAlias "$site_8_0.cpd75" "Entry375_10" vTcl:WidgetProc "Toplevel375" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 1 -fill x -side left 
    pack $site_8_0.cpd75 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd84" "Frame15" vTcl:WidgetProc "Toplevel375" 1
    set site_8_0 $site_7_0.cpd84
    button $site_8_0.cpd85 \
        \
        -command {global DirName DataDir ClusterAvgOutputDir

set ClusterOutputDirTmp $ClusterAvgOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT MAIN DIRECTORY"
if {$DirName != "" } {
    set ClusterAvgOutputDir $DirName
    } else {
    set ClusterAvgOutputDir $ClusterOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_8_0.cpd85" "Button375_10" vTcl:WidgetProc "Toplevel375" 1
    bindtags $site_8_0.cpd85 "$site_8_0.cpd85 Button $top all _vTclBalloon"
    bind $site_8_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_8_0.cpd85 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd82 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd84 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel375" 1
    set site_3_0 $top.fra83
    button $site_3_0.cpd67 \
        -background #ffff00 \
        -command {global ClusterDirInput ClusterDirOutput ClusterAvgOutputDir ClusterAvgOutputSubDir
global ClusterFileInData ClusterAvgOutputSubDirFormat ClusterFormat
global OpenDirFile ClusterData
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine ConfigFile PolarCase PolarType
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    set ClusterDirOutput $ClusterAvgOutputDir
    if {$ClusterAvgOutputSubDir != ""} {append ClusterDirOutput "/$ClusterAvgOutputSubDir"}

    #####################################################################
    #Create Directory
    set ClusterDirOutput [PSPCreateDirectory $ClusterDirOutput $ClusterAvgOutputDir $ClusterFormat]
    #####################################################################       

    if {$VarWarning =="ok"} {
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
            set Fonction ""
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            if {$ClusterFormat == "S2m"} { ClusterDataS }
            if {$ClusterFormat == "S2b"} { ClusterDataS }
            if {$ClusterFormat == "SPP"} { ClusterDataS }
            if {$ClusterFormat == "C2"} { ClusterDataC }
            if {$ClusterFormat == "C3"} { ClusterDataC }
            if {$ClusterFormat == "C4"} { ClusterDataC }
            if {$ClusterFormat == "T3"} { ClusterDataT }
            if {$ClusterFormat == "T4"} { ClusterDataT }
            if {$ClusterFormat == "IPP"} { ClusterDataI }
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            set ConfigFile "$ClusterDirOutput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                if {$ClusterAvgOutputSubDirFormat == "IPP"} {
                    EnviWriteConfigI $ClusterDirOutput $FinalNlig $FinalNcol
                    ClusterRGB_IPP
                    }
                if {$ClusterAvgOutputSubDirFormat == "T3"} {
                    EnviWriteConfigT $ClusterDirOutput $FinalNlig $FinalNcol
                    ClusterRGB_T3
                    }
                if {$ClusterAvgOutputSubDirFormat == "T4"} {
                    EnviWriteConfigT $ClusterDirOutput $FinalNlig $FinalNcol
                    ClusterRGB_T3
                    }
                if {$ClusterAvgOutputSubDirFormat == "C2"} {
                    EnviWriteConfigC $ClusterDirOutput $FinalNlig $FinalNcol
                    ClusterRGB_C2
                    }
                if {$ClusterAvgOutputSubDirFormat == "C3"} {
                    EnviWriteConfigC $ClusterDirOutput $FinalNlig $FinalNcol
                    ClusterRGB_C3
                    }
                if {$ClusterAvgOutputSubDirFormat == "C4"} {
                    EnviWriteConfigC $ClusterDirOutput $FinalNlig $FinalNcol
                    ClusterRGB_C4
                    }
                set DataDir $ClusterAvgOutputDir
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Polarimetric Data File Averaging"
                set VarError ""
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }
            Window hide $widget(Toplevel375); TextEditorRunTrace "Close Window Data Clustering - Data Sets Averaging" "b"
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel375); TextEditorRunTrace "Close Window Data Clustering - Data Sets Averaging" "b"}
        }
    }
} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button375" vTcl:WidgetProc "Toplevel375" 1
    bindtags $site_3_0.cpd67 "$site_3_0.cpd67 Button $top all _vTclBalloon"
    bind $site_3_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command { HelpPdfEdit "Help/ClusterProcess.pdf" } \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel375" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel375); TextEditorRunTrace "Close Window Data Clustering - Data Sets Averaging" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel375" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.cpd67 \
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
    pack $top.cpd86 \
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
Window show .top375

main $argc $argv
