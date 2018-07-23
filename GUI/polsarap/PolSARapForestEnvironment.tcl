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
        {{[file join . GUI Images DecrDir.gif]} {user image} user {}}
        {{[file join . GUI Images HomeDir.gif]} {user image} user {}}

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
    set base .top536
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra69
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra81
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra81
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra81
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top536
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

proc vTclWindow.top536 {base} {
    if {$base == ""} {
        set base .top536
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
    wm geometry $top 500x196+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Environment : Dual-Baseline Pol-InSAR"
    vTcl:DefineAlias "$top" "Toplevel536" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra69" "Frame1" vTcl:WidgetProc "Toplevel536" 1
    set site_3_0 $top.fra69
    button $site_3_0.cpd71 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/util/EnvironnementDual.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -padx 1 -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.cpd71" "Button12" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_3_0.cpd71 "$site_3_0.cpd71 Button $top all _vTclBalloon"
    bind $site_3_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.cpd66 \
        -background #ffff00 \
        -command {global OpenDirFile ActiveProgram2 DataFormatActive2
global DataDirTmp3 DataDirChannel3

if {$OpenDirFile == 0} {
set DataDirTmp3 ""
set DataDirChannel3 ""
set ActiveProgram2 ""
set DataFormatActive2 ""
Window hide $widget(Toplevel536); TextEditorRunTrace "Close Window PolSARap Showcase Forest - Environment" "b"
}} \
        -padx 4 -pady 2 -text {Exit (without saving)} 
    bindtags $site_3_0.cpd66 "$site_3_0.cpd66 Button $top all _vTclBalloon"
    bind $site_3_0.cpd66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    button $site_3_0.cpd70 \
        -background #ffff00 \
        -command {global OpenDirFile CONFIGDir
global DataDirTmp1 DataDirChannel1 DataDirTmp2 DataDirChannel2 DataDirTmp3 DataDirChannel3

if {$OpenDirFile == 0} {
#if {$DataDirTmp1 != $DataDirChannel1 || $DataDirTmp3 != $DataDirChannel3} {
#    #MenuRAZ
#    CloseAllWidget
#    }
CheckEnvironnement2
set DataDirTmp1 $DataDirChannel1
set DataDirTmp3 $DataDirChannel3
Window hide $widget(Toplevel536); TextEditorRunTrace "Close Window PolSARap Showcase Forest - Environment" "b"
}} \
        -padx 4 -pady 2 -text {Save & Exit} 
    bindtags $site_3_0.cpd70 "$site_3_0.cpd70 Button $top all _vTclBalloon"
    bind $site_3_0.cpd70 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save Configuration and Exit the Function}
    }
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit92 \
        -ipad 0 -text {Main Input Master Directory} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame536_1" vTcl:WidgetProc "Toplevel536" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    entry $site_4_0.cpd79 \
        -background #ffffff -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DataDirChannel1 
    vTcl:DefineAlias "$site_4_0.cpd79" "Entry536_1" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Entry $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Main Directory}
    }
    frame $site_4_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra81" "Frame5" vTcl:WidgetProc "Toplevel536" 1
    set site_5_0 $site_4_0.fra81
    button $site_5_0.cpd82 \
        \
        -command {global ActiveProgram ConfigFile PolarType
global DirName DataDirChannel1 BMPDirInput DataDirTmp1

MenuOff
set DataDirTmp1 $DataDirChannel1
set DirName ""
if {$ActiveProgram == "POLINSAR"} {OpenDir "$DataDirChannel1" "DATA INPUT MASTER DIRECTORY"}
if {$ActiveProgram == "DUALFREQ"} {OpenDir "$DataDirChannel1" "DATA INPUT FREQUENCY CHANNEL 1 DIRECTORY"}
if {$DirName != ""} {
    set DataDirChannel1 $DirName
    } else {
    set DataDirChannel1 $DataDirTmp1
    }

set BMPDirInput $DataDirChannel1

CheckEnvBinData} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -state disabled -text button 
    vTcl:DefineAlias "$site_5_0.cpd82" "Button536_1" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd82 "$site_5_0.cpd82 Button $top all _vTclBalloon"
    bind $site_5_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Directory}
    }
    button $site_5_0.cpd72 \
        \
        -command {global DataDirChannel1 OpenDirFile DataDirTmp1

if {$OpenDirFile == 0} {
set DataDirTmp1 $DataDirChannel1
MenuOff
set DataDirChannel1 [file dirname $DataDirChannel1]
CheckEnvBinData
}} \
        -image [vTcl:image:get_image [file join . GUI Images DecrDir.gif]] \
        -pady 0 -state disabled -text button 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button536_2" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Parent Directory}
    }
    button $site_5_0.cpd73 \
        \
        -command {global DataDirChannel1 OpenDirFile DataDirTmp1

if {$OpenDirFile == 0} {
set DataDirTmp1 $DataDirChannel1
MenuOff
set DataDirChannel1 $env(HOME)
CheckEnvBinData
}} \
        -image [vTcl:image:get_image [file join . GUI Images HomeDir.gif]] \
        -pady 0 -state disabled -text button 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button536_3" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Home Directory}
    }
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Main Input Slave - 1 Directory} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame536" vTcl:WidgetProc "Toplevel536" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd79 \
        -background #ffffff -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DataDirChannel2 
    vTcl:DefineAlias "$site_4_0.cpd79" "Entry536_2" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Entry $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Main Directory}
    }
    frame $site_4_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra81" "Frame18" vTcl:WidgetProc "Toplevel536" 1
    set site_5_0 $site_4_0.fra81
    button $site_5_0.cpd82 \
        \
        -command {global ActiveProgram ConfigFile PolarType
global DirName DataDirChannel2 DataDirTmp2

MenuOff
set DataDirTmp2 $DataDirChannel2
set DirName ""
if {$ActiveProgram == "POLINSAR"} {OpenDir "$DataDirChannel2" "DATA INPUT SLAVE-1 DIRECTORY"}
if {$DirName != ""} {
    set DataDirChannel2 $DirName
    } else {
    set DataDirChannel2 $DataDirTmp2
    }

CheckEnvBinData} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -state disabled -text button 
    vTcl:DefineAlias "$site_5_0.cpd82" "Button536_4" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd82 "$site_5_0.cpd82 Button $top all _vTclBalloon"
    bind $site_5_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Directory}
    }
    button $site_5_0.cpd72 \
        \
        -command {global DataDirChannel2 OpenDirFile DataDirTmp2

if {$OpenDirFile == 0} {
set DataDirTmp2 $DataDirChannel2
MenuOff
set DataDirChannel2 [file dirname $DataDirChannel2]
CheckEnvBinData
}} \
        -image [vTcl:image:get_image [file join . GUI Images DecrDir.gif]] \
        -pady 0 -state disabled -text button 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button536_5" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Parent Directory}
    }
    button $site_5_0.cpd73 \
        \
        -command {global DataDirChannel2 OpenDirFile DataDirTmp2

if {$OpenDirFile == 0} {
set DataDirTmp2 $DataDirChannel2
MenuOff
set DataDirChannel2 $env(HOME)
CheckEnvBinData
}} \
        -image [vTcl:image:get_image [file join . GUI Images HomeDir.gif]] \
        -pady 0 -state disabled -text button 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button536_6" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Home Directory}
    }
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd67 \
        -ipad 0 -text {Main Input Slave - 2 Directory} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame454" vTcl:WidgetProc "Toplevel536" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    entry $site_4_0.cpd79 \
        -background #ffffff -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DataDirChannel3 
    vTcl:DefineAlias "$site_4_0.cpd79" "Entry536_3" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Entry $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Main Directory}
    }
    frame $site_4_0.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra81" "Frame19" vTcl:WidgetProc "Toplevel536" 1
    set site_5_0 $site_4_0.fra81
    button $site_5_0.cpd82 \
        \
        -command {global ActiveProgram ConfigFile PolarType
global DirName DataDirChannel3 DataDirTmp3

set DataDirTmp3 $DataDirChannel3
set DirName ""
if {$ActiveProgram == "POLINSAR"} {OpenDir "$DataDirChannel3" "DATA INPUT SLAVE-2 DIRECTORY"}
if {$DirName != ""} {
    set DataDirChannel3 $DirName
    } else {
    set DataDirChannel3 $DataDirTmp3
    }

CheckEnvBinData2} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd82" "Button536_7" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd82 "$site_5_0.cpd82 Button $top all _vTclBalloon"
    bind $site_5_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Directory}
    }
    button $site_5_0.cpd72 \
        \
        -command {global DataDirChannel3 OpenDirFile DataDirTmp3

if {$OpenDirFile == 0} {
set DataDirTmp3 $DataDirChannel3
set DataDirChannel3 [file dirname $DataDirChannel3]
CheckEnvBinData2
}} \
        -image [vTcl:image:get_image [file join . GUI Images DecrDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button536_8" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Parent Directory}
    }
    button $site_5_0.cpd73 \
        \
        -command {global DataDirChannel3 OpenDirFile DataDirTmp3

if {$OpenDirFile == 0} {
set DataDirTmp3 $DataDirChannel3
set DataDirChannel3 $env(HOME)
CheckEnvBinData2
}} \
        -image [vTcl:image:get_image [file join . GUI Images HomeDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button536_9" vTcl:WidgetProc "Toplevel536" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Home Directory}
    }
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra69 \
        -in $top -anchor center -expand 1 -fill x -side bottom 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
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
Window show .top536

main $argc $argv
