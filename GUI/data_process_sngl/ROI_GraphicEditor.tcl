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

        {{[file join . GUI Images lines.gif]} {user image} user {}}
        {{[file join . GUI Images rectangle.gif]} {user image} user {}}
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
    set base .top393
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra49 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra49
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra41
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but29 {
        array set save {-_tooltip 1 -command 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra42 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra42
    namespace eval ::widgets::$site_3_0.but26 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but27 {
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
            vTclWindow.top393
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

proc vTclWindow.top393 {base} {
    if {$base == ""} {
        set base .top393
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
    wm geometry $top 120x110+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Graphic Editor"
    vTcl:DefineAlias "$top" "Toplevel393" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra49 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra49" "Frame168" vTcl:WidgetProc "Toplevel393" 1
    set site_3_0 $top.fra49
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global widget SourceWidth SourceHeight WidthBMP HeightBMP BMPWidth BMPHeight ZoomBMP BMPImage ImageSource BMPCanvas

set Num1 ""
set Num2 ""
set Num1 [string index $ZoomBMP 0]
set Num2 [string index $ZoomBMP 1]
if {$Num2 == ":"} {
    set Num $Num1
    set Den1 ""
    set Den2 ""
    set Den1 [string index $ZoomBMP 2]
    set Den2 [string index $ZoomBMP 3]
    if {$Den2 == ""} {
        set Den $Den1
        } else {
        set Den [expr 10*$Den1 + $Den2]
        }
    } else {
    set Num [expr 10*$Num1 + $Num2]
    set Den1 ""
    set Den2 ""
    set Den1 [string index $ZoomBMP 3]
    set Den2 [string index $ZoomBMP 4]
    if {$Den2 == ""} {
        set Den $Den1
        } else {
        set Den [expr 10*$Den1 + $Den2]
        }
    }

if {$Den >= $Num} {
    set BMPSample $Den
    set Xmax [expr round($BMPWidth * $BMPSample)]
    set Ymax [expr round($BMPHeight * $BMPSample)]
    BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -subsample $BMPSample $BMPSample
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    }
if {$Den < $Num} {
    set BMPZoom $Num
    set Xmax [expr round($BMPWidth / $BMPZoom)]
    set Ymax [expr round($BMPHeight / $BMPZoom)]
    BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    }} \
        -padx 4 -pady 2 -text Clear 
    vTcl:DefineAlias "$site_3_0.but24" "Button86" vTcl:WidgetProc "Toplevel393" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Clear the Contours on the BMP image}
    }
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint
global MouseInitX MouseInitY MouseEndX MouseEndY MouseNlig MouseNcol
global widget SourceWidth SourceHeight WidthBMP HeightBMP BMPWidth BMPHeight ZoomBMP BMPImage ImageSource BMPCanvas

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

set AreaClassN 1
set NTrainingAreaClass 1
set AreaN 1
set NTrainingArea(1) 1

set MouseInitX ""
set MouseInitY ""
set MouseEndX ""
set MouseEndY ""
set MouseNlig ""
set MouseNcol ""

set Num1 ""
set Num2 ""
set Num1 [string index $ZoomBMP 0]
set Num2 [string index $ZoomBMP 1]
if {$Num2 == ":"} {
    set Num $Num1
    set Den1 ""
    set Den2 ""
    set Den1 [string index $ZoomBMP 2]
    set Den2 [string index $ZoomBMP 3]
    if {$Den2 == ""} {
        set Den $Den1
        } else {
        set Den [expr 10*$Den1 + $Den2]
        }
    } else {
    set Num [expr 10*$Num1 + $Num2]
    set Den1 ""
    set Den2 ""
    set Den1 [string index $ZoomBMP 3]
    set Den2 [string index $ZoomBMP 4]
    if {$Den2 == ""} {
        set Den $Den1
        } else {
        set Den [expr 10*$Den1 + $Den2]
        }
    }

if {$Den >= $Num} {
    set BMPSample $Den
    set Xmax [expr round($BMPWidth * $BMPSample)]
    set Ymax [expr round($BMPHeight * $BMPSample)]
    BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -subsample $BMPSample $BMPSample
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    }
if {$Den < $Num} {
    set BMPZoom $Num
    set Xmax [expr round($BMPWidth / $BMPZoom)]
    set Ymax [expr round($BMPHeight / $BMPZoom)]
    BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    }} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but25" "Button87" vTcl:WidgetProc "Toplevel393" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Delete all the Training Areas from the List}
    }
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra41 \
        -borderwidth 2 -height 84 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame471" vTcl:WidgetProc "Toplevel393" 1
    set site_3_0 $top.fra41
    button $site_3_0.but47 \
        \
        -command {global TrainingAreaTool TrainingAreaToolLine AreaTiePointN
global BMPImageOpen BMPView RectLensCenter Lens BMPSampleLens ZoomBMP ZoomBMPTmp
global MouseActiveButton OpenDirFile

if {$OpenDirFile == 0} {

if {"$BMPImageOpen" == "1"} {
    if {$MouseActiveButton != "Training"} {
        if {$MouseActiveButton == "Lens"} {
            set Lens ""
            set BMPSampleLens ""
            $widget(CANVASBMPLENS) dtag RectLensCenter
            Window hide $widget(VIEWBMPLENS); TextEditorRunTrace "Close Window View BMP Lens" "b"
            Window hide $widget(VIEWLENS); TextEditorRunTrace "Close Window Zoom" "b"
            WidgetShow $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPTmp
            }
        set TrainingAreaTool rect
        MouseActiveFunction "Training"
        set AreaTiePointN ""
        set TrainingAreaToolLine "false"
        } else {
        if {$TrainingAreaTool == "rect"} {
            MouseActiveFunction ""
            } else {
            set TrainingAreaTool rect
            MouseActiveFunction "Training"
            set AreaTiePointN ""
            set TrainingAreaToolLine "false"
            }
        } 
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images rectangle.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but47" "Button640" vTcl:WidgetProc "Toplevel393" 1
    bindtags $site_3_0.but47 "$site_3_0.but47 Button $top all _vTclBalloon"
    bind $site_3_0.but47 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Rectangle Selection}
    }
    button $site_3_0.but29 \
        \
        -command {global rect_color

if {$rect_color == "white"} {
    set rect_color "black"
    } else {
    set rect_color "white"
    }

set b .top393.fra41.but29
$b configure -background $rect_color -foreground $rect_color} \
        -padx 0 -pady 0 -relief ridge -text {   } 
    vTcl:DefineAlias "$site_3_0.but29" "Button631" vTcl:WidgetProc "Toplevel393" 1
    bindtags $site_3_0.but29 "$site_3_0.but29 Button $top all _vTclBalloon"
    bind $site_3_0.but29 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Toggle Training Area Contour Color (B/W)}
    }
    button $site_3_0.but45 \
        \
        -command {global TrainingAreaTool TrainingAreaToolLine AreaTiePointN
global BMPImageOpen BMPView RectLensCenter Lens BMPSampleLens ZoomBMP ZoomBMPTmp
global MouseActiveButton OpenDirFile

if {$OpenDirFile == 0} {

if {"$BMPImageOpen" == "1"} {
    if {$MouseActiveButton != "Training"} {
        if {$MouseActiveButton == "Lens"} {
            set Lens ""
            set BMPSampleLens ""
            $widget(CANVASBMPLENS) dtag RectLensCenter
            Window hide $widget(VIEWBMPLENS); TextEditorRunTrace "Close Window View BMP Lens" "b"
            Window hide $widget(VIEWLENS); TextEditorRunTrace "Close Window Zoom" "b"
            WidgetShow $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPTmp
            }
        set TrainingAreaTool line
        MouseActiveFunction "Training"
        set AreaTiePointN ""
        set TrainingAreaToolLine "false"
        } else {
        if {$TrainingAreaTool == "line"} {
            MouseActiveFunction ""
            } else {
            set TrainingAreaTool line
            MouseActiveFunction "Training"
            set AreaTiePointN ""
            set TrainingAreaToolLine "false"
            }
        } 
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images lines.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but45" "Button638" vTcl:WidgetProc "Toplevel393" 1
    bindtags $site_3_0.but45 "$site_3_0.but45 Button $top all _vTclBalloon"
    bind $site_3_0.but45 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Polygon Selection}
    }
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but29 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra42 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame472" vTcl:WidgetProc "Toplevel393" 1
    set site_3_0 $top.fra42
    button $site_3_0.but26 \
        -background #ffff00 \
        -command {global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPointLig AreaPointCol AreaPoint
global SupervisedOutputDir SupervisedOutputSubDir VarTrainingArea OpenDirFile CONFIGDir
global MaskFonction TMPMaskROIarea

if {$OpenDirFile == 0} {

set Argument [expr (10000*$NTrainingAreaClass + 101)]
if {$AreaPointLig($Argument) == ""} {set NTrainingAreaClass [expr $NTrainingAreaClass -1]}

if {$FileTrainingArea == "$CONFIGDir/roi_areas.txt"} { set FileTrainingArea $TMPMaskROIarea }
    
set f [open $FileTrainingArea w]
for {set i 1} {$i <= $NTrainingAreaClass} {incr i} {
    for {set j 1} {$j <= $NTrainingArea($i)} {incr j} {
        puts $f "Nb_Tie_Points"
        set Argument [expr (100*$i + $j)]
        puts $f $AreaPoint($Argument)
        for {set k 1} {$k <= $AreaPoint($Argument)} {incr k} {
            puts $f "Tie_Point"
            set Argument1 [expr (10000*$i + 100*$j + $k)]
            puts $f "Row"
            puts $f $AreaPointLig($Argument1)
            puts $f "Col"
            puts $f $AreaPointCol($Argument1)
            }
        puts $f "--------------"
        }
    }
close $f

set VarTrainingArea "ok"
ClosePSPViewer
Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
Window hide $widget(Toplevel393); TextEditorRunTrace "Close Window Graphic Editor" "b"

}} \
        -padx 4 -pady 2 -text Save 
    vTcl:DefineAlias "$site_3_0.but26" "Button635" vTcl:WidgetProc "Toplevel393" 1
    bindtags $site_3_0.but26 "$site_3_0.but26 Button $top all _vTclBalloon"
    bind $site_3_0.but26 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save the Training Area List}
    }
    button $site_3_0.but44 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ROI_GraphicEditor.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but44" "Button15" vTcl:WidgetProc "Toplevel393" 1
    bindtags $site_3_0.but44 "$site_3_0.but44 Button $top all _vTclBalloon"
    bind $site_3_0.but44 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but27 \
        -background #ffff00 \
        -command {global VarTrainingArea BMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

set VarTrainingArea $VarTrainingArea

ClosePSPViewer
Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"

if {$BMPImageOpen == 0} {
    Window hide $widget(Toplevel393); TextEditorRunTrace "Close Window Graphic Editor" "b"
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but27" "Button636" vTcl:WidgetProc "Toplevel393" 1
    bindtags $site_3_0.but27 "$site_3_0.but27 Button $top all _vTclBalloon"
    bind $site_3_0.but27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but26 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra49 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra41 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra42 \
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
Window show .top393

main $argc $argv
