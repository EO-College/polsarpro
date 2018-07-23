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
    
    # Needs Itcl
    package require Itcl

    # Needs Itk
    package require Itk

    # Needs Iwidgets
    package require Iwidgets

    switch $tcl_platform(platform) {
	windows {
            option add *Pushbutton.padY         0
	}
	default {
	    option add *Scrolledhtml.sbWidth    10
	    option add *Scrolledtext.sbWidth    10
	    option add *Scrolledlistbox.sbWidth 10
	    option add *Scrolledframe.sbWidth   10
	    option add *Hierarchy.sbWidth       10
            option add *Pushbutton.padY         2
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
    set base .top396
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd78 {
        array set save {-borderwidth 1 -foreground 1 -ipad 1}
    }
    set site_4_0 [$base.cpd78 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.scr67 {
        array set save {-listvariable 1}
    }
    namespace eval ::widgets::$site_5_0.scr70 {
        array set save {-listvariable 1}
    }
    namespace eval ::widgets::$site_5_0.fra71 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_6_0 $site_5_0.fra71
    namespace eval ::widgets::$site_6_0.but72 {
        array set save {-command 1 -foreground 1 -highlightcolor 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.but73 {
        array set save {-command 1 -foreground 1 -highlightcolor 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.but74 {
        array set save {-command 1 -foreground 1 -highlightcolor 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.but75 {
        array set save {-command 1 -foreground 1 -highlightcolor 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra99 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_3_0 $base.fra99
    namespace eval ::widgets::$site_3_0.but100 {
        array set save {-background 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd101 {
        array set save {-_tooltip 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m71 {
        array set save {-activeborderwidth 1 -borderwidth 1 -cursor 1 -foreground 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top396
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

proc vTclWindow.top396 {base} {
    if {$base == ""} {
        set base .top396
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m71" -highlightcolor black 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 400x240+600+100; update
    wm maxsize $top 1284 1008
    wm minsize $top 150 15
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Select Polarimetric Indicators"
    vTcl:DefineAlias "$top" "Toplevel396" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd78 \
        -borderwidth 0 -foreground black -ipad 2 
    vTcl:DefineAlias "$top.cpd78" "TitleFrame5" vTcl:WidgetProc "Toplevel396" 1
    bind $top.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd78 getframe]
    label $site_4_0.lab69 \
        -text {Add or remove polarimetric indicator (No complex file !)} 
    vTcl:DefineAlias "$site_4_0.lab69" "Label2" vTcl:WidgetProc "Toplevel396" 1
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame481" vTcl:WidgetProc "Toplevel396" 1
    set site_5_0 $site_4_0.cpd72
    ::iwidgets::scrolledlistbox $site_5_0.scr67 \
        -listvariable PolarIndicSaveList 
    vTcl:DefineAlias "$site_5_0.scr67" "Scrolledlistbox1" vTcl:WidgetProc "Toplevel396" 1
    ::iwidgets::scrolledlistbox $site_5_0.scr70 \
        -listvariable TMPBinFiles 
    vTcl:DefineAlias "$site_5_0.scr70" "Scrolledlistbox2" vTcl:WidgetProc "Toplevel396" 1
    frame $site_5_0.fra71 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_5_0.fra71" "Frame1" vTcl:WidgetProc "Toplevel396" 1
    set site_6_0 $site_5_0.fra71
    button $site_6_0.but72 \
        \
        -command {global TMPBinFiles PolarIndicSaveList

set listName $PolarIndicSaveList
set element [selection get]

set list $listName
   if {[lsearch $list $element]<0} {lappend list $element}
     set list
     
     set PolarIndicSaveList $list} \
        -foreground black -highlightcolor black -pady 0 -text -> 
    vTcl:DefineAlias "$site_6_0.but72" "Button1" vTcl:WidgetProc "Toplevel396" 1
    button $site_6_0.but73 \
        \
        -command {global TMPBinFiles PolarIndicSaveList
set list $PolarIndicSaveList
set element [selection get]

set pos [lsearch $list $element]
     set list [lreplace $list $pos $pos]
     
    set PolarIndicSaveList $list} \
        -foreground black -highlightcolor black -pady 0 -text <- 
    vTcl:DefineAlias "$site_6_0.but73" "Button2" vTcl:WidgetProc "Toplevel396" 1
    button $site_6_0.but74 \
        \
        -command {global TMPBinFiles PolarIndicSaveList
set PolarIndicSaveList $TMPBinFiles} \
        -foreground black -highlightcolor black -pady 0 -text >> 
    vTcl:DefineAlias "$site_6_0.but74" "Button3" vTcl:WidgetProc "Toplevel396" 1
    bindtags $site_6_0.but74 "$site_6_0.but74 Button $top all _TopLevel"
    button $site_6_0.but75 \
        \
        -command {global TMPBinFiles PolarIndicSaveList
set PolarIndicSaveList {}} \
        -foreground black -highlightcolor black -pady 0 -text << 
    vTcl:DefineAlias "$site_6_0.but75" "Button4" vTcl:WidgetProc "Toplevel396" 1
    pack $site_6_0.but72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.but73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.but74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.but75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.scr67 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side right 
    pack $site_5_0.scr70 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra71 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.lab69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra99 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$top.fra99" "Frame2" vTcl:WidgetProc "Toplevel396" 1
    set site_3_0 $top.fra99
    button $site_3_0.but100 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/data_process_sngl/SVMSupervisedClassification.pdf"} \
        \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -padx 4 -pady 2 -text button 
    vTcl:DefineAlias "$site_3_0.but100" "Button5" vTcl:WidgetProc "Toplevel396" 1
    button $site_3_0.cpd101 \
        -background #ffff00 \
        -command {global OpenDirFile PolarIndicSaveList RBFGamma RBFGammaVar Npolar
global SupervisedDirInput FileName VarError ErrorMessage
global PolarIndicBinFile ENVIHdrFile ENVICommonFormatFlag
global PolarIndicFloatFlag Kernel
global PolarIndicSaveList PolarFiles TMPBinFiles

global PolarIndic DataFormatActive StandardPol
global PolarIndicFloatFlag RBFGamma RBFGammaVar 

if {$PolarIndicFloatFlag == 0} {
    set PolarIndicFloatFlag 1
    }
set PolarFiles ""
set i 0
foreach line $PolarIndicSaveList {
    set name [file tail $line]
    append PolarFiles $name; append PolarFiles " "
    incr i 
}
set Npolar $i

if {$Npolar != 0} {
    set RBFGamma [expr 4.*1./$Npolar]
    if {$RBFGamma > 1} { set RBFGamma 1 }
    set RBFGammaVar $RBFGamma
    } else {
    set StandardPol "1"
    set PolarIndicFloatFlag "0"
    set PolarIndic $DataFormatActive
    $widget(Button394_5) configure -state disable
    if {$PolarIndic == "Ipp"} {
          set Npolar "4"
          set PolarFiles "I11.bin I22.bin I12.bin I21.bin"
        }
    
      if {$PolarIndic == "C2"} {
          set Npolar "4"
          set PolarFiles "C11.bin C22.bin C12_real.bin C12_imag.bin"
        }
    
      if {$PolarIndic == "C3"} {
          set Npolar "9"
          set PolarFiles "C11.bin C22.bin C33.bin C12_real.bin C12_imag.bin C13_real.bin C13_imag.bin C23_real.bin C23_imag.bin"
        }
    
    if {$PolarIndic == "C4"} {
          set Npolar "16"
          set PolarFiles "C11.bin C22.bin C33.bin C44.bin C12_real.bin C12_imag.bin C13_real.bin C13_imag.bin C14_real.bin C14_imag.bin C23_real.bin C23_imag.bin C24_real.bin C24_imag.bin C34_real.bin C34_imag.bin"
        }
    
        if {$PolarIndic == "T3"} {
          set Npolar "9"
          set PolarFiles "T11.bin T22.bin T33.bin T12_real.bin T12_imag.bin T13_real.bin T13_imag.bin T23_real.bin T23_imag.bin"
        }
    
    if {$PolarIndic == "T4"} {
          set Npolar "16"
          set PolarFiles "C11.bin T22.bin T33.bin T44.bin T12_real.bin T12_imag.bin T13_real.bin T13_imag.bin T14_real.bin T14_imag.bin T23_real.bin T23_imag.bin T24_real.bin T24_imag.bin T34_real.bin T34_imag.bin"
        }
    
    InitRBF
    }
Window hide $widget(Toplevel396); TextEditorRunTrace "Close Window SVM Polarimetric Indicator Selection" "b"} \
        -foreground black -highlightcolor black -padx 4 -pady 2 \
        -text {Exit and Save} 
    vTcl:DefineAlias "$site_3_0.cpd101" "Button67" vTcl:WidgetProc "Toplevel396" 1
    bindtags $site_3_0.cpd101 "$site_3_0.cpd101 Button $top all _vTclBalloon"
    bind $site_3_0.cpd101 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but100 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd101 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -cursor {} -foreground black 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd78 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.fra99 \
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
Window show .top396

main $argc $argv
