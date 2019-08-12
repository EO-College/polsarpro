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
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}
        {{[file join . GUI Images tools.gif]} {user image} user {}}

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
    set base .top436a
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd79
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
    namespace eval ::widgets::$site_6_0.cpd114 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
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
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd69
    namespace eval ::widgets::$site_3_0.cpd83 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd70
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd72 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd114 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd114 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd68 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd68 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd74 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd84
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd80
    namespace eval ::widgets::$site_6_0.lab79 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd81
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd82
    namespace eval ::widgets::$site_6_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd83
    namespace eval ::widgets::$site_6_0.ent80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd77 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd77
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd98 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd116 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd116 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd117 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd117 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd118 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd118 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd122 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd67
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd98 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd116 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd116 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd117 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd117 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd118 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd118 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd122 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but66 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1}
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
            vTclWindow.top436a
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
    wm geometry $top 200x200+100+100; update
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

proc vTclWindow.top436a {base} {
    if {$base == ""} {
        set base .top436a
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
    wm geometry $top 500x600+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "TANDEM-X Input Data File"
    vTcl:DefineAlias "$top" "Toplevel436a" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel436a" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TANDEMXDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel436a" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel436a" 1
    pack $site_6_0.cpd114 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd72 \
        -ipad 0 -text {TANDEM-X Product File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame220" vTcl:WidgetProc "Toplevel436a" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TANDEMXProductFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry220" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame30" vTcl:WidgetProc "Toplevel436a" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName TANDEMXDirInput TANDEMXProductFile

set types {
    {{XML Files}        {.xml}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $TANDEMXDirInput $types "TANDEM-X PRODUCT FILE"
set TANDEMXProductFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button220" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_5_0.cpd119 "$site_5_0.cpd119 Button $top all _vTclBalloon"
    bind $site_5_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd69" "Frame18" vTcl:WidgetProc "Toplevel436a" 1
    set site_3_0 $top.cpd69
    button $site_3_0.cpd83 \
        -background #ffff00 \
        -command {global TANDEMXDirInput TANDEMXProductFile TANDEMXFileInputFlag 
global TANDEMXDirInputMaster TANDEMXDirOutputMaster TANDEMXProductFileMaster
global TANDEMXDirInputSlave TANDEMXDirOutputSlave TANDEMXProductFileSlave
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPTANDEMXConfig TMPGoogle OpenDirFile PolarType
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global TMPTANDEMXConfig TMPTANDEMXConfigMaster TMPTANDEMXConfigSlave

if {$OpenDirFile == 0} {

set NligFullSize ""
set NcolFullSize ""
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set NligFullSizeInput 0
set NcolFullSizeInput 0

if {$TANDEMXProductFile != ""} {
    #####################################################################
    #Create Directory
    set TANDEMXDirInput [PSPCreateDirectoryMask $TANDEMXDirInput $TANDEMXDirInput $TANDEMXDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {

        DeleteFile $TMPTANDEMXConfig
        DeleteFile $TMPGoogle
        set TANDEMXFile "$TANDEMXDirInput/product_header.txt"
        set Sensor "tandemx"
        ReadXML $TANDEMXProductFile $TANDEMXFile $TMPTANDEMXConfig $Sensor
        WaitUntilCreated $TMPTANDEMXConfig
        if [file exists $TMPTANDEMXConfig] {
            set f [open $TMPTANDEMXConfig r]
            gets $f Tmp; set TANDEMXDirInputMaster "$TANDEMXDirInput/"; append TANDEMXDirInputMaster $Tmp
            gets $f Tmp; set TANDEMXDirInputSlave "$TANDEMXDirInput/"; append TANDEMXDirInputSlave $Tmp
            gets $f Tmp; set TANDEMXProductFileMaster "$TANDEMXDirInput/"; append TANDEMXProductFileMaster $Tmp
            gets $f Tmp; set TANDEMXProductFileSlave "$TANDEMXDirInput/"; append TANDEMXProductFileSlave $Tmp
            gets $f NligFullSize
            gets $f NcolFullSize
            gets $f PolarType 
            close $f
            if {$PolarType == "full"} {
                set TANDEMXDirOutputMaster "$TANDEMXDirInput/master";
                set TANDEMXDirOutputSlave "$TANDEMXDirInput/slave";
                set NligInit 1; set NligEnd $NligFullSize
                set NcolInit 1; set NcolEnd $NcolFullSize
                set NligFullSizeInput $NligFullSize
                set NcolFullSizeInput $NcolFullSize
                set TDXPolar "Quad Pol"
                $widget(Button436a_01) configure -state normal; 
    
                if {$TANDEMXProductFileSlave != ""} {
                    #####################################################################
                    #Create Directory
                    set TANDEMXDirOutputSlave [PSPCreateDirectoryMask $TANDEMXDirOutputSlave $TANDEMXDirOutputSlave $TANDEMXDirInputSlave]
                    #####################################################################       
    
                    if {"$VarWarning"=="ok"} {
    
                        DeleteFile $TMPTANDEMXConfigSlave
                        DeleteFile $TMPGoogle
                        set TANDEMXFile "$TANDEMXDirOutputSlave/product_header.txt"
                        set Sensor "terrasar"
                        ReadXML $TANDEMXProductFileSlave $TANDEMXFile $TMPTANDEMXConfigSlave $Sensor
                        WaitUntilCreated $TMPTANDEMXConfigSlave
                        if [file exists $TMPTANDEMXConfigSlave] {
                            set f [open $TMPTANDEMXConfigSlave r]
                            gets $f TSXtmp; gets $f TSXtmp;
                            gets $f TSXtmp; gets $f TSXtmp;
                            gets $f PolarType 
                            set FileInput "$TANDEMXDirInputSlave/"; gets $f TSXtmp; append FileInput $TSXtmp
                            if [file exists $FileInput] {
                                set FileInput5 $FileInput
                                } else {
                                set FileInput5 ""
                                }
                            gets $f TSXtmp; gets $f TSXtmp;
                            set FileInput "$TANDEMXDirInputSlave/"; gets $f TSXtmp; append FileInput $TSXtmp
                            if [file exists $FileInput] {
                                set FileInput6 $FileInput
                                } else {
                                set FileInput6 ""
                                }            
                            gets $f TSXtmp; gets $f TSXtmp;
                            set FileInput "$TANDEMXDirInputSlave/"; gets $f TSXtmp; append FileInput $TSXtmp
                            if [file exists $FileInput] {
                                set FileInput7 $FileInput
                                } else {
                                set FileInput7 ""
                                }            
                            gets $f TSXtmp; gets $f TSXtmp;
                            set FileInput "$TANDEMXDirInputSlave/"; gets $f TSXtmp; append FileInput $TSXtmp
                            if [file exists $FileInput] {
                                set FileInput8 $FileInput
                                } else {
                                set FileInput8 ""
                                }            
                            $widget(Entry436a_5) configure -disabledbackground #FFFFFF; $widget(Button436a_5) configure -state normal
                            $widget(Entry436a_6) configure -disabledbackground #FFFFFF; $widget(Button436a_6) configure -state normal
                            $widget(Entry436a_7) configure -disabledbackground #FFFFFF; $widget(Button436a_7) configure -state normal
                            $widget(Entry436a_8) configure -disabledbackground #FFFFFF; $widget(Button436a_8) configure -state normal
                            gets $f TSXtmp; gets $f TSXtmp;
                            gets $f TSXlookDirection
                            gets $f TSXorbitDirection
                            gets $f TSXTeta0
                            gets $f TSXSpacingAzimuth; set TSXSpacingAzimuth [expr round(10000. * $TSXSpacingAzimuth) / 10000.]
                            gets $f TSXSpacingSlant; set TSXSpacingSlant [expr round(10000. * $TSXSpacingSlant) / 10000.]
                            close $f

                            if {$TSXorbitDirection == "ASCENDING" } { set TSXAntennaPass "A" } else { set TSXAntennaPass "D" }
                            if {$TSXlookDirection == "RIGHT" } { append TSXAntennaPass "R" } else { append TSXAntennaPass "L" }
                            set f [open "$TANDEMXDirOutputSlave/config_acquisition.txt" w]
                            puts $f $TSXAntennaPass
                            puts $f $TSXTeta0
                            puts $f $TSXSpacingSlant
                            puts $f $TSXSpacingAzimuth
                            close $f

                            $widget(Button436a_05) configure -state normal 
                            TextEditorRunTrace "Process The Function Soft/bin/data_import/terrasarx_google.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$TANDEMXDirOutputSlave\x22 -of \x22$TMPGoogle\x22" "k"
                            set f [ open "| Soft/bin/data_import/terrasarx_google.exe -id \x22$TANDEMXDirOutputSlave\x22 -of \x22$TMPGoogle\x22" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            WaitUntilCreated $TMPGoogle
                            $widget(Button436a_06) configure -state normal 
                            }
                        }
                   }    

                if {$TANDEMXProductFileMaster != ""} {
                    #####################################################################
                    #Create Directory
                    set TANDEMXDirOutputMaster [PSPCreateDirectoryMask $TANDEMXDirOutputMaster $TANDEMXDirOutputMaster $TANDEMXDirInputMaster]
                    #####################################################################       
    
                    if {"$VarWarning"=="ok"} {
    
                        DeleteFile $TMPTANDEMXConfigMaster
                        DeleteFile $TMPGoogle
                        set TANDEMXFile "$TANDEMXDirOutputMaster/product_header.txt"
                        set Sensor "terrasar"
                        ReadXML $TANDEMXProductFileMaster $TANDEMXFile $TMPTANDEMXConfigMaster $Sensor
                        WaitUntilCreated $TMPTANDEMXConfigMaster
                        if [file exists $TMPTANDEMXConfigMaster] {
                            set f [open $TMPTANDEMXConfigMaster r]
                            gets $f TSXtmp; gets $f TSXtmp;
                            gets $f TSXtmp; gets $f TSXtmp;
                            gets $f PolarType 
                            set FileInput "$TANDEMXDirInputMaster/"; gets $f TSXtmp; append FileInput $TSXtmp
                            if [file exists $FileInput] {
                                set FileInput1 $FileInput
                                } else {
                                set FileInput1 ""
                                }
                            gets $f TSXtmp; gets $f TSXtmp;
                            set FileInput "$TANDEMXDirInputMaster/"; gets $f TSXtmp; append FileInput $TSXtmp
                            if [file exists $FileInput] {
                                set FileInput2 $FileInput
                                } else {
                                set FileInput2 ""
                                }            
                            gets $f TSXtmp; gets $f TSXtmp;
                            set FileInput "$TANDEMXDirInputMaster/"; gets $f TSXtmp; append FileInput $TSXtmp
                            if [file exists $FileInput] {
                                set FileInput3 $FileInput
                                } else {
                                set FileInput3 ""
                                }            
                            gets $f TSXtmp; gets $f TSXtmp;
                            set FileInput "$TANDEMXDirInputMaster/"; gets $f TSXtmp; append FileInput $TSXtmp
                            if [file exists $FileInput] {
                                set FileInput4 $FileInput
                                } else {
                                set FileInput4 ""
                                }            
                            $widget(Entry436a_1) configure -disabledbackground #FFFFFF; $widget(Button436a_1) configure -state normal
                            $widget(Entry436a_2) configure -disabledbackground #FFFFFF; $widget(Button436a_2) configure -state normal
                            $widget(Entry436a_3) configure -disabledbackground #FFFFFF; $widget(Button436a_3) configure -state normal
                            $widget(Entry436a_4) configure -disabledbackground #FFFFFF; $widget(Button436a_4) configure -state normal
                            gets $f TSXtmp; gets $f TSXtmp;
                            gets $f TSXlookDirection
                            gets $f TSXorbitDirection
                            gets $f TSXTeta0
                            gets $f TSXSpacingAzimuth; set TSXSpacingAzimuth [expr round(10000. * $TSXSpacingAzimuth) / 10000.]
                            gets $f TSXSpacingSlant; set TSXSpacingSlant [expr round(10000. * $TSXSpacingSlant) / 10000.]
                            close $f

                            if {$TSXorbitDirection == "ASCENDING" } { set TSXAntennaPass "A" } else { set TSXAntennaPass "D" }
                            if {$TSXlookDirection == "RIGHT" } { append TSXAntennaPass "R" } else { append TSXAntennaPass "L" }
                            set f [open "$TANDEMXDirOutputMaster/config_acquisition.txt" w]
                            puts $f $TSXAntennaPass
                            puts $f $TSXTeta0
                            puts $f $TSXSpacingSlant
                            puts $f $TSXSpacingAzimuth
                            close $f

                            $widget(Button436a_03) configure -state normal 
                            TextEditorRunTrace "Process The Function Soft/bin/data_import/terrasarx_google.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$TANDEMXDirOutputMaster\x22 -of \x22$TMPGoogle\x22" "k"
                            set f [ open "| Soft/bin/data_import/terrasarx_google.exe -id \x22$TANDEMXDirOutputMaster\x22 -of \x22$TMPGoogle\x22" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            WaitUntilCreated $TMPGoogle
                            $widget(Button436a_04) configure -state normal 
                            }
                        }
                   }  
               $widget(Button436a_0) configure -state normal 
               } else {
              set VarError ""
              set ErrorMessage "NOT A QUAD-POL TANDEM-X PRODUCT"
              Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
              tkwait variable VarError
              Window hide $widget(Toplevel436a); TextEditorRunTrace "Close Window TANDEM-X Input File" "b"
               }
           #Config
           }
        #Warning
        }
    #ProductFile
    } else {
    set VarError ""
    set ErrorMessage "ENTER THE XML - PRODUCT FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
#OpenDirFile
}} \
        -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_3_0.cpd83" "Button2" vTcl:WidgetProc "Toplevel436a" 1
    button $site_3_0.cpd84 \
        -background #ffff00 \
        -command {global FileName VarError ErrorMessage TANDEMXDirInput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set TANDEMXFile "$TANDEMXDirInput/product_header.txt"
if [file exists $TANDEMXFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top436a $TANDEMXFile
    }} \
        -padx 4 -pady 2 -text {Edit Header} 
    vTcl:DefineAlias "$site_3_0.cpd84" "Button436a_01" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_3_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd70" "Frame19" vTcl:WidgetProc "Toplevel436a" 1
    set site_4_0 $site_3_0.cpd70
    label $site_4_0.cpd93 \
        -text {Polarization Mode} 
    vTcl:DefineAlias "$site_4_0.cpd93" "Label5" vTcl:WidgetProc "Toplevel436a" 1
    entry $site_4_0.cpd71 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable TDXPolar -width 12 
    vTcl:DefineAlias "$site_4_0.cpd71" "Entry5" vTcl:WidgetProc "Toplevel436a" 1
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    button $site_3_0.cpd72 \
        \
        -command {global FileName VarError ErrorMessage TANDEMXDirInput

set TANDEMXFile "$TANDEMXDirInput/GEARTH_POLY.kml"
if [file exists $TANDEMXFile] {
    GoogleEarth $TANDEMXFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -padx 4 -pady 2 -relief raised -text Google 
    vTcl:DefineAlias "$site_3_0.cpd72" "Button436a_02" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_3_0.cpd72 "$site_3_0.cpd72 Button $top all _vTclBalloon"
    bind $site_3_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_3_0.cpd83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Input Master Directory} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame5" vTcl:WidgetProc "Toplevel436a" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TANDEMXDirInputMaster 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame16" vTcl:WidgetProc "Toplevel436a" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.cpd114" "Button40" vTcl:WidgetProc "Toplevel436a" 1
    pack $site_5_0.cpd114 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd71 \
        -ipad 0 -text {Output Master Directory} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame436a" vTcl:WidgetProc "Toplevel436a" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable TANDEMXDirOutputMaster 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry436a" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel436a" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global DirName DataDir TANDEMXDirOutputMaster
global VarWarning WarningMessage WarningMessage2

set TANDEMXOutputDirTmp $TANDEMXDirOutputMaster
set DirName ""
OpenDir $DataDir "DATA OUTPUT MASTER DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set TANDEMXDirOutputMaster $DirName
        } else {
        set TANDEMXDirOutputMaster $TANDEMXOutputDirTmp
        }
    } else {
    set TANDEMXDirOutputMaster $TANDEMXOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button436a" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_5_0.cpd119 "$site_5_0.cpd119 Button $top all _vTclBalloon"
    bind $site_5_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd67 \
        -ipad 0 -text {Input Slave Directory} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame6" vTcl:WidgetProc "Toplevel436a" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TANDEMXDirInputSlave 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame17" vTcl:WidgetProc "Toplevel436a" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.cpd114" "Button41" vTcl:WidgetProc "Toplevel436a" 1
    pack $site_5_0.cpd114 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd68 \
        -ipad 0 -text {Output Slave Directory} 
    vTcl:DefineAlias "$top.cpd68" "TitleFrame437" vTcl:WidgetProc "Toplevel436a" 1
    bind $top.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd68 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable TANDEMXDirOutputSlave 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry437" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame31" vTcl:WidgetProc "Toplevel436a" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global DirName DataDir TANDEMXDirOutputSlave
global VarWarning WarningMessage WarningMessage2

set TANDEMXOutputDirTmp $TANDEMXDirOutputSlave
set DirName ""
OpenDir $DataDir "DATA OUTPUT SLAVE DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set TANDEMXDirOutputSlave $DirName
        } else {
        set TANDEMXDirOutputSlave $TANDEMXOutputDirTmp
        }
    } else {
    set TANDEMXDirOutputSlave $TANDEMXOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button437" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_5_0.cpd119 "$site_5_0.cpd119 Button $top all _vTclBalloon"
    bind $site_5_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame4" vTcl:WidgetProc "Toplevel436a" 1
    set site_3_0 $top.fra73
    TitleFrame $site_3_0.cpd74 \
        -ipad 2 -text {Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd74" "TitleFrame2" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_3_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd74 getframe]
    button $site_5_0.cpd75 \
        -background #ffff00 \
        -command {global FileName VarError ErrorMessage TANDEMXDirOutputMaster
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set TANDEMXFile "$TANDEMXDirOutputMaster/product_header.txt"
if [file exists $TANDEMXFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top436a $TANDEMXFile
    }} \
        -padx 4 -pady 2 -text {Edit Header} 
    vTcl:DefineAlias "$site_5_0.cpd75" "Button436a_03" vTcl:WidgetProc "Toplevel436a" 1
    button $site_5_0.cpd76 \
        \
        -command {global FileName VarError ErrorMessage TANDEMXDirOutputMaster

set TANDEMXFile "$TANDEMXDirOutputMaster/GEARTH_POLY.kml"
if [file exists $TANDEMXFile] {
    GoogleEarth $TANDEMXFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -padx 4 -pady 2 -relief raised -text Google 
    vTcl:DefineAlias "$site_5_0.cpd76" "Button436a_04" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_5_0.cpd76 "$site_5_0.cpd76 Button $top all _vTclBalloon"
    bind $site_5_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd84 \
        -borderwidth 2 -relief ridge -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd84" "Frame13" vTcl:WidgetProc "Toplevel436a" 1
    set site_4_0 $site_3_0.cpd84
    frame $site_4_0.cpd78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd78" "Frame14" vTcl:WidgetProc "Toplevel436a" 1
    set site_5_0 $site_4_0.cpd78
    frame $site_5_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame15" vTcl:WidgetProc "Toplevel436a" 1
    set site_6_0 $site_5_0.cpd79
    label $site_6_0.lab77 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_6_0.lab77" "Label439" vTcl:WidgetProc "Toplevel436a" 1
    pack $site_6_0.lab77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd80" "Frame21" vTcl:WidgetProc "Toplevel436a" 1
    set site_6_0 $site_5_0.cpd80
    label $site_6_0.lab79 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_6_0.lab79" "Label442" vTcl:WidgetProc "Toplevel436a" 1
    pack $site_6_0.lab79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    frame $site_4_0.cpd81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd81" "Frame22" vTcl:WidgetProc "Toplevel436a" 1
    set site_5_0 $site_4_0.cpd81
    frame $site_5_0.cpd82 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd82" "Frame23" vTcl:WidgetProc "Toplevel436a" 1
    set site_6_0 $site_5_0.cpd82
    entry $site_6_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligFullSize -width 6 
    vTcl:DefineAlias "$site_6_0.ent78" "Entry441" vTcl:WidgetProc "Toplevel436a" 1
    pack $site_6_0.ent78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $site_5_0.cpd83 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd83" "Frame24" vTcl:WidgetProc "Toplevel436a" 1
    set site_6_0 $site_5_0.cpd83
    entry $site_6_0.ent80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolFullSize -width 6 
    vTcl:DefineAlias "$site_6_0.ent80" "Entry444" vTcl:WidgetProc "Toplevel436a" 1
    pack $site_6_0.ent80 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd77 \
        -ipad 2 -text {Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd77" "TitleFrame3" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_3_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd77 getframe]
    button $site_5_0.cpd75 \
        -background #ffff00 \
        -command {global FileName VarError ErrorMessage TANDEMXDirOutputSlave
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set TANDEMXFile "$TANDEMXDirOutputSlave/product_header.txt"
if [file exists $TANDEMXFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top436a $TANDEMXFile
    }} \
        -padx 4 -pady 2 -text {Edit Header} 
    vTcl:DefineAlias "$site_5_0.cpd75" "Button436a_05" vTcl:WidgetProc "Toplevel436a" 1
    button $site_5_0.cpd76 \
        \
        -command {global FileName VarError ErrorMessage TANDEMXDirOutputSlave

set TANDEMXFile "$TANDEMXDirOutputSlave/GEARTH_POLY.kml"
if [file exists $TANDEMXFile] {
    GoogleEarth $TANDEMXFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -padx 4 -pady 2 -relief raised -text Google 
    vTcl:DefineAlias "$site_5_0.cpd76" "Button436a_06" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_5_0.cpd76 "$site_5_0.cpd76 Button $top all _vTclBalloon"
    bind $site_5_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 20 \
        -side left 
    pack $site_3_0.cpd84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 2 -ipady 4 \
        -side left 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 20 \
        -side left 
    frame $top.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame3" vTcl:WidgetProc "Toplevel436a" 1
    set site_3_0 $top.cpd77
    frame $site_3_0.cpd66 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame5" vTcl:WidgetProc "Toplevel436a" 1
    set site_4_0 $site_3_0.cpd66
    TitleFrame $site_4_0.cpd98 \
        -ipad 0 -text {Input Master Data File ( s11 )} 
    vTcl:DefineAlias "$site_4_0.cpd98" "TitleFrame436a_1" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_4_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd98 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput1 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry436a_1" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame32" vTcl:WidgetProc "Toplevel436a" 1
    set site_7_0 $site_6_0.cpd91
    button $site_7_0.cpd119 \
        \
        -command {global FileName TANDEMXDirInputMaster TANDEMXDataFormat FileInput1

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TANDEMXDirInputMaster/IMAGEDATA"] {
    set TDXDirTmp "$TANDEMXDirInputMaster/IMAGEDATA"
    } else {
    set TDXDirTmp $TANDEMXDirInputMaster
    }
if {$TANDEMXDataFormat == "quad"} {OpenFile $TDXDirTmp $types "HH INPUT FILE (s11)"}
if {$FileName == "" } { set FileName $FileInput1 }
set FileInput1 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd119" "Button436a_1" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_7_0.cpd119 "$site_7_0.cpd119 Button $top all _vTclBalloon"
    bind $site_7_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd119 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_4_0.cpd116 \
        -ipad 0 -text {Input Master Data File ( s12 )} 
    vTcl:DefineAlias "$site_4_0.cpd116" "TitleFrame436a_2" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_4_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd116 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput2 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry436a_2" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame33" vTcl:WidgetProc "Toplevel436a" 1
    set site_7_0 $site_6_0.cpd91
    button $site_7_0.cpd120 \
        \
        -command {global FileName TANDEMXDirInputMaster TANDEMXDataFormat FileInput2

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TANDEMXDirInputMaster/IMAGEDATA"] {
    set TDXDirTmp "$TANDEMXDirInputMaster/IMAGEDATA"
    } else {
    set TDXDirTmp $TANDEMXDirInputMaster
    }
if {$TANDEMXDataFormat == "quad"} {OpenFile $TDXDirTmp $types "HV INPUT FILE (s12)"}
if {$FileName == "" } { set FileName $FileInput2 }
set FileInput2 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd120" "Button436a_2" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_7_0.cpd120 "$site_7_0.cpd120 Button $top all _vTclBalloon"
    bind $site_7_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd120 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_4_0.cpd117 \
        -ipad 0 -text {Input Master Data File ( s21 )} 
    vTcl:DefineAlias "$site_4_0.cpd117" "TitleFrame436a_3" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_4_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd117 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput3 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry436a_3" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame34" vTcl:WidgetProc "Toplevel436a" 1
    set site_7_0 $site_6_0.cpd91
    button $site_7_0.cpd121 \
        \
        -command {global FileName TANDEMXDirInputMaster TANDEMXDataFormat FileInput3

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TANDEMXDirInputMaster/IMAGEDATA"] {
    set TDXDirTmp "$TANDEMXDirInputMaster/IMAGEDATA"
    } else {
    set TDXDirTmp $TANDEMXDirInputMaster
    }
if {$TANDEMXDataFormat == "quad"} {OpenFile $TDXDirTmp $types "VH INPUT FILE (s21)"}
if {$FileName == "" } { set FileName $FileInput3 }
set FileInput3 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd121" "Button436a_3" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_7_0.cpd121 "$site_7_0.cpd121 Button $top all _vTclBalloon"
    bind $site_7_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd121 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_4_0.cpd118 \
        -ipad 0 -text {Input Master Data File ( s22 )} 
    vTcl:DefineAlias "$site_4_0.cpd118" "TitleFrame436a_4" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_4_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd118 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput4 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry436a_4" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame35" vTcl:WidgetProc "Toplevel436a" 1
    set site_7_0 $site_6_0.cpd91
    button $site_7_0.cpd122 \
        \
        -command {global FileName TANDEMXDirInputMaster TANDEMXDataFormat FileInput4

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TANDEMXDirInputMaster/IMAGEDATA"] {
    set TDXDirTmp "$TANDEMXDirInputMaster/IMAGEDATA"
    } else {
    set TDXDirTmp $TANDEMXDirInputMaster
    }
if {$TANDEMXDataFormat == "quad"} {OpenFile $TDXDirTmp $types "VV INPUT FILE (s22)"}
if {$FileName == "" } { set FileName $FileInput4 }
set FileInput4 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd122" "Button436a_4" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_7_0.cpd122 "$site_7_0.cpd122 Button $top all _vTclBalloon"
    bind $site_7_0.cpd122 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd122 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd116 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd117 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd118 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.cpd67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd67" "Frame6" vTcl:WidgetProc "Toplevel436a" 1
    set site_4_0 $site_3_0.cpd67
    TitleFrame $site_4_0.cpd98 \
        -ipad 0 -text {Input Slave Data File ( s11 )} 
    vTcl:DefineAlias "$site_4_0.cpd98" "TitleFrame436a_5" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_4_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd98 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput5 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry436a_5" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame36" vTcl:WidgetProc "Toplevel436a" 1
    set site_7_0 $site_6_0.cpd91
    button $site_7_0.cpd119 \
        \
        -command {global FileName TANDEMXDirInputSlave TANDEMXDataFormat FileInput5

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TANDEMXDirInputSlave/IMAGEDATA"] {
    set TDXDirTmp "$TANDEMXDirInputSlave/IMAGEDATA"
    } else {
    set TDXDirTmp $TANDEMXDirInputSlave
    }
if {$TANDEMXDataFormat == "quad"} {OpenFile $TDXDirTmp $types "HH INPUT FILE (s11)"}
if {$FileName == "" } { set FileName $FileInput5 }
set FileInput5 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd119" "Button436a_5" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_7_0.cpd119 "$site_7_0.cpd119 Button $top all _vTclBalloon"
    bind $site_7_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd119 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_4_0.cpd116 \
        -ipad 0 -text {Input Slave Data File ( s12 )} 
    vTcl:DefineAlias "$site_4_0.cpd116" "TitleFrame436a_6" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_4_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd116 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput6 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry436a_6" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame37" vTcl:WidgetProc "Toplevel436a" 1
    set site_7_0 $site_6_0.cpd91
    button $site_7_0.cpd120 \
        \
        -command {global FileName TANDEMXDirInputSlave TANDEMXDataFormat FileInput6

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TANDEMXDirInputSlave/IMAGEDATA"] {
    set TDXDirTmp "$TANDEMXDirInputSlave/IMAGEDATA"
    } else {
    set TDXDirTmp $TANDEMXDirInputSlave
    }
if {$TANDEMXDataFormat == "quad"} {OpenFile $TDXDirTmp $types "HV INPUT FILE (s12)"}
if {$FileName == "" } { set FileName $FileInput6 }
set FileInput6 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd120" "Button436a_6" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_7_0.cpd120 "$site_7_0.cpd120 Button $top all _vTclBalloon"
    bind $site_7_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd120 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_4_0.cpd117 \
        -ipad 0 -text {Input Slave Data File ( s21 )} 
    vTcl:DefineAlias "$site_4_0.cpd117" "TitleFrame436a_7" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_4_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd117 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput7 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry436a_7" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame38" vTcl:WidgetProc "Toplevel436a" 1
    set site_7_0 $site_6_0.cpd91
    button $site_7_0.cpd121 \
        \
        -command {global FileName TANDEMXDirInputSlave TANDEMXDataFormat FileInput7

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TANDEMXDirInputSlave/IMAGEDATA"] {
    set TDXDirTmp "$TANDEMXDirInputSlave/IMAGEDATA"
    } else {
    set TDXDirTmp $TANDEMXDirInputSlave
    }
if {$TANDEMXDataFormat == "quad"} {OpenFile $TDXDirTmp $types "VH INPUT FILE (s21)"}
if {$FileName == "" } { set FileName $FileInput7 }
set FileInput7 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd121" "Button436a_7" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_7_0.cpd121 "$site_7_0.cpd121 Button $top all _vTclBalloon"
    bind $site_7_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd121 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_4_0.cpd118 \
        -ipad 0 -text {Input Slave Data File ( s22 )} 
    vTcl:DefineAlias "$site_4_0.cpd118" "TitleFrame436a_8" vTcl:WidgetProc "Toplevel436a" 1
    bind $site_4_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd118 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput8 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry436a_8" vTcl:WidgetProc "Toplevel436a" 1
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame39" vTcl:WidgetProc "Toplevel436a" 1
    set site_7_0 $site_6_0.cpd91
    button $site_7_0.cpd122 \
        \
        -command {global FileName TANDEMXDirInputSlave TANDEMXDataFormat FileInput8

set types {
    {{All Files}        *        }
    }
set FileName ""
if [file isdirectory "$TANDEMXDirInputSlave/IMAGEDATA"] {
    set TDXDirTmp "$TANDEMXDirInputSlave/IMAGEDATA"
    } else {
    set TDXDirTmp $TANDEMXDirInputSlave
    }
if {$TANDEMXDataFormat == "quad"} {OpenFile $TDXDirTmp $types "VV INPUT FILE (s22)"}
if {$FileName == "" } { set FileName $FileInput8 }
set FileInput8 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd122" "Button436a_8" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_7_0.cpd122 "$site_7_0.cpd122 Button $top all _vTclBalloon"
    bind $site_7_0.cpd122 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd122 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd116 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd117 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd118 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill x -padx 2 -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill x -padx 2 -side left 
    frame $top.fra71 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel436a" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global TANDEMXFileInputFlag OpenDirFile
global FileInput1 FileInput2 FileInput3 FileInput4
global FileInput5 FileInput6 FileInput7 FileInput8
global fonction fonction2 ErrorMessage VarError
global VarWarning VarAdvice WarningMessage WarningMessage2
global Load_CheckSizeBinaryDataFile8

if {$OpenDirFile == 0} {

set TANDEMXFileInputFlag 0

set TANDEMXFileFlag 0
if {$FileInput1 != ""} {incr TANDEMXFileFlag}
if {$FileInput2 != ""} {incr TANDEMXFileFlag}
if {$FileInput3 != ""} {incr TANDEMXFileFlag}
if {$FileInput4 != ""} {incr TANDEMXFileFlag}
if {$FileInput5 != ""} {incr TANDEMXFileFlag}
if {$FileInput6 != ""} {incr TANDEMXFileFlag}
if {$FileInput7 != ""} {incr TANDEMXFileFlag}
if {$FileInput8 != ""} {incr TANDEMXFileFlag}
if {$TANDEMXFileFlag == 8} {set TANDEMXFileInputFlag 1}

if {$TANDEMXFileInputFlag == 1} {
    set WarningMessage "DON'T FORGET TO EXTRACT DATA"
    set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    Window hide $widget(Toplevel436a); TextEditorRunTrace "Close Window TANDEMX Input File" "b"
    } else {
    set TANDEMXFileInputFlag 0
    set ErrorMessage "ENTER THE TANDEMX DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
if {$Load_CheckSizeBinaryDataFile8 == 1} { Window hide $widget(Toplevel438a); TextEditorRunTrace "Close Window Check Binary Data Files" "b" }

}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button436a_0" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/TANDEMX_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but66 \
        \
        -command {global Load_CheckSizeBinaryDataFile8 PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_CheckSizeBinaryDataFile8 == 0} {
    source "GUI/tools/CheckSizeBinaryDataFile8.tcl"
    set Load_CheckSizeBinaryDataFile8 1
    WmTransient $widget(Toplevel438a) $PSPTopLevel
    }

WidgetShowFromWidget $widget(Toplevel436a) $widget(Toplevel438a); TextEditorRunTrace "Open Window Check Binary Data Files" "b"
CheckBinRAZ8
CheckTandemQuadSSC8
}} \
        -image [vTcl:image:get_image [file join . GUI Images tools.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_3_0.but66" "Button1" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_3_0.but66 "$site_3_0.but66 Button $top all _vTclBalloon"
    bind $site_3_0.but66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Check Bin Data File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile Load_CheckSizeBinaryDataFile8

if {$OpenDirFile == 0} {

if {$Load_CheckSizeBinaryDataFile8 == 1} { Window hide $widget(Toplevel438a); TextEditorRunTrace "Close Window Check Binary Data Files" "b" }
Window hide $widget(Toplevel436a); TextEditorRunTrace "Close Window TANDEMX Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel436a" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
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
Window show .top436a

main $argc $argv
