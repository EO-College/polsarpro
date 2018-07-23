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

        {{[file join . GUI Images PolSARap.gif]} {user image} user {}}

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
    set base .top530
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab66 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.but83 {
        array set save {-command 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-command 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.men66 {
        array set save {-menu 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.men66.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.but86 {
        array set save {-command 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.but87 {
        array set save {-command 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.but67 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top530
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
    wm geometry $top 200x200+88+88; update
    wm maxsize $top 1924 1065
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

proc vTclWindow.top530 {base} {
    if {$base == ""} {
        set base .top530
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
    wm geometry $top 130x280+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PolSAR-ap Showcase : Menu"
    vTcl:DefineAlias "$top" "Toplevel530" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
        -image [vTcl:image:get_image [file join . GUI Images PolSARap.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab66" "Label1" vTcl:WidgetProc "Toplevel530" 1
    button $top.but83 \
        \
        -command {global DataDir FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global PolSARapAgriDirInput PolSARapAgriOutputDir PolSARapAgriFonc PolSARapAgriFonction
global PolSARapAgriIncAngFile PolSARapAgriMaskFile PolSARapAgriFsFdFile PolSARapAgriAlphaBetaFile
global PolSARapAgriKsFile PolSARapAgriMvFile PolSARapAgriDcSoilFile PolSARapAgriDcTrunkFile
global PolSARapAgriNwinL PolSARapAgriNwinC PolSARapAgriUnit PolSARapAgriSurfSoil PolSARapAgriSurfLUT
global PolSARapAgriDihedSoil PolSARapAgriDihedTrunk PolSARapAgriDihedLUT
global PSPBackgroundColor

#POLSARAP
global Load_PolSARapAgriculture
global PSPTopLevel

if {$ActiveProgram == "POLSARPRO"} {

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$DataFormatActive == "SPP" || $DataFormatActive == "IPP"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$DataFormatActive == "C2" || $DataFormatActive == "T2"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$DataFormatActive == "C4" || $DataFormatActive == "T4"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }


if {$configformat == "true"} {

    if {$Load_PolSARapAgriculture == 0} {
        source "GUI/polsarap/PolSARapAgriculture.tcl"
        set Load_PolSARapAgriculture 1
        WmTransient $widget(Toplevel531) $PSPTopLevel
        }

    set ConfigFile ""

    set PolSARapAgriOutputDir $DataDir
    set PolSARapAgriDirOutput $DataDir

    if {$DataFormatActive == "S2"} {
        set PolSARapAgriDirInput $DataDir
        set PolSARapAgriOutputSubDir ""
        set BMPDirInput $PolSARapAgriDirOutput
        set PolSARapAgriFonction "S2"
        }       
    if { $DataFormatActive == "C3" } {
        set PolSARapAgriDirInput "$DataDir/C3"
        set PolSARapAgriOutputSubDir "C3"
        set BMPDirInput "$PolSARapAgriDirOutput/C3"
        set PolSARapAgriFonction "C3"
        }
    if { $DataFormatActive == "T3" } {
        set PolSARapAgriDirInput "$DataDir/T3"
        set PolSARapAgriOutputSubDir "T3"
        set BMPDirInput "$PolSARapAgriDirOutput/T3"
        set PolSARapAgriFonction "T3"
        }

    set PolSARapAgriFonc ""

    $widget(TitleFrame531_4) configure -text "Polarimetric Decomposition File"
    $widget(TitleFrame531_5) configure -text "Polarimetric Decomposition File"

    $widget(TitleFrame531_3) configure -state disable
    $widget(TitleFrame531_4) configure -state disable
    $widget(TitleFrame531_5) configure -state disable
    $widget(TitleFrame531_6) configure -state disable
    $widget(TitleFrame531_7) configure -state disable
    $widget(TitleFrame531_8) configure -state disable
    $widget(TitleFrame531_9) configure -state disable
    $widget(TitleFrame531_10) configure -state disable
    $widget(TitleFrame531_11) configure -state disable

    $widget(Label531_1) configure -state disable
    $widget(Label531_2) configure -state disable
    $widget(Label531_3) configure -state disable
    $widget(Label531_4) configure -state disable
    $widget(Label531_5) configure -state disable
    $widget(Label531_6) configure -state disable
    $widget(Label531_7) configure -state disable

    $widget(Button531_1) configure -state disable
    $widget(Button531_2) configure -state disable
    $widget(Button531_3) configure -state disable
    $widget(Button531_4) configure -state disable
    $widget(Button531_5) configure -state disable

    $widget(Radiobutton531_4) configure -state disable
    $widget(Radiobutton531_5) configure -state disable

    $widget(Entry531_1) configure -state disable
    $widget(Entry531_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_2) configure -state disable
    $widget(Entry531_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_3) configure -state disable
    $widget(Entry531_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_4) configure -state disable
    $widget(Entry531_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_5) configure -state disable
    $widget(Entry531_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_6) configure -state disable
    $widget(Entry531_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_7) configure -state disable
    $widget(Entry531_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_8) configure -state disable
    $widget(Entry531_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_9) configure -state disable
    $widget(Entry531_9) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_10) configure -state disable
    $widget(Entry531_10) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_11) configure -state disable
    $widget(Entry531_11) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_12) configure -state disable
    $widget(Entry531_12) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_13) configure -state disable
    $widget(Entry531_13) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_14) configure -state disable
    $widget(Entry531_14) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry531_15) configure -state disable
    $widget(Entry531_15) configure -disabledbackground $PSPBackgroundColor

    set PolSARapAgriIncAngFile ""
    set PolSARapAgriMaskFile ""
    set PolSARapAgriFsFdFile ""
    set PolSARapAgriAlphaBetaFile ""
    set PolSARapAgriKsFile ""
    set PolSARapAgriMvFile ""
    set PolSARapAgriDcSoilFile ""
    set PolSARapAgriDcTrunkFile ""
    set PolSARapAgriNwinL ""
    set PolSARapAgriNwinC ""
    set PolSARapAgriUnit ""
    set PolSARapAgriSurfSoil ""
    set PolSARapAgriSurfLUT ""
    set PolSARapAgriDihedSoil ""
    set PolSARapAgriDihedTrunk ""
    set PolSARapAgriDihedLUT ""

    if [file exists "$PolSARapAgriDirInput/config.txt"] {
        set ConfigFile "$PolSARapAgriDirInput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            WidgetShow $widget(Toplevel531); TextEditorRunTrace "Open Window PolSARap Showcase Agriculture" "b"
            } else {
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        } else {
        set ErrorMessage "ENTER A VALID DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    # Config Format
    }
# ActiveProgram
} else {
set ErrorMessage "PolSARpro IS NOT IN A SINGLE DATA SET MODE"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}} \
        -padx 4 -pady 2 -relief ridge -text Agriculture 
    vTcl:DefineAlias "$top.but83" "Button573" vTcl:WidgetProc "Toplevel530" 1
    button $top.cpd66 \
        \
        -command {global DataDirChannel1 DataDirChannel2 FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global PolSARapCryoMasterDirInput PolSARapCryoSlaveDirInput PolSARapCryoMasterSlaveDirInput
global PolSARapCryoDirInput PolSARapCryoDirOutput PolSARapCryoOutputDir PolSARapCryoOutputSubDir
global PolSARapCryoKzFile PolSARapCryoIncAngFile PolSARapCryoCohSNRFile PolSARapCryoCmplxCohFile PolSARapCryoSurfVolFile PolSARapCryoKappaFile PolSARapCryoDepthFile
global PolSARapCryoNwinL PolSARapCryoNwinC PolSARapCryoUnit PolSARapCryoNwinMedian PolSARapCryoIteration
global PolSARapCryoChannel PolSARapCryoDielectric PolSARapCryoDr PolSARapCryoThreshold PolSARapCryoFonc
global PSPBackgroundColor ActiveProgram

#POLSARAP
global Load_PolSARapCryosphere
global PSPTopLevel

if {$ActiveProgram == "POLINSAR"} {

set configformat ""

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$DataFormatActive == "SPP" || $DataFormatActive == "T4" || $DataFormatActive == "T6"} {
    set WarningMessage "FUNCTIONALITY NOT AVAILABLE FOR THIS"
    set WarningMessage2 "INPUT POLARIMETRIC DATA FORMAT"
    set VarWarning ""
    Window show $widget(Toplevel388); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    set VarWarning ""
    set configformat "false"
    }

if {$DataFormatActive == "S2"} {set configformat "true" }


if {$configformat == "true"} {


if {$Load_PolSARapCryosphere == 0} {
    source "GUI/polsarap/PolSARapCryosphere.tcl"
    set Load_PolSARapCryosphere 1
    WmTransient $widget(Toplevel532) $PSPTopLevel
    }

set ConfigFile ""

set PolSARapCryoMasterDirInput $DataDirChannel1
set PolSARapCryoSlaveDirInput $DataDirChannel2
set MasterSlaveOutputDir $DataDirChannel1
set DirTmp [file tail $DataDirChannel2]
append MasterSlaveOutputDir "_"
append MasterSlaveOutputDir $DirTmp

set PolSARapCryoOutputDir $MasterSlaveOutputDir 
set PolSARapCryoDirOutput $PolSARapCryoOutputDir
set PolSARapCryoOutputSubDir ""

set PolSARapCryoMasterSlaveDirInput $MasterSlaveOutputDir

set PolSARapCryoDirInput ""
$widget(TitleFrame532_1) configure -text ""

set PolSARapCryoFonc ""

$widget(TitleFrame532_2) configure -state disable
$widget(TitleFrame532_3) configure -state disable
$widget(TitleFrame532_4) configure -state disable
$widget(TitleFrame532_5) configure -state disable
$widget(TitleFrame532_6) configure -state disable
$widget(TitleFrame532_7) configure -state disable
$widget(TitleFrame532_8) configure -state disable
$widget(TitleFrame532_9) configure -state disable
$widget(TitleFrame532_10) configure -state disable
$widget(TitleFrame532_11) configure -state disable

$widget(Label532_1) configure -state disable
$widget(Label532_2) configure -state disable
$widget(Label532_3) configure -state disable
$widget(Label532_4) configure -state disable
$widget(Label532_5) configure -state disable
$widget(Label532_6) configure -state disable
$widget(Label532_7) configure -state disable

$widget(Button532_1) configure -state disable
$widget(Button532_2) configure -state disable
$widget(Button532_3) configure -state disable
$widget(Button532_4) configure -state disable
$widget(Button532_5) configure -state disable

$widget(Radiobutton532_1) configure -state disable
$widget(Radiobutton532_2) configure -state disable
$widget(Radiobutton532_3) configure -state disable
$widget(Radiobutton532_4) configure -state disable
$widget(Radiobutton532_5) configure -state disable

$widget(Entry532_1) configure -state disable
$widget(Entry532_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_2) configure -state disable
$widget(Entry532_2) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_3) configure -state disable
$widget(Entry532_3) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_4) configure -state disable
$widget(Entry532_4) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_5) configure -state disable
$widget(Entry532_5) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_6) configure -state disable
$widget(Entry532_6) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_7) configure -state disable
$widget(Entry532_7) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_8) configure -state disable
$widget(Entry532_8) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_9) configure -state disable
$widget(Entry532_9) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_10) configure -state disable
$widget(Entry532_10) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_11) configure -state disable
$widget(Entry532_11) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_12) configure -state disable
$widget(Entry532_12) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_13) configure -state disable
$widget(Entry532_13) configure -disabledbackground $PSPBackgroundColor
$widget(Entry532_14) configure -state disable
$widget(Entry532_14) configure -disabledbackground $PSPBackgroundColor

set PolSARapCryoKzFile ""
set PolSARapCryoIncAngFile ""
set PolSARapCryoCohSNRFile ""
set PolSARapCryoCmplxCohFile ""
set PolSARapCryoSurfVolFile ""
set PolSARapCryoKappaFile ""
set PolSARapCryoDepthFile ""
set PolSARapCryoNwinL ""
set PolSARapCryoNwinC ""
set PolSARapCryoUnit ""
set PolSARapCryoNwinMedian ""
set PolSARapCryoIteration ""
set PolSARapCryoChannel ""
set PolSARapCryoDielectric ""
set PolSARapCryoDr ""
set PolSARapCryoThreshold ""

if [file exists "$PolSARapCryoMasterDirInput/config.txt"] {
    set ConfigFile "$PolSARapCryoMasterDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        WidgetShow $widget(Toplevel532); TextEditorRunTrace "Open Window PolSARap Showcase Cryosphere" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }

# Config Format
}
# ActiveProgram
} else {
set ErrorMessage "PolSARpro IS NOT IN A DUAL POL-INSAR DATA SETS MODE"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}} \
        -padx 4 -pady 2 -relief ridge -text Cryosphere 
    vTcl:DefineAlias "$top.cpd66" "Button578" vTcl:WidgetProc "Toplevel530" 1
    menubutton $top.men66 \
        -menu "$top.men66.m" -padx 5 -pady 4 -relief ridge -text Forest 
    vTcl:DefineAlias "$top.men66" "Menubutton1" vTcl:WidgetProc "Toplevel530" 1
    menu $top.men66.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $top.men66.m add command \
        \
        -command {global DataDirChannel1 DataDirChannel2 DataDirChannel3 FileName 
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global ActiveProgram2 DataFormatActive2

#POLSARAP
global Load_PolSARapForestEnvironment
global PSPTopLevel

if {$ActiveProgram == "POLINSAR"} {

if {$Load_PolSARapForestEnvironment == 0} {
    source "GUI/polsarap/PolSARapForestEnvironment.tcl"
    set Load_PolSARapForestEnvironment 1
    WmTransient $widget(Toplevel536) $PSPTopLevel
    }

set DataFormatActive2 ""
set ActiveProgram2 ""
WidgetShow $widget(Toplevel536); TextEditorRunTrace "Open Window PolSARap Showcase Forest - Environment" "b"

# ActiveProgram
} else {
set ErrorMessage "PolSARpro IS NOT IN A DUAL POL-INSAR DATA SETS MODE"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}} \
        -label Environment 
    $top.men66.m add separator \
        
    $top.men66.m add command \
        \
        -command {global DataDirChannel1 DataDirChannel2 DataDirChannel3 FileName 
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2 PSPBackgroundColor
global PolSARapForestDirMasterInput PolSARapForestDirSlave1Input PolSARapForestDirSlave2Input 
global PolSARapForestDirOutput PolSARapForestOutputDir PolSARapForestOutputSubDir
global PolSARapForestMinHeight PolSARapForestMaxHeight PolSARapForestDelHeight
global PolSARapForestMinSigma PolSARapForestMaxSigma PolSARapForestDelSigma
global PolSARapForestNwinL PolSARapForestNwinC
global PolSARapForestKz1File PolSARapForestKz2File PolSARapForestHeightFile
global ActiveProgram2 DataFormatActive DataFormatActive2

#POLSARAP
global Load_PolSARapForestHeightEstimation
global PSPTopLevel

if {$ActiveProgram2 == "POLINSAR2"} {

set configformat "true"

if {$DataFormatActive2 == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$DataFormatActive2 != "S2" & $DataFormatActive2 != "T6"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$configformat == "true"} {


if {$Load_PolSARapForestHeightEstimation == 0} {
    source "GUI/polsarap/PolSARapForestHeightEstimation.tcl"
    set Load_PolSARapForestHeightEstimation 1
    WmTransient $widget(Toplevel533) $PSPTopLevel
    }

set ConfigFile ""

set PolSARapForestDirMasterInput ""
set PolSARapForestDirSlave1Input ""
set PolSARapForestDirSlave2Input ""
set PolSARapForestDirOutput ""
set PolSARapForestOutputDir ""
set PolSARapForestOutputSubDir ""
set PolSARapForestMinHeight "1"
set PolSARapForestMaxHeight "50"
set PolSARapForestDelHeight "0.5"
set PolSARapForestMinSigma "0.01"
set PolSARapForestMaxSigma "2"
set PolSARapForestDelSigma "0.02"
set PolSARapForestNwinL "7"
set PolSARapForestNwinC "7"
set PolSARapForestKz1File "Enter 2D Kz-1 file"
set PolSARapForestKz2File "Enter 2D Kz-2 file"
set PolSARapForestHeightFile ""

if {$DataFormatActive2 == "S2"} {
    set MasterSlaveOutputDir $DataDirChannel1
    set DirTmp [file tail $DataDirChannel2]
    append MasterSlaveOutputDir "_"
    append MasterSlaveOutputDir $DirTmp
    append MasterSlaveOutputDir "_"
    set DirTmp [file tail $DataDirChannel3]
    append MasterSlaveOutputDir "_"
    append MasterSlaveOutputDir $DirTmp
    set PolSARapForestDirMasterInput $DataDirChannel1
    set PolSARapForestDirSlave1Input $DataDirChannel2
    set PolSARapForestDirSlave2Input $DataDirChannel3
    set PolSARapForestOutputSubDir ""
    $widget(TitleFrame533_1) configure -text "Input Master Directory"    
    $widget(TitleFrame533_2) configure -text "Input Slave - 1 Directory"    
    $widget(TitleFrame533_3) configure -text "Input Slave - 2 Directory"    
    $widget(Entry533_1) configure -disabledbackground #FFFFFF
    $widget(Entry533_1) configure -state disable
    }

if {$DataFormatActive2 == "T6"} {
    set MasterSlaveOutputDir $DataDirChannel1
    set DirTmp [file tail $DataDirChannel3]
    append MasterSlaveOutputDir "_"
    append MasterSlaveOutputDir $DirTmp
    set PolSARapForestDirMasterInput "$DataDirChannel1/T6"
    set PolSARapForestDirSlave1Input "$DataDirChannel3/T6"
    set PolSARapForestDirSlave2Input ""
    set PolSARapForestOutputSubDir "T6"
    $widget(TitleFrame533_1) configure -text "Input Master - Slave - 1 Directory"    
    $widget(TitleFrame533_2) configure -text "Input Master - Slave - 2 Directory"    
    $widget(TitleFrame533_3) configure -text ""    
    $widget(Entry533_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry533_1) configure -state disable
    }

set PolSARapForestOutputDir $MasterSlaveOutputDir 
set PolSARapForestDirOutput $PolSARapForestOutputDir
set PolSARapForestHeightFile "$PolSARapForestOutputDir/showcase_forest_height.bin"

if [file exists "$PolSARapForestDirMasterInput/config.txt"] {
    set ConfigFile "$PolSARapForestDirMasterInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        WidgetShow $widget(Toplevel533); TextEditorRunTrace "Open Window PolSARap Showcase Forest - Height Estimation" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }

# Config Format
}
# ActiveProgram
} else {
set ErrorMessage "PolSARpro IS NOT IN A DUAL POL-INSAR DATA SETS MODE"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}} \
        -label {Height Estimation} 
    button $top.but86 \
        \
        -command {global DataDir FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global PolSARapOceanDirInput PolSARapOceanDirOutput PolSARapOceanOutputDir PolSARapOceanOutputSubDir
global ActiveProgram PolSARapOceanFonction
global PolSARapOceanThreshold PolSARapOceanRedR
global PolSARapOceanNwinTrainL PolSARapOceanNwinTrainC
global PolSARapOceanNwinTestL PolSARapOceanNwinTestC
global PolSARapOceanOutputCohFile PolSARapOceanOutputMaskFile

#POLSARAP
global Load_PolSARapOcean
global PSPTopLevel

if {$ActiveProgram == "POLSARPRO"} {

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$DataFormatActive == "IPP"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$configformat == "true"} {


    if {$Load_PolSARapOcean == 0} {
        source "GUI/polsarap/PolSARapOcean.tcl"
        set Load_PolSARapOcean 1
        WmTransient $widget(Toplevel534) $PSPTopLevel
        }

    set ConfigFile ""
    set PolSARapOceanThreshold "0.98"
    set PolSARapOceanRedR "0.0025"
    set PolSARapOceanNwinTrainL "51"
    set PolSARapOceanNwinTrainC "51"
    set PolSARapOceanNwinTestL "9"
    set PolSARapOceanNwinTestC "9"

    set PolSARapOceanOutputDir $DataDir
    set PolSARapOceanDirOutput $DataDir

    if {$DataFormatActive == "S2"} {
        set PolSARapOceanDirInput $DataDir
        set PolSARapOceanOutputSubDir ""
        set BMPDirInput $PolSARapOceanDirOutput
        if { "$PolarCase" == "monostatic"} {
            set PolSARapOceanFonction "S2T3"
            }
        if { "$PolarCase" == "bistatic"} {
            set PolSARapOceanFonction "S2T4"
            }
        }       
    if { $DataFormatActive == "C2" } {
        set PolSARapOceanDirInput "$DataDir/C2"
        set PolSARapOceanOutputSubDir "C2"
        set BMPDirInput "$PolSARapOceanDirOutput/C2"
        set PolSARapOceanFonction "C2"
        }
    if { $DataFormatActive == "T2" } {
        set PolSARapOceanDirInput "$DataDir/T2"
        set PolSARapOceanOutputSubDir "T2"
        set BMPDirInput "$PolSARapOceanDirOutput/T2"
        set PolSARapOceanFonction "T2"
        }
    if { $DataFormatActive == "C3" } {
        set PolSARapOceanDirInput "$DataDir/C3"
        set PolSARapOceanOutputSubDir "C3"
        set BMPDirInput "$PolSARapOceanDirOutput/C3"
        set PolSARapOceanFonction "C3"
        }
    if { $DataFormatActive == "T3" } {
        set PolSARapOceanDirInput "$DataDir/T3"
        set PolSARapOceanOutputSubDir "T3"
        set BMPDirInput "$PolSARapOceanDirOutput/T3"
        set PolSARapOceanFonction "T3"
        }
    if { $DataFormatActive == "C4" } {
        set PolSARapOceanDirInput "$DataDir/C4"
        set PolSARapOceanOutputSubDir "C4"
        set BMPDirInput "$PolSARapOceanDirOutput/C4"
        set PolSARapOceanFonction "C4"
        }
    if { $DataFormatActive == "T4" } {
        set PolSARapOceanDirInput "$DataDir/T4"
        set PolSARapOceanOutputSubDir "T4"
        set BMPDirInput "$PolSARapOceanDirOutput/T4"
        set PolSARapOceanFonction "T4"
        }
    if {$DataFormatActive == "SPP"} {
        set PolSARapOceanDirInput $DataDir
        set PolSARapOceanOutputSubDir ""
        set BMPDirInput $PolSARapOceanDirOutput
        set PolSARapOceanFonction "SPP"
        }       

    set PolSARapOceanOutputCohFile "$PolSARapOceanOutputDir/ocean_coherence.bin"
    set PolSARapOceanOutputMaskFile "$PolSARapOceanOutputDir/ocean_mask.bin"

    if [file exists "$PolSARapOceanDirInput/config.txt"] {
        set ConfigFile "$PolSARapOceanDirInput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            WidgetShow $widget(Toplevel534); TextEditorRunTrace "Open Window PolSARap Showcase Ocean" "b"
            } else {
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        } else {
        set ErrorMessage "ENTER A VALID DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    # Config Format
    }
# ActiveProgram
} else {
set ErrorMessage "PolSARpro IS NOT IN A SINGLE DATA SET MODE"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}} \
        -padx 4 -pady 2 -relief ridge -text Ocean 
    vTcl:DefineAlias "$top.but86" "Button576" vTcl:WidgetProc "Toplevel530" 1
    button $top.but87 \
        \
        -command {global DataDirChannel1 DataDirChannel2 FileName DataFormatActive
global VarError ErrorMessage VarWarning WarningMessage WarningMessage2
global ConfigFile Fonction Fonction2
global PolSARapUrbanDirInput PolSARapUrbanDirOutput PolSARapUrbanOutputDir PolSARapUrbanOutputSubDir
global PolSARapUrbanCmplxCohFile PolSARapUrbanOutputFile PolSARapUrbanFileOutput 
global ActiveProgram

#POLSARAP
global Load_PolSARapUrban
global PSPTopLevel

if {$ActiveProgram == "POLINSAR"} {

set configformat "true"

if {$DataFormatActive == "---"} {
    set ErrorMessage "INPUT POLARIMETRIC DATA FORMAT NOT DEFINED"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ErrorMessage ""
    set configformat "false"
    }

if {$configformat == "true"} {


if {$Load_PolSARapUrban == 0} {
    source "GUI/polsarap/PolSARapUrban.tcl"
    set Load_PolSARapUrban 1
    WmTransient $widget(Toplevel535) $PSPTopLevel
    }

set ConfigFile ""
set PolSARapUrbanCmplxCohFile ""
set PolSARapUrbanOutputFile  ""
set PolSARapUrbanFileOutput  ""
set PolSARapUrbanDirInput ""
set PolSARapUrbanDirOutput ""
set PolSARapUrbanOutputDir ""
set PolSARapUrbanOutputSubDir ""

if {$DataFormatActive == "SPP"} {
    set MasterSlaveOutputDir $DataDirChannel1
    set DirTmp [file tail $DataDirChannel2]
    append MasterSlaveOutputDir "_"
    append MasterSlaveOutputDir $DirTmp
    set PolSARapUrbanDirInput $MasterSlaveOutputDir 
    set PolSARapUrbanOutputSubDir ""
    }
if {$DataFormatActive == "T4"} {
    set PolSARapUrbanDirInput "$DataDirChannel1/T4"
    set PolSARapUrbanOutputSubDir "T4"
    set MasterSlaveOutputDir $DataDirChannel1
    }
if {$DataFormatActive == "S2"} {
    set MasterSlaveOutputDir $DataDirChannel1
    set DirTmp [file tail $DataDirChannel2]
    append MasterSlaveOutputDir "_"
    append MasterSlaveOutputDir $DirTmp
    set PolSARapUrbanDirInput $MasterSlaveOutputDir 
    set PolSARapUrbanOutputSubDir ""
    }
if {$DataFormatActive == "T6"} {
    set PolSARapUrbanDirInput "$DataDirChannel1/T6"
    set PolSARapUrbanOutputSubDir "T6"
    set MasterSlaveOutputDir $DataDirChannel1
    }

set PolSARapUrbanOutputDir $MasterSlaveOutputDir 
set PolSARapUrbanDirOutput $PolSARapUrbanOutputDir

if [file exists "$PolSARapUrbanDirInput/config.txt"] {
    set ConfigFile "$PolSARapUrbanDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        WidgetShow $widget(Toplevel535); TextEditorRunTrace "Open Window PolSARap Showcase Urban" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }

# Config Format
}
# ActiveProgram
} else {
set ErrorMessage "PolSARpro IS NOT IN A DUAL POL-INSAR DATA SETS MODE"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}} \
        -padx 4 -pady 2 -relief ridge -text Urban 
    vTcl:DefineAlias "$top.but87" "Button577" vTcl:WidgetProc "Toplevel530" 1
    button $top.but67 \
        -background #ffff00 \
        -command {global OpenDirFile PolSARapShortcut
global Load_PolSARapAgriculture Load_PolSARapCryosphere Load_PolSARapForestEnvironment Load_PolSARapForestHeightEstimation Load_PolSARapOcean Load_PolSARapUrban
if {$OpenDirFile == 0} {
set PolSARapShortcut 0
Window hide $widget(Toplevel530); TextEditorRunTrace "Close Window PolSARap Showcase Menu" "b"
if {$Load_PolSARapAgriculture == 1} { Window hide $widget(Toplevel531); TextEditorRunTrace "Close Window PolSARap Showcase Agriculture" "b" }
if {$Load_PolSARapCryosphere == 1} { Window hide $widget(Toplevel532); TextEditorRunTrace "Close Window PolSARap Showcase Cryosphere" "b" }
if {$Load_PolSARapForestEnvironment == 1} { Window hide $widget(Toplevel536); TextEditorRunTrace "Close Window PolSARap Showcase Forest - Environment" "b" }
if {$Load_PolSARapForestHeightEstimation == 1} { Window hide $widget(Toplevel533); TextEditorRunTrace "Close Window PolSARap Showcase Forest - Height Estimation" "b" }
if {$Load_PolSARapOcean == 1} { Window hide $widget(Toplevel534); TextEditorRunTrace "Close Window PolSARap Showcase Ocean" "b" }
if {$Load_PolSARapUrban == 1} { Window hide $widget(Toplevel535); TextEditorRunTrace "Close Window PolSARap Showcase Urban" "b" }
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$top.but67" "Button1" vTcl:WidgetProc "Toplevel530" 1
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab66 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.but83 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.men66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.but86 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.but87 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.but67 \
        -in $top -anchor center -expand 1 -fill none -side top 

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
Window show .top530

main $argc $argv
