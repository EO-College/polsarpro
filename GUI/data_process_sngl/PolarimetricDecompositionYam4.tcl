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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}

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
    set base .top426
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
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.ent25 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra68 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra68
    namespace eval ::widgets::$site_5_0.rad69 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.rad69 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd69 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.rad69 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.che66 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd68
    namespace eval ::widgets::$site_4_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra67
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd68
    namespace eval ::widgets::$site_6_0.che78 {
        array set save {-_tooltip 1 -foreground 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.lab79 {
        array set save {-_tooltip 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab80 {
        array set save {-_tooltip 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-_tooltip 1 -command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.lab30 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.che31 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.lab32 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent33 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent35 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.cpd68 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
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
            vTclWindow.top426
            DecompYam4TGT
            DecompYam4RGB
            DecompYam4BMP
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
## Procedure:  DecompYam4TGT

proc ::DecompYam4TGT {} {
global DecompDirInput DecompDirOutput TMPDecompDir
global DecompDecompositionFonction DecompFonction DecompYam4Final
global NwinDecompL NwinDecompC RGBPolarDecomp BMPPolarDecomp
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax 
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd PSPMemory TMPMemoryAllocError TestVarErrorTGT
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType 

set config "false"
if {"$RGBPolarDecomp"=="1"} { set config "true" }
if {"$BMPPolarDecomp"=="1"} { set config "true" }

if {"$config"=="true"} {
    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Window Size Row"; set TestVarType(0) "int"; set TestVarValue(0) $NwinDecompL; set TestVarMin(0) "1"; set TestVarMax(0) "1000"
        set TestVarName(1) "Window Size Col"; set TestVarType(1) "int"; set TestVarValue(1) $NwinDecompC; set TestVarMin(1) "1"; set TestVarMax(1) "1000"
        TestVar 2
        set TestVarErrorTGT $TestVarError 
        if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        DeleteMatrixC $TMPDecompDir
        DeleteMatrixT $TMPDecompDir

        set ConfigFile "$TMPDecompDir/config.txt"
        WriteConfig

        set MaskCmd ""
        set MaskFile "$DecompDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

        if [file exists $MaskFile] { 
            CopyFile "$DecompDirInput/mask_valid_pixels.bin" "$TMPDecompDir/mask_valid_pixels.bin"
            CopyFile "$DecompDirInput/mask_valid_pixels.bin.hdr" "$TMPDecompDir/mask_valid_pixels.bin.hdr"
            }

        set Fonction "Creation of all the Binary Data Files"

        set DecompDecompositionF $DecompDecompositionFonction
        if {"$DecompDecompositionFonction" == "S2"} { set DecompDecompositionF "S2T3" }

        if {"$DecompFonction"=="Yamaguchi4"} {
            set Fonction2 "of the Yamaguchi Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/yamaguchi_4components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -mod $DecompYam4Final -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/yamaguchi_4components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -mod $DecompYam4Final -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$DecompYam4Final == "Y4O"} {
                if [file exists "$DecompDirOutput/Yamaguchi4_Y4O_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_Y4O_Odd.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_Y4O_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_Y4O_Dbl.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_Y4O_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_Y4O_Vol.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_Y4O_Hlx.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_Y4O_Hlx.bin" $FinalNlig $FinalNcol 4}
                } 
            if {$DecompYam4Final == "Y4R"} {
                if [file exists "$DecompDirOutput/Yamaguchi4_Y4R_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_Y4R_Odd.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_Y4R_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_Y4R_Dbl.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_Y4R_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_Y4R_Vol.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_Y4R_Hlx.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_Y4R_Hlx.bin" $FinalNlig $FinalNcol 4}
                } 
            if {$DecompYam4Final == "S4R"} {
                if [file exists "$DecompDirOutput/Yamaguchi4_S4R_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_S4R_Odd.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_S4R_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_S4R_Dbl.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_S4R_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_S4R_Vol.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Yamaguchi4_S4R_Hlx.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_S4R_Hlx.bin" $FinalNlig $FinalNcol 4}
                } 
            }
        if {"$DecompFonction"=="Singh4"} {
            set Fonction2 "of the Singh Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/singh_4components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -mod $DecompYam4Final -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/singh_4components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -mod $DecompYam4Final -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$DecompYam4Final == "G4U1"} {
                if [file exists "$DecompDirOutput/Singh4_G4U1_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_G4U1_Odd.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Singh4_G4U1_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_G4U1_Dbl.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Singh4_G4U1_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_G4U1_Vol.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Singh4_G4U1_Hlx.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi4_G4U1_Hlx.bin" $FinalNlig $FinalNcol 4}
                } 
            if {$DecompYam4Final == "G4U2"} {
                if [file exists "$DecompDirOutput/Singh4_G4U2_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Singh4_G4U2_Odd.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Singh4_G4U2_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Singh4_G4U2_Dbl.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Singh4_G4U2_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Singh4_G4U2_Vol.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$DecompDirOutput/Singh4_G4U2_Hlx.bin"] {EnviWriteConfig "$DecompDirOutput/Singh4_G4U2_Hlx.bin" $FinalNlig $FinalNcol 4}
                } 
            }           
        }
        #TestVar
        }
        #Warning
    }
    #Config Creation TgtGenerators Bin Files
}
#############################################################################
## Procedure:  DecompYam4RGB

proc ::DecompYam4RGB {} {
global DecompDirInput DecompDirOutput
global DecompDecompositionFonction DecompFonction
global RGBPolarDecomp TMPDecompDir PSPMemory TMPMemoryAllocError DecompYam4Final
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

        set MaskCmd ""
        set MaskFile "$DecompDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

        if {"$DecompDecompositionFonction" == "C3"} { 
            set DecompDecompositionF "C3"
            } else {
            set DecompDecompositionF "T3"
            }
                
        if {$DecompYam4Final == "Y4O"} {
            set FileInputBlue "$DecompDirOutput/Yamaguchi4_Y4O_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Yamaguchi4_Y4O_Vol.bin"
            set FileInputRed "$DecompDirOutput/Yamaguchi4_Y4O_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Yamaguchi4_Y4O_RGB.bmp"
            }

        if {$DecompYam4Final == "Y4R"} {
            set FileInputBlue "$DecompDirOutput/Yamaguchi4_Y4R_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Yamaguchi4_Y4R_Vol.bin"
            set FileInputRed "$DecompDirOutput/Yamaguchi4_Y4R_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Yamaguchi4_Y4R_RGB.bmp"
            }

        if {$DecompYam4Final == "S4R"} {
            set FileInputBlue "$DecompDirOutput/Yamaguchi4_S4R_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Yamaguchi4_S4R_Vol.bin"
            set FileInputRed "$DecompDirOutput/Yamaguchi4_S4R_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Yamaguchi4_S4R_RGB.bmp"
            }

        if {$DecompYam4Final == "G4U1"} {
            set FileInputBlue "$DecompDirOutput/Singh4_G4U1_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Singh4_G4U1_Vol.bin"
            set FileInputRed "$DecompDirOutput/Singh4_G4U1_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Singh4_G4U1_RGB.bmp"
            }

        if {$DecompYam4Final == "G4U2"} {
            set FileInputBlue "$DecompDirOutput/Singh4_G4U2_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Singh4_G4U2_Vol.bin"
            set FileInputRed "$DecompDirOutput/Singh4_G4U2_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Singh4_G4U2_RGB.bmp"
            }

        set Fonction2 "$RGBFileOutput"    
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file.exe" "k"
        TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
        set f [ open "| Soft/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set BMPDirInput $DecompDirOutput
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
        }
    }
    #RGBPolarDecomp
}
#############################################################################
## Procedure:  DecompYam4BMP

proc ::DecompYam4BMP {} {
global DecompDirInput DecompDirOutput TMPDecompDir
global DecompDecompositionFonction DecompFonction
global BMPPolarDecomp
global MinMaxBMPDecomp MinBMPDecomp MaxBMPDecomp DecompYam4Final
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

        if {$DecompYam4Final == "Y4O"} {
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_Y4O_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_Y4O_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_Y4O_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_Y4O_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_Y4O_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_Y4O_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_Y4O_Hlx.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_Y4O_Hlx_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }

        if {$DecompYam4Final == "Y4R"} {
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_Y4R_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_Y4R_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_Y4R_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_Y4R_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_Y4R_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_Y4R_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_Y4R_Hlx.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_Y4R_Hlx_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }

        if {$DecompYam4Final == "S4R"} {
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_S4R_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_S4R_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_S4R_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_S4R_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_S4R_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_S4R_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi4_S4R_Hlx.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi4_S4R_Hlx_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }

        if {$DecompYam4Final == "G4U1"} {
            set BMPFileInput "$DecompDirOutput/Singh4_G4U1_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Singh4_G4U1_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Singh4_G4U1_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Singh4_G4U1_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Singh4_G4U1_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Singh4_G4U1_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Singh4_G4U1_Hlx.bin"
            set BMPFileOutput "$DecompDirOutput/Singh4_G4U1_Hlx_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }

        if {$DecompYam4Final == "G4U2"} {
            set BMPFileInput "$DecompDirOutput/Singh4_G4U2_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Singh4_G4U2_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Singh4_G4U2_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Singh4_G4U2_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Singh4_G4U2_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Singh4_G4U2_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Singh4_G4U2_Hlx.bin"
            set BMPFileOutput "$DecompDirOutput/Singh4_G4U2_Hlx_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }

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
    wm geometry $top 200x200+25+25; update
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

proc vTclWindow.top426 {base} {
    if {$base == ""} {
        set base .top426
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
    wm geometry $top 500x420+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Polarimetric Decomposition"
    vTcl:DefineAlias "$top" "Toplevel426" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd97 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd97" "Frame4" vTcl:WidgetProc "Toplevel426" 1
    set site_3_0 $top.cpd97
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel426" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DecompDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel426" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel426" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel426" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel426" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable DecompOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel426" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel426" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd76 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label14" vTcl:WidgetProc "Toplevel426" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel426" 1
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame17" vTcl:WidgetProc "Toplevel426" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd71 \
        \
        -command {global DirName DataDir DecompOutputDir

set DecompDirOutputTmp $DecompOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set DecompOutputDir $DirName
    } else {
    set DecompOutputDir $DecompDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button540" vTcl:WidgetProc "Toplevel426" 1
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
    vTcl:DefineAlias "$top.fra72" "Frame9" vTcl:WidgetProc "Toplevel426" 1
    set site_3_0 $top.fra72
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel426" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel426" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel426" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel426" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel426" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel426" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel426" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel426" 1
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
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$top.fra73" "Frame110" vTcl:WidgetProc "Toplevel426" 1
    set site_3_0 $top.fra73
    entry $site_3_0.ent25 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompType -width 40 
    vTcl:DefineAlias "$site_3_0.ent25" "Entry60" vTcl:WidgetProc "Toplevel426" 1
    bindtags $site_3_0.ent25 "$site_3_0.ent25 Entry $top all _vTclBalloon"
    bind $site_3_0.ent25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Polarimetric Decomposition Theorem}
    }
    pack $site_3_0.ent25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -ipad 2 -text {Yamaguchi Decomposition} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame426_1" vTcl:WidgetProc "Toplevel426" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.fra68 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra68" "Frame6" vTcl:WidgetProc "Toplevel426" 1
    set site_5_0 $site_4_0.fra68
    radiobutton $site_5_0.rad69 \
        \
        -command {global DecompDirOutput DecompDirOutputTmp DecompOutputDir
global DecompYam4 DecompYam4Final DecompVolume
    
#set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_Y4O"
set DecompOutputDir $DecompDirOutput
set DecompYam4 "Y4O"
set DecompYam4Final "Y4O"
$widget(Checkbutton426_2) configure -state disable} \
        -text {Four Component Decomposition (Original : Y4O)} -value Y4O \
        -variable DecompYam4 
    vTcl:DefineAlias "$site_5_0.rad69" "Radiobutton426_1" vTcl:WidgetProc "Toplevel426" 1
    pack $site_5_0.rad69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame7" vTcl:WidgetProc "Toplevel426" 1
    set site_5_0 $site_4_0.cpd69
    radiobutton $site_5_0.rad69 \
        \
        -command {global DecompDirOutput DecompDirOutputTmp DecompOutputDir
global DecompYam4 DecompYam4Final DecompVolume
    
set DecompYam4 "Y4R"
$widget(Checkbutton426_2) configure -state normal

if { $DecompVolume == 0 } { 
    set DecompYam4Final "Y4R" 
#    set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_Y4R"
#    set DecompOutputDir $DecompDirOutput
    }
if { $DecompVolume == 1 } { 
    set DecompYam4Final "S4R" 
#    set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_S4R"
#    set DecompOutputDir $DecompDirOutput
    }} \
        -text {Four Component Decomposition with Rotation Transformation ( Y4R or S4R)} \
        -value Y4R -variable DecompYam4 
    vTcl:DefineAlias "$site_5_0.rad69" "Radiobutton426_2" vTcl:WidgetProc "Toplevel426" 1
    pack $site_5_0.rad69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra68 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd69 \
        -ipad 2 -text {Singh Decomposition} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame426_2" vTcl:WidgetProc "Toplevel426" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    frame $site_4_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame18" vTcl:WidgetProc "Toplevel426" 1
    set site_5_0 $site_4_0.cpd70
    radiobutton $site_5_0.rad69 \
        \
        -command {global DecompDirOutput DecompDirOutputTmp DecompOutputDir
global DecompYam4 DecompYam4Final DecompVolume
    
set DecompYam4 "G4U1"
$widget(Checkbutton426_2) configure -state normal

if { $DecompVolume == 0 } { 
    set DecompYam4Final "G4U1" 
#    set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_G4U1"
#    set DecompOutputDir $DecompDirOutput
    }
if { $DecompVolume == 1 } { 
    set DecompYam4Final "G4U2"
#    set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_G4U2"
#    set DecompOutputDir $DecompDirOutput
    }} \
        -text {Four Component Decomposition with Special Unitary Transformation ( G4U1 or G4U2 )} \
        -value G4U1 -variable DecompYam4 
    vTcl:DefineAlias "$site_5_0.rad69" "Radiobutton426_3" vTcl:WidgetProc "Toplevel426" 1
    pack $site_5_0.rad69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit67 \
        -ipad 2 -text {Volume Scattering Model ( Automatic Estimation )} 
    vTcl:DefineAlias "$top.tit67" "TitleFrame1" vTcl:WidgetProc "Toplevel426" 1
    bind $top.tit67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit67 getframe]
    checkbutton $site_4_0.che66 \
        \
        -command {global DecompDirOutput DecompDirOutputTmp DecompOutputDir
global DecompYam4 DecompYam4Final DecompVolume
    
if { $DecompVolume == 0 } { 
    if { $DecompYam4 == "Y4R" } {
        set DecompYam4Final "Y4R" 
#        set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_Y4R"
#        set DecompOutputDir $DecompDirOutput
        }
    if { $DecompYam4 == "G4U1" } {
        set DecompYam4Final "G4U1"
#        set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_G4U1"
#        set DecompOutputDir $DecompDirOutput
        }
    }
if { $DecompVolume == 1 } { 
    if { $DecompYam4 == "Y4R" } {
        set DecompYam4Final "S4R" 
#        set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_S4R"
#        set DecompOutputDir $DecompDirOutput
        }
    if { $DecompYam4 == "G4U1" } {
        set DecompYam4Final "G4U2"
#        set DecompDirOutput $DecompDirOutputTmp; append DecompDirOutput "_G4U2"
#        set DecompOutputDir $DecompDirOutput
        }
    }} \
        -text {With / Without Extended Volume Scattering Model ( dihedral scattering )} \
        -variable DecompVolume 
    vTcl:DefineAlias "$site_4_0.che66" "Checkbutton426_2" vTcl:WidgetProc "Toplevel426" 1
    pack $site_4_0.che66 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame1" vTcl:WidgetProc "Toplevel426" 1
    set site_3_0 $top.fra67
    frame $site_3_0.cpd68 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd68" "Frame10" vTcl:WidgetProc "Toplevel426" 1
    set site_4_0 $site_3_0.cpd68
    frame $site_4_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra67" "Frame11" vTcl:WidgetProc "Toplevel426" 1
    set site_5_0 $site_4_0.fra67
    frame $site_5_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame441" vTcl:WidgetProc "Toplevel426" 1
    set site_6_0 $site_5_0.cpd68
    checkbutton $site_6_0.che78 \
        -foreground #0000ff -padx 1 -text TgtG -variable RGBPolarDecomp 
    vTcl:DefineAlias "$site_6_0.che78" "Checkbutton426_3" vTcl:WidgetProc "Toplevel426" 1
    bindtags $site_6_0.che78 "$site_6_0.che78 Checkbutton $top all _vTclBalloon"
    bind $site_6_0.che78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    label $site_6_0.lab79 \
        -foreground #008000 -text TgtG 
    vTcl:DefineAlias "$site_6_0.lab79" "Label426_6" vTcl:WidgetProc "Toplevel426" 1
    bindtags $site_6_0.lab79 "$site_6_0.lab79 Label $top all _vTclBalloon"
    bind $site_6_0.lab79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    label $site_6_0.lab80 \
        -foreground #ff0000 -text {TgtG  } 
    vTcl:DefineAlias "$site_6_0.lab80" "Label426_7" vTcl:WidgetProc "Toplevel426" 1
    bindtags $site_6_0.lab80 "$site_6_0.lab80 Label $top all _vTclBalloon"
    bind $site_6_0.lab80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    pack $site_6_0.che78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab79 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side left 
    pack $site_6_0.lab80 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side left 
    checkbutton $site_5_0.cpd69 \
        \
        -command {if {"$BMPPolarDecomp"=="0"} {
$widget(Label426_1) configure -state disable
$widget(Label426_2) configure -state disable
$widget(Label426_3) configure -state disable
$widget(Checkbutton426_1) configure -state disable
$widget(Entry426_1) configure -state disable
$widget(Entry426_2) configure -state disable
set MinMaxBMPDecomp "0"
set MinBMPDecomp ""
set MaxBMPDecomp ""
} else {
$widget(Label426_1) configure -state normal
$widget(Label426_2) configure -state normal
$widget(Label426_3) configure -state normal
$widget(Checkbutton426_1) configure -state normal
$widget(Entry426_1) configure -state normal
$widget(Entry426_2) configure -state normal
set MinMaxBMPDecomp "1"
set MinBMPDecomp "Auto"
set MaxBMPDecomp "Auto"
}} \
        -text {BMP  Target Generators (TgtG)} -variable BMPPolarDecomp 
    vTcl:DefineAlias "$site_5_0.cpd69" "Checkbutton324" vTcl:WidgetProc "Toplevel426" 1
    bindtags $site_5_0.cpd69 "$site_5_0.cpd69 Checkbutton $top all _vTclBalloon"
    bind $site_5_0.cpd69 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators BMP Image}
    }
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd71 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame68" vTcl:WidgetProc "Toplevel426" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab30 \
        -padx 1 -text {Minimum / Maximum Values} 
    vTcl:DefineAlias "$site_5_0.lab30" "Label426_1" vTcl:WidgetProc "Toplevel426" 1
    checkbutton $site_5_0.che31 \
        \
        -command {if {"$MinMaxBMPDecomp"=="1"} {
    $widget(Entry426_1) configure -state disable
    $widget(Entry426_2) configure -state disable
    set MinBMPDecomp "Auto"
    set MaxBMPDecomp "Auto"
    } else {
    $widget(Entry426_1) configure -state normal
    $widget(Entry426_2) configure -state normal
    set MinBMPDecomp "?"
    set MaxBMPDecomp "?"
    }} \
        -padx 1 -text auto -variable MinMaxBMPDecomp 
    vTcl:DefineAlias "$site_5_0.che31" "Checkbutton426_1" vTcl:WidgetProc "Toplevel426" 1
    label $site_5_0.lab32 \
        -padx 1 -text Min 
    vTcl:DefineAlias "$site_5_0.lab32" "Label426_2" vTcl:WidgetProc "Toplevel426" 1
    entry $site_5_0.ent33 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MinBMPDecomp -width 5 
    vTcl:DefineAlias "$site_5_0.ent33" "Entry426_1" vTcl:WidgetProc "Toplevel426" 1
    label $site_5_0.lab34 \
        -padx 1 -text Max 
    vTcl:DefineAlias "$site_5_0.lab34" "Label426_3" vTcl:WidgetProc "Toplevel426" 1
    entry $site_5_0.ent35 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MaxBMPDecomp -width 5 
    vTcl:DefineAlias "$site_5_0.ent35" "Entry426_2" vTcl:WidgetProc "Toplevel426" 1
    pack $site_5_0.lab30 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.che31 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab32 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent33 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.lab34 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent35 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    TitleFrame $site_3_0.cpd67 \
        -text {Window Size} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame4" vTcl:WidgetProc "Toplevel426" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.cpd72
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.cpd68 \
        -padx 1 -text Row -width 5 
    vTcl:DefineAlias "$site_6_0.cpd68" "Label77" vTcl:WidgetProc "Toplevel426" 1
    entry $site_6_0.cpd70 \
        -background white -disabledforeground #0000ff -foreground #ff0000 \
        -justify center -textvariable NwinDecompL -width 5 
    vTcl:DefineAlias "$site_6_0.cpd70" "Entry76" vTcl:WidgetProc "Toplevel426" 1
    pack $site_6_0.cpd68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd73
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.cpd69 \
        -padx 1 -text Col -width 5 
    vTcl:DefineAlias "$site_6_0.cpd69" "Label80" vTcl:WidgetProc "Toplevel426" 1
    entry $site_6_0.cpd71 \
        -background white -disabledforeground #0000ff -foreground #ff0000 \
        -justify center -textvariable NwinDecompC -width 5 
    vTcl:DefineAlias "$site_6_0.cpd71" "Entry79" vTcl:WidgetProc "Toplevel426" 1
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra75 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra75" "Frame20" vTcl:WidgetProc "Toplevel426" 1
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

set config "false"
if {"$RGBPolarDecomp"=="1"} { set config "true" }
if {"$BMPPolarDecomp"=="1"} { set config "true" }
if {"$config"=="true"} {
    set TestVarErrorTGT ""
    DecompYam4TGT
    if {$TestVarErrorTGT == "ok"} {
        if {"$BMPPolarDecomp"=="1"} { DecompYam4BMP }
        if {"$RGBPolarDecomp"=="1"} { DecompYam4RGB }
        }
    }
    #Config Creation TgtGenerators Bin Files

    $widget(Checkbutton426_3) configure -state normal
    $widget(Label426_6) configure -state normal
    $widget(Label426_7) configure -state normal
    Window hide $widget(Toplevel426); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"

    }
    #TestVar
    } else {
    if {"$VarWarning"=="no"} {
        $widget(Checkbutton426_3) configure -state normal
        $widget(Label426_6) configure -state normal
        $widget(Label426_7) configure -state normal
        Window hide $widget(Toplevel426); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"
        }
    }
    #Warning

}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel426" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolarimetricDecompositionYam4.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel426" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
$widget(Checkbutton426_3) configure -state normal
$widget(Label426_6) configure -state normal
$widget(Label426_7) configure -state normal
Window hide $widget(Toplevel426); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel426" 1
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
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -pady 5 -side top 
    pack $top.tit67 \
        -in $top -anchor center -expand 0 -fill none -pady 3 -side top 
    pack $top.fra67 \
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
Window show .top426

main $argc $argv
