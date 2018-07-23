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

        {{[file join . GUI Images screen.gif]} {user image} user {}}
        {{[file join . GUI Images zoom.gif]} {user image} user {}}
        {{[file join . GUI Images color-rgb.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
        {{[file join . GUI Images CloseFile.gif]} {user image} user {}}
        {{[file join . GUI Images PVv3small.gif]} {user image} user {}}
        {{[file join . GUI Images dropper.gif]} {user image} user {}}
        {{[file join . GUI Images img-xflip.gif]} {user image} user {}}
        {{[file join . GUI Images img-yflip.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images zoom2.gif]} {user image} user {}}
        {{[file join . GUI Images Overview.gif]} {user image} user {}}
        {{[file join . GUI Images img-lrotat.gif]} {user image} user {}}
        {{[file join . GUI Images img-rrotat.gif]} {user image} user {}}
        {{[file join . GUI Images colormap.gif]} {user image} user {}}
        {{[file join . GUI Images ViewDisplayAll.gif]} {user image} user {}}

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
    set base .top64
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab65 {
        array set save {-_tooltip 1 -image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra24 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra24
    namespace eval ::widgets::$site_3_0.but26 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but88 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-_tooltip 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-_tooltip 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab79 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd80 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.cpd80 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-_tooltip 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-_tooltip 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab79 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd81 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.cpd81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd110 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd85
    namespace eval ::widgets::$site_5_0.cpd88 {
        array set save {-_tooltip 1 -activebackground 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but109 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$base.cpd90 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.cpd90 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.but71 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-_tooltip 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd95 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.cpd95 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd99 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd104 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.cpd104 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd105 {
        array set save {-borderwidth 1 -closeenough 1 -height 1 -relief 1 -takefocus 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-_tooltip 1 -background 1 -foreground 1 -relief 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra32 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra32
    namespace eval ::widgets::$site_3_0.but33 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but30 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but34 {
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
            vTclWindow.top64
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
    wm geometry $top 200x200+50+50; update
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

proc vTclWindow.top64 {base} {
    if {$base == ""} {
        set base .top64
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
    wm geometry $top 140x480+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PV3.0"
    vTcl:DefineAlias "$top" "Toplevel64" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab65 \
        -image [vTcl:image:get_image [file join . GUI Images PVv3small.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$top.lab65" "Label172" vTcl:WidgetProc "Toplevel64" 1
    bindtags $top.lab65 "$top.lab65 Label $top all _vTclBalloon"
    bind $top.lab65 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP Viewer v3.0}
    }
    frame $top.fra24 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra24" "Frame387" vTcl:WidgetProc "Toplevel64" 1
    set site_3_0 $top.fra24
    button $site_3_0.but26 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight 
global BMPWidth BMPHeight WidthBMP HeightBMP ZoomBMP
global BMPImage BMPImageLens BMPLens ImageSource BMPView BMPCanvas
global BMPViewAll BMPOverviewAll BMPLensAll
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette BMPColorBar
global BMPDropperFlag RectLensCenter BMPWidthSource BMPHeightSource BMPSampleSource ZoomBMPSource
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect
global BMPMax BMPMin BMPValue BMPMouseX BMPMouseY
global RectOverviewAllCenter RectLensAllCenter 
package require Img
#BMP PROCESS
global Load_Save Load_Display Load_ViewBMPFile Load_ViewBMP1 Load_ViewBMPLens
global Load_Zoom Load_ViewOverview Load_ViewBMPOverview
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global Load_ViewBMPQL QLBMPImageOpen Load_ViewBMPAll PSPTopLevel
global TMPBmpTmpHeader PSPMemory

if {$Load_ViewBMPQL == 1} {
    if {$QLBMPImageOpen == 1} {
        image delete ImageSource
        image delete BMPImage
        set QLBMPImageOpen 0
        # .top207 = VIEWBMPQL
        Window hide .top207
        }
    }
     
if {$Load_ViewBMP1 == 0} {
    source "GUI/bmp_process/ViewBMP1.tcl"
    set Load_ViewBMP1 1
    $widget(CANVASBMP1) configure -cursor arrow
    WmTransient .top51 $PSPTopLevel
    }
if {$Load_Save == 0} {
    source "GUI/bmp_process/Save.tcl"
    set Load_Save 1
    WmTransient $widget(Toplevel82) $PSPTopLevel
    }

#Update Geometry widget SAVE 
#Screen Size Geometry
set geowidth [winfo screenwidth .top2]
set geowidth [expr $geowidth - 10]
#PSP Viewer
set pv3width [expr $geowidth - 150]
set geomwidget [expr $pv3width - 120]
set geometrie "120x180+"; append geometrie $geomwidget; append geometrie "+110"
wm geometry .top82 $geometrie; update

if { $BMPImageOpen == 1 } {
    if {$BMPChange == 1 } {
    #####################################################################
        set WarningMessage "BMP IMAGE HAS CHANGED"
        set WarningMessage2 "DO YOU WISH TO SAVE ?"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel82); TextEditorRunTrace "Open Window Save" "b"
            tkwait variable BMPChange
            if {$BMPChange == "0"} {Window hide $widget(Toplevel82); TextEditorRunTrace "Close Window Save" "b"}
            set BMPChange "0"
            }
        if {"$VarWarning"=="no"} {set BMPChange "0"}
        if {"$VarWarning"=="cancel"} {set BMPChange "1"}
    ##################################################################### 
    }    
    if {$BMPChange == 0 } {
        #Display Window
        TextEditorRunTrace "Close All Image & ColorMap Windows" "b"
        if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP)}
        if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1)}
        if {$Load_ViewBMPLens == 1} {Window hide $widget(VIEWBMPLENS)}
        if {$Load_Zoom == 1} {Window hide $widget(VIEWLENS)}
        if {$Load_ViewBMPOverview == 1} {Window hide $widget(VIEWBMPOVERVIEW)}
        if {$Load_ViewOverview == 1} {Window hide $widget(VIEWOVERVIEW)}
        if {$Load_ViewBMPAll == 1} {Window hide $widget(VIEWBMPALL)}
        #Colormap Window
        set BMPColorMapDisplay "0"
        set BMPColorMapGrayJetHsv "0"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
        MouseActiveFunction ""
        if { $Load_ViewBMPLens == 1 } {$widget(CANVASBMPLENS) dtag RectLensCenter}
        if { $Load_ViewOverview == 1 } {$widget(CANVASOVERVIEW) dtag RectLensCenter}
        if { $Load_ViewBMPAll == 1 } {
            $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
            $widget(CANVASLENSALL) dtag RectLensAllCenter
            }
            
        if {$Load_Save == 1} {Window hide $widget(Toplevel82)}
        if {$Load_Display == 1} {Window hide $widget(Toplevel71)}

        image delete ImageSource
        image delete BMPImage
        image delete BMPImageLens
        image delete BMPLens
        image delete BMPOverview
        image delete BMPImageOverview
        image delete BMPViewAll
        image delete BMPOverviewAll
        image delete BMPLensAll
        
        if [file exists $ColorBarBMP] {
            BMPColorBar blank
            $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
            image delete BMPColorBar
            set BMPMax ""
            set BMPMin ""
            set BMPValue ""
            }
        set BMPImageOpen "0"
        set SourceWidth ""
        set SourceHeight ""
        }
    }
if { $BMPImageOpen == 0 } {
    MouseActiveFunction ""

    set SourceWidth ""
    set SourceHeight ""
    set BMPMouseX ""
    set BMPMouseY ""
    set BMPMax ""
    set BMPMin ""
    set BMPValue ""
    set ZoomBMP "0:0"
    set BMPImageOpen "0"
    set BMPColorMapDisplay "0"
    set BMPScreenDisplay "0"
    set BMPDropperFlag "0"
        
    set types {
        {{BMP Files}        {.bmp}        }
        }
    set FileName ""
    OpenFile $BMPDirInput $types "INPUT BMP FILE"

    if {$FileName != ""} {

        set BMPViewFileInput $FileName
        TextEditorRunTrace "Process The Function Soft/bmp_process/extract_bmp_size.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$BMPViewFileInput\x22 -of \x22$TMPBmpTmpHeader\x22" "k"
        set f [ open "| Soft/bmp_process/extract_bmp_size.exe -if \x22$BMPViewFileInput\x22 -of \x22$TMPBmpTmpHeader\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError

        WaitUntilCreated $TMPBmpTmpHeader
        if [file exists $TMPBmpTmpHeader] {
            set f [open $TMPBmpTmpHeader r]
            gets $f tmpncol
            gets $f tmpnlig
            close $f
            }

        set BMPImageOpen "1"
        #Display Window
        if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP)}
        if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1)}
        if {$Load_ViewBMPLens == 1} {Window hide $widget(VIEWBMPLENS)}
        if {$Load_Zoom == 1} {Window hide $widget(VIEWLENS)}
        if {$Load_ViewBMPOverview == 1} {Window hide $widget(VIEWBMPOVERVIEW)}
        if {$Load_ViewOverview == 1} {Window hide $widget(VIEWOVERVIEW)}
        if {$Load_ViewBMPAll == 1} {Window hide $widget(VIEWBMPALL)}
        set BMPColorMapDisplay "0"
        set BMPColorMapGrayJetHsv "0"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
        MouseActiveFunction ""
        if { $Load_ViewBMPLens == 1 } {$widget(CANVASBMPLENS) dtag RectLensCenter}
        if { $Load_ViewOverview == 1 } {$widget(CANVASOVERVIEW) dtag RectLensCenter}
        if { $Load_ViewBMPAll == 1 } {
            $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
            $widget(CANVASLENSALL) dtag RectLensAllCenter
            }

        if {$Load_Save == 1} {Window hide $widget(Toplevel82)}
        if {$Load_Display == 1} {Window hide $widget(Toplevel71)}

        load_bmp_caracteristics $BMPViewFileInput

        set configbmp "true"     
        if {$ColorNumber == "BMP 24 Bits"} {
            set MaxSize [expr $tmpnlig * $tmpncol * 4]
            } else {
            set MaxSize [expr $tmpnlig * $tmpncol]
            }
        set MaxMemory [expr $PSPMemory * 1000000]
        set MaxMemory [expr $MaxMemory / 10]
        if {$MaxSize >= $MaxMemory} { 
            set configbmp "false"
            set WarningMessage "HUGE BMP IMAGE : OPENING WILL TAKE TIME"
            set WarningMessage2 "DO YOU WISH TO CONTINUE ?"
            set VarWarning ""
            Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
            tkwait variable VarWarning
            if {"$VarWarning"=="ok"} { set configbmp "true" }
            }

    if {$configbmp == "true"} { 
        Window show $widget(Toplevel336); TextEditorRunTrace "Open Window Loading BMP" "b"
        TextEditorRunTrace "" "r"
        TextEditorRunTrace "Loading BMP Image" "r"
        TextEditorRunTrace "" "r"
        if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
        load_bmp_file $BMPViewFileInput    
        Window hide $widget(Toplevel336); TextEditorRunTrace "Close Window Loading BMP" "b"
      
        $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
        $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
        wm title $widget($BMPView) [file tail $BMPViewFileInput]

        set x [winfo x $widget($BMPView)]
        set y [winfo y $widget($BMPView)]
        set geometrie $BMPWidth; append geometrie "x"; append geometrie $BMPHeight; append geometrie "+";
        append geometrie $x; append geometrie "+"; append geometrie $y
        wm geometry $widget($BMPView) $geometrie; update
        WidgetGeometryLeft $widget($BMPView)
        catch {wm geometry $widget($BMPView) {}} 
        Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
        }
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_3_0.but26" "Button543" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_3_0.but26 "$site_3_0.but26 Button $top all _vTclBalloon"
    bind $site_3_0.but26 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open}
    }
    button $site_3_0.but88 \
        \
        -command {global BMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

#BMP PROCESS
global Load_Save PSPTopLevel

if {$Load_Save == 0} {
    source "GUI/bmp_process/Save.tcl"
    set Load_Save 1
    WmTransient $widget(Toplevel82) $PSPTopLevel
    }

#Update Geometry widget SAVE 
#Screen Size Geometry
##set geowidth [winfo screenwidth .top2]
##set geowidth [expr $geowidth - 10]
#PSP Viewer
##set pv3width [expr $geowidth - 150]
##set geomwidget [expr $pv3width - 120]
##set geometrie "120x180+"; append geometrie $geomwidget; append geometrie "+110"
##wm geometry .top82 $geometrie; update

if {$BMPImageOpen == 1} {
    WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel82); TextEditorRunTrace "Open Window Save" "b"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but88" "Button578" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_3_0.but88 "$site_3_0.but88 Button $top all _vTclBalloon"
    bind $site_3_0.but88 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save As}
    }
    button $site_3_0.but23 \
        \
        -command {global BMPChange BMPImageOpen SourceWidth SourceHeight BMPMouseX BMPMouseY ZoomBMP BMPDropperFlag
global BMPTrainingRect BMPColorMapDisplay BMPColorMapGrayJetHsv BMPColorBar ColorNumber 
global ImageSource BMPImage BMPImageLens BMPLens BMPOverview BMPImageOverview
global BMPViewAll BMPOverviewAll BMPLensAll
global BMPMax BMPMin BMPValue OpenDirFile
#BMP PROCESS
global Load_Save Load_Display Load_ViewBMPFile Load_ViewBMP1 Load_ViewBMPLens Load_Zoom Load_ViewOverview Load_ViewBMPOverview
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global Load_ViewBMPQL QLBMPImageOpen Load_ViewBMPAll PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_ViewBMPQL == 1} {
    if {$QLBMPImageOpen == 1} {
        image delete ImageSource
        image delete BMPImage
        set QLBMPImageOpen 0
        # .top207 = VIEWBMPQL
        Window hide .top207
        }
    }
    
if {$Load_Save == 0} {
    source "GUI/bmp_process/Save.tcl"
    set Load_Save 1
    WmTransient $widget(Toplevel82) $PSPTopLevel
    }

#Update Geometry widget SAVE 
#Screen Size Geometry
##set geowidth [winfo screenwidth .top2]
##set geowidth [expr $geowidth - 10]
#PSP Viewer
##set pv3width [expr $geowidth - 150]
##set geomwidget [expr $pv3width - 120]
##set geometrie "120x180+"; append geometrie $geomwidget; append geometrie "+110"
##wm geometry .top82 $geometrie; update

if { $BMPImageOpen == 1 } {
    if {$BMPChange == 1 } {
    #####################################################################
        set WarningMessage "BMP IMAGE HAS CHANGED"
        set WarningMessage2 "DO YOU WISH TO SAVE ?"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel82); TextEditorRunTrace "Open Window Save" "b"
            tkwait variable BMPChange
            if {$BMPChange == "0"} {Window hide $widget(Toplevel82); TextEditorRunTrace "Close Window Save" "b"}
            }
        if {"$VarWarning"=="no"} {set BMPChange "0"}
        if {"$VarWarning"=="cancel"} {set BMPChange "1"}
    ##################################################################### 
    }    
    if {$BMPChange == 0 } {
        #Display Window
        TextEditorRunTrace "Close All Image Windows" "b"
        if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP)}
        if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1)}
        if {$Load_ViewBMPLens == 1} {Window hide $widget(VIEWBMPLENS)}
        if {$Load_Zoom == 1} {Window hide $widget(VIEWLENS)}
        if {$Load_ViewBMPOverview == 1} {Window hide $widget(VIEWBMPOVERVIEW)}
        if {$Load_ViewOverview == 1} {Window hide $widget(VIEWOVERVIEW)}
        if {$Load_ViewBMPAll == 1} {Window hide $widget(VIEWBMPALL)}
        #Colormap Window
        set BMPColorMapDisplay "0"
        set BMPColorMapGrayJetHsv "0"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
        MouseActiveFunction ""
        if { $Load_ViewBMPLens == 1 } {$widget(CANVASBMPLENS) dtag RectLensCenter}
        if { $Load_ViewOverview == 1 } {$widget(CANVASOVERVIEW) dtag RectLensCenter}
        if { $Load_ViewBMPAll == 1 } {
            $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
            $widget(CANVASLENSALL) dtag RectLensAllCenter
            }

        if {$Load_Save == 1} {Window hide $widget(Toplevel82)}
        if {$Load_Display == 1} {Window hide $widget(Toplevel71)}

        set SourceWidth ""
        set SourceHeight ""
        set BMPMouseX ""
        set BMPMouseY ""
        set BMPMax ""
        set BMPMin ""
        set BMPValue ""
        set ZoomBMP "0:0"
        set BMPImageOpen "0"
        set BMPColorMapDisplay "0"
        set BMPScreenDisplay "0"
        set BMPDropperFlag "0"
        set c0 .top64.cpd90.f.cpd92
        $c0 configure -background $couleur_fond
        if {$ColorNumber != "BMP 24 Bits"} {
            BMPColorBar blank
            $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
            }
        image delete BMPColorBar
        image delete ImageSource
        image delete BMPImage
        image delete BMPImageLens
        image delete BMPLens
        image delete BMPOverview
        image delete BMPImageOverview
        image delete BMPViewAll
        image delete BMPOverviewAll
        image delete BMPLensAll
        }
}
}} \
        -image [vTcl:image:get_image [file join . GUI Images CloseFile.gif]] \
        -pady 0 -text {    } -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button545" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Close}
    }
    pack $site_3_0.but26 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but88 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit71 \
        -ipad 2 -relief sunken -text {Image Size} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel64" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    label $site_4_0.cpd72 \
        -relief groove -text C -width 2 
    vTcl:DefineAlias "$site_4_0.cpd72" "Label269" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd72 "$site_4_0.cpd72 Label $top all _vTclBalloon"
    bind $site_4_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Rows}
    }
    label $site_4_0.cpd77 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable SourceWidth -width 4 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label1" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd77 "$site_4_0.cpd77 Label $top all _vTclBalloon"
    bind $site_4_0.cpd77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Columns}
    }
    label $site_4_0.cpd78 \
        -relief groove -text R -width 2 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label268" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd78 "$site_4_0.cpd78 Label $top all _vTclBalloon"
    bind $site_4_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Columns}
    }
    label $site_4_0.lab79 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable SourceHeight -width 4 
    vTcl:DefineAlias "$site_4_0.lab79" "Label2" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.lab79 "$site_4_0.lab79 Label $top all _vTclBalloon"
    bind $site_4_0.lab79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Rows}
    }
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.lab79 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd80 \
        -ipad 2 -relief sunken -text {Mouse Position} 
    vTcl:DefineAlias "$top.cpd80" "TitleFrame2" vTcl:WidgetProc "Toplevel64" 1
    bind $top.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd80 getframe]
    label $site_4_0.cpd72 \
        -relief groove -text X -width 2 
    vTcl:DefineAlias "$site_4_0.cpd72" "Label270" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd72 "$site_4_0.cpd72 Label $top all _vTclBalloon"
    bind $site_4_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Rows}
    }
    label $site_4_0.cpd77 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable BMPMouseX -width 4 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label3" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd77 "$site_4_0.cpd77 Label $top all _vTclBalloon"
    bind $site_4_0.cpd77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Mouse Pointer Position in X}
    }
    label $site_4_0.cpd78 \
        -relief groove -text Y -width 2 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label271" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd78 "$site_4_0.cpd78 Label $top all _vTclBalloon"
    bind $site_4_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Columns}
    }
    label $site_4_0.lab79 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable BMPMouseY -width 4 
    vTcl:DefineAlias "$site_4_0.lab79" "Label4" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.lab79 "$site_4_0.lab79 Label $top all _vTclBalloon"
    bind $site_4_0.lab79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Mouse Pointer Position in Y}
    }
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.lab79 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd81 \
        -ipad 0 -relief sunken -text Zoom 
    vTcl:DefineAlias "$top.cpd81" "TitleFrame3" vTcl:WidgetProc "Toplevel64" 1
    bind $top.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd81 getframe]
    label $site_4_0.cpd110 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable ZoomBMP -width 6 
    vTcl:DefineAlias "$site_4_0.cpd110" "Label8" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd110 "$site_4_0.cpd110 Label $top all _vTclBalloon"
    bind $site_4_0.cpd110 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Zoom Level Value}
    }
    frame $site_4_0.cpd85 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd85" "Frame4" vTcl:WidgetProc "Toplevel64" 1
    set site_5_0 $site_4_0.cpd85
    button $site_5_0.cpd88 \
        -activebackground #ffff00 \
        -command {global BMPImageOpen BMPView RectLensCenter Lens BMPSampleLens BMPSampleOverview ZoomBMP ZoomBMPView
global MouseActiveButton OpenDirFile RectOverviewAllCenter RectLensAllCenter LensAllq
global ImageSource TMPBmpTmp ColorNumber BMPColorBar BMPCanvas BMPWidth BMPHeight BMPImage BMPViewFileInput

#BMP PROCESS
global Load_ViewBMPFile PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_ViewBMPFile == 0} {
    source "GUI/bmp_process/ViewBMPFile.tcl"
    set Load_ViewBMPFile 1
    $widget(CANVASBMP) configure -cursor arrow
    WmTransient .top27 $PSPTopLevel
    }

if {"$BMPImageOpen" == "1"} {
    if {$MouseActiveButton != "Zoom"} {
        if {$MouseActiveButton == "Lens"} {
            set Lens ""
            set BMPSampleLens ""
            $widget(CANVASBMPLENS) dtag RectLensCenter
            Window hide $widget(VIEWBMPLENS); TextEditorRunTrace "Close Window View BMP Lens" "b"
            Window hide $widget(VIEWLENS); TextEditorRunTrace "Close Window Zoom" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            }
        if {$MouseActiveButton == "Overview"} {
            set BMPSampleOverview ""
            $widget(CANVASOVERVIEW) dtag RectLensCenter
            Window hide $widget(VIEWBMPOVERVIEW); TextEditorRunTrace "Close Window View BMP Overview" "b"
            Window hide $widget(VIEWOVERVIEW); TextEditorRunTrace "Close Window Overview" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            }
        if {$MouseActiveButton == "ViewAll"} {
            set BMPSampleOverview ""
            $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
            set LensAll ""
            set BMPSampleLens ""
            $widget(CANVASLENSALL) dtag RectLensAllCenter
            Window hide $widget(VIEWBMPALL); TextEditorRunTrace "Close Window View BMP All" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            }
        MouseActiveFunction "Zoom"
        } else {
        MouseActiveFunction ""
        Window hide $widget($BMPView); TextEditorRunTrace "Close Window View $BMPView" "b"
        image delete ImageSource
        set TmpImage $BMPViewFileInput; 
        if [file exists $TMPBmpTmp] {set TmpImage $TMPBmpTmp}
        load_bmp_caracteristics $TmpImage
        if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
        load_bmp_file $TmpImage
        $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
        $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
        catch {wm geometry $widget($BMPView) {}} 
        wm title $widget($BMPView) [file tail $BMPViewFileInput]
        Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
        } 
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images zoom2.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_5_0.cpd88" "Button71" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_5_0.cpd88 "$site_5_0.cpd88 Button $top all _vTclBalloon"
    bind $site_5_0.cpd88 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Zoom Tool}
    }
    button $site_5_0.cpd89 \
        \
        -command [list vTcl:DoCmdOption $site_5_0.cpd89 {global BMPImageOpen BMPViewFileInput SourceWidth SourceHeight BMPImage BMPImageLens BMPLens ImageSource 
global BMPView RectLensCenter RectLensCenterX RectLensCenterY RectLens SizeRect SizeLens Lens BMPSampleLens
global ZoomLensBMP BMPWidthSource BMPHeightSource BMPSampleSource BMPSampleOverview LensX1 LensY1 plot
global BMPColorMapDisplay BMPColorMapGrayJetHsv RectOverviewAllCenter RectLensAllCenter LensAll
global ZoomBMP ZoomBMPView ZoomBMPSource BMPLensDeltaX BMPLensDeltaY
global MouseActiveButton MouseRectLens OpenDirFile
global ImageSource TMPBmpTmp ColorNumber BMPColorBar BMPCanvas BMPWidth BMPHeight BMPImage BMPViewFileInput
#BMP PROCESS
global Load_ViewBMPLens Load_Zoom PSPTopLevel
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256 Load_ColorMapGrayJetHsv

if {$OpenDirFile == 0} {

if {"$BMPImageOpen" == "1"} {
if {$MouseActiveButton == "Training"} {
    set ErrorMessage "IMPOSSIBLE IN TRAINING MODE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
if {$MouseActiveButton != "Lens"} {

    if {$Load_ViewBMPLens == 0} {
        source "GUI/bmp_process/ViewBMPLens.tcl"
        set Load_ViewBMPLens 1
        WmTransient .top73 $PSPTopLevel
        }
    if {$Load_Zoom == 0} {
        source "GUI/bmp_process/Zoom.tcl"
        set Load_Zoom 1
        WmTransient .top78 $PSPTopLevel
        }

    if {$MouseActiveButton == "Overview"} {
        set BMPSampleOverview ""
        $widget(CANVASOVERVIEW) dtag RectLensCenter
        Window hide $widget(VIEWBMPOVERVIEW); TextEditorRunTrace "Close Window View BMP Overview" "b"
        Window hide $widget(VIEWOVERVIEW); TextEditorRunTrace "Close Window Overview" "b"
        }
    if {$MouseActiveButton == "ViewAll"} {
        set BMPSampleOverview ""
        $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
        set LensAll ""
        set BMPSampleLens ""
        $widget(CANVASLENSALL) dtag RectLensAllCenter
        Window hide $widget(VIEWBMPALL); TextEditorRunTrace "Close Window View BMP All" "b"
        } else {
        Window hide $widget($BMPView); TextEditorRunTrace "Close Window View $BMPView" "b"
        set ZoomBMPView $ZoomBMP
        }
        
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    TextEditorRunTrace "Close All ColorMap Windows" "b"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    
    MouseActiveFunction "Lens"
    
    set MouseRectLens "Outside"
    set Lens "1"
    set BMPSampleLens "1"
    set ZoomLensBMP "1:1"

    set BMPLensDeltaX "0"
    set BMPLensDeltaY "0"
        
    set SizeRect 200
    set SizeLens 200
    
    #show lens
    package require Img
    set LensX1 [expr round(($SourceWidth - $SizeLens) / 2 )]
    set LensY1 [expr round(($SourceHeight - $SizeLens) / 2 )]
    set LensX2 [expr $LensX1 + $SizeLens]
    set LensY2 [expr $LensY1 + $SizeLens]
    BMPLens blank
    BMPLens copy ImageSource -from $LensX1 $LensY1 $LensX2 $LensY2 -subsample $BMPSampleLens $BMPSampleLens
    $widget(CANVASLENS) configure -width $SizeLens -height $SizeLens
    $widget(CANVASLENS) create image 0 0 -anchor nw -image BMPLens
    set BMPTitleLens "Zoom "
    append BMPTitleLens $ZoomLensBMP
    wm title $widget(VIEWLENS) [file tail $BMPTitleLens]
    set x [winfo x $widget(VIEWLENS)]
    set y [winfo y $widget(VIEWLENS)]
    set geometrie $SizeLens; append geometrie "x"; append geometrie $SizeLens; append geometrie "+";
    append geometrie $x; append geometrie "+"; append geometrie $y
    wm geometry $widget(VIEWLENS) $geometrie; update
    WidgetGeometryCenter $widget(VIEWLENS)
    catch {wm geometry $widget(VIEWLENS) {}}
    Window show $widget(VIEWLENS); TextEditorRunTrace "Open Window Zoom" "b"

    #show image_lens
    set ZoomBMP $ZoomBMPSource 
    BMPImageLens blank
    BMPImageLens copy ImageSource -from 0 0 $SourceWidth $SourceHeight -subsample $BMPSampleSource $BMPSampleSource
    $widget(CANVASBMPLENS) configure -width $BMPWidthSource -height $BMPHeightSource
    $widget(CANVASBMPLENS) create image 0 0 -anchor nw -image BMPImageLens
    wm title $widget(VIEWBMPLENS) [file tail $BMPViewFileInput]
    set x [winfo x $widget(VIEWBMPLENS)]
    set y [winfo y $widget(VIEWBMPLENS)]
    set geometrie $BMPWidthSource; append geometrie "x"; append geometrie $BMPHeightSource; append geometrie "+";
    append geometrie $x; append geometrie "+"; append geometrie $y
    wm geometry $widget(VIEWBMPLENS) $geometrie; update
    WidgetGeometryLeft $widget(VIEWBMPLENS)
    catch {wm geometry $widget(VIEWBMPLENS) {}} 
    Window show $widget(VIEWBMPLENS); TextEditorRunTrace "Open Window View BMP Lens" "b"

    #show rect_zoom
    set RectLensCenterX [expr round($BMPWidthSource/2)]
    set RectLensCenterY [expr round($BMPHeightSource/2)]
    set RectLensCenter {$RectLensCenterX $RectLensCenterY}
   
    set RectLensX1 [expr [lindex $RectLensCenter 0] - round($SizeRect / 2 / $BMPSampleSource)]
    set RectLensY1 [expr [lindex $RectLensCenter 1] - round($SizeRect / 2 / $BMPSampleSource)]
    set RectLensX2 [expr $RectLensX1 + round($SizeRect / $BMPSampleSource)]
    set RectLensY2 [expr $RectLensY1 + round($SizeRect / $BMPSampleSource)]
    set RectLens [$widget(CANVASBMPLENS) create rectangle $RectLensX1 $RectLensY1 $RectLensX2 $RectLensY2 -outline white -width 2]
    $widget(CANVASBMPLENS) addtag RectLensCenter withtag $RectLens
    bind $widget(CANVASBMPLENS) <B1-Motion> "RectLensMove $widget(CANVASBMPLENS) %x %y $widget(CANVASLENS)"
    set plot(lastX) 0
    set plot(lastY) 0
    } else {
    MouseActiveFunction ""
    set Lens ""
    set BMPSampleLens ""
    $widget(CANVASBMPLENS) dtag RectLensCenter
    Window hide $widget(VIEWBMPLENS); TextEditorRunTrace "Close Window View BMP Lens" "b"
    Window hide $widget(VIEWLENS); TextEditorRunTrace "Close Window Zoom" "b"
    #Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    #set ZoomBMP $ZoomBMPView
    image delete ImageSource
    set TmpImage $BMPViewFileInput; 
    if [file exists $TMPBmpTmp] {set TmpImage $TMPBmpTmp}
    load_bmp_caracteristics $TmpImage
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    load_bmp_file $TmpImage
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    catch {wm geometry $widget($BMPView) {}} 
    wm title $widget($BMPView) [file tail $BMPViewFileInput]
    Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    }
}
}
}}] \
        -image [vTcl:image:get_image [file join . GUI Images zoom.gif]] \
        -pady 0 -text {    } -width 20 
    bindtags $site_5_0.cpd89 "$site_5_0.cpd89 Button $top all _vTclBalloon"
    bind $site_5_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Lens Tool}
    }
    button $site_5_0.but109 \
        \
        -command [list vTcl:DoCmdOption $site_5_0.but109 {global BMPImageOpen BMPViewFileInput SourceWidth SourceHeight BMPImage BMPImageOverview BMPOverview ImageSource 
global BMPView RectLensCenter RectLensCenterX RectLensCenterY RectLens SizeRect SizeLensOverview
global SizeBMPOverview BMPSampleOverview plot BMPSampleLens
global BMPWidthSource BMPHeightSource BMPSampleSource LensX1 LensY1 LensAll
global BMPColorMapDisplay BMPColorMapGrayJetHsv RectOverviewAllCenter RectLensAllCenter
global ZoomBMP ZoomBMPView ZoomBMPSource ZoomOverviewBMP
global MouseActiveButton MouseRectLens OpenDirFile
global ImageSource TMPBmpTmp ColorNumber BMPColorBar BMPCanvas BMPWidth BMPHeight BMPImage BMPViewFileInput
#BMP PROCESS
global Load_ViewBMPOverview Load_ViewOverview PSPTopLevel
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256 Load_ColorMapGrayJetHsv

if {$OpenDirFile == 0} {

if {"$BMPImageOpen" == "1"} {
if {$MouseActiveButton == "Training"} {
    set ErrorMessage "IMPOSSIBLE IN TRAINING MODE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
if {$MouseActiveButton != "Overview"} {

    if {$Load_ViewBMPOverview == 0} {
        source "GUI/bmp_process/ViewBMPOverview.tcl"
        set Load_ViewBMPOverview 1
        WmTransient .top215 $PSPTopLevel
        }
    if {$Load_ViewOverview == 0} {
        source "GUI/bmp_process/ViewOverview.tcl"
        set Load_ViewOverview 1
        WmTransient .top216 $PSPTopLevel
        }

    if {$MouseActiveButton == "Lens"} {
        set Lens ""
        set BMPSampleLens ""
        $widget(CANVASBMPLENS) dtag RectLensCenter
        Window hide $widget(VIEWBMPLENS); TextEditorRunTrace "Close Window View BMP Lens" "b"
        Window hide $widget(VIEWLENS); TextEditorRunTrace "Close Window Zoom" "b"
        }
    if {$MouseActiveButton == "ViewAll"} {
        set BMPSampleOverview ""
        $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
        set LensAll ""
        set BMPSampleLens ""
        $widget(CANVASLENSALL) dtag RectLensAllCenter
        Window hide $widget(VIEWBMPALL); TextEditorRunTrace "Close Window View BMP All" "b"
        } else {
        Window hide $widget($BMPView); TextEditorRunTrace "Close Window View $BMPView" "b"
        set ZoomBMPView $ZoomBMP
        }

    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    TextEditorRunTrace "Close All ColorMap Windows" "b"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    
    MouseActiveFunction "Overview"
    
    set MouseRectLens "Outside"
    set BMPSampleOverview "1"
    set ZoomBMP "1:1"

    set SizeOverviewWidth 250
    set SizeOverviewHeight 250

    set SizeBMPOverview 500
    set SizeLensOverview $SizeBMPOverview
    if {$SourceWidth <= $SizeLensOverview} {set SizeLensOverview $SourceWidth}
    if {$SourceHeight <= $SizeLensOverview} {set SizeLensOverview $SourceHeight}
    set SizeRect $SizeLensOverview

    #show Overview
    package require Img
    set subsample 0
    if {$SourceWidth > $SizeOverviewWidth} {set subsample 1}
    if {$SourceHeight > $SizeOverviewHeight} {set subsample 1}

    set ZoomOverviewBMP "0:0"
    if {$subsample == 0} {
        set ZoomOverviewBMP "1:$BMPSample"
        set SizeOverviewWidth $SourceWidth
        set SizeOverviewHeight $SourceHeight
        } else {
        if {$SourceWidth >= $SourceHeight} {
            while {[expr round($SourceWidth / $BMPSampleOverview)] > $SizeOverviewWidth} {incr BMPSampleOverview}
            } else {
            while {[expr round($SourceHeight / $BMPSampleOverview)] > $SizeOverviewHeight} {incr BMPSampleOverview}
            } 
        set ZoomOverviewBMP "1:$BMPSampleOverview"
        set SizeOverviewWidth [expr round($SourceWidth / $BMPSampleOverview)]
        set SizeOverviewHeight [expr round($SourceHeight / $BMPSampleOverview)]
        } 

    BMPOverview blank
    BMPOverview copy ImageSource -from 0 0 $SourceWidth $SourceHeight -subsample $BMPSampleOverview $BMPSampleOverview
    $widget(CANVASOVERVIEW) configure -width $SizeOverviewWidth -height $SizeOverviewHeight
    $widget(CANVASOVERVIEW) create image 0 0 -anchor nw -image BMPOverview
    set BMPTitleOverview "Overview "
    append BMPTitleOverview $ZoomOverviewBMP
    wm title $widget(VIEWOVERVIEW) [file tail $BMPTitleOverview]
    set x [winfo x $widget(VIEWOVERVIEW)]
    set y [winfo y $widget(VIEWOVERVIEW)]
    set geometrie $SizeOverviewWidth; append geometrie "x"; append geometrie $SizeOverviewHeight; append geometrie "+";
    append geometrie $x; append geometrie "+"; append geometrie $y
    wm geometry $widget(VIEWOVERVIEW) $geometrie; update
    WidgetGeometryCenter $widget(VIEWOVERVIEW)
    catch {wm geometry $widget(VIEWOVERVIEW) {}}
    Window show $widget(VIEWOVERVIEW); TextEditorRunTrace "Open Window Overview" "b"
    
    #show rect_overview
    set RectLensCenterX [expr round($SizeOverviewWidth/2)]
    set RectLensCenterY [expr round($SizeOverviewHeight/2)]
    set RectLensCenter {$RectLensCenterX $RectLensCenterY}
   
    set RectLensX1 [expr [lindex $RectLensCenter 0] - round($SizeRect / 2 / $BMPSampleOverview)]
    set RectLensY1 [expr [lindex $RectLensCenter 1] - round($SizeRect / 2 / $BMPSampleOverview)]
    set RectLensX2 [expr $RectLensX1 + round($SizeRect / $BMPSampleOverview)]
    set RectLensY2 [expr $RectLensY1 + round($SizeRect / $BMPSampleOverview)]
    set RectLens [$widget(CANVASOVERVIEW) create rectangle $RectLensX1 $RectLensY1 $RectLensX2 $RectLensY2 -outline white -width 2]
    $widget(CANVASOVERVIEW) addtag RectLensCenter withtag $RectLens
    bind $widget(CANVASOVERVIEW) <B1-Motion> "RectOverviewMove $widget(CANVASOVERVIEW) %x %y $widget(CANVASBMPOVERVIEW)"
    set plot(lastX) 0
    set plot(lastY) 0

    #show Overview
    set LensX1 [expr round(($SourceWidth - $SizeRect) / 2 )]
    set LensY1 [expr round(($SourceHeight - $SizeRect) / 2 )]
    set LensX2 [expr $LensX1 + $SizeRect]
    set LensY2 [expr $LensY1 + $SizeRect]
    BMPImageOverview blank
    BMPImageOverview copy ImageSource -from $LensX1 $LensY1 $LensX2 $LensY2
    $widget(CANVASBMPOVERVIEW) configure -width $SizeLensOverview -height $SizeLensOverview
    $widget(CANVASBMPOVERVIEW) create image 0 0 -anchor nw -image BMPImageOverview
    wm title $widget(VIEWBMPOVERVIEW) [file tail $BMPViewFileInput]
    set x [winfo x $widget(VIEWBMPOVERVIEW)]
    set y [winfo y $widget(VIEWBMPOVERVIEW)]
    set geometrie $SizeLensOverview; append geometrie "x"; append geometrie $SizeLensOverview; append geometrie "+";
    append geometrie $x; append geometrie "+"; append geometrie $y
    wm geometry $widget(VIEWBMPOVERVIEW) $geometrie; update
    WidgetGeometryLeft $widget(VIEWBMPOVERVIEW)
    catch {wm geometry $widget(VIEWBMPOVERVIEW) {}} 
    Window show $widget(VIEWBMPOVERVIEW); TextEditorRunTrace "Open Window View BMP Overview" "b"
        
    } else {
    MouseActiveFunction ""
    set BMPSampleOverview ""
    $widget(CANVASBMPOVERVIEW) dtag RectLensCenter
    Window hide $widget(VIEWBMPOVERVIEW); TextEditorRunTrace "Close Window View BMP Overview" "b"
    Window hide $widget(VIEWOVERVIEW); TextEditorRunTrace "Close Window Overview" "b"
    #Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    #set ZoomBMP $ZoomBMPView
    image delete ImageSource
    set TmpImage $BMPViewFileInput; 
    if [file exists $TMPBmpTmp] {set TmpImage $TMPBmpTmp}
    load_bmp_caracteristics $TmpImage
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    load_bmp_file $TmpImage
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    catch {wm geometry $widget($BMPView) {}} 
    wm title $widget($BMPView) [file tail $BMPViewFileInput]
    Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    }
}
}
}}] \
        -image [vTcl:image:get_image [file join . GUI Images Overview.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but109" "Button1" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_5_0.but109 "$site_5_0.but109 Button $top all _vTclBalloon"
    bind $site_5_0.but109 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Overview Tool}
    }
    button $site_5_0.cpd73 \
        \
        -command [list vTcl:DoCmdOption $site_5_0.cpd73 {global BMPImageOpen BMPViewFileInput SourceWidth SourceHeight ImageSource
global BMPImage BMPOverviewAll BMPLensAll BMPViewAll BMPView
global RectOverviewAllCenter RectOverviewAllCenterX RectOverviewAllCenterY RectOverviewAll
global SizeRectOverviewAll SizeOverviewAllWidth SizeOverviewAllHeight SizeViewAll plotOverviewAll
global RectLensAllCenter RectLensAllCenterX RectLensAllCenterY RectLensAll
global SizeRectLensAll SizeLensAll SizeViewAll plotOverviewAll plotLensAll
global SizeRectAllTmp SizeRectAllTmpX SizeRectAllTmpY
global BMPSample BMPTitleOverviewAll BMPTitleViewAll BMPTitleLensAll
global BMPSampleOverview BMPSampleLens LensAll
global BMPWidthSource BMPHeightSource BMPSampleSource LensX1 LensY1
global BMPColorMapDisplay BMPColorMapGrayJetHsv
global ZoomBMP ZoomBMPView ZoomBMPSource ZoomOverviewBMP ZoomLensBMP BMPLensDeltaX BMPLensDeltaY
global MouseActiveButton MouseRectOverviewAll MouseRectLensAll OpenDirFile
global OverviewAllX1 OverviewAllY1 OverviewAllX2 OverviewAllY2
global LensAllX1 LensAllY1 LensAllX2 LensAllY2
global ImageSource TMPBmpTmp ColorNumber BMPColorBar BMPCanvas BMPWidth BMPHeight BMPImage BMPViewFileInput
#BMP PROCESS
global Load_ViewBMPAll PSPTopLevel
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256 Load_ColorMapGrayJetHsv

if {$OpenDirFile == 0} {

if {"$BMPImageOpen" == "1"} {
if {$MouseActiveButton == "Training"} {
    set ErrorMessage "IMPOSSIBLE IN TRAINING MODE" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
if {$MouseActiveButton != "ViewAll"} {

    if {$Load_ViewBMPAll == 0} {
        source "GUI/bmp_process/ViewBMPAll.tcl"
        set Load_ViewBMPAll 1
        WmTransient .top339 $PSPTopLevel
        }

    if {$MouseActiveButton == "Lens"} {
        set Lens ""
        set BMPSampleLens ""
        $widget(CANVASBMPLENS) dtag RectLensCenter
        Window hide $widget(VIEWBMPLENS); TextEditorRunTrace "Close Window View BMP Lens" "b"
        Window hide $widget(VIEWLENS); TextEditorRunTrace "Close Window Zoom" "b"
        }
    if {$MouseActiveButton == "Overview"} {
        set BMPSampleOverview ""
        $widget(CANVASOVERVIEW) dtag RectLensCenter
        Window hide $widget(VIEWBMPOVERVIEW); TextEditorRunTrace "Close Window View BMP Overview" "b"
        Window hide $widget(VIEWOVERVIEW); TextEditorRunTrace "Close Window Overview" "b"
        } else {
        Window hide $widget($BMPView); TextEditorRunTrace "Close Window View $BMPView" "b"
        set ZoomBMPView $ZoomBMP
        }

    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    TextEditorRunTrace "Close All ColorMap Windows" "b"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    
    MouseActiveFunction "ViewAll"
    set ZoomBMP "1:1"
    
    set MouseRectOverviewAll "Outside"
    set BMPSampleOverview "1"

    set SizeOverviewAllWidth 300
    set SizeOverviewAllHeight 300
    set SizeViewAll 600

    set SizeRectOverviewAll $SizeViewAll
    if {$SourceWidth <= $SizeViewAll} {set SizeRectOverviewAll $SourceWidth}
    if {$SourceHeight <= $SizeViewAll} {set SizeRectOverviewAll $SourceHeight}

    #show Overview
    package require Img
    set subsample 0
    if {$SourceWidth > $SizeOverviewAllWidth} {set subsample 1}
    if {$SourceHeight > $SizeOverviewAllHeight} {set subsample 1}

    set ZoomOverviewBMP "0:0"
    if {$subsample == 0} {
        set ZoomOverviewBMP "1:$BMPSample"
        set SizeOverviewAllWidth $SourceWidth
        set SizeOverviewAllHeight $SourceHeight
        } else {
        if {$SourceWidth >= $SourceHeight} {
            while {[expr round($SourceWidth / $BMPSampleOverview)] > $SizeOverviewAllWidth} {incr BMPSampleOverview}
            } else {
            while {[expr round($SourceHeight / $BMPSampleOverview)] > $SizeOverviewAllHeight} {incr BMPSampleOverview}
            } 
        set ZoomOverviewBMP "1:$BMPSampleOverview"
        set SizeOverviewAllWidth [expr round($SourceWidth / $BMPSampleOverview)]
        set SizeOverviewAllHeight [expr round($SourceHeight / $BMPSampleOverview)]
        } 

    BMPOverviewAll blank
    BMPOverviewAll copy ImageSource -from 0 0 $SourceWidth $SourceHeight -subsample $BMPSampleOverview $BMPSampleOverview
    $widget(CANVASOVERVIEWALL) configure -width $SizeOverviewAllWidth -height $SizeOverviewAllHeight
    $widget(CANVASOVERVIEWALL) create image 0 0 -anchor nw -image BMPOverviewAll
    set BMPTitleOverviewAll "Overview "
    append BMPTitleOverviewAll $ZoomOverviewBMP
    
    #show rect_overview
    set RectOverviewAllCenterX [expr round($SizeOverviewAllWidth/2)]
    set RectOverviewAllCenterY [expr round($SizeOverviewAllHeight/2)]
    set RectOverviewAllCenter {$RectOverviewAllCenterX $RectOverviewAllCenterY}
   
    set RectLensX1 [expr [lindex $RectOverviewAllCenter 0] - round($SizeRectOverviewAll / 2 / $BMPSampleOverview)]
    set RectLensY1 [expr [lindex $RectOverviewAllCenter 1] - round($SizeRectOverviewAll / 2 / $BMPSampleOverview)]
    set RectLensX2 [expr $RectLensX1 + round($SizeRectOverviewAll / $BMPSampleOverview)]
    set RectLensY2 [expr $RectLensY1 + round($SizeRectOverviewAll / $BMPSampleOverview)]
    set RectOverviewAll [$widget(CANVASOVERVIEWALL) create rectangle $RectLensX1 $RectLensY1 $RectLensX2 $RectLensY2 -outline white -width 2]
    $widget(CANVASOVERVIEWALL) addtag RectOverviewAllCenter withtag $RectOverviewAll
    bind $widget(CANVASOVERVIEWALL) <B1-Motion> "RectOverviewAllMove $widget(CANVASOVERVIEWALL) %x %y $widget(CANVASVIEWALL)"
    set plotOverviewAll(lastX) 0
    set plotOverviewAll(lastY) 0

    #show View
    set OverviewAllX1 [expr round(($SourceWidth - $SizeRectOverviewAll) / 2 )]
    set OverviewAllY1 [expr round(($SourceHeight - $SizeRectOverviewAll) / 2 )]
    set OverviewAllX2 [expr $OverviewAllX1 + $SizeRectOverviewAll]
    set OverviewAllY2 [expr $OverviewAllY1 + $SizeRectOverviewAll]
    BMPViewAll blank
    BMPViewAll copy ImageSource -from $OverviewAllX1 $OverviewAllY1 $OverviewAllX2 $OverviewAllY2
    $widget(CANVASVIEWALL) configure -width $SizeViewAll -height $SizeViewAll
    $widget(CANVASVIEWALL) create image 0 0 -anchor nw -image BMPViewAll
    set BMPTitleViewAll "Display 1:1 "
 
    set MouseRectLensAll "Outside"
    set LensAll "1"
    set BMPSampleLens "1"
    set ZoomLensBMP "1:1"

    set BMPLensDeltaX "0"
    set BMPLensDeltaY "0"
        
    set SizeRectLensAll 300
    set SizeRectAllTmp $SizeRectLensAll
    set SizeRectAllTmpX $SizeViewAll
    set SizeRectAllTmpY $SizeViewAll
    set SizeLensAll 300
        
    #show Lens
    set LensAllX1 [expr $OverviewAllX1 + round(($SizeViewAll - $SizeRectLensAll) / 2 )]
    set LensAllY1 [expr $OverviewAllY1 + round(($SizeViewAll - $SizeRectLensAll) / 2 )]
    set LensAllX2 [expr $LensAllX1 + $SizeRectLensAll]
    set LensAllY2 [expr $LensAllY1 + $SizeRectLensAll]
    BMPLensAll blank
    BMPLensAll copy ImageSource -from $LensAllX1 $LensAllY1 $LensAllX2 $LensAllY2 -subsample $BMPSampleLens $BMPSampleLens
    $widget(CANVASLENSALL) configure -width $SizeLensAll -height $SizeLensAll
    $widget(CANVASLENSALL) create image 0 0 -anchor nw -image BMPLensAll
    set BMPTitleLensAll "Zoom "
    append BMPTitleLensAll $ZoomLensBMP
               
    #show rect_zoom
    set RectLensAllCenterX [expr round($SizeViewAll/2)]
    set RectLensAllCenterY [expr round($SizeViewAll/2)]
    set RectLensAllCenter {$RectLensAllCenterX $RectLensAllCenterY}
   
    set RectLensX1 [expr [lindex $RectLensAllCenter 0] - round($SizeRectLensAll / 2)]
    set RectLensY1 [expr [lindex $RectLensAllCenter 1] - round($SizeRectLensAll / 2)]
    set RectLensX2 [expr $RectLensX1 + $SizeRectLensAll]
    set RectLensY2 [expr $RectLensY1 + $SizeRectLensAll]
    set RectLensAll [$widget(CANVASVIEWALL) create rectangle $RectLensX1 $RectLensY1 $RectLensX2 $RectLensY2 -outline white -width 2]
    $widget(CANVASVIEWALL) addtag RectLensAllCenter withtag $RectLensAll
    bind $widget(CANVASVIEWALL) <B1-Motion> "RectLensAllMove $widget(CANVASVIEWALL) %x %y $widget(CANVASLENSALL)"
    set plotLensAll(lastX) 0
    set plotLensAll(lastY) 0
                                            
    catch {wm geometry $widget(VIEWBMPALL) {}} 
    wm title $widget(VIEWBMPALL) [file tail $BMPViewFileInput]
    Window show $widget(VIEWBMPALL); TextEditorRunTrace "Open Window View BMP All" "b"
    } else {
    MouseActiveFunction ""
    set BMPSampleOverview ""
    $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
    set LensAll ""
    set BMPSampleLens ""
    $widget(CANVASVIEWALL) dtag RectLensAllCenter
    Window hide $widget(VIEWBMPALL); TextEditorRunTrace "Close Window View BMP All" "b"
    #Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    #set ZoomBMP $ZoomBMPView
    image delete ImageSource
    set TmpImage $BMPViewFileInput; 
    if [file exists $TMPBmpTmp] {set TmpImage $TMPBmpTmp}
    load_bmp_caracteristics $TmpImage
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    load_bmp_file $TmpImage
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    catch {wm geometry $widget($BMPView) {}} 
    wm title $widget($BMPView) [file tail $BMPViewFileInput]
    Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    }
}
}
}}] \
        -image [vTcl:image:get_image [file join . GUI Images ViewDisplayAll.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button3" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {View Overview Lens Tool}
    }
    pack $site_5_0.cpd88 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd89 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but109 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd110 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    TitleFrame $top.cpd90 \
        -ipad 2 -relief sunken -text Color 
    vTcl:DefineAlias "$top.cpd90" "TitleFrame4" vTcl:WidgetProc "Toplevel64" 1
    bind $top.cpd90 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd90 getframe]
    button $site_4_0.but71 \
        \
        -command {global BMPImageOpen BMPColorMapDisplay BMPColorMapGrayJetHsv ColorNumber ColorNumberUtil
global InitRedPalette RedPalette InitGreenPalette GreenPalette InitBluePalette BluePalette
global BMPView RectLensCenter Lens BMPSampleLens BMPSampleOverview ZoomBMP ZoomBMPView
global MouseActiveButton OpenDirFile RectOverviewAllCenter RectLensAllCenter
#BMP PROCESS
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256 Load_ColorMapGrayJetHsv PSPTopLevel

if {$OpenDirFile == 0} {

if {$BMPImageOpen == 1} {
    if {"$ColorNumber" == "BMP 24 Bits"} {
        set ErrorMessage "NO CHANGE: BMP 24 Bits" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } else {
        if {$MouseActiveButton == "Lens"} {
            set Lens ""
            set BMPSampleLens ""
            $widget(CANVASBMPLENS) dtag RectLensCenter
            Window hide $widget(VIEWBMPLENS); TextEditorRunTrace "Close Window View BMP Lens" "b"
            Window hide $widget(VIEWLENS); TextEditorRunTrace "Close Window Zoom" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            MouseActiveFunction ""
            }
        if {$MouseActiveButton == "Overview"} {
            set BMPSampleOverview ""
            $widget(CANVASOVERVIEW) dtag RectLensCenter
            Window hide $widget(VIEWBMPOVERVIEW); TextEditorRunTrace "Close Window View BMP Overview" "b"
            Window hide $widget(VIEWOVERVIEW); TextEditorRunTrace "Close Window Overview" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            MouseActiveFunction ""
            }
        if {$MouseActiveButton == "ViewAll"} {
            set BMPSampleOverview ""
            set BMPSampleLens ""
            $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
            $widget(CANVASVIEWALL) dtag RectLensAllCenter
            Window hide $widget(VIEWBMPALL); TextEditorRunTrace "Close Window View BMP All" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            MouseActiveFunction ""
            }

        set BMPColorMapDisplay "0"
        TextEditorRunTrace "Close All ColorMap Windows" "b"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}

        if {$ColorNumberUtil >= 250 } {
            if {$BMPColorMapGrayJetHsv == 0} {
                set BMPColorMapGrayJetHsv 1
                if {$Load_ColorMapGrayJetHsv == 0} {
                    source "GUI/bmp_process/ColorMapGrayJetHsv.tcl"
                    set Load_ColorMapGrayJetHsv 1
                    WmTransient $widget(Toplevel208) $PSPTopLevel
                    }
                for {set i 0} {$i <= 256} {incr i} {
                    set InitRedPalette($i) $RedPalette($i)
                    set InitGreenPalette($i) $GreenPalette($i)
                    set InitBluePalette($i) $BluePalette($i)
                    }
                WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel208); TextEditorRunTrace "Open Window ColorMap Gray Jet Hsv" "b"
                } else {
                set BMPColorMapGrayJetHsv 0
                Window hide $widget(Toplevel208); TextEditorRunTrace "Close Window ColorMap Gray Jet Hsv" "b"
                }
            } else {
            set ErrorMessage "NOT A 256 COLORS BMP IMAGE" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images colormap.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_4_0.but71" "Button2" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.but71 "$site_4_0.but71 Button $top all _vTclBalloon"
    bind $site_4_0.but71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Change ColorMap}
    }
    button $site_4_0.cpd91 \
        \
        -command {global BMPView RectLensCenter Lens BMPSampleLens BMPSampleOverview ZoomBMP ZoomBMPView
global BMPImageOpen BMPDropperFlag BMPColorMapDisplay BMPColorMapGrayJetHsv
global MouseActiveButton OpenDirFile RectOverviewAllCenter RectLensAllCenter
#BMP PROCESS
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256 Load_ColorMapGrayJetHsv

if {$OpenDirFile == 0} {

if {"$BMPImageOpen" == "1"} {

if {$MouseActiveButton != "Dropper"} {
    if {$MouseActiveButton == "Lens"} {
        set Lens ""
        set BMPSampleLens ""
        $widget(CANVASBMPLENS) dtag RectLensCenter
        Window hide $widget(VIEWBMPLENS)
        Window hide $widget(VIEWLENS)
        Window show $widget($BMPView)
        set ZoomBMP $ZoomBMPView
        }
    if {$MouseActiveButton == "Overview"} {
        set BMPSampleOverview ""
        $widget(CANVASOVERVIEW) dtag RectLensCenter
        Window hide $widget(VIEWBMPOVERVIEW)
        Window hide $widget(VIEWOVERVIEW)
        Window show $widget($BMPView)
        set ZoomBMP $ZoomBMPView
        }
    if {$MouseActiveButton == "ViewAll"} {
        set BMPSampleOverview ""
        set BMPSampleLens ""
        $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
        $widget(CANVASVIEWALL) dtag RectLensAllCenter
        Window hide $widget(VIEWBMPALL); TextEditorRunTrace "Close Window View BMP All" "b"
        Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
        set ZoomBMP $ZoomBMPView
        }
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}

    MouseActiveFunction "Dropper"
    } else {
    if {$MouseActiveButton == "Dropper" } {
        MouseActiveFunction ""
        set BMPDropperFlag 0
        set c0 .top64.cpd90.f.cpd92
        $c0 configure -background $couleur_fond
        } else {
        MouseActiveFunction "Dropper"
        } 
    }
}
}} \
        -image [vTcl:image:get_image [file join . GUI Images dropper.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_4_0.cpd91" "Button546" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd91 "$site_4_0.cpd91 Button $top all _vTclBalloon"
    bind $site_4_0.cpd91 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Dropper Tool}
    }
    button $site_4_0.cpd92 \
        \
        -command [list vTcl:DoCmdOption $site_4_0.cpd92 {global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global RedPalette GreenPalette BluePalette
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global Fonction Fonction2 updatecolormap
global MouseActiveButton
#BMP PROCESS
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256

if {"$BMPImageOpen" == "1"} {
    if {"$MouseActiveButton" == "Dropper"} {
        if {"$BMPDropperFlag" == 1 } {
            if {"$ColorNumber" == "BMP 24 Bits"} {
                set ErrorMessage "NO CHANGE: BMP 24 Bits" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                } else {
                set c0 .top64.cpd90.f.cpd92
                set initialColor [$c0 cget -background]
                for {set i 1} {$i <= $ColorNumber} {incr i} {
                    set color [format #%02x%02x%02x $RedPalette($i) $GreenPalette($i) $BluePalette($i)]
                    if {$initialColor == $color } {set IndPalette $i}
                    }
                UpdateColorMap $widget($BMPCanvas) $c0 $IndPalette
                if {$updatecolormap == "true"} {
                    if {$BMPColorMapDisplay == "8"} { UpdateColorMap8 }
                    if {$BMPColorMapDisplay == "16"} { UpdateColorMap16 }
                    if {$BMPColorMapDisplay == "32"} { UpdateColorMap32 }
                    if {$BMPColorMapDisplay == "256"} { UpdateColorMap256 }
                    }
                set BMPDropperFlag 0
                }
            }
        }
    }}] \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_4_0.cpd92" "Button551" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd92 "$site_4_0.cpd92 Button $top all _vTclBalloon"
    bind $site_4_0.cpd92 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Pixel Color Display}
    }
    button $site_4_0.cpd93 \
        \
        -command {global BMPImageOpen BMPColorMapDisplay ColorNumber ColorNumberUtilDisplay ColorMapBMP RedPalette GreenPalette BluePalette
global BMPView RectLensCenter Lens BMPSampleLens BMPSampleOverview ZoomBMP ZoomBMPView
global MouseActiveButton OpenDirFile RectOverviewAllCenter RectLensAllCenter
#BMP PROCESS
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256 Load_ColorMapGrayJetHsv PSPTopLevel

if {$OpenDirFile == 0} {

if {"$BMPImageOpen" == "1"} {

if {"$ColorNumber" == "BMP 24 Bits"} {
    set BMPColorMapDisplay "0"
    set ErrorMessage "NO CHANGE: BMP 24 Bits" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    if {$BMPColorMapDisplay != "0"} {
        set BMPColorMapDisplay "0"
        #Colormap Window
        TextEditorRunTrace "Close All ColorMap Windows" "b"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        } else {
        if {$MouseActiveButton == "Lens"} {
            set Lens ""
            set BMPSampleLens ""
            $widget(CANVASBMPLENS) dtag RectLensCenter
            Window hide $widget(VIEWBMPLENS); TextEditorRunTrace "Close Window View BMP Lens" "b"
            Window hide $widget(VIEWLENS); TextEditorRunTrace "Close Window Zoom" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            MouseActiveFunction ""
            }
        if {$MouseActiveButton == "Overview"} {
            set BMPSampleOverview ""
            $widget(CANVASOVERVIEW) dtag RectLensCenter
            Window hide $widget(VIEWBMPOVERVIEW); TextEditorRunTrace "Close Window View BMP Overview" "b"
            Window hide $widget(VIEWOVERVIEW); TextEditorRunTrace "Close Window Overview" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            MouseActiveFunction ""
            }
        if {$MouseActiveButton == "ViewAll"} {
            set BMPSampleOverview ""
            set BMPSampleLens ""
            $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
            $widget(CANVASVIEWALL) dtag RectLensAllCenter
            Window hide $widget(VIEWBMPALL); TextEditorRunTrace "Close Window View BMP All" "b"
            Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
            set ZoomBMP $ZoomBMPView
            MouseActiveFunction ""
            }
        set BMPColorMapGrayJetHsv "0"
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
        
        if {$ColorNumberUtilDisplay == 256 } {
            if {$Load_colormap256 == 0} {
                source "GUI/bmp_process/colormap256.tcl"
                set Load_colormap256 1
                WmTransient $widget(Toplevel62) $PSPTopLevel
                }
            UpdateColorMap256
            set BMPColorMapDisplay "256"
            WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel62); TextEditorRunTrace "Open Window Colormap 256" "b"
            }
        if {$ColorNumberUtilDisplay == 32 } {
            if {$Load_colormap32 == 0} {
                source "GUI/bmp_process/colormap32.tcl"
                set Load_colormap32 1
                WmTransient $widget(Toplevel76) $PSPTopLevel
                }
            UpdateColorMap32
            set BMPColorMapDisplay "32"
            WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel76); TextEditorRunTrace "Open Window Colormap 32" "b"
            }
        if {$ColorNumberUtilDisplay == 16 } {
            if {$Load_colormap16 == 0} {
                source "GUI/bmp_process/colormap16.tcl"
                set Load_colormap16 1
                WmTransient $widget(Toplevel77) $PSPTopLevel
                }
            UpdateColorMap16
            set BMPColorMapDisplay "16"
            WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel77); TextEditorRunTrace "Open Window Colormap 16" "b"
            }
        if {$ColorNumberUtilDisplay == 8 } {
            if {$Load_colormap8 == 0} {
                source "GUI/bmp_process/colormap8.tcl"
                set Load_colormap8 1
                WmTransient $widget(Toplevel81) $PSPTopLevel
                }
            UpdateColorMap8
            set BMPColorMapDisplay "8"
            WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel81); TextEditorRunTrace "Open Window Colormap 8" "b"
            }
        }
    }
}
}} \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text {    } -width 20 
    vTcl:DefineAlias "$site_4_0.cpd93" "Button548" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd93 "$site_4_0.cpd93 Button $top all _vTclBalloon"
    bind $site_4_0.cpd93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_4_0.but71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd95 \
        -ipad 2 -relief sunken -text Tools 
    vTcl:DefineAlias "$top.cpd95" "TitleFrame5" vTcl:WidgetProc "Toplevel64" 1
    bind $top.cpd95 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd95 getframe]
    button $site_4_0.cpd96 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight
global BMPWidth BMPHeight WidthBMP HeightBMP ZoomBMP
global ImageSource BMPImage BMPImageLens BMPLens BMPOverview BMPImageOverview BMPView BMPCanvas
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette
global BMPLensFlag RectLensCenter BMPWidthSource BMPHeightSource BMPSampleSource ZoomBMPSource
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect BMPMax BMPMin
global Fonction Fonction2 OpenDirFile RectOverviewAllCenter RectLensAllCenter
package require Img
#BMP PROCESS
global Load_Save Load_ViewBMPFile Load_ViewBMP1 Load_ViewBMPLens Load_Zoom
global Load_ViewBMPOverview Load_ViewOverview Load_ViewBMPAll
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    set BMPChange "1"

    set Fonction "IMAGE PROCESSING"
    set Fonction2 "ROTATION FLIP LEFT-RIGHT"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    if {"$ColorNumber" != "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bmp_process/bmp_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op fliplr -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" "k"
        set f [ open "| Soft/bmp_process/bmp_processing.exe -op fliplr -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" r]
        }
    if {"$ColorNumber" == "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bmp_process/bmp24_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op fliplr -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" "k"
        set f [ open "| Soft/bmp_process/bmp24_processing.exe -op fliplr -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    #Display Window
    TextEditorRunTrace "Close All Image Windows" "b"
    if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP)}
    if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1)}
    if {$Load_ViewBMPLens == 1} {Window hide $widget(VIEWBMPLENS)}
    if {$Load_Zoom == 1} {Window hide $widget(VIEWLENS)}
    if {$Load_ViewBMPOverview == 1} {Window hide $widget(VIEWBMPOVERVIEW)}
    if {$Load_ViewOverview == 1} {Window hide $widget(VIEWOVERVIEW)}
    #Colormap Window
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    MouseActiveFunction ""
    if { $Load_ViewBMPLens == 1 } {$widget(CANVASBMPLENS) dtag RectLensCenter}
    if { $Load_ViewOverview == 1 } {$widget(CANVASOVERVIEW) dtag RectLensCenter}

    if {$Load_ViewBMPAll == 1} {
        Window hide $widget(VIEWBMPALL)
        $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
        $widget(CANVASLENSALL) dtag RectLensAllCenter
        }

    image delete ImageSource

    load_bmp_caracteristics $TMPBmpTmp
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    load_bmp_file $TMPBmpTmp
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    catch {wm geometry $widget($BMPView) {}} 
    wm title $widget($BMPView) [file tail $BMPViewFileInput]
    Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images img-xflip.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd96" "Button661" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd96 "$site_4_0.cpd96 Button $top all _vTclBalloon"
    bind $site_4_0.cpd96 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Mirror}
    }
    button $site_4_0.cpd97 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight
global BMPWidth BMPHeight WidthBMP HeightBMP ZoomBMP
global ImageSource BMPImage BMPImageLens BMPLens BMPOverview BMPImageOverview BMPView BMPCanvas
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette
global BMPLensFlag RectLensCenter BMPWidthSource BMPHeightSource BMPSampleSource ZoomBMPSource
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect BMPMax BMPMin
global Fonction Fonction2 OpenDirFile RectOverviewAllCenter RectLensAllCenter
package require Img
#BMP PROCESS
global Load_Save Load_ViewBMPFile Load_ViewBMP1 Load_ViewBMPLens Load_Zoom
global Load_ViewBMPOverview Load_ViewOverview Load_ViewBMPAll
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    set BMPChange "1"

    set Fonction "IMAGE PROCESSING"
    set Fonction2 "ROTATION FLIP UP-DOWN"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    if {"$ColorNumber" != "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bmp_process/bmp_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op flipud -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" "k"
        set f [ open "| Soft/bmp_process/bmp_processing.exe -op flipud -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" r]
        }
    if {"$ColorNumber" == "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bmp_process/bmp24_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op flipud -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" "k"
        set f [ open "| Soft/bmp_process/bmp24_processing.exe -op flipud -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    #Display Window
    TextEditorRunTrace "Close All Image Windows" "b"
    if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP)}
    if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1)}
    if {$Load_ViewBMPLens == 1} {Window hide $widget(VIEWBMPLENS)}
    if {$Load_Zoom == 1} {Window hide $widget(VIEWLENS)}
    if {$Load_ViewBMPOverview == 1} {Window hide $widget(VIEWBMPOVERVIEW)}
    if {$Load_ViewOverview == 1} {Window hide $widget(VIEWOVERVIEW)}
    #Colormap Window
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    MouseActiveFunction ""
    if { $Load_ViewBMPLens == 1 } {$widget(CANVASBMPLENS) dtag RectLensCenter}
    if { $Load_ViewOverview == 1 } {$widget(CANVASOVERVIEW) dtag RectLensCenter}

    if {$Load_ViewBMPAll == 1} {
        Window hide $widget(VIEWBMPALL)
        $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
        $widget(CANVASLENSALL) dtag RectLensAllCenter
        }

    image delete ImageSource

    load_bmp_caracteristics $TMPBmpTmp
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    load_bmp_file $TMPBmpTmp
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    catch {wm geometry $widget($BMPView) {}} 
    wm title $widget($BMPView) [file tail $BMPViewFileInput]
    Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images img-yflip.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd97" "Button662" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd97 "$site_4_0.cpd97 Button $top all _vTclBalloon"
    bind $site_4_0.cpd97 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Flip}
    }
    button $site_4_0.cpd98 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight
global BMPWidth BMPHeight WidthBMP HeightBMP ZoomBMP
global ImageSource BMPImage BMPImageLens BMPLens BMPOverview BMPImageOverview BMPView BMPCanvas
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette
global BMPLensFlag RectLensCenter BMPWidthSource BMPHeightSource BMPSampleSource ZoomBMPSource
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect BMPMax BMPMin
global Fonction Fonction2 OpenDirFile RectOverviewAllCenter RectLensAllCenter
package require Img
#BMP PROCESS
global Load_Save Load_ViewBMPFile Load_ViewBMP1 Load_ViewBMPLens Load_Zoom
global Load_ViewBMPOverview Load_ViewOverview Load_ViewBMPAll
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    set BMPChange "1"

    set Fonction "IMAGE PROCESSING"
    set Fonction2 "ROTATION 90deg LEFT"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    if {"$ColorNumber" != "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bmp_process/bmp_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op rot270 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" "k"
        set f [ open "| Soft/bmp_process/bmp_processing.exe -op rot270 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" r]
        }
    if {"$ColorNumber" == "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bmp_process/bmp24_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op rot270 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" "k"
        set f [ open "| Soft/bmp_process/bmp24_processing.exe -op rot270 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    #Display Window
    TextEditorRunTrace "Close All Image Windows" "b"
    if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP)}
    if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1)}
    if {$Load_ViewBMPLens == 1} {Window hide $widget(VIEWBMPLENS)}
    if {$Load_Zoom == 1} {Window hide $widget(VIEWLENS)}
    if {$Load_ViewBMPOverview == 1} {Window hide $widget(VIEWBMPOVERVIEW)}
    if {$Load_ViewOverview == 1} {Window hide $widget(VIEWOVERVIEW)}
    #Colormap Window
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    MouseActiveFunction ""
    if { $Load_ViewBMPLens == 1 } {$widget(CANVASBMPLENS) dtag RectLensCenter}
    if { $Load_ViewOverview == 1 } {$widget(CANVASOVERVIEW) dtag RectLensCenter}

    if {$Load_ViewBMPAll == 1} {
        Window hide $widget(VIEWBMPALL)
        $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
        $widget(CANVASLENSALL) dtag RectLensAllCenter
        }

    image delete ImageSource

    load_bmp_caracteristics $TMPBmpTmp
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    load_bmp_file $TMPBmpTmp
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    catch {wm geometry $widget($BMPView) {}} 
    wm title $widget($BMPView) [file tail $BMPViewFileInput]
    Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images img-lrotat.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd98" "Button663" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd98 "$site_4_0.cpd98 Button $top all _vTclBalloon"
    bind $site_4_0.cpd98 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Rotate +90}
    }
    button $site_4_0.cpd99 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight
global BMPWidth BMPHeight WidthBMP HeightBMP ZoomBMP
global ImageSource BMPImage BMPImageLens BMPLens BMPOverview BMPImageOverview BMPView BMPCanvas
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette
global BMPLensFlag RectLensCenter BMPWidthSource BMPHeightSource BMPSampleSource ZoomBMPSource
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect BMPMax BMPMin
global Fonction Fonction2 OpenDirFile RectOverviewAllCenter RectLensAllCenter
package require Img
#BMP PROCESS
global Load_Save Load_ViewBMPFile Load_ViewBMP1 Load_ViewBMPLens Load_Zoom
global Load_ViewBMPOverview Load_ViewOverview Load_ViewBMPAll
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    set BMPChange "1"

    set Fonction "IMAGE PROCESSING"
    set Fonction2 "ROTATION 90deg RIGHT"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    if {"$ColorNumber" != "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bmp_process/bmp_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op rot90 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" "k"
        set f [ open "| Soft/bmp_process/bmp_processing.exe -op rot90 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" r]
        }
    if {"$ColorNumber" == "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bmp_process/bmp24_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op rot90 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" "k"
        set f [ open "| Soft/bmp_process/bmp24_processing.exe -op rot90 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    #Display Window
    TextEditorRunTrace "Close All Image Windows" "b"
    if {$Load_ViewBMPFile == 1} {Window hide $widget(VIEWBMP)}
    if {$Load_ViewBMP1 == 1} {Window hide $widget(VIEWBMP1)}
    if {$Load_ViewBMPLens == 1} {Window hide $widget(VIEWBMPLENS)}
    if {$Load_Zoom == 1} {Window hide $widget(VIEWLENS)}
    if {$Load_ViewBMPOverview == 1} {Window hide $widget(VIEWBMPOVERVIEW)}
    if {$Load_ViewOverview == 1} {Window hide $widget(VIEWOVERVIEW)}
    #Colormap Window
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    MouseActiveFunction ""
    if { $Load_ViewBMPLens == 1 } {$widget(CANVASBMPLENS) dtag RectLensCenter}
    if { $Load_ViewOverview == 1 } {$widget(CANVASOVERVIEW) dtag RectLensCenter}

    if {$Load_ViewBMPAll == 1} {
        Window hide $widget(VIEWBMPALL)
        $widget(CANVASOVERVIEWALL) dtag RectOverviewAllCenter
        $widget(CANVASLENSALL) dtag RectLensAllCenter
        }

    image delete ImageSource

    load_bmp_caracteristics $TMPBmpTmp
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    load_bmp_file $TMPBmpTmp
    $widget($BMPCanvas) configure -width $BMPWidth -height $BMPHeight
    $widget($BMPCanvas) create image 0 0 -anchor nw -image BMPImage
    catch {wm geometry $widget($BMPView) {}} 
    wm title $widget($BMPView) [file tail $BMPViewFileInput]
    Window show $widget($BMPView); TextEditorRunTrace "Open Window View $BMPView" "b"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images img-rrotat.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd99" "Button664" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_4_0.cpd99 "$site_4_0.cpd99 Button $top all _vTclBalloon"
    bind $site_4_0.cpd99 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Rotate -90}
    }
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd99 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd104 \
        -ipad 2 -relief sunken -text {Color Map} 
    vTcl:DefineAlias "$top.cpd104" "TitleFrame6" vTcl:WidgetProc "Toplevel64" 1
    bind $top.cpd104 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd104 getframe]
    canvas $site_4_0.cpd105 \
        -borderwidth 2 -closeenough 1.0 -height 12 -relief ridge \
        -takefocus {} -width 120 
    vTcl:DefineAlias "$site_4_0.cpd105" "CANVASCOLORBAR" vTcl:WidgetProc "Toplevel64" 1
    frame $site_4_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame1" vTcl:WidgetProc "Toplevel64" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.cpd73 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable BMPMin -width 6 
    vTcl:DefineAlias "$site_5_0.cpd73" "Label5" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Label $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Coded Min Value}
    }
    label $site_5_0.cpd75 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable BMPMax -width 6 
    vTcl:DefineAlias "$site_5_0.cpd75" "Label9" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_5_0.cpd75 "$site_5_0.cpd75 Label $top all _vTclBalloon"
    bind $site_5_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Coded Max Value}
    }
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd74 \
        -borderwidth 3 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame2" vTcl:WidgetProc "Toplevel64" 1
    set site_5_0 $site_4_0.cpd74
    label $site_5_0.cpd76 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable BMPValue -width 6 
    vTcl:DefineAlias "$site_5_0.cpd76" "Label6" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_5_0.cpd76 "$site_5_0.cpd76 Label $top all _vTclBalloon"
    bind $site_5_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Coded Pixel Value}
    }
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd105 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra32 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra32" "Frame390" vTcl:WidgetProc "Toplevel64" 1
    set site_3_0 $top.fra32
    button $site_3_0.but33 \
        \
        -command {global BMPScreenDisplay OpenDirFile

if {$OpenDirFile == 0} {

#BMP PROCESS
global Load_Display PSPTopLevel

if {$BMPScreenDisplay == 0} {
    if {$Load_Display == 0} {
        source "GUI/bmp_process/Display.tcl"
        set Load_Display 1
        WmTransient $widget(Toplevel71) $PSPTopLevel
        }
    set BMPScreenDisplay 1
    WidgetShowFromWidget $widget(Toplevel64) $widget(Toplevel71); TextEditorRunTrace "Open Window Screen Display" "b"
    } else {
    set BMPScreenDisplay 0
    Window hide $widget(Toplevel71); TextEditorRunTrace "Close Window Screen Display" "b"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images screen.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_3_0.but33" "Button552" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_3_0.but33 "$site_3_0.but33 Button $top all _vTclBalloon"
    bind $site_3_0.but33 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Screen Display Size}
    }
    button $site_3_0.but30 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolSARpro_Viewer.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but30" "Button15" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_3_0.but30 "$site_3_0.but30 Button $top all _vTclBalloon"
    bind $site_3_0.but30 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but34 \
        -background #ffff00 \
        -command {global PVMainMenu BMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

ClosePSPViewer

if {$BMPImageOpen == 0} {
    Window hide $widget(Toplevel64); TextEditorRunTrace "Close Window PolSARpro Viewer" "b"
    if {$PVMainMenu == 1} {
        set PVMainMenu 0
        Window show $widget(Toplevel2)
        }
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but34" "Button67" vTcl:WidgetProc "Toplevel64" 1
    bindtags $site_3_0.but34 "$site_3_0.but34 Button $top all _vTclBalloon"
    bind $site_3_0.but34 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but33 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but30 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but34 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab65 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra24 \
        -in $top -anchor center -expand 1 -fill both -side top 
    pack $top.tit71 \
        -in $top -anchor center -expand 1 -fill both -side top 
    pack $top.cpd80 \
        -in $top -anchor center -expand 1 -fill both -side top 
    pack $top.cpd81 \
        -in $top -anchor center -expand 1 -fill both -side top 
    pack $top.cpd90 \
        -in $top -anchor center -expand 1 -fill both -side top 
    pack $top.cpd95 \
        -in $top -anchor center -expand 1 -fill both -side top 
    pack $top.cpd104 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra32 \
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
Window show .top64

main $argc $argv
