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

        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapGray.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapGrayRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapJet.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapJetInv.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapJetRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapJetRevInv.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapHsv.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapHsvInv.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapHsvRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapHsvRevInv.gif]} {user image} user {}}

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
    set base .top208
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd74 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd81
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd83
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd75 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd80
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra51 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra51
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top208
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
    wm geometry $top 200x200+66+66; update
    wm maxsize $top 1604 1185
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

proc vTclWindow.top208 {base} {
    if {$base == ""} {
        set base .top208
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
    wm geometry $top 150x180+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Color Map"
    vTcl:DefineAlias "$top" "Toplevel208" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd74 \
        -ipad 0 -text {Jet ColorMap} 
    vTcl:DefineAlias "$top.cpd74" "TitleFrame7" vTcl:WidgetProc "Toplevel208" 1
    bind $top.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd74 getframe]
    frame $site_4_0.cpd81
    set site_5_0 $site_4_0.cpd81
    button $site_5_0.cpd72 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapJET.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapJET.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapJet.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button44" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Jet}
    }
    button $site_5_0.cpd73 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapJETinv.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapJETinv.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapJetInv.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button45" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Jet Inverse}
    }
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side right 
    frame $site_4_0.cpd82
    set site_5_0 $site_4_0.cpd82
    button $site_5_0.cpd72 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapJETrev.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapJETrev.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapJetRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button46" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Jet Reverse}
    }
    button $site_5_0.cpd73 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapJETrevinv.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapJETrevinv.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapJetRevInv.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button47" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Jet Reverse Inverse}
    }
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side right 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd71 \
        -ipad 0 -text {Gray ColorMap} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame6" vTcl:WidgetProc "Toplevel208" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    frame $site_4_0.cpd83
    set site_5_0 $site_4_0.cpd83
    button $site_5_0.cpd72 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapGRAY.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapGRAY.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapGray.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button48" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Gray}
    }
    button $site_5_0.cpd73 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapGRAYrev.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapGRAYrev.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapGrayRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button49" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Gray Reverse}
    }
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side right 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd75 \
        -ipad 0 -text {Hsv ColorMap} 
    vTcl:DefineAlias "$top.cpd75" "TitleFrame8" vTcl:WidgetProc "Toplevel208" 1
    bind $top.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd75 getframe]
    frame $site_4_0.cpd78
    set site_5_0 $site_4_0.cpd78
    button $site_5_0.cpd72 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapHSV.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapHSV.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapHsv.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button40" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Hsv}
    }
    button $site_5_0.cpd73 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapHSVinv.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapHSVinv.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapHsvInv.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button41" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Hsv Inverse}
    }
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side right 
    frame $site_4_0.cpd80
    set site_5_0 $site_4_0.cpd80
    button $site_5_0.cpd72 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapHSVrev.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapHSVrev.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapHsvRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd72" "Button42" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd72 "$site_5_0.cpd72 Button $top all _vTclBalloon"
    bind $site_5_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Hsv Reverse}
    }
    button $site_5_0.cpd73 \
        \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists "$CONFIGDir/ColorMapHSVrevinv.pal"] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open "$CONFIGDir/ColorMapHSVrevinv.pal" r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 1} {$i <= 256} {incr i} {
        gets $f newcouleur
        set RedPalette($i) [lindex $newcouleur 0]
        set GreenPalette($i) [lindex $newcouleur 1]
        set BluePalette($i) [lindex $newcouleur 2]
        }
    close $f
    set BMPChange "1"
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$RedPalette($i) $GreenPalette($i) $BluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
        
    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapHsvRevInv.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button43" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_5_0.cpd73 "$site_5_0.cpd73 Button $top all _vTclBalloon"
    bind $site_5_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Hsv Reverse Inverse}
    }
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side right 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra51 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra51" "Frame20" vTcl:WidgetProc "Toplevel208" 1
    set site_3_0 $top.fra51
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ColorMapOut RedPalette GreenPalette BluePalette
global ColorMapOut InitRedPalette InitGreenPalette InitBluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

    set BMPChange "1"

    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) $InitRedPalette($i)
        set GreenPalette($i) $InitGreenPalette($i)
        set BluePalette($i) $InitBluePalette($i)
        }
        
    set f [ open $TMPBmpTmpColormap w]
    puts $f "JASC-PAL"
    puts $f "0100"
    puts $f "256"
    for {set i 1} {$i <= 256} {incr i} {
        set couleur "$InitRedPalette($i) $InitGreenPalette($i) $InitBluePalette($i)"
        puts $f $couleur
        }
    close $f
    set f [ open "| Soft/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f

    image delete ImageSource
    image create photo ImageSource -file $TMPBmpTmp

    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    $widget(CANVASCOLORBAR) create image 0 0 -anchor nw -image BMPColorBar
        
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
        }
    if {$Den < $Num} {
        set BMPZoom $Num
        set Xmax [expr round($BMPWidth / $BMPZoom)]
        set Ymax [expr round($BMPHeight / $BMPZoom)]
        BMPImage copy ImageSource -from 0 0 $Xmax $Ymax -zoom $BMPZoom $BMPZoom
        }        
    $widget($BMPCanvas) itemconfigure current -image BMPImage} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ColorMapGrayJetHsv.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel208" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global BMPColorMapGrayJetHsv

set BMPColorMapGrayJetHsv 0
Window hide $widget(Toplevel208); TextEditorRunTrace "Close Window ColorMap Gray Jet Hsv" "b"} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel208" 1
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
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra51 \
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
Window show .top208

main $argc $argv
