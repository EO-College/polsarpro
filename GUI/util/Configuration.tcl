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

        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top341
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.lab75 {
        array set save {-height 1 -image 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$base.fra78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra78
    namespace eval ::widgets::$site_3_0.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra79
    namespace eval ::widgets::$site_4_0.tit66 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.tit66 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.tit82 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.tit82 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {-borderwidth 1}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd69
    namespace eval ::widgets::$site_7_0.but70 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$base.fra341 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra341
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd75 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
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

proc ::main {argc argv} {}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {}

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
    wm maxsize $top 2964 1035
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

proc vTclWindow.top341 {base} {
    if {$base == ""} {
        set base .top341
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
    wm geometry $top 450x190+200+200; update
    wm maxsize $top 1604 1185
    wm minsize $top 104 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Configuration"
    vTcl:DefineAlias "$top" "Toplevel341" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame1" vTcl:WidgetProc "Toplevel341" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab75 \
        -height 20 \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -text { } -width 20 
    vTcl:DefineAlias "$site_3_0.lab75" "Label341_1" vTcl:WidgetProc "Toplevel341" 1
    label $site_3_0.lab76 \
        -text {PDF READER} 
    vTcl:DefineAlias "$site_3_0.lab76" "Label341_2" vTcl:WidgetProc "Toplevel341" 1
    pack $site_3_0.lab75 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.lab76 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    frame $top.fra78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra78" "Frame2" vTcl:WidgetProc "Toplevel341" 1
    set site_3_0 $top.fra78
    frame $site_3_0.fra79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra79" "Frame3" vTcl:WidgetProc "Toplevel341" 1
    set site_4_0 $site_3_0.fra79
    TitleFrame $site_4_0.tit66 \
        -ipad 2 -text {Research one of the following exe files} 
    vTcl:DefineAlias "$site_4_0.tit66" "TitleFrame2" vTcl:WidgetProc "Toplevel341" 1
    bind $site_4_0.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.tit66 getframe]
    entry $site_6_0.cpd69 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ConfigFileNameVar -width 60 
    vTcl:DefineAlias "$site_6_0.cpd69" "Entry2" vTcl:WidgetProc "Toplevel341" 1
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill x -padx 5 -side top 
    TitleFrame $site_4_0.tit82 \
        -text {Path Name} 
    vTcl:DefineAlias "$site_4_0.tit82" "TitleFrame1" vTcl:WidgetProc "Toplevel341" 1
    bind $site_4_0.tit82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.tit82 getframe]
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ConfigFileNamePath 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry1" vTcl:WidgetProc "Toplevel341" 1
    frame $site_6_0.cpd69 \
        -borderwidth 1 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd69" "Frame4" vTcl:WidgetProc "Toplevel341" 1
    set site_7_0 $site_6_0.cpd69
    button $site_7_0.but70 \
        \
        -command {global FileName DataDirInit ConfigFileNamePath PlatForm

set ConfigFileNamePathTmp $ConfigFileNamePath

if {$PlatForm == "windows"} {
    set types {
        {{EXE Files}        {.exe}   }
        }
    } else {
    set types {
        {{All Files}        *        }
        }
    }
set FileName ""
OpenFile $DataDirInit $types "EXE FILE"
    
if {$FileName != ""} {
    set ConfigFileNamePath $FileName
    } else {
    set ConfigFileNamePath $ConfigFileNamePathTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_7_0.but70" "Button1" vTcl:WidgetProc "Toplevel341" 1
    pack $site_7_0.but70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.tit66 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.tit82 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    pack $site_3_0.fra79 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra341 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra341" "Frame6" vTcl:WidgetProc "Toplevel341" 1
    set site_3_0 $top.fra341
    button $site_3_0.but74 \
        -background #ffff00 \
        -command {global OpenDirFile ConfigFileNameSearch ConfigFileNamePath  VarConfigFileName 
global PDFReader GoogleEarthReader GimpReader SnapReader SnapGpt S1tbxReader MapReadyReader ImageMagickMaker

if {$OpenDirFile == 0} {

    if {$ConfigFileNameSearch == "PDF"} {
        set PDFReader $ConfigFileNamePath
        if {$PlatForm == "windows"} {
            if {$PDFReader != ""} {
                set f [open "$CONFIGDir/PDFReaderWindows.txt" w]
                puts $f $PDFReader
                close $f
                }
            }
        if {$PlatForm == "unix"} {
            if {$PDFReader != ""} {
                set f [open "$CONFIGDir/PDFReaderUnix.txt" w]
                puts $f $PDFReader
                close $f
                }
            }       
        }
    
    if {$ConfigFileNameSearch == "GOOGLEEARTH"} {
        set GoogleEarthReader $ConfigFileNamePath
        if {$PlatForm == "windows"} {
            if {$GoogleEarthReader != ""} {
                set f [open "$CONFIGDir/GoogleEarthWindows.txt" w]
                puts $f $GoogleEarthReader
                close $f
                }
            }
        if {$PlatForm == "unix"} {
            if {$GoogleEarthReader != ""} {
                set f [open "$CONFIGDir/GoogleEarthUnix.txt" w]
                puts $f $GoogleEarthReader
                close $f
                }
            }       
        }

    if {$ConfigFileNameSearch == "IMAGEMAGICK"} {
        set ImageMagickMaker $ConfigFileNamePath
        if {$PlatForm == "windows"} {
            if {$ImageMagickMaker != ""} {
                set f [open "$CONFIGDir/ImageMagickWindows.txt" w]
                puts $f $ImageMagickMaker
                close $f
                }
            }
        if {$PlatForm == "unix"} {
            if {$ImageMagickMaker != ""} {
                set f [open "$CONFIGDir/ImageMagickUnix.txt" w]
                puts $f $ImageMagickMaker
                close $f
                }
            }       
        }
        
    if {$ConfigFileNameSearch == "GIMP"} {
        set GimpReader $ConfigFileNamePath
        if {$PlatForm == "windows"} {
            if {$GimpReader != ""} {
                set f [open "$CONFIGDir/GimpWindows.txt" w]
                puts $f $GimpReader
                close $f
                }
            }
        if {$PlatForm == "unix"} {
            if {$GimpReader != ""} {
                set f [open "$CONFIGDir/GimpUnix.txt" w]
                puts $f $GimpReader
                close $f
                }
            }       
        }

    if {$ConfigFileNameSearch == "SNAP"} {
        set SnapReader $ConfigFileNamePath
        set SnapGpt ""
        set SnapGpt [file dirname $SnapReader]
        append SnapGpt "/gpt"
        if {$PlatForm == "windows"} {
            if {$SnapReader != ""} {
                set f [open "$CONFIGDir/SnapWindows.txt" w]
                puts $f $SnapReader
                close $f
                }
            }
        if {$PlatForm == "unix"} {
            if {$SnapReader != ""} {
                set f [open "$CONFIGDir/SnapUnix.txt" w]
                puts $f $SnapReader
                close $f
                }
            }       
        }

    if {$ConfigFileNameSearch == "S1TBX"} {
        set S1tbxReader $ConfigFileNamePath
        if {$PlatForm == "windows"} {
            if {$S1tbxReader != ""} {
                set f [open "$CONFIGDir/S1tbxWindows.txt" w]
                puts $f $S1tbxReader
                close $f
                }
            }
        if {$PlatForm == "unix"} {
            if {$S1tbxReader != ""} {
                set f [open "$CONFIGDir/S1tbxUnix.txt" w]
                puts $f $S1tbxReader
                close $f
                }
            }       
        }

    if {$ConfigFileNameSearch == "MAPREADY"} {
        set MapReadyReader $ConfigFileNamePath
        if {$PlatForm == "windows"} {
            if {$MapReadyReader != ""} {
                set f [open "$CONFIGDir/MapReadyWindows.txt" w]
                puts $f $MapReadyReader
                close $f
                }
            }
        if {$PlatForm == "unix"} {
            if {$MapReadyReader != ""} {
                set f [open "$CONFIGDir/MapReadyUnix.txt" w]
                puts $f $MapReadyReader
                close $f
                }
            }       
        }

    Window hide $widget(Toplevel341)
    if {$ConfigFileNameSearch == "PDF"} { TextEditorRunTrace "Close Window Configuration PDF READER Software" "b" }
    if {$ConfigFileNameSearch == "GOOGLEEARTH"} { TextEditorRunTrace "Close Window Configuration GOOGLE EARTH Software" "b" }
    if {$ConfigFileNameSearch == "GIMP"} { TextEditorRunTrace "Close Window Configuration GIMP VIEWER Software" "b" }
    if {$ConfigFileNameSearch == "SNAP"} { TextEditorRunTrace "Close Window Configuration SNAP Software" "b" }
    if {$ConfigFileNameSearch == "S1TBX"} { TextEditorRunTrace "Close Window Configuration S1TBX Software" "b" }
    if {$ConfigFileNameSearch == "MAPREADY"} { TextEditorRunTrace "Close Window Configuration MAP READY Software" "b" }
    if {$ConfigFileNameSearch == "IMAGEMAGICK"} { TextEditorRunTrace "Close Window Configuration IMAGE MAGICK Software" "b" }
    
    set VarConfigFileName "ok"
    }} \
        -padx 4 -pady 2 -text {Save & Exit} 
    vTcl:DefineAlias "$site_3_0.but74" "Button2" vTcl:WidgetProc "Toplevel341" 1
    button $site_3_0.cpd75 \
        -background #ffff00 \
        -command {global OpenDirFile ConfigFileNameSearch VarConfigFileName

if {$OpenDirFile == 0} {
    Window hide $widget(Toplevel341)
    if {$ConfigFileNameSearch == "PDF"} { TextEditorRunTrace "Close Window Configuration PDF READER Software" "b" }
    if {$ConfigFileNameSearch == "GOOGLEEARTH"} { TextEditorRunTrace "Close Window Configuration GOOGLE EARTH Software" "b" }
    if {$ConfigFileNameSearch == "GIMP"} { TextEditorRunTrace "Close Window Configuration GIMP VIEWER Software" "b" }
    if {$ConfigFileNameSearch == "SNAP"} { TextEditorRunTrace "Close Window Configuration SNAP Software" "b" }
    if {$ConfigFileNameSearch == "S1TBX"} { TextEditorRunTrace "Close Window Configuration S1TBX Software" "b" }
    if {$ConfigFileNameSearch == "MAPREADY"} { TextEditorRunTrace "Close Window Configuration MAP READY Software" "b" }
    if {$ConfigFileNameSearch == "IMAGEMAGICK"} { TextEditorRunTrace "Close Window Configuration IMAGE MAGICK Software" "b" }
    
    set VarConfigFileName "ok"
    }} \
        -padx 4 -pady 2 -text {Exit ( without Saving )} 
    vTcl:DefineAlias "$site_3_0.cpd75" "Button3" vTcl:WidgetProc "Toplevel341" 1
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra78 \
        -in $top -anchor center -expand 1 -fill both -side top 
    pack $top.fra341 \
        -in $top -anchor center -expand 0 -fill x -side top 

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

Window show .
Window show .top341

main $argc $argv
