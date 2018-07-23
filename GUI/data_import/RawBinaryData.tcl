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

        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}

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
    set base .top231
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
    namespace eval ::widgets::$site_6_0.cpd114 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd100 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd100 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.rad80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad81 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit83 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit83 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.rad80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad81 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad82 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad83 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad84 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad85 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad86 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd87 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd87 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.rad80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad81 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad82 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad83 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad84 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad85 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd88 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.rad80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad81 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad82 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad83 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra23
    namespace eval ::widgets::$site_3_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra39
    namespace eval ::widgets::$site_4_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent41 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab42 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent43 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra89 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra89
    namespace eval ::widgets::$site_3_0.but90 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd91 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
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
            vTclWindow.top231
            WidgetTop232_ON
            WidgetTop232_OFF
            WidgetTop232_TestFiles
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
## Procedure:  WidgetTop232_ON

proc ::WidgetTop232_ON {} {
global RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput PSPBackgroundColor
global RawBinaryDataPage RawBinaryDataPageMax RawBinaryDataPageCurrent
#DATA CONVERT
global Load_RawBinaryDataFiles

if {$Load_RawBinaryDataFiles == 1} {

set RawBinaryDataPage 1

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s12)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22)"
        set RawBinaryDataPageMax 1
        set RawBinaryDataPageCurrent "1 / 1"
        .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
        }
    if {$RawBinaryDataInput == "RealImag"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 real)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 imag)"
        set RawBinaryDataPageMax 2
        set RawBinaryDataPageCurrent "1 / 2"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "ModPha"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 mod)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 phase)"
        set RawBinaryDataPageMax 2
        set RawBinaryDataPageCurrent "1 / 2"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataFormatPP == "PP1"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s21)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        if {$RawBinaryDataInput == "RealImag"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s21 imag)"
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        if {$RawBinaryDataInput == "ModPha"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s21 phase)"
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        }
    if {$RawBinaryDataFormatPP == "PP2"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        if {$RawBinaryDataInput == "RealImag"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 imag)"
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        if {$RawBinaryDataInput == "ModPha"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 phase)"
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        }
    if {$RawBinaryDataFormatPP == "PP3"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        if {$RawBinaryDataInput == "RealImag"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 imag)"
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        if {$RawBinaryDataInput == "ModPha"} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 phase)"
            set RawBinaryDataPageMax 1
            set RawBinaryDataPageCurrent "1 / 1"
            .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
            }
        }
    }
if {$RawBinaryDataFormat == "IPP"} {
    if {$RawBinaryDataFormatPP == "PP5"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I21)"
        .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
        .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
        .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
        .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
        set RawBinaryDataPageMax 1
        set RawBinaryDataPageCurrent "1 / 1"
        .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
        }
    if {$RawBinaryDataFormatPP == "PP6"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I22)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I12)"
        .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
        .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
        .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
        .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
        set RawBinaryDataPageMax 1
        set RawBinaryDataPageCurrent "1 / 1"
        .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
        }
    if {$RawBinaryDataFormatPP == "PP7"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I22)"
        .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
        .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
        .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
        .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
        set RawBinaryDataPageMax 1
        set RawBinaryDataPageCurrent "1 / 1"
        .top232.fra66.but67 configure -state disable; .top232.fra66.cpd68 configure -state disable
        }
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T13)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T22)"
        set RawBinaryDataPageMax 2
        set RawBinaryDataPageCurrent "1 / 2"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "RealImag"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 real)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 imag)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 real)"
        set RawBinaryDataPageMax 3
        set RawBinaryDataPageCurrent "1 / 3"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "ModPha"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 mod)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 phase)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 mod)"
        set RawBinaryDataPageMax 3
        set RawBinaryDataPageCurrent "1 / 3"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T13)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T14)"
        set RawBinaryDataPageMax 3
        set RawBinaryDataPageCurrent "1 / 3"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "RealImag"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 real)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 imag)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 real)"
        set RawBinaryDataPageMax 4
        set RawBinaryDataPageCurrent "1 / 4"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "ModPha"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 mod)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 phase)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 mod)"
        set RawBinaryDataPageMax 4
        set RawBinaryDataPageCurrent "1 / 4"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C13)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C22)"
        set RawBinaryDataPageMax 2
        set RawBinaryDataPageCurrent "1 / 2"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "RealImag"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 real)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 imag)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 real)"
        set RawBinaryDataPageMax 3
        set RawBinaryDataPageCurrent "1 / 3"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "ModPha"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 mod)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 phase)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 mod)"
        set RawBinaryDataPageMax 3
        set RawBinaryDataPageCurrent "1 / 3"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C13)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C14)"
        set RawBinaryDataPageMax 3
        set RawBinaryDataPageCurrent "1 / 3"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "RealImag"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 real)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 imag)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 real)"
        set RawBinaryDataPageMax 4
        set RawBinaryDataPageCurrent "1 / 4"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    if {$RawBinaryDataInput == "ModPha"} {
        .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
        .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 mod)"
        .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 phase)"
        .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
        .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 mod)"
        set RawBinaryDataPageMax 4
        set RawBinaryDataPageCurrent "1 / 4"
        .top232.fra66.but67 configure -state normal; .top232.fra66.cpd68 configure -state normal
        }
    }

}
}
#############################################################################
## Procedure:  WidgetTop232_OFF

proc ::WidgetTop232_OFF {} {
global RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput PSPBackgroundColor
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6 FileInput7 FileInput8
global FileInput9 FileInput10 FileInput11 FileInput12 FileInput13 FileInput14 FileInput15 FileInput16
global RawBinaryDataPage RawBinaryDataPageMax RawBinaryDataPageCurrent

#DATA CONVERT
global Load_RawBinaryDataFiles

set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""; set FileInput5 ""; set FileInput6 ""; set FileInput7 ""; set FileInput8 ""
set FileInput9 ""; set FileInput10 ""; set FileInput11 ""; set FileInput12 ""; set FileInput13 ""; set FileInput14 ""; set FileInput15 ""; set FileInput16 ""

if {$Load_RawBinaryDataFiles == 1} {
set RawBinaryDataPage 1
set RawBinaryDataPageMax 1
set RawBinaryDataPageCurrent "1 / 1"

.top232.cpd73.f.cpd85 configure -disabledbackground $PSPBackgroundColor
.top232.cpd73.f.cpd91.cpd119 configure -state disable; .top232.cpd73 configure -text ""
.top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
.top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
.top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
.top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
.top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
.top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
}
}
#############################################################################
## Procedure:  WidgetTop232_TestFiles

proc ::WidgetTop232_TestFiles {} {
global RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput RawBinaryFileInputFlag
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6 FileInput7 FileInput8
global FileInput9 FileInput10 FileInput11 FileInput12 FileInput13 FileInput14 FileInput15 FileInput16
#DATA CONVERT
global Load_RawBinaryDataFiles

set RawBinaryFileInputFlag 0

if {$Load_RawBinaryDataFiles == 1} {
    
if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 4} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 8} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 8} {set RawBinaryFileInputFlag 1}
        }
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataFormatPP == "PP1"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 2} {set RawBinaryFileInputFlag 1}
            }
        if {$RawBinaryDataInput == "RealImag"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$FileInput3 != ""} {incr RawBinaryFlag}
            if {$FileInput4 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 4} {set RawBinaryFileInputFlag 1}
            }
        if {$RawBinaryDataInput == "ModPha"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$FileInput3 != ""} {incr RawBinaryFlag}
            if {$FileInput4 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 4} {set RawBinaryFileInputFlag 1}
            }
        }
    if {$RawBinaryDataFormatPP == "PP2"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 2} {set RawBinaryFileInputFlag 1}
            }
        if {$RawBinaryDataInput == "RealImag"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$FileInput3 != ""} {incr RawBinaryFlag}
            if {$FileInput4 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 4} {set RawBinaryFileInputFlag 1}
            }
        if {$RawBinaryDataInput == "ModPha"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$FileInput3 != ""} {incr RawBinaryFlag}
            if {$FileInput4 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 4} {set RawBinaryFileInputFlag 1}
            }
        }
    if {$RawBinaryDataFormatPP == "PP3"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 2} {set RawBinaryFileInputFlag 1}
            }
        if {$RawBinaryDataInput == "RealImag"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$FileInput3 != ""} {incr RawBinaryFlag}
            if {$FileInput4 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 4} {set RawBinaryFileInputFlag 1}
            }
        if {$RawBinaryDataInput == "ModPha"} {
            set RawBinaryFlag 0
            if {$FileInput1 != ""} {incr RawBinaryFlag}
            if {$FileInput2 != ""} {incr RawBinaryFlag}
            if {$FileInput3 != ""} {incr RawBinaryFlag}
            if {$FileInput4 != ""} {incr RawBinaryFlag}
            if {$RawBinaryFlag == 4} {set RawBinaryFileInputFlag 1}
            }
        }
    }
if {$RawBinaryDataFormat == "IPP"} {
    if {$RawBinaryDataFormatPP == "PP5"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 2} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataFormatPP == "PP6"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 2} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataFormatPP == "PP7"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 2} {set RawBinaryFileInputFlag 1}
        }
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 6} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 9} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 9} {set RawBinaryFileInputFlag 1}
        }
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$FileInput10 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 10} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$FileInput10 != ""} {incr RawBinaryFlag}
        if {$FileInput11 != ""} {incr RawBinaryFlag}
        if {$FileInput12 != ""} {incr RawBinaryFlag}
        if {$FileInput13 != ""} {incr RawBinaryFlag}
        if {$FileInput14 != ""} {incr RawBinaryFlag}
        if {$FileInput15 != ""} {incr RawBinaryFlag}
        if {$FileInput16 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 16} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$FileInput10 != ""} {incr RawBinaryFlag}
        if {$FileInput11 != ""} {incr RawBinaryFlag}
        if {$FileInput12 != ""} {incr RawBinaryFlag}
        if {$FileInput13 != ""} {incr RawBinaryFlag}
        if {$FileInput14 != ""} {incr RawBinaryFlag}
        if {$FileInput15 != ""} {incr RawBinaryFlag}
        if {$FileInput16 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 16} {set RawBinaryFileInputFlag 1}
        }
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 6} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 9} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 9} {set RawBinaryFileInputFlag 1}
        }
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$FileInput10 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 10} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$FileInput10 != ""} {incr RawBinaryFlag}
        if {$FileInput11 != ""} {incr RawBinaryFlag}
        if {$FileInput12 != ""} {incr RawBinaryFlag}
        if {$FileInput13 != ""} {incr RawBinaryFlag}
        if {$FileInput14 != ""} {incr RawBinaryFlag}
        if {$FileInput15 != ""} {incr RawBinaryFlag}
        if {$FileInput16 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 16} {set RawBinaryFileInputFlag 1}
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set RawBinaryFlag 0
        if {$FileInput1 != ""} {incr RawBinaryFlag}
        if {$FileInput2 != ""} {incr RawBinaryFlag}
        if {$FileInput3 != ""} {incr RawBinaryFlag}
        if {$FileInput4 != ""} {incr RawBinaryFlag}
        if {$FileInput5 != ""} {incr RawBinaryFlag}
        if {$FileInput6 != ""} {incr RawBinaryFlag}
        if {$FileInput7 != ""} {incr RawBinaryFlag}
        if {$FileInput8 != ""} {incr RawBinaryFlag}
        if {$FileInput9 != ""} {incr RawBinaryFlag}
        if {$FileInput10 != ""} {incr RawBinaryFlag}
        if {$FileInput11 != ""} {incr RawBinaryFlag}
        if {$FileInput12 != ""} {incr RawBinaryFlag}
        if {$FileInput13 != ""} {incr RawBinaryFlag}
        if {$FileInput14 != ""} {incr RawBinaryFlag}
        if {$FileInput15 != ""} {incr RawBinaryFlag}
        if {$FileInput16 != ""} {incr RawBinaryFlag}
        if {$RawBinaryFlag == 16} {set RawBinaryFileInputFlag 1}
        }
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

proc vTclWindow.top231 {base} {
    if {$base == ""} {
        set base .top231
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
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Raw Binary Input Data"
    vTcl:DefineAlias "$top" "Toplevel231" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel231" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel231" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RawBinaryDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel231" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel231" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel231" 1
    pack $site_6_0.cpd114 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd100 \
        -ipad 1 -text {Data Type} 
    vTcl:DefineAlias "$top.cpd100" "TitleFrame231_1" vTcl:WidgetProc "Toplevel231" 1
    bind $top.cpd100 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd100 getframe]
    frame $site_4_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame8" vTcl:WidgetProc "Toplevel231" 1
    set site_5_0 $site_4_0.cpd79
    radiobutton $site_5_0.rad80 \
        \
        -command {$widget(Radiobutton231_3) configure -state normal
$widget(Radiobutton231_4) configure -state normal
$widget(Radiobutton231_5) configure -state normal
$widget(Radiobutton231_6) configure -state normal
$widget(Radiobutton231_7) configure -state disable
$widget(Radiobutton231_8) configure -state normal
$widget(Radiobutton231_9) configure -state disable} \
        -text {Mono Static ( S12 == S21 )} -value Monostatic \
        -variable RawBinaryDataType 
    vTcl:DefineAlias "$site_5_0.rad80" "Radiobutton231_1" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad81 \
        \
        -command {$widget(Radiobutton231_3) configure -state normal
$widget(Radiobutton231_4) configure -state normal
$widget(Radiobutton231_5) configure -state normal
$widget(Radiobutton231_9) configure -state normal
$widget(Radiobutton231_6) configure -state normal
$widget(Radiobutton231_7) configure -state normal
$widget(Radiobutton231_8) configure -state normal} \
        -text {Multi Static ( S12 <> S21 )} -value Bistatic \
        -variable RawBinaryDataType 
    vTcl:DefineAlias "$site_5_0.rad81" "Radiobutton231_2" vTcl:WidgetProc "Toplevel231" 1
    pack $site_5_0.rad80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.tit83 \
        -ipad 1 -text {Data Format} 
    vTcl:DefineAlias "$top.tit83" "TitleFrame231_2" vTcl:WidgetProc "Toplevel231" 1
    bind $top.tit83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit83 getframe]
    frame $site_4_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame5" vTcl:WidgetProc "Toplevel231" 1
    set site_5_0 $site_4_0.cpd79
    radiobutton $site_5_0.rad80 \
        \
        -command {global RawBinaryDataFormatPP RawBinaryDataInput

set RawBinaryDataFormatPP ""
$widget(Radiobutton231_10) configure -state disable
$widget(Radiobutton231_11) configure -state disable
$widget(Radiobutton231_12) configure -state disable
$widget(Radiobutton231_13) configure -state disable
$widget(Radiobutton231_14) configure -state disable
$widget(Radiobutton231_15) configure -state disable
set RawBinaryDataInput ""
$widget(Radiobutton231_16) configure -state normal
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state normal
$widget(Radiobutton231_19) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {[ S2 ]} -value S2 -variable RawBinaryDataFormat 
    vTcl:DefineAlias "$site_5_0.rad80" "Radiobutton231_3" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad81 \
        \
        -command {global RawBinaryDataFormatPP RawBinaryDataInput

set RawBinaryDataFormatPP ""
$widget(Radiobutton231_10) configure -state normal
$widget(Radiobutton231_11) configure -state normal
$widget(Radiobutton231_12) configure -state normal
$widget(Radiobutton231_13) configure -state disable
$widget(Radiobutton231_14) configure -state disable
$widget(Radiobutton231_15) configure -state disable

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {( Sxx, Sxy )} -value SPP -variable RawBinaryDataFormat 
    vTcl:DefineAlias "$site_5_0.rad81" "Radiobutton231_4" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad82 \
        \
        -command {global RawBinaryDataFormatPP RawBinaryDataInput

set RawBinaryDataFormatPP ""
$widget(Radiobutton231_10) configure -state disable
$widget(Radiobutton231_11) configure -state disable
$widget(Radiobutton231_12) configure -state disable
$widget(Radiobutton231_13) configure -state normal
$widget(Radiobutton231_14) configure -state normal
$widget(Radiobutton231_15) configure -state normal


WidgetTop232_OFF; WidgetTop232_ON} \
        -text {( Ixx, Ixy )} -value IPP -variable RawBinaryDataFormat 
    vTcl:DefineAlias "$site_5_0.rad82" "Radiobutton231_5" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad83 \
        \
        -command {global RawBinaryDataFormatPP RawBinaryDataInput

set RawBinaryDataFormatPP ""
$widget(Radiobutton231_10) configure -state disable
$widget(Radiobutton231_11) configure -state disable
$widget(Radiobutton231_12) configure -state disable
$widget(Radiobutton231_13) configure -state disable
$widget(Radiobutton231_14) configure -state disable
$widget(Radiobutton231_15) configure -state disable
set RawBinaryDataInput ""
$widget(Radiobutton231_16) configure -state normal
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state normal
$widget(Radiobutton231_19) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {[ T3 ]} -value T3 -variable RawBinaryDataFormat 
    vTcl:DefineAlias "$site_5_0.rad83" "Radiobutton231_6" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad84 \
        \
        -command {global RawBinaryDataFormatPP RawBinaryDataInput

set RawBinaryDataFormatPP ""
$widget(Radiobutton231_10) configure -state disable
$widget(Radiobutton231_11) configure -state disable
$widget(Radiobutton231_12) configure -state disable
$widget(Radiobutton231_13) configure -state disable
$widget(Radiobutton231_14) configure -state disable
$widget(Radiobutton231_15) configure -state disable
set RawBinaryDataInput ""
$widget(Radiobutton231_16) configure -state normal
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state normal
$widget(Radiobutton231_19) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {[ T4 ]} -value T4 -variable RawBinaryDataFormat 
    vTcl:DefineAlias "$site_5_0.rad84" "Radiobutton231_7" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad85 \
        \
        -command {global RawBinaryDataFormatPP RawBinaryDataInput

set RawBinaryDataFormatPP ""
$widget(Radiobutton231_10) configure -state disable
$widget(Radiobutton231_11) configure -state disable
$widget(Radiobutton231_12) configure -state disable
$widget(Radiobutton231_13) configure -state disable
$widget(Radiobutton231_14) configure -state disable
$widget(Radiobutton231_15) configure -state disable
set RawBinaryDataInput ""
$widget(Radiobutton231_16) configure -state normal
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state normal
$widget(Radiobutton231_19) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {[ C3 ]} -value C3 -variable RawBinaryDataFormat 
    vTcl:DefineAlias "$site_5_0.rad85" "Radiobutton231_8" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad86 \
        \
        -command {global RawBinaryDataFormatPP RawBinaryDataInput

set RawBinaryDataFormatPP ""
$widget(Radiobutton231_10) configure -state disable
$widget(Radiobutton231_11) configure -state disable
$widget(Radiobutton231_12) configure -state disable
$widget(Radiobutton231_13) configure -state disable
$widget(Radiobutton231_14) configure -state disable
$widget(Radiobutton231_15) configure -state disable
set RawBinaryDataInput ""
$widget(Radiobutton231_16) configure -state normal
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state normal
$widget(Radiobutton231_19) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {[ C4 ]} -value C4 -variable RawBinaryDataFormat 
    vTcl:DefineAlias "$site_5_0.rad86" "Radiobutton231_9" vTcl:WidgetProc "Toplevel231" 1
    pack $site_5_0.rad80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad84 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad85 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad86 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd87 \
        -ipad 1 -text {Partial Polarimetry Data Format} 
    vTcl:DefineAlias "$top.cpd87" "TitleFrame231_3" vTcl:WidgetProc "Toplevel231" 1
    bind $top.cpd87 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd87 getframe]
    frame $site_4_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame6" vTcl:WidgetProc "Toplevel231" 1
    set site_5_0 $site_4_0.cpd79
    radiobutton $site_5_0.rad80 \
        \
        -command {set RawBinaryDataInput ""
$widget(Radiobutton231_16) configure -state normal
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state normal
$widget(Radiobutton231_19) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {(S11, S21)} -value PP1 -variable RawBinaryDataFormatPP 
    vTcl:DefineAlias "$site_5_0.rad80" "Radiobutton231_10" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad81 \
        \
        -command {set RawBinaryDataInput ""
$widget(Radiobutton231_16) configure -state normal
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state normal
$widget(Radiobutton231_19) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {(S22, S12)} -value PP2 -variable RawBinaryDataFormatPP 
    vTcl:DefineAlias "$site_5_0.rad81" "Radiobutton231_11" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad82 \
        \
        -command {set RawBinaryDataInput ""
$widget(Radiobutton231_16) configure -state normal
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state normal
$widget(Radiobutton231_19) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {(S11, S22)} -value PP3 -variable RawBinaryDataFormatPP 
    vTcl:DefineAlias "$site_5_0.rad82" "Radiobutton231_12" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad83 \
        \
        -command {set RawBinaryDataInput "Float"
$widget(Radiobutton231_16) configure -state disable
$widget(Radiobutton231_17) configure -state normal
$widget(Radiobutton231_18) configure -state disable
$widget(Radiobutton231_19) configure -state disable

$widget(Button231_1) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {(I11, I21)} -value PP5 -variable RawBinaryDataFormatPP 
    vTcl:DefineAlias "$site_5_0.rad83" "Radiobutton231_13" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad84 \
        \
        -command {set RawBinaryDataInput "Float"
$widget(Radiobutton231_16) configure -state disable
$widget(Radiobutton231_17) configure -state normal
$widget(Radiobutton231_18) configure -state disable
$widget(Radiobutton231_19) configure -state disable

$widget(Button231_1) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {(I22, I12)} -value PP6 -variable RawBinaryDataFormatPP 
    vTcl:DefineAlias "$site_5_0.rad84" "Radiobutton231_14" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad85 \
        \
        -command {set RawBinaryDataInput "Float"
$widget(Radiobutton231_16) configure -state disable
$widget(Radiobutton231_17) configure -state normal
$widget(Radiobutton231_18) configure -state disable
$widget(Radiobutton231_19) configure -state disable

$widget(Button231_1) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {(I11, I22)} -value PP7 -variable RawBinaryDataFormatPP 
    vTcl:DefineAlias "$site_5_0.rad85" "Radiobutton231_15" vTcl:WidgetProc "Toplevel231" 1
    pack $site_5_0.rad80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad84 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad85 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd88 \
        -ipad 1 -text {Input Format} 
    vTcl:DefineAlias "$top.cpd88" "TitleFrame231_4" vTcl:WidgetProc "Toplevel231" 1
    bind $top.cpd88 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd88 getframe]
    frame $site_4_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame7" vTcl:WidgetProc "Toplevel231" 1
    set site_5_0 $site_4_0.cpd79
    radiobutton $site_5_0.rad80 \
        \
        -command {$widget(Button231_1) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text Complex -value Cmplx -variable RawBinaryDataInput 
    vTcl:DefineAlias "$site_5_0.rad80" "Radiobutton231_16" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad81 \
        \
        -command {$widget(Button231_1) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text Float -value Float -variable RawBinaryDataInput 
    vTcl:DefineAlias "$site_5_0.rad81" "Radiobutton231_17" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad82 \
        \
        -command {$widget(Button231_1) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {Real / Imag} -value RealImag -variable RawBinaryDataInput 
    vTcl:DefineAlias "$site_5_0.rad82" "Radiobutton231_18" vTcl:WidgetProc "Toplevel231" 1
    radiobutton $site_5_0.rad83 \
        \
        -command {$widget(Button231_1) configure -state normal

WidgetTop232_OFF; WidgetTop232_ON} \
        -text {Modulus / Phase} -value ModPha -variable RawBinaryDataInput 
    vTcl:DefineAlias "$site_5_0.rad83" "Radiobutton231_19" vTcl:WidgetProc "Toplevel231" 1
    pack $site_5_0.rad80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra23 \
        -borderwidth 2 -relief groove -height 76 -width 125 
    vTcl:DefineAlias "$top.fra23" "Frame65" vTcl:WidgetProc "Toplevel231" 1
    set site_3_0 $top.fra23
    frame $site_3_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra39" "Frame107" vTcl:WidgetProc "Toplevel231" 1
    set site_4_0 $site_3_0.fra39
    label $site_4_0.lab40 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_4_0.lab40" "Label49" vTcl:WidgetProc "Toplevel231" 1
    entry $site_4_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent41" "Entry33" vTcl:WidgetProc "Toplevel231" 1
    label $site_4_0.lab42 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_4_0.lab42" "Label123" vTcl:WidgetProc "Toplevel231" 1
    entry $site_4_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_4_0.ent43" "Entry51" vTcl:WidgetProc "Toplevel231" 1
    pack $site_4_0.lab40 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent41 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.lab42 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent43 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.fra39 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side bottom 
    checkbutton $top.cpd74 \
        -text {Convert Input IEEE binary Format (LE<->BE)} \
        -variable IEEEFormat 
    vTcl:DefineAlias "$top.cpd74" "Checkbutton146" vTcl:WidgetProc "Toplevel231" 1
    frame $top.fra89 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra89" "Frame2" vTcl:WidgetProc "Toplevel231" 1
    set site_3_0 $top.fra89
    button $site_3_0.but90 \
        -background #ffff00 \
        -command {global RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput OpenDirFile
#DATA CONVERT
global Load_RawBinaryDataFiles PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_RawBinaryDataFiles == 0} {
    source "GUI/data_import/RawBinaryDataFiles.tcl"
    set Load_RawBinaryDataFiles 1
    WmTransient $widget(Toplevel232) $PSPTopLevel
    }

WidgetTop232_OFF

WidgetTop232_ON

WidgetShowFromWidget $widget(Toplevel231) $widget(Toplevel232); TextEditorRunTrace "Open Window Raw Binary Input Data Files" "b"
}} \
        -padx 4 -pady 2 -text {Input File Names} 
    vTcl:DefineAlias "$site_3_0.but90" "Button231_1" vTcl:WidgetProc "Toplevel231" 1
    bindtags $site_3_0.but90 "$site_3_0.but90 Button $top all _vTclBalloon"
    bind $site_3_0.but90 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Enter the Input File Names}
    }
    button $site_3_0.cpd91 \
        -background #ffff00 \
        -command {global RawBinaryDataType RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global NligFullSize NcolFullSize IEEEFormat

set RawBinaryDataType ""
set RawBinaryDataFormat ""
set RawBinaryDataFormatPP ""
set RawBinaryDataInput ""

set NligFullSize "?"; set NcolFullSize "?"; set IEEEFormat 0
$widget(Button231_1) configure -state disable
$widget(Radiobutton231_3) configure -state disable
$widget(Radiobutton231_4) configure -state disable
$widget(Radiobutton231_5) configure -state disable
$widget(Radiobutton231_6) configure -state disable
$widget(Radiobutton231_7) configure -state disable
$widget(Radiobutton231_8) configure -state disable
$widget(Radiobutton231_9) configure -state disable
$widget(Radiobutton231_10) configure -state disable
$widget(Radiobutton231_11) configure -state disable
$widget(Radiobutton231_12) configure -state disable
$widget(Radiobutton231_13) configure -state disable
$widget(Radiobutton231_14) configure -state disable
$widget(Radiobutton231_15) configure -state disable
$widget(Radiobutton231_16) configure -state disable
$widget(Radiobutton231_17) configure -state disable
$widget(Radiobutton231_18) configure -state disable
$widget(Radiobutton231_19) configure -state disable

WidgetTop232_OFF} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd91" "Button2" vTcl:WidgetProc "Toplevel231" 1
    bindtags $site_3_0.cpd91 "$site_3_0.cpd91 Button $top all _vTclBalloon"
    bind $site_3_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.but90 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd91 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra71 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel231" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global RawBinaryDirOutput RawBinaryFileInputFlag IEEEFormat OpenDirFile
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

#DATA CONVERT
global Load_RawBinaryDataFiles

if {$OpenDirFile == 0} {

set TestVarName(0) "Initial Number of Rows"; set TestVarType(0) "int"; set TestVarValue(0) $NligFullSize; set TestVarMin(0) "0"; set TestVarMax(0) ""
set TestVarName(1) "Initial Number of Cols"; set TestVarType(1) "int"; set TestVarValue(1) $NcolFullSize; set TestVarMin(1) "0"; set TestVarMax(1) ""
TestVar 2
if {$TestVarError == "ok"} {
    set RawBinaryFileInputFlag 0
    WidgetTop232_TestFiles
    if {$RawBinaryFileInputFlag == 1} {
        set NligInit 1
        set NligEnd $NligFullSize
        set NcolInit 1
        set NcolEnd $NcolFullSize
        set NligFullSizeInput $NligFullSize
        set NcolFullSizeInput $NcolFullSize
        if {$Load_RawBinaryDataFiles == 1} {
            Window hide $widget(Toplevel232); TextEditorRunTrace "Close Window Raw Binary Input Data Files" "b"
            }
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel231); TextEditorRunTrace "Close Window Raw Binary Input Data" "b"
        } else {
        set RawBinaryFileInputFlag 0
        set ErrorMessage "ENTER THE RAW BINARY INPUT DATA FILE NAMES"
        set VarError ""
        Window show $widget(Toplevel44)
        }
    }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel231" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/RawBinaryData.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel231" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
#DATA CONVERT
global Load_RawBinaryDataFiles

if {$OpenDirFile == 0} {

if {$Load_RawBinaryDataFiles == 1} {
    Window hide $widget(Toplevel232); TextEditorRunTrace "Close Window Raw Binary Input Data Files" "b"
    }

Window hide $widget(Toplevel231); TextEditorRunTrace "Close Window Raw Binary Input Data" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel231" 1
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
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd100 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit83 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd87 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra23 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra89 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
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
Window show .top231

main $argc $argv
