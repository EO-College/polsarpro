#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

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

        {{[file join . GUI Images DisplayMenu.gif]} {user image} user {}}
        {{[file join . GUI Images PVv3shortcut.gif]} {user image} user {}}
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
    set base .top308
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab53 {
        array set save {-_tooltip 1 -image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.men84 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men84.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.men85 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men85.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd67
    namespace eval ::widgets::$site_3_0.men84 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men84.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.men85 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men85.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra68
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd69
    namespace eval ::widgets::$site_4_0.men77 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.men77.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd70
    namespace eval ::widgets::$site_4_0.men77 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.men77.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -padx 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-_tooltip 1 -command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra26 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra26
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but27 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top1
            vTclWindow.top308
            vTclWindow.top2
            vTclWindow.top5
            vTclWindow.top4
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
    wm geometry $top 200x200+154+154; update
    wm maxsize $top 3604 1065
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

proc vTclWindow.top308 {base} {
    if {$base == ""} {
        set base .top308
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
    wm geometry $top 150x210+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Display"
    vTcl:DefineAlias "$top" "Toplevel308" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab53 \
        \
        -image [vTcl:image:get_image [file join . GUI Images DisplayMenu.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$top.lab53" "Label171" vTcl:WidgetProc "Toplevel308" 1
    bindtags $top.lab53 "$top.lab53 Label $top all _vTclBalloon"
    bind $top.lab53 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP 1.4}
    }
    frame $top.fra83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame3" vTcl:WidgetProc "Toplevel308" 1
    set site_3_0 $top.fra83
    menubutton $site_3_0.men84 \
        -menu "$site_3_0.men84.m" -padx 4 -pady 4 -relief raised \
        -text {[S2] Master} -width 8 
    vTcl:DefineAlias "$site_3_0.men84" "Menubutton308_1" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_3_0.men84 "$site_3_0.men84 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men84 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Sinclair Matrix}
    }
    menu $site_3_0.men84.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men84.m add command \
        \
        -command {global DataDirChannel1 ColorMap ColorMapFile CONFIGDir ValidMaskFile ValidMaskColor
#BMP PROCESS
global Load_CreateBMPFile PSPTopLevel
 
if {$Load_CreateBMPFile == 0} {
    source "GUI/bmp_process/CreateBMPFile.tcl"
    set Load_CreateBMPFile 1
    WmTransient $widget(Toplevel43) $PSPTopLevel
    }

set config "false"
    
set BMPDirInput $DataDirChannel1
set BMPDirOutput ""
if {$BMPDirInput != ""} {set config "true"}
if [file exists "$BMPDirInput/config.txt"] {set config "true"}
if [file exists "$BMPDirInput/s11.bin"] {set config "true"}
if [file exists "$BMPDirInput/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} {set config "false"}
    }
if {$config == "false"} {
    set BMPDirInput ""
    set BMPDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NcolFullSize 0
    set InputFormat "float"
    set OutputFormat "real"
    } else {
    set InputFormat "cmplx"
    set OutputFormat "mod"
    }
set BMPOutputFormat "bmp8"
set BMPFileInput ""
set BMPFileOutput ""
set BMPFileOutputTmp ""
set ValidMaskFile ""; set ValidMaskColor "black"
$widget(Entry43_5) configure -state disable
$widget(Entry43_5) configure -disabledbackground #FFFFFF
$widget(Button43_5) configure -state normal
set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
set ColorMap "jet"
set MinMaxAutoBMP 1
set MinMaxContrastBMP 0
$widget(Label43_1) configure -state disable
$widget(Entry43_1) configure -state disable
$widget(Label43_2) configure -state disable
$widget(Entry43_2) configure -state disable
$widget(Label43_3) configure -state disable
$widget(Entry43_3) configure -state disable
$widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label43_4) configure -state disable
$widget(Entry43_4) configure -state disable
$widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button43_1) configure -state disable
set MinBMP "Auto"; set MaxBMP "Auto"
set MinCBMP ""; set MaxCBMP ""
$widget(Checkbutton43_1) configure -state normal
$widget(Checkbutton43_2) configure -state normal
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel43); TextEditorRunTrace "Open Window Create BMP File" "b"} \
        -label {Create BMP File} 
    $site_3_0.men84.m add separator \
        
    $site_3_0.men84.m add command \
        \
        -command {global DataDirChannel1 RGBFunction
#BMP PROCESS
global Load_CreateRGBFile PSPTopLevel
 
if {$Load_CreateRGBFile == 0} {
    source "GUI/bmp_process/CreateRGBFile.tcl"
    set Load_CreateRGBFile 1
    WmTransient $widget(Toplevel39) $PSPTopLevel
    }

set RGBFunction "S2"

set config "false"
    
set RGBDirInput $DataDirChannel1
set RGBDirOutput $DataDirChannel1
if {$RGBDirInput != ""} {set config "true"}
if [file exists "$RGBDirInput/config.txt"] {set config "true"}
if [file exists "$RGBDirInput/s11.bin"] {set config "true"}
if [file exists "$RGBDirInput/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$RGBDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} { set config "false" }
    }
if {$config == "false"} {
    set RGBDirInput ""
    set RGBDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    }
set RGBFileInput ""
set RGBFileOutput ""
set FileInputBlue ""
set FileInputGreen ""
set FileInputRed ""
set FileOutput ""
set RGBFormat " "
set RGBCCCE "independant"
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel39); TextEditorRunTrace "Open Window Create RGB File" "b"} \
        -label {Create RGB File} 
    $site_3_0.men84.m add separator \
        
    $site_3_0.men84.m add command \
        \
        -command {global DataDirChannel1 HSLFunction
#BMP PROCESS
global Load_CreateHSLFile PSPTopLevel
 
if {$Load_CreateHSLFile == 0} {
    source "GUI/bmp_process/CreateHSLFile.tcl"
    set Load_CreateHSLFile 1
    WmTransient $widget(Toplevel69) $PSPTopLevel
    }
    
set HSVFunction "S2"

set config "false"
    
set HSVDirInput $DataDirChannel1
set HSVDirOutput $DataDirChannel1
if {$HSVDirInput != ""} {set config "true"}
if [file exists "$HSVDirInput/config.txt"] {set config "true"}
if [file exists "$HSVDirInput/s11.bin"] {set config "true"}
if [file exists "$HSVDirInput/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$HSVDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} { set config "false" }
    }
if {$config == "false"} {
    set HSVDirInput ""
    set HSVDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    }
set HSVFileInput ""
set HSVFileOutput ""
set FileInputHue ""
set FileInputSat ""
set FileInputVal ""
set FileOutput ""
set HSVFormat " "
set HSVCCCE "independant"
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel69); TextEditorRunTrace "Open Window Create HSL File" "b"} \
        -label {Create HSL File} 
    menubutton $site_3_0.men85 \
        -menu "$site_3_0.men85.m" -padx 4 -pady 4 -relief raised \
        -text {[S2] Slave} -width 8 
    vTcl:DefineAlias "$site_3_0.men85" "Menubutton308_2" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_3_0.men85 "$site_3_0.men85 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Sinclair Matrix}
    }
    menu $site_3_0.men85.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men85.m add command \
        \
        -command {global DataDirChannel2 ColorMap ColorMapFile CONFIGDir ValidMaskFile ValidMaskColor
#BMP PROCESS
global Load_CreateBMPFile PSPTopLevel
 
if {$Load_CreateBMPFile == 0} {
    source "GUI/bmp_process/CreateBMPFile.tcl"
    set Load_CreateBMPFile 1
    WmTransient $widget(Toplevel43) $PSPTopLevel
    }

set config "false"
    
set BMPDirInput $DataDirChannel2
set BMPDirOutput ""
if {$BMPDirInput != ""} {set config "true"}
if [file exists "$BMPDirInput/config.txt"] {set config "true"}
if [file exists "$BMPDirInput/s11.bin"] {set config "true"}
if [file exists "$BMPDirInput/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} {set config "false"}
    }
if {$config == "false"} {
    set BMPDirInput ""
    set BMPDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NcolFullSize 0
    set InputFormat "float"
    set OutputFormat "real"
    } else {
    set InputFormat "cmplx"
    set OutputFormat "mod"
    }
set BMPOutputFormat "bmp8"
set BMPFileInput ""
set BMPFileOutput ""
set BMPFileOutputTmp ""
set ValidMaskFile ""; set ValidMaskColor "black"
$widget(Entry43_5) configure -state disable
$widget(Entry43_5) configure -disabledbackground #FFFFFF
$widget(Button43_5) configure -state normal
set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
set ColorMap "jet"
set MinMaxAutoBMP 1
set MinMaxContrastBMP 0
$widget(Label43_1) configure -state disable
$widget(Entry43_1) configure -state disable
$widget(Label43_2) configure -state disable
$widget(Entry43_2) configure -state disable
$widget(Label43_3) configure -state disable
$widget(Entry43_3) configure -state disable
$widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label43_4) configure -state disable
$widget(Entry43_4) configure -state disable
$widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button43_1) configure -state disable
set MinBMP "Auto"; set MaxBMP "Auto"
set MinCBMP ""; set MaxCBMP ""
$widget(Checkbutton43_1) configure -state normal
$widget(Checkbutton43_2) configure -state normal
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel43); TextEditorRunTrace "Open Window Create BMP File" "b"} \
        -label {Create BMP File} 
    $site_3_0.men85.m add separator \
        
    $site_3_0.men85.m add command \
        \
        -command {global DataDirChannel2 RGBFunction
#BMP PROCESS
global Load_CreateRGBFile PSPTopLevel
 
if {$Load_CreateRGBFile == 0} {
    source "GUI/bmp_process/CreateRGBFile.tcl"
    set Load_CreateRGBFile 1
    WmTransient $widget(Toplevel39) $PSPTopLevel
    }

set RGBFunction "S2"

set config "false"
    
set RGBDirInput $DataDirChannel2
set RGBDirOutput $DataDirChannel2
if {$RGBDirInput != ""} {set config "true"}
if [file exists "$RGBDirInput/config.txt"] {set config "true"}
if [file exists "$RGBDirInput/s11.bin"] {set config "true"}
if [file exists "$RGBDirInput/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$RGBDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} { set config "false" }
    }
if {$config == "false"} {
    set RGBDirInput ""
    set RGBDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    }
set RGBFileInput ""
set RGBFileOutput ""
set FileInputBlue ""
set FileInputGreen ""
set FileInputRed ""
set FileOutput ""
set RGBFormat " "
set RGBCCCE "independant"
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel39); TextEditorRunTrace "Open Window Create RGB File" "b"} \
        -label {Create RGB File} 
    $site_3_0.men85.m add separator \
        
    $site_3_0.men85.m add command \
        \
        -command {global DataDirChannel2 HSLFunction
#BMP PROCESS
global Load_CreateHSLFile PSPTopLevel
 
if {$Load_CreateHSLFile == 0} {
    source "GUI/bmp_process/CreateHSLFile.tcl"
    set Load_CreateHSLFile 1
    WmTransient $widget(Toplevel69) $PSPTopLevel
    }
    
set HSVFunction "S2"

set config "false"
    
set HSVDirInput $DataDirChannel2
set HSVDirOutput $DataDirChannel2
if {$HSVDirInput != ""} {set config "true"}
if [file exists "$HSVDirInput/config.txt"] {set config "true"}
if [file exists "$HSVDirInput/s11.bin"] {set config "true"}
if [file exists "$HSVDirInput/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$HSVDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} { set config "false" }
    }
if {$config == "false"} {
    set HSVDirInput ""
    set HSVDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    }
set HSVFileInput ""
set HSVFileOutput ""
set FileInputHue ""
set FileInputSat ""
set FileInputVal ""
set FileOutput ""
set HSVFormat " "
set HSVCCCE "independant"
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel69); TextEditorRunTrace "Open Window Create HSL File" "b"} \
        -label {Create HSL File} 
    pack $site_3_0.men84 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    pack $site_3_0.men85 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipady 1 -side right 
    frame $top.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd67" "Frame7" vTcl:WidgetProc "Toplevel308" 1
    set site_3_0 $top.cpd67
    menubutton $site_3_0.men84 \
        -menu "$site_3_0.men84.m" -padx 4 -pady 4 -relief raised \
        -text {[SPP] Master} -width 8 
    vTcl:DefineAlias "$site_3_0.men84" "Menubutton308_4" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_3_0.men84 "$site_3_0.men84 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men84 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Dual Polarimetric Complex data}
    }
    menu $site_3_0.men84.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men84.m add command \
        \
        -command {global DataDirChannel1 ColorMap ColorMapFile CONFIGDir ValidMaskFile ValidMaskColor
#BMP PROCESS
global Load_CreateBMPFile PSPTopLevel
 
if {$Load_CreateBMPFile == 0} {
    source "GUI/bmp_process/CreateBMPFile.tcl"
    set Load_CreateBMPFile 1
    WmTransient $widget(Toplevel43) $PSPTopLevel
    }

set config "false"
    
set BMPDirInput $DataDirChannel1
set BMPDirOutput ""
if {$BMPDirInput != ""} {set config "true"}
if [file exists "$BMPDirInput/config.txt"] {set config "true"}
if [file exists "$BMPDirInput/s11.bin"] {set config "true"}
if [file exists "$BMPDirInput/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} {set config "false"}
    }
if {$config == "false"} {
    set BMPDirInput ""
    set BMPDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NcolFullSize 0
    set InputFormat "float"
    set OutputFormat "real"
    } else {
    set InputFormat "cmplx"
    set OutputFormat "mod"
    }
set BMPOutputFormat "bmp8"
set BMPFileInput ""
set BMPFileOutput ""
set BMPFileOutputTmp ""
set ValidMaskFile ""; set ValidMaskColor "black"
$widget(Entry43_5) configure -state disable
$widget(Entry43_5) configure -disabledbackground #FFFFFF
$widget(Button43_5) configure -state normal
set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
set ColorMap "jet"
set MinMaxAutoBMP 1
set MinMaxContrastBMP 0
$widget(Label43_1) configure -state disable
$widget(Entry43_1) configure -state disable
$widget(Label43_2) configure -state disable
$widget(Entry43_2) configure -state disable
$widget(Label43_3) configure -state disable
$widget(Entry43_3) configure -state disable
$widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label43_4) configure -state disable
$widget(Entry43_4) configure -state disable
$widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button43_1) configure -state disable
set MinBMP "Auto"; set MaxBMP "Auto"
set MinCBMP ""; set MaxCBMP ""
$widget(Checkbutton43_1) configure -state normal
$widget(Checkbutton43_2) configure -state normal
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel43); TextEditorRunTrace "Open Window Create BMP File" "b"} \
        -label {Create BMP File} 
    $site_3_0.men84.m add separator \
        
    $site_3_0.men84.m add command \
        \
        -command {global DataDirChannel1 RGBFunction
#BMP PROCESS
global Load_CreateRGBFile_PP PSPTopLevel
 
if {$Load_CreateRGBFile_PP == 0} {
    source "GUI/bmp_process/CreateRGBFile_PP.tcl"
    set Load_CreateRGBFile_PP 1
    WmTransient $widget(Toplevel201) $PSPTopLevel
    }
  
set RGBFunction "SPP"
set RGBDirInput $DataDirChannel1
set RGBDirOutput $DataDirChannel1
set RGBFileInput ""
set RGBFileOutput ""
set FileInputBlue ""
set FileInputGreen ""
set FileInputRed ""
set FileOutput ""
set RGBFormat " "
set RGBCCCE "independant"
$widget(Radiobutton201_1) configure -state normal
$widget(Radiobutton201_2) configure -state normal
set ConfigFile ""

set MinMaxAutoRGB "1"
$widget(TitleFrame201_1) configure -state disable
$widget(TitleFrame201_2) configure -state disable
$widget(TitleFrame201_3) configure -state disable
$widget(Label201_1) configure -state disable
$widget(Entry201_1) configure -state disable
$widget(Label201_2) configure -state disable
$widget(Entry201_2) configure -state disable
$widget(Label201_3) configure -state disable
$widget(Entry201_3) configure -state disable
$widget(Label201_4) configure -state disable
$widget(Entry201_4) configure -state disable
$widget(Label201_5) configure -state disable
$widget(Entry201_5) configure -state disable
$widget(Label201_6) configure -state disable
$widget(Entry201_6) configure -state disable
$widget(Button201_1) configure -state disable
$widget(Button201_2) configure -state normal
set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
set RGBMinRed "Auto"; set RGBMaxRed "Auto"
set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"

set ConfigFile "$RGBDirInput/config.txt"
set ErrorMessage ""
LoadConfig
if {"$ErrorMessage" == ""} {   
    if { "$PolarType" == "pp1"} {
        set Channel1 "s11"
        set Channel2 "s21"
        }
    if { "$PolarType" == "pp2"} {
        set Channel1 "s22"
        set Channel2 "s12"
        }
    if { "$PolarType" == "pp3"} {
        set Channel1 "s11"
        set Channel2 "s22"
        }
    WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel201); TextEditorRunTrace "Open Window Create RGB File PP" "b"
    } else {
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Create RGB File} 
    menubutton $site_3_0.men85 \
        -menu "$site_3_0.men85.m" -padx 4 -pady 4 -relief raised \
        -text {[SPP] Slave} -width 8 
    vTcl:DefineAlias "$site_3_0.men85" "Menubutton308_5" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_3_0.men85 "$site_3_0.men85 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Dual Polarimetric Complex data}
    }
    menu $site_3_0.men85.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men85.m add command \
        \
        -command {global DataDirChannel2 ColorMap ColorMapFile CONFIGDir ValidMaskFile ValidMaskColor
#BMP PROCESS
global Load_CreateBMPFile PSPTopLevel
 
if {$Load_CreateBMPFile == 0} {
    source "GUI/bmp_process/CreateBMPFile.tcl"
    set Load_CreateBMPFile 1
    WmTransient $widget(Toplevel43) $PSPTopLevel
    }

set config "false"
    
set BMPDirInput $DataDirChannel2
set BMPDirOutput ""
if {$BMPDirInput != ""} {set config "true"}
if [file exists "$BMPDirInput/config.txt"] {set config "true"}
if [file exists "$BMPDirInput/s11.bin"] {set config "true"}
if [file exists "$BMPDirInput/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} {set config "false"}
    }
if {$config == "false"} {
    set BMPDirInput ""
    set BMPDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NcolFullSize 0
    set InputFormat "float"
    set OutputFormat "real"
    } else {
    set InputFormat "cmplx"
    set OutputFormat "mod"
    }
set BMPOutputFormat "bmp8"
set BMPFileInput ""
set BMPFileOutput ""
set BMPFileOutputTmp ""
set ValidMaskFile ""; set ValidMaskColor "black"
$widget(Entry43_5) configure -state disable
$widget(Entry43_5) configure -disabledbackground #FFFFFF
$widget(Button43_5) configure -state normal
set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
set ColorMap "jet"
set MinMaxAutoBMP 1
set MinMaxContrastBMP 0
$widget(Label43_1) configure -state disable
$widget(Entry43_1) configure -state disable
$widget(Label43_2) configure -state disable
$widget(Entry43_2) configure -state disable
$widget(Label43_3) configure -state disable
$widget(Entry43_3) configure -state disable
$widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label43_4) configure -state disable
$widget(Entry43_4) configure -state disable
$widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button43_1) configure -state disable
set MinBMP "Auto"; set MaxBMP "Auto"
set MinCBMP ""; set MaxCBMP ""
$widget(Checkbutton43_1) configure -state normal
$widget(Checkbutton43_2) configure -state normal
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel43); TextEditorRunTrace "Open Window Create BMP File" "b"} \
        -label {Create BMP File} 
    $site_3_0.men85.m add separator \
        
    $site_3_0.men85.m add command \
        \
        -command {global DataDirChannel1 RGBFunction
#BMP PROCESS
global Load_CreateRGBFile_PP PSPTopLevel
 
if {$Load_CreateRGBFile_PP == 0} {
    source "GUI/bmp_process/CreateRGBFile_PP.tcl"
    set Load_CreateRGBFile_PP 1
    WmTransient $widget(Toplevel201) $PSPTopLevel
    }
  
set RGBFunction "SPP"
set RGBDirInput $DataDirChannel2
set RGBDirOutput $DataDirChannel2
set RGBFileInput ""
set RGBFileOutput ""
set FileInputBlue ""
set FileInputGreen ""
set FileInputRed ""
set FileOutput ""
set RGBFormat " "
set RGBCCCE "independant"
$widget(Radiobutton201_1) configure -state normal
$widget(Radiobutton201_2) configure -state normal
set ConfigFile ""

set MinMaxAutoRGB "1"
$widget(TitleFrame201_1) configure -state disable
$widget(TitleFrame201_2) configure -state disable
$widget(TitleFrame201_3) configure -state disable
$widget(Label201_1) configure -state disable
$widget(Entry201_1) configure -state disable
$widget(Label201_2) configure -state disable
$widget(Entry201_2) configure -state disable
$widget(Label201_3) configure -state disable
$widget(Entry201_3) configure -state disable
$widget(Label201_4) configure -state disable
$widget(Entry201_4) configure -state disable
$widget(Label201_5) configure -state disable
$widget(Entry201_5) configure -state disable
$widget(Label201_6) configure -state disable
$widget(Entry201_6) configure -state disable
$widget(Button201_1) configure -state disable
$widget(Button201_2) configure -state normal
set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
set RGBMinRed "Auto"; set RGBMaxRed "Auto"
set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"

set ConfigFile "$RGBDirInput/config.txt"
set ErrorMessage ""
LoadConfig
if {"$ErrorMessage" == ""} {   
    if { "$PolarType" == "pp1"} {
        set Channel1 "s11"
        set Channel2 "s21"
        }
    if { "$PolarType" == "pp2"} {
        set Channel1 "s22"
        set Channel2 "s12"
        }
    if { "$PolarType" == "pp3"} {
        set Channel1 "s11"
        set Channel2 "s22"
        }
    WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel201); TextEditorRunTrace "Open Window Create RGB File PP" "b"
    } else {
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Create RGB File} 
    pack $site_3_0.men84 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    pack $site_3_0.men85 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipady 1 -side right 
    frame $top.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra68" "Frame2" vTcl:WidgetProc "Toplevel308" 1
    set site_3_0 $top.fra68
    frame $site_3_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd69" "Frame5" vTcl:WidgetProc "Toplevel308" 1
    set site_4_0 $site_3_0.cpd69
    menubutton $site_4_0.men77 \
        -menu "$site_4_0.men77.m" -padx 4 -pady 4 -relief raised \
        -text {[ T4 ]} -width 4 
    vTcl:DefineAlias "$site_4_0.men77" "Menubutton308_6" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_4_0.men77 "$site_4_0.men77 Menubutton $top all _vTclBalloon"
    bind $site_4_0.men77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {4x4 Coherency Matrix}
    }
    menu $site_4_0.men77.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ColorMap ColorMapFile CONFIGDir ValidMaskFile ValidMaskColor
#BMP PROCESS
global Load_CreateBMPFile PSPTopLevel
 
if {$Load_CreateBMPFile == 0} {
    source "GUI/bmp_process/CreateBMPFile.tcl"
    set Load_CreateBMPFile 1
    WmTransient $widget(Toplevel43) $PSPTopLevel
    }

set config "false"
    
set BMPDirInput "$DataDirChannel1/T4"
set BMPDirOutput ""
if {$BMPDirInput != ""} {set config "true"}
if [file exists "$BMPDirInput/config.txt"] {set config "true"}
if [file exists "$BMPDirInput/T11.bin"] {set config "true"}
if [file exists "$BMPDirInput/T44.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} {set config "false"}
    }
if {$config == "false"} {
    set BMPDirInput ""
    set BMPDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NcolFullSize 0
    }
set InputFormat "float"
set OutputFormat "real"
set BMPOutputFormat "bmp8"
set BMPFileInput ""
set BMPFileOutput ""
set BMPFileOutputTmp ""
set ValidMaskFile ""; set ValidMaskColor "black"
$widget(Entry43_5) configure -state disable
$widget(Entry43_5) configure -disabledbackground #FFFFFF
$widget(Button43_5) configure -state normal
set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
set ColorMap "jet"
set MinMaxAutoBMP 1
set MinMaxContrastBMP 0
$widget(Label43_1) configure -state disable
$widget(Entry43_1) configure -state disable
$widget(Label43_2) configure -state disable
$widget(Entry43_2) configure -state disable
$widget(Label43_3) configure -state disable
$widget(Entry43_3) configure -state disable
$widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label43_4) configure -state disable
$widget(Entry43_4) configure -state disable
$widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button43_1) configure -state disable
set MinBMP "Auto"; set MaxBMP "Auto"
set MinCBMP ""; set MaxCBMP ""
$widget(Checkbutton43_1) configure -state normal
$widget(Checkbutton43_2) configure -state normal
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel43); TextEditorRunTrace "Open Window Create BMP File" "b"} \
        -label {Create BMP File} 
    $site_4_0.men77.m add separator \
        
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 RGBFunction
#BMP PROCESS
global Load_CreateRGBDualFile_PP PSPTopLevel
 
if {$Load_CreateRGBDualFile_PP == 0} {
    source "GUI/bmp_process/CreateRGBDualFile_PP.tcl"
    set Load_CreateRGBDualFile_PP 1
    WmTransient $widget(Toplevel439) $PSPTopLevel
    }

set RGBFunction "T4"

set config "false"
    
set RGBDirInput "$DataDirChannel1/T4"
set RGBDirOutput "$DataDirChannel1/T4"
if {$RGBDirInput != ""} {set config "true"}
if [file exists "$RGBDirInput/config.txt"] {set config "true"}
if [file exists "$RGBDirInput/T11.bin"] {set config "true"}
if [file exists "$RGBDirInput/T44.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$RGBDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} { set config "false" }
    }
if {$config == "false"} {
    set RGBDirInput ""
    set RGBDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    }
set RGBFileOutputT1 ""
set RGBFileOutputT2 ""
set RGBFormat " "
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel439); TextEditorRunTrace "Open Window Create RGB Dual Files" "b"} \
        -label {Create RGB File} 
    pack $site_4_0.men77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd70" "Frame6" vTcl:WidgetProc "Toplevel308" 1
    set site_4_0 $site_3_0.cpd70
    menubutton $site_4_0.men77 \
        -menu "$site_4_0.men77.m" -padx 4 -pady 4 -relief raised \
        -text {[ T6 ]} -width 4 
    vTcl:DefineAlias "$site_4_0.men77" "Menubutton308_3" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_4_0.men77 "$site_4_0.men77 Menubutton $top all _vTclBalloon"
    bind $site_4_0.men77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {6x6 Coherency Matrix}
    }
    menu $site_4_0.men77.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ColorMap ColorMapFile CONFIGDir ValidMaskFile ValidMaskColor
#BMP PROCESS
global Load_CreateBMPFile PSPTopLevel
 
if {$Load_CreateBMPFile == 0} {
    source "GUI/bmp_process/CreateBMPFile.tcl"
    set Load_CreateBMPFile 1
    WmTransient $widget(Toplevel43) $PSPTopLevel
    }

set config "false"
    
set BMPDirInput "$DataDirChannel1/T6"
set BMPDirOutput ""
if {$BMPDirInput != ""} {set config "true"}
if [file exists "$BMPDirInput/config.txt"] {set config "true"}
if [file exists "$BMPDirInput/T11.bin"] {set config "true"}
if [file exists "$BMPDirInput/T66.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} {set config "false"}
    }
if {$config == "false"} {
    set BMPDirInput ""
    set BMPDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NcolFullSize 0
    }
set InputFormat "float"
set OutputFormat "real"
set BMPOutputFormat "bmp8"
set BMPFileInput ""
set BMPFileOutput ""
set BMPFileOutputTmp ""
set ValidMaskFile ""; set ValidMaskColor "black"
$widget(Entry43_5) configure -state disable
$widget(Entry43_5) configure -disabledbackground #FFFFFF
$widget(Button43_5) configure -state normal
set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
set ColorMap "jet"
set MinMaxAutoBMP 1
set MinMaxContrastBMP 0
$widget(Label43_1) configure -state disable
$widget(Entry43_1) configure -state disable
$widget(Label43_2) configure -state disable
$widget(Entry43_2) configure -state disable
$widget(Label43_3) configure -state disable
$widget(Entry43_3) configure -state disable
$widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label43_4) configure -state disable
$widget(Entry43_4) configure -state disable
$widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button43_1) configure -state disable
set MinBMP "Auto"; set MaxBMP "Auto"
set MinCBMP ""; set MaxCBMP ""
$widget(Checkbutton43_1) configure -state normal
$widget(Checkbutton43_2) configure -state normal
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel43); TextEditorRunTrace "Open Window Create BMP File" "b"} \
        -label {Create BMP File} 
    $site_4_0.men77.m add separator \
        
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 RGBFunction
#BMP PROCESS
global Load_CreateRGBDualFile PSPTopLevel
 
if {$Load_CreateRGBDualFile == 0} {
    source "GUI/bmp_process/CreateRGBDualFile.tcl"
    set Load_CreateRGBDualFile 1
    WmTransient $widget(Toplevel309) $PSPTopLevel
    }

set RGBFunction "T6"

set config "false"
    
set RGBDirInput "$DataDirChannel1/T6"
set RGBDirOutput "$DataDirChannel1/T6"
if {$RGBDirInput != ""} {set config "true"}
if [file exists "$RGBDirInput/config.txt"] {set config "true"}
if [file exists "$RGBDirInput/T11.bin"] {set config "true"}
if [file exists "$RGBDirInput/T66.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$RGBDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" != ""} { set config "false" }
    }
if {$config == "false"} {
    set RGBDirInput ""
    set RGBDirOutput ""
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    }
set RGBFileOutputT1 ""
set RGBFileOutputT2 ""
set RGBFormat " "
WidgetShowFromMenuFix $widget(Toplevel308) $widget(Toplevel309); TextEditorRunTrace "Open Window Create RGB Dual Files" "b"} \
        -label {Create RGB File} 
    pack $site_4_0.men77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra71 \
        -borderwidth 2 -relief raised -height 75 -padx 7 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame4" vTcl:WidgetProc "Toplevel308" 1
    set site_3_0 $top.fra71
    button $site_3_0.but72 \
        \
        -command {global PVProcessShortcut

if {$PVProcessShortcut == 0} {
    set PVProcessShortcut 1
    LoadPSPViewerProcess
    Window show $widget(Toplevel64p); TextEditorRunTrace "Open Window PolSARpro Viewer - Process" "b"
    } else {
    set PVProcessShortcut 0
    ClosePSPViewerProcess
    Window hide $widget(Toplevel64p); TextEditorRunTrace "Close Window PolSARpro Viewer - Process" "b"
    }} \
        -image [vTcl:image:get_image [file join . GUI Images PVv3shortcut.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_3_0.but72" "Button2" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_3_0.but72 "$site_3_0.but72 Button $top all _vTclBalloon"
    bind $site_3_0.but72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP Viewer3.0}
    }
    button $site_3_0.but73 \
        \
        -command {global PVProcessShortcut

if {$PVProcessShortcut == 0} {
    set PVProcessShortcut 1
    LoadPSPViewerProcess
    Window show $widget(Toplevel64p); TextEditorRunTrace "Open Window PolSARpro Viewer - Process" "b"
    } else {
    set PVProcessShortcut 0
    ClosePSPViewerProcess
    Window hide $widget(Toplevel64p); TextEditorRunTrace "Close Window PolSARpro Viewer - Process" "b"
    }} \
        -pady 0 -relief flat -text {BMP Viewer} 
    vTcl:DefineAlias "$site_3_0.but73" "Button3" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_3_0.but73 "$site_3_0.but73 Button $top all _vTclBalloon"
    bind $site_3_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP Viewer3.0}
    }
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra26 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra26" "Frame413" vTcl:WidgetProc "Toplevel308" 1
    set site_3_0 $top.fra26
    button $site_3_0.but74 \
        -background #ff8000 -command {HelpPdfEdit "Help/DisplayMenuDual.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but74" "Button1" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_3_0.but74 "$site_3_0.but74 Button $top all _vTclBalloon"
    bind $site_3_0.but74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help}
    }
    button $site_3_0.but27 \
        -background #ffff00 \
        -command {global Load_CreateBMPFile Load_CreateHSLFile Load_CreateRGBFile
global Load_CreateRGBDualFile Load_CreateRGBDualFile_PP Load_CreateRGBFile_PP
global PVMainMenu PVProcessShortcut BMPImageOpen OpenDirFile

if {$Load_CreateBMPFile == 1} { Window hide $widget(Toplevel43) }
if {$Load_CreateHSLFile == 1} { Window hide $widget(Toplevel69) }
if {$Load_CreateRGBFile == 1} { Window hide $widget(Toplevel39) }
if {$Load_CreateRGBDualFile == 1} { Window hide $widget(Toplevel309) }
if {$Load_CreateRGBDualFile_PP == 1} { Window hide $widget(Toplevel439) }
if {$Load_CreateRGBFile_PP == 1} { Window hide $widget(Toplevel201) }

if {$OpenDirFile == 0} {
    if {$PVProcessShortcut == 1} {
        set PVProcessShortcut 0
        ClosePSPViewerProcess
        if {$BMPImageOpen == 0} {
            Window hide $widget(Toplevel64p); TextEditorRunTrace "Close Window PolSARpro Viewer - Process" "b"
            if {$PVMainMenu == 1} {
                set PVMainMenu 0
                Window show $widget(Toplevel2)
                }
            }
        }
    }

$widget(Menubutton308_1) configure -state normal
$widget(Menubutton308_2) configure -state normal
$widget(Menubutton308_3) configure -state normal
Window hide $widget(Toplevel308); TextEditorRunTrace "Close Window Display Menu Dual" "b"} \
        -padx 4 -pady 2 -text Exit -width 4 
    vTcl:DefineAlias "$site_3_0.but27" "Button35" vTcl:WidgetProc "Toplevel308" 1
    bindtags $site_3_0.but27 "$site_3_0.but27 Button $top all _vTclBalloon"
    bind $site_3_0.but27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit Display Menu}
    }
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab53 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra83 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra68 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra26 \
        -in $top -anchor center -expand 1 -fill x -side bottom 

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
Window show .top308

main $argc $argv
