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
        .gif -
	.png	{return photo}
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
    set base .top525
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_3_0 $base.cpd66
    set site_5_0 [$site_3_0.cpd67 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd75
    set site_3_0 $base.fra44
    set site_3_0 $base.fra53
    set site_4_0 $site_3_0.cpd54
    set site_4_0 $site_3_0.cpd55
    set site_3_0 $base.fra90
    set site_5_0 [$site_3_0.cpd91 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd75
    set site_4_0 $site_3_0.cpd78
    set site_6_0 [$site_4_0.cpd76 getframe]
    set site_6_0 $site_6_0
    set site_7_0 $site_6_0.cpd75
    set site_4_0 $site_3_0.fra110
    set site_6_0 [$site_4_0.cpd112 getframe]
    set site_6_0 $site_6_0
    set site_7_0 $site_6_0.cpd107
    set site_7_0 $site_6_0.cpd75
    set site_7_0 $site_6_0.cpd104
    set site_7_0 $site_6_0.cpd109
    set site_7_0 $site_6_0.cpd105
    set site_5_0 $site_4_0.fra113
    set site_7_0 [$site_5_0.cpd114 getframe]
    set site_7_0 $site_7_0
    set site_8_0 $site_7_0.cpd75
    set site_8_0 $site_7_0.cpd104
    set site_8_0 $site_7_0.cpd66
    set site_8_0 $site_7_0.cpd67
    set site_8_0 $site_7_0.cpd69
    set site_3_0 $base.fra92
    set site_5_0 [$site_3_0.cpd47 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd72
    set site_7_0 $site_6_0.cpd92
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top525
            PTOMprocesschannel
            PTOMprocessmatrix
            PTOMprocessdecomp
            PTOMprocesshaalp
            PTOMprocessspan
            PTOMreset
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
## Procedure:  PTOMprocesschannel

proc ::PTOMprocesschannel {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMProcessNwinL PTOMProcessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        if {"$PTOMhhpvv"=="1"} { 
            set FileSource "$PTOMProcessDirOutput/T11.bin"
            set FileTarget "$PTOMProcessDirOutput/tomo_HHpVV.bin"
            CopyFile $FileSource $FileTarget
            set FileSource "$PTOMProcessDirOutput/T11.bin.hdr"
            set FileTarget "$PTOMProcessDirOutput/tomo_HHpVV.bin.hdr"
            CopyFile $FileSource $FileTarget
            }
        if {"$PTOMhhmvv"=="1"} { 
            set FileSource "$PTOMProcessDirOutput/T22.bin"
            set FileTarget "$PTOMProcessDirOutput/tomo_HHmVV.bin"
            CopyFile $FileSource $FileTarget
            set FileSource "$PTOMProcessDirOutput/T22.bin.hdr"
            set FileTarget "$PTOMProcessDirOutput/tomo_HHmVV.bin.hdr"
            CopyFile $FileSource $FileTarget
            }

        set config "false"
        if {"$PTOMhh"=="1"} { set config "true"}
        if {"$PTOMhv"=="1"} { set config "true"}
        if {"$PTOMvv"=="1"} { set config "true"}
        if {"$config"=="true"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_convert/data_convert.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_convert/data_convert.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            EnviWriteConfigC $TMPDirectory $FinalNlig $FinalNcol
            if {"$PTOMhh"=="1"} { 
                set FileSource "$TMPDirectory/C11.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_HH.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C11.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_HH.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            if {"$PTOMhv"=="1"} { 
                set FileSource "$TMPDirectory/C22.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_HV.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C22.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_HV.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            if {"$PTOMvv"=="1"} { 
                set FileSource "$TMPDirectory/C33.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_VV.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C33.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_VV.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            }

        set config "false"
        if {"$PTOMll"=="1"} { set config "true"}
        if {"$PTOMlr"=="1"} { set config "true"}
        if {"$PTOMrr"=="1"} { set config "true"}
        if {"$config"=="true"} {
            set FileTarget "$TMPDirectory/config.txt"
            set FileSource "$PTOMProcessDirOutput/config.txt"
            CopyFile $FileSource $FileTarget
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/basis_change/basis_change.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -phi 0 -tau 45 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/basis_change/basis_change.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -phi 0 -tau 45 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            EnviWriteConfigT $TMPDirectory $FinalNlig $FinalNcol
            WaitUntilCreated "$TMPDirectory/T33.bin.hdr"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_convert/data_convert.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_convert/data_convert.exe -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            EnviWriteConfigC $TMPDirectory $FinalNlig $FinalNcol
            if {"$PTOMll"=="1"} { 
                set FileSource "$TMPDirectory/C11.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_LL.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C11.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_LL.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            if {"$PTOMlr"=="1"} { 
                set FileSource "$TMPDirectory/C22.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_LR.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C22.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_LR.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            if {"$PTOMrr"=="1"} { 
                set FileSource "$TMPDirectory/C33.bin"
                set FileTarget "$PTOMProcessDirOutput/tomo_RR.bin"
                CopyFile $FileSource $FileTarget
                set FileSource "$TMPDirectory/C33.bin.hdr"
                set FileTarget "$PTOMProcessDirOutput/tomo_RR.bin.hdr"
                CopyFile $FileSource $FileTarget
                }
            }

        }
    }
}
}
#############################################################################
## Procedure:  PTOMprocessmatrix

proc ::PTOMprocessmatrix {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMProcessNwinL PTOMProcessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $PTOMProcessNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $PTOMProcessNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        if {$PTOMcorrT3 == "1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 12 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 12 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError      
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro12.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_Ro12.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}

            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 13 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 13 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro13.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_Ro13.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}
        
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 23 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -elt 23 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro23.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_Ro23.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}
            }
            
        if {$PTOMcorrCCC == "1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr_CCC.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr_CCC.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/CCC.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_CCC.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}        
            }
            
        if {$PTOMcorrCCCN == "1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr_CCC_norm.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr_CCC_norm.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/CCCnorm.bin"
            set FileNameOutput "$PTOMProcessDirOutput/T3_CCCnorm.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}        
            }
            
        if {$PTOMcorrC3 == "1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_convert/data_convert.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_convert/data_convert.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$TMPDirectory\x22 -iodf T3C3 -sym 1 -nlr 1 -nlc 1 -ssr 1 -ssc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 12 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 12 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError      
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro12.bin"
            set FileNameOutput "$PTOMProcessDirOutput/C3_Ro12.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}

            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 13 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 13 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro13.bin"
            set FileNameOutput "$PTOMProcessDirOutput/C3_Ro13.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}
        
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_corr.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 23 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/process_corr.exe -id \x22$TMPDirectory\x22 -od \x22$TMPDirectory\x22 -iodf C3 -elt 23 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            set FileNameInput "$TMPDirectory/Ro23.bin"
            set FileNameOutput "$PTOMProcessDirOutput/C3_Ro23.bin"
            CopyFile $FileNameInput $FileNameOutput
            if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 6}
            }
        }
    }
}
}
#############################################################################
## Procedure:  PTOMprocessdecomp

proc ::PTOMprocessdecomp {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam
global PTOMProcessNwinL PTOMProcessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $PTOMProcessNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $PTOMProcessNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        if {"$PTOMfree"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/freeman_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/freeman_decomposition.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3  -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/Freeman_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Freeman_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Freeman_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Freeman_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Freeman_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Freeman_Vol.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMvz"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/vanzyl92_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/vanzyl92_3components_decomposition.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/VanZyl3_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/VanZyl3_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/VanZyl3_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/VanZyl3_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/VanZyl3_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/VanZyl3_Vol.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMnned"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/arii_nned_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/arii_nned_3components_decomposition.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/Arii3_NNED_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Arii3_NNED_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Arii3_NNED_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Arii3_NNED_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Arii3_NNED_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Arii3_NNED_Vol.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMyam"=="1"} {
            set Fonction2 "of the Yamaguchi Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/yamaguchi_4components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -mod S4R -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/yamaguchi_4components_decomposition.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -mod S4R -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/Yamaguchi4_S4R_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Yamaguchi4_S4R_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Yamaguchi4_S4R_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Yamaguchi4_S4R_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Yamaguchi4_S4R_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Yamaguchi4_S4R_Vol.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Yamaguchi4_S4R_Hlx.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Yamaguchi4_S4R_Hlx.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMsingh"=="1"} {
            set Fonction2 "of the Singh Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/singh_4components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -mod G4U2 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/singh_4components_decomposition.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -mod G4U2 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/Singh4_G4U2_Odd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Singh4_G4U2_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Singh4_G4U2_Dbl.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Singh4_G4U2_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Singh4_G4U2_Vol.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Singh4_G4U2_Vol.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/Singh4_G4U2_Hlx.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/Singh4_G4U2_Hlx.bin" $FinalNlig $FinalNcol 4}
            }           
        }
    }
}
}
#############################################################################
## Procedure:  PTOMprocesshaalp

proc ::PTOMprocesshaalp {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd
global PTOMProcessNwinL PTOMProcessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $PTOMProcessNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $PTOMProcessNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        if {"$PTOMhaalp"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 1 -fl3 1 -fl4 1 -fl5 1 -fl6 0 -fl7 0 -fl8 0 -fl9 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 1 -fl3 1 -fl4 1 -fl5 1 -fl6 0 -fl7 0 -fl8 0 -fl9 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
  	    TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/lambda.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/lambda.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/alpha.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/anisotropy.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMshannon"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 1 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 1 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/entropy_shannon.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_I.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_I.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_P.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_P.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_norm.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_I_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_I_norm.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/entropy_shannon_P_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/entropy_shannon_P_norm.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMprob"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 1 -fl2 1 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 1 -fl2 1 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/l1.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/l1.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/l2.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/l2.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/l3.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/l3.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/p1.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/p1.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/p2.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/p2.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/p3.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/p3.bin" $FinalNlig $FinalNcol 4}
            }

        if {"$PTOMasym"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 1 -fl7 1 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 1 -fl7 1 -fl8 0 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/asymetry.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/asymetry.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/polarisation_fraction.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/polarisation_fraction.bin" $FinalNlig $FinalNcol 4}
            }
            
        if {"$PTOMerd"=="1"} {
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 1 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_eigenvalue_set.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -nwr $PTOMProcessNwinL -nwc $PTOMProcessNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 0 -fl4 0 -fl5 0 -fl6 0 -fl7 0 -fl8 1 -fl9 0 -fl10 0 -fl11 0 -fl12 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$PTOMProcessDirOutput/serd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/serd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/derd.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/derd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/serd_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/serd_norm.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$PTOMProcessDirOutput/derd_norm.bin"] {EnviWriteConfig "$PTOMProcessDirOutput/derd_norm.bin" $FinalNlig $FinalNcol 4}
            }
        }
    }
}
}
#############################################################################
## Procedure:  PTOMprocessspan

proc ::PTOMprocessspan {} {
global PTOMProcessDirInput PTOMProcessDirOutput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMProcessNwinL PTOMProcessNwinC
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TMPMemoryAllocError TMPDirectory
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNcolEnd PTOMNligFullSize PTOMNcolFullSize

if {$OpenDirFile == 0} {

set PTOMProcessDirOutput $PTOMProcessOutputDir
if {$PTOMProcessOutputSubDir != ""} {append PTOMProcessDirOutput "/$PTOMProcessOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set PTOMProcessDirOutput [PSPCreateDirectoryMask $PTOMProcessDirOutput $PTOMProcessOutputDir $PTOMProcessDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $PTOMNligInit - 1]
    set OffsetCol [expr $PTOMNcolInit - 1]
    set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
    set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $PTOMNligInit; set TestVarMin(0) "0"; set TestVarMax(0) $PTOMNligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $PTOMNcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $PTOMNcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $PTOMNligEnd; set TestVarMin(2) $PTOMNligInit; set TestVarMax(2) $PTOMNligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $PTOMNcolEnd; set TestVarMin(3) $PTOMNcolInit; set TestVarMax(3) $PTOMNcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {
        set Fonction ""; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$PTOMProcessDirOutput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -fmt lin -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -fmt lin -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError      
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        set FileNameOutput "$PTOMProcessDirOutput/span.bin"
        if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 4}

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$PTOMProcessDirOutput\x22 -od \x22$PTOMProcessDirOutput\x22 -iodf T3 -fmt db -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError      
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        set FileNameOutput "$PTOMProcessDirOutput/span_db.bin"
        if [file exists $FileNameOutput] {EnviWriteConfig $FileNameOutput $FinalNlig $FinalNcol 4}
        }
    }
}
}
#############################################################################
## Procedure:  PTOMreset

proc ::PTOMreset {} {
global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMspan PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd

set PTOMhh "0"; set PTOMhv "0"; set PTOMvv "0"; set PTOMhhpvv "0"; set PTOMhhmvv "0"; set PTOMrr "0"; set PTOMlr "0"; set PTOMll "0"
set PTOMspan "0"; set PTOMcorrT3 "0"; set PTOMcorrC3 "0"; set PTOMcorrCCC "0"; set PTOMcorrCCCN "0"
set PTOMnned "0"; set PTOMvz "0"; set PTOMfree "0"; set PTOMsingh "0"; set PTOMyam "0"
set PTOMhaalp "0"; set PTOMshannon "0"; set PTOMprob "0"; set PTOMasym "0"; set PTOMerd "0"
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
    wm maxsize $top 3844 1065
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

proc vTclWindow.top525 {base} {
    if {$base == ""} {
        set base .top525
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
		-menu "$top.m71" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x400+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Polarimetric Tomography ( Pol-TomSAR ) - Generator Parameters"
    vTcl:DefineAlias "$top" "Toplevel525" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd66 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame21" vTcl:WidgetProc "Toplevel525" 1
    set site_3_0 $top.cpd66
    TitleFrame $site_3_0.cpd67 \
		-ipad 0 -text {Input - Output Process Directory} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame12" vTcl:WidgetProc "Toplevel525" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame54" vTcl:WidgetProc "Toplevel525" 1
    set site_6_0 $site_5_0.cpd75
    entry $site_6_0.cpd71 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMProcessOutputDir 
    vTcl:DefineAlias "$site_6_0.cpd71" "Entry67" vTcl:WidgetProc "Toplevel525" 1
    button $site_6_0.cpd56 \
		\
		-command {global DirName PTOMProcessDirInput PTOMProcessOutputDir PTOMProcessOutputSubDir
global PTOMzdim PTOMxdim PTOMzmin PTOMzmax PTOMxmin PTOMxmax
global PTOMNligInit PTOMNcolInit PTOMNligEnd PTOMNligFullSize PTOMNcolEnd PTOMNcolFullSize        
global PTOMProcessNwinL PTOMProcessNwinC

set PTOMProcessOutputTmp $PTOMProcessOutputDir
set PTOMProcessOutputDir $PTOMProcessDirInput 
set PTOMProcessOutputSubDir " "
set PTOMzdim " "; set PTOMxdim " "; set PTOMzmin " "; set PTOMzmax " "; set PTOMxmin " "; set PTOMxmax " "
set PTOMNligInit " "; set PTOMNcolInit " "; set PTOMNligEnd " "; set PTOMNligFullSize " "; set PTOMNcolEnd " "; set PTOMNcolFullSize " "

PTOMreset

$widget(Button525_3) configure -state disable
$widget(Button525_5) configure -state disable
$widget(Button525_6) configure -state disable

set DirName ""
OpenDir $PTOMProcessDirInput "INPUT - OUTPUT DATA DIRECTORY"
if {$DirName != "" } {
    set PTOMProcessOutputDir $DirName
    set PTOMProcessOutputSubDir "T3"
    set PTOMProcessDirOutput "$DirName/T3"
    set ConfigFileTomo "$PTOMProcessDirOutput/config.txt"  
    if [file exists $ConfigFileTomo] {
        set f [open $ConfigFileTomo r]
        gets $f tmp
        gets $f PTOMNligFullSize
        gets $f tmp
        gets $f tmp
        gets $f PTOMNcolFullSize
        gets $f tmp
        gets $f tmp
        gets $f tmp
        gets $f tmp
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {![eof $f]} {
            gets $f tmp
            gets $f PTOMzdim
            gets $f tmp
            gets $f tmp
            gets $f PTOMxdim
            gets $f tmp
            gets $f tmp
            gets $f PTOMzmin
            gets $f tmp
            gets $f tmp
            gets $f PTOMzmax
            gets $f tmp
            gets $f tmp
            gets $f PTOMxmin
            gets $f tmp
            gets $f tmp
            gets $f PTOMxmax
            close $f

            set config "false"
            if {$PTOMxmin != " " && $PTOMxmax != " " && $PTOMxdim != " " && $PTOMzmin != " " && $PTOMzmax != " " && $PTOMzdim != " "} { set config "true"}
           
            if {$config == "true"} {
                set PTOMNligInit "1"; set PTOMNcolInit "1";
                set PTOMNligEnd $PTOMNligFullSize; set PTOMNcolEnd $PTOMNcolFullSize        
                set PTOMProcessNwinL "1"; set PTOMProcessNwinC "1" 
                $widget(Button525_3) configure -state normal
                $widget(Button525_5) configure -state normal
                $widget(Button525_6) configure -state normal
                } else {
                close $f
                set ErrorMessage "NOT A POL-TOMO DIRECTORY TYPE"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set PTOMProcessOutputDir PTOMProcessDirInput 
                set PTOMProcessOutputSubDir " " 
                if {$VarError == "cancel"} {Window hide $widget(Toplevel525); TextEditorRunTrace "Close Window Polarimetric Tomography - Generator Parameters" "b"}
                }    
            } else {
            close $f
            set ErrorMessage "NOT A POL-TOMO DIRECTORY TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set PTOMProcessOutputDir PTOMProcessDirInput 
            set PTOMProcessOutputSubDir " " 
            if {$VarError == "cancel"} {Window hide $widget(Toplevel525); TextEditorRunTrace "Close Window Polarimetric Tomography - Generator Parameters" "b"}
            }    
        } else {
        set ErrorMessage "NOT CONFIG FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel525); TextEditorRunTrace "Close Window Polarimetric Tomography - Generator Parameters" "b"}
        }    
    } else {
    set PTOMProcessOutputDir PTOMProcessDirInput 
    set PTOMProcessOutputSubDir " " 
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd56" "Button525" vTcl:WidgetProc "Toplevel525" 1
    entry $site_6_0.cpd69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMProcessOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd69" "Entry64" vTcl:WidgetProc "Toplevel525" 1
    label $site_6_0.cpd70 \
		-text / -width 2 
    vTcl:DefineAlias "$site_6_0.cpd70" "Label40" vTcl:WidgetProc "Toplevel525" 1
    pack $site_6_0.cpd71 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd56 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd69 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    pack $site_6_0.cpd70 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd75 \
		-in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd67 \
		-in $site_3_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra44 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra44" "Frame1" vTcl:WidgetProc "Toplevel525" 1
    set site_3_0 $top.fra44
    label $site_3_0.lab45 \
		-text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab45" "Label1" vTcl:WidgetProc "Toplevel525" 1
    entry $site_3_0.ent49 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMNligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent49" "Entry1" vTcl:WidgetProc "Toplevel525" 1
    label $site_3_0.cpd46 \
		-text {End Row} 
    vTcl:DefineAlias "$site_3_0.cpd46" "Label2" vTcl:WidgetProc "Toplevel525" 1
    entry $site_3_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMNligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.cpd50" "Entry2" vTcl:WidgetProc "Toplevel525" 1
    label $site_3_0.cpd47 \
		-text {Init Col} 
    vTcl:DefineAlias "$site_3_0.cpd47" "Label3" vTcl:WidgetProc "Toplevel525" 1
    entry $site_3_0.cpd51 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMNcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.cpd51" "Entry3" vTcl:WidgetProc "Toplevel525" 1
    label $site_3_0.cpd48 \
		-text {End Col} 
    vTcl:DefineAlias "$site_3_0.cpd48" "Label4" vTcl:WidgetProc "Toplevel525" 1
    entry $site_3_0.cpd52 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMNcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.cpd52" "Entry4" vTcl:WidgetProc "Toplevel525" 1
    pack $site_3_0.lab45 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.ent49 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd46 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd50 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd47 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd51 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd48 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd52 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra53 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra53" "Frame14" vTcl:WidgetProc "Toplevel525" 1
    set site_3_0 $top.fra53
    frame $site_3_0.cpd54 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd54" "Frame15" vTcl:WidgetProc "Toplevel525" 1
    set site_4_0 $site_3_0.cpd54
    label $site_4_0.lab45 \
		-text Xmin 
    vTcl:DefineAlias "$site_4_0.lab45" "Label5" vTcl:WidgetProc "Toplevel525" 1
    entry $site_4_0.ent49 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMxmin -width 7 
    vTcl:DefineAlias "$site_4_0.ent49" "Entry5" vTcl:WidgetProc "Toplevel525" 1
    label $site_4_0.cpd46 \
		-text Xmax 
    vTcl:DefineAlias "$site_4_0.cpd46" "Label6" vTcl:WidgetProc "Toplevel525" 1
    entry $site_4_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMxmax -width 7 
    vTcl:DefineAlias "$site_4_0.cpd50" "Entry6" vTcl:WidgetProc "Toplevel525" 1
    label $site_4_0.cpd47 \
		-text Xunit 
    vTcl:DefineAlias "$site_4_0.cpd47" "Label7" vTcl:WidgetProc "Toplevel525" 1
    entry $site_4_0.cpd51 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMxdim -width 5 
    vTcl:DefineAlias "$site_4_0.cpd51" "Entry7" vTcl:WidgetProc "Toplevel525" 1
    pack $site_4_0.lab45 \
		-in $site_4_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_4_0.ent49 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd46 \
		-in $site_4_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_4_0.cpd50 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd47 \
		-in $site_4_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_4_0.cpd51 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd55 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd55" "Frame18" vTcl:WidgetProc "Toplevel525" 1
    set site_4_0 $site_3_0.cpd55
    label $site_4_0.lab45 \
		-text Zmin 
    vTcl:DefineAlias "$site_4_0.lab45" "Label8" vTcl:WidgetProc "Toplevel525" 1
    entry $site_4_0.ent49 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMzmin -width 7 
    vTcl:DefineAlias "$site_4_0.ent49" "Entry8" vTcl:WidgetProc "Toplevel525" 1
    label $site_4_0.cpd46 \
		-text Zmax 
    vTcl:DefineAlias "$site_4_0.cpd46" "Label9" vTcl:WidgetProc "Toplevel525" 1
    entry $site_4_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMzmax -width 7 
    vTcl:DefineAlias "$site_4_0.cpd50" "Entry10" vTcl:WidgetProc "Toplevel525" 1
    label $site_4_0.cpd47 \
		-text Zunit 
    vTcl:DefineAlias "$site_4_0.cpd47" "Label10" vTcl:WidgetProc "Toplevel525" 1
    entry $site_4_0.cpd51 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMzdim -width 5 
    vTcl:DefineAlias "$site_4_0.cpd51" "Entry12" vTcl:WidgetProc "Toplevel525" 1
    pack $site_4_0.lab45 \
		-in $site_4_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_4_0.ent49 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd46 \
		-in $site_4_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_4_0.cpd50 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd47 \
		-in $site_4_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_4_0.cpd51 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd54 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd55 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra90 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra90" "Frame5" vTcl:WidgetProc "Toplevel525" 1
    set site_3_0 $top.fra90
    TitleFrame $site_3_0.cpd91 \
		-ipad 0 -text {Polarization Channels} 
    vTcl:DefineAlias "$site_3_0.cpd91" "TitleFrame525_3" vTcl:WidgetProc "Toplevel525" 1
    bind $site_3_0.cpd91 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd91 getframe]
    frame $site_5_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame39" vTcl:WidgetProc "Toplevel525" 1
    set site_6_0 $site_5_0.cpd75
    checkbutton $site_6_0.che78 \
		-text HH -variable PTOMhh 
    vTcl:DefineAlias "$site_6_0.che78" "Checkbutton525_1" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_6_0.cpd79 \
		-text HV -variable PTOMhv 
    vTcl:DefineAlias "$site_6_0.cpd79" "Checkbutton525_2" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_6_0.cpd93 \
		-text VV -variable PTOMvv 
    vTcl:DefineAlias "$site_6_0.cpd93" "Checkbutton525_3" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_6_0.cpd94 \
		-text {HH + VV} -variable PTOMhhpvv 
    vTcl:DefineAlias "$site_6_0.cpd94" "Checkbutton525_4" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_6_0.cpd95 \
		-text {HH - VV} -variable PTOMhhmvv 
    vTcl:DefineAlias "$site_6_0.cpd95" "Checkbutton525_5" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_6_0.cpd96 \
		-text LL -variable PTOMll 
    vTcl:DefineAlias "$site_6_0.cpd96" "Checkbutton525_6" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_6_0.cpd97 \
		-text LR -variable PTOMlr 
    vTcl:DefineAlias "$site_6_0.cpd97" "Checkbutton525_7" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_6_0.cpd98 \
		-text RR -variable PTOMrr 
    vTcl:DefineAlias "$site_6_0.cpd98" "Checkbutton525_8" vTcl:WidgetProc "Toplevel525" 1
    pack $site_6_0.che78 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd79 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd93 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd94 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd95 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd96 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd97 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd98 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd75 \
		-in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_3_0.cpd78 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame13" vTcl:WidgetProc "Toplevel525" 1
    set site_4_0 $site_3_0.cpd78
    TitleFrame $site_4_0.cpd76 \
		-ipad 0 -text {Matrix Elements} 
    vTcl:DefineAlias "$site_4_0.cpd76" "TitleFrame525_4" vTcl:WidgetProc "Toplevel525" 1
    bind $site_4_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    frame $site_6_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame44" vTcl:WidgetProc "Toplevel525" 1
    set site_7_0 $site_6_0.cpd75
    checkbutton $site_7_0.che78 \
		-text Span -variable PTOMspan 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton525_9" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_7_0.cpd79 \
		-text {Corr Coeffs - [T3]} -variable PTOMcorrT3 
    vTcl:DefineAlias "$site_7_0.cpd79" "Checkbutton525_10" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_7_0.cpd100 \
		-text {Corr Coeffs - [C3]} -variable PTOMcorrC3 
    vTcl:DefineAlias "$site_7_0.cpd100" "Checkbutton525_11" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_7_0.cpd71 \
		-text C.C.C -variable PTOMcorrCCC 
    vTcl:DefineAlias "$site_7_0.cpd71" "Checkbutton525_12" vTcl:WidgetProc "Toplevel525" 1
    checkbutton $site_7_0.cpd72 \
		-text {Normalized C.C.C} -variable PTOMcorrCCCN 
    vTcl:DefineAlias "$site_7_0.cpd72" "Checkbutton525_21" vTcl:WidgetProc "Toplevel525" 1
    pack $site_7_0.che78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd79 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd100 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd71 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd72 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd75 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd76 \
		-in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $site_3_0.fra110 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra110" "Frame9" vTcl:WidgetProc "Toplevel525" 1
    set site_4_0 $site_3_0.fra110
    TitleFrame $site_4_0.cpd112 \
		-ipad 0 -text {Polarimetric Decompositions} 
    vTcl:DefineAlias "$site_4_0.cpd112" "TitleFrame525_5" vTcl:WidgetProc "Toplevel525" 1
    bind $site_4_0.cpd112 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd112 getframe]
    frame $site_6_0.cpd107 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd107" "Frame59" vTcl:WidgetProc "Toplevel525" 1
    set site_7_0 $site_6_0.cpd107
    checkbutton $site_7_0.che78 \
		-text {Arii NNED 3 components} -variable PTOMnned 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton525_13" vTcl:WidgetProc "Toplevel525" 1
    pack $site_7_0.che78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame60" vTcl:WidgetProc "Toplevel525" 1
    set site_7_0 $site_6_0.cpd75
    checkbutton $site_7_0.che78 \
		-text {Van Zyl 3 components} -variable PTOMvz 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton525_14" vTcl:WidgetProc "Toplevel525" 1
    pack $site_7_0.che78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd104 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd104" "Frame61" vTcl:WidgetProc "Toplevel525" 1
    set site_7_0 $site_6_0.cpd104
    checkbutton $site_7_0.che78 \
		-text {Freeman 3 components} -variable PTOMfree 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton525_15" vTcl:WidgetProc "Toplevel525" 1
    pack $site_7_0.che78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd109 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd109" "Frame62" vTcl:WidgetProc "Toplevel525" 1
    set site_7_0 $site_6_0.cpd109
    checkbutton $site_7_0.che78 \
		-text {Singh 4 components} -variable PTOMsingh 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton525_16" vTcl:WidgetProc "Toplevel525" 1
    pack $site_7_0.che78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd105 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd105" "Frame63" vTcl:WidgetProc "Toplevel525" 1
    set site_7_0 $site_6_0.cpd105
    checkbutton $site_7_0.che78 \
		-text {Yamaguchi 4 components} -variable PTOMyam 
    vTcl:DefineAlias "$site_7_0.che78" "Checkbutton525_17" vTcl:WidgetProc "Toplevel525" 1
    pack $site_7_0.che78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd107 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd75 \
		-in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd104 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd109 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd105 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_4_0.fra113 \
		-height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra113" "Frame11" vTcl:WidgetProc "Toplevel525" 1
    set site_5_0 $site_4_0.fra113
    TitleFrame $site_5_0.cpd114 \
		-ipad 0 -text {Eigenvalues parameters} 
    vTcl:DefineAlias "$site_5_0.cpd114" "TitleFrame525_6" vTcl:WidgetProc "Toplevel525" 1
    bind $site_5_0.cpd114 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd114 getframe]
    frame $site_7_0.cpd75 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame42" vTcl:WidgetProc "Toplevel525" 1
    set site_8_0 $site_7_0.cpd75
    checkbutton $site_8_0.che78 \
		-text {Entropy / Anisotropy / Alpha / Lambda} -variable PTOMhaalp 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton525_18" vTcl:WidgetProc "Toplevel525" 1
    pack $site_8_0.che78 \
		-in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd104 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd104" "Frame53" vTcl:WidgetProc "Toplevel525" 1
    set site_8_0 $site_7_0.cpd104
    checkbutton $site_8_0.che78 \
		-text {Shannon Entropy} -variable PTOMshannon 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton525_19" vTcl:WidgetProc "Toplevel525" 1
    pack $site_8_0.che78 \
		-in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd66 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd66" "Frame57" vTcl:WidgetProc "Toplevel525" 1
    set site_8_0 $site_7_0.cpd66
    checkbutton $site_8_0.che78 \
		-text {Probabilities (p1,p2,p3)  / eigenvalues (L1,L2,L3) } \
		-variable PTOMprob 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton525_20" vTcl:WidgetProc "Toplevel525" 1
    pack $site_8_0.che78 \
		-in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd67 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd67" "Frame68" vTcl:WidgetProc "Toplevel525" 1
    set site_8_0 $site_7_0.cpd67
    checkbutton $site_8_0.che78 \
		-text {Eigenvalue Relative Difference (E.R.D)} -variable PTOMerd 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton525_22" vTcl:WidgetProc "Toplevel525" 1
    pack $site_8_0.che78 \
		-in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd69 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd69" "Frame69" vTcl:WidgetProc "Toplevel525" 1
    set site_8_0 $site_7_0.cpd69
    checkbutton $site_8_0.che78 \
		-text {Polarisation asymetry / polarisation fraction} \
		-variable PTOMasym 
    vTcl:DefineAlias "$site_8_0.che78" "Checkbutton525_23" vTcl:WidgetProc "Toplevel525" 1
    pack $site_8_0.che78 \
		-in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd75 \
		-in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd104 \
		-in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd66 \
		-in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd67 \
		-in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd69 \
		-in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd114 \
		-in $site_5_0 -anchor center -expand 1 -fill both -padx 1 -side top 
    pack $site_4_0.cpd112 \
		-in $site_4_0 -anchor center -expand 1 -fill both -padx 1 -side right 
    pack $site_4_0.fra113 \
		-in $site_4_0 -anchor center -expand 1 -fill both -side left 
    pack $site_3_0.cpd91 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd78 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra110 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra92 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra92" "Frame20" vTcl:WidgetProc "Toplevel525" 1
    set site_3_0 $top.fra92
    TitleFrame $site_3_0.cpd47 \
		-ipad 1 -text {Window Size} 
    vTcl:DefineAlias "$site_3_0.cpd47" "TitleFrame16" vTcl:WidgetProc "Toplevel525" 1
    bind $site_3_0.cpd47 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd47 getframe]
    frame $site_5_0.cpd72 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame65" vTcl:WidgetProc "Toplevel525" 1
    set site_6_0 $site_5_0.cpd72
    frame $site_6_0.cpd92 \
		-relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd92" "Frame72" vTcl:WidgetProc "Toplevel525" 1
    set site_7_0 $site_6_0.cpd92
    label $site_7_0.lab85 \
		-text Row 
    vTcl:DefineAlias "$site_7_0.lab85" "Label17" vTcl:WidgetProc "Toplevel525" 1
    entry $site_7_0.cpd88 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMProcessNwinC -width 5 
    vTcl:DefineAlias "$site_7_0.cpd88" "Entry17" vTcl:WidgetProc "Toplevel525" 1
    entry $site_7_0.cpd95 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMProcessNwinL -width 5 
    vTcl:DefineAlias "$site_7_0.cpd95" "Entry18" vTcl:WidgetProc "Toplevel525" 1
    label $site_7_0.cpd94 \
		-text {  Col} 
    vTcl:DefineAlias "$site_7_0.cpd94" "Label18" vTcl:WidgetProc "Toplevel525" 1
    pack $site_7_0.lab85 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd88 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side right 
    pack $site_7_0.cpd95 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd94 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd92 \
		-in $site_6_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_5_0.cpd72 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    button $site_3_0.cpd67 \
		-background {#ffff00} \
		-command {global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMspan PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd
global PTOMProcessNwinL PTOMProcessNwinC PSPBackgroundColor
global OpenDirFile 

if {$OpenDirFile == 0} {

set config "false"
if {$PTOMhh == "1"} {set config "true"}
if {$PTOMhv == "1"} {set config "true"}
if {$PTOMvv == "1"} {set config "true"}
if {$PTOMhhpvv == "1"} {set config "true"}
if {$PTOMhhmvv == "1"} {set config "true"}
if {$PTOMll == "1"} {set config "true"}
if {$PTOMlr == "1"} {set config "true"}
if {$PTOMrr == "1"} {set config "true"}
if {$config == "true"} { PTOMprocesschannel }

set config "false"
if {$PTOMspan == "1"} {set config "true"}
if {$config == "true"} { PTOMprocessspan }

set config "false"
if {$PTOMcorrT3 == "1"} {set config "true"}
if {$PTOMcorrC3 == "1"} {set config "true"}
if {$PTOMcorrCCC == "1"} {set config "true"}
if {$PTOMcorrCCCN == "1"} {set config "true"}
if {$config == "true"} { PTOMprocessmatrix }

set config "false"
if {$PTOMnned == "1"} {set config "true"}
if {$PTOMvz == "1"} {set config "true"}
if {$PTOMfree == "1"} {set config "true"}
if {$PTOMsingh == "1"} {set config "true"}
if {$PTOMyam == "1"} {set config "true"}
if {$config == "true"} { PTOMprocessdecomp }

set config "false"
if {$PTOMhaalp == "1"} {set config "true"}
if {$PTOMshannon == "1"} {set config "true"}
if {$PTOMerd == "1"} {set config "true"}
if {$PTOMprob == "1"} {set config "true"}
if {$PTOMasym == "1"} {set config "true"}
if {$config == "true"} { PTOMprocesshaalp }

#Window hide $widget(Toplevel525); TextEditorRunTrace "Close Window Polarimetric Tomography - Generator Parameters" "b"

}} \
		-padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.cpd67" "Button525_3" vTcl:WidgetProc "Toplevel525" 1
    button $site_3_0.cpd69 \
		-background {#ffff00} \
		-command {global PTOMhh PTOMhv PTOMvv PTOMhhpvv PTOMhhmvv PTOMrr PTOMlr PTOMll
global PTOMspan PTOMcorrT3 PTOMcorrC3 PTOMcorrCCC PTOMcorrCCCN
global PTOMnned PTOMvz PTOMfree PTOMsingh PTOMyam PTOMhaalp PTOMshannon PTOMprob PTOMasym PTOMerd

set PTOMhh "1"; set PTOMhv "1"; set PTOMvv "1"; set PTOMhhpvv "1"; set PTOMhhmvv "1"; set PTOMrr "1"; set PTOMlr "1"; set PTOMll "1"
set PTOMspan "1"; set PTOMcorrT3 "1"; set PTOMcorrC3 "1"; set PTOMcorrCCC "1"; set PTOMcorrCCCN "1"
set PTOMnned "1"; set PTOMvz "1"; set PTOMfree "1"; set PTOMsingh "1"; set PTOMyam "1"
set PTOMhaalp "1"; set PTOMshannon "1"; set PTOMprob "1"; set PTOMasym "1"; set PTOMerd "1"} \
		-padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd69" "Button525_5" vTcl:WidgetProc "Toplevel525" 1
    button $site_3_0.but66 \
		-background {#ffff00} -command PTOMreset -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but66" "Button525_6" vTcl:WidgetProc "Toplevel525" 1
    button $site_3_0.but23 \
		-background {#ff8000} \
		-command {HelpPdfEdit "Help/data_process_dual/DisplayPolarizationCoherenceTomography.pdf"} \
		-image [vTcl:image:get_image [file join . GUI Images help.gif]] \
		-pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel525" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
		-background {#ffff00} \
		-command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel525); TextEditorRunTrace "Close Window Polarimetric Tomography - Generator Parameters" "b"
}} \
		-padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button525_0" vTcl:WidgetProc "Toplevel525" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.cpd47 \
		-in $site_3_0 -anchor center -expand 0 -fill none -ipadx 5 -padx 2 \
		-side left 
    pack $site_3_0.cpd67 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but66 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
		-activeborderwidth 1 -borderwidth 1 -cursor {}  
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd66 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra44 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra53 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra90 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra92 \
		-in $top -anchor center -expand 0 -fill x -pady 10 -side top 

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
Window show .top525

main $argc $argv
