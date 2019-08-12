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

        {{[file join . GUI Images ColorMap_Autumn.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Blue.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_BlueLight.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Bone.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Brown.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Cool.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Gray.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Green.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_GreenLight.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Magenta.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Ocean.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Orange.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Purple.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Red.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Spring.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Summer.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Winter.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_Yellow.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_AutumnRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_BlueRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_BlueLightRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_BoneRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_BrownRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_CoolRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_GrayRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_GreenRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_GreenLightRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_MagentaRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_OceanRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_OrangeRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_PurpleRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_RedRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_SpringRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_SummerRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_WinterRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMap_YellowRev.gif]} {user image} user {}}

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
    set base .top208a
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra67 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.fra68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra68
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra51 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra51
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
            vTclWindow.top208a
            ColorMapRedGreenBlueProcess
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
## Procedure:  ColorMapRedGreenBlueProcess

proc ::ColorMapRedGreenBlueProcess {ColorMapRGB ColorMapInv} {
global ColorMapOut RedPalette GreenPalette BluePalette
global BMPChange BMPImageOpen BMPDropperFlag BMPColorMapDisplay ColorNumber ColorNumberUtil
global ImageSource BMPImage BMPCanvas BMPWidth BMPHeight ZoomBMP CONFIGDir
global BMPImageLens SourceWidth SourceHeight BMPSampleSource BMPColorBar MapAlgebraConfigFileProcess
global TMPBmpTmpHeader TMPBmpTmpData TMPBmpTmp TMPBmpTmpColormap TMPBmpColorBar

#read colormap
if [file exists $ColorMapRGB] {
    for {set i 0} {$i <= 256} {incr i} {
        set RedPalette($i) 1
        set GreenPalette($i) 1
        set BluePalette($i) 1
        }
    set f [open $ColorMapRGB r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    if {$ColorMapInv == 0} {
        for {set i 1} {$i <= 256} {incr i} {
            gets $f newcouleur
            set RedPalette($i) [lindex $newcouleur 0]
            set GreenPalette($i) [lindex $newcouleur 1]
            set BluePalette($i) [lindex $newcouleur 2]
            }
        } else {
        for {set i 1} {$i <= 256} {incr i} {
            gets $f newcouleur
            set ii [expr 257 - $i]
            set RedPalette($ii) [lindex $newcouleur 0]
            set GreenPalette($ii) [lindex $newcouleur 1]
            set BluePalette($ii) [lindex $newcouleur 2]
            }
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

    DeleteFile $TMPBmpTmp
    set Fonction "IMAGE PROCESSING"
    set Fonction2 "CHANGE COLORMAP"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    set f [ open "| Soft/bin/bmp_process/recreate_bmp.exe -ifh \x22$TMPBmpTmpHeader\x22 -ifd \x22$TMPBmpTmpData\x22 -oft \x22$TMPBmpTmp\x22 -ifcm \x22$TMPBmpTmpColormap\x22 -ofcb \x22$TMPBmpColorBar\x22" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    WaitUntilCreated $TMPBmpTmp

    set MapAlgebraConfigFileProcess [MapAlgebra_command $MapAlgebraConfigFileProcess "quit" ""]
    set MapAlgebraConfigFileProcess ""

    load_bmp_caracteristics $TMPBmpTmp
    image delete BMPColorBar
    image create photo BMPColorBar -file $TMPBmpColorBar
    .top64p.cpd104.f.cpd105 create image 0 0 -anchor nw -image BMPColorBar
    MapAlgebra_load_bmp_file $TMPBmpTmp "process"
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
    wm geometry $top 200x200+125+125; update
    wm maxsize $top 3364 1032
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

proc vTclWindow.top208a {base} {
    if {$base == ""} {
        set base .top208a
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
    wm geometry $top 150x370+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Color Map"
    vTcl:DefineAlias "$top" "Toplevel208a" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame1" vTcl:WidgetProc "Toplevel208a" 1
    set site_3_0 $top.fra67
    frame $site_3_0.fra68 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra68" "Frame2" vTcl:WidgetProc "Toplevel208a" 1
    set site_4_0 $site_3_0.fra68
    button $site_4_0.cpd70 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_AUTUMN.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Autumn.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd70" "Button50" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd70 "$site_4_0.cpd70 Button $top all _vTclBalloon"
    bind $site_4_0.cpd70 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Autumn}
    }
    button $site_4_0.cpd71 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_BLUE.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Blue.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd71" "Button51" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd71 "$site_4_0.cpd71 Button $top all _vTclBalloon"
    bind $site_4_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Blue}
    }
    button $site_4_0.cpd73 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_BLUELIGHT.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_BlueLight.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd73" "Button53" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd73 "$site_4_0.cpd73 Button $top all _vTclBalloon"
    bind $site_4_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Blue Light}
    }
    button $site_4_0.cpd74 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_BONE.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Bone.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd74" "Button54" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd74 "$site_4_0.cpd74 Button $top all _vTclBalloon"
    bind $site_4_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Bone}
    }
    button $site_4_0.cpd75 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_BROWN.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Brown.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd75" "Button55" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd75 "$site_4_0.cpd75 Button $top all _vTclBalloon"
    bind $site_4_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Brown}
    }
    button $site_4_0.cpd76 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_COOL.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Cool.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd76" "Button56" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd76 "$site_4_0.cpd76 Button $top all _vTclBalloon"
    bind $site_4_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cool}
    }
    button $site_4_0.cpd72 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMapGRAY.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Gray.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd72" "Button52" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd72 "$site_4_0.cpd72 Button $top all _vTclBalloon"
    bind $site_4_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Gray}
    }
    button $site_4_0.cpd77 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_GREEN.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Green.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd77" "Button57" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd77 "$site_4_0.cpd77 Button $top all _vTclBalloon"
    bind $site_4_0.cpd77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Green}
    }
    button $site_4_0.cpd78 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_GREENLIGHT.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_GreenLight.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd78" "Button58" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd78 "$site_4_0.cpd78 Button $top all _vTclBalloon"
    bind $site_4_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Green Light}
    }
    button $site_4_0.cpd79 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_MAGENTA.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Magenta.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd79" "Button59" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Button $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Magenta}
    }
    button $site_4_0.cpd80 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_OCEAN.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Ocean.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd80" "Button60" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd80 "$site_4_0.cpd80 Button $top all _vTclBalloon"
    bind $site_4_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Ocean}
    }
    button $site_4_0.cpd81 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_ORANGE.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Orange.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd81" "Button61" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd81 "$site_4_0.cpd81 Button $top all _vTclBalloon"
    bind $site_4_0.cpd81 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Orange}
    }
    button $site_4_0.cpd82 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_PURPLE.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Purple.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd82" "Button62" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd82 "$site_4_0.cpd82 Button $top all _vTclBalloon"
    bind $site_4_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Purple}
    }
    button $site_4_0.cpd83 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_RED.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Red.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd83" "Button63" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd83 "$site_4_0.cpd83 Button $top all _vTclBalloon"
    bind $site_4_0.cpd83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Red}
    }
    button $site_4_0.cpd84 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_SPRING.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Spring.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd84" "Button64" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd84 "$site_4_0.cpd84 Button $top all _vTclBalloon"
    bind $site_4_0.cpd84 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Spring}
    }
    button $site_4_0.cpd85 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_SUMMER.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Summer.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd85" "Button65" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd85 "$site_4_0.cpd85 Button $top all _vTclBalloon"
    bind $site_4_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Summer}
    }
    button $site_4_0.cpd86 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_WINTER.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Winter.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd86" "Button66" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd86 "$site_4_0.cpd86 Button $top all _vTclBalloon"
    bind $site_4_0.cpd86 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Winter}
    }
    button $site_4_0.cpd87 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_YELLOW.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 0
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Yellow.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd87" "Button67" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd87 "$site_4_0.cpd87 Button $top all _vTclBalloon"
    bind $site_4_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Yellow}
    }
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.cpd66 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame3" vTcl:WidgetProc "Toplevel208a" 1
    set site_4_0 $site_3_0.cpd66
    button $site_4_0.cpd70 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_AUTUMN.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_AutumnRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd70" "Button68" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd70 "$site_4_0.cpd70 Button $top all _vTclBalloon"
    bind $site_4_0.cpd70 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Autumn}
    }
    button $site_4_0.cpd71 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_BLUE.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_BlueRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd71" "Button69" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd71 "$site_4_0.cpd71 Button $top all _vTclBalloon"
    bind $site_4_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Blue}
    }
    button $site_4_0.cpd73 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_BLUELIGHT.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_BlueLightRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd73" "Button70" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd73 "$site_4_0.cpd73 Button $top all _vTclBalloon"
    bind $site_4_0.cpd73 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Blue Light}
    }
    button $site_4_0.cpd74 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_BONE.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_BoneRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd74" "Button71" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd74 "$site_4_0.cpd74 Button $top all _vTclBalloon"
    bind $site_4_0.cpd74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Bone}
    }
    button $site_4_0.cpd75 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_BROWN.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_BrownRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd75" "Button72" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd75 "$site_4_0.cpd75 Button $top all _vTclBalloon"
    bind $site_4_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Brown}
    }
    button $site_4_0.cpd76 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_COOL.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_CoolRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd76" "Button73" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd76 "$site_4_0.cpd76 Button $top all _vTclBalloon"
    bind $site_4_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cool}
    }
    button $site_4_0.cpd72 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMapGRAY.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_GrayRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd72" "Button74" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd72 "$site_4_0.cpd72 Button $top all _vTclBalloon"
    bind $site_4_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Gray}
    }
    button $site_4_0.cpd77 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_GREEN.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_GreenRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd77" "Button75" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd77 "$site_4_0.cpd77 Button $top all _vTclBalloon"
    bind $site_4_0.cpd77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Green}
    }
    button $site_4_0.cpd78 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_GREENLIGHT.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_GreenLightRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd78" "Button76" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd78 "$site_4_0.cpd78 Button $top all _vTclBalloon"
    bind $site_4_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Green Light}
    }
    button $site_4_0.cpd79 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_MAGENTA.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_MagentaRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd79" "Button77" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd79 "$site_4_0.cpd79 Button $top all _vTclBalloon"
    bind $site_4_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Magenta}
    }
    button $site_4_0.cpd80 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_OCEAN.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_OceanRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd80" "Button78" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd80 "$site_4_0.cpd80 Button $top all _vTclBalloon"
    bind $site_4_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Ocean}
    }
    button $site_4_0.cpd81 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_ORANGE.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_OrangeRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd81" "Button79" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd81 "$site_4_0.cpd81 Button $top all _vTclBalloon"
    bind $site_4_0.cpd81 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Orange}
    }
    button $site_4_0.cpd82 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_PURPLE.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_PurpleRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd82" "Button80" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd82 "$site_4_0.cpd82 Button $top all _vTclBalloon"
    bind $site_4_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Purple}
    }
    button $site_4_0.cpd83 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_RED.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_RedRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd83" "Button81" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd83 "$site_4_0.cpd83 Button $top all _vTclBalloon"
    bind $site_4_0.cpd83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Red}
    }
    button $site_4_0.cpd84 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_SPRING.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_SpringRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd84" "Button82" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd84 "$site_4_0.cpd84 Button $top all _vTclBalloon"
    bind $site_4_0.cpd84 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Spring}
    }
    button $site_4_0.cpd85 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_SUMMER.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_SummerRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd85" "Button83" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd85 "$site_4_0.cpd85 Button $top all _vTclBalloon"
    bind $site_4_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Summer}
    }
    button $site_4_0.cpd86 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_WINTER.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_WinterRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd86" "Button84" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd86 "$site_4_0.cpd86 Button $top all _vTclBalloon"
    bind $site_4_0.cpd86 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Winter}
    }
    button $site_4_0.cpd87 \
        \
        -command {#read colormap
set colormapfile "$CONFIGDir/ColorMap_YELLOW.pal"
if [file exists $colormapfile] {
    ColorMapRedGreenBlueProcess $colormapfile 1
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_YellowRev.gif]] \
        -padx 1 -pady 0 -relief groove -text {    } 
    vTcl:DefineAlias "$site_4_0.cpd87" "Button85" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_4_0.cpd87 "$site_4_0.cpd87 Button $top all _vTclBalloon"
    bind $site_4_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Yellow}
    }
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.fra68 \
        -in $site_3_0 -anchor center -expand 0 -fill y -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side top 
    frame $top.fra51 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra51" "Frame20" vTcl:WidgetProc "Toplevel208a" 1
    set site_3_0 $top.fra51
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global BMPColorMapRedGreenBlue

set BMPColorMapRedGreenBlue 0
Window hide $widget(Toplevel208a); TextEditorRunTrace "Close Window ColorMap Red Green Blue" "b"} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel208a" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra67 \
        -in $top -anchor center -expand 0 -fill both -side top 
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
Window show .top208a

main $argc $argv
