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

        {{[file join . GUI Images ColorMapGrayRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapJetRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapJetInv.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapJetRevInv.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapHsv.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapHsvRev.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapHsvInv.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapHsvRevInv.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapJet.gif]} {user image} user {}}
        {{[file join . GUI Images ColorMapGray.gif]} {user image} user {}}

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
    set base .top43
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
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
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra51 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra51
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
    namespace eval ::widgets::$base.tit81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit85 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit85 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra91 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra91
    namespace eval ::widgets::$site_3_0.cpd92 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd92 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd76
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd93 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd93 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-_tooltip 1 -command 1 -image 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd86 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd94 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd94 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -value 1 -variable 1}
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
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra36 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra36
    namespace eval ::widgets::$site_3_0.lab27 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent29 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit97 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit97 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra77
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.cpd102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd102
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-_tooltip 1 -background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra67
    namespace eval ::widgets::$site_6_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.ent71 {
        array set save {-background 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.lab68 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd75
    namespace eval ::widgets::$site_6_0.ent71 {
        array set save {-background 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
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
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-background 1 -borderwidth 1 -padx 1 -pady 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-background 1 -borderwidth 1 -padx 1 -pady 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -borderwidth 1 -padx 1 -pady 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.cpd99 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.fra38 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra38
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top43
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
    wm geometry $top 200x200+250+250; update
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

proc vTclWindow.top43 {base} {
    if {$base == ""} {
        set base .top43
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
    wm title $top "Create BMP File"
    vTcl:DefineAlias "$top" "Toplevel43" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel43" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel43" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPFileInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel43" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName BMPDirInput BMPDirOutput BMPFileInput BMPFileOutput BMPFileOutputTmp BMPOutputFormat
global ValidMaskFile ValidMaskColor ColorMapFile
global VarError ErrorMessage MaskCmd CONFIGDir
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize

set BMPFileInput ""
set BMPFileOutput ""
set BMPFileOutputTmp ""
set NligInit ""
set NligEnd ""
set NcolInit ""
set NcolEnd ""
set NcolFullSize ""
set NligFullSize ""
set InputFormat "float"
set OutputFormat "real"
set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
set ColorMap "jet"
set MinMaxAutoBMP 1
set MinMaxContrastBMP 0
$widget(Label43_1) configure -state disable
$widget(Entry43_1) configure -state disable
$widget(Label43_2) configure -state disable
$widget(Entry43_2) configure -state disable
$widget(Button43_1) configure -state disable
$widget(Label43_3) configure -state disable
$widget(Entry43_3) configure -state disable
$widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label43_4) configure -state disable
$widget(Entry43_4) configure -state disable
$widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button43_1) configure -state disable
$widget(Checkbutton43_1) configure -state normal
$widget(Checkbutton43_2) configure -state normal
set MinBMP "Auto"
set MaxBMP "Auto"
set MinCBMP ""
set MaxCBMP ""
set BMPOutputFormat "bmp8"
set MaskCmd ""
set ValidMaskFile ""
set ValidMaskColor "black"

set BMPDirInputTmp $BMPDirInput
set BMPDirOutputTmp $BMPDirOutput

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $BMPDirInput $types "INPUT FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; set NcolFullSize [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; set NligFullSize [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            set NligInit 1
            set NligEnd $NligFullSize
            set NcolInit 1
            set NcolEnd $NcolFullSize
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {$tmp == "data type = 2"} {set InputFormat "int"; set OutputFormat "real"}
            if {$tmp == "data type = 4"} {set InputFormat "float"; set OutputFormat "real"}
            if {$tmp == "data type = 6"} {set InputFormat "cmplx"; set OutputFormat "mod"}
            set BMPDirInput [file dirname $FileName]
            set BMPDirOutput $BMPDirInput
            set BMPFileInput $FileName
            set BMPFileOutput [file rootname $BMPFileInput]
            if {$OutputFormat == "real"} {append BMPFileOutput "_real.bmp"}
            if {$OutputFormat == "mod"} {append BMPFileOutput "_mod.bmp"}
            set MaskFile "$BMPDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] { 
                set ValidMaskFile $MaskFile
                set MaskCmd "-mask \x22$MaskFile\x22" 
                }
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set BMPDirInput $BMPDirInputTmp
            set BMPDirOutput $BMPDirOutputTmp
            if {$VarError == "cancel"} {Window hide $widget(Toplevel43); TextEditorRunTrace "Close Window Create BMP File" "b"}
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set BMPDirInput $BMPDirInputTmp
        set BMPDirOutput $BMPDirOutputTmp
        if {$VarError == "cancel"} {Window hide $widget(Toplevel43); TextEditorRunTrace "Close Window Create BMP File" "b"}
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
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output BMP Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame9" vTcl:WidgetProc "Toplevel43" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BMPDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel43" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global DirName DataDir BMPDirOutput BMPFileOutput

set BMPDirOutputTmp $BMPDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set BMPDirOutput $DirName
    } else {
    set BMPDirOutput $BMPDirOutputTmp
    }
set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileOutput]
set BMPFileOutput $FileTmp} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra51 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra51" "Frame9" vTcl:WidgetProc "Toplevel43" 1
    set site_3_0 $top.fra51
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel43" 1
    entry $site_3_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel43" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel43" 1
    entry $site_3_0.ent60 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel43" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel43" 1
    entry $site_3_0.ent62 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel43" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel43" 1
    entry $site_3_0.ent64 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel43" 1
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
    TitleFrame $top.tit81 \
        -ipad 0 -text {Data Format} 
    vTcl:DefineAlias "$top.tit81" "TitleFrame1" vTcl:WidgetProc "Toplevel43" 1
    bind $top.tit81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit81 getframe]
    radiobutton $site_4_0.cpd82 \
        -padx 1 -text Complex -value cmplx -variable InputFormat 
    radiobutton $site_4_0.cpd83 \
        -padx 1 -text Float -value float -variable InputFormat 
    radiobutton $site_4_0.cpd84 \
        -padx 1 -text Integer -value int -variable InputFormat 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit85 \
        -ipad 0 -text Show 
    vTcl:DefineAlias "$top.tit85" "TitleFrame2" vTcl:WidgetProc "Toplevel43" 1
    bind $top.tit85 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit85 getframe]
    radiobutton $site_4_0.cpd86 \
        \
        -command {global BMPFileOutput BMPFileInput BMPDirOutput MinMaxContrastBMP

set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileInput]
set BMPFileOutput [file rootname $FileTmp]
append BMPFileOutput "_mod.bmp"
set MinMaxContrastBMP 0} \
        -padx 1 -text Modulus -value mod -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd86" "Radiobutton35" vTcl:WidgetProc "Toplevel43" 1
    radiobutton $site_4_0.cpd71 \
        \
        -command {global BMPFileOutput BMPFileInput BMPDirOutput MinMaxContrastBMP

set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileInput]
set BMPFileOutput [file rootname $FileTmp]
append BMPFileOutput "_db.bmp"
set MinMaxContrastBMP 1} \
        -padx 1 -text 10log(Mod) -value db10 -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd71" "Radiobutton43" vTcl:WidgetProc "Toplevel43" 1
    radiobutton $site_4_0.cpd87 \
        \
        -command {global BMPFileOutput BMPFileInput BMPDirOutput MinMaxContrastBMP

set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileInput]
set BMPFileOutput [file rootname $FileTmp]
append BMPFileOutput "_db.bmp"
set MinMaxContrastBMP 1} \
        -padx 1 -text 20log(Mod) -value db20 -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd87" "Radiobutton36" vTcl:WidgetProc "Toplevel43" 1
    radiobutton $site_4_0.cpd89 \
        \
        -command {global BMPFileOutput BMPFileInput BMPDirOutput MinMaxContrastBMP

set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileInput]
set BMPFileOutput [file rootname $FileTmp]
append BMPFileOutput "_pha.bmp"
set MinMaxContrastBMP 0} \
        -padx 1 -text Phase -value pha -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd89" "Radiobutton37" vTcl:WidgetProc "Toplevel43" 1
    radiobutton $site_4_0.cpd90 \
        \
        -command {global BMPFileOutput BMPFileInput BMPDirOutput MinMaxContrastBMP

set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileInput]
set BMPFileOutput [file rootname $FileTmp]
append BMPFileOutput "_real.bmp"
set MinMaxContrastBMP 0} \
        -padx 1 -text Real -value real -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd90" "Radiobutton38" vTcl:WidgetProc "Toplevel43" 1
    radiobutton $site_4_0.cpd92 \
        \
        -command {global BMPFileOutput BMPFileInput BMPDirOutput MinMaxContrastBMP

set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileInput]
set BMPFileOutput [file rootname $FileTmp]
append BMPFileOutput "_imag.bmp"
set MinMaxContrastBMP 0} \
        -padx 1 -text Imag -value imag -variable OutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd92" "Radiobutton39" vTcl:WidgetProc "Toplevel43" 1
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra91" "Frame11" vTcl:WidgetProc "Toplevel43" 1
    set site_3_0 $top.fra91
    TitleFrame $site_3_0.cpd92 \
        -text {ColorMap JET} 
    vTcl:DefineAlias "$site_3_0.cpd92" "TitleFrame11" vTcl:WidgetProc "Toplevel43" 1
    bind $site_3_0.cpd92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd92 getframe]
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame12" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd75
    radiobutton $site_6_0.cpd80 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} { 
    set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapJet.gif]] \
        -padx 1 -value jet -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd80" "Radiobutton51" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd80 "$site_6_0.cpd80 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Jet}
    }
    radiobutton $site_6_0.cpd84 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapJETrev.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapJetRev.gif]] \
        -padx 1 -value jetrev -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd84" "Radiobutton52" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd84 "$site_6_0.cpd84 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd84 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Jet Reverse}
    }
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd76" "Frame13" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd76
    radiobutton $site_6_0.cpd83 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapJETinv.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapJetInv.gif]] \
        -padx 1 -value jetinv -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd83" "Radiobutton53" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd83 "$site_6_0.cpd83 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd83 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Jet Inverse}
    }
    radiobutton $site_6_0.cpd85 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapJETrevinv.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapJetRevInv.gif]] \
        -padx 1 -value jetrevinv -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd85" "Radiobutton54" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd85 "$site_6_0.cpd85 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Jet Reverse Inverse}
    }
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd93 \
        -text {ColorMap GRAY} 
    vTcl:DefineAlias "$site_3_0.cpd93" "TitleFrame13" vTcl:WidgetProc "Toplevel43" 1
    bind $site_3_0.cpd93 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd93 getframe]
    frame $site_5_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame14" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd77
    radiobutton $site_6_0.cpd81 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapGRAY.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapGray.gif]] \
        -value gray -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd81" "Radiobutton55" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd81 "$site_6_0.cpd81 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd81 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Gray}
    }
    radiobutton $site_6_0.cpd86 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapGRAYrev.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapGrayRev.gif]] \
        -padx 1 -value grayrev -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd86" "Radiobutton56" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd86 "$site_6_0.cpd86 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd86 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Gray Reverse}
    }
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd86 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd94 \
        -text {ColorMap HSV} 
    vTcl:DefineAlias "$site_3_0.cpd94" "TitleFrame14" vTcl:WidgetProc "Toplevel43" 1
    bind $site_3_0.cpd94 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd94 getframe]
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame15" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd78
    radiobutton $site_6_0.cpd82 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapHSV.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapHsv.gif]] \
        -padx 1 -value hsv -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd82" "Radiobutton57" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd82 "$site_6_0.cpd82 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Hsv}
    }
    radiobutton $site_6_0.cpd87 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapHSVrev.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapHsvRev.gif]] \
        -padx 1 -value hsvrev -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd87" "Radiobutton58" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd87 "$site_6_0.cpd87 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Hsv Reverse}
    }
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side top 
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame16" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd79
    radiobutton $site_6_0.cpd88 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapHSVinv.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapHsvInv.gif]] \
        -padx 1 -value hsvinv -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd88" "Radiobutton59" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd88 "$site_6_0.cpd88 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd88 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Hsv Inverse}
    }
    radiobutton $site_6_0.cpd89 \
        \
        -command {global BMPOutputFormat ColorMapFile MinMaxAutoBMP MinMaxContrastBMP CONFIGDir

if {$BMPOutputFormat == "bmp8"} {
    set ColorMapFile "$CONFIGDir/ColorMapHSVrevinv.pal"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }} \
        -image [vTcl:image:get_image [file join . GUI Images ColorMapHsvRevInv.gif]] \
        -padx 1 -value hsvrevinv -variable ColorMap 
    vTcl:DefineAlias "$site_6_0.cpd89" "Radiobutton60" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Radiobutton $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Hsv Reverse Inverse}
    }
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side top 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd92 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd93 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd94 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {ColorMap File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame8" vTcl:WidgetProc "Toplevel43" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry43_5" vTcl:WidgetProc "Toplevel43" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel43" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd79 \
        \
        -command {global FileName ColorMap ColorMapFile MinMaxAutoBMP MinMaxContrastBMP COLORMAPDir

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$COLORMAPDir" $types "INPUT COLOR MAP FILE"
    
if {$FileName != ""} {
    set ColorMapFile $FileName
    set ColorMap "$ColorMapFile"
    set MinMaxAutoBMP 0
    set MinMaxContrastBMP 0
    set MinBMP "0"
    set MaxBMP "255"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state disable
    $widget(Checkbutton43_2) configure -state disable
    } else {
    set ColorMapFile "$CONFIGDir/ColorMapJET.pal"
    set ColorMap "jet"
    set MinMaxAutoBMP 1
    set MinMaxContrastBMP 0
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    $widget(Checkbutton43_1) configure -state normal
    $widget(Checkbutton43_2) configure -state normal
    }
$widget(Label43_1) configure -state disable
$widget(Entry43_1) configure -state disable
$widget(Label43_2) configure -state disable
$widget(Entry43_2) configure -state disable
$widget(Label43_3) configure -state disable
$widget(Entry43_3) configure -state disable
$widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
$widget(Label43_4) configure -state disable
$widget(Entry43_4) configure -state disable
$widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
$widget(Button43_1) configure -state disable} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd79" "Button43_5" vTcl:WidgetProc "Toplevel43" 1
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
    frame $top.fra36 \
        -borderwidth 2 -relief groove -height 80 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame65" vTcl:WidgetProc "Toplevel43" 1
    set site_3_0 $top.fra36
    label $site_3_0.lab27 \
        -padx 1 -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_3_0.lab27" "Label49" vTcl:WidgetProc "Toplevel43" 1
    entry $site_3_0.ent29 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NcolFullSize -width 9 
    vTcl:DefineAlias "$site_3_0.ent29" "Entry33" vTcl:WidgetProc "Toplevel43" 1
    pack $site_3_0.lab27 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent29 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    TitleFrame $top.tit97 \
        -ipad 0 -text {Minimum / Maximum Values} 
    vTcl:DefineAlias "$top.tit97" "TitleFrame6" vTcl:WidgetProc "Toplevel43" 1
    bind $top.tit97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit97 getframe]
    frame $site_4_0.cpd72
    set site_5_0 $site_4_0.cpd72
    frame $site_5_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra77" "Frame3" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.fra77
    checkbutton $site_6_0.cpd78 \
        \
        -command {global MinMaxAutoBMP
if {"$MinMaxAutoBMP"=="1"} {
    $widget(Label43_1) configure -state disable
    $widget(Entry43_1) configure -state disable
    $widget(Label43_2) configure -state disable
    $widget(Entry43_2) configure -state disable
    $widget(Label43_3) configure -state disable
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Label43_4) configure -state disable
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button43_1) configure -state disable
    set MinBMP "Auto"
    set MaxBMP "Auto"
    set MinCBMP ""
    set MaxCBMP ""
    } else {
    $widget(Label43_1) configure -state normal
    $widget(Entry43_1) configure -state normal
    $widget(Label43_2) configure -state normal
    $widget(Entry43_2) configure -state normal
    $widget(Label43_3) configure -state normal
    $widget(Entry43_3) configure -state disable
    $widget(Entry43_3) configure -disabledbackground #FFFFFF
    $widget(Label43_4) configure -state normal
    $widget(Entry43_4) configure -state disable
    $widget(Entry43_4) configure -disabledbackground #FFFFFF
    $widget(Button43_1) configure -state normal
    set MinBMP "?"
    set MaxBMP "?"
    set MinCBMP ""
    set MaxCBMP ""
    }} \
        -padx 1 -text Automatic -variable MinMaxAutoBMP 
    vTcl:DefineAlias "$site_6_0.cpd78" "Checkbutton43_1" vTcl:WidgetProc "Toplevel43" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame4" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd79
    checkbutton $site_6_0.cpd78 \
        -padx 1 -text {Enhanced Contrast} -variable MinMaxContrastBMP 
    vTcl:DefineAlias "$site_6_0.cpd78" "Checkbutton43_2" vTcl:WidgetProc "Toplevel43" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra77 \
        -in $site_5_0 -anchor w -expand 1 -fill none -side top 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor w -expand 0 -fill none -side top 
    frame $site_4_0.cpd73
    set site_5_0 $site_4_0.cpd73
    frame $site_5_0.cpd102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd102" "Frame69" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd102
    button $site_6_0.cpd75 \
        -background #ffff00 \
        -command {global MaxBMP MinBMP MaxCBMP MinCBMP TMPMinMaxBmp OpenDirFile MaskCmd

if {$OpenDirFile == 0} {
#read MinMaxBMP
set MinMaxBMPvalues $TMPMinMaxBmp
DeleteFile $MinMaxBMPvalues

set OffsetLig [expr $NligInit - 1]
set OffsetCol [expr $NcolInit - 1]
set FinalNlig [expr $NligEnd - $NligInit + 1]
set FinalNcol [expr $NcolEnd - $NcolInit + 1]

set Fonction "Min / Max Values Determination of the Bin File :"
set Fonction2 "$BMPFileInput"    
set ProgressLine "0"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
update
TextEditorRunTrace "Process The Function Soft/bin/bmp_process/MinMaxBMP.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -ift $InputFormat -oft $OutputFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/bmp_process/MinMaxBMP.exe -if \x22$BMPFileInput\x22 -ift $InputFormat -oft $OutputFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPMinMaxBmp\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

WaitUntilCreated $MinMaxBMPvalues
if [file exists $MinMaxBMPvalues] {
    set f [open $MinMaxBMPvalues r]
    gets $f MaxBMP
    gets $f MinBMP
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f tmp
    gets $f MaxCBMP
    gets $f MinCBMP
    close $f
    }
}} \
        -pady 2 -text MinMax 
    vTcl:DefineAlias "$site_6_0.cpd75" "Button43_1" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_6_0.cpd75 "$site_6_0.cpd75 Button $top all _vTclBalloon"
    bind $site_6_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Find the Min Max values}
    }
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra67" "Frame1" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.fra67
    label $site_6_0.lab68 \
        -text Min 
    vTcl:DefineAlias "$site_6_0.lab68" "Label43_1" vTcl:WidgetProc "Toplevel43" 1
    label $site_6_0.cpd69 \
        -text {Min E.C} 
    vTcl:DefineAlias "$site_6_0.cpd69" "Label43_3" vTcl:WidgetProc "Toplevel43" 1
    pack $site_6_0.lab68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_5_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame6" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd70
    entry $site_6_0.ent71 \
        -background white -foreground #ff0000 -justify center -state disabled \
        -textvariable MinBMP -width 12 
    vTcl:DefineAlias "$site_6_0.ent71" "Entry43_1" vTcl:WidgetProc "Toplevel43" 1
    entry $site_6_0.cpd73 \
        -background white -disabledforeground #0000ff -foreground #0000ff \
        -justify center -state disabled -textvariable MinCBMP -width 12 
    vTcl:DefineAlias "$site_6_0.cpd73" "Entry43_3" vTcl:WidgetProc "Toplevel43" 1
    pack $site_6_0.ent71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame7" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd74
    label $site_6_0.lab68 \
        -text Max 
    vTcl:DefineAlias "$site_6_0.lab68" "Label43_2" vTcl:WidgetProc "Toplevel43" 1
    label $site_6_0.cpd69 \
        -text {Max E.C} 
    vTcl:DefineAlias "$site_6_0.cpd69" "Label43_4" vTcl:WidgetProc "Toplevel43" 1
    pack $site_6_0.lab68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    frame $site_5_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd75" "Frame8" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd75
    entry $site_6_0.ent71 \
        -background white -foreground #ff0000 -justify center -state disabled \
        -textvariable MaxBMP -width 12 
    vTcl:DefineAlias "$site_6_0.ent71" "Entry43_2" vTcl:WidgetProc "Toplevel43" 1
    entry $site_6_0.cpd73 \
        -background white -disabledforeground #0000ff -foreground #0000ff \
        -justify center -state disabled -textvariable MaxCBMP -width 12 
    vTcl:DefineAlias "$site_6_0.cpd73" "Entry43_4" vTcl:WidgetProc "Toplevel43" 1
    pack $site_6_0.ent71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_5_0.cpd102 \
        -in $site_5_0 -anchor center -expand 1 -fill y -padx 5 -side right 
    pack $site_5_0.fra67 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd67 \
        -ipad 0 -text {Valid Pixel Mask File} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame15" vTcl:WidgetProc "Toplevel43" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    frame $site_4_0.cpd68
    set site_5_0 $site_4_0.cpd68
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ValidMaskFile 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry44" vTcl:WidgetProc "Toplevel43" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame24" vTcl:WidgetProc "Toplevel43" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName ValidMaskFile BMPDirInput MaskCmd

set ValidMaskFile ""
set MaskCmd "" 

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $BMPDirInput $types "INPUT VALID PIXEL MASK FILE"
    
if {$FileName != ""} {
    set ValidMaskFile $FileName
    set MaskCmd "-mask \x22$FileName\x22" 
    } else {
    set ValidMaskFile ""
    set MaskCmd "" 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd79" "Button44" vTcl:WidgetProc "Toplevel43" 1
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
    frame $site_4_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame17" vTcl:WidgetProc "Toplevel43" 1
    set site_5_0 $site_4_0.cpd76
    radiobutton $site_5_0.cpd73 \
        -background #ffffff -borderwidth 1 -padx 0 -pady 0 -relief groove \
        -value white -variable ValidMaskColor 
    vTcl:DefineAlias "$site_5_0.cpd73" "Radiobutton7" vTcl:WidgetProc "Toplevel43" 1
    radiobutton $site_5_0.cpd74 \
        -background #999999 -borderwidth 1 -padx 0 -pady 0 -relief sunken \
        -value gray -variable ValidMaskColor 
    vTcl:DefineAlias "$site_5_0.cpd74" "Radiobutton8" vTcl:WidgetProc "Toplevel43" 1
    radiobutton $site_5_0.cpd75 \
        -background #000000 -borderwidth 1 -padx 0 -pady 0 -relief sunken \
        -value black -variable ValidMaskColor 
    vTcl:DefineAlias "$site_5_0.cpd75" "Radiobutton9" vTcl:WidgetProc "Toplevel43" 1
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame5" vTcl:WidgetProc "Toplevel43" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd99 \
        -ipad 0 -text {Output BMP File} 
    vTcl:DefineAlias "$site_3_0.cpd99" "TitleFrame12" vTcl:WidgetProc "Toplevel43" 1
    bind $site_3_0.cpd99 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BMPFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh12" vTcl:WidgetProc "Toplevel43" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd99 \
        -in $site_3_0 -anchor center -expand 1 -fill x -pady 10 -side top 
    frame $top.fra38 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel43" 1
    set site_3_0 $top.fra38
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global BMPDirOutput BMPFileInput BMPFileOutput InputFormat OutputFormat BMPOutputFormat NligInit 
global VarError ErrorMessage Fonction Fonction2 ProgressLine ValidMaskColor
global MinMaxAutoBMP MinMaxContrastBMP OpenDirFile MaskCmd PSPViewGimpBMP
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {"$NligInit"!="0"} {
    set config "true"
    if {"$BMPFileInput"==""} {set config "false"}
    
    if {"$config"=="false"} {
        set VarError ""
        set ErrorMessage "INVALID INPUT FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {"$config"=="true"} {

    set BMPDirOutput [file dirname $BMPFileOutput]
    
    #####################################################################
    #Create Directory
    set BMPDirOutput [PSPCreateDirectoryMask $BMPDirOutput $BMPDirOutput $BMPDirInput]
    #####################################################################       

        if {"$VarWarning"=="ok"} {
            if {$MinMaxAutoBMP == 0} {
                if {$MinMaxContrastBMP == 0} {set MinMaxBMP 0}
                if {$MinMaxContrastBMP == 1} {set MinMaxBMP 2}
                }            
            if {$MinMaxAutoBMP == 1} {
                if {$MinMaxContrastBMP == 0} {set MinMaxBMP 3}
                if {$MinMaxContrastBMP == 1} {set MinMaxBMP 1}
                set MinBMP "-9999"
                set MaxBMP "+9999"
                }

            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            set TestVarName(4) "Min Value"; set TestVarType(4) "float"; set TestVarValue(4) $MinBMP; set TestVarMin(4) "-10000.00"; set TestVarMax(4) "10000.00"
            set TestVarName(5) "Max Value"; set TestVarType(5) "float"; set TestVarValue(5) $MaxBMP; set TestVarMin(5) "-10000.00"; set TestVarMax(5) "10000.00"
            set TestVarName(6) "Initial Number of Col"; set TestVarType(6) "int"; set TestVarValue(6) $NcolFullSize; set TestVarMin(6) "0"; set TestVarMax(6) "100000"
            TestVar 7
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
                set Fonction "Creation of the BMP File :"
                set Fonction2 "$BMPFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                if {$BMPOutputFormat == "bmp8"} {
                    set MaskCmdMask $MaskCmd
                    if {$MaskCmd != ""} { append MaskCmdMask " -mcol $ValidMaskColor" }
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp_file.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift $InputFormat -oft $OutputFormat -clm \x22$ColorMap\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxBMP -min $MinBMP -max $MaxBMP $MaskCmdMask" "k"
                    set f [ open "| Soft/bin/bmp_process/create_bmp_file.exe -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift $InputFormat -oft $OutputFormat -clm \x22$ColorMap\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxBMP -min $MinBMP -max $MaxBMP $MaskCmdMask" r]
                    }
                if {$BMPOutputFormat == "bmp24"} {
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_bmp24_file.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift $InputFormat -oft $OutputFormat -clm \x22$ColorMap\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxBMP -min $MinBMP -max $MaxBMP $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/create_bmp24_file.exe -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift $InputFormat -oft $OutputFormat -clm \x22$ColorMap\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxBMP -min $MinBMP -max $MaxBMP $MaskCmd" r]
                    }
                if {$BMPOutputFormat == "tiff24"} {
                    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_tiff24_file.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift $InputFormat -oft $OutputFormat -clm \x22$ColorMap\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxBMP -min $MinBMP -max $MaxBMP $MaskCmd" "k"
                    set f [ open "| Soft/bin/bmp_process/create_tiff24_file.exe -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift $InputFormat -oft $OutputFormat -clm \x22$ColorMap\x22 -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm $MinMaxBMP -min $MinBMP -max $MaxBMP $MaskCmd" r]
                    }
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
                }
            } else {
            if {"$VarWarning"=="no"} {Window hide $widget(Toplevel43); TextEditorRunTrace "Close Window Create BMP File" "b"}
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
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit "Help/CreateBMPFile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel43" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global DisplayMainMenu OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel43); TextEditorRunTrace "Close Window Create BMP File" "b"
if {$DisplayMainMenu == 1} { set DisplayMainMenu 0 }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel43" 1
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
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra51 \
        -in $top -anchor center -expand 0 -fill x -pady 3 -side top 
    pack $top.tit81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit85 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra91 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
        -in $top -anchor center -expand 0 -fill none -pady 3 -side top 
    pack $top.tit97 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
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
Window show .top43

main $argc $argv
