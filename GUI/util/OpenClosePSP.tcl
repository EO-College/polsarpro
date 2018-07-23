#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

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

        {{[file join . GUI Images logo_ietr2.gif]} {user image} user {}}
        {{[file join . GUI Images logo_saphir2.gif]} {user image} user {}}

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
## Library Procedure:  ::progressbar::Build

namespace eval ::progressbar {
proc Build {w args} {
  variable widgetOptions
  variable widgetGlobals

  if {$widgetGlobals(debug)} {
    puts stderr "pb_Build '$w' '$args'"
  }

  # create the namespace for this instance, and define a few
  # variables
  namespace eval ::progressbar::$w {
    variable options
    variable widgets
    variable info
  }

  # this gives us access to the namespace variables within
  # this proc
  upvar ::progressbar::${w}::widgets widgets
  upvar ::progressbar::${w}::options options
  upvar ::progressbar::${w}::info info

  set info(rgb) ""
  set info(rgbHasChanged) 0

  # this is our widget -- a frame of class Progressbar. Naturally,
  # it will contain other widgets. We create it here because
  # we need it to be able to set our default options.
  set widgets(this) [frame $w -class Progressbar1]

  # this defines all of the default options. We get the
  # values from the option database. Note that if an array
  # value is a list of length one it is an alias to another
  # option, so we just ignore it
  foreach name [array names widgetOptions] {
    if {[llength $widgetOptions($name)] == 1} continue
    set optName  [lindex $widgetOptions($name) 0]
    set optClass [lindex $widgetOptions($name) 1]
    set options($name) [option get $w $optName $optClass]
    if {$widgetGlobals(debug) > 1} {
      puts stderr "pb_Build:Opt '$w' '$optName' '$optClass' '$options($name)'"
    }
  }

  # now apply any of the options supplied on the command
  # line. This may overwrite our defaults, which is OK
  if {[llength $args] > 0} {
    array set options $args
  }
  
  # this will only set the name of canvas's widget, we will
  # later create the canvas in our drawing procedure.
  set widgets(canvas) $w.pb

  # we will later rename the frame's widget proc to be our
  # own custom widget proc. We need to keep track of this
  # new name, so we'll define and store it here...
  set widgets(frame) ::progressbar::${w}::$w

  # this moves the original frame widget proc into our
  # namespace and gives it a handy name
  rename ::$w $widgets(frame)

  # Alias the window to our WidgetProc and pass the window name.
  interp alias {} ::$w {} ::progressbar::WidgetProc $w

  # ok, the thing exists... let's do a bit more configuration. 
  if {[catch "Configure $widgets(this) [array get options]" error]} {
    return -code error $error
    catch {destroy $w}
  }

  return $w
}
}
#############################################################################
## Library Procedure:  ::progressbar::Canonize

namespace eval ::progressbar {
proc Canonize {w object opt} {
  variable widgetOptions
  variable widgetCommands
  variable widgetGlobals
  variable widgetShapes

  if {$widgetGlobals(debug)} {
    puts stderr "pb_Canonize '$w' '$object' '$opt'"
  }

  switch $object {
    command {
      if {[lsearch -exact $widgetCommands $opt] >= 0} {
	return $opt
      }

      # command names aren't stored in an array, and there
      # isn't a way to get all the matches in a list, so
      # we'll stuff the columns in a temporary array so
      # we can use [array names]
      set list $widgetCommands
      foreach element $list {
	set tmp($element) ""
      }
      set matches [array names tmp ${opt}*]
    }

    option {
      if {[info exists widgetOptions($opt)]  && [llength $widgetOptions($opt)] == 3} {
	return $opt
      }
      set list [array names widgetOptions]
      set matches [array names widgetOptions ${opt}*]
    }

    shape {
      if {[lsearch -exact $widgetShapes $opt] >= 0} {
	return $opt
      }

      # same procedure as command
      set list $widgetShapes
      foreach element $list {
	set tmp($element) ""
      }
      set matches [array names tmp ${opt}*]
    }
  }
  if {[llength $matches] == 0} {
    set choices [HumanizeList $list]
    return -code error "unknown $object \"$opt\"; must be one of $choices"
  } elseif {[llength $matches] == 1} {
    # deal with option aliases
    set opt [lindex $matches 0]
    switch $object {
      option {
	if {[llength $widgetOptions($opt)] == 1} {
	  set opt $widgetOptions($opt)
	}
      }
    }
    return $opt
  } else {
      set choices [HumanizeList $list]
      return -code error "ambiguous $object \"$opt\"; must be one of $choices"
  }
}
}
#############################################################################
## Library Procedure:  ::progressbar::Configure

namespace eval ::progressbar {
proc Configure {w args} {
  variable widgetOptions
  variable widgetGlobals

  if {$widgetGlobals(debug)} {
    puts stderr "pb_Configure '$w' '$args'"
  }

  upvar ${w}::widgets widgets
  upvar ${w}::options options
  upvar ${w}::info info
  
  if {[llength $args] == 0} {
    # hmmm. User must be wanting all configuration information
    # note that if the value of an array element is of length
    # one it is an alias, which needs to be handled slightly
    # differently
    set results {}
    foreach opt [lsort [array names widgetOptions]] {
      if {[llength $widgetOptions($opt)] == 1} {
	set alias $widgetOptions($opt)
	set optName $widgetOptions($alias)
	lappend results [list $opt $optName]
      } else {
	set optName  [lindex $widgetOptions($opt) 0]
	set optClass [lindex $widgetOptions($opt) 1]
	set default [option get $w $optName $optClass]
	lappend results [list $opt $optName $optClass $default $options($opt)]
      }
    }
    return $results
  }
  
  # one argument means we are looking for configuration
  # information on a single option
  if {[llength $args] == 1} {
    set opt [Canonize $w option [lindex $args 0]]
    set optName  [lindex $widgetOptions($opt) 0]
    set optClass [lindex $widgetOptions($opt) 1]
    set default [option get $w $optName $optClass]
    set results [list $opt $optName $optClass $default $options($opt)]
    return $results
  }

  # if we have an odd number of values, bail. 
  if {[expr {[llength $args]%2}] == 1} {
    # hmmm. An odd number of elements in args
    return -code error "value for \"[lindex $args end]\" missing"
  }
  
  # Great. An even number of options. Let's make sure they 
  # are all valid before we do anything. Note that Canonize
  # will generate an error if it finds a bogus option; otherwise
  # it returns the canonical option name
  foreach {name value} $args {
    set name [Canonize $w option $name]
    set opts($name) $value
  }

  # process all of the configuration options
  foreach option [array names opts] {
    set newValue $opts($option)
    if {[info exists options($option)]} {
      set oldValue $options($option)
    }

    if {$widgetGlobals(debug) > 2} {
      puts stderr "pb_Configure:Opt '$option' n='$newValue' o='$oldValue'"
    }
    switch -- $option {
      -background  -
      -borderwidth -
      -relief      {
	if {[winfo exists $widgets(this)]} {
	  $widgets(frame) configure $option $newValue
	  set options($option) [$widgets(frame) cget $option]
	}
      }
      -color {
        switch -- $newValue {
	  @blue0    -
	  @blue1    -
	  @blue2    -
	  @blue3    -
	  @blue4    -
	  @green0   -
	  @green1   -
	  @green2   -
	  @green3   -
	  @yellow0  -
	  @yellow1  -
	  @red0     -
	  @red1     -
	  @magenta0 -
	  @brown0   -
	  @brown1   -
	  @gray0    {
	    set info(rgb) $widgetGlobals($newValue)
	  }
	  @* {
	    set info(rgb) $widgetGlobals(@saphir)
	  }
	  default {
	    set info(rgb) [RGBs $newValue]
	  }
	}
	set info(rgbHasChanged) 1
      }
      -percent {
	set options($option) $newValue
      }
      -shape {
	set options($option) [Canonize $w shape $newValue]
	set info(rgbHasChanged) 1
      }
      -variable {
	# hmmm .. are there any traces left? Yes! Destroy!
	if {[info procs Trace($w)] != ""} {
	  uplevel #0 trace vdelete $oldValue wu ::progressbar::Trace($w)
	  unset widgetGlobals($w)
	  rename Trace($w) {}
	}
	if {$newValue != ""} {
	  # there is a new variable to trace. build a new proc to trace it.
	  proc ::progressbar::Trace($w) {name1 name2 op} "
	    variable widgetGlobals

	    if {\$widgetGlobals(debug)} {
	      puts stderr \"pb_Trace($w) '\$name1' '\$name2' '\$op'\"
	    }
	    switch -- \$op {
	      w {
		if {\$name2 != \"\"} {
		  upvar 1 \${name1}(\$name2) var
		  catch {$w configure -percent \$var}
		} else {
		  upvar 1 \$name1 var
		  catch {$w configure -percent \$var}
		}
	      }
	      u {
		if {\[info procs Trace($w)\] != \"\"} {  unset widgetGlobals($w);  rename Trace($w) {};  }
	      }
	    }
	  "
	  # install trace proc for variable
	  uplevel #0 trace variable $newValue wu ::progressbar::Trace($w)
	}
	set options($option) $newValue
	set widgetGlobals($w) $newValue
      }
      -width {
	if {$newValue < 20} {
	  return -code error "a -width of less than 20 is not supported."
	}
	if {[winfo exists $widgets(canvas)]} {
	  $widgets(canvas) configure $option $newValue
	  set options($option) [$widgets(canvas) cget $option]
	} else {
          set options($option) $newValue
	}
      }
      -textvalue {
        set options($option) $newValue
	if {![winfo exists $widgets(canvas)]} { continue }
	$widgets(canvas) itemconfigure ttxt -text $newValue
      }
      -textcolor {
        set options($option) $newValue
	if {![winfo exists $widgets(canvas)]} { continue }
	$widgets(canvas) itemconfigure ttxt -fill $newValue
      }
    }
  }

  Draw $w
}
}
#############################################################################
## Library Procedure:  ::progressbar::DestroyHandler

namespace eval ::progressbar {
proc DestroyHandler {w} {
  variable widgetGlobals

  if {$widgetGlobals(debug)} {
    puts stderr "pb_DestroyHandler '$w'"
  }

  # hmmm .. are there any traces left? Yes! Destroy!
  if {[info procs Trace($w)] != ""} {
    uplevel 1 trace vdelete $widgetGlobals($w) wu ::progressbar::Trace($w)
    unset widgetGlobals($w)
    rename Trace($w) {}
  }

  # if the widget actually being destroyed is of class Progressbar,
  # crush the namespace and kill the proc. Get it? Crush. Kill. 
  # Destroy. Heh. Danger Will Robinson! Oh, man! I'm so funny it
  # brings tears to my eyes.
  if {[string compare [winfo class $w] "Progressbar1"] == 0} {
    namespace delete ::progressbar::$w
    rename $w {}
  }
}
}
#############################################################################
## Library Procedure:  ::progressbar::Draw

namespace eval ::progressbar {
proc Draw {w} {
  variable widgetGlobals

  if {$widgetGlobals(debug) > 2} {
    puts stderr "pb_Draw '$w'"
  }

  upvar ${w}::widgets widgets
  upvar ${w}::options options
  upvar ${w}::info info

  set width   $options(-width)
  set percent $options(-percent)
  set text    $options(-textvalue)

  if {$options(-shape) == "flat"} {
    set minDisplay 0
    if {[llength $info(rgb)] == 7} {
      set rgb(0) [lindex $info(rgb) 6]
    } else {
      set rgb(0) [lindex $info(rgb) 2]
    }
    set rgb(1) $rgb(0)
    set rgb(2) $rgb(0)
    set rgb(3) $rgb(0)
    set rgb(4) $rgb(0)
    set rgb(5) $rgb(0)
  } else {
    set minDisplay 7
    set rgb(0) [lindex $info(rgb) 0]
    set rgb(1) [lindex $info(rgb) 1]
    set rgb(2) [lindex $info(rgb) 2]
    set rgb(3) [lindex $info(rgb) 3]
    set rgb(4) [lindex $info(rgb) 4]
    set rgb(5) [lindex $info(rgb) 5]
  }

  if {$percent < 0} {
    set percent 0
  } elseif {$percent > 100} {
    set percent 100
  }
  if {$percent == 0} {
    set mark $minDisplay
  } else {
    set mark [expr (($width - $minDisplay) / 100.0 * $percent) + $minDisplay]
  }

  if {![winfo exists $widgets(canvas)]} {
    canvas $widgets(canvas) -width $width -height 14 -bd 0 -highlightthickness 0
    pack $widgets(canvas) -side left -anchor nw -fill both

    foreach {type color tag coords opts} $widgetGlobals(toDraw) {
      eval $widgets(canvas) create $type $coords -fill $color -tag t$tag $opts
    }

    set info(rgbHasChanged) 0
    # nothing more to do
    return
  }

  foreach {type color tag coords opts} $widgetGlobals(toDraw) {
    eval $widgets(canvas) coords t$tag $coords
    if {$info(rgbHasChanged)} {
      eval $widgets(canvas) itemconfigure t$tag -fill $color
    }
  }
  set info(rgbHasChanged) 0
}
}
#############################################################################
## Library Procedure:  ::progressbar::HumanizeList

namespace eval ::progressbar {
proc HumanizeList {list} {
  variable widgetGlobals

  if {$widgetGlobals(debug)} {
    puts stderr "pb_HumanizeList $list"
  }

  if {[llength $list] == 1} {
    return [lindex $list 0]
  } else {
    set list [lsort $list]
    set secondToLast [expr {[llength $list] -2}]
    set most [lrange $list 0 $secondToLast]
    set last [lindex $list end]

    return "[join $most {, }] or $last"
  }
}
}
#############################################################################
## Library Procedure:  ::progressbar::Init

namespace eval ::progressbar {
proc Init {} {
  variable widgetOptions
  variable widgetCommands
  variable widgetGlobals
  variable widgetShapes

  if {$widgetGlobals(debug)} {
    puts stderr "pb_Init"
  }

  # here we match up command line options with option database names
  # and classes. As it turns out, this is a handy reference of all of the
  # available options. Note that if an item has a value with only one
  # item (like -bd, for example) it is a synonym and the value is the
  # actual item.

  array set widgetOptions {
    -background		{background	Background	}
    -borderwidth	{borderWidth	BorderWidth	}
    -color		{color		Color		}
    -cursor		{cursor		Cursor		}
    -percent		{percent	Percent		}
    -relief		{relief		Relief		}
    -shape		{shape		Shape		}
    -variable		{variable	Variable	}
    -width		{width		Width		}
    -textvalue		{textValue	TextValue	}
    -textcolor		{textColor	TextColor	}

    -bg			-background
    -bd			-borderwidth
    -pc			-percent
  } 

  # this defines the valid widget commands. It's important to
  # list them here; we use this list to validate commands and
  # expand abbreviations.

  set widgetCommands {
      cget
      configure
      incr
      step
  }

  # this defines the valid shape options. It's important to
  # list them here; we use this list to validate options and
  # expand abbreviations.

  set widgetShapes {
      3D
      3d
      flat
  }
      
  set widgetGlobals(toDraw) {
    rect #bdbdbd es0 {[expr $mark +3] 2 [expr $width -2] 11} {-outline ""}
    line #525252 es1 {[expr $mark +1] 2 [expr $mark +1] 11} {}
    line #8c8c8c es2 {[expr $mark +2] 11 [expr $mark +2] 2  [expr $width -4] 2} {}
    line #8c8c8c es3 {[expr $mark +3] 11 [expr $width -3] 11  [expr $width -3] 3} {}
    line $rgb(0) pb0 {4 11 [expr $mark -1] 11 [expr $mark -1] 3} {}
    line $rgb(1) pb1 {3 11 3 10 [expr $mark -2] 10 [expr $mark -2] 2  [expr $mark -1] 2 4 2} {}
    line $rgb(2) pb2 {3 2 2 2 2 11 2 10 3 10 3 9 [expr $mark -3] 9  [expr $mark -3] 3 [expr $mark -2] 3 4 3} {}
    line $rgb(3) pb3 {3 3 3 9 3 8 [expr $mark -3] 8 [expr $mark -3] 4 4 4} {}
    line $rgb(4) pb4 {3 4 3 8 3 7 [expr $mark -3] 7 [expr $mark -3] 5 4 5} {}
    line $rgb(5) pb5 {3 5 3 7 3 6 [expr $mark -3] 6} {}
    line #000000 mrk {$mark 1 $mark 12} {}
    line #adadad fr0 {0 12 0 0 [expr $width -1] 0} {}
    line #ffffff fr1 {1 13 [expr $width -1] 13 [expr $width -1] 1} {}
    line #000000 fr2 {1 1 [expr $width -2] 1 [expr $width -2] 12 1 12 1 1} {}
    text #000000 txt {[expr $width / 2] 8} {-text $text}
  }

  set widgetGlobals(@blue0) {#000052 #0031ce #3163ff #639cff #9cceff #efefef}
  set widgetGlobals(@blue1) {#000021 #00639c #009cce #00ceff #63ffff #ceffff}
  set widgetGlobals(@blue2) {#000052 #31319c #6363ce #9c9cff #ceceff #efefef}
  set widgetGlobals(@blue3)	 {#21214a #52527b #63639c #8484bd #b5b5ef #ceceff}
  set widgetGlobals(@blue4) {#29396b #4a6b9c #6384b5 #739cd6 #94b5ef #adceff}
  set widgetGlobals(@green0)	 {#003131 #08736b #318c94 #5abdad #63dece #ceffef}
  set widgetGlobals(@green1) {#001000 #003100 #316331 #639c63 #9cce9c #ceffce}
  set widgetGlobals(@green2) {#002100 #006331 #319c63 #31ce63 #63ff9c #ceffce}
  set widgetGlobals(@green3) {#003131 #316363 #427b7b #639c9c #9ccece #bdefef}
  set widgetGlobals(@yellow0) {#101010 #636300 #9c9c00 #cece00 #ffff00 #ffff9c}
  set widgetGlobals(@yellow1) {#8c7321 #cead39 #e7c642 #f7de63 #f7de63 #ffffe7}
  set widgetGlobals(@red0) {#420000 #9c0000 #ce3131 #ff6363 #ff9c9c #ffcece}
  set widgetGlobals(@red1) {#210000 #9c3100 #ce6331 #ff9c63 #ffce9c #ffffce}
  set widgetGlobals(@magenta0) {#210000 #630063 #9c319c #ce63ce #ff9cff #ffceff}
  set widgetGlobals(@brown0) {#210000 #633100 #9c6331 #ce9c63 #efb573 #ffdeb5}
  set widgetGlobals(@brown1) {#310000 #7b4242 #9c6363 #ce9c9c #efcece #ffdede}
  set widgetGlobals(@gray0) {#212121 #525252 #737373 #adadad #cecece #efefef}

  # this initializes the option database. Kinda gross, but it works
  # (I think).
  set tmpWidget ".__tmp__"

  # steal some options from frame widgets; we only want a subset
  # so we'll use a slightly different method. No harm in *not*
  # adding in the one or two that we don't use... :-)
  label $tmpWidget
  foreach option [list Background Relief] {
    set values [$tmpWidget configure -[string tolower $option]]
    option add *Progressbar1.$option [lindex $values 3]
  }
  destroy $tmpWidget

  # these are unique to us...
  option add *Progressbar1.borderWidth	5		widgetDefault
  option add *Progressbar1.color	@blue0		widgetDefault
  option add *Progressbar1.percent	0		widgetDefault
  option add *Progressbar1.shape	3D		widgetDefault
  option add *Progressbar1.variable	{}		widgetDefault
  option add *Progressbar1.width	180		widgetDefault
  option add *Progressbar1.textColor	black		widgetDefault

  # define the class bindings
  # this allows us to clean up some things when we go away
  bind Progressbar1 <Destroy> [list ::progressbar::DestroyHandler %W]
}
}
#############################################################################
## Library Procedure:  ::progressbar::RGBs

namespace eval ::progressbar {
proc RGBs {color} {
  variable widgetGlobals

  if {$widgetGlobals(debug)} {
    puts stderr "pb_RGB '$color'"
  }

  # get rgb values of given color
  set color [winfo rgb . $color]

  set R [expr int([lindex $color 0] / 256)]
  set G [expr int([lindex $color 1] / 256)]
  set B [expr int([lindex $color 2] / 256)]

  set rgb {}
  foreach factor {0.13 0.32 0.45 0.68 0.8 0.93} {
    set r [expr int($R * $factor)]
    set g [expr int($G * $factor)]
    set b [expr int($B * $factor)]
    lappend rgb [format "#%02x%02x%02x" $r $g $b]
  }
  lappend rgb [format "#%02x%02x%02x" $R $G $B]

  return $rgb
}
}
#############################################################################
## Library Procedure:  ::progressbar::WidgetProc

namespace eval ::progressbar {
proc WidgetProc {w args} {
  variable widgetOptions
  variable widgetGlobals

  if {[llength $args] == 0} {
      return -code error [vTcl:WrongNumArgs "$w option ?arg arg ...?"]
  }

  set command [lindex $args 0]
  set args [lrange $args 1 end]

  if {$widgetGlobals(debug)} {
    puts stderr "pb_WidgetProc '$w' '$command' '$args'"
  }

  upvar ::progressbar::${w}::widgets   widgets
  upvar ::progressbar::${w}::options   options
  upvar ::progressbar::${w}::info info

  set command [Canonize $w command $command]

  set result ""

  switch $command {
    cget {
      if {[llength $args] != 1} {
	return -code error "wrong # args: should be $w cget option"
      }
      set opt [Canonize $w option [lindex $args 0]]
      set result $options($opt)
    }

    configure {
      set result [eval Configure {$w} $args]
    }

    incr -
    step {
      set val 1
      if {[llength $args] > 1} {
      	return -code error "wrong # args: should be $w $command <incrValue>"
      } elseif {[llength $args] == 1} {
      	set val $args
      }
      set percent [$w cget -percent]
      set result [eval Configure $w -percent [expr $percent + $val]]
    }

    default {
	return -code error "bad option \"$command\": must be cget or configure"
    }
  }
  return $result
}
}
#############################################################################
## Library Procedure:  ::progressbar::progressbar

namespace eval ::progressbar {
proc progressbar {args} {
  variable widgetOptions
  variable widgetGlobals

  # perform a one time initialization
  if {![info exists widgetOptions]} {
    __progressbar_Setup
    Init
  }

  if {$widgetGlobals(debug)} {
    puts stderr "pb_progressbar '$args'"
  }

  # make sure we at least have a widget name
  if {[llength $args] == 0} {
    return -code error  "wrong # args: should be \"progressbar pathName ?options?\""
  }

  # ... and make sure a widget doesn't already exist by that name
  if {[winfo exists [lindex $args 0]]} {
    return -code error "window name \"[lindex $args 0]\" already exists"
  }

  # and check that all of the args are valid
  foreach {name value} [lrange $args 1 end] {
    Canonize [lindex $args 0] option $name
  }

  # build it...
  set w [eval Build $args]

  # and we are done!
  return $w
}
}
#############################################################################
## Library Procedure:  __progressbar_Setup

proc ::__progressbar_Setup {} {
  namespace eval ::progressbar {
    # this is the public interface
    namespace export progressbar

    # these contain references to available options
    variable widgetOptions

    # these contain references to available commands
    variable widgetCommands

    # these contain references to available options for shape option
    variable widgetShapes

    # these contain references to global variables
    variable widgetGlobals

    set widgetGlobals(debug) 0
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
    set base .top345
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra30 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra30
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-background 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra103 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra103
    namespace eval ::widgets::$site_4_0.lab104 {
        array set save {-background 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.lab105 {
        array set save {-background 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-background 1 -text 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-background 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$base.pro35 {
        array set save {-background 1 -variable 1 -width 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top345
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
    wm geometry $top 200x200+66+66; update
    wm maxsize $top 1604 1185
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

proc vTclWindow.top345 {base} {
    if {$base == ""} {
        set base .top345
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -background #ffffff 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x100+200+200; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Message"
    vTcl:DefineAlias "$top" "Toplevel345" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra30 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra30" "Frame82" vTcl:WidgetProc "Toplevel345" 1
    set site_3_0 $top.fra30
    label $site_3_0.cpd67 \
        -background #ffffff \
        -image [vTcl:image:get_image [file join . GUI Images logo_ietr2.gif]] \
        -text label 
    vTcl:DefineAlias "$site_3_0.cpd67" "Label1" vTcl:WidgetProc "Toplevel345" 1
    frame $site_3_0.fra103 \
        -borderwidth 2 -background #ffffff -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra103" "Frame657" vTcl:WidgetProc "Toplevel345" 1
    set site_4_0 $site_3_0.fra103
    label $site_4_0.lab104 \
        -background #ffffff -text {PROCESSING THE FUNCTION :} 
    vTcl:DefineAlias "$site_4_0.lab104" "Label75" vTcl:WidgetProc "Toplevel345" 1
    label $site_4_0.lab105 \
        -background #ffffff -textvariable Fonction -width 35 
    vTcl:DefineAlias "$site_4_0.lab105" "Label76" vTcl:WidgetProc "Toplevel345" 1
    label $site_4_0.cpd71 \
        -background #ffffff -text { . } \
        -textvariable Fonction2 
    vTcl:DefineAlias "$site_4_0.cpd71" "Label78" vTcl:WidgetProc "Toplevel345" 1
    pack $site_4_0.lab104 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.lab105 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    label $site_3_0.cpd68 \
        -background #ffffff \
        -image [vTcl:image:get_image [file join . GUI Images logo_saphir2.gif]] \
        -text label 
    vTcl:DefineAlias "$site_3_0.cpd68" "Label2" vTcl:WidgetProc "Toplevel345" 1
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 0 -fill y -side left 
    pack $site_3_0.fra103 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 0 -fill y -ipadx 5 -side right 
    ::progressbar::progressbar $top.pro35 \
        -background #ffffff -variable ProgressLine -width 490 
    vTcl:DefineAlias "$top.pro35" "Progressbar2" vTcl:WidgetProc "Toplevel345" 1
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra30 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.pro35 \
        -in $top -anchor center -expand 0 -fill none -side top 

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
Window show .top345

main $argc $argv
