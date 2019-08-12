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
    set base .top504
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
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
        array set save {-_tooltip 1 -image 1 -padx 1 -pady 1 -relief 1 -state 1 -text 1}
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
    namespace eval ::widgets::$site_5_0.cpd66 {
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
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
    namespace eval ::widgets::$base.cpd70 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd70 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra83
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd66
    namespace eval ::widgets::$site_7_0.cpd70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd67
    namespace eval ::widgets::$site_7_0.cpd70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd68
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd66
    namespace eval ::widgets::$site_7_0.cpd70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd67
    namespace eval ::widgets::$site_7_0.cpd70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd69
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd66
    namespace eval ::widgets::$site_7_0.cpd70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd67
    namespace eval ::widgets::$site_7_0.cpd70 {
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
            vTclWindow.top504
            MultConvertRGB_SPP
            MultConvertDATA
            MultConvertRGB_C2
            MultConvertRGB_S2
            MultConvertRGB_T3
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
## Procedure:  MultConvertRGB_SPP

proc ::MultConvertRGB_SPP {} {
global ConvertDirOutput BMPDirInput PolarType
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError 
   
set RGBDirInput $ConvertDirOutput
set RGBDirOutput $ConvertDirOutput
set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
set Channel1 ""
set Channel2 ""
if {$PolarType == "pp1"} {set Channel1 "s11"; set Channel2 "s21"}
if {$PolarType == "pp2"} {set Channel1 "s22"; set Channel2 "s12"}
if {$PolarType == "pp3"} {set Channel1 "s11"; set Channel2 "s22"}
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
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

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
## Procedure:  MultConvertDATA

proc ::MultConvertDATA {} {
global ConvertFonction ConvertOutputFormat ConvertOutputFormatPP
global ConvertDirInput ConvertDirOutput
global ConvertExtractFonction ConvertOutputFormat ConvertSymmetrisation
global NcolFullSize
global MultiLookRow MultiLookCol SubSampRow SubSampCol
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine TMPMemoryAllocError

set ExtractFunction "Soft/bin/data_convert/data_convert.exe"

TextEditorRunTrace "Process The Function $ExtractFunction" "k"

set ExtractCommand "-id \x22$ConvertDirInput\x22 -od \x22$ConvertDirOutput\x22 -iodf $ConvertOutputFormat -sym $ConvertSymmetrisation "
append ExtractCommand "-ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol "
if {$ConvertExtractFonction == "Full"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr 1 -ssc 1"}
if {$ConvertExtractFonction == "SubSamp"} {append ExtractCommand "-nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol"}
if {$ConvertExtractFonction == "MultiLook"} {append ExtractCommand "-nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1"}

TextEditorRunTrace "Arguments: $ExtractCommand  -errf \x22$TMPMemoryAllocError\x22" "k"
set f [ open "| $ExtractFunction $ExtractCommand  -errf \x22$TMPMemoryAllocError\x22" r]
PsPprogressBar $f
}
#############################################################################
## Procedure:  MultConvertRGB_C2

proc ::MultConvertRGB_C2 {} {
global ConvertDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError 
   
set RGBDirInput $ConvertDirOutput
set RGBDirOutput $ConvertDirOutput
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
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
    set f [ open "| Soft/bin/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    set BMPDirInput $RGBDirOutput
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  MultConvertRGB_S2

proc ::MultConvertRGB_S2 {} {
global ConvertDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError 
   
set RGBDirInput $ConvertDirOutput
set RGBDirOutput $ConvertDirOutput
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
    set MaskCmd ""
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

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
## Procedure:  MultConvertRGB_T3

proc ::MultConvertRGB_T3 {} {
global ConvertDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError 
   
set RGBDirInput $ConvertDirOutput
set RGBDirOutput $ConvertDirOutput
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
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

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

proc vTclWindow.top504 {base} {
    if {$base == ""} {
        set base .top504
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
    wm geometry $top 500x360+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data File Conversion"
    vTcl:DefineAlias "$top" "Toplevel504" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel504" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel504" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ConvertDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel504" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel504" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel504" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel504" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable ConvertOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel504" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel504" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab75 \
        -text {/ } 
    vTcl:DefineAlias "$site_6_0.lab75" "Label1" vTcl:WidgetProc "Toplevel504" 1
    entry $site_6_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ConvertOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd77" "Entry1" vTcl:WidgetProc "Toplevel504" 1
    pack $site_6_0.lab75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame12" vTcl:WidgetProc "Toplevel504" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd95 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -state disabled -text button 
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
    vTcl:DefineAlias "$top.fra27" "Frame9" vTcl:WidgetProc "Toplevel504" 1
    set site_3_0 $top.fra27
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel504" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel504" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel504" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel504" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel504" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel504" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel504" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel504" 1
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
    vTcl:DefineAlias "$top.fra96" "Frame3" vTcl:WidgetProc "Toplevel504" 1
    set site_3_0 $top.fra96
    frame $site_3_0.fra97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra97" "Frame4" vTcl:WidgetProc "Toplevel504" 1
    set site_4_0 $site_3_0.fra97
    frame $site_4_0.fra102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra102" "Frame6" vTcl:WidgetProc "Toplevel504" 1
    set site_5_0 $site_4_0.fra102
    radiobutton $site_5_0.cpd105 \
        \
        -command {global MultiLookRow MultiLookCol SubSampRow SubSampCol DataFormatActive
global ConvertOutputDirExt ConvertOutputDir DataDirMult ConvertOutputFormat

set MultiLookRow " "
set MultiLookCol " "
set SubSampRow " "
set SubSampCol " "
$widget(Label504_1) configure -state disable
$widget(Label504_2) configure -state disable
$widget(Label504_3) configure -state disable
$widget(Label504_4) configure -state disable
$widget(Entry504_1) configure -state disable
$widget(Entry504_2) configure -state disable
$widget(Entry504_3) configure -state disable
$widget(Entry504_4) configure -state disable
if {$DataFormatActive == "SPP"} { $widget(Radiobutton504_1) configure -state normal }
if {$DataFormatActive == "S2"} { $widget(Radiobutton504_4) configure -state normal }
set ConvertOutputDirExt "_FUL"
if {$ConvertOutputFormat == "S2T3"} { set ConvertOutputDirExt ""}
if {$ConvertOutputFormat == "SPPC2"} { set ConvertOutputDirExt ""}
set ConvertOutputDir $DataDirMult(1)
append ConvertOutputDir $ConvertOutputDirExt} \
        -text {Full Resolution} -value Full -variable ConvertExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd105" "Radiobutton5041" vTcl:WidgetProc "Toplevel504" 1
    pack $site_5_0.cpd105 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.fra103 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra103" "Frame7" vTcl:WidgetProc "Toplevel504" 1
    set site_5_0 $site_4_0.fra103
    radiobutton $site_5_0.cpd66 \
        \
        -command {global MultiLookRow MultiLookCol SubSampRow SubSampCol DataFormatActive
global ConvertOutputDirExt ConvertOutputDir DataDirMult ConvertOutputFormat

set MultiLookRow " "
set MultiLookCol " "
set SubSampRow " ? "
set SubSampCol " ? "
$widget(Label504_1) configure -state normal
$widget(Label504_2) configure -state normal
$widget(Label504_3) configure -state disable
$widget(Label504_4) configure -state disable
$widget(Entry504_1) configure -state normal
$widget(Entry504_2) configure -state normal
$widget(Entry504_3) configure -state disable
$widget(Entry504_4) configure -state disable
if {$DataFormatActive == "SPP"} { $widget(Radiobutton504_1) configure -state disable }
if {$DataFormatActive == "S2"} { $widget(Radiobutton504_4) configure -state normal }
set ConvertOutputDirExt "_SSP"
if {$ConvertOutputFormat == "S2T3"} { set ConvertOutputDirExt ""}
if {$ConvertOutputFormat == "SPPC2"} { set ConvertOutputDirExt ""}
set ConvertOutputDir $DataDirMult(1)
append ConvertOutputDir $ConvertOutputDirExt} \
        -text {Sub Sampling} -value SubSamp -variable ConvertExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd66" "Radiobutton5042" vTcl:WidgetProc "Toplevel504" 1
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.fra104 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra104" "Frame8" vTcl:WidgetProc "Toplevel504" 1
    set site_5_0 $site_4_0.fra104
    radiobutton $site_5_0.cpd107 \
        \
        -command {global MultiLookRow MultiLookCol SubSampRow SubSampCol DataFormatActive
global ConvertOutputDirExt ConvertOutputDir DataDirMult ConvertOutputFormat

set MultiLookRow " ? "
set MultiLookCol " ? "
set SubSampRow " "
set SubSampCol " "
$widget(Label504_1) configure -state disable
$widget(Label504_2) configure -state disable
$widget(Label504_3) configure -state normal
$widget(Label504_4) configure -state normal
$widget(Entry504_1) configure -state disable
$widget(Entry504_2) configure -state disable
$widget(Entry504_3) configure -state normal
$widget(Entry504_4) configure -state normal
if {$DataFormatActive == "SPP"} { $widget(Radiobutton504_1) configure -state disable }
if {$DataFormatActive == "S2"} { $widget(Radiobutton504_4) configure -state disable }
set ConvertOutputDirExt "_MLK"
if {$ConvertOutputFormat == "S2T3"} { set ConvertOutputDirExt ""}
if {$ConvertOutputFormat == "SPPC2"} { set ConvertOutputDirExt ""}
set ConvertOutputDir $DataDirMult(1)
append ConvertOutputDir $ConvertOutputDirExt} \
        -text {Multi Look} -value MultiLook -variable ConvertExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd107" "Radiobutton5043" vTcl:WidgetProc "Toplevel504" 1
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
    vTcl:DefineAlias "$site_3_0.cpd98" "Frame5" vTcl:WidgetProc "Toplevel504" 1
    set site_4_0 $site_3_0.cpd98
    frame $site_4_0.cpd111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd111" "Frame153" vTcl:WidgetProc "Toplevel504" 1
    set site_5_0 $site_4_0.cpd111
    label $site_5_0.lab23 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab23" "Label203" vTcl:WidgetProc "Toplevel504" 1
    label $site_5_0.lab25 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab25" "Label204" vTcl:WidgetProc "Toplevel504" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_4_0.cpd109 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd109" "Frame154" vTcl:WidgetProc "Toplevel504" 1
    set site_5_0 $site_4_0.cpd109
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label504_1" vTcl:WidgetProc "Toplevel504" 1
    entry $site_5_0.ent26 \
        -background white -disabledbackground #ff0000 \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SubSampRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry504_1" vTcl:WidgetProc "Toplevel504" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label504_2" vTcl:WidgetProc "Toplevel504" 1
    entry $site_5_0.ent24 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable SubSampCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry504_2" vTcl:WidgetProc "Toplevel504" 1
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
    vTcl:DefineAlias "$site_4_0.cpd110" "Frame155" vTcl:WidgetProc "Toplevel504" 1
    set site_5_0 $site_4_0.cpd110
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label504_3" vTcl:WidgetProc "Toplevel504" 1
    entry $site_5_0.ent26 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable MultiLookRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry504_3" vTcl:WidgetProc "Toplevel504" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label504_4" vTcl:WidgetProc "Toplevel504" 1
    entry $site_5_0.ent24 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable MultiLookCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry504_4" vTcl:WidgetProc "Toplevel504" 1
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
    frame $top.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame13" vTcl:WidgetProc "Toplevel504" 1
    set site_3_0 $top.cpd77
    label $site_3_0.lab80 \
        -text { Input Data Format   } 
    vTcl:DefineAlias "$site_3_0.lab80" "Label3" vTcl:WidgetProc "Toplevel504" 1
    entry $site_3_0.ent81 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ConvertInputFormat -width 40 
    vTcl:DefineAlias "$site_3_0.ent81" "Entry3" vTcl:WidgetProc "Toplevel504" 1
    pack $site_3_0.lab80 \
        -in $site_3_0 -anchor center -expand 0 -fill none -ipadx 5 -side left 
    pack $site_3_0.ent81 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd70 \
        -text {Output Data Format} 
    vTcl:DefineAlias "$top.cpd70" "TitleFrame3" vTcl:WidgetProc "Toplevel504" 1
    bind $top.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd70 getframe]
    frame $site_4_0.fra83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra83" "Frame16" vTcl:WidgetProc "Toplevel504" 1
    set site_5_0 $site_4_0.fra83
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame17" vTcl:WidgetProc "Toplevel504" 1
    set site_6_0 $site_5_0.cpd75
    frame $site_6_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd66" "Frame19" vTcl:WidgetProc "Toplevel504" 1
    set site_7_0 $site_6_0.cpd66
    radiobutton $site_7_0.cpd70 \
        \
        -command {global ConvertOutputSubDir ConvertOutputFormatPP ConvertExtractFonction
global ConvertOutputDirExt ConvertOutputDir DataDirMult

set ConvertOutputSubDir ""
set ConvertOutputFormatPP " "
if {$ConvertExtractFonction == ""} {set ConvertOutputDirExt "_???"}
if {$ConvertExtractFonction == "Full"} {set ConvertOutputDirExt "_FUL"}
if {$ConvertExtractFonction == "SubSamp"} {set ConvertOutputDirExt "_SSP"}
if {$ConvertExtractFonction == "MultiLook"} {set ConvertOutputDirExt "_MLK"}
set ConvertOutputDir $DataDirMult(1)
append ConvertOutputDir $ConvertOutputDirExt} \
        -text {( SPP ) >> ( SPP )} -value SPP -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_7_0.cpd70" "Radiobutton504_1" vTcl:WidgetProc "Toplevel504" 1
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd67" "Frame21" vTcl:WidgetProc "Toplevel504" 1
    set site_7_0 $site_6_0.cpd67
    radiobutton $site_7_0.cpd70 \
        \
        -command {global ConvertOutputSubDir ConvertOutputFormatPP
global ConvertOutputDirExt ConvertOutputDir DataDirMult

set ConvertOutputSubDir ""
set ConvertOutputFormatPP " "
if {$ConvertExtractFonction == ""} {set ConvertOutputDirExt "_???"}
if {$ConvertExtractFonction == "Full"} {set ConvertOutputDirExt "_FUL"}
if {$ConvertExtractFonction == "SubSamp"} {set ConvertOutputDirExt "_SSP"}
if {$ConvertExtractFonction == "MultiLook"} {set ConvertOutputDirExt "_MLK"}
set ConvertOutputDir $DataDirMult(1)
append ConvertOutputDir $ConvertOutputDirExt} \
        -text {[S2] >> [S2]} -value S2 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_7_0.cpd70" "Radiobutton504_4" vTcl:WidgetProc "Toplevel504" 1
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd67 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame18" vTcl:WidgetProc "Toplevel504" 1
    set site_6_0 $site_5_0.cpd68
    frame $site_6_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd66" "Frame22" vTcl:WidgetProc "Toplevel504" 1
    set site_7_0 $site_6_0.cpd66
    radiobutton $site_7_0.cpd70 \
        \
        -command {global ConvertOutputSubDir ConvertOutputFormatPP
global ConvertOutputDirExt ConvertOutputDir DataDirMult

set ConvertOutputSubDir "C2"
set ConvertOutputFormatPP " "
set ConvertOutputDirExt ""
set ConvertOutputDir $DataDirMult(1)} \
        -text {( SPP ) >> [C2]} -value SPPC2 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_7_0.cpd70" "Radiobutton504_2" vTcl:WidgetProc "Toplevel504" 1
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd67" "Frame23" vTcl:WidgetProc "Toplevel504" 1
    set site_7_0 $site_6_0.cpd67
    radiobutton $site_7_0.cpd70 \
        \
        -command {global ConvertOutputSubDir ConvertOutputFormatPP
global ConvertOutputDirExt ConvertOutputDir DataDirMult

set ConvertOutputSubDir "T3"
set ConvertOutputFormatPP " "
set ConvertOutputDirExt ""
set ConvertOutputDir $DataDirMult(1)} \
        -text {[S2] >> [T3]} -value S2T3 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_7_0.cpd70" "Radiobutton504_5" vTcl:WidgetProc "Toplevel504" 1
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd67 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd69" "Frame24" vTcl:WidgetProc "Toplevel504" 1
    set site_6_0 $site_5_0.cpd69
    frame $site_6_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd66" "Frame25" vTcl:WidgetProc "Toplevel504" 1
    set site_7_0 $site_6_0.cpd66
    radiobutton $site_7_0.cpd70 \
        \
        -command {global ConvertOutputSubDir ConvertOutputFormatPP
global ConvertOutputDirExt ConvertOutputDir DataDirMult

set ConvertOutputSubDir "C2"
set ConvertOutputFormatPP " "
if {$ConvertExtractFonction == ""} {set ConvertOutputDirExt "_???"}
if {$ConvertExtractFonction == "Full"} {set ConvertOutputDirExt "_FUL"}
if {$ConvertExtractFonction == "SubSamp"} {set ConvertOutputDirExt "_SSP"}
if {$ConvertExtractFonction == "MultiLook"} {set ConvertOutputDirExt "_MLK"}
set ConvertOutputDir $DataDirMult(1)
append ConvertOutputDir $ConvertOutputDirExt} \
        -text {[C2] >> [C2]} -value C2 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_7_0.cpd70" "Radiobutton504_3" vTcl:WidgetProc "Toplevel504" 1
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd67" "Frame26" vTcl:WidgetProc "Toplevel504" 1
    set site_7_0 $site_6_0.cpd67
    radiobutton $site_7_0.cpd70 \
        \
        -command {global ConvertOutputSubDir ConvertOutputFormatPP
global ConvertOutputDirExt ConvertOutputDir DataDirMult

set ConvertOutputSubDir "T3"
set ConvertOutputFormatPP " "
if {$ConvertExtractFonction == ""} {set ConvertOutputDirExt "_???"}
if {$ConvertExtractFonction == "Full"} {set ConvertOutputDirExt "_FUL"}
if {$ConvertExtractFonction == "SubSamp"} {set ConvertOutputDirExt "_SSP"}
if {$ConvertExtractFonction == "MultiLook"} {set ConvertOutputDirExt "_MLK"}
set ConvertOutputDir $DataDirMult(1)
append ConvertOutputDir $ConvertOutputDirExt} \
        -text {[T3] >> [T3]} -value T3 -variable ConvertOutputFormat 
    vTcl:DefineAlias "$site_7_0.cpd70" "Radiobutton504_6" vTcl:WidgetProc "Toplevel504" 1
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd67 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra83 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra41 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame20" vTcl:WidgetProc "Toplevel504" 1
    set site_3_0 $top.fra41
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirMult NDataDirMult DataDirMultActive OpenDirFile
global ConvertDirInput ConvertInputSubDir ConvertDirOutput ConvertOutputDir ConvertOutputSubDir
global ConvertFonction ConvertFonctionPP DataFormatActive ConvertOutputDirExt
global ConvertExtractFonction ConvertOutputFormat ConvertSymmetrisation
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global MultiLookRow MultiLookCol SubSampRow SubSampCol
global OffsetLig OffsetCol FinalNlig FinalNcol 
global ProgressLine ConfigFile PolarCase PolarType
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {$ConvertOutputFormat == ""} {
    set ErrorMessage "DEFINE THE OUTPUT FORMAT FIRST"
    set VarError ""
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
} else {
set ConvertDirOutput $ConvertOutputDir
if {$ConvertOutputSubDir != ""} {append ConvertDirOutput "/$ConvertOutputSubDir"}
            
if {$ConvertDirOutput == $ConvertDirInput} {
    set ErrorMessage "CONFLICT NAME BETWEEN INPUT DIRECTORY AND OUTPUT DIRECTORY"
    set VarError ""
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
} else {
          
    #####################################################################
    #Create Directory
    set ConvertDirOutput [PSPCreateDirectory $ConvertDirOutput $ConvertOutputDir $ConvertOutputFormat]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$ConvertExtractFonction == "Full"} {TestVar 4}
        if {$ConvertExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Row"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Col"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$ConvertExtractFonction == "MultiLook"} {
            set TestVarName(4) "Multi Look Row"; set TestVarType(4) "int"; set TestVarValue(4) $MultiLookRow; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Multi Look Col"; set TestVarType(5) "int"; set TestVarValue(5) $MultiLookCol; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {

            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            for {set ii 1} {$ii <= $NDataDirMult} {incr ii} {
                set ConvertDirInput $DataDirMult($ii)
                if {$ConvertInputSubDir != ""} {append ConvertDirInput "/$ConvertInputSubDir"}
                set ConvertOutputDir $DataDirMult($ii); append ConvertOutputDir $ConvertOutputDirExt
                set ConvertDirOutput $ConvertOutputDir
                if {$ConvertOutputSubDir != ""} {append ConvertDirOutput "/$ConvertOutputSubDir"}

                #Create Directory
                set ConvertDirOutput [PSPCreateDirectoryMult $ConvertDirOutput $ConvertDirOutput $ConvertOutputFormat]
    
                set Fonction2 ""
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                MultConvertDATA 
        
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
        
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                }

            for {set ii 1} {$ii <= $NDataDirMult} {incr ii} {
                set ConvertDirInput $DataDirMult($ii)
                if {$ConvertInputSubDir != ""} {append ConvertDirInput "/$ConvertInputSubDir"}
                set ConvertOutputDir $DataDirMult($ii); append ConvertOutputDir $ConvertOutputDirExt
                set ConvertDirOutput $ConvertOutputDir
                if {$ConvertOutputSubDir != ""} {append ConvertDirOutput "/$ConvertOutputSubDir"}

                MapInfoWriteConfig $ConvertDirOutput

                set ConfigFile "$ConvertDirOutput/config.txt"
                set ErrorMessage ""
                LoadConfig
                if {"$ErrorMessage" == ""} {
                    if {$ConvertOutputFormat == "SPP"} {set DataFormatActive "SPP"}
                    if {$ConvertOutputFormat == "SPPC2"} {set DataFormatActive "C2"}
                    if {$ConvertOutputFormat == "C2"} {set DataFormatActive "C2"}
                    if {$ConvertOutputFormat == "S2"} {set DataFormatActive "S2"}
                    if {$ConvertOutputFormat == "S2T3"} {set DataFormatActive "T3"}
                    if {$ConvertOutputFormat == "T3"} {set DataFormatActive "T3"}

                    if {$DataFormatActive == "S2"} {
                        EnviWriteConfigS $ConvertDirOutput $NligFullSize $NcolFullSize
                        MultConvertRGB_S2
                        }
                    if {$DataFormatActive == "T3"} {
                        EnviWriteConfigT $ConvertDirOutput $NligFullSize $NcolFullSize
                        MultConvertRGB_T3
                        }
                    if {$DataFormatActive == "SPP"} {
                        EnviWriteConfigS $ConvertDirOutput $NligFullSize $NcolFullSize
                        MultConvertRGB_SPP
                        }
                    if {$DataFormatActive == "C2"} {
                        EnviWriteConfigC $ConvertDirOutput $NligFullSize $NcolFullSize
                        MultConvertRGB_C2
                        }
                    } else {
                    append ErrorMessage " -> An ERROR occured during the Data Extraction"
                    set VarError ""
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    set ErrorMessage ""
                    }
    
                set DataDirMult($ii) $ConvertOutputDir
                }
            WriteConfigMult
            set DataDirMultActive $DataDirMult(1)
            MenuOn
            Window hide $widget(Toplevel504); TextEditorRunTrace "Close Window Data File Convert Mult" "b"
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel504); TextEditorRunTrace "Close Window Data File Convert Mult" "b"}
        }
}
}
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel504" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DataFileConvertMult.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel504" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel504); TextEditorRunTrace "Close Window Convert Data" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel504" 1
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
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra27 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra96 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd70 \
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
Window show .top504

main $argc $argv
