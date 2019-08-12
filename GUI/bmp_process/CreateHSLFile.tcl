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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
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
    set base .top69
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd103 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd103
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
    namespace eval ::widgets::$site_6_0.cpd106 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd107 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.fra38 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra38
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.fra24 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra24
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd71
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd104 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd104
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
    namespace eval ::widgets::$site_6_0.cpd109 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd110 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd108 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd108 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd111 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd66
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-borderwidth 1 -relief 1}
    }
    set site_6_0 $site_5_0.cpd67
    namespace eval ::widgets::$site_6_0.che68 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.but69 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.rad67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra70
    namespace eval ::widgets::$site_5_0.tit71 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.tit71 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra72
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd77 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra72
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd78 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra72
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd105 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd105
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
    namespace eval ::widgets::$site_6_0.but112 {
        array set save {-image 1 -pady 1 -relief 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m71 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top69
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

proc vTclWindow.top69 {base} {
    if {$base == ""} {
        set base .top69
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
    wm geometry $top 500x550+10+110; update
    wm maxsize $top 1028 752
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create HSL File"
    vTcl:DefineAlias "$top" "Toplevel69" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd103 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd103" "Frame1" vTcl:WidgetProc "Toplevel69" 1
    set site_3_0 $top.cpd103
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel69" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HSVDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel69" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel69" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd106 \
        \
        -command {global DirName DataDir BMPDirInput HSVDirInput HSVDirOutput ConfigFile VarError ErrorMessage

set HSVFormat "combine"
set HSVDirInput ""
set VarError ""

set HSVDirInputTmp $BMPDirInput
set DirName ""
OpenDir $DataDir "DATA INPUT DIRECTORY"
if {$DirName != ""} {
    set HSVDirInput $DirName
    } else {
    set HSVDirInput $HSVDirInputTmp
    } 
set HSVDirOutput $HSVDirInput

set ConfigFile "$HSVDirInput/config.txt"
set ErrorMessage ""
LoadConfig
if {"$ErrorMessage" != ""} {
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set HSVDirInput ""
    set HSVDirOutput ""
    if {$VarError == "cancel"} {Window hide $widget(Toplevel69); TextEditorRunTrace "Close Window Create HSL File" "b"}
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd106" "Button36" vTcl:WidgetProc "Toplevel69" 1
    bindtags $site_6_0.cpd106 "$site_6_0.cpd106 Button $top all _vTclBalloon"
    bind $site_6_0.cpd106 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd106 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel69" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable HSVDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel69" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel69" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd107 \
        \
        -command {global DirName DataDir HSVDirOutput HSVFileOutput HSVFormat

set HSVDirOutputTmp $HSVDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set HSVDirOutput $DirName
    } else {
    set HSVDirOutput $HSVDirOutputTmp
    }
if {$HSVFormat == "polar1"} {set HSVFileOutput "$HSVDirOutput/Polar1HSV.bmp"}
if {$HSVFormat == "polar2"} {set HSVFileOutput "$HSVDirOutput/Polar2HSV.bmp"}
if {$HSVFormat == "combine"} {set HSVFileOutput "$HSVDirOutput/CombineHSV.bmp"}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd107 "$site_6_0.cpd107 Button $top all _vTclBalloon"
    bind $site_6_0.cpd107 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd107 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra71 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame9" vTcl:WidgetProc "Toplevel69" 1
    set site_3_0 $top.fra71
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel69" 1
    entry $site_3_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel69" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel69" 1
    entry $site_3_0.ent60 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel69" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel69" 1
    entry $site_3_0.ent62 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel69" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel69" 1
    entry $site_3_0.ent64 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel69" 1
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
    frame $top.fra76 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame67" vTcl:WidgetProc "Toplevel69" 1
    set site_3_0 $top.fra76
    frame $site_3_0.fra38 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra38" "Frame85" vTcl:WidgetProc "Toplevel69" 1
    set site_4_0 $site_3_0.fra38
    radiobutton $site_4_0.rad67 \
        \
        -command {global HSVDirOutput HSVDirInput HSVFileOutput HSVFormat PolarType
global HSVMinHue HSVMaxHue HSVMinSat HSVMaxSat HSVMinVal HSVMaxVal
global MinMaxAutoHSV

if {$PolarType == "full"} {
    set HSVFormat "polar1"
    set HSVFileOutput "$HSVDirOutput/Polar1HSV.bmp"
    set FileInputHue "alpha"
    set FileInputSat "entropy"
    set FileInputVal "span"
    } else {
    set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set HSVFormat "combine"
    set HSVDirInput ""
    set HSVDirOutput ""
    set HSVFileOutput ""
    set FileInputSat ""
    set FileInputHue ""
    set FileInputVal ""
    }
set MinMaxAutoHSV "1"
$widget(TitleFrame69_1) configure -state disable
$widget(TitleFrame69_2) configure -state disable
$widget(TitleFrame69_3) configure -state disable
$widget(Label69_1) configure -state disable
$widget(Entry69_1) configure -state disable
$widget(Label69_2) configure -state disable
$widget(Entry69_2) configure -state disable
$widget(Label69_3) configure -state disable
$widget(Entry69_3) configure -state disable
$widget(Label69_4) configure -state disable
$widget(Entry69_4) configure -state disable
$widget(Label69_5) configure -state disable
$widget(Entry69_5) configure -state disable
$widget(Label69_6) configure -state disable
$widget(Entry69_6) configure -state disable
$widget(Button69_1) configure -state disable
$widget(Button69_2) configure -state normal
set HSVMinHue "Auto"; set HSVMaxHue "Auto"
set HSVMinSat "Auto"; set HSVMaxSat "Auto"
set HSVMinVal "Auto"; set HSVMaxVal "Auto"
$widget(Checkbutton69_1) configure -state disable} \
        -text {Polar Decomposition : Hue (Alpha) / Sat (1 - Entropy) / Light (Span)} \
        -value polar1 -variable HSVFormat 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton35" vTcl:WidgetProc "Toplevel69" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor w -expand 0 -fill none -side left 
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame384" vTcl:WidgetProc "Toplevel69" 1
    set site_4_0 $site_3_0.fra24
    radiobutton $site_4_0.rad67 \
        \
        -command {global HSVDirOutput HSVDirInput HSVFileOutput HSVFormat PolarType
global HSVMinHue HSVMaxHue HSVMinSat HSVMaxSat HSVMinVal HSVMaxVal
global MinMaxAutoHSV

if {$PolarType == "full"} {
    set HSVFormat "polar2"
    set HSVFileOutput "$HSVDirOutput/Polar2HSV.bmp"
    set FileInputHue "alpha"
    set FileInputSat "entropy"
    set FileInputVal "anisotropy"
    } else {
    set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set HSVFormat "combine"
    set HSVDirInput ""
    set HSVDirOutput ""
    set HSVFileOutput ""
    set FileInputSat ""
    set FileInputHue ""
    set FileInputVal ""
    }
set MinMaxAutoHSV "1"
$widget(TitleFrame69_1) configure -state disable
$widget(TitleFrame69_2) configure -state disable
$widget(TitleFrame69_3) configure -state disable
$widget(Label69_1) configure -state disable
$widget(Entry69_1) configure -state disable
$widget(Label69_2) configure -state disable
$widget(Entry69_2) configure -state disable
$widget(Label69_3) configure -state disable
$widget(Entry69_3) configure -state disable
$widget(Label69_4) configure -state disable
$widget(Entry69_4) configure -state disable
$widget(Label69_5) configure -state disable
$widget(Entry69_5) configure -state disable
$widget(Label69_6) configure -state disable
$widget(Entry69_6) configure -state disable
$widget(Button69_1) configure -state disable
$widget(Button69_2) configure -state normal
set HSVMinHue "Auto"; set HSVMaxHue "Auto"
set HSVMinSat "Auto"; set HSVMaxSat "Auto"
set HSVMinVal "Auto"; set HSVMaxVal "Auto"
$widget(Checkbutton69_1) configure -state disable} \
        -text {Polar Decomposition : Hue (Alpha) / Sat (1 - Entropy) / Light (Anisotropy)} \
        -value polar2 -variable HSVFormat 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton110" vTcl:WidgetProc "Toplevel69" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor w -expand 0 -fill none -side left 
    frame $site_3_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd71" "Frame86" vTcl:WidgetProc "Toplevel69" 1
    set site_4_0 $site_3_0.cpd71
    radiobutton $site_4_0.rad67 \
        \
        -command {global HSVDirOutput HSVDirInput HSVFileOutput HSVFormat PolarType TMPFileNull
global HSVMinHue HSVMaxHue HSVMinSat HSVMaxSat HSVMinVal HSVMaxVal
global MinMaxAutoHSV

set HSVFormat "combine"
set HSVFileOutput "$HSVDirOutput/CombineHSV.bmp"
set FileInputSat "$TMPFileNull"
set FileInputHue "$TMPFileNull"
set FileInputVal "$TMPFileNull"
set MinMaxAutoHSV "1"
$widget(TitleFrame69_1) configure -state disable
$widget(TitleFrame69_2) configure -state disable
$widget(TitleFrame69_3) configure -state disable
$widget(Label69_1) configure -state disable
$widget(Entry69_1) configure -state disable
$widget(Label69_2) configure -state disable
$widget(Entry69_2) configure -state disable
$widget(Label69_3) configure -state disable
$widget(Entry69_3) configure -state disable
$widget(Label69_4) configure -state disable
$widget(Entry69_4) configure -state disable
$widget(Label69_5) configure -state disable
$widget(Entry69_5) configure -state disable
$widget(Label69_6) configure -state disable
$widget(Entry69_6) configure -state disable
$widget(Button69_1) configure -state disable
$widget(Button69_2) configure -state normal
set HSVMinHue "Auto"; set HSVMaxHue "Auto"
set HSVMinSat "Auto"; set HSVMaxSat "Auto"
set HSVMinVal "Auto"; set HSVMaxVal "Auto"
$widget(Checkbutton69_1) configure -state normal} \
        -text {Combine : Hue File / Sat File / Light File} -value combine \
        -variable HSVFormat 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton36" vTcl:WidgetProc "Toplevel69" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor w -expand 0 -fill none -side left 
    pack $site_3_0.fra38 \
        -in $site_3_0 -anchor w -expand 1 -fill x -side top 
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor w -expand 1 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.cpd104 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd104" "Frame2" vTcl:WidgetProc "Toplevel69" 1
    set site_3_0 $top.cpd104
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {HUE Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame6" vTcl:WidgetProc "Toplevel69" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputHue 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel69" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame17" vTcl:WidgetProc "Toplevel69" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd109 \
        \
        -command {global FileName HSVDirInput HSVDirOutput HSVFileOutput FileInputHue HSVFormat VarError ErrorMessage TMPFileNull

set HSVFormat "combine"
if {$HSVDirInput != ""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $HSVDirInput $types "HUE INPUT FILE"
    if {$FileName != ""} {
        set FileInputHue $FileName
        set HSVFileOutput "$HSVDirOutput/CombineHSV.bmp"
        } else {
        set FileInputHue $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd109" "Button37" vTcl:WidgetProc "Toplevel69" 1
    bindtags $site_6_0.cpd109 "$site_6_0.cpd109 Button $top all _vTclBalloon"
    bind $site_6_0.cpd109 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd109 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {SAT Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel69" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputSat 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel69" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel69" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd110 \
        \
        -command {global FileName HSVDirInput HSVDirOutput HSVFileOutput FileInputSat HSVFormat VarError ErrorMessage TMPFileNull

set HSVFormat "combine"
if {$HSVDirInput != ""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $HSVDirInput $types "SAT INPUT FILE"
    if {$FileName != ""} {
        set FileInputSat $FileName
        set HSVFileOutput "$HSVDirOutput/CombineHSV.bmp"
        } else {
        set FileInputSat $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd110 "$site_6_0.cpd110 Button $top all _vTclBalloon"
    bind $site_6_0.cpd110 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd110 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd108 \
        -ipad 0 -text {LIGHT Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd108" "TitleFrame10" vTcl:WidgetProc "Toplevel69" 1
    bind $site_3_0.cpd108 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd108 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputVal 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel69" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel69" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd111 \
        \
        -command {global FileName HSVDirInput HSVDirOutput HSVFileOutput FileInputVal HSVFormat VarError ErrorMessage TMPFileNull

set HSVFormat "combine"
if {$HSVDirInput != ""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $HSVDirInput $types "VAL INPUT FILE"
    if {$FileName != ""} {
        set FileInputVal $FileName
        set HSVFileOutput "$HSVDirOutput/CombineHSV.bmp"
        } else {
        set FileInputVal $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd111" "Button39" vTcl:WidgetProc "Toplevel69" 1
    bindtags $site_6_0.cpd111 "$site_6_0.cpd111 Button $top all _vTclBalloon"
    bind $site_6_0.cpd111 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd111 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd108 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd66 \
        -ipad 0 -relief sunken -text {Color Channel Contrast Enhancement} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame11" vTcl:WidgetProc "Toplevel69" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.cpd66
    set site_5_0 $site_4_0.cpd66
    frame $site_5_0.cpd67 \
        -borderwidth 2 -relief sunken 
    set site_6_0 $site_5_0.cpd67
    checkbutton $site_6_0.che68 \
        \
        -command {global HSVMinHue HSVMaxHue HSVMinSat HSVMaxSat HSVMinVal HSVMaxVal
global MinMaxAutoHSV
if {"$MinMaxAutoHSV"=="1"} {
    $widget(TitleFrame69_1) configure -state disable
    $widget(TitleFrame69_2) configure -state disable
    $widget(TitleFrame69_3) configure -state disable
    $widget(Label69_1) configure -state disable
    $widget(Entry69_1) configure -state disable
    $widget(Label69_2) configure -state disable
    $widget(Entry69_2) configure -state disable
    $widget(Label69_3) configure -state disable
    $widget(Entry69_3) configure -state disable
    $widget(Label69_4) configure -state disable
    $widget(Entry69_4) configure -state disable
    $widget(Label69_5) configure -state disable
    $widget(Entry69_5) configure -state disable
    $widget(Label69_6) configure -state disable
    $widget(Entry69_6) configure -state disable
    $widget(Button69_1) configure -state disable
    $widget(Button69_2) configure -state normal
    set HSVMinHue "Auto"; set HSVMaxHue "Auto"
    set HSVMinSat "Auto"; set HSVMaxSat "Auto"
    set HSVMinVal "Auto"; set HSVMaxVal "Auto"
    } else {
    $widget(TitleFrame69_1) configure -state normal
    $widget(TitleFrame69_2) configure -state normal
    $widget(TitleFrame69_3) configure -state normal
    $widget(Label69_1) configure -state normal
    $widget(Entry69_1) configure -state normal
    $widget(Label69_2) configure -state normal
    $widget(Entry69_2) configure -state normal
    $widget(Label69_3) configure -state normal
    $widget(Entry69_3) configure -state normal
    $widget(Label69_4) configure -state normal
    $widget(Entry69_4) configure -state normal
    $widget(Label69_5) configure -state normal
    $widget(Entry69_5) configure -state normal
    $widget(Label69_6) configure -state normal
    $widget(Entry69_6) configure -state normal
    $widget(Button69_1) configure -state normal
    $widget(Button69_2) configure -state disable
    set HSVMinHue "?"; set HSVMaxHue "?"
    set HSVMinSat "?"; set HSVMaxSat "?"
    set HSVMinVal "?"; set HSVMaxVal "?"
    }} \
        -text Automatic -variable MinMaxAutoHSV 
    vTcl:DefineAlias "$site_6_0.che68" "Checkbutton69_1" vTcl:WidgetProc "Toplevel69" 1
    button $site_6_0.but69 \
        -background #ffff00 \
        -command {global TMPFileNull HSVDirInput HSVDirOutput HSVFileOutput HSVFormat HSVCCCE BMPDirInput
global FileInputHue FileInputSat FileInputVal MinMaxAutoHSV TMPMinMaxBmp
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global HSVMinHue HSVMaxHue HSVMinSat HSVMaxSat HSVMinVal HSVMaxVal NcolFullSize NligFullSize

$widget(Button69_2) configure -state disable

if {$OpenDirFile == 0} {

    if {"$HSVDirInput"!=""} {
    
        set config "true"
        if {"$HSVFormat"=="combine"} {
            if {"$FileInputHue"==""} {set config "false"}
            if {"$FileInputSat"==""} {set config "false"}
            if {"$FileInputVal"==""} {set config "false"}
            if {"$config"=="false"} {
                set VarError ""
                set ErrorMessage "INVALID INPUT FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$config"=="true"} {
            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            TestVar 4
            if {$TestVarError == "ok"} {
                set Fonction "Min / Max HSV Values Determination"
                set Fonction2 ""    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update

                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]

                #read MinMaxBMP
                DeleteFile $TMPMinMaxBmp

                if {"$HSVFormat"=="combine"} {
                    set config "false"
                    if {"$FileInputHue"=="$TMPFileNull"} {set config "true"}
                    if {"$FileInputSat"=="$TMPFileNull"} {set config "true"}
                    if {"$FileInputVal"=="$TMPFileNull"} {set config "true"}
                    if {"$config"=="true"} {
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_null_file.exe" "k"
                        TextEditorRunTrace "Arguments: -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
                        set f [ open "| Soft/bin/bmp_process/create_null_file.exe -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
                        }

                    set MaskCmd ""; set MaskDir ""
                    if {"$FileInputHue" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputHue] }
                    if {"$FileInputVal" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputVal] }
                    if {"$FileInputSat" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputSat] }
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                    set Argument "-ifh \x22$FileInputHue\x22 -ifs \x22$FileInputSat\x22 -ifv \x22$FileInputVal\x22 -of \x22$TMPMinMaxBmp\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd"
                    if {"$HSVCCCE"=="independant"} {
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/minmax_hsv_file.exe" "k"
                        TextEditorRunTrace "Arguments: $Argument" "k"
                        set f [ open "| Soft/bin/bmp_process/minmax_hsv_file.exe $Argument" r]
                        }
                    if {"$HSVCCCE"=="common"} {
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/minmax_hsv_cce_file.exe" "k"
                        TextEditorRunTrace "Arguments: $Argument" "k"
                        set f [ open "| Soft/bin/bmp_process/minmax_hsv_cce_file.exe $Argument" r]
                        }
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    }
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                set HSVMinHue ""; set HSVMaxHue ""
                set HSVMinVal ""; set HSVMaxVal ""
                set HSVMinSat ""; set HSVMaxSat ""

                WaitUntilCreated $TMPMinMaxBmp

                if [file exists $TMPMinMaxBmp] {
                    set f [open $TMPMinMaxBmp r]
                    gets $f HSVMinHue
                    gets $f HSVMaxHue
                    gets $f HSVMinVal
                    gets $f HSVMaxVal
                    gets $f HSVMinSat 
                    gets $f HSVMaxSat
                    close $f
                    }

                set config "true"
                if {$HSVMinHue == ""} {set config "false"}
                if {$HSVMaxHue == ""} {set config "false"}
                if {$HSVMinVal == ""} {set config "false"}
                if {$HSVMaxVal == ""} {set config "false"}
                if {$HSVMinSat == ""} {set config "false"}
                if {$HSVMaxSat == ""} {set config "false"}

                if {$config == "true"} {$widget(Button69_2) configure -state normal}
                }
            }
        } else {
        set HSVFormat " "
        set VarError ""
        set ErrorMessage "ENTER A VALID DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }} \
        -padx 4 -pady 2 -text MinMax 
    vTcl:DefineAlias "$site_6_0.but69" "Button69_1" vTcl:WidgetProc "Toplevel69" 1
    pack $site_6_0.che68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.but69 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -pady 1 \
        -side left 
    radiobutton $site_5_0.rad67 \
        -text Independant -value independant -variable HSVCCCE 
    vTcl:DefineAlias "$site_5_0.rad67" "Radiobutton3" vTcl:WidgetProc "Toplevel69" 1
    radiobutton $site_5_0.cpd68 \
        -text Common -value common -variable HSVCCCE 
    vTcl:DefineAlias "$site_5_0.cpd68" "Radiobutton4" vTcl:WidgetProc "Toplevel69" 1
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 30 -side left 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 30 -side left 
    frame $site_4_0.fra70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra70" "Frame4" vTcl:WidgetProc "Toplevel69" 1
    set site_5_0 $site_4_0.fra70
    TitleFrame $site_5_0.tit71 \
        -text {Hue Channel} 
    vTcl:DefineAlias "$site_5_0.tit71" "TitleFrame69_1" vTcl:WidgetProc "Toplevel69" 1
    bind $site_5_0.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit71 getframe]
    frame $site_7_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra72" "Frame5" vTcl:WidgetProc "Toplevel69" 1
    set site_8_0 $site_7_0.fra72
    label $site_8_0.lab73 \
        -text Min 
    vTcl:DefineAlias "$site_8_0.lab73" "Label69_1" vTcl:WidgetProc "Toplevel69" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable HSVMinHue -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry69_1" vTcl:WidgetProc "Toplevel69" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame6" vTcl:WidgetProc "Toplevel69" 1
    set site_8_0 $site_7_0.cpd76
    label $site_8_0.lab73 \
        -text Max 
    vTcl:DefineAlias "$site_8_0.lab73" "Label69_2" vTcl:WidgetProc "Toplevel69" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable HSVMaxHue -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry69_2" vTcl:WidgetProc "Toplevel69" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd77 \
        -text {Val Channel} 
    vTcl:DefineAlias "$site_5_0.cpd77" "TitleFrame69_2" vTcl:WidgetProc "Toplevel69" 1
    bind $site_5_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd77 getframe]
    frame $site_7_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra72" "Frame7" vTcl:WidgetProc "Toplevel69" 1
    set site_8_0 $site_7_0.fra72
    label $site_8_0.lab73 \
        -text Min 
    vTcl:DefineAlias "$site_8_0.lab73" "Label69_3" vTcl:WidgetProc "Toplevel69" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable HSVMinVal -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry69_3" vTcl:WidgetProc "Toplevel69" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame8" vTcl:WidgetProc "Toplevel69" 1
    set site_8_0 $site_7_0.cpd76
    label $site_8_0.lab73 \
        -text Max 
    vTcl:DefineAlias "$site_8_0.lab73" "Label69_4" vTcl:WidgetProc "Toplevel69" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable HSVMaxVal -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry69_4" vTcl:WidgetProc "Toplevel69" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd78 \
        -text {Light Channel} 
    vTcl:DefineAlias "$site_5_0.cpd78" "TitleFrame69_3" vTcl:WidgetProc "Toplevel69" 1
    bind $site_5_0.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd78 getframe]
    frame $site_7_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra72" "Frame10" vTcl:WidgetProc "Toplevel69" 1
    set site_8_0 $site_7_0.fra72
    label $site_8_0.lab73 \
        -text Min 
    vTcl:DefineAlias "$site_8_0.lab73" "Label69_5" vTcl:WidgetProc "Toplevel69" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable HSVMinSat -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry69_5" vTcl:WidgetProc "Toplevel69" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame11" vTcl:WidgetProc "Toplevel69" 1
    set site_8_0 $site_7_0.cpd76
    label $site_8_0.lab73 \
        -text Max 
    vTcl:DefineAlias "$site_8_0.lab73" "Label69_6" vTcl:WidgetProc "Toplevel69" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable HSVMaxSat -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry69_6" vTcl:WidgetProc "Toplevel69" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.tit71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.fra70 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    frame $top.cpd105 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd105" "Frame3" vTcl:WidgetProc "Toplevel69" 1
    set site_3_0 $top.cpd105
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output HSL File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel69" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable HSVFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel69" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel69" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.but112 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat 
    vTcl:DefineAlias "$site_6_0.but112" "Button1" vTcl:WidgetProc "Toplevel69" 1
    pack $site_6_0.but112 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra74 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame20" vTcl:WidgetProc "Toplevel69" 1
    set site_3_0 $top.fra74
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global TMPFileNull HSVDirInput HSVDirOutput HSVFileOutput HSVFormat HSVCCCE BMPDirInput
global FileInputHue FileInputSat FileInputVal MinMaxAutoHSV PSPViewGimpBMP
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global HSVMinHue HSVMaxHue HSVMinSat HSVMaxSat HSVMinVal HSVMaxVal NcolFullSize NligFullSize

if {$OpenDirFile == 0} {

if {"$HSVDirInput"!=""} {

    #####################################################################
    #Create Directory
    set HSVDirOutput [PSPCreateDirectoryMask $HSVDirOutput $HSVDirOutput $HSVDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
    
        set config "true"
        if {"$HSVFormat"=="combine"} {
            if {"$FileInputHue"==""} {set config "false"}
            if {"$FileInputSat"==""} {set config "false"}
            if {"$FileInputVal"==""} {set config "false"}
            if {"$config"=="false"} {
                set VarError ""
                set ErrorMessage "INVALID INPUT FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$config"=="true"} {
            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            TestVar 4
            if {$TestVarError == "ok"} {
                set Fonction "Creation of the HSV BMP File :"
                set Fonction2 "$HSVFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]
                if {"$HSVFormat"=="combine"} {
                    set config "false"
                    if {"$FileInputHue"=="$TMPFileNull"} {set config "true"}
                    if {"$FileInputSat"=="$TMPFileNull"} {set config "true"}
                    if {"$FileInputVal"=="$TMPFileNull"} {set config "true"}
                    if {"$config"=="true"} {
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_null_file.exe" "k"
                        TextEditorRunTrace "Arguments: -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
                        set f [ open "| Soft/bin/bmp_process/create_null_file.exe -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
                        }
                        
                    set MaskCmd ""; set MaskDir ""
                    if {"$FileInputHue" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputHue] }
                    if {"$FileInputVal" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputVal] }
                    if {"$FileInputSat" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputSat] }
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                    
                    if {$MinMaxAutoHSV == 1} { set Argument "-ifh \x22$FileInputHue\x22 -ifs \x22$FileInputSat\x22 -ifv \x22$FileInputVal\x22 -of \x22$HSVFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto $MinMaxAutoHSV"}
                    if {$MinMaxAutoHSV == 0} { set Argument "-ifh \x22$FileInputHue\x22 -ifs \x22$FileInputSat\x22 -ifv \x22$FileInputVal\x22 -of \x22$HSVFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto $MinMaxAutoHSV -minh $HSVMinHue -maxh $HSVMaxHue -mins $HSVMinSat -maxs $HSVMaxSat -minv $HSVMinVal -maxv $HSVMaxVal"}
                    if {"$HSVCCCE"=="independant"} {
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_hsv_file.exe" "k"
                        TextEditorRunTrace "Arguments: $Argument" "k"
                        set f [ open "| Soft/bin/bmp_process/create_hsv_file.exe $Argument" r]
                        }
                    if {"$HSVCCCE"=="common"} {
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_hsv_cce_file.exe" "k"
                        TextEditorRunTrace "Arguments: $Argument" "k"
                        set f [ open "| Soft/bin/bmp_process/create_hsv_cce_file.exe $Argument" r]
                        }
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    set BMPDirInput $HSVDirOutput
                    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $HSVFileOutput }
                    }
                if {"$HSVFormat"=="polar1"} {
                    set config "true"
                    set fichier "$HSVDirInput/span.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE span.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        } 
                    set fichier "$HSVDirInput/entropy.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE entropy.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        } 
                    set fichier "$HSVDirInput/alpha.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
                        set VarError ""
                        set ErrorMessage "THE FILE alpha.bin MUST BE CREATED FIRST"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        } 
                    if {"$config"=="true"} {
                        set MaskCmd ""
                        set MaskDir $HSVDirInput
                        set MaskFile "$MaskDir/mask_valid_pixels.bin"
                        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_polar1_hsv_file.exe" "k"
                        TextEditorRunTrace "Arguments: -id \x22$HSVDirInput\x22 -of \x22$HSVFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                        set f [ open "| Soft/bin/bmp_process/create_polar1_hsv_file.exe -id \x22$HSVDirInput\x22 -of \x22$HSVFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                        PsPprogressBar $f
                        TextEditorRunTrace "Check RunTime Errors" "r"
                        CheckRunTimeError
                        set BMPDirInput $HSVDirOutput
                       if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $HSVFileOutput }
                        }
                    }
                if {"$HSVFormat"=="polar2"} {
                    set config "true"
                    set fichier "$HSVDirInput/anisotropy.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
    			      set VarError ""
    			      set ErrorMessage "THE FILE anisotropy.bin MUST BE CREATED FIRST"
    			      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    			      tkwait variable VarError
                        } 
                    set fichier "$HSVDirInput/entropy.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
    			      set VarError ""
    			      set ErrorMessage "THE FILE entropy.bin MUST BE CREATED FIRST"
    			      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    			      tkwait variable VarError
                        } 
                    set fichier "$HSVDirInput/alpha.bin"
                    if [file exists $fichier] {
                        } else {
                        set config "false"
    			      set VarError ""
    			      set ErrorMessage "THE FILE alpha.bin MUST BE CREATED FIRST"
    			      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    			      tkwait variable VarError
                        } 
                    if {"$config"=="true"} {
                        set MaskCmd ""
                        set MaskDir $HSVDirInput
                        set MaskFile "$MaskDir/mask_valid_pixels.bin"
                        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
                        TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_polar2_hsv_file.exe" "k"
                        TextEditorRunTrace "Arguments: -id \x22$HSVDirInput\x22 -of \x22$HSVFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                        set f [ open "| Soft/bin/bmp_process/create_polar2_hsv_file.exe -id \x22$HSVDirInput\x22 -of \x22$HSVFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                        PsPprogressBar $f
                        TextEditorRunTrace "Check RunTime Errors" "r"
                        CheckRunTimeError
                        set BMPDirInput $HSVDirOutput
                        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $HSVFileOutput }
                        }
                    }
                set HSVFormat " "
                set FileInputHue ""
                set FileInputSat ""
                set FileInputVal ""
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                Window hide $widget(Toplevel69); TextEditorRunTrace "Close Window Create HSL File" "b"
                }
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel69); TextEditorRunTrace "Close Window Create HSL File" "b"}
        }
    } else {
    set HSVFormat " "
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button69_2" vTcl:WidgetProc "Toplevel69" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CreateHSLFile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel69" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global DisplayMainMenu OpenDirFile

if {$OpenDirFile == 0} {

Window hide $widget(Toplevel69); TextEditorRunTrace "Close Window Create HSL File" "b"
if {$DisplayMainMenu == 1} {
    set DisplayMainMenu 0
    WidgetShow $widget(Toplevel2)
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel69" 1
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
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd103 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.cpd104 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd105 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 1 -fill x -pady 10 -side bottom 

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
Window show .top69

main $argc $argv
