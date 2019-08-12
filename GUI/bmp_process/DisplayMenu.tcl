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
    set base .top214
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab53 {
        array set save {-_tooltip 1 -image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.but66 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd68 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd44 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd70 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd70
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-borderwidth 1 -command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-borderwidth 1 -command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -padx 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-_tooltip 1 -command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.lab66 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-borderwidth 1 -height 1 -padx 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd74
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-_tooltip 1 -command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.lab66 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-borderwidth 1 -height 1 -padx 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd75
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-_tooltip 1 -command 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.lab66 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$base.fra26 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra26
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
            vTclWindow.top214
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

proc vTclWindow.top214 {base} {
    if {$base == ""} {
        set base .top214
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
    wm geometry $top 150x460+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Display"
    vTcl:DefineAlias "$top" "Toplevel214" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab53 \
        \
        -image [vTcl:image:get_image [file join . GUI Images DisplayMenu.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$top.lab53" "Label171" vTcl:WidgetProc "Toplevel214" 1
    bindtags $top.lab53 "$top.lab53 Label $top all _vTclBalloon"
    bind $top.lab53 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP 1.4}
    }
    button $top.but66 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2 ValidMaskFile ValidMaskColor
global ActiveProgram ColorMap ColorMapFile CONFIGDir
global InputFormat OutputFormat BMPOutputFormat BMPFileInput BMPFileOutput BMPFileOutputTmp
global MinMaxAutoBMP MinMaxContrastBMP MinBMP MaxBMP MinCBMP MaxCBMP
global BMPDirOutput BMPDirInput
#BMP PROCESS
global Load_CreateBMPFile PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_CreateBMPFile == 0} {
        source "GUI/bmp_process/CreateBMPFile.tcl"
        set Load_CreateBMPFile 1
        WmTransient $widget(Toplevel43) $PSPTopLevel
        }

    set InputFormat "float"
    set OutputFormat "real"
    set BMPOutputFormat "bmp8"
    set BMPFileInput " "
    set BMPFileOutput " "
    set BMPFileOutputTmp " "
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
    set MinCBMP " "; set MaxCBMP " "
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    set ConfigFile ""

    if {$DataFormatActive == "S2" || $DataFormatActive == "SPP"} {
        set BMPDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)" }
        set InputFormat "cmplx"
        set OutputFormat "mod"
        }
    if {$DataFormatActive == "C2"} {
        set BMPDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "C3"} {
        set BMPDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set BMPDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set BMPDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set BMPDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "IPP"} {
        set BMPDirInput $DataDir
        }

    set BMPDirOutput $BMPDirInput

    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel43); TextEditorRunTrace "Open Window Create BMP File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }


# Config Format
}
}} \
        -pady 0 -text {Create BMP File} 
    vTcl:DefineAlias "$top.but66" "Button4" vTcl:WidgetProc "Toplevel214" 1
    button $top.cpd67 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram DataDir DataDirMult RGBFunction
global RGBFileInput RGBFileOutput FileInputBlue FileInputGreen FileInputRed
global FileOutput RGBFormat RGBCCCE Channel1 Channel2 RGBDirOutput RGBDirInput
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global MinMaxAutoRGB
#BMP PROCESS
global Load_CreateRGBFile Load_CreateRGBFile_PP PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$DataFormatActive == "S2" || $DataFormatActive == "C3" || $DataFormatActive == "T3" || $DataFormatActive == "C4" || $DataFormatActive == "T4"} {

    if {$Load_CreateRGBFile == 0} {
        source "GUI/bmp_process/CreateRGBFile.tcl"
        set Load_CreateRGBFile 1
        WmTransient $widget(Toplevel39) $PSPTopLevel
        }

    set RGBFileInput " "
    set RGBFileOutput " "
    set FileInputBlue " "
    set FileInputGreen " "
    set FileInputRed " "
    set FileOutput " "
    set RGBFormat " "
    set RGBCCCE "independant"
    set ConfigFile ""

    set MinMaxAutoRGB "1"
    $widget(TitleFrame39_1) configure -state disable
    $widget(TitleFrame39_2) configure -state disable
    $widget(TitleFrame39_3) configure -state disable
    $widget(Label39_1) configure -state disable
    $widget(Entry39_1) configure -state disable
    $widget(Label39_2) configure -state disable
    $widget(Entry39_2) configure -state disable
    $widget(Label39_3) configure -state disable
    $widget(Entry39_3) configure -state disable
    $widget(Label39_4) configure -state disable
    $widget(Entry39_4) configure -state disable
    $widget(Label39_5) configure -state disable
    $widget(Entry39_5) configure -state disable
    $widget(Label39_6) configure -state disable
    $widget(Entry39_6) configure -state disable
    $widget(Button39_1) configure -state disable
    $widget(Button39_2) configure -state normal
    set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
    set RGBMinRed "Auto"; set RGBMaxRed "Auto"
    set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"

    if {$DataFormatActive == "S2"} {
        set RGBFunction "S2"
        set RGBDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set RGBDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C3"} {
        set RGBFunction "C3"
        set RGBDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set RGBFunction "T3"
        set RGBDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set RGBDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set RGBFunction "C4"
        set RGBDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set RGBFunction "T4"
        set RGBDirInput "$DataDir/T4"
        }

    set RGBDirOutput $RGBDirInput

    set ConfigFile "$RGBDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel39); TextEditorRunTrace "Open Window Create RGB File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
}

if {$DataFormatActive == "C2" || $DataFormatActive == "SPP"} {

    if {$Load_CreateRGBFile_PP == 0} {
        source "GUI/bmp_process/CreateRGBFile_PP.tcl"
        set Load_CreateRGBFile_PP 1
        WmTransient $widget(Toplevel201) $PSPTopLevel
        }

    set RGBFileInput " "
    set RGBFileOutput " "
    set FileInputBlue " "
    set FileInputGreen " "
    set FileInputRed " "
    set FileOutput " "
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

    if {$DataFormatActive == "C2"} {
        set RGBFunction "C2"
        set RGBDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set RGBDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "SPP"} {
        set RGBFunction "SPP"
        set RGBDirInput "$DataDir"
        if {$ActiveProgram == "POLMULT"} { set RGBDirInput "$DataDirMult(1)" }
        }

    set RGBDirOutput $RGBDirInput

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
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel201); TextEditorRunTrace "Open Window Create RGB File PP" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
}

if {$DataFormatActive == "IPP"} {

    if {$Load_CreateRGBFile == 0} {
        source "GUI/bmp_process/CreateRGBFile.tcl"
        set Load_CreateRGBFile 1
        WmTransient $widget(Toplevel39) $PSPTopLevel
        }
    if {$Load_CreateRGBFile_PP == 0} {
        source "GUI/bmp_process/CreateRGBFile_PP.tcl"
        set Load_CreateRGBFile_PP 1
        WmTransient $widget(Toplevel201) $PSPTopLevel
        }

    set RGBFunction "SPP"
    set RGBDirInput "$DataDir"
    set RGBDirOutput $RGBDirInput

    set ConfigFile "$RGBDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        set configPP "yes"
        if { "$PolarType" == "pp4"} { set configPP "no" }
        if { "$PolarType" == "full"} { set configPP "no" }
        if { $configPP == "yes"} {
            if {$ActiveProgram == "ASAR"} {
                if { "$PolarType" == "pp1"} {
                    set Channel1 "I11"
                    set Channel2 "I21"
                    }
                if { "$PolarType" == "pp2"} {
                    set Channel1 "I22"
                    set Channel2 "I12"
                    }
                if { "$PolarType" == "pp3"} {
                    set Channel1 "I11"
                    set Channel2 "I22"
                    }
                }
            if { "$PolarType" == "pp5"} {
                set Channel1 "I11"
                set Channel2 "I21"
                }
            if { "$PolarType" == "pp6"} {
                set Channel1 "I22"
                set Channel2 "I12"
                }
            if { "$PolarType" == "pp7"} {
                set Channel1 "I11"
                set Channel2 "I22"
                }
            set RGBFileInput " "
            set RGBFileOutput " "
            set FileInputBlue " "
            set FileInputGreen " "
            set FileInputRed " "
            set FileOutput " "
            set RGBFormat " "
            set RGBCCCE "independant"
            $widget(Radiobutton201_1) configure -state disable
            $widget(Radiobutton201_2) configure -state disable
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
            WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel201); TextEditorRunTrace "Open Window Create RGB File PP" "b"
            } else {
            if { "$PolarType" == "pp4"} { set RGBFunction "I4" }
            if { "$PolarType" == "full"} { set RGBFunction "I2" }
            set RGBFormat "sinclair"
            set RGBFileOutput "$RGBDirOutput/SinclairRGB.bmp"
            set FileInputBlue "I11"
            if { "$PolarType" == "pp4"} { set FileInputGreen "I12"}
            if { "$PolarType" == "full"} { set FileInputGreen "I12+I21"}
            set FileInputRed "I22"
            set RGBCCCE "independant"
            set MinMaxAutoRGB "1"
            $widget(TitleFrame39_1) configure -state disable
            $widget(TitleFrame39_2) configure -state disable
            $widget(TitleFrame39_3) configure -state disable
            $widget(Label39_1) configure -state disable
            $widget(Entry39_1) configure -state disable
            $widget(Label39_2) configure -state disable
            $widget(Entry39_2) configure -state disable
            $widget(Label39_3) configure -state disable
            $widget(Entry39_3) configure -state disable
            $widget(Label39_4) configure -state disable
            $widget(Entry39_4) configure -state disable
            $widget(Label39_5) configure -state disable
            $widget(Entry39_5) configure -state disable
            $widget(Label39_6) configure -state disable
            $widget(Entry39_6) configure -state disable
            $widget(Button39_1) configure -state disable
            $widget(Button39_2) configure -state normal
            set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
            set RGBMinRed "Auto"; set RGBMaxRed "Auto"
            set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"
            WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel39); TextEditorRunTrace "Open Window Create RGB File" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
}

# Config Format
}} \
        -pady 0 -text {Create RGB File} 
    vTcl:DefineAlias "$top.cpd67" "Button5" vTcl:WidgetProc "Toplevel214" 1
    button $top.cpd68 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram DataDir DataDirMult
global HSVFileInput HSVFileOutput FileInputHue FileInputSat FileInputVal FileOutput
global HSVFormat HSVCCCE HSVDirOutput HSVDirInput
global HSVMinHue HSVMaxHue HSVMinSat HSVMaxSat HSVMinVal HSVMaxVal
global MinMaxAutoHSV
#BMP PROCESS
global Load_CreateHSLFile PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$DataFormatActive == "S2" || $DataFormatActive == "C3" || $DataFormatActive == "T3" || $DataFormatActive == "C4" || $DataFormatActive == "T4"} {
    set configformat "true"
    } else {
    set WarningMessage "FUNCTIONALITY NOT AVAILABLE FOR THIS"
    set WarningMessage2 "INPUT POLARIMETRIC DATA FORMAT"
    set VarWarning ""
    Window show $widget(Toplevel388); TextEditorRunTrace "Open Window Advice Warning" "b"
    tkwait variable VarWarning
    set VarWarning ""
    set configformat "false"
    }

if {$configformat == "true"} {

    if {$Load_CreateHSLFile == 0} {
        source "GUI/bmp_process/CreateHSLFile.tcl"
        set Load_CreateHSLFile 1
        WmTransient $widget(Toplevel69) $PSPTopLevel
        }

    set HSVFileInput " "
    set HSVFileOutput " "
    set FileInputHue " "
    set FileInputSat " "
    set FileInputVal " "
    set FileOutput " "
    set HSVFormat " "
    set HSVCCCE "independant"
    set ConfigFile ""

    set MinMaxAutoHSV "1"
    $widget(TitleFrame69_1) configure -state disable
    $widget(TitleFrame69_2) configure -state disable
    $widget(TitleFrame69_3) configure -state disable
    $widget(Label69_1) configure -state disable
    $widget(Entry69_1) configure -state disable
    $widget(Label69_2) configure -state disable
    $widget(Entry69_2) configure -state disable
    $widget(Label69_3) configure -state disable
    $widget(Entry69_3) configure -state disable
    $widget(Label69_4) configure -state disable
    $widget(Entry69_4) configure -state disable
    $widget(Label69_5) configure -state disable
    $widget(Entry69_5) configure -state disable
    $widget(Label69_6) configure -state disable
    $widget(Entry69_6) configure -state disable
    $widget(Button69_1) configure -state disable
    $widget(Button69_2) configure -state normal
    set HSVMinHue "Auto"; set HSVMaxHue "Auto"
    set HSVMinSat "Auto"; set HSVMaxSat "Auto"
    set HSVMinVal "Auto"; set HSVMaxVal "Auto"
    $widget(Checkbutton69_1) configure -state normal

    if {$DataFormatActive == "S2"} {
        set HSVDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set HSVDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C3"} {
        set HSVDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set HSVDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set HSVDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set HSVDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set HSVDirInput "$DataDir/T4"
        }

    set HSVDirOutput $HSVDirInput

    set ConfigFile "$HSVDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel69); TextEditorRunTrace "Open Window Create HSL File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
}

# Config Format
}} \
        -pady 0 -text {Create HSL File} 
    vTcl:DefineAlias "$top.cpd68" "Button6" vTcl:WidgetProc "Toplevel214" 1
    button $top.cpd44 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram DataDir DataDirMult 
global RGBFileInput RGBFileOutput FileInputOdd FileInputDbl FileInputVol FileInputHlx
global FileOutput RGBFormat RGBDirOutput RGBDirInput
global RGBvl RGBlv RGBlab RGBbin

#BMP PROCESS
global Load_CreateCIEFile PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

    if {$Load_CreateCIEFile == 0} {
        source "GUI/bmp_process/CreateCIEFile.tcl"
        set Load_CreateCIEFile 1
        WmTransient $widget(Toplevel30) $PSPTopLevel
        }

    set RGBFileOutput " "
    set FileInputOdd " "
    set FileInputDbl " "
    set FileInputVol " "
    set FileInputHlx " "
    set RGBFormat " "
    set ConfigFile ""
    set RGBvl " "; set RGBlv " "
    set RGBlab " "; set RGBbin " "

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

    set RGBDirInput $DataDir
    if {$DataFormatActive == "S2"} {
        set RGBDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set RGBDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C3"} {
        set RGBDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set RGBDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set RGBDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set RGBDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set RGBDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "C2"} {
        set RGBDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set RGBDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "SPP"} {
        set RGBDirInput "$DataDir"
        if {$ActiveProgram == "POLMULT"} { set RGBDirInput "$DataDirMult(1)" }
        }
    set RGBDirOutput $RGBDirInput

    set ConfigFile "$RGBDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel30); TextEditorRunTrace "Open Window Create CIE-Lab RGB File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    # Config Format
    }} \
        -pady 0 -text {Create CIE-Lab RGB File} 
    vTcl:DefineAlias "$top.cpd44" "Button15" vTcl:WidgetProc "Toplevel214" 1
    button $top.cpd73 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram DataDir DataDirMult ColorMap ColorMapFile CONFIGDir
global ReducFactor TranspColor DisplayGoogleEarth
global BMPFileInput BMPFileOutput BMPFileOutputTmp
global BMPDirInput BMPDirOutput MapInfoGeocoding BMPGearthPolyFile
global NLigBMPColor NColBMPColor NColorBMPColor

#BMP PROCESS
global Load_CreateBMPKMLFile PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_CreateBMPKMLFile == 0} {
        source "GUI/bmp_process/CreateBMPKMLFile.tcl"
        set Load_CreateBMPKMLFile 1
        WmTransient $widget(Toplevel397) $PSPTopLevel
        }

    set BMPDirInput " "
    set BMPDirOutput " "
    set BMPFileInput " "
    set BMPFileOutput " "
    set BMPFileOutputTmp " "
    set ReducFactor 2; set TranspColor 2; set DisplayGoogleEarth 0
    set BMPGearthPolyFile " "
    set NLigBMPColor " "; set NColBMPColor " "; set NColorBMPColor " "
    set ConfigFile ""

    if {$DataFormatActive == "S2" || $DataFormatActive == "SPP"} {
        set BMPDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C2"} {
        set BMPDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "C3"} {
        set BMPDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set BMPDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set BMPDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set BMPDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "IPP"} {
        set BMPDirInput $DataDir
        }

    set BMPDirOutput $BMPDirInput

    if [file exists "$BMPDirInput/config_mapinfo.txt"] {
        set BMPGearthPolyFile "ENTER THE GEARTH_POLY.kml FILE"
        set ConfigFile "$BMPDirInput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {   
            WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel397); TextEditorRunTrace "Open Window Create BMP - KML File" "b"
            } else {
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        } else {
        set ErrorMessage "DATA MUST BE GEOCODED FIRST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set ErrorMessage ""
        set BMPDirInput " "
        set BMPDirOutput " "
        }

# Config Format
}
}} \
        -pady 0 -text {Create KML File} 
    vTcl:DefineAlias "$top.cpd73" "Button13" vTcl:WidgetProc "Toplevel214" 1
    button $top.cpd66 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram ColorMap ColorMapFile CONFIGDir
global GIFAnimDirInput GIFAnimDirOutput GIFAnimGIFFile
global GIFAnimBMPFileList NGIFAnimBMPFile GIFAnimBMPFile
global OpenDirFile NGIFAnimBMPFileActive
#BMP PROCESS
global Load_CreateAnimGIF PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_CreateAnimGIF == 0} {
        source "GUI/bmp_process/CreateAnimGIF.tcl"
        set Load_CreateAnimGIF 1
        WmTransient $widget(Toplevel405) $PSPTopLevel
        }

    set GIFAnimBMPFile " "
    set GIFAnimGIFFile " "

    set ConfigFile ""
    if {$DataFormatActive == "S2" || $DataFormatActive == "SPP"} {
        set GIFAnimDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set GIFAnimDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C2"} {
        set GIFAnimDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set GIFAnimDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "C3"} {
        set GIFAnimDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set GIFAnimDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set GIFAnimDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set GIFAnimDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set GIFAnimDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "IPP"} {
        set GIFAnimDirInput $DataDir
        }

    set GIFAnimDirOutput $GIFAnimDirInput
    set GIFAnimGIFFile "$GIFAnimDirOutput/animated_gif.gif"
    set GIFAnimBMPFile "???"

    set NGIFAnimBMPFile 1
    set NGIFAnimBMPFileActive 1
    for {set i 0} {$i <= 100} {incr i} {set GIFAnimBMPFileList($i) "???"}

    set ConfigFile "$GIFAnimDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel405); TextEditorRunTrace "Open Window Create Animated GIF File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }


# Config Format
}
}} \
        -pady 0 -text {Create Anim GIF File} 
    vTcl:DefineAlias "$top.cpd66" "Button9" vTcl:WidgetProc "Toplevel214" 1
    frame $top.cpd70 \
        -borderwidth 2 -relief raised -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd70" "Frame5" vTcl:WidgetProc "Toplevel214" 1
    set site_3_0 $top.cpd70
    button $site_3_0.cpd71 \
        -borderwidth 0 \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram DataDir DataDirMult 
global BMPDirInput BMPDirOutput BMPOutputFile
global NColorBMPGray NColorBMPColor
global NLigBMPGray NLigBMPColor NLigBMPMask NColBMPGray NColBMPColor NColBMPMask
global BMPFileInputGray BMPFileInputColor BMPFileInputMask BMPInvertMask
#BMP PROCESS
global Load_CreateGrayColorBMPFile PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_CreateGrayColorBMPFile  == 0} {
        source "GUI/bmp_process/CreateGrayColorBMPFile.tcl"
        set Load_CreateGrayColorBMPFile 1
        WmTransient $widget(Toplevel384) $PSPTopLevel
        }

    set NColorBMPGray " "; set NColorBMPColor " "; set BMPOutputFile " "
    set NLigBMPGray " "; set NLigBMPColor " "; set NLigBMPMask " "; set NColBMPGray " "; set NColBMPColor " "; set NColBMPMask " "
    set BMPFileInputGray " "; set BMPFileInputColor " "; set BMPFileInputMask " "; set BMPInvertMask 0
    $widget(Button384_1) configure -state disable
    set ConfigFile ""

    if {$DataFormatActive == "S2" || $DataFormatActive == "SPP"} {
        set BMPDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C2"} {
        set BMPDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "C3"} {
        set BMPDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set BMPDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set BMPDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set BMPDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "IPP"} {
        set BMPDirInput $DataDir
        }

    set BMPDirOutput $BMPDirInput

    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel384); TextEditorRunTrace "Open Window Create Gray & Color BMP File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }


# Config Format
}
}} \
        -pady 0 -relief flat -text {Create Gray &} 
    vTcl:DefineAlias "$site_3_0.cpd71" "Button7" vTcl:WidgetProc "Toplevel214" 1
    button $site_3_0.cpd72 \
        -borderwidth 0 \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram DataDir DataDirMult 
global BMPDirInput BMPDirOutput BMPOutputFile
global NColorBMPGray NColorBMPColor
global NLigBMPGray NLigBMPColor NLigBMPMask NColBMPGray NColBMPColor NColBMPMask
global BMPFileInputGray BMPFileInputColor BMPFileInputMask BMPInvertMask
#BMP PROCESS
global Load_CreateGrayColorBMPFile PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_CreateGrayColorBMPFile  == 0} {
        source "GUI/bmp_process/CreateGrayColorBMPFile.tcl"
        set Load_CreateGrayColorBMPFile 1
        WmTransient $widget(Toplevel384) $PSPTopLevel
        }

    set NColorBMPGray " "; set NColorBMPColor " "; set BMPOutputFile " "
    set NLigBMPGray " "; set NLigBMPColor " "; set NLigBMPMask " "; set NColBMPGray " "; set NColBMPColor " "; set NColBMPMask " "
    set BMPFileInputGray " "; set BMPFileInputColor " "; set BMPFileInputMask " "; set BMPInvertMask 0
    $widget(Button384_1) configure -state disable
    set ConfigFile ""

    if {$DataFormatActive == "S2" || $DataFormatActive == "SPP"} {
        set BMPDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C2"} {
        set BMPDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "C3"} {
        set BMPDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set BMPDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set BMPDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set BMPDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "IPP"} {
        set BMPDirInput $DataDir
        }

    set BMPDirOutput $BMPDirInput

    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel384); TextEditorRunTrace "Open Window Create Gray & Color BMP File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }


# Config Format
}
}} \
        -pady 0 -relief flat -text {Color BMP File} 
    vTcl:DefineAlias "$site_3_0.cpd72" "Button8" vTcl:WidgetProc "Toplevel214" 1
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    button $top.cpd69 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram ColorMap ColorMapFile CONFIGDir
global ScatterPlotFileInputX ScatterPlotFileMaskX
global MinMaxAutoScatterPlotX MinMaxContrastScatterPlotX
global InputFormatX OutputFormatX MinScatterPlotX MaxScatterPlotX MinCScatterPlotX MaxCScatterPlotX
global ScatterPlotFileInputY ScatterPlotFileMaskY
global MinMaxAutoScatterPlotY MinMaxContrastScatterPlotY
global InputFormatY OutputFormatY MinScatterPlotY MaxScatterPlotY MinCScatterPlotY MaxCScatterPlotY
global ScatterPlotDirOutput ScatterPlotDirInput
global ScatterPlotLabelX ScatterPlotLabelY ScatterPlotTitle
#ScatterPlot PROCESS
global Load_CreateScatterPlot PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_CreateScatterPlot == 0} {
        source "GUI/bmp_process/CreateScatterPlot.tcl"
        set Load_CreateScatterPlot 1
        WmTransient $widget(Toplevel407) $PSPTopLevel
        }

    set InputFormatX "float"; set OutputFormatX "real"
    set InputFormatY "float"; set OutputFormatY "real"
    set MinMaxAutoScatterPlotX 1; set MinMaxContrastScatterPlotX 0
    set MinMaxAutoScatterPlotY 1; set MinMaxContrastScatterPlotY 0
    set MinScatterPlotX "Auto"; set MaxScatterPlotX "Auto"
    set MinCScatterPlotX " "; set MaxCScatterPlotX " "
    set MinScatterPlotY "Auto"; set MaxScatterPlotY "Auto"
    set MinCScatterPlotY " "; set MaxCScatterPlotY " "

    set ScatterPlotFileInputX " "; set ScatterPlotFileInputY " "
    set ScatterPlotFileOutput " "

    set ScatterPlotLabelX "Label X"
    set ScatterPlotLabelY "Label Y"
    set ScatterPlotTitle "Title"
    
    $widget(Label407_1) configure -state disable
    $widget(Entry407_1) configure -state disable
    $widget(Label407_2) configure -state disable
    $widget(Entry407_2) configure -state disable
    $widget(Label407_3) configure -state disable
    $widget(Entry407_3) configure -state disable
    $widget(Entry407_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label407_4) configure -state disable
    $widget(Entry407_4) configure -state disable
    $widget(Entry407_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button407_1) configure -state disable
    $widget(Label407_5) configure -state disable
    $widget(Entry407_5) configure -state disable
    $widget(Label407_6) configure -state disable
    $widget(Entry407_6) configure -state disable
    $widget(Label407_7) configure -state disable
    $widget(Entry407_7) configure -state disable
    $widget(Entry407_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Label407_8) configure -state disable
    $widget(Entry407_8) configure -state disable
    $widget(Entry407_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Button407_2) configure -state disable
    $widget(Button407_3) configure -state disable
    $widget(Button407_4) configure -state disable

    set ConfigFile ""
    if {$DataFormatActive == "S2" || $DataFormatActive == "SPP"} {
        set ScatterPlotDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set ScatterPlotDirInput "$DataDirMult(1)" }
        set InputFormatX "cmplx"; set OutputFormatX "mod"
        set InputFormatY "cmplx"; set OutputFormatY "mod"
        }
    if {$DataFormatActive == "C2"} {
        set ScatterPlotDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set ScatterPlotDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "C3"} {
        set ScatterPlotDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set ScatterPlotDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set ScatterPlotDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set ScatterPlotDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set ScatterPlotDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "IPP"} {
        set ScatterPlotDirInput $DataDir
        }

    set ScatterPlotDirOutput $ScatterPlotDirInput
    set ScatterPlotFileOutput " "

    set ConfigFile "$ScatterPlotDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel407); TextEditorRunTrace "Open Window Create Scatter Plot File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }


# Config Format
}
}} \
        -pady 0 -text {Create Scatter Plot} 
    vTcl:DefineAlias "$top.cpd69" "Button10" vTcl:WidgetProc "Toplevel214" 1
    button $top.cpd72 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram ColorMap ColorMapFile CONFIGDir
global PTOMDisplayFileInput PTOMDisplayFileMask
global MinMaxAutoPTOMDisplay MinMaxContrastPTOMDisplay MinMaxNormalisationPTOMDisplay
global InputFormat OutputFormat MinPTOMDisplay MaxPTOMDisplay MinCPTOMDisplay MaxCPTOMDisplay
global PTOMNligInit PTOMNligEnd PTOMNcolInit PTOMNcolEnd PTOMNcolFullSize PTOMNligFullSize
global PTOMzdim PTOMxdim PTOMzmin PTOMzmax PTOMxmin PTOMxmax 
global PTOMDisplayDirOutput PTOMDisplayDirInput PTOMDisplayZGroundFile PTOMDisplayZTopFile
global PTOMDisplayLabelX PTOMDisplayLabelY PTOMDisplayTitle
global PTOMProcessDirInput PTOMProcessDirOutput
global PTOMGifCol PTOMGifLig

#PTOMDisplay PROCESS
global Load_CreatePolTomoDisplay PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_CreatePolTomoDisplay == 0} {
        source "GUI/bmp_process/CreatePolTomoDisplay.tcl"
        set Load_CreatePolTomoDisplay 1
        WmTransient $widget(Toplevel528) $PSPTopLevel
        }

    set InputFormat "float"; set OutputFormat "real"
    set MinMaxAutoPTOMDisplay 1; set MinMaxContrastPTOMDisplay 0
    set MinMaxNormalisationPTOMDisplay 0
    set MinPTOMDisplay "Auto"; set MaxPTOMDisplay "Auto"
    set MinCPTOMDisplay " "; set MaxCPTOMDisplay " "

    set PTOMNligInit " "; set PTOMNligEnd " "
    set PTOMNcolInit " "; set PTOMNcolEnd " "
    set PTOMNcolFullSize " "; set PTOMNligFullSize " "
    set PTOMzdim " "; set PTOMxdim " "
    set PTOMzmin "?"; set PTOMzmax "?"
    set PTOMxmin "?"; set PTOMxmax "?"

    set PTOMDisplayFileInput " "; set PTOMDisplayFileOutput " "
    set PTOMDisplayZGroundFile " "; set PTOMDisplayZTopFile " "

    set PTOMDisplayLabelX "X axis label"
    set PTOMDisplayLabelY "Y axis label"
    set PTOMDisplayTitle "Title of the Tomogram"

    set PTOMGifCol 1280; set PTOMGifLig 480
    
    $widget(Label528_1) configure -state disable
    $widget(Entry528_1) configure -state disable
    $widget(Label528_2) configure -state disable
    $widget(Entry528_2) configure -state disable
    $widget(Label528_3) configure -state disable
    $widget(Entry528_3) configure -state disable
    $widget(Entry528_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label528_4) configure -state disable
    $widget(Entry528_4) configure -state disable
    $widget(Entry528_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button528_1) configure -state disable
    $widget(Button528_3) configure -state disable
    $widget(Button528_4) configure -state disable
    $widget(Checkbutton528_1) configure -state normal
    $widget(Checkbutton528_2) configure -state normal

    set ConfigFile " "
    if {$DataFormatActive == "S2" || $DataFormatActive == "SPP"} {
        set PTOMDisplayDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set PTOMDisplayDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C2"} {
        set PTOMDisplayDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set PTOMDisplayDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "C3"} {
        set PTOMDisplayDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set PTOMDisplayDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set PTOMDisplayDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set PTOMDisplayDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set PTOMDisplayDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "IPP"} {
        set PTOMDisplayDirInput $DataDir
        }

    set PTOMDisplayDirOutput $PTOMDisplayDirInput
    set PTOMDisplayFileOutput " "

    set ConfigFile "$PTOMDisplayDirInput/config.txt"
    set ErrorMessage " "
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel528); TextEditorRunTrace "Open Window Create Tomogram Display File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }


# Config Format
}
}} \
        -pady 0 -text {Create Tomogram Display} 
    vTcl:DefineAlias "$top.cpd72" "Button12" vTcl:WidgetProc "Toplevel214" 1
    button $top.cpd71 \
        \
        -command {global DataDir DataDirMult FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram DataDir DataDirMult 
global BMPDirInput BMPDirOutput BMPFileInput BMPFileOutput BMPFileOutputTmp
global NColorBMPColor NLigBMPColor NColBMPColor BMPOutputFormat
global BMPFileInputColor BMPFileOutputColorBIN BMPFileOutputColorPAL BMPFileOutputColorBMP
global BMPWorldFile BMPFileOutput BMPFileOutputWF BMPGearthPolyFile BMPConfAcqFile
global ReducFactor TranspColor DisplayGoogleEarth

#BMP PROCESS
global Load_ConvertBMPFile PSPTopLevel

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    } else {

if {$configformat == "true"} {

    if {$Load_ConvertBMPFile  == 0} {
        source "GUI/bmp_process/ConvertBMPFile.tcl"
        set Load_ConvertBMPFile 1
        WmTransient $widget(Toplevel450) $PSPTopLevel
        }

    set BMPDirInput " "
    set BMPDirOutput " "
    set BMPFileInput " "
    set BMPFileOutput " "
    set BMPFileOutputTmp " "; set BMPOutputFormat " "
    set ReducFactor " "; set TranspColor " "; 
    set NLigBMPColor " "; set NColBMPColor " "; set NColorBMPColor " "
    set BMPFileOutputWF " "; set BMPGearthPolyFile " "; set BMPConfAcqFile " "; set BMPWorldFile 0    
    set BMPFileInputColor " "; set BMPFileOutputColorBIN " "; set BMPFileOutputColorPAL " "; set BMPFileOutputColorBMP " "
    set ConfigFile ""

    if {$DataFormatActive == "S2" || $DataFormatActive == "SPP"} {
        set BMPDirInput $DataDir
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)" }
        }
    if {$DataFormatActive == "C2"} {
        set BMPDirInput "$DataDir/C2"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/C2" }
        }
    if {$DataFormatActive == "C3"} {
        set BMPDirInput "$DataDir/C3"
        }
    if {$DataFormatActive == "T3"} {
        set BMPDirInput "$DataDir/T3"
        if {$ActiveProgram == "POLMULT"} { set BMPDirInput "$DataDirMult(1)/T3" }
        }
    if {$DataFormatActive == "C4"} {
        set BMPDirInput "$DataDir/C4"
        }
    if {$DataFormatActive == "T4"} {
        set BMPDirInput "$DataDir/T4"
        }
    if {$DataFormatActive == "IPP"} {
        set BMPDirInput $DataDir
        }

    set BMPDirOutput $BMPDirInput

    set ConfigFile "$BMPDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {   
        $widget(Label450_1) configure -state disable
        $widget(Radiobutton450_2) configure -state disable
        $widget(Radiobutton450_3) configure -state disable
        $widget(Radiobutton450_4) configure -state disable
        $widget(Label450_2) configure -state disable
        $widget(Button450_1) configure -state disable
        $widget(Button450_2) configure -state disable
        $widget(Entry450_1) configure -state disable
        $widget(Entry450_1) configure -disabledbackground $PSPBackgroundColor
        $widget(TitleFrame450_1) configure -state disable
        $widget(TitleFrame450_2) configure -state disable
        $widget(TitleFrame450_3) configure -state disable
        $widget(Button450_3) configure -state disable
        $widget(Button450_4) configure -state disable
        $widget(Entry450_2) configure -state disable
        $widget(Entry450_2) configure -disabledbackground $PSPBackgroundColor
        $widget(Entry450_3) configure -state disable
        $widget(Entry450_3) configure -disabledbackground $PSPBackgroundColor
        $widget(Entry450_4) configure -state disable
        $widget(Entry450_4) configure -disabledbackground $PSPBackgroundColor
        WidgetShowFromMenuFix $widget(Toplevel214) $widget(Toplevel450); TextEditorRunTrace "Open Window Convert BMP File" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }


# Config Format
}
}} \
        -pady 0 -text {Convert BMP File} 
    vTcl:DefineAlias "$top.cpd71" "Button11" vTcl:WidgetProc "Toplevel214" 1
    frame $top.fra71 \
        -borderwidth 2 -relief raised -height 75 -padx 2 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame4" vTcl:WidgetProc "Toplevel214" 1
    set site_3_0 $top.fra71
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
        -pady 0 -relief flat -text {Process 1 BMP File} 
    vTcl:DefineAlias "$site_3_0.but73" "Button3" vTcl:WidgetProc "Toplevel214" 1
    bindtags $site_3_0.but73 "$site_3_0.but73 Button $top all _vTclBalloon"
    bind $site_3_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP Viewer3.0}
    }
    label $site_3_0.lab66 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images PVv3shortcut.gif]] \
        -text label 
    vTcl:DefineAlias "$site_3_0.lab66" "Label1" vTcl:WidgetProc "Toplevel214" 1
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side right 
    pack $site_3_0.lab66 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.cpd74 \
        -borderwidth 2 -relief raised -height 75 -padx 2 -width 125 
    vTcl:DefineAlias "$top.cpd74" "Frame6" vTcl:WidgetProc "Toplevel214" 1
    set site_3_0 $top.cpd74
    button $site_3_0.but73 \
        \
        -command {global PVDisplayShortcut

if {$PVDisplayShortcut == 0} {
    set PVDisplayShortcut 1
    LoadPSPViewerDisplay
    Window show $widget(Toplevel64d); TextEditorRunTrace "Open Window PolSARpro Viewer - Display" "b"
    } else {
    set PVDisplayShortcut 0
    ClosePSPViewerDisplay
    Window hide $widget(Toplevel64d); TextEditorRunTrace "Close Window PolSARpro Viewer - Display" "b"
    }} \
        -pady 0 -relief flat -text {Display N BMP Files} 
    vTcl:DefineAlias "$site_3_0.but73" "Button14" vTcl:WidgetProc "Toplevel214" 1
    bindtags $site_3_0.but73 "$site_3_0.but73 Button $top all _vTclBalloon"
    bind $site_3_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP Viewer3.0}
    }
    label $site_3_0.lab66 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images PVv3shortcut.gif]] \
        -text label 
    vTcl:DefineAlias "$site_3_0.lab66" "Label2" vTcl:WidgetProc "Toplevel214" 1
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side right 
    pack $site_3_0.lab66 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.cpd75 \
        -borderwidth 2 -relief raised -height 75 -padx 2 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame8" vTcl:WidgetProc "Toplevel214" 1
    set site_3_0 $top.cpd75
    button $site_3_0.but73 \
        \
        -command {global MapAlgebraSatimFullPath PlatForm

set MapAlgebraSatimFullPath [pwd]
if {$PlatForm == "windows"} {
    append MapAlgebraSatimFullPath "/Soft/bin/map_algebra/win32/map_algebra_satim.exe"
    }
if {$PlatForm == "unix"} {
    append MapAlgebraSatimFullPath "/Soft/bin/map_algebra/linux/map_algebra_satim.exe"
    }
set MA_ID [ open "| \x22$MapAlgebraSatimFullPath\x22" r]
} \
        -pady 0 -relief flat -text {SATIM Map Algebra} 
    vTcl:DefineAlias "$site_3_0.but73" "Button16" vTcl:WidgetProc "Toplevel214" 1
    bindtags $site_3_0.but73 "$site_3_0.but73 Button $top all _vTclBalloon"
    bind $site_3_0.but73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP Viewer3.0}
    }
    label $site_3_0.lab66 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images PVv3shortcut.gif]] \
        -text label 
    vTcl:DefineAlias "$site_3_0.lab66" "Label4" vTcl:WidgetProc "Toplevel214" 1
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side right 
    pack $site_3_0.lab66 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra26 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra26" "Frame413" vTcl:WidgetProc "Toplevel214" 1
    set site_3_0 $top.fra26
    button $site_3_0.but27 \
        -background #ffff00 \
        -command {global Load_CreateBMPFile Load_CreateHSLFile Load_CreateRGBFile Load_CreateRGBFile_PP Load_CreateCIEFile
global Load_CreateBMPKMLFile Load_CreateGrayColorBMPFile 
global Load_CreateAnimGIF Load_CreateScatterPlot Load_ConvertBMPFile Load_CreatePolTomoDisplay 
global PVMainMenu PVDisplayShortcut PVProcessShortcut BMPImageOpen OpenDirFile

global GnuplotPipeFid

if {$Load_CreateBMPFile == 1} { Window hide $widget(Toplevel43) }
if {$Load_CreateHSLFile == 1} { Window hide $widget(Toplevel69) }
if {$Load_CreateRGBFile == 1} { Window hide $widget(Toplevel39) }
if {$Load_CreateCIEFile == 1} { Window hide $widget(Toplevel30) }
if {$Load_CreateRGBFile_PP == 1} { Window hide $widget(Toplevel201) }
if {$Load_CreateBMPKMLFile == 1} { Window hide $widget(Toplevel397) }
if {$Load_CreateGrayColorBMPFile == 1} { Window hide $widget(Toplevel384) }
if {$Load_CreateAnimGIF == 1} { Window hide $widget(Toplevel405) }
if {$Load_CreateScatterPlot == 1} { set GnuplotPipeFid ""; Window hide .top401; Window hide $widget(Toplevel407) }
if {$Load_CreatePolTomoDisplay == 1} { set GnuplotPipeFid ""; Window hide .top401tomo; Window hide $widget(Toplevel524) }
if {$Load_ConvertBMPFile == 1} { Window hide $widget(Toplevel450) }

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
    if {$PVDisplayShortcut == 1} {
        set PVDisplayShortcut 0
        ClosePSPViewerDisplay
        if {$BMPImageOpen == 0} {
            Window hide $widget(Toplevel64d); TextEditorRunTrace "Close Window PolSARpro Viewer - Display" "b"
            if {$PVMainMenu == 1} {
                set PVMainMenu 0
                Window show $widget(Toplevel2)
                }
            }
        }
    }

Window hide $widget(Toplevel214); TextEditorRunTrace "Close Window Display Menu" "b"} \
        -padx 4 -pady 2 -text Exit -width 4 
    vTcl:DefineAlias "$site_3_0.but27" "Button35" vTcl:WidgetProc "Toplevel214" 1
    bindtags $site_3_0.but27 "$site_3_0.but27 Button $top all _vTclBalloon"
    bind $site_3_0.but27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit Display Menu}
    }
    pack $site_3_0.but27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab53 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.but66 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd44 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd70 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra26 \
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
Window show .top214

main $argc $argv
