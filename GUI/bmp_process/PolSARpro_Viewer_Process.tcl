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

        {{[file join . GUI Images color-rgb.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
        {{[file join . GUI Images CloseFile.gif]} {user image} user {}}
        {{[file join . GUI Images PVv3small.gif]} {user image} user {}}
        {{[file join . GUI Images img-xflip.gif]} {user image} user {}}
        {{[file join . GUI Images img-yflip.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images img-lrotat.gif]} {user image} user {}}
        {{[file join . GUI Images img-rrotat.gif]} {user image} user {}}
        {{[file join . GUI Images colormap.gif]} {user image} user {}}
        {{[file join . GUI Images colormap2.gif]} {user image} user {}}

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
    set base .top64p
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
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1}
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
    namespace eval ::widgets::$base.fra32 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra32
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
            vTclWindow.top64p
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
    wm geometry $top 200x200+242+242; update
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

proc vTclWindow.top64p {base} {
    if {$base == ""} {
        set base .top64p
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
    wm geometry $top 140x320+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PV5.1process"
    vTcl:DefineAlias "$top" "Toplevel64p" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab65 \
        -image [vTcl:image:get_image [file join . GUI Images PVv3small.gif]] \
        -relief ridge -text label 
    vTcl:DefineAlias "$top.lab65" "Label172" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $top.lab65 "$top.lab65 Label $top all _vTclBalloon"
    bind $top.lab65 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP Viewer v3.0}
    }
    frame $top.fra24 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra24" "Frame387" vTcl:WidgetProc "Toplevel64p" 1
    set site_3_0 $top.fra24
    button $site_3_0.but26 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight 
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette BMPColorBar
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPColorMapRedGreenBlue BMPTrainingRect
global BMPMax BMPMin MapAlgebraConfigFileProcess
package require Img

#BMP PROCESS
global Load_Save Load_Display Load_ViewBMPFile Load_ViewBMPLens
global Load_Zoom Load_ViewOverview Load_ViewBMPOverview
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global Load_ViewBMPAll PSPTopLevel
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

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
            WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel82); TextEditorRunTrace "Open Window Save" "b"
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
        #Colormap Window
        set BMPColorMapDisplay "0"
        set BMPColorMapGrayJetHsv "0"
        set BMPColorMapRedGreenBlue "0"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
        if {$Load_ColorMapRedGreenBlue == 1} {Window hide $widget(Toplevel208a)}
            
        if {$Load_Save == 1} {Window hide $widget(Toplevel82)}
        if {$Load_Display == 1} {Window hide $widget(Toplevel71)}
        
        if [file exists $ColorBarBMP] {
            BMPColorBar blank
            $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
            image delete BMPColorBar
            set BMPMax ""
            set BMPMin ""
            }
        set BMPImageOpen "0"
        set SourceWidth ""
        set SourceHeight ""
        if {$MapAlgebraConfigFileProcess != ""} {
            set MapAlgebraConfigFileProcess [MapAlgebra_command $MapAlgebraConfigFileProcess "quit" ""]
            }
        set MapAlgebraConfigFileProcess ""
        }
    }
if { $BMPImageOpen == 0 } {
    MouseActiveFunction ""

    set SourceWidth ""
    set SourceHeight ""
    set BMPMax ""
    set BMPMin ""
    set BMPImageOpen "0"
    set BMPColorMapDisplay "0"
        
    set types {
        {{BMP Files}        {.bmp}        }
        }
    set FileName ""
    OpenFile $BMPDirInput $types "INPUT BMP FILE"

    if {$FileName != ""} {

        set bmphdr "OK"
        set FileNameHdr "$FileName.hdr"
        if [file exists $FileNameHdr] {
            set f [open $FileNameHdr "r"]
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {[string first "PolSARpro" $tmp] != "-1"} {
                gets $f tmp; set tmpncol [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
                gets $f tmp; set tmpnlig [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            } else {
            set ErrorMessage "NOT A PolSARpro BMP FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set bmphdr "KO"
            }    
          close $f
          } else {
          set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
          Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
          tkwait variable VarError
          set bmphdr "KO"
          }    
        
      if {$bmphdr == "OK"} {
        set BMPViewFileInput $FileName
        set BMPImageOpen "1"
        set BMPColorMapDisplay "0"
        set BMPColorMapGrayJetHsv "0"
        set BMPColorMapRedGreenBlue "0"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
        if {$Load_ColorMapRedGreenBlue== 1} {Window hide $widget(Toplevel208a)}

        if {$Load_Save == 1} {Window hide $widget(Toplevel82)}
        if {$Load_Display == 1} {Window hide $widget(Toplevel71)}

        DeleteFile $TMPBmpTmpHeader; DeleteFile $TMPBmp24TmpData; DeleteFile $TMPBmpTmpData
        DeleteFile $TMPBmpTmp; DeleteFile $TMPBmpTmpColormap
        CopyFile "$BMPViewFileInput.hdr" "$TMPBmpTmp.hdr"
        load_bmp_caracteristics $BMPViewFileInput
        if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
        MapAlgebra_load_bmp_file $BMPViewFileInput "process"   
      #bmphdr
      }
    #filename
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text {     } -width 20 
    vTcl:DefineAlias "$site_3_0.but26" "Button543" vTcl:WidgetProc "Toplevel64p" 1
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

if {$BMPImageOpen == 1} {
    WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel82); TextEditorRunTrace "Open Window Save" "b"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but88" "Button578" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_3_0.but88 "$site_3_0.but88 Button $top all _vTclBalloon"
    bind $site_3_0.but88 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save As}
    }
    button $site_3_0.but23 \
        \
        -command {global BMPChange BMPImageOpen SourceWidth SourceHeight
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPColorBar ColorNumber 
global BMPMax BMPMin OpenDirFile MapAlgebraConfigFileProcess

#BMP PROCESS
global Load_Save 
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global PSPTopLevel TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {
  
if {$Load_Save == 0} {
    source "GUI/bmp_process/Save.tcl"
    set Load_Save 1
    WmTransient $widget(Toplevel82) $PSPTopLevel
    }

if { $BMPImageOpen == 1 } {
    if {$BMPChange == 1 } {
    #####################################################################
        set WarningMessage "BMP IMAGE HAS CHANGED"
        set WarningMessage2 "DO YOU WISH TO SAVE ?"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel82); TextEditorRunTrace "Open Window Save" "b"
            tkwait variable BMPChange
            if {$BMPChange == "0"} {Window hide $widget(Toplevel82); TextEditorRunTrace "Close Window Save" "b"}
            }
        if {"$VarWarning"=="no"} {set BMPChange "0"}
        if {"$VarWarning"=="cancel"} {set BMPChange "1"}
    ##################################################################### 
    }    
    if {$BMPChange == 0 } {
        #Colormap Window
        set BMPColorMapDisplay "0"
        set BMPColorMapGrayJetHsv "0"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}

        if {$Load_Save == 1} {Window hide $widget(Toplevel82)}
        if {$Load_Display == 1} {Window hide $widget(Toplevel71)}

        set SourceWidth ""
        set SourceHeight ""
        set BMPMax ""
        set BMPMin ""
        set BMPImageOpen "0"
        set BMPColorMapDisplay "0"
        set BMPScreenDisplay "0"
        if {$ColorNumber != "BMP 24 Bits"} {
            BMPColorBar blank
            $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
            }
        image delete BMPColorBar
        if {$MapAlgebraConfigFileProcess != ""} {
            set MapAlgebraConfigFileProcess [MapAlgebra_command $MapAlgebraConfigFileProcess "quit" ""]
            }
        set MapAlgebraConfigFileProcess ""
        DeleteFile $TMPBmpTmpHeader; DeleteFile $TMPBmp24TmpData; DeleteFile $TMPBmpTmpData
        DeleteFile $TMPBmpTmp; DeleteFile $TMPBmpTmpColormap
        }
}
}} \
        -image [vTcl:image:get_image [file join . GUI Images CloseFile.gif]] \
        -pady 0 -text {    } -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button545" vTcl:WidgetProc "Toplevel64p" 1
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
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel64p" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    label $site_4_0.cpd72 \
        -relief groove -text C -width 2 
    vTcl:DefineAlias "$site_4_0.cpd72" "Label269" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.cpd72 "$site_4_0.cpd72 Label $top all _vTclBalloon"
    bind $site_4_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Rows}
    }
    label $site_4_0.cpd77 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable SourceWidth -width 4 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label1" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.cpd77 "$site_4_0.cpd77 Label $top all _vTclBalloon"
    bind $site_4_0.cpd77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Columns}
    }
    label $site_4_0.cpd78 \
        -relief groove -text R -width 2 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label268" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.cpd78 "$site_4_0.cpd78 Label $top all _vTclBalloon"
    bind $site_4_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Number of Columns}
    }
    label $site_4_0.lab79 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable SourceHeight -width 4 
    vTcl:DefineAlias "$site_4_0.lab79" "Label2" vTcl:WidgetProc "Toplevel64p" 1
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
    TitleFrame $top.cpd90 \
        -ipad 2 -relief sunken -text Color 
    vTcl:DefineAlias "$top.cpd90" "TitleFrame4" vTcl:WidgetProc "Toplevel64p" 1
    bind $top.cpd90 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd90 getframe]
    button $site_4_0.but71 \
        \
        -command {global BMPImageOpen BMPColorMapDisplay BMPColorMapGrayJetHsv BMPColorMapRedGreenBlue ColorNumber ColorNumberUtil
global InitRedPalette RedPalette InitGreenPalette GreenPalette InitBluePalette BluePalette
global BMPView OpenDirFile
#BMP PROCESS
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256
global Load_ColorMapGrayJetHsv Load_ColorMapRedGreenBlue PSPTopLevel

if {$OpenDirFile == 0} {

if {$BMPImageOpen == 1} {
    if {"$ColorNumber" == "BMP 24 Bits"} {
        set ErrorMessage "NO CHANGE: BMP 24 Bits" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } else {
        set BMPColorMapDisplay "0"
        TextEditorRunTrace "Close All ColorMap Windows" "b"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        set BMPColorMapRedGreenBlue "0"
        if {$Load_ColorMapRedGreenBlue == 1} {Window hide $widget(Toplevel208a)}

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
                WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel208); TextEditorRunTrace "Open Window ColorMap Gray Jet Hsv" "b"
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
    vTcl:DefineAlias "$site_4_0.but71" "Button2" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.but71 "$site_4_0.but71 Button $top all _vTclBalloon"
    bind $site_4_0.but71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Change ColorMap}
    }
    button $site_4_0.cpd93 \
        \
        -command {global BMPImageOpen BMPColorMapDisplay ColorNumber ColorNumberUtilDisplay ColorMapBMP RedPalette GreenPalette BluePalette
global BMPView OpenDirFile BMPColorMapGrayJetHsv BMPColorMapRedGreenBlue
#BMP PROCESS
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256
global Load_ColorMapGrayJetHsv Load_ColorMapRedGreenBlue PSPTopLevel

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
        set BMPColorMapGrayJetHsv "0"
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
        set BMPColorMapRedGreenBlue "0"
        if {$Load_ColorMapRedGreenBlue == 1} {Window hide $widget(Toplevel208a)}
        
        if {$ColorNumberUtilDisplay == 256 } {
            if {$Load_colormap256 == 0} {
                source "GUI/bmp_process/colormap256.tcl"
                set Load_colormap256 1
                WmTransient $widget(Toplevel62) $PSPTopLevel
                }
            UpdateColorMap256
            set BMPColorMapDisplay "256"
            WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel62); TextEditorRunTrace "Open Window Colormap 256" "b"
            }
        if {$ColorNumberUtilDisplay == 32 } {
            if {$Load_colormap32 == 0} {
                source "GUI/bmp_process/colormap32.tcl"
                set Load_colormap32 1
                WmTransient $widget(Toplevel76) $PSPTopLevel
                }
            UpdateColorMap32
            set BMPColorMapDisplay "32"
            WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel76); TextEditorRunTrace "Open Window Colormap 32" "b"
            }
        if {$ColorNumberUtilDisplay == 16 } {
            if {$Load_colormap16 == 0} {
                source "GUI/bmp_process/colormap16.tcl"
                set Load_colormap16 1
                WmTransient $widget(Toplevel77) $PSPTopLevel
                }
            UpdateColorMap16
            set BMPColorMapDisplay "16"
            WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel77); TextEditorRunTrace "Open Window Colormap 16" "b"
            }
        if {$ColorNumberUtilDisplay == 8 } {
            if {$Load_colormap8 == 0} {
                source "GUI/bmp_process/colormap8.tcl"
                set Load_colormap8 1
                WmTransient $widget(Toplevel81) $PSPTopLevel
                }
            UpdateColorMap8
            set BMPColorMapDisplay "8"
            WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel81); TextEditorRunTrace "Open Window Colormap 8" "b"
            }
        }
    }
}
}} \
        -image [vTcl:image:get_image [file join . GUI Images color-rgb.gif]] \
        -pady 0 -text {    } -width 20 
    vTcl:DefineAlias "$site_4_0.cpd93" "Button548" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.cpd93 "$site_4_0.cpd93 Button $top all _vTclBalloon"
    bind $site_4_0.cpd93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    button $site_4_0.cpd66 \
        \
        -command {global BMPImageOpen BMPColorMapDisplay BMPColorMapGrayJetHsv BMPColorMapRedGreenBlue ColorNumber ColorNumberUtil
global InitRedPalette RedPalette InitGreenPalette GreenPalette InitBluePalette BluePalette
global BMPView OpenDirFile
#BMP PROCESS
global Load_colormap8 Load_colormap16 Load_colormap32 Load_colormap256
global Load_ColorMapGrayJetHsv Load_ColorMapRedGreenBlue PSPTopLevel

if {$OpenDirFile == 0} {

if {$BMPImageOpen == 1} {
    if {"$ColorNumber" == "BMP 24 Bits"} {
        set ErrorMessage "NO CHANGE: BMP 24 Bits" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } else {
        set BMPColorMapDisplay "0"
        TextEditorRunTrace "Close All ColorMap Windows" "b"
        if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
        if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
        if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
        if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
        set BMPColorMapGrayJetHsv "0"
        if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}

        if {$ColorNumberUtil >= 250 } {
            if {$BMPColorMapRedGreenBlue == 0} {
                set BMPColorMapRedGreenBlue 1
                if {$Load_ColorMapRedGreenBlue == 0} {
                    source "GUI/bmp_process/ColorMapRedGreenBlue.tcl"
                    set Load_ColorMapRedGreenBlue 1
                    WmTransient $widget(Toplevel208a) $PSPTopLevel
                    }
                for {set i 0} {$i <= 256} {incr i} {
                    set InitRedPalette($i) $RedPalette($i)
                    set InitGreenPalette($i) $GreenPalette($i)
                    set InitBluePalette($i) $BluePalette($i)
                    }
                WidgetShowFromWidget $widget(Toplevel64p) $widget(Toplevel208a); TextEditorRunTrace "Open Window ColorMap Red Green Blue" "b"
                } else {
                set BMPColorMapRedGreenBlue 0
                Window hide $widget(Toplevel208a); TextEditorRunTrace "Close Window ColorMap Red Green Blue" "b"
                }
            } else {
            set ErrorMessage "NOT A 256 COLORS BMP IMAGE" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images colormap2.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_4_0.cpd66" "Button3" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.cpd66 "$site_4_0.cpd66 Button $top all _vTclBalloon"
    bind $site_4_0.cpd66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Change ColorMap}
    }
    pack $site_4_0.but71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd95 \
        -ipad 2 -relief sunken -text Tools 
    vTcl:DefineAlias "$top.cpd95" "TitleFrame5" vTcl:WidgetProc "Toplevel64p" 1
    bind $top.cpd95 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd95 getframe]
    button $site_4_0.cpd96 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect BMPMax BMPMin
global Fonction Fonction2 OpenDirFile MapAlgebraConfigFileProcess
package require Img

#BMP PROCESS
global Load_Save
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    set BMPChange "1"

    #Colormap Window
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    
    DeleteFile $TMPBmpTmp
    set Fonction "IMAGE PROCESSING"
    set Fonction2 "ROTATION FLIP LEFT-RIGHT"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    if {"$ColorNumber" != "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/bmp_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op fliplr -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" "k"
        set f [ open "| Soft/bin/bmp_process/bmp_processing.exe -op fliplr -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" r]
        }
    if {"$ColorNumber" == "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/bmp24_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op fliplr -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" "k"
        set f [ open "| Soft/bin/bmp_process/bmp24_processing.exe -op fliplr -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    WaitUntilCreated $TMPBmpTmp
    
    set MapAlgebraConfigFileProcess [MapAlgebra_command $MapAlgebraConfigFileProcess "quit" ""]
    set MapAlgebraConfigFileProcess ""

    load_bmp_caracteristics $TMPBmpTmp
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    MapAlgebra_load_bmp_file $TMPBmpTmp "process"  
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images img-xflip.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd96" "Button661" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.cpd96 "$site_4_0.cpd96 Button $top all _vTclBalloon"
    bind $site_4_0.cpd96 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Mirror}
    }
    button $site_4_0.cpd97 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect BMPMax BMPMin
global Fonction Fonction2 OpenDirFile MapAlgebraConfigFileProcess
package require Img

#BMP PROCESS
global Load_Save
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    set BMPChange "1"

    #Colormap Window
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    
    DeleteFile $TMPBmpTmp
    set Fonction "IMAGE PROCESSING"
    set Fonction2 "ROTATION FLIP UP-DOWN"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    if {"$ColorNumber" != "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/bmp_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op flipud -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" "k"
        set f [ open "| Soft/bin/bmp_process/bmp_processing.exe -op flipud -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" r]
        }
    if {"$ColorNumber" == "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/bmp24_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op flipud -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" "k"
        set f [ open "| Soft/bin/bmp_process/bmp24_processing.exe -op flipud -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    WaitUntilCreated $TMPBmpTmp

    set MapAlgebraConfigFileProcess [MapAlgebra_command $MapAlgebraConfigFileProcess "quit" ""]
    set MapAlgebraConfigFileProcess ""

    load_bmp_caracteristics $TMPBmpTmp
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    MapAlgebra_load_bmp_file $TMPBmpTmp "process"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images img-yflip.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd97" "Button662" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.cpd97 "$site_4_0.cpd97 Button $top all _vTclBalloon"
    bind $site_4_0.cpd97 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Flip}
    }
    button $site_4_0.cpd98 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect BMPMax BMPMin
global Fonction Fonction2 OpenDirFile MapAlgebraConfigFileProcess
package require Img

#BMP PROCESS
global Load_Save
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    set BMPChange "1"

    #Colormap Window
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    
    DeleteFile $TMPBmpTmp
    set Fonction "IMAGE PROCESSING"
    set Fonction2 "ROTATION 90deg LEFT"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    if {"$ColorNumber" != "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/bmp_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op rot270 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" "k"
        set f [ open "| Soft/bin/bmp_process/bmp_processing.exe -op rot270 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" r]
        }
    if {"$ColorNumber" == "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/bmp24_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op rot270 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" "k"
        set f [ open "| Soft/bin/bmp_process/bmp24_processing.exe -op rot270 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    WaitUntilCreated $TMPBmpTmp

    set MapAlgebraConfigFileProcess [MapAlgebra_command $MapAlgebraConfigFileProcess "quit" ""]
    set MapAlgebraConfigFileProcess ""
    
    load_bmp_caracteristics $TMPBmpTmp
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    MapAlgebra_load_bmp_file $TMPBmpTmp "process"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images img-lrotat.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd98" "Button663" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_4_0.cpd98 "$site_4_0.cpd98 Button $top all _vTclBalloon"
    bind $site_4_0.cpd98 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Rotate +90}
    }
    button $site_4_0.cpd99 \
        \
        -command {global DataDir FileName BMPChange BMPImageOpen BMPDirInput BMPViewFileInput SourceWidth SourceHeight
global ColorNumber ColorNumberUtil ColorMapBMP RedPalette GreenPalette BluePalette
global BMPColorMapDisplay BMPColorMapGrayJetHsv BMPTrainingRect BMPMax BMPMin
global Fonction Fonction2 OpenDirFile MapAlgebraConfigFileProcess
package require Img

#BMP PROCESS
global Load_Save
global Load_colormap256 Load_colormap32 Load_colormap16 Load_colormap8
global TMPBmpTmpHeader TMPBmp24TmpData TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap

if {$OpenDirFile == 0} {

if { $BMPImageOpen == 1 } {
    set BMPChange "1"

    #Colormap Window
    set BMPColorMapDisplay "0"
    set BMPColorMapGrayJetHsv "0"
    if {$Load_colormap256 == 1} {Window hide $widget(Toplevel62)}
    if {$Load_colormap32 == 1} {Window hide $widget(Toplevel76)}
    if {$Load_colormap16 == 1} {Window hide $widget(Toplevel77)}
    if {$Load_colormap8 == 1} {Window hide $widget(Toplevel81)}
    if {$Load_ColorMapGrayJetHsv == 1} {Window hide $widget(Toplevel208)}
    
    DeleteFile $TMPBmpTmp
    set Fonction "IMAGE PROCESSING"
    set Fonction2 "ROTATION 90deg RIGHT"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    if {"$ColorNumber" != "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/bmp_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op rot90 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" "k"
        set f [ open "| Soft/bin/bmp_process/bmp_processing.exe -op rot90 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -of \x22$TMPBmpTmp\x22 -ifc \x22$TMPBmpTmpColormap\x22" r]
        }
    if {"$ColorNumber" == "BMP 24 Bits"} {
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/bmp24_processing.exe" "k"
        TextEditorRunTrace "Arguments: -op rot90 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" "k"
        set f [ open "| Soft/bin/bmp_process/bmp24_processing.exe -op rot90 -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmp24TmpData\x22 -of \x22$TMPBmpTmp\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    WaitUntilCreated $TMPBmpTmp

    set MapAlgebraConfigFileProcess [MapAlgebra_command $MapAlgebraConfigFileProcess "quit" ""]
    set MapAlgebraConfigFileProcess ""
    
    load_bmp_caracteristics $TMPBmpTmp
    if {$ColorNumber != "BMP 24 Bits"} {$widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar}
    MapAlgebra_load_bmp_file $TMPBmpTmp "process"
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images img-rrotat.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd99" "Button664p" vTcl:WidgetProc "Toplevel64p" 1
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
    vTcl:DefineAlias "$top.cpd104" "TitleFrame6" vTcl:WidgetProc "Toplevel64p" 1
    bind $top.cpd104 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd104 getframe]
    canvas $site_4_0.cpd105 \
        -borderwidth 2 -closeenough 1.0 -height 12 -relief ridge \
        -takefocus {} -width 120 
    vTcl:DefineAlias "$site_4_0.cpd105" "CANVASCOLORBAR" vTcl:WidgetProc "Toplevel64p" 1
    frame $site_4_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame1" vTcl:WidgetProc "Toplevel64p" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.cpd73 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable BMPMin -width 6 
    vTcl:DefineAlias "$site_5_0.cpd73" "Label5" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Label $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Coded Min Value}
    }
    label $site_5_0.cpd75 \
        -background #ffffff -foreground #0000ff -relief sunken \
        -textvariable BMPMax -width 6 
    vTcl:DefineAlias "$site_5_0.cpd75" "Label9" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_5_0.cpd75 "$site_5_0.cpd75 Label $top all _vTclBalloon"
    bind $site_5_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Coded Max Value}
    }
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd105 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra32 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra32" "Frame390" vTcl:WidgetProc "Toplevel64p" 1
    set site_3_0 $top.fra32
    button $site_3_0.but30 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolSARpro_Viewer_Process.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but30" "Button15" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_3_0.but30 "$site_3_0.but30 Button $top all _vTclBalloon"
    bind $site_3_0.but30 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but34 \
        -background #ffff00 \
        -command {global PVMainMenu PVProcessShortcut BMPImageOpen OpenDirFile

if {$OpenDirFile == 0} {

set PVProcessShortcut 0
ClosePSPViewerProcess

if {$BMPImageOpen == 0} {
    Window hide $widget(Toplevel64p); TextEditorRunTrace "Close Window PolSARpro Viewer - Process" "b"
    if {$PVMainMenu == 1} {
        set PVMainMenu 0
        Window show $widget(Toplevel2)
        }
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but34" "Button67" vTcl:WidgetProc "Toplevel64p" 1
    bindtags $site_3_0.but34 "$site_3_0.but34 Button $top all _vTclBalloon"
    bind $site_3_0.but34 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
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
Window show .top64p

main $argc $argv
