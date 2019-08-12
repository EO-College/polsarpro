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

        {{[file join . GUI Images ToolsMenu.gif]} {user image} user {}}
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
    set base .top310
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab53 {
        array set save {-_tooltip 1 -image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd86
    namespace eval ::widgets::$site_3_0.men82 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men82.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.men83 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men83.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd66
    namespace eval ::widgets::$site_3_0.men82 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men82.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.men83 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men83.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.cpd84 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd84
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd67
    namespace eval ::widgets::$site_4_0.men77 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.men77.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.men77 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.men77.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.men77 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.men77.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
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
    namespace eval ::widgets::$base.men73 {
        array set save {-_tooltip 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.men73.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.fra26 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra26
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
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
            vTclWindow.top310
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

proc vTclWindow.top310 {base} {
    if {$base == ""} {
        set base .top310
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
    wm geometry $top 150x270+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Tools"
    vTcl:DefineAlias "$top" "Toplevel310" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab53 \
        -image [vTcl:image:get_image [file join . GUI Images ToolsMenu.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$top.lab53" "Label171" vTcl:WidgetProc "Toplevel310" 1
    bindtags $top.lab53 "$top.lab53 Label $top all _vTclBalloon"
    bind $top.lab53 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP 1.4}
    }
    frame $top.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd86" "Frame6" vTcl:WidgetProc "Toplevel310" 1
    set site_3_0 $top.cpd86
    menubutton $site_3_0.men82 \
        -menu "$site_3_0.men82.m" -padx 4 -pady 4 -relief raised \
        -text {[S2] Master} -width 8 
    vTcl:DefineAlias "$site_3_0.men82" "Menubutton310_1" vTcl:WidgetProc "Toplevel310" 1
    bindtags $site_3_0.men82 "$site_3_0.men82 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Dual Polarimetric Complex data}
    }
    menu $site_3_0.men82.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men82.m add command \
        \
        -command {global CheckDirInput CheckInputDir CheckInputSubDir
global CheckData CheckType CheckFileName CheckResult CheckFile
global BinaryDataCheck 
#UTIL
global Load_CheckBinaryData PSPTopLevel

if {$Load_CheckBinaryData == 0} {
    source "GUI/tools/CheckBinaryData.tcl"
    set Load_CheckBinaryData 1
    WmTransient $widget(Toplevel316) $PSPTopLevel
    }

    set CheckDirInput $DataDir
    set CheckInputDir $DataDir
    set CheckInputSubDir ""
    set CheckData " "
    set CheckType " "
    set CheckFile ""
    set CheckFileName ""
    set CheckResult ""
    $widget(Button316_3) configure -state normal
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
    WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel316); TextEditorRunTrace "Open Window Check Binary Data" "b"
} \
        -label {Data Binary Check} 
    $site_3_0.men82.m add separator \
        
    $site_3_0.men82.m add command \
        \
        -command {global DataDir DirName DirName1 DirName2 CompareDataDir1 CompareDataDir2
global CompareFile1 CompareFile2 CompareFormat1 CompareFormat2
global CompareSample1 CompareSample2 CompareLine1 CompareLine2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol
global CompareResult CompareFormat CompareSubDir CompareDataSubDir FileCompare

#TOOLS
global Load_CompareDir PSPTopLevel

if {$Load_CompareDir == 0} {
    source "GUI/tools/CompareDir.tcl"
    set Load_CompareDir 1
    WmTransient $widget(Toplevel416) $PSPTopLevel
    }

set DirName ""; set DirName1 ""; set DirName2 ""
set CompareDataDir1 $DataDir; set CompareDataDir2 $DataDir
set CompareFile1 ""; set CompareFile2 ""; set CompareFormat1 ""; set CompareFormat2 ""
set CompareSample1 ""; set CompareSample2 ""; set CompareLine1 ""; set CompareLine2 ""
set CompareOffLig ""; set CompareOffCol ""; set CompareSubNlig ""; set CompareSubNcol ""
set CompareResult ""; set CompareFormat ""

for {set i 0} {$i <= 40} {incr i} { set FileCompare($i) ""}
set CompareSubDir " "; set CompareDataSubDir ""

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel416); TextEditorRunTrace "Open Window Compare Data Directory" "b"} \
        -label {Compare Data Directory} 
    $site_3_0.men82.m add separator \
        
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsFormat

set ToolsDirInput ""
set ToolsFormat ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsFormat "S2"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| Soft/bin/tools/create_mask_valid_pixels.exe -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Create Mask Valid Pixels} 
    $site_3_0.men82.m add separator \
        
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase


#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_IEEE"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "IEEE FORMAT CONVERT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "ieee"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {IEEE Format Convert} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_SUB"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR SUB DATA EXTRACTION"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "extract"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Sub Data Extraction} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_L90"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 90 LEFT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "rot90l"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 left} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R90"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 90 RIGHT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "rot90r"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 right} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R180"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 180"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "rot180"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 180} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FUD"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FLIP UP DOWN"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "flipud"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Up-Down} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FLR"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FLIP LEFT RIGHT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "fliplr"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Left-Right} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_TRP"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR TRANSPOSE"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "transp"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label Transpose 
    $site_3_0.men82.m add command \
        \
        -command {global ToolsFonction ToolsFunction ToolsErase ToolsDirInput ToolsDirOutput ToolsDirOutputErase DataDirChannel1 ConfigFile VarError ErrorMessage
global ToolsFFTSize InputFFTShift OutputFFTShift

#TOOLS
global Load_ToolsFFT PSPTopLevel

if {$Load_ToolsFFT == 0} {
    source "GUI/tools/ToolsFFT.tcl"
    set Load_ToolsFFT 1
    WmTransient $widget(Toplevel58) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set InputFFTShift 0
set OutputFFTShift 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FFT"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FFT (lines)"
    set ToolsFunction "Soft/bin/tools/cmplx_tools_fft.exe"
    set ToolsFormat "S2"
    set ToolsOperation "fft"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            set ToolsFFTSize 1
            while {$ToolsFFTSize < $NcolFullSize} {set ToolsFFTSize [expr 2 * $ToolsFFTSize]}
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel58); TextEditorRunTrace "Open Window Tools FFT" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label FFT 
    $site_3_0.men82.m add separator \
        
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase ToolsMaskFile

#TOOLS
global Load_ToolsMask PSPTopLevel

if {$Load_ToolsMask == 0} {
    source "GUI/tools/ToolsMask.tcl"
    set Load_ToolsMask 1
    WmTransient $widget(Toplevel383) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ToolsMaskFile ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_MASK"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR APPLY MASK"
    set ToolsFunction "Soft/bin/tools/cmplx_tools_mask.exe"
    set ToolsFormat "S2"
    set ToolsOperation "mask"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel383); TextEditorRunTrace "Open Window Tools - Mask" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Apply Mask} 
    menubutton $site_3_0.men83 \
        -menu "$site_3_0.men83.m" -padx 4 -pady 4 -relief raised \
        -text {[S2] Slave} -width 8 
    vTcl:DefineAlias "$site_3_0.men83" "Menubutton310_2" vTcl:WidgetProc "Toplevel310" 1
    bindtags $site_3_0.men83 "$site_3_0.men83 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Dual Polarimetric Intensity data}
    }
    menu $site_3_0.men83.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men83.m add command \
        \
        -command {global CheckDirInput CheckInputDir CheckInputSubDir
global CheckData CheckType CheckFileName CheckResult CheckFile
global BinaryDataCheck 
#UTIL
global Load_CheckBinaryData PSPTopLevel

if {$Load_CheckBinaryData == 0} {
    source "GUI/tools/CheckBinaryData.tcl"
    set Load_CheckBinaryData 1
    WmTransient $widget(Toplevel316) $PSPTopLevel
    }

    set CheckDirInput $DataDir
    set CheckInputDir $DataDir
    set CheckInputSubDir ""
    set CheckData " "
    set CheckType ""
    set CheckFile ""
    set CheckFileName ""
    set CheckResult ""
    $widget(Button316_3) configure -state normal
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
    WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel316); TextEditorRunTrace "Open Window Check Binary Data" "b"
} \
        -label {Data Binary Check} 
    $site_3_0.men83.m add separator \
        
    $site_3_0.men83.m add command \
        \
        -command {global DataDir DirName DirName1 DirName2 CompareDataDir1 CompareDataDir2
global CompareFile1 CompareFile2 CompareFormat1 CompareFormat2
global CompareSample1 CompareSample2 CompareLine1 CompareLine2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol
global CompareResult CompareFormat CompareSubDir CompareDataSubDir FileCompare

#TOOLS
global Load_CompareDir PSPTopLevel

if {$Load_CompareDir == 0} {
    source "GUI/tools/CompareDir.tcl"
    set Load_CompareDir 1
    WmTransient $widget(Toplevel416) $PSPTopLevel
    }

set DirName ""; set DirName1 ""; set DirName2 ""
set CompareDataDir1 $DataDir; set CompareDataDir2 $DataDir
set CompareFile1 ""; set CompareFile2 ""; set CompareFormat1 ""; set CompareFormat2 ""
set CompareSample1 ""; set CompareSample2 ""; set CompareLine1 ""; set CompareLine2 ""
set CompareOffLig ""; set CompareOffCol ""; set CompareSubNlig ""; set CompareSubNcol ""
set CompareResult ""; set CompareFormat ""

for {set i 0} {$i <= 40} {incr i} { set FileCompare($i) ""}
set CompareSubDir " "; set CompareDataSubDir ""

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel416); TextEditorRunTrace "Open Window Compare Data Directory" "b"} \
        -label {Compare Data Directory} 
    $site_3_0.men83.m add separator \
        
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsFormat

set ToolsDirInput ""
set ToolsFormat ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsFormat "S2"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| Soft/bin/tools/create_mask_valid_pixels.exe -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Create Mask Valid Pixels} 
    $site_3_0.men83.m add separator \
        
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_IEEE"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "IEEE FORMAT CONVERT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "ieee"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {IEEE Format Convert} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_SUB"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR SUB DATA EXTRACTION"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "extract"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Sub Data Extraction} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_L90"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 90 LEFT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "rot90l"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 left} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R90"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 90 RIGHT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "rot90r"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 right} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R180"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 180"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "rot180"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 180} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FUD"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FLIP UP DOWN"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "flipud"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Up-Down} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FLR"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FLIP LEFT RIGHT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "fliplr"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Left-Right} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_TRP"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR TRANSPOSE"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "transp"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label Transpose 
    $site_3_0.men83.m add command \
        \
        -command {global ToolsFonction ToolsFunction ToolsErase ToolsDirInput ToolsDirOutput ToolsDirOutputErase DataDirChannel2 ConfigFile VarError ErrorMessage
global ToolsFFTSize InputFFTShift OutputFFTShift

#TOOLS
global Load_ToolsFFT 

if {$Load_ToolsFFT == 0} {
    source "GUI/tools/ToolsFFT.tcl"
    set Load_ToolsFFT 1
    WmTransient $widget(Toplevel58) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set InputFFTShift 0
set OutputFFTShift 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FFT"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FFT (lines)"
    set ToolsFunction "Soft/bin/tools/cmplx_tools_fft.exe"
    set ToolsFormat "S2"
    set ToolsOperation "fft"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            set ToolsFFTSize 1
            while {$ToolsFFTSize < $NcolFullSize} {set ToolsFFTSize [expr 2 * $ToolsFFTSize]}
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel58); TextEditorRunTrace "Open Window Tools FFT" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label FFT 
    $site_3_0.men83.m add separator \
        
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase ToolsMaskFile

#TOOLS
global Load_ToolsMask PSPTopLevel

if {$Load_ToolsMask == 0} {
    source "GUI/tools/ToolsMask.tcl"
    set Load_ToolsMask 1
    WmTransient $widget(Toplevel383) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ToolsMaskFile ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_MASK"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR APPLY MASK"
    set ToolsFunction "Soft/bin/tools/cmplx_tools_mask.exe"
    set ToolsFormat "S2"
    set ToolsOperation "mask"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel383); TextEditorRunTrace "Open Window Tools - Mask" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Apply Mask} 
    pack $site_3_0.men82 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    pack $site_3_0.men83 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipady 1 -side right 
    frame $top.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame7" vTcl:WidgetProc "Toplevel310" 1
    set site_3_0 $top.cpd66
    menubutton $site_3_0.men82 \
        -menu "$site_3_0.men82.m" -padx 4 -pady 4 -relief raised \
        -text {[SPP] Master} -width 8 
    vTcl:DefineAlias "$site_3_0.men82" "Menubutton310_4" vTcl:WidgetProc "Toplevel310" 1
    bindtags $site_3_0.men82 "$site_3_0.men82 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Dual Polarimetric Complex data}
    }
    menu $site_3_0.men82.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men82.m add command \
        \
        -command {global CheckDirInput CheckInputDir CheckInputSubDir
global CheckData CheckType CheckFileName CheckResult CheckFile
global BinaryDataCheck 
#UTIL
global Load_CheckBinaryData PSPTopLevel

if {$Load_CheckBinaryData == 0} {
    source "GUI/tools/CheckBinaryData.tcl"
    set Load_CheckBinaryData 1
    WmTransient $widget(Toplevel316) $PSPTopLevel
    }

    set CheckDirInput $DataDir
    set CheckInputDir $DataDir
    set CheckInputSubDir ""
    set CheckData " "
    set CheckType " "
    set CheckFile ""
    set CheckFileName ""
    set CheckResult ""
    $widget(Button316_3) configure -state normal
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
    WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel316); TextEditorRunTrace "Open Window Check Binary Data" "b"} \
        -label {Data Binary Check} 
    $site_3_0.men82.m add separator \
        
    $site_3_0.men82.m add command \
        \
        -command {global DataDir DirName DirName1 DirName2 CompareDataDir1 CompareDataDir2
global CompareFile1 CompareFile2 CompareFormat1 CompareFormat2
global CompareSample1 CompareSample2 CompareLine1 CompareLine2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol
global CompareResult CompareFormat CompareSubDir CompareDataSubDir FileCompare

#TOOLS
global Load_CompareDir PSPTopLevel

if {$Load_CompareDir == 0} {
    source "GUI/tools/CompareDir.tcl"
    set Load_CompareDir 1
    WmTransient $widget(Toplevel416) $PSPTopLevel
    }

set DirName ""; set DirName1 ""; set DirName2 ""
set CompareDataDir1 $DataDir; set CompareDataDir2 $DataDir
set CompareFile1 ""; set CompareFile2 ""; set CompareFormat1 ""; set CompareFormat2 ""
set CompareSample1 ""; set CompareSample2 ""; set CompareLine1 ""; set CompareLine2 ""
set CompareOffLig ""; set CompareOffCol ""; set CompareSubNlig ""; set CompareSubNcol ""
set CompareResult ""; set CompareFormat ""

for {set i 0} {$i <= 40} {incr i} { set FileCompare($i) ""}
set CompareSubDir " "; set CompareDataSubDir ""

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel416); TextEditorRunTrace "Open Window Compare Data Directory" "b"} \
        -label {Compare Data Directory} 
    $site_3_0.men82.m add separator \
        
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsFormat

set ToolsDirInput ""
set ToolsFormat ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsFormat "SPP"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| Soft/bin/tools/create_mask_valid_pixels.exe -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Create Mask Valid Pixels} 
    $site_3_0.men82.m add separator \
        
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase


#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_IEEE"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "IEEE FORMAT CONVERT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "ieee"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {IEEE Format Convert} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_SUB"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR SUB DATA EXTRACTION"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "extract"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Sub Data Extraction} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_L90"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 90 LEFT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "rot90l"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 left} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R90"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 90 RIGHT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "rot90r"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 right} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R180"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 180"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "rot180"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 180} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FUD"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FLIP UP DOWN"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "S2"
    set ToolsOperation "flipud"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType != "full"} {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Up-Down} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FLR"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FLIP LEFT RIGHT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "fliplr"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Left-Right} 
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_TRP"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR TRANSPOSE"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "transp"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label Transpose 
    $site_3_0.men82.m add command \
        \
        -command {global ToolsFonction ToolsFunction ToolsErase ToolsDirInput ToolsDirOutput ToolsDirOutputErase DataDirChannel1 ConfigFile VarError ErrorMessage
global ToolsFFTSize InputFFTShift OutputFFTShift

#TOOLS
global Load_ToolsFFT PSPTopLevel

if {$Load_ToolsFFT == 0} {
    source "GUI/tools/ToolsFFT.tcl"
    set Load_ToolsFFT 1
    WmTransient $widget(Toplevel58) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set InputFFTShift 0
set OutputFFTShift 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FFT"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FFT (lines)"
    set ToolsFunction "Soft/bin/tools/cmplx_tools_fft.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "fft"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            set ToolsFFTSize 1
            while {$ToolsFFTSize < $NcolFullSize} {set ToolsFFTSize [expr 2 * $ToolsFFTSize]}
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel58); TextEditorRunTrace "Open Window Tools FFT" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label FFT 
    $site_3_0.men82.m add separator \
        
    $site_3_0.men82.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase ToolsMaskFile

#TOOLS
global Load_ToolsMask PSPTopLevel

if {$Load_ToolsMask == 0} {
    source "GUI/tools/ToolsMask.tcl"
    set Load_ToolsMask 1
    WmTransient $widget(Toplevel383) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ToolsMaskFile ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel1/config.txt"] {
set config "false"
if [file exists "$DataDirChannel1/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel1/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel1
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_MASK"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR APPLY MASK"
    set ToolsFunction "Soft/bin/tools/cmplx_tools_mask.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "mask"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel383); TextEditorRunTrace "Open Window Tools - Mask" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Apply Mask} 
    menubutton $site_3_0.men83 \
        -menu "$site_3_0.men83.m" -padx 4 -pady 4 -relief raised \
        -text {[SPP] Slave} -width 8 
    vTcl:DefineAlias "$site_3_0.men83" "Menubutton310_5" vTcl:WidgetProc "Toplevel310" 1
    bindtags $site_3_0.men83 "$site_3_0.men83 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Dual Polarimetric Intensity data}
    }
    menu $site_3_0.men83.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men83.m add command \
        \
        -command {global CheckDirInput CheckInputDir CheckInputSubDir
global CheckData CheckType CheckFileName CheckResult CheckFile
global BinaryDataCheck 
#UTIL
global Load_CheckBinaryData PSPTopLevel

if {$Load_CheckBinaryData == 0} {
    source "GUI/tools/CheckBinaryData.tcl"
    set Load_CheckBinaryData 1
    WmTransient $widget(Toplevel316) $PSPTopLevel
    }

    set CheckDirInput $DataDir
    set CheckInputDir $DataDir
    set CheckInputSubDir ""
    set CheckData " "
    set CheckType " "
    set CheckFile ""
    set CheckFileName ""
    set CheckResult ""
    $widget(Button316_3) configure -state normal
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
    WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel316); TextEditorRunTrace "Open Window Check Binary Data" "b"
} \
        -label {Data Binary Check} 
    $site_3_0.men83.m add separator \
        
    $site_3_0.men83.m add command \
        \
        -command {global DataDir DirName DirName1 DirName2 CompareDataDir1 CompareDataDir2
global CompareFile1 CompareFile2 CompareFormat1 CompareFormat2
global CompareSample1 CompareSample2 CompareLine1 CompareLine2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol
global CompareResult CompareFormat CompareSubDir CompareDataSubDir FileCompare

#TOOLS
global Load_CompareDir PSPTopLevel

if {$Load_CompareDir == 0} {
    source "GUI/tools/CompareDir.tcl"
    set Load_CompareDir 1
    WmTransient $widget(Toplevel416) $PSPTopLevel
    }

set DirName ""; set DirName1 ""; set DirName2 ""
set CompareDataDir1 $DataDir; set CompareDataDir2 $DataDir
set CompareFile1 ""; set CompareFile2 ""; set CompareFormat1 ""; set CompareFormat2 ""
set CompareSample1 ""; set CompareSample2 ""; set CompareLine1 ""; set CompareLine2 ""
set CompareOffLig ""; set CompareOffCol ""; set CompareSubNlig ""; set CompareSubNcol ""
set CompareResult ""; set CompareFormat ""

for {set i 0} {$i <= 40} {incr i} { set FileCompare($i) ""}
set CompareSubDir " "; set CompareDataSubDir ""

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel416); TextEditorRunTrace "Open Window Compare Data Directory" "b"} \
        -label {Compare Data Directory} 
    $site_3_0.men83.m add separator \
        
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsFormat

set ToolsDirInput ""
set ToolsFormat ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsFormat "SPP"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set FinalNlig [expr $NligEnd - $NligInit + 1]
            set FinalNcol [expr $NcolEnd - $NcolInit + 1]
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" "k"
            set f [ open "| Soft/bin/tools/create_mask_valid_pixels.exe -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Create Mask Valid Pixels} 
    $site_3_0.men83.m add separator \
        
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_IEEE"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "IEEE FORMAT CONVERT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "ieee"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {IEEE Format Convert} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_SUB"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR SUB DATA EXTRACTION"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "extract"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Sub Data Extraction} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_L90"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 90 LEFT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "rot90l"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 left} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R90"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 90 RIGHT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "rot90r"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 right} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R180"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR ROTATION 180"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "rot180"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 180} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FUD"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FLIP UP DOWN"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "flipud"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Up-Down} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FLR"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FLIP LEFT RIGHT"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "fliplr"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Left-Right} 
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_TRP"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR TRANSPOSE"
    set ToolsFunction "Soft/bin/tools/cmplx_tools.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "transp"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label Transpose 
    $site_3_0.men83.m add command \
        \
        -command {global ToolsFonction ToolsFunction ToolsErase ToolsDirInput ToolsDirOutput ToolsDirOutputErase DataDirChannel2 ConfigFile VarError ErrorMessage
global ToolsFFTSize InputFFTShift OutputFFTShift

#TOOLS
global Load_ToolsFFT 

if {$Load_ToolsFFT == 0} {
    source "GUI/tools/ToolsFFT.tcl"
    set Load_ToolsFFT 1
    WmTransient $widget(Toplevel58) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set InputFFTShift 0
set OutputFFTShift 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FFT"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR FFT (lines)"
    set ToolsFunction "Soft/bin/tools/cmplx_tools_fft.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "fft"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            set ToolsFFTSize 1
            while {$ToolsFFTSize < $NcolFullSize} {set ToolsFFTSize [expr 2 * $ToolsFFTSize]}
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel58); TextEditorRunTrace "Open Window Tools FFT" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label FFT 
    $site_3_0.men83.m add separator \
        
    $site_3_0.men83.m add command \
        \
        -command {global DataDirChannel2 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase ToolsMaskFile

#TOOLS
global Load_ToolsMask PSPTopLevel

if {$Load_ToolsMask == 0} {
    source "GUI/tools/ToolsMask.tcl"
    set Load_ToolsMask 1
    WmTransient $widget(Toplevel383) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ToolsMaskFile ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file exists "$DataDirChannel2/config.txt"] {
set config "false"
if [file exists "$DataDirChannel2/s11.bin"] {set config "true"}
if [file exists "$DataDirChannel2/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ToolsDirInput $DataDirChannel2
    set ToolsDirOutputErase $DataDirChannel2
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_MASK"
    set ToolsOutputSubDir ""
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "SINCLAIR APPLY MASK"
    set ToolsFunction "Soft/bin/tools/cmplx_tools_mask.exe"
    set ToolsFormat "SPP"
    set ToolsOperation "mask"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if {$PolarType == "full"} {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } else {
            set NcolFullSize $NcolEnd
            WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel383); TextEditorRunTrace "Open Window Tools - Mask" "b"
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE TO THE DATA MAIN INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Apply Mask} 
    pack $site_3_0.men82 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipady 1 -side left 
    pack $site_3_0.men83 \
        -in $site_3_0 -anchor center -expand 1 -fill x -ipady 1 -side right 
    frame $top.cpd84 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd84" "Frame4" vTcl:WidgetProc "Toplevel310" 1
    set site_3_0 $top.cpd84
    frame $site_3_0.cpd67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd67" "Frame5" vTcl:WidgetProc "Toplevel310" 1
    set site_4_0 $site_3_0.cpd67
    menubutton $site_4_0.men77 \
        -menu "$site_4_0.men77.m" -padx 4 -pady 4 -relief raised \
        -text {[ T4 ]} -width 4 
    vTcl:DefineAlias "$site_4_0.men77" "Menubutton310_6" vTcl:WidgetProc "Toplevel310" 1
    bindtags $site_4_0.men77 "$site_4_0.men77 Menubutton $top all _vTclBalloon"
    bind $site_4_0.men77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {6x6 Coherency Matrix}
    }
    menu $site_4_0.men77.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_4_0.men77.m add command \
        \
        -command {global CheckDirInput CheckInputDir CheckInputSubDir
global CheckData CheckType CheckFileName CheckResult CheckFile
global BinaryDataCheck 
#UTIL
global Load_CheckBinaryData PSPTopLevel

if {$Load_CheckBinaryData == 0} {
    source "GUI/tools/CheckBinaryData.tcl"
    set Load_CheckBinaryData 1
    WmTransient $widget(Toplevel316) $PSPTopLevel
    }

    set CheckDirInput $DataDir
    set CheckInputDir $DataDir
    set CheckInputSubDir ""
    set CheckData " "
    set CheckType " "
    set CheckFile ""
    set CheckFileName ""
    set CheckResult ""
    $widget(Button316_3) configure -state normal
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
    WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel316); TextEditorRunTrace "Open Window Check Binary Data" "b"} \
        -label {Data Binary Check} 
    $site_4_0.men77.m add separator \
        
    $site_4_0.men77.m add command \
        \
        -command {global DataDir DirName DirName1 DirName2 CompareDataDir1 CompareDataDir2
global CompareFile1 CompareFile2 CompareFormat1 CompareFormat2
global CompareSample1 CompareSample2 CompareLine1 CompareLine2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol
global CompareResult CompareFormat CompareSubDir CompareDataSubDir FileCompare

#TOOLS
global Load_CompareDir PSPTopLevel

if {$Load_CompareDir == 0} {
    source "GUI/tools/CompareDir.tcl"
    set Load_CompareDir 1
    WmTransient $widget(Toplevel416) $PSPTopLevel
    }

set DirName ""; set DirName1 ""; set DirName2 ""
set CompareDataDir1 $DataDir; set CompareDataDir2 $DataDir
set CompareFile1 ""; set CompareFile2 ""; set CompareFormat1 ""; set CompareFormat2 ""
set CompareSample1 ""; set CompareSample2 ""; set CompareLine1 ""; set CompareLine2 ""
set CompareOffLig ""; set CompareOffCol ""; set CompareSubNlig ""; set CompareSubNcol ""
set CompareResult ""; set CompareFormat ""

for {set i 0} {$i <= 40} {incr i} { set FileCompare($i) ""}
set CompareSubDir " "; set CompareDataSubDir ""

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel416); TextEditorRunTrace "Open Window Compare Data Directory" "b"} \
        -label {Compare Data Directory} 
    $site_4_0.men77.m add separator \
        
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsFormat

set ToolsDirInput ""
set ToolsFormat ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsFormat "T4"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        set ProgressLine "0"
        update
        TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
        TextEditorRunTrace "Arguments: \x22$ToolsDirInput\x22 -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" "k"
        set f [ open "| Soft/bin/tools/create_mask_valid_pixels.exe -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Create Mask Valid Pixels} 
    $site_4_0.men77.m add separator \
        
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_IEEE"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 IEEE FORMAT CONVERT"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T4"
    set ToolsOperation "ieee"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {IEEE Format Convert} 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_SUB"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 COHERENCY SUB DATA EXTRACTION"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T4"
    set ToolsOperation "extract"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Sub Data Extraction} 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_L90"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 COHERENCY ROTATION 90 LEFT"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T4"
    set ToolsOperation "rot90l"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 left} 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R90"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 COHERENCY ROTATION 90 RIGHT"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T4"
    set ToolsOperation "rot90r"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 right} 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }


set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R180"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 COHERENCY ROTATION 180"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T4"
    set ToolsOperation "rot180"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 180} 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FUD"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 COHERENCY FLIP UP DOWN"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T4"
    set ToolsOperation "flipud"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Up-Down} 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FLR"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 COHERENCY FLIP LEFT RIGHT"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T4"
    set ToolsOperation "fliplr"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Left-Right} 
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_TRP"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 COHERENCY TRANSPOSE"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T4"
    set ToolsOperation "transp"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label Transpose 
    $site_4_0.men77.m add separator \
        
    $site_4_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase ToolsMaskFile

#TOOLS
global Load_ToolsMask PSPTopLevel

if {$Load_ToolsMask == 0} {
    source "GUI/tools/ToolsMask.tcl"
    set Load_ToolsMask 1
    WmTransient $widget(Toplevel383) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ToolsMaskFile ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T4"] {
if [file exists "$DataDirChannel1/T4/config.txt"] {
if [file exists "$DataDirChannel1/T4/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T4"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_MASK"
    set ToolsOutputSubDir "T4"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T4 COHERENCY APPLY MASK"
    set ToolsFunction "Soft/bin/tools/float_tools_mask.exe"
    set ToolsFormat "T4"
    set ToolsOperation "mask"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel383); TextEditorRunTrace "Open Window Tools - Mask" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Apply Mask} 
    pack $site_4_0.men77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    menubutton $site_3_0.men77 \
        -menu "$site_3_0.men77.m" -padx 4 -pady 4 -relief raised \
        -text {[ T6 ]} -width 4 
    vTcl:DefineAlias "$site_3_0.men77" "Menubutton310_3" vTcl:WidgetProc "Toplevel310" 1
    bindtags $site_3_0.men77 "$site_3_0.men77 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {6x6 Coherency Matrix}
    }
    menu $site_3_0.men77.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men77.m add command \
        \
        -command {global CheckDirInput CheckInputDir CheckInputSubDir
global CheckData CheckType CheckFileName CheckResult CheckFile
global BinaryDataCheck 
#UTIL
global Load_CheckBinaryData PSPTopLevel

if {$Load_CheckBinaryData == 0} {
    source "GUI/tools/CheckBinaryData.tcl"
    set Load_CheckBinaryData 1
    WmTransient $widget(Toplevel316) $PSPTopLevel
    }

    set CheckDirInput $DataDir
    set CheckInputDir $DataDir
    set CheckInputSubDir ""
    set CheckData " "
    set CheckType " "
    set CheckFile ""
    set CheckFileName ""
    set CheckResult ""
    $widget(Button316_3) configure -state normal
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
    WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel316); TextEditorRunTrace "Open Window Check Binary Data" "b"
} \
        -label {Data Binary Check} 
    $site_3_0.men77.m add separator \
        
    $site_3_0.men77.m add command \
        \
        -command {global DataDir DirName DirName1 DirName2 CompareDataDir1 CompareDataDir2
global CompareFile1 CompareFile2 CompareFormat1 CompareFormat2
global CompareSample1 CompareSample2 CompareLine1 CompareLine2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol
global CompareResult CompareFormat CompareSubDir CompareDataSubDir FileCompare

#TOOLS
global Load_CompareDir PSPTopLevel

if {$Load_CompareDir == 0} {
    source "GUI/tools/CompareDir.tcl"
    set Load_CompareDir 1
    WmTransient $widget(Toplevel416) $PSPTopLevel
    }

set DirName ""; set DirName1 ""; set DirName2 ""
set CompareDataDir1 $DataDir; set CompareDataDir2 $DataDir
set CompareFile1 ""; set CompareFile2 ""; set CompareFormat1 ""; set CompareFormat2 ""
set CompareSample1 ""; set CompareSample2 ""; set CompareLine1 ""; set CompareLine2 ""
set CompareOffLig ""; set CompareOffCol ""; set CompareSubNlig ""; set CompareSubNcol ""
set CompareResult ""; set CompareFormat ""

for {set i 0} {$i <= 40} {incr i} { set FileCompare($i) ""}
set CompareSubDir " "; set CompareDataSubDir ""

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel416); TextEditorRunTrace "Open Window Compare Data Directory" "b"} \
        -label {Compare Data Directory} 
    $site_3_0.men77.m add separator \
        
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsFormat

set ToolsDirInput ""
set ToolsFormat ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsFormat "T6"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        set ProgressLine "0"
        update
        TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
        TextEditorRunTrace "Arguments: \x22$ToolsDirInput\x22 -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" "k"
        set f [ open "| Soft/bin/tools/create_mask_valid_pixels.exe -id \x22$ToolsDirInput\x22 -od \x22$ToolsDirInput\x22 -idf $ToolsFormat -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Create Mask Valid Pixels} 
    $site_3_0.men77.m add separator \
        
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_IEEE"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 IEEE FORMAT CONVERT"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T6"
    set ToolsOperation "ieee"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {IEEE Format Convert} 
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_SUB"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 COHERENCY SUB DATA EXTRACTION"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T6"
    set ToolsOperation "extract"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Sub Data Extraction} 
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_L90"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 COHERENCY ROTATION 90 LEFT"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T6"
    set ToolsOperation "rot90l"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 left} 
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R90"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 COHERENCY ROTATION 90 RIGHT"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T6"
    set ToolsOperation "rot90r"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 90 right} 
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }


set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_R180"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 COHERENCY ROTATION 180"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T6"
    set ToolsOperation "rot180"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Rotation 180} 
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FUD"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 COHERENCY FLIP UP DOWN"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T6"
    set ToolsOperation "flipud"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Up-Down} 
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_FLR"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 COHERENCY FLIP LEFT RIGHT"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T6"
    set ToolsOperation "fliplr"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Flip Left-Right} 
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase

#TOOLS
global Load_Tools PSPTopLevel

if {$Load_Tools == 0} {
    source "GUI/tools/Tools.tcl"
    set Load_Tools 1
    WmTransient $widget(Toplevel29) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_TRP"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 COHERENCY TRANSPOSE"
    set ToolsFunction "Soft/bin/tools/float_tools.exe"
    set ToolsFormat "T6"
    set ToolsOperation "transp"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel29); TextEditorRunTrace "Open Window Tools" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label Transpose 
    $site_3_0.men77.m add separator \
        
    $site_3_0.men77.m add command \
        \
        -command {global DataDirChannel1 ConfigFile VarError ErrorMessage NcolFullSize
global ToolsDirInput ToolsDirOutput ToolsOutputDir ToolsOutputSubDir ToolsDirOutputErase
global ToolsOperation ToolsFormat ToolsFonction ToolsFunction ToolsErase ToolsMaskFile

#TOOLS
global Load_ToolsMask PSPTopLevel

if {$Load_ToolsMask == 0} {
    source "GUI/tools/ToolsMask.tcl"
    set Load_ToolsMask 1
    WmTransient $widget(Toplevel383) $PSPTopLevel
    }

set ToolsDirInput ""
set ToolsDirOutput ""
set ToolsFonction ""
set ToolsFunction ""
set ToolsFormat ""
set ToolsErase "0"
set ToolsMaskFile ""
set ConfigFile ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0

if [file isdirectory "$DataDirChannel1/T6"] {
if [file exists "$DataDirChannel1/T6/config.txt"] {
if [file exists "$DataDirChannel1/T6/T11.bin"] {
    set ToolsDirInput "$DataDirChannel1/T6"
    set ToolsDirOutputErase $DataDirChannel1
    set ToolsOutputDir $ToolsDirOutputErase
    append ToolsOutputDir "_MASK"
    set ToolsOutputSubDir "T6"
    set ToolsDirOutput $ToolsDirOutputErase
    set ToolsFonction "T6 COHERENCY APPLY MASK"
    set ToolsFunction "Soft/bin/tools/float_tools_mask.exe"
    set ToolsFormat "T6"
    set ToolsOperation "mask"
    set ConfigFile "$ToolsDirInput/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set NcolFullSize $NcolEnd
        WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel383); TextEditorRunTrace "Open Window Tools - Mask" "b"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T6 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -label {Apply Mask} 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.men77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menubutton $top.men77 \
        -menu "$top.men77.m" -padx 7 -pady 5 -relief raised \
        -text {Data File Management} 
    vTcl:DefineAlias "$top.men77" "Menubutton1" vTcl:WidgetProc "Toplevel310" 1
    bindtags $top.men77 "$top.men77 Menubutton $top all _vTclBalloon"
    bind $top.men77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Data File Management}
    }
    menu $top.men77.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $top.men77.m add command \
        \
        -command {global CheckDirInput CheckInputDir CheckInputSubDir
global CheckData CheckType CheckFileName CheckResult CheckFile
global BinaryDataCheck 
#UTIL
global Load_CheckBinaryData PSPTopLevel

if {$Load_CheckBinaryData == 0} {
    source "GUI/tools/CheckBinaryData.tcl"
    set Load_CheckBinaryData 1
    WmTransient $widget(Toplevel316) $PSPTopLevel
    }

    set CheckDirInput $DataDir
    set CheckInputDir $DataDir
    set CheckInputSubDir ""
    set CheckData " "
    set CheckType " "
    set CheckFile ""
    set CheckFileName ""
    set CheckResult ""
    $widget(Button316_3) configure -state normal
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
    WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel316); TextEditorRunTrace "Open Window Check Binary Data" "b"
} \
        -label {Data Binary Check} 
    $top.men77.m add separator \
        
    $top.men77.m add command \
        \
        -command {global DataDir CompareDataDir1 CompareDataDir2
global CompareFile1 CompareFile2 CompareFormat1 CompareFormat2
global CompareSample1 CompareSample2 CompareLine1 CompareLine2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol
global CompareResult

#TOOLS
global Load_CompareFile PSPTopLevel

if {$Load_CompareFile == 0} {
    source "GUI/tools/CompareFile.tcl"
    set Load_CompareFile 1
    WmTransient $widget(Toplevel406) $PSPTopLevel
    }

set CompareDataDir1 $DataDir; set CompareDataDir2 $DataDir
set CompareFile1 ""; set CompareFile2 ""; set CompareFormat1 ""; set CompareFormat2 ""
set CompareSample1 ""; set CompareSample2 ""; set CompareLine1 ""; set CompareLine2 ""
set CompareOffLig ""; set CompareOffCol ""; set CompareSubNlig ""; set CompareSubNcol ""
set CompareResult ""

package require Img
image create photo ImageConfig
ImageConfig blank
$widget(Label406_2) configure -anchor nw -image ImageConfig
image delete ImageConfig
image create photo ImageConfig -file "GUI/Images/smiley_transparent.gif"
$widget(Label406_2) configure -anchor nw -image ImageConfig

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel406); TextEditorRunTrace "Open Window Compare Binary Files" "b"} \
        -label {Compare Binary Files} 
    $top.men77.m add command \
        \
        -command {global DataDir ReadDataDir
global ReadFile ReadFormat ReadSample ReadLine
global ReadLig ReadCol 
global ReadReal ReadImag ReadMod ReadArg

#TOOLS
global Load_ReadBinaryDataFileValue PSPTopLevel

if {$Load_ReadBinaryDataFileValue == 0} {
    source "GUI/tools/ReadBinaryDataFileValue.tcl"
    set Load_ReadBinaryDataFileValue 1
    WmTransient $widget(Toplevel418) $PSPTopLevel
    }

set ReadDataDir $DataDir
set ReadFile ""; set ReadFormat ""
set ReadSample ""; set ReadLine ""
set ReadLig ""; set ReadCol ""
set ReadReal ""; set ReadImag ""
set ReadMod ""; set ReadArg ""

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel418); TextEditorRunTrace "Open Window Read Binary Data File Value" "b"} \
        -label {Read Binary Data Value} 
    $top.men77.m add separator \
        
    $top.men77.m add command \
        \
        -command {global FileNameSourceCopy FileNameTargetCopy

#TOOLS
global Load_CopyFile PSPTopLevel

if {$Load_CopyFile == 0} {
    source "GUI/tools/CopyFile.tcl"
    set Load_CopyFile 1
    WmTransient $widget(Toplevel54) $PSPTopLevel
    }

set FileNameSourceCopy ""
set FileNameTargetCopy ""
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel54); TextEditorRunTrace "Open Window Copy File" "b"} \
        -label {Copy File} 
    $top.men77.m add command \
        \
        -command {global FileNameDelete

#TOOLS
global Load_DeleteFile PSPTopLevel

if {$Load_DeleteFile == 0} {
    source "GUI/tools/DeleteFile.tcl"
    set Load_DeleteFile 1
    WmTransient $widget(Toplevel63) $PSPTopLevel
    }

set FileNameDelete ""
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel63); TextEditorRunTrace "Open Window Delete File" "b"} \
        -label {Delete File} 
    $top.men77.m add command \
        \
        -command {global FileNameSourceRename FileNameTargetRename

#TOOLS
global Load_RenameFile PSPTopLevel

if {$Load_RenameFile == 0} {
    source "GUI/tools/RenameFile.tcl"
    set Load_RenameFile 1
    WmTransient $widget(Toplevel59) $PSPTopLevel
    }

set FileNameSourceRename ""
set FileNameTargetRename ""
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel59); TextEditorRunTrace "Open Window Rename File" "b"} \
        -label {Rename File} 
    $top.men77.m add separator \
        
    $top.men77.m add command \
        \
        -command {global DataFileSourceName DataFileTargetName
glogal DataFileSourceDir DataFileTargetDir
global DataFileFormat DataFileOperation DataFileFunction
global NligEndTools NligInitTools NcolEndTools NcolInitTools

#TOOLS
global Load_DataFileManagement PSPTopLevel

if {$Load_DataFileManagement == 0} {
    source "GUI/tools/DataFileManagement.tcl"
    set Load_DataFileManagement 1
    WmTransient $widget(Toplevel371) $PSPTopLevel
    }

set DataFileSourceDir ""
set DataFileSourceName ""
set DataFileTargetDir ""
set DataFileTargetName ""
set DataFileFunction "IEEE DATA FORMAT CONVERT"
set DataFileOperation "ieee"
set DataFileFormat "float"
set NligInitTools "?"; set NcolInitTools "?"
set NligEndTools "?"; set NcolEndTools "?"

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel371); TextEditorRunTrace "Open Window Data File Management" "b"} \
        -label {IEEE Format Convert} 
    $top.men77.m add command \
        \
        -command {global DataFileSourceName DataFileTargetName
global DataFileSourceDir DataFileTargetDir 
global DataFileFormat DataFileOperation DataFileFunction
global NligEndTools NligInitTools NcolEndTools NcolInitTools

#TOOLS
global Load_DataFileManagement PSPTopLevel

if {$Load_DataFileManagement == 0} {
    source "GUI/tools/DataFileManagement.tcl"
    set Load_DataFileManagement 1
    WmTransient $widget(Toplevel371) $PSPTopLevel
    }

set DataFileSourceDir ""
set DataFileSourceName ""
set DataFileTargetDir ""
set DataFileTargetName ""
set DataFileFunction "SUB DATA EXTRACTION"
set DataFileOperation "extract"
set DataFileFormat "float"
set NligInitTools "?"; set NcolInitTools "?"
set NligEndTools "?"; set NcolEndTools "?"

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel371); TextEditorRunTrace "Open Window Data File Management" "b"} \
        -label {Sub Data Extraction} 
    $top.men77.m add command \
        \
        -command {global DataFileSourceName DataFileTargetName
global DataFileSourceDir DataFileTargetDir 
global DataFileFormat DataFileOperation DataFileFunction
global NligEndTools NligInitTools NcolEndTools NcolInitTools

#TOOLS
global Load_DataFileManagement PSPTopLevel

if {$Load_DataFileManagement == 0} {
    source "GUI/tools/DataFileManagement.tcl"
    set Load_DataFileManagement 1
    WmTransient $widget(Toplevel371) $PSPTopLevel
    }

set DataFileSourceDir ""
set DataFileSourceName ""
set DataFileTargetDir ""
set DataFileTargetName ""
set DataFileFunction "DATA ROTATION 90 LEFT"
set DataFileOperation "rot90l"
set DataFileFormat "float"
set NligInitTools "?"; set NcolInitTools "?"
set NligEndTools "?"; set NcolEndTools "?"

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel371); TextEditorRunTrace "Open Window Data File Management" "b"} \
        -label {Rotation 90 left} 
    $top.men77.m add command \
        \
        -command {global DataFileSourceName DataFileTargetName
global DataFileSourceDir DataFileTargetDir 
global DataFileFormat DataFileOperation DataFileFunction
global NligEndTools NligInitTools NcolEndTools NcolInitTools

#TOOLS
global Load_DataFileManagement PSPTopLevel

if {$Load_DataFileManagement == 0} {
    source "GUI/tools/DataFileManagement.tcl"
    set Load_DataFileManagement 1
    WmTransient $widget(Toplevel371) $PSPTopLevel
    }

set DataFileSourceDir ""
set DataFileSourceName ""
set DataFileTargetDir ""
set DataFileTargetName ""
set DataFileFunction "DATA ROTATION 90 RIGHT"
set DataFileOperation "rot90r"
set DataFileFormat "float"
set NligInitTools "?"; set NcolInitTools "?"
set NligEndTools "?"; set NcolEndTools "?"

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel371); TextEditorRunTrace "Open Window Data File Management" "b"} \
        -label {Rotation 90 right} 
    $top.men77.m add command \
        \
        -command {global DataFileSourceName DataFileTargetName
global DataFileSourceDir DataFileTargetDir 
global DataFileFormat DataFileOperation DataFileFunction
global NligEndTools NligInitTools NcolEndTools NcolInitTools

#TOOLS
global Load_DataFileManagement PSPTopLevel

if {$Load_DataFileManagement == 0} {
    source "GUI/tools/DataFileManagement.tcl"
    set Load_DataFileManagement 1
    WmTransient $widget(Toplevel371) $PSPTopLevel
    }

set DataFileSourceDir ""
set DataFileSourceName ""
set DataFileTargetDir ""
set DataFileTargetName ""
set DataFileFunction "DATA ROTATION 180"
set DataFileOperation "rot180"
set DataFileFormat "float"
set NligInitTools "?"; set NcolInitTools "?"
set NligEndTools "?"; set NcolEndTools "?"

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel371); TextEditorRunTrace "Open Window Data File Management" "b"} \
        -label {Rotation 180} 
    $top.men77.m add command \
        \
        -command {global DataFileSourceName DataFileTargetName
global DataFileSourceDir DataFileTargetDir 
global DataFileFormat DataFileOperation DataFileFunction
global NligEndTools NligInitTools NcolEndTools NcolInitTools

#TOOLS
global Load_DataFileManagement PSPTopLevel

if {$Load_DataFileManagement == 0} {
    source "GUI/tools/DataFileManagement.tcl"
    set Load_DataFileManagement 1
    WmTransient $widget(Toplevel371) $PSPTopLevel
    }

set DataFileSourceDir ""
set DataFileSourceName ""
set DataFileTargetDir ""
set DataFileTargetName ""
set DataFileFunction "DATA FLIP UP - DOWN"
set DataFileOperation "flipud"
set DataFileFormat "float"
set NligInitTools "?"; set NcolInitTools "?"
set NligEndTools "?"; set NcolEndTools "?"

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel371); TextEditorRunTrace "Open Window Data File Management" "b"} \
        -label {Flip Up-Down} 
    $top.men77.m add command \
        \
        -command {global DataFileSourceName DataFileTargetName
global DataFileSourceDir DataFileTargetDir 
global DataFileFormat DataFileOperation DataFileFunction
global NligEndTools NligInitTools NcolEndTools NcolInitTools

#TOOLS
global Load_DataFileManagement PSPTopLevel

if {$Load_DataFileManagement == 0} {
    source "GUI/tools/DataFileManagement.tcl"
    set Load_DataFileManagement 1
    WmTransient $widget(Toplevel371) $PSPTopLevel
    }

sqet DataFileSourceDir ""
set DataFileSourceName ""
set DataFileTargetDir ""
set DataFileTargetName ""
set DataFileFunction "DATA FLIP LEFT - RIGHT"
set DataFileOperation "fliplr"
set DataFileFormat "float"
set NligInitTools "?"; set NcolInitTools "?"
set NligEndTools "?"; set NcolEndTools "?"

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel371); TextEditorRunTrace "Open Window Data File Management" "b"} \
        -label {Flip Left-Right} 
    $top.men77.m add command \
        \
        -command {global DataFileSourceName DataFileTargetName
global DataFileSourceDir DataFileTargetDir 
global DataFileFormat DataFileOperation DataFileFunction
global NligEndTools NligInitTools NcolEndTools NcolInitTools

#TOOLS
global Load_DataFileManagement PSPTopLevel

if {$Load_DataFileManagement == 0} {
    source "GUI/tools/DataFileManagement.tcl"
    set Load_DataFileManagement 1
    WmTransient $widget(Toplevel371) $PSPTopLevel
    }

set DataFileSourceDir ""
set DataFileSourceName ""
set DataFileTargetDir ""
set DataFileTargetName ""
set DataFileFunction "DATA TRANSPOSE"
set DataFileOperation "transp"
set DataFileFormat "float"
set NligInitTools "?"; set NcolInitTools "?"
set NligEndTools "?"; set NcolEndTools "?"

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel371); TextEditorRunTrace "Open Window Data File Management" "b"} \
        -label Transpose 
    $top.men77.m add separator \
        
    $top.men77.m add command \
        \
        -command {global FileNameInput FileNameOutput1 FileNameOutput2
global CmplxOutputFormat NligCmplx NcolCmplx
#TOOLS
global Load_ComplexFile PSPTopLevel


if {$Load_ComplexFile == 0} {
    source "GUI/tools/ComplexFile.tcl"
    set Load_ComplexFile 1
    WmTransient $widget(Toplevel417) $PSPTopLevel
    }

set FileNameInput ""
set FileNameOutput1 ""
set FileNameOutput2 ""
set NligCmplx ""
set NcolCmplx ""
set CmplxOutputFormat " "

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel417); TextEditorRunTrace "Open Window Complex Data File" "b"} \
        -label {Complex Data File} 
    $top.men77.m add separator \
        
    $top.men77.m add command \
        \
        -command {global DataDir SupervisedDirInput SupervisedDirOutput SupervisedOutputDir SupervisedOutputSubDir 
global ConfigFile VarError ErrorMessage NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol
global FileTrainingSet FileTrainingArea Fonction VarTrainingArea MaskFonction

#DATA PROCESS SNGL
global Load_CreateMask PSPTopLevel

if {$Load_CreateMask == 0} {
    source "GUI/tools/CreateMask.tcl"
    set Load_CreateMask 1
    WmTransient $widget(Toplevel379) $PSPTopLevel
    }

set NTrainingArea(0) 0        
set AreaPoint(0) 0
set AreaPointLig(0) 0
set AreaPointCol(0) 0
for {set i 0} {$i <= 17} {incr i} {
    set NTrainingArea($i) ""
    for {set j 0} {$j <= 17} {incr j} {
        set Argument [expr (100*$i + $j)]
        set AreaPoint($Argument) ""
        for {set k 0} {$k <= 17} {incr k} {
            set Argument [expr (10000*$i + 100*$j + $k)]
            set AreaPointLig($Argument) ""
            set AreaPointCol($Argument) ""
            }
        }
    }           

set SupervisedDirInput ""
set SupervisedDirOutput "SELECT THE OUTPUT DIRECTORY FIRST"
set SupervisedOutputDir ""
set SupervisedOutputSubDir ""

set MaskFonction "1"

set FileTrainingSet ""
set FileTrainingArea ""

set AreaClassN 1
set AreaN 1

$widget(Button379_1) configure -state disable
$widget(Button379_3) configure -state disable
$widget(Button379_4) configure -state disable

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel379); TextEditorRunTrace "Open Window Create Mask" "b"} \
        -label {Create MASK} 
    $top.men77.m add separator \
        
    $top.men77.m add command \
        \
        -command {global FileNameSourceHDR FileNameTargetHDR FileHDRFormat

#TOOLS
global Load_CreateHDRFile PSPTopLevel

if {$Load_CreateHDRFile == 0} {
    source "GUI/tools/CreateHDRFile.tcl"
    set Load_CreateHDRFile 1
    WmTransient $widget(Toplevel372) $PSPTopLevel
    }

set FileNameSourceHDR ""
set FileNameTargetHDR ""
set FileHDRFormat "float"
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel372); TextEditorRunTrace "Open Window Create ENVI ( .hdr ) File" "b"} \
        -label {Create ENVI ( .hdr ) File} 
    menubutton $top.men66 \
        -menu "$top.men66.m" -padx 5 -pady 4 -relief raised \
        -text {Directory Management} 
    vTcl:DefineAlias "$top.men66" "Menubutton4" vTcl:WidgetProc "Toplevel310" 1
    menu $top.men66.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $top.men66.m add command \
        \
        -command {global DirNameCreate

#TOOLS
global Load_CreateDirectory PSPTopLevel

if {$Load_CreateDirectory == 0} {
    source "GUI/tools/CreateDirectory.tcl"
    set Load_CreateDirectory 1
    WmTransient $widget(Toplevel33) $PSPTopLevel
    }

set DirNameCreate ""
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel33); TextEditorRunTrace "Open Window Create Directory" "b"} \
        -label {Create Directory} 
    $top.men66.m add command \
        \
        -command {global DirNameSourceCopy DirNameTargetCopy

#TOOLS
global Load_CopyDirectory PSPTopLevel

if {$Load_CopyDirectory == 0} {
    source "GUI/tools/CopyDirectory.tcl"
    set Load_CopyDirectory 1
    WmTransient $widget(Toplevel37) $PSPTopLevel
    }

set DirNameSourceCopy ""
set DirNameTargetCopy ""
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel37); TextEditorRunTrace "Open Window Copy Directory" "b"} \
        -label {Copy Directory} 
    $top.men66.m add command \
        \
        -command {global DirNameDelete

#TOOLS
global Load_DeleteDirectory PSPTopLevel

if {$Load_DeleteDirectory == 0} {
    source "GUI/tools/DeleteDirectory.tcl"
    set Load_DeleteDirectory 1
    WmTransient $widget(Toplevel36) $PSPTopLevel
    }

set DirNameDelete ""
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel36); TextEditorRunTrace "Open Window Delete Directory" "b"} \
        -label {Delete Directory} 
    $top.men66.m add command \
        \
        -command {global DirNameSourceRename DirNameTargetRename

#TOOLS
global Load_RenameDirectory PSPTopLevel

if {$Load_RenameDirectory == 0} {
    source "GUI/tools/RenameDirectory.tcl"
    set Load_RenameDirectory 1
    WmTransient $widget(Toplevel50) $PSPTopLevel
    }

set DirNameSourceRename ""
set DirNameTargetRename ""
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel50); TextEditorRunTrace "Open Window Rename Directory" "b"} \
        -label {Rename Directory} 
    menubutton $top.men73 \
        -menu "$top.men73.m" -padx 7 -pady 5 -relief raised \
        -text {My Function} 
    vTcl:DefineAlias "$top.men73" "Menubutton3" vTcl:WidgetProc "Toplevel310" 1
    bindtags $top.men73 "$top.men73 Menubutton $top all _vTclBalloon"
    bind $top.men73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {My Function Functionalities}
    }
    menu $top.men73.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $top.men73.m add command \
        \
        -command {global MyFunctionFullName MyFunctionName MyFunctionPath VarMyFunction
global MyFunctionVar MyFunctionVarN MyFunctionVarName MyFunctionVarType
#TOOLS
global Load_CreateMyFunction PSPTopLevel

if {$Load_CreateMyFunction == 0} {
    source "GUI/tools/CreateMyFunction.tcl"
    set Load_CreateMyFunction 1
    WmTransient $widget(Toplevel101) $PSPTopLevel
    }

set VarMyFunction ""
set MyFunctionFullName ""
set MyFunctionName ""
set MyFunctionPath ""

set MyFunctionVar "0"
set MyFunctionVarN "0"
for {set i 0} {$i <= 20} {incr i} {
    set MyFunctionVarName($i) ""
    set MyFunctionVarType($i) ""
    }
$widget(TitleFrame101_1) configure -state disable
$widget(TitleFrame101_2) configure -state disable
$widget(TitleFrame101_3) configure -state disable
$widget(Entry101_1) configure -state disable
$widget(Entry101_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry101_2) configure -state disable
$widget(Entry101_2) configure -disabledbackground $PSPBackgroundColor
$widget(Radiobutton101_1) configure -state disable
$widget(Radiobutton101_2) configure -state disable
$widget(Radiobutton101_3) configure -state disable
$widget(Radiobutton101_4) configure -state disable
$widget(Button101_1) configure -state disable
$widget(Button101_2) configure -state disable
$widget(Button101_3) configure -state disable
$widget(Button101_4) configure -state disable
$widget(Button101_5) configure -state disable
$widget(Button101_6) configure -state disable
$widget(Button101_7) configure -state disable
    
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel101); TextEditorRunTrace "Open Window Create My Function" "b"} \
        -label Create 
    $top.men73.m add command \
        \
        -command {global MyFunctionFullName MyFunctionName VarMyFunction
#TOOLS
global Load_DeleteMyFunction PSPTopLevel

if {$Load_DeleteMyFunction == 0} {
    source "GUI/tools/DeleteMyFunction.tcl"
    set Load_DeleteMyFunction 1
    WmTransient $widget(Toplevel121) $PSPTopLevel
    }

set VarMyFunction ""
set MyFunctionFullName ""
set MyFunctionName ""
WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel121); TextEditorRunTrace "Open Window Delete My Function" "b"} \
        -label Delete 
    $top.men73.m add separator \
        
    $top.men73.m add command \
        \
        -command {global MyFunctionFullName MyFunctionName MyFunctionPath MyFunctionVar
global MyFunctionVarN MyFunctionVarName MyFunctionVarType MyFunctionVarValue
global VarName VarType VarValue1 VarValue2 VarMyFunction
#TOOLS
global Load_ExecuteMyFunction PSPTopLevel

if {$Load_ExecuteMyFunction == 0} {
    source "GUI/tools/ExecuteMyFunction.tcl"
    set Load_ExecuteMyFunction 1
    WmTransient $widget(Toplevel130) $PSPTopLevel
    }

set VarMyFunction ""
set MyFunctionFullName ""
set MyFunctionName ""
set MyFunctionPath ""
set MyFunctionVar ""
set MyFunctionVarN ""
set VarName ""
set VarType " "
set VarValue1 ""
set VarValue2 ""
for {set i 0} {$i <= 20} {incr i} {
    set MyFunctionVarName($i) ""
    set MyFunctionVarType($i) ""
    set MyFunctionVarValue($i) "?"
    }
$widget(TitleFrame130_0) configure -state disable
$widget(TitleFrame130_1) configure -state disable
$widget(TitleFrame130_2) configure -state disable
$widget(Entry130_1) configure -state disable
$widget(Entry130_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry130_2) configure -state disable
$widget(Entry130_2) configure -disabledbackground $PSPBackgroundColor
$widget(Button130_1) configure -state disable
$widget(Button130_2) configure -state disable
$widget(Entry130_3) configure -state disable
$widget(Entry130_3) configure -disabledbackground $PSPBackgroundColor
$widget(Entry130_4) configure -state disable
$widget(Entry130_4) configure -disabledbackground $PSPBackgroundColor
$widget(TitleFrame130_3) configure -state disable
$widget(TitleFrame130_4) configure -state disable
$widget(Entry130_5) configure -state disable
$widget(Entry130_5) configure -disabledbackground $PSPBackgroundColor
$widget(Entry130_6) configure -state disable
$widget(Entry130_6) configure -disabledbackground $PSPBackgroundColor
$widget(Button130_3) configure -state disable

WidgetShowFromMenuFix $widget(Toplevel310) $widget(Toplevel130); TextEditorRunTrace "Open Window Execute My Function" "b"} \
        -label Execute 
    frame $top.fra26 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra26" "Frame413" vTcl:WidgetProc "Toplevel310" 1
    set site_3_0 $top.fra26
    button $site_3_0.but87 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ToolsMenuDual.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text button -width 20 
    vTcl:DefineAlias "$site_3_0.but87" "Button1" vTcl:WidgetProc "Toplevel310" 1
    bindtags $site_3_0.but87 "$site_3_0.but87 Button $top all _vTclBalloon"
    bind $site_3_0.but87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help}
    }
    button $site_3_0.but27 \
        -background #ffff00 \
        -command {global OpenDirFile
global Load_CopyDirectory Load_CopyFile Load_CreateDirectory Load_CreateFunction Load_DeleteDirectory
global Load_DeleteFile Load_DeleteFunction Load_ExecuteFunction Load_RenameDirectory Load_RenameFile
global Load_Tools Load_ToolsFFT Load_ExportENVI
global Load_CheckBinaryData Load_CompareDir Load_ToolsMask Load_CompareFile 
global Load_ReadBinaryDataFileValue Load_DataFileManagement Load_ComplexFile 
global Load_CreateMask Load_CreateHDRFile 

if {$OpenDirFile == 0} {

if {$Load_CopyDirectory == 1} { Window hide $widget(Toplevel37) }
if {$Load_CopyFile == 1} { Window hide $widget(Toplevel54) }
if {$Load_CreateDirectory == 1} { Window hide $widget(Toplevel33) }
if {$Load_CreateMyFunction == 1} { Window hide $widget(Toplevel101) }
if {$Load_DeleteDirectory == 1} { Window hide $widget(Toplevel36) }
if {$Load_DeleteFile == 1} { Window hide $widget(Toplevel63) }
if {$Load_DeleteMyFunction == 1} { Window hide $widget(Toplevel121) }
if {$Load_ExecuteMyFunction == 1} { Window hide $widget(Toplevel130) }
if {$Load_RenameDirectory == 1} { Window hide $widget(Toplevel50) }
if {$Load_RenameFile == 1} { Window hide $widget(Toplevel59) }
if {$Load_Tools == 1} { Window hide $widget(Toplevel29) }
if {$Load_ToolsFFT == 1} { Window hide $widget(Toplevel58) }
if {$Load_ExportENVI == 1} { Window hide $widget(Toplevel217) }
if {$Load_CheckBinaryData == 1} { Window hide $widget(Toplevel316) }
if {$Load_CompareDir == 1} { Window hide $widget(Toplevel416) }
if {$Load_ToolsMask == 1} { Window hide $widget(Toplevel383) }
if {$Load_CompareFile == 1} { Window hide $widget(Toplevel406) }
if {$Load_ReadBinaryDataFileValue == 1} { Window hide $widget(Toplevel418) }
if {$Load_DataFileManagement == 1} { Window hide $widget(Toplevel371) }
if {$Load_ComplexFile == 1} { Window hide $widget(Toplevel417) }
if {$Load_CreateMask == 1} { Window hide $widget(Toplevel379) }
if {$Load_CreateHDRFile == 1} { Window hide $widget(Toplevel372) }

$widget(Menubutton310_1) configure -state normal
$widget(Menubutton310_2) configure -state normal
$widget(Menubutton310_3) configure -state normal
Window hide $widget(Toplevel310); TextEditorRunTrace "Close Window Tools Dual Menu" "b"
}} \
        -padx 4 -pady 2 -text Exit -width 4 
    vTcl:DefineAlias "$site_3_0.but27" "Button35" vTcl:WidgetProc "Toplevel310" 1
    bindtags $site_3_0.but27 "$site_3_0.but27 Button $top all _vTclBalloon"
    bind $site_3_0.but27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit Tools}
    }
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab53 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd86 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd84 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.men77 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.men66 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.men73 \
        -in $top -anchor center -expand 1 -fill x -side top 
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
Window show .top310

main $argc $argv
