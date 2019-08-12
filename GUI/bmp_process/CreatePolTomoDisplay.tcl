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
# Visual Tcl v8.6.0.5 Project
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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
        {{[file join . GUI Images GIMPshortcut.gif]} {user image} user {}}

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
    set base .top528
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_3_0 $base.fra67
    set site_5_0 [$site_3_0.cpd69 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd91
    set site_4_0 $site_3_0.cpd53
    set site_5_0 [$site_3_0.cpd70 getframe]
    set site_5_0 $site_5_0
    set site_5_0 [$site_3_0.cpd71 getframe]
    set site_5_0 $site_5_0
    set site_5_0 [$site_3_0.cpd72 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd72
    set site_7_0 $site_6_0.fra77
    set site_7_0 $site_6_0.cpd79
    set site_7_0 $site_6_0.cpd66
    set site_6_0 $site_5_0.cpd73
    set site_7_0 $site_6_0.cpd102
    set site_7_0 $site_6_0.fra67
    set site_7_0 $site_6_0.cpd70
    set site_7_0 $site_6_0.cpd74
    set site_7_0 $site_6_0.cpd75
    set site_4_0 [$base.cpd75 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd91
    set site_4_0 [$base.cpd66 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd91
    set site_3_0 $base.fra74
    set site_4_0 $site_3_0.cpd71
    set site_4_0 $site_3_0.cpd70
    set site_5_0 $site_4_0.fra67
    set site_5_0 $site_4_0.cpd70
    set site_5_0 $site_4_0.cpd71
    set site_3_0 $base.cpd72
    set site_4_0 $site_3_0.cpd71
    set site_4_0 $site_3_0.cpd70
    set site_5_0 $site_4_0.fra67
    set site_5_0 $site_4_0.cpd70
    set site_5_0 $site_4_0.cpd71
    set site_3_0 $base.cpd67
    set site_5_0 [$site_3_0.cpd66 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd68
    set site_6_0 $site_5_0.cpd67
    set site_3_0 $base.fra38
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top528
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
    wm geometry $top 200x200+132+132; update
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

proc vTclWindow.top528 {base} {
    if {$base == ""} {
        set base .top528
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
    wm geometry $top 500x510+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create Pol-Tomography Display"
    vTcl:DefineAlias "$top" "Toplevel528" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra67 \
		-borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame11" vTcl:WidgetProc "Toplevel528" 1
    set site_3_0 $top.fra67
    TitleFrame $site_3_0.cpd69 \
		-ipad 0 -text {Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd69" "TitleFrame8" vTcl:WidgetProc "Toplevel528" 1
    bind $site_3_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMDisplayFileInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel528" 1
    frame $site_5_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel528" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
		\
		-command {global FileName PTOMDisplayDirInput PTOMDisplayDirOutput PTOMDisplayFileInput PTOMDisplayFileMask
global MinMaxAutoPTOMDisplay MinMaxContrastPTOMDisplay MinMaxNormalisationPTOMDisplay
global InputFormat OutputFormat MinPTOMDisplay MaxPTOMDisplay MinCPTOMDisplay MaxCPTOMDisplay
global PTOMNligInit PTOMNligEnd PTOMNcolInit PTOMNcolEnd PTOMNcolFullSize PTOMNligFullSize
global PTOMzdim PTOMxdim PTOMzmin PTOMzmax PTOMxmin PTOMxmax
global PTOMDisplayZGroundFile PTOMDisplayZTopFile
global ConfigFile VarError ErrorMessage MaskCmd
global ValidMaskFile ValidMaskColor

Window hide .top401
Window hide .top401tomo

set PTOMDisplayFileInput " "
#set PTOMDisplayZGroundFile ""
#set PTOMDisplayZTopFile ""
set PTOMDisplayFileMask " "
set MaskCmd ""
set PTOMNligInit " "; set PTOMNligEnd " "
set PTOMNcolInit " "; set PTOMNcolEnd " "
set PTOMNcolFullSize " "; set PTOMNligFullSize " "
set PTOMzdim " "; set PTOMxdim " "
set PTOMzmin "?"; set PTOMzmax "?"
set PTOMxmin "?"; set PTOMxmax "?"
set InputFormat "float"
set OutputFormat "real"
set MinMaxAutoPTOMDisplay 1
set MinMaxContrastPTOMDisplay 0
set MinMaxNormalisationPTOMDisplay 0
$widget(Label528_1) configure -state disable
$widget(Entry528_1) configure -state disable
$widget(Label528_2) configure -state disable
$widget(Entry528_2) configure -state disable
$widget(Label528_3) configure -state disable
$widget(Entry528_3) configure -state disable
$widget(Entry528_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label528_4) configure -state disable
$widget(Entry528_4) configure -state disable
$widget(Entry528_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button528_1) configure -state disable
set MinPTOMDisplay "Auto"
set MaxPTOMDisplay "Auto"
set MinCPTOMDisplay ""
set MaxCPTOMDisplay ""
set MaskCmd ""
set ValidMaskFile ""
set ValidMaskColor "black"

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $PTOMDisplayDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
    set PTOMDisplayDirInput [file dirname $FileName]
    set PTOMDisplayDirOutput $PTOMDisplayDirInput
    set ConfigFileTomo [file dirname $FileName]
    append ConfigFileTomo "/config.txt"
    if [file exists $ConfigFileTomo] {
        set PTOMzdim " "; set PTOMxdim " "
        set PTOMzmin "?"; set PTOMzmax "?"
        set PTOMxmin "?"; set PTOMxmax "?"
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
            if {$PTOMxmin != "?" && $PTOMxmax != "?" && $PTOMxdim != " " && $PTOMzmin != "?" && $PTOMzmax != "?" && $PTOMzdim != " "} { set config "true"}
           
            if {$config == "true"} {
                set FileNameHdr "$FileName.hdr"
                if [file exists $FileNameHdr] {
                    set f [open $FileNameHdr "r"]
                    gets $f tmp
                    gets $f tmp
                    gets $f tmp
                    if {[string first "PolSARpro" $tmp] != "-1"} {
                        gets $f tmp; set PTOMNcolFullSize [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
                        gets $f tmp; set PTOMNligFullSize [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
                        set PTOMNligInit 1
                        set PTOMNligEnd $PTOMNligFullSize
                        set PTOMNcolInit 1
                        set PTOMNcolEnd $PTOMNcolFullSize
                        gets $f tmp
                        gets $f tmp
                        gets $f tmp
                        gets $f tmp
                        if {$tmp == "data type = 2"} {set InputFormat "int"; set OutputFormat "real"}
                        if {$tmp == "data type = 4"} {set InputFormat "float"; set OutputFormat "real"}
                        if {$tmp == "data type = 6"} {set InputFormat "cmplx"; set OutputFormat "mod"}
                        set MaskFile "$PTOMDisplayDirInput/mask_valid_pixels.bin"
                        if [file exists $MaskFile] { 
                            set PTOMDisplayFileMask $MaskFile
                            set MaskCmd "-mask \x22$MaskFile\x22" 
                            }
                        set PTOMDisplayFileInput $FileName
                        } else {
                        set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        if {$VarError == "cancel"} {Window hide $widget(Toplevel43); TextEditorRunTrace "Close Window Create BMP File" "b"}
                        }    
                    close $f
                    } else {
                    set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    if {$VarError == "cancel"} {Window hide $widget(Toplevel43); TextEditorRunTrace "Close Window Create BMP File" "b"}
                    }    
                } else {
                close $f
                set ErrorMessage "NOT A POL-TOMO DIRECTORY TYPE"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                if {$VarError == "cancel"} {Window hide $widget(Toplevel528); TextEditorRunTrace "Close Window Create PTOMDisplay File" "b"}
                }    
            } else {
            close $f
            set ErrorMessage "NOT A POL-TOMO DIRECTORY TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            if {$VarError == "cancel"} {Window hide $widget(Toplevel528); TextEditorRunTrace "Close Window Create PTOMDisplay File" "b"}
            }    
        } else {
        set ErrorMessage "NOT CONFIG FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel528); TextEditorRunTrace "Close Window Create PTOMDisplay File" "b"}
        }    
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
		-in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.cpd53 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd53" "Frame10" vTcl:WidgetProc "Toplevel528" 1
    set site_4_0 $site_3_0.cpd53
    label $site_4_0.lab45 \
		-text {Init Row} 
    vTcl:DefineAlias "$site_4_0.lab45" "Label5" vTcl:WidgetProc "Toplevel528" 1
    entry $site_4_0.ent49 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMNligInit -width 5 
    vTcl:DefineAlias "$site_4_0.ent49" "Entry5" vTcl:WidgetProc "Toplevel528" 1
    label $site_4_0.cpd46 \
		-text {End Row} 
    vTcl:DefineAlias "$site_4_0.cpd46" "Label6" vTcl:WidgetProc "Toplevel528" 1
    entry $site_4_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMNligEnd -width 5 
    vTcl:DefineAlias "$site_4_0.cpd50" "Entry6" vTcl:WidgetProc "Toplevel528" 1
    label $site_4_0.cpd47 \
		-text {Init Col} 
    vTcl:DefineAlias "$site_4_0.cpd47" "Label18" vTcl:WidgetProc "Toplevel528" 1
    entry $site_4_0.cpd51 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMNcolInit -width 5 
    vTcl:DefineAlias "$site_4_0.cpd51" "Entry17" vTcl:WidgetProc "Toplevel528" 1
    label $site_4_0.cpd48 \
		-text {End Col} 
    vTcl:DefineAlias "$site_4_0.cpd48" "Label19" vTcl:WidgetProc "Toplevel528" 1
    entry $site_4_0.cpd52 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable PTOMNcolEnd -width 5 
    vTcl:DefineAlias "$site_4_0.cpd52" "Entry18" vTcl:WidgetProc "Toplevel528" 1
    pack $site_4_0.lab45 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent49 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd46 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd50 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd47 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd51 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd48 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd52 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd70 \
		-ipad 0 -text {Data Format} 
    vTcl:DefineAlias "$site_3_0.cpd70" "TitleFrame1" vTcl:WidgetProc "Toplevel528" 1
    bind $site_3_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    radiobutton $site_5_0.cpd82 \
		-padx 1 -text Complex -value cmplx -variable InputFormat 
    radiobutton $site_5_0.cpd83 \
		-padx 1 -text Float -value float -variable InputFormat 
    radiobutton $site_5_0.cpd84 \
		-padx 1 -text Integer -value int -variable InputFormat 
    pack $site_5_0.cpd82 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd83 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd84 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd71 \
		-ipad 0 -text Show 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame2" vTcl:WidgetProc "Toplevel528" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    radiobutton $site_5_0.cpd86 \
		-padx 1 -text Modulus -value mod -variable OutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd86" "Radiobutton35" vTcl:WidgetProc "Toplevel528" 1
    radiobutton $site_5_0.cpd71 \
		-padx 1 -text 10log(Mod) -value db10 -variable OutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd71" "Radiobutton43" vTcl:WidgetProc "Toplevel528" 1
    radiobutton $site_5_0.cpd87 \
		-padx 1 -text 20log(Mod) -value db20 -variable OutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd87" "Radiobutton36" vTcl:WidgetProc "Toplevel528" 1
    radiobutton $site_5_0.cpd89 \
		-padx 1 -text Phase -value pha -variable OutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd89" "Radiobutton37" vTcl:WidgetProc "Toplevel528" 1
    radiobutton $site_5_0.cpd90 \
		-padx 1 -text Real -value real -variable OutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd90" "Radiobutton38" vTcl:WidgetProc "Toplevel528" 1
    radiobutton $site_5_0.cpd92 \
		-padx 1 -text Imag -value imag -variable OutputFormat 
    vTcl:DefineAlias "$site_5_0.cpd92" "Radiobutton39" vTcl:WidgetProc "Toplevel528" 1
    pack $site_5_0.cpd86 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd71 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd87 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd89 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd90 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd92 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd72 \
		-ipad 0 -text {Minimum / Maximum Values} 
    vTcl:DefineAlias "$site_3_0.cpd72" "TitleFrame6" vTcl:WidgetProc "Toplevel528" 1
    bind $site_3_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd72 getframe]
    frame $site_5_0.cpd72
    set site_6_0 $site_5_0.cpd72
    frame $site_6_0.fra77 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra77" "Frame3" vTcl:WidgetProc "Toplevel528" 1
    set site_7_0 $site_6_0.fra77
    checkbutton $site_7_0.cpd78 \
		\
		-command {global MinMaxAutoPTOMDisplay
if {"$MinMaxAutoPTOMDisplay"=="1"} {
    $widget(Label528_1) configure -state disable
    $widget(Entry528_1) configure -state disable
    $widget(Label528_2) configure -state disable
    $widget(Entry528_2) configure -state disable
    $widget(Label528_3) configure -state disable
    $widget(Entry528_3) configure -state disable
    $widget(Entry528_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label528_4) configure -state disable
    $widget(Entry528_4) configure -state disable
    $widget(Entry528_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button528_1) configure -state disable
    set MinPTOMDisplay "Auto"
    set MaxPTOMDisplay "Auto"
    set MinCPTOMDisplay ""
    set MaxCPTOMDisplay ""
    } else {
    $widget(Label528_1) configure -state normal
    $widget(Entry528_1) configure -state normal
    $widget(Label528_2) configure -state normal
    $widget(Entry528_2) configure -state normal
    $widget(Label528_3) configure -state normal
    $widget(Entry528_3) configure -state disable
    $widget(Entry528_3) configure -disabledbackground #FFFFFF
    $widget(Label528_4) configure -state normal
    $widget(Entry528_4) configure -state disable
    $widget(Entry528_4) configure -disabledbackground #FFFFFF
    $widget(Button528_1) configure -state normal
    set MinPTOMDisplay "?"
    set MaxPTOMDisplay "?"
    set MinCPTOMDisplay ""
    set MaxCPTOMDisplay ""
    }} \
		-padx 1 -text Automatic -variable MinMaxAutoPTOMDisplay 
    vTcl:DefineAlias "$site_7_0.cpd78" "Checkbutton528_1" vTcl:WidgetProc "Toplevel528" 1
    pack $site_7_0.cpd78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd79 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd79" "Frame4" vTcl:WidgetProc "Toplevel528" 1
    set site_7_0 $site_6_0.cpd79
    checkbutton $site_7_0.cpd78 \
		-padx 1 -text {Enhanced Contrast} -variable MinMaxContrastPTOMDisplay 
    vTcl:DefineAlias "$site_7_0.cpd78" "Checkbutton528_2" vTcl:WidgetProc "Toplevel528" 1
    pack $site_7_0.cpd78 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd66 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd66" "Frame5" vTcl:WidgetProc "Toplevel528" 1
    set site_7_0 $site_6_0.cpd66
    checkbutton $site_7_0.cpd78 \
		\
		-command {global MinMaxAutoPTOMDisplay MinMaxContrastPTOMDisplay MinMaxNormalisationPTOMDisplay

$widget(Label528_1) configure -state disable
$widget(Entry528_1) configure -state disable
$widget(Label528_2) configure -state disable
$widget(Entry528_2) configure -state disable
$widget(Label528_3) configure -state disable
$widget(Entry528_3) configure -state disable
$widget(Entry528_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label528_4) configure -state disable
$widget(Entry528_4) configure -state disable
$widget(Entry528_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button528_1) configure -state disable
set MinPTOMDisplay "Auto"
set MaxPTOMDisplay "Auto"
set MinCPTOMDisplay ""
set MaxCPTOMDisplay ""

if {"$MinMaxNormalisationPTOMDisplay"=="1"} {
    set MinMaxAutoPTOMDisplay 0
    set MinMaxContrastPTOMDisplay 0
    $widget(Checkbutton528_1) configure -state disable
    $widget(Checkbutton528_2) configure -state disable  
    } else {
    set MinMaxAutoPTOMDisplay 1
    set MinMaxContrastPTOMDisplay 0
    $widget(Checkbutton528_1) configure -state normal
    $widget(Checkbutton528_2) configure -state normal  
    }} \
		-padx 1 -text {Normalisation % X [bin]} \
		-variable MinMaxNormalisationPTOMDisplay 
    vTcl:DefineAlias "$site_7_0.cpd78" "Checkbutton45" vTcl:WidgetProc "Toplevel528" 1
    pack $site_7_0.cpd78 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra77 \
		-in $site_6_0 -anchor w -expand 1 -fill none -side top 
    pack $site_6_0.cpd79 \
		-in $site_6_0 -anchor w -expand 1 -fill none -side top 
    pack $site_6_0.cpd66 \
		-in $site_6_0 -anchor w -expand 1 -fill none -side top 
    frame $site_5_0.cpd73
    set site_6_0 $site_5_0.cpd73
    frame $site_6_0.cpd102 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd102" "Frame69" vTcl:WidgetProc "Toplevel528" 1
    set site_7_0 $site_6_0.cpd102
    button $site_7_0.cpd75 \
		-background {#ffff00} \
		-command {global PTOMDisplayFileInput MaxPTOMDisplay MinPTOMDisplay MaxCPTOMDisplay MinCPTOMDisplay TMPMinMaxBmp OpenDirFile
global PTOMNligInit PTOMNcolInit PTOMNligInit PTOMNcolEnd PTOMNcolFullSize

if {$OpenDirFile == 0} {
#read MinMaxPTOMDisplay
set MinMaxPTOMDisplayvalues $TMPMinMaxBmp
DeleteFile $MinMaxPTOMDisplayvalues

set OffsetLig [expr $PTOMNligInit - 1]
set OffsetCol [expr $PTOMNcolInit - 1]
set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]

set MaskCmd ""
set MaskDir [file dirname $PTOMDisplayFileInput]
set MaskFile "$MaskDir/mask_valid_pixels.bin"
if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

set Fonction "Min / Max Values Determination of the Bin File :"
set Fonction2 "$PTOMDisplayFileInput"    
set ProgressLine "0"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
update
TextEditorRunTrace "Process The Function Soft/bin/bmp_process/MinMaxBMP.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$PTOMDisplayFileInput\x22 -ift $InputFormat -oft $OutputFormat -nc $PTOMNcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/bmp_process/MinMaxBMP.exe -if \x22$PTOMDisplayFileInput\x22 -ift $InputFormat -oft $OutputFormat -nc $PTOMNcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

WaitUntilCreated $MinMaxPTOMDisplayvalues
if [file exists $MinMaxPTOMDisplayvalues] {
    set f [open $MinMaxPTOMDisplayvalues r]
    gets $f MaxPTOMDisplay
    gets $f MinPTOMDisplay
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f MaxCPTOMDisplay
    gets $f MinCPTOMDisplay
    close $f
    }
}} \
		-pady 2 -text MinMax 
    vTcl:DefineAlias "$site_7_0.cpd75" "Button528_1" vTcl:WidgetProc "Toplevel528" 1
    bindtags $site_7_0.cpd75 "$site_7_0.cpd75 Button $top all _vTclBalloon"
    bind $site_7_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Find the Min Max values}
    }
    pack $site_7_0.cpd75 \
		-in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.fra67 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra67" "Frame1" vTcl:WidgetProc "Toplevel528" 1
    set site_7_0 $site_6_0.fra67
    label $site_7_0.lab68 \
		-text Min 
    vTcl:DefineAlias "$site_7_0.lab68" "Label528_1" vTcl:WidgetProc "Toplevel528" 1
    label $site_7_0.cpd69 \
		-text {Min E.C} 
    vTcl:DefineAlias "$site_7_0.cpd69" "Label528_3" vTcl:WidgetProc "Toplevel528" 1
    pack $site_7_0.lab68 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd69 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd70 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd70" "Frame6" vTcl:WidgetProc "Toplevel528" 1
    set site_7_0 $site_6_0.cpd70
    entry $site_7_0.ent71 \
		-background white -foreground {#ff0000} -justify center \
		-textvariable MinPTOMDisplay -width 12 
    vTcl:DefineAlias "$site_7_0.ent71" "Entry528_1" vTcl:WidgetProc "Toplevel528" 1
    entry $site_7_0.cpd73 \
		-background white -disabledforeground {#0000ff} -foreground {#0000ff} \
		-justify center -state disabled -textvariable MinCPTOMDisplay \
		-width 12 
    vTcl:DefineAlias "$site_7_0.cpd73" "Entry528_3" vTcl:WidgetProc "Toplevel528" 1
    pack $site_7_0.ent71 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd73 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd74 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd74" "Frame7" vTcl:WidgetProc "Toplevel528" 1
    set site_7_0 $site_6_0.cpd74
    label $site_7_0.lab68 \
		-text Max 
    vTcl:DefineAlias "$site_7_0.lab68" "Label528_2" vTcl:WidgetProc "Toplevel528" 1
    label $site_7_0.cpd69 \
		-text {Max E.C} 
    vTcl:DefineAlias "$site_7_0.cpd69" "Label528_4" vTcl:WidgetProc "Toplevel528" 1
    pack $site_7_0.lab68 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd69 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_6_0.cpd75 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame8" vTcl:WidgetProc "Toplevel528" 1
    set site_7_0 $site_6_0.cpd75
    entry $site_7_0.ent71 \
		-background white -foreground {#ff0000} -justify center \
		-textvariable MaxPTOMDisplay -width 12 
    vTcl:DefineAlias "$site_7_0.ent71" "Entry528_2" vTcl:WidgetProc "Toplevel528" 1
    entry $site_7_0.cpd73 \
		-background white -disabledforeground {#0000ff} -foreground {#0000ff} \
		-justify center -state disabled -textvariable MaxCPTOMDisplay \
		-width 12 
    vTcl:DefineAlias "$site_7_0.cpd73" "Entry528_4" vTcl:WidgetProc "Toplevel528" 1
    pack $site_7_0.ent71 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_7_0.cpd73 \
		-in $site_7_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_6_0.cpd102 \
		-in $site_6_0 -anchor center -expand 1 -fill y -padx 5 -side right 
    pack $site_6_0.fra67 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd70 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd74 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.cpd75 \
		-in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd72 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd73 \
		-in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.cpd69 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd53 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd70 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd72 \
		-in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd75 \
		-ipad 0 -text {Z Ground Profile - Input Data File} 
    vTcl:DefineAlias "$top.cpd75" "TitleFrame9" vTcl:WidgetProc "Toplevel528" 1
    bind $top.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd75 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMDisplayZGroundFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel528" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel528" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd79 \
		\
		-command {global FileName PTOMDisplayDirInput PTOMDisplayZGroundFile
global WarningMessage WarningMessage2 VarAdvice

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $PTOMDisplayDirInput $types "Z-GROUND INPUT FILE"
    
if {$FileName != ""} {
    set PTOMDisplayZGroundFile $FileName   
    } else {
    set PTOMDisplayZGroundFile ""
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-padx 1 -pady 0 -text button 
    bindtags $site_5_0.cpd79 "$site_5_0.cpd79 Button $top all _vTclBalloon"
    bind $site_5_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd79 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
		-in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd66 \
		-ipad 0 -text {Z Top Profile - Input Data File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame10" vTcl:WidgetProc "Toplevel528" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable PTOMDisplayZTopFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh10" vTcl:WidgetProc "Toplevel528" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame23" vTcl:WidgetProc "Toplevel528" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd79 \
		\
		-command {global FileName PTOMDisplayDirInput PTOMDisplayZTopFile
global WarningMessage WarningMessage2 VarAdvice

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $PTOMDisplayDirInput $types "Z-TOP INPUT FILE"
    
if {$FileName != ""} {
    set PTOMDisplayZTopFile $FileName   
    } else {
    set PTOMDisplayZTopFile ""
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-padx 1 -pady 0 -text button 
    bindtags $site_5_0.cpd79 "$site_5_0.cpd79 Button $top all _vTclBalloon"
    bind $site_5_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd79 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
		-in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.fra74 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame2" vTcl:WidgetProc "Toplevel528" 1
    set site_3_0 $top.fra74
    frame $site_3_0.cpd71 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd71" "Frame27" vTcl:WidgetProc "Toplevel528" 1
    set site_4_0 $site_3_0.cpd71
    label $site_4_0.lab68 \
		-text {Label ( X )} 
    vTcl:DefineAlias "$site_4_0.lab68" "Label10" vTcl:WidgetProc "Toplevel528" 1
    entry $site_4_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} \
		-textvariable PTOMDisplayLabelX 
    vTcl:DefineAlias "$site_4_0.ent69" "Entry10" vTcl:WidgetProc "Toplevel528" 1
    pack $site_4_0.lab68 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent69 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd70 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd70" "Frame19" vTcl:WidgetProc "Toplevel528" 1
    set site_4_0 $site_3_0.cpd70
    frame $site_4_0.fra67 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra67" "Frame24" vTcl:WidgetProc "Toplevel528" 1
    set site_5_0 $site_4_0.fra67
    label $site_5_0.lab68 \
		-text X_min 
    vTcl:DefineAlias "$site_5_0.lab68" "Label7" vTcl:WidgetProc "Toplevel528" 1
    entry $site_5_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -justify center -state disabled \
		-textvariable PTOMxmin -width 7 
    vTcl:DefineAlias "$site_5_0.ent69" "Entry7" vTcl:WidgetProc "Toplevel528" 1
    pack $site_5_0.lab68 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent69 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd70 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame25" vTcl:WidgetProc "Toplevel528" 1
    set site_5_0 $site_4_0.cpd70
    label $site_5_0.lab68 \
		-text X_max 
    vTcl:DefineAlias "$site_5_0.lab68" "Label8" vTcl:WidgetProc "Toplevel528" 1
    entry $site_5_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -justify center -state disabled \
		-textvariable PTOMxmax -width 7 
    vTcl:DefineAlias "$site_5_0.ent69" "Entry8" vTcl:WidgetProc "Toplevel528" 1
    pack $site_5_0.lab68 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent69 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd71 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame26" vTcl:WidgetProc "Toplevel528" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab68 \
		-text X_unit 
    vTcl:DefineAlias "$site_5_0.lab68" "Label9" vTcl:WidgetProc "Toplevel528" 1
    entry $site_5_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -justify center -state disabled \
		-textvariable PTOMxdim -width 5 
    vTcl:DefineAlias "$site_5_0.ent69" "Entry9" vTcl:WidgetProc "Toplevel528" 1
    pack $site_5_0.lab68 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent69 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra67 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd70 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd71 \
		-in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd70 \
		-in $site_3_0 -anchor center -expand 1 -fill x -side left 
    frame $top.cpd72 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame28" vTcl:WidgetProc "Toplevel528" 1
    set site_3_0 $top.cpd72
    frame $site_3_0.cpd71 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd71" "Frame29" vTcl:WidgetProc "Toplevel528" 1
    set site_4_0 $site_3_0.cpd71
    label $site_4_0.lab68 \
		-text {Label ( Z )} 
    vTcl:DefineAlias "$site_4_0.lab68" "Label11" vTcl:WidgetProc "Toplevel528" 1
    entry $site_4_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} \
		-textvariable PTOMDisplayLabelY 
    vTcl:DefineAlias "$site_4_0.ent69" "Entry11" vTcl:WidgetProc "Toplevel528" 1
    pack $site_4_0.lab68 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent69 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd70 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd70" "Frame30" vTcl:WidgetProc "Toplevel528" 1
    set site_4_0 $site_3_0.cpd70
    frame $site_4_0.fra67 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra67" "Frame31" vTcl:WidgetProc "Toplevel528" 1
    set site_5_0 $site_4_0.fra67
    label $site_5_0.lab68 \
		-text Z_min 
    vTcl:DefineAlias "$site_5_0.lab68" "Label12" vTcl:WidgetProc "Toplevel528" 1
    entry $site_5_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -justify center -state disabled \
		-textvariable PTOMzmin -width 7 
    vTcl:DefineAlias "$site_5_0.ent69" "Entry12" vTcl:WidgetProc "Toplevel528" 1
    pack $site_5_0.lab68 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent69 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd70 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame32" vTcl:WidgetProc "Toplevel528" 1
    set site_5_0 $site_4_0.cpd70
    label $site_5_0.lab68 \
		-text Z_max 
    vTcl:DefineAlias "$site_5_0.lab68" "Label13" vTcl:WidgetProc "Toplevel528" 1
    entry $site_5_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -justify center -state disabled \
		-textvariable PTOMzmax -width 7 
    vTcl:DefineAlias "$site_5_0.ent69" "Entry13" vTcl:WidgetProc "Toplevel528" 1
    pack $site_5_0.lab68 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent69 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd71 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame33" vTcl:WidgetProc "Toplevel528" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab68 \
		-text Z_unit 
    vTcl:DefineAlias "$site_5_0.lab68" "Label14" vTcl:WidgetProc "Toplevel528" 1
    entry $site_5_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -justify center -state disabled \
		-textvariable PTOMzdim -width 5 
    vTcl:DefineAlias "$site_5_0.ent69" "Entry14" vTcl:WidgetProc "Toplevel528" 1
    pack $site_5_0.lab68 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent69 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra67 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd70 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd71 \
		-in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd70 \
		-in $site_3_0 -anchor center -expand 1 -fill x -side left 
    frame $top.cpd67 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd67" "Frame17" vTcl:WidgetProc "Toplevel528" 1
    set site_3_0 $top.cpd67
    label $site_3_0.cpd69 \
		-text {Tomogram Display Title} 
    vTcl:DefineAlias "$site_3_0.cpd69" "Label15" vTcl:WidgetProc "Toplevel528" 1
    entry $site_3_0.cpd68 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} \
		-textvariable PTOMDisplayTitle -width 30 
    vTcl:DefineAlias "$site_3_0.cpd68" "EntryTopXXCh19" vTcl:WidgetProc "Toplevel528" 1
    TitleFrame $site_3_0.cpd66 \
		-ipad 0 -text {Display Size} 
    vTcl:DefineAlias "$site_3_0.cpd66" "TitleFrame3" vTcl:WidgetProc "Toplevel528" 1
    bind $site_3_0.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd66 getframe]
    frame $site_5_0.cpd68 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame35" vTcl:WidgetProc "Toplevel528" 1
    set site_6_0 $site_5_0.cpd68
    label $site_6_0.lab68 \
		-text Col 
    vTcl:DefineAlias "$site_6_0.lab68" "Label17" vTcl:WidgetProc "Toplevel528" 1
    entry $site_6_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMGifCol -width 5 
    vTcl:DefineAlias "$site_6_0.ent69" "Entry16" vTcl:WidgetProc "Toplevel528" 1
    pack $site_6_0.lab68 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent69 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd67 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd67" "Frame34" vTcl:WidgetProc "Toplevel528" 1
    set site_6_0 $site_5_0.cpd67
    label $site_6_0.lab68 \
		-text Row 
    vTcl:DefineAlias "$site_6_0.lab68" "Label16" vTcl:WidgetProc "Toplevel528" 1
    entry $site_6_0.ent69 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} -justify center \
		-textvariable PTOMGifLig -width 5 
    vTcl:DefineAlias "$site_6_0.ent69" "Entry15" vTcl:WidgetProc "Toplevel528" 1
    pack $site_6_0.lab68 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent69 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd68 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd67 \
		-in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
		-in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd68 \
		-in $site_3_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    pack $site_3_0.cpd66 \
		-in $site_3_0 -anchor center -expand 0 -fill none -padx 10 \
		-side right 
    frame $top.fra38 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel528" 1
    set site_3_0 $top.fra38
    button $site_3_0.but93 \
		-background {#ffff00} \
		-command {global PTOMDisplayDirOutput PTOMDisplayFileOutput PTOMNligInit 
global PTOMDisplayFileInput PTOMDisplayFileMask MaskCmd
global PTOMDisplayZGroundFile PTOMDisplayZTopFile
global PTOMxmin PTOMxmax PTOMzmin PTOMzmax
global MinMaxAutoPTOMDisplay MinMaxContrastPTOMDisplay MinMaxNormalisationPTOMDisplay
global InputFormat OutputFormat MinPTOMDisplay MaxPTOMDisplay MinCPTOMDisplay MaxCPTOMDisplay
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPPTOMDisplayFileOutputXtxt TMPPTOMDisplayFileOutputXbin
global TMPPTOMDisplayFileOutputXYbin TMPPTOMDisplayFileOutputXYtxt
global PTOMDisplayZGroundFile PTOMDisplayZTopFile
global PTOMDisplayFileZGround PTOMDisplayFileZTop


if {$OpenDirFile == 0} {

if {"$PTOMNligInit"!="0"} {
    set config "true"
    if {"$PTOMDisplayFileInput"==""} {
        set config "false"
        set VarError ""
        set ErrorMessage "INVALID INPUT DATA FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {"$config"=="true"} {
        set VarWarning "ok"
        if {"$VarWarning"=="ok"} {
           if {$MinMaxAutoPTOMDisplay == 0} {
                if {$MinMaxContrastPTOMDisplay == 0} {set MinMaxPTOMDisplay 0}
                if {$MinMaxContrastPTOMDisplay == 1} {set MinMaxPTOMDisplay 2}
                }            
            if {$MinMaxAutoPTOMDisplay == 1} {
                if {$MinMaxContrastPTOMDisplay == 0} {set MinMaxPTOMDisplay 3}
                if {$MinMaxContrastPTOMDisplay == 1} {set MinMaxPTOMDisplay 1}
                set MinPTOMDisplay "-9999"
                set MaxPTOMDisplay "+9999"
                }
            if {$MinMaxNormalisationPTOMDisplay == 1} {
                set MinMaxPTOMDisplay 4
                set MinPTOMDisplay "-9999"
                set MaxPTOMDisplay "+9999"
                }

            set TestVarName(0) "Min Value"; set TestVarType(0) "float"; set TestVarValue(0) $MinPTOMDisplay; set TestVarMin(0) "-10000.00"; set TestVarMax(0) "10000.00"
            set TestVarName(1) "Max Value"; set TestVarType(1) "float"; set TestVarValue(1) $MaxPTOMDisplay; set TestVarMin(1) "-10000.00"; set TestVarMax(1) "10000.00"
            TestVar 2
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $PTOMNligInit - 1]
                set OffsetCol [expr $PTOMNcolInit - 1]
                set FinalNlig [expr $PTOMNligEnd - $PTOMNligInit + 1]
                set FinalNcol [expr $PTOMNcolEnd - $PTOMNcolInit + 1]
    
                DeleteFile $TMPPTOMDisplayFileOutputXbin
                DeleteFile $TMPPTOMDisplayFileOutputXtxt
                DeleteFile $TMPPTOMDisplayFileOutputXYbin
                DeleteFile $TMPPTOMDisplayFileOutputXYtxt
               
                set MaskCmd ""
                if {$PTOMDisplayFileMask != ""} { set MaskCmd "-mask \x22$MaskFile\x22" }
                set Fonction "Creation of the PTOMDisplay File :"
                set Fonction2 "$PTOMDisplayFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/prepare_tomo_display.exe" "k"
                TextEditorRunTrace "Arguments: -if \x22$PTOMDisplayFileInput\x22 -obf \x22$TMPPTOMDisplayFileOutputXbin\x22 -otf \x22$TMPPTOMDisplayFileOutputXtxt\x22 -ift $InputFormat -oft $OutputFormat -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxPTOMDisplay -min $MinPTOMDisplay -max $MaxPTOMDisplay $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/prepare_tomo_display.exe -if \x22$PTOMDisplayFileInput\x22 -obf \x22$TMPPTOMDisplayFileOutputXbin\x22 -otf \x22$TMPPTOMDisplayFileOutputXtxt\x22 -ift $InputFormat -oft $OutputFormat -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxPTOMDisplay -min $MinPTOMDisplay -max $MaxPTOMDisplay $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                WaitUntilCreated $TMPPTOMDisplayFileOutputXtxt
                set ff [open $TMPPTOMDisplayFileOutputXtxt w]
                puts $ff $PTOMxmin
                puts $ff $PTOMxmax
                puts $ff $PTOMzmin
                puts $ff $PTOMzmax
                close $ff

                set PTOMDisplayFileZGround "nofile"
                if {$PTOMDisplayZGroundFile != ""} { set PTOMDisplayFileZGround $PTOMDisplayZGroundFile}
                set PTOMDisplayFileZTop "nofile"
                if {$PTOMDisplayZTopFile != ""} { set PTOMDisplayFileZTop $PTOMDisplayZTopFile}

                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_tomo_display.exe" "k"
                TextEditorRunTrace "Arguments: -ifb \x22$TMPPTOMDisplayFileOutputXbin\x22 -ift \x22$TMPPTOMDisplayFileOutputXtxt\x22 -igf \x22$PTOMDisplayFileZGround\x22 -itf \x22$PTOMDisplayFileZTop\x22 -ofb \x22$TMPPTOMDisplayFileOutputXYbin\x22 -oft \x22$TMPPTOMDisplayFileOutputXYtxt\x22 -fnr $FinalNlig -fnc $FinalNcol $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/create_tomo_display.exe -ifb \x22$TMPPTOMDisplayFileOutputXbin\x22 -ift \x22$TMPPTOMDisplayFileOutputXtxt\x22 -igf \x22$PTOMDisplayFileZGround\x22 -itf \x22$PTOMDisplayFileZTop\x22 -ofb \x22$TMPPTOMDisplayFileOutputXYbin\x22 -oft \x22$TMPPTOMDisplayFileOutputXYtxt\x22 -fnr $FinalNlig -fnc $FinalNcol $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                WaitUntilCreated $TMPPTOMDisplayFileOutputXYbin

                PsPPTOMDisplay
                $widget(Button528_3) configure -state normal
                $widget(Button528_4) configure -state normal
                }
            } else {
            if {"$VarWarning"=="no"} {Window hide $widget(Toplevel528); TextEditorRunTrace "Close Window Create PTOMDisplay File" "b"}
            }
        }
    } else {
        set VarError ""
        set ErrorMessage "ENTER A VALID INPUT DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
}} \
		-padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel528" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but66 \
		-background {#ffff00} \
		-command {global ErrorMessage VarError VarSaveGnuPlotFile
global GnuplotPipeFid SaveDisplayDirOutput PTOMDisplayDirOutput
global SaveDisplayOutputFile1

#BMP_PROCESS
global Load_SaveDisplay1 PSPTopLevel

if {$GnuplotPipeFid == ""} {
    set ErrorMessage "GNUPLOT IS NOT RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

    if {$Load_SaveDisplay1 == 0} {
        source "GUI/bmp_process/SaveDisplay1.tcl"
        set Load_SaveDisplay1 1
        WmTransient $widget(Toplevel456) $PSPTopLevel
        }

    set SaveDisplayOutputFile1 "Tomogram_Display"
    set SaveDisplayDirOutput $PTOMDisplayDirOutput
    
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel528) $widget(Toplevel456); TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
		-image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
		-pady 0 
    vTcl:DefineAlias "$site_3_0.but66" "Button528_3" vTcl:WidgetProc "Toplevel528" 1
    bindtags $site_3_0.but66 "$site_3_0.but66 Button $top all _vTclBalloon"
    bind $site_3_0.but66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Save}
    }
    button $site_3_0.but67 \
		-background {#ffffff} \
		-command {global TMPGnuPlotTk1 

Gimp $TMPGnuPlotTk1} \
		-image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but67" "Button528_4" vTcl:WidgetProc "Toplevel528" 1
    button $site_3_0.but23 \
		-background {#ff8000} \
		-command {HelpPdfEdit "Help/CreatePolTomoDisplay.pdf"} \
		-image [vTcl:image:get_image [file join . GUI Images help.gif]] \
		-pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel528" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
		-background {#ffff00} \
		-command {global DisplayMainMenu GnuplotPipeFid OpenDirFile Load_SaveDisplay1 

if {$OpenDirFile == 0} {
if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}
set GnuplotPipeFid ""
Window hide .top401tomo
Window hide $widget(Toplevel528); TextEditorRunTrace "Close Window Create Tomogram Display File" "b"
}} \
		-padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel528" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but66 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but67 \
		-in $site_3_0 -anchor center -expand 1 -fill none -ipadx 1 -ipady 1 \
		-side left 
    pack $site_3_0.but23 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra67 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd75 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
		-in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd72 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra38 \
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
Window show .top528

main $argc $argv
