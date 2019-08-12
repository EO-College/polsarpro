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
    set base .top519
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
    namespace eval ::widgets::$base.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
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
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd66
    namespace eval ::widgets::$site_6_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd67
    namespace eval ::widgets::$site_6_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd67
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top519
            WidgetOn519Mult
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
## Procedure:  WidgetOn519Mult

proc ::WidgetOn519Mult {} {
global ParametersOutputFile ParaConformity ParaFaraday
global ParaScattPred ParaScattDiv ParaDegPur ParaDepInd ParaEntropy ParaAlpha
global ParaKozlovAni ParaLueneburgAni ParaFreemanEntropy ParaVanZylEntropy
global ParaNwinL ParaNwinC ParaBMP ParametersFonction ParametersFonctionPP
global ParaPPS ParaPPSp1 ParaPPSalpha1 ParaPOC ParaRVOG ParaName
global ParametersOutputDir ParametersOutputSubDir PSPBackgroundColor

set ParaNwinL "?"
set ParaNwinC "?"
set ParaBMP 0
if {$ParaConformity == 1} { set ParametersOutputFile "conformity.bin" }
if {$ParaFaraday == 1} { set ParametersOutputFile "faraday_rotation_freeman.bin & faraday_rotation_bickel_bates.bin" }
if {$ParaScattPred == 1} { set ParametersOutputFile "scatt_predominance.bin" }
if {$ParaScattDiv == 1} { set ParametersOutputFile "scatt_diversity.bin" }
if {$ParaDegPur == 1} { set ParametersOutputFile "degree_purity.bin" }
if {$ParaDepInd == 1} { set ParametersOutputFile "depolarisation_index.bin" }
if {$ParaEntropy == 1} { 
    if {$ParaName == "prakscolin"} { set ParametersOutputFile "entropy_praks_colin.bin" }
    if {$ParaName == "ancuiyang"} { set ParametersOutputFile "entropy_an_cui_yang.bin" }
    }
if {$ParaAlpha == 1} {
    if {$ParaName == "prakscolin"} { set ParametersOutputFile "alpha_praks_colin.bin" }
    if {$ParaName == "ancuiyang"} { set ParametersOutputFile "alpha_an_cui_yang.bin" }
    }
if {$ParaKozlovAni == 1} { set ParametersOutputFile "anisotropy_kozlov.bin & anisotropy_cmplx_kozlov.bin" }
if {$ParaLueneburgAni == 1} { set ParametersOutputFile "anisotropy_lueneburg.bin" }
if {$ParaFreemanEntropy == 1} { set ParametersOutputFile "entropy_scatt_mecha_freeman.bin" }
if {$ParaVanZylEntropy == 1} { set ParametersOutputFile "entropy_scatt_mecha_vanzyl.bin" }
if {$ParaPPS == 1} { set ParametersOutputFile "pps_detection.bin" }
if {$ParaPOC == 1} { set ParametersOutputFile "Pauli_RGB.bmp & orientation_estimation.bin" }
if {$ParaRVOG == 1} { set ParametersOutputFile "RVOG_PolSAR_ms _md _mv _mu _alpha.bin" }

.top519.cpd88.cpd68 configure -state disable -relief flat
.top519.cpd88.cpd68 configure -text ""
.top519.cpd88.cpd68.f.cpd66.lab69 configure -state disable
.top519.cpd88.cpd68.f.cpd66.lab69 configure -text ""
.top519.cpd88.cpd68.f.cpd66.ent70 configure -state disable -relief flat
.top519.cpd88.cpd68.f.cpd66.ent70 configure -disabledbackground $PSPBackgroundColor
.top519.cpd88.cpd68.f.cpd67.lab69 configure -state disable
.top519.cpd88.cpd68.f.cpd67.lab69 configure -text ""
.top519.cpd88.cpd68.f.cpd67.ent70 configure -state disable -relief flat
.top519.cpd88.cpd68.f.cpd67.ent70 configure -disabledbackground $PSPBackgroundColor

if {$ParaPPS == 1} {
    .top519.cpd88.cpd68 configure -state normal -relief groove
    .top519.cpd88.cpd68 configure -text "P.P.S Detection"
    .top519.cpd88.cpd68.f.cpd66.lab69 configure -state normal
    .top519.cpd88.cpd68.f.cpd66.lab69 configure -text "p1"
    .top519.cpd88.cpd68.f.cpd66.ent70 configure -state normal -relief sunken
    .top519.cpd88.cpd68.f.cpd66.ent70 configure -disabledbackground #FFFFFF
    .top519.cpd88.cpd68.f.cpd67.lab69 configure -state normal
    .top519.cpd88.cpd68.f.cpd67.lab69 configure -text "alpha 1"
    .top519.cpd88.cpd68.f.cpd67.ent70 configure -state normal -relief sunken
    .top519.cpd88.cpd68.f.cpd67.ent70 configure -disabledbackground #FFFFFF
    }
    
set ParaNwinL "?"
set ParaNwinC "?"
.top519.cpd88.fra24.lab57 configure -state normal
.top519.cpd88.fra24.ent58 configure -state normal
.top519.cpd88.fra24.ent58 configure -disabledbackground #FFFFFF
.top519.cpd88.cpd67.lab57 configure -state normal
.top519.cpd88.cpd67.ent58 configure -state normal
.top519.cpd88.cpd67.ent58 configure -disabledbackground #FFFFFF
if {$ParaPOC == 1} {
    set ParaNwinL "3"
    set ParaNwinC "3"
    #.top519.cpd88.fra24.lab57 configure -state disable
    #.top519.cpd88.fra24.ent58 configure -state disable
    #.top519.cpd88.fra24.ent58 configure -disabledbackground $PSPBackgroundColor
    #.top519.cpd88.cpd67.lab57 configure -state disable
    #.top519.cpd88.cpd67.ent58 configure -state disable
    #.top519.cpd88.cpd67.ent58 configure -disabledbackground $PSPBackgroundColor
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

proc vTclWindow.top519 {base} {
    if {$base == ""} {
        set base .top519
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
    wm geometry $top 500x230+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Parameters"
    vTcl:DefineAlias "$top" "Toplevel519" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd74 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd74" "Frame4" vTcl:WidgetProc "Toplevel519" 1
    set site_3_0 $top.cpd74
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel519" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ParametersDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel519" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel519" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel519" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel519" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ParametersOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel519" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel519" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel519" 1
    entry $site_6_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ParametersOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd72" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel519" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel519" 1
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
    }
WidgetOn519Mult} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd75" "Button82" vTcl:WidgetProc "Toplevel519" 1
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
    vTcl:DefineAlias "$top.fra102" "Frame9" vTcl:WidgetProc "Toplevel519" 1
    set site_3_0 $top.fra102
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel519" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel519" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel519" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel519" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel519" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel519" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel519" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel519" 1
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
    TitleFrame $top.cpd71 \
        -ipad 0 -text {Output File} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame10" vTcl:WidgetProc "Toplevel519" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ParametersOutputFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh5" vTcl:WidgetProc "Toplevel519" 1
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra109 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra109" "Frame20" vTcl:WidgetProc "Toplevel519" 1
    set site_3_0 $top.fra109
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ParametersDirInput ParametersDirOutput ParametersOutputDir ParametersOutputSubDir
global ParametersFonction ParametersFonctionPP ParaBMP ParaNwinL ParaNwinC
global ParaConformity ParaFaraday BMPDirInput TMPMemoryAllocError
global ParaScattPred ParaScattDiv ParaDegPur ParaDepInd ParaEntropy ParaAlpha ParaName
global ParaKozlovAni ParaFreemanEntropy ParaPPS ParaPPSp1 ParaPPSalpha1 ParaPOC ParaRVOG
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global DataDirMult NDataDirMult
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType PSPViewGimpBMP

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
    if {$ParaPPS == 1} {
        set TestVarName(4) "Threshold p1"; set TestVarType(4) "float"; set TestVarValue(4) $ParaPPSp1; set TestVarMin(4) "0.0"; set TestVarMax(4) "1.0"
        set TestVarName(5) "Threshold alpha1"; set TestVarType(5) "float"; set TestVarValue(5) $ParaPPSalpha1; set TestVarMin(5) "0.0"; set TestVarMax(5) "90.0"
        TestVar 6
        } else {
        TestVar 4
        }
    if {$TestVarError == "ok"} {

        WidgetShowTop399; TextEditorRunTrace "Open Window Processing" "b"

###############################################################################

        for {set ii 1} {$ii <= $NDataDirMult} {incr ii} {
            set ParametersDirInput $DataDirMult($ii)
            if {$ParametersFonction == "T3"} { set ParametersDirInput "$DataDirMult($ii)/T3" }
            if {$ParametersFonction == "C2"} { set ParametersDirInput "$DataDirMult($ii)/C2" }        
            set ParametersDirOutput $DataDirMult($ii)
            set ParametersOutputDir $DataDirMult($ii)
            if {$ParametersOutputSubDir != ""} {append ParametersDirOutput "/$ParametersOutputSubDir"}

            #Create Directory
            set ParametersDirOutput [PSPCreateDirectoryMaskMult $ParametersDirOutput $ParametersDirOutput $ParametersDirInput]

###############################################################################
###############################################################################

    if {$ParaConformity == 1} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Conformity Coefficient"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/conformity_coeff.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/conformity_coeff.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/conformity.bin"] {EnviWriteConfig "$ParametersDirOutput/conformity.bin" $FinalNlig $FinalNcol 4}
         
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if [file exists "$ParametersDirOutput/conformity.bin"] {
                set BMPFileInput "$ParametersDirOutput/conformity.bin"
                set BMPFileOutput "$ParametersDirOutput/conformity.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -1 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } #parabmp
        } #Conformity

###############################################################################
###############################################################################

    if {$ParaFaraday == 1} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Faraday Rotation Estimation"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/faraday_rotation.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/faraday_rotation.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/faraday_rotation_freeman.bin"] {EnviWriteConfig "$ParametersDirOutput/faraday_rotation_freeman.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/faraday_rotation_bickel_bates.bin"] {EnviWriteConfig "$ParametersDirOutput/faraday_rotation_bickel_bates.bin" $FinalNlig $FinalNcol 4}
         
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if [file exists "$ParametersDirOutput/faraday_rotation_freeman.bin"] {
                set BMPFileInput "$ParametersDirOutput/faraday_rotation_freeman.bin"
                set BMPFileOutput "$ParametersDirOutput/faraday_rotation_freeman.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -90 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$ParametersDirOutput/faraday_rotation_bickel_bates.bin"] {
                set BMPFileInput "$ParametersDirOutput/faraday_rotation_bickel_bates.bin"
                set BMPFileOutput "$ParametersDirOutput/faraday_rotation_bickel_bates.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -90 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } #parabmp
        } #Faraday

###############################################################################
###############################################################################

    set PraksColin "false"
    if {$ParaScattPred == 1} { set PraksColin "true" }
    if {$ParaScattDiv == 1} { set PraksColin "true" }
    if {$ParaDegPur == 1} { set PraksColin "true" }
    if {$ParaDepInd == 1} { set PraksColin "true" }
    if {$ParaEntropy == 1} { if {$ParaName == "prakscolin"} { set PraksColin "true" } }
    if {$ParaAlpha == 1} { if {$ParaName == "prakscolin"} { set PraksColin "true" } }
    if {$PraksColin == "true" } {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Praks & Colin Parameters"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/praks_colin.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $ParaScattPred -fl2 $ParaScattDiv -fl3 $ParaDegPur -fl4 $ParaDepInd -fl5 $ParaEntropy -fl6 $ParaAlpha  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/praks_colin.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $ParaScattPred -fl2 $ParaScattDiv -fl3 $ParaDegPur -fl4 $ParaDepInd -fl5 $ParaEntropy -fl6 $ParaAlpha  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/scatt_predominance.bin"] {EnviWriteConfig "$ParametersDirOutput/scatt_predominance.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/scatt_diversity.bin"] {EnviWriteConfig "$ParametersDirOutput/scatt_diversity.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/degree_purity.bin"] {EnviWriteConfig "$ParametersDirOutput/degree_purity.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/depolarisation_index.bin"] {EnviWriteConfig "$ParametersDirOutput/depolarisation_index.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/entropy_praks_colin.bin"] {EnviWriteConfig "$ParametersDirOutput/entropy_praks_colin.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/alpha_praks_colin.bin"] {EnviWriteConfig "$ParametersDirOutput/alpha_praks_colin.bin" $FinalNlig $FinalNcol 4}
           
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if {$ParaScattPred == 1} {
                if [file exists "$ParametersDirOutput/scatt_predominance.bin"] {
                    set BMPFileInput "$ParametersDirOutput/scatt_predominance.bin"
                    set BMPFileOutput "$ParametersDirOutput/scatt_predominance.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE scatt_predominance.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$ParaScattDiv == 1} {
                if [file exists "$ParametersDirOutput/scatt_diversity.bin"] {
                    set BMPFileInput "$ParametersDirOutput/scatt_diversity.bin"
                    set BMPFileOutput "$ParametersDirOutput/scatt_diversity.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE scatt_diversity.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$ParaDegPur == 1} {
                if [file exists "$ParametersDirOutput/degree_purity.bin"] {
                    set BMPFileInput "$ParametersDirOutput/degree_purity.bin"
                    set BMPFileOutput "$ParametersDirOutput/degree_purity.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1.733
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE degree_purity.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$ParaDepInd == 1} {
                if [file exists "$ParametersDirOutput/depolarisation_index.bin"] {
                    set BMPFileInput "$ParametersDirOutput/depolarisation_index.bin"
                    set BMPFileOutput "$ParametersDirOutput/depolarisation_index.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE depolarisation_index.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$ParaEntropy == 1} {
                if [file exists "$ParametersDirOutput/entropy_praks_colin.bin"] {
                    set BMPFileInput "$ParametersDirOutput/entropy_praks_colin.bin"
                    set BMPFileOutput "$ParametersDirOutput/entropy_praks_colin.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE entropy_praks_colin.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$ParaAlpha == 1} {
                if [file exists "$ParametersDirOutput/alpha_praks_colin.bin"] {
                    set BMPFileInput "$ParametersDirOutput/alpha_praks_colin.bin"
                    set BMPFileOutput "$ParametersDirOutput/alpha_praks_colin.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 90
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE alpha_praks_colin.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            } #parabmp
        } #PraksColin

###############################################################################
###############################################################################

    set AnCuiYang "false"
    if {$ParaEntropy == 1} { if {$ParaName == "ancuiyang"} { set AnCuiYang "true" } }
    if {$ParaAlpha == 1} { if {$ParaName == "ancuiyang"} { set AnCuiYang "true" } }
    if {$AnCuiYang == "true" } {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Praks & Colin Parameters"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/an_cui_yang.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $ParaEntropy -fl2 $ParaAlpha  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/an_cui_yang.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 $ParaEntropy -fl2 $ParaAlpha  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/entropy_an_cui_yang.bin"] {EnviWriteConfig "$ParametersDirOutput/entropy_an_cui_yang.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/alpha_an_cui_yang.bin"] {EnviWriteConfig "$ParametersDirOutput/alpha_an_cui_yang.bin" $FinalNlig $FinalNcol 4}
           
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if {$ParaEntropy == 1} {
                if [file exists "$ParametersDirOutput/entropy_an_cui_yang.bin"] {
                    set BMPFileInput "$ParametersDirOutput/entropy_an_cui_yang.bin"
                    set BMPFileOutput "$ParametersDirOutput/entropy_an_cui_yang.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE entropy_an_cui_yang.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            if {$ParaAlpha == 1} {
                if [file exists "$ParametersDirOutput/alpha_an_cui_yang.bin"] {
                    set BMPFileInput "$ParametersDirOutput/alpha_an_cui_yang.bin"
                    set BMPFileOutput "$ParametersDirOutput/alpha_an_cui_yang.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 90
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE alpha_an_cui_yang.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            } #parabmp
        } #AnCuiYang

###############################################################################
###############################################################################

    if {$ParaKozlovAni == 1} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Kozlov Anisotropy"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/kozlov_anisotropy.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/kozlov_anisotropy.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/anisotropy_kozlov.bin"] {EnviWriteConfig "$ParametersDirOutput/anisotropy_kozlov.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/anisotropy_cmplx_kozlov.bin"] {EnviWriteConfig "$ParametersDirOutput/anisotropy_cmplx_kozlov.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/anisotropy_cmplx_kozlov_norm.bin"] {EnviWriteConfig "$ParametersDirOutput/anisotropy_cmplx_kozlov_norm.bin" $FinalNlig $FinalNcol 4}
            
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if {$ParaKozlovAni == 1} {
                if [file exists "$ParametersDirOutput/anisotropy_kozlov.bin"] {
                    set BMPFileInput "$ParametersDirOutput/anisotropy_kozlov.bin"
                    set BMPFileOutput "$ParametersDirOutput/anisotropy_kozlov.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE anisotropy_kozlov.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                if [file exists "$ParametersDirOutput/anisotropy_cmplx_kozlov.bin"] {
                    set BMPFileInput "$ParametersDirOutput/anisotropy_cmplx_kozlov.bin"
                    set BMPFileOutput "$ParametersDirOutput/anisotropy_cmplx_kozlov.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -1 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE anisotropy_cmplx_kozlov.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                if [file exists "$ParametersDirOutput/anisotropy_cmplx_kozlov_norm.bin"] {
                    set BMPFileInput "$ParametersDirOutput/anisotropy_cmplx_kozlov_norm.bin"
                    set BMPFileOutput "$ParametersDirOutput/anisotropy_cmplx_kozlov_norm.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE anisotropy_cmplx_kozlov_norm.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            } #parabmp
        } #Kozlov

###############################################################################
###############################################################################

    if {$ParaLueneburgAni == 1} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2T3" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2T4" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Lueneburg Anisotropy"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/anisotropy_lueneburg.bin"] {EnviWriteConfig "$ParametersDirOutput/anisotropy_lueneburg.bin" $FinalNlig $FinalNcol 4}
   
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if {$ParaLueneburgAni == 1} {
                if [file exists "$ParametersDirOutput/anisotropy_lueneburg.bin"] {
                    set BMPFileInput "$ParametersDirOutput/anisotropy_lueneburg.bin"
                    set BMPFileOutput "$ParametersDirOutput/anisotropy_lueneburg.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE anisotropy_lueneburg.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            } #parabmp
        } #Lueneburg

###############################################################################
###############################################################################

    if {$ParaFreemanEntropy == 1} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Freeman Scattering Mechanism Entropy"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/scattering_mechanism_entropy_freeman.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/scattering_mechanism_entropy_freeman.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/entropy_scatt_mecha_freeman.bin"] {EnviWriteConfig "$ParametersDirOutput/entropy_scatt_mecha_freeman.bin" $FinalNlig $FinalNcol 4}
    
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if {$ParaFreemanEntropy == 1} {
                if [file exists "$ParametersDirOutput/entropy_scatt_mecha_freeman.bin"] {
                    set BMPFileInput "$ParametersDirOutput/entropy_scatt_mecha_freeman.bin"
                    set BMPFileOutput "$ParametersDirOutput/entropy_scatt_mecha_freeman.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE entropy_scatt_mecha_freeman.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            } #parabmp
        }
        #Freeman

###############################################################################
###############################################################################

    if {$ParaVanZylEntropy == 1} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Van Zyl Scattering Mechanism Entropy"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/scattering_mechanism_entropy_vanzyl.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/scattering_mechanism_entropy_vanzyl.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/entropy_scatt_mecha_vanzyl.bin"] {EnviWriteConfig "$ParametersDirOutput/entropy_scatt_mecha_vanzyl.bin" $FinalNlig $FinalNcol 4}
    
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if {$ParaVanZylEntropy == 1} {
                if [file exists "$ParametersDirOutput/entropy_scatt_mecha_vanzyl.bin"] {
                    set BMPFileInput "$ParametersDirOutput/entropy_scatt_mecha_vanzyl.bin"
                    set BMPFileOutput "$ParametersDirOutput/entropy_scatt_mecha_vanzyl.bmp"
                    set BMPDirInput $ParametersDirOutput
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                    } else {
                    set VarError ""
                    set ErrorMessage "IMPOSSIBLE TO OPEN THE entropy_scatt_mecha_vanzyl.bin FILE" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    }
                }
            } #parabmp
        }
        #VanZyl

###############################################################################
###############################################################################

    if {$ParaPPS == 1} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Creation of the Polarized Point Scatterer Detection"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/pps_detection.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p1 $ParaPPSp1 -a1 $ParaPPSalpha1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/pps_detection.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -p1 $ParaPPSp1 -a1 $ParaPPSalpha1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/pps_detection.bin"] {EnviWriteConfig "$ParametersDirOutput/pps_detection.bin" $FinalNlig $FinalNcol 4}
    
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if [file exists "$ParametersDirOutput/pps_detection.bin"] {
                set BMPFileInput "$ParametersDirOutput/pps_detection.bin"
                set BMPFileOutput "$ParametersDirOutput/pps_detection.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE pps_detection.bin FILE" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } #parabmp
        }
        #PPSDetection

###############################################################################
###############################################################################

    if {$ParaPOC == 1} {   
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "Polarization Orientation Angle Estimation"
        set Fonction2 ""

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/orientation_estimation.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/orientation_estimation.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        if [file exists "$ParametersDirOutput/orientation_estimation.bin"] { EnviWriteConfig "$ParametersDirOutput/orientation_estimation.bin" $FinalNlig $FinalNcol 4 }

        if [file exists "$ParametersDirOutput/orientation_estimation.bin"] {
            set OrientationFile "$ParametersDirOutput/orientation_estimation.bin"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/orientation_correction.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -if \x22$OrientationFile\x22 -iodf $ParametersF -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/orientation_correction.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -if \x22$OrientationFile\x22 -iodf $ParametersF -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            set ConfigFile "$ParametersDirOutput/config.txt"
            WriteConfig

            if {$ParametersF == "S2"} { EnviWriteConfigS $ParametersDirOutput $FinalNlig $FinalNcol }
            if {$ParametersF == "C3"} { EnviWriteConfigC $ParametersDirOutput $FinalNlig $FinalNcol }
            if {$ParametersF == "T3"} { EnviWriteConfigT $ParametersDirOutput $FinalNlig $FinalNcol }
            }
        
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            set config "true"
            if {$ParametersF == "S2"} { 
                if [file exists "$ParametersDirOutput/s11.bin"] {
                    set config "true"
                    } else {
                    set config "false"
                    }
                }
            if {$ParametersF == "C3"} { 
                if [file exists "$ParametersDirOutput/C11.bin"] {
                    set config "true"
                    } else {
                    set config "false"
                    }
                }
            if {$ParametersF == "T3"} { 
                if [file exists "$ParametersDirOutput/T11.bin"] {
                    set config "true"
                    } else {
                    set config "false"
                    }
                }
            if {"$config"=="true"} {
                set RGBDirInput $ParametersDirOutput
                set RGBDirOutput $ParametersDirOutput
                set RGBFileOutput "$ParametersDirOutput/PauliRGB.bmp"
                set MaskCmd ""
                set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $ParametersF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $ParametersF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }

            if [file exists "$ParametersDirOutput/orientation_estimation.bin"] {
                set BMPFileInput "$ParametersDirOutput/orientation_estimation.bin"
                set BMPFileOutput "$ParametersDirOutput/orientation_estimation.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -90 +90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } #parabmp
        set DataDir $ParametersOutputDir            
        } #POC

###############################################################################
###############################################################################

    if {$ParaRVOG == 1} {
        set ParametersF $ParametersFonction
        if {$ParametersFonction == "S2m"} { set ParametersF "S2" }
        if {$ParametersFonction == "S2b"} { set ParametersF "S2" }
        set MaskCmd ""
        set MaskFile "$ParametersDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set Fonction  "RVOG PolSAR Inversion"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/RVOG_PolSAR.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/RVOG_PolSAR.exe -id \x22$ParametersDirInput\x22 -od \x22$ParametersDirOutput\x22 -iodf $ParametersF -nwr $ParaNwinL -nwc $ParaNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
        if [file exists "$ParametersDirOutput/RVOG_PolSAR_ms.bin"] {EnviWriteConfig "$ParametersDirOutput/RVOG_PolSAR_ms.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/RVOG_PolSAR_md.bin"] {EnviWriteConfig "$ParametersDirOutput/RVOG_PolSAR_md.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/RVOG_PolSAR_mv.bin"] {EnviWriteConfig "$ParametersDirOutput/RVOG_PolSAR_mv.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/RVOG_PolSAR_mu.bin"] {EnviWriteConfig "$ParametersDirOutput/RVOG_PolSAR_mu.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$ParametersDirOutput/RVOG_PolSAR_alpha.bin"] {EnviWriteConfig "$ParametersDirOutput/RVOG_PolSAR_alpha.bin" $FinalNlig $FinalNcol 4}
            
        #####################################################################       
        
        if {"$ParaBMP"=="1"} {
            if [file exists "$ParametersDirOutput/RVOG_PolSAR_ms.bin"] {
                set BMPFileInput "$ParametersDirOutput/RVOG_PolSAR_ms.bin"
                set BMPFileOutput "$ParametersDirOutput/RVOG_PolSAR_ms.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$ParametersDirOutput/RVOG_PolSAR_md.bin"] {
                set BMPFileInput "$ParametersDirOutput/RVOG_PolSAR_md.bin"
                set BMPFileOutput "$ParametersDirOutput/RVOG_PolSAR_md.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$ParametersDirOutput/RVOG_PolSAR_mv.bin"] {
                set BMPFileInput "$ParametersDirOutput/RVOG_PolSAR_mv.bin"
                set BMPFileOutput "$ParametersDirOutput/RVOG_PolSAR_mv.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$ParametersDirOutput/RVOG_PolSAR_mu.bin"] {
                set BMPFileInput "$ParametersDirOutput/RVOG_PolSAR_mu.bin"
                set BMPFileOutput "$ParametersDirOutput/RVOG_PolSAR_mu.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if [file exists "$ParametersDirOutput/RVOG_PolSAR_alpha.bin"] {
                set BMPFileInput "$ParametersDirOutput/RVOG_PolSAR_alpha.bin"
                set BMPFileOutput "$ParametersDirOutput/RVOG_PolSAR_alpha.bmp"
                set BMPDirInput $ParametersDirOutput
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 0 +90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            } #parabmp
        } #RVOG

###############################################################################
###############################################################################

      }
      #ii

    WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"

    } #testvarerror
    
    } else {
    if {"$VarWarning"=="no"} {
        Window hide $widget(Toplevel519)
        if {$ParametersFonction == "S2m"} {TextEditorRunTrace "Close Window S2 Parameters" "b"}
        if {$ParametersFonction == "S2b"} {TextEditorRunTrace "Close Window S2 Parameters" "b"}
        if {$ParametersFonction == "T3"} {TextEditorRunTrace "Close Window T3 Parameters" "b"}
        if {$ParametersFonction == "C2"} {TextEditorRunTrace "Close Window C2 Parameters" "b"}
        if {$ParametersFonction == "SPP"} {TextEditorRunTrace "Close Window SPP Parameters" "b"}
        }
    }
}
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel519" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ParametersMult.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel519" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile ParametersFonction
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel519); 
if {$ParametersFonction == "S2m"} {TextEditorRunTrace "Close Window S2 Parameters" "b"}
if {$ParametersFonction == "S2b"} {TextEditorRunTrace "Close Window S2 Parameters" "b"}
if {$ParametersFonction == "T3"} {TextEditorRunTrace "Close Window T3 Parameters" "b"}
if {$ParametersFonction == "C2"} {TextEditorRunTrace "Close Window C2 Parameters" "b"}
if {$ParametersFonction == "SPP"} {TextEditorRunTrace "Close Window SPP Parameters" "b"}
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel519" 1
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
    frame $top.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame51" vTcl:WidgetProc "Toplevel519" 1
    set site_3_0 $top.cpd88
    checkbutton $site_3_0.cpd66 \
        -padx 1 -text BMP -variable ParaBMP 
    vTcl:DefineAlias "$site_3_0.cpd66" "Checkbutton468" vTcl:WidgetProc "Toplevel519" 1
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame52" vTcl:WidgetProc "Toplevel519" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label36" vTcl:WidgetProc "Toplevel519" 1
    entry $site_4_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ParaNwinL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry24" vTcl:WidgetProc "Toplevel519" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd68 \
        -ipad 0 -text {P.P.S Detection} 
    vTcl:DefineAlias "$site_3_0.cpd68" "TitleFrame519_1" vTcl:WidgetProc "Toplevel519" 1
    bind $site_3_0.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    frame $site_5_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd66" "Frame7" vTcl:WidgetProc "Toplevel519" 1
    set site_6_0 $site_5_0.cpd66
    label $site_6_0.lab69 \
        -text p1 
    vTcl:DefineAlias "$site_6_0.lab69" "Label519_1" vTcl:WidgetProc "Toplevel519" 1
    entry $site_6_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ParaPPSp1 -width 5 
    vTcl:DefineAlias "$site_6_0.ent70" "Entry519_1" vTcl:WidgetProc "Toplevel519" 1
    pack $site_6_0.lab69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_6_0.ent70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    frame $site_5_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd67" "Frame8" vTcl:WidgetProc "Toplevel519" 1
    set site_6_0 $site_5_0.cpd67
    label $site_6_0.lab69 \
        -text {alpha 1} 
    vTcl:DefineAlias "$site_6_0.lab69" "Label519_2" vTcl:WidgetProc "Toplevel519" 1
    entry $site_6_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ParaPPSalpha1 -width 5 
    vTcl:DefineAlias "$site_6_0.ent70" "Entry519_2" vTcl:WidgetProc "Toplevel519" 1
    pack $site_6_0.lab69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_6_0.ent70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd67 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd67" "Frame53" vTcl:WidgetProc "Toplevel519" 1
    set site_4_0 $site_3_0.cpd67
    label $site_4_0.lab57 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label37" vTcl:WidgetProc "Toplevel519" 1
    entry $site_4_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable ParaNwinC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry25" vTcl:WidgetProc "Toplevel519" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra102 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra109 \
        -in $top -anchor center -expand 1 -fill x -side bottom 
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 

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
Window show .top519

main $argc $argv
