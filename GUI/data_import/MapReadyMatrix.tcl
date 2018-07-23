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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}

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
    set base .top381
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd67
    namespace eval ::widgets::$site_6_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra70
    namespace eval ::widgets::$site_3_0.fra74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra74
    namespace eval ::widgets::$site_4_0.fra78 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra78
    namespace eval ::widgets::$site_5_0.che79 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.ent80 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra75
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.tit72 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_5_0 [$site_3_0.tit72 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top381
            MapReadyFlipUpDown
            MapReadyMatrixALOS_C2
            MapReadyMatrixALOS_T3
            MapReadyMatrixRS2_C2
            MapReadyMatrixRS2_T3
            MapReadyMatrixTSX_C2
            MapReadyMatrixTSX_T3
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
## Procedure:  MapReadyFlipUpDown

proc ::MapReadyFlipUpDown {} {
}
#############################################################################
## Procedure:  MapReadyMatrixALOS_C2

proc ::MapReadyMatrixALOS_C2 {} {
global MapReadyOutputDir MapReadyDirOutput TMPDir PSPMemory TMPMemoryAllocError 
global MapReadyFileHdr MapReadySensor MapInfoActive MapInfoMapInfo MapInfoUnit
global ConfigFile ErrorMessage PolarCase PolarType NligFullSize NcolFullSize 
global TMPMapReadyMatrixStatusStatus PSPViewGimpBMP

        MapReadyDelete
        MapReadyMatrix
        MapReady "matrix"

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/mapready_batchcontrol.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPMapReadyMatrixStatusStatus\x22" "k"
        set f [ open "| Soft/tools/mapready_batchcontrol.exe -if \x22$TMPMapReadyMatrixStatusStatus\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set MapReadyDirOutput $MapReadyOutputDir 
        append MapReadyDirOutput "/C2"
        set MapReadyFileHdr "$MapReadyDirOutput/C22.bin.hdr"
        TextEditorRunTrace "Process The Function Soft/tools/mapinfo_config_file.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" "k"
        set f [ open "| Soft/tools/mapinfo_config_file.exe -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" r]
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set MapInfoConfigFile "$MapReadyDirOutput/config_mapinfo.txt" 
        WaitUntilCreated $MapInfoConfigFile
           
        set ConfigFile "$MapReadyDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            EnviWriteConfigC $MapReadyDirOutput $NligFullSize $NcolFullSize
     
            set DataDir $MapReadyOutputDir

            set RGBDirInput $MapReadyDirOutput
            set RGBDirOutput $MapReadyDirOutput
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set config "true"
            set fichier "$RGBDirInput/C11.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C11.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/C22.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C22.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/C12_real.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C12_real.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if {"$config"=="true"} {
                set MaskPolFormat "C2"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" "k"
                set f [ open "| Soft/tools/create_mask_valid_pixels.exe -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] { EnviWriteConfig $MaskFile $NligFullSize $NcolFullSize 4 } 

                set MaskCmd ""
                set MaskDir $RGBDirInput
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
                set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }

            }
}
#############################################################################
## Procedure:  MapReadyMatrixALOS_T3

proc ::MapReadyMatrixALOS_T3 {} {
global MapReadyOutputDir MapReadyDirOutput TMPDir PSPMemory TMPMemoryAllocError 
global MapReadyFileHdr MapReadySensor MapInfoActive MapInfoMapInfo MapInfoUnit
global ConfigFile ErrorMessage  NligFullSize NcolFullSize PolarType
global TMPMapReadyMatrixStatusStatus PSPViewGimpBMP

        MapReadyDelete
        MapReadyMatrix
        MapReady "matrix"

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/mapready_batchcontrol.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPMapReadyMatrixStatusStatus\x22" "k"
        set f [ open "| Soft/tools/mapready_batchcontrol.exe -if \x22$TMPMapReadyMatrixStatusStatus\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set MapReadyDirOutput $MapReadyOutputDir 
        append MapReadyDirOutput "/T3"
        set MapReadyFileHdr "$MapReadyDirOutput/T33.bin.hdr"
        TextEditorRunTrace "Process The Function Soft/tools/mapinfo_config_file.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" "k"
        set f [ open "| Soft/tools/mapinfo_config_file.exe -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" r]
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set MapInfoConfigFile "$MapReadyDirOutput/config_mapinfo.txt" 
        WaitUntilCreated $MapInfoConfigFile
           
        set ConfigFile "$MapReadyDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            EnviWriteConfigT $MapReadyDirOutput $NligFullSize $NcolFullSize

            set DataDir $MapReadyOutputDir

            set RGBDirInput $MapReadyDirOutput
            set RGBDirOutput $MapReadyDirOutput
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set config "true"
            set fichier "$RGBDirInput/T11.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE T11.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/T22.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE T22.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/T33.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE T33.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if {"$config"=="true"} {
                set MaskPolFormat "T3"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" "k"
                set f [ open "| Soft/tools/create_mask_valid_pixels.exe -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] { EnviWriteConfig $MaskFile $NligFullSize $NcolFullSize 4 }

                set MaskCmd ""
                set MaskDir $RGBDirInput
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
                set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }

            }
}
#############################################################################
## Procedure:  MapReadyMatrixRS2_C2

proc ::MapReadyMatrixRS2_C2 {} {
global MapReadyDirInput MapReadyOutputDir MapReadyDirOutput TMPDirSession TMPDir PSPMemory TMPMemoryAllocError 
global MapReadyFileHdr MapReadySensor MapInfoActive MapInfoMapInfo MapInfoUnit
global ConfigFile ErrorMessage PolarCase PolarType NligFullSize NcolFullSize
global TMPMapReadyMatrixStatusStatus PSPViewGimpBMP

        MapReadyDelete
        MapReadyMatrix
        MapReady "matrix"

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/mapready_batchcontrol.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPMapReadyMatrixStatusStatus\x22" "k"
        set f [ open "| Soft/tools/mapready_batchcontrol.exe -if \x22$TMPMapReadyMatrixStatusStatus\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set MapReadyDirOutput $MapReadyOutputDir 
        append MapReadyDirOutput "/C2"
        set MapReadyFileHdr "$MapReadyDirOutput/C22.bin.hdr"
        TextEditorRunTrace "Process The Function Soft/tools/mapinfo_config_file.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" "k"
        set f [ open "| Soft/tools/mapinfo_config_file.exe -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" r]
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set MapInfoConfigFile "$MapReadyDirOutput/config_mapinfo.txt" 
        WaitUntilCreated $MapInfoConfigFile
           
        set ConfigFile "$MapReadyDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            EnviWriteConfigC $MapReadyDirOutput $NligFullSize $NcolFullSize
   
            set DataDir $MapReadyOutputDir
    
            set RGBDirInput $MapReadyDirOutput
            set RGBDirOutput $MapReadyDirOutput
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set config "true"
            set fichier "$RGBDirInput/C11.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C11.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/C22.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C22.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/C12_real.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C12_real.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if {"$config"=="true"} {
                set MaskPolFormat "C2"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" "k"
                set f [ open "| Soft/tools/create_mask_valid_pixels.exe -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] { EnviWriteConfig $MaskFile $NligFullSize $NcolFullSize 4 } 

                set MaskCmd ""
                set MaskDir $RGBDirInput
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
                set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }
            }
}
#############################################################################
## Procedure:  MapReadyMatrixRS2_T3

proc ::MapReadyMatrixRS2_T3 {} {
global MapReadyDirInput MapReadyOutputDir MapReadyDirOutput TMPDirSession TMPDir PSPMemory TMPMemoryAllocError 
global MapReadyFileHdr MapReadySensor MapInfoActive MapInfoMapInfo MapInfoUnit
global ConfigFile ErrorMessage NligFullSize NcolFullSize PolarType
global TMPMapReadyMatrixStatusStatus PSPViewGimpBMP

        MapReadyDelete
        MapReadyMatrix
        MapReady "matrix"

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/mapready_batchcontrol.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPMapReadyMatrixStatusStatus\x22" "k"
        set f [ open "| Soft/tools/mapready_batchcontrol.exe -if \x22$TMPMapReadyMatrixStatusStatus\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set MapReadyDirOutput $MapReadyOutputDir 
        append MapReadyDirOutput "/T3"
        set MapReadyFileHdr "$MapReadyDirOutput/T33.bin.hdr"
        TextEditorRunTrace "Process The Function Soft/tools/mapinfo_config_file.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" "k"
        set f [ open "| Soft/tools/mapinfo_config_file.exe -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" r]
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set MapInfoConfigFile "$MapReadyDirOutput/config_mapinfo.txt" 
        WaitUntilCreated $MapInfoConfigFile
           
        set ConfigFile "$MapReadyDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            EnviWriteConfigT $MapReadyDirOutput $NligFullSize $NcolFullSize
     
            set DataDir $MapReadyOutputDir
    
            set RGBDirInput $MapReadyDirOutput
            set RGBDirOutput $MapReadyDirOutput
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set config "true"
            set fichier "$RGBDirInput/T11.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE T11.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/T22.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE T22.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/T33.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE T33.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if {"$config"=="true"} {
                set MaskPolFormat "T3"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" "k"
                set f [ open "| Soft/tools/create_mask_valid_pixels.exe -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] { EnviWriteConfig $MaskFile $NligFullSize $NcolFullSize 4 }

                set MaskCmd ""
                set MaskDir $RGBDirInput
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
                set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf T3 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }
            }
}
#############################################################################
## Procedure:  MapReadyMatrixTSX_C2

proc ::MapReadyMatrixTSX_C2 {} {
global MapReadyDirInput MapReadyOutputDir MapReadyDirOutput TMPDirSession TMPDir PSPMemory TMPMemoryAllocError 
global MapReadyFileHdr MapReadySensor MapInfoActive MapInfoMapInfo MapInfoUnit
global ConfigFile ErrorMessage PolarCase PolarType NligFullSize NcolFullSize
global TMPMapReadyMatrixStatusStatus PSPViewGimpBMP

        MapReadyDelete
        MapReadyMatrix
        MapReady "matrix"

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/mapready_batchcontrol.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$TMPMapReadyMatrixStatusStatus\x22" "k"
        set f [ open "| Soft/tools/mapready_batchcontrol.exe -if \x22$TMPMapReadyMatrixStatusStatus\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set MapReadyDirOutput $MapReadyOutputDir 
        append MapReadyDirOutput "/C2"
        set MapReadyFileHdr "$MapReadyDirOutput/C22.bin.hdr"
        TextEditorRunTrace "Process The Function Soft/tools/mapinfo_config_file.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" "k"
        set f [ open "| Soft/tools/mapinfo_config_file.exe -id \x22$MapReadyDirOutput\x22 -if \x22$MapReadyFileHdr\x22 -ss $MapReadySensor -pp $PolarType" r]
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set MapInfoConfigFile "$MapReadyDirOutput/config_mapinfo.txt" 
        WaitUntilCreated $MapInfoConfigFile
           
        set ConfigFile "$MapReadyDirOutput/config.txt"
        set ErrorMessage ""
        LoadConfig
        if {"$ErrorMessage" == ""} {
            EnviWriteConfigC $MapReadyDirOutput $NligFullSize $NcolFullSize
   
            set DataDir $MapReadyOutputDir
    
            set RGBDirInput $MapReadyDirOutput
            set RGBDirOutput $MapReadyDirOutput
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set config "true"
            set fichier "$RGBDirInput/C11.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C11.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/C22.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C22.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set fichier "$RGBDirInput/C12_real.bin"
            if [file exists $fichier] {
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE C12_real.bin HAS NOT BEEN CREATED"
                Window show .top44; TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            if {"$config"=="true"} {
                set MaskPolFormat "C2"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                set ProgressLine "0"
                update
                TextEditorRunTrace "Process The Function create_mask_valid_pixels.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" "k"
                set f [ open "| Soft/tools/create_mask_valid_pixels.exe -id \x22$RGBDirInput\x22 -od \x22$RGBDirInput\x22 -idf $MaskPolFormat -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] { EnviWriteConfig $MaskFile $NligFullSize $NcolFullSize 4 } 

                set MaskCmd ""
                set MaskDir $RGBDirInput
                set MaskFile "$MaskDir/mask_valid_pixels.bin"
                if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
                set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -rgbf RGB1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }

            set DirNameDelete "$TMPDirSession/C2"
            DeleteDir $DirNameDelete
            }
}
#############################################################################
## Procedure:  MapReadyMatrixTSX_T3

proc ::MapReadyMatrixTSX_T3 {} {
global widget
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

proc vTclWindow.top381 {base} {
    if {$base == ""} {
        set base .top381
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
    wm geometry $top 500x300+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "MapReady - Geocode Matrix"
    vTcl:DefineAlias "$top" "Toplevel381" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame1" vTcl:WidgetProc "Toplevel381" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel381" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MapReadyDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel381" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel381" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button1" vTcl:WidgetProc "Toplevel381" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame5" vTcl:WidgetProc "Toplevel381" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable MapReadyOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel381" 1
    frame $site_5_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd67" "Frame3" vTcl:WidgetProc "Toplevel381" 1
    set site_6_0 $site_5_0.cpd67
    label $site_6_0.lab68 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab68" "Label1" vTcl:WidgetProc "Toplevel381" 1
    entry $site_6_0.cpd69 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MapReadyOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd69" "EntryTopXXCh5" vTcl:WidgetProc "Toplevel381" 1
    pack $site_6_0.lab68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame12" vTcl:WidgetProc "Toplevel381" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -command {global DirName DataDir MapReadyOutputDir
global VarWarning WarningMessage WarningMessage2

set MapReadyOutputDirTmp $MapReadyOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set MapReadyOutputDir $DirName
        } else {
        set MapReadyOutputDir $MapReadyOutputDirTmp
        }
    } else {
    set MapReadyOutputDir $MapReadyOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button2" vTcl:WidgetProc "Toplevel381" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd72 \
        -ipad 0 -text {SAR Leader File  ( LED-xxxxxxxxxxxx-xx.x__x )} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame381_1" vTcl:WidgetProc "Toplevel381" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable MapReadyLeaderFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel381" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel381" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.but71 \
        \
        -command {global FileName MapReadyDirInput MapReadySensor MapReadyLeaderFile
global ErrorMessage VarError

set MapReadyDirInputTmp [file dirname $MapReadyDirInput]

if {$MapReadySensor == "ALOS"} {
set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $MapReadyDirInputTmp $types "SAR LEADER INPUT FILE"

set LeaderDirName [file dirname $FileName]
set LeaderDirNameLength [string length $LeaderDirName]
set index1 [expr ($LeaderDirNameLength + 1)]
set index2 [expr ($index1 + 2)]
set LeaderFile [string range $FileName $index1 $index2]

if {$LeaderFile == "LED"} {
    set MapReadyLeaderFile $FileName
    } else {
    set MapReadyLeaderFile ""
    set VarError ""
    set ErrorMessage "THIS IS NOT A SAR LEADER FILE"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    
} else {

set types {
    {{XML Files}        {.xml}        }
    }
set FileName ""
OpenFile $MapReadyDirInputTmp $types "SAR PRODUCT FILE"
set MapReadyLeaderFile $FileName

}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but71" "Button3" vTcl:WidgetProc "Toplevel381" 1
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit66 \
        -ipad 0 -text {Resampling Method} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame1" vTcl:WidgetProc "Toplevel381" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    radiobutton $site_4_0.cpd68 \
        -text Bicubic -value bicubic -variable MapReadyResampling 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel381" 1
    radiobutton $site_4_0.rad67 \
        -text Bilinear -value bilinear -variable MapReadyResampling 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel381" 1
    radiobutton $site_4_0.cpd69 \
        -text {Nearest Neighbor} -value nearest_neighbor \
        -variable MapReadyResampling 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton3" vTcl:WidgetProc "Toplevel381" 1
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra70" "Frame4" vTcl:WidgetProc "Toplevel381" 1
    set site_3_0 $top.fra70
    frame $site_3_0.fra74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra74" "Frame2" vTcl:WidgetProc "Toplevel381" 1
    set site_4_0 $site_3_0.fra74
    frame $site_4_0.fra78 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra78" "Frame6" vTcl:WidgetProc "Toplevel381" 1
    set site_5_0 $site_4_0.fra78
    checkbutton $site_5_0.che79 \
        \
        -command {global MapReadyAutomaticInterpolate MapReadyPixelSize PSPBackgroundColor

if {$MapReadyAutomaticInterpolate == "1"} {
$widget(Entry381_1) configure -state disable
$widget(Entry381_1) configure -disabledbackground $PSPBackgroundColor
set MapReadyPixelSize ""
}
if {$MapReadyAutomaticInterpolate == "0"} {
$widget(Entry381_1) configure -state normal
$widget(Entry381_1) configure -disabledbackground #FFFFFF
set MapReadyPixelSize "?"
}} \
        -text {Auto Pixel Size} -variable MapReadyAutomaticInterpolate 
    vTcl:DefineAlias "$site_5_0.che79" "Checkbutton1" vTcl:WidgetProc "Toplevel381" 1
    entry $site_5_0.ent80 \
        -background white -disabledforeground #0000ff -foreground #ff0000 \
        -justify center -state disabled -textvariable MapReadyPixelSize \
        -width 9 
    vTcl:DefineAlias "$site_5_0.ent80" "Entry381_1" vTcl:WidgetProc "Toplevel381" 1
    pack $site_5_0.che79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.ent80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra75" "Frame5" vTcl:WidgetProc "Toplevel381" 1
    set site_5_0 $site_4_0.fra75
    checkbutton $site_5_0.cpd77 \
        \
        -command {global MapReadyTerrain
global MapReadyTerrainAutoMask MapReadyTerrainMask
global MapReadyMaskFile MapReadyTerrainInterp MapReadyTerrainSave
global MapReadyTerrainRadio MapReadyTerrainSkip
global MapReadyDEMFile MapReadyTerrainSmooth
global MapReadyTerrainGeo Load_MapReadyTerrain

set MapReadyTerrainAutoMask "0"; set MapReadyTerrainMask ""
set MapReadyMaskFile ""; set MapReadyTerrainInterp "0"; set MapReadyTerrainSave "0"
set MapReadyTerrainRadio "0"; set MapReadyTerrainSkip "0"
set MapReadyDEMFile ""; set MapReadyTerrainSmooth "0"
set MapReadyTerrainGeo "geo"

if {$Load_MapReadyTerrain == 0} {
    source "GUI/data_import/MapReadyTerrain.tcl"
    set Load_MapReadyTerrain 1
    WmTransient $widget(Toplevel385) $PSPTopLevel
    }

if {$Load_MapReadyTerrain == 1} {
    $widget(Checkbutton385_1) configure -state disable
    $widget(Checkbutton385_2) configure -state disable
    $widget(Checkbutton385_3) configure -state disable
    $widget(Checkbutton385_4) configure -state disable
    $widget(Checkbutton385_5) configure -state disable
    $widget(Radiobutton385_1) configure -state disable
    $widget(Radiobutton385_2) configure -state disable
    $widget(TitleFrame385_1) configure -state disable
    $widget(Entry385_1) configure -state disable
    $widget(Entry385_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button385_1) configure -state disable
    }

if {$MapReadyTerrain == 1} {
    set geowidth [winfo screenwidth .top2]; set geowidth [expr $geowidth - 10]
    set geowidth [expr $geowidth - 510]
    set geometrie "500x280+"; append geometrie $geowidth; append geometrie "+110"
    wm geometry .top385 $geometrie; update
    WidgetShowFromWidget $widget(Toplevel381) $widget(Toplevel385); TextEditorRunTrace "Open Window MapReady - Terrain Correction" "b"
    } else {
    Window hide $widget(Toplevel385); TextEditorRunTrace "Close Window MapReady - Terrain Correction" "b"
    }} \
        -text {Terrain Correction} -variable MapReadyTerrain 
    vTcl:DefineAlias "$site_5_0.cpd77" "Checkbutton2" vTcl:WidgetProc "Toplevel381" 1
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -ipady 2 -side top 
    pack $site_4_0.fra75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.tit72 \
        -ipad 0 -relief sunken -text {Default Parameters} 
    vTcl:DefineAlias "$site_3_0.tit72" "TitleFrame2" vTcl:WidgetProc "Toplevel381" 1
    bind $site_3_0.tit72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit72 getframe]
    label $site_5_0.lab73 \
        \
        -text {Geocoding : UTM          Datum : WGS84          Zone : < from metadata >} 
    vTcl:DefineAlias "$site_5_0.lab73" "Label2" vTcl:WidgetProc "Toplevel381" 1
    label $site_5_0.lab74 \
        -text {Input Format : PolSARpro          Output Format : PolSARpro} 
    vTcl:DefineAlias "$site_5_0.lab74" "Label3" vTcl:WidgetProc "Toplevel381" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.lab74 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.tit72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel381" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir OpenDirFile MapReadyDirOutput MapReadyOutputDir MapReadyOutputSubDir
global VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global MapReadyFileHdr MapInfoMapInfo MapInfoUnit MapInfoActive MapReadyState
global MapReadySensorPol MapReadySensor MapReadyTerrain TMPDir MapReadyPixelSize
global MapReadyLeaderFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set TestVarName(0) "Leader File"; set TestVarType(0) "file"; set TestVarValue(0) $MapReadyLeaderFile; set TestVarMin(0) ""; set TestVarMax(0) ""
TestVar 1
if {$TestVarError == "ok"} {

    set MapReadyDirOutput $MapReadyOutputDir 
    #if {$MapReadyOutputSubDir != ""} {append MapReadyDirOutput "/$MapReadyOutputSubDir"}

    #####################################################################
    #Create Directory
    set DirNameCreate $MapReadyDirOutput
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        set WarningMessage "THE OUTPUT DIRECTORY ALREADY EXISTS AND MUST BE"
        set WarningMessage2 "DELETED FIRST !!!... DO YOU WISH TO CONTINUE ?"
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Delete Directory" "k"
            DeleteDir $DirNameCreate
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44
                set VarWarning ""
                }
            }
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show .top44
                set VarWarning ""
                }
            }
        }
    #####################################################################       

    if {"$VarWarning"=="ok"} {

        set FileNameGEARTH "$MapReadyOutputDir/GEARTH_POLY.kml"
        DeleteFile $FileNameGEARTH

        set MapReadyState "1"
        if {$MapReadySensor == "ALOS"} {
            if {$MapReadySensorPol == "C2"} { MapReadyMatrixALOS_C2 }
            if {$MapReadySensorPol == "T3"} { MapReadyMatrixALOS_T3 }     
            }
        if {$MapReadySensor == "RS2"} {
            if {$MapReadySensorPol == "C2"} { MapReadyMatrixRS2_C2 }
            if {$MapReadySensorPol == "T3"} { MapReadyMatrixRS2_T3 }     
            }
        if {$MapReadySensor == "TSX"} {
            if {$MapReadySensorPol == "C2"} { MapReadyMatrixTSX_C2 }
            }
        set MapReadyState "2"

        set MapInfoConfigFile "$MapReadyDirOutput/config_mapinfo.txt" 
        if [file exists $MapInfoConfigFile] { MapInfoReadConfig $MapInfoConfigFile }

        set titi "$TMPDir/"; append titi [file tail $MapReadyOutputDir]
        set MapReadyFileOverlay $titi; append MapReadyFileOverlay "_overlay.kml"

        WaitUntilCreated $MapReadyFileOverlay

        TextEditorRunTrace "Process The Function Soft/tools/mapready_google_file.exe" "k"
        TextEditorRunTrace "Arguments: -od \x22$MapReadyOutputDir\x22 -if \x22$MapReadyFileOverlay\x22" "k"
        set f [ open "| Soft/tools/mapready_google_file.exe -od \x22$MapReadyOutputDir\x22 -if \x22$MapReadyFileOverlay\x22" r]
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError

        set FileNameGEARTH "$MapReadyOutputDir/GEARTH_POLY.kml"
        WaitUntilCreated $FileNameGEARTH
            
        MapReadyDelete
        
        set FileNameDelete "$TMPDir/"; append FileNameDelete [file tail $MapReadyOutputDir]
        set FileNameDel $FileNameDelete; append FileNameDel "_overlay.kml"
        DeleteFile $FileNameDel

        set FileNameDel $FileNameDelete; append FileNameDel "_overlay.meta"
        DeleteFile $FileNameDel

        set FileNameDel $FileNameDelete; append FileNameDel "_overlay.png"
        DeleteFile $FileNameDel

        set FileNameDel $FileNameDelete; append FileNameDel "_thumb.meta"
        DeleteFile $FileNameDel

        set FileNameDel $FileNameDelete; append FileNameDel "_thumb.png"
        DeleteFile $FileNameDel

        set FileNameDel $FileNameDelete; append FileNameDel "_thumb.img"
        DeleteFile $FileNameDel

        set DataDir $MapReadyOutputDir            

        if {$MapReadyTerrain == 1} {
            Window hide $widget(Toplevel385); TextEditorRunTrace "Close Window MapReady - Terrain Correction" "b"
            set MapReadyTerrain 0
            }
        Window hide $widget(Toplevel381); TextEditorRunTrace "Close Window MapReady - Geocode Matrix" "b"

        } else {
        if {"$VarWarning"=="no"} {
            if {$MapReadyTerrain == 1} {
                Window hide $widget(Toplevel385); TextEditorRunTrace "Close Window MapReady - Terrain Correction" "b"
                set MapReadyTerrain 0
                }
            Window hide $widget(Toplevel381); TextEditorRunTrace "Close Window MapReady - Geocode Matrix" "b"
            }
        }
    }
}} \
        -cursor {} -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button381_10" vTcl:WidgetProc "Toplevel381" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/MapReadyMatrix.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel381" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile TMPDir MapReadyTerrain MapReadyOutputDir MapReadyState

if {$OpenDirFile == 0} {

if {$MapReadyState == "2"} {
    set FileNameGEARTH "$MapReadyOutputDir/GEARTH_POLY.kml"
    WaitUntilCreated $FileNameGEARTH

    MapReadyDelete
    
    set FileNameDelete "$TMPDir/"; append FileNameDelete [file tail $MapReadyOutputDir]
    set FileNameDel $FileNameDelete; append FileNameDel "_overlay.kml"
    DeleteFile $FileNameDel

    set FileNameDel $FileNameDelete; append FileNameDel "_overlay.png"
    DeleteFile $FileNameDel

    set FileNameDel $FileNameDelete; append FileNameDel "_thumb.meta"
    DeleteFile $FileNameDel

    set FileNameDel $FileNameDelete; append FileNameDel "_thumb.png"
    DeleteFile $FileNameDel

    set FileNameDel $FileNameDelete; append FileNameDel "_thumb.img"
    DeleteFile $FileNameDel
   
    set DataDir $MapReadyOutputDir            
    }

if {$MapReadyState != "1"} {
    if {$MapReadyTerrain == 1} {
        Window hide $widget(Toplevel385); TextEditorRunTrace "Close Window MapReady - Terrain Correction" "b"
        set MapReadyTerrain 0
        }
    Window hide $widget(Toplevel381); TextEditorRunTrace "Close Window MapReady - Geocode Matrix" "b"
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel381" 1
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
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra70 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra59 \
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
Window show .top381

main $argc $argv
