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
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
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
    set base .top533
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
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
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.but75 {
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
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
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
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd84
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
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
    namespace eval ::widgets::$base.fra67 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra72
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd69
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd82
    namespace eval ::widgets::$site_7_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd83
    namespace eval ::widgets::$site_7_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd82
    namespace eval ::widgets::$site_7_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd83
    namespace eval ::widgets::$site_7_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd82
    namespace eval ::widgets::$site_7_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd83
    namespace eval ::widgets::$site_7_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra88
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra90
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra88
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra90
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd88 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra88
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m89 {
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
            vTclWindow.top533
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
    wm geometry $top 200x200+264+264; update
    wm maxsize $top 1924 1065
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

proc vTclWindow.top533 {base} {
    if {$base == ""} {
        set base .top533
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m89" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x510+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PolSAR-ap Showcase : Forest"
    vTcl:DefineAlias "$top" "Toplevel533" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd66 \
        -ipad 2 -text {Input Master Directory} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame533_1" vTcl:WidgetProc "Toplevel533" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.cpd67
    set site_5_0 $site_4_0.cpd67
    entry $site_5_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapForestDirMasterInput 
    vTcl:DefineAlias "$site_5_0.cpd72" "Entry314" vTcl:WidgetProc "Toplevel533" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame8" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but75" "Button5" vTcl:WidgetProc "Toplevel533" 1
    pack $site_6_0.but75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd67 \
        -ipad 2 -text {Input Slave - 1 Directory} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame533_2" vTcl:WidgetProc "Toplevel533" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    frame $site_4_0.cpd67
    set site_5_0 $site_4_0.cpd67
    entry $site_5_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapForestDirSlave1Input 
    vTcl:DefineAlias "$site_5_0.cpd72" "Entry315" vTcl:WidgetProc "Toplevel533" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame21" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but75" "Button6" vTcl:WidgetProc "Toplevel533" 1
    pack $site_6_0.but75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd68 \
        -ipad 2 -text {Input Slave - 2 Directory} 
    vTcl:DefineAlias "$top.cpd68" "TitleFrame533_3" vTcl:WidgetProc "Toplevel533" 1
    bind $top.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd68 getframe]
    frame $site_4_0.cpd67
    set site_5_0 $site_4_0.cpd67
    entry $site_5_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapForestDirSlave2Input 
    vTcl:DefineAlias "$site_5_0.cpd72" "Entry533_1" vTcl:WidgetProc "Toplevel533" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame22" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but75" "Button7" vTcl:WidgetProc "Toplevel533" 1
    pack $site_6_0.but75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd69 \
        -ipad 2 -text {Output Master - Slave -1 - Slave - 2 Directory} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame17" vTcl:WidgetProc "Toplevel533" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    frame $site_4_0.cpd70
    set site_5_0 $site_4_0.cpd70
    entry $site_5_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PolSARapForestOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd82" "Entry533" vTcl:WidgetProc "Toplevel533" 1
    frame $site_5_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame15" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab73" "Label5" vTcl:WidgetProc "Toplevel533" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PolSARapForestOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry5" vTcl:WidgetProc "Toplevel533" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd84" "Frame7" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.cpd84
    button $site_6_0.cpd85 \
        \
        -command {global DirName DataDirChannel1 PolSARapForestOutputDir 

set PolSARapForestOutputDirTmp $PolSARapForestOutputDir
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set PolSARapForestOutputDir $DirName
    } else {
    set PolSARapForestOutputDir $PolSARapForestOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd85" "Button533" vTcl:WidgetProc "Toplevel533" 1
    bindtags $site_6_0.cpd85 "$site_6_0.cpd85 Button $top all _vTclBalloon"
    bind $site_6_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel533" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label533_01" vTcl:WidgetProc "Toplevel533" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry533_01" vTcl:WidgetProc "Toplevel533" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label533_02" vTcl:WidgetProc "Toplevel533" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry533_02" vTcl:WidgetProc "Toplevel533" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label533_03" vTcl:WidgetProc "Toplevel533" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry533_03" vTcl:WidgetProc "Toplevel533" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label533_04" vTcl:WidgetProc "Toplevel533" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry533_04" vTcl:WidgetProc "Toplevel533" 1
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
    frame $top.fra67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame1" vTcl:WidgetProc "Toplevel533" 1
    set site_3_0 $top.fra67
    frame $site_3_0.cpd66 \
        -borderwidth 2 -relief ridge -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame3" vTcl:WidgetProc "Toplevel533" 1
    set site_4_0 $site_3_0.cpd66
    frame $site_4_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra72" "Frame10" vTcl:WidgetProc "Toplevel533" 1
    set site_5_0 $site_4_0.fra72
    label $site_5_0.lab73 \
        -text {Window Size (Row)} 
    vTcl:DefineAlias "$site_5_0.lab73" "Label533" vTcl:WidgetProc "Toplevel533" 1
    entry $site_5_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapForestNwinL -width 5 
    vTcl:DefineAlias "$site_5_0.ent74" "Entry533" vTcl:WidgetProc "Toplevel533" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_5_0.ent74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame11" vTcl:WidgetProc "Toplevel533" 1
    set site_5_0 $site_4_0.cpd75
    label $site_5_0.lab73 \
        -text {Window Size (Col)} 
    vTcl:DefineAlias "$site_5_0.lab73" "Label533" vTcl:WidgetProc "Toplevel533" 1
    entry $site_5_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapForestNwinC -width 5 
    vTcl:DefineAlias "$site_5_0.ent74" "Entry534" vTcl:WidgetProc "Toplevel533" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_5_0.ent74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.fra72 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $site_3_0.cpd81 \
        -ipad 2 -text {Look - Up Tables ( L.U.T )} 
    vTcl:DefineAlias "$site_3_0.cpd81" "TitleFrame533_5" vTcl:WidgetProc "Toplevel533" 1
    bind $site_3_0.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    frame $site_5_0.cpd69
    set site_6_0 $site_5_0.cpd69
    frame $site_6_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd82" "Frame17" vTcl:WidgetProc "Toplevel533" 1
    set site_7_0 $site_6_0.cpd82
    label $site_7_0.lab73 \
        -text {Min Height} 
    vTcl:DefineAlias "$site_7_0.lab73" "Label534" vTcl:WidgetProc "Toplevel533" 1
    entry $site_7_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapForestMinHeight -width 5 
    vTcl:DefineAlias "$site_7_0.ent74" "Entry535" vTcl:WidgetProc "Toplevel533" 1
    pack $site_7_0.lab73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    frame $site_6_0.cpd83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd83" "Frame23" vTcl:WidgetProc "Toplevel533" 1
    set site_7_0 $site_6_0.cpd83
    label $site_7_0.lab73 \
        -text {Min Sigma} 
    vTcl:DefineAlias "$site_7_0.lab73" "Label535" vTcl:WidgetProc "Toplevel533" 1
    entry $site_7_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapForestMinSigma -width 5 
    vTcl:DefineAlias "$site_7_0.ent74" "Entry536" vTcl:WidgetProc "Toplevel533" 1
    pack $site_7_0.lab73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.cpd70
    set site_6_0 $site_5_0.cpd70
    frame $site_6_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd82" "Frame24" vTcl:WidgetProc "Toplevel533" 1
    set site_7_0 $site_6_0.cpd82
    label $site_7_0.lab73 \
        -text {Max Height} 
    vTcl:DefineAlias "$site_7_0.lab73" "Label536" vTcl:WidgetProc "Toplevel533" 1
    entry $site_7_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapForestMaxHeight -width 5 
    vTcl:DefineAlias "$site_7_0.ent74" "Entry537" vTcl:WidgetProc "Toplevel533" 1
    pack $site_7_0.lab73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    frame $site_6_0.cpd83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd83" "Frame25" vTcl:WidgetProc "Toplevel533" 1
    set site_7_0 $site_6_0.cpd83
    label $site_7_0.lab73 \
        -text {Max Sigma} 
    vTcl:DefineAlias "$site_7_0.lab73" "Label537" vTcl:WidgetProc "Toplevel533" 1
    entry $site_7_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapForestMaxSigma -width 5 
    vTcl:DefineAlias "$site_7_0.ent74" "Entry538" vTcl:WidgetProc "Toplevel533" 1
    pack $site_7_0.lab73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.cpd71
    set site_6_0 $site_5_0.cpd71
    frame $site_6_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd82" "Frame26" vTcl:WidgetProc "Toplevel533" 1
    set site_7_0 $site_6_0.cpd82
    label $site_7_0.lab73 \
        -text {Delta Height} 
    vTcl:DefineAlias "$site_7_0.lab73" "Label538" vTcl:WidgetProc "Toplevel533" 1
    entry $site_7_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapForestDelHeight -width 5 
    vTcl:DefineAlias "$site_7_0.ent74" "Entry539" vTcl:WidgetProc "Toplevel533" 1
    pack $site_7_0.lab73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    frame $site_6_0.cpd83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd83" "Frame29" vTcl:WidgetProc "Toplevel533" 1
    set site_7_0 $site_6_0.cpd83
    label $site_7_0.lab73 \
        -text {Delta Sigma} 
    vTcl:DefineAlias "$site_7_0.lab73" "Label539" vTcl:WidgetProc "Toplevel533" 1
    entry $site_7_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapForestDelSigma -width 5 
    vTcl:DefineAlias "$site_7_0.ent74" "Entry540" vTcl:WidgetProc "Toplevel533" 1
    pack $site_7_0.lab73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side right 
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd73 \
        -ipad 2 -text {2D Kz - 1 File} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame535" vTcl:WidgetProc "Toplevel533" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame114" vTcl:WidgetProc "Toplevel533" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame31" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapForestKz1File -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry542" vTcl:WidgetProc "Toplevel533" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame32" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName PolSARapForestDirMasterInput PolSARapForestKz1File
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D Kz FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Kz Files}        {.bin}        }
}
set FileName ""
OpenFile "$PolSARapForestDirMasterInput" $types "2D Kz-1 FILE"
if {$FileName != ""} {
    set PolSARapForestKz1File $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button534" vTcl:WidgetProc "Toplevel533" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra90 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd72 \
        -ipad 2 -text {2D Kz - 2 File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame534" vTcl:WidgetProc "Toplevel533" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame113" vTcl:WidgetProc "Toplevel533" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame27" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapForestKz2File -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry541" vTcl:WidgetProc "Toplevel533" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame30" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName PolSARapForestDirMasterInput PolSARapForestKz2File
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D Kz FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Kz Files}        {.bin}        }
}
set FileName ""
OpenFile "$PolSARapForestDirMasterInput" $types "2D Kz-2 FILE"
if {$FileName != ""} {
    set PolSARapForestKz2File $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button533" vTcl:WidgetProc "Toplevel533" 1
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.fra90 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd88 \
        -ipad 2 -text {Output Forest Height File} 
    vTcl:DefineAlias "$top.cpd88" "TitleFrame533_8" vTcl:WidgetProc "Toplevel533" 1
    bind $top.cpd88 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd88 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame118" vTcl:WidgetProc "Toplevel533" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame28" vTcl:WidgetProc "Toplevel533" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PolSARapForestHeightFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry533_13" vTcl:WidgetProc "Toplevel533" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel533" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2 DataDirChannel3 DirName DataFormatActive2
global PolSARapForestDirMasterInput PolSARapForestDirSlave1Input PolSARapForestDirSlave2Input 
global PolSARapForestDirOutput PolSARapForestOutputDir PolSARapForestOutputSubDir
global PolSARapForestMinHeight PolSARapForestMaxHeight PolSARapForestDelHeight
global PolSARapForestMinSigma PolSARapForestMaxSigma PolSARapForestDelSigma
global PolSARapForestNwinL PolSARapForestNwinC
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile OpenDirFile PolSARapForestKz1File PolSARapForestKz2File PolSARapForestHeightFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set PolSARapForestDirOutput $PolSARapForestOutputDir
if {$PolSARapForestOutputSubDir != ""} {append PolSARapForestDirOutput "/$PolSARapForestOutputSubDir"}

    #####################################################################
    #Create Directory
    set PolSARapForestDirOutput [PSPCreateDirectoryMask $PolSARapForestDirOutput $PolSARapForestOutputDir $PolSARapForestDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Min Height"; set TestVarType(4) "float"; set TestVarValue(4) $PolSARapForestMinHeight; set TestVarMin(4) "1"; set TestVarMax(4) "100"
    set TestVarName(5) "Max Height"; set TestVarType(5) "float"; set TestVarValue(5) $PolSARapForestMaxHeight; set TestVarMin(5) "1"; set TestVarMax(5) "100"
    set TestVarName(6) "Delta Height"; set TestVarType(6) "float"; set TestVarValue(6) $PolSARapForestDelHeight; set TestVarMin(6) "0"; set TestVarMax(6) "10"
    set TestVarName(7) "Min Sigma"; set TestVarType(7) "float"; set TestVarValue(7) $PolSARapForestMinSigma; set TestVarMin(7) "0"; set TestVarMax(7) "5"
    set TestVarName(8) "Max Sigma"; set TestVarType(8) "float"; set TestVarValue(8) $PolSARapForestMaxSigma; set TestVarMin(8) "0"; set TestVarMax(8) "5"
    set TestVarName(9) "Delta Sigma"; set TestVarType(9) "float"; set TestVarValue(9) $PolSARapForestDelSigma; set TestVarMin(9) "0"; set TestVarMax(9) "1"
    set TestVarName(10) "Window Size Row"; set TestVarType(10) "int"; set TestVarValue(10) $PolSARapForestNwinL; set TestVarMin(10) "1"; set TestVarMax(10) "100"
    set TestVarName(11) "Window Size Col"; set TestVarType(11) "int"; set TestVarValue(11) $PolSARapForestNwinC; set TestVarMin(11) "1"; set TestVarMax(11) "100"
    TestVar 12
    if {$TestVarError == "ok"} {
        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "PolSARap Forest"

        set MaskCmd ""
        set MaskFile "$PolSARapForestDirMasterInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/PolSARap/PolSARap_Forest_Height_Estimation_Dual_Baseline.exe" "k"
        if {$DataFormatActive2 == "S2"} {
            TextEditorRunTrace "Arguments: -idm $PolSARapForestDirMasterInput -ids1 $PolSARapForestDirSlave1Input -ids2 $PolSARapForestDirSlave2Input -od $PolSARapForestDirOutput -iodf S2T6 -ikz1 \x22$PolSARapForestKz1File\x22 -ikz2 \x22$PolSARapForestKz2File\x22 -hmin $PolSARapForestMinHeight -hmax $PolSARapForestMaxHeight -hdel $PolSARapForestDelHeight -smin $PolSARapForestMinSigma -smax $PolSARapForestMaxSigma -sdel $PolSARapForestDelSigma -nwr $PolSARapForestNwinL -nwc $PolSARapForestNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/PolSARap/PolSARap_Forest_Height_Estimation_Dual_Baseline.exe -idm $PolSARapForestDirMasterInput -ids1 $PolSARapForestDirSlave1Input -ids2 $PolSARapForestDirSlave2Input -od $PolSARapForestDirOutput -iodf S2T6 -ikz1 \x22$PolSARapForestKz1File\x22 -ikz2 \x22$PolSARapForestKz2File\x22 -hmin $PolSARapForestMinHeight -hmax $PolSARapForestMaxHeight -hdel $PolSARapForestDelHeight -smin $PolSARapForestMinSigma -smax $PolSARapForestMaxSigma -sdel $PolSARapForestDelSigma -nwr $PolSARapForestNwinL -nwc $PolSARapForestNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        if {$DataFormatActive2 == "T6"} {
            TextEditorRunTrace "Arguments: -idm $PolSARapForestDirMasterInput -ids1 $PolSARapForestDirSlave1Input -od $PolSARapForestDirOutput -iodf T6 -ikz1 \x22$PolSARapForestKz1File\x22 -ikz2 \x22$PolSARapForestKz2File\x22 -hmin $PolSARapForestMinHeight -hmax $PolSARapForestMaxHeight -hdel $PolSARapForestDelHeight -smin $PolSARapForestMinSigma -smax $PolSARapForestMaxSigma -sdel $PolSARapForestDelSigma -nwr $PolSARapForestNwinL -nwc $PolSARapForestNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/PolSARap/PolSARap_Forest_Height_Estimation_Dual_Baseline.exe -idm $PolSARapForestDirMasterInput -ids1 $PolSARapForestDirSlave1Input -od $PolSARapForestDirOutput -iodf T6 -ikz1 \x22$PolSARapForestKz1File\x22 -ikz2 \x22$PolSARapForestKz2File\x22 -hmin $PolSARapForestMinHeight -hmax $PolSARapForestMaxHeight -hdel $PolSARapForestDelHeight -smin $PolSARapForestMinSigma -smax $PolSARapForestMaxSigma -sdel $PolSARapForestDelSigma -nwr $PolSARapForestNwinL -nwc $PolSARapForestNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig $PolSARapForestFileOutput $FinalNlig $FinalNcol 4
        set BMPDirInput $PolSARapForestDirOutput
        set BMPFileInput $PolSARapForestHeightFile    
        set BMPFileOutput [file rootname $PolSARapForestHeightFile]
        append BMPFileOutput ".bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 0 1
        }
        #TestVar
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel533); TextEditorRunTrace "Close Window PolSARap Showcase Forest - Height Estimation" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel533" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel533" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel533); TextEditorRunTrace "Close Window PolSARap Showcase Forest - Height Estimation" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel533" 1
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
    menu $top.m89 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra83 \
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
Window show .top533

main $argc $argv
