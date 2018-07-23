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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}

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
    set base .top428
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra68
    namespace eval ::widgets::$site_5_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra68
    namespace eval ::widgets::$site_6_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd69
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_7_0.but70 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_7_0.but70 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra68
    namespace eval ::widgets::$site_6_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd69
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_7_0.but70 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd72
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_7_0.but70 {
        array set save {-command 1 -image 1 -pady 1}
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
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-text 1 -value 1 -variable 1}
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
        array set save {}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.rad71 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
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
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-ipad 1 -relief 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd78 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd66
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd68
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top428
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
    wm geometry $top 200x200+50+50; update
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

proc vTclWindow.top428 {base} {
    if {$base == ""} {
        set base .top428
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
    wm geometry $top 500x540+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "NEST - Geocode Parameter"
    vTcl:DefineAlias "$top" "Toplevel428" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame1" vTcl:WidgetProc "Toplevel428" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel428" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable NESTDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel428" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel428" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button1" vTcl:WidgetProc "Toplevel428" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame5" vTcl:WidgetProc "Toplevel428" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable NESTDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel428" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame12" vTcl:WidgetProc "Toplevel428" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -command {global DirName DataDir NESTDirOutput
global VarWarning WarningMessage WarningMessage2

set NESTOutputDirTmp $NESTDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set NESTDirOutput $DirName
    } else {
    set NESTDirOutput $NESTOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button2" vTcl:WidgetProc "Toplevel428" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd67 \
        -ipad 0 -text {Input Parameter File} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame428_0" vTcl:WidgetProc "Toplevel428" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable NESTParameterFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel428" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame14" vTcl:WidgetProc "Toplevel428" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.but71 \
        \
        -command {global FileName NESTDirInput NESTSensorPol NESTParameterFile
global ErrorMessage VarError

set types {
    {{Bin Files}        {.bin}        }
    }
set FileName ""
OpenFile $NESTDirInput $types "INPUT PARAMETER FILE"
set NESTParameterFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but71" "Button4" vTcl:WidgetProc "Toplevel428" 1
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd72 \
        -ipad 0 -text {SAR Product File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame428_1" vTcl:WidgetProc "Toplevel428" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable NESTLeaderFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel428" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel428" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.but71 \
        \
        -command {global FileName NESTDirInput NESTSensor NESTLeaderFile
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0
global TMPRadarsat2Config
global ErrorMessage VarError
global NESTMlkAzIn NESTMlkRgIn
global NESTMlkAzOut NESTMlkRgOut

$widget(Button428_1) configure -state disable
$widget(Button428_2) configure -state disable
$widget(Button428_3) configure -state disable
$widget(Button428_4) configure -state disable
$widget(Button428_6) configure -state disable
$widget(Button428_7) configure -state disable
$widget(Button428_8) configure -state disable
$widget(Button428_9) configure -state disable

set NESTDirInputTmp [file dirname $NESTDirInput]
set types {
    {{XML Files}        {.xml}        }
    }
set FileName ""
OpenFile $NESTDirInputTmp $types "SAR PRODUCT FILE"
set NESTLeaderFile $FileName

set NESTMlkAzIn "1"; set NESTMlkRgIn "1"
set NESTMlkAzOut "1"; set NESTMlkRgOut "1"

if {$NESTSensor == "RS2"} {
    DeleteFile $TMPRadarsat2Config
    NESTReadXML $NESTLeaderFile $TMPRadarsat2Config "radarsat"
    WaitUntilCreated $TMPRadarsat2Config
    if [file exists $TMPRadarsat2Config] {
        set f [open $TMPRadarsat2Config r]
        gets $f TetaNearRg
        gets $f TetaFarRg
        gets $f NESTPixelSizeRg0
        gets $f NESTPixelSizeAz0
        close $f
        }
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    $widget(Button428_1) configure -state normal
    $widget(Button428_2) configure -state normal
    $widget(Button428_3) configure -state normal
    $widget(Button428_4) configure -state normal
    $widget(Button428_6) configure -state normal
    $widget(Button428_7) configure -state normal
    $widget(Button428_8) configure -state normal
    $widget(Button428_9) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but71" "Button3" vTcl:WidgetProc "Toplevel428" 1
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit67 \
        -ipad 2 -text {Source GR Pixel Spacings} 
    vTcl:DefineAlias "$top.tit67" "TitleFrame3" vTcl:WidgetProc "Toplevel428" 1
    bind $top.tit67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit67 getframe]
    frame $site_4_0.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra68" "Frame5" vTcl:WidgetProc "Toplevel428" 1
    set site_5_0 $site_4_0.fra68
    label $site_5_0.lab69 \
        -text {Azimut (m) } 
    vTcl:DefineAlias "$site_5_0.lab69" "Label4" vTcl:WidgetProc "Toplevel428" 1
    entry $site_5_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NESTPixelSizeAz -width 10 
    vTcl:DefineAlias "$site_5_0.ent70" "Entry1" vTcl:WidgetProc "Toplevel428" 1
    pack $site_5_0.lab69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame7" vTcl:WidgetProc "Toplevel428" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab69 \
        -text {Range (m) } 
    vTcl:DefineAlias "$site_5_0.lab69" "Label5" vTcl:WidgetProc "Toplevel428" 1
    entry $site_5_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NESTPixelSizeRg -width 10 
    vTcl:DefineAlias "$site_5_0.ent70" "Entry2" vTcl:WidgetProc "Toplevel428" 1
    pack $site_5_0.lab69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame8" vTcl:WidgetProc "Toplevel428" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab69 \
        -text {Pixel Spacing (m) } 
    vTcl:DefineAlias "$site_5_0.lab69" "Label6" vTcl:WidgetProc "Toplevel428" 1
    entry $site_5_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -textvariable NESTPixelSize -width 10 
    vTcl:DefineAlias "$site_5_0.ent70" "Entry3" vTcl:WidgetProc "Toplevel428" 1
    pack $site_5_0.lab69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame3" vTcl:WidgetProc "Toplevel428" 1
    set site_3_0 $top.fra66
    TitleFrame $site_3_0.cpd67 \
        -ipad 2 -relief sunken -text {Input Multi Look} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame8" vTcl:WidgetProc "Toplevel428" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    frame $site_5_0.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra68" "Frame16" vTcl:WidgetProc "Toplevel428" 1
    set site_6_0 $site_5_0.fra68
    label $site_6_0.lab69 \
        -text Azimut 
    vTcl:DefineAlias "$site_6_0.lab69" "Label9" vTcl:WidgetProc "Toplevel428" 1
    entry $site_6_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NESTMlkAzIn -width 5 
    vTcl:DefineAlias "$site_6_0.ent70" "Entry6" vTcl:WidgetProc "Toplevel428" 1
    frame $site_6_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd69" "Frame18" vTcl:WidgetProc "Toplevel428" 1
    set site_7_0 $site_6_0.cpd69
    button $site_7_0.cpd71 \
        \
        -command {global NESTMlkAzIn NESTMlkRgIn NESTMlkAzOut NESTMlkRgOut NESTSensor
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0

set NESTMlkAzIn [expr $NESTMlkAzIn + 1]
if {$NESTMlkAzIn == 16} {set NESTMlkAzIn 1}

if {$NESTSensor == "RS2"} {
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg * ($NESTMlkRgIn * $NESTMlkRgOut)]
    set NESTPixelSizeAz [expr $NESTPixelSizeAz * ($NESTMlkAzIn * $NESTMlkAzOut)]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_7_0.cpd71" "Button428_6" vTcl:WidgetProc "Toplevel428" 1
    button $site_7_0.but70 \
        \
        -command {global NESTMlkAzIn NESTMlkRgIn NESTMlkAzOut NESTMlkRgOut NESTSensor
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0

set NESTMlkAzIn [expr $NESTMlkAzIn - 1]
if {$NESTMlkAzIn == 0} {set NESTMlkAzIn 15}

if {$NESTSensor == "RS2"} {
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg * ($NESTMlkRgIn * $NESTMlkRgOut)]
    set NESTPixelSizeAz [expr $NESTPixelSizeAz * ($NESTMlkAzIn * $NESTMlkAzOut)]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_7_0.but70" "Button428_7" vTcl:WidgetProc "Toplevel428" 1
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.but70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.lab69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame19" vTcl:WidgetProc "Toplevel428" 1
    set site_6_0 $site_5_0.cpd71
    label $site_6_0.lab69 \
        -text Range 
    vTcl:DefineAlias "$site_6_0.lab69" "Label10" vTcl:WidgetProc "Toplevel428" 1
    entry $site_6_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NESTMlkRgIn -width 5 
    vTcl:DefineAlias "$site_6_0.ent70" "Entry7" vTcl:WidgetProc "Toplevel428" 1
    frame $site_6_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame21" vTcl:WidgetProc "Toplevel428" 1
    set site_7_0 $site_6_0.cpd72
    button $site_7_0.cpd71 \
        \
        -command {global NESTMlkAzIn NESTMlkRgIn NESTMlkAzOut NESTMlkRgOut NESTSensor
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0

set NESTMlkRgIn [expr $NESTMlkRgIn + 1]
if {$NESTMlkRgIn == 16} {set NESTMlkRgIn 1}

if {$NESTSensor == "RS2"} {
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg * ($NESTMlkRgIn * $NESTMlkRgOut)]
    set NESTPixelSizeAz [expr $NESTPixelSizeAz * ($NESTMlkAzIn * $NESTMlkAzOut)]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_7_0.cpd71" "Button428_8" vTcl:WidgetProc "Toplevel428" 1
    button $site_7_0.but70 \
        \
        -command {global NESTMlkAzIn NESTMlkRgIn NESTMlkAzOut NESTMlkRgOut NESTSensor
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0

set NESTMlkRgIn [expr $NESTMlkRgIn - 1]
if {$NESTMlkRgIn == 0} {set NESTMlkRgIn 15}

if {$NESTSensor == "RS2"} {
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg * ($NESTMlkRgIn * $NESTMlkRgOut)]
    set NESTPixelSizeAz [expr $NESTPixelSizeAz * ($NESTMlkAzIn * $NESTMlkAzOut)]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_7_0.but70" "Button428_9" vTcl:WidgetProc "Toplevel428" 1
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.but70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.lab69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd68 \
        -ipad 2 -relief sunken -text {Output Multi Look} 
    vTcl:DefineAlias "$site_3_0.cpd68" "TitleFrame10" vTcl:WidgetProc "Toplevel428" 1
    bind $site_3_0.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd68 getframe]
    frame $site_5_0.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra68" "Frame22" vTcl:WidgetProc "Toplevel428" 1
    set site_6_0 $site_5_0.fra68
    label $site_6_0.lab69 \
        -text Azimut 
    vTcl:DefineAlias "$site_6_0.lab69" "Label12" vTcl:WidgetProc "Toplevel428" 1
    entry $site_6_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NESTMlkAzOut -width 5 
    vTcl:DefineAlias "$site_6_0.ent70" "Entry8" vTcl:WidgetProc "Toplevel428" 1
    frame $site_6_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd69" "Frame23" vTcl:WidgetProc "Toplevel428" 1
    set site_7_0 $site_6_0.cpd69
    button $site_7_0.cpd71 \
        \
        -command {global NESTMlkAzIn NESTMlkRgIn NESTMlkAzOut NESTMlkRgOut NESTSensor
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0

set NESTMlkAzOut [expr $NESTMlkAzOut + 1]
if {$NESTMlkAzOut == 16} {set NESTMlkAzOut 1}

if {$NESTSensor == "RS2"} {
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg * ($NESTMlkRgIn * $NESTMlkRgOut)]
    set NESTPixelSizeAz [expr $NESTPixelSizeAz * ($NESTMlkAzIn * $NESTMlkAzOut)]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_7_0.cpd71" "Button428_1" vTcl:WidgetProc "Toplevel428" 1
    button $site_7_0.but70 \
        \
        -command {global NESTMlkAzIn NESTMlkRgIn NESTMlkAzOut NESTMlkRgOut NESTSensor
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0

set NESTMlkAzOut [expr $NESTMlkAzOut - 1]
if {$NESTMlkAzOut == 0} {set NESTMlkAzOut 15}

if {$NESTSensor == "RS2"} {
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg * ($NESTMlkRgIn * $NESTMlkRgOut)]
    set NESTPixelSizeAz [expr $NESTPixelSizeAz * ($NESTMlkAzIn * $NESTMlkAzOut)]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_7_0.but70" "Button428_2" vTcl:WidgetProc "Toplevel428" 1
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.but70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.lab69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame24" vTcl:WidgetProc "Toplevel428" 1
    set site_6_0 $site_5_0.cpd71
    label $site_6_0.lab69 \
        -text Range 
    vTcl:DefineAlias "$site_6_0.lab69" "Label16" vTcl:WidgetProc "Toplevel428" 1
    entry $site_6_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NESTMlkRgOut -width 5 
    vTcl:DefineAlias "$site_6_0.ent70" "Entry9" vTcl:WidgetProc "Toplevel428" 1
    frame $site_6_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd72" "Frame25" vTcl:WidgetProc "Toplevel428" 1
    set site_7_0 $site_6_0.cpd72
    button $site_7_0.cpd71 \
        \
        -command {global NESTMlkAzIn NESTMlkRgIn NESTMlkAzOut NESTMlkRgOut NESTSensor
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0

set NESTMlkRgOut [expr $NESTMlkRgOut + 1]
if {$NESTMlkRgOut == 16} {set NESTMlkRgOut 1}

if {$NESTSensor == "RS2"} {
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg * ($NESTMlkRgIn * $NESTMlkRgOut)]
    set NESTPixelSizeAz [expr $NESTPixelSizeAz * ($NESTMlkAzIn * $NESTMlkAzOut)]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_7_0.cpd71" "Button428_3" vTcl:WidgetProc "Toplevel428" 1
    button $site_7_0.but70 \
        \
        -command {global NESTMlkAzIn NESTMlkRgIn NESTMlkAzOut NESTMlkRgOut NESTSensor
global NESTPixelSizeAz NESTPixelSizeRg NESTPixelSize
global TetaNearRg TetaFarRg NESTPixelSizeRg0 NESTPixelSizeAz0

set NESTMlkRgOut [expr $NESTMlkRgOut - 1]
if {$NESTMlkRgOut == 0} {set NESTMlkRgOut 15}

if {$NESTSensor == "RS2"} {
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg0) / 100000.]
    set NESTPixelSizeAz [expr round(100000. * $NESTPixelSizeAz0) / 100000.]
    set Teta0 [expr ($TetaNearRg + $TetaFarRg) / 2 ]
    set Teta0 [expr ($Teta0 * 3.1415926) / 180.0]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg / sin($Teta0)]
    set NESTPixelSizeRg [expr round(100000. * $NESTPixelSizeRg) / 100000.]
    set NESTPixelSizeRg [expr $NESTPixelSizeRg * ($NESTMlkRgIn * $NESTMlkRgOut)]
    set NESTPixelSizeAz [expr $NESTPixelSizeAz * ($NESTMlkAzIn * $NESTMlkAzOut)]
    if {$NESTPixelSizeRg <= $NESTPixelSizeAz} {
        set NESTPixelSize $NESTPixelSizeAz
        } else {
        set NESTPixelSize $NESTPixelSizeRg
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_7_0.but70" "Button428_4" vTcl:WidgetProc "Toplevel428" 1
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.but70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.lab69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent70 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit66 \
        -ipad 0 -text {Image Resampling Method} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame1" vTcl:WidgetProc "Toplevel428" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    radiobutton $site_4_0.rad67 \
        -text Bilinear -value BILINEAR_INTERPOLATION \
        -variable NESTResamplingIMG 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel428" 1
    radiobutton $site_4_0.cpd68 \
        -text Cubic -value CUBIC_INTERPOLATION -variable NESTResamplingIMG 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel428" 1
    radiobutton $site_4_0.cpd69 \
        -text {Nearest Neighbor} -value NEAREST_NEIGHBOUR \
        -variable NESTResamplingIMG 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton3" vTcl:WidgetProc "Toplevel428" 1
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd69 \
        -ipad 0 -text {Digital Elevation Model (DEM)} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame428" vTcl:WidgetProc "Toplevel428" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    frame $site_4_0.cpd70
    set site_5_0 $site_4_0.cpd70
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable NESTDEMFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry428_1" vTcl:WidgetProc "Toplevel428" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame17" vTcl:WidgetProc "Toplevel428" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -command {global FileName NESTDirInput NESTDEMFile
global ErrorMessage VarError

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $NESTDirInput $types "DEM FILE"
set NESTDEMFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button428_5" vTcl:WidgetProc "Toplevel428" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    radiobutton $site_4_0.rad71 \
        \
        -command {global PSPBackgroundColor
$widget(Entry428_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry428_1) configure -state disable
$widget(Button428_5) configure -state disable} \
        -text S.R.T.M -value srtm -variable NESTDEM 
    vTcl:DefineAlias "$site_4_0.rad71" "Radiobutton9" vTcl:WidgetProc "Toplevel428" 1
    radiobutton $site_4_0.cpd72 \
        \
        -command {global PSPBackgroundColor
$widget(Entry428_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry428_1) configure -state disable
$widget(Button428_5) configure -state disable} \
        -text ASTER -value aster -variable NESTDEM 
    vTcl:DefineAlias "$site_4_0.cpd72" "Radiobutton10" vTcl:WidgetProc "Toplevel428" 1
    radiobutton $site_4_0.cpd73 \
        \
        -command {global PSPBackgroundColor
$widget(Entry428_1) configure -disabledbackground #FFFFFF
$widget(Entry428_1) configure -state disable
$widget(Button428_5) configure -state normal} \
        -text External -value external -variable NESTDEM 
    vTcl:DefineAlias "$site_4_0.cpd73" "Radiobutton11" vTcl:WidgetProc "Toplevel428" 1
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.rad71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {DEM Resampling Method} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame6" vTcl:WidgetProc "Toplevel428" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    radiobutton $site_4_0.cpd68 \
        -text Bicubic -value BICUBIC_INTERPOLATION \
        -variable NESTResamplingDEM 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton4" vTcl:WidgetProc "Toplevel428" 1
    radiobutton $site_4_0.rad67 \
        -text Bilinear -value BILINEAR_INTERPOLATION \
        -variable NESTResamplingDEM 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton5" vTcl:WidgetProc "Toplevel428" 1
    radiobutton $site_4_0.cpd70 \
        -text Bisinc -value BISINC_INTERPOLATION -variable NESTResamplingDEM 
    vTcl:DefineAlias "$site_4_0.cpd70" "Radiobutton8" vTcl:WidgetProc "Toplevel428" 1
    radiobutton $site_4_0.cpd67 \
        -text Cubic -value CUBIC_INTERPOLATION -variable NESTResamplingDEM 
    vTcl:DefineAlias "$site_4_0.cpd67" "Radiobutton7" vTcl:WidgetProc "Toplevel428" 1
    radiobutton $site_4_0.cpd69 \
        -text {Nearest Neighbor} -value NEAREST_NEIGHBOUR \
        -variable NESTResamplingDEM 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton6" vTcl:WidgetProc "Toplevel428" 1
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame2" vTcl:WidgetProc "Toplevel428" 1
    set site_3_0 $top.fra71
    TitleFrame $site_3_0.cpd78 \
        -ipad 0 -relief sunken -text {Default Parameters} 
    vTcl:DefineAlias "$site_3_0.cpd78" "TitleFrame9" vTcl:WidgetProc "Toplevel428" 1
    bind $site_3_0.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd78 getframe]
    frame $site_5_0.cpd66
    set site_6_0 $site_5_0.cpd66
    label $site_6_0.cpd75 \
        -text {Geocoding : Latitude / Longitude} 
    vTcl:DefineAlias "$site_6_0.cpd75" "Label13" vTcl:WidgetProc "Toplevel428" 1
    label $site_6_0.lab74 \
        -text {Datum : WGS84 } 
    vTcl:DefineAlias "$site_6_0.lab74" "Label11" vTcl:WidgetProc "Toplevel428" 1
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 1 -fill x -padx 3 -pady 3 \
        -side left 
    frame $site_5_0.cpd68
    set site_6_0 $site_5_0.cpd68
    label $site_6_0.cpd75 \
        -text {Input Format : PolSARpro} 
    vTcl:DefineAlias "$site_6_0.cpd75" "Label14" vTcl:WidgetProc "Toplevel428" 1
    label $site_6_0.cpd69 \
        -text {Output Format : PolSARpro} 
    vTcl:DefineAlias "$site_6_0.cpd69" "Label15" vTcl:WidgetProc "Toplevel428" 1
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 20 \
        -side left 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel428" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir OpenDirFile NESTDirInput NESTDirOutput NESTOutputDir
global VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NESTFileHdr MapInfoMapInfo MapInfoUnit MapInfoActive NESTState
global NESTSensorPol NESTSensor NESTPixelSize NESTLeaderFile
global TMPDir NESTParameterFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set TestVarName(0) "Leader File"; set TestVarType(0) "file"; set TestVarValue(0) $NESTLeaderFile; set TestVarMin(0) ""; set TestVarMax(0) ""
TestVar 1
if {$TestVarError == "ok"} {

    #####################################################################
    #Create Directory
    set DirNameCreate $NESTDirOutput
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        set NESTParameterInput [file rootname $NESTParameterFile]
        set NESTParameterOutput $NESTDirOutput
        append NESTParameterOutput "/"
        append NESTParameterOutput [file tail $NESTParameterFile]
        if [file exists $NESTParameterOutput] { DeleteFile $NESTParameterOutput }
        set NESTFileHdr "$NESTParameterOutput.hdr"
        if [file exists $NESTFileHdr] { DeleteFile $NESTFileHdr }
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show $widget(Toplevel44)
                set VarWarning ""
                }
            }
        }
    ##################################################################### 

    if {"$VarWarning"=="ok"} {

        set NESTOutputDir $NESTDirOutput
        set NESTParameterOutput $NESTDirOutput; append NESTParameterOutput "/"; append NESTParameterOutput [file tail $NESTParameterFile]

        set NESTState "1"
        NESTBatchProcess $NESTParameterFile $NESTParameterOutput
        set NESTState "2"

        set MapInfoConfigFile "$NESTDirOutput/config_mapinfo.txt"
        if [file exists $MapInfoConfigFile] { MapInfoReadConfig $MapInfoConfigFile }

        Window hide $widget(Toplevel428); TextEditorRunTrace "Close Window NEST - Geocode Parameter" "b"

        } else {
        if {"$VarWarning"=="no"} {
            Window hide $widget(Toplevel428); TextEditorRunTrace "Close Window NEST - Geocode Parameter" "b"
            }
        }
    }
}} \
        -cursor {} -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button428_10" vTcl:WidgetProc "Toplevel428" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit "Help/NESTParameter.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel428" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile TMPDir NESTDirOutput NESTParameterOutput NESTState

if {$OpenDirFile == 0} {
    NESTDelete
    Window hide $widget(Toplevel428); TextEditorRunTrace "Close Window NEST - Geocode Parameter" "b"
    }} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel428" 1
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
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra59 \
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
Window show .top428

main $argc $argv
