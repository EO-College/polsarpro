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

        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top417
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd90 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd90
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd103 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra69
    namespace eval ::widgets::$site_3_0.rad70 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd103 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd103 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$base.fra65 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra65
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but68 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
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
            vTclWindow.top417
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

proc vTclWindow.top417 {base} {
    if {$base == ""} {
        set base .top417
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
    wm geometry $top 500x200+160+100; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Complex Data File"
    vTcl:DefineAlias "$top" "Toplevel417" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd90 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd90" "Frame3" vTcl:WidgetProc "Toplevel417" 1
    set site_3_0 $top.cpd90
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Complex Binary Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel417" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileNameInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel417" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel417" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd103 \
        \
        -command {global FileName FileNameInput FileNameOutput1 FileNameOutput2
global VarError ErrorMessage CmplxOutputFormat
global NligCmplx NcolCmplx

set FileNameInput ""
set FileNameOutput1 ""
set FileNameOutput2 ""
set NligCmplx ""
set NcolCmplx ""
set CmplxOutputFormat " "

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $DataDir $types "INPUT COMPLEX DATA FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; set NcolCmplx [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; set NligCmplx [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {$tmp == "data type = 6"} {
                set CmplxOutputFormat "realimag"
                set FileNameInput $FileName
                set FileNameOutput1 [file rootname $FileNameInput]
                append FileNameOutput1 "_real.bin"
                set FileNameOutput2 [file rootname $FileNameInput]
                append FileNameOutput2 "_imag.bin"
                } else {
                set ErrorMessage "NOT A PolSARpro COMPLEX BINARY DATA FILE"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                if {$VarError == "cancel"} {Window hide $widget(Toplevel417); TextEditorRunTrace "Close Window Complex Data File" "b"}
                }    
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            if {$VarError == "cancel"} {Window hide $widget(Toplevel417); TextEditorRunTrace "Close Window Complex Data File" "b"}
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        if {$VarError == "cancel"} {Window hide $widget(Toplevel417); TextEditorRunTrace "Close Window Complex Data File" "b"}
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd103" "Button27" vTcl:WidgetProc "Toplevel417" 1
    bindtags $site_6_0.cpd103 "$site_6_0.cpd103 Button $top all _vTclBalloon"
    bind $site_6_0.cpd103 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd103 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra69" "Frame1" vTcl:WidgetProc "Toplevel417" 1
    set site_3_0 $top.fra69
    radiobutton $site_3_0.rad70 \
        \
        -command {global FileNameInput FileNameOutput1 FileNameOutput2

set FileNameOutput1 [file rootname $FileNameInput]
append FileNameOutput1 "_real.bin"
set FileNameOutput2 [file rootname $FileNameInput]
append FileNameOutput2 "_imag.bin"} \
        -text {Complex to Real / Imag} -value realimag \
        -variable CmplxOutputFormat 
    vTcl:DefineAlias "$site_3_0.rad70" "Radiobutton1" vTcl:WidgetProc "Toplevel417" 1
    radiobutton $site_3_0.cpd71 \
        \
        -command {global FileNameInput FileNameOutput1 FileNameOutput2

set FileNameOutput1 [file rootname $FileNameInput]
append FileNameOutput1 "_mod.bin"
set FileNameOutput2 [file rootname $FileNameInput]
append FileNameOutput2 "_pha.bin"} \
        -text {Complex to Mod / Pha (deg)} -value modargdeg \
        -variable CmplxOutputFormat 
    vTcl:DefineAlias "$site_3_0.cpd71" "Radiobutton2" vTcl:WidgetProc "Toplevel417" 1
    radiobutton $site_3_0.cpd72 \
        \
        -command {global FileNameInput FileNameOutput1 FileNameOutput2

set FileNameOutput1 [file rootname $FileNameInput]
append FileNameOutput1 "_mod.bin"
set FileNameOutput2 [file rootname $FileNameInput]
append FileNameOutput2 "_pha.bin"} \
        -text {Complex to Mod / Pha (rad)} -value modargrad \
        -variable CmplxOutputFormat 
    vTcl:DefineAlias "$site_3_0.cpd72" "Radiobutton3" vTcl:WidgetProc "Toplevel417" 1
    pack $site_3_0.rad70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Output Binary Data File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame8" vTcl:WidgetProc "Toplevel417" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.cpd67
    set site_5_0 $site_4_0.cpd67
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileNameOutput1 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel417" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel417" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd103 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -state disabled -text button 
    vTcl:DefineAlias "$site_6_0.cpd103" "Button29" vTcl:WidgetProc "Toplevel417" 1
    pack $site_6_0.cpd103 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 8 -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd68
    set site_5_0 $site_4_0.cpd68
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileNameOutput2 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh10" vTcl:WidgetProc "Toplevel417" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel417" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd103 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -state disabled -text button 
    vTcl:DefineAlias "$site_6_0.cpd103" "Button30" vTcl:WidgetProc "Toplevel417" 1
    pack $site_6_0.cpd103 \
        -in $site_6_0 -anchor center -expand 0 -fill none -ipadx 8 -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    frame $top.fra65 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra65" "Frame20" vTcl:WidgetProc "Toplevel417" 1
    set site_3_0 $top.fra65
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global FileNameInput FileNameOutput1 FileNameOutput2
global Fonction Fonction2 ProgressLine CmplxOutputFormat
global NligCmplx NcolCmplx TMPMemoryAllocError

if {$OpenDirFile == 0} {
    set FileDirInput [file dirname $FileNameInput]
    set MaskCmd ""
    set MaskFile "$FileDirInput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set Fonction "Complex Binary Data File"
    set Fonction2 ""
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    if {$CmplxOutputFormat == "realimag"} {
        TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput1\x22 -ot float -op real -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calculator/file_operand.exe -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput1\x22 -ot float -op real -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput2\x22 -ot float -op imag -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calculator/file_operand.exe -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput2\x22 -ot float -op imag -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        }
    if {$CmplxOutputFormat == "modargdeg"} {
        TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput1\x22 -ot float -op abs -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calculator/file_operand.exe -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput1\x22 -ot float -op abs -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput2\x22 -ot float -op arg -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calculator/file_operand.exe -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput2\x22 -ot float -op arg -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        }
    if {$CmplxOutputFormat == "modargrad"} {
        TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput1\x22 -ot float -op abs -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calculator/file_operand.exe -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput1\x22 -ot float -op abs -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        TextEditorRunTrace "Process The Function Soft/bin/calculator/file_operand.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput2\x22 -ot float -op argrad -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/calculator/file_operand.exe -if \x22$FileNameInput\x22 -it cmplx -of \x22$FileNameOutput2\x22 -ot float -op argrad -ofr 0 -ofc 0 -fnr $NligCmplx -fnc $NcolCmplx -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    if [file exists $FileNameOutput1] {EnviWriteConfig $FileNameOutput1 $NligCmplx $NcolCmplx 4}
    if [file exists $FileNameOutput2] {EnviWriteConfig $FileNameOutput2 $NligCmplx $NcolCmplx 4}
    }} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel417" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but68 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DataFileManagement.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but68" "Button1" vTcl:WidgetProc "Toplevel417" 1
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel417); TextEditorRunTrace "Close Window Complex Data File" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel417" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd90 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra69 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra65 \
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
Window show .top417

main $argc $argv
