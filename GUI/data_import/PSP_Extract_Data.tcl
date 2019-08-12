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

        {{[file join . GUI Images OpenDir.gif]} {file not found!} user {}}
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
    set base .top233
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.can73 {
        array set save {-borderwidth 1 -closeenough 1 -height 1 -highlightthickness 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
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
    namespace eval ::widgets::$site_6_0.cpd86 {
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
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.lab75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra27 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra27
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra96 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra96
    namespace eval ::widgets::$site_3_0.fra97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra97
    namespace eval ::widgets::$site_4_0.fra102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra102
    namespace eval ::widgets::$site_5_0.cpd105 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra103 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra103
    namespace eval ::widgets::$site_5_0.cpd106 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra104 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra104
    namespace eval ::widgets::$site_5_0.cpd107 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd98
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd111
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1}
    }
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1}
    }
    namespace eval ::widgets::$site_4_0.cpd109 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd109
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent26 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd110 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd110
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent26 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra79
    namespace eval ::widgets::$site_3_0.che74 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd77
    namespace eval ::widgets::$site_3_0.lab80 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent81 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit80 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit80 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.fra87 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra87
    namespace eval ::widgets::$site_6_0.cpd90 {
        array set save {-justify 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra88
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra89 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra89
    namespace eval ::widgets::$site_6_0.cpd92 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra83
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd96 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd98 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra94
    namespace eval ::widgets::$site_6_0.cpd99 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd100 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra95
    namespace eval ::widgets::$site_6_0.cpd101 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd102 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd103 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
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
            vTclWindow.top233
            ExtractAIRSAR
            ExtractCONVAIR
            ExtractESAR
            ExtractFSAR
            ExtractSETHI
            ExtractEMISAR
            ExtractPISAR
            RGB_T3
            RGB_S2
            RGB_T4
            RGB_C3
            RGB_C4
            RGB_C2
            RGB_SPP
            RGB_IPP
            ExtractRAWBINARYDATA
            OutputDataFormat_ON
            OutputDataFormatMLK_ON
            ExtractRADARSAT2
            ExtractSIRC
            ExtractALOS
            ExtractALOS2
            ExtractCSK
            RGB_I2
            ExtractTERRASARX
            ExtractUAVSAR
            ExtractRISAT
            ExtractSENTINEL1
            ExtractGF3
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
## Procedure:  ExtractAIRSAR

proc ::ExtractAIRSAR {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NligFullSize NcolFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine 
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3
global AirsarHeader AIRSARDataFormat AIRSARProcessor
global TMPAirsarConfig IEEEFormat MultiLookSubSamp

if {$AIRSARDataFormat == "SLC"} {
    if {$AIRSARProcessor == "old"} {
        set ExtractFunction "Soft/bin/data_import/airsar_convert_SLC.exe"
        TextEditorRunTrace "Process The Function $ExtractFunction" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileInputSTK\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPAirsarConfig\x22 $MultiLookSubSamp" "k"
        set f [ open "| $ExtractFunction -if \x22$FileInputSTK\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPAirsarConfig\x22 $MultiLookSubSamp" r]
        }            
    if {$AIRSARProcessor == "new"} {
        set ExtractFunction "Soft/bin/data_import/airsar_convert_V6_SLC.exe"
        TextEditorRunTrace "Process The Function $ExtractFunction" "k"
        TextEditorRunTrace "Arguments: -if1 \x22$FileInputSTK\x22 -if2 \x22$FileInputSTK1\x22 -if3 \x22$FileInputSTK2\x22 -if4 \x22$FileInputSTK3\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPAirsarConfig\x22 -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" "k"
        set f [ open "| $ExtractFunction -if1 \x22$FileInputSTK\x22 -if2 \x22$FileInputSTK1\x22 -if3 \x22$FileInputSTK2\x22 -if4 \x22$FileInputSTK3\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPAirsarConfig\x22 -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" r]
        }            
    }
    
if {$AIRSARDataFormat == "MLC"} {
    set ExtractFunction "Soft/bin/data_import/airsar_convert.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if \x22$FileInputSTK\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPAirsarConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if \x22$FileInputSTK\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPAirsarConfig\x22 $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractCONVAIR

proc ::ExtractCONVAIR {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine
global FileInputHH FileInputHV FileInputVH FileInputVV
global IEEEFormat MultiLookSubSamp

set ExtractFunction "Soft/bin/data_import/convair_convert.exe"
TextEditorRunTrace "Process The Function $ExtractFunction" "k"
TextEditorRunTrace "Arguments: -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" "k"
set f [ open "| $ExtractFunction -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" r]

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractESAR

proc ::ExtractESAR {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize ESARDataFormat
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine
global FileInputHH FileInputHV FileInputVH FileInputVV
global IEEEFormat EsarHeader MultiLookSubSamp

if {$ESARDataFormat == "RGI"} {
    set ExtractFunction "Soft/bin/data_import/esar_convert.exe"
    }
if {$ESARDataFormat == "GTC"} {
    set ExtractFunction "Soft/bin/data_import/esar_convert_gtc.exe"
    }
TextEditorRunTrace "Process The Function $ExtractFunction" "k"
TextEditorRunTrace "Arguments: -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -hdr $EsarHeader $MultiLookSubSamp" "k"
set f [ open "| $ExtractFunction -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -hdr $EsarHeader $MultiLookSubSamp" r]

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractFSAR

proc ::ExtractFSAR {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize FSARDataFormat
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine
global FileInputHH FileInputHV FileInputVH FileInputVV
global IEEEFormat FsarHeader MultiLookSubSamp
global FSARMaskFile FSARIncAngFile

set ExtractFunction "Soft/bin/data_import/fsar_convert.exe"
TextEditorRunTrace "Process The Function $ExtractFunction" "k"
TextEditorRunTrace "Arguments: -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -msk \x22$FSARMaskFile\x22 -inc \x22$FSARIncAngFile\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -hdr $FsarHeader $MultiLookSubSamp" "k"
set f [ open "| $ExtractFunction -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -msk \x22$FSARMaskFile\x22 -inc \x22$FSARIncAngFile\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -hdr $FsarHeader $MultiLookSubSamp" r]

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractSETHI

proc ::ExtractSETHI {} {
global PSPImportDirInput PSPImportDirOutput TMPSethiConfig 
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize 
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine
global FileInputHH FileInputHV FileInputVH FileInputVV
global IEEEFormat MultiLookSubSamp

set ExtractFunction "Soft/bin/data_import/sethi_convert.exe"
TextEditorRunTrace "Process The Function $ExtractFunction" "k"
TextEditorRunTrace "Arguments: -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -cfg $TMPSethiConfig $MultiLookSubSamp" "k"
set f [ open "| $ExtractFunction -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -cfg $TMPSethiConfig $MultiLookSubSamp" r]

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractEMISAR

proc ::ExtractEMISAR {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NligFullSize NcolFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global IEEEFormat EMISARDataFormat MultiLookSubSamp

if {$EMISARDataFormat == "S2"} {
    set ExtractFunction "Soft/bin/data_import/emisar_convert_SLC.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" r]
    }

if {$EMISARDataFormat == "C3"} {
    set ExtractFunction "Soft/bin/data_import/emisar_convert_MLK.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -if5 \x22$FileInput5\x22 -if6 \x22$FileInput6\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -if5 \x22$FileInput5\x22 -if6 \x22$FileInput6\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractPISAR

proc ::ExtractPISAR {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine
global FileInputHH FileInputHV FileInputVH FileInputVV FileInputPISAR
global IEEEFormat PISARDataFormat PISAROffset MultiLookSubSamp

if {$PISARDataFormat == "MGPC"} {
    set ExtractFunction "Soft/bin/data_import/pisar_convert_MGPC.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if \x22$FileInputPISAR\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if \x22$FileInputPISAR\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" r]
    }
if {$PISARDataFormat == "MGPSSC"} {
    set ExtractFunction "Soft/bin/data_import/pisar_convert_MGPSSC.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -off $PISAROffset $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInputHH\x22 -if2 \x22$FileInputHV\x22 -if3 \x22$FileInputVH\x22 -if4 \x22$FileInputVV\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -off $PISAROffset $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  RGB_T3

proc ::RGB_T3 {} {
global PSPImportDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
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
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGB_S2

proc ::RGB_S2 {} {
global PSPImportDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
set config "true"
set fichier "$RGBDirInput/s11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s12.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s12.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s21.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s21.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/s22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE s22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf S2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGB_T4

proc ::RGB_T4 {} {
global PSPImportDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
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
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGB_C3

proc ::RGB_C3 {} {
global PSPImportDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
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
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGB_C4

proc ::RGB_C4 {} {
global PSPImportDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
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
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C4 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C4 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGB_C2

proc ::RGB_C2 {} {
global PSPImportDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
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
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -rgbf RGB1 -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -rgbf RGB1 -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGB_SPP

proc ::RGB_SPP {} {
global PSPImportDirOutput BMPDirInput ActiveImportData RawBinaryDataFormatPP
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PolarType TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
set Channel1 ""
set Channel2 ""
if {$ActiveImportData == "RAWBINARYDATA"} { 
    if {$RawBinaryDataFormatPP == "PP1"} {set Channel1 "s11"; set Channel2 "s21"}
    if {$RawBinaryDataFormatPP == "PP2"} {set Channel1 "s22"; set Channel2 "s12"}
    if {$RawBinaryDataFormatPP == "PP3"} {set Channel1 "s11"; set Channel2 "s22"}
    if {$RawBinaryDataFormatPP == "pp1"} {set Channel1 "s11"; set Channel2 "s21"}
    if {$RawBinaryDataFormatPP == "pp2"} {set Channel1 "s22"; set Channel2 "s12"}
    if {$RawBinaryDataFormatPP == "pp3"} {set Channel1 "s11"; set Channel2 "s22"}
    } else {
    if {$PolarType == "pp1"} {set Channel1 "s11"; set Channel2 "s21"}
    if {$PolarType == "pp2"} {set Channel1 "s22"; set Channel2 "s12"}
    if {$PolarType == "pp3"} {set Channel1 "s11"; set Channel2 "s22"}
    } 
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
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGB_IPP

proc ::RGB_IPP {} {
global PSPImportDirOutput BMPDirInput ActiveImportData RawBinaryDataFormatPP
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine PolarType TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
if {$ActiveImportData == "RAWBINARYDATA"} { 
    if {$RawBinaryDataFormatPP == "PP5"} {set Channel1 "I11"; set Channel2 "I21"}
    if {$RawBinaryDataFormatPP == "PP6"} {set Channel1 "I22"; set Channel2 "I12"}
    if {$RawBinaryDataFormatPP == "PP7"} {set Channel1 "I11"; set Channel2 "I22"}
    } else {
    if {$PolarType == "pp5"} {set Channel1 "I11"; set Channel2 "I21"}
    if {$PolarType == "pp6"} {set Channel1 "I22"; set Channel2 "I12"}
    if {$PolarType == "pp7"} {set Channel1 "I11"; set Channel2 "I22"}
    } 
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
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf IPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf IPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  ExtractRAWBINARYDATA

proc ::ExtractRAWBINARYDATA {} {
global RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize 
global MultiLookCol MultiLookRow SubSampCol SubSampRow
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6 FileInput7 FileInput8
global FileInput9 FileInput10 FileInput11 FileInput12 FileInput13 FileInput14 FileInput15 FileInput16
global IEEEFormat

set ExtractFunction "Soft/bin/data_import/rawbinary_convert_"
append ExtractFunction "$RawBinaryDataInput"
append ExtractFunction "_"
if {$PSPImportExtractFonction == "MultiLook"} {append ExtractFunction "MLK_"}
append ExtractFunction "$RawBinaryDataFormat"
append ExtractFunction ".exe"

TextEditorRunTrace "Process The Function $ExtractFunction" "k"

set ExtractCommand "$ExtractFunction \x22$PSPImportDirOutput\x22 $NcolFullSize $OffsetLig $OffsetCol $FinalNlig $FinalNcol $IEEEFormat $PSPSymmetrisation $PSPImportOutputFormat "
if {$PSPImportExtractFonction == "Full"} {append ExtractCommand "1 1 "}
if {$PSPImportExtractFonction == "SubSamp"} {append ExtractCommand "$SubSampCol $SubSampRow "}
if {$PSPImportExtractFonction == "MultiLook"} {append ExtractCommand "$MultiLookCol $MultiLookRow "}
if {$RawBinaryDataFormat == "SPP"} {append ExtractCommand "$RawBinaryDataFormatPP "}
if {$RawBinaryDataFormat == "IPP"} {append ExtractCommand "$RawBinaryDataFormatPP "}

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 $FileInput4"
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22"
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22"
        }
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22"
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22"
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22"
        }
    }
if {$RawBinaryDataFormat == "IPP"} {
    set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22"
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22"
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22"
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22"
        }
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22 \x22$FileInput10\x22"
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22 \x22$FileInput10\x22 \x22$FileInput11\x22 \x22$FileInput12\x22 \x22$FileInput13\x22 \x22$FileInput14\x22 \x22$FileInput15\x22 \x22$FileInput16\x22"
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22 \x22$FileInput10\x22 \x22$FileInput11\x22 \x22$FileInput12\x22 \x22$FileInput13\x22 \x22$FileInput14\x22 \x22$FileInput15\x22 \x22$FileInput16\x22"
        }
    }
if {$RawBinaryDataFormat == "C2"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22"
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22"
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22"
        }
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22"
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22"
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22"
        }
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22 \x22$FileInput10\x22"
        }
    if {$RawBinaryDataInput == "RealImag"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22 \x22$FileInput10\x22 \x22$FileInput11\x22 \x22$FileInput12\x22 \x22$FileInput13\x22 \x22$FileInput14\x22 \x22$FileInput15\x22 \x22$FileInput16\x22"
        }
    if {$RawBinaryDataInput == "ModPha"} {
        set ExtractFile "\x22$FileInput1\x22 \x22$FileInput2\x22 \x22$FileInput3\x22 \x22$FileInput4\x22 \x22$FileInput5\x22 \x22$FileInput6\x22 \x22$FileInput7\x22 \x22$FileInput8\x22 \x22$FileInput9\x22 \x22$FileInput10\x22 \x22$FileInput11\x22 \x22$FileInput12\x22 \x22$FileInput13\x22 \x22$FileInput14\x22 \x22$FileInput15\x22 \x22$FileInput16\x22"
        }
    }

TextEditorRunTrace "Arguments: $ExtractCommand $ExtractFile" "k"
set f [ open "| $ExtractCommand $ExtractFile" r]
PsPprogressBar $f
}
#############################################################################
## Procedure:  OutputDataFormat_ON

proc ::OutputDataFormat_ON {} {
global ActiveImportData PSPImportExtractFonction
global PSPImportOutputSubDir
global PSPImportOutputFormat PSPSymmetrisation
global RawBinaryDataFormat RawBinaryDataType
global AIRSARDataFormat EMISARDataFormat PISARDataFormat
global AIRSARProcessor SIRCDataFormat UAVSARDataFormat
global RADARSAT2DataFormat ALOSDataFormat CSKDataFormat
global TERRASARXDataFormat TERRASARXDataLevel RISATDataFormat
global SENTINEL1DataFormat GF3DataFormat

set Radiobutton233_1 .top233.tit80.f.fra83.fra93.cpd96
set Radiobutton233_2 .top233.tit80.f.fra83.fra93.cpd97
set Radiobutton233_3 .top233.tit80.f.fra83.fra93.cpd98
set Radiobutton233_4 .top233.tit80.f.fra83.fra94.cpd99
set Radiobutton233_5 .top233.tit80.f.fra83.fra94.cpd100
set Radiobutton233_6 .top233.tit80.f.fra83.fra95.cpd101
set Radiobutton233_7 .top233.tit80.f.fra83.fra95.cpd102
set Radiobutton233_8 .top233.tit80.f.fra83.fra95.cpd103
set Checkbutton233_1 .top233.fra79.che74

if {$PSPImportExtractFonction != ""} {
    if {$ActiveImportData == "RAWBINARYDATA"} {
	if {$RawBinaryDataFormat == "S2"} {
		set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
		$Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		if {$RawBinaryDataType == "Monostatic"} {
			set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
			$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
			$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
			}
		if {$RawBinaryDataType == "Bistatic"} {
			set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
			$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
			$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
			}
		}
	if {$RawBinaryDataFormat == "SPP"} {
		set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
		set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
		$Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
		$Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
		}
	if {$RawBinaryDataFormat == "IPP"} {
		set PSPImportOutputFormat "IPP";  set PSPImportOutputSubDir ""
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
		set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
		$Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
		}
	if {$RawBinaryDataFormat == "T3"} {
		set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
		set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
		}
	if {$RawBinaryDataFormat == "T4"} {
		set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
		set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
		}
	if {$RawBinaryDataFormat == "C3"} {
		set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
		set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
		}
	if {$RawBinaryDataFormat == "C4"} {
		set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
		set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
		}
	}
    if {$ActiveImportData == "ALOS"} {
	if {$ALOSDataFormat == "dual1.1"} {
            set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "dual1.5"} {
            set PSPImportOutputFormat "IPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "quad1.1"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	if {$ALOSDataFormat == "quad1.5"} {
            set PSPImportOutputFormat "IPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "dual1.1vex"} {
            set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "quad1.1vex"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
        }            
    if {$ActiveImportData == "ALOS2"} {
	if {$ALOSDataFormat == "dual1.1"} {
            set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "quad1.1"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
        }            
    if {$ActiveImportData == "CSK"} {
	if {$CSKDataFormat == "dual"} {
            set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "GF3"} {
	if {$GF3DataFormat == "quad"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	}
    if {$ActiveImportData == "RADARSAT2"} {
	if {$RADARSAT2DataFormat == "quad"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	if {$RADARSAT2DataFormat == "dual"} {
            set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "RISAT"} {
	if {$RISATDataFormat == "dual1.1"} {
            set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$RISATDataFormat == "quad1.1"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
        }            
    if {$ActiveImportData == "SENTINEL1"} {
	if {$SENTINEL1DataFormat == "dual"} {
            set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "TERRASARX"} {
        if {$TERRASARXDataFormat == "dual"} {
            if {$TERRASARXDataLevel == "SSC"} {
                set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
                $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
                set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
                $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
                $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
                } else {
                set PSPImportOutputFormat "IPP";  set PSPImportOutputSubDir ""
                $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
                set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
                $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
                $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
                }
           }
        if {$TERRASARXDataFormat == "quad"} {
            if {$TERRASARXDataLevel == "SSC"} {
                set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
                set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
                $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
                $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
                $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
                }
           }
	}
    if {$ActiveImportData == "SIRC"} {
	if {$SIRCDataFormat == "SLCdual"} {
            set PSPImportOutputFormat "SPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state normal; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$SIRCDataFormat == "SLCquad"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
	      set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	if {$SIRCDataFormat == "MLCdual"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$SIRCDataFormat == "MLCquad"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "AIRSAR"} {
	if {$AIRSARDataFormat == "SLC"} {
	  set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
	  set PSPSymmetrisation 1
          if {$AIRSARProcessor == "old"} {
              $Checkbutton233_1 configure -state disable
	      $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	      $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
	      $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
              }
          if {$AIRSARProcessor == "new"} {
              $Checkbutton233_1 configure -state normal
	      $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	      $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	      $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
              }
        }
	if {$AIRSARDataFormat == "MLC"} {
	  set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	  set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
	  $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	  $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
	  $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
        }
	}
    if {$ActiveImportData == "CONVAIR"} {
	set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
	set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
	$Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
	}
    if {$ActiveImportData == "EMISAR"} {
	if {$EMISARDataFormat == "S2"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	if {$EMISARDataFormat == "C3"} {
            set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
	      set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "ESAR"} {
	set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
	set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
	$Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
	}
    if {$ActiveImportData == "FSAR"} {
	set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
	set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
	$Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
	}
    if {$ActiveImportData == "PISAR"} {
	if {$PISARDataFormat == "MGPC"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
	    set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
        if {$PISARDataFormat == "MGPSSC"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
	      set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	}
    if {$ActiveImportData == "SETHI"} {
        set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
	set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
	$Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
	}
    if {$ActiveImportData == "UAVSAR"} {
	if {$UAVSARDataFormat == "SLC"} {
            set PSPImportOutputFormat "S2";  set PSPImportOutputSubDir ""
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state normal; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	if {$UAVSARDataFormat == "MLC"} {
            set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
	      set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	if {$UAVSARDataFormat == "GRD"} {
            set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
	      set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	}
}
}
#############################################################################
## Procedure:  OutputDataFormatMLK_ON

proc ::OutputDataFormatMLK_ON {} {
global ActiveImportData PSPImportExtractFonction
global PSPImportOutputSubDir
global PSPImportOutputFormat PSPSymmetrisation
global RawBinaryDataFormat RawBinaryDataType
global AIRSARDataFormat EMISARDataFormat PISARDataFormat
global AIRSARProcessor SIRCDataFormat UAVSARDataFormat
global RADARSAT2DataFormat ALOSDataFormat CSKDataFormat
global TERRASARXDataFormat TERRASARXDataLevel RISATDataFormat
global SENTINEL1DataFormat GF3DataFormat

set Radiobutton233_1 .top233.tit80.f.fra83.fra93.cpd96
set Radiobutton233_2 .top233.tit80.f.fra83.fra93.cpd97
set Radiobutton233_3 .top233.tit80.f.fra83.fra93.cpd98
set Radiobutton233_4 .top233.tit80.f.fra83.fra94.cpd99
set Radiobutton233_5 .top233.tit80.f.fra83.fra94.cpd100
set Radiobutton233_6 .top233.tit80.f.fra83.fra95.cpd101
set Radiobutton233_7 .top233.tit80.f.fra83.fra95.cpd102
set Radiobutton233_8 .top233.tit80.f.fra83.fra95.cpd103
set Checkbutton233_1 .top233.fra79.che74

if {$PSPImportExtractFonction != ""} {
    if {$ActiveImportData == "RAWBINARYDATA"} {
	if {$RawBinaryDataFormat == "S2"} {
		set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		if {$RawBinaryDataType == "Monostatic"} {
			set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
			$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
			$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
			}
		if {$RawBinaryDataType == "Bistatic"} {
			set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
			$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
			$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
			}
		}
	if {$RawBinaryDataFormat == "SPP"} {
		set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
		set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
		$Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
		$Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
		}
	if {$RawBinaryDataFormat == "IPP"} {
		set PSPImportOutputFormat "IPP";  set PSPImportOutputSubDir ""
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
		set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
		$Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
		}
	if {$RawBinaryDataFormat == "T3"} {
		set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
		set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
		}
	if {$RawBinaryDataFormat == "T4"} {
		set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
		set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
		}
	if {$RawBinaryDataFormat == "C3"} {
		set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
		set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
		}
	if {$RawBinaryDataFormat == "C4"} {
		set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
		set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
		$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
		$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
		$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
		}
	}
    if {$ActiveImportData == "ALOS"} {
	if {$ALOSDataFormat == "dual1.1"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "dual1.5"} {
            set PSPImportOutputFormat "IPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "quad1.1"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	if {$ALOSDataFormat == "quad1.5"} {
            set PSPImportOutputFormat "IPP";  set PSPImportOutputSubDir ""
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "dual1.1vex"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "quad1.1vex"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
        }            
    if {$ActiveImportData == "ALOS2"} {
	if {$ALOSDataFormat == "dual1.1"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$ALOSDataFormat == "quad1.1"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
        }            
    if {$ActiveImportData == "CSK"} {
	if {$CSKDataFormat == "dual"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "GF3"} {
	if {$GF3DataFormat == "quad"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	}
    if {$ActiveImportData == "RADARSAT2"} {
	if {$RADARSAT2DataFormat == "quad"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	if {$RADARSAT2DataFormat == "dual"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "RISAT"} {
	if {$RISATDataFormat == "dual1.1"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$RISATDataFormat == "quad1.1"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
        }            
    if {$ActiveImportData == "SENTINEL1"} {
	if {$SENTINEL1DataFormat == "dual"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "TERRASARX"} {
        if {$TERRASARXDataFormat == "dual"} {
            if {$TERRASARXDataLevel == "SSC"} {
                set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
                $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
                set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
                $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
                $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
                } else {
                set PSPImportOutputFormat "IPP";  set PSPImportOutputSubDir ""
                $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
                set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
                $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
                $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
                }
           }
        if {$TERRASARXDataFormat == "quad"} {
            if {$TERRASARXDataLevel == "SSC"} {
                set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
                set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
                $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
                $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
                $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
                }
           }
	}
    if {$ActiveImportData == "SIRC"} {
	if {$SIRCDataFormat == "SLCdual"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state normal
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$SIRCDataFormat == "SLCquad"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1
            $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	if {$SIRCDataFormat == "MLCdual"} {
            set PSPImportOutputFormat "C2";  set PSPImportOutputSubDir "C2"
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            set PSPSymmetrisation 0; $Checkbutton233_1 configure -state disable
            $Radiobutton233_4 configure -state disable; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state normal; $Radiobutton233_7 configure -state disable; $Radiobutton233_8 configure -state disable
            }
	if {$SIRCDataFormat == "MLCquad"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "AIRSAR"} {
	if {$AIRSARDataFormat == "SLC"} {
 	  set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	  set PSPSymmetrisation 1
          if {$AIRSARProcessor == "old"} {
              $Checkbutton233_1 configure -state disable
              $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
              $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
	      $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
              }
          if {$AIRSARProcessor == "new"} {
              $Checkbutton233_1 configure -state normal
              $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
              $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	      $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
              }
        }
	if {$AIRSARDataFormat == "MLC"} {
 	  set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	  set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
	  $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	  $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
	  $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
        }
	}
    if {$ActiveImportData == "CONVAIR"} {
	set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
	$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
	}
    if {$ActiveImportData == "EMISAR"} {
	if {$EMISARDataFormat == "S2"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	if {$EMISARDataFormat == "C3"} {
            set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
	    set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	}
    if {$ActiveImportData == "ESAR"} {
	set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
	$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
	}
    if {$ActiveImportData == "FSAR"} {
	set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
	$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
	}
    if {$ActiveImportData == "PISAR"} {
	if {$PISARDataFormat == "MGPC"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	    set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
        if {$PISARDataFormat == "MGPSSC"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	    set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	}
    if {$ActiveImportData == "SETHI"} {
        set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
	set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
	$Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
	$Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
	$Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
	}
    if {$ActiveImportData == "UAVSAR"} {
	if {$UAVSARDataFormat == "SLC"} {
            set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
            set PSPSymmetrisation 1; $Checkbutton233_1 configure -state normal
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state normal
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state normal
            }
	if {$UAVSARDataFormat == "MLC"} {
            set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
	      set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	if {$UAVSARDataFormat == "GRD"} {
            set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
	      set PSPSymmetrisation 1; $Checkbutton233_1 configure -state disable
            $Radiobutton233_1 configure -state disable; $Radiobutton233_2 configure -state disable; $Radiobutton233_3 configure -state disable
            $Radiobutton233_4 configure -state normal; $Radiobutton233_5 configure -state disable
            $Radiobutton233_6 configure -state disable; $Radiobutton233_7 configure -state normal; $Radiobutton233_8 configure -state disable
            }
	}
}
}
#############################################################################
## Procedure:  ExtractRADARSAT2

proc ::ExtractRADARSAT2 {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize PolarType NligFullSize 
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global IEEEFormat RADARSAT2DataFormat RADARSAT2LutFile

if {$RADARSAT2DataFormat == "dual"} {
    set ExtractFunction "Soft/bin/data_import/radarsat2_convert_dual.exe"
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType -lut \x22$RADARSAT2LutFile\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType -lut \x22$RADARSAT2LutFile\x22 $MultiLookSubSamp" r]
    }

if {$RADARSAT2DataFormat == "quad"} {
    set ExtractFunction "Soft/bin/data_import/radarsat2_convert.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -lut \x22$RADARSAT2LutFile\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -lut \x22$RADARSAT2LutFile\x22 $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractSIRC

proc ::ExtractSIRC {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInputSIRC SIRCDataFormat
global TMPSIRCConfig MultiLookSubSamp

if {$SIRCDataFormat == "SLCdual"} {
    set ExtractFunction "Soft/bin/data_import/sirc_convert_SLC_dual.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    TextEditorRunTrace "Arguments: -if \x22$FileInputSIRC\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPSIRCConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if \x22$FileInputSIRC\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPSIRCConfig\x22 $MultiLookSubSamp" r]
    }
 
if {$SIRCDataFormat == "SLCquad"} {
    set ExtractFunction "Soft/bin/data_import/sirc_convert_SLC.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if \x22$FileInputSIRC\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPSIRCConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if \x22$FileInputSIRC\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPSIRCConfig\x22 $MultiLookSubSamp" r]
    }

if {$SIRCDataFormat == "MLCdual"} {
    set ExtractFunction "Soft/bin/data_import/sirc_convert_dual.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if \x22$FileInputSIRC\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPSIRCConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if \x22$FileInputSIRC\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPSIRCConfig\x22 $MultiLookSubSamp" r]
    }
            
if {$SIRCDataFormat == "MLCquad"} {
    set ExtractFunction "Soft/bin/data_import/sirc_convert.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if \x22$FileInputSIRC\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPSIRCConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if \x22$FileInputSIRC\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPSIRCConfig\x22 $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractALOS

proc ::ExtractALOS {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInput1 FileInput2 FileInput3 FileInput4
global TMPALOSConfig ALOSDataFormat ALOSUnCalibration
global IEEEFormat MultiLookSubSamp

if {$ALOSDataFormat == "dual1.1"} {
    set ExtractFunction "Soft/bin/data_import/alos_convert_11_dual.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPALOSConfig\x22 -pp $PolarType $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPALOSConfig\x22 -pp $PolarType $MultiLookSubSamp" r]
    }

if {$ALOSDataFormat == "dual1.5"} {
    set ExtractFunction "Soft/bin/data_import/alos_convert_15_dual.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPALOSConfig\x22 -pp $PolarType $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPALOSConfig\x22 -pp $PolarType $MultiLookSubSamp" r]
    }

if {$ALOSDataFormat == "quad1.1"} {
    set ExtractFunction "Soft/bin/data_import/alos_convert_11.exe"
    if {$ALOSUnCalibration == 1} { set ExtractFunction "Soft/bin/data_import/alos_convert_11_uncal.exe" }
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPALOSConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPALOSConfig\x22 $MultiLookSubSamp" r]
    }

if {$ALOSDataFormat == "quad1.5"} {
    set ExtractFunction "Soft/bin/data_import/alos_convert_15.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPALOSConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPALOSConfig\x22 $MultiLookSubSamp" r]
    }

if {$ALOSDataFormat == "dual1.1vex"} {
    set ExtractFunction "Soft/bin/data_import/alos_vex_convert_dual.exe"
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType $MultiLookSubSamp" r]
    }

if {$ALOSDataFormat == "quad1.1vex"} {
    set ExtractFunction "Soft/bin/data_import/alos_vex_convert.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractALOS2

proc ::ExtractALOS2 {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInput1 FileInput2 FileInput3 FileInput4
global TMPALOSConfig ALOSDataFormat ALOSUnCalibration
global IEEEFormat MultiLookSubSamp

if {$ALOSDataFormat == "dual1.1"} {
    set ExtractFunction "Soft/bin/data_import/alos_convert_11_dual.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPALOSConfig\x22 -pp $PolarType $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPALOSConfig\x22 -pp $PolarType $MultiLookSubSamp" r]
    }

if {$ALOSDataFormat == "quad1.1"} {
    set ExtractFunction "Soft/bin/data_import/alos_convert_11.exe"
    if {$ALOSUnCalibration == 1} { set ExtractFunction "Soft/bin/data_import/alos2_convert_11_uncal.exe" }
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPALOSConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPALOSConfig\x22 $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractCSK

proc ::ExtractCSK {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize PolarType NligFullSize 
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global IEEEFormat CSKDataFormat

if {$CSKDataFormat == "dual"} {
    set ExtractFunction "Soft/bin/data_import/csk_convert_dual.exe"
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  RGB_I2

proc ::RGB_I2 {} {
global PSPImportDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError MaskCmd
   
set RGBDirInput $PSPImportDirOutput
set RGBDirOutput $PSPImportDirOutput
set RGBFileOutput "$RGBDirOutput/SinclairRGB.bmp"
set config "true"
set fichier "$RGBDirInput/I11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE I11.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/I12.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE I12.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/I21.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE I21.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/I22.bin"
    if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE I22.bin HAS NOT BEEN CREATED"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf IPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf IPP -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  ExtractTERRASARX

proc ::ExtractTERRASARX {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInput1 FileInput2 FileInput3 FileInput4 IEEEFormat MultiLookSubSamp
global TMPTerrasarxConfig TERRASARXDataFormat TERRASARXDataLevel

if {$TERRASARXDataFormat == "dual"} {
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    if {$TERRASARXDataLevel == "SSC"} {
        set ExtractFunction "Soft/bin/data_import/terrasarx_convert_ssc_dual.exe"
        TextEditorRunTrace "Process The Function $ExtractFunction" "k"
        TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTerrasarxConfig\x22 -pp $PolarType $MultiLookSubSamp" "k"
        set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTerrasarxConfig\x22 -pp $PolarType $MultiLookSubSamp" r]
        } else {
        set ExtractFunction "Soft/bin/data_import/terrasarx_convert_mgd_gec_eec_dual.exe"
        TextEditorRunTrace "Process The Function $ExtractFunction" "k"
        TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTerrasarxConfig\x22 -pp $PolarType $MultiLookSubSamp" "k"
        set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPTerrasarxConfig\x22 -pp $PolarType $MultiLookSubSamp" r]
        }
    }        

if {$TERRASARXDataFormat == "quad"} {
    set ExtractFunction "Soft/bin/data_import/terrasarx_convert_ssc_quad.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPTerrasarxConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPTerrasarxConfig\x22 $MultiLookSubSamp" r]
    }
PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractUAVSAR

proc ::ExtractUAVSAR {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global UAVSARDataFormat UAVSARAnnotationFile
global UAVSARMapInfoMapInfo UAVSARMapInfoLat UAVSARMapInfoLon UAVSARMapInfoLatDeg UAVSARMapInfoLonDeg

if {$UAVSARDataFormat == "SLC"} {
    set ExtractFunction "Soft/bin/data_import/uavsar_convert_SLC.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -hf \x22$UAVSARAnnotationFile\x22 -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -inr $NligFullSize -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -hf \x22$UAVSARAnnotationFile\x22 -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -inr $NligFullSize -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation $MultiLookSubSamp" r]
    } else {
    set ExtractFunction "Soft/bin/data_import/uavsar_convert_MLC.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -hf \x22$UAVSARAnnotationFile\x22 -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -if5 \x22$FileInput5\x22 -if6 \x22$FileInput6\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -inr $NligFullSize -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -hf \x22$UAVSARAnnotationFile\x22 -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -if5 \x22$FileInput5\x22 -if6 \x22$FileInput6\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -inr $NligFullSize -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MultiLookSubSamp" r]
    }

set ff [open "$PSPImportDirOutput/config_mapinfo.txt" w]
puts $ff "Sensor"
puts $ff "UAVSAR"
puts $ff "---------"
puts $ff "MapInfo"
puts $ff $UAVSARMapInfoMapInfo
puts $ff "---------"
puts $ff "MapProj"
puts $ff "Geographic Lat/Lon"
puts $ff "1."
puts $ff "1."
puts $ff $UAVSARMapInfoLat
puts $ff $UAVSARMapInfoLon
puts $ff $UAVSARMapInfoLatDeg
puts $ff $UAVSARMapInfoLonDeg
puts $ff "WGS-84"
puts $ff "units=Degrees"
close $ff

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractRISAT

proc ::ExtractRISAT {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize NligFullSize
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInput1 FileInput2 FileInput3 FileInput4
global TMPRISATConfig RISATDataFormat RISATIncAngFile
global IEEEFormat MultiLookSubSamp

if {$RISATDataFormat == "dual1.1"} {
    set ExtractFunction "Soft/bin/data_import/risat_convert_11_dual.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -ifa \x22$RISATIncAngFile\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPRISATConfig\x22 -pp $PolarType $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -ifa \x22$RISATIncAngFile\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf \x22$TMPRISATConfig\x22 -pp $PolarType $MultiLookSubSamp" r]
    }

if {$RISATDataFormat == "quad1.1"} {
    set ExtractFunction "Soft/bin/data_import/risat_convert_11.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -ifa \x22$RISATIncAngFile\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPRISATConfig\x22 $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -ifa \x22$RISATIncAngFile\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sym $PSPSymmetrisation -cf \x22$TMPRISATConfig\x22 $MultiLookSubSamp" r]
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractSENTINEL1

proc ::ExtractSENTINEL1 {} {
global PSPImportDirInput PSPImportDirOutput DirOutputPSPImport
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize PolarType NligFullSize 
global MultiLookSubSamp TMPDirectory
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType IEEEFormat
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global SENTINEL1DirInput SENTINEL1DataFormat SENTINEL1FUD SENTINEL1Burst

if {$SENTINEL1DataFormat == "dual"} {
    if {$PSPImportOutputFormat == "SPP"} { set PolType "SPP" }
    if {$PSPImportOutputFormat == "IPP"} { set PolType "SPPIPP" }
    if {$PSPImportOutputFormat == "C2"} { set PolType "SPPC2" }
    if {$SENTINEL1Burst == "ALL"} {
        set SENTINEL1File "$SENTINEL1DirInput/product_header.txt"
        TextEditorRunTrace "Process The Function Soft/bin/data_import/sentinel1_convert_dual_all.exe" "k"
        TextEditorRunTrace "Arguments: -if $SENTINEL1File -td \x22$TMPDirectory\x22 -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType $MultiLookSubSamp" "k"
        set f [ open "| Soft/bin/data_import/sentinel1_convert_dual_all.exe -if $SENTINEL1File -td \x22$TMPDirectory\x22 -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType $MultiLookSubSamp" r]
        } else {
        if {$SENTINEL1FUD == 1} { set DirOutputPSPImport $PSPImportDirOutput; set PSPImportDirOutput $TMPDirectory }
        TextEditorRunTrace "Process The Function Soft/bin/data_import/sentinel1_convert_dual.exe" "k"
        TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType $MultiLookSubSamp" "k"
        set f [ open "| Soft/bin/data_import/sentinel1_convert_dual.exe -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -od \x22$PSPImportDirOutput\x22 -odf $PolType -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -pp $PolarType $MultiLookSubSamp" r]
        }
    }

PsPprogressBar $f
}
#############################################################################
## Procedure:  ExtractGF3

proc ::ExtractGF3 {} {
global PSPImportDirInput PSPImportDirOutput
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global NcolFullSize PolarType NligFullSize 
global MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine PolarType
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6
global IEEEFormat GF3DataFormat GF3QualifyValueHH GF3QualifyValueHV GF3QualifyValueVH GF3QualifyValueVV 

if {$GF3DataFormat == "quad"} {
    set ExtractFunction "Soft/bin/data_import/gf3_convert.exe"
    TextEditorRunTrace "Process The Function $ExtractFunction" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -qv1 $GF3QualifyValueHH -qv2 $GF3QualifyValueHV -qv3 $GF3QualifyValueVH -qv4 $GF3QualifyValueVV $MultiLookSubSamp" "k"
    set f [ open "| $ExtractFunction -if1 \x22$FileInput1\x22 -if2 \x22$FileInput2\x22 -if3 \x22$FileInput3\x22 -if4 \x22$FileInput4\x22 -od \x22$PSPImportDirOutput\x22 -odf $PSPImportOutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -iee $IEEEFormat -sym $PSPSymmetrisation -qv1 $GF3QualifyValueHH -qv2 $GF3QualifyValueHV -qv3 $GF3QualifyValueVH -qv4 $GF3QualifyValueVV $MultiLookSubSamp" r]
    }

PsPprogressBar $f
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
    wm geometry $top 200x200+75+75; update
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

proc vTclWindow.top233 {base} {
    if {$base == ""} {
        set base .top233
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
    wm title $top "Extract Data"
    vTcl:DefineAlias "$top" "Toplevel233" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    canvas $top.can73 \
        -borderwidth 2 -closeenough 0.0 -height 84 -highlightthickness 0 \
        -relief ridge -width 200 
    vTcl:DefineAlias "$top.can73" "CANVASPSPImportEXTRACTMENU" vTcl:WidgetProc "Toplevel233" 1
    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel233" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel233" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PSPImportDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel233" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel233" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel233" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PSPImportOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel233" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab75 \
        -text {/ } 
    vTcl:DefineAlias "$site_6_0.lab75" "Label1" vTcl:WidgetProc "Toplevel233" 1
    entry $site_6_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPImportOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd77" "Entry1" vTcl:WidgetProc "Toplevel233" 1
    pack $site_6_0.lab75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame12" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd95 \
        \
        -command {global DirName DataDir PSPImportOutputDir PSPImportOutputDirBis PSPImportOutputSubDir
global VarWarning WarningMessage WarningMessage2

set PSPImportOutputDirTmp $PSPImportOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set PSPImportOutputDir $DirName
        set PSPImportOutputDirBis $PSPImportOutputDir
        set PSPImportExtractFonction "Full"
        set PSPImportConvertMLKName 0
        set MultiLookCol " "
        set MultiLookRow " "
        set SubSampCol " "
        set SubSampRow " "
        $widget(Label233_1) configure -state disable
        $widget(Label233_2) configure -state disable
        $widget(Label233_3) configure -state disable
        $widget(Label233_4) configure -state disable
        $widget(Entry233_1) configure -state disable
        $widget(Entry233_2) configure -state disable
        $widget(Entry233_3) configure -state disable
        $widget(Entry233_4) configure -state disable
        } else {
        set PSPImportOutputDir $PSPImportOutputDirTmp
        set PSPImportOutputDirBis $PSPImportOutputDir
        }
    } else {
    set PSPImportOutputDir $PSPImportOutputDirTmp
    set PSPImportOutputDirBis $PSPImportOutputDir
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd95 "$site_6_0.cpd95 Button $top all _vTclBalloon"
    bind $site_6_0.cpd95 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra27 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra27" "Frame9" vTcl:WidgetProc "Toplevel233" 1
    set site_3_0 $top.fra27
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel233" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel233" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel233" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel233" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel233" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel233" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel233" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel233" 1
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
    frame $top.fra96 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra96" "Frame3" vTcl:WidgetProc "Toplevel233" 1
    set site_3_0 $top.fra96
    frame $site_3_0.fra97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra97" "Frame4" vTcl:WidgetProc "Toplevel233" 1
    set site_4_0 $site_3_0.fra97
    frame $site_4_0.fra102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra102" "Frame6" vTcl:WidgetProc "Toplevel233" 1
    set site_5_0 $site_4_0.fra102
    radiobutton $site_5_0.cpd105 \
        \
        -command {global MultiLookCol MultiLookRow SubSampCol SubSampRow

set MultiLookCol " "
set MultiLookRow " "
set SubSampCol " "
set SubSampRow " "
$widget(Label233_1) configure -state disable
$widget(Label233_2) configure -state disable
$widget(Label233_3) configure -state disable
$widget(Label233_4) configure -state disable
$widget(Entry233_1) configure -state disable
$widget(Entry233_2) configure -state disable
$widget(Entry233_3) configure -state disable
$widget(Entry233_4) configure -state disable
OutputDataFormat_ON} \
        -text {Full Resolution} -value Full \
        -variable PSPImportExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd105" "Radiobutton4" vTcl:WidgetProc "Toplevel233" 1
    pack $site_5_0.cpd105 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.fra103 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra103" "Frame7" vTcl:WidgetProc "Toplevel233" 1
    set site_5_0 $site_4_0.fra103
    radiobutton $site_5_0.cpd106 \
        \
        -command {global MultiLookCol MultiLookRow SubSampCol SubSampRow

set MultiLookCol " "
set MultiLookRow " "
set SubSampCol " ? "
set SubSampRow " ? "
$widget(Label233_1) configure -state normal
$widget(Label233_2) configure -state normal
$widget(Label233_3) configure -state disable
$widget(Label233_4) configure -state disable
$widget(Entry233_1) configure -state normal
$widget(Entry233_2) configure -state normal
$widget(Entry233_3) configure -state disable
$widget(Entry233_4) configure -state disable
OutputDataFormat_ON} \
        -text {Sub Sampling} -value SubSamp \
        -variable PSPImportExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd106" "Radiobutton5" vTcl:WidgetProc "Toplevel233" 1
    pack $site_5_0.cpd106 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.fra104 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra104" "Frame8" vTcl:WidgetProc "Toplevel233" 1
    set site_5_0 $site_4_0.fra104
    radiobutton $site_5_0.cpd107 \
        \
        -command {global MultiLookCol MultiLookRow SubSampCol SubSampRow

set MultiLookCol " ? "
set MultiLookRow " ? "
set SubSampCol " "
set SubSampRow " "
$widget(Label233_1) configure -state disable
$widget(Label233_2) configure -state disable
$widget(Label233_3) configure -state normal
$widget(Label233_4) configure -state normal
$widget(Entry233_1) configure -state disable
$widget(Entry233_2) configure -state disable
$widget(Entry233_3) configure -state normal
$widget(Entry233_4) configure -state normal
OutputDataFormatMLK_ON} \
        -text {Multi Look} -value MultiLook \
        -variable PSPImportExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd107" "Radiobutton6" vTcl:WidgetProc "Toplevel233" 1
    pack $site_5_0.cpd107 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra102 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra103 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra104 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $site_3_0.cpd98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd98" "Frame5" vTcl:WidgetProc "Toplevel233" 1
    set site_4_0 $site_3_0.cpd98
    frame $site_4_0.cpd111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd111" "Frame153" vTcl:WidgetProc "Toplevel233" 1
    set site_5_0 $site_4_0.cpd111
    label $site_5_0.lab23 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab23" "Label203" vTcl:WidgetProc "Toplevel233" 1
    label $site_5_0.lab25 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab25" "Label204" vTcl:WidgetProc "Toplevel233" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_4_0.cpd109 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd109" "Frame154" vTcl:WidgetProc "Toplevel233" 1
    set site_5_0 $site_4_0.cpd109
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label233_2" vTcl:WidgetProc "Toplevel233" 1
    entry $site_5_0.ent26 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable SubSampRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry233_2" vTcl:WidgetProc "Toplevel233" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label233_1" vTcl:WidgetProc "Toplevel233" 1
    entry $site_5_0.ent24 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable SubSampCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry233_1" vTcl:WidgetProc "Toplevel233" 1
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd110 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd110" "Frame155" vTcl:WidgetProc "Toplevel233" 1
    set site_5_0 $site_4_0.cpd110
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label233_4" vTcl:WidgetProc "Toplevel233" 1
    entry $site_5_0.ent26 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable MultiLookRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry233_4" vTcl:WidgetProc "Toplevel233" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label233_3" vTcl:WidgetProc "Toplevel233" 1
    entry $site_5_0.ent24 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable MultiLookCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry233_3" vTcl:WidgetProc "Toplevel233" 1
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent26 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent24 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd109 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd110 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.fra97 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra79" "Frame10" vTcl:WidgetProc "Toplevel233" 1
    set site_3_0 $top.fra79
    checkbutton $site_3_0.che74 \
        \
        -command {global PSPSymmetrisation PSPImportOutputFormat PSPImportOutputSubDir
if {$PSPSymmetrisation == 1} {
    if {$PSPImportOutputFormat == "T4"} {
        set PSPImportOutputFormat "T3";  set PSPImportOutputSubDir "T3"
        }
    if {$PSPImportOutputFormat == "C4"} {
        set PSPImportOutputFormat "C3";  set PSPImportOutputSubDir "C3"
        }
    }
if {$PSPSymmetrisation == 0} {
    if {$PSPImportOutputFormat == "T3"} {
        set PSPImportOutputFormat "T4";  set PSPImportOutputSubDir "T4"
        }
    if {$PSPImportOutputFormat == "C3"} {
        set PSPImportOutputFormat "C4";  set PSPImportOutputSubDir "C4"
        }
    }} \
        -text {Symmetrisation ( S12 = S21 )} -variable PSPSymmetrisation 
    vTcl:DefineAlias "$site_3_0.che74" "Checkbutton233_1" vTcl:WidgetProc "Toplevel233" 1
    pack $site_3_0.che74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame13" vTcl:WidgetProc "Toplevel233" 1
    set site_3_0 $top.cpd77
    label $site_3_0.lab80 \
        -text { Input Data Format   } 
    vTcl:DefineAlias "$site_3_0.lab80" "Label3" vTcl:WidgetProc "Toplevel233" 1
    entry $site_3_0.ent81 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PSPImportInputFormat -width 40 
    vTcl:DefineAlias "$site_3_0.ent81" "Entry3" vTcl:WidgetProc "Toplevel233" 1
    pack $site_3_0.lab80 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.ent81 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit80 \
        -text {Output Data Format} 
    vTcl:DefineAlias "$top.tit80" "TitleFrame2" vTcl:WidgetProc "Toplevel233" 1
    bind $top.tit80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit80 getframe]
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame14" vTcl:WidgetProc "Toplevel233" 1
    set site_5_0 $site_4_0.cpd82
    frame $site_5_0.fra87 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra87" "Frame16" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.fra87
    label $site_6_0.cpd90 \
        -justify left -text {Sinclair Elements} 
    vTcl:DefineAlias "$site_6_0.cpd90" "Label2" vTcl:WidgetProc "Toplevel233" 1
    pack $site_6_0.cpd90 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame17" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.fra88
    label $site_6_0.cpd91 \
        -text {Coherency Elements} 
    vTcl:DefineAlias "$site_6_0.cpd91" "Label4" vTcl:WidgetProc "Toplevel233" 1
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.fra89 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra89" "Frame18" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.fra89
    label $site_6_0.cpd92 \
        -text {Covariance Elements} 
    vTcl:DefineAlias "$site_6_0.cpd92" "Label5" vTcl:WidgetProc "Toplevel233" 1
    pack $site_6_0.cpd92 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra87 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra89 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    frame $site_4_0.fra83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra83" "Frame15" vTcl:WidgetProc "Toplevel233" 1
    set site_5_0 $site_4_0.fra83
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame19" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.fra93
    radiobutton $site_6_0.cpd96 \
        -command {global PSPImportOutputSubDir

set PSPImportOutputSubDir ""} \
        -text {[ S2 ]} -value S2 -variable PSPImportOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd96" "Radiobutton233_1" vTcl:WidgetProc "Toplevel233" 1
    radiobutton $site_6_0.cpd97 \
        -command {global PSPImportOutputSubDir

set PSPImportOutputSubDir ""} \
        -text {( Sxx, Sxy )} -value SPP -variable PSPImportOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd97" "Radiobutton233_2" vTcl:WidgetProc "Toplevel233" 1
    radiobutton $site_6_0.cpd98 \
        -command {global PSPImportOutputSubDir

set PSPImportOutputSubDir ""} \
        -text {( Ixx, Ixy )} -value IPP -variable PSPImportOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd98" "Radiobutton233_3" vTcl:WidgetProc "Toplevel233" 1
    pack $site_6_0.cpd96 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 20 \
        -side left 
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 20 \
        -side left 
    pack $site_6_0.cpd98 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 20 \
        -side left 
    frame $site_5_0.fra94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra94" "Frame21" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.fra94
    radiobutton $site_6_0.cpd99 \
        \
        -command {global PSPImportOutputSubDir
global ActiveImportData
global PSPImportOutputFormat PSPSymmetrisation
global RawBinaryDataFormat RawBinaryDataType
global EMISARDataFormat PISARDataFormat
global AIRSARDataFormat AIRSARProcessor UAVSARDataFormat
global RADARSAT2DataFormat SIRCDataFormat ALOSDataFormat CSKDataFormat
global TERRASARXDataFormat TERRASARXDataLevel RISATDataFormat GF3DataFormat

set PSPImportOutputSubDir "T3"

set config "false"
if {$ActiveImportData == "RAWBINARYDATA"} {
    if {$RawBinaryDataFormat == "S2"} { set config "true" }
    if {$RawBinaryDataFormat == "T4"} { set config "true" }
    if {$RawBinaryDataFormat == "C4"} { set config "true" }
    }
if {$ActiveImportData == "GF3"} {
    if {$GF3DataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "RADARSAT2"} {
    if {$RADARSAT2DataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "TERRASARX"} {
    if {$TERRASARXDataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "ALOS"} {
    if {$ALOSDataFormat == "quad1.1"} {  set config "true" }
    if {$ALOSDataFormat == "quad1.1vex"} {  set config "true" }
    }
if {$ActiveImportData == "ALOS2"} {
    if {$ALOSDataFormat == "quad1.1"} {  set config "true" }
    }
if {$ActiveImportData == "RISAT"} {
    if {$RISATDataFormat == "quad1.1"} {  set config "true" }
    }
if {$ActiveImportData == "SIRC"} {
    if {$SIRCDataFormat == "SLCquad"} {  set config "true" }
    }
if {$ActiveImportData == "AIRSAR"} {
    if {$AIRSARDataFormat == "SLC"} {
        if {$AIRSARProcessor == "new"} {
            set config "true"
            }
        }
    }
if {$ActiveImportData == "CONVAIR"} {  set config "true" }
if {$ActiveImportData == "EMISAR"} {
    if {$EMISARDataFormat == "S2"} {  set config "true" }
    }
if {$ActiveImportData == "ESAR"} { set config "true" }
if {$ActiveImportData == "FSAR"} { set config "true" }
if {$ActiveImportData == "PISAR"} {
    if {$PISARDataFormat == "MGPSSC"} { set config "true" }
    if {$PISARDataFormat == "MGPC"} { set config "true" }
    }
if {$ActiveImportData == "SETHI"} { set config "true" }
if {$ActiveImportData == "UAVSAR"} { set config "true" }

if {$config == "true"} {set PSPSymmetrisation 1}} \
        -text {[ T3 ]} -value T3 -variable PSPImportOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd99" "Radiobutton233_4" vTcl:WidgetProc "Toplevel233" 1
    radiobutton $site_6_0.cpd100 \
        \
        -command {global PSPImportOutputSubDir
global ActiveImportData
global PSPImportOutputFormat PSPSymmetrisation
global RawBinaryDataFormat RawBinaryDataType
global EMISARDataFormat PISARDataFormat
global AIRSARDataFormat AIRSARProcessor UAVSARDataForma
global RADARSAT2DataFormat SIRCDataFormat ALOSDataFormat CSKDataFormat
global TERRASARXDataFormat TERRASARXDataLevel RISATDataFormat GF3DataFormat

set PSPImportOutputSubDir "T4"

set config "false"
if {$ActiveImportData == "RAWBINARYDATA"} {
    if {$RawBinaryDataFormat == "S2"} { set config "true" }
    if {$RawBinaryDataFormat == "T4"} { set config "true" }
    if {$RawBinaryDataFormat == "C4"} { set config "true" }
    }
if {$ActiveImportData == "GF3"} {
    if {$GF3DataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "RADARSAT2"} {
    if {$RADARSAT2DataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "TERRASARX"} {
    if {$TERRASARXDataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "ALOS"} {
    if {$ALOSDataFormat == "quad1.1"} {  set config "true" }
    if {$ALOSDataFormat == "quad1.1vex"} {  set config "true" }
    }
if {$ActiveImportData == "ALOS2"} {
    if {$ALOSDataFormat == "quad1.1"} {  set config "true" }
    }
if {$ActiveImportData == "RISAT"} {
    if {$RISATDataFormat == "quad1.1"} {  set config "true" }
    }
if {$ActiveImportData == "SIRC"} {
    if {$SIRCDataFormat == "SLCquad"} {  set config "true" }
    }
if {$ActiveImportData == "AIRSAR"} {
    if {$AIRSARDataFormat == "SLC"} {
        if {$AIRSARProcessor == "new"} {
            set config "true"
            }
        }
    }
if {$ActiveImportData == "CONVAIR"} {  set config "true" }
if {$ActiveImportData == "EMISAR"} {
    if {$EMISARDataFormat == "S2"} {  set config "true" }
    }
if {$ActiveImportData == "ESAR"} { set config "true" }
if {$ActiveImportData == "FSAR"} { set config "true" }
if {$ActiveImportData == "PISAR"} {
    if {$PISARDataFormat == "MGPSSC"} { set config "true" }
    if {$PISARDataFormat == "MGPC"} { set config "true" }
    }
if {$ActiveImportData == "SETHI"} { set config "true" }
if {$ActiveImportData == "UAVSAR"} { set config "true" }

if {$config == "true"} {set PSPSymmetrisation 0}} \
        -text {[ T4 ]} -value T4 -variable PSPImportOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd100" "Radiobutton233_5" vTcl:WidgetProc "Toplevel233" 1
    pack $site_6_0.cpd99 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 20 \
        -side left 
    pack $site_6_0.cpd100 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 20 \
        -side left 
    frame $site_5_0.fra95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra95" "Frame22" vTcl:WidgetProc "Toplevel233" 1
    set site_6_0 $site_5_0.fra95
    radiobutton $site_6_0.cpd101 \
        \
        -command {global PSPImportOutputSubDir

set PSPImportOutputSubDir "C2"} \
        -text {[ C2 ]} -value C2 -variable PSPImportOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd101" "Radiobutton233_6" vTcl:WidgetProc "Toplevel233" 1
    radiobutton $site_6_0.cpd102 \
        \
        -command {global PSPImportOutputSubDir
global ActiveImportData
global PSPImportOutputFormat PSPSymmetrisation
global RawBinaryDataFormat RawBinaryDataType
global EMISARDataFormat PISARDataFormat
global AIRSARDataFormat AIRSARProcessor UAVSARDataFormat
global RADARSAT2DataFormat SIRCDataFormat ALOSDataFormat CSKDataFormat
global TERRASARXDataFormat TERRASARXDataLevel RISATDataFormat GF3DataFormat

set PSPImportOutputSubDir "C3"

set config "false"
if {$ActiveImportData == "RAWBINARYDATA"} {
    if {$RawBinaryDataFormat == "S2"} { set config "true" }
    if {$RawBinaryDataFormat == "T4"} { set config "true" }
    if {$RawBinaryDataFormat == "C4"} { set config "true" }
    }
if {$ActiveImportData == "GF3"} {
    if {$GF3DataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "RADARSAT2"} {
    if {$RADARSAT2DataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "TERRASARX"} {
    if {$TERRASARXDataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "ALOS"} {
    if {$ALOSDataFormat == "quad1.1"} {  set config "true" }
    if {$ALOSDataFormat == "quad1.1vex"} {  set config "true" }
    }
if {$ActiveImportData == "ALOS2"} {
    if {$ALOSDataFormat == "quad1.1"} {  set config "true" }
    }
if {$ActiveImportData == "RISAT"} {
    if {$RISATDataFormat == "quad1.1"} {  set config "true" }
    }
if {$ActiveImportData == "SIRC"} {
    if {$SIRCDataFormat == "SLCquad"} {  set config "true" }
    }
if {$ActiveImportData == "AIRSAR"} {
    if {$AIRSARDataFormat == "SLC"} {
        if {$AIRSARProcessor == "new"} {
            set config "true"
            }
        }
    }
if {$ActiveImportData == "CONVAIR"} {  set config "true" }
if {$ActiveImportData == "EMISAR"} {
    if {$EMISARDataFormat == "S2"} {  set config "true" }
    }
if {$ActiveImportData == "ESAR"} { set config "true" }
if {$ActiveImportData == "FSAR"} { set config "true" }
if {$ActiveImportData == "PISAR"} {
    if {$PISARDataFormat == "MGPSSC"} { set config "true" }
    if {$PISARDataFormat == "MGPC"} { set config "true" }
    }
if {$ActiveImportData == "SETHI"} { set config "true" }
if {$ActiveImportData == "UAVSAR"} { set config "true" }

if {$config == "true"} {set PSPSymmetrisation 1}} \
        -text {[ C3 ]} -value C3 -variable PSPImportOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd102" "Radiobutton233_7" vTcl:WidgetProc "Toplevel233" 1
    radiobutton $site_6_0.cpd103 \
        \
        -command {global PSPImportOutputSubDir
global ActiveImportData
global PSPImportOutputFormat PSPSymmetrisation
global RawBinaryDataFormat RawBinaryDataType
global EMISARDataFormat PISARDataFormat
global AIRSARDataFormat AIRSARProcessor UAVSARDataFormat
global RADARSAT2DataFormat SIRCDataFormat ALOSDataFormat CSKDataFormat
global TERRASARXDataFormat TERRASARXDataLevel RISATDataFormat GF3DataFormat

set PSPImportOutputSubDir "C4"

set config "false"
if {$ActiveImportData == "RAWBINARYDATA"} {
    if {$RawBinaryDataFormat == "S2"} { set config "true" }
    if {$RawBinaryDataFormat == "T4"} { set config "true" }
    if {$RawBinaryDataFormat == "C4"} { set config "true" }
    }
if {$ActiveImportData == "GF3"} {
    if {$GF3DataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "RADARSAT2"} {
    if {$RADARSAT2DataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "TERRASARX"} {
    if {$TERRASARXDataFormat == "quad"} {  set config "true" }
    }
if {$ActiveImportData == "ALOS"} {
    if {$ALOSDataFormat == "quad1.1"} {  set config "true" }
    if {$ALOSDataFormat == "quad1.1vex"} {  set config "true" }
    }
if {$ActiveImportData == "ALOS2"} {
    if {$ALOSDataFormat == "quad1.1"} {  set config "true" }
    }
if {$ActiveImportData == "RISAT"} {
    if {$RISATDataFormat == "quad1.1"} {  set config "true" }
    }
if {$ActiveImportData == "SIRC"} {
    if {$SIRCDataFormat == "SLCquad"} {  set config "true" }
    }
if {$ActiveImportData == "AIRSAR"} {
    if {$AIRSARDataFormat == "SLC"} {
        if {$AIRSARProcessor == "new"} {
            set config "true"
            }
        }
    }
if {$ActiveImportData == "CONVAIR"} {  set config "true" }
if {$ActiveImportData == "EMISAR"} {
    if {$EMISARDataFormat == "S2"} {  set config "true" }
    }
if {$ActiveImportData == "ESAR"} { set config "true" }
if {$ActiveImportData == "FSAR"} { set config "true" }
if {$ActiveImportData == "PISAR"} {
    if {$PISARDataFormat == "MGPSSC"} { set config "true" }
    if {$PISARDataFormat == "MGPC"} { set config "true" }
    }
if {$ActiveImportData == "SETHI"} { set config "true" }
if {$ActiveImportData == "UAVSAR"} { set config "true" }

if {$config == "true"} {set PSPSymmetrisation 0}} \
        -text {[ C4 ]} -value C4 -variable PSPImportOutputFormat 
    vTcl:DefineAlias "$site_6_0.cpd103" "Radiobutton233_8" vTcl:WidgetProc "Toplevel233" 1
    pack $site_6_0.cpd101 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 20 \
        -side left 
    pack $site_6_0.cpd102 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 20 \
        -side left 
    pack $site_6_0.cpd103 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 48 \
        -side left 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.fra94 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.fra95 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra83 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra41 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame20" vTcl:WidgetProc "Toplevel233" 1
    set site_3_0 $top.fra41
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir ActiveImportData OpenDirFile DataFormatActive 
global RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global PSPImportDirInput PSPImportDirOutput PSPImportOutputDir PSPImportOutputSubDir
global PSPImportExtractFonction PSPImportOutputFormat PSPSymmetrisation
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global MultiLookCol MultiLookRow SubSampCol SubSampRow MultiLookSubSamp
global OffsetLig OffsetCol FinalNlig FinalNcol TMPDirectory DirOutputPSPImport
global ProgressLine ConfigFile PolarCase PolarType TMPMemoryAllocError MaskCmd PSPViewGimpBMP

global FileInputHH FileInputHV FileInputVH FileInputVV FileInputPISAR FileInputSIRC
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6 FileInput7 FileInput8
global FileInput9 FileInput10 FileInput11 FileInput12 FileInput13 FileInput14 FileInput15 FileInput16
global AirsarHeader EsarHeader ESARDataFormat FsarHeader FSARDataFormat UAVSARDataFormat
global FSARMaskFile FSARIncAngFile
global PISARDataFormat EMISARDataFormat SIRCDataFormat ALOSDataFormat
global TERRASARXDataFormat TERRASARXDataLevel RISATDataFormat SENTINEL1DataFormat
global IEEEFormat PISAROffset UAVSARAnnotationFile UAVSARFileDEM SENTINEL1Burst SENTINEL1FUD
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {$PSPImportOutputFormat == ""} {
    set ErrorMessage "DEFINE THE OUTPUT FORMAT FIRST"
    set VarError ""
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
} else {
set PSPImportDirOutput $PSPImportOutputDir
if {$PSPImportOutputSubDir != ""} {append PSPImportDirOutput "/$PSPImportOutputSubDir"}
            
    #####################################################################
    #Create Directory
    set PSPImportDirOutput [PSPCreateDirectory $PSPImportDirOutput $PSPImportOutputDir $PSPImportOutputFormat] 
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$PSPImportExtractFonction == "Full"} {TestVar 4}
        if {$PSPImportExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Col"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampCol; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Row"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampRow; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$PSPImportExtractFonction == "MultiLook"} {
            set TestVarName(4) "Multi Look Col"; set TestVarType(4) "int"; set TestVarValue(4) $MultiLookCol; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Multi Look Row"; set TestVarType(5) "int"; set TestVarValue(5) $MultiLookRow; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {
            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            set Fonction $ActiveProgram; append Fonction " Convert Input Data File"
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update

            if {$PSPImportExtractFonction == "Full"} { set MultiLookSubSamp " -nlr 1 -nlc 1 -ssr 1 -ssc 1 " }
            if {$PSPImportExtractFonction == "SubSamp"} { set MultiLookSubSamp " -nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol " }
            if {$PSPImportExtractFonction == "MultiLook"} { set MultiLookSubSamp " -nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1 " }

            append MultiLookSubSamp "-mem 2000 -errf \x22$TMPMemoryAllocError\x22 "
            #append MultiLookSubSamp " -errf \x22$TMPMemoryAllocError\x22 "

            if {$ActiveImportData == "RAWBINARYDATA"} { ExtractRAWBINARYDATA } 
            if {$ActiveImportData == "ALOS"} { ExtractALOS } 
            if {$ActiveImportData == "ALOS2"} { ExtractALOS2 } 
            if {$ActiveImportData == "CSK"} { ExtractCSK } 
            if {$ActiveImportData == "GF3"} { ExtractGF3 } 
            if {$ActiveImportData == "RADARSAT2"} { ExtractRADARSAT2 } 
            if {$ActiveImportData == "RISAT"} { ExtractRISAT } 
            if {$ActiveImportData == "SENTINEL1"} { ExtractSENTINEL1 } 
            if {$ActiveImportData == "TERRASARX"} { ExtractTERRASARX } 
            if {$ActiveImportData == "SIRC"} { ExtractSIRC } 
            if {$ActiveImportData == "AIRSAR"} { ExtractAIRSAR } 
            if {$ActiveImportData == "CONVAIR"} { ExtractCONVAIR }  
            if {$ActiveImportData == "EMISAR"} { ExtractEMISAR } 
            if {$ActiveImportData == "ESAR"} { ExtractESAR } 
            if {$ActiveImportData == "FSAR"} { ExtractFSAR } 
            if {$ActiveImportData == "PISAR"} { ExtractPISAR } 
            if {$ActiveImportData == "SETHI"} { ExtractSETHI } 
            if {$ActiveImportData == "UAVSAR"} { ExtractUAVSAR } 
    
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            if {$ActiveImportData == "UAVSAR"} {
                if {$UAVSARDataFormat == "GRD"} {
                    if {$UAVSARFileDEM != ""} {
                        set Fonction "Creation of the UAVSAR DEM File :"
                        set Fonction2 ""    
                        set ProgressLine "0"
                        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                        update
                        TextEditorRunTrace "Process The Function Soft/bin/data_import/uavsar_convert_dem.exe" "k"
                        TextEditorRunTrace "Arguments: -hf \x22$UAVSARAnnotationFile\x22 -if \x22$UAVSARFileDEM\x22 -od \x22$PSPImportDirOutput\x22 -inr $NligFullSize -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MultiLookSubSamp" "k"
                        set f [ open "| Soft/bin/data_import/uavsar_convert_dem.exe -hf \x22$UAVSARAnnotationFile\x22 -if \x22$UAVSARFileDEM\x22 -od \x22$PSPImportDirOutput\x22 -inr $NligFullSize -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MultiLookSubSamp" r]
                        PsPprogressBar $f
                        TextEditorRunTrace "Check RunTime Errors" "r"
                        CheckRunTimeError
                        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                        }
                    }
               }

            set ConfigFile "$PSPImportDirOutput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                if {$ActiveImportData == "SENTINEL1"} {
                    if {$SENTINEL1Burst != "ALL"} {
                        if {$SENTINEL1FUD == 1} {
                            set PSPImportDirOutput $DirOutputPSPImport
                            Sentinel1_FlipUpDown $TMPDirectory $PSPImportDirOutput $PSPImportOutputFormat $NligFullSize $NcolFullSize
                            }
                        }
                    }          
            
                set DataFormatActive $PSPImportOutputFormat
                if {$PSPImportOutputFormat == "S2"} {
                    EnviWriteConfigS $PSPImportDirOutput $NligFullSize $NcolFullSize
                    }
                if {$PSPImportOutputFormat == "SPP"} {
                    EnviWriteConfigS $PSPImportDirOutput $NligFullSize $NcolFullSize
                    }
                if {$PSPImportOutputFormat == "IPP"} {
                    EnviWriteConfigI $PSPImportDirOutput $NligFullSize $NcolFullSize
                    }
                if {$PSPImportOutputFormat == "T3"} {
                    EnviWriteConfigT $PSPImportDirOutput $NligFullSize $NcolFullSize
                    }
                if {$PSPImportOutputFormat == "T4"} {
                    EnviWriteConfigT $PSPImportDirOutput $NligFullSize $NcolFullSize
                    }
                if {$PSPImportOutputFormat == "C2"} {
                    EnviWriteConfigC $PSPImportDirOutput $NligFullSize $NcolFullSize
                    }
                if {$PSPImportOutputFormat == "C3"} {
                    EnviWriteConfigC $PSPImportDirOutput $NligFullSize $NcolFullSize
                    }
                if {$PSPImportOutputFormat == "C4"} {
                    EnviWriteConfigC $PSPImportDirOutput $NligFullSize $NcolFullSize
                    }

                set MaskCmd ""
                set MaskFile "$PSPImportDirOutput/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                if {$PSPImportOutputFormat == "S2"} { RGB_S2 }
                if {$PSPImportOutputFormat == "SPP"} { RGB_SPP }
                if {$PSPImportOutputFormat == "IPP"} {
                    if {$ActiveImportData == "ALOS"} {  
                        if {$ALOSDataFormat == "dual1.5"} { RGB_IPP }
                        if {$ALOSDataFormat == "quad1.5"} { RGB_I2 }
                        } else  {
                        RGB_IPP
                        }
                    }
                if {$PSPImportOutputFormat == "T3"} { RGB_T3 }
                if {$PSPImportOutputFormat == "T4"} { RGB_T3 }
                if {$PSPImportOutputFormat == "C2"} { RGB_C2 }
                if {$PSPImportOutputFormat == "C3"} { RGB_C3 }
                if {$PSPImportOutputFormat == "C4"} { RGB_C4 }

                if {$ActiveImportData == "UAVSAR"} {
                    set fichier "$PSPImportDirOutput/dem.bin"
                    if [file exists $fichier] {
                        EnviWriteConfig $fichier $NligFullSize $NcolFullSize 4
                        set fichierbmp "$PSPImportDirOutput/dem.bmp"
                        set ProgressLine "0"
                        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                        update
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp_file.exe" "k"
                        TextEditorRunTrace "Arguments: -if \x22$fichier\x22 -of \x22$fichierbmp\x22 -ift float -oft real -clm gray -nc $NcolFullSize -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mm 1 -min 0 -max 0 $MaskCmd" "k"
                        set f [ open "| Soft/bin/bmp_process/create_bmp_file.exe -if \x22$fichier\x22 -of \x22$fichierbmp\x22 -ift float -oft real -clm gray -nc $NcolFullSize -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mm 1 -min 0 -max 0 $MaskCmd" r]
                        PsPprogressBar $f
                        TextEditorRunTrace "Check RunTime Errors" "r"
                        CheckRunTimeError
                        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $fichierbmp }
                        }
                    } 

                if {$ActiveImportData == "FSAR"} {
                    set fichier "$PSPImportDirOutput/incidence_angle.bin"
                    if [file exists $fichier] {
                        EnviWriteConfig $fichier $NligFullSize $NcolFullSize 4
                        }
                    } 

                set DataDir $PSPImportOutputDir
                MenuOn
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }
    
            Window hide $widget(Toplevel233); TextEditorRunTrace "Close Window Extract Data" "b"
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel233); TextEditorRunTrace "Close Window Extract Data" "b"}
        }
}
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel233" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PSP_Extract_Data.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel233" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel233); TextEditorRunTrace "Close Window Extract Data" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel233" 1
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
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.can73 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra27 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra96 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit80 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra41 \
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
Window show .top233

main $argc $argv
