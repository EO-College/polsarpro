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

        {{[file join . GUI Images AIRSAR.gif]} {user image} user {}}
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
    set base .top251
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab71 {
        array set save {-image 1 -text 1}
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
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
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
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd110 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd110
    namespace eval ::widgets::$site_5_0.lab25 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent26 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab23 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent24 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad73 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra89 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra89
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd90
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd90
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd93
    namespace eval ::widgets::$site_5_0.cpd90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd90
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-text 1 -variable 1}
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
    namespace eval ::widgets::$base.m72 {
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
            vTclWindow.top251
            RGB_C3
            RGB_T3
            TOPSARHeader
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
## Procedure:  RGB_C3

proc ::RGB_C3 {} {
global EOSIDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError 
   
set RGBDirInput $EOSIDirOutput
set RGBDirOutput $EOSIDirOutput
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
    set MaskDir $RGBDirInput
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

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
## Procedure:  RGB_T3

proc ::RGB_T3 {} {
global EOSIDirOutput BMPDirInput
global VarError ErrorMessage Fonction Fonction2
global NligFullSize NcolFullSize PSPViewGimpBMP
global ProgressLine TMPMemoryAllocError 
   
set RGBDirInput $EOSIDirOutput
set RGBDirOutput $EOSIDirOutput
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
## Procedure:  TOPSARHeader

proc ::TOPSARHeader {TopsarFile} {
global TMPTopsarConfig TopsarHeader TopsarNlig TopsarNcol

DeleteFile $TMPTopsarConfig

TextEditorRunTrace "Process The Function Soft/bin/data_import/topsar_header.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$TopsarFile\x22 -of \x22$TMPTopsarConfig\x22" "k"
set f [ open "| Soft/bin/data_import/topsar_header.exe -if \x22$TopsarFile\x22 -of \x22$TMPTopsarConfig\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
    
set TopsarNlig 0
set TopsarNcol 0
set TopsarHeader "no"
set ConfigFile $TMPTopsarConfig
set ErrorMessage ""
WaitUntilCreated $ConfigFile
if [file exists $ConfigFile] {
    set f [open $ConfigFile r]
    gets $f tmp
    if {$tmp == "HEADER_OK"} {
        gets $f tmp
        gets $f TopsarNlig
        gets $f tmp
        gets $f tmp
        gets $f TopsarNcol
        close $f
        set TopsarHeader "ok"
        } else {
        gets $f tmp
        close $f
        set ErrorMessage "HEADER CONFIGURATION ERROR"
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set TopsarHeader "no"
        }            
    } else {
    set ErrorMessage "NO HEADER FILE"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set TopsarHeader "no"
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

proc vTclWindow.top251 {base} {
    if {$base == ""} {
        set base .top251
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m72" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x490+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "TOPSAR Extract Data"
    vTcl:DefineAlias "$top" "Toplevel251" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab71 \
        -image [vTcl:image:get_image [file join . GUI Images AIRSAR.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab71" "Label2" vTcl:WidgetProc "Toplevel251" 1
    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel251" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel251" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable EOSIDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel251" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel251" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd86 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd86" "Button34" vTcl:WidgetProc "Toplevel251" 1
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel251" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable EOSIOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel251" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel251" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab75 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab75" "Label1" vTcl:WidgetProc "Toplevel251" 1
    entry $site_6_0.cpd77 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable EOSIOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd77" "Entry1" vTcl:WidgetProc "Toplevel251" 1
    pack $site_6_0.lab75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame12" vTcl:WidgetProc "Toplevel251" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd95 \
        \
        -command {global DirName DataDir EOSIOutputDir EOSIOutputDirBis EOSIOutputSubDir
global VarWarning WarningMessage WarningMessage2

set EOSIOutputDirTmp $EOSIOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set EOSIOutputDir $DirName
        set EOSIOutputDirBis $EOSIOutputDir
        set EOSIExtractFonction "Full"
        set EOSIConvertMLKName 0
        set MultiLookCol " "
        set MultiLookRow " "
        set SubSampCol " "
        set SubSampRow " "
        $widget(Label251_1) configure -state disable
        $widget(Label251_2) configure -state disable
        $widget(Label251_3) configure -state disable
        $widget(Label251_4) configure -state disable
        $widget(Entry251_1) configure -state disable
        $widget(Entry251_2) configure -state disable
        $widget(Entry251_3) configure -state disable
        $widget(Entry251_4) configure -state disable
        } else {
        set EOSIOutputDir $EOSIOutputDirTmp
        set EOSIOutputDirBis $EOSIOutputDir
        }
    } else {
    set EOSIOutputDir $EOSIOutputDirTmp
    set EOSIOutputDirBis $EOSIOutputDir
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
    vTcl:DefineAlias "$top.fra27" "Frame9" vTcl:WidgetProc "Toplevel251" 1
    set site_3_0 $top.fra27
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel251" 1
    entry $site_3_0.ent58 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel251" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel251" 1
    entry $site_3_0.ent60 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel251" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel251" 1
    entry $site_3_0.ent62 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel251" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel251" 1
    entry $site_3_0.ent64 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel251" 1
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
    vTcl:DefineAlias "$top.fra96" "Frame3" vTcl:WidgetProc "Toplevel251" 1
    set site_3_0 $top.fra96
    frame $site_3_0.fra97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra97" "Frame4" vTcl:WidgetProc "Toplevel251" 1
    set site_4_0 $site_3_0.fra97
    frame $site_4_0.fra102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra102" "Frame6" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.fra102
    radiobutton $site_5_0.cpd105 \
        \
        -command {global MultiLookCol MultiLookRow SubSampCol SubSampRow

set MultiLookCol " "
set MultiLookRow " "
set SubSampCol " "
set SubSampRow " "
$widget(Label251_1) configure -state disable
$widget(Label251_2) configure -state disable
$widget(Label251_3) configure -state disable
$widget(Label251_4) configure -state disable
$widget(Entry251_1) configure -state disable
$widget(Entry251_2) configure -state disable
$widget(Entry251_3) configure -state disable
$widget(Entry251_4) configure -state disable} \
        -text {Full Resolution} -value Full -variable EOSIExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd105" "Radiobutton4" vTcl:WidgetProc "Toplevel251" 1
    pack $site_5_0.cpd105 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.fra103 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra103" "Frame7" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.fra103
    radiobutton $site_5_0.cpd106 \
        \
        -command {global MultiLookCol MultiLookRow SubSampCol SubSampRow

set MultiLookCol " "
set MultiLookRow " "
set SubSampCol " ? "
set SubSampRow " ? "
$widget(Label251_1) configure -state normal
$widget(Label251_2) configure -state normal
$widget(Label251_3) configure -state disable
$widget(Label251_4) configure -state disable
$widget(Entry251_1) configure -state normal
$widget(Entry251_2) configure -state normal
$widget(Entry251_3) configure -state disable
$widget(Entry251_4) configure -state disable} \
        -text {Sub Sampling} -value SubSamp -variable EOSIExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd106" "Radiobutton5" vTcl:WidgetProc "Toplevel251" 1
    pack $site_5_0.cpd106 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    frame $site_4_0.fra104 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra104" "Frame8" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.fra104
    radiobutton $site_5_0.cpd107 \
        \
        -command {global MultiLookCol MultiLookRow SubSampCol SubSampRow

set MultiLookCol " ? "
set MultiLookRow " ? "
set SubSampCol " "
set SubSampRow " "
$widget(Label251_1) configure -state disable
$widget(Label251_2) configure -state disable
$widget(Label251_3) configure -state normal
$widget(Label251_4) configure -state normal
$widget(Entry251_1) configure -state disable
$widget(Entry251_2) configure -state disable
$widget(Entry251_3) configure -state normal
$widget(Entry251_4) configure -state normal} \
        -text {Multi Look} -value MultiLook -variable EOSIExtractFonction 
    vTcl:DefineAlias "$site_5_0.cpd107" "Radiobutton6" vTcl:WidgetProc "Toplevel251" 1
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
    vTcl:DefineAlias "$site_3_0.cpd98" "Frame5" vTcl:WidgetProc "Toplevel251" 1
    set site_4_0 $site_3_0.cpd98
    frame $site_4_0.cpd111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd111" "Frame153" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.cpd111
    label $site_5_0.lab23 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab23" "Label203" vTcl:WidgetProc "Toplevel251" 1
    label $site_5_0.lab25 \
        -padx 1 
    vTcl:DefineAlias "$site_5_0.lab25" "Label204" vTcl:WidgetProc "Toplevel251" 1
    pack $site_5_0.lab23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.lab25 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $site_4_0.cpd109 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd109" "Frame154" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.cpd109
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label251_2" vTcl:WidgetProc "Toplevel251" 1
    entry $site_5_0.ent26 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubSampRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry251_2" vTcl:WidgetProc "Toplevel251" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label251_1" vTcl:WidgetProc "Toplevel251" 1
    entry $site_5_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable SubSampCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry251_1" vTcl:WidgetProc "Toplevel251" 1
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
    vTcl:DefineAlias "$site_4_0.cpd110" "Frame155" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.cpd110
    label $site_5_0.lab25 \
        -padx 1 -text Row 
    vTcl:DefineAlias "$site_5_0.lab25" "Label251_4" vTcl:WidgetProc "Toplevel251" 1
    entry $site_5_0.ent26 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MultiLookRow -width 7 
    vTcl:DefineAlias "$site_5_0.ent26" "Entry251_4" vTcl:WidgetProc "Toplevel251" 1
    label $site_5_0.lab23 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab23" "Label251_3" vTcl:WidgetProc "Toplevel251" 1
    entry $site_5_0.ent24 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MultiLookCol -width 7 
    vTcl:DefineAlias "$site_5_0.ent24" "Entry251_3" vTcl:WidgetProc "Toplevel251" 1
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
    TitleFrame $top.tit72 \
        -ipad 2 -text {Output Data Format} 
    vTcl:DefineAlias "$top.tit72" "TitleFrame1" vTcl:WidgetProc "Toplevel251" 1
    bind $top.tit72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit72 getframe]
    radiobutton $site_4_0.rad73 \
        -command {global EOSIOutputSubDir

set EOSIOutputSubDir "T3"} \
        -text {Coherency Elements [ T3 ]} -value T3 \
        -variable TOPSAROutputFormat 
    vTcl:DefineAlias "$site_4_0.rad73" "Radiobutton251_1" vTcl:WidgetProc "Toplevel251" 1
    radiobutton $site_4_0.cpd74 \
        -command {global EOSIOutputSubDir

set EOSIOutputSubDir "C3"} \
        -text {Covariance Elements [ C3 ]} -value C3 \
        -variable TOPSAROutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd74" "Radiobutton251_2" vTcl:WidgetProc "Toplevel251" 1
    pack $site_4_0.rad73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit71 \
        -ipad 2 -text {TOPSAR Auxiliary Files} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame251_1" vTcl:WidgetProc "Toplevel251" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    frame $site_4_0.fra89 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra89" "Frame15" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.fra89
    frame $site_5_0.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd90" "Frame10" vTcl:WidgetProc "Toplevel251" 1
    set site_6_0 $site_5_0.cpd90
    checkbutton $site_6_0.cpd87 \
        -text {C-Band VV  ( TS####_c.vvi2 )} -variable FlagFileInputSTK1 
    vTcl:DefineAlias "$site_6_0.cpd87" "Checkbutton251_1" vTcl:WidgetProc "Toplevel251" 1
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel251" 1
    set site_6_0 $site_5_0.cpd91
    checkbutton $site_6_0.cpd88 \
        -text {C-Band DEM ( TS####.demi2 )} -variable FlagFileInputSTK2 
    vTcl:DefineAlias "$site_6_0.cpd88" "Checkbutton251_2" vTcl:WidgetProc "Toplevel251" 1
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame16" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.cpd92
    frame $site_5_0.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd90" "Frame17" vTcl:WidgetProc "Toplevel251" 1
    set site_6_0 $site_5_0.cpd90
    checkbutton $site_6_0.cpd87 \
        -text {Correlation Coeff Map ( TS####.corgr )} \
        -variable FlagFileInputSTK3 
    vTcl:DefineAlias "$site_6_0.cpd87" "Checkbutton251_3" vTcl:WidgetProc "Toplevel251" 1
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel251" 1
    set site_6_0 $site_5_0.cpd91
    checkbutton $site_6_0.cpd88 \
        -text {Local Incidence Angle ( TS####.incgr )} \
        -variable FlagFileInputSTK4 
    vTcl:DefineAlias "$site_6_0.cpd88" "Checkbutton251_4" vTcl:WidgetProc "Toplevel251" 1
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd93" "Frame19" vTcl:WidgetProc "Toplevel251" 1
    set site_5_0 $site_4_0.cpd93
    frame $site_5_0.cpd90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd90" "Frame21" vTcl:WidgetProc "Toplevel251" 1
    set site_6_0 $site_5_0.cpd90
    checkbutton $site_6_0.cpd87 \
        -text {P-Band Stokes Matrix MLC ( TS####_p.datgr )} \
        -variable FlagFileInputSTK5 
    vTcl:DefineAlias "$site_6_0.cpd87" "Checkbutton251_5" vTcl:WidgetProc "Toplevel251" 1
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd90 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra89 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra41 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame20" vTcl:WidgetProc "Toplevel251" 1
    set site_3_0 $top.fra41
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir ActiveProgram OpenDirFile
global EOSIDirInput EOSIDirOutput EOSIOutputDir EOSIOutputSubDir EOSIExtractFonction
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize
global ProgressLine ConfigFile FinalNlig FinalNcol PolarCase PolarType
global FileInputSTK FileInputSTK1 FileInputSTK2 FileInputSTK3 FileInputSTK4 FileInputSTK5
global FlagFileInputSTK1 FlagFileInputSTK2 FlagFileInputSTK3 FlagFileInputSTK4 FlagFileInputSTK5
global TMPAirsarConfig AIRSARDataFormat TOPSAROutputFormat TMPTopsarConfig
global SubSampCol SubSampRow MultiLookCol MultiLookRow MultiLookSubSamp
global TopsarNlig TopsarNlig TopsarHeader PSPViewGimpBMP
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {
    
set EOSIDirOutput $EOSIOutputDir
if {$EOSIOutputSubDir != ""} {append EOSIDirOutput "/$EOSIOutputSubDir"}
            
    #####################################################################
    #Create Directory
    set EOSIDirOutput [PSPCreateDirectory $EOSIDirOutput $EOSIOutputDir "NO"]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
        set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
        set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
        set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
        if {$EOSIExtractFonction == "Full"} {TestVar 4}
        if {$EOSIExtractFonction == "SubSamp"} {
            set TestVarName(4) "Sub Sampling Col"; set TestVarType(4) "int"; set TestVarValue(4) $SubSampCol; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Sub Sampling Row"; set TestVarType(5) "int"; set TestVarValue(5) $SubSampRow; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$EOSIExtractFonction == "MultiLook"} {
            set TestVarName(4) "Multi Look Col"; set TestVarType(4) "int"; set TestVarValue(4) $MultiLookCol; set TestVarMin(4) "1"; set TestVarMax(4) "100"
            set TestVarName(5) "Multi Look Row"; set TestVarType(5) "int"; set TestVarValue(5) $MultiLookRow; set TestVarMin(5) "1"; set TestVarMax(5) "100"
            TestVar 6
            }
        if {$TestVarError == "ok"} {

            set OffsetLig [expr $NligInit - 1]
            set OffsetCol [expr $NcolInit - 1]
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
            if {$EOSIExtractFonction == "Full"} { set MultiLookSubSamp " -nlr 1 -nlc 1 -ssr 1 -ssc 1 " }
            if {$EOSIExtractFonction == "SubSamp"} { set MultiLookSubSamp " -nlr 1 -nlc 1 -ssr $SubSampRow -ssc $SubSampCol " }
            if {$EOSIExtractFonction == "MultiLook"} { set MultiLookSubSamp " -nlr $MultiLookRow -nlc $MultiLookCol -ssr 1 -ssc 1 " }

            set Fonction " TOPSAR Convert Input Data File"
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_import/airsar_convert.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$FileInputSTK\x22 -od \x22$EOSIDirOutput\x22 -odf $TOPSAROutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf $TMPAirsarConfig $MultiLookSubSamp" "k"
            set f [ open "| Soft/bin/data_import/airsar_convert.exe -if \x22$FileInputSTK\x22 -od \x22$EOSIDirOutput\x22 -odf $TOPSAROutputFormat -nr $NligFullSize -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cf $TMPAirsarConfig $MultiLookSubSamp" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
            if {$FlagFileInputSTK1 == "1"} {
                TOPSARHeader $FileInputSTK1
                if {$TopsarHeader == "ok"} {
                    set Fonction " TOPSAR Convert Auxiliary Data File"
                    set Fonction2 "$FileInputSTK1"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/data_import/topsar_CbandVV.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$FileInputSTK1\x22 -od \x22$EOSIDirOutput\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hf \x22$TMPTopsarConfig\x22" "k"
                    set f [ open "| Soft/bin/data_import/topsar_CbandVV.exe -if \x22$FileInputSTK1\x22 -od \x22$EOSIDirOutput\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hf \x22$TMPTopsarConfig\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    EnviWriteConfig "$EOSIDirOutput/CBandVV.bin" $TopsarNlig $TopsarNcol 4
                    set BMPDirInput $EOSIDirOutput
                    set BMPFileInput "$EOSIDirOutput/CBandVV.bin"
                    set BMPFileOutput "$EOSIDirOutput/CBandVV_db.bmp"
                    set MaskCmd ""
                    set MaskDir $BMPDirInput
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                    set Fonction "Creation of the BMP File :"
                    set Fonction2 "$BMPFileOutput"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp_file.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft db10 -clm gray -nc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mm 1 -min 0 -max 0 $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/create_bmp_file.exe -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft db10 -clm gray -nc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mm 1 -min 0 -max 0 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
                    }
                }
    
            if {$FlagFileInputSTK2 == "1"} {
                TOPSARHeader $FileInputSTK2
                if {$TopsarHeader == "ok"} {
                    set Fonction " TOPSAR Convert Auxiliary Data File"
                    set Fonction2 "$FileInputSTK2"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/data_import/topsar_CbandDEM.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$FileInputSTK2\x22 -od \x22$EOSIDirOutput\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hf \x22$TMPTopsarConfig\x22" "k"
                    set f [ open "| Soft/bin/data_import/topsar_CbandDEM.exe -if \x22$FileInputSTK2\x22 -od \x22$EOSIDirOutput\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hf \x22$TMPTopsarConfig\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    EnviWriteConfig "$EOSIDirOutput/CBandDEM.bin" $TopsarNlig $TopsarNcol 4
                    set BMPDirInput $EOSIDirOutput
                    set BMPFileInput "$EOSIDirOutput/CBandDEM.bin"
                    set BMPFileOutput "$EOSIDirOutput/CBandDEM.bmp"
                    set MaskCmd ""
                    set MaskDir $BMPDirInput
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                    set Fonction "Creation of the BMP File :"
                    set Fonction2 "$BMPFileOutput"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp_file.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm jet -nc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mm 3 -min 0 -max 0 $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/create_bmp_file.exe -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm jet -nc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mm 3 -min 0 -max 0 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
                    }
                }
    
            if {$FlagFileInputSTK3 == "1"} {
                TOPSARHeader $FileInputSTK3
                if {$TopsarHeader == "ok"} {
                    set Fonction " TOPSAR Convert Auxiliary Data File"
                    set Fonction2 "$FileInputSTK3"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/data_import/topsar_corr_coeff_map.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$FileInputSTK3\x22 -od \x22$EOSIDirOutput\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hf \x22$TMPTopsarConfig\x22" "k"
                    set f [ open "| Soft/bin/data_import/topsar_corr_coeff_map.exe -if \x22$FileInputSTK3\x22 -od \x22$EOSIDirOutput\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hf \x22$TMPTopsarConfig\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    EnviWriteConfig "$EOSIDirOutput/CorrCoeffMap.bin" $TopsarNlig $TopsarNcol 4
                    set BMPDirInput $EOSIDirOutput
                    set BMPFileInput "$EOSIDirOutput/CorrCoeffMap.bin"
                    set BMPFileOutput "$EOSIDirOutput/CorrCoeffMap.bmp"
                    set MaskCmd ""
                    set MaskDir $BMPDirInput
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                    set Fonction "Creation of the BMP File :"
                    set Fonction2 "$BMPFileOutput"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp_file.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm jet -nc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mm 3 -min 0 -max 0 $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/create_bmp_file.exe -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm jet -nc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mm 3 -min 0 -max 0 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
                    }
                }

            if {$FlagFileInputSTK4 == "1"} {
                TOPSARHeader $FileInputSTK4
                if {$TopsarHeader == "ok"} {
                    set Fonction " TOPSAR Convert Auxiliary Data File"
                    set Fonction2 "$FileInputSTK4"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/data_import/topsar_loc_inc_angle.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$FileInputSTK4\x22 -od \x22$EOSIDirOutput\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hf \x22$TMPTopsarConfig\x22" "k"
                    set f [ open "| Soft/bin/data_import/topsar_loc_inc_angle.exe -if \x22$FileInputSTK4\x22 -od \x22$EOSIDirOutput\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hf \x22$TMPTopsarConfig\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    EnviWriteConfig "$EOSIDirOutput/LocIncAngle.bin" $TopsarNlig $TopsarNcol 4
                    set BMPDirInput $EOSIDirOutput
                    set BMPFileInput "$EOSIDirOutput/LocIncAngle.bin"
                    set BMPFileOutput "$EOSIDirOutput/LocIncAngle.bmp"
                    set MaskCmd ""
                    set MaskDir $BMPDirInput
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                    set Fonction "Creation of the BMP File :"
                    set Fonction2 "$BMPFileOutput"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp_file.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm jet -nc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mm 3 -min 0 -max 0 $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/create_bmp_file.exe -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm jet -nc $FinalNcol -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mm 3 -min 0 -max 0 $MaskCmd" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
                    }
                }
    
            set ConfigFile "$EOSIDirOutput/config.txt"
            set ErrorMessage ""
            LoadConfig
            if {"$ErrorMessage" == ""} {
                if {$TOPSAROutputFormat == "T3"} {
                    EnviWriteConfigT $EOSIDirOutput $NligFullSize $NcolFullSize
                    RGB_T3
                    }
                if {$TOPSAROutputFormat == "C3"} {
                    EnviWriteConfigC $EOSIDirOutput $NligFullSize $NcolFullSize
                    RGB_C3
                    }
                } else {
                append ErrorMessage " -> An ERROR occured during the Data Extraction"
                set VarError ""
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }
    
            set DataDir $EOSIOutputDir
            MenuOn
            Window hide $widget(Toplevel251); TextEditorRunTrace "Close Window $ActiveProgram Extract Data" "b"
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel251); TextEditorRunTrace "Close Window $ActiveProgram Extract Data" "b"}
        }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel251" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/TOPSAR_Extract_Data.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel251" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global ActiveProgram OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel251); TextEditorRunTrace "Close Window $ActiveProgram Extract Data" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel251" 1
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
    menu $top.m72 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab71 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra27 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra96 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill both -side top 
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
Window show .top251

main $argc $argv
