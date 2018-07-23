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
    set base .top531
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
    namespace eval ::widgets::$site_3_0.tit68 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.tit68 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.rad70 {
        array set save {-background 1 -command 1 -highlightthickness 1 -offrelief 1 -padx 1 -pady 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra71
    namespace eval ::widgets::$site_6_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra72
    namespace eval ::widgets::$site_7_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd75
    namespace eval ::widgets::$site_7_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.fra78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra78
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd80
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit84 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit84 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-background 1 -command 1 -highlightthickness 1 -offrelief 1 -padx 1 -pady 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd85
    namespace eval ::widgets::$site_5_0.fra71 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra71
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd86
    namespace eval ::widgets::$site_7_0.cpd66 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd66
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd88
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-background 1 -command 1 -highlightthickness 1 -offrelief 1 -padx 1 -pady 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd85
    namespace eval ::widgets::$site_5_0.fra71 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra71
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd86
    namespace eval ::widgets::$site_7_0.cpd66 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd66
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd68 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd68
    namespace eval ::widgets::$site_8_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent74 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd88
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd78 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd78 getframe]
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
    namespace eval ::widgets::$base.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd77 getframe]
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
    namespace eval ::widgets::$base.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd70 getframe]
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
    namespace eval ::widgets::$base.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
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
    namespace eval ::widgets::$base.cpd68 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd68 getframe]
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
    namespace eval ::widgets::$base.cpd87 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd87 getframe]
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
            vTclWindow.top531
            PolSARapAgriDecomp
            PolSARapAgriInvSurface
            PolSARapAgriInvDihedral
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
## Procedure:  PolSARapAgriDecomp

proc ::PolSARapAgriDecomp {} {
global PolSARapAgriDirInput PolSARapAgriDirOutput PolSARapAgriOutputDir PolSARapAgriFonc PolSARapAgriFonction
global PolSARapAgriIncAngFile PolSARapAgriMaskFile PolSARapAgriFsFdFile PolSARapAgriAlphaBetaFile
global PolSARapAgriKsFile PolSARapAgriMvFile PolSARapAgriDcSoilFile PolSARapAgriDcTrunkFile
global PolSARapAgriNwinL PolSARapAgriNwinC PolSARapAgriUnit PolSARapAgriSurfSoil PolSARapAgriSurfLUT
global PolSARapAgriDihedSoil PolSARapAgriDihedTrunk PolSARapAgriDihedLUT
global PSPMemory TMPMemoryAllocError
global NligInit NcolInit NligEnd NcolEnd NligFullSize NcolFullSize
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TestVarName TestVarType TestVarValue TestVarMin TestVarMax TestVarError

if {$OpenDirFile == 0} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $PolSARapAgriNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $PolSARapAgriNwinC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "PolSARap Agriculture Decomposition"
        set MaskCmd ""
        set MaskFile "$PolSARapAgriDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/PolSARap/PolSARap_Agriculture_Decomposition.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$PolSARapAgriDirInput\x22 -od \x22$PolSARapAgriDirOutput\x22 -iodf $PolSARapAgriFonction -nwr $PolSARapAgriNwinL -nwc $PolSARapAgriNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/PolSARap/PolSARap_Agriculture_Decomposition.exe -id \x22$PolSARapAgriDirInput\x22 -od \x22$PolSARapAgriDirOutput\x22 -iodf $PolSARapAgriFonction -nwr $PolSARapAgriNwinL -nwc $PolSARapAgriNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_fs.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4
        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_fd.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4
        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_fv.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4
        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_alpha.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4
        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_beta.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4
        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_mask.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4
        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_Ps.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4
        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_Pd.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4
        set PolSARapAgriFile "$PolSARapAgriDirOutput/showcase_agri_Pv.bin"
        EnviWriteConfig $PolSARapAgriFile $FinalNlig $FinalNcol 4             
        }
    }
}
#############################################################################
## Procedure:  PolSARapAgriInvSurface

proc ::PolSARapAgriInvSurface {} {
global PolSARapAgriDirInput PolSARapAgriDirOutput PolSARapAgriOutputDir PolSARapAgriFonc
global PolSARapAgriIncAngFile PolSARapAgriMaskFile PolSARapAgriFsFdFile PolSARapAgriAlphaBetaFile
global PolSARapAgriKsFile PolSARapAgriMvFile PolSARapAgriDcSoilFile PolSARapAgriDcTrunkFile
global PolSARapAgriNwinL PolSARapAgriNwinC PolSARapAgriUnit PolSARapAgriSurfSoil PolSARapAgriSurfLUT
global PolSARapAgriDihedSoil PolSARapAgriDihedTrunk PolSARapAgriDihedLUT
global PSPMemory TMPMemoryAllocError
global NligInit NcolInit NligEnd NcolEnd NligFullSize NcolFullSize
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TestVarName TestVarType TestVarValue TestVarMin TestVarMax TestVarError

if {$OpenDirFile == 0} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Soil Dielectric Constant"; set TestVarType(4) "float"; set TestVarValue(4) $PolSARapAgriSurfSoil; set TestVarMin(4) "1"; set TestVarMax(4) "100"
    set TestVarName(5) "LUT Increment Angle"; set TestVarType(5) "float"; set TestVarValue(5) $PolSARapAgriSurfLUT; set TestVarMin(5) "0"; set TestVarMax(5) "360"
    TestVar 6
    if {$TestVarError == "ok"} {
        #Inversion
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "PolSARap Agriculture Surface Inversion"
        set MaskCmd ""
        set MaskFile "$PolSARapAgriDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/PolSARap/PolSARap_Agriculture_Inversion_Surface.exe" "k"
        set PolSARapArguments "-ifs \x22$PolSARapAgriFsFdFile\x22 -itt \x22$PolSARapAgriIncAngFile\x22 -ibe \x22$PolSARapAgriAlphaBetaFile\x22 -imk \x22$PolSARapAgriMaskFile\x22 -od \x22$PolSARapAgriDirOutput\x22 -un $PolSARapAgriUnit -die $PolSARapAgriSurfSoil -inc $PolSARapAgriSurfLUT -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd"
        TextEditorRunTrace "Arguments: $PolSARapArguments" "k"
        set f [ open "| Soft/PolSARap/PolSARap_Agriculture_Inversion_Surface.exe $PolSARapArguments" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig $PolSARapAgriMvFile $FinalNlig $FinalNcol 4
        EnviWriteConfig $PolSARapAgriDcSoilFile $FinalNlig $FinalNcol 4
        set BMPDirInput $PolSARapAgriDirOutput
        set BMPFileInput $PolSARapAgriMvFile
        set BMPFileOutput "$PolSARapAgriDirOutput/showcase_agri_surf_mv_soil.bmp"
        PSPcreate_bmp_file white $BMPFileInput $BMPFileOutput float real jet $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
        set BMPFileInput $PolSARapAgriDcSoilFile
        set BMPFileOutput "$PolSARapAgriDirOutput/showcase_agri_surf_dc_soil.bmp"
        PSPcreate_bmp_file white $BMPFileInput $BMPFileOutput float real jet $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
        }
    }
}
#############################################################################
## Procedure:  PolSARapAgriInvDihedral

proc ::PolSARapAgriInvDihedral {} {
global PolSARapAgriDirInput PolSARapAgriDirOutput PolSARapAgriOutputDir PolSARapAgriFonc
global PolSARapAgriIncAngFile PolSARapAgriMaskFile PolSARapAgriFsFdFile PolSARapAgriAlphaBetaFile
global PolSARapAgriKsFile PolSARapAgriMvFile PolSARapAgriDcSoilFile PolSARapAgriDcTrunkFile
global PolSARapAgriNwinL PolSARapAgriNwinC PolSARapAgriUnit PolSARapAgriSurfSoil PolSARapAgriSurfLUT
global PolSARapAgriDihedSoil PolSARapAgriDihedTrunk PolSARapAgriDihedLUT
global PSPMemory TMPMemoryAllocError
global NligInit NcolInit NligEnd NcolEnd NligFullSize NcolFullSize
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile TestVarName TestVarType TestVarValue TestVarMin TestVarMax TestVarError

if {$OpenDirFile == 0} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Soil Dielectric Constant"; set TestVarType(4) "float"; set TestVarValue(4) $PolSARapAgriDihedSoil; set TestVarMin(4) "1"; set TestVarMax(4) "100"
    set TestVarName(5) "LUT Increment Angle"; set TestVarType(5) "float"; set TestVarValue(5) $PolSARapAgriDihedLUT; set TestVarMin(5) "0"; set TestVarMax(5) "360"
    set TestVarName(6) "Trunk Dielectric Constant"; set TestVarType(6) "float"; set TestVarValue(6) $PolSARapAgriDihedTrunk; set TestVarMin(6) "1"; set TestVarMax(6) "100"
    TestVar 7
    if {$TestVarError == "ok"} {
        #Inversion
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "PolSARap Agriculture Dihedral Inversion"
        set MaskCmd ""
        set MaskFile "$PolSARapAgriDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/PolSARap/PolSARap_Agriculture_Inversion_Dihedral.exe" "k"
        set PolSARapArguments "-ifd \x22$PolSARapAgriFsFdFile\x22 -itt \x22$PolSARapAgriIncAngFile\x22 -ial \x22$PolSARapAgriAlphaBetaFile\x22 -imk \x22$PolSARapAgriMaskFile\x22 -od \x22$PolSARapAgriDirOutput\x22 -un $PolSARapAgriUnit -dis $PolSARapAgriDihedSoil -dit $PolSARapAgriDihedTrunk -inc $PolSARapAgriDihedLUT -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd"
        if {$PolSARapAgriKsFile != "Enter 2D Ks File ( Optional )"} { append PolSARapArguments " -iks \x22$PolSARapAgriKsFile\x22" }
        TextEditorRunTrace "Arguments: $PolSARapArguments" "k"
        set f [ open "| Soft/PolSARap/PolSARap_Agriculture_Inversion_Dihedral.exe $PolSARapArguments" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig $PolSARapAgriMvFile $FinalNlig $FinalNcol 4
        EnviWriteConfig $PolSARapAgriDcSoilFile $FinalNlig $FinalNcol 4
        set BMPDirInput $PolSARapAgriDirOutput
        set BMPFileInput $PolSARapAgriMvFile
        set BMPFileOutput "$PolSARapAgriDirOutput/showcase_agri_dihed_mv_soil.bmp"
        PSPcreate_bmp_file white $BMPFileInput $BMPFileOutput float real jet $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
        set BMPFileInput $PolSARapAgriDcSoilFile
        set BMPFileOutput "$PolSARapAgriDirOutput/showcase_agri_dihed_dc_soil.bmp"
        PSPcreate_bmp_file white $BMPFileInput $BMPFileOutput float real jet $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
        set BMPFileInput $PolSARapAgriDcTrunkFile
        set BMPFileOutput "$PolSARapAgriDirOutput/showcase_agri_dihed_dc_trunk.bmp"
        PSPcreate_bmp_file white $BMPFileInput $BMPFileOutput float real jet $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
        }
    }
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
    wm geometry $top 200x200+175+175; update
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

proc vTclWindow.top531 {base} {
    if {$base == ""} {
        set base .top531
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
    wm geometry $top 500x740+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PolSAR-ap Showcase : Agriculture"
    vTcl:DefineAlias "$top" "Toplevel531" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd66 \
        -ipad 2 -text {Input Directory} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame531_1" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.cpd67
    set site_5_0 $site_4_0.cpd67
    entry $site_5_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapAgriDirInput 
    vTcl:DefineAlias "$site_5_0.cpd72" "Entry314" vTcl:WidgetProc "Toplevel531" 1
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame8" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but75" "Button5" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.but75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd69 \
        -ipad 2 -text {Output Directory} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame17" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    frame $site_4_0.cpd70
    set site_5_0 $site_4_0.cpd70
    entry $site_5_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PolSARapAgriOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd82" "Entry531" vTcl:WidgetProc "Toplevel531" 1
    frame $site_5_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame15" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab73" "Label5" vTcl:WidgetProc "Toplevel531" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PolSARapAgriOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry5" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd84" "Frame7" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.cpd84
    button $site_6_0.cpd85 \
        \
        -command {global DirName DataDirChannel1 PolSARapAgriOutputDir 
global PolSARapAgriKappaFile PolSARapAgriDepthFile PolSARapAgriChannel

set PolSARapAgriOutputDirTmp $PolSARapAgriOutputDir
set DirName ""
OpenDir $DataDirChannel1 "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set PolSARapAgriOutputDir $DirName
    } else {
    set PolSARapAgriOutputDir $PolSARapAgriOutputDirTmp
    }
    
set PolSARapAgriKappaFile "$PolSARapAgriOutputDir/kappa_"
append PolSARapAgriKappaFile $PolSARapAgriChannel
append PolSARapAgriKappaFile ".bin"
set PolSARapAgriDepthFile "$PolSARapAgriOutputDir/depth_"
append PolSARapAgriDepthFile $PolSARapAgriChannel
append PolSARapAgriDepthFile ".bin"} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd85" "Button531" vTcl:WidgetProc "Toplevel531" 1
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
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel531" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label531_01" vTcl:WidgetProc "Toplevel531" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry531_01" vTcl:WidgetProc "Toplevel531" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label531_02" vTcl:WidgetProc "Toplevel531" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry531_02" vTcl:WidgetProc "Toplevel531" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label531_03" vTcl:WidgetProc "Toplevel531" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry531_03" vTcl:WidgetProc "Toplevel531" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label531_04" vTcl:WidgetProc "Toplevel531" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry531_04" vTcl:WidgetProc "Toplevel531" 1
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
    vTcl:DefineAlias "$top.fra67" "Frame1" vTcl:WidgetProc "Toplevel531" 1
    set site_3_0 $top.fra67
    TitleFrame $site_3_0.tit68 \
        -ipad 2 -text Decomposition 
    vTcl:DefineAlias "$site_3_0.tit68" "TitleFrame1" vTcl:WidgetProc "Toplevel531" 1
    bind $site_3_0.tit68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit68 getframe]
    radiobutton $site_5_0.rad70 \
        -background #ffff00 \
        -command {global PolSARapAgriDirInput PolSARapAgriOutputDir PolSARapAgriFonc
global PolSARapAgriIncAngFile PolSARapAgriMaskFile PolSARapAgriFsFdFile PolSARapAgriAlphaBetaFile
global PolSARapAgriKsFile PolSARapAgriMvFile PolSARapAgriDcSoilFile PolSARapAgriDcTrunkFile
global PolSARapAgriNwinL PolSARapAgriNwinC PolSARapAgriUnit PolSARapAgriSurfSoil PolSARapAgriSurfLUT
global PolSARapAgriDihedSoil PolSARapAgriDihedTrunk PolSARapAgriDihedLUT
global PSPBackgroundColor

$widget(TitleFrame531_4) configure -text "Polarimetric Decomposition File"
$widget(TitleFrame531_5) configure -text "Polarimetric Decomposition File"

$widget(TitleFrame531_3) configure -state disable
$widget(TitleFrame531_4) configure -state disable
$widget(TitleFrame531_5) configure -state disable
$widget(TitleFrame531_6) configure -state disable
$widget(TitleFrame531_7) configure -state disable
$widget(TitleFrame531_8) configure -state disable
$widget(TitleFrame531_9) configure -state disable
$widget(TitleFrame531_10) configure -state disable
$widget(TitleFrame531_11) configure -state disable

$widget(Label531_1) configure -state normal
$widget(Label531_2) configure -state normal
$widget(Label531_3) configure -state disable
$widget(Label531_4) configure -state disable
$widget(Label531_5) configure -state disable
$widget(Label531_6) configure -state disable
$widget(Label531_7) configure -state disable

$widget(Button531_1) configure -state disable
$widget(Button531_2) configure -state disable
$widget(Button531_3) configure -state disable
$widget(Button531_4) configure -state disable
$widget(Button531_5) configure -state disable

$widget(Radiobutton531_4) configure -state disable
$widget(Radiobutton531_5) configure -state disable

$widget(Entry531_1) configure -state normal
$widget(Entry531_1) configure -disabledbackground #FFFFFF
$widget(Entry531_2) configure -state normal
$widget(Entry531_2) configure -disabledbackground #FFFFFF
$widget(Entry531_3) configure -state disable
$widget(Entry531_3) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_4) configure -state disable
$widget(Entry531_4) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_5) configure -state disable
$widget(Entry531_5) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_6) configure -state disable
$widget(Entry531_6) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_7) configure -state disable
$widget(Entry531_7) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_8) configure -state disable
$widget(Entry531_8) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_9) configure -state disable
$widget(Entry531_9) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_10) configure -state disable
$widget(Entry531_10) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_11) configure -state disable
$widget(Entry531_11) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_12) configure -state disable
$widget(Entry531_12) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_13) configure -state disable
$widget(Entry531_13) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_14) configure -state disable
$widget(Entry531_14) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_15) configure -state disable
$widget(Entry531_15) configure -disabledbackground $PSPBackgroundColor

set PolSARapAgriIncAngFile ""
set PolSARapAgriMaskFile ""
set PolSARapAgriFsFdFile ""
set PolSARapAgriAlphaBetaFile ""
set PolSARapAgriKsFile ""
set PolSARapAgriMvFile ""
set PolSARapAgriDcSoilFile ""
set PolSARapAgriDcTrunkFile ""
set PolSARapAgriNwinL "7"
set PolSARapAgriNwinC "7"
set PolSARapAgriUnit ""
set PolSARapAgriSurfSoil ""
set PolSARapAgriSurfLUT ""
set PolSARapAgriDihedSoil ""
set PolSARapAgriDihedTrunk ""
set PolSARapAgriDihedLUT ""} \
        -highlightthickness 0 -offrelief flat -padx 0 -pady 0 -relief raised \
        -value Dec -variable PolSARapAgriFonc 
    vTcl:DefineAlias "$site_5_0.rad70" "Radiobutton4" vTcl:WidgetProc "Toplevel531" 1
    frame $site_5_0.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra71" "Frame2" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra71
    frame $site_6_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra72" "Frame5" vTcl:WidgetProc "Toplevel531" 1
    set site_7_0 $site_6_0.fra72
    label $site_7_0.lab73 \
        -text {Window Size (Row)} 
    vTcl:DefineAlias "$site_7_0.lab73" "Label531_1" vTcl:WidgetProc "Toplevel531" 1
    entry $site_7_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapAgriNwinL -width 5 
    vTcl:DefineAlias "$site_7_0.ent74" "Entry531_1" vTcl:WidgetProc "Toplevel531" 1
    pack $site_7_0.lab73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    frame $site_6_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd75" "Frame6" vTcl:WidgetProc "Toplevel531" 1
    set site_7_0 $site_6_0.cpd75
    label $site_7_0.lab73 \
        -text {Window Size (Col)} 
    vTcl:DefineAlias "$site_7_0.lab73" "Label531_2" vTcl:WidgetProc "Toplevel531" 1
    entry $site_7_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapAgriNwinC -width 5 
    vTcl:DefineAlias "$site_7_0.ent74" "Entry531_2" vTcl:WidgetProc "Toplevel531" 1
    pack $site_7_0.lab73 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_7_0.ent74 \
        -in $site_7_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    pack $site_6_0.fra72 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.rad70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd69 \
        -ipad 2 -text {Inc Ang Unit} 
    vTcl:DefineAlias "$site_3_0.cpd69" "TitleFrame531_10" vTcl:WidgetProc "Toplevel531" 1
    bind $site_3_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    frame $site_5_0.fra78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra78" "Frame10" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra78
    radiobutton $site_6_0.cpd79 \
        -text Degrees -value 0 -variable PolSARapAgriUnit 
    vTcl:DefineAlias "$site_6_0.cpd79" "Radiobutton531_4" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd80" "Frame11" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.cpd80
    radiobutton $site_6_0.cpd79 \
        -text Radians -value 1 -variable PolSARapAgriUnit 
    vTcl:DefineAlias "$site_6_0.cpd79" "Radiobutton531_5" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra78 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_3_0.tit68 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    TitleFrame $top.tit84 \
        -ipad 2 -text {Surface Soil Moisture Inversion} 
    vTcl:DefineAlias "$top.tit84" "TitleFrame5" vTcl:WidgetProc "Toplevel531" 1
    bind $top.tit84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit84 getframe]
    radiobutton $site_4_0.cpd90 \
        -background #ffff00 \
        -command {global PolSARapAgriDirInput PolSARapAgriOutputDir PolSARapAgriFonc
global PolSARapAgriIncAngFile PolSARapAgriMaskFile PolSARapAgriFsFdFile PolSARapAgriAlphaBetaFile
global PolSARapAgriKsFile PolSARapAgriMvFile PolSARapAgriDcSoilFile PolSARapAgriDcTrunkFile
global PolSARapAgriNwinL PolSARapAgriNwinC PolSARapAgriUnit PolSARapAgriSurfSoil PolSARapAgriSurfLUT
global PolSARapAgriDihedSoil PolSARapAgriDihedTrunk PolSARapAgriDihedLUT
global PSPBackgroundColor

$widget(TitleFrame531_4) configure -text "Polarimetric Decomposition fs File"
$widget(TitleFrame531_5) configure -text "Polarimetric Decomposition Beta File"

$widget(TitleFrame531_3) configure -state normal
$widget(TitleFrame531_4) configure -state normal
$widget(TitleFrame531_5) configure -state normal
$widget(TitleFrame531_6) configure -state disable
$widget(TitleFrame531_7) configure -state normal
$widget(TitleFrame531_8) configure -state normal
$widget(TitleFrame531_9) configure -state disable
$widget(TitleFrame531_10) configure -state normal
$widget(TitleFrame531_11) configure -state normal

$widget(Label531_1) configure -state disable
$widget(Label531_2) configure -state disable
$widget(Label531_3) configure -state disable
$widget(Label531_4) configure -state disable
$widget(Label531_5) configure -state normal
$widget(Label531_6) configure -state disable
$widget(Label531_7) configure -state normal

$widget(Button531_1) configure -state normal
$widget(Button531_2) configure -state normal
$widget(Button531_3) configure -state normal
$widget(Button531_4) configure -state disable
$widget(Button531_5) configure -state normal

$widget(Radiobutton531_4) configure -state normal
$widget(Radiobutton531_5) configure -state normal

$widget(Entry531_1) configure -state disable
$widget(Entry531_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_2) configure -state disable
$widget(Entry531_2) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_3) configure -state disable
$widget(Entry531_3) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_4) configure -state disable
$widget(Entry531_4) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_5) configure -state normal
$widget(Entry531_5) configure -disabledbackground #FFFFFF
$widget(Entry531_6) configure -state disable
$widget(Entry531_6) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_7) configure -state normal
$widget(Entry531_7) configure -disabledbackground #FFFFFF
$widget(Entry531_8) configure -state disable
$widget(Entry531_8) configure -disabledbackground #FFFFFF
$widget(Entry531_9) configure -state disable
$widget(Entry531_9) configure -disabledbackground #FFFFFF
$widget(Entry531_10) configure -state disable
$widget(Entry531_10) configure -disabledbackground #FFFFFF
$widget(Entry531_11) configure -state disable
$widget(Entry531_11) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_12) configure -state disable
$widget(Entry531_12) configure -disabledbackground #FFFFFF
$widget(Entry531_13) configure -state disable
$widget(Entry531_13) configure -disabledbackground #FFFFFF
$widget(Entry531_14) configure -state disable
$widget(Entry531_14) configure -disabledbackground #FFFFFF
$widget(Entry531_15) configure -state disable
$widget(Entry531_15) configure -disabledbackground $PSPBackgroundColor

set PolSARapAgriIncAngFile "Enter 2D Incidence Angle File"
set PolSARapAgriMaskFile "Enter (showcase_agri_mask.bin) file"
set PolSARapAgriFsFdFile "Enter (showcase_agri_fs.bin) file"
set PolSARapAgriAlphaBetaFile "Enter (showcase_agri_beta.bin) file"
set PolSARapAgriKsFile ""
set PolSARapAgriMvFile "$PolSARapAgriOutputDir/showcase_agri_surf_mv_soil.bin"
set PolSARapAgriDcSoilFile "$PolSARapAgriOutputDir/showcase_agri_surf_dc_soil.bin"
set PolSARapAgriDcTrunkFile ""
set PolSARapAgriNwinL ""
set PolSARapAgriNwinC ""
set PolSARapAgriUnit "1"
set PolSARapAgriSurfSoil "40"
set PolSARapAgriSurfLUT "0.1"
set PolSARapAgriDihedSoil ""
set PolSARapAgriDihedTrunk ""
set PolSARapAgriDihedLUT ""} \
        -highlightthickness 0 -offrelief flat -padx 0 -pady 0 -relief raised \
        -value InvS -variable PolSARapAgriFonc 
    vTcl:DefineAlias "$site_4_0.cpd90" "Radiobutton10" vTcl:WidgetProc "Toplevel531" 1
    frame $site_4_0.cpd85 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd85" "Frame12" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd85
    frame $site_5_0.fra71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra71" "Frame13" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra71
    frame $site_6_0.cpd86 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd86" "Frame17" vTcl:WidgetProc "Toplevel531" 1
    set site_7_0 $site_6_0.cpd86
    frame $site_7_0.cpd66 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd66" "Frame24" vTcl:WidgetProc "Toplevel531" 1
    set site_8_0 $site_7_0.cpd66
    label $site_8_0.lab73 \
        -text {Soil Dielectric Constant Max} 
    vTcl:DefineAlias "$site_8_0.lab73" "Label531_5" vTcl:WidgetProc "Toplevel531" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapAgriSurfSoil -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry531_5" vTcl:WidgetProc "Toplevel531" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_7_0.cpd66 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd88" "Frame23" vTcl:WidgetProc "Toplevel531" 1
    set site_7_0 $site_6_0.cpd88
    label $site_7_0.cpd75 \
        -text {Increment Angle of the Incidence Angle LUT (deg) } 
    vTcl:DefineAlias "$site_7_0.cpd75" "Label531_7" vTcl:WidgetProc "Toplevel531" 1
    entry $site_7_0.cpd76 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapAgriSurfLUT -width 5 
    vTcl:DefineAlias "$site_7_0.cpd76" "Entry531_7" vTcl:WidgetProc "Toplevel531" 1
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra71 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -padx 5 -pady 2 \
        -side left 
    TitleFrame $top.cpd67 \
        -ipad 2 -text {Dihedral Soil Moisture Inversion} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame6" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    radiobutton $site_4_0.cpd90 \
        -background #ffff00 \
        -command {global PolSARapAgriDirInput PolSARapAgriOutputDir PolSARapAgriFonc
global PolSARapAgriIncAngFile PolSARapAgriMaskFile PolSARapAgriFsFdFile PolSARapAgriAlphaBetaFile
global PolSARapAgriKsFile PolSARapAgriMvFile PolSARapAgriDcSoilFile PolSARapAgriDcTrunkFile
global PolSARapAgriNwinL PolSARapAgriNwinC PolSARapAgriUnit PolSARapAgriSurfSoil PolSARapAgriSurfLUT
global PolSARapAgriDihedSoil PolSARapAgriDihedTrunk PolSARapAgriDihedLUT
global PSPBackgroundColor

$widget(TitleFrame531_4) configure -text "Polarimetric Decomposition fd File"
$widget(TitleFrame531_5) configure -text "Polarimetric Decomposition Alpha File"

$widget(TitleFrame531_3) configure -state normal
$widget(TitleFrame531_4) configure -state normal
$widget(TitleFrame531_5) configure -state normal
$widget(TitleFrame531_6) configure -state normal
$widget(TitleFrame531_7) configure -state normal
$widget(TitleFrame531_8) configure -state normal
$widget(TitleFrame531_9) configure -state normal
$widget(TitleFrame531_10) configure -state normal
$widget(TitleFrame531_11) configure -state normal

$widget(Label531_1) configure -state disable
$widget(Label531_2) configure -state disable
$widget(Label531_3) configure -state normal
$widget(Label531_4) configure -state normal
$widget(Label531_5) configure -state disable
$widget(Label531_6) configure -state normal
$widget(Label531_7) configure -state disable

$widget(Button531_1) configure -state normal
$widget(Button531_2) configure -state normal
$widget(Button531_3) configure -state normal
$widget(Button531_4) configure -state normal
$widget(Button531_5) configure -state normal

$widget(Radiobutton531_4) configure -state normal
$widget(Radiobutton531_5) configure -state normal

$widget(Entry531_1) configure -state disable
$widget(Entry531_1) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_2) configure -state disable
$widget(Entry531_2) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_3) configure -state normal
$widget(Entry531_3) configure -disabledbackground #FFFFFF
$widget(Entry531_4) configure -state normal
$widget(Entry531_4) configure -disabledbackground #FFFFFF
$widget(Entry531_5) configure -state disable
$widget(Entry531_5) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_6) configure -state normal
$widget(Entry531_6) configure -disabledbackground #FFFFFF
$widget(Entry531_7) configure -state disable
$widget(Entry531_7) configure -disabledbackground $PSPBackgroundColor
$widget(Entry531_8) configure -state disable
$widget(Entry531_8) configure -disabledbackground #FFFFFF
$widget(Entry531_9) configure -state disable
$widget(Entry531_9) configure -disabledbackground #FFFFFF
$widget(Entry531_10) configure -state disable
$widget(Entry531_10) configure -disabledbackground #FFFFFF
$widget(Entry531_11) configure -state disable
$widget(Entry531_11) configure -disabledbackground #FFFFFF
$widget(Entry531_12) configure -state disable
$widget(Entry531_12) configure -disabledbackground #FFFFFF
$widget(Entry531_13) configure -state disable
$widget(Entry531_13) configure -disabledbackground #FFFFFF
$widget(Entry531_14) configure -state disable
$widget(Entry531_14) configure -disabledbackground #FFFFFF
$widget(Entry531_15) configure -state disable
$widget(Entry531_15) configure -disabledbackground #FFFFFF

set PolSARapAgriIncAngFile "Enter 2D Incidence Angle File"
set PolSARapAgriMaskFile "Enter (showcase_agri_mask.bin) file"
set PolSARapAgriFsFdFile "Enter (showcase_agri_fd.bin) file"
set PolSARapAgriAlphaBetaFile "Enter (showcase_agri_alpha.bin) file"
set PolSARapAgriKsFile "Enter 2D Ks File ( Optional )"
set PolSARapAgriMvFile "$PolSARapAgriOutputDir/showcase_agri_dihed_mv_soil.bin"
set PolSARapAgriDcSoilFile "$PolSARapAgriOutputDir/showcase_agri_dihed_dc_soil.bin"
set PolSARapAgriDcTrunkFile "$PolSARapAgriOutputDir/showcase_agri_dihed_dc_trunk.bin"
set PolSARapAgriNwinL ""
set PolSARapAgriNwinC ""
set PolSARapAgriUnit "1"
set PolSARapAgriSurfSoil ""
set PolSARapAgriSurfLUT ""
set PolSARapAgriDihedSoil "40"
set PolSARapAgriDihedTrunk "40"
set PolSARapAgriDihedLUT "0.1"} \
        -highlightthickness 0 -offrelief flat -padx 0 -pady 0 -relief raised \
        -value InvD -variable PolSARapAgriFonc 
    vTcl:DefineAlias "$site_4_0.cpd90" "Radiobutton11" vTcl:WidgetProc "Toplevel531" 1
    frame $site_4_0.cpd85 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd85" "Frame14" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd85
    frame $site_5_0.fra71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra71" "Frame16" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra71
    frame $site_6_0.cpd86 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd86" "Frame33" vTcl:WidgetProc "Toplevel531" 1
    set site_7_0 $site_6_0.cpd86
    frame $site_7_0.cpd66 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd66" "Frame34" vTcl:WidgetProc "Toplevel531" 1
    set site_8_0 $site_7_0.cpd66
    label $site_8_0.lab73 \
        -text {Soil Dielectric Constant Max} 
    vTcl:DefineAlias "$site_8_0.lab73" "Label531_6" vTcl:WidgetProc "Toplevel531" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapAgriDihedSoil -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry531_6" vTcl:WidgetProc "Toplevel531" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_7_0.cpd68 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd68" "Frame36" vTcl:WidgetProc "Toplevel531" 1
    set site_8_0 $site_7_0.cpd68
    label $site_8_0.lab73 \
        -text {Trunk Dielectric Constant Max} 
    vTcl:DefineAlias "$site_8_0.lab73" "Label531_3" vTcl:WidgetProc "Toplevel531" 1
    entry $site_8_0.ent74 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapAgriDihedTrunk -width 5 
    vTcl:DefineAlias "$site_8_0.ent74" "Entry531_3" vTcl:WidgetProc "Toplevel531" 1
    pack $site_8_0.lab73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.ent74 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_7_0.cpd66 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd68 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd88" "Frame35" vTcl:WidgetProc "Toplevel531" 1
    set site_7_0 $site_6_0.cpd88
    label $site_7_0.cpd75 \
        -text {Increment Angle of the Incidence Angle LUT (deg) } 
    vTcl:DefineAlias "$site_7_0.cpd75" "Label531_4" vTcl:WidgetProc "Toplevel531" 1
    entry $site_7_0.cpd76 \
        -background white -foreground #ff0000 -justify center \
        -textvariable PolSARapAgriDihedLUT -width 5 
    vTcl:DefineAlias "$site_7_0.cpd76" "Entry531_4" vTcl:WidgetProc "Toplevel531" 1
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra71 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -padx 5 -pady 2 \
        -side left 
    TitleFrame $top.cpd78 \
        -ipad 2 -text {2D-Incidence Angle File} 
    vTcl:DefineAlias "$top.cpd78" "TitleFrame531_11" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd78 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame113" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame21" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapAgriIncAngFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry531_14" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame22" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName PolSARapAgriDirInput PolSARapAgriIncAngFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D INCIDENCE ANGLE FILE MUST HAVE THE SAME"
set WarningMessage2 "DATA SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Incidence Angle Files}        {.bin}        }
}
set FileName ""
OpenFile "$PolSARapAgriDirInput" $types "2D-INCIDENCE ANGLE FILE"
if {$FileName != ""} {
    set PolSARapAgriIncAngFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button531_5" vTcl:WidgetProc "Toplevel531" 1
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
    TitleFrame $top.cpd77 \
        -ipad 2 -text {2D Mask File} 
    vTcl:DefineAlias "$top.cpd77" "TitleFrame531_3" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd77 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame112" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame18" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapAgriMaskFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry531_8" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame19" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName PolSARapAgriDirInput PolSARapAgriMaskFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D MASK FILE MUST HAVE THE SAME DATA SIZE"
set WarningMessage2 "AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Mask Files}        {.bin}        }
}
set FileName ""
OpenFile "$PolSARapAgriDirInput" $types "2D MASK FILE"
if {$FileName != ""} {
    set PolSARapAgriMaskFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button531_1" vTcl:WidgetProc "Toplevel531" 1
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
    TitleFrame $top.cpd70 \
        -ipad 2 -text {Polarimetric Decomposition File} 
    vTcl:DefineAlias "$top.cpd70" "TitleFrame531_4" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd70 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame115" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame25" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapAgriFsFdFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry531_9" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame26" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName PolSARapAgriDirInput PolSARapAgriFsFdFile PolSARapAgriFonc
global WarningMessage WarningMessage2 VarAdvice

if {$PolSARapAgriFonc == "InvS"} {
    set types {
    {{Fs Files}        {.bin}        }
    }
    set FileName ""
    OpenFile "$PolSARapAgriDirInput" $types "POLARIMETRIC fs FILE"
    }
if {$PolSARapAgriFonc == "InvD"} {
    set types {
    {{Fd Files}        {.bin}        }
    }
    set FileName ""
    OpenFile "$PolSARapAgriDirInput" $types "POLARIMETRIC fd FILE"
    }
    
if {$FileName != ""} {
    set PolSARapAgriFsFdFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button531_2" vTcl:WidgetProc "Toplevel531" 1
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
    TitleFrame $top.cpd71 \
        -ipad 2 -text {Polarimetric Decomposition File} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame531_5" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame120" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame31" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapAgriAlphaBetaFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry531_10" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame32" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName PolSARapAgriDirInput PolSARapAgriAlphaBetaFile PolSARapAgriFonc
global WarningMessage WarningMessage2 VarAdvice

if {$PolSARapAgriFonc == "InvS"} {
    set types {
    {{Beta Files}        {.bin}        }
    }
    set FileName ""
    OpenFile "$PolSARapAgriDirInput" $types "POLARIMETRIC Beta FILE"
    }
if {$PolSARapAgriFonc == "InvD"} {
    set types {
    {{Alpha Files}        {.bin}        }
    }
    set FileName ""
    OpenFile "$PolSARapAgriDirInput" $types "POLARIMETRIC Alpha FILE"
    }
    
if {$FileName != ""} {
    set PolSARapAgriAlphaBetaFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button531_3" vTcl:WidgetProc "Toplevel531" 1
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
    TitleFrame $top.cpd68 \
        -ipad 2 -text {Vertical Rougness Indicator (ks) File (optional)} 
    vTcl:DefineAlias "$top.cpd68" "TitleFrame531_6" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd68 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame119" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame29" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable PolSARapAgriKsFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry531_11" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra90" "Frame30" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra90
    button $site_6_0.cpd72 \
        \
        -command {global FileName PolSARapAgriDirInput PolSARapAgriKsFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D KS FILE MUST HAVE THE SAME"
set WarningMessage2 "DATA SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{Ks Files}        {.bin}        }
}
set FileName ""
OpenFile "$PolSARapAgriDirInput" $types "2D KS FILE"
if {$FileName != ""} {
    set PolSARapAgriKsFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd72" "Button531_4" vTcl:WidgetProc "Toplevel531" 1
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
    TitleFrame $top.cpd87 \
        -ipad 2 -text {Output Soil Moisture File} 
    vTcl:DefineAlias "$top.cpd87" "TitleFrame531_7" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd87 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd87 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame117" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame27" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PolSARapAgriMvFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry531_12" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd88 \
        -ipad 2 -text {Output Soil Dielectric Constant File} 
    vTcl:DefineAlias "$top.cpd88" "TitleFrame531_8" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd88 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd88 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame118" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame28" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PolSARapAgriDcSoilFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry531_13" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd72 \
        -ipad 2 -text {Output Trunk Dielectric Constant File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame531_9" vTcl:WidgetProc "Toplevel531" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    frame $site_4_0.cpd76 \
        -height 75 -width 159 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame121" vTcl:WidgetProc "Toplevel531" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra88" "Frame37" vTcl:WidgetProc "Toplevel531" 1
    set site_6_0 $site_5_0.fra88
    entry $site_6_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable PolSARapAgriDcTrunkFile -width 40 
    vTcl:DefineAlias "$site_6_0.cpd89" "Entry531_15" vTcl:WidgetProc "Toplevel531" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra88 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel531" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global PolSARapAgriDirOutput PolSARapAgriOutputDir PolSARapAgriOutputSubDir PolSARapAgriDirInput
global PSPMemory TMPMemoryAllocError
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile PolSARapAgriFonc

if {$OpenDirFile == 0} {

set PolSARapAgriDirOutput $PolSARapAgriOutputDir 
if {$PolSARapAgriOutputSubDir != ""} {append PolSARapAgriDirOutput "/$PolSARapAgriOutputSubDir"}
        
    #####################################################################
    #Create Directory
    set PolSARapAgriDirOutput [PSPCreateDirectoryMask $PolSARapAgriDirOutput $PolSARapAgriOutputDir $PolSARapAgriDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    if {$PolSARapAgriFonc == "Dec"} { PolSARapAgriDecomp }
    if {$PolSARapAgriFonc == "InvS"} { PolSARapAgriInvSurface }
    if {$PolSARapAgriFonc == "InvD"} { PolSARapAgriInvDihedral }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel534); TextEditorRunTrace "Close Window PolSARap Showcase Agriculture" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel531" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel531" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel531); TextEditorRunTrace "Close Window PolSARap Showcase Agriculture" "b"
set ProgressLine "0"; update
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel531" 1
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
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit84 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -side top 
    pack $top.cpd78 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd70 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd87 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
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
Window show .top531

main $argc $argv
