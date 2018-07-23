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
    set base .top201
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd122 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd122
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
    namespace eval ::widgets::$site_6_0.cpd125 {
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
    namespace eval ::widgets::$site_6_0.cpd126 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
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
    namespace eval ::widgets::$base.fra69 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra69
    namespace eval ::widgets::$site_3_0.fra70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra70
    namespace eval ::widgets::$site_4_0.ent72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd71
    namespace eval ::widgets::$site_4_0.fra38 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra38
    namespace eval ::widgets::$site_5_0.rad67 {
        array set save {-anchor 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.rad67 {
        array set save {-anchor 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.rad68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-anchor 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd123 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd123
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-foreground 1 -ipad 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd127 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-foreground 1 -ipad 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd128 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd129 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.che69 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.but68 {
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
    namespace eval ::widgets::$site_7_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra73
    namespace eval ::widgets::$site_8_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd76 {
        array set save {-background 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd78
    namespace eval ::widgets::$site_8_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd76 {
        array set save {-background 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd79 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra73
    namespace eval ::widgets::$site_8_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd76 {
        array set save {-background 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd78
    namespace eval ::widgets::$site_8_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd76 {
        array set save {-background 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd80 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra73
    namespace eval ::widgets::$site_8_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd76 {
        array set save {-background 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd78
    namespace eval ::widgets::$site_8_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd76 {
        array set save {-background 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd124 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd124
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
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m24 {
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
            vTclWindow.top201
            CreateRGBC2
            CreateRGBIPP
            CreateRGBSPP
            MinMaxRGBC2
            MinMaxRGBIPP
            MinMaxRGBSPP
            CreateRGBCombinePP
            MinMaxRGBCombinePP
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
## Procedure:  CreateRGBC2

proc ::CreateRGBC2 {} {
global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB 
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol PSPViewGimpBMP
global VarError ErrorMessage Fonction Fonction2 ProgressLine PSPViewGimpBMP
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set config "true"
set fichier "$RGBDirInput/C11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C11.bin MUST BE CREATED FIRST"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C12_real.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C12_real.bin MUST BE CREATED FIRST"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C22.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C22.bin MUST BE CREATED FIRST"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    if {$RGBFormat == "RGB1" || $RGBFormat == "RGB2"} {
        if {$MinMaxAutoRGB == 1} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat -auto $MinMaxAutoRGB" }
        if {$MinMaxAutoRGB == 0} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat -auto $MinMaxAutoRGB -minb $RGBMinBlue -maxb $RGBMaxBlue -minr $RGBMinRed -maxr $RGBMaxRed -ming $RGBMinGreen -maxg $RGBMaxGreen"}
        if {"$RGBCCCE"=="independant"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2 $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }
        if {"$RGBCCCE"=="common"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_cce_file_SPPIPPC2.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/create_rgb_cce_file_SPPIPPC2 $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }
        } else {
        if {$MinMaxAutoRGB == 1} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -auto $MinMaxAutoRGB" }
        if {$MinMaxAutoRGB == 0} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -auto $MinMaxAutoRGB -minb $RGBMinBlue -maxb $RGBMaxBlue -minr $RGBMinRed -maxr $RGBMaxRed -ming $RGBMinGreen -maxg $RGBMaxGreen"}
        if {$RGBFormat == "Stokes1"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_Stokes.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/create_rgb_file_Stokes $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }
        if {$RGBFormat == "Stokes2"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_hsv_file_Stokes.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/create_hsv_file_Stokes $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }
        }
    }                                 
}
#############################################################################
## Procedure:  CreateRGBIPP

proc ::CreateRGBIPP {} {
global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB 
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol PSPViewGimpBMP
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError PolarType
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set config "true"
if {$PolarType == "pp4"} {
    set VarError ""
    set ErrorMessage "IMPOSSIBLE TO CREATE A RGB FILE IN pp4 MODE"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set fichier "$RGBDirInput/"
    append fichier "$Channel1.bin"
    if [file exists $fichier] {
        } else {
        set config "false"
        }
    set fichier "$RGBDirInput/"
    append fichier "$Channel2.bin"
    if [file exists $fichier] {
        } else {
        set config "false"
        }
    if {"$config"=="true"} {
        if {$MinMaxAutoRGB == 1} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf IPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat -auto $MinMaxAutoRGB" }
        if {$MinMaxAutoRGB == 0} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf IPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat -auto $MinMaxAutoRGB -minb $RGBMinBlue -maxb $RGBMaxBlue -minr $RGBMinRed -maxr $RGBMaxRed -ming $RGBMinGreen -maxg $RGBMaxGreen"}
        if {"$RGBCCCE"=="independant"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2 $ArgumentRGB" r]
            }
        if {"$RGBCCCE"=="common"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_cce_file_SPPIPPC2.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/create_rgb_cce_file_SPPIPPC2 $ArgumentRGB" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set BMPDirInput $RGBDirOutput
        if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
        } else {
        set VarError ""
        set ErrorMessage "THE FILES $Channel1 AND $Channel2 MUST BE CREATED FIRST"
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }
}
#############################################################################
## Procedure:  CreateRGBSPP

proc ::CreateRGBSPP {} {
global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB 
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol PSPViewGimpBMP
global VarError ErrorMessage Fonction Fonction2 ProgressLine 
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError PolarType
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set config "true"
if {$PolarType == "pp4"} {
    set VarError ""
    set ErrorMessage "IMPOSSIBLE TO CREATE A RGB FILE IN pp4 MODE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set fichier "$RGBDirInput/"
    append fichier "$Channel1.bin"
    if [file exists $fichier] {
        } else {
        set config "false"
        }
    set fichier "$RGBDirInput/"
    append fichier "$Channel2.bin"
    if [file exists $fichier] {
        } else {
        set config "false"
        }
    if {"$config"=="true"} {
        if {$RGBFormat == "RGB1" || $RGBFormat == "RGB2"} {
            if {$MinMaxAutoRGB == 1} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat -auto $MinMaxAutoRGB" }
            if {$MinMaxAutoRGB == 0} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat -auto $MinMaxAutoRGB -minb $RGBMinBlue -maxb $RGBMaxBlue -minr $RGBMinRed -maxr $RGBMaxRed -ming $RGBMinGreen -maxg $RGBMaxGreen"}
            if {"$RGBCCCE"=="independant"} {
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_SPPIPPC2.exe" "k"
                TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
                set f [ open "| Soft/bmp_process/create_rgb_file_SPPIPPC2 $ArgumentRGB" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }
            if {"$RGBCCCE"=="common"} {
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_cce_file_SPPIPPC2.exe" "k"
                TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
                set f [ open "| Soft/bmp_process/create_rgb_cce_file_SPPIPPC2 $ArgumentRGB" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }
            } else {
            if {$MinMaxAutoRGB == 1} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -auto $MinMaxAutoRGB" }
            if {$MinMaxAutoRGB == 0} { set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf SPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -auto $MinMaxAutoRGB -minb $RGBMinBlue -maxb $RGBMaxBlue -minr $RGBMinRed -maxr $RGBMaxRed -ming $RGBMinGreen -maxg $RGBMaxGreen"}
            if {$RGBFormat == "Stokes1"} {
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file_Stokes.exe" "k"
                TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
                set f [ open "| Soft/bmp_process/create_rgb_file_Stokes $ArgumentRGB" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }
            if {$RGBFormat == "Stokes2"} {
                TextEditorRunTrace "Process The Function Soft/bmp_process/create_hsv_file_Stokes.exe" "k"
                TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
                set f [ open "| Soft/bmp_process/create_hsv_file_Stokes $ArgumentRGB" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set BMPDirInput $RGBDirOutput
                if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
                }
            }
        } else {
        set VarError ""
        set ErrorMessage "THE FILES $Channel1 AND $Channel2 MUST BE CREATED FIRST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }
}
#############################################################################
## Procedure:  MinMaxRGBC2

proc ::MinMaxRGBC2 {} {
global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB TMPMinMaxBmp
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set config "true"
set fichier "$RGBDirInput/C11.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C11.bin MUST BE CREATED FIRST"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C12_real.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C12_real.bin MUST BE CREATED FIRST"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
set fichier "$RGBDirInput/C22.bin"
if [file exists $fichier] {
    } else {
    set config "false"
    set VarError ""
    set ErrorMessage "THE FILE C22.bin MUST BE CREATED FIRST"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {"$config"=="true"} {
    if {$RGBFormat == "RGB1" || $RGBFormat == "RGB2"} {
        set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$TMPMinMaxBmp\x22 -iodf C2 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat"
        if {"$RGBCCCE"=="independant"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_file_SPPIPPC2.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/minmax_rgb_file_SPPIPPC2 $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if {"$RGBCCCE"=="common"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_cce_file_SPPIPPC2.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/minmax_rgb_cce_file_SPPIPPC2 $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        } else {
        set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf C2 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22"
        if {$RGBFormat == "Stokes1"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_file_Stokes.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/minmax_rgb_file_Stokes $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if {$RGBFormat == "Stokes2"} {
            }
        }
    }                                 
}
#############################################################################
## Procedure:  MinMaxRGBIPP

proc ::MinMaxRGBIPP {} {
global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB TMPMinMaxBmp
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError PolarType
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set config "true"
if {$PolarType == "pp4"} {
    set VarError ""
    set ErrorMessage "IMPOSSIBLE TO CREATE A RGB FILE IN pp4 MODE"
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set fichier "$RGBDirInput/"
    append fichier "$Channel1.bin"
    if [file exists $fichier] {
        } else {
        set config "false"
        }
    set fichier "$RGBDirInput/"
    append fichier "$Channel2.bin"
    if [file exists $fichier] {
        } else {
        set config "false"
        }
    if {"$config"=="true"} {
        set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$TMPMinMaxBmp\x22 -iodf IPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat"
        if {"$RGBCCCE"=="independant"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_file_SPPIPPC2.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/minmax_rgb_file_SPPIPPC2 $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        if {"$RGBCCCE"=="common"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_cce_file_SPPIPPC2.exe" "k"
            TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
            set f [ open "| Soft/bmp_process/minmax_rgb_cce_file_SPPIPPC2 $ArgumentRGB" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            }
        } else {
        set VarError ""
        set ErrorMessage "THE FILES $Channel1 AND $Channel2 MUST BE CREATED FIRST"
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }
}
#############################################################################
## Procedure:  MinMaxRGBSPP

proc ::MinMaxRGBSPP {} {
global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB TMPMinMaxBmp
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError PolarType
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

set config "true"
if {$PolarType == "pp4"} {
    set VarError ""
    set ErrorMessage "IMPOSSIBLE TO CREATE A RGB FILE IN pp4 MODE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {
    set fichier "$RGBDirInput/"
    append fichier "$Channel1.bin"
    if [file exists $fichier] {
        } else {
        set config "false"
        }
    set fichier "$RGBDirInput/"
    append fichier "$Channel2.bin"
    if [file exists $fichier] {
        } else {
        set config "false"
        }
    if {"$config"=="true"} {
        if {$RGBFormat == "RGB1" || $RGBFormat == "RGB2"} {
            set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$TMPMinMaxBmp\x22 -iodf SPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -rgbf $RGBFormat"
            if {"$RGBCCCE"=="independant"} {
                TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_file_SPPIPPC2.exe" "k"
                TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
                set f [ open "| Soft/bmp_process/minmax_rgb_file_SPPIPPC2 $ArgumentRGB" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                }
            if {"$RGBCCCE"=="common"} {
                TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_cce_file_SPPIPPC2.exe" "k"
                TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
                set f [ open "| Soft/bmp_process/minmax_rgb_cce_file_SPPIPPC2 $ArgumentRGB" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                }
            } else {
            set ArgumentRGB "-id \x22$RGBDirInput\x22 -of \x22$TMPMinMaxBmp\x22 -iodf SPP -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22"
            if {$RGBFormat == "Stokes1"} {
                TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_file_Stokes.exe" "k"
                TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
                set f [ open "| Soft/bmp_process/minmax_rgb_file_Stokes $ArgumentRGB" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                }
            if {$RGBFormat == "Stokes2"} {
                }
            }
        } else {
        set VarError ""
        set ErrorMessage "THE FILES $Channel1 AND $Channel2 MUST BE CREATED FIRST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }
}
#############################################################################
## Procedure:  CreateRGBCombinePP

proc ::CreateRGBCombinePP {} {
global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB 
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize
global VarError ErrorMessage Fonction Fonction2 ProgressLine PSPViewGimpBMP 
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax


set config "false"
if {"$FileInputBlue"=="$TMPFileNull"} {set config "true"}
if {"$FileInputRed"=="$TMPFileNull"} {set config "true"}
if {"$FileInputGreen"=="$TMPFileNull"} {set config "true"}
if {"$config"=="true"} {
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_null_file.exe" "k"
    TextEditorRunTrace "Arguments: -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
    set f [ open "| Soft/bmp_process/create_null_file.exe -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
    }
if {$MinMaxAutoRGB == 1} { set ArgumentRGB "-ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -auto $MinMaxAutoRGB"}
if {$MinMaxAutoRGB == 0} { set ArgumentRGB "-ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 -auto $MinMaxAutoRGB -minb $RGBMinBlue -maxb $RGBMaxBlue -minr $RGBMinRed -maxr $RGBMaxRed -ming $RGBMinGreen -maxg $RGBMaxGreen"}
if {"$RGBCCCE"=="independant"} {
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
    set f [ open "| Soft/bmp_process/create_rgb_file.exe $ArgumentRGB" r]
    }
if {"$RGBCCCE"=="common"} {
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_cce_file.exe" "k"
    TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
    set f [ open "| Soft/bmp_process/create_rgb_cce_file.exe $ArgumentRGB" r]
    }
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
set BMPDirInput $RGBDirOutput
if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
}
#############################################################################
## Procedure:  MinMaxRGBCombinePP

proc ::MinMaxRGBCombinePP {} {
global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB TMPMinMaxBmp
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax


set config "false"
if {"$FileInputBlue"=="$TMPFileNull"} {set config "true"}
if {"$FileInputRed"=="$TMPFileNull"} {set config "true"}
if {"$FileInputGreen"=="$TMPFileNull"} {set config "true"}
if {"$config"=="true"} {
    TextEditorRunTrace "Process The Function Soft/bmp_process/create_null_file.exe" "k"
    TextEditorRunTrace "Arguments: -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
    set f [ open "| Soft/bmp_process/create_null_file.exe -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
    }
set ArgumentRGB "-ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$TMPMinMaxBmp\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol $MaskCmd -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22"
if {"$RGBCCCE"=="independant"} {
    TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
    set f [ open "| Soft/bmp_process/minmax_rgb_file.exe $ArgumentRGB" r]
    }
if {"$RGBCCCE"=="common"} {
    TextEditorRunTrace "Process The Function Soft/bmp_process/minmax_rgb_cce_file.exe" "k"
    TextEditorRunTrace "Arguments: $ArgumentRGB" "k"
    set f [ open "| Soft/bmp_process/minmax_rgb_cce_file.exe $ArgumentRGB" r]
    }
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
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
    wm geometry $top 200x200+75+75; update
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

proc vTclWindow.top201 {base} {
    if {$base == ""} {
        set base .top201
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
    wm geometry $top 500x560+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create RGB File"
    vTcl:DefineAlias "$top" "Toplevel201" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd122 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd122" "Frame3" vTcl:WidgetProc "Toplevel201" 1
    set site_3_0 $top.cpd122
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel201" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RGBDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel201" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame16" vTcl:WidgetProc "Toplevel201" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd125 \
        \
        -command {global DirName DataDir BMPDirInput RGBFunction RGBDirInput RGBDirOutput ConfigFile VarError ErrorMessage
global Channel1 Channel2
set RGBFormat "combine"
set RGBFunction "SPP"
set RGBDirInput ""
set VarError ""

set RGBDirInputTmp $BMPDirInput
set DirName ""
OpenDir $DataDir "DATA INPUT DIRECTORY"
if {$DirName != ""} {
    set RGBDirInput $DirName
    } else {
    set RGBDirInput $RGBDirInputTmp
    } 
set RGBDirOutput $RGBDirInput

set RGBFunction ""
set ConfigFile "$RGBDirInput/config.txt"
set ErrorMessage ""
LoadConfig
if {"$ErrorMessage" != ""} {
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RGBDirInput ""
    set RGBDirOutput ""
    if {$VarError == "cancel"} {Window hide $widget(Toplevel201); TextEditorRunTrace "Close Window Create RGB File PP" "b"}
    } else {
    if { "$PolarType" != "full"} {
            if {$RGBFunction == ""} {
                set config "false"
                if [file exists "$RGBDirInput/s11.bin"] {set config "true"}
                if [file exists "$RGBDirInput/s22.bin"] {set config "true"}
                if {$config == "true"} {    
                    set RGBFunction "SPP"
                    if { "$PolarType" == "pp1"} {
                        set Channel1 "s11"
                        set Channel2 "s21"
                        }
                    if { "$PolarType" == "pp2"} {
                        set Channel1 "s22"
                        set Channel2 "s12"
                        }
                    if { "$PolarType" == "pp3"} {
                        set Channel1 "s11"
                        set Channel2 "s22"
                        }
                    }
                }
            if {$RGBFunction == ""} {
                set config "false"
                if [file exists "$RGBDirInput/I11.bin"] {set config "true"}
                if [file exists "$RGBDirInput/I22.bin"] {set config "true"}
                if {$config == "true"} {    
                    set RGBFunction "IPP"
                    if { "$PolarType" == "pp4"} {
                        set ErrorMessage "IMPOSSIBLE TO CREATE A RGB FILE IN pp4 MODE"
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        set ErrorMessage ""
                        }
                    if { "$PolarType" == "pp5"} {
                        set Channel1 "I11"
                        set Channel2 "I21"
                        }
                    if {"$PolarType" == "pp6"} {
                        set Channel1 "I22"
                        set Channel2 "I12"
                        }
                    if { "$PolarType" == "pp7"} {
                        set Channel1 "I11"
                        set Channel2 "I22"
                        }
                    }
                }
            if {$RGBFunction == ""} {
                set config "false"
                if [file exists "$RGBDirInput/C11.bin"] {set config "true"}
                if [file exists "$RGBDirInput/C22.bin"] {set config "true"}
                if {$config == "true"} {    
                    set RGBFunction "C2"
                    }
                }                    
        } else {
        set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set ErrorMessage ""
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd125" "Button36" vTcl:WidgetProc "Toplevel201" 1
    bindtags $site_6_0.cpd125 "$site_6_0.cpd125 Button $top all _vTclBalloon"
    bind $site_6_0.cpd125 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd125 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel201" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel201" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel201" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd126 \
        \
        -command {global DirName DataDir RGBDirOutput RGBFileOutput RGBFormat

set RGBDirOutputTmp $RGBDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set RGBDirOutput $DirName
    } else {
    set RGBDirOutput $RGBDirOutputTmp
    }
if {$RGBFormat == "RGB1"} {set RGBFileOutput "$RGBDirOutput/RGB1.bmp"}
if {$RGBFormat == "RGB2"} {set RGBFileOutput "$RGBDirOutput/RGB2.bmp"}
if {$RGBFormat == "combine"} {set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp"}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd126 "$site_6_0.cpd126 Button $top all _vTclBalloon"
    bind $site_6_0.cpd126 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd126 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra41 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame9" vTcl:WidgetProc "Toplevel201" 1
    set site_3_0 $top.fra41
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel201" 1
    entry $site_3_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel201" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel201" 1
    entry $site_3_0.ent60 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel201" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel201" 1
    entry $site_3_0.ent62 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel201" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel201" 1
    entry $site_3_0.ent64 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel201" 1
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
    frame $top.fra69 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra69" "Frame1" vTcl:WidgetProc "Toplevel201" 1
    set site_3_0 $top.fra69
    frame $site_3_0.fra70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra70" "Frame2" vTcl:WidgetProc "Toplevel201" 1
    set site_4_0 $site_3_0.fra70
    entry $site_4_0.ent72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PolarType -width 4 
    vTcl:DefineAlias "$site_4_0.ent72" "Entry1" vTcl:WidgetProc "Toplevel201" 1
    label $site_4_0.lab73 \
        -text {Channel 1} 
    vTcl:DefineAlias "$site_4_0.lab73" "Label1" vTcl:WidgetProc "Toplevel201" 1
    entry $site_4_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Channel1 -width 4 
    vTcl:DefineAlias "$site_4_0.ent74" "Entry2" vTcl:WidgetProc "Toplevel201" 1
    label $site_4_0.lab75 \
        -text {Channel 2} 
    vTcl:DefineAlias "$site_4_0.lab75" "Label2" vTcl:WidgetProc "Toplevel201" 1
    entry $site_4_0.ent76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Channel2 -width 4 
    vTcl:DefineAlias "$site_4_0.ent76" "Entry3" vTcl:WidgetProc "Toplevel201" 1
    pack $site_4_0.ent72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.lab73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.lab75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd71" "Frame71" vTcl:WidgetProc "Toplevel201" 1
    set site_4_0 $site_3_0.cpd71
    frame $site_4_0.fra38 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra38" "Frame87" vTcl:WidgetProc "Toplevel201" 1
    set site_5_0 $site_4_0.fra38
    radiobutton $site_5_0.rad67 \
        -anchor center \
        -command {global ActiveProgram RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType RGBFunction Channel1 Channel2
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global MinMaxAutoRGB RGBFormat

if {$PolarType != "full"} {
    set RGBFormat "RGB1"
    set RGBFileOutput "$RGBDirOutput/RGB1.bmp"
    if {$ActiveProgram == "ASAR"} {set RGBFileOutput "$RGBDirOutput/AsarRGB1.bmp"}
    set FileInputBlue "|$Channel1|"
    set FileInputGreen "|$Channel1 - $Channel2|"
    set FileInputRed "|$Channel2|"
    if {"$RGBFunction"=="C2"} {
        set FileInputBlue "C11"
        set FileInputGreen "|C11 - 2*C12r + C22|"
        set FileInputRed "C22"
        }
    } else {
    set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RGBFormat "combine"
    set RGBDirInput ""
    set RGBDirOutput ""
    set RGBFileOutput ""
    set FileInputBlue ""
    set FileInputGreen ""
    set FileInputRed ""
    }
set MinMaxAutoRGB "1"
$widget(TitleFrame201_1) configure -state disable
$widget(TitleFrame201_2) configure -state disable
$widget(TitleFrame201_3) configure -state disable
$widget(Label201_1) configure -state disable
$widget(Entry201_1) configure -state disable
$widget(Label201_2) configure -state disable
$widget(Entry201_2) configure -state disable
$widget(Label201_3) configure -state disable
$widget(Entry201_3) configure -state disable
$widget(Label201_4) configure -state disable
$widget(Entry201_4) configure -state disable
$widget(Label201_5) configure -state disable
$widget(Entry201_5) configure -state disable
$widget(Label201_6) configure -state disable
$widget(Entry201_6) configure -state disable
$widget(Button201_1) configure -state disable
$widget(Button201_2) configure -state normal
set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
set RGBMinRed "Auto"; set RGBMaxRed "Auto"
set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"} \
        -text {RGB Color Composition 1} -value RGB1 -variable RGBFormat 
    vTcl:DefineAlias "$site_5_0.rad67" "Radiobutton37" vTcl:WidgetProc "Toplevel201" 1
    radiobutton $site_5_0.rad68 \
        \
        -command {global ActiveProgram RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType RGBFunction Channel1 Channel2
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global MinMaxAutoRGB RGBFormat

if {$PolarType != "full"} {
    set RGBFormat "RGB2"
    set RGBFileOutput "$RGBDirOutput/RGB2.bmp"
    if {$ActiveProgram == "ASAR"} {set RGBFileOutput "$RGBDirOutput/AsarRGB2.bmp"}
    set FileInputBlue "|$Channel2|"
    set FileInputGreen "|$Channel2 - $Channel1|"
    set FileInputRed "|$Channel1|"
    if {"$RGBFunction"=="C2"} {
        set FileInputBlue "C22"
        set FileInputGreen "|C22 - 2*C12r + C11|"
        set FileInputRed "C11"
        }
    } else {
    set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RGBFormat "combine"
    set RGBDirInput ""
    set RGBDirOutput ""
    set RGBFileOutput ""
    set FileInputBlue ""
    set FileInputGreen ""
    set FileInputRed ""
    }
set MinMaxAutoRGB "1"
$widget(TitleFrame201_1) configure -state disable
$widget(TitleFrame201_2) configure -state disable
$widget(TitleFrame201_3) configure -state disable
$widget(Label201_1) configure -state disable
$widget(Entry201_1) configure -state disable
$widget(Label201_2) configure -state disable
$widget(Entry201_2) configure -state disable
$widget(Label201_3) configure -state disable
$widget(Entry201_3) configure -state disable
$widget(Label201_4) configure -state disable
$widget(Entry201_4) configure -state disable
$widget(Label201_5) configure -state disable
$widget(Entry201_5) configure -state disable
$widget(Label201_6) configure -state disable
$widget(Entry201_6) configure -state disable
$widget(Button201_1) configure -state disable
$widget(Button201_2) configure -state normal
set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
set RGBMinRed "Auto"; set RGBMaxRed "Auto"
set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"} \
        -text {RGB Color Composition 2} -value RGB2 -variable RGBFormat 
    vTcl:DefineAlias "$site_5_0.rad68" "Radiobutton38" vTcl:WidgetProc "Toplevel201" 1
    pack $site_5_0.rad67 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    pack $site_5_0.rad68 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    frame $site_4_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame88" vTcl:WidgetProc "Toplevel201" 1
    set site_5_0 $site_4_0.cpd73
    radiobutton $site_5_0.rad67 \
        -anchor center \
        -command {global ActiveProgram RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType RGBFunction Channel1 Channel2
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global MinMaxAutoRGB RGBFormat

if {$PolarType != "full"} {
    set RGBFormat "Stokes1"
    set RGBFileOutput "$RGBDirOutput/StokesRGB.bmp"
    set FileInputBlue "g1 / g0"
    set FileInputGreen "g3 / g0"
    set FileInputRed "g2 / g0"
    } else {
    set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RGBFormat "combine"
    set RGBDirInput ""
    set RGBDirOutput ""
    set RGBFileOutput ""
    set FileInputBlue ""
    set FileInputGreen ""
    set FileInputRed ""
    }
set MinMaxAutoRGB "1"
$widget(TitleFrame201_1) configure -state disable
$widget(TitleFrame201_2) configure -state disable
$widget(TitleFrame201_3) configure -state disable
$widget(Label201_1) configure -state disable
$widget(Entry201_1) configure -state disable
$widget(Label201_2) configure -state disable
$widget(Entry201_2) configure -state disable
$widget(Label201_3) configure -state disable
$widget(Entry201_3) configure -state disable
$widget(Label201_4) configure -state disable
$widget(Entry201_4) configure -state disable
$widget(Label201_5) configure -state disable
$widget(Entry201_5) configure -state disable
$widget(Label201_6) configure -state disable
$widget(Entry201_6) configure -state disable
$widget(Button201_1) configure -state disable
$widget(Button201_2) configure -state normal
set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
set RGBMinRed "Auto"; set RGBMaxRed "Auto"
set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"} \
        -text {RGB Stokes Composition} -value Stokes1 -variable RGBFormat 
    vTcl:DefineAlias "$site_5_0.rad67" "Radiobutton201_1" vTcl:WidgetProc "Toplevel201" 1
    radiobutton $site_5_0.rad68 \
        \
        -command {global ActiveProgram RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType RGBFunction Channel1 Channel2
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global MinMaxAutoRGB RGBFormat

if {$PolarType != "full"} {
    set RGBFormat "Stokes2"
    set RGBFileOutput "$RGBDirOutput/StokesHSV.bmp"
    set FileInputBlue "Refer to the Widget Help File"
    set FileInputGreen "for a complete description"
    set FileInputRed "of the Color Composition Coding"
    } else {
    set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RGBFormat "combine"
    set RGBDirInput ""
    set RGBDirOutput ""
    set RGBFileOutput ""
    set FileInputBlue ""
    set FileInputGreen ""
    set FileInputRed ""
    }
set MinMaxAutoRGB "1"
$widget(TitleFrame201_1) configure -state disable
$widget(TitleFrame201_2) configure -state disable
$widget(TitleFrame201_3) configure -state disable
$widget(Label201_1) configure -state disable
$widget(Entry201_1) configure -state disable
$widget(Label201_2) configure -state disable
$widget(Entry201_2) configure -state disable
$widget(Label201_3) configure -state disable
$widget(Entry201_3) configure -state disable
$widget(Label201_4) configure -state disable
$widget(Entry201_4) configure -state disable
$widget(Label201_5) configure -state disable
$widget(Entry201_5) configure -state disable
$widget(Label201_6) configure -state disable
$widget(Entry201_6) configure -state disable
$widget(Button201_1) configure -state disable
$widget(Button201_2) configure -state normal
set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
set RGBMinRed "Auto"; set RGBMaxRed "Auto"
set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"} \
        -text {HSV Stokes Composition} -value Stokes2 -variable RGBFormat 
    vTcl:DefineAlias "$site_5_0.rad68" "Radiobutton201_2" vTcl:WidgetProc "Toplevel201" 1
    pack $site_5_0.rad67 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    pack $site_5_0.rad68 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.fra38 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    radiobutton $site_3_0.cpd78 \
        -anchor center \
        -command {global ActiveProgram RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType RGBFunction Channel1 Channel2 TMPFileNull
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global MinMaxAutoRGB RGBFormat

set RGBFormat "combine"
set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp"
set FileInputBlue "$TMPFileNull"
set FileInputGreen "$TMPFileNull"
set FileInputRed "$TMPFileNull"
set MinMaxAutoRGB "1"
$widget(TitleFrame201_1) configure -state disable
$widget(TitleFrame201_2) configure -state disable
$widget(TitleFrame201_3) configure -state disable
$widget(Label201_1) configure -state disable
$widget(Entry201_1) configure -state disable
$widget(Label201_2) configure -state disable
$widget(Entry201_2) configure -state disable
$widget(Label201_3) configure -state disable
$widget(Entry201_3) configure -state disable
$widget(Label201_4) configure -state disable
$widget(Entry201_4) configure -state disable
$widget(Label201_5) configure -state disable
$widget(Entry201_5) configure -state disable
$widget(Label201_6) configure -state disable
$widget(Entry201_6) configure -state disable
$widget(Button201_1) configure -state disable
$widget(Button201_2) configure -state normal
set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
set RGBMinRed "Auto"; set RGBMaxRed "Auto"
set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"} \
        -text {Combine ( Blue File / Green File / Red File )} -value combine \
        -variable RGBFormat 
    vTcl:DefineAlias "$site_3_0.cpd78" "Radiobutton39" vTcl:WidgetProc "Toplevel201" 1
    pack $site_3_0.fra70 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side top 
    frame $top.cpd123 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd123" "Frame4" vTcl:WidgetProc "Toplevel201" 1
    set site_3_0 $top.cpd123
    TitleFrame $site_3_0.cpd97 \
        -foreground #0000ff -ipad 0 -text {BLUE Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame6" vTcl:WidgetProc "Toplevel201" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputBlue 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel201" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame18" vTcl:WidgetProc "Toplevel201" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd127 \
        \
        -command {global FileName RGBDirInput RGBDirOutput RGBFileOutput FileInputBlue RGBFormat VarError ErrorMessage TMPFileNull

set RGBFormat "combine"
if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "BLUE INPUT FILE"
    if {$FileName != ""} {
        set FileInputBlue $FileName
        set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp"
        } else {
        set FileInputBlue $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd127" "Button37" vTcl:WidgetProc "Toplevel201" 1
    bindtags $site_6_0.cpd127 "$site_6_0.cpd127 Button $top all _vTclBalloon"
    bind $site_6_0.cpd127 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd127 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -foreground #009900 -ipad 0 -text {GREEN Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel201" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputGreen 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel201" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel201" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd128 \
        \
        -command {global FileName RGBDirInput  RGBDirOutput RGBFileOutput FileInputGreen RGBFormat VarError ErrorMessage TMPFileNull

set RGBFormat "combine"

if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "GREEN INPUT FILE"
    if {$FileName != ""} {
        set FileInputGreen $FileName
        set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp"
        } else {
        set FileInputGreen $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd128 "$site_6_0.cpd128 Button $top all _vTclBalloon"
    bind $site_6_0.cpd128 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd128 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd118 \
        -foreground #ff0000 -ipad 0 -text {RED Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame10" vTcl:WidgetProc "Toplevel201" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputRed 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel201" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel201" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd129 \
        \
        -command {global FileName RGBDirInput RGBDirOutput RGBFileOutput FileInputRed RGBFormat VarError ErrorMessage TMPFileNull

set RGBFormat "combine"

if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "RED INPUT FILE"
    if {$FileName != ""} {
        set FileInputRed $FileName
        set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp"
        } else {
        set FileInputRed $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd129" "Button38" vTcl:WidgetProc "Toplevel201" 1
    bindtags $site_6_0.cpd129 "$site_6_0.cpd129 Button $top all _vTclBalloon"
    bind $site_6_0.cpd129 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd129 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Color Channel Contrast Enhancement} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame11" vTcl:WidgetProc "Toplevel201" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.cpd66
    set site_5_0 $site_4_0.cpd66
    frame $site_5_0.cpd67 \
        -borderwidth 2 -relief sunken 
    set site_6_0 $site_5_0.cpd67
    checkbutton $site_6_0.che69 \
        \
        -command {global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global MinMaxAutoRGB RGBFormat

if {$RGBFormat != "Stokes2"} {

if {"$MinMaxAutoRGB"=="1"} {
    $widget(TitleFrame201_1) configure -state disable
    $widget(TitleFrame201_2) configure -state disable
    $widget(TitleFrame201_3) configure -state disable
    $widget(Label201_1) configure -state disable
    $widget(Entry201_1) configure -state disable
    $widget(Label201_2) configure -state disable
    $widget(Entry201_2) configure -state disable
    $widget(Label201_3) configure -state disable
    $widget(Entry201_3) configure -state disable
    $widget(Label201_4) configure -state disable
    $widget(Entry201_4) configure -state disable
    $widget(Label201_5) configure -state disable
    $widget(Entry201_5) configure -state disable
    $widget(Label201_6) configure -state disable
    $widget(Entry201_6) configure -state disable
    $widget(Button201_1) configure -state disable
    $widget(Button201_2) configure -state normal
    set RGBMinBlue "Auto"; set RGBMaxBlue "Auto"
    set RGBMinRed "Auto"; set RGBMaxRed "Auto"
    set RGBMinGreen "Auto"; set RGBMaxGreen "Auto"
    } else {
    $widget(TitleFrame201_1) configure -state normal
    $widget(TitleFrame201_2) configure -state normal
    $widget(TitleFrame201_3) configure -state normal
    $widget(Label201_1) configure -state normal
    $widget(Entry201_1) configure -state normal
    $widget(Label201_2) configure -state normal
    $widget(Entry201_2) configure -state normal
    $widget(Label201_3) configure -state normal
    $widget(Entry201_3) configure -state normal
    $widget(Label201_4) configure -state normal
    $widget(Entry201_4) configure -state normal
    $widget(Label201_5) configure -state normal
    $widget(Entry201_5) configure -state normal
    $widget(Label201_6) configure -state normal
    $widget(Entry201_6) configure -state normal
    $widget(Button201_1) configure -state normal
    $widget(Button201_2) configure -state disable
    set RGBMinBlue "?"; set RGBMaxBlue "?"
    set RGBMinRed "?"; set RGBMaxRed "?"
    set RGBMinGreen "?"; set RGBMaxGreen "?"
    }
}} \
        -text Automatic -variable MinMaxAutoRGB 
    vTcl:DefineAlias "$site_6_0.che69" "Checkbutton1" vTcl:WidgetProc "Toplevel201" 1
    button $site_6_0.but68 \
        -background #ffff00 \
        -command {global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB TMPMinMaxBmp
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize NligFullSize
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

$widget(Button201_2) configure -state disable

if {$OpenDirFile == 0} {
    if {"$RGBDirInput"!=""} {

        set config "true"
        if {"$RGBFormat"=="combine"} {
            if {"$FileInputBlue"==""} {set config "false"}
            if {"$FileInputRed"==""} {set config "false"}
            if {"$FileInputGreen"==""} {set config "false"}
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
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]

                #read MinMaxBMP
                DeleteFile $TMPMinMaxBmp

                set Fonction "Min / Max RGB Values Determination"
                set Fonction2 ""    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update

                if {"$RGBFormat"=="combine"} {
                    set MaskCmd ""; set MaskDir ""
                    if {"$FileInputBlue" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputBlue] }
                    if {"$FileInputRed" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputRed] }
                    if {"$FileInputGreen" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputGreen] }
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                    MinMaxRGBCombinePP
                    }
                if {"$RGBFormat"!="combine"} {
                    set MaskCmd ""
                    set MaskDir $RGBDirInput
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                    if {"$RGBFunction"=="SPP"} { MinMaxRGBSPP }                 
                    if {"$RGBFunction"=="IPP"} { MinMaxRGBIPP }                 
                    if {"$RGBFunction"=="C2"} { MinMaxRGBC2 }
                    }                                  
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                set RGBMinBlue ""; set RGBMaxBlue ""
                set RGBMinRed ""; set RGBMaxRed ""
                set RGBMinGreen ""; set RGBMaxGreen ""

                WaitUntilCreated $TMPMinMaxBmp

                if [file exists $TMPMinMaxBmp] {
                    set f [open $TMPMinMaxBmp r]
                    gets $f RGBMinBlue
                    gets $f RGBMaxBlue
                    gets $f RGBMinRed
                    gets $f RGBMaxRed
                    gets $f RGBMinGreen 
                    gets $f RGBMaxGreen
                    close $f
                    }
                set config "true"
                if {$RGBMinBlue == ""} {set config "false"}
                if {$RGBMaxBlue == ""} {set config "false"}
                if {$RGBMinRed == ""} {set config "false"}
                if {$RGBMaxRed == ""} {set config "false"}
                if {$RGBMinGreen == ""} {set config "false"}
                if {$RGBMaxGreen == ""} {set config "false"}

                if {$config == "true"} {$widget(Button201_2) configure -state normal}
                }
            }
        } else {
        set RGBFormat ""
        set VarError ""
        set ErrorMessage "ENTER A VALID DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }} \
        -padx 4 -pady 2 -text MinMax 
    vTcl:DefineAlias "$site_6_0.but68" "Button201_1" vTcl:WidgetProc "Toplevel201" 1
    pack $site_6_0.che69 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.but68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -pady 1 \
        -side left 
    radiobutton $site_5_0.rad67 \
        -text Independant -value independant -variable RGBCCCE 
    vTcl:DefineAlias "$site_5_0.rad67" "Radiobutton3" vTcl:WidgetProc "Toplevel201" 1
    radiobutton $site_5_0.cpd68 \
        -text Common -value common -variable RGBCCCE 
    vTcl:DefineAlias "$site_5_0.cpd68" "Radiobutton4" vTcl:WidgetProc "Toplevel201" 1
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.rad67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 30 -side left 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 30 -side left 
    frame $site_4_0.fra70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra70" "Frame6" vTcl:WidgetProc "Toplevel201" 1
    set site_5_0 $site_4_0.fra70
    TitleFrame $site_5_0.tit71 \
        -text {Blue Channel} 
    vTcl:DefineAlias "$site_5_0.tit71" "TitleFrame201_1" vTcl:WidgetProc "Toplevel201" 1
    bind $site_5_0.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit71 getframe]
    frame $site_7_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra73" "Frame7" vTcl:WidgetProc "Toplevel201" 1
    set site_8_0 $site_7_0.fra73
    label $site_8_0.lab74 \
        -text Min 
    vTcl:DefineAlias "$site_8_0.lab74" "Label201_1" vTcl:WidgetProc "Toplevel201" 1
    entry $site_8_0.cpd76 \
        -background white -foreground #ff0000 -textvariable RGBMinBlue \
        -width 5 
    vTcl:DefineAlias "$site_8_0.cpd76" "Entry201_1" vTcl:WidgetProc "Toplevel201" 1
    pack $site_8_0.lab74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd78" "Frame8" vTcl:WidgetProc "Toplevel201" 1
    set site_8_0 $site_7_0.cpd78
    label $site_8_0.lab74 \
        -text Max 
    vTcl:DefineAlias "$site_8_0.lab74" "Label201_2" vTcl:WidgetProc "Toplevel201" 1
    entry $site_8_0.cpd76 \
        -background white -foreground #ff0000 -textvariable RGBMaxBlue \
        -width 5 
    vTcl:DefineAlias "$site_8_0.cpd76" "Entry201_2" vTcl:WidgetProc "Toplevel201" 1
    pack $site_8_0.lab74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra73 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd79 \
        -text {Red Channel} 
    vTcl:DefineAlias "$site_5_0.cpd79" "TitleFrame201_2" vTcl:WidgetProc "Toplevel201" 1
    bind $site_5_0.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd79 getframe]
    frame $site_7_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra73" "Frame10" vTcl:WidgetProc "Toplevel201" 1
    set site_8_0 $site_7_0.fra73
    label $site_8_0.lab74 \
        -text Min 
    vTcl:DefineAlias "$site_8_0.lab74" "Label201_3" vTcl:WidgetProc "Toplevel201" 1
    entry $site_8_0.cpd76 \
        -background white -foreground #ff0000 -textvariable RGBMinRed \
        -width 5 
    vTcl:DefineAlias "$site_8_0.cpd76" "Entry201_3" vTcl:WidgetProc "Toplevel201" 1
    pack $site_8_0.lab74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd78" "Frame11" vTcl:WidgetProc "Toplevel201" 1
    set site_8_0 $site_7_0.cpd78
    label $site_8_0.lab74 \
        -text Max 
    vTcl:DefineAlias "$site_8_0.lab74" "Label201_4" vTcl:WidgetProc "Toplevel201" 1
    entry $site_8_0.cpd76 \
        -background white -foreground #ff0000 -textvariable RGBMaxRed \
        -width 5 
    vTcl:DefineAlias "$site_8_0.cpd76" "Entry201_4" vTcl:WidgetProc "Toplevel201" 1
    pack $site_8_0.lab74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra73 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd80 \
        -text {Green Channel} 
    vTcl:DefineAlias "$site_5_0.cpd80" "TitleFrame201_3" vTcl:WidgetProc "Toplevel201" 1
    bind $site_5_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd80 getframe]
    frame $site_7_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra73" "Frame12" vTcl:WidgetProc "Toplevel201" 1
    set site_8_0 $site_7_0.fra73
    label $site_8_0.lab74 \
        -text Min 
    vTcl:DefineAlias "$site_8_0.lab74" "Label201_5" vTcl:WidgetProc "Toplevel201" 1
    entry $site_8_0.cpd76 \
        -background white -foreground #ff0000 -textvariable RGBMinGreen \
        -width 5 
    vTcl:DefineAlias "$site_8_0.cpd76" "Entry201_5" vTcl:WidgetProc "Toplevel201" 1
    pack $site_8_0.lab74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd78" "Frame13" vTcl:WidgetProc "Toplevel201" 1
    set site_8_0 $site_7_0.cpd78
    label $site_8_0.lab74 \
        -text Max 
    vTcl:DefineAlias "$site_8_0.lab74" "Label201_6" vTcl:WidgetProc "Toplevel201" 1
    entry $site_8_0.cpd76 \
        -background white -foreground #ff0000 -textvariable RGBMaxGreen \
        -width 5 
    vTcl:DefineAlias "$site_8_0.cpd76" "Entry201_6" vTcl:WidgetProc "Toplevel201" 1
    pack $site_8_0.lab74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_8_0.cpd76 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra73 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.tit71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.fra70 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.cpd124 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd124" "Frame5" vTcl:WidgetProc "Toplevel201" 1
    set site_3_0 $top.cpd124
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output RGB File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel201" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel201" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel201" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd107 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text button 
    pack $site_6_0.cpd107 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel201" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global TMPFileNull RGBDirInput RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global FileInputBlue FileInputGreen FileInputRed RGBCCCE MinMaxAutoRGB
global RGBMinBlue RGBMaxBlue RGBMinRed RGBMaxRed RGBMinGreen RGBMaxGreen
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize NligFullSize
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global Channel1 Channel2 OpenDirFile MaskCmd PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {"$RGBDirInput"!=""} {

    #####################################################################
    #Create Directory
    set RGBDirOutput [PSPCreateDirectoryMask $RGBDirOutput $RGBDirOutput $RGBDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
    
        set config "true"
        if {"$RGBFormat"=="combine"} {
            if {"$FileInputBlue"==""} {set config "false"}
            if {"$FileInputRed"==""} {set config "false"}
            if {"$FileInputGreen"==""} {set config "false"}
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
                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]

                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update

                if {"$RGBFormat"=="combine"} {
                    set MaskCmd ""; set MaskDir ""
                    if {"$FileInputBlue" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputBlue] }
                    if {"$FileInputRed" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputRed] }
                    if {"$FileInputGreen" != "$TMPFileNull"} { set MaskDir [file dirname $FileInputGreen] }
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                    CreateRGBCombinePP
                    }
                if {"$RGBFormat"!="combine"} {
                    set MaskCmd ""
                    set MaskDir $RGBDirInput
                    set MaskFile "$MaskDir/mask_valid_pixels.bin"
                    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

                    if {"$RGBFunction"=="SPP"} { CreateRGBSPP }                 
                    if {"$RGBFunction"=="IPP"} { CreateRGBIPP }                 
                    if {"$RGBFunction"=="C2"} { CreateRGBC2 }
                    }                                  
                set RGBFormat ""
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                Window hide $widget(Toplevel201); TextEditorRunTrace "Close Window Create RGB File PP" "b"
                }
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel201); TextEditorRunTrace "Close Window Create RGB File PP" "b"}
        }
    } else {
    set RGBFormat ""
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button201_2" vTcl:WidgetProc "Toplevel201" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CreateRGBFile_PP.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel201" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel201); TextEditorRunTrace "Close Window Create RGB File PP" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel201" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit  the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m24 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd122 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra41 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra69 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd123 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd124 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra59 \
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
Window show .top201

main $argc $argv
