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
    set base .top70a
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd97 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd97
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
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra72
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra67
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.che78 {
        array set save {-_tooltip 1 -foreground 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.lab79 {
        array set save {-_tooltip 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab80 {
        array set save {-_tooltip 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-_tooltip 1 -command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd71
    namespace eval ::widgets::$site_4_0.lab30 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.che31 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.lab32 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent33 {
        array set save {-background 1 -disabledbackground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent35 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd67
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.fra76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra76
    namespace eval ::widgets::$site_5_0.lab57 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd77
    namespace eval ::widgets::$site_4_0.lab78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.rad79 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra75
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
            vTclWindow.top70a
            UHDecompTGT
            UHDecompRGB
            UHDecompBMP
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
## Procedure:  UHDecompTGT

proc ::UHDecompTGT {} {
global DecompDirInput DecompDirOutput DecompOutputSubDirTmp
global DecompDecompositionFonction DecompDecompF DecompFonction DecompUHD
global NwinDecompL NwinDecompC RGBPolarDecomp BMPPolarDecomp
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd TMPMemoryAllocError
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType 

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Window Size Row"; set TestVarType(0) "int"; set TestVarValue(0) $NwinDecompL; set TestVarMin(0) "1"; set TestVarMax(0) "1000"
        set TestVarName(1) "Window Size Col"; set TestVarType(1) "int"; set TestVarValue(1) $NwinDecompC; set TestVarMin(1) "1"; set TestVarMax(1) "1000"
        TestVar 2
        if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        set ConfigFile "$DecompDirOutput/config.txt"
        WriteConfig

        set MaskCmd ""
        set MaskFile "$DecompDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

        set Fonction "Creation of all the Binary Data Files"

        set DecompDecompositionF $DecompDecompositionFonction
        if { $DecompDecompositionFonction == "S2"} { 
            if { $DecompOutputSubDirTmp == "T3"} { set DecompDecompositionF "S2T3" } 
            if { $DecompOutputSubDirTmp == "C3"} { set DecompDecompositionF "S2C3" } 
            }

        set Fonction2 "of the Huynen Decomposition"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/unified_huynen_decomposition.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -dec $DecompUHD  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/unified_huynen_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -dec $DecompUHD  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        set DecompDecompF $DecompDecompositionF
        if { $DecompDecompositionF == "T3"} { EnviWriteConfigT $DecompDirOutput $FinalNlig $FinalNcol }
        if { $DecompDecompositionF =="C3"} { EnviWriteConfigC $DecompDirOutput $FinalNlig $FinalNcol }
        if { $DecompDecompositionF == "S2T3"} { EnviWriteConfigT $DecompDirOutput $FinalNlig $FinalNcol; set DecompDecompF "T3"}
        if { $DecompDecompositionF == "S2C3"} { EnviWriteConfigC $DecompDirOutput $FinalNlig $FinalNcol; set DecompDecompF "C3"}

        }
        #TestVar
        }
        #Warning
}
#############################################################################
## Procedure:  UHDecompRGB

proc ::UHDecompRGB {} {
global DecompDirInput DecompDirOutput
global DecompDecompositionFonction DecompDecompF DecompFonction
global RGBPolarDecomp TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd FinalNlig FinalNcol PSPViewGimpBMP

if {"$RGBPolarDecomp"=="1"} {
    if {"$VarWarning"=="ok"} {
        #####################################################################       
        
        #Update the Nlig/Ncol of the new image after processing
        set NligInit 1
        set NcolInit 1
        set NligEnd $FinalNlig
        set NcolEnd $FinalNcol
            
        #####################################################################       

        set Fonction "Creation of the RGB File"

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        set RGBDirInput $DecompDirOutput
        set RGBFileOutput "$DecompDirOutput/PauliRGB.bmp"

        set MaskCmd ""
        set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

        set Fonction2 "$RGBFileOutput"    
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_pauli_rgb_file.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $DecompDecompF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
        set f [ open "| Soft/bin/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $DecompDecompF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set BMPDirInput $DecompDirOutput
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
        }
    }
    #RGBPolarDecomp
}
#############################################################################
## Procedure:  UHDecompBMP

proc ::UHDecompBMP {} {
global DecompDirInput DecompDirOutput
global DecompDecompositionFonction DecompDecompF DecompFonction
global BMPPolarDecomp PSPViewGimpBMP
global MinMaxBMPDecomp MinBMPDecomp MaxBMPDecomp
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd FinalNlig FinalNcol

if {"$BMPPolarDecomp"=="1"} {
    if {"$VarWarning"=="ok"} {
        #####################################################################       
        
        #Update the Nlig/Ncol of the new image after processing
        set NligInit 1
        set NcolInit 1
        set NligEnd $FinalNlig
        set NcolEnd $FinalNcol
            
        #####################################################################       

        if {"$MinMaxBMPDecomp"=="1"} {
            set MinBMPDecomp "-9999"
            set MaxBMPDecomp "+9999"
            }

        set TestVarName(0) "Min Value"; set TestVarType(0) "float"; set TestVarValue(0) $MinBMPDecomp; set TestVarMin(0) "-10000.00"; set TestVarMax(0) "10000.00"
        set TestVarName(1) "Max Value"; set TestVarType(1) "float"; set TestVarValue(1) $MaxBMPDecomp; set TestVarMin(1) "-10000.00"; set TestVarMax(1) "10000.00"
        TestVar 2
        if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        if {"$DecompDecompositionF" == "C3"} {
            set BMPFileInput "$DecompDirOutput/C11.bin"
            set BMPFileOutput "$DecompDirOutput/C11_dB.bmp"
            } else {
            set BMPFileInput "$DecompDirOutput/T11.bin"
            set BMPFileOutput "$DecompDirOutput/T11_dB.bmp"
            }
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
        if {"$DecompDecompositionF" == "C3"} {
            set BMPFileInput "$DecompDirOutput/C22.bin"
            set BMPFileOutput "$DecompDirOutput/C22_dB.bmp"
            } else {
            set BMPFileInput "$DecompDirOutput/T22.bin"
            set BMPFileOutput "$DecompDirOutput/T22_dB.bmp"
            }
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
        if {"$DecompDecompositionF" == "C3"} {
            set BMPFileInput "$DecompDirOutput/C33.bin"
            set BMPFileOutput "$DecompDirOutput/C33_dB.bmp"
            } else {
            set BMPFileInput "$DecompDirOutput/T33.bin"
            set BMPFileOutput "$DecompDirOutput/T33_dB.bmp"
            }
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }

        set BMPDirInput $DecompDirOutput

        }
        #TestVar
        }
        #Warning
    }
    #BMPPolarDecomp
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
    wm geometry $top 200x200+175+175; update
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

proc vTclWindow.top70a {base} {
    if {$base == ""} {
        set base .top70a
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
    wm minsize $top 148 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Polarimetric Decomposition"
    vTcl:DefineAlias "$top" "Toplevel70a" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd97 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd97" "Frame4" vTcl:WidgetProc "Toplevel70a" 1
    set site_3_0 $top.cpd97
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel70a" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DecompDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel70a" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel70a" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel70a" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel70a" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable DecompOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel70a" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel70a" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd76 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label14" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel70a" 1
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame17" vTcl:WidgetProc "Toplevel70a" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd71 \
        \
        -command {global DirName DataDir DecompOutputDir

set DecompOutputDirTmp $DecompOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set DecompOutputDir $DirName
    } else {
    set DecompOutputDir $DecompOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button540" vTcl:WidgetProc "Toplevel70a" 1
    bindtags $site_6_0.cpd71 "$site_6_0.cpd71 Button $top all _vTclBalloon"
    bind $site_6_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra72 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra72" "Frame9" vTcl:WidgetProc "Toplevel70a" 1
    set site_3_0 $top.fra72
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel70a" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel70a" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel70a" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel70a" 1
    pack $site_3_0.lab57 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent58 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab59 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent60 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab61 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent62 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab63 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_3_0.ent64 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit66 \
        -ipad 1 -text {Unified Huynen Dichotomy (UHD)} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame1" vTcl:WidgetProc "Toplevel70a" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    radiobutton $site_4_0.rad67 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD1"} \
        -text 1 -value UHD1 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd68 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD2"} \
        -text 2 -value UHD2 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd69 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD3"} \
        -text 3 -value UHD3 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton3" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd70 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD4"} \
        -text 4 -value UHD4 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.cpd70" "Radiobutton4" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd71 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD5"} \
        -text 5 -value UHD5 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.cpd71" "Radiobutton5" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd72 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD6"} \
        -text 6 -value UHD6 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.cpd72" "Radiobutton6" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd73 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD7"} \
        -text 7 -value UHD7 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.cpd73" "Radiobutton7" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd74 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD8"} \
        -text 8 -value UHD8 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.cpd74" "Radiobutton8" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd75 \
        \
        -command {global DecompDirOutputTmp DecompOutputDir

set DecompOutputDir $DecompDirOutputTmp; append DecompOutputDir "_UHD9"} \
        -text 9 -value UHD9 -variable DecompUHD 
    vTcl:DefineAlias "$site_4_0.cpd75" "Radiobutton9" vTcl:WidgetProc "Toplevel70a" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame3" vTcl:WidgetProc "Toplevel70a" 1
    set site_3_0 $top.fra66
    frame $site_3_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra67" "Frame5" vTcl:WidgetProc "Toplevel70a" 1
    set site_4_0 $site_3_0.fra67
    frame $site_4_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd68" "Frame440" vTcl:WidgetProc "Toplevel70a" 1
    set site_5_0 $site_4_0.cpd68
    checkbutton $site_5_0.che78 \
        -foreground #0000ff -padx 1 -text TgtG -variable RGBPolarDecomp 
    vTcl:DefineAlias "$site_5_0.che78" "Checkbutton70a_3" vTcl:WidgetProc "Toplevel70a" 1
    bindtags $site_5_0.che78 "$site_5_0.che78 Checkbutton $top all _vTclBalloon"
    bind $site_5_0.che78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    label $site_5_0.lab79 \
        -foreground #008000 -text TgtG 
    vTcl:DefineAlias "$site_5_0.lab79" "Label70a_6" vTcl:WidgetProc "Toplevel70a" 1
    bindtags $site_5_0.lab79 "$site_5_0.lab79 Label $top all _vTclBalloon"
    bind $site_5_0.lab79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    label $site_5_0.lab80 \
        -foreground #ff0000 -text {TgtG  } 
    vTcl:DefineAlias "$site_5_0.lab80" "Label70a_7" vTcl:WidgetProc "Toplevel70a" 1
    bindtags $site_5_0.lab80 "$site_5_0.lab80 Label $top all _vTclBalloon"
    bind $site_5_0.lab80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    pack $site_5_0.che78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.lab79 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.lab80 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    checkbutton $site_4_0.cpd69 \
        \
        -command {if {"$BMPPolarDecomp"=="0"} {
$widget(Label70a_1) configure -state disable
$widget(Label70a_2) configure -state disable
$widget(Label70a_3) configure -state disable
$widget(Checkbutton70a_1) configure -state disable
$widget(Entry70a_1) configure -state disable
$widget(Entry70a_2) configure -state disable
set MinMaxBMPDecomp "0"
set MinBMPDecomp ""
set MaxBMPDecomp ""
} else {
$widget(Label70a_1) configure -state normal
$widget(Label70a_2) configure -state normal
$widget(Label70a_3) configure -state normal
$widget(Checkbutton70a_1) configure -state normal
$widget(Entry70a_1) configure -state normal
$widget(Entry70a_2) configure -state normal
set MinMaxBMPDecomp "1"
set MinBMPDecomp "Auto"
set MaxBMPDecomp "Auto"
}} \
        -text {BMP  Target Generators (TgtG)} -variable BMPPolarDecomp 
    vTcl:DefineAlias "$site_4_0.cpd69" "Checkbutton323" vTcl:WidgetProc "Toplevel70a" 1
    bindtags $site_4_0.cpd69 "$site_4_0.cpd69 Checkbutton $top all _vTclBalloon"
    bind $site_4_0.cpd69 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators BMP Image}
    }
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd71 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd71" "Frame67" vTcl:WidgetProc "Toplevel70a" 1
    set site_4_0 $site_3_0.cpd71
    label $site_4_0.lab30 \
        -padx 1 -text {Minimum / Maximum Values} 
    vTcl:DefineAlias "$site_4_0.lab30" "Label70a_1" vTcl:WidgetProc "Toplevel70a" 1
    checkbutton $site_4_0.che31 \
        \
        -command {if {"$MinMaxBMPDecomp"=="1"} {
    $widget(Entry70a_1) configure -state disable
    $widget(Entry70a_2) configure -state disable
    set MinBMPDecomp "Auto"
    set MaxBMPDecomp "Auto"
    } else {
    $widget(Entry70a_1) configure -state normal
    $widget(Entry70a_2) configure -state normal
    set MinBMPDecomp "?"
    set MaxBMPDecomp "?"
    }} \
        -padx 1 -text auto -variable MinMaxBMPDecomp 
    vTcl:DefineAlias "$site_4_0.che31" "Checkbutton70a_1" vTcl:WidgetProc "Toplevel70a" 1
    label $site_4_0.lab32 \
        -padx 1 -text Min 
    vTcl:DefineAlias "$site_4_0.lab32" "Label70a_2" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_4_0.ent33 \
        -background white -disabledbackground #f0f0f0f0f0f0 \
        -foreground #ff0000 -justify center -textvariable MinBMPDecomp \
        -width 5 
    vTcl:DefineAlias "$site_4_0.ent33" "Entry70a_1" vTcl:WidgetProc "Toplevel70a" 1
    label $site_4_0.lab34 \
        -padx 1 -text Max 
    vTcl:DefineAlias "$site_4_0.lab34" "Label70a_3" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_4_0.ent35 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MaxBMPDecomp -width 5 
    vTcl:DefineAlias "$site_4_0.ent35" "Entry70a_2" vTcl:WidgetProc "Toplevel70a" 1
    pack $site_4_0.lab30 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.che31 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.lab32 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent33 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.lab34 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent35 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra67 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side top 
    frame $top.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd67" "Frame8" vTcl:WidgetProc "Toplevel70a" 1
    set site_3_0 $top.cpd67
    frame $site_3_0.cpd66 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame112" vTcl:WidgetProc "Toplevel70a" 1
    set site_4_0 $site_3_0.cpd66
    frame $site_4_0.fra76 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_4_0.fra76" "Frame389" vTcl:WidgetProc "Toplevel70a" 1
    set site_5_0 $site_4_0.fra76
    label $site_5_0.lab57 \
        -padx 1 -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_5_0.lab57" "Label73" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_5_0.ent58 \
        -background white -disabledforeground #0000ff -foreground #ff0000 \
        -justify center -textvariable NwinDecompL -width 5 
    vTcl:DefineAlias "$site_5_0.ent58" "Entry72" vTcl:WidgetProc "Toplevel70a" 1
    pack $site_5_0.lab57 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent58 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side right 
    frame $site_4_0.cpd66 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_4_0.cpd66" "Frame390" vTcl:WidgetProc "Toplevel70a" 1
    set site_5_0 $site_4_0.cpd66
    label $site_5_0.lab57 \
        -padx 1 -text Col 
    vTcl:DefineAlias "$site_5_0.lab57" "Label74" vTcl:WidgetProc "Toplevel70a" 1
    entry $site_5_0.ent58 \
        -background white -disabledforeground #0000ff -foreground #ff0000 \
        -justify center -textvariable NwinDecompC -width 5 
    vTcl:DefineAlias "$site_5_0.ent58" "Entry73" vTcl:WidgetProc "Toplevel70a" 1
    pack $site_5_0.lab57 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.ent58 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side right 
    pack $site_4_0.fra76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd77" "Frame380" vTcl:WidgetProc "Toplevel70a" 1
    set site_4_0 $site_3_0.cpd77
    label $site_4_0.lab78 \
        -text {Output Format} 
    vTcl:DefineAlias "$site_4_0.lab78" "Label70a_4" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.rad79 \
        \
        -command {global DecompOutputSubDir DecompOutputSubDirTmp

set DecompOutputSubDir $DecompOutputSubDirTmp} \
        -text T3 -value T3 -variable DecompOutputSubDirTmp 
    vTcl:DefineAlias "$site_4_0.rad79" "Radiobutton70a_1" vTcl:WidgetProc "Toplevel70a" 1
    radiobutton $site_4_0.cpd80 \
        \
        -command {global DecompOutputSubDir DecompOutputSubDirTmp

set DecompOutputSubDir $DecompOutputSubDirTmp} \
        -text C3 -value C3 -variable DecompOutputSubDirTmp 
    vTcl:DefineAlias "$site_4_0.cpd80" "Radiobutton70a_2" vTcl:WidgetProc "Toplevel70a" 1
    pack $site_4_0.lab78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.rad79 \
        -in $site_4_0 -anchor center -expand 1 -fill none -ipadx 5 -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 1 -fill none -ipadx 5 -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $top.fra75 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra75" "Frame20" vTcl:WidgetProc "Toplevel70a" 1
    set site_3_0 $top.fra75
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DecompDirInput DecompDirOutput DecompOutputDir DecompOutputSubDir
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global DecompDecompositionFonction DecompFonction PolarDecomp RGBDecomp BMPDecomp OpenDirFile
global BMPDirInput TestVarErrorTGT
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd FinalNlig FinalNcol

if {$OpenDirFile == 0} {

    set DecompDirOutput $DecompOutputDir
    if {$DecompOutputSubDir != ""} {append DecompDirOutput "/$DecompOutputSubDir"}

    #####################################################################
    #Create Directory
    set DecompDirOutput [PSPCreateDirectoryMask $DecompDirOutput $DecompOutputDir $DecompDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {

set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
TestVar 4
if {$TestVarError == "ok"} {
    UHDecompTGT
    if {$DecompDecompositionFonction == "S2"} {
        set WarningMessage "THE DATA FORMAT TO BE PROCESSED IS NOW:"
        if {$DecompOutputSubDir == "T3"} {set WarningMessage2 "3x3 COHERENCY MATRIX - T3"}
        if {$DecompOutputSubDir == "C3"} {set WarningMessage2 "3x3 COVARIANCE MATRIX - C3"}
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        }
    if {"$BMPPolarDecomp"=="1"} { UHDecompBMP }
    if {"$RGBPolarDecomp"=="1"} { UHDecompRGB }
    Window hide $widget(Toplevel70a); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"

    }
    #TestVar
    } else {
    if {"$VarWarning"=="no"} {
        Window hide $widget(Toplevel70a); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"
        }
    }
    #Warning

}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel70a" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolarimetricDecomposition.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel70a" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel70a); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel70a" 1
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
    pack $top.cpd97 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill none -ipadx 20 -ipady 2 \
        -pady 5 -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra75 \
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
Window show .top70a

main $argc $argv
